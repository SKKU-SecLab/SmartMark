
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;

interface IDependencyController {

    function currentExecutor() external returns (address);

}// BUSL-1.1
pragma solidity ^0.8.0;


uint256 constant FUND_TRANSFERER = 1;
uint256 constant MARGIN_CALLER = 2;
uint256 constant BORROWER = 3;
uint256 constant MARGIN_TRADER = 4;
uint256 constant FEE_SOURCE = 5;
uint256 constant LIQUIDATOR = 6;
uint256 constant AUTHORIZED_FUND_TRADER = 7;
uint256 constant INCENTIVE_REPORTER = 8;
uint256 constant TOKEN_ACTIVATOR = 9;
uint256 constant STAKE_PENALIZER = 10;

uint256 constant FUND = 101;
uint256 constant LENDING = 102;
uint256 constant MARGIN_ROUTER = 103;
uint256 constant CROSS_MARGIN_TRADING = 104;
uint256 constant FEE_CONTROLLER = 105;
uint256 constant PRICE_CONTROLLER = 106;
uint256 constant ADMIN = 107;
uint256 constant INCENTIVE_DISTRIBUTION = 108;
uint256 constant TOKEN_ADMIN = 109;

uint256 constant DISABLER = 1001;
uint256 constant DEPENDENCY_CONTROLLER = 1002;

contract Roles is Ownable {

    mapping(address => mapping(uint256 => bool)) public roles;
    mapping(uint256 => address) public mainCharacters;

    constructor() Ownable() {
        roles[msg.sender][TOKEN_ACTIVATOR] = true;
    }

    modifier onlyOwnerExecDepController() {

        require(
            owner() == msg.sender ||
                executor() == msg.sender ||
                mainCharacters[DEPENDENCY_CONTROLLER] == msg.sender,
            "Roles: caller is not the owner"
        );
        _;
    }

    function giveRole(uint256 role, address actor)
        external
        onlyOwnerExecDepController
    {

        roles[actor][role] = true;
    }

    function removeRole(uint256 role, address actor)
        external
        onlyOwnerExecDepController
    {

        roles[actor][role] = false;
    }

    function setMainCharacter(uint256 role, address actor)
        external
        onlyOwnerExecDepController
    {

        mainCharacters[role] = actor;
    }

    function getRole(uint256 role, address contr) external view returns (bool) {

        return roles[contr][role];
    }

    function executor() public returns (address exec) {

        address depController = mainCharacters[DEPENDENCY_CONTROLLER];
        if (depController != address(0)) {
            exec = IDependencyController(depController).currentExecutor();
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


contract RoleAware {

    Roles public immutable roles;
    mapping(uint256 => address) public mainCharacterCache;
    mapping(address => mapping(uint256 => bool)) public roleCache;

    constructor(address _roles) {
        require(_roles != address(0), "Please provide valid roles address");
        roles = Roles(_roles);
    }

    modifier noIntermediary() {

        require(
            msg.sender == tx.origin,
            "Currently no intermediaries allowed for this function call"
        );
        _;
    }

    modifier onlyOwnerExec() {

        require(
            owner() == msg.sender || executor() == msg.sender,
            "Roles: caller is not the owner"
        );
        _;
    }

    modifier onlyOwnerExecDisabler() {

        require(
            owner() == msg.sender ||
                executor() == msg.sender ||
                disabler() == msg.sender,
            "Caller is not the owner, executor or authorized disabler"
        );
        _;
    }

    modifier onlyOwnerExecActivator() {

        require(
            owner() == msg.sender ||
                executor() == msg.sender ||
                isTokenActivator(msg.sender),
            "Caller is not the owner, executor or authorized activator"
        );
        _;
    }

    function updateRoleCache(uint256 role, address contr) public virtual {

        roleCache[contr][role] = roles.getRole(role, contr);
    }

    function updateMainCharacterCache(uint256 role) public virtual {

        mainCharacterCache[role] = roles.mainCharacters(role);
    }

    function owner() internal view returns (address) {

        return roles.owner();
    }

    function executor() internal returns (address) {

        return roles.executor();
    }

    function disabler() internal view returns (address) {

        return mainCharacterCache[DISABLER];
    }

    function fund() internal view returns (address) {

        return mainCharacterCache[FUND];
    }

    function lending() internal view returns (address) {

        return mainCharacterCache[LENDING];
    }

    function marginRouter() internal view returns (address) {

        return mainCharacterCache[MARGIN_ROUTER];
    }

    function crossMarginTrading() internal view returns (address) {

        return mainCharacterCache[CROSS_MARGIN_TRADING];
    }

    function feeController() internal view returns (address) {

        return mainCharacterCache[FEE_CONTROLLER];
    }

    function price() internal view returns (address) {

        return mainCharacterCache[PRICE_CONTROLLER];
    }

    function admin() internal view returns (address) {

        return mainCharacterCache[ADMIN];
    }

    function incentiveDistributor() internal view returns (address) {

        return mainCharacterCache[INCENTIVE_DISTRIBUTION];
    }

    function tokenAdmin() internal view returns (address) {

        return mainCharacterCache[TOKEN_ADMIN];
    }

    function isBorrower(address contr) internal view returns (bool) {

        return roleCache[contr][BORROWER];
    }

    function isFundTransferer(address contr) internal view returns (bool) {

        return roleCache[contr][FUND_TRANSFERER];
    }

    function isMarginTrader(address contr) internal view returns (bool) {

        return roleCache[contr][MARGIN_TRADER];
    }

    function isFeeSource(address contr) internal view returns (bool) {

        return roleCache[contr][FEE_SOURCE];
    }

    function isMarginCaller(address contr) internal view returns (bool) {

        return roleCache[contr][MARGIN_CALLER];
    }

    function isLiquidator(address contr) internal view returns (bool) {

        return roleCache[contr][LIQUIDATOR];
    }

    function isAuthorizedFundTrader(address contr)
        internal
        view
        returns (bool)
    {

        return roleCache[contr][AUTHORIZED_FUND_TRADER];
    }

    function isIncentiveReporter(address contr) internal view returns (bool) {

        return roleCache[contr][INCENTIVE_REPORTER];
    }

    function isTokenActivator(address contr) internal view returns (bool) {

        return roleCache[contr][TOKEN_ACTIVATOR];
    }

    function isStakePenalizer(address contr) internal view returns (bool) {

        return roleCache[contr][STAKE_PENALIZER];
    }
}// BUSL-1.1
pragma solidity ^0.8.0;

abstract contract BaseLending {
    uint256 constant FP32 = 2**32;
    uint256 constant ACCUMULATOR_INIT = 10**18;

    struct YieldAccumulator {
        uint256 accumulatorFP;
        uint256 lastUpdated;
        uint256 hourlyYieldFP;
    }

    struct LendingMetadata {
        uint256 totalLending;
        uint256 totalBorrowed;
        uint256 lendingBuffer;
        uint256 lendingCap;
    }
    mapping(address => LendingMetadata) public lendingMeta;

    mapping(address => YieldAccumulator) public borrowYieldAccumulators;

    uint256 public maxHourlyYieldFP;
    uint256 public yieldChangePerSecondFP;

    function applyInterest(
        uint256 balance,
        uint256 accumulatorFP,
        uint256 yieldQuotientFP
    ) internal pure returns (uint256) {
        return (balance * accumulatorFP) / yieldQuotientFP;
    }

    function updatedYieldFP(
        uint256 yieldFP,
        uint256 lastUpdated,
        uint256 totalLendingInBucket,
        uint256 bucketTarget,
        uint256 buyingSpeed,
        uint256 withdrawingSpeed,
        uint256 bucketMaxYield
    ) internal view returns (uint256) {
        uint256 timeDiff = block.timestamp - lastUpdated;
        uint256 yieldDiff = timeDiff * yieldChangePerSecondFP;

        if (
            totalLendingInBucket >= bucketTarget ||
            buyingSpeed >= withdrawingSpeed
        ) {
            yieldFP -= min(yieldFP, yieldDiff);
        } else {
            yieldFP += yieldDiff;
            if (yieldFP > bucketMaxYield) {
                yieldFP = bucketMaxYield;
            }
        }

        return max(FP32, yieldFP);
    }

    function updateSpeed(
        uint256 speed,
        uint256 lastAction,
        uint256 amount,
        uint256 runtime
    ) internal view returns (uint256 newSpeed, uint256 newLastAction) {
        uint256 timeDiff = block.timestamp - lastAction;
        uint256 updateAmount = (amount * runtime) / (timeDiff + 1);

        uint256 oldSpeedWeight = (runtime + 120 minutes) / 3;
        uint256 updateWeight = timeDiff + 1;
        newSpeed =
            (speed * oldSpeedWeight + updateAmount * updateWeight) /
            (oldSpeedWeight + updateWeight);
        newLastAction = block.timestamp;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return b;
        } else {
            return a;
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }

    function _makeFallbackBond(
        address issuer,
        address holder,
        uint256 amount
    ) internal virtual;

    function lendingTarget(LendingMetadata storage meta)
        internal
        view
        returns (uint256)
    {
        return min(meta.lendingCap, meta.totalBorrowed + meta.lendingBuffer);
    }

    function viewLendingTarget(address issuer) external view returns (uint256) {
        LendingMetadata storage meta = lendingMeta[issuer];
        return lendingTarget(meta);
    }

    function issuanceBalance(address issuance)
        internal
        view
        virtual
        returns (uint256);
}// BUSL-1.1
pragma solidity ^0.8.0;

struct Bond {
    address holder;
    address issuer;
    uint256 originalPrice;
    uint256 returnAmount;
    uint256 maturityTimestamp;
    uint256 runtime;
    uint256 yieldFP;
}

abstract contract BondLending is BaseLending {
    uint256 public minRuntime = 30 days;
    uint256 public maxRuntime = 365 days;
    uint256 public diffMaxMinRuntime = maxRuntime - minRuntime;
    uint256 public constant WEIGHT_TOTAL_10k = 10_000;

    struct BondBucketMetadata {
        uint256 runtimeWeight;
        uint256 buyingSpeed;
        uint256 lastBought;
        uint256 withdrawingSpeed;
        uint256 lastWithdrawn;
        uint256 yieldLastUpdated;
        uint256 totalLending;
        uint256 runtimeYieldFP;
    }

    mapping(uint256 => Bond) public bonds;

    mapping(address => BondBucketMetadata[]) public bondBucketMetadata;

    uint256 public nextBondIndex = 1;

    event LiquidityWarning(
        address indexed issuer,
        address indexed holder,
        uint256 value
    );

    function _makeBond(
        address holder,
        address issuer,
        uint256 runtime,
        uint256 amount,
        uint256 minReturn
    ) internal returns (uint256 bondIndex) {
        uint256 bucketIndex = getBucketIndex(issuer, runtime);
        BondBucketMetadata storage bondMeta =
            bondBucketMetadata[issuer][bucketIndex];

        uint256 yieldFP = calcBondYieldFP(issuer, amount, runtime, bondMeta);

        uint256 bondReturn = (yieldFP * amount) / FP32;
        if (bondReturn >= minReturn) {
            uint256 interpolatedAmount = (amount + bondReturn) / 2;
            lendingMeta[issuer].totalLending += interpolatedAmount;

            bondMeta.totalLending += interpolatedAmount;

            bondIndex = nextBondIndex;
            nextBondIndex++;

            bonds[bondIndex] = Bond({
                holder: holder,
                issuer: issuer,
                originalPrice: amount,
                returnAmount: bondReturn,
                maturityTimestamp: block.timestamp + runtime,
                runtime: runtime,
                yieldFP: yieldFP
            });

            (bondMeta.buyingSpeed, bondMeta.lastBought) = updateSpeed(
                bondMeta.buyingSpeed,
                bondMeta.lastBought,
                amount,
                runtime
            );
        }
    }

    function _withdrawBond(uint256 bondId, Bond storage bond)
        internal
        returns (uint256 withdrawAmount)
    {
        address issuer = bond.issuer;
        uint256 bucketIndex = getBucketIndex(issuer, bond.runtime);
        BondBucketMetadata storage bondMeta =
            bondBucketMetadata[issuer][bucketIndex];

        uint256 returnAmount = bond.returnAmount;
        address holder = bond.holder;

        uint256 interpolatedAmount = (bond.originalPrice + returnAmount) / 2;

        LendingMetadata storage meta = lendingMeta[issuer];
        meta.totalLending -= interpolatedAmount;
        bondMeta.totalLending -= interpolatedAmount;

        (bondMeta.withdrawingSpeed, bondMeta.lastWithdrawn) = updateSpeed(
            bondMeta.withdrawingSpeed,
            bondMeta.lastWithdrawn,
            bond.originalPrice,
            bond.runtime
        );

        delete bonds[bondId];
        if (
            meta.totalBorrowed > meta.totalLending ||
            issuanceBalance(issuer) < returnAmount
        ) {
            emit LiquidityWarning(issuer, holder, returnAmount);
            _makeFallbackBond(issuer, holder, returnAmount);
        } else {
            withdrawAmount = returnAmount;
        }
    }

    function calcBondYieldFP(
        address issuer,
        uint256 addedAmount,
        uint256 runtime,
        BondBucketMetadata storage bucketMeta
    ) internal view returns (uint256 yieldFP) {
        uint256 totalLendingInBucket = addedAmount + bucketMeta.totalLending;

        yieldFP = bucketMeta.runtimeYieldFP;
        uint256 lastUpdated = bucketMeta.yieldLastUpdated;

        LendingMetadata storage meta = lendingMeta[issuer];
        uint256 bucketTarget =
            (lendingTarget(meta) * bucketMeta.runtimeWeight) / WEIGHT_TOTAL_10k;

        uint256 buying = bucketMeta.buyingSpeed;
        uint256 withdrawing = bucketMeta.withdrawingSpeed;

        YieldAccumulator storage borrowAccumulator =
            borrowYieldAccumulators[issuer];

        uint256 yieldGeneratedFP =
            (borrowAccumulator.hourlyYieldFP * meta.totalBorrowed) /
                (1 + meta.totalLending);
        uint256 _maxHourlyYieldFP = min(maxHourlyYieldFP, yieldGeneratedFP);

        uint256 bucketMaxYield = _maxHourlyYieldFP * (runtime / (1 hours));

        yieldFP = updatedYieldFP(
            yieldFP,
            lastUpdated,
            totalLendingInBucket,
            bucketTarget,
            buying,
            withdrawing,
            bucketMaxYield
        );
    }

    function viewBondReturn(
        address issuer,
        uint256 runtime,
        uint256 amount
    ) external view returns (uint256) {
        uint256 bucketIndex = getBucketIndex(issuer, runtime);
        uint256 yieldFP =
            calcBondYieldFP(
                issuer,
                amount + bondBucketMetadata[issuer][bucketIndex].totalLending,
                runtime,
                bondBucketMetadata[issuer][bucketIndex]
            );
        return (yieldFP * amount) / FP32;
    }

    function getBucketIndex(address issuer, uint256 runtime)
        internal
        view
        returns (uint256 bucketIndex)
    {
        uint256 bucketSize =
            diffMaxMinRuntime / bondBucketMetadata[issuer].length;
        bucketIndex = (runtime - minRuntime) / bucketSize;
    }
}pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}// BUSL-1.1
pragma solidity ^0.8.0;


contract Fund is RoleAware {

    using SafeERC20 for IERC20;
    address public immutable WETH;

    constructor(address _WETH, address _roles) RoleAware(_roles) {
        WETH = _WETH;
    }

    function deposit(address depositToken, uint256 depositAmount) external {

        IERC20(depositToken).safeTransferFrom(
            msg.sender,
            address(this),
            depositAmount
        );
    }

    function depositFor(
        address sender,
        address depositToken,
        uint256 depositAmount
    ) external {

        require(isFundTransferer(msg.sender), "Unauthorized deposit");
        IERC20(depositToken).safeTransferFrom(
            sender,
            address(this),
            depositAmount
        );
    }

    function depositToWETH() external payable {

        IWETH(WETH).deposit{value: msg.value}();
    }

    function withdraw(
        address withdrawalToken,
        address recipient,
        uint256 withdrawalAmount
    ) external {

        require(isFundTransferer(msg.sender), "Unauthorized withdraw");
        IERC20(withdrawalToken).safeTransfer(recipient, withdrawalAmount);
    }

    function withdrawETH(address recipient, uint256 withdrawalAmount) external {

        require(isFundTransferer(msg.sender), "Unauthorized withdraw");
        IWETH(WETH).withdraw(withdrawalAmount);
        Address.sendValue(payable(recipient), withdrawalAmount);
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


struct HourlyBond {
    uint256 amount;
    uint256 yieldQuotientFP;
    uint256 moduloHour;
}

abstract contract HourlyBondSubscriptionLending is BaseLending {
    struct HourlyBondMetadata {
        YieldAccumulator yieldAccumulator;
        uint256 buyingSpeed;
        uint256 withdrawingSpeed;
        uint256 lastBought;
        uint256 lastWithdrawn;
    }

    mapping(address => HourlyBondMetadata) hourlyBondMetadata;

    uint256 public withdrawalWindow = 15 minutes;
    mapping(address => mapping(address => HourlyBond))
        public hourlyBondAccounts;

    uint256 public borrowingFactorPercent = 200;

    function _makeHourlyBond(
        address issuer,
        address holder,
        uint256 amount
    ) internal {
        HourlyBond storage bond = hourlyBondAccounts[issuer][holder];
        updateHourlyBondAmount(issuer, bond);

        HourlyBondMetadata storage bondMeta = hourlyBondMetadata[issuer];
        bond.yieldQuotientFP = bondMeta.yieldAccumulator.accumulatorFP;
        bond.moduloHour = block.timestamp % (1 hours);
        bond.amount += amount;
        lendingMeta[issuer].totalLending += amount;

        (bondMeta.buyingSpeed, bondMeta.lastBought) = updateSpeed(
            bondMeta.buyingSpeed,
            bondMeta.lastBought,
            amount,
            1 hours
        );
    }

    function updateHourlyBondAmount(address issuer, HourlyBond storage bond)
        internal
    {
        uint256 yieldQuotientFP = bond.yieldQuotientFP;
        if (yieldQuotientFP > 0) {
            YieldAccumulator storage yA =
                getUpdatedHourlyYield(issuer, hourlyBondMetadata[issuer]);

            uint256 oldAmount = bond.amount;

            bond.amount = applyInterest(
                bond.amount,
                yA.accumulatorFP,
                yieldQuotientFP
            );

            uint256 deltaAmount = bond.amount - oldAmount;
            lendingMeta[issuer].totalLending += deltaAmount;
        }
    }

    function viewHourlyBondAmount(address issuer, address holder)
        public
        view
        returns (uint256)
    {
        HourlyBond storage bond = hourlyBondAccounts[issuer][holder];
        uint256 yieldQuotientFP = bond.yieldQuotientFP;

        uint256 cumulativeYield =
            viewCumulativeYieldFP(
                hourlyBondMetadata[issuer].yieldAccumulator,
                block.timestamp
            );

        if (yieldQuotientFP > 0) {
            return applyInterest(bond.amount, cumulativeYield, yieldQuotientFP);
        } else {
            return bond.amount;
        }
    }

    function _withdrawHourlyBond(
        address issuer,
        HourlyBond storage bond,
        uint256 amount
    ) internal {
        uint256 currentOffset = (block.timestamp - bond.moduloHour) % (1 hours);

        require(
            withdrawalWindow >= currentOffset,
            "Tried withdrawing outside subscription cancellation time window"
        );

        bond.amount -= amount;
        lendingMeta[issuer].totalLending -= amount;

        HourlyBondMetadata storage bondMeta = hourlyBondMetadata[issuer];
        (bondMeta.withdrawingSpeed, bondMeta.lastWithdrawn) = updateSpeed(
            bondMeta.withdrawingSpeed,
            bondMeta.lastWithdrawn,
            bond.amount,
            1 hours
        );
    }

    function calcCumulativeYieldFP(
        YieldAccumulator storage yieldAccumulator,
        uint256 timeDelta
    ) internal view returns (uint256 accumulatorFP) {
        uint256 secondsDelta = timeDelta % (1 hours);
        accumulatorFP =
            yieldAccumulator.accumulatorFP +
            (yieldAccumulator.accumulatorFP *
                (yieldAccumulator.hourlyYieldFP - FP32) *
                secondsDelta) /
            (FP32 * 1 hours);

        uint256 hoursDelta = timeDelta / (1 hours);
        if (hoursDelta > 0) {
            for (uint256 i = 0; hoursDelta > i; i++) {
                accumulatorFP =
                    (accumulatorFP * yieldAccumulator.hourlyYieldFP) /
                    FP32;
            }
        }
    }

    function getUpdatedHourlyYield(
        address issuer,
        HourlyBondMetadata storage bondMeta
    ) internal returns (YieldAccumulator storage accumulator) {
        accumulator = bondMeta.yieldAccumulator;
        uint256 lastUpdated = accumulator.lastUpdated;
        uint256 timeDelta = (block.timestamp - lastUpdated);

        YieldAccumulator storage borrowAccumulator =
            borrowYieldAccumulators[issuer];

        if (timeDelta > (5 minutes)) {
            accumulator.accumulatorFP = calcCumulativeYieldFP(
                accumulator,
                timeDelta
            );

            LendingMetadata storage meta = lendingMeta[issuer];

            uint256 yieldGeneratedFP =
                (borrowAccumulator.hourlyYieldFP * meta.totalBorrowed) /
                    (1 + meta.totalLending);
            uint256 _maxHourlyYieldFP = min(maxHourlyYieldFP, yieldGeneratedFP);

            accumulator.hourlyYieldFP = updatedYieldFP(
                accumulator.hourlyYieldFP,
                lastUpdated,
                meta.totalLending,
                lendingTarget(meta),
                bondMeta.buyingSpeed,
                bondMeta.withdrawingSpeed,
                _maxHourlyYieldFP
            );
            accumulator.lastUpdated = block.timestamp;
        }

        updateBorrowYieldAccu(borrowAccumulator);

        borrowAccumulator.hourlyYieldFP =
            1 +
            (borrowingFactorPercent * accumulator.hourlyYieldFP) /
            100;
    }

    function updateBorrowYieldAccu(YieldAccumulator storage borrowAccumulator)
        internal
    {
        uint256 timeDelta = block.timestamp - borrowAccumulator.lastUpdated;

        if (timeDelta > (5 minutes)) {
            borrowAccumulator.accumulatorFP = calcCumulativeYieldFP(
                borrowAccumulator,
                timeDelta
            );

            borrowAccumulator.lastUpdated = block.timestamp;
        }
    }

    function getUpdatedBorrowYieldAccuFP(address issuer)
        external
        returns (uint256)
    {
        YieldAccumulator storage yA = borrowYieldAccumulators[issuer];
        updateBorrowYieldAccu(yA);
        return yA.accumulatorFP;
    }

    function viewCumulativeYieldFP(
        YieldAccumulator storage yA,
        uint256 timestamp
    ) internal view returns (uint256) {
        uint256 timeDelta = (timestamp - yA.lastUpdated);
        if (timeDelta > 5 minutes) {
            return calcCumulativeYieldFP(yA, timeDelta);
        } else {
            return yA.accumulatorFP;
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


struct Claim {
    uint256 startingRewardRateFP;
    uint256 amount;
    uint256 intraDayGain;
    uint256 intraDayLoss;
}

contract IncentiveDistribution is RoleAware {

    uint256 internal constant FP32 = 2**32;
    uint256 public constant contractionPerMil = 999;
    address public immutable MFI;

    constructor(
        address _MFI,
        uint256 startingDailyDistributionWithoutDecimals,
        address _roles
    ) RoleAware(_roles) {
        MFI = _MFI;
        currentDailyDistribution =
            startingDailyDistributionWithoutDecimals *
            (1 ether);

        lastUpdatedDay = block.timestamp % (1 days);
    }

    uint256 public currentDailyDistribution;

    uint256 public trancheShareTotal;
    uint256[] public allTranches;

    struct TrancheMeta {
        uint256 rewardShare;
        uint256 currentDayGains;
        uint256 currentDayLosses;
        uint256 tomorrowOngoingTotals;
        uint256 yesterdayOngoingTotals;
        uint256 intraDayGains;
        uint256 intraDayLosses;
        uint256 intraDayRewardGains;
        uint256 intraDayRewardLosses;
        uint256 aggregateDailyRewardRateFP;
        uint256 yesterdayRewardRateFP;
        mapping(address => Claim) claims;
    }

    mapping(uint256 => TrancheMeta) public trancheMetadata;

    uint256 public lastUpdatedDay;

    mapping(address => uint256) public accruedReward;

    function setTrancheShare(uint256 tranche, uint256 share)
        external
        onlyOwnerExecActivator
    {

        require(
            trancheMetadata[tranche].rewardShare > 0,
            "Tranche not initialized"
        );
        _setTrancheShare(tranche, share);
    }

    function _setTrancheShare(uint256 tranche, uint256 share) internal {

        TrancheMeta storage tm = trancheMetadata[tranche];

        if (share > tm.rewardShare) {
            trancheShareTotal += share - tm.rewardShare;
        } else {
            trancheShareTotal -= tm.rewardShare - share;
        }
        tm.rewardShare = share;
    }

    function initTranche(uint256 tranche, uint256 share)
        external
        onlyOwnerExecActivator
    {

        TrancheMeta storage tm = trancheMetadata[tranche];
        require(tm.rewardShare == 0, "Tranche already initialized");
        _setTrancheShare(tranche, share);

        tm.aggregateDailyRewardRateFP = FP32;
        allTranches.push(tranche);
    }

    function addToClaimAmount(
        uint256 tranche,
        address recipient,
        uint256 claimAmount
    ) external {

        require(
            isIncentiveReporter(msg.sender),
            "Contract not authorized to report incentives"
        );
        if (currentDailyDistribution > 0) {
            TrancheMeta storage tm = trancheMetadata[tranche];
            Claim storage claim = tm.claims[recipient];

            uint256 currentDay =
                claimAmount * (1 days - (block.timestamp % (1 days)));

            tm.currentDayGains += currentDay;
            claim.intraDayGain += currentDay * currentDailyDistribution;

            tm.tomorrowOngoingTotals += claimAmount * 1 days;
            updateAccruedReward(tm, recipient, claim);

            claim.amount += claimAmount * (1 days);
        }
    }

    function subtractFromClaimAmount(
        uint256 tranche,
        address recipient,
        uint256 subtractAmount
    ) external {

        require(
            isIncentiveReporter(msg.sender),
            "Contract not authorized to report incentives"
        );
        uint256 currentDay = subtractAmount * (block.timestamp % (1 days));

        TrancheMeta storage tm = trancheMetadata[tranche];
        Claim storage claim = tm.claims[recipient];

        tm.currentDayLosses += currentDay;
        claim.intraDayLoss += currentDay * currentDailyDistribution;

        tm.tomorrowOngoingTotals -= subtractAmount * 1 days;

        updateAccruedReward(tm, recipient, claim);
        claim.amount -= subtractAmount * (1 days);
    }

    function updateAccruedReward(
        TrancheMeta storage tm,
        address recipient,
        Claim storage claim
    ) internal returns (uint256 rewardDelta) {

        if (claim.startingRewardRateFP > 0) {
            rewardDelta = calcRewardAmount(tm, claim);
            accruedReward[recipient] += rewardDelta;
        }
        claim.startingRewardRateFP =
            tm.yesterdayRewardRateFP +
            tm.aggregateDailyRewardRateFP;
    }

    function calcRewardAmount(TrancheMeta storage tm, Claim storage claim)
        internal
        view
        returns (uint256 rewardAmount)
    {

        uint256 ours = claim.startingRewardRateFP;
        uint256 aggregate = tm.aggregateDailyRewardRateFP;
        if (aggregate > ours) {
            rewardAmount = (claim.amount * (aggregate - ours)) / FP32;
        }
    }

    function applyIntraDay(TrancheMeta storage tm, Claim storage claim)
        internal
        view
        returns (uint256 gainImpact, uint256 lossImpact)
    {

        uint256 gain = claim.intraDayGain;
        uint256 loss = claim.intraDayLoss;

        if (gain + loss > 0) {
            gainImpact =
                (gain * tm.intraDayRewardGains) /
                (tm.intraDayGains + 1);
            lossImpact =
                (loss * tm.intraDayRewardLosses) /
                (tm.intraDayLosses + 1);
        }
    }

    function viewRewardAmount(uint256 tranche, address claimant)
        external
        view
        returns (uint256)
    {

        TrancheMeta storage tm = trancheMetadata[tranche];
        Claim storage claim = tm.claims[claimant];

        uint256 rewardAmount =
            accruedReward[claimant] + calcRewardAmount(tm, claim);
        (uint256 gainImpact, uint256 lossImpact) = applyIntraDay(tm, claim);

        return rewardAmount + gainImpact - lossImpact;
    }

    function withdrawReward(uint256[] calldata tranches)
        external
        returns (uint256 withdrawAmount)
    {

        updateDayTotals();

        withdrawAmount = accruedReward[msg.sender];
        for (uint256 i; tranches.length > i; i++) {
            uint256 tranche = tranches[i];

            TrancheMeta storage tm = trancheMetadata[tranche];
            Claim storage claim = tm.claims[msg.sender];

            withdrawAmount += updateAccruedReward(tm, msg.sender, claim);

            (uint256 gainImpact, uint256 lossImpact) = applyIntraDay(tm, claim);

            withdrawAmount = withdrawAmount + gainImpact - lossImpact;

            tm.intraDayGains -= claim.intraDayGain;
            tm.intraDayLosses -= claim.intraDayLoss;
            tm.intraDayRewardGains -= gainImpact;
            tm.intraDayRewardLosses -= lossImpact;

            claim.intraDayGain = 0;
        }

        accruedReward[msg.sender] = 0;

        Fund(fund()).withdraw(MFI, msg.sender, withdrawAmount);
    }

    function updateDayTotals() internal {

        uint256 nowDay = block.timestamp / (1 days);
        uint256 dayDiff = nowDay - lastUpdatedDay;

        for (uint256 i = 0; i < dayDiff; i++) {
            _updateTrancheTotals();

            currentDailyDistribution =
                (currentDailyDistribution * contractionPerMil) /
                1000;

            lastUpdatedDay += 1;
        }
    }

    function _updateTrancheTotals() internal {

        for (uint256 i; allTranches.length > i; i++) {
            uint256 tranche = allTranches[i];
            TrancheMeta storage tm = trancheMetadata[tranche];

            uint256 todayTotal =
                tm.yesterdayOngoingTotals +
                    tm.currentDayGains -
                    tm.currentDayLosses;

            uint256 todayRewardRateFP =
                (FP32 * (currentDailyDistribution * tm.rewardShare)) /
                    trancheShareTotal /
                    todayTotal;

            tm.yesterdayRewardRateFP = todayRewardRateFP;

            tm.aggregateDailyRewardRateFP += todayRewardRateFP;

            tm.intraDayGains += tm.currentDayGains * currentDailyDistribution;

            tm.intraDayLosses += tm.currentDayLosses * currentDailyDistribution;

            tm.intraDayRewardGains +=
                (tm.currentDayGains * todayRewardRateFP) /
                FP32;

            tm.intraDayRewardLosses +=
                (tm.currentDayLosses * todayRewardRateFP) /
                FP32;

            tm.yesterdayOngoingTotals = tm.tomorrowOngoingTotals;
            tm.currentDayGains = 0;
            tm.currentDayLosses = 0;
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


abstract contract IncentivizedHolder is RoleAware {
    mapping(address => uint256) public incentiveTranches;

    function setIncentiveTranche(address token, uint8 tranche)
        external
        onlyOwnerExecActivator
    {
        incentiveTranches[token] = tranche;
    }

    function stakeClaim(
        address claimant,
        address token,
        uint256 amount
    ) internal {
        IncentiveDistribution iD =
            IncentiveDistribution(incentiveDistributor());

        uint256 tranche = incentiveTranches[token];

        iD.addToClaimAmount(tranche, claimant, amount);
    }

    function withdrawClaim(
        address claimant,
        address token,
        uint256 amount
    ) internal {
        uint256 tranche = incentiveTranches[token];

        IncentiveDistribution(incentiveDistributor()).subtractFromClaimAmount(
            tranche,
            claimant,
            amount
        );
    }
}// BUSL-1.1
pragma solidity ^0.8.0;



contract Lending is
    RoleAware,
    HourlyBondSubscriptionLending,
    BondLending,
    IncentivizedHolder
{

    mapping(address => uint256[]) public bondIds;

    mapping(address => address) public issuerTokens;

    mapping(address => uint256) public haircuts;

    mapping(address => bool) public activeIssuers;

    constructor(address _roles) RoleAware(_roles) {
        uint256 APR = 899;
        maxHourlyYieldFP = (FP32 * APR) / 100 / (24 * 365);

        uint256 aprChangePerMil = 3;
        yieldChangePerSecondFP = (FP32 * aprChangePerMil) / 1000;
    }

    function activateIssuer(address issuer) external {

        activateIssuer(issuer, issuer);
    }

    function activateIssuer(address issuer, address token)
        public
        onlyOwnerExecActivator
    {

        activeIssuers[issuer] = true;
        issuerTokens[issuer] = token;
    }

    function deactivateIssuer(address issuer) external onlyOwnerExecActivator {

        activeIssuers[issuer] = false;
    }

    function setLendingCap(address issuer, uint256 cap)
        external
        onlyOwnerExecActivator
    {

        lendingMeta[issuer].lendingCap = cap;
    }

    function setLendingBuffer(address issuer, uint256 buffer)
        external
        onlyOwnerExecActivator
    {

        lendingMeta[issuer].lendingBuffer = buffer;
    }

    function setWithdrawalWindow(uint256 window) external onlyOwnerExec {

        withdrawalWindow = window;
    }

    function setHourlyYieldAPR(address issuer, uint256 aprPercent)
        external
        onlyOwnerExecActivator
    {

        HourlyBondMetadata storage bondMeta = hourlyBondMetadata[issuer];

        if (bondMeta.yieldAccumulator.accumulatorFP == 0) {
            uint256 yieldFP = FP32 + (FP32 * aprPercent) / 100 / (24 * 365);
            bondMeta.yieldAccumulator = YieldAccumulator({
                accumulatorFP: FP32,
                lastUpdated: block.timestamp,
                hourlyYieldFP: yieldFP
            });
            bondMeta.buyingSpeed = 1;
            bondMeta.withdrawingSpeed = 1;
            bondMeta.lastBought = block.timestamp;
            bondMeta.lastWithdrawn = block.timestamp;
        } else {
            YieldAccumulator storage yA =
                getUpdatedHourlyYield(issuer, bondMeta);
            yA.hourlyYieldFP = (FP32 * (100 + aprPercent)) / 100 / (24 * 365);
        }
    }

    function setMaxHourlyYieldFP(uint256 maxYieldFP) external onlyOwnerExec {

        maxHourlyYieldFP = maxYieldFP;
    }

    function setYieldChangePerSecondFP(uint256 changePerSecondFP)
        external
        onlyOwnerExec
    {

        yieldChangePerSecondFP = changePerSecondFP;
    }

    function setRuntimeYieldsFP(address issuer, uint256[] memory yieldsFP)
        external
        onlyOwnerExec
    {

        BondBucketMetadata[] storage bondMetas = bondBucketMetadata[issuer];
        for (uint256 i; bondMetas.length > i; i++) {
            bondMetas[i].runtimeYieldFP = yieldsFP[i];
        }
    }

    function setMinRuntime(uint256 runtime) external onlyOwnerExec {

        require(runtime > 1 hours, "Min runtime > 1 hour");
        require(maxRuntime > runtime, "Runtime too long");
        minRuntime = runtime;
    }

    function setMaxRuntime(uint256 runtime) external onlyOwnerExec {

        require(runtime > minRuntime, "Max > min runtime");
        maxRuntime = runtime;
    }

    function setRuntimeWeights(address issuer, uint256[] memory weights)
        external
        onlyOwnerExecActivator
    {

        BondBucketMetadata[] storage bondMetas = bondBucketMetadata[issuer];

        if (bondMetas.length == 0) {

            uint256 hourlyYieldFP = (110 * FP32) / 100 / (24 * 365);
            uint256 bucketSize = diffMaxMinRuntime / weights.length;

            for (uint256 i; weights.length > i; i++) {
                uint256 runtime = minRuntime + bucketSize * i;
                bondMetas.push(
                    BondBucketMetadata({
                        runtimeYieldFP: (hourlyYieldFP * runtime) / (1 hours),
                        lastBought: block.timestamp,
                        lastWithdrawn: block.timestamp,
                        yieldLastUpdated: block.timestamp,
                        buyingSpeed: 1,
                        withdrawingSpeed: 1,
                        runtimeWeight: weights[i],
                        totalLending: 0
                    })
                );
            }
        } else {
            require(weights.length == bondMetas.length, "Weights don't match");
            for (uint256 i; weights.length > i; i++) {
                bondMetas[i].runtimeWeight = weights[i];
            }
        }
    }

    function applyBorrowInterest(
        uint256 balance,
        address issuer,
        uint256 yieldQuotientFP
    ) external returns (uint256 balanceWithInterest, uint256 accumulatorFP) {

        require(isBorrower(msg.sender), "Not approved call");

        YieldAccumulator storage yA = borrowYieldAccumulators[issuer];
        updateBorrowYieldAccu(yA);
        accumulatorFP = yA.accumulatorFP;

        balanceWithInterest = applyInterest(
            balance,
            accumulatorFP,
            yieldQuotientFP
        );

        uint256 deltaAmount = balanceWithInterest - balance;
        LendingMetadata storage meta = lendingMeta[issuer];
        meta.totalBorrowed += deltaAmount;
    }

    function viewWithBorrowInterest(
        uint256 balance,
        address issuer,
        uint256 yieldQuotientFP
    ) external view returns (uint256) {

        uint256 accumulatorFP =
            viewCumulativeYieldFP(
                borrowYieldAccumulators[issuer],
                block.timestamp
            );
        return applyInterest(balance, accumulatorFP, yieldQuotientFP);
    }

    function registerBorrow(address issuer, uint256 amount) external {

        require(isBorrower(msg.sender), "Not approved borrower");
        require(activeIssuers[issuer], "Not approved issuer");

        LendingMetadata storage meta = lendingMeta[issuer];
        meta.totalBorrowed += amount;
        require(
            meta.totalLending >= meta.totalBorrowed,
            "Insufficient lending"
        );
    }

    function payOff(address issuer, uint256 amount) external {

        require(isBorrower(msg.sender), "Not approved borrower");
        lendingMeta[issuer].totalBorrowed -= amount;
    }

    function viewAccumulatedBorrowingYieldFP(address issuer)
        external
        view
        returns (uint256)
    {

        YieldAccumulator storage yA = borrowYieldAccumulators[issuer];
        return viewCumulativeYieldFP(yA, block.timestamp);
    }

    function viewAPRPer10k(YieldAccumulator storage yA)
        internal
        view
        returns (uint256)
    {

        uint256 hourlyYieldFP = yA.hourlyYieldFP;

        uint256 aprFP =
            ((hourlyYieldFP * 10_000 - FP32 * 10_000) * 365 days) / (1 hours);

        return aprFP / FP32;
    }

    function viewBorrowAPRPer10k(address issuer)
        external
        view
        returns (uint256)
    {

        return viewAPRPer10k(borrowYieldAccumulators[issuer]);
    }

    function viewHourlyBondAPRPer10k(address issuer)
        external
        view
        returns (uint256)
    {

        return viewAPRPer10k(hourlyBondMetadata[issuer].yieldAccumulator);
    }

    function _makeFallbackBond(
        address issuer,
        address holder,
        uint256 amount
    ) internal override {

        _makeHourlyBond(issuer, holder, amount);
    }

    function withdrawHourlyBond(address issuer, uint256 amount) external {

        HourlyBond storage bond = hourlyBondAccounts[issuer][msg.sender];
        updateHourlyBondAmount(issuer, bond);
        super._withdrawHourlyBond(issuer, bond, amount);

        if (bond.amount == 0) {
            delete hourlyBondAccounts[issuer][msg.sender];
        }

        disburse(issuer, msg.sender, amount);

        withdrawClaim(msg.sender, issuer, amount);
    }

    function closeHourlyBondAccount(address issuer) external {

        HourlyBond storage bond = hourlyBondAccounts[issuer][msg.sender];
        updateHourlyBondAmount(issuer, bond);

        uint256 amount = bond.amount;
        super._withdrawHourlyBond(issuer, bond, amount);

        disburse(issuer, msg.sender, amount);

        delete hourlyBondAccounts[issuer][msg.sender];

        withdrawClaim(msg.sender, issuer, amount);
    }

    function buyHourlyBondSubscription(address issuer, uint256 amount)
        external
    {

        require(activeIssuers[issuer], "Not approved issuer");

        LendingMetadata storage meta = lendingMeta[issuer];
        if (lendingTarget(meta) >= meta.totalLending + amount) {
            collectToken(issuer, msg.sender, amount);

            super._makeHourlyBond(issuer, msg.sender, amount);

            stakeClaim(msg.sender, issuer, amount);
        }
    }

    function buyBond(
        address issuer,
        uint256 runtime,
        uint256 amount,
        uint256 minReturn
    ) external returns (uint256 bondIndex) {

        require(activeIssuers[issuer], "Not approved issuer");

        LendingMetadata storage meta = lendingMeta[issuer];
        if (
            lendingTarget(meta) >= meta.totalLending + amount &&
            maxRuntime >= runtime &&
            runtime >= minRuntime
        ) {
            bondIndex = super._makeBond(
                msg.sender,
                issuer,
                runtime,
                amount,
                minReturn
            );
            if (bondIndex > 0) {
                bondIds[msg.sender].push(bondIndex);

                collectToken(issuer, msg.sender, amount);
                stakeClaim(msg.sender, issuer, amount);
            }
        }
    }

    function withdrawBond(uint256 bondId) external {

        Bond storage bond = bonds[bondId];
        require(msg.sender == bond.holder, "Not bond holder");
        require(
            block.timestamp > bond.maturityTimestamp,
            "bond is still immature"
        );
        withdrawClaim(msg.sender, bond.issuer, bond.originalPrice);

        uint256 withdrawAmount = super._withdrawBond(bondId, bond);
        disburse(bond.issuer, msg.sender, withdrawAmount);
    }

    function initBorrowYieldAccumulator(address issuer)
        external
        onlyOwnerExecActivator
    {

        YieldAccumulator storage yA = borrowYieldAccumulators[issuer];
        require(yA.accumulatorFP == 0, "don't re-initialize");

        yA.accumulatorFP = FP32;
        yA.lastUpdated = block.timestamp;
        yA.hourlyYieldFP = FP32 + FP32 / (365 * 24);
    }

    function setBorrowingFactorPercent(uint256 borrowingFactor)
        external
        onlyOwnerExec
    {

        borrowingFactorPercent = borrowingFactor;
    }

    function issuanceBalance(address issuer)
        internal
        view
        override
        returns (uint256)
    {

        address token = issuerTokens[issuer];
        if (token == issuer) {
            return IERC20(token).balanceOf(fund());
        } else {
            return lendingMeta[issuer].totalLending - haircuts[issuer];
        }
    }

    function disburse(
        address issuer,
        address recipient,
        uint256 amount
    ) internal {

        uint256 haircutAmount = haircuts[issuer];
        if (haircutAmount > 0 && amount > 0) {
            uint256 totalLending = lendingMeta[issuer].totalLending;
            uint256 adjustment =
                (amount * min(totalLending, haircutAmount)) / totalLending;
            amount = amount - adjustment;
            haircuts[issuer] -= adjustment;
        }

        address token = issuerTokens[issuer];
        Fund(fund()).withdraw(token, recipient, amount);
    }

    function collectToken(
        address issuer,
        address source,
        uint256 amount
    ) internal {

        Fund(fund()).depositFor(source, issuer, amount);
    }

    function haircut(uint256 amount) external {

        haircuts[msg.sender] += amount;
    }
}