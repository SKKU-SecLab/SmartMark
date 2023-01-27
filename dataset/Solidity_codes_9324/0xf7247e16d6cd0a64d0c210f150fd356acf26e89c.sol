
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// BUSL-1.1
pragma solidity 0.8.10;

interface ITokenPairPriceFeed {

    function getRate(bytes32 rateConversionData) external view returns (uint256 rate, uint256 rateDenominator);

}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT
pragma solidity 0.8.10;

interface IChainlinkAggregator {

    function decimals() external view returns (uint8);


    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

}// BUSL-1.1
pragma solidity 0.8.10;

interface IENS {

    function resolver(bytes32 node) external view returns (IENSResolver);

}

interface IENSResolver {

    function addr(bytes32 node) external view returns (address);

}// BUSL-1.1
pragma solidity 0.8.10;



abstract contract ChainlinkTokenPairPriceFeed is ITokenPairPriceFeed {
    IENS private constant ENS = IENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    function getRate(bytes32 chainlinkAggregatorNodeHash)
        public
        view
        override
        returns (uint256 rate, uint256 rateDenominator)
    {
        IENSResolver ensResolver = ENS.resolver(chainlinkAggregatorNodeHash);
        IChainlinkAggregator chainLinkAggregator = IChainlinkAggregator(ensResolver.addr(chainlinkAggregatorNodeHash));

        (, int256 latestRate, , , ) = chainLinkAggregator.latestRoundData();

        return (SafeCast.toUint256(latestRate), 10**chainLinkAggregator.decimals());
    }
}// BUSL-1.1
pragma solidity >=0.7.6 <0.9.0;


interface IPoolShare {

    enum ShareKind {
        Principal,
        Yield
    }

    function kind() external view returns (ShareKind);


    function pool() external view returns (ITempusPool);


    function getPricePerFullShare() external returns (uint256);


    function getPricePerFullShareStored() external view returns (uint256);

}// MIT
pragma solidity >=0.7.6 <0.9.0;

interface IOwnable {

    event OwnershipProposed(address indexed currentOwner, address indexed proposedOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;


    function acceptOwnership() external;

}// MIT
pragma solidity >=0.7.6 <0.9.0;
pragma abicoder v2;

interface IVersioned {

    struct Version {
        uint16 major;
        uint16 minor;
        uint16 patch;
    }

    function version() external view returns (Version memory);

}// BUSL-1.1
pragma solidity >=0.7.6 <0.9.0;


interface ITempusFees is IOwnable {

    struct FeesConfig {
        uint256 depositPercent;
        uint256 earlyRedeemPercent;
        uint256 matureRedeemPercent;
    }

    function getFeesConfig() external view returns (FeesConfig memory);


    function setFeesConfig(FeesConfig calldata newFeesConfig) external;


    function maxDepositFee() external view returns (uint256);


    function maxEarlyRedeemFee() external view returns (uint256);


    function maxMatureRedeemFee() external view returns (uint256);


    function totalFees() external view returns (uint256);


    function transferFees(address recipient) external;

}

interface ITempusPool is ITempusFees, IVersioned {

    function protocolName() external view returns (bytes32);


    function yieldBearingToken() external view returns (address);


    function backingToken() external view returns (address);


    function backingTokenONE() external view returns (uint256);


    function principalShare() external view returns (IPoolShare);


    function yieldShare() external view returns (IPoolShare);


    function controller() external view returns (address);


    function startTime() external view returns (uint256);


    function maturityTime() external view returns (uint256);


    function exceptionalHaltTime() external view returns (uint256);


    function maximumNegativeYieldDuration() external view returns (uint256);


    function matured() external view returns (bool);


    function finalize() external;


    function onDepositYieldBearing(uint256 yieldTokenAmount, address recipient)
        external
        returns (
            uint256 mintedShares,
            uint256 depositedBT,
            uint256 fee,
            uint256 rate
        );


    function onDepositBacking(uint256 backingTokenAmount, address recipient)
        external
        payable
        returns (
            uint256 mintedShares,
            uint256 depositedYBT,
            uint256 fee,
            uint256 rate
        );


    function redeem(
        address from,
        uint256 principalAmount,
        uint256 yieldAmount,
        address recipient
    )
        external
        returns (
            uint256 redeemableYieldTokens,
            uint256 fee,
            uint256 rate
        );


    function redeemToBacking(
        address from,
        uint256 principalAmount,
        uint256 yieldAmount,
        address recipient
    )
        external
        payable
        returns (
            uint256 redeemableYieldTokens,
            uint256 redeemableBackingTokens,
            uint256 fee,
            uint256 rate
        );


    function estimatedMintedShares(uint256 amount, bool isBackingToken) external view returns (uint256);


    function estimatedRedeem(
        uint256 principals,
        uint256 yields,
        bool toBackingToken
    ) external view returns (uint256);


    function currentInterestRate() external view returns (uint256);


    function initialInterestRate() external view returns (uint256);


    function maturityInterestRate() external view returns (uint256);


    function pricePerYieldShare() external returns (uint256);


    function pricePerPrincipalShare() external returns (uint256);


    function pricePerYieldShareStored() external view returns (uint256);


    function pricePerPrincipalShareStored() external view returns (uint256);


    function numAssetsPerYieldToken(uint yieldTokens, uint interestRate) external view returns (uint);


    function numYieldTokensPerAsset(uint backingTokens, uint interestRate) external view returns (uint);

}// MIT
pragma solidity 0.8.10;

library Fixed256xVar {

    function mulfV(
        uint256 a,
        uint256 b,
        uint256 one
    ) internal pure returns (uint256) {

        return (a * b) / one;
    }

    function divfV(
        uint256 a,
        uint256 b,
        uint256 one
    ) internal pure returns (uint256) {

        return (a * one) / b;
    }
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
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
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT
pragma solidity 0.8.10;


contract ERC20OwnerMintableToken is ERC20 {
    address public immutable manager;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        manager = msg.sender;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == manager, "mint: only manager can mint");
        _mint(account, amount);
    }

    function burn(uint256 amount) external {
        require(msg.sender == manager, "burn: only manager can burn");
        _burn(manager, amount);
    }

    function burnFrom(address account, uint256 amount) external {
        require(msg.sender == manager, "burn: only manager can burn");
        _burn(account, amount);
    }
}// BUSL-1.1
pragma solidity 0.8.10;


abstract contract PoolShare is IPoolShare, ERC20OwnerMintableToken {
    ShareKind public immutable override kind;

    ITempusPool public immutable override pool;

    uint8 internal immutable tokenDecimals;

    constructor(
        ShareKind _kind,
        ITempusPool _pool,
        string memory name,
        string memory symbol,
        uint8 _decimals
    ) ERC20OwnerMintableToken(name, symbol) {
        kind = _kind;
        pool = _pool;
        tokenDecimals = _decimals;
    }

    function decimals() public view virtual override returns (uint8) {
        return tokenDecimals;
    }
}// BUSL-1.1
pragma solidity >=0.7.0;


interface IVault {
    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IERC20 assetIn;
        IERC20 assetOut;
        uint256 amount;
        bytes userData;
    }
    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    struct JoinPoolRequest {
        IERC20[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    struct ExitPoolRequest {
        IERC20[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;

    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            IERC20[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );
}// BUSL-1.1
pragma solidity >=0.7.0;


interface ITempusAMM {
    enum JoinKind {
        INIT,
        EXACT_TOKENS_IN_FOR_BPT_OUT
    }
    enum ExitKind {
        EXACT_BPT_IN_FOR_TOKENS_OUT,
        BPT_IN_FOR_EXACT_TOKENS_OUT
    }

    function getVault() external view returns (IVault);

    function getPoolId() external view returns (bytes32);

    function tempusPool() external view returns (ITempusPool);

    function balanceOf(address) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getExpectedReturnGivenIn(uint256 amount, bool yieldShareIn) external view returns (uint256);

    function getSwapAmountToEndWithEqualShares(
        uint256 principals,
        uint256 yields,
        uint256 threshold
    ) external view returns (uint256 amountIn, bool yieldsIn);

    function getExpectedTokensOutGivenBPTIn(uint256 bptAmountIn)
        external
        view
        returns (uint256 principals, uint256 yields);

    function getExpectedBPTInGivenTokensOut(uint256 principalsStaked, uint256 yieldsStaked)
        external
        view
        returns (uint256 lpTokens);

    function getExpectedLPTokensForTokensIn(uint256[] memory amountsIn) external view returns (uint256);

    function getRate() external view returns (uint256);
}// BUSL-1.1
pragma solidity 0.8.10;


library AMMBalancesHelper {
    using Fixed256xVar for uint256;

    uint256 internal constant ONE = 1e18;

    function getLiquidityProvisionSharesAmounts(uint256[] memory ammBalances, uint256 shares)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[2] memory ammDepositPercentages = getAMMBalancesRatio(ammBalances);
        uint256[] memory ammLiquidityProvisionAmounts = new uint256[](2);

        (ammLiquidityProvisionAmounts[0], ammLiquidityProvisionAmounts[1]) = (
            shares.mulfV(ammDepositPercentages[0], ONE),
            shares.mulfV(ammDepositPercentages[1], ONE)
        );

        return ammLiquidityProvisionAmounts;
    }

    function getAMMBalancesRatio(uint256[] memory ammBalances) internal pure returns (uint256[2] memory balancesRatio) {
        uint256 rate = ammBalances[0].divfV(ammBalances[1], ONE);

        (balancesRatio[0], balancesRatio[1]) = rate > ONE ? (ONE, ONE.divfV(rate, ONE)) : (rate, ONE);
    }
}// MIT
pragma solidity >=0.7.6 <0.9.0;


abstract contract Versioned is IVersioned {
    uint16 private immutable _major;
    uint16 private immutable _minor;
    uint16 private immutable _patch;

    constructor(
        uint16 major,
        uint16 minor,
        uint16 patch
    ) {
        _major = major;
        _minor = minor;
        _patch = patch;
    }

    function version() external view returns (Version memory) {
        return Version(_major, _minor, _patch);
    }
}// BUSL-1.1
pragma solidity 0.8.10;



contract Stats is ITokenPairPriceFeed, ChainlinkTokenPairPriceFeed, Versioned {
    using Fixed256xVar for uint256;
    using AMMBalancesHelper for uint256[];

    constructor() Versioned(1, 0, 0) {}

    function totalValueLockedInBackingTokens(ITempusPool pool) public view returns (uint256) {
        PoolShare principalShare = PoolShare(address(pool.principalShare()));
        PoolShare yieldShare = PoolShare(address(pool.yieldShare()));

        uint256 backingTokenOne = pool.backingTokenONE();

        uint256 pricePerPrincipalShare = pool.pricePerPrincipalShareStored();
        uint256 pricePerYieldShare = pool.pricePerYieldShareStored();

        return
            calculateTvlInBackingTokens(
                IERC20(address(principalShare)).totalSupply(),
                IERC20(address(yieldShare)).totalSupply(),
                pricePerPrincipalShare,
                pricePerYieldShare,
                backingTokenOne
            );
    }

    function totalValueLockedAtGivenRate(ITempusPool pool, bytes32 rateConversionData) external view returns (uint256) {
        uint256 tvlInBackingTokens = totalValueLockedInBackingTokens(pool);

        (uint256 rate, uint256 rateDenominator) = getRate(rateConversionData);
        return (tvlInBackingTokens * rate) / rateDenominator;
    }

    function calculateTvlInBackingTokens(
        uint256 totalSupplyTPS,
        uint256 totalSupplyTYS,
        uint256 pricePerPrincipalShare,
        uint256 pricePerYieldShare,
        uint256 backingTokenOne
    ) internal pure returns (uint256) {
        return
            totalSupplyTPS.mulfV(pricePerPrincipalShare, backingTokenOne) +
            totalSupplyTYS.mulfV(pricePerYieldShare, backingTokenOne);
    }

    function estimatedMintedShares(
        ITempusPool pool,
        uint256 amount,
        bool isBackingToken
    ) public view returns (uint256) {
        return pool.estimatedMintedShares(amount, isBackingToken);
    }

    function estimatedRedeem(
        ITempusPool pool,
        uint256 principals,
        uint256 yields,
        bool toBackingToken
    ) public view returns (uint256) {
        return pool.estimatedRedeem(principals, yields, toBackingToken);
    }

    function estimatedDepositAndProvideLiquidity(
        ITempusAMM tempusAMM,
        uint256 amount,
        bool isBackingToken
    )
        public
        view
        returns (
            uint256 lpTokens,
            uint256 principals,
            uint256 yields
        )
    {
        ITempusPool pool = tempusAMM.tempusPool();
        uint256 shares = estimatedMintedShares(pool, amount, isBackingToken);

        (IERC20[] memory ammTokens, uint256[] memory ammBalances, ) = tempusAMM.getVault().getPoolTokens(
            tempusAMM.getPoolId()
        );
        uint256[] memory ammLiquidityProvisionAmounts = ammBalances.getLiquidityProvisionSharesAmounts(shares);

        lpTokens = tempusAMM.getExpectedLPTokensForTokensIn(ammLiquidityProvisionAmounts);
        (principals, yields) = (address(pool.principalShare()) == address(ammTokens[0]))
            ? (shares - ammLiquidityProvisionAmounts[0], shares - ammLiquidityProvisionAmounts[1])
            : (shares - ammLiquidityProvisionAmounts[1], shares - ammLiquidityProvisionAmounts[0]);
    }

    function estimatedDepositAndFix(
        ITempusAMM tempusAMM,
        uint256 amount,
        bool isBackingToken
    ) public view returns (uint256 principals) {
        principals = estimatedMintedShares(tempusAMM.tempusPool(), amount, isBackingToken);
        principals += tempusAMM.getExpectedReturnGivenIn(principals, true);
    }

    function estimateExitAndRedeem(
        ITempusAMM tempusAMM,
        uint256 lpTokens,
        uint256 principals,
        uint256 yields,
        uint256 threshold,
        bool toBackingToken
    )
        public
        view
        returns (
            uint256 tokenAmount,
            uint256 principalsStaked,
            uint256 yieldsStaked,
            uint256 principalsRate,
            uint256 yieldsRate
        )
    {
        if (lpTokens > 0) {
            (principalsStaked, yieldsStaked) = tempusAMM.getExpectedTokensOutGivenBPTIn(lpTokens);
            principals += principalsStaked;
            yields += yieldsStaked;
        }

        if (!tempusAMM.tempusPool().matured()) {
            (uint256 amountIn, bool yieldsIn) = tempusAMM.getSwapAmountToEndWithEqualShares(
                principals,
                yields,
                threshold
            );
            uint256 amountOut = (amountIn != 0) ? tempusAMM.getExpectedReturnGivenIn(amountIn, yieldsIn) : 0;
            if (amountIn > 0) {
                if (yieldsIn) {
                    principals += amountOut;
                    yields -= amountIn;
                    yieldsRate = amountOut.divfV(amountIn, tempusAMM.tempusPool().backingTokenONE());
                } else {
                    principals -= amountIn;
                    yields += amountOut;
                    principalsRate = amountOut.divfV(amountIn, tempusAMM.tempusPool().backingTokenONE());
                }
            }

            if (principals > yields) {
                principals = yields;
            } else {
                yields = principals;
            }
        }

        tokenAmount = estimatedRedeem(tempusAMM.tempusPool(), principals, yields, toBackingToken);
    }

    function estimateExitAndRedeemGivenStakedOut(
        ITempusAMM tempusAMM,
        uint256 principals,
        uint256 yields,
        uint256 principalsStaked,
        uint256 yieldsStaked,
        bool toBackingToken
    ) public view returns (uint256 tokenAmount, uint256 lpTokensRedeemed) {
        require(!tempusAMM.tempusPool().matured(), "Pool already finalized!");

        if (principalsStaked > 0 || yieldsStaked > 0) {
            lpTokensRedeemed = tempusAMM.getExpectedBPTInGivenTokensOut(principalsStaked, yieldsStaked);
            principals += principalsStaked;
            yields += yieldsStaked;
        }

        tokenAmount = estimatedRedeem(tempusAMM.tempusPool(), principals, yields, toBackingToken);
    }
}