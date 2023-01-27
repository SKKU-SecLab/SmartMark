
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
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

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
}// BUSL-1.1
pragma solidity ^0.8.0;

interface IMarginTrading {

    function registerDeposit(
        address trader,
        address token,
        uint256 amount
    ) external returns (uint256 extinguishAmount);


    function registerWithdrawal(
        address trader,
        address token,
        uint256 amount
    ) external;


    function registerBorrow(
        address trader,
        address token,
        uint256 amount
    ) external;


    function registerTradeAndBorrow(
        address trader,
        address inToken,
        address outToken,
        uint256 inAmount,
        uint256 outAmount
    ) external returns (uint256 extinguishAmount, uint256 borrowAmount);


    function registerOvercollateralizedBorrow(
        address trader,
        address depositToken,
        uint256 depositAmount,
        address borrowToken,
        uint256 withdrawAmount
    ) external;


    function registerLiquidation(address trader) external;


    function getHoldingAmounts(address trader)
        external
        view
        returns (
            address[] memory holdingTokens,
            uint256[] memory holdingAmounts
        );


    function getBorrowAmounts(address trader)
        external
        view
        returns (address[] memory borrowTokens, uint256[] memory borrowAmounts);

}pragma solidity >=0.5.0;


library UniswapStyleLib {

    address constant UNISWAP_FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant SUSHI_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {

        require(tokenA != tokenB, "Identical address!");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "Zero address!");
    }

    function getReserves(
        address pair,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) =
            IUniswapV2Pair(pair).getReserves();

        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1_000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, "INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn * amountOut * 1_000;

        uint256 denominator = (reserveOut - amountOut) - 997;
        amountIn = (numerator / denominator) + 1;
    }

    function getAmountsOut(
        uint256 amountIn,
        bytes32 amms,
        address[] memory tokens
    ) internal view returns (uint256[] memory amounts, address[] memory pairs) {

        require(tokens.length >= 2, "token path too short");

        amounts = new uint256[](tokens.length);
        amounts[0] = amountIn;

        pairs = new address[](tokens.length - 1);

        for (uint256 i; i < tokens.length - 1; i++) {
            address inToken = tokens[i];
            address outToken = tokens[i + 1];

            address pair =
                amms[i] == 0
                    ? pairForUni(inToken, outToken)
                    : pairForSushi(inToken, outToken);
            pairs[i] = pair;

            (uint256 reserveIn, uint256 reserveOut) =
                getReserves(pair, inToken, outToken);

            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(
        uint256 amountOut,
        bytes32 amms,
        address[] memory tokens
    ) internal view returns (uint256[] memory amounts, address[] memory pairs) {

        require(tokens.length >= 2, "token path too short");

        amounts = new uint256[](tokens.length);
        amounts[amounts.length - 1] = amountOut;

        pairs = new address[](tokens.length - 1);

        for (uint256 i = tokens.length - 1; i > 0; i--) {
            address inToken = tokens[i - 1];
            address outToken = tokens[i];

            address pair =
                amms[i - 1] == 0
                    ? pairForUni(inToken, outToken)
                    : pairForSushi(inToken, outToken);
            pairs[i - 1] = pair;

            (uint256 reserveIn, uint256 reserveOut) =
                getReserves(pair, inToken, outToken);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function pairForUni(address tokenA, address tokenB)
        internal
        pure
        returns (address pair)
    {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            UNISWAP_FACTORY,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                        )
                    )
                )
            )
        );
    }

    function pairForSushi(address tokenA, address tokenB)
        internal
        pure
        returns (address pair)
    {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            SUSHI_FACTORY,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303" // init code hash
                        )
                    )
                )
            )
        );
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


abstract contract BaseRouter {
    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "Trade has expired");
        _;
    }

    function _swap(
        uint256[] memory amounts,
        address[] memory pairs,
        address[] memory tokens,
        address _to
    ) internal {
        for (uint256 i; i < pairs.length; i++) {
            (address input, address output) = (tokens[i], tokens[i + 1]);
            (address token0, ) = UniswapStyleLib.sortTokens(input, output);

            uint256 amountOut = amounts[i + 1];

            (uint256 amount0Out, uint256 amount1Out) =
                input == token0
                    ? (uint256(0), amountOut)
                    : (amountOut, uint256(0));

            address to = i < pairs.length - 1 ? pairs[i + 1] : _to;
            IUniswapV2Pair pair = IUniswapV2Pair(pairs[i]);

            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;



contract MarginRouter is RoleAware, IncentivizedHolder, BaseRouter {

    event AccountUpdated(address indexed trader);

    uint256 public constant mswapFeesPer10k = 10;
    address public immutable WETH;

    constructor(address _WETH, address _roles) RoleAware(_roles) {
        WETH = _WETH;
    }


    function crossDeposit(address depositToken, uint256 depositAmount)
        external
    {

        Fund(fund()).depositFor(msg.sender, depositToken, depositAmount);

        uint256 extinguishAmount =
            IMarginTrading(crossMarginTrading()).registerDeposit(
                msg.sender,
                depositToken,
                depositAmount
            );
        if (extinguishAmount > 0) {
            Lending(lending()).payOff(depositToken, extinguishAmount);
            withdrawClaim(msg.sender, depositToken, extinguishAmount);
        }
        emit AccountUpdated(msg.sender);
    }

    function crossDepositETH() external payable {

        Fund(fund()).depositToWETH{value: msg.value}();
        uint256 extinguishAmount =
            IMarginTrading(crossMarginTrading()).registerDeposit(
                msg.sender,
                WETH,
                msg.value
            );
        if (extinguishAmount > 0) {
            Lending(lending()).payOff(WETH, extinguishAmount);
            withdrawClaim(msg.sender, WETH, extinguishAmount);
        }
        emit AccountUpdated(msg.sender);
    }

    function crossWithdraw(address withdrawToken, uint256 withdrawAmount)
        external
    {

        IMarginTrading(crossMarginTrading()).registerWithdrawal(
            msg.sender,
            withdrawToken,
            withdrawAmount
        );
        Fund(fund()).withdraw(withdrawToken, msg.sender, withdrawAmount);
        emit AccountUpdated(msg.sender);
    }

    function crossWithdrawETH(uint256 withdrawAmount) external {

        IMarginTrading(crossMarginTrading()).registerWithdrawal(
            msg.sender,
            WETH,
            withdrawAmount
        );
        Fund(fund()).withdrawETH(msg.sender, withdrawAmount);
        emit AccountUpdated(msg.sender);
    }

    function crossBorrow(address borrowToken, uint256 borrowAmount) external {

        Lending(lending()).registerBorrow(borrowToken, borrowAmount);
        IMarginTrading(crossMarginTrading()).registerBorrow(
            msg.sender,
            borrowToken,
            borrowAmount
        );

        stakeClaim(msg.sender, borrowToken, borrowAmount);
        emit AccountUpdated(msg.sender);
    }

    function crossOvercollateralizedBorrow(
        address depositToken,
        uint256 depositAmount,
        address borrowToken,
        uint256 withdrawAmount
    ) external {

        Fund(fund()).depositFor(msg.sender, depositToken, depositAmount);

        Lending(lending()).registerBorrow(borrowToken, withdrawAmount);
        IMarginTrading(crossMarginTrading()).registerOvercollateralizedBorrow(
            msg.sender,
            depositToken,
            depositAmount,
            borrowToken,
            withdrawAmount
        );

        Fund(fund()).withdraw(borrowToken, msg.sender, withdrawAmount);
        stakeClaim(msg.sender, borrowToken, withdrawAmount);
        emit AccountUpdated(msg.sender);
    }

    function crossCloseAccount() external {

        (address[] memory holdingTokens, uint256[] memory holdingAmounts) =
            IMarginTrading(crossMarginTrading()).getHoldingAmounts(msg.sender);

        IMarginTrading(crossMarginTrading()).registerLiquidation(msg.sender);

        for (uint256 i; holdingTokens.length > i; i++) {
            Fund(fund()).withdraw(
                holdingTokens[i],
                msg.sender,
                holdingAmounts[i]
            );
        }

        emit AccountUpdated(msg.sender);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        bytes32 amms,
        address[] calldata tokens,
        uint256 deadline
    ) external ensure(deadline) returns (uint256[] memory amounts) {

        uint256 fees = takeFeesFromInput(amountIn);

        address[] memory pairs;
        (amounts, pairs) = UniswapStyleLib.getAmountsOut(
            amountIn - fees,
            amms,
            tokens
        );

        registerTrade(
            msg.sender,
            tokens[0],
            tokens[tokens.length - 1],
            amountIn,
            amounts[amounts.length - 1]
        );

        _fundSwapExactT4T(amounts, amountOutMin, pairs, tokens);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        bytes32 amms,
        address[] calldata tokens,
        uint256 deadline
    ) external ensure(deadline) returns (uint256[] memory amounts) {

        address[] memory pairs;
        (amounts, pairs) = UniswapStyleLib.getAmountsIn(
            amountOut + takeFeesFromOutput(amountOut),
            amms,
            tokens
        );

        registerTrade(
            msg.sender,
            tokens[0],
            tokens[tokens.length - 1],
            amounts[0],
            amountOut
        );

        _fundSwapT4ExactT(amounts, amountInMax, pairs, tokens);
    }

    function registerTrade(
        address trader,
        address inToken,
        address outToken,
        uint256 inAmount,
        uint256 outAmount
    ) internal {

        (uint256 extinguishAmount, uint256 borrowAmount) =
            IMarginTrading(crossMarginTrading()).registerTradeAndBorrow(
                trader,
                inToken,
                outToken,
                inAmount,
                outAmount
            );
        if (extinguishAmount > 0) {
            Lending(lending()).payOff(outToken, extinguishAmount);
            withdrawClaim(trader, outToken, extinguishAmount);
        }
        if (borrowAmount > 0) {
            Lending(lending()).registerBorrow(inToken, borrowAmount);
            stakeClaim(trader, inToken, borrowAmount);
        }

        emit AccountUpdated(trader);
    }


    function _fundSwapExactT4T(
        uint256[] memory amounts,
        uint256 amountOutMin,
        address[] memory pairs,
        address[] calldata tokens
    ) internal {

        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "MarginRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        Fund(fund()).withdraw(tokens[0], pairs[0], amounts[0]);
        _swap(amounts, pairs, tokens, fund());
    }

    function authorizedSwapExactT4T(
        uint256 amountIn,
        uint256 amountOutMin,
        bytes32 amms,
        address[] calldata tokens
    ) external returns (uint256[] memory amounts) {

        require(
            isAuthorizedFundTrader(msg.sender),
            "Calling contract is not authorized to trade with protocl funds"
        );
        address[] memory pairs;
        (amounts, pairs) = UniswapStyleLib.getAmountsOut(
            amountIn,
            amms,
            tokens
        );
        _fundSwapExactT4T(amounts, amountOutMin, pairs, tokens);
    }

    function _fundSwapT4ExactT(
        uint256[] memory amounts,
        uint256 amountInMax,
        address[] memory pairs,
        address[] calldata tokens
    ) internal {

        require(
            amounts[0] <= amountInMax,
            "MarginRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        Fund(fund()).withdraw(tokens[0], pairs[0], amounts[0]);
        _swap(amounts, pairs, tokens, fund());
    }

    function authorizedSwapT4ExactT(
        uint256 amountOut,
        uint256 amountInMax,
        bytes32 amms,
        address[] calldata tokens
    ) external returns (uint256[] memory amounts) {

        require(
            isAuthorizedFundTrader(msg.sender),
            "Calling contract is not authorized to trade with protocl funds"
        );

        address[] memory pairs;
        (amounts, pairs) = UniswapStyleLib.getAmountsIn(
            amountOut,
            amms,
            tokens
        );
        _fundSwapT4ExactT(amounts, amountInMax, pairs, tokens);
    }

    function takeFeesFromOutput(uint256 amount)
        internal
        pure
        returns (uint256 fees)
    {

        fees = (mswapFeesPer10k * amount) / 10_000;
    }

    function takeFeesFromInput(uint256 amount)
        internal
        pure
        returns (uint256 fees)
    {

        fees = (mswapFeesPer10k * amount) / (10_000 + mswapFeesPer10k);
    }

    function getAmountsOut(
        uint256 inAmount,
        bytes32 amms,
        address[] calldata tokens
    ) external view returns (uint256[] memory amounts) {

        (amounts, ) = UniswapStyleLib.getAmountsOut(inAmount, amms, tokens);
    }

    function getAmountsIn(
        uint256 outAmount,
        bytes32 amms,
        address[] calldata tokens
    ) external view returns (uint256[] memory amounts) {

        (amounts, ) = UniswapStyleLib.getAmountsIn(outAmount, amms, tokens);
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


struct TokenPrice {
    uint256 blockLastUpdated;
    uint256 tokenPerRefAmount;
    address[] liquidationTokens;
    bytes32 amms;
    address[] inverseLiquidationTokens;
    bytes32 inverseAmms;
}

struct VolatilitySetting {
    uint256 priceUpdateWindow;
    uint256 updateRatePermil;
}

abstract contract PriceAware is RoleAware {
    uint256 constant pegDecimals = 6;
    uint256 constant REFERENCE_PEG_AMOUNT = 100 * (10**pegDecimals);
    address public immutable peg;

    mapping(address => TokenPrice) public tokenPrices;

    uint256 public priceUpdateWindow = 20;
    uint256 public UPDATE_RATE_PERMIL = 50;
    VolatilitySetting[] public volatilitySettings;

    constructor(address _peg) {
        peg = _peg;
    }

    function setPriceUpdateWindow(uint16 window) external onlyOwnerExec {
        priceUpdateWindow = window;
    }

    function addVolatilitySetting(
        uint256 _priceUpdateWindow,
        uint256 _updateRatePermil
    ) external onlyOwnerExec {
        volatilitySettings.push(
            VolatilitySetting({
                priceUpdateWindow: _priceUpdateWindow,
                updateRatePermil: _updateRatePermil
            })
        );
    }

    function chooseVolatilitySetting(uint256 index)
        external
        onlyOwnerExecDisabler
    {
        VolatilitySetting storage vs = volatilitySettings[index];
        if (vs.updateRatePermil > 0) {
            UPDATE_RATE_PERMIL = vs.updateRatePermil;
            priceUpdateWindow = vs.priceUpdateWindow;
        }
    }

    function setUpdateRate(uint256 rate) external onlyOwnerExec {
        UPDATE_RATE_PERMIL = rate;
    }

    function getCurrentPriceInPeg(address token, uint256 inAmount)
        public
        returns (uint256)
    {
        if (token == peg) {
            return inAmount;
        } else {
            TokenPrice storage tokenPrice = tokenPrices[token];

            if (
                block.number - tokenPrice.blockLastUpdated >
                priceUpdateWindow ||
                tokenPrice.tokenPerRefAmount == 0
            ) {
                getPriceFromAMM(tokenPrice);
            }

            return
                (inAmount * REFERENCE_PEG_AMOUNT) /
                (tokenPrice.tokenPerRefAmount + 1);
        }
    }

    function viewCurrentPriceInPeg(address token, uint256 inAmount)
        public
        view
        returns (uint256)
    {
        if (token == peg) {
            return inAmount;
        } else {
            TokenPrice storage tokenPrice = tokenPrices[token];
            return
                (inAmount * REFERENCE_PEG_AMOUNT) /
                (tokenPrice.tokenPerRefAmount + 1);
        }
    }

    function getPriceFromAMM(TokenPrice storage tokenPrice) internal virtual {
        (uint256[] memory pathAmounts, ) =
            UniswapStyleLib.getAmountsIn(
                REFERENCE_PEG_AMOUNT,
                tokenPrice.amms,
                tokenPrice.liquidationTokens
            );
        _setPriceVal(tokenPrice, pathAmounts[0], UPDATE_RATE_PERMIL);
    }

    function _setPriceVal(
        TokenPrice storage tokenPrice,
        uint256 updatePerRefAmount,
        uint256 weightPerMil
    ) internal {
        tokenPrice.tokenPerRefAmount =
            (tokenPrice.tokenPerRefAmount *
                (1000 - weightPerMil) +
                updatePerRefAmount *
                weightPerMil) /
            1000;
    }

    function setLiquidationPath(bytes32 amms, address[] memory tokens)
        external
        onlyOwnerExecActivator
    {
        address token = tokens[0];

        if (token != peg) {
            TokenPrice storage tokenPrice = tokenPrices[token];

            tokenPrice.amms = amms;

            tokenPrice.liquidationTokens = tokens;
            tokenPrice.inverseLiquidationTokens = new address[](tokens.length);

            bytes32 inverseAmms;

            for (uint256 i = 0; tokens.length - 1 > i; i++) {
                bytes32 shifted =
                    bytes32(amms[i]) >> ((tokens.length - 2 - i) * 8);
                inverseAmms = inverseAmms | shifted;
            }

            tokenPrice.inverseAmms = inverseAmms;

            for (uint256 i = 0; tokens.length > i; i++) {
                tokenPrice.inverseLiquidationTokens[i] = tokens[
                    tokens.length - i - 1
                ];
            }

            (uint256[] memory pathAmounts, ) =
                UniswapStyleLib.getAmountsIn(
                    REFERENCE_PEG_AMOUNT,
                    amms,
                    tokens
                );
            uint256 inAmount = pathAmounts[0];

            _setPriceVal(tokenPrice, inAmount, 1000);
        }
    }

    function liquidateToPeg(address token, uint256 amount)
        internal
        returns (uint256)
    {
        if (token == peg) {
            return amount;
        } else {
            TokenPrice storage tP = tokenPrices[token];
            uint256[] memory amounts =
                MarginRouter(marginRouter()).authorizedSwapExactT4T(
                    amount,
                    0,
                    tP.amms,
                    tP.liquidationTokens
                );

            uint256 outAmount = amounts[amounts.length - 1];

            return outAmount;
        }
    }

    function liquidateFromPeg(address token, uint256 targetAmount)
        internal
        returns (uint256)
    {
        if (token == peg) {
            return targetAmount;
        } else {
            TokenPrice storage tP = tokenPrices[token];
            uint256[] memory amounts =
                MarginRouter(marginRouter()).authorizedSwapT4ExactT(
                    targetAmount,
                    type(uint256).max,
                    tP.amms,
                    tP.inverseLiquidationTokens
                );

            return amounts[0];
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;




struct CrossMarginAccount {
    uint256 lastDepositBlock;
    address[] borrowTokens;
    mapping(address => uint256) borrowed;
    mapping(address => uint256) borrowedYieldQuotientsFP;
    address[] holdingTokens;
    mapping(address => uint256) holdings;
    mapping(address => bool) holdsToken;
}

abstract contract CrossMarginAccounts is RoleAware, PriceAware {
    uint256 public leveragePercent = 300;

    uint256 public liquidationThresholdPercent = 115;

    mapping(address => CrossMarginAccount) internal marginAccounts;
    mapping(address => uint256) public tokenCaps;
    mapping(address => uint256) public totalShort;
    mapping(address => uint256) public totalLong;
    uint256 public coolingOffPeriod = 10;

    function addHolding(
        CrossMarginAccount storage account,
        address token,
        uint256 depositAmount
    ) internal {
        if (!hasHoldingToken(account, token)) {
            account.holdingTokens.push(token);
            account.holdsToken[token] = true;
        }

        account.holdings[token] += depositAmount;
    }

    function borrow(
        CrossMarginAccount storage account,
        address borrowToken,
        uint256 borrowAmount
    ) internal {
        if (!hasBorrowedToken(account, borrowToken)) {
            account.borrowTokens.push(borrowToken);
            account.borrowedYieldQuotientsFP[borrowToken] = Lending(lending())
                .getUpdatedBorrowYieldAccuFP(borrowToken);

            account.borrowed[borrowToken] = borrowAmount;
        } else {
            (uint256 oldBorrowed, uint256 accumulatorFP) =
                Lending(lending()).applyBorrowInterest(
                    account.borrowed[borrowToken],
                    borrowToken,
                    account.borrowedYieldQuotientsFP[borrowToken]
                );
            account.borrowedYieldQuotientsFP[borrowToken] = accumulatorFP;

            account.borrowed[borrowToken] = oldBorrowed + borrowAmount;
        }

        require(positiveBalance(account), "Insufficient balance");
    }

    function positiveBalance(CrossMarginAccount storage account)
        internal
        returns (bool)
    {
        uint256 loan = loanInPeg(account);
        uint256 holdings = holdingsInPeg(account);
        return holdings * (leveragePercent - 100) >= loan * leveragePercent;
    }

    function extinguishDebt(
        CrossMarginAccount storage account,
        address debtToken,
        uint256 extinguishAmount
    ) internal {
        (uint256 borrowAmount, uint256 newYieldQuot) =
            Lending(lending()).applyBorrowInterest(
                account.borrowed[debtToken],
                debtToken,
                account.borrowedYieldQuotientsFP[debtToken]
            );

        uint256 newBorrowAmount = borrowAmount - extinguishAmount;
        account.borrowed[debtToken] = newBorrowAmount;

        account.holdings[debtToken] =
            account.holdings[debtToken] -
            extinguishAmount;

        if (newBorrowAmount > 0) {
            account.borrowedYieldQuotientsFP[debtToken] = newYieldQuot;
        } else {
            delete account.borrowedYieldQuotientsFP[debtToken];

            bool decrement = false;
            uint256 len = account.borrowTokens.length;
            for (uint256 i; len > i; i++) {
                address currToken = account.borrowTokens[i];
                if (currToken == debtToken) {
                    decrement = true;
                } else if (decrement) {
                    account.borrowTokens[i - 1] = currToken;
                }
            }
            account.borrowTokens.pop();
        }
    }

    function hasHoldingToken(CrossMarginAccount storage account, address token)
        internal
        view
        returns (bool)
    {
        return account.holdsToken[token];
    }

    function hasBorrowedToken(CrossMarginAccount storage account, address token)
        internal
        view
        returns (bool)
    {
        return account.borrowedYieldQuotientsFP[token] > 0;
    }

    function loanInPeg(CrossMarginAccount storage account)
        internal
        returns (uint256)
    {
        return
            sumTokensInPegWithYield(
                account.borrowTokens,
                account.borrowed,
                account.borrowedYieldQuotientsFP
            );
    }

    function holdingsInPeg(CrossMarginAccount storage account)
        internal
        returns (uint256)
    {
        return sumTokensInPeg(account.holdingTokens, account.holdings);
    }

    function belowMaintenanceThreshold(CrossMarginAccount storage account)
        internal
        returns (bool)
    {
        uint256 loan = loanInPeg(account);
        uint256 holdings = holdingsInPeg(account);
        return 100 * holdings < liquidationThresholdPercent * loan;
    }

    function sumTokensInPeg(
        address[] storage tokens,
        mapping(address => uint256) storage amounts
    ) internal returns (uint256 totalPeg) {
        uint256 len = tokens.length;
        for (uint256 tokenId; tokenId < len; tokenId++) {
            address token = tokens[tokenId];
            totalPeg += PriceAware.getCurrentPriceInPeg(token, amounts[token]);
        }
    }

    function viewTokensInPeg(
        address[] storage tokens,
        mapping(address => uint256) storage amounts
    ) internal view returns (uint256 totalPeg) {
        uint256 len = tokens.length;
        for (uint256 tokenId; tokenId < len; tokenId++) {
            address token = tokens[tokenId];
            totalPeg += PriceAware.viewCurrentPriceInPeg(token, amounts[token]);
        }
    }

    function sumTokensInPegWithYield(
        address[] storage tokens,
        mapping(address => uint256) storage amounts,
        mapping(address => uint256) storage yieldQuotientsFP
    ) internal returns (uint256 totalPeg) {
        uint256 len = tokens.length;
        for (uint256 tokenId; tokenId < len; tokenId++) {
            address token = tokens[tokenId];
            totalPeg += yieldTokenInPeg(
                token,
                amounts[token],
                yieldQuotientsFP
            );
        }
    }

    function viewTokensInPegWithYield(
        address[] storage tokens,
        mapping(address => uint256) storage amounts,
        mapping(address => uint256) storage yieldQuotientsFP
    ) internal view returns (uint256 totalPeg) {
        uint256 len = tokens.length;
        for (uint256 tokenId; tokenId < len; tokenId++) {
            address token = tokens[tokenId];
            totalPeg += viewYieldTokenInPeg(
                token,
                amounts[token],
                yieldQuotientsFP
            );
        }
    }

    function yieldTokenInPeg(
        address token,
        uint256 amount,
        mapping(address => uint256) storage yieldQuotientsFP
    ) internal returns (uint256) {
        uint256 yieldFP =
            Lending(lending()).viewAccumulatedBorrowingYieldFP(token);
        uint256 amountInToken = (amount * yieldFP) / yieldQuotientsFP[token];
        return PriceAware.getCurrentPriceInPeg(token, amountInToken);
    }

    function viewYieldTokenInPeg(
        address token,
        uint256 amount,
        mapping(address => uint256) storage yieldQuotientsFP
    ) internal view returns (uint256) {
        uint256 yieldFP =
            Lending(lending()).viewAccumulatedBorrowingYieldFP(token);
        uint256 amountInToken = (amount * yieldFP) / yieldQuotientsFP[token];
        return PriceAware.viewCurrentPriceInPeg(token, amountInToken);
    }

    function adjustAmounts(
        CrossMarginAccount storage account,
        address fromToken,
        address toToken,
        uint256 soldAmount,
        uint256 boughtAmount
    ) internal {
        account.holdings[fromToken] = account.holdings[fromToken] - soldAmount;
        addHolding(account, toToken, boughtAmount);
    }

    function deleteAccount(CrossMarginAccount storage account) internal {
        uint256 len = account.borrowTokens.length;
        for (uint256 borrowIdx; len > borrowIdx; borrowIdx++) {
            address borrowToken = account.borrowTokens[borrowIdx];
            totalShort[borrowToken] -= account.borrowed[borrowToken];
            account.borrowed[borrowToken] = 0;
            account.borrowedYieldQuotientsFP[borrowToken] = 0;
        }
        len = account.holdingTokens.length;
        for (uint256 holdingIdx; len > holdingIdx; holdingIdx++) {
            address holdingToken = account.holdingTokens[holdingIdx];
            totalLong[holdingToken] -= account.holdings[holdingToken];
            account.holdings[holdingToken] = 0;
            account.holdsToken[holdingToken] = false;
        }
        delete account.borrowTokens;
        delete account.holdingTokens;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return b;
        } else {
            return a;
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


abstract contract CrossMarginLiquidation is CrossMarginAccounts {
    event LiquidationShortfall(uint256 amount);
    event AccountLiquidated(address account);

    struct Liquidation {
        uint256 buy;
        uint256 sell;
        uint256 blockNum;
    }

    struct AccountLiqRecord {
        uint256 blockNum;
        address loser;
        uint256 amount;
        address stakeAttacker;
    }

    mapping(address => Liquidation) liquidationAmounts;
    address[] internal sellTokens;
    address[] internal buyTokens;
    address[] internal tradersToLiquidate;

    mapping(address => uint256) public maintenanceFailures;
    mapping(address => AccountLiqRecord) public stakeAttackRecords;
    uint256 public avgLiquidationPerCall = 10;

    uint256 public liqStakeAttackWindow = 5;
    uint256 public MAINTAINER_CUT_PERCENT = 5;

    uint256 public failureThreshold = 10;

    function setFailureThreshold(uint256 threshFactor) external onlyOwnerExec {
        failureThreshold = threshFactor;
    }

    function setLiqStakeAttackWindow(uint256 window) external onlyOwnerExec {
        liqStakeAttackWindow = window;
    }

    function setMaintainerCutPercent(uint256 cut) external onlyOwnerExec {
        MAINTAINER_CUT_PERCENT = cut;
    }

    function calcLiquidationAmounts(
        address[] memory liquidationCandidates,
        bool isAuthorized
    ) internal returns (uint256 attackReturns) {
        sellTokens = new address[](0);
        buyTokens = new address[](0);
        tradersToLiquidate = new address[](0);

        for (
            uint256 traderIndex = 0;
            liquidationCandidates.length > traderIndex;
            traderIndex++
        ) {
            address traderAddress = liquidationCandidates[traderIndex];
            CrossMarginAccount storage account = marginAccounts[traderAddress];
            if (belowMaintenanceThreshold(account)) {
                tradersToLiquidate.push(traderAddress);
                uint256 len = account.holdingTokens.length;
                for (uint256 sellIdx = 0; len > sellIdx; sellIdx++) {
                    address token = account.holdingTokens[sellIdx];
                    Liquidation storage liquidation = liquidationAmounts[token];

                    if (liquidation.blockNum != block.number) {
                        liquidation.sell = account.holdings[token];
                        liquidation.buy = 0;
                        liquidation.blockNum = block.number;
                        sellTokens.push(token);
                    } else {
                        liquidation.sell += account.holdings[token];
                    }
                }

                len = account.borrowTokens.length;
                for (uint256 buyIdx = 0; len > buyIdx; buyIdx++) {
                    address token = account.borrowTokens[buyIdx];
                    Liquidation storage liquidation = liquidationAmounts[token];

                    (uint256 loanAmount, ) =
                        Lending(lending()).applyBorrowInterest(
                            account.borrowed[token],
                            token,
                            account.borrowedYieldQuotientsFP[token]
                        );

                    Lending(lending()).payOff(token, loanAmount);

                    if (liquidation.blockNum != block.number) {
                        liquidation.sell = 0;
                        liquidation.buy = loanAmount;
                        liquidation.blockNum = block.number;
                        buyTokens.push(token);
                    } else {
                        liquidation.buy += loanAmount;
                    }
                }
            }

            AccountLiqRecord storage liqAttackRecord =
                stakeAttackRecords[traderAddress];
            if (isAuthorized) {
                attackReturns += _disburseLiqAttack(liqAttackRecord);
            }
        }
    }

    function _disburseLiqAttack(AccountLiqRecord storage liqAttackRecord)
        internal
        returns (uint256 returnAmount)
    {
        if (liqAttackRecord.amount > 0) {
            uint256 blockDiff =
                min(
                    block.number - liqAttackRecord.blockNum,
                    liqStakeAttackWindow
                );

            uint256 attackerCut =
                (liqAttackRecord.amount * blockDiff) / liqStakeAttackWindow;

            Fund(fund()).withdraw(
                PriceAware.peg,
                liqAttackRecord.stakeAttacker,
                attackerCut
            );

            Admin a = Admin(admin());
            uint256 penalty =
                (a.maintenanceStakePerBlock() * attackerCut) /
                    avgLiquidationPerCall;
            a.penalizeMaintenanceStake(
                liqAttackRecord.loser,
                penalty,
                liqAttackRecord.stakeAttacker
            );

            returnAmount = liqAttackRecord.amount - attackerCut;
        }
    }

    function disburseLiqStakeAttacks(address[] memory liquidatedAccounts)
        external
    {
        for (uint256 i = 0; liquidatedAccounts.length > i; i++) {
            address liqAccount = liquidatedAccounts[i];
            AccountLiqRecord storage liqAttackRecord =
                stakeAttackRecords[liqAccount];
            if (
                block.number > liqAttackRecord.blockNum + liqStakeAttackWindow
            ) {
                _disburseLiqAttack(liqAttackRecord);
                delete stakeAttackRecords[liqAccount];
            }
        }
    }

    function liquidateFromPeg() internal returns (uint256 pegAmount) {
        uint256 len = buyTokens.length;
        for (uint256 tokenIdx = 0; len > tokenIdx; tokenIdx++) {
            address buyToken = buyTokens[tokenIdx];
            Liquidation storage liq = liquidationAmounts[buyToken];
            if (liq.buy > liq.sell) {
                pegAmount += PriceAware.liquidateFromPeg(
                    buyToken,
                    liq.buy - liq.sell
                );
                delete liquidationAmounts[buyToken];
            }
        }
        delete buyTokens;
    }

    function liquidateToPeg() internal returns (uint256 pegAmount) {
        uint256 len = sellTokens.length;
        for (uint256 tokenIndex = 0; len > tokenIndex; tokenIndex++) {
            address token = sellTokens[tokenIndex];
            Liquidation storage liq = liquidationAmounts[token];
            if (liq.sell > liq.buy) {
                uint256 sellAmount = liq.sell - liq.buy;
                pegAmount += PriceAware.liquidateToPeg(token, sellAmount);
                delete liquidationAmounts[token];
            }
        }
        delete sellTokens;
    }

    function maintainerIsFailing() internal view returns (bool) {
        (address currentMaintainer, ) =
            Admin(admin()).viewCurrentMaintenanceStaker();
        return
            maintenanceFailures[currentMaintainer] >
            failureThreshold * avgLiquidationPerCall;
    }

    function liquidate(address[] memory liquidationCandidates)
        external
        noIntermediary
        returns (uint256 maintainerCut)
    {
        bool isAuthorized = Admin(admin()).isAuthorizedStaker(msg.sender);
        bool canTakeNow = isAuthorized || maintainerIsFailing();

        maintainerCut = calcLiquidationAmounts(
            liquidationCandidates,
            isAuthorized
        );

        uint256 sale2pegAmount = liquidateToPeg();
        uint256 peg2targetCost = liquidateFromPeg();

        uint256 costWithCut =
            (peg2targetCost * (100 + MAINTAINER_CUT_PERCENT)) / 100;
        if (costWithCut > sale2pegAmount) {
            emit LiquidationShortfall(costWithCut - sale2pegAmount);
        }

        address loser = address(0);
        if (!canTakeNow) {
            loser = Admin(admin()).getUpdatedCurrentStaker();
        }

        for (
            uint256 traderIdx = 0;
            tradersToLiquidate.length > traderIdx;
            traderIdx++
        ) {
            address traderAddress = tradersToLiquidate[traderIdx];
            CrossMarginAccount storage account = marginAccounts[traderAddress];

            uint256 holdingsValue = holdingsInPeg(account);
            uint256 borrowValue = loanInPeg(account);
            uint256 maintainerCut4Account =
                (borrowValue * MAINTAINER_CUT_PERCENT) / 100;
            maintainerCut += maintainerCut4Account;

            if (!canTakeNow) {
                AccountLiqRecord storage liqAttackRecord =
                    stakeAttackRecords[traderAddress];
                liqAttackRecord.amount = maintainerCut4Account;
                liqAttackRecord.stakeAttacker = msg.sender;
                liqAttackRecord.blockNum = block.number;
                liqAttackRecord.loser = loser;
            }

            if (holdingsValue > maintainerCut4Account + borrowValue) {
                Fund(fund()).withdraw(
                    PriceAware.peg,
                    traderAddress,
                    holdingsValue - borrowValue - maintainerCut4Account
                );
            }

            emit AccountLiquidated(traderAddress);
            deleteAccount(account);
        }

        avgLiquidationPerCall =
            (avgLiquidationPerCall * 99 + maintainerCut) /
            100;

        if (canTakeNow) {
            Fund(fund()).withdraw(PriceAware.peg, msg.sender, maintainerCut);
        }

        address currentMaintainer = Admin(admin()).getUpdatedCurrentStaker();
        if (isAuthorized) {
            if (maintenanceFailures[currentMaintainer] > maintainerCut) {
                maintenanceFailures[currentMaintainer] -= maintainerCut;
            } else {
                maintenanceFailures[currentMaintainer] = 0;
            }
        } else {
            maintenanceFailures[currentMaintainer] += maintainerCut;
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;




contract CrossMarginTrading is CrossMarginLiquidation, IMarginTrading {

    constructor(address _peg, address _roles)
        RoleAware(_roles)
        PriceAware(_peg)
    {}

    function setTokenCap(address token, uint256 cap)
        external
        onlyOwnerExecActivator
    {

        tokenCaps[token] = cap;
    }

    function setCoolingOffPeriod(uint256 blocks) external onlyOwnerExec {

        coolingOffPeriod = blocks;
    }

    function setLeveragePercent(uint256 _leveragePercent)
        external
        onlyOwnerExec
    {

        leveragePercent = _leveragePercent;
    }

    function setLiquidationThresholdPercent(uint256 threshold)
        external
        onlyOwnerExec
    {

        liquidationThresholdPercent = threshold;
    }

    function registerDeposit(
        address trader,
        address token,
        uint256 depositAmount
    ) external override returns (uint256 extinguishableDebt) {

        require(isMarginTrader(msg.sender), "Calling contr. not authorized");

        CrossMarginAccount storage account = marginAccounts[trader];
        account.lastDepositBlock = block.number;

        if (account.borrowed[token] > 0) {
            extinguishableDebt = min(depositAmount, account.borrowed[token]);
            extinguishDebt(account, token, extinguishableDebt);
            totalShort[token] -= extinguishableDebt;
        }

        uint256 addedHolding = depositAmount - extinguishableDebt;
        _registerDeposit(account, token, addedHolding);
    }

    function _registerDeposit(
        CrossMarginAccount storage account,
        address token,
        uint256 addedHolding
    ) internal {

        addHolding(account, token, addedHolding);

        totalLong[token] += addedHolding;
        require(
            tokenCaps[token] >= totalLong[token],
            "Exceeds global token cap"
        );
    }

    function registerBorrow(
        address trader,
        address borrowToken,
        uint256 borrowAmount
    ) external override {

        require(isMarginTrader(msg.sender), "Calling contr. not authorized");
        CrossMarginAccount storage account = marginAccounts[trader];
        addHolding(account, borrowToken, borrowAmount);
        _registerBorrow(account, borrowToken, borrowAmount);
    }

    function _registerBorrow(
        CrossMarginAccount storage account,
        address borrowToken,
        uint256 borrowAmount
    ) internal {

        totalShort[borrowToken] += borrowAmount;
        totalLong[borrowToken] += borrowAmount;
        require(
            tokenCaps[borrowToken] >= totalShort[borrowToken] &&
                tokenCaps[borrowToken] >= totalLong[borrowToken],
            "Exceeds global token cap"
        );

        borrow(account, borrowToken, borrowAmount);
    }

    function registerWithdrawal(
        address trader,
        address withdrawToken,
        uint256 withdrawAmount
    ) external override {

        require(isMarginTrader(msg.sender), "Calling contr not authorized");
        CrossMarginAccount storage account = marginAccounts[trader];
        _registerWithdrawal(account, withdrawToken, withdrawAmount);
    }

    function _registerWithdrawal(
        CrossMarginAccount storage account,
        address withdrawToken,
        uint256 withdrawAmount
    ) internal {

        require(
            block.number > account.lastDepositBlock + coolingOffPeriod,
            "No withdrawal soon after deposit"
        );

        totalLong[withdrawToken] -= withdrawAmount;
        account.holdings[withdrawToken] =
            account.holdings[withdrawToken] -
            withdrawAmount;
        require(positiveBalance(account), "Insufficient balance");
    }

    function registerOvercollateralizedBorrow(
        address trader,
        address depositToken,
        uint256 depositAmount,
        address borrowToken,
        uint256 withdrawAmount
    ) external override {

        require(isMarginTrader(msg.sender), "Calling contr. not authorized");

        CrossMarginAccount storage account = marginAccounts[trader];

        _registerDeposit(account, depositToken, depositAmount);
        _registerBorrow(account, borrowToken, withdrawAmount);
        _registerWithdrawal(account, borrowToken, withdrawAmount);

        account.lastDepositBlock = block.number;
    }

    function registerTradeAndBorrow(
        address trader,
        address tokenFrom,
        address tokenTo,
        uint256 inAmount,
        uint256 outAmount
    )
        external
        override
        returns (uint256 extinguishableDebt, uint256 borrowAmount)
    {

        require(isMarginTrader(msg.sender), "Calling contr. not an authorized");

        CrossMarginAccount storage account = marginAccounts[trader];

        if (account.borrowed[tokenTo] > 0) {
            extinguishableDebt = min(outAmount, account.borrowed[tokenTo]);
            extinguishDebt(account, tokenTo, extinguishableDebt);
            totalShort[tokenTo] -= extinguishableDebt;
        }

        uint256 sellAmount = inAmount;
        uint256 fromHoldings = account.holdings[tokenFrom];
        if (inAmount > fromHoldings) {
            sellAmount = fromHoldings;
            borrowAmount = inAmount - sellAmount;
        }

        if (inAmount > borrowAmount) {
            totalLong[tokenFrom] -= inAmount - borrowAmount;
        }
        if (outAmount > extinguishableDebt) {
            totalLong[tokenTo] += outAmount - extinguishableDebt;
        }
        require(
            tokenCaps[tokenTo] >= totalLong[tokenTo],
            "Exceeds global token cap"
        );

        adjustAmounts(
            account,
            tokenFrom,
            tokenTo,
            sellAmount,
            outAmount - extinguishableDebt
        );

        if (borrowAmount > 0) {
            totalShort[tokenFrom] += borrowAmount;
            require(
                tokenCaps[tokenFrom] >= totalShort[tokenFrom],
                "Exceeds global token cap"
            );
            borrow(account, tokenFrom, borrowAmount);
        }
    }

    function registerLiquidation(address trader) external override {

        require(isMarginTrader(msg.sender), "Calling contr. not authorized");
        CrossMarginAccount storage account = marginAccounts[trader];
        require(loanInPeg(account) == 0, "Can't liquidate: borrowing");

        deleteAccount(account);
    }

    function viewBalanceInToken(address trader, address token)
        external
        view
        returns (uint256)
    {

        CrossMarginAccount storage account = marginAccounts[trader];
        return account.holdings[token];
    }

    function getHoldingAmounts(address trader)
        external
        view
        override
        returns (
            address[] memory holdingTokens,
            uint256[] memory holdingAmounts
        )
    {

        CrossMarginAccount storage account = marginAccounts[trader];
        holdingTokens = account.holdingTokens;

        holdingAmounts = new uint256[](account.holdingTokens.length);
        for (uint256 idx = 0; holdingTokens.length > idx; idx++) {
            address tokenAddress = holdingTokens[idx];
            holdingAmounts[idx] = account.holdings[tokenAddress];
        }
    }

    function getBorrowAmounts(address trader)
        external
        view
        override
        returns (address[] memory borrowTokens, uint256[] memory borrowAmounts)
    {

        CrossMarginAccount storage account = marginAccounts[trader];
        borrowTokens = account.borrowTokens;

        borrowAmounts = new uint256[](account.borrowTokens.length);
        for (uint256 idx = 0; borrowTokens.length > idx; idx++) {
            address tokenAddress = borrowTokens[idx];
            borrowAmounts[idx] = Lending(lending()).viewWithBorrowInterest(
                account.borrowed[tokenAddress],
                tokenAddress,
                account.borrowedYieldQuotientsFP[tokenAddress]
            );
        }
    }

    function viewLoanInPeg(address trader)
        external
        view
        returns (uint256 amount)
    {

        CrossMarginAccount storage account = marginAccounts[trader];
        return
            viewTokensInPegWithYield(
                account.borrowTokens,
                account.borrowed,
                account.borrowedYieldQuotientsFP
            );
    }

    function viewHoldingsInPeg(address trader) external view returns (uint256) {

        CrossMarginAccount storage account = marginAccounts[trader];
        return viewTokensInPeg(account.holdingTokens, account.holdings);
    }

    function canBeLiquidated(address trader) external view returns (bool) {

        CrossMarginAccount storage account = marginAccounts[trader];
        uint256 loan =
            viewTokensInPegWithYield(
                account.borrowTokens,
                account.borrowed,
                account.borrowedYieldQuotientsFP
            );

        uint256 holdings =
            viewTokensInPeg(account.holdingTokens, account.holdings);

        return 100 * holdings >= liquidationThresholdPercent * loan;
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


contract Admin is RoleAware {

    address public immutable MFI;
    mapping(address => uint256) public stakes;
    uint256 public totalStakes;

    uint256 public constant mfiStakeTranche = 1;

    uint256 public maintenanceStakePerBlock = 15 ether;
    mapping(address => address) public nextMaintenanceStaker;
    mapping(address => mapping(address => bool)) public maintenanceDelegateTo;
    address public currentMaintenanceStaker;
    address public prevMaintenanceStaker;
    uint256 public currentMaintenanceStakerStartBlock;
    address public immutable lockedMFI;

    constructor(
        address _MFI,
        address _lockedMFI,
        address lockedMFIDelegate,
        address _roles
    ) RoleAware(_roles) {
        MFI = _MFI;
        lockedMFI = _lockedMFI;

        nextMaintenanceStaker[_lockedMFI] = _lockedMFI;
        currentMaintenanceStaker = _lockedMFI;
        prevMaintenanceStaker = _lockedMFI;
        maintenanceDelegateTo[_lockedMFI][lockedMFIDelegate];
        currentMaintenanceStakerStartBlock = block.number;
    }

    function setMaintenanceStakePerBlock(uint256 amount)
        external
        onlyOwnerExec
    {

        maintenanceStakePerBlock = amount;
    }

    function _stake(address holder, uint256 amount) internal {

        Fund(fund()).depositFor(holder, MFI, amount);

        stakes[holder] += amount;
        totalStakes += amount;

        IncentiveDistribution(incentiveDistributor()).addToClaimAmount(
            mfiStakeTranche,
            holder,
            amount
        );
    }

    function depositStake(uint256 amount) external {

        _stake(msg.sender, amount);
    }

    function _withdrawStake(
        address holder,
        uint256 amount,
        address recipient
    ) internal {

        stakes[holder] -= amount;
        totalStakes -= amount;
        Fund(fund()).withdraw(MFI, recipient, amount);

        IncentiveDistribution(incentiveDistributor()).subtractFromClaimAmount(
            mfiStakeTranche,
            holder,
            amount
        );
    }

    function withdrawStake(uint256 amount) external {

        require(
            !isAuthorizedStaker(msg.sender),
            "You can't withdraw while you're authorized staker"
        );
        _withdrawStake(msg.sender, amount, msg.sender);
    }

    function depositMaintenanceStake(uint256 amount) external {

        require(
            amount + stakes[msg.sender] >= maintenanceStakePerBlock,
            "Insufficient stake to call even one block"
        );
        _stake(msg.sender, amount);
        if (nextMaintenanceStaker[msg.sender] == address(0)) {
            nextMaintenanceStaker[msg.sender] = getUpdatedCurrentStaker();
            nextMaintenanceStaker[prevMaintenanceStaker] = msg.sender;
        }
    }

    function getMaintenanceStakerStake(address staker)
        public
        view
        returns (uint256)
    {

        if (staker == lockedMFI) {
            return IERC20(MFI).balanceOf(lockedMFI) / 2;
        } else {
            return stakes[staker];
        }
    }

    function getUpdatedCurrentStaker() public returns (address) {

        uint256 currentStake =
            getMaintenanceStakerStake(currentMaintenanceStaker);
        while (
            (block.number - currentMaintenanceStakerStartBlock) *
                maintenanceStakePerBlock >=
            currentStake
        ) {
            if (maintenanceStakePerBlock > currentStake) {
                address nextOne =
                    nextMaintenanceStaker[currentMaintenanceStaker];
                nextMaintenanceStaker[prevMaintenanceStaker] = nextOne;
                nextMaintenanceStaker[currentMaintenanceStaker] = address(0);

                currentMaintenanceStaker = nextOne;
            } else {
                currentMaintenanceStakerStartBlock +=
                    currentStake /
                    maintenanceStakePerBlock;

                prevMaintenanceStaker = currentMaintenanceStaker;
                currentMaintenanceStaker = nextMaintenanceStaker[
                    currentMaintenanceStaker
                ];
            }
            currentStake = getMaintenanceStakerStake(currentMaintenanceStaker);
        }
        return currentMaintenanceStaker;
    }

    function viewCurrentMaintenanceStaker()
        public
        view
        returns (address staker, uint256 startBlock)
    {

        staker = currentMaintenanceStaker;
        uint256 currentStake = getMaintenanceStakerStake(staker);
        startBlock = currentMaintenanceStakerStartBlock;
        while (
            (block.number - startBlock) * maintenanceStakePerBlock >=
            currentStake
        ) {
            if (currentStake >= maintenanceStakePerBlock) {
                startBlock += currentStake / maintenanceStakePerBlock;
            }
            staker = nextMaintenanceStaker[staker];
            currentStake = getMaintenanceStakerStake(staker);
        }
    }

    function addDelegate(address forStaker, address delegate) external {

        require(
            msg.sender == forStaker ||
                maintenanceDelegateTo[forStaker][msg.sender],
            "msg.sender not authorized to delegate for staker"
        );
        maintenanceDelegateTo[forStaker][delegate] = true;
    }

    function removeDelegate(address forStaker, address delegate) external {

        require(
            msg.sender == forStaker ||
                maintenanceDelegateTo[forStaker][msg.sender],
            "msg.sender not authorized to delegate for staker"
        );
        maintenanceDelegateTo[forStaker][delegate] = false;
    }

    function isAuthorizedStaker(address caller)
        public
        returns (bool isAuthorized)
    {

        address currentStaker = getUpdatedCurrentStaker();
        isAuthorized =
            currentStaker == caller ||
            maintenanceDelegateTo[currentStaker][caller];
    }

    function penalizeMaintenanceStake(
        address maintainer,
        uint256 penalty,
        address recipient
    ) external returns (uint256 stakeTaken) {

        require(
            isStakePenalizer(msg.sender),
            "msg.sender not authorized to penalize stakers"
        );
        if (penalty > stakes[maintainer]) {
            stakeTaken = stakes[maintainer];
        } else {
            stakeTaken = penalty;
        }
        _withdrawStake(maintainer, stakeTaken, recipient);
    }
}