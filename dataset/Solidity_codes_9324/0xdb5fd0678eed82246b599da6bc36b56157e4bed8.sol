
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
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
pragma solidity 0.8.10;


library UntrustedERC20 {

    using SafeERC20 for IERC20;

    function untrustedTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal returns (uint256) {

        uint256 startBalance = token.balanceOf(to);
        token.safeTransfer(to, value);
        return token.balanceOf(to) - startBalance;
    }

    function untrustedTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal returns (uint256) {

        uint256 startBalance = token.balanceOf(to);
        token.safeTransferFrom(from, to, value);
        return token.balanceOf(to) - startBalance;
    }
}// MIT
pragma solidity 0.8.10;


abstract contract Ownable is IOwnable {
    address private _owner;
    address private _proposedOwner;

    constructor() {
        _setOwner(msg.sender);
    }

    function owner() public view virtual override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _proposedOwner = newOwner;
        emit OwnershipProposed(_owner, _proposedOwner);
    }

    function acceptOwnership() public virtual override {
        require(msg.sender == _proposedOwner, "Ownable: Only proposed owner can accept ownership");
        _setOwner(_proposedOwner);
        _proposedOwner = address(0);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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



contract TempusController is ReentrancyGuard, Ownable, Versioned {

    using Fixed256xVar for uint256;
    using SafeERC20 for IERC20;
    using UntrustedERC20 for IERC20;
    using AMMBalancesHelper for uint256[];

    mapping(address => bool) private registry;

    event Deposited(
        address indexed pool,
        address indexed depositor,
        address indexed recipient,
        uint256 yieldTokenAmount,
        uint256 backingTokenValue,
        uint256 shareAmounts,
        uint256 interestRate,
        uint256 fee
    );

    event Redeemed(
        address indexed pool,
        address indexed redeemer,
        address indexed recipient,
        uint256 principalShareAmount,
        uint256 yieldShareAmount,
        uint256 yieldTokenAmount,
        uint256 backingTokenValue,
        uint256 interestRate,
        uint256 fee,
        bool isEarlyRedeem
    );

    constructor() Versioned(1, 0, 0) {}

    function register(address authorizedContract, bool isValid) public onlyOwner {

        registry[authorizedContract] = isValid;
    }

    function requireRegistered(address authorizedContract) private view {

        require(registry[authorizedContract], "Unauthorized contract address");
    }

    function depositAndProvideLiquidity(
        ITempusAMM tempusAMM,
        uint256 tokenAmount,
        bool isBackingToken
    ) external payable nonReentrant {

        requireRegistered(address(tempusAMM));
        _depositAndProvideLiquidity(tempusAMM, tokenAmount, isBackingToken);
    }

    function provideLiquidity(ITempusAMM tempusAMM, uint256 sharesAmount) external nonReentrant {

        requireRegistered(address(tempusAMM));
        (
            IVault vault,
            bytes32 poolId,
            IERC20[] memory ammTokens,
            uint256[] memory ammBalances
        ) = _getAMMDetailsAndEnsureInitialized(tempusAMM);

        _provideLiquidity(msg.sender, vault, poolId, ammTokens, ammBalances, sharesAmount, msg.sender);
    }

    function depositAndFix(
        ITempusAMM tempusAMM,
        uint256 tokenAmount,
        bool isBackingToken,
        uint256 minTYSRate,
        uint256 deadline
    ) external payable nonReentrant {

        requireRegistered(address(tempusAMM));
        _depositAndFix(tempusAMM, tokenAmount, isBackingToken, minTYSRate, deadline);
    }

    function depositYieldBearing(
        ITempusPool targetPool,
        uint256 yieldTokenAmount,
        address recipient
    ) external nonReentrant {

        require(recipient != address(0), "recipient can not be 0x0");
        requireRegistered(address(targetPool));
        _depositYieldBearing(targetPool, yieldTokenAmount, recipient);
    }

    function depositBacking(
        ITempusPool targetPool,
        uint256 backingTokenAmount,
        address recipient
    ) external payable nonReentrant {

        require(recipient != address(0), "recipient can not be 0x0");
        requireRegistered(address(targetPool));
        _depositBacking(targetPool, backingTokenAmount, recipient);
    }

    function redeemToYieldBearing(
        ITempusPool targetPool,
        uint256 principalAmount,
        uint256 yieldAmount,
        address recipient
    ) external nonReentrant {

        require(recipient != address(0), "recipient can not be 0x0");
        requireRegistered(address(targetPool));
        _redeemToYieldBearing(targetPool, msg.sender, principalAmount, yieldAmount, recipient);
    }

    function redeemToBacking(
        ITempusPool targetPool,
        uint256 principalAmount,
        uint256 yieldAmount,
        address recipient
    ) external nonReentrant {

        require(recipient != address(0), "recipient can not be 0x0");
        requireRegistered(address(targetPool));
        _redeemToBacking(targetPool, msg.sender, principalAmount, yieldAmount, recipient);
    }

    function exitTempusAMM(
        ITempusAMM tempusAMM,
        uint256 lpTokensAmount,
        uint256 principalAmountOutMin,
        uint256 yieldAmountOutMin,
        bool toInternalBalances
    ) external nonReentrant {

        requireRegistered(address(tempusAMM));
        _exitTempusAMM(tempusAMM, lpTokensAmount, principalAmountOutMin, yieldAmountOutMin, toInternalBalances);
    }

    function exitAmmGivenAmountsOutAndEarlyRedeem(
        ITempusAMM tempusAMM,
        uint256 principals,
        uint256 yields,
        uint256 principalsStaked,
        uint256 yieldsStaked,
        uint256 maxLpTokensToRedeem,
        bool toBackingToken
    ) external nonReentrant {

        requireRegistered(address(tempusAMM));
        _exitAmmGivenAmountsOutAndEarlyRedeem(
            tempusAMM,
            principals,
            yields,
            principalsStaked,
            yieldsStaked,
            maxLpTokensToRedeem,
            toBackingToken
        );
    }

    function exitAmmGivenLpAndRedeem(
        ITempusAMM tempusAMM,
        uint256 lpTokens,
        uint256 principals,
        uint256 yields,
        uint256 minPrincipalsStaked,
        uint256 minYieldsStaked,
        uint256 maxLeftoverShares,
        uint256 yieldsRate,
        uint256 maxSlippage,
        bool toBackingToken,
        uint256 deadline
    ) external nonReentrant {

        requireRegistered(address(tempusAMM));
        if (lpTokens > 0) {
            require(tempusAMM.transferFrom(msg.sender, address(this), lpTokens), "LP token transfer failed");

            uint256[] memory minAmountsOutFromLP = getAMMOrderedAmounts(
                tempusAMM,
                minPrincipalsStaked,
                minYieldsStaked
            );
            _exitTempusAMMGivenLP(tempusAMM, address(this), address(this), lpTokens, minAmountsOutFromLP, false);
        }

        _redeemWithEqualShares(
            tempusAMM,
            principals,
            yields,
            maxLeftoverShares,
            yieldsRate,
            maxSlippage,
            deadline,
            toBackingToken
        );
    }

    function swap(
        ITempusAMM tempusAMM,
        uint256 swapAmount,
        IERC20 tokenIn,
        IERC20 tokenOut,
        uint256 minReturn,
        uint256 deadline
    ) private {

        require(swapAmount > 0, "Invalid swap amount.");
        tokenIn.safeIncreaseAllowance(address(tempusAMM.getVault()), swapAmount);

        (IVault vault, bytes32 poolId, , ) = _getAMMDetailsAndEnsureInitialized(tempusAMM);

        IVault.SingleSwap memory singleSwap = IVault.SingleSwap({
            poolId: poolId,
            kind: IVault.SwapKind.GIVEN_IN,
            assetIn: tokenIn,
            assetOut: tokenOut,
            amount: swapAmount,
            userData: ""
        });

        IVault.FundManagement memory fundManagement = IVault.FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: payable(address(this)),
            toInternalBalance: false
        });
        vault.swap(singleSwap, fundManagement, minReturn, deadline);
    }

    function _depositAndProvideLiquidity(
        ITempusAMM tempusAMM,
        uint256 tokenAmount,
        bool isBackingToken
    ) private {

        (
            IVault vault,
            bytes32 poolId,
            IERC20[] memory ammTokens,
            uint256[] memory ammBalances
        ) = _getAMMDetailsAndEnsureInitialized(tempusAMM);

        uint256 mintedShares = _deposit(tempusAMM.tempusPool(), tokenAmount, isBackingToken);

        uint256[] memory sharesUsed = _provideLiquidity(
            address(this),
            vault,
            poolId,
            ammTokens,
            ammBalances,
            mintedShares,
            msg.sender
        );

        if (mintedShares > sharesUsed[0]) {
            ammTokens[0].safeTransfer(msg.sender, mintedShares - sharesUsed[0]);
        }
        if (mintedShares > sharesUsed[1]) {
            ammTokens[1].safeTransfer(msg.sender, mintedShares - sharesUsed[1]);
        }
    }

    function _provideLiquidity(
        address sender,
        IVault vault,
        bytes32 poolId,
        IERC20[] memory ammTokens,
        uint256[] memory ammBalances,
        uint256 sharesAmount,
        address recipient
    ) private returns (uint256[] memory) {

        uint256[] memory ammLiquidityProvisionAmounts = ammBalances.getLiquidityProvisionSharesAmounts(sharesAmount);

        if (sender != address(this)) {
            ammTokens[0].safeTransferFrom(sender, address(this), ammLiquidityProvisionAmounts[0]);
            ammTokens[1].safeTransferFrom(sender, address(this), ammLiquidityProvisionAmounts[1]);
        }

        ammTokens[0].safeIncreaseAllowance(address(vault), ammLiquidityProvisionAmounts[0]);
        ammTokens[1].safeIncreaseAllowance(address(vault), ammLiquidityProvisionAmounts[1]);

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest({
            assets: ammTokens,
            maxAmountsIn: ammLiquidityProvisionAmounts,
            userData: abi.encode(uint8(ITempusAMM.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT), ammLiquidityProvisionAmounts),
            fromInternalBalance: false
        });

        vault.joinPool(poolId, address(this), recipient, request);

        return ammLiquidityProvisionAmounts;
    }

    function _depositAndFix(
        ITempusAMM tempusAMM,
        uint256 tokenAmount,
        bool isBackingToken,
        uint256 minTYSRate,
        uint256 deadline
    ) private {

        ITempusPool targetPool = tempusAMM.tempusPool();
        IERC20 principalShares = IERC20(address(targetPool.principalShare()));
        IERC20 yieldShares = IERC20(address(targetPool.yieldShare()));

        uint256 swapAmount = _deposit(targetPool, tokenAmount, isBackingToken);

        yieldShares.safeIncreaseAllowance(address(tempusAMM.getVault()), swapAmount);
        uint256 minReturn = swapAmount.mulfV(minTYSRate, targetPool.backingTokenONE());
        swap(tempusAMM, swapAmount, yieldShares, principalShares, minReturn, deadline);

        uint256 principalsBalance = principalShares.balanceOf(address(this));
        assert(principalsBalance > 0);

        principalShares.safeTransfer(msg.sender, principalsBalance);
    }

    function _deposit(
        ITempusPool targetPool,
        uint256 tokenAmount,
        bool isBackingToken
    ) private returns (uint256 mintedShares) {

        mintedShares = isBackingToken
            ? _depositBacking(targetPool, tokenAmount, address(this))
            : _depositYieldBearing(targetPool, tokenAmount, address(this));
    }

    function _depositYieldBearing(
        ITempusPool targetPool,
        uint256 yieldTokenAmount,
        address recipient
    ) private returns (uint256) {

        require(yieldTokenAmount > 0, "yieldTokenAmount is 0");

        IERC20 yieldBearingToken = IERC20(targetPool.yieldBearingToken());

        uint transferredYBT = yieldBearingToken.untrustedTransferFrom(
            msg.sender,
            address(targetPool),
            yieldTokenAmount
        );

        (uint mintedShares, uint depositedBT, uint fee, uint rate) = targetPool.onDepositYieldBearing(
            transferredYBT,
            recipient
        );

        emit Deposited(
            address(targetPool),
            msg.sender,
            recipient,
            transferredYBT,
            depositedBT,
            mintedShares,
            rate,
            fee
        );

        return mintedShares;
    }

    function _depositBacking(
        ITempusPool targetPool,
        uint256 backingTokenAmount,
        address recipient
    ) private returns (uint256) {

        require(backingTokenAmount > 0, "backingTokenAmount is 0");

        IERC20 backingToken = IERC20(targetPool.backingToken());

        if (msg.value == 0) {
            require(address(backingToken) != address(0), "Pool requires ETH deposits");

            backingTokenAmount = backingToken.untrustedTransferFrom(
                msg.sender,
                address(targetPool),
                backingTokenAmount
            );
        } else {
            require(address(backingToken) == address(0), "given TempusPool's Backing Token is not ETH");
            require(msg.value == backingTokenAmount, "ETH value does not match provided amount");
        }

        (uint256 mintedShares, uint256 depositedYBT, uint256 fee, uint256 interestRate) = targetPool.onDepositBacking{
            value: msg.value
        }(backingTokenAmount, recipient);

        emit Deposited(
            address(targetPool),
            msg.sender,
            recipient,
            depositedYBT,
            backingTokenAmount,
            mintedShares,
            interestRate,
            fee
        );

        return mintedShares;
    }

    function _redeemToYieldBearing(
        ITempusPool targetPool,
        address sender,
        uint256 principals,
        uint256 yields,
        address recipient
    ) private {

        require((principals > 0) || (yields > 0), "principalAmount and yieldAmount cannot both be 0");

        (uint redeemedYBT, uint fee, uint interestRate) = targetPool.redeem(sender, principals, yields, recipient);

        uint redeemedBT = targetPool.numAssetsPerYieldToken(redeemedYBT, targetPool.currentInterestRate());
        bool earlyRedeem = !targetPool.matured();
        emit Redeemed(
            address(targetPool),
            sender,
            recipient,
            principals,
            yields,
            redeemedYBT,
            redeemedBT,
            fee,
            interestRate,
            earlyRedeem
        );
    }

    function _redeemToBacking(
        ITempusPool targetPool,
        address sender,
        uint256 principals,
        uint256 yields,
        address recipient
    ) private {

        require((principals > 0) || (yields > 0), "principalAmount and yieldAmount cannot both be 0");

        (uint redeemedYBT, uint redeemedBT, uint fee, uint rate) = targetPool.redeemToBacking(
            sender,
            principals,
            yields,
            recipient
        );

        bool earlyRedeem = !targetPool.matured();
        emit Redeemed(
            address(targetPool),
            sender,
            recipient,
            principals,
            yields,
            redeemedYBT,
            redeemedBT,
            fee,
            rate,
            earlyRedeem
        );
    }

    function _exitTempusAMM(
        ITempusAMM tempusAMM,
        uint256 lpTokensAmount,
        uint256 principalAmountOutMin,
        uint256 yieldAmountOutMin,
        bool toInternalBalances
    ) private {

        require(tempusAMM.transferFrom(msg.sender, address(this), lpTokensAmount), "LP token transfer failed");

        uint256[] memory amounts = getAMMOrderedAmounts(tempusAMM, principalAmountOutMin, yieldAmountOutMin);
        _exitTempusAMMGivenLP(tempusAMM, address(this), msg.sender, lpTokensAmount, amounts, toInternalBalances);
    }

    function _exitTempusAMMGivenLP(
        ITempusAMM tempusAMM,
        address sender,
        address recipient,
        uint256 lpTokensAmount,
        uint256[] memory minAmountsOut,
        bool toInternalBalances
    ) private {

        require(lpTokensAmount > 0, "LP token amount is 0");

        (IVault vault, bytes32 poolId, IERC20[] memory ammTokens, ) = _getAMMDetailsAndEnsureInitialized(tempusAMM);

        IVault.ExitPoolRequest memory request = IVault.ExitPoolRequest({
            assets: ammTokens,
            minAmountsOut: minAmountsOut,
            userData: abi.encode(uint8(ITempusAMM.ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT), lpTokensAmount),
            toInternalBalance: toInternalBalances
        });
        vault.exitPool(poolId, sender, payable(recipient), request);
    }

    function _exitTempusAMMGivenAmountsOut(
        ITempusAMM tempusAMM,
        address sender,
        address recipient,
        uint256[] memory amountsOut,
        uint256 lpTokensAmountInMax,
        bool toInternalBalances
    ) private {

        (IVault vault, bytes32 poolId, IERC20[] memory ammTokens, ) = _getAMMDetailsAndEnsureInitialized(tempusAMM);

        IVault.ExitPoolRequest memory request = IVault.ExitPoolRequest({
            assets: ammTokens,
            minAmountsOut: amountsOut,
            userData: abi.encode(
                uint8(ITempusAMM.ExitKind.BPT_IN_FOR_EXACT_TOKENS_OUT),
                amountsOut,
                lpTokensAmountInMax
            ),
            toInternalBalance: toInternalBalances
        });
        vault.exitPool(poolId, sender, payable(recipient), request);
    }

    function _exitAmmGivenAmountsOutAndEarlyRedeem(
        ITempusAMM tempusAMM,
        uint256 principals,
        uint256 yields,
        uint256 principalsStaked,
        uint256 yieldsStaked,
        uint256 maxLpTokensToRedeem,
        bool toBackingToken
    ) private {

        ITempusPool tempusPool = tempusAMM.tempusPool();
        require(!tempusPool.matured(), "Pool already finalized");
        principals += principalsStaked;
        yields += yieldsStaked;
        require(principals == yields, "Needs equal amounts of shares before maturity");

        require(tempusAMM.transferFrom(msg.sender, address(this), maxLpTokensToRedeem), "LP token transfer failed");

        uint256[] memory amounts = getAMMOrderedAmounts(tempusAMM, principalsStaked, yieldsStaked);
        _exitTempusAMMGivenAmountsOut(tempusAMM, address(this), msg.sender, amounts, maxLpTokensToRedeem, false);

        uint256 lpTokenBalance = tempusAMM.balanceOf(address(this));
        require(tempusAMM.transferFrom(address(this), msg.sender, lpTokenBalance), "LP token transfer failed");

        if (toBackingToken) {
            _redeemToBacking(tempusPool, msg.sender, principals, yields, msg.sender);
        } else {
            _redeemToYieldBearing(tempusPool, msg.sender, principals, yields, msg.sender);
        }
    }

    function _redeemWithEqualShares(
        ITempusAMM tempusAMM,
        uint256 principals,
        uint256 yields,
        uint256 maxLeftoverShares,
        uint256 yieldsRate,
        uint256 maxSlippage,
        uint256 deadline,
        bool toBackingToken
    ) private {

        ITempusPool tempusPool = tempusAMM.tempusPool();

        IERC20 principalShare = IERC20(address(tempusPool.principalShare()));
        IERC20 yieldShare = IERC20(address(tempusPool.yieldShare()));
        require(principalShare.transferFrom(msg.sender, address(this), principals), "Principals transfer failed");
        require(yieldShare.transferFrom(msg.sender, address(this), yields), "Yields transfer failed");
        require(yieldsRate > 0, "yieldsRate must be greater than 0");
        require(maxSlippage <= 1e18, "maxSlippage can not be greater than 1e18");

        principals = principalShare.balanceOf(address(this));
        yields = yieldShare.balanceOf(address(this));

        if (!tempusPool.matured()) {
            if (((yields > principals) ? (yields - principals) : (principals - yields)) >= maxLeftoverShares) {
                (uint256 swapAmount, bool yieldsIn) = tempusAMM.getSwapAmountToEndWithEqualShares(
                    principals,
                    yields,
                    maxLeftoverShares
                );
                uint256 minReturn = yieldsIn
                    ? swapAmount.mulfV(yieldsRate, tempusPool.backingTokenONE())
                    : swapAmount.divfV(yieldsRate, tempusPool.backingTokenONE());

                minReturn = minReturn.mulfV(1e18 - maxSlippage, 1e18);

                swap(
                    tempusAMM,
                    swapAmount,
                    yieldsIn ? yieldShare : principalShare,
                    yieldsIn ? principalShare : yieldShare,
                    minReturn,
                    deadline
                );

                principals = principalShare.balanceOf(address(this));
                yields = yieldShare.balanceOf(address(this));
            }
            (yields, principals) = (principals <= yields) ? (principals, principals) : (yields, yields);
        }

        if (toBackingToken) {
            _redeemToBacking(tempusPool, address(this), principals, yields, msg.sender);
        } else {
            _redeemToYieldBearing(tempusPool, address(this), principals, yields, msg.sender);
        }
    }

    function _getAMMDetailsAndEnsureInitialized(ITempusAMM tempusAMM)
        private
        view
        returns (
            IVault vault,
            bytes32 poolId,
            IERC20[] memory ammTokens,
            uint256[] memory ammBalances
        )
    {

        vault = tempusAMM.getVault();
        poolId = tempusAMM.getPoolId();
        (ammTokens, ammBalances, ) = vault.getPoolTokens(poolId);
        require(
            ammTokens.length == 2 && ammBalances.length == 2 && ammBalances[0] > 0 && ammBalances[1] > 0,
            "AMM not initialized"
        );
    }

    function getAMMOrderedAmounts(
        ITempusAMM tempusAMM,
        uint256 principalAmount,
        uint256 yieldAmount
    ) private view returns (uint256[] memory) {

        IVault vault = tempusAMM.getVault();
        (IERC20[] memory ammTokens, , ) = vault.getPoolTokens(tempusAMM.getPoolId());
        uint256[] memory amounts = new uint256[](2);
        (amounts[0], amounts[1]) = (address(tempusAMM.tempusPool().principalShare()) == address(ammTokens[0]))
            ? (principalAmount, yieldAmount)
            : (yieldAmount, principalAmount);
        return amounts;
    }
}