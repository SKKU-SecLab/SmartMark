
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
}// MIT

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
}// MIT

pragma solidity 0.7.6;

interface IPendleLiquidityMiningV2 {

    event Funded(uint256[] rewards, uint256 numberOfEpochs);
    event RewardsToppedUp(uint256[] epochIds, uint256[] rewards);
    event Staked(address user, uint256 amount);
    event Withdrawn(address user, uint256 amount);
    event PendleRewardsSettled(address user, uint256 amount);

    function fund(uint256[] calldata rewards) external;


    function topUpRewards(uint256[] calldata epochIds, uint256[] calldata rewards) external;


    function stake(address forAddr, uint256 amount) external;


    function withdraw(address toAddr, uint256 amount) external;


    function redeemRewards(address user) external returns (uint256 rewards);


    function redeemDueInterests(address user) external returns (uint256 amountOut);


    function setUpEmergencyMode(address spender, bool) external;


    function updateAndReadEpochData(uint256 epochId, address user)
        external
        returns (
            uint256 totalStakeUnits,
            uint256 totalRewards,
            uint256 lastUpdated,
            uint256 stakeUnitsForUser,
            uint256 availableRewardsForUser
        );


    function balances(address user) external view returns (uint256);


    function startTime() external view returns (uint256);


    function epochDuration() external view returns (uint256);


    function readEpochData(uint256 epochId, address user)
        external
        view
        returns (
            uint256 totalStakeUnits,
            uint256 totalRewards,
            uint256 lastUpdated,
            uint256 stakeUnitsForUser,
            uint256 availableRewardsForUser
        );


    function numberOfEpochs() external view returns (uint256);


    function vestingEpochs() external view returns (uint256);


    function stakeToken() external view returns (address);


    function yieldToken() external view returns (address);


    function pendleTokenAddress() external view returns (address);


    function totalStake() external view returns (uint256);


    function dueInterests(address) external view returns (uint256);


    function lastParamL(address) external view returns (uint256);


    function lastNYield() external view returns (uint256);


    function paramL() external view returns (uint256);

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

}// MIT
pragma solidity 0.7.6;

interface IPendleWhitelist {

    event AddedToWhiteList(address);
    event RemovedFromWhiteList(address);

    function whitelisted(address) external view returns (bool);


    function addToWhitelist(address[] calldata _addresses) external;


    function removeFromWhitelist(address[] calldata _addresses) external;


    function getWhitelist() external view returns (address[] memory list);

}// GPL-2.0-or-later
pragma solidity ^0.7.0;


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
}// GPL-2.0-or-later
pragma solidity ^0.7.0;

library TokenUtils {

    function requireERC20(address tokenAddr) internal view {

        require(IERC20(tokenAddr).totalSupply() > 0, "INVALID_ERC20");
    }

    function requireERC20(IERC20 token) internal view {

        require(token.totalSupply() > 0, "INVALID_ERC20");
    }
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleLiquidityMiningBaseV2 is IPendleLiquidityMiningV2, WithdrawableV2, ReentrancyGuard {

    using Math for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct EpochData {
        uint256 totalStakeUnits;
        uint256 totalRewards;
        uint256 lastUpdated;
        mapping(address => uint256) stakeUnitsForUser;
        mapping(address => uint256) availableRewardsForUser;
    }

    IPendleWhitelist public immutable whitelist;
    IPendlePausingManager public immutable pausingManager;

    uint256 public override numberOfEpochs;
    uint256 public override totalStake;
    mapping(uint256 => EpochData) internal epochData;
    mapping(address => uint256) public override balances;
    mapping(address => uint256) public lastTimeUserStakeUpdated;
    mapping(address => uint256) public lastEpochClaimed;

    address public immutable override pendleTokenAddress;
    address public immutable override stakeToken;
    address public immutable override yieldToken;
    uint256 public immutable override startTime;
    uint256 public immutable override epochDuration;
    uint256 public immutable override vestingEpochs;
    uint256 public constant MULTIPLIER = 10**20;

    mapping(address => uint256) public override dueInterests;
    mapping(address => uint256) public override lastParamL;
    uint256 public override lastNYield;
    uint256 public override paramL;

    modifier hasStarted() {

        require(_getCurrentEpochId() > 0, "NOT_STARTED");
        _;
    }

    modifier nonContractOrWhitelisted() {

        bool isEOA = !Address.isContract(msg.sender) && tx.origin == msg.sender;
        require(isEOA || whitelist.whitelisted(msg.sender), "CONTRACT_NOT_WHITELISTED");
        _;
    }

    modifier isUserAllowedToUse() {

        (bool paused, ) = pausingManager.checkLiqMiningStatus(address(this));
        require(!paused, "LIQ_MINING_PAUSED");
        require(numberOfEpochs > 0, "NOT_FUNDED");
        require(_getCurrentEpochId() > 0, "NOT_STARTED");
        _;
    }

    constructor(
        address _governanceManager,
        address _pausingManager,
        address _whitelist,
        address _pendleTokenAddress,
        address _stakeToken,
        address _yieldToken,
        uint256 _startTime,
        uint256 _epochDuration,
        uint256 _vestingEpochs
    ) PermissionsV2(_governanceManager) {
        require(_startTime > block.timestamp, "INVALID_START_TIME");
        TokenUtils.requireERC20(_pendleTokenAddress);
        TokenUtils.requireERC20(_stakeToken);
        require(_vestingEpochs > 0, "INVALID_VESTING_EPOCHS");
        pausingManager = IPendlePausingManager(_pausingManager);
        whitelist = IPendleWhitelist(_whitelist);
        pendleTokenAddress = _pendleTokenAddress;

        stakeToken = _stakeToken;
        yieldToken = _yieldToken;
        startTime = _startTime;
        epochDuration = _epochDuration;
        vestingEpochs = _vestingEpochs;
        paramL = 1;
    }

    function setUpEmergencyMode(address spender, bool) external virtual override {

        (, bool emergencyMode) = pausingManager.checkLiqMiningStatus(address(this));
        require(emergencyMode, "NOT_EMERGENCY");

        (address liqMiningEmergencyHandler, , ) = pausingManager.liqMiningEmergencyHandler();
        require(msg.sender == liqMiningEmergencyHandler, "NOT_EMERGENCY_HANDLER");

        IERC20(pendleTokenAddress).safeApprove(spender, type(uint256).max);
        IERC20(stakeToken).safeApprove(spender, type(uint256).max);
        if (yieldToken != address(0)) IERC20(yieldToken).safeApprove(spender, type(uint256).max);
    }

    function fund(uint256[] calldata rewards) external virtual override onlyGovernance {

        require(_getCurrentEpochId() <= numberOfEpochs, "LAST_EPOCH_OVER");

        uint256 nNewEpochs = rewards.length;
        uint256 totalFunded;
        for (uint256 i = 0; i < nNewEpochs; i++) {
            totalFunded = totalFunded.add(rewards[i]);
            epochData[numberOfEpochs + i + 1].totalRewards = rewards[i];
        }

        numberOfEpochs = numberOfEpochs.add(nNewEpochs);
        IERC20(pendleTokenAddress).safeTransferFrom(msg.sender, address(this), totalFunded);
        emit Funded(rewards, numberOfEpochs);
    }

    function topUpRewards(uint256[] calldata epochIds, uint256[] calldata rewards)
        external
        virtual
        override
        onlyGovernance
    {

        require(epochIds.length == rewards.length, "INVALID_ARRAYS");

        uint256 curEpoch = _getCurrentEpochId();
        uint256 endEpoch = numberOfEpochs;
        uint256 totalTopUp;

        for (uint256 i = 0; i < epochIds.length; i++) {
            require(curEpoch < epochIds[i] && epochIds[i] <= endEpoch, "INVALID_EPOCH_ID");
            totalTopUp = totalTopUp.add(rewards[i]);
            epochData[epochIds[i]].totalRewards = epochData[epochIds[i]].totalRewards.add(
                rewards[i]
            );
        }

        IERC20(pendleTokenAddress).safeTransferFrom(msg.sender, address(this), totalTopUp);
        emit RewardsToppedUp(epochIds, rewards);
    }

    function stake(address forAddr, uint256 amount)
        external
        virtual
        override
        nonReentrant
        nonContractOrWhitelisted
        isUserAllowedToUse
    {

        require(forAddr != address(0), "ZERO_ADDRESS");
        require(amount != 0, "ZERO_AMOUNT");
        require(_getCurrentEpochId() <= numberOfEpochs, "INCENTIVES_PERIOD_OVER");

        _settleStake(forAddr, msg.sender, amount);
        emit Staked(forAddr, amount);
    }

    function withdraw(address toAddr, uint256 amount)
        external
        virtual
        override
        nonReentrant
        isUserAllowedToUse
    {

        require(amount != 0, "ZERO_AMOUNT");
        require(toAddr != address(0), "ZERO_ADDRESS");

        _settleWithdraw(msg.sender, toAddr, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function redeemRewards(address user)
        external
        virtual
        override
        nonReentrant
        isUserAllowedToUse
        returns (uint256 rewards)
    {

        require(user != address(0), "ZERO_ADDRESS");

        rewards = _beforeTransferPendingRewards(user);
        if (rewards != 0) IERC20(pendleTokenAddress).safeTransfer(user, rewards);
    }

    function redeemDueInterests(address user)
        external
        virtual
        override
        nonReentrant
        isUserAllowedToUse
        returns (uint256 amountOut)
    {

        if (yieldToken == address(0)) return 0;
        require(user != address(0), "ZERO_ADDRESS");

        amountOut = _beforeTransferDueInterests(user);
        amountOut = _pushYieldToken(user, amountOut);
    }

    function updateAndReadEpochData(uint256 epochId, address user)
        external
        override
        nonReentrant
        isUserAllowedToUse
        returns (
            uint256 totalStakeUnits,
            uint256 totalRewards,
            uint256 lastUpdated,
            uint256 stakeUnitsForUser,
            uint256 availableRewardsForUser
        )
    {

        _updatePendingRewards(user);
        return readEpochData(epochId, user);
    }

    function readEpochData(uint256 epochId, address user)
        public
        view
        override
        returns (
            uint256 totalStakeUnits,
            uint256 totalRewards,
            uint256 lastUpdated,
            uint256 stakeUnitsForUser,
            uint256 availableRewardsForUser
        )
    {

        totalStakeUnits = epochData[epochId].totalStakeUnits;
        totalRewards = epochData[epochId].totalRewards;
        lastUpdated = epochData[epochId].lastUpdated;
        stakeUnitsForUser = epochData[epochId].stakeUnitsForUser[user];
        availableRewardsForUser = epochData[epochId].availableRewardsForUser[user];
    }

    function _updatePendingRewards(address user) internal virtual {

        _updateStakeData();

        if (lastTimeUserStakeUpdated[user] == 0) {
            lastTimeUserStakeUpdated[user] = block.timestamp;
            return;
        }

        uint256 _curEpoch = _getCurrentEpochId();
        uint256 _endEpoch = Math.min(numberOfEpochs, _curEpoch);

        bool _isEndEpochOver = (_curEpoch > numberOfEpochs);

        uint256 _balance = balances[user];
        uint256 _lastTimeUserStakeUpdated = lastTimeUserStakeUpdated[user];
        uint256 _totalStake = totalStake;
        uint256 _startEpoch = _epochOfTimestamp(_lastTimeUserStakeUpdated);

        for (uint256 epochId = _startEpoch; epochId <= _endEpoch; epochId++) {
            if (epochData[epochId].totalStakeUnits == 0) {
                if (_totalStake == 0) break;
                continue;
            }
            epochData[epochId].stakeUnitsForUser[user] = epochData[epochId]
            .stakeUnitsForUser[user]
            .add(_calcUnitsStakeInEpoch(_balance, _lastTimeUserStakeUpdated, epochId));

            if (epochId == _endEpoch && !_isEndEpochOver) {
                break;
            }

            uint256 rewardsPerVestingEpoch = _calcAmountRewardsForUserInEpoch(user, epochId);

            for (uint256 i = epochId + 1; i <= epochId + vestingEpochs; i++) {
                epochData[i].availableRewardsForUser[user] = epochData[i]
                .availableRewardsForUser[user]
                .add(rewardsPerVestingEpoch);
            }
        }

        lastTimeUserStakeUpdated[user] = block.timestamp;
    }

    function _updateStakeData() internal virtual {

        uint256 _curEpoch = _getCurrentEpochId();

        for (uint256 i = Math.min(_curEpoch, numberOfEpochs); i > 0; i--) {
            uint256 epochEndTime = _endTimeOfEpoch(i);
            uint256 lastUpdatedForEpoch = epochData[i].lastUpdated;

            if (lastUpdatedForEpoch == epochEndTime) {
                break; // its already updated until this epoch, our job here is done
            }

            epochData[i].totalStakeUnits = epochData[i].totalStakeUnits.add(
                _calcUnitsStakeInEpoch(totalStake, lastUpdatedForEpoch, i)
            );
            epochData[i].lastUpdated = Math.min(block.timestamp, epochEndTime);
        }
    }

    function _updateDueInterests(address user) internal virtual {

        if (yieldToken == address(0)) return;

        _updateParamL();

        if (lastParamL[user] == 0) {
            lastParamL[user] = paramL;
            return;
        }

        uint256 principal = balances[user];
        uint256 interestValuePerStakeToken = paramL.sub(lastParamL[user]);

        uint256 interestFromStakeToken = principal.mul(interestValuePerStakeToken).div(MULTIPLIER);

        dueInterests[user] = dueInterests[user].add(interestFromStakeToken);
        lastParamL[user] = paramL;
    }

    function _updateParamL() internal virtual {

        if (yieldToken == address(0) || !_checkNeedUpdateParamL()) return;

        _redeemExternalInterests();

        uint256 currentNYield = IERC20(yieldToken).balanceOf(address(this));
        (uint256 firstTerm, uint256 paramR) = _getFirstTermAndParamR(currentNYield);

        uint256 secondTerm;

        if (totalStake != 0) secondTerm = paramR.mul(MULTIPLIER).div(totalStake);

        paramL = firstTerm.add(secondTerm);
        lastNYield = currentNYield;
    }

    function _getFirstTermAndParamR(uint256 currentNYield)
        internal
        virtual
        returns (uint256 firstTerm, uint256 paramR)
    {

        firstTerm = paramL;
        paramR = currentNYield.sub(lastNYield);
    }

    function _checkNeedUpdateParamL() internal virtual returns (bool) {}


    function _redeemExternalInterests() internal virtual {}


    function _beforeTransferPendingRewards(address user)
        internal
        virtual
        returns (uint256 amountOut)
    {

        _updatePendingRewards(user);

        uint256 _lastEpoch = Math.min(_getCurrentEpochId(), numberOfEpochs + vestingEpochs);
        for (uint256 i = lastEpochClaimed[user]; i <= _lastEpoch; i++) {
            if (epochData[i].availableRewardsForUser[user] > 0) {
                amountOut = amountOut.add(epochData[i].availableRewardsForUser[user]);
                epochData[i].availableRewardsForUser[user] = 0;
            }
        }

        lastEpochClaimed[user] = _lastEpoch;
        emit PendleRewardsSettled(user, amountOut);
    }

    function _beforeTransferDueInterests(address user)
        internal
        virtual
        returns (uint256 amountOut)
    {

        if (yieldToken == address(0)) return 0;

        _updateDueInterests(user);
        amountOut = Math.min(dueInterests[user], lastNYield);
        dueInterests[user] = 0;
        lastNYield = lastNYield.sub(amountOut);
    }

    function _settleStake(
        address user,
        address payer,
        uint256 amount
    ) internal virtual {

        _updatePendingRewards(user);
        _updateDueInterests(user);

        balances[user] = balances[user].add(amount);
        totalStake = totalStake.add(amount);

        _pullStakeToken(payer, amount);
    }

    function _settleWithdraw(
        address user,
        address receiver,
        uint256 amount
    ) internal virtual {

        _updatePendingRewards(user);
        _updateDueInterests(user);

        balances[user] = balances[user].sub(amount);
        totalStake = totalStake.sub(amount);

        _pushStakeToken(receiver, amount);
    }

    function _pullStakeToken(address from, uint256 amount) internal virtual {

        IERC20(stakeToken).safeTransferFrom(from, address(this), amount);
    }

    function _pushStakeToken(address to, uint256 amount) internal virtual {

        if (amount != 0) IERC20(stakeToken).safeTransfer(to, amount);
    }

    function _pushYieldToken(address to, uint256 amount)
        internal
        virtual
        returns (uint256 outAmount)
    {

        outAmount = Math.min(amount, IERC20(yieldToken).balanceOf(address(this)));
        if (outAmount != 0) IERC20(yieldToken).safeTransfer(to, outAmount);
    }

    function _calcUnitsStakeInEpoch(
        uint256 _tokenAmount,
        uint256 _startTime,
        uint256 _epochId
    ) internal view returns (uint256 stakeUnitsForUser) {

        uint256 _endTime = block.timestamp;

        uint256 _l = Math.max(_startTime, _startTimeOfEpoch(_epochId));
        uint256 _r = Math.min(_endTime, _endTimeOfEpoch(_epochId));
        uint256 durationStakeThisEpoch = _r.subMax0(_l);

        return _tokenAmount.mul(durationStakeThisEpoch);
    }

    function _calcAmountRewardsForUserInEpoch(address user, uint256 epochId)
        internal
        view
        returns (uint256 rewardsPerVestingEpoch)
    {

        rewardsPerVestingEpoch = epochData[epochId]
        .totalRewards
        .mul(epochData[epochId].stakeUnitsForUser[user])
        .div(epochData[epochId].totalStakeUnits)
        .div(vestingEpochs);
    }

    function _startTimeOfEpoch(uint256 t) internal view returns (uint256) {

        return startTime.add((t.sub(1)).mul(epochDuration));
    }

    function _getCurrentEpochId() internal view returns (uint256) {

        return _epochOfTimestamp(block.timestamp);
    }

    function _epochOfTimestamp(uint256 t) internal view returns (uint256) {

        if (t < startTime) return 0;
        return (t.sub(startTime)).div(epochDuration).add(1);
    }

    function _endTimeOfEpoch(uint256 t) internal view returns (uint256) {

        return startTime.add(t.mul(epochDuration));
    }

    function _allowedToWithdraw(address _token) internal view override returns (bool allowed) {

        allowed = _token != pendleTokenAddress && _token != stakeToken && _token != yieldToken;
    }
}// MIT
pragma solidity 0.7.6;

interface IMasterChef {

    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accSushiPerShare;
    }

    function userInfo(uint256 pid, address user) external view returns (UserInfo calldata);


    function poolInfo(uint256 pid) external view returns (PoolInfo calldata);


    function deposit(uint256 pid, uint256 amount) external;


    function withdraw(uint256 pid, uint256 amount) external;


    function emergencyWithdraw(uint256 pid) external;

}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleSLPLiquidityMining is PendleLiquidityMiningBaseV2 {

    using SafeERC20 for IERC20;
    IMasterChef public immutable masterChef;
    uint256 public immutable pid;

    constructor(
        address _governanceManager,
        address _pausingManager,
        address _whitelist,
        address _pendleTokenAddress,
        address _stakeToken,
        address _yieldToken,
        uint256 _startTime,
        uint256 _epochDuration,
        uint256 _vestingEpochs,
        address _masterChef,
        uint256 _pid
    )
        PendleLiquidityMiningBaseV2(
            _governanceManager,
            _pausingManager,
            _whitelist,
            _pendleTokenAddress,
            _stakeToken,
            _yieldToken,
            _startTime,
            _epochDuration,
            _vestingEpochs
        )
    {
        require(_masterChef != address(0), "ZERO_ADDRESS");
        TokenUtils.requireERC20(_yieldToken);
        require(
            address(IMasterChef(_masterChef).poolInfo(_pid).lpToken) == _stakeToken,
            "INVALID_TOKEN_INFO"
        );

        masterChef = IMasterChef(_masterChef);
        pid = _pid;
        IERC20(_stakeToken).safeApprove(address(_masterChef), type(uint256).max);
    }

    function setUpEmergencyMode(address spender, bool useEmergencyWithdraw)
        external
        virtual
        override
    {

        (, bool emergencyMode) = pausingManager.checkLiqMiningStatus(address(this));
        require(emergencyMode, "NOT_EMERGENCY");

        (address liqMiningEmergencyHandler, , ) = pausingManager.liqMiningEmergencyHandler();
        require(msg.sender == liqMiningEmergencyHandler, "NOT_EMERGENCY_HANDLER");

        if (useEmergencyWithdraw) {
            masterChef.emergencyWithdraw(pid);
        } else {
            masterChef.withdraw(pid, masterChef.userInfo(pid, address(this)).amount);
        }

        IERC20(pendleTokenAddress).safeApprove(spender, type(uint256).max);
        IERC20(stakeToken).safeApprove(spender, type(uint256).max);
        IERC20(yieldToken).safeApprove(spender, type(uint256).max);
    }

    function _checkNeedUpdateParamL() internal virtual override returns (bool) {

        return true;
    }

    function _redeemExternalInterests() internal virtual override {

        masterChef.withdraw(pid, 0);
    }

    function _pullStakeToken(address from, uint256 amount) internal virtual override {

        IERC20(stakeToken).safeTransferFrom(from, address(this), amount);
        masterChef.deposit(pid, amount);
    }

    function _pushStakeToken(address to, uint256 amount) internal virtual override {

        masterChef.withdraw(pid, amount);
        IERC20(stakeToken).safeTransfer(to, amount);
    }
}