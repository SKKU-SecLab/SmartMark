
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
uint256 constant LENDER = 11;

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

    function isLender(address contr) internal view returns (bool) {

        return roleCache[contr][LENDER];
    }
}// BUSL-1.1
pragma solidity ^0.8.0;

abstract contract BaseLending {
    uint256 constant FP48 = 2**48;
    uint256 constant ACCUMULATOR_INIT = 10**18;

    uint256 constant hoursPerYear = 365 days / (1 hours);
    uint256 constant CHANGE_POINT = 82;
    uint256 public normalRatePerPercent =
        (FP48 * 12) / hoursPerYear / CHANGE_POINT / 100;
    uint256 public highRatePerPercent =
        (FP48 * (135 - 12)) / hoursPerYear / (100 - CHANGE_POINT) / 100;

    struct YieldAccumulator {
        uint256 accumulatorFP;
        uint256 lastUpdated;
        uint256 hourlyYieldFP;
    }

    struct LendingMetadata {
        uint256 totalLending;
        uint256 totalBorrowed;
        uint256 lendingCap;
        uint256 cumulIncentiveAllocationFP;
        uint256 incentiveLastUpdated;
        uint256 incentiveEnd;
        uint256 incentiveTarget;
    }
    mapping(address => LendingMetadata) public lendingMeta;

    mapping(address => YieldAccumulator) public borrowYieldAccumulators;

    function applyInterest(
        uint256 balance,
        uint256 accumulatorFP,
        uint256 yieldQuotientFP
    ) internal pure returns (uint256) {
        return (balance * accumulatorFP) / yieldQuotientFP;
    }

    function currentLendingRateFP(uint256 totalLending, uint256 totalBorrowing)
        internal
        view
        returns (uint256 rate)
    {
        rate = FP48;
        uint256 utilizationPercent =
            totalLending > 0 ? (100 * totalBorrowing) / totalLending : 0;
        if (utilizationPercent < CHANGE_POINT) {
            rate += utilizationPercent * normalRatePerPercent;
        } else {
            rate +=
                CHANGE_POINT *
                normalRatePerPercent +
                (utilizationPercent - CHANGE_POINT) *
                highRatePerPercent;
        }
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

    function issuanceBalance(address issuance)
        internal
        view
        virtual
        returns (uint256);
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
    uint256 incentiveAllocationStart;
}

abstract contract HourlyBondSubscriptionLending is BaseLending {
    mapping(address => YieldAccumulator) hourlyBondYieldAccumulators;

    uint256 constant RATE_UPDATE_WINDOW = 10 minutes;
    uint256 public withdrawalWindow = 20 minutes;
    uint256 constant MAX_HOUR_UPDATE = 4;
    mapping(address => mapping(address => HourlyBond))
        public hourlyBondAccounts;

    uint256 public borrowingFactorPercent = 200;

    uint256 constant borrowMinAPR = 25;
    uint256 constant borrowMinHourlyYield =
        FP48 + (borrowMinAPR * FP48) / 1000 / hoursPerYear;

    function _makeHourlyBond(
        address issuer,
        address holder,
        uint256 amount
    ) internal {
        HourlyBond storage bond = hourlyBondAccounts[issuer][holder];
        LendingMetadata storage meta = lendingMeta[issuer];
        addToTotalLending(meta, amount);
        updateHourlyBondAmount(issuer, bond, holder);

        if (bond.amount == 0) {
            bond.moduloHour = block.timestamp % (1 hours);
        }
        bond.amount += amount;
    }

    function updateHourlyBondAmount(
        address issuer,
        HourlyBond storage bond,
        address holder
    ) internal {
        uint256 yieldQuotientFP = bond.yieldQuotientFP;

        YieldAccumulator storage yA =
            getUpdatedHourlyYield(
                issuer,
                hourlyBondYieldAccumulators[issuer],
                RATE_UPDATE_WINDOW
            );

        LendingMetadata storage meta = lendingMeta[issuer];

        if (yieldQuotientFP > 0) {
            disburseIncentive(bond, meta, holder);
            uint256 oldAmount = bond.amount;

            bond.amount = applyInterest(
                bond.amount,
                yA.accumulatorFP,
                yieldQuotientFP
            );

            uint256 deltaAmount = bond.amount - oldAmount;
            addToTotalLending(meta, deltaAmount);
        } else {
            bond.incentiveAllocationStart = meta.cumulIncentiveAllocationFP;
        }
        bond.yieldQuotientFP = yA.accumulatorFP;
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
                hourlyBondYieldAccumulators[issuer],
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
        uint256 amount,
        address holder
    ) internal {
        subtractFromTotalLending(lendingMeta[issuer], amount);
        updateHourlyBondAmount(issuer, bond, holder);

        uint256 currentOffset = (block.timestamp - bond.moduloHour) % (1 hours);

        require(
            withdrawalWindow >= currentOffset,
            "Tried withdrawing outside subscription cancellation time window"
        );

        bond.amount -= amount;
    }

    function calcCumulativeYieldFP(
        YieldAccumulator storage yieldAccumulator,
        uint256 timeDelta
    ) internal view returns (uint256 accumulatorFP) {
        uint256 secondsDelta = timeDelta % (1 hours);
        accumulatorFP =
            yieldAccumulator.accumulatorFP +
            (yieldAccumulator.accumulatorFP *
                (yieldAccumulator.hourlyYieldFP - FP48) *
                secondsDelta) /
            (FP48 * 1 hours);

        uint256 hoursDelta = timeDelta / (1 hours);
        if (hoursDelta > 0) {
            uint256 accumulatorBeforeFP = accumulatorFP;
            for (uint256 i = 0; hoursDelta > i && MAX_HOUR_UPDATE > i; i++) {
                accumulatorFP =
                    (accumulatorFP * yieldAccumulator.hourlyYieldFP) /
                    FP48;
            }

            if (hoursDelta > MAX_HOUR_UPDATE) {
                accumulatorFP +=
                    ((accumulatorFP - accumulatorBeforeFP) *
                        (hoursDelta - MAX_HOUR_UPDATE)) /
                    MAX_HOUR_UPDATE;
            }
        }
    }

    function updateHourlyYield(address issuer)
        public
        returns (uint256 hourlyYield)
    {
        return
            getUpdatedHourlyYield(
                issuer,
                hourlyBondYieldAccumulators[issuer],
                RATE_UPDATE_WINDOW
            )
                .hourlyYieldFP;
    }

    function getUpdatedHourlyYield(
        address issuer,
        YieldAccumulator storage accumulator,
        uint256 window
    ) internal returns (YieldAccumulator storage) {
        uint256 lastUpdated = accumulator.lastUpdated;
        uint256 timeDelta = (block.timestamp - lastUpdated);

        if (timeDelta > window) {
            YieldAccumulator storage borrowAccumulator =
                borrowYieldAccumulators[issuer];

            accumulator.accumulatorFP = calcCumulativeYieldFP(
                accumulator,
                timeDelta
            );

            LendingMetadata storage meta = lendingMeta[issuer];

            accumulator.hourlyYieldFP = currentLendingRateFP(
                meta.totalLending,
                meta.totalBorrowed
            );
            accumulator.lastUpdated = block.timestamp;

            updateBorrowYieldAccu(borrowAccumulator);

            borrowAccumulator.hourlyYieldFP = max(
                borrowMinHourlyYield,
                FP48 +
                    (borrowingFactorPercent *
                        (accumulator.hourlyYieldFP - FP48)) /
                    100
            );
        }

        return accumulator;
    }

    function updateBorrowYieldAccu(YieldAccumulator storage borrowAccumulator)
        internal
    {
        uint256 timeDelta = block.timestamp - borrowAccumulator.lastUpdated;

        if (timeDelta > RATE_UPDATE_WINDOW) {
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
        if (timeDelta > RATE_UPDATE_WINDOW) {
            return calcCumulativeYieldFP(yA, timeDelta);
        } else {
            return yA.accumulatorFP;
        }
    }

    function viewYearlyIncentivePer10k(address token)
        external
        view
        returns (uint256)
    {
        LendingMetadata storage meta = lendingMeta[token];
        if (
            meta.incentiveEnd < block.timestamp ||
            meta.incentiveLastUpdated > meta.incentiveEnd
        ) {
            return 0;
        } else {
            uint256 timeDelta = meta.incentiveEnd - meta.incentiveLastUpdated;

            return
                (10_000 * (365 days) * meta.incentiveTarget) /
                (1 + meta.totalLending * timeDelta);
        }
    }

    function updateIncentiveAllocation(LendingMetadata storage meta) internal {
        uint256 endTime = min(meta.incentiveEnd, block.timestamp);
        if (meta.incentiveTarget > 0 && endTime > meta.incentiveLastUpdated) {
            uint256 timeDelta = endTime - meta.incentiveLastUpdated;
            uint256 targetDelta =
                min(
                    meta.incentiveTarget,
                    (timeDelta * meta.incentiveTarget) /
                        (meta.incentiveEnd - meta.incentiveLastUpdated)
                );
            meta.incentiveTarget -= targetDelta;
            meta.cumulIncentiveAllocationFP +=
                (targetDelta * FP48) /
                (1 + meta.totalLending);
            meta.incentiveLastUpdated = block.timestamp;
        }
    }

    function addToTotalLending(LendingMetadata storage meta, uint256 amount)
        internal
    {
        updateIncentiveAllocation(meta);
        meta.totalLending += amount;
    }

    function subtractFromTotalLending(
        LendingMetadata storage meta,
        uint256 amount
    ) internal {
        updateIncentiveAllocation(meta);
        meta.totalLending -= amount;
    }

    function disburseIncentive(
        HourlyBond storage bond,
        LendingMetadata storage meta,
        address holder
    ) internal virtual;
}library IncentiveReporter {
    event AddToClaim(address topic, address indexed claimant, uint256 amount);
    event SubtractFromClaim(
        address topic,
        address indexed claimant,
        uint256 amount
    );

    function addToClaimAmount(
        address topic,
        address recipient,
        uint256 claimAmount
    ) internal {
        emit AddToClaim(topic, recipient, claimAmount);
    }

    function subtractFromClaimAmount(
        address topic,
        address recipient,
        uint256 subtractAmount
    ) internal {
        emit SubtractFromClaim(topic, recipient, subtractAmount);
    }
}// BUSL-1.1
pragma solidity ^0.8.0;



contract Lending is RoleAware, HourlyBondSubscriptionLending {

    mapping(address => address) public issuerTokens;

    mapping(address => uint256) public haircuts;

    mapping(address => bool) public activeIssuers;

    uint256 constant BORROW_RATE_UPDATE_WINDOW = 60 minutes;

    address public immutable MFI;

    constructor(address _MFI, address _roles) RoleAware(_roles) {
        MFI = _MFI;
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

    function setWithdrawalWindow(uint256 window) external onlyOwnerExec {

        withdrawalWindow = window;
    }

    function setNormalRatePerPercent(uint256 rate) external onlyOwnerExec {

        normalRatePerPercent = rate;
    }

    function setHighRatePerPercent(uint256 rate) external onlyOwnerExec {

        highRatePerPercent = rate;
    }

    function setHourlyYieldAPR(address issuer, uint256 aprPercent)
        external
        onlyOwnerExecActivator
    {

        YieldAccumulator storage yieldAccumulator =
            hourlyBondYieldAccumulators[issuer];

        if (yieldAccumulator.accumulatorFP == 0) {
            uint256 yieldFP = FP48 + (FP48 * aprPercent) / 100 / (24 * 365);
            hourlyBondYieldAccumulators[issuer] = YieldAccumulator({
                accumulatorFP: FP48,
                lastUpdated: block.timestamp,
                hourlyYieldFP: yieldFP
            });
        } else {
            YieldAccumulator storage yA =
                getUpdatedHourlyYield(
                    issuer,
                    yieldAccumulator,
                    RATE_UPDATE_WINDOW
                );
            yA.hourlyYieldFP = (FP48 * (100 + aprPercent)) / 100 / (24 * 365);
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

        getUpdatedHourlyYield(
            issuer,
            hourlyBondYieldAccumulators[issuer],
            BORROW_RATE_UPDATE_WINDOW
        );

        require(
            meta.totalLending >= meta.totalBorrowed,
            "Insufficient lending"
        );
    }

    function registerLend(address issuer, uint256 amount) external {

        require(isLender(msg.sender), "Not an approved lender");
        require(activeIssuers[issuer], "Not approved issuer");
        LendingMetadata storage meta = lendingMeta[issuer];
        addToTotalLending(meta, amount);

        getUpdatedHourlyYield(
            issuer,
            hourlyBondYieldAccumulators[issuer],
            RATE_UPDATE_WINDOW
        );
    }

    function registerWithdrawal(address issuer, uint256 amount) external {

        require(isLender(msg.sender), "Not an approved lender");
        require(activeIssuers[issuer], "Not approved issuer");
        LendingMetadata storage meta = lendingMeta[issuer];
        subtractFromTotalLending(meta, amount);

        getUpdatedHourlyYield(
            issuer,
            hourlyBondYieldAccumulators[issuer],
            RATE_UPDATE_WINDOW
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
            ((hourlyYieldFP * 10_000 - FP48 * 10_000) * 365 days) / (1 hours);

        return aprFP / FP48;
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

        return viewAPRPer10k(hourlyBondYieldAccumulators[issuer]);
    }

    function makeFallbackBond(
        address issuer,
        address holder,
        uint256 amount
    ) external {

        require(isLender(msg.sender), "Not an approved lender");
        _makeHourlyBond(issuer, holder, amount);
    }

    function withdrawHourlyBond(address issuer, uint256 amount) external {

        HourlyBond storage bond = hourlyBondAccounts[issuer][msg.sender];
        super._withdrawHourlyBond(issuer, bond, amount, msg.sender);

        if (bond.amount == 0) {
            delete hourlyBondAccounts[issuer][msg.sender];
        }

        disburse(issuer, msg.sender, amount);

        IncentiveReporter.subtractFromClaimAmount(issuer, msg.sender, amount);
    }

    function closeHourlyBondAccount(address issuer) external {

        HourlyBond storage bond = hourlyBondAccounts[issuer][msg.sender];

        uint256 amount = bond.amount;
        super._withdrawHourlyBond(issuer, bond, amount, msg.sender);

        disburse(issuer, msg.sender, amount);

        delete hourlyBondAccounts[issuer][msg.sender];

        IncentiveReporter.subtractFromClaimAmount(issuer, msg.sender, amount);
    }

    function buyHourlyBondSubscription(address issuer, uint256 amount)
        external
    {

        require(activeIssuers[issuer], "Not approved issuer");

        collectToken(issuer, msg.sender, amount);

        super._makeHourlyBond(issuer, msg.sender, amount);

        IncentiveReporter.addToClaimAmount(issuer, msg.sender, amount);
    }

    function initBorrowYieldAccumulator(address issuer)
        external
        onlyOwnerExecActivator
    {

        YieldAccumulator storage yA = borrowYieldAccumulators[issuer];
        require(yA.accumulatorFP == 0, "don't re-initialize");

        yA.accumulatorFP = FP48;
        yA.lastUpdated = block.timestamp;
        yA.hourlyYieldFP = FP48 + (FP48 * borrowMinAPR) / 1000 / (365 * 24);
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

        Fund(fund()).depositFor(source, issuerTokens[issuer], amount);
    }

    function haircut(uint256 amount) external {

        haircuts[msg.sender] += amount;
    }

    function addIncentive(
        address token,
        uint256 amount,
        uint256 endTimestamp
    ) external onlyOwnerExecActivator {

        LendingMetadata storage meta = lendingMeta[token];
        meta.incentiveEnd = endTimestamp;
        meta.incentiveTarget = amount;
        meta.incentiveLastUpdated = block.timestamp;
    }

    function disburseIncentive(
        HourlyBond storage bond,
        LendingMetadata storage meta,
        address holder
    ) internal override {

        uint256 allocationDelta =
            meta.cumulIncentiveAllocationFP - bond.incentiveAllocationStart;
        if (allocationDelta > 0) {
            uint256 disburseAmount = (allocationDelta * bond.amount) / FP48;
            Fund(fund()).withdraw(MFI, holder, disburseAmount);
            bond.incentiveAllocationStart += allocationDelta;
        }
    }

    function withdrawIncentive(address token) external {

        LendingMetadata storage meta = lendingMeta[token];
        updateIncentiveAllocation(meta);
        disburseIncentive(
            hourlyBondAccounts[token][msg.sender],
            meta,
            msg.sender
        );
    }
}