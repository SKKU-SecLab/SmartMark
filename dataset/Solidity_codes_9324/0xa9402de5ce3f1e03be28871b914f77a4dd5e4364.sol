

pragma solidity =0.6.7 >=0.6.0 <0.8.0 >=0.6.7 <0.7.0;


abstract contract CoinJoinLike {
    function systemCoin() virtual public view returns (address);
    function safeEngine() virtual public view returns (address);
    function join(address, uint256) virtual external;
}


abstract contract CollateralJoinLike {
    function safeEngine() virtual public view returns (address);
    function collateralType() virtual public view returns (bytes32);
    function collateral() virtual public view returns (address);
    function decimals() virtual public view returns (uint256);
    function contractEnabled() virtual public view returns (uint256);
    function join(address, uint256) virtual external;
}


abstract contract ERC20Like {
    function approve(address guy, uint wad) virtual public returns (bool);
    function transfer(address dst, uint wad) virtual public returns (bool);
    function balanceOf(address) virtual external view returns (uint256);
    function transferFrom(address src, address dst, uint wad)
        virtual
        public
        returns (bool);
}


abstract contract GebSafeManagerLike {
    function safes(uint256) virtual public view returns (address);
    function ownsSAFE(uint256) virtual public view returns (address);
    function safeCan(address,uint256,address) virtual public view returns (uint256);
}


abstract contract LiquidationEngineLike_3 {
    function safeSaviours(address) virtual public view returns (uint256);
}


abstract contract OracleRelayerLike_2 {
    function collateralTypes(bytes32) virtual public view returns (address, uint256, uint256);
    function liquidationCRatio(bytes32) virtual public view returns (uint256);
    function redemptionPrice() virtual public returns (uint256);
}


abstract contract PriceFeedLike {
    function priceSource() virtual public view returns (address);
    function read() virtual public view returns (uint256);
    function getResultWithValidity() virtual external view returns (uint256,bool);
}


abstract contract SAFEEngineLike_8 {
    function approveSAFEModification(address) virtual external;
    function safeRights(address,address) virtual public view returns (uint256);
    function collateralTypes(bytes32) virtual public view returns (
        uint256 debtAmount,        // [wad]
        uint256 accumulatedRate,   // [ray]
        uint256 safetyPrice,       // [ray]
        uint256 debtCeiling,       // [rad]
        uint256 debtFloor,         // [rad]
        uint256 liquidationPrice   // [ray]
    );
    function safes(bytes32,address) virtual public view returns (
        uint256 lockedCollateral,  // [wad]
        uint256 generatedDebt      // [wad]
    );
    function modifySAFECollateralization(
        bytes32 collateralType,
        address safe,
        address collateralSource,
        address debtDestination,
        int256 deltaCollateral,    // [wad]
        int256 deltaDebt           // [wad]
    ) virtual external;
}


abstract contract SAFESaviourRegistryLike {
    function markSave(bytes32 collateralType, address safeHandler) virtual external;
}


abstract contract TaxCollectorLike {
    function taxSingle(bytes32) public virtual returns (uint256);
}



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
}








abstract contract SafeSaviourLike is ReentrancyGuard {
    modifier liquidationEngineApproved(address saviour) {
        require(liquidationEngine.safeSaviours(saviour) == 1, "SafeSaviour/not-approved-in-liquidation-engine");
        _;
    }
    modifier controlsSAFE(address owner, uint256 safeID) {
        require(owner != address(0), "SafeSaviour/null-owner");
        require(either(owner == safeManager.ownsSAFE(safeID), safeManager.safeCan(safeManager.ownsSAFE(safeID), safeID, owner) == 1), "SafeSaviour/not-owning-safe");

        _;
    }

    LiquidationEngineLike_3   public liquidationEngine;
    TaxCollectorLike        public taxCollector;
    OracleRelayerLike_2       public oracleRelayer;
    GebSafeManagerLike      public safeManager;
    SAFEEngineLike_8          public safeEngine;
    SAFESaviourRegistryLike public saviourRegistry;

    uint256 public keeperPayout;          // [wad]
    uint256 public minKeeperPayoutValue;  // [wad]
    uint256 public payoutToSAFESize;

    uint256 public constant ONE               = 1;
    uint256 public constant HUNDRED           = 100;
    uint256 public constant THOUSAND          = 1000;
    uint256 public constant WAD_COMPLEMENT    = 10**9;
    uint256 public constant WAD               = 10**18;
    uint256 public constant RAY               = 10**27;
    uint256 public constant MAX_UINT          = uint(-1);

    function both(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := and(x, y) }
    }
    function either(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := or(x, y)}
    }

    event SaveSAFE(address indexed keeper, bytes32 indexed collateralType, address indexed safeHandler, uint256 collateralAddedOrDebtRepaid);

    function saveSAFE(address,bytes32,address) virtual external returns (bool,uint256,uint256);
    function getKeeperPayoutValue() virtual public returns (uint256);
    function keeperPayoutExceedsMinValue() virtual public returns (bool);
    function canSave(bytes32,address) virtual external returns (bool);
    function tokenAmountUsedToSave(bytes32,address) virtual public returns (uint256);
}




abstract contract SaviourCRatioSetterLike is ReentrancyGuard {
    mapping (address => uint256) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {
        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {
        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {
        require(authorizedAccounts[msg.sender] == 1, "SaviourCRatioSetter/account-not-authorized");
        _;
    }

    modifier controlsSAFE(address owner, uint256 safeID) {
        require(owner != address(0), "SaviourCRatioSetter/null-owner");
        require(either(owner == safeManager.ownsSAFE(safeID), safeManager.safeCan(safeManager.ownsSAFE(safeID), safeID, owner) == 1), "SaviourCRatioSetter/not-owning-safe");

        _;
    }

    OracleRelayerLike_2  public oracleRelayer;
    GebSafeManagerLike public safeManager;

    mapping(bytes32 => uint256)                     public defaultDesiredCollateralizationRatios;
    mapping(bytes32 => uint256)                     public minDesiredCollateralizationRatios;
    mapping(bytes32 => mapping(address => uint256)) public desiredCollateralizationRatios;

    uint256 public constant MAX_CRATIO        = 1000;
    uint256 public constant CRATIO_SCALE_DOWN = 10**25;

    function both(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := and(x, y) }
    }
    function either(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := or(x, y)}
    }

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 indexed parameter, address data);
    event SetDefaultCRatio(bytes32 indexed collateralType, uint256 cRatio);
    event SetMinDesiredCollateralizationRatio(
      bytes32 indexed collateralType,
      uint256 cRatio
    );
    event SetDesiredCollateralizationRatio(
      address indexed caller,
      bytes32 indexed collateralType,
      uint256 safeID,
      address indexed safeHandler,
      uint256 cRatio
    );

    function setDefaultCRatio(bytes32, uint256) virtual external;
    function setMinDesiredCollateralizationRatio(bytes32 collateralType, uint256 cRatio) virtual external;
    function setDesiredCollateralizationRatio(bytes32 collateralType, uint256 safeID, uint256 cRatio) virtual external;
}


abstract contract UniswapLiquidityManagerLike {
    function getToken0FromLiquidity(uint256) virtual public view returns (uint256);
    function getToken1FromLiquidity(uint256) virtual public view returns (uint256);

    function getLiquidityFromToken0(uint256) virtual public view returns (uint256);
    function getLiquidityFromToken1(uint256) virtual public view returns (uint256);

    function removeLiquidity(
      uint256 liquidity,
      uint128 amount0Min,
      uint128 amount1Min,
      address to
    ) public virtual returns (uint256, uint256);
}



contract SafeMath_2 {

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







contract NativeUnderlyingUniswapV2SafeSaviour is SafeMath_2, SafeSaviourLike {

    mapping (address => uint256) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "NativeUnderlyingUniswapV2SafeSaviour/account-not-authorized");
        _;
    }

    mapping (address => uint256) public allowedUsers;
    function allowUser(address usr) external isAuthorized {

        allowedUsers[usr] = 1;
        emit AllowUser(usr);
    }
    function disallowUser(address usr) external isAuthorized {

        allowedUsers[usr] = 0;
        emit DisallowUser(usr);
    }
    modifier isAllowed {

        require(
          either(restrictUsage == 0, both(restrictUsage == 1, allowedUsers[msg.sender] == 1)),
          "NativeUnderlyingUniswapV2SafeSaviour/account-not-allowed"
        );
        _;
    }

    struct Reserves {
        uint256 systemCoins;
        uint256 collateralCoins;
    }

    uint256                        public restrictUsage;

    bool                           public isSystemCoinToken0;
    mapping(address => uint256)    public lpTokenCover;
    mapping(address => Reserves)   public underlyingReserves;
    UniswapLiquidityManagerLike    public liquidityManager;
    ERC20Like                      public systemCoin;
    CoinJoinLike                   public coinJoin;
    CollateralJoinLike             public collateralJoin;
    ERC20Like                      public lpToken;
    ERC20Like                      public collateralToken;
    PriceFeedLike                  public systemCoinOrcl;
    SaviourCRatioSetterLike        public cRatioSetter;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event AllowUser(address usr);
    event DisallowUser(address usr);
    event ModifyParameters(bytes32 indexed parameter, uint256 val);
    event ModifyParameters(bytes32 indexed parameter, address data);
    event Deposit(
      address indexed caller,
      address indexed safeHandler,
      uint256 lpTokenAmount
    );
    event Withdraw(
      address indexed caller,
      address indexed safeHandler,
      address dst,
      uint256 lpTokenAmount
    );
    event GetReserves(
      address indexed caller,
      address indexed safeHandler,
      uint256 systemCoinAmount,
      uint256 collateralAmount,
      address dst
    );

    constructor(
        bool isSystemCoinToken0_,
        address coinJoin_,
        address collateralJoin_,
        address cRatioSetter_,
        address systemCoinOrcl_,
        address liquidationEngine_,
        address taxCollector_,
        address oracleRelayer_,
        address safeManager_,
        address saviourRegistry_,
        address liquidityManager_,
        address lpToken_,
        uint256 minKeeperPayoutValue_
    ) public {
        require(coinJoin_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-coin-join");
        require(collateralJoin_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-collateral-join");
        require(cRatioSetter_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-cratio-setter");
        require(systemCoinOrcl_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-system-coin-oracle");
        require(oracleRelayer_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-oracle-relayer");
        require(liquidationEngine_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-liquidation-engine");
        require(taxCollector_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-tax-collector");
        require(safeManager_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-safe-manager");
        require(saviourRegistry_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-saviour-registry");
        require(liquidityManager_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-liq-manager");
        require(lpToken_ != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-lp-token");
        require(minKeeperPayoutValue_ > 0, "NativeUnderlyingUniswapV2SafeSaviour/invalid-min-payout-value");

        authorizedAccounts[msg.sender] = 1;

        isSystemCoinToken0   = isSystemCoinToken0_;
        minKeeperPayoutValue = minKeeperPayoutValue_;

        coinJoin             = CoinJoinLike(coinJoin_);
        collateralJoin       = CollateralJoinLike(collateralJoin_);
        cRatioSetter         = SaviourCRatioSetterLike(cRatioSetter_);
        liquidationEngine    = LiquidationEngineLike_3(liquidationEngine_);
        taxCollector         = TaxCollectorLike(taxCollector_);
        oracleRelayer        = OracleRelayerLike_2(oracleRelayer_);
        systemCoinOrcl       = PriceFeedLike(systemCoinOrcl_);
        systemCoin           = ERC20Like(coinJoin.systemCoin());
        safeEngine           = SAFEEngineLike_8(coinJoin.safeEngine());
        safeManager          = GebSafeManagerLike(safeManager_);
        saviourRegistry      = SAFESaviourRegistryLike(saviourRegistry_);
        liquidityManager     = UniswapLiquidityManagerLike(liquidityManager_);
        lpToken              = ERC20Like(lpToken_);
        collateralToken      = ERC20Like(collateralJoin.collateral());

        systemCoinOrcl.getResultWithValidity();
        oracleRelayer.redemptionPrice();

        require(collateralJoin.contractEnabled() == 1, "NativeUnderlyingUniswapV2SafeSaviour/join-disabled");
        require(address(collateralToken) != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-col-token");
        require(address(safeEngine) != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-safe-engine");
        require(address(systemCoin) != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-sys-coin");

        emit AddAuthorization(msg.sender);
        emit ModifyParameters("minKeeperPayoutValue", minKeeperPayoutValue);
        emit ModifyParameters("oracleRelayer", oracleRelayer_);
        emit ModifyParameters("taxCollector", taxCollector_);
        emit ModifyParameters("systemCoinOrcl", systemCoinOrcl_);
        emit ModifyParameters("liquidationEngine", liquidationEngine_);
        emit ModifyParameters("liquidityManager", liquidityManager_);
    }

    function modifyParameters(bytes32 parameter, uint256 val) external isAuthorized {

        if (parameter == "minKeeperPayoutValue") {
            require(val > 0, "NativeUnderlyingUniswapV2SafeSaviour/null-min-payout");
            minKeeperPayoutValue = val;
        }
        else if (parameter == "restrictUsage") {
            require(val <= 1, "NativeUnderlyingUniswapV2SafeSaviour/invalid-restriction");
            restrictUsage = val;
        }
        else revert("NativeUnderlyingUniswapV2SafeSaviour/modify-unrecognized-param");
        emit ModifyParameters(parameter, val);
    }
    function modifyParameters(bytes32 parameter, address data) external isAuthorized {

        require(data != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-data");

        if (parameter == "systemCoinOrcl") {
            systemCoinOrcl = PriceFeedLike(data);
            systemCoinOrcl.getResultWithValidity();
        }
        else if (parameter == "oracleRelayer") {
            oracleRelayer = OracleRelayerLike_2(data);
            oracleRelayer.redemptionPrice();
        }
        else if (parameter == "liquidityManager") {
            liquidityManager = UniswapLiquidityManagerLike(data);
        }
        else if (parameter == "liquidationEngine") {
            liquidationEngine = LiquidationEngineLike_3(data);
        }
        else if (parameter == "taxCollector") {
            taxCollector = TaxCollectorLike(data);
        }
        else revert("NativeUnderlyingUniswapV2SafeSaviour/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    function getReserves(uint256 safeID, address dst) external controlsSAFE(msg.sender, safeID) nonReentrant {

        address safeHandler = safeManager.safes(safeID);
        (uint256 systemCoins, uint256 collateralCoins) =
          (underlyingReserves[safeHandler].systemCoins, underlyingReserves[safeHandler].collateralCoins);

        require(either(systemCoins > 0, collateralCoins > 0), "NativeUnderlyingUniswapV2SafeSaviour/no-reserves");
        delete(underlyingReserves[safeManager.safes(safeID)]);

        if (systemCoins > 0) {
          systemCoin.transfer(dst, systemCoins);
        }

        if (collateralCoins > 0) {
          collateralToken.transfer(dst, collateralCoins);
        }

        emit GetReserves(msg.sender, safeHandler, systemCoins, collateralCoins, dst);
    }

    function deposit(uint256 safeID, uint256 lpTokenAmount) external isAllowed() liquidationEngineApproved(address(this)) nonReentrant {

        require(lpTokenAmount > 0, "NativeUnderlyingUniswapV2SafeSaviour/null-lp-amount");

        address safeHandler = safeManager.safes(safeID);
        require(safeHandler != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-handler");

        (, uint256 safeDebt) =
          SAFEEngineLike_8(collateralJoin.safeEngine()).safes(collateralJoin.collateralType(), safeHandler);
        require(safeDebt > 0, "NativeUnderlyingUniswapV2SafeSaviour/safe-does-not-have-debt");

        lpTokenCover[safeHandler] = add(lpTokenCover[safeHandler], lpTokenAmount);
        require(lpToken.transferFrom(msg.sender, address(this), lpTokenAmount), "NativeUnderlyingUniswapV2SafeSaviour/could-not-transfer-lp");

        emit Deposit(msg.sender, safeHandler, lpTokenAmount);
    }
    function withdraw(uint256 safeID, uint256 lpTokenAmount, address dst) external controlsSAFE(msg.sender, safeID) nonReentrant {

        require(lpTokenAmount > 0, "NativeUnderlyingUniswapV2SafeSaviour/null-lp-amount");

        address safeHandler = safeManager.safes(safeID);
        require(lpTokenCover[safeHandler] >= lpTokenAmount, "NativeUnderlyingUniswapV2SafeSaviour/not-enough-to-withdraw");

        lpTokenCover[safeHandler] = sub(lpTokenCover[safeHandler], lpTokenAmount);
        lpToken.transfer(dst, lpTokenAmount);

        emit Withdraw(msg.sender, safeHandler, dst, lpTokenAmount);
    }

    function saveSAFE(address keeper, bytes32 collateralType, address safeHandler) override external returns (bool, uint256, uint256) {

        require(address(liquidationEngine) == msg.sender, "NativeUnderlyingUniswapV2SafeSaviour/caller-not-liquidation-engine");
        require(keeper != address(0), "NativeUnderlyingUniswapV2SafeSaviour/null-keeper-address");

        if (both(both(collateralType == "", safeHandler == address(0)), keeper == address(liquidationEngine))) {
            return (true, uint(-1), uint(-1));
        }

        require(collateralType == collateralJoin.collateralType(), "NativeUnderlyingUniswapV2SafeSaviour/invalid-collateral-type");

        require(lpTokenCover[safeHandler] > 0, "NativeUnderlyingUniswapV2SafeSaviour/null-cover");

        taxCollector.taxSingle(collateralType);

        (uint256 safeDebtRepaid, uint256 safeCollateralAdded) =
          getTokensForSaving(safeHandler, oracleRelayer.redemptionPrice());

        require(either(safeDebtRepaid > 0, safeCollateralAdded > 0), "NativeUnderlyingUniswapV2SafeSaviour/cannot-save-safe");

        (uint256 keeperSysCoins, uint256 keeperCollateralCoins) =
          getKeeperPayoutTokens(safeHandler, oracleRelayer.redemptionPrice(), safeDebtRepaid, safeCollateralAdded);

        require(either(keeperSysCoins > 0, keeperCollateralCoins > 0), "NativeUnderlyingUniswapV2SafeSaviour/cannot-pay-keeper");

        uint256 totalCover = lpTokenCover[safeHandler];
        delete(lpTokenCover[safeHandler]);

        saviourRegistry.markSave(collateralType, safeHandler);

        uint256 sysCoinBalance        = systemCoin.balanceOf(address(this));
        uint256 collateralCoinBalance = collateralToken.balanceOf(address(this));

        lpToken.approve(address(liquidityManager), totalCover);
        liquidityManager.removeLiquidity(totalCover, 0, 0, address(this));

        require(
          either(systemCoin.balanceOf(address(this)) > sysCoinBalance, collateralToken.balanceOf(address(this)) > collateralCoinBalance),
          "NativeUnderlyingUniswapV2SafeSaviour/faulty-remove-liquidity"
        );

        sysCoinBalance        = sub(sub(systemCoin.balanceOf(address(this)), sysCoinBalance), add(safeDebtRepaid, keeperSysCoins));
        collateralCoinBalance = sub(
          sub(collateralToken.balanceOf(address(this)), collateralCoinBalance), add(safeCollateralAdded, keeperCollateralCoins)
        );

        if (sysCoinBalance > 0) {
          underlyingReserves[safeHandler].systemCoins = add(
            underlyingReserves[safeHandler].systemCoins, sysCoinBalance
          );
        }
        if (collateralCoinBalance > 0) {
          underlyingReserves[safeHandler].collateralCoins = add(
            underlyingReserves[safeHandler].collateralCoins, collateralCoinBalance
          );
        }

        if (safeDebtRepaid > 0) {
          systemCoin.approve(address(coinJoin), safeDebtRepaid);
          uint256 nonAdjustedSystemCoinsToRepay = div(mul(safeDebtRepaid, RAY), getAccumulatedRate(collateralType));

          coinJoin.join(address(this), safeDebtRepaid);
          safeEngine.modifySAFECollateralization(
            collateralType,
            safeHandler,
            address(0),
            address(this),
            int256(0),
            -int256(nonAdjustedSystemCoinsToRepay)
          );
        }

        if (safeCollateralAdded > 0) {
          collateralToken.approve(address(collateralJoin), safeCollateralAdded);

          collateralJoin.join(address(this), safeCollateralAdded);
          safeEngine.modifySAFECollateralization(
            collateralType,
            safeHandler,
            address(this),
            address(0),
            int256(safeCollateralAdded),
            int256(0)
          );
        }

        if (keeperSysCoins > 0) {
          systemCoin.transfer(keeper, keeperSysCoins);
        }

        if (keeperCollateralCoins > 0) {
          collateralToken.transfer(keeper, keeperCollateralCoins);
        }

        emit SaveSAFE(keeper, collateralType, safeHandler, totalCover);

        return (true, totalCover, 0);
    }

    function getKeeperPayoutValue() override public returns (uint256) {

        return 0;
    }
    function keeperPayoutExceedsMinValue() override public returns (bool) {

        return false;
    }
    function canSave(bytes32, address safeHandler) override external returns (bool) {

        uint256 redemptionPrice = oracleRelayer.redemptionPrice();

        (uint256 safeDebtRepaid, uint256 safeCollateralAdded) =
          getTokensForSaving(safeHandler, redemptionPrice);

        (uint256 keeperSysCoins, uint256 keeperCollateralCoins) =
          getKeeperPayoutTokens(safeHandler, redemptionPrice, safeDebtRepaid, safeCollateralAdded);

        if (both(
          either(safeDebtRepaid > 0, safeCollateralAdded > 0),
          either(keeperSysCoins > 0, keeperCollateralCoins > 0)
        )) {
          return true;
        }

        return false;
    }
    function tokenAmountUsedToSave(bytes32, address safeHandler) override public returns (uint256) {

        return lpTokenCover[safeHandler];
    }
    function getCollateralPrice() public view returns (uint256) {

        (address ethFSM,,) = oracleRelayer.collateralTypes(collateralJoin.collateralType());
        if (ethFSM == address(0)) return 0;

        (uint256 priceFeedValue, bool hasValidValue) = PriceFeedLike(ethFSM).getResultWithValidity();
        if (!hasValidValue) return 0;

        return priceFeedValue;
    }
    function getSystemCoinMarketPrice() public view returns (uint256) {

        (uint256 priceFeedValue, bool hasValidValue) = systemCoinOrcl.getResultWithValidity();
        if (!hasValidValue) return 0;

        return priceFeedValue;
    }
    function getTargetCRatio(address safeHandler) public view returns (uint256) {

        bytes32 collateralType = collateralJoin.collateralType();
        uint256 defaultCRatio  = cRatioSetter.defaultDesiredCollateralizationRatios(collateralType);
        uint256 targetCRatio   = (cRatioSetter.desiredCollateralizationRatios(collateralType, safeHandler) == 0) ?
          defaultCRatio : cRatioSetter.desiredCollateralizationRatios(collateralType, safeHandler);
        return targetCRatio;
    }
    function getLPUnderlying(address safeHandler) public view returns (uint256, uint256) {

        uint256 coverAmount = lpTokenCover[safeHandler];

        if (coverAmount == 0) return (0, 0);

        (uint256 sysCoinsFromLP, uint256 collateralFromLP) = (isSystemCoinToken0) ?
          (liquidityManager.getToken0FromLiquidity(coverAmount), liquidityManager.getToken1FromLiquidity(coverAmount)) :
          (liquidityManager.getToken1FromLiquidity(coverAmount), liquidityManager.getToken0FromLiquidity(coverAmount));

        return (sysCoinsFromLP, collateralFromLP);
    }
    function getTokensForSaving(address safeHandler, uint256 redemptionPrice)
      public view returns (uint256, uint256) {

        if (either(lpTokenCover[safeHandler] == 0, redemptionPrice == 0)) {
            return (0, 0);
        }

        (uint256 depositedCollateralToken, uint256 safeDebt) =
          SAFEEngineLike_8(collateralJoin.safeEngine()).safes(collateralJoin.collateralType(), safeHandler);
        uint256 targetCRatio = getTargetCRatio(safeHandler);
        if (either(safeDebt == 0, targetCRatio == 0)) {
            return (0, 0);
        }

        uint256 collateralPrice = getCollateralPrice();
        if (collateralPrice == 0) {
            return (0, 0);
        }

        uint256 debtToRepay = mul(
          mul(HUNDRED, mul(depositedCollateralToken, collateralPrice) / WAD) / targetCRatio, RAY
        ) / redemptionPrice;

        if (either(debtToRepay >= safeDebt, debtBelowFloor(collateralJoin.collateralType(), debtToRepay))) {
            return (0, 0);
        }
        safeDebt    = mul(safeDebt, getAccumulatedRate(collateralJoin.collateralType())) / RAY;
        debtToRepay = sub(safeDebt, debtToRepay);

        (uint256 sysCoinsFromLP, uint256 collateralFromLP) = getLPUnderlying(safeHandler);

        if (sysCoinsFromLP >= debtToRepay) {
            return (debtToRepay, 0);
        } else {
            uint256 scaledDownDebtValue = mul(add(mul(redemptionPrice, sub(safeDebt, sysCoinsFromLP)) / RAY, ONE), targetCRatio) / HUNDRED;

            uint256 collateralTokenNeeded = div(mul(scaledDownDebtValue, WAD), collateralPrice);
            collateralTokenNeeded         = (depositedCollateralToken < collateralTokenNeeded) ?
              sub(collateralTokenNeeded, depositedCollateralToken) : MAX_UINT;

            if (collateralTokenNeeded <= collateralFromLP) {
              return (sysCoinsFromLP, collateralTokenNeeded);
            } else {
              return (0, 0);
            }
        }
    }
    function getKeeperPayoutTokens(address safeHandler, uint256 redemptionPrice, uint256 safeDebtRepaid, uint256 safeCollateralAdded)
      public view returns (uint256, uint256) {

        uint256 collateralPrice    = getCollateralPrice();
        uint256 sysCoinMarketPrice = getSystemCoinMarketPrice();
        if (either(collateralPrice == 0, sysCoinMarketPrice == 0)) {
            return (0, 0);
        }

        (uint256 sysCoinsFromLP, uint256 collateralFromLP) = getLPUnderlying(safeHandler);

        uint256 keeperSysCoins;
        if (sysCoinsFromLP > safeDebtRepaid) {
            uint256 remainingSystemCoins = sub(sysCoinsFromLP, safeDebtRepaid);
            uint256 payoutInSystemCoins  = div(mul(minKeeperPayoutValue, WAD), sysCoinMarketPrice);

            if (payoutInSystemCoins <= remainingSystemCoins) {
              return (payoutInSystemCoins, 0);
            } else {
              keeperSysCoins = remainingSystemCoins;
            }
        }

        if (collateralFromLP <= safeCollateralAdded) return (0, 0);

        uint256 remainingCollateral        = sub(collateralFromLP, safeCollateralAdded);
        uint256 remainingKeeperPayoutValue = sub(minKeeperPayoutValue, mul(keeperSysCoins, sysCoinMarketPrice) / WAD);
        uint256 collateralTokenNeeded      = div(mul(remainingKeeperPayoutValue, WAD), collateralPrice);

        if (collateralTokenNeeded <= remainingCollateral) {
          return (keeperSysCoins, collateralTokenNeeded);
        } else {
          return (0, 0);
        }
    }
    function debtBelowFloor(bytes32 collateralType, uint256 targetDebtAmount) public view returns (bool) {

        (, , , , uint256 debtFloor, ) = safeEngine.collateralTypes(collateralType);
        return (mul(targetDebtAmount, RAY) < debtFloor);
    }
    function getAccumulatedRate(bytes32 collateralType)
      public view returns (uint256 accumulatedRate) {

        (, accumulatedRate, , , , ) = safeEngine.collateralTypes(collateralType);
    }
}