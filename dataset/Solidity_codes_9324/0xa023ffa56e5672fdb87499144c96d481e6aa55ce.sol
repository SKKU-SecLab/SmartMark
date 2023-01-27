
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

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.7.6;

interface IPendleYieldTokenHolder {

    function redeemRewards() external;


    function setUpEmergencyMode(address spender) external;


    function yieldToken() external returns (address);


    function forge() external returns (address);


    function rewardToken() external returns (address);


    function expiry() external returns (uint256);

}// BUSL-1.1
pragma solidity 0.7.6;

contract PendleGovernanceManager {

    address public governance;
    address public pendingGovernance;

    event GovernanceClaimed(address newGovernance, address previousGovernance);

    event TransferGovernancePending(address pendingGovernance);

    constructor(address _governance) {
        require(_governance != address(0), "ZERO_ADDRESS");
        governance = _governance;
    }

    modifier onlyGovernance() {

        require(msg.sender == governance, "ONLY_GOVERNANCE");
        _;
    }

    function claimGovernance() external {

        require(pendingGovernance == msg.sender, "WRONG_GOVERNANCE");
        emit GovernanceClaimed(pendingGovernance, governance);
        governance = pendingGovernance;
        pendingGovernance = address(0);
    }

    function transferGovernance(address _governance) external onlyGovernance {

        require(_governance != address(0), "ZERO_ADDRESS");
        pendingGovernance = _governance;

        emit TransferGovernancePending(pendingGovernance);
    }
}// MIT

pragma solidity 0.7.6;
pragma abicoder v2;


interface IPermissionsV2 {

    function governanceManager() external returns (PendleGovernanceManager);

}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract PermissionsV2 is IPermissionsV2 {
    PendleGovernanceManager public immutable override governanceManager;
    address internal initializer;

    constructor(address _governanceManager) {
        require(_governanceManager != address(0), "ZERO_ADDRESS");
        initializer = msg.sender;
        governanceManager = PendleGovernanceManager(_governanceManager);
    }

    modifier initialized() {
        require(initializer == address(0), "NOT_INITIALIZED");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == _governance(), "ONLY_GOVERNANCE");
        _;
    }

    function _governance() internal view returns (address) {
        return governanceManager.governance();
    }
}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract WithdrawableV2 is PermissionsV2 {
    using SafeERC20 for IERC20;

    event EtherWithdraw(uint256 amount, address sendTo);
    event TokenWithdraw(IERC20 token, uint256 amount, address sendTo);

    function withdrawEther(uint256 amount, address payable sendTo) external onlyGovernance {
        (bool success, ) = sendTo.call{value: amount}("");
        require(success, "WITHDRAW_FAILED");
        emit EtherWithdraw(amount, sendTo);
    }

    function withdrawToken(
        IERC20 token,
        uint256 amount,
        address sendTo
    ) external onlyGovernance {
        require(_allowedToWithdraw(address(token)), "TOKEN_NOT_ALLOWED");
        token.safeTransfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }

    function _allowedToWithdraw(address) internal view virtual returns (bool allowed);
}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract PendleYieldTokenHolderBase is IPendleYieldTokenHolder, WithdrawableV2 {
    using SafeERC20 for IERC20;

    address public immutable override yieldToken;
    address public immutable override forge;
    address public immutable override rewardToken;
    uint256 public immutable override expiry;

    constructor(
        address _governanceManager,
        address _forge,
        address _yieldToken,
        address _rewardToken,
        address _rewardManager,
        uint256 _expiry
    ) PermissionsV2(_governanceManager) {
        require(_yieldToken != address(0) && _rewardToken != address(0), "ZERO_ADDRESS");
        yieldToken = _yieldToken;
        forge = _forge;
        rewardToken = _rewardToken;
        expiry = _expiry;

        IERC20(_yieldToken).safeApprove(_forge, type(uint256).max);
        IERC20(_rewardToken).safeApprove(_rewardManager, type(uint256).max);
    }

    function redeemRewards() external virtual override;

    function setUpEmergencyMode(address spender) external override {
        require(msg.sender == forge, "NOT_FROM_FORGE");
        IERC20(yieldToken).safeApprove(spender, type(uint256).max);
        IERC20(rewardToken).safeApprove(spender, type(uint256).max);
    }

    function _allowedToWithdraw(address _token) internal view override returns (bool allowed) {
        allowed = _token != yieldToken && _token != rewardToken;
    }
}// MIT
pragma solidity 0.7.6;

interface IComptroller {

    struct Market {
        bool isListed;
        uint256 collateralFactorMantissa;
    }

    function markets(address) external view returns (Market memory);


    function claimComp(
        address[] memory holders,
        address[] memory cTokens,
        bool borrowers,
        bool suppliers
    ) external;


    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256 error,
            uint256 liquidity,
            uint256 shortfall
        );

    function getAssetsIn(address account) external view returns (address[] memory);

}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleCompoundYieldTokenHolder is PendleYieldTokenHolderBase {

    IComptroller private immutable comptroller;

    constructor(
        address _governanceManager,
        address _forge,
        address _yieldToken,
        address _rewardToken,
        address _rewardManager,
        address _comptroller,
        uint256 _expiry
    )
        PendleYieldTokenHolderBase(
            _governanceManager,
            _forge,
            _yieldToken,
            _rewardToken,
            _rewardManager,
            _expiry
        )
    {
        require(_comptroller != address(0), "ZERO_ADDRESS");
        comptroller = IComptroller(_comptroller);
    }

    function redeemRewards() external override {

        address[] memory cTokens = new address[](1);
        address[] memory holders = new address[](1);
        cTokens[0] = yieldToken;
        holders[0] = address(this);
        comptroller.claimComp(holders, cTokens, false, true);
    }
}// MIT
pragma solidity 0.7.6;

interface IPendleYieldContractDeployer {

    function forgeId() external returns (bytes32);


    function forgeOwnershipToken(
        address _underlyingAsset,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _expiry
    ) external returns (address ot);


    function forgeFutureYieldToken(
        address _underlyingAsset,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _expiry
    ) external returns (address xyt);


    function deployYieldTokenHolder(address yieldToken, uint256 expiry)
        external
        returns (address yieldTokenHolder);

}// MIT
pragma solidity 0.7.6;


interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;

}// MIT

pragma solidity 0.7.6;


interface IPendleBaseToken is IERC20 {

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function start() external view returns (uint256);


    function expiry() external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// MIT

pragma solidity 0.7.6;


interface IPendleYieldToken is IERC20, IPendleBaseToken {

    event Burn(address indexed user, uint256 amount);

    event Mint(address indexed user, uint256 amount);

    function burn(address user, uint256 amount) external;


    function mint(address user, uint256 amount) external;


    function forge() external view returns (IPendleForge);


    function underlyingAsset() external view returns (address);


    function underlyingYieldToken() external view returns (address);


    function approveRouter(address user) external;

}// MIT
pragma solidity 0.7.6;

interface IPendlePausingManager {

    event AddPausingAdmin(address admin);
    event RemovePausingAdmin(address admin);
    event PendingForgeEmergencyHandler(address _pendingForgeHandler);
    event PendingMarketEmergencyHandler(address _pendingMarketHandler);
    event PendingLiqMiningEmergencyHandler(address _pendingLiqMiningHandler);
    event ForgeEmergencyHandlerSet(address forgeEmergencyHandler);
    event MarketEmergencyHandlerSet(address marketEmergencyHandler);
    event LiqMiningEmergencyHandlerSet(address liqMiningEmergencyHandler);

    event PausingManagerLocked();
    event ForgeHandlerLocked();
    event MarketHandlerLocked();
    event LiqMiningHandlerLocked();

    event SetForgePaused(bytes32 forgeId, bool settingToPaused);
    event SetForgeAssetPaused(bytes32 forgeId, address underlyingAsset, bool settingToPaused);
    event SetForgeAssetExpiryPaused(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        bool settingToPaused
    );

    event SetForgeLocked(bytes32 forgeId);
    event SetForgeAssetLocked(bytes32 forgeId, address underlyingAsset);
    event SetForgeAssetExpiryLocked(bytes32 forgeId, address underlyingAsset, uint256 expiry);

    event SetMarketFactoryPaused(bytes32 marketFactoryId, bool settingToPaused);
    event SetMarketPaused(bytes32 marketFactoryId, address market, bool settingToPaused);

    event SetMarketFactoryLocked(bytes32 marketFactoryId);
    event SetMarketLocked(bytes32 marketFactoryId, address market);

    event SetLiqMiningPaused(address liqMiningContract, bool settingToPaused);
    event SetLiqMiningLocked(address liqMiningContract);

    function forgeEmergencyHandler()
        external
        view
        returns (
            address handler,
            address pendingHandler,
            uint256 timelockDeadline
        );


    function marketEmergencyHandler()
        external
        view
        returns (
            address handler,
            address pendingHandler,
            uint256 timelockDeadline
        );


    function liqMiningEmergencyHandler()
        external
        view
        returns (
            address handler,
            address pendingHandler,
            uint256 timelockDeadline
        );


    function permLocked() external view returns (bool);


    function permForgeHandlerLocked() external view returns (bool);


    function permMarketHandlerLocked() external view returns (bool);


    function permLiqMiningHandlerLocked() external view returns (bool);


    function isPausingAdmin(address) external view returns (bool);


    function setPausingAdmin(address admin, bool isAdmin) external;


    function requestForgeHandlerChange(address _pendingForgeHandler) external;


    function requestMarketHandlerChange(address _pendingMarketHandler) external;


    function requestLiqMiningHandlerChange(address _pendingLiqMiningHandler) external;


    function applyForgeHandlerChange() external;


    function applyMarketHandlerChange() external;


    function applyLiqMiningHandlerChange() external;


    function lockPausingManagerPermanently() external;


    function lockForgeHandlerPermanently() external;


    function lockMarketHandlerPermanently() external;


    function lockLiqMiningHandlerPermanently() external;


    function setForgePaused(bytes32 forgeId, bool paused) external;


    function setForgeAssetPaused(
        bytes32 forgeId,
        address underlyingAsset,
        bool paused
    ) external;


    function setForgeAssetExpiryPaused(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        bool paused
    ) external;


    function setForgeLocked(bytes32 forgeId) external;


    function setForgeAssetLocked(bytes32 forgeId, address underlyingAsset) external;


    function setForgeAssetExpiryLocked(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external;


    function checkYieldContractStatus(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external returns (bool _paused, bool _locked);


    function setMarketFactoryPaused(bytes32 marketFactoryId, bool paused) external;


    function setMarketPaused(
        bytes32 marketFactoryId,
        address market,
        bool paused
    ) external;


    function setMarketFactoryLocked(bytes32 marketFactoryId) external;


    function setMarketLocked(bytes32 marketFactoryId, address market) external;


    function checkMarketStatus(bytes32 marketFactoryId, address market)
        external
        returns (bool _paused, bool _locked);


    function setLiqMiningPaused(address liqMiningContract, bool settingToPaused) external;


    function setLiqMiningLocked(address liqMiningContract) external;


    function checkLiqMiningStatus(address liqMiningContract)
        external
        returns (bool _paused, bool _locked);

}// GPL-2.0-or-later
pragma solidity 0.7.6;

struct TokenReserve {
    uint256 weight;
    uint256 balance;
}

struct PendingTransfer {
    uint256 amount;
    bool isOut;
}// MIT

pragma solidity 0.7.6;


interface IPendleMarket is IERC20 {

    event Sync(uint256 reserve0, uint256 weight0, uint256 reserve1);

    function setUpEmergencyMode(address spender) external;


    function bootstrap(
        address user,
        uint256 initialXytLiquidity,
        uint256 initialTokenLiquidity
    ) external returns (PendingTransfer[2] memory transfers, uint256 exactOutLp);


    function addMarketLiquiditySingle(
        address user,
        address inToken,
        uint256 inAmount,
        uint256 minOutLp
    ) external returns (PendingTransfer[2] memory transfers, uint256 exactOutLp);


    function addMarketLiquidityDual(
        address user,
        uint256 _desiredXytAmount,
        uint256 _desiredTokenAmount,
        uint256 _xytMinAmount,
        uint256 _tokenMinAmount
    ) external returns (PendingTransfer[2] memory transfers, uint256 lpOut);


    function removeMarketLiquidityDual(
        address user,
        uint256 inLp,
        uint256 minOutXyt,
        uint256 minOutToken
    ) external returns (PendingTransfer[2] memory transfers);


    function removeMarketLiquiditySingle(
        address user,
        address outToken,
        uint256 exactInLp,
        uint256 minOutToken
    ) external returns (PendingTransfer[2] memory transfers);


    function swapExactIn(
        address inToken,
        uint256 inAmount,
        address outToken,
        uint256 minOutAmount
    ) external returns (uint256 outAmount, PendingTransfer[2] memory transfers);


    function swapExactOut(
        address inToken,
        uint256 maxInAmount,
        address outToken,
        uint256 outAmount
    ) external returns (uint256 inAmount, PendingTransfer[2] memory transfers);


    function redeemLpInterests(address user) external returns (uint256 interests);


    function getReserves()
        external
        view
        returns (
            uint256 xytBalance,
            uint256 xytWeight,
            uint256 tokenBalance,
            uint256 tokenWeight,
            uint256 currentBlock
        );


    function factoryId() external view returns (bytes32);


    function token() external view returns (address);


    function xyt() external view returns (address);

}// MIT

pragma solidity 0.7.6;


interface IPendleData {

    event ForgeFactoryValiditySet(bytes32 _forgeId, bytes32 _marketFactoryId, bool _valid);

    event TreasurySet(address treasury);

    event LockParamsSet(uint256 lockNumerator, uint256 lockDenominator);

    event ExpiryDivisorSet(uint256 expiryDivisor);

    event ForgeFeeSet(uint256 forgeFee);

    event InterestUpdateRateDeltaForMarketSet(uint256 interestUpdateRateDeltaForMarket);

    event MarketFeesSet(uint256 _swapFee, uint256 _protocolSwapFee);

    event CurveShiftBlockDeltaSet(uint256 _blockDelta);

    event NewMarketFactory(bytes32 indexed marketFactoryId, address indexed marketFactoryAddress);

    function setForgeFactoryValidity(
        bytes32 _forgeId,
        bytes32 _marketFactoryId,
        bool _valid
    ) external;


    function setTreasury(address newTreasury) external;


    function router() external view returns (IPendleRouter);


    function pausingManager() external view returns (IPendlePausingManager);


    function treasury() external view returns (address);



    event ForgeAdded(bytes32 indexed forgeId, address indexed forgeAddress);

    function addForge(bytes32 forgeId, address forgeAddress) external;


    function storeTokens(
        bytes32 forgeId,
        address ot,
        address xyt,
        address underlyingAsset,
        uint256 expiry
    ) external;


    function setForgeFee(uint256 _forgeFee) external;


    function getPendleYieldTokens(
        bytes32 forgeId,
        address underlyingYieldToken,
        uint256 expiry
    ) external view returns (IPendleYieldToken ot, IPendleYieldToken xyt);


    function getForgeAddress(bytes32 forgeId) external view returns (address forgeAddress);


    function isValidXYT(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external view returns (bool);


    function isValidOT(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external view returns (bool);


    function validForgeFactoryPair(bytes32 _forgeId, bytes32 _marketFactoryId)
        external
        view
        returns (bool);


    function otTokens(
        bytes32 forgeId,
        address underlyingYieldToken,
        uint256 expiry
    ) external view returns (IPendleYieldToken ot);


    function xytTokens(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external view returns (IPendleYieldToken xyt);



    event MarketPairAdded(address indexed market, address indexed xyt, address indexed token);

    function addMarketFactory(bytes32 marketFactoryId, address marketFactoryAddress) external;


    function isMarket(address _addr) external view returns (bool result);


    function isXyt(address _addr) external view returns (bool result);


    function addMarket(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        address market
    ) external;


    function setMarketFees(uint256 _swapFee, uint256 _protocolSwapFee) external;


    function setInterestUpdateRateDeltaForMarket(uint256 _interestUpdateRateDeltaForMarket)
        external;


    function setLockParams(uint256 _lockNumerator, uint256 _lockDenominator) external;


    function setExpiryDivisor(uint256 _expiryDivisor) external;


    function setCurveShiftBlockDelta(uint256 _blockDelta) external;


    function allMarketsLength() external view returns (uint256);


    function forgeFee() external view returns (uint256);


    function interestUpdateRateDeltaForMarket() external view returns (uint256);


    function expiryDivisor() external view returns (uint256);


    function lockNumerator() external view returns (uint256);


    function lockDenominator() external view returns (uint256);


    function swapFee() external view returns (uint256);


    function protocolSwapFee() external view returns (uint256);


    function curveShiftBlockDelta() external view returns (uint256);


    function getMarketByIndex(uint256 index) external view returns (address market);


    function getMarket(
        bytes32 marketFactoryId,
        address xyt,
        address token
    ) external view returns (address market);


    function getMarketFactoryAddress(bytes32 marketFactoryId)
        external
        view
        returns (address marketFactoryAddress);


    function getMarketFromKey(
        address xyt,
        address token,
        bytes32 marketFactoryId
    ) external view returns (address market);

}// MIT

pragma solidity 0.7.6;


interface IPendleMarketFactory {

    function createMarket(address xyt, address token) external returns (address market);


    function router() external view returns (IPendleRouter);


    function marketFactoryId() external view returns (bytes32);

}// MIT

pragma solidity 0.7.6;


interface IPendleRouter {

    event MarketCreated(
        bytes32 marketFactoryId,
        address indexed xyt,
        address indexed token,
        address indexed market
    );

    event SwapEvent(
        address indexed trader,
        address inToken,
        address outToken,
        uint256 exactIn,
        uint256 exactOut,
        address market
    );

    event Join(
        address indexed sender,
        uint256 token0Amount,
        uint256 token1Amount,
        address market,
        uint256 exactOutLp
    );

    event Exit(
        address indexed sender,
        uint256 token0Amount,
        uint256 token1Amount,
        address market,
        uint256 exactInLp
    );

    function data() external view returns (IPendleData);


    function weth() external view returns (IWETH);



    function newYieldContracts(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external returns (address ot, address xyt);


    function redeemAfterExpiry(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external returns (uint256 redeemedAmount);


    function redeemDueInterests(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        address user
    ) external returns (uint256 interests);


    function redeemUnderlying(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        uint256 amountToRedeem
    ) external returns (uint256 redeemedAmount);


    function renewYield(
        bytes32 forgeId,
        uint256 oldExpiry,
        address underlyingAsset,
        uint256 newExpiry,
        uint256 renewalRate
    )
        external
        returns (
            uint256 redeemedAmount,
            uint256 amountRenewed,
            address ot,
            address xyt,
            uint256 amountTokenMinted
        );


    function tokenizeYield(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        uint256 amountToTokenize,
        address to
    )
        external
        returns (
            address ot,
            address xyt,
            uint256 amountTokenMinted
        );



    function addMarketLiquidityDual(
        bytes32 _marketFactoryId,
        address _xyt,
        address _token,
        uint256 _desiredXytAmount,
        uint256 _desiredTokenAmount,
        uint256 _xytMinAmount,
        uint256 _tokenMinAmount
    )
        external
        payable
        returns (
            uint256 amountXytUsed,
            uint256 amountTokenUsed,
            uint256 lpOut
        );


    function addMarketLiquiditySingle(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        bool forXyt,
        uint256 exactInAsset,
        uint256 minOutLp
    ) external payable returns (uint256 exactOutLp);


    function removeMarketLiquidityDual(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        uint256 exactInLp,
        uint256 minOutXyt,
        uint256 minOutToken
    ) external returns (uint256 exactOutXyt, uint256 exactOutToken);


    function removeMarketLiquiditySingle(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        bool forXyt,
        uint256 exactInLp,
        uint256 minOutAsset
    ) external returns (uint256 exactOutXyt, uint256 exactOutToken);


    function createMarket(
        bytes32 marketFactoryId,
        address xyt,
        address token
    ) external returns (address market);


    function bootstrapMarket(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        uint256 initialXytLiquidity,
        uint256 initialTokenLiquidity
    ) external payable;


    function swapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 inTotalAmount,
        uint256 minOutTotalAmount,
        bytes32 marketFactoryId
    ) external payable returns (uint256 outTotalAmount);


    function swapExactOut(
        address tokenIn,
        address tokenOut,
        uint256 outTotalAmount,
        uint256 maxInTotalAmount,
        bytes32 marketFactoryId
    ) external payable returns (uint256 inTotalAmount);


    function redeemLpInterests(address market, address user) external returns (uint256 interests);

}// MIT
pragma solidity 0.7.6;

interface IPendleRewardManager {

    event UpdateFrequencySet(address[], uint256[]);
    event SkippingRewardsSet(bool);

    event DueRewardsSettled(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        uint256 amountOut,
        address user
    );

    function redeemRewards(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external returns (uint256 dueRewards);


    function updatePendingRewards(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external;


    function updateParamLManual(address _underlyingAsset, uint256 _expiry) external;


    function setUpdateFrequency(
        address[] calldata underlyingAssets,
        uint256[] calldata frequencies
    ) external;


    function setSkippingRewards(bool skippingRewards) external;


    function forgeId() external returns (bytes32);

}// MIT

pragma solidity 0.7.6;


interface IPendleForge {

    event MintYieldTokens(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        uint256 amountToTokenize,
        uint256 amountTokenMinted,
        address indexed user
    );

    event NewYieldContracts(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        address ot,
        address xyt,
        address yieldBearingAsset
    );

    event RedeemYieldToken(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        uint256 amountToRedeem,
        uint256 redeemedAmount,
        address indexed user
    );

    event DueInterestsSettled(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        uint256 amount,
        uint256 forgeFeeAmount,
        address indexed user
    );

    event ForgeFeeWithdrawn(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        uint256 amount
    );

    function setUpEmergencyMode(
        address _underlyingAsset,
        uint256 _expiry,
        address spender
    ) external;


    function newYieldContracts(address underlyingAsset, uint256 expiry)
        external
        returns (address ot, address xyt);


    function redeemAfterExpiry(
        address user,
        address underlyingAsset,
        uint256 expiry
    ) external returns (uint256 redeemedAmount);


    function redeemDueInterests(
        address user,
        address underlyingAsset,
        uint256 expiry
    ) external returns (uint256 interests);


    function updateDueInterests(
        address underlyingAsset,
        uint256 expiry,
        address user
    ) external;


    function updatePendingRewards(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external;


    function redeemUnderlying(
        address user,
        address underlyingAsset,
        uint256 expiry,
        uint256 amountToRedeem
    ) external returns (uint256 redeemedAmount);


    function mintOtAndXyt(
        address underlyingAsset,
        uint256 expiry,
        uint256 amountToTokenize,
        address to
    )
        external
        returns (
            address ot,
            address xyt,
            uint256 amountTokenMinted
        );


    function withdrawForgeFee(address underlyingAsset, uint256 expiry) external;


    function getYieldBearingToken(address underlyingAsset) external returns (address);


    function router() external view returns (IPendleRouter);


    function data() external view returns (IPendleData);


    function rewardManager() external view returns (IPendleRewardManager);


    function yieldContractDeployer() external view returns (IPendleYieldContractDeployer);


    function rewardToken() external view returns (IERC20);


    function forgeId() external view returns (bytes32);


    function dueInterests(
        address _underlyingAsset,
        uint256 expiry,
        address _user
    ) external view returns (uint256);


    function yieldTokenHolders(address _underlyingAsset, uint256 _expiry)
        external
        view
        returns (address yieldTokenHolder);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract PendleBaseToken is ERC20 {
    using SafeMath for uint256;

    uint256 public immutable start;
    uint256 public immutable expiry;
    IPendleRouter public immutable router;

    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;


    constructor(
        address _router,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _start,
        uint256 _expiry
    ) ERC20(_name, _symbol) {
        _setupDecimals(_decimals);
        start = _start;
        expiry = _expiry;
        router = IPendleRouter(_router);

        uint256 chainId;
        assembly {
            chainId := chainid() // chainid() is a function in assembly in this solidity version
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_name)), // use our own _name here
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "PERMIT_EXPIRED");
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
        address recoveredAddress = ECDSA.recover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal virtual override {
        require(to != address(this), "SEND_TO_TOKEN_CONTRACT");
        require(to != from, "SEND_TO_SELF");
    }
}// MIT

pragma solidity 0.7.6;

interface IPendleYieldTokenCommon {
    event Burn(address indexed user, uint256 amount);

    event Mint(address indexed user, uint256 amount);

    function burn(address user, uint256 amount) external;

    function mint(address user, uint256 amount) external;

    function forge() external view returns (address);

    function underlyingAsset() external view returns (address);

    function underlyingYieldToken() external view returns (address);
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleFutureYieldToken is PendleBaseToken, IPendleYieldTokenCommon {
    address public immutable override forge;
    address public immutable override underlyingAsset;
    address public immutable override underlyingYieldToken;

    constructor(
        address _router,
        address _forge,
        address _underlyingAsset,
        address _underlyingYieldToken,
        string memory _name,
        string memory _symbol,
        uint8 _underlyingYieldTokenDecimals,
        uint256 _start,
        uint256 _expiry
    ) PendleBaseToken(_router, _name, _symbol, _underlyingYieldTokenDecimals, _start, _expiry) {
        require(
            _underlyingAsset != address(0) && _underlyingYieldToken != address(0),
            "ZERO_ADDRESS"
        );
        require(_forge != address(0), "ZERO_ADDRESS");
        forge = _forge;
        underlyingAsset = _underlyingAsset;
        underlyingYieldToken = _underlyingYieldToken;
    }

    modifier onlyForge() {
        require(msg.sender == address(forge), "ONLY_FORGE");
        _;
    }

    function burn(address user, uint256 amount) public override onlyForge {
        _burn(user, amount);
        emit Burn(user, amount);
    }

    function mint(address user, uint256 amount) public override onlyForge {
        _mint(user, amount);
        emit Mint(user, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);
        if (from != address(0))
            IPendleForge(forge).updateDueInterests(underlyingAsset, expiry, from);
        if (to != address(0)) IPendleForge(forge).updateDueInterests(underlyingAsset, expiry, to);
    }

    function approveRouter(address user) external {
        require(msg.sender == address(router), "NOT_ROUTER");
        _approve(user, address(router), type(uint256).max);
    }
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleOwnershipToken is PendleBaseToken, IPendleYieldTokenCommon {
    address public immutable override forge;
    address public immutable override underlyingAsset;
    address public immutable override underlyingYieldToken;

    constructor(
        address _router,
        address _forge,
        address _underlyingAsset,
        address _underlyingYieldToken,
        string memory _name,
        string memory _symbol,
        uint8 _underlyingYieldTokenDecimals,
        uint256 _start,
        uint256 _expiry
    ) PendleBaseToken(_router, _name, _symbol, _underlyingYieldTokenDecimals, _start, _expiry) {
        require(
            _underlyingAsset != address(0) && _underlyingYieldToken != address(0),
            "ZERO_ADDRESS"
        );
        require(_forge != address(0), "ZERO_ADDRESS");
        forge = _forge;
        underlyingAsset = _underlyingAsset;
        underlyingYieldToken = _underlyingYieldToken;
    }

    modifier onlyForge() {
        require(msg.sender == address(forge), "ONLY_FORGE");
        _;
    }

    function burn(address user, uint256 amount) public override onlyForge {
        _burn(user, amount);
        emit Burn(user, amount);
    }

    function mint(address user, uint256 amount) public override onlyForge {
        _mint(user, amount);
        emit Mint(user, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (from != address(0))
            IPendleForge(forge).updatePendingRewards(underlyingAsset, expiry, from);
        if (to != address(0))
            IPendleForge(forge).updatePendingRewards(underlyingAsset, expiry, to);
    }
}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract PendleYieldContractDeployerBase is IPendleYieldContractDeployer, PermissionsV2 {
    bytes32 public immutable override forgeId;
    IPendleForge public forge;

    modifier onlyForge() {
        require(msg.sender == address(forge), "ONLY_FORGE");
        _;
    }

    constructor(address _governanceManager, bytes32 _forgeId) PermissionsV2(_governanceManager) {
        forgeId = _forgeId;
    }

    function initialize(address _forgeAddress) external {
        require(msg.sender == initializer, "FORBIDDEN");
        require(address(_forgeAddress) != address(0), "ZERO_ADDRESS");

        forge = IPendleForge(_forgeAddress);
        require(forge.forgeId() == forgeId, "FORGE_ID_MISMATCH");
        initializer = address(0);
    }

    function forgeFutureYieldToken(
        address _underlyingAsset,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _expiry
    ) external override onlyForge returns (address xyt) {
        xyt = address(
            new PendleFutureYieldToken(
                address(forge.router()),
                address(forge),
                _underlyingAsset,
                forge.getYieldBearingToken(_underlyingAsset),
                _name,
                _symbol,
                _decimals,
                block.timestamp,
                _expiry
            )
        );
    }

    function forgeOwnershipToken(
        address _underlyingAsset,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _expiry
    ) external override onlyForge returns (address ot) {
        ot = address(
            new PendleOwnershipToken(
                address(forge.router()),
                address(forge),
                _underlyingAsset,
                forge.getYieldBearingToken(_underlyingAsset),
                _name,
                _symbol,
                _decimals,
                block.timestamp,
                _expiry
            )
        );
    }

    function deployYieldTokenHolder(address yieldToken, uint256 expiry)
        external
        virtual
        override
        returns (address yieldTokenHolder);
}// MIT
pragma solidity 0.7.6;


interface ICToken is IERC20 {

    function balanceOfUnderlying(address owner) external returns (uint256);

    function isCToken() external returns (bool);

    function underlying() external returns (address);

    function mint(uint256 mintAmount) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256 error,
            uint256 balance,
            uint256 borrowed,
            uint256 exchangeRate
        );

    function decimals() external view returns (uint256);
}// MIT

pragma solidity 0.7.6;


interface IPendleCompoundForge is IPendleForge {
    function getExchangeRate(address _underlyingAsset) external returns (uint256);
}// GPL-2.0-or-later
pragma solidity 0.7.6;


library ExpiryUtils {
    struct Date {
        uint16 year;
        uint8 month;
        uint8 day;
    }

    uint256 private constant DAY_IN_SECONDS = 86400;
    uint256 private constant YEAR_IN_SECONDS = 31536000;
    uint256 private constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint16 private constant ORIGIN_YEAR = 1970;

    function concat(
        string memory _bt,
        string memory _yt,
        uint256 _expiry,
        string memory _delimiter
    ) internal pure returns (string memory result) {
        result = string(
            abi.encodePacked(_bt, _delimiter, _yt, _delimiter, toRFC2822String(_expiry))
        );
    }

    function toRFC2822String(uint256 _timestamp) internal pure returns (string memory s) {
        Date memory d = parseTimestamp(_timestamp);
        string memory day = uintToString(d.day);
        string memory month = monthName(d);
        string memory year = uintToString(d.year);
        s = string(abi.encodePacked(day, month, year));
    }

    function getDaysInMonth(uint8 _month, uint16 _year) private pure returns (uint8) {
        if (
            _month == 1 ||
            _month == 3 ||
            _month == 5 ||
            _month == 7 ||
            _month == 8 ||
            _month == 10 ||
            _month == 12
        ) {
            return 31;
        } else if (_month == 4 || _month == 6 || _month == 9 || _month == 11) {
            return 30;
        } else if (isLeapYear(_year)) {
            return 29;
        } else {
            return 28;
        }
    }

    function getYear(uint256 _timestamp) private pure returns (uint16) {
        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;

        year = uint16(ORIGIN_YEAR + _timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > _timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function isLeapYear(uint16 _year) private pure returns (bool) {
        return ((_year % 4 == 0) && (_year % 100 != 0)) || (_year % 400 == 0);
    }

    function leapYearsBefore(uint256 _year) private pure returns (uint256) {
        _year -= 1;
        return _year / 4 - _year / 100 + _year / 400;
    }

    function monthName(Date memory d) private pure returns (string memory) {
        string[12] memory months =
            ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        return months[d.month - 1];
    }

    function parseTimestamp(uint256 _timestamp) private pure returns (Date memory d) {
        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 i;

        d.year = getYear(_timestamp);
        buf = leapYearsBefore(d.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (d.year - ORIGIN_YEAR - buf);

        uint256 secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, d.year);
            if (secondsInMonth + secondsAccountedFor > _timestamp) {
                d.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        for (i = 1; i <= getDaysInMonth(d.month, d.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > _timestamp) {
                d.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
    }

    function uintToString(uint256 _i) private pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}// GPL-2.0-or-later
pragma solidity 0.7.6;


library Math {
    using SafeMath for uint256;

    uint256 internal constant BIG_NUMBER = (uint256(1) << uint256(200));
    uint256 internal constant PRECISION_BITS = 40;
    uint256 internal constant RONE = uint256(1) << PRECISION_BITS;
    uint256 internal constant PI = (314 * RONE) / 10**2;
    uint256 internal constant PI_PLUSONE = (414 * RONE) / 10**2;
    uint256 internal constant PRECISION_POW = 1e2;

    function checkMultOverflow(uint256 _x, uint256 _y) internal pure returns (bool) {
        if (_y == 0) return false;
        return (((_x * _y) / _y) != _x);
    }

    function log2Int(uint256 _p, uint256 _q) internal pure returns (uint256) {
        uint256 res = 0;
        uint256 remain = _p / _q;
        while (remain > 0) {
            res++;
            remain /= 2;
        }
        return res - 1;
    }

    function log2ForSmallNumber(uint256 _x) internal pure returns (uint256) {
        uint256 res = 0;
        uint256 one = (uint256(1) << PRECISION_BITS);
        uint256 two = 2 * one;
        uint256 addition = one;

        require((_x >= one) && (_x < two), "MATH_ERROR");
        require(PRECISION_BITS < 125, "MATH_ERROR");

        for (uint256 i = PRECISION_BITS; i > 0; i--) {
            _x = (_x * _x) / one;
            addition = addition / 2;
            if (_x >= two) {
                _x = _x / 2;
                res += addition;
            }
        }

        return res;
    }

    function logBase2(uint256 _p, uint256 _q) internal pure returns (uint256) {
        uint256 n = 0;

        if (_p > _q) {
            n = log2Int(_p, _q);
        }

        require(n * RONE <= BIG_NUMBER, "MATH_ERROR");
        require(!checkMultOverflow(_p, RONE), "MATH_ERROR");
        require(!checkMultOverflow(n, RONE), "MATH_ERROR");
        require(!checkMultOverflow(uint256(1) << n, _q), "MATH_ERROR");

        uint256 y = (_p * RONE) / (_q * (uint256(1) << n));
        uint256 log2Small = log2ForSmallNumber(y);

        assert(log2Small <= BIG_NUMBER);

        return n * RONE + log2Small;
    }

    function ln(uint256 p, uint256 q) internal pure returns (uint256) {
        uint256 ln2Numerator = 6931471805599453094172;
        uint256 ln2Denomerator = 10000000000000000000000;

        uint256 log2x = logBase2(p, q);

        require(!checkMultOverflow(ln2Numerator, log2x), "MATH_ERROR");

        return (ln2Numerator * log2x) / ln2Denomerator;
    }

    function fpart(uint256 value) internal pure returns (uint256) {
        return value % RONE;
    }

    function toInt(uint256 value) internal pure returns (uint256) {
        return value / RONE;
    }

    function toFP(uint256 value) internal pure returns (uint256) {
        return value * RONE;
    }

    function rpowe(uint256 exp) internal pure returns (uint256) {
        uint256 res = 0;

        uint256 curTerm = RONE;

        for (uint256 n = 0; ; n++) {
            res += curTerm;
            curTerm = rmul(curTerm, rdiv(exp, toFP(n + 1)));
            if (curTerm == 0) {
                break;
            }
            if (n == 500) {
                revert("RPOWE_SLOW_CONVERGE");
            }
        }

        return res;
    }

    function rpow(uint256 base, uint256 exp) internal pure returns (uint256) {
        if (exp == 0) {
            return RONE;
        }
        if (base == 0) {
            return 0;
        }

        uint256 frac = fpart(exp); // get the fractional part
        uint256 whole = exp - frac;

        uint256 wholePow = rpowi(base, toInt(whole)); // whole is a FP, convert to Int
        uint256 fracPow;

        if (base < RONE) {
            uint256 newExp = rmul(frac, ln(rdiv(RONE, base), RONE));
            fracPow = rdiv(RONE, rpowe(newExp));
        } else {
            uint256 newExp = rmul(frac, ln(base, RONE));
            fracPow = rpowe(newExp);
        }
        return rmul(wholePow, fracPow);
    }

    function rpowi(uint256 base, uint256 exp) internal pure returns (uint256) {
        uint256 res = exp % 2 != 0 ? base : RONE;

        for (exp /= 2; exp != 0; exp /= 2) {
            base = rmul(base, base);

            if (exp % 2 != 0) {
                res = rmul(res, base);
            }
        }
        return res;
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

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return (y / 2).add(x.mul(RONE)).div(y);
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return (RONE / 2).add(x.mul(y)).div(RONE);
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function subMax0(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a - b : 0;
    }
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
}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract PendleForgeBase is IPendleForge, WithdrawableV2, ReentrancyGuard {
    using ExpiryUtils for string;
    using SafeMath for uint256;
    using Math for uint256;
    using SafeERC20 for IERC20;

    struct PendleTokens {
        IPendleYieldToken xyt;
        IPendleYieldToken ot;
    }

    IPendleRouter public immutable override router;
    IPendleData public immutable override data;
    bytes32 public immutable override forgeId;
    IERC20 public immutable override rewardToken; // COMP/StkAAVE
    IPendleRewardManager public immutable override rewardManager;
    IPendleYieldContractDeployer public immutable override yieldContractDeployer;
    IPendlePausingManager public immutable pausingManager;

    mapping(address => mapping(uint256 => mapping(address => uint256)))
        public
        override dueInterests;

    mapping(address => mapping(uint256 => uint256)) public totalFee;
    mapping(address => mapping(uint256 => address)) public override yieldTokenHolders; // yieldTokenHolders[underlyingAsset][expiry]

    string private constant OT = "OT";
    string private constant XYT = "YT";

    modifier onlyXYT(address _underlyingAsset, uint256 _expiry) {
        require(
            msg.sender == address(data.xytTokens(forgeId, _underlyingAsset, _expiry)),
            "ONLY_YT"
        );
        _;
    }

    modifier onlyOT(address _underlyingAsset, uint256 _expiry) {
        require(
            msg.sender == address(data.otTokens(forgeId, _underlyingAsset, _expiry)),
            "ONLY_OT"
        );
        _;
    }

    modifier onlyRouter() {
        require(msg.sender == address(router), "ONLY_ROUTER");
        _;
    }

    constructor(
        address _governanceManager,
        IPendleRouter _router,
        bytes32 _forgeId,
        address _rewardToken,
        address _rewardManager,
        address _yieldContractDeployer
    ) PermissionsV2(_governanceManager) {
        require(address(_router) != address(0), "ZERO_ADDRESS");
        require(_forgeId != 0x0, "ZERO_BYTES");

        router = _router;
        forgeId = _forgeId;
        IPendleData _dataTemp = IPendleRouter(_router).data();
        data = _dataTemp;
        rewardToken = IERC20(_rewardToken);
        rewardManager = IPendleRewardManager(_rewardManager);
        yieldContractDeployer = IPendleYieldContractDeployer(_yieldContractDeployer);
        pausingManager = _dataTemp.pausingManager();
    }

    function checkNotPaused(address _underlyingAsset, uint256 _expiry) internal {
        (bool paused, ) =
            pausingManager.checkYieldContractStatus(forgeId, _underlyingAsset, _expiry);
        require(!paused, "YIELD_CONTRACT_PAUSED");
    }

    function setUpEmergencyMode(
        address _underlyingAsset,
        uint256 _expiry,
        address spender
    ) external override {
        (, bool emergencyMode) =
            pausingManager.checkYieldContractStatus(forgeId, _underlyingAsset, _expiry);
        require(emergencyMode, "NOT_EMERGENCY");
        (address forgeEmergencyHandler, , ) = pausingManager.forgeEmergencyHandler();
        require(msg.sender == forgeEmergencyHandler, "NOT_EMERGENCY_HANDLER");
        IPendleYieldTokenHolder(yieldTokenHolders[_underlyingAsset][_expiry]).setUpEmergencyMode(
            spender
        );
    }

    function newYieldContracts(address _underlyingAsset, uint256 _expiry)
        external
        override
        onlyRouter
        returns (address ot, address xyt)
    {
        checkNotPaused(_underlyingAsset, _expiry);
        address yieldToken = _getYieldBearingToken(_underlyingAsset);
        uint8 yieldTokenDecimals = IPendleYieldToken(yieldToken).decimals();


        ot = yieldContractDeployer.forgeOwnershipToken(
            _underlyingAsset,
            OT.concat(IPendleBaseToken(yieldToken).name(), _expiry, " "),
            OT.concat(IPendleBaseToken(yieldToken).symbol(), _expiry, "-"),
            yieldTokenDecimals,
            _expiry
        );

        xyt = yieldContractDeployer.forgeFutureYieldToken(
            _underlyingAsset,
            XYT.concat(IPendleBaseToken(yieldToken).name(), _expiry, " "),
            XYT.concat(IPendleBaseToken(yieldToken).symbol(), _expiry, "-"),
            yieldTokenDecimals,
            _expiry
        );

        yieldTokenHolders[_underlyingAsset][_expiry] = yieldContractDeployer
            .deployYieldTokenHolder(yieldToken, _expiry);

        data.storeTokens(forgeId, ot, xyt, _underlyingAsset, _expiry);

        emit NewYieldContracts(forgeId, _underlyingAsset, _expiry, ot, xyt, yieldToken);
    }

    function redeemAfterExpiry(
        address _user,
        address _underlyingAsset,
        uint256 _expiry
    ) external override onlyRouter returns (uint256 redeemedAmount) {
        checkNotPaused(_underlyingAsset, _expiry);
        IERC20 yieldToken = IERC20(_getYieldBearingToken(_underlyingAsset));
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);
        uint256 expiredOTamount = tokens.ot.balanceOf(_user);
        require(expiredOTamount > 0, "NOTHING_TO_REDEEM");

        tokens.ot.burn(_user, expiredOTamount);

        redeemedAmount = _calcTotalAfterExpiry(_underlyingAsset, _expiry, expiredOTamount);

        redeemedAmount = redeemedAmount.add(
            _beforeTransferDueInterests(tokens, _underlyingAsset, _expiry, _user, false)
        );

        redeemedAmount = _safeTransfer(
            yieldToken,
            _underlyingAsset,
            _expiry,
            _user,
            redeemedAmount
        );

        emit RedeemYieldToken(
            forgeId,
            _underlyingAsset,
            _expiry,
            expiredOTamount,
            redeemedAmount,
            _user
        );
    }

    function redeemUnderlying(
        address _user,
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _amountToRedeem
    ) external override onlyRouter returns (uint256 redeemedAmount) {
        checkNotPaused(_underlyingAsset, _expiry);
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);

        IERC20 yieldToken = IERC20(_getYieldBearingToken(_underlyingAsset));

        tokens.ot.burn(_user, _amountToRedeem);
        tokens.xyt.burn(_user, _amountToRedeem);

        redeemedAmount = _calcUnderlyingToRedeem(_underlyingAsset, _amountToRedeem).add(
            _beforeTransferDueInterests(tokens, _underlyingAsset, _expiry, _user, true)
        );

        redeemedAmount = _safeTransfer(
            yieldToken,
            _underlyingAsset,
            _expiry,
            _user,
            redeemedAmount
        );

        emit RedeemYieldToken(
            forgeId,
            _underlyingAsset,
            _expiry,
            _amountToRedeem,
            redeemedAmount,
            _user
        );

        return redeemedAmount;
    }

    function redeemDueInterests(
        address _user,
        address _underlyingAsset,
        uint256 _expiry
    ) external override onlyRouter returns (uint256 amountOut) {
        checkNotPaused(_underlyingAsset, _expiry);
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);
        IERC20 yieldToken = IERC20(_getYieldBearingToken(_underlyingAsset));

        amountOut = _beforeTransferDueInterests(tokens, _underlyingAsset, _expiry, _user, false);

        amountOut = _safeTransfer(yieldToken, _underlyingAsset, _expiry, _user, amountOut);
    }

    function updateDueInterests(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external override onlyXYT(_underlyingAsset, _expiry) nonReentrant {
        checkNotPaused(_underlyingAsset, _expiry);
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);
        uint256 principal = tokens.xyt.balanceOf(_user);
        _updateDueInterests(principal, _underlyingAsset, _expiry, _user);
    }

    function updatePendingRewards(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external override onlyOT(_underlyingAsset, _expiry) nonReentrant {
        checkNotPaused(_underlyingAsset, _expiry);
        rewardManager.updatePendingRewards(_underlyingAsset, _expiry, _user);
    }

    function mintOtAndXyt(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _amountToTokenize,
        address _to
    )
        external
        override
        onlyRouter
        returns (
            address ot,
            address xyt,
            uint256 amountTokenMinted
        )
    {
        checkNotPaused(_underlyingAsset, _expiry);
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);

        amountTokenMinted = _calcAmountToMint(_underlyingAsset, _amountToTokenize);

        tokens.ot.mint(_to, amountTokenMinted);

        tokens.xyt.mint(_to, amountTokenMinted);

        emit MintYieldTokens(
            forgeId,
            _underlyingAsset,
            _expiry,
            _amountToTokenize,
            amountTokenMinted,
            _to
        );
        return (address(tokens.ot), address(tokens.xyt), amountTokenMinted);
    }

    function withdrawForgeFee(address _underlyingAsset, uint256 _expiry)
        external
        override
        onlyGovernance
    {
        checkNotPaused(_underlyingAsset, _expiry);
        IERC20 yieldToken = IERC20(_getYieldBearingToken(_underlyingAsset));

        _updateForgeFee(_underlyingAsset, _expiry, 0);
        uint256 _totalFee = totalFee[_underlyingAsset][_expiry];
        totalFee[_underlyingAsset][_expiry] = 0;

        address treasuryAddress = data.treasury();
        _totalFee = _safeTransfer(
            yieldToken,
            _underlyingAsset,
            _expiry,
            treasuryAddress,
            _totalFee
        );
        emit ForgeFeeWithdrawn(forgeId, _underlyingAsset, _expiry, _totalFee);
    }

    function getYieldBearingToken(address _underlyingAsset) external override returns (address) {
        return _getYieldBearingToken(_underlyingAsset);
    }

    function _beforeTransferDueInterests(
        PendleTokens memory _tokens,
        address _underlyingAsset,
        uint256 _expiry,
        address _user,
        bool _skipUpdateDueInterests
    ) internal returns (uint256 amountOut) {
        uint256 principal = _tokens.xyt.balanceOf(_user);

        if (!_skipUpdateDueInterests) {
            _updateDueInterests(principal, _underlyingAsset, _expiry, _user);
        }

        amountOut = dueInterests[_underlyingAsset][_expiry][_user];
        dueInterests[_underlyingAsset][_expiry][_user] = 0;

        uint256 forgeFee = data.forgeFee();
        uint256 forgeFeeAmount;
        if (forgeFee > 0) {
            forgeFeeAmount = amountOut.rmul(forgeFee);
            amountOut = amountOut.sub(forgeFeeAmount);
            _updateForgeFee(_underlyingAsset, _expiry, forgeFeeAmount);
        }

        emit DueInterestsSettled(
            forgeId,
            _underlyingAsset,
            _expiry,
            amountOut,
            forgeFeeAmount,
            _user
        );
    }

    function _safeTransfer(
        IERC20 _yieldToken,
        address _underlyingAsset,
        uint256 _expiry,
        address _user,
        uint256 _amount
    ) internal returns (uint256) {
        address yieldTokenHolder = yieldTokenHolders[_underlyingAsset][_expiry];
        _amount = Math.min(_amount, _yieldToken.balanceOf(yieldTokenHolder));
        if (_amount == 0) return 0;
        _yieldToken.safeTransferFrom(yieldTokenHolder, _user, _amount);
        return _amount;
    }

    function _getTokens(address _underlyingAsset, uint256 _expiry)
        internal
        view
        returns (PendleTokens memory _tokens)
    {
        (_tokens.ot, _tokens.xyt) = data.getPendleYieldTokens(forgeId, _underlyingAsset, _expiry);
    }

    function _allowedToWithdraw(address) internal pure override returns (bool allowed) {
        allowed = true;
    }

    function _updateDueInterests(
        uint256 _principal,
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) internal virtual;

    function _updateForgeFee(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _feeAmount
    ) internal virtual;

    function _calcTotalAfterExpiry(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 redeemedAmount
    ) internal virtual returns (uint256 totalAfterExpiry);

    function _calcUnderlyingToRedeem(address, uint256 _amountToRedeem)
        internal
        virtual
        returns (uint256 underlyingToRedeem)
    {
        underlyingToRedeem = _amountToRedeem;
    }

    function _calcAmountToMint(address, uint256 _amountToTokenize)
        internal
        virtual
        returns (uint256 amountToMint)
    {
        amountToMint = _amountToTokenize;
    }

    function _getYieldBearingToken(address _underlyingAsset) internal virtual returns (address);
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleCompoundForge is PendleForgeBase, IPendleCompoundForge {
    using ExpiryUtils for string;
    using SafeMath for uint256;
    using Math for uint256;

    IComptroller public immutable comptroller;

    mapping(address => uint256) public initialRate;
    mapping(address => address) public underlyingToCToken;
    mapping(address => mapping(uint256 => uint256)) public lastRateBeforeExpiry;
    mapping(address => mapping(uint256 => mapping(address => uint256))) public lastRate;

    event RegisterCTokens(address[] underlyingAssets, address[] cTokens);

    constructor(
        address _governanceManager,
        IPendleRouter _router,
        IComptroller _comptroller,
        bytes32 _forgeId,
        address _rewardToken,
        address _rewardManager,
        address _yieldContractDeployer,
        address _coumpoundEth
    )
        PendleForgeBase(
            _governanceManager,
            _router,
            _forgeId,
            _rewardToken,
            _rewardManager,
            _yieldContractDeployer
        )
    {
        require(address(_comptroller) != address(0), "ZERO_ADDRESS");

        comptroller = _comptroller;

        address weth = address(_router.weth());
        underlyingToCToken[weth] = _coumpoundEth;
        initialRate[weth] = ICToken(_coumpoundEth).exchangeRateCurrent();
    }

    function registerCTokens(address[] calldata _underlyingAssets, address[] calldata _cTokens)
        external
        onlyGovernance
    {
        require(_underlyingAssets.length == _cTokens.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < _cTokens.length; ++i) {
            require(underlyingToCToken[_underlyingAssets[i]] == address(0), "FORBIDDEN");
            verifyCToken(_underlyingAssets[i], _cTokens[i]);
            underlyingToCToken[_underlyingAssets[i]] = _cTokens[i];
            initialRate[_underlyingAssets[i]] = ICToken(_cTokens[i]).exchangeRateCurrent();
        }

        emit RegisterCTokens(_underlyingAssets, _cTokens);
    }

    function verifyCToken(address _underlyingAsset, address _cTokenAddress) internal {
        require(
            comptroller.markets(_cTokenAddress).isListed &&
                ICToken(_cTokenAddress).isCToken() &&
                ICToken(_cTokenAddress).underlying() == _underlyingAsset,
            "INVALID_CTOKEN_DATA"
        );
    }

    function _calcTotalAfterExpiry(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 redeemedAmount
    ) internal view override returns (uint256 totalAfterExpiry) {
        totalAfterExpiry = redeemedAmount.mul(initialRate[_underlyingAsset]).div(
            lastRateBeforeExpiry[_underlyingAsset][_expiry]
        );
    }

    function getExchangeRateBeforeExpiry(address _underlyingAsset, uint256 _expiry)
        internal
        returns (uint256)
    {
        if (block.timestamp > _expiry) {
            return lastRateBeforeExpiry[_underlyingAsset][_expiry];
        }
        uint256 exchangeRate = ICToken(underlyingToCToken[_underlyingAsset]).exchangeRateCurrent();

        lastRateBeforeExpiry[_underlyingAsset][_expiry] = exchangeRate;
        return exchangeRate;
    }

    function getExchangeRate(address _underlyingAsset) public override returns (uint256) {
        return ICToken(underlyingToCToken[_underlyingAsset]).exchangeRateCurrent();
    }

    function _calcUnderlyingToRedeem(address _underlyingAsset, uint256 _amountToRedeem)
        internal
        override
        returns (uint256 underlyingToRedeem)
    {
        uint256 currentRate = getExchangeRate(_underlyingAsset);
        underlyingToRedeem = _amountToRedeem.mul(initialRate[_underlyingAsset]).div(currentRate);
    }

    function _calcAmountToMint(address _underlyingAsset, uint256 _amountToTokenize)
        internal
        override
        returns (uint256 amountToMint)
    {
        uint256 currentRate = getExchangeRate(_underlyingAsset);
        amountToMint = _amountToTokenize.mul(currentRate).div(initialRate[_underlyingAsset]);
    }

    function _getYieldBearingToken(address _underlyingAsset)
        internal
        view
        override
        returns (address)
    {
        require(underlyingToCToken[_underlyingAsset] != address(0), "INVALID_UNDERLYING_ASSET");
        return underlyingToCToken[_underlyingAsset];
    }

    function _updateDueInterests(
        uint256 principal,
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) internal override {
        uint256 prevRate = lastRate[_underlyingAsset][_expiry][_user];
        uint256 currentRate = getExchangeRateBeforeExpiry(_underlyingAsset, _expiry);

        lastRate[_underlyingAsset][_expiry][_user] = currentRate;
        if (prevRate == 0 || prevRate == currentRate) {
            return;
        }
        uint256 interestFromXyt = principal.mul(currentRate).div(prevRate).sub(principal);
        interestFromXyt = interestFromXyt.mul(initialRate[_underlyingAsset]).div(currentRate);

        dueInterests[_underlyingAsset][_expiry][_user] = dueInterests[_underlyingAsset][_expiry][
            _user
        ]
            .add(interestFromXyt);
    }

    function _updateForgeFee(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _feeAmount
    ) internal override {
        totalFee[_underlyingAsset][_expiry] = totalFee[_underlyingAsset][_expiry].add(_feeAmount);
    }
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleCompoundYieldContractDeployer is PendleYieldContractDeployerBase {
    constructor(address _governanceManager, bytes32 _forgeId)
        PendleYieldContractDeployerBase(_governanceManager, _forgeId)
    {}

    function deployYieldTokenHolder(address yieldToken, uint256 expiry)
        external
        override
        onlyForge
        returns (address yieldTokenHolder)
    {
        yieldTokenHolder = address(
            new PendleCompoundYieldTokenHolder(
                address(governanceManager),
                address(forge),
                yieldToken,
                address(forge.rewardToken()),
                address(forge.rewardManager()),
                address(PendleCompoundForge(address(forge)).comptroller()),
                expiry
            )
        );
    }
}