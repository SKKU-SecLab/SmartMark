
pragma solidity 0.8.11;

interface IVaultRestricted {

    
    function reallocate(
        address[] calldata vaultStrategies,
        uint256 newVaultProportions,
        uint256 finishedIndex,
        uint24 activeIndex
    ) external returns (uint256[] memory, uint256);


    function payFees(uint256 profit) external returns (uint256 feesPaid);



    event Reallocate(uint24 indexed index, uint256 newProportions);
}// BUSL-1.1

pragma solidity 0.8.11;

interface IVaultIndexActions {



    struct IndexAction {
        uint128 depositAmount;
        uint128 withdrawShares;
    }

    struct LastIndexInteracted {
        uint128 index1;
        uint128 index2;
    }

    struct Redeem {
        uint128 depositShares;
        uint128 withdrawnAmount;
    }


    event VaultRedeem(uint indexed globalIndex);
    event UserRedeem(address indexed member, uint indexed globalIndex);
}// MIT

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

pragma solidity 0.8.11;


interface IRewardDrip {


    struct RewardConfiguration {
        uint32 rewardsDuration;
        uint32 periodFinish;
        uint192 rewardRate; // rewards per second multiplied by accuracy
        uint32 lastUpdateTime;
        uint224 rewardPerTokenStored;
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
    }


    function getActiveRewards(address account) external;

    function tokenBlacklist(IERC20 token) view external returns(bool);


    
    event RewardPaid(IERC20 token, address indexed user, uint256 reward);
    event RewardAdded(IERC20 indexed token, uint256 amount, uint256 duration);
    event RewardExtended(IERC20 indexed token, uint256 amount, uint256 leftover, uint256 duration, uint32 periodFinish);
    event RewardRemoved(IERC20 indexed token);
    event PeriodFinishUpdated(IERC20 indexed token, uint32 periodFinish);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint192(uint256 value) internal pure returns (uint192) {

        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 128 bits");
        return uint192(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }
}// MIT

pragma solidity 0.8.11;

library Bitwise {

    function get8BitUintByIndex(uint256 bitwiseData, uint256 i) internal pure returns(uint256) {

        return (bitwiseData >> (8 * i)) & type(uint8).max;
    }

    function get14BitUintByIndex(uint256 bitwiseData, uint256 i) internal pure returns(uint256) {

        return (bitwiseData >> (14 * i)) & (16_383); // 16.383 is 2^14 - 1
    }

    function set14BitUintByIndex(uint256 bitwiseData, uint256 i, uint256 num14bit) internal pure returns(uint256) {

        return bitwiseData + (num14bit << (14 * i));
    }

    function reset14BitUintByIndex(uint256 bitwiseData, uint256 i) internal pure returns(uint256) {

        return bitwiseData & (~(16_383 << (14 * i)));
    }
}// MIT

pragma solidity 0.8.11;

library Hash {

    function hashReallocationTable(uint256[][] memory reallocationTable) internal pure returns(bytes32) {

        return keccak256(abi.encode(reallocationTable));
    }

    function hashStrategies(address[] memory strategies) internal pure returns(bytes32) {

        return keccak256(abi.encodePacked(strategies));
    }

    function sameStrategies(address[] memory strategies1, address[] memory strategies2) internal pure returns(bool) {

        return hashStrategies(strategies1) == hashStrategies(strategies2);
    }

    function sameStrategies(address[] memory strategies, bytes32 strategiesHash) internal pure returns(bool) {

        return hashStrategies(strategies) == strategiesHash;
    }
}// BUSL-1.1

pragma solidity 0.8.11;

struct VaultDetails {
    address underlying;
    address[] strategies;
    uint256[] proportions;
    address creator;
    uint16 vaultFee;
    address riskProvider;
    int8 riskTolerance;
    string name;
}

struct VaultInitializable {
    string name;
    address owner;
    uint16 fee;
    address[] strategies;
    uint256[] proportions;
}// BUSL-1.1

pragma solidity 0.8.11;


interface IVaultBase {


    function initialize(VaultInitializable calldata vaultInitializable) external;



    struct User {
        uint128 instantDeposit; // used for calculating rewards
        uint128 activeDeposit; // users deposit after deposit process and claim
        uint128 owed; // users owed underlying amount after withdraw has been processed and claimed
        uint128 withdrawnDeposits; // users withdrawn deposit, used to calculate performance fees
        uint128 shares; // users shares after deposit process and claim
    }


    event Claimed(address indexed member, uint256 claimAmount);
    event Deposit(address indexed member, uint256 indexed index, uint256 amount);
    event Withdraw(address indexed member, uint256 indexed index, uint256 shares);
    event WithdrawFast(address indexed member, uint256 shares);
    event StrategyRemoved(uint256 i, address strategy);
    event TransferVaultOwner(address owner);
    event LowerVaultFee(uint16 fee);
    event UpdateName(string name);
}// BUSL-1.1

pragma solidity 0.8.11;


struct VaultImmutables {
    IERC20 underlying;
    address riskProvider;
    int8 riskTolerance;
}

interface IVaultImmutable {


    function underlying() external view returns (IERC20);


    function riskProvider() external view returns (address);


    function riskTolerance() external view returns (int8);

}// BUSL-1.1

pragma solidity 0.8.11;


abstract contract VaultImmutable {

    function _underlying() internal view returns (IERC20) {
        return IVaultImmutable(address(this)).underlying();
    }

    function _riskProvider() internal view returns (address) {
        return IVaultImmutable(address(this)).riskProvider();
    }
}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolOwner {

    function isSpoolOwner(address user) external view returns(bool);

}// BUSL-1.1

pragma solidity 0.8.11;


abstract contract SpoolOwnable {
    ISpoolOwner internal immutable spoolOwner;

    constructor(ISpoolOwner _spoolOwner) {
        require(
            address(_spoolOwner) != address(0),
            "SpoolOwnable::constructor: Spool owner contract address cannot be 0"
        );

        spoolOwner = _spoolOwner;
    }

    function isSpoolOwner() internal view returns(bool) {
        return spoolOwner.isSpoolOwner(msg.sender);
    }


    function _onlyOwner() private view {
        require(isSpoolOwner(), "SpoolOwnable::onlyOwner: Caller is not the Spool owner");
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }
}// BUSL-1.1

pragma solidity 0.8.11;


abstract contract BaseConstants {
    uint256 internal constant FULL_PERCENT = 100_00;

    uint256 internal constant ACCURACY = 10**30;
}

abstract contract USDC {
    IERC20 internal constant USDC_ADDRESS = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
}// BUSL-1.1

pragma solidity 0.8.11;

struct SwapData {
    uint256 slippage; // min amount out
    bytes path; // 1st byte is action, then path 
}// BUSL-1.1

pragma solidity 0.8.11;


interface ISpoolExternal {


    function deposit(address strategy, uint128 amount, uint256 index) external;


    function withdraw(address strategy, uint256 vaultProportion, uint256 index) external;


    function fastWithdrawStrat(address strat, address underlying, uint256 shares, uint256[] calldata slippages, SwapData[] calldata swapData) external returns(uint128);


    function redeem(address strat, uint256 index) external returns (uint128, uint128);


    function redeemUnderlying(uint128 amount) external;


    function redeemReallocation(address[] calldata vaultStrategies, uint256 depositProportions, uint256 index) external;


    function removeShares(address[] calldata vaultStrategies, uint256 vaultProportion) external returns(uint128[] memory);

}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolReallocation {

    event StartReallocation(uint24 indexed index);
}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolDoHardWork {


    event DoHardWorkStrategyCompleted(address indexed strat, uint256 indexed index);
}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolStrategy {


    function getUnderlying(address strat) external returns (uint128);

    
    function getVaultTotalUnderlyingAtIndex(address strat, uint256 index) external view returns(uint128);


    function addStrategy(address strat) external;


    function disableStrategy(address strategy, bool skipDisable) external;


    function runDisableStrategy(address strategy) external;


    function emergencyWithdraw(
        address strat,
        address withdrawRecipient,
        uint256[] calldata data
    ) external;

}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolBase {


    function getCompletedGlobalIndex() external view returns(uint24);


    function getActiveGlobalIndex() external view returns(uint24);


    function isMidReallocation() external view returns (bool);



    event ReallocationTableUpdated(
        uint24 indexed index,
        bytes32 reallocationTableHash
    );

    event ReallocationTableUpdatedWithTable(
        uint24 indexed index,
        bytes32 reallocationTableHash,
        uint256[][] reallocationTable
    );
    
    event DoHardWorkCompleted(uint24 indexed index);

    event SetAllocationProvider(address actor, bool isAllocationProvider);
    event SetIsDoHardWorker(address actor, bool isDoHardWorker);
}// BUSL-1.1

pragma solidity 0.8.11;


interface ISpool is ISpoolExternal, ISpoolReallocation, ISpoolDoHardWork, ISpoolStrategy, ISpoolBase {}// BUSL-1.1


pragma solidity 0.8.11;


interface IController {


    function strategies(uint256 i) external view returns (address);


    function validStrategy(address strategy) external view returns (bool);


    function validVault(address vault) external view returns (bool);


    function getStrategiesCount() external view returns(uint8);


    function supportedUnderlying(IERC20 underlying)
        external
        view
        returns (bool);


    function getAllStrategies() external view returns (address[] memory);


    function verifyStrategies(address[] calldata _strategies) external view;


    function transferToSpool(
        address transferFrom,
        uint256 amount
    ) external;


    function checkPaused() external view;



    event EmergencyWithdrawStrategy(address indexed strategy);
    event EmergencyRecipientUpdated(address indexed recipient);
    event EmergencyWithdrawerUpdated(address indexed withdrawer, bool set);
    event PauserUpdated(address indexed user, bool set);
    event UnpauserUpdated(address indexed user, bool set);
    event VaultCreated(address indexed vault, address underlying, address[] strategies, uint256[] proportions,
        uint16 vaultFee, address riskProvider, int8 riskTolerance);
    event StrategyAdded(address strategy);
    event StrategyRemoved(address strategy);
    event VaultInvalid(address vault);
    event DisableStrategy(address strategy);
}// BUSL-1.1

pragma solidity 0.8.11;


struct FastWithdrawParams {
    bool doExecuteWithdraw;
    uint256[][] slippages;
    SwapData[][] swapData;
}

interface IFastWithdraw {

    function transferShares(
        address[] calldata vaultStrategies,
        uint128[] calldata sharesWithdrawn,
        uint256 proportionateDeposit,
        address user,
        FastWithdrawParams calldata fastWithdrawParams
    ) external;



    event StrategyWithdrawn(address indexed user, address indexed vault, address indexed strategy);
    event UserSharesSaved(address indexed user, address indexed vault);
    event FastWithdrawExecuted(address indexed user, address indexed vault, uint256 totalWithdrawn);
}// BUSL-1.1

pragma solidity 0.8.11;


interface IFeeHandler {

    function payFees(
        IERC20 underlying,
        uint256 profit,
        address riskProvider,
        address vaultOwner,
        uint16 vaultFee
    ) external returns (uint256 feesPaid);


    function setRiskProviderFee(address riskProvider, uint16 fee) external;



    event FeesPaid(address indexed vault, uint profit, uint ecosystemCollected, uint treasuryCollected, uint riskProviderColected, uint vaultFeeCollected);
    event RiskProviderFeeUpdated(address indexed riskProvider, uint indexed fee);
    event EcosystemFeeUpdated(uint indexed fee);
    event TreasuryFeeUpdated(uint indexed fee);
    event EcosystemCollectorUpdated(address indexed collector);
    event TreasuryCollectorUpdated(address indexed collector);
    event FeeCollected(address indexed collector, IERC20 indexed underlying, uint amount);
    event EcosystemFeeCollected(IERC20 indexed underlying, uint amount);
    event TreasuryFeeCollected(IERC20 indexed underlying, uint amount);
}// MIT

pragma solidity 0.8.11;


abstract contract SpoolPausable {

    IController public immutable controller;

    constructor(IController _controller) {
        require(
            address(_controller) != address(0),
            "SpoolPausable::constructor: Controller contract address cannot be 0"
        );

        controller = _controller;
    }


    modifier systemNotPaused() {
        controller.checkPaused();
        _;
    }
}// BUSL-1.1

pragma solidity 0.8.11;




abstract contract VaultBase is IVaultBase, VaultImmutable, SpoolOwnable, SpoolPausable, BaseConstants {
    using Bitwise for uint256;
    using SafeERC20 for IERC20;


    ISpool internal immutable spool;

    IFastWithdraw internal immutable fastWithdraw;

    IFeeHandler internal immutable feeHandler;

    bool private _initialized;

    address public vaultOwner;

    uint16 public vaultFee;

    string public name;

    uint128 public totalShares;

    uint128 public totalInstantDeposit;

    uint256 public proportions;

    uint256 internal depositProportions;
    
    bytes32 public strategiesHash;

    uint8 public rewardTokensCount;
    
    uint24 public reallocationIndex;

    mapping(address => User) public users;


    constructor(
        ISpool _spool,
        IController _controller,
        IFastWithdraw _fastWithdraw,
        IFeeHandler _feeHandler
    )
    SpoolPausable(_controller)
    {
        require(address(_spool) != address(0), "VaultBase::constructor: Spool address cannot be 0");
        require(address(_fastWithdraw) != address(0), "VaultBase::constructor: FastWithdraw address cannot be 0");
        require(address(_feeHandler) != address(0), "VaultBase::constructor: Fee Handler address cannot be 0");

        spool = _spool;
        fastWithdraw = _fastWithdraw;
        feeHandler = _feeHandler;
    }


    function initialize(
        VaultInitializable memory vaultInitializable
    ) external override initializer {
        vaultOwner = vaultInitializable.owner;
        vaultFee = vaultInitializable.fee;
        name = vaultInitializable.name;

        proportions = _mapProportionsArrayToBits(vaultInitializable.proportions);
        _updateStrategiesHash(vaultInitializable.strategies);
    }


    function _getProportion128(uint128 mul1, uint128 mul2, uint128 div) internal pure returns (uint128) {
        return SafeCast.toUint128((uint256(mul1) * mul2) / div);
    }


    function transferVaultOwner(address _vaultOwner) external onlyVaultOwnerOrSpoolOwner {
        vaultOwner = _vaultOwner;
        emit TransferVaultOwner(_vaultOwner);
    }

    function lowerVaultFee(uint16 _vaultFee) external {
        require(
            msg.sender == vaultOwner &&
            _vaultFee < vaultFee,
            "FEE"
        );

        vaultFee = _vaultFee;
        emit LowerVaultFee(_vaultFee);
    }

    function updateName(string memory _name) external onlyOwner {
        name = _name;
        emit UpdateName(_name);
    }


    function _addInstantDeposit(uint128 amount) internal {
        users[msg.sender].instantDeposit += amount;
        totalInstantDeposit += amount;
    }

    function _getStrategyDepositAmount(
        uint256 _proportions,
        uint256 i,
        uint256 amount
    ) internal pure returns (uint128) {
        return SafeCast.toUint128((_proportions.get14BitUintByIndex(i) * amount) / FULL_PERCENT);
    }

    function _transferDepositToSpool(uint128 amount, bool fromVault) internal {
        if (fromVault) {
            _underlying().safeTransferFrom(msg.sender, address(spool), amount);
        } else {
            controller.transferToSpool(msg.sender, amount);
        }
    }


    function _getVaultShareProportion(uint128 sharesToWithdraw) internal view returns(uint256) {
        return (ACCURACY * sharesToWithdraw) / totalShares;
    }


    function _payFeesAndTransfer(uint256 profit) internal returns (uint128 feeSize) {
        feeSize = SafeCast.toUint128(_payFees(profit));

        _underlying().safeTransfer(address(feeHandler), feeSize);
    }

    function _payFees(uint256 profit) internal returns (uint256) {
        return feeHandler.payFees(
            _underlying(),
            profit,
            _riskProvider(),
            vaultOwner,
            vaultFee
        );
    }


    function _mapProportionsArrayToBits(uint256[] memory _proportions) internal pure returns (uint256) {
        uint256 proportions14bit;
        for (uint256 i = 0; i < _proportions.length; i++) {
            proportions14bit = proportions14bit.set14BitUintByIndex(i, _proportions[i]);
        }

        return proportions14bit;
    }

    function _updateStrategiesHash(address[] memory vaultStrategies) internal {
        strategiesHash = Hash.hashStrategies(vaultStrategies);
    }

    function _verifyStrategies(address[] memory vaultStrategies) internal view {
        require(Hash.sameStrategies(vaultStrategies, strategiesHash), "VSH");
    }


    function _onlyVaultOwnerOrSpoolOwner() private view {
        require(
            msg.sender == vaultOwner || isSpoolOwner(),
            "OOD"
        );
    }

    function _onlySpool() private view {
        require(address(spool) == msg.sender, "OSP");
    }

    function _onlyFastWithdraw() private view {
        require(address(fastWithdraw) == msg.sender, "OFW");
    }

    function _noMidReallocation() private view {
        require(!spool.isMidReallocation(), "NMR");
    }


    modifier onlyVaultOwnerOrSpoolOwner() {
        _onlyVaultOwnerOrSpoolOwner();
        _;
    }

    modifier onlySpool() {
        _onlySpool();
        _;
    }

    modifier onlyFastWithdraw() {
        _onlyFastWithdraw();
        _;
    }

    modifier verifyStrategies(address[] memory vaultStrategies) {
        _verifyStrategies(vaultStrategies);
        _;
    }

    modifier noMidReallocation() {
        _noMidReallocation();
        _;
    }

    modifier initializer() {
        require(!_initialized, "AINT");
        _;
        _initialized = true;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

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
}// MIT

pragma solidity 0.8.11;



library Math {

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? b : a;
    }

    function getProportion128(uint256 mul1, uint256 mul2, uint256 div) internal pure returns (uint128) {

        return SafeCast.toUint128(((mul1 * mul2) / div));
    }

    function getProportion128Unchecked(uint256 mul1, uint256 mul2, uint256 div) internal pure returns (uint128) {

        unchecked {
            return uint128((mul1 * mul2) / div);
        }
    }
}// BUSL-1.1

pragma solidity 0.8.11;



abstract contract RewardDrip is IRewardDrip, ReentrancyGuard, VaultBase {
    using SafeERC20 for IERC20;


    uint256 constant private REWARD_ACCURACY = 1e18;


    mapping(uint256 => IERC20) public rewardTokens;

    mapping(IERC20 => RewardConfiguration) public rewardConfiguration;

    mapping(IERC20 => bool) public override tokenBlacklist;


    function lastTimeRewardApplicable(IERC20 token)
        public
        view
        returns (uint32)
    {
        return uint32(Math.min(block.timestamp, rewardConfiguration[token].periodFinish));
    }

    function rewardPerToken(IERC20 token) public view returns (uint224) {
        RewardConfiguration storage config = rewardConfiguration[token];

        if (totalInstantDeposit == 0)
            return config.rewardPerTokenStored;
            
        uint256 timeDelta = lastTimeRewardApplicable(token) - config.lastUpdateTime;

        if (timeDelta == 0)
            return config.rewardPerTokenStored;

        return
            SafeCast.toUint224(
                config.rewardPerTokenStored + 
                    ((timeDelta
                        * config.rewardRate)
                        / totalInstantDeposit)
            );
    }

    function earned(IERC20 token, address account)
        public
        view
        returns (uint256)
    {
        RewardConfiguration storage config = rewardConfiguration[token];

        uint256 userShares = users[account].instantDeposit;

        if (userShares == 0)
            return config.rewards[account];
        
        uint256 userRewardPerTokenPaid = config.userRewardPerTokenPaid[account];

        return
            ((userShares * 
                (rewardPerToken(token) - userRewardPerTokenPaid))
                / REWARD_ACCURACY)
                + config.rewards[account];
    }

    function getRewardForDuration(IERC20 token)
        external
        view
        returns (uint256)
    {
        RewardConfiguration storage config = rewardConfiguration[token];
        return uint256(config.rewardRate) * config.rewardsDuration;
    }


    function getRewards(IERC20[] memory tokens) external nonReentrant {
        for (uint256 i; i < tokens.length; i++) {
            _getReward(tokens[i], msg.sender);
        }
    }

    function getActiveRewards(address account) external override onlyController nonReentrant {
        uint256 _rewardTokensCount = rewardTokensCount;
        for (uint256 i; i < _rewardTokensCount; i++) {
            _getReward(rewardTokens[i], account);
        }
    }

    function _getReward(IERC20 token, address account)
        internal
        updateReward(token, account)
    {
        RewardConfiguration storage config = rewardConfiguration[token];

        require(
            config.rewardsDuration != 0,
            "BTK"
        );

        uint256 reward = config.rewards[account];
        if (reward > 0) {
            config.rewards[account] = 0;
            token.safeTransfer(account, reward);
            emit RewardPaid(token, account, reward);
        }
    }


    function addToken(
        IERC20 token,
        uint32 rewardsDuration,
        uint256 reward
    ) external onlyVaultOwnerOrSpoolOwner exceptUnderlying(token) {
        RewardConfiguration storage config = rewardConfiguration[token];

        require(!tokenBlacklist[token], "TOBL");
        require(
            rewardsDuration != 0 &&
            config.lastUpdateTime == 0,
            "BCFG"
        );
        require(
            rewardTokensCount <= 5,
            "TMAX"
        );

        rewardTokens[rewardTokensCount] = token;
        rewardTokensCount++;

        config.rewardsDuration = rewardsDuration;

        if (reward > 0) {
            _notifyRewardAmount(token, reward);
        }
    }

    function notifyRewardAmount(IERC20 token, uint256 reward, uint32 rewardsDuration)
    external
    onlyVaultOwnerOrSpoolOwner
    {
        rewardConfiguration[token].rewardsDuration = rewardsDuration;
        _notifyRewardAmount(token, reward);
    }

    function _notifyRewardAmount(IERC20 token, uint256 reward)
        private
        updateReward(token, address(0))
    {
        RewardConfiguration storage config = rewardConfiguration[token];

        require(
            config.rewardPerTokenStored + (reward * REWARD_ACCURACY) <= type(uint192).max,
            "RTB"
        );

        token.safeTransferFrom(msg.sender, address(this), reward);
        uint32 newPeriodFinish = uint32(block.timestamp) + config.rewardsDuration;

        if (block.timestamp >= config.periodFinish) {
            config.rewardRate = SafeCast.toUint192((reward * REWARD_ACCURACY) / config.rewardsDuration);
            emit RewardAdded(token, reward, config.rewardsDuration);
        } else {
            require(config.periodFinish <= newPeriodFinish, "PFS");
            uint256 remaining = config.periodFinish - block.timestamp;
            uint256 leftover = remaining * config.rewardRate;
            uint192 newRewardRate = SafeCast.toUint192((reward * REWARD_ACCURACY + leftover) / config.rewardsDuration);
        
            require(
                newRewardRate >= config.rewardRate,
                "LRR"
            );

            config.rewardRate = newRewardRate;
            emit RewardExtended(token, reward, leftover, config.rewardsDuration, newPeriodFinish);
        }

        config.lastUpdateTime = uint32(block.timestamp);
        config.periodFinish = newPeriodFinish;
    }

    function updatePeriodFinish(IERC20 token, uint32 timestamp)
        external
        onlyOwner
        updateReward(token, address(0))
    {
        if (rewardConfiguration[token].lastUpdateTime > timestamp) {
            rewardConfiguration[token].periodFinish = rewardConfiguration[token].lastUpdateTime;
        } else {
            rewardConfiguration[token].periodFinish = timestamp;
        }

        emit PeriodFinishUpdated(token, rewardConfiguration[token].periodFinish);
    }

    function claimFinishedRewards(IERC20 token, uint256 amount) external onlyOwner exceptUnderlying(token) onlyFinished(token) {
        token.safeTransfer(msg.sender, amount);
    }

    function forceRemoveReward(IERC20 token) external onlyOwner {
        tokenBlacklist[token] = true;
        _removeReward(token);

        delete rewardConfiguration[token];
    }

    function removeReward(IERC20 token) 
        external
        onlyVaultOwnerOrSpoolOwner
        onlyFinished(token)
        updateReward(token, address(0))
    {
        _removeReward(token);
    }


    function _updateRewards(address account) private {
        uint256 _rewardTokensCount = rewardTokensCount;
        
        for (uint256 i; i < _rewardTokensCount; i++)
            _updateReward(rewardTokens[i], account);
    }

    function _updateReward(IERC20 token, address account) private {
        RewardConfiguration storage config = rewardConfiguration[token];
        config.rewardPerTokenStored = rewardPerToken(token);
        config.lastUpdateTime = lastTimeRewardApplicable(token);
        if (account != address(0)) {
            config.rewards[account] = earned(token, account);
            config.userRewardPerTokenPaid[account] = config
                .rewardPerTokenStored;
        }
    }

    function _removeReward(IERC20 token) private {
        uint256 _rewardTokensCount = rewardTokensCount;
        for (uint256 i; i < _rewardTokensCount; i++) {
            if (rewardTokens[i] == token) {
                rewardTokens[i] = rewardTokens[_rewardTokensCount - 1];

                delete rewardTokens[_rewardTokensCount - 1];
                rewardTokensCount--;
                emit RewardRemoved(token);

                break;
            }
        }
    }

    function _exceptUnderlying(IERC20 token) private view {
        require(
            token != _underlying(),
            "NUT"
        );
    }

    function _onlyFinished(IERC20 token) private view {
        require(
            block.timestamp > rewardConfiguration[token].periodFinish,
            "RNF"
        );
    }

    function _onlyController() private view {
        require(
            msg.sender == address(controller),
            "OCTRL"
        );
    }


    modifier updateReward(IERC20 token, address account) {
        _updateReward(token, account);
        _;
    }

    modifier updateRewards() {
        _updateRewards(msg.sender);
        _;
    }

    modifier exceptUnderlying(IERC20 token) {
        _exceptUnderlying(token);
        _;
    }

    modifier onlyFinished(IERC20 token) {
        _onlyFinished(token);
        _;
    }

    modifier onlyController() {
        _onlyController();
        _;
    }
}// BUSL-1.1

pragma solidity 0.8.11;


abstract contract VaultIndexActions is IVaultIndexActions, RewardDrip {
    using SafeERC20 for IERC20;
    using Bitwise for uint256;


    uint128 private constant SHARES_MULTIPLIER = 10**6;
    
    uint128 private constant INITIAL_SHARES_LOCKED = 10**11;

    uint256 private constant MIN_SHARES_FOR_ACCURACY = INITIAL_SHARES_LOCKED * 10;


    LastIndexInteracted public lastIndexInteracted;

    mapping(uint256 => IndexAction) public vaultIndexAction;
    
    mapping(address => mapping(uint256 => IndexAction)) public userIndexAction;

    mapping(address => LastIndexInteracted) public userLastInteractions;

    mapping(uint256 => Redeem) public redeems;


    function _isVaultReallocatingAtIndex(uint256 index) internal view returns (bool isReallocating) {
        if (index == reallocationIndex) {
            isReallocating = true;
        }
    }

    function _isVaultReallocating() internal view returns (bool isReallocating) {
        if (reallocationIndex > 0) {
            isReallocating = true;
        }
    }


    function _redeemVaultStrategies(address[] memory vaultStrategies) internal systemNotPaused {
        LastIndexInteracted memory _lastIndexInteracted = lastIndexInteracted;
        if (_lastIndexInteracted.index1 > 0) {
            uint256 globalIndex1 = _lastIndexInteracted.index1;
            uint256 completedGlobalIndex = spool.getCompletedGlobalIndex();
            if (globalIndex1 <= completedGlobalIndex) {
                _redeemStrategiesIndex(globalIndex1, vaultStrategies);
                _lastIndexInteracted.index1 = 0;

                if (_lastIndexInteracted.index2 > 0) {
                    uint256 globalIndex2 = _lastIndexInteracted.index2;
                    if (globalIndex2 <= completedGlobalIndex) {
                        _redeemStrategiesIndex(globalIndex2, vaultStrategies);
                    } else {
                        _lastIndexInteracted.index1 = _lastIndexInteracted.index2;
                    }
                    
                    _lastIndexInteracted.index2 = 0;
                }

                lastIndexInteracted = _lastIndexInteracted;
            }
        }
    }

    function _redeemStrategiesIndex(uint256 globalIndex, address[] memory vaultStrategies) private {
        uint128 _totalShares = totalShares;
        uint128 totalReceived = 0;
        uint128 totalWithdrawn = 0;
        uint128 totalUnderlyingAtIndex = 0;
        
        bool isReallocating = _isVaultReallocatingAtIndex(globalIndex);
        if (isReallocating) {
            spool.redeemReallocation(vaultStrategies, depositProportions, globalIndex);
            reallocationIndex = 0;
        }

        for (uint256 i = 0; i < vaultStrategies.length; i++) {
            address strat = vaultStrategies[i];
            (uint128 receivedTokens, uint128 withdrawnTokens) = spool.redeem(strat, globalIndex);
            totalReceived += receivedTokens;
            totalWithdrawn += withdrawnTokens;
            
            totalUnderlyingAtIndex += spool.getVaultTotalUnderlyingAtIndex(strat, globalIndex);
        }

        if (totalWithdrawn > 0) {
            spool.redeemUnderlying(totalWithdrawn);
        }

        _totalShares -= vaultIndexAction[globalIndex].withdrawShares;

        uint128 newShares = 0;
        if (_totalShares <= MIN_SHARES_FOR_ACCURACY || totalUnderlyingAtIndex == 0) {
            newShares = totalReceived * SHARES_MULTIPLIER;

            if (_totalShares < INITIAL_SHARES_LOCKED) {
                if (newShares + _totalShares >= INITIAL_SHARES_LOCKED) {
                    unchecked {
                        uint128 newLockedShares = INITIAL_SHARES_LOCKED - _totalShares;
                        _totalShares += newLockedShares;
                        newShares -= newLockedShares;
                    }
                } else {
                    unchecked {
                        _totalShares += newShares;
                    }
                    newShares = 0;
                }
            }
        } else {
            if (totalReceived < totalUnderlyingAtIndex) {
                unchecked {
                    newShares = _getProportion128(totalReceived, _totalShares, totalUnderlyingAtIndex - totalReceived);
                }
            } else {
                newShares = _totalShares;
            }
        }

        totalShares = _totalShares + newShares;

        redeems[globalIndex] = Redeem(newShares, totalWithdrawn);

        emit VaultRedeem(globalIndex);
    }


    function _redeemUser() internal {
        LastIndexInteracted memory _lastIndexInteracted = lastIndexInteracted;
        LastIndexInteracted memory userIndexInteracted = userLastInteractions[msg.sender];

        if (userIndexInteracted.index1 > 0 && 
            (_lastIndexInteracted.index1 == 0 || userIndexInteracted.index1 < _lastIndexInteracted.index1)) {
            _redeemUserAction(userIndexInteracted.index1, true);
            userIndexInteracted.index1 = 0;

            if (userIndexInteracted.index2 > 0) {
                if (_lastIndexInteracted.index2 == 0 || userIndexInteracted.index2 < _lastIndexInteracted.index1) {
                    _redeemUserAction(userIndexInteracted.index2, false);
                } else {
                    userIndexInteracted.index1 = userIndexInteracted.index2;
                }
                
                userIndexInteracted.index2 = 0;
            }

            userLastInteractions[msg.sender] = userIndexInteracted;
        }
    }

    function _redeemUserAction(uint256 index, bool isFirstIndex) private {
        User storage user = users[msg.sender];
        IndexAction storage userIndex = userIndexAction[msg.sender][index];

        uint128 userWithdrawalShares = userIndex.withdrawShares;
        if (userWithdrawalShares > 0) {

            uint128 userWithdrawnAmount = _getProportion128(redeems[index].withdrawnAmount, userWithdrawalShares, vaultIndexAction[index].withdrawShares);

            user.owed += userWithdrawnAmount;

            uint128 proportionateDeposit;
            uint128 sharesAtWithdrawal = user.shares + userWithdrawalShares;
            if (isFirstIndex) {
                sharesAtWithdrawal += userIndexAction[msg.sender][index + 1].withdrawShares;
            }

            if (sharesAtWithdrawal > userWithdrawalShares) {
                uint128 userTotalDeposit = user.activeDeposit;
                
                proportionateDeposit = _getProportion128(userTotalDeposit, userWithdrawalShares, sharesAtWithdrawal);
                user.activeDeposit = userTotalDeposit - proportionateDeposit;
            } else {
                proportionateDeposit = user.activeDeposit;
                user.activeDeposit = 0;
            }

            user.withdrawnDeposits += proportionateDeposit;

            userIndex.withdrawShares = 0;
        }

        uint128 userDepositAmount = userIndex.depositAmount;
        if (userDepositAmount > 0) {
            uint128 newUserShares = _getProportion128(userDepositAmount, redeems[index].depositShares, vaultIndexAction[index].depositAmount);

            user.shares += newUserShares;
            user.activeDeposit += userDepositAmount;

            userIndex.depositAmount = 0;
        }
        
        emit UserRedeem(msg.sender, index);
    }


    function _updateInteractedIndex(uint24 globalIndex) internal {
        _updateLastIndexInteracted(lastIndexInteracted, globalIndex);
    }

    function _updateUserInteractedIndex(uint24 globalIndex) internal {
        _updateLastIndexInteracted(userLastInteractions[msg.sender], globalIndex);
    }

    function _updateLastIndexInteracted(LastIndexInteracted storage lit, uint24 globalIndex) private {
        if (lit.index1 > 0) {
            if (lit.index1 < globalIndex) {
                lit.index2 = globalIndex;
            }
        } else {
            lit.index1 = globalIndex;
        }

    }

    function _getActiveGlobalIndex() internal view returns(uint24) {
        return spool.getActiveGlobalIndex();
    }


    function _noReallocation() private view {
        require(!_isVaultReallocating(), "NRED");
    }


    modifier redeemVaultStrategiesModifier(address[] memory vaultStrategies) {
        _redeemVaultStrategies(vaultStrategies);
        _;
    }

    modifier redeemUserModifier() {
        _redeemUser();
        _;
    }

    modifier noReallocation() {
        _noReallocation();
        _;
    }  
}// BUSL-1.1

pragma solidity 0.8.11;


abstract contract VaultRestricted is IVaultRestricted, VaultIndexActions {
    using Bitwise for uint256;


    function payFees(uint256 profit) external override onlyFastWithdraw returns (uint256) {
        return _payFees(profit);
    }


    function reallocate(
        address[] memory vaultStrategies,
        uint256 newVaultProportions,
        uint256 finishedIndex,
        uint24 activeIndex
    ) 
        external 
        override
        onlySpool
        verifyStrategies(vaultStrategies)
        redeemVaultStrategiesModifier(vaultStrategies)
        noReallocation
        returns(uint256[] memory withdrawProportionsArray, uint256 newDepositProportions)
    {
        (withdrawProportionsArray, newDepositProportions) = _adjustAllocation(vaultStrategies, newVaultProportions, finishedIndex);

        proportions = newVaultProportions;

        reallocationIndex = activeIndex;
        _updateInteractedIndex(activeIndex);
        emit Reallocate(reallocationIndex, newVaultProportions);
    }

    function _adjustAllocation(
        address[] memory vaultStrategies,
        uint256 newVaultProportions,
        uint256 finishedIndex
    )
        private returns(uint256[] memory, uint256)
    {
        uint256[] memory depositProportionsArray = new uint256[](vaultStrategies.length);
        uint256[] memory withdrawProportionsArray = new uint256[](vaultStrategies.length);

        (uint256[] memory stratUnderlyings, uint256 vaultTotalUnderlying) = _getStratsAndVaultUnderlying(vaultStrategies, finishedIndex);

        require(vaultTotalUnderlying > 0, "NUL");

        uint256 totalProportion;
        uint256 totalDepositProportion;
        uint256 lastDepositIndex;

        {
            bool didWithdraw = false;
            bool willDeposit = false;
            for (uint256 i; i < vaultStrategies.length; i++) {
                uint256 newStratProportion = Bitwise.get14BitUintByIndex(newVaultProportions, i);
                totalProportion += newStratProportion;

                uint256 stratProportion;
                if (stratUnderlyings[i] > 0) {
                    stratProportion = (stratUnderlyings[i] * FULL_PERCENT) / vaultTotalUnderlying;
                }

                if (stratProportion > newStratProportion) {
                    uint256 withdrawalProportion = stratProportion - newStratProportion;
                    if (withdrawalProportion < 10) // NOTE: skip if diff is less than 0.1%
                        continue;

                    uint256 withdrawalShareProportion = (withdrawalProportion * ACCURACY) / stratProportion;
                    withdrawProportionsArray[i] = withdrawalShareProportion;

                    didWithdraw = true;
                } else if (stratProportion < newStratProportion) {
                    uint256 depositProportion = newStratProportion - stratProportion;
                    if (depositProportion < 10) // NOTE: skip if diff is less than 0.1%
                        continue;

                    depositProportionsArray[i] = depositProportion;
                    totalDepositProportion += depositProportion;
                    lastDepositIndex = i;

                    willDeposit = true;
                }
            }

            require(
                totalProportion == FULL_PERCENT,
                "BPP"
            );

            require(didWithdraw && willDeposit, "NRD");
        }

        uint256 newDepositProportions;
        uint256 totalDepositProp;
        for (uint256 i; i <= lastDepositIndex; i++) {
            if (depositProportionsArray[i] > 0) {
                uint256 proportion = (depositProportionsArray[i] * FULL_PERCENT) / totalDepositProportion;

                newDepositProportions = newDepositProportions.set14BitUintByIndex(i, proportion);
                
                totalDepositProp += proportion;
            }
        }
        
        newDepositProportions = newDepositProportions.set14BitUintByIndex(lastDepositIndex, FULL_PERCENT - totalDepositProp);

        depositProportions = newDepositProportions;

        return (withdrawProportionsArray, newDepositProportions);
    }

    function _getStratsAndVaultUnderlying(address[] memory vaultStrategies, uint256 index)
        private
        view
        returns (uint256[] memory, uint256)
    {
        uint256[] memory stratUnderlyings = new uint256[](vaultStrategies.length);

        uint256 vaultTotalUnderlying;
        for (uint256 i; i < vaultStrategies.length; i++) {
            uint256 stratUnderlying = spool.getVaultTotalUnderlyingAtIndex(vaultStrategies[i], index);

            stratUnderlyings[i] = stratUnderlying;
            vaultTotalUnderlying += stratUnderlying;
        }

        return (stratUnderlyings, vaultTotalUnderlying);
    }
}// BUSL-1.1

pragma solidity 0.8.11;


contract Vault is VaultRestricted {

    using SafeERC20 for IERC20;
    using Bitwise for uint256;


    constructor(
        ISpool _spool,
        IController _controller,
        IFastWithdraw _fastWithdraw,
        IFeeHandler _feeHandler,
        ISpoolOwner _spoolOwner
    )
        VaultBase(
            _spool,
            _controller,
            _fastWithdraw,
            _feeHandler
        )
        SpoolOwnable(_spoolOwner)
    {}


    function deposit(address[] memory vaultStrategies, uint128 amount, bool transferFromVault)
        external
        verifyStrategies(vaultStrategies)
        hasStrategies(vaultStrategies)
        redeemVaultStrategiesModifier(vaultStrategies)
        redeemUserModifier
        updateRewards
    {

        require(amount > 0, "NDP");

        uint24 activeGlobalIndex = _getActiveGlobalIndex();

        vaultIndexAction[activeGlobalIndex].depositAmount += amount;
        userIndexAction[msg.sender][activeGlobalIndex].depositAmount += amount;

        _distributeInStrats(vaultStrategies, amount, activeGlobalIndex);

        _updateInteractedIndex(activeGlobalIndex);
        _updateUserInteractedIndex(activeGlobalIndex);

        _transferDepositToSpool(amount, transferFromVault);

        _addInstantDeposit(amount);

        emit Deposit(msg.sender, activeGlobalIndex, amount);
    }

    function _distributeInStrats(
        address[] memory vaultStrategies,
        uint128 amount,
        uint256 activeGlobalIndex
    ) private {

        uint128 amountLeft = amount;
        uint256 lastElement = vaultStrategies.length - 1;
        uint256 _proportions = proportions;

        for (uint256 i; i < lastElement; i++) {
            uint128 proportionateAmount = _getStrategyDepositAmount(_proportions, i, amount);
            if (proportionateAmount > 0) {
                spool.deposit(vaultStrategies[i], proportionateAmount, activeGlobalIndex);
                amountLeft -= proportionateAmount;
            }
        }

        if (amountLeft > 0) {
            spool.deposit(vaultStrategies[lastElement], amountLeft, activeGlobalIndex);
        }
    }


    function withdraw(
        address[] memory vaultStrategies,
        uint128 sharesToWithdraw,
        bool withdrawAll
    )
        external
        verifyStrategies(vaultStrategies)
        redeemVaultStrategiesModifier(vaultStrategies)
        noReallocation
        redeemUserModifier
        updateRewards
    {

        sharesToWithdraw = _withdrawShares(sharesToWithdraw, withdrawAll);
        
        uint24 activeGlobalIndex = _getActiveGlobalIndex();

        userIndexAction[msg.sender][activeGlobalIndex].withdrawShares += sharesToWithdraw;
        vaultIndexAction[activeGlobalIndex].withdrawShares += sharesToWithdraw;

        _withdrawFromStrats(vaultStrategies, sharesToWithdraw, activeGlobalIndex);

        _updateInteractedIndex(activeGlobalIndex);
        _updateUserInteractedIndex(activeGlobalIndex);

        emit Withdraw(msg.sender, activeGlobalIndex, sharesToWithdraw);
    }


    function withdrawFast(
        address[] memory vaultStrategies,
        uint128 sharesToWithdraw,
        bool withdrawAll,
        FastWithdrawParams memory fastWithdrawParams
    )
        external
        noMidReallocation
        verifyStrategies(vaultStrategies)
        redeemVaultStrategiesModifier(vaultStrategies)
        noReallocation
        redeemUserModifier
        updateRewards
    {

        sharesToWithdraw = _withdrawShares(sharesToWithdraw, withdrawAll);

        uint256 vaultShareProportion = _getVaultShareProportion(sharesToWithdraw);
        totalShares -= sharesToWithdraw;

        uint128[] memory strategyRemovedShares = spool.removeShares(vaultStrategies, vaultShareProportion);

        uint256 proportionateDeposit = _getUserProportionateDeposit(sharesToWithdraw);

        fastWithdraw.transferShares(
            vaultStrategies,
            strategyRemovedShares,
            proportionateDeposit,
            msg.sender,
            fastWithdrawParams
        );

        emit WithdrawFast(msg.sender, sharesToWithdraw);
    }

    function _withdrawShares(uint128 sharesToWithdraw, bool withdrawAll) private returns(uint128) {

        User storage user = users[msg.sender];
        uint128 userShares = user.shares;

        uint128 userActiveInstantDeposit = user.instantDeposit;

        LastIndexInteracted memory userIndexInteracted = userLastInteractions[msg.sender];
        if (userIndexInteracted.index1 > 0) {
            userActiveInstantDeposit -= userIndexAction[msg.sender][userIndexInteracted.index1].depositAmount;
            if (userIndexInteracted.index2 > 0) {
                userActiveInstantDeposit -= userIndexAction[msg.sender][userIndexInteracted.index2].depositAmount;
            }
        }
        
        if (withdrawAll || (userShares > 0 && userShares == sharesToWithdraw)) {
            sharesToWithdraw = userShares;
            user.shares = 0;

            totalInstantDeposit -= userActiveInstantDeposit;
            user.instantDeposit -= userActiveInstantDeposit;
        } else {
            require(
                userShares >= sharesToWithdraw &&
                sharesToWithdraw > 0, 
                "WSH"
            );

            uint128 instantDepositWithdrawn = _getProportion128(userActiveInstantDeposit, sharesToWithdraw, userShares);

            totalInstantDeposit -= instantDepositWithdrawn;
            user.instantDeposit -= instantDepositWithdrawn;

            unchecked {
                user.shares = userShares - sharesToWithdraw;
            }
        }
        
        return sharesToWithdraw;
    }

    function _getUserProportionateDeposit(uint128 sharesToWithdraw) private returns(uint256) {

        User storage user = users[msg.sender];
        LastIndexInteracted memory userIndexInteracted = userLastInteractions[msg.sender];

        uint128 proportionateDeposit;
        uint128 sharesAtWithdrawal = user.shares + sharesToWithdraw;

        if (userIndexInteracted.index1 > 0) {
            sharesAtWithdrawal += userIndexAction[msg.sender][userIndexInteracted.index1].withdrawShares;

            if (userIndexInteracted.index2 > 0) {
                sharesAtWithdrawal += userIndexAction[msg.sender][userIndexInteracted.index2].withdrawShares;
            }
        }

        if (sharesAtWithdrawal > sharesToWithdraw) {
            uint128 userTotalDeposit = user.activeDeposit;
            proportionateDeposit = _getProportion128(userTotalDeposit, sharesToWithdraw, sharesAtWithdrawal);
            user.activeDeposit = userTotalDeposit - proportionateDeposit;
        } else {
            proportionateDeposit = user.activeDeposit;
            user.activeDeposit = 0;
        }

        return proportionateDeposit;
    }

    function _withdrawFromStrats(address[] memory vaultStrategies, uint128 totalSharesToWithdraw, uint256 activeGlobalIndex) private {

        uint256 vaultShareProportion = _getVaultShareProportion(totalSharesToWithdraw);
        for (uint256 i; i < vaultStrategies.length; i++) {
            spool.withdraw(vaultStrategies[i], vaultShareProportion, activeGlobalIndex);
        }
    }


    function claim(
        bool doRedeemVault,
        address[] memory vaultStrategies,
        bool doRedeemUser
    ) external returns (uint128 claimAmount) {

        User storage user = users[msg.sender];

        if (doRedeemVault) {
            _verifyStrategies(vaultStrategies);
            _redeemVaultStrategies(vaultStrategies);
        }

        if (doRedeemUser) {
            _redeemUser();
        }

        claimAmount = user.owed;
        require(claimAmount > 0, "CA0");

        user.owed = 0;

        uint128 userWithdrawnDeposits = user.withdrawnDeposits;
        if (claimAmount > userWithdrawnDeposits) {
            user.withdrawnDeposits = 0;
            uint128 profit = claimAmount - userWithdrawnDeposits;

            uint128 feesPaid = _payFeesAndTransfer(profit);

            claimAmount -= feesPaid;
        } else {
            user.withdrawnDeposits = userWithdrawnDeposits - claimAmount;
        }

        _underlying().safeTransfer(msg.sender, claimAmount);

        emit Claimed(msg.sender, claimAmount);
    }


    function redeemVaultAndUser(address[] memory vaultStrategies)
        external
        verifyStrategies(vaultStrategies)
        redeemVaultStrategiesModifier(vaultStrategies)
        redeemUserModifier
    {}


    function getUpdatedUser(address[] memory vaultStrategies)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        (uint256 totalUnderlying, , , , , ) = getUpdatedVault(vaultStrategies);
        _redeemUser();
        
        User storage user = users[msg.sender];

        uint256 userTotalUnderlying;
        if (totalShares > 0 && user.shares > 0) {
            userTotalUnderlying = (totalUnderlying * user.shares) / totalShares;
        }

        IndexAction storage indexAction1 = userIndexAction[msg.sender][userLastInteractions[msg.sender].index1];
        IndexAction storage indexAction2 = userIndexAction[msg.sender][userLastInteractions[msg.sender].index2];

        return (
            user.shares,
            user.activeDeposit, // amount of user deposited underlying token
            user.owed, // underlying token claimable amount
            user.withdrawnDeposits, // underlying token withdrawn amount
            userTotalUnderlying,
            indexAction1.depositAmount,
            indexAction1.withdrawShares,
            indexAction2.depositAmount,
            indexAction2.withdrawShares
        );
    }

    function redeemVaultStrategies(address[] memory vaultStrategies)
        external
        verifyStrategies(vaultStrategies)
        redeemVaultStrategiesModifier(vaultStrategies)
    {}


    function getUpdatedVault(address[] memory vaultStrategies)
        public
        verifyStrategies(vaultStrategies)
        redeemVaultStrategiesModifier(vaultStrategies)
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        uint256 totalUnderlying = 0;
        for (uint256 i; i < vaultStrategies.length; i++) {
            totalUnderlying += spool.getUnderlying(vaultStrategies[i]);
        }

        IndexAction storage indexAction1 = vaultIndexAction[lastIndexInteracted.index1];
        IndexAction storage indexAction2 = vaultIndexAction[lastIndexInteracted.index2];

        return (
            totalUnderlying,
            totalShares,
            indexAction1.depositAmount,
            indexAction1.withdrawShares,
            indexAction2.depositAmount,
            indexAction2.withdrawShares
        );
    }

    function redeemUser()
        external
    {

        _redeemUser();
    }


    function notifyStrategyRemoved(
        address[] memory vaultStrategies,
        uint256 i
    )
        external
        reallocationFinished
        verifyStrategies(vaultStrategies)
        hasStrategies(vaultStrategies)
        redeemVaultStrategiesModifier(vaultStrategies)
    {

        require(
            i < vaultStrategies.length &&
            !controller.validStrategy(vaultStrategies[i]),
            "BSTR"
        );

        uint256 lastElement = vaultStrategies.length - 1;

        address[] memory newStrategies = new address[](lastElement);

        if (lastElement > 0) {
            for (uint256 j; j < lastElement; j++) {
                newStrategies[j] = vaultStrategies[j];
            }

            if (i < lastElement) {
                newStrategies[i] = vaultStrategies[lastElement];
            }

            uint256 _proportions = proportions;
            uint256 proportionsLeft = FULL_PERCENT - _proportions.get14BitUintByIndex(i);
            if (lastElement > 1 && proportionsLeft > 0) {
                if (i == lastElement) {
                    _proportions = _proportions.reset14BitUintByIndex(i);
                } else {
                    uint256 lastProportion = _proportions.get14BitUintByIndex(lastElement);
                    _proportions = _proportions.reset14BitUintByIndex(i);
                    _proportions = _proportions.set14BitUintByIndex(i, lastProportion);
                }

                uint256 newProportions = _proportions;

                uint256 lastNewElement = lastElement - 1;
                uint256 newProportionsLeft = FULL_PERCENT;
                for (uint256 j; j < lastNewElement; j++) {
                    uint256 propJ = _proportions.get14BitUintByIndex(j);
                    propJ = (propJ * FULL_PERCENT) / proportionsLeft;
                    newProportions = newProportions.set14BitUintByIndex(j, propJ);
                    newProportionsLeft -= propJ;
                }

                newProportions = newProportions.set14BitUintByIndex(lastNewElement, newProportionsLeft);

                proportions = newProportions;
            } else {
                proportions = FULL_PERCENT;
            }
        } else {
            proportions = 0;
        }

        _updateStrategiesHash(newStrategies);
        emit StrategyRemoved(i, vaultStrategies[i]);
    }


    function _hasStrategies(address[] memory vaultStrategies) private pure {

        require(vaultStrategies.length > 0, "NST");
    }


    modifier hasStrategies(address[] memory vaultStrategies) {

        _hasStrategies(vaultStrategies);
        _;
    }

    modifier reallocationFinished() {

        require(
            !_isVaultReallocating() ||
            reallocationIndex <= spool.getCompletedGlobalIndex(),
            "RNF"
        );
        _;
    }
}