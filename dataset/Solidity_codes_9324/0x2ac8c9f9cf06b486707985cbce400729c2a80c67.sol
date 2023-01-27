
pragma solidity 0.8.0;

interface IStabilityPool {


    event StabilityPoolETHBalanceUpdated(uint256 _newBalance);
    event StabilityPoolLUSDBalanceUpdated(uint256 _newBalance);
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event LUSDTokenAddressChanged(address _newLUSDTokenAddress);
    event SortedTrovesAddressChanged(address _newSortedTrovesAddress);
    event CommunityIssuanceAddressChanged(address _newCommunityIssuanceAddress);

    event P_Updated(uint256 _P);
    event S_Updated(uint256 _S, uint128 _epoch, uint128 _scale);
    event G_Updated(uint256 _G, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event FrontEndRegistered(address indexed _frontEnd, uint256 _kickbackRate);
    event FrontEndTagSet(address indexed _depositor, address indexed _frontEnd);

    event DepositSnapshotUpdated(address indexed _depositor, uint256 _P, uint256 _S, uint256 _G);
    event FrontEndSnapshotUpdated(address indexed _frontEnd, uint256 _P, uint256 _G);
    event UserDepositChanged(address indexed _depositor, uint256 _newDeposit);
    event FrontEndStakeChanged(
        address indexed _frontEnd,
        uint256 _newFrontEndStake,
        address _depositor
    );

    event ETHGainWithdrawn(address indexed _depositor, uint256 _ETH, uint256 _LUSDLoss);
    event LQTYPaidToDepositor(address indexed _depositor, uint256 _LQTY);
    event LQTYPaidToFrontEnd(address indexed _frontEnd, uint256 _LQTY);
    event EtherSent(address _to, uint256 _amount);
    event GovernanceAddressChanged(address _governanceAddress);


    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _lusdTokenAddress,
        address _sortedTrovesAddress,
        address _wethAddress,
        address _governanceAddress
    ) external;


    function provideToSP(uint256 _amount, address _frontEndTag) external;


    function withdrawFromSP(uint256 _amount) external;


    function withdrawETHGainToTrove(address _upperHint, address _lowerHint) external;


    function registerFrontEnd(uint256 _kickbackRate) external;


    function offset(uint256 _debt, uint256 _coll) external;


    function getETH() external view returns (uint256);


    function getTotalLUSDDeposits() external view returns (uint256);


    function getDepositorETHGain(address _depositor) external view returns (uint256);


    function getDepositorLQTYGain(address _depositor) external view returns (uint256);


    function getFrontEndLQTYGain(address _frontEnd) external view returns (uint256);


    function getCompoundedLUSDDeposit(address _depositor) external view returns (uint256);


    function getCompoundedFrontEndStake(address _frontEnd) external view returns (uint256);


    function receiveETH(uint256 _amount) external;

}// MIT

pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

interface IPriceFeed {

    event LastGoodPriceUpdated(uint256 _lastGoodPrice);

    function fetchPrice() external returns (uint256);

}// MIT

pragma solidity 0.8.0;


interface ILiquityBase {

    function getPriceFeed() external view returns (IPriceFeed);

}// MIT

pragma solidity 0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.8.0;

interface IERC2612 {

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function version() external view returns (string memory);


    function permitTypeHash() external view returns (bytes32);


    function domainSeparator() external view returns (bytes32);

}// MIT

pragma solidity 0.8.0;


interface ILiquityLUSDToken is IERC20, IERC2612 {



    event BorrowerOperationsAddressToggled(address borrowerOperations, bool oldFlag, bool newFlag, uint256 timestamp);
    event TroveManagerToggled(address troveManager, bool oldFlag, bool newFlag, uint256 timestamp);
    event StabilityPoolToggled(address stabilityPool, bool oldFlag, bool newFlag, uint256 timestamp);

    event LUSDTokenBalanceUpdated(address _user, uint _amount);


    function toggleBorrowerOperations(address borrowerOperations) external;


    function toggleTroveManager(address troveManager) external;


    function toggleStabilityPool(address stabilityPool) external;


    function mint(address _account, uint256 _amount) external;


    function burn(address _account, uint256 _amount) external;


    function sendToPool(address _sender,  address poolAddress, uint256 _amount) external;


    function returnFromPool(address poolAddress, address user, uint256 _amount ) external;

}// MIT

pragma solidity 0.8.0;


interface ITroveManager is ILiquityBase {



    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event LUSDTokenAddressChanged(address _newLUSDTokenAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event GovernanceAddressChanged(address _governanceAddress);
    event WETHAddressChanged(address _wethAddress);

    event RewardSnapshotDetailsUpdated(address owner, address newOwner, uint256 timestamp);
    event TroveOwnersUpdated(address owner, address newOwner, uint256 idx, uint256 timestamp);
    event Liquidation(
        uint256 _liquidatedDebt,
        uint256 _liquidatedColl,
        uint256 _collGasCompensation,
        uint256 _LUSDGasCompensation
    );
    event Redemption(
        uint256 _attemptedLUSDAmount,
        uint256 _actualLUSDAmount,
        uint256 _ETHSent,
        uint256 _ETHFee
    );
    event TroveUpdated(
        address indexed _borrower,
        uint256 _debt,
        uint256 _coll,
        uint256 _stake,
        TroveManagerOperation _operation
    );
    event TroveLiquidated(
        address indexed _borrower,
        uint256 _debt,
        uint256 _coll,
        TroveManagerOperation _operation
    );
    event BaseRateUpdated(uint256 _baseRate);
    event LastFeeOpTimeUpdated(uint256 _lastFeeOpTime);
    event TotalStakesUpdated(uint256 _newTotalStakes);
    event SystemSnapshotsUpdated(uint256 _totalStakesSnapshot, uint256 _totalCollateralSnapshot);
    event LTermsUpdated(uint256 _L_ETH, uint256 _L_LUSDDebt);
    event TroveSnapshotsUpdated(uint256 _L_ETH, uint256 _L_LUSDDebt);
    event TroveIndexUpdated(address _borrower, uint256 _newIndex);

    enum TroveManagerOperation {
        applyPendingRewards,
        liquidateInNormalMode,
        liquidateInRecoveryMode,
        redeemCollateral
    }


    function setAddresses(
        address _borrowerOperationsAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _lusdTokenAddress,
        address _sortedTrovesAddress,
        address _governanceAddress,
        address _wethAddress
    ) external;


    function stabilityPool() external view returns (IStabilityPool);


    function lusdToken() external view returns (ILiquityLUSDToken);


    function getTroveOwnersCount() external view returns (uint256);


    function getTroveFromTroveOwnersArray(uint256 _index) external view returns (address);


    function getNominalICR(address _borrower) external view returns (uint256);


    function getCurrentICR(address _borrower, uint256 _price) external view returns (uint256);


    function liquidate(address _borrower) external;


    function liquidateTroves(uint256 _n) external;


    function batchLiquidateTroves(address[] calldata _troveArray) external;


    function redeemCollateral(
        uint256 _LUSDAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint256 _partialRedemptionHintNICR,
        uint256 _maxIterations,
        uint256 _maxFee
    ) external;


    function updateStakeAndTotalStakes(address _borrower) external returns (uint256);


    function updateTroveRewardSnapshots(address _borrower) external;


    function addTroveOwnerToArray(address _borrower) external returns (uint256 index);


    function applyPendingRewards(address _borrower) external;


    function getPendingETHReward(address _borrower) external view returns (uint256);


    function getPendingLUSDDebtReward(address _borrower) external view returns (uint256);


    function hasPendingRewards(address _borrower) external view returns (bool);


    function getEntireDebtAndColl(address _borrower)
        external
        view
        returns (
            uint256 debt,
            uint256 coll,
            uint256 pendingLUSDDebtReward,
            uint256 pendingETHReward
        );


    function closeTrove(address _borrower) external;


    function removeStake(address _borrower) external;


    function getRedemptionRate() external view returns (uint256);


    function getRedemptionRateWithDecay() external view returns (uint256);


    function getRedemptionFeeWithDecay(uint256 _ETHDrawn) external view returns (uint256);


    function getBorrowingRate() external view returns (uint256);


    function getBorrowingRateWithDecay() external view returns (uint256);


    function getBorrowingFee(uint256 LUSDDebt) external view returns (uint256);


    function getBorrowingFeeWithDecay(uint256 _LUSDDebt) external view returns (uint256);


    function decayBaseRateFromBorrowing() external;


    function getTroveStatus(address _borrower) external view returns (uint256);


    function getTroveStake(address _borrower) external view returns (uint256);


    function getTroveDebt(address _borrower) external view returns (uint256);


    function getTroveFrontEnd(address _borrower) external view returns (address);


    function getTroveColl(address _borrower) external view returns (uint256);


    function setTroveStatus(address _borrower, uint256 num) external;


    function setTroveFrontEndTag(address _borrower, address _frontEndTag) external;


    function increaseTroveColl(address _borrower, uint256 _collIncrease) external returns (uint256);


    function decreaseTroveColl(address _borrower, uint256 _collDecrease) external returns (uint256);


    function increaseTroveDebt(address _borrower, uint256 _debtIncrease) external returns (uint256);


    function decreaseTroveDebt(address _borrower, uint256 _collDecrease) external returns (uint256);


    function getTCR(uint256 _price) external view returns (uint256);


    function checkRecoveryMode(uint256 _price) external view returns (bool);

}// MIT

pragma solidity 0.8.0;

interface ICollSurplusPool {


    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);

    event CollBalanceUpdated(address indexed _account, uint256 _newBalance);
    event EtherSent(address _to, uint256 _amount);


    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _wethAddress
    ) external;


    function getETH() external view returns (uint256);


    function receiveETH(uint256 _amount) external;


    function getCollateral(address _account) external view returns (uint256);


    function accountSurplus(address _account, uint256 _amount) external;


    function claimColl(address _account) external;

}// MIT

pragma solidity 0.8.0;

interface ISortedTroves {


    event TroveManagerAddressChanged(address _troveManagerAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event NodeAdded(address _id, uint256 _NICR);
    event NodeRemoved(address _id);
    event NodeOwnerUpdated(address id, address newId, uint256 timestamp);


    function setParams(
        uint256 _size,
        address _TroveManagerAddress,
        address _borrowerOperationsAddress
    ) external;


    function insert(
        address _id,
        uint256 _ICR,
        address _prevId,
        address _nextId
    ) external;


    function remove(address _id) external;


    function reInsert(
        address _id,
        uint256 _newICR,
        address _prevId,
        address _nextId
    ) external;


    function contains(address _id) external view returns (bool);


    function isFull() external view returns (bool);


    function isEmpty() external view returns (bool);


    function getSize() external view returns (uint256);


    function getMaxSize() external view returns (uint256);


    function getFirst() external view returns (address);


    function getLast() external view returns (address);


    function getNext(address _id) external view returns (address);


    function getPrev(address _id) external view returns (address);


    function validInsertPosition(
        uint256 _ICR,
        address _prevId,
        address _nextId
    ) external view returns (bool);


    function findInsertPosition(
        uint256 _ICR,
        address _prevId,
        address _nextId
    ) external view returns (address, address);

}// MIT
pragma solidity 0.8.0;

contract BaseMath {

    uint256 public constant DECIMAL_PRECISION = 1e18;
}// MIT

pragma solidity 0.8.0;

library SafeMath {

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
}// MIT

pragma solidity 0.8.0;



library LiquityMath {

    using SafeMath for uint;

    uint internal constant DECIMAL_PRECISION = 1e18;

    uint internal constant NICR_PRECISION = 1e20;

    function _min(uint _a, uint _b) internal pure returns (uint) {

        return (_a < _b) ? _a : _b;
    }

    function _max(uint _a, uint _b) internal pure returns (uint) {

        return (_a >= _b) ? _a : _b;
    }

    function decMul(uint x, uint y) internal pure returns (uint decProd) {

        uint prod_xy = x.mul(y);

        decProd = prod_xy.add(DECIMAL_PRECISION / 2).div(DECIMAL_PRECISION);
    }

    function _decPow(uint _base, uint _minutes) internal pure returns (uint) {


        if (_minutes > 525600000) {_minutes = 525600000;}  // cap to avoid overflow

        if (_minutes == 0) {return DECIMAL_PRECISION;}

        uint y = DECIMAL_PRECISION;
        uint x = _base;
        uint n = _minutes;

        while (n > 1) {
            if (n % 2 == 0) {
                x = decMul(x, x);
                n = n.div(2);
            } else { // if (n % 2 != 0)
                y = decMul(x, y);
                x = decMul(x, x);
                n = (n.sub(1)).div(2);
            }
        }

        return decMul(x, y);
  }

    function _getAbsoluteDifference(uint _a, uint _b) internal pure returns (uint) {

        return (_a >= _b) ? _a.sub(_b) : _b.sub(_a);
    }

    function _computeNominalCR(uint _coll, uint _debt) internal pure returns (uint) {

        if (_debt > 0) {
            return _coll.mul(NICR_PRECISION).div(_debt);
        }
        else { // if (_debt == 0)
            return 2**256 - 1;
        }
    }

    function _computeCR(uint _coll, uint _debt, uint _price) internal pure returns (uint) {

        if (_debt > 0) {
            uint newCollRatio = _coll.mul(_price).div(_debt);

            return newCollRatio;
        }
        else { // if (_debt == 0)
            return 2**256 - 1;
        }
    }
}// MIT

pragma solidity 0.8.0;

interface ISimpleERCFund {

    function deposit(
        address token,
        uint256 amount,
        string memory reason
    ) external;


    function withdraw(
        address token,
        uint256 amount,
        address to,
        string memory reason
    ) external;

}// MIT

pragma solidity 0.8.0;

interface IOracle {

    function getPrice() external view returns (uint256);


    function getDecimalPercision() external view returns (uint256);

}// MIT

pragma solidity 0.8.0;


interface IGovernance {

    function getDeploymentStartTime() external view returns (uint256);


    function getBorrowingFeeFloor() external view returns (uint256);


    function getRedemptionFeeFloor() external view returns (uint256);


    function getMaxBorrowingFee() external view returns (uint256);


    function getMaxDebtCeiling() external view returns (uint256);


    function getAllowMinting() external view returns (bool);


    function getPriceFeed() external view returns (IPriceFeed);


    function getStabilityFee() external view returns (uint256);


    function getStabilityFeeToken() external view returns (IERC20);


    function getStabilityTokenPairOracle() external view returns (IOracle);


    function getFund() external view returns (ISimpleERCFund);


    function chargeStabilityFee(address who, uint256 LUSDAmount) external;


    function sendToFund(address token, uint256 amount, string memory reason) external;

}// MIT

pragma solidity 0.8.0;

interface IPool {


    event ETHBalanceUpdated(uint256 _newBalance);
    event LUSDBalanceUpdated(uint256 _newBalance);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event EtherSent(address _to, uint256 _amount);


    function getETH() external view returns (uint256);


    function getLUSDDebt() external view returns (uint256);


    function increaseLUSDDebt(uint256 _amount) external;


    function decreaseLUSDDebt(uint256 _amount) external;

}// MIT

pragma solidity 0.8.0;


interface IActivePool is IPool {

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolLUSDDebtUpdated(uint256 _LUSDDebt);
    event ActivePoolETHBalanceUpdated(uint256 _ETH);

    event Repay(address indexed from, uint256 amount);
    event Borrow(address indexed from, uint256 amount);

    function sendETH(address _account, uint256 _amount) external;


    function receiveETH(uint256 _amount) external;


    function borrow(uint256 amount) external;


    function repay(uint256 amount) external;

}// MIT

pragma solidity 0.8.0;


interface IDefaultPool is IPool {

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolLUSDDebtUpdated(uint256 _LUSDDebt);
    event DefaultPoolETHBalanceUpdated(uint256 _ETH);

    function sendETHToActivePool(uint256 _amount) external;


    function receiveETH(uint256 _amount) external;

}// MIT

pragma solidity 0.8.0;


contract LiquityBase is BaseMath, ILiquityBase {

    using SafeMath for uint256;

    uint256 public _100pct = 1000000000000000000; // 1e18 == 100%

    uint256 public MCR = 1080000000000000000; // 108%

    uint256 public CCR = 1300000000000000000; // 130%

    uint256 public LUSD_GAS_COMPENSATION = 50e18;

    uint256 public MIN_NET_DEBT = 50e18;

    uint256 public PERCENT_DIVISOR = 200; // dividing by 200 yields 0.5%

    IActivePool public activePool;
    IDefaultPool public defaultPool;
    IGovernance public governance;


    function getBorrowingFeeFloor() public view returns (uint256) {

        return governance.getBorrowingFeeFloor();
    }

    function getRedemptionFeeFloor() public view returns (uint256) {

        return governance.getRedemptionFeeFloor();
    }

    function getMaxBorrowingFee() public view returns (uint256) {

        return governance.getMaxBorrowingFee();
    }

    function getPriceFeed() public view override returns (IPriceFeed) {

        return governance.getPriceFeed();
    }

    function _getCompositeDebt(uint256 _debt) internal view returns (uint256) {

        return _debt.add(LUSD_GAS_COMPENSATION);
    }

    function _getNetDebt(uint256 _debt) internal view returns (uint256) {

        return _debt.sub(LUSD_GAS_COMPENSATION);
    }

    function _getCollGasCompensation(uint256 _entireColl) internal view returns (uint256) {

        return _entireColl / PERCENT_DIVISOR;
    }

    function getEntireSystemColl() public view returns (uint256 entireSystemColl) {

        uint256 activeColl = activePool.getETH();
        uint256 liquidatedColl = defaultPool.getETH();
        return activeColl.add(liquidatedColl);
    }

    function getEntireSystemDebt() public view returns (uint256 entireSystemDebt) {

        uint256 activeDebt = activePool.getLUSDDebt();
        uint256 closedDebt = defaultPool.getLUSDDebt();
        return activeDebt.add(closedDebt);
    }

    function _getTCR(uint256 _price) internal view returns (uint256 TCR) {

        uint256 entireSystemColl = getEntireSystemColl();
        uint256 entireSystemDebt = getEntireSystemDebt();
        TCR = LiquityMath._computeCR(entireSystemColl, entireSystemDebt, _price);
        return TCR;
    }

    function _checkRecoveryMode(uint256 _price) internal view returns (bool) {

        uint256 TCR = _getTCR(_price);
        return TCR < CCR;
    }

    function _requireUserAcceptsFee(
        uint256 _fee,
        uint256 _amount,
        uint256 _maxFeePercentage
    ) internal pure {

        uint256 feePercentage = _fee.mul(DECIMAL_PRECISION).div(_amount);
        require(feePercentage <= _maxFeePercentage, "Fee exceeded provided maximum");
    }
}// MIT

pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity 0.8.0;

contract Ownable is Context {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function _renounceOwnership() internal {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}// MIT

pragma solidity 0.8.0;

contract CheckContract {

    function checkContract(address _account) internal view {

        require(_account != address(0), "Account cannot be zero address");

        uint256 size;
        assembly {
            size := extcodesize(_account)
        }
        require(size > 0, "Account code size cannot be zero");
    }
}// MIT

pragma solidity 0.8.0;


interface IGasPool {

    event LUSDAddressChanged(address _lusdAddress);
    event TroveManagerAddressChanged(address _troveManagerAddress);
    event ReturnToLiquidator(address indexed to, uint256 amount, uint256 timestamp);
    event CoreControllerAddressChanged(address _coreControllerAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event LUSDBurnt(uint256 amount, uint256 timestamp);

    function setAddresses(
        address _troveManagerAddress,
        address _lusdTokenAddress,
        address _borrowerOperationAddress,
        address _coreControllerAddress
    ) external;

    function returnToLiquidator(address _account, uint256 amount) external;

    function burnLUSD(uint256 _amount) external;

}// MIT

pragma solidity 0.8.0;


contract TroveManager is LiquityBase, Ownable, CheckContract, ITroveManager {

    using SafeMath for uint256;
    string public constant NAME = "TroveManager";

    address public borrowerOperationsAddress;
    address public wethAddress;

    IStabilityPool public override stabilityPool;
    address gasPoolAddress;
    ICollSurplusPool collSurplusPool;
    ILiquityLUSDToken public override lusdToken;

    ISortedTroves public sortedTroves;


    uint256 public constant SECONDS_IN_ONE_MINUTE = 60;
    uint256 public constant MINUTE_DECAY_FACTOR = 999037758833783000;

    uint256 public constant BOOTSTRAP_PERIOD = 7 days;

    uint256 public constant BETA = 2;

    uint256 public baseRate;

    uint256 public lastFeeOperationTime;

    enum Status {
        nonExistent,
        active,
        closedByOwner,
        closedByLiquidation,
        closedByRedemption
    }

    struct Trove {
        uint256 debt;
        uint256 coll;
        uint256 stake;
        Status status;
        uint128 arrayIndex;
        address frontEndTag;
    }

    mapping(address => Trove) public Troves;

    uint256 public totalStakes;

    uint256 public totalStakesSnapshot;

    uint256 public totalCollateralSnapshot;

    uint256 public L_ETH;
    uint256 public L_LUSDDebt;

    mapping(address => RewardSnapshot) public rewardSnapshots;

    struct RewardSnapshot {
        uint256 ETH;
        uint256 LUSDDebt;
    }

    address[] public TroveOwners;

    uint256 public lastETHError_Redistribution;
    uint256 public lastLUSDDebtError_Redistribution;


    struct LocalVariables_OuterLiquidationFunction {
        uint256 price;
        uint256 LUSDInStabPool;
        bool recoveryModeAtStart;
        uint256 liquidatedDebt;
        uint256 liquidatedColl;
    }

    struct LocalVariables_InnerSingleLiquidateFunction {
        uint256 collToLiquidate;
        uint256 pendingDebtReward;
        uint256 pendingCollReward;
    }

    struct LocalVariables_LiquidationSequence {
        uint256 remainingLUSDInStabPool;
        uint256 i;
        uint256 ICR;
        address user;
        bool backToNormalMode;
        uint256 entireSystemDebt;
        uint256 entireSystemColl;
    }

    struct LiquidationValues {
        uint256 entireTroveDebt;
        uint256 entireTroveColl;
        uint256 collGasCompensation;
        uint256 LUSDGasCompensation;
        uint256 debtToOffset;
        uint256 collToSendToSP;
        uint256 debtToRedistribute;
        uint256 collToRedistribute;
        uint256 collSurplus;
    }

    struct LiquidationTotals {
        uint256 totalCollInSequence;
        uint256 totalDebtInSequence;
        uint256 totalCollGasCompensation;
        uint256 totalLUSDGasCompensation;
        uint256 totalDebtToOffset;
        uint256 totalCollToSendToSP;
        uint256 totalDebtToRedistribute;
        uint256 totalCollToRedistribute;
        uint256 totalCollSurplus;
    }

    struct ContractsCache {
        IActivePool activePool;
        IDefaultPool defaultPool;
        ILiquityLUSDToken lusdToken;
        ISortedTroves sortedTroves;
        ICollSurplusPool collSurplusPool;
        address gasPoolAddress;
        IPriceFeed priceFeed;
        IGovernance governance;
    }

    struct RedemptionTotals {
        uint256 remainingLUSD;
        uint256 totalLUSDToRedeem;
        uint256 totalETHDrawn;
        uint256 ETHFee;
        uint256 ETHToSendToRedeemer;
        uint256 decayedBaseRate;
        uint256 price;
        uint256 totalLUSDSupplyAtStart;
    }

    struct SingleRedemptionValues {
        uint256 LUSDLot;
        uint256 ETHLot;
        bool cancelledPartial;
    }


    function setAddresses(
        address _borrowerOperationsAddress,
        address _activePoolAddress,
        address _defaultPoolAddress,
        address _stabilityPoolAddress,
        address _gasPoolAddress,
        address _collSurplusPoolAddress,
        address _lusdTokenAddress,
        address _sortedTrovesAddress,
        address _governanceAddress,
        address _wethAddress
    ) external override onlyOwner {

        checkContract(_borrowerOperationsAddress);
        checkContract(_activePoolAddress);
        checkContract(_defaultPoolAddress);
        checkContract(_stabilityPoolAddress);
        checkContract(_gasPoolAddress);
        checkContract(_collSurplusPoolAddress);
        checkContract(_lusdTokenAddress);
        checkContract(_sortedTrovesAddress);
        checkContract(_governanceAddress);
        checkContract(_wethAddress);

        borrowerOperationsAddress = _borrowerOperationsAddress;
        wethAddress = _wethAddress;
        activePool = IActivePool(_activePoolAddress);
        defaultPool = IDefaultPool(_defaultPoolAddress);
        stabilityPool = IStabilityPool(_stabilityPoolAddress);
        gasPoolAddress = _gasPoolAddress;
        collSurplusPool = ICollSurplusPool(_collSurplusPoolAddress);
        lusdToken = ILiquityLUSDToken(_lusdTokenAddress);
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
        governance = IGovernance(_governanceAddress);

        emit WETHAddressChanged(_wethAddress);
        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);
        emit GovernanceAddressChanged(_governanceAddress);
        emit ActivePoolAddressChanged(_activePoolAddress);
        emit DefaultPoolAddressChanged(_defaultPoolAddress);
        emit StabilityPoolAddressChanged(_stabilityPoolAddress);
        emit GasPoolAddressChanged(_gasPoolAddress);
        emit CollSurplusPoolAddressChanged(_collSurplusPoolAddress);
        emit LUSDTokenAddressChanged(_lusdTokenAddress);
        emit SortedTrovesAddressChanged(_sortedTrovesAddress);

        _renounceOwnership();
    }


    function getTroveOwnersCount() external view override returns (uint256) {

        return TroveOwners.length;
    }

    function getTroveFromTroveOwnersArray(uint256 _index) external view override returns (address) {

        return TroveOwners[_index];
    }


    function liquidate(address _borrower) external override {

        _requireTroveIsActive(_borrower);

        address[] memory borrowers = new address[](1);
        borrowers[0] = _borrower;
        batchLiquidateTroves(borrowers);
    }


    function _liquidateNormalMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        address _borrower,
        uint256 _LUSDInStabPool
    ) internal returns (LiquidationValues memory singleLiquidation) {

        LocalVariables_InnerSingleLiquidateFunction memory vars;

        (
            singleLiquidation.entireTroveDebt,
            singleLiquidation.entireTroveColl,
            vars.pendingDebtReward,
            vars.pendingCollReward
        ) = getEntireDebtAndColl(_borrower);

        _movePendingTroveRewardsToActivePool(
            _activePool,
            _defaultPool,
            vars.pendingDebtReward,
            vars.pendingCollReward
        );
        _removeStake(_borrower);

        singleLiquidation.collGasCompensation = _getCollGasCompensation(
            singleLiquidation.entireTroveColl
        );
        singleLiquidation.LUSDGasCompensation = LUSD_GAS_COMPENSATION;
        uint256 collToLiquidate = singleLiquidation.entireTroveColl.sub(
            singleLiquidation.collGasCompensation
        );

        (
            singleLiquidation.debtToOffset,
            singleLiquidation.collToSendToSP,
            singleLiquidation.debtToRedistribute,
            singleLiquidation.collToRedistribute
        ) = _getOffsetAndRedistributionVals(
            singleLiquidation.entireTroveDebt,
            collToLiquidate,
            _LUSDInStabPool
        );

        _closeTrove(_borrower, Status.closedByLiquidation);
        emit TroveLiquidated(
            _borrower,
            singleLiquidation.entireTroveDebt,
            singleLiquidation.entireTroveColl,
            TroveManagerOperation.liquidateInNormalMode
        );
        emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.liquidateInNormalMode);
        return singleLiquidation;
    }

    function _liquidateRecoveryMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        address _borrower,
        uint256 _ICR,
        uint256 _LUSDInStabPool,
        uint256 _TCR,
        uint256 _price
    ) internal returns (LiquidationValues memory singleLiquidation) {

        LocalVariables_InnerSingleLiquidateFunction memory vars;
        if (TroveOwners.length <= 1) {
            return singleLiquidation;
        } // don't liquidate if last trove
        (
            singleLiquidation.entireTroveDebt,
            singleLiquidation.entireTroveColl,
            vars.pendingDebtReward,
            vars.pendingCollReward
        ) = getEntireDebtAndColl(_borrower);

        singleLiquidation.collGasCompensation = _getCollGasCompensation(
            singleLiquidation.entireTroveColl
        );
        singleLiquidation.LUSDGasCompensation = LUSD_GAS_COMPENSATION;
        vars.collToLiquidate = singleLiquidation.entireTroveColl.sub(
            singleLiquidation.collGasCompensation
        );

        if (_ICR <= _100pct) {
            _movePendingTroveRewardsToActivePool(
                _activePool,
                _defaultPool,
                vars.pendingDebtReward,
                vars.pendingCollReward
            );
            _removeStake(_borrower);

            singleLiquidation.debtToOffset = 0;
            singleLiquidation.collToSendToSP = 0;
            singleLiquidation.debtToRedistribute = singleLiquidation.entireTroveDebt;
            singleLiquidation.collToRedistribute = vars.collToLiquidate;

            _closeTrove(_borrower, Status.closedByLiquidation);
            emit TroveLiquidated(
                _borrower,
                singleLiquidation.entireTroveDebt,
                singleLiquidation.entireTroveColl,
                TroveManagerOperation.liquidateInRecoveryMode
            );
            emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.liquidateInRecoveryMode);

        } else if ((_ICR > _100pct) && (_ICR < MCR)) {
            _movePendingTroveRewardsToActivePool(
                _activePool,
                _defaultPool,
                vars.pendingDebtReward,
                vars.pendingCollReward
            );
            _removeStake(_borrower);

            (
                singleLiquidation.debtToOffset,
                singleLiquidation.collToSendToSP,
                singleLiquidation.debtToRedistribute,
                singleLiquidation.collToRedistribute
            ) = _getOffsetAndRedistributionVals(
                singleLiquidation.entireTroveDebt,
                vars.collToLiquidate,
                _LUSDInStabPool
            );

            _closeTrove(_borrower, Status.closedByLiquidation);
            emit TroveLiquidated(
                _borrower,
                singleLiquidation.entireTroveDebt,
                singleLiquidation.entireTroveColl,
                TroveManagerOperation.liquidateInRecoveryMode
            );
            emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.liquidateInRecoveryMode);
        } else if (
            (_ICR >= MCR) && (_ICR < _TCR) && (singleLiquidation.entireTroveDebt <= _LUSDInStabPool)
        ) {
            _movePendingTroveRewardsToActivePool(
                _activePool,
                _defaultPool,
                vars.pendingDebtReward,
                vars.pendingCollReward
            );
            assert(_LUSDInStabPool != 0);

            _removeStake(_borrower);
            singleLiquidation = _getCappedOffsetVals(
                singleLiquidation.entireTroveDebt,
                singleLiquidation.entireTroveColl,
                _price
            );

            _closeTrove(_borrower, Status.closedByLiquidation);
            if (singleLiquidation.collSurplus > 0) {
                collSurplusPool.accountSurplus(_borrower, singleLiquidation.collSurplus);
            }

            emit TroveLiquidated(
                _borrower,
                singleLiquidation.entireTroveDebt,
                singleLiquidation.collToSendToSP,
                TroveManagerOperation.liquidateInRecoveryMode
            );
            emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.liquidateInRecoveryMode);
        } else {
            LiquidationValues memory zeroVals;
            return zeroVals;
        }

        return singleLiquidation;
    }

    function _getOffsetAndRedistributionVals(
        uint256 _debt,
        uint256 _coll,
        uint256 _LUSDInStabPool
    )
        internal
        pure
        returns (
            uint256 debtToOffset,
            uint256 collToSendToSP,
            uint256 debtToRedistribute,
            uint256 collToRedistribute
        )
    {

        if (_LUSDInStabPool > 0) {
            debtToOffset = LiquityMath._min(_debt, _LUSDInStabPool);
            collToSendToSP = _coll.mul(debtToOffset).div(_debt);
            debtToRedistribute = _debt.sub(debtToOffset);
            collToRedistribute = _coll.sub(collToSendToSP);
        } else {
            debtToOffset = 0;
            collToSendToSP = 0;
            debtToRedistribute = _debt;
            collToRedistribute = _coll;
        }
    }

    function _getCappedOffsetVals(
        uint256 _entireTroveDebt,
        uint256 _entireTroveColl,
        uint256 _price
    ) internal view returns (LiquidationValues memory singleLiquidation) {

        singleLiquidation.entireTroveDebt = _entireTroveDebt;
        singleLiquidation.entireTroveColl = _entireTroveColl;
        uint256 collToOffset = _entireTroveDebt.mul(MCR).div(_price);

        singleLiquidation.collGasCompensation = _getCollGasCompensation(collToOffset);
        singleLiquidation.LUSDGasCompensation = LUSD_GAS_COMPENSATION;

        singleLiquidation.debtToOffset = _entireTroveDebt;
        singleLiquidation.collToSendToSP = collToOffset.sub(singleLiquidation.collGasCompensation);
        singleLiquidation.collSurplus = _entireTroveColl.sub(collToOffset);
        singleLiquidation.debtToRedistribute = 0;
        singleLiquidation.collToRedistribute = 0;
    }

    function liquidateTroves(uint256 _n) external override {

        ContractsCache memory contractsCache = ContractsCache(
            activePool,
            defaultPool,
            ILiquityLUSDToken(address(0)),
            sortedTroves,
            ICollSurplusPool(address(0)),
            address(0),
            getPriceFeed(),
            governance
        );
        IStabilityPool stabilityPoolCached = stabilityPool;

        LocalVariables_OuterLiquidationFunction memory vars;

        LiquidationTotals memory totals;

        vars.price = contractsCache.priceFeed.fetchPrice();
        vars.LUSDInStabPool = stabilityPoolCached.getTotalLUSDDeposits();
        vars.recoveryModeAtStart = _checkRecoveryMode(vars.price);

        if (vars.recoveryModeAtStart) {
            totals = _getTotalsFromLiquidateTrovesSequence_RecoveryMode(
                contractsCache,
                vars.price,
                vars.LUSDInStabPool,
                _n
            );
        } else {
            totals = _getTotalsFromLiquidateTrovesSequence_NormalMode(
                contractsCache.activePool,
                contractsCache.defaultPool,
                vars.price,
                vars.LUSDInStabPool,
                _n
            );
        }

        require(totals.totalDebtInSequence > 0, "TroveManager: nothing to liquidate");

        stabilityPoolCached.offset(totals.totalDebtToOffset, totals.totalCollToSendToSP);
        _redistributeDebtAndColl(
            contractsCache.activePool,
            contractsCache.defaultPool,
            totals.totalDebtToRedistribute,
            totals.totalCollToRedistribute
        );
        if (totals.totalCollSurplus > 0) {
            contractsCache.activePool.sendETH(address(collSurplusPool), totals.totalCollSurplus);
        }

        _updateSystemSnapshots_excludeCollRemainder(
            contractsCache.activePool,
            totals.totalCollGasCompensation
        );

        vars.liquidatedDebt = totals.totalDebtInSequence;
        vars.liquidatedColl = totals.totalCollInSequence.sub(totals.totalCollGasCompensation).sub(
            totals.totalCollSurplus
        );
        emit Liquidation(
            vars.liquidatedDebt,
            vars.liquidatedColl,
            totals.totalCollGasCompensation,
            totals.totalLUSDGasCompensation
        );

        _sendGasCompensation(
            contractsCache.activePool,
            msg.sender,
            totals.totalLUSDGasCompensation,
            totals.totalCollGasCompensation
        );
    }

    function _getTotalsFromLiquidateTrovesSequence_RecoveryMode(
        ContractsCache memory _contractsCache,
        uint256 _price,
        uint256 _LUSDInStabPool,
        uint256 _n
    ) internal returns (LiquidationTotals memory totals) {

        LocalVariables_LiquidationSequence memory vars;
        LiquidationValues memory singleLiquidation;

        vars.remainingLUSDInStabPool = _LUSDInStabPool;
        vars.backToNormalMode = false;
        vars.entireSystemDebt = getEntireSystemDebt();
        vars.entireSystemColl = getEntireSystemColl();

        vars.user = _contractsCache.sortedTroves.getLast();
        address firstUser = _contractsCache.sortedTroves.getFirst();
        for (vars.i = 0; vars.i < _n && vars.user != firstUser; vars.i++) {
            address nextUser = _contractsCache.sortedTroves.getPrev(vars.user);

            vars.ICR = getCurrentICR(vars.user, _price);

            if (!vars.backToNormalMode) {
                if (vars.ICR >= MCR && vars.remainingLUSDInStabPool == 0) {
                    break;
                }

                uint256 TCR = LiquityMath._computeCR(
                    vars.entireSystemColl,
                    vars.entireSystemDebt,
                    _price
                );

                singleLiquidation = _liquidateRecoveryMode(
                    _contractsCache.activePool,
                    _contractsCache.defaultPool,
                    vars.user,
                    vars.ICR,
                    vars.remainingLUSDInStabPool,
                    TCR,
                    _price
                );

                vars.remainingLUSDInStabPool = vars.remainingLUSDInStabPool.sub(
                    singleLiquidation.debtToOffset
                );
                vars.entireSystemDebt = vars.entireSystemDebt.sub(singleLiquidation.debtToOffset);
                vars.entireSystemColl = vars
                .entireSystemColl
                .sub(singleLiquidation.collToSendToSP)
                .sub(singleLiquidation.collSurplus);

                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);

                vars.backToNormalMode = !_checkPotentialRecoveryMode(
                    vars.entireSystemColl,
                    vars.entireSystemDebt,
                    _price
                );
            } else if (vars.backToNormalMode && vars.ICR < MCR) {
                singleLiquidation = _liquidateNormalMode(
                    _contractsCache.activePool,
                    _contractsCache.defaultPool,
                    vars.user,
                    vars.remainingLUSDInStabPool
                );

                vars.remainingLUSDInStabPool = vars.remainingLUSDInStabPool.sub(
                    singleLiquidation.debtToOffset
                );

                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);
            } else break; // break if the loop reaches a Trove with ICR >= MCR

            vars.user = nextUser;
        }
    }

    function _getTotalsFromLiquidateTrovesSequence_NormalMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint256 _price,
        uint256 _LUSDInStabPool,
        uint256 _n
    ) internal returns (LiquidationTotals memory totals) {

        LocalVariables_LiquidationSequence memory vars;
        LiquidationValues memory singleLiquidation;
        ISortedTroves sortedTrovesCached = sortedTroves;

        vars.remainingLUSDInStabPool = _LUSDInStabPool;

        for (vars.i = 0; vars.i < _n; vars.i++) {
            vars.user = sortedTrovesCached.getLast();
            vars.ICR = getCurrentICR(vars.user, _price);

            if (vars.ICR < MCR) {
                singleLiquidation = _liquidateNormalMode(
                    _activePool,
                    _defaultPool,
                    vars.user,
                    vars.remainingLUSDInStabPool
                );

                vars.remainingLUSDInStabPool = vars.remainingLUSDInStabPool.sub(
                    singleLiquidation.debtToOffset
                );

                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);
            } else break; // break if the loop reaches a Trove with ICR >= MCR
        }
    }

    function batchLiquidateTroves(address[] memory _troveArray) public override {

        require(_troveArray.length != 0, "TroveManager: Calldata address array must not be empty");

        IActivePool activePoolCached = activePool;
        IDefaultPool defaultPoolCached = defaultPool;
        IStabilityPool stabilityPoolCached = stabilityPool;
        IPriceFeed priceFeed = getPriceFeed();

        LocalVariables_OuterLiquidationFunction memory vars;
        LiquidationTotals memory totals;

        vars.price = priceFeed.fetchPrice();
        vars.LUSDInStabPool = stabilityPoolCached.getTotalLUSDDeposits();
        vars.recoveryModeAtStart = _checkRecoveryMode(vars.price);

        if (vars.recoveryModeAtStart) {
            totals = _getTotalFromBatchLiquidate_RecoveryMode(
                activePoolCached,
                defaultPoolCached,
                vars.price,
                vars.LUSDInStabPool,
                _troveArray
            );
        } else {
            totals = _getTotalsFromBatchLiquidate_NormalMode(
                activePoolCached,
                defaultPoolCached,
                vars.price,
                vars.LUSDInStabPool,
                _troveArray
            );
        }

        require(totals.totalDebtInSequence > 0, "TroveManager: nothing to liquidate");

        stabilityPoolCached.offset(totals.totalDebtToOffset, totals.totalCollToSendToSP);
        _redistributeDebtAndColl(
            activePoolCached,
            defaultPoolCached,
            totals.totalDebtToRedistribute,
            totals.totalCollToRedistribute
        );
        if (totals.totalCollSurplus > 0) {
            activePoolCached.sendETH(address(collSurplusPool), totals.totalCollSurplus);
        }

        _updateSystemSnapshots_excludeCollRemainder(
            activePoolCached,
            totals.totalCollGasCompensation
        );

        vars.liquidatedDebt = totals.totalDebtInSequence;
        vars.liquidatedColl = totals.totalCollInSequence.sub(totals.totalCollGasCompensation).sub(
            totals.totalCollSurplus
        );
        emit Liquidation(
            vars.liquidatedDebt,
            vars.liquidatedColl,
            totals.totalCollGasCompensation,
            totals.totalLUSDGasCompensation
        );

        _sendGasCompensation(
            activePoolCached,
            msg.sender,
            totals.totalLUSDGasCompensation,
            totals.totalCollGasCompensation
        );
    }

    function _getTotalFromBatchLiquidate_RecoveryMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint256 _price,
        uint256 _LUSDInStabPool,
        address[] memory _troveArray
    ) internal returns (LiquidationTotals memory totals) {

        LocalVariables_LiquidationSequence memory vars;
        LiquidationValues memory singleLiquidation;

        vars.remainingLUSDInStabPool = _LUSDInStabPool;
        vars.backToNormalMode = false;
        vars.entireSystemDebt = getEntireSystemDebt();
        vars.entireSystemColl = getEntireSystemColl();

        for (vars.i = 0; vars.i < _troveArray.length; vars.i++) {
            vars.user = _troveArray[vars.i];
            if (Troves[vars.user].status != Status.active) {
                continue;
            }
            vars.ICR = getCurrentICR(vars.user, _price);

            if (!vars.backToNormalMode) {
                if (vars.ICR >= MCR && vars.remainingLUSDInStabPool == 0) {
                    continue;
                }

                uint256 TCR = LiquityMath._computeCR(
                    vars.entireSystemColl,
                    vars.entireSystemDebt,
                    _price
                );

                singleLiquidation = _liquidateRecoveryMode(
                    _activePool,
                    _defaultPool,
                    vars.user,
                    vars.ICR,
                    vars.remainingLUSDInStabPool,
                    TCR,
                    _price
                );

                vars.remainingLUSDInStabPool = vars.remainingLUSDInStabPool.sub(
                    singleLiquidation.debtToOffset
                );
                vars.entireSystemDebt = vars.entireSystemDebt.sub(singleLiquidation.debtToOffset);
                vars.entireSystemColl = vars.entireSystemColl.sub(singleLiquidation.collToSendToSP);

                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);

                vars.backToNormalMode = !_checkPotentialRecoveryMode(
                    vars.entireSystemColl,
                    vars.entireSystemDebt,
                    _price
                );
            } else if (vars.backToNormalMode && vars.ICR < MCR) {
                singleLiquidation = _liquidateNormalMode(
                    _activePool,
                    _defaultPool,
                    vars.user,
                    vars.remainingLUSDInStabPool
                );
                vars.remainingLUSDInStabPool = vars.remainingLUSDInStabPool.sub(
                    singleLiquidation.debtToOffset
                );

                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);
            } else continue; // In Normal Mode skip troves with ICR >= MCR
        }
    }

    function _getTotalsFromBatchLiquidate_NormalMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint256 _price,
        uint256 _LUSDInStabPool,
        address[] memory _troveArray
    ) internal returns (LiquidationTotals memory totals) {

        LocalVariables_LiquidationSequence memory vars;
        LiquidationValues memory singleLiquidation;

        vars.remainingLUSDInStabPool = _LUSDInStabPool;

        for (vars.i = 0; vars.i < _troveArray.length; vars.i++) {
            vars.user = _troveArray[vars.i];
            vars.ICR = getCurrentICR(vars.user, _price);

            if (vars.ICR < MCR) {
                singleLiquidation = _liquidateNormalMode(
                    _activePool,
                    _defaultPool,
                    vars.user,
                    vars.remainingLUSDInStabPool
                );
                vars.remainingLUSDInStabPool = vars.remainingLUSDInStabPool.sub(
                    singleLiquidation.debtToOffset
                );

                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);
            }
        }
    }


    function _addLiquidationValuesToTotals(
        LiquidationTotals memory oldTotals,
        LiquidationValues memory singleLiquidation
    ) internal pure returns (LiquidationTotals memory newTotals) {

        newTotals.totalCollGasCompensation = oldTotals.totalCollGasCompensation.add(
            singleLiquidation.collGasCompensation
        );
        newTotals.totalLUSDGasCompensation = oldTotals.totalLUSDGasCompensation.add(
            singleLiquidation.LUSDGasCompensation
        );
        newTotals.totalDebtInSequence = oldTotals.totalDebtInSequence.add(
            singleLiquidation.entireTroveDebt
        );
        newTotals.totalCollInSequence = oldTotals.totalCollInSequence.add(
            singleLiquidation.entireTroveColl
        );
        newTotals.totalDebtToOffset = oldTotals.totalDebtToOffset.add(
            singleLiquidation.debtToOffset
        );
        newTotals.totalCollToSendToSP = oldTotals.totalCollToSendToSP.add(
            singleLiquidation.collToSendToSP
        );
        newTotals.totalDebtToRedistribute = oldTotals.totalDebtToRedistribute.add(
            singleLiquidation.debtToRedistribute
        );
        newTotals.totalCollToRedistribute = oldTotals.totalCollToRedistribute.add(
            singleLiquidation.collToRedistribute
        );
        newTotals.totalCollSurplus = oldTotals.totalCollSurplus.add(singleLiquidation.collSurplus);

        return newTotals;
    }

    function _sendGasCompensation(
        IActivePool _activePool,
        address _liquidator,
        uint256 _LUSD,
        uint256 _ETH
    ) internal {

        if (_LUSD > 0) {
            lusdToken.returnFromPool(gasPoolAddress, _liquidator, _LUSD);
        }

        if (_ETH > 0) {
            _activePool.sendETH(_liquidator, _ETH);
        }
    }

    function _movePendingTroveRewardsToActivePool(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint256 _LUSD,
        uint256 _ETH
    ) internal {

        _defaultPool.decreaseLUSDDebt(_LUSD);
        _activePool.increaseLUSDDebt(_LUSD);
        _defaultPool.sendETHToActivePool(_ETH);
    }


    function _redeemCollateralFromTrove(
        ContractsCache memory _contractsCache,
        address _borrower,
        uint256 _maxLUSDamount,
        uint256 _price,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint256 _partialRedemptionHintNICR
    ) internal returns (SingleRedemptionValues memory singleRedemption) {

        singleRedemption.LUSDLot = LiquityMath._min(
            _maxLUSDamount,
            Troves[_borrower].debt.sub(LUSD_GAS_COMPENSATION)
        );

        singleRedemption.ETHLot = singleRedemption.LUSDLot.mul(DECIMAL_PRECISION).div(_price);

        uint256 newDebt = (Troves[_borrower].debt).sub(singleRedemption.LUSDLot);
        uint256 newColl = (Troves[_borrower].coll).sub(singleRedemption.ETHLot);

        if (newDebt == LUSD_GAS_COMPENSATION) {
            _removeStake(_borrower);
            _closeTrove(_borrower, Status.closedByRedemption);
            _redeemCloseTrove(_contractsCache, _borrower, LUSD_GAS_COMPENSATION, newColl);
            emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.redeemCollateral);
        } else {
            uint256 newNICR = LiquityMath._computeNominalCR(newColl, newDebt);

            if (newNICR != _partialRedemptionHintNICR || _getNetDebt(newDebt) < MIN_NET_DEBT) {
                singleRedemption.cancelledPartial = true;
                return singleRedemption;
            }

            _contractsCache.sortedTroves.reInsert(
                _borrower,
                newNICR,
                _upperPartialRedemptionHint,
                _lowerPartialRedemptionHint
            );

            Troves[_borrower].debt = newDebt;
            Troves[_borrower].coll = newColl;
            _updateStakeAndTotalStakes(_borrower);

            emit TroveUpdated(
                _borrower,
                newDebt,
                newColl,
                Troves[_borrower].stake,
                TroveManagerOperation.redeemCollateral
            );
        }

        return singleRedemption;
    }

    function _redeemCloseTrove(
        ContractsCache memory _contractsCache,
        address _borrower,
        uint256 _LUSD,
        uint256 _ETH
    ) internal {

        _contractsCache.lusdToken.burn(gasPoolAddress, _LUSD);
        _contractsCache.activePool.decreaseLUSDDebt(_LUSD);

        _contractsCache.collSurplusPool.accountSurplus(_borrower, _ETH);
        _contractsCache.activePool.sendETH(address(_contractsCache.collSurplusPool), _ETH);
    }

    function _isValidFirstRedemptionHint(
        ISortedTroves _sortedTroves,
        address _firstRedemptionHint,
        uint256 _price
    ) internal view returns (bool) {

        if (
            _firstRedemptionHint == address(0) ||
            !_sortedTroves.contains(_firstRedemptionHint) ||
            getCurrentICR(_firstRedemptionHint, _price) < MCR
        ) {
            return false;
        }

        address nextTrove = _sortedTroves.getNext(_firstRedemptionHint);
        return nextTrove == address(0) || getCurrentICR(nextTrove, _price) < MCR;
    }

    function redeemCollateral(
        uint256 _LUSDamount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint256 _partialRedemptionHintNICR,
        uint256 _maxIterations,
        uint256 _maxFeePercentage
    ) external override {

        ContractsCache memory contractsCache = ContractsCache(
            activePool,
            defaultPool,
            lusdToken,
            sortedTroves,
            collSurplusPool,
            gasPoolAddress,
            getPriceFeed(),
            governance
        );
        RedemptionTotals memory totals;

        _requireValidMaxFeePercentage(_maxFeePercentage);
        _requireAfterBootstrapPeriod();
        totals.price = contractsCache.priceFeed.fetchPrice();
        _requireTCRoverMCR(totals.price);
        _requireAmountGreaterThanZero(_LUSDamount);
        _requireLUSDBalanceCoversRedemption(contractsCache.lusdToken, msg.sender, _LUSDamount);

        totals.totalLUSDSupplyAtStart = getEntireSystemDebt();
        assert(contractsCache.lusdToken.balanceOf(msg.sender) <= totals.totalLUSDSupplyAtStart);

        totals.remainingLUSD = _LUSDamount;
        address currentBorrower;

        if (
            _isValidFirstRedemptionHint(
                contractsCache.sortedTroves,
                _firstRedemptionHint,
                totals.price
            )
        ) {
            currentBorrower = _firstRedemptionHint;
        } else {
            currentBorrower = contractsCache.sortedTroves.getLast();
            while (
                currentBorrower != address(0) && getCurrentICR(currentBorrower, totals.price) < MCR
            ) {
                currentBorrower = contractsCache.sortedTroves.getPrev(currentBorrower);
            }
        }

        if (_maxIterations == 0) {
            _maxIterations = uint256(999999999999999999999);
        }
        while (currentBorrower != address(0) && totals.remainingLUSD > 0 && _maxIterations > 0) {
            _maxIterations--;
            address nextUserToCheck = contractsCache.sortedTroves.getPrev(currentBorrower);

            _applyPendingRewards(
                contractsCache.activePool,
                contractsCache.defaultPool,
                currentBorrower
            );

            SingleRedemptionValues memory singleRedemption = _redeemCollateralFromTrove(
                contractsCache,
                currentBorrower,
                totals.remainingLUSD,
                totals.price,
                _upperPartialRedemptionHint,
                _lowerPartialRedemptionHint,
                _partialRedemptionHintNICR
            );

            if (singleRedemption.cancelledPartial) break; // Partial redemption was cancelled (out-of-date hint, or new net debt < minimum), therefore we could not redeem from the last Trove

            totals.totalLUSDToRedeem = totals.totalLUSDToRedeem.add(singleRedemption.LUSDLot);
            totals.totalETHDrawn = totals.totalETHDrawn.add(singleRedemption.ETHLot);

            totals.remainingLUSD = totals.remainingLUSD.sub(singleRedemption.LUSDLot);
            currentBorrower = nextUserToCheck;
        }
        require(totals.totalETHDrawn > 0, "TroveManager: Unable to redeem any amount");

        _updateBaseRateFromRedemption(
            totals.totalETHDrawn,
            totals.price,
            totals.totalLUSDSupplyAtStart
        );

        totals.ETHFee = _getRedemptionFee(totals.totalETHDrawn);

        _requireUserAcceptsFee(totals.ETHFee, totals.totalETHDrawn, _maxFeePercentage);

        contractsCache.activePool.sendETH(address(contractsCache.governance), totals.ETHFee);
        contractsCache.governance.sendToFund(wethAddress, totals.ETHFee, "Redeeming fee triggered");

        totals.ETHToSendToRedeemer = totals.totalETHDrawn.sub(totals.ETHFee);

        emit Redemption(_LUSDamount, totals.totalLUSDToRedeem, totals.totalETHDrawn, totals.ETHFee);

        contractsCache.lusdToken.burn(msg.sender, totals.totalLUSDToRedeem);
        contractsCache.activePool.decreaseLUSDDebt(totals.totalLUSDToRedeem);
        contractsCache.activePool.sendETH(msg.sender, totals.ETHToSendToRedeemer);
        contractsCache.governance.chargeStabilityFee(msg.sender, _LUSDamount);
    }


    function getNominalICR(address _borrower) public view override returns (uint256) {

        (uint256 currentETH, uint256 currentLUSDDebt) = _getCurrentTroveAmounts(_borrower);
        uint256 NICR = LiquityMath._computeNominalCR(currentETH, currentLUSDDebt);
        return NICR;
    }

    function getCurrentICR(address _borrower, uint256 _price)
        public
        view
        override
        returns (uint256)
    {

        (uint256 currentETH, uint256 currentLUSDDebt) = _getCurrentTroveAmounts(_borrower);

        uint256 ICR = LiquityMath._computeCR(currentETH, currentLUSDDebt, _price);
        return ICR;
    }

    function _getCurrentTroveAmounts(address _borrower) internal view returns (uint256, uint256) {

        uint256 pendingETHReward = getPendingETHReward(_borrower);
        uint256 pendingLUSDDebtReward = getPendingLUSDDebtReward(_borrower);

        uint256 currentETH = Troves[_borrower].coll.add(pendingETHReward);
        uint256 currentLUSDDebt = Troves[_borrower].debt.add(pendingLUSDDebtReward);

        return (currentETH, currentLUSDDebt);
    }

    function applyPendingRewards(address _borrower) external override {

        _requireCallerIsBorrowerOperations();
        return _applyPendingRewards(activePool, defaultPool, _borrower);
    }

    function _applyPendingRewards(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        address _borrower
    ) internal {

        if (hasPendingRewards(_borrower)) {
            _requireTroveIsActive(_borrower);

            uint256 pendingETHReward = getPendingETHReward(_borrower);
            uint256 pendingLUSDDebtReward = getPendingLUSDDebtReward(_borrower);

            Troves[_borrower].coll = Troves[_borrower].coll.add(pendingETHReward);
            Troves[_borrower].debt = Troves[_borrower].debt.add(pendingLUSDDebtReward);

            _updateTroveRewardSnapshots(_borrower);

            _movePendingTroveRewardsToActivePool(
                _activePool,
                _defaultPool,
                pendingLUSDDebtReward,
                pendingETHReward
            );

            emit TroveUpdated(
                _borrower,
                Troves[_borrower].debt,
                Troves[_borrower].coll,
                Troves[_borrower].stake,
                TroveManagerOperation.applyPendingRewards
            );
        }
    }

    function updateTroveRewardSnapshots(address _borrower) external override {

        _requireCallerIsBorrowerOperations();
        return _updateTroveRewardSnapshots(_borrower);
    }

    function _updateTroveRewardSnapshots(address _borrower) internal {

        rewardSnapshots[_borrower].ETH = L_ETH;
        rewardSnapshots[_borrower].LUSDDebt = L_LUSDDebt;
        emit TroveSnapshotsUpdated(L_ETH, L_LUSDDebt);
    }

    function getPendingETHReward(address _borrower) public view override returns (uint256) {

        uint256 snapshotETH = rewardSnapshots[_borrower].ETH;
        uint256 rewardPerUnitStaked = L_ETH.sub(snapshotETH);

        if (rewardPerUnitStaked == 0 || Troves[_borrower].status != Status.active) {
            return 0;
        }

        uint256 stake = Troves[_borrower].stake;

        uint256 pendingETHReward = stake.mul(rewardPerUnitStaked).div(DECIMAL_PRECISION);

        return pendingETHReward;
    }

    function getPendingLUSDDebtReward(address _borrower) public view override returns (uint256) {

        uint256 snapshotLUSDDebt = rewardSnapshots[_borrower].LUSDDebt;
        uint256 rewardPerUnitStaked = L_LUSDDebt.sub(snapshotLUSDDebt);

        if (rewardPerUnitStaked == 0 || Troves[_borrower].status != Status.active) {
            return 0;
        }

        uint256 stake = Troves[_borrower].stake;

        uint256 pendingLUSDDebtReward = stake.mul(rewardPerUnitStaked).div(DECIMAL_PRECISION);

        return pendingLUSDDebtReward;
    }

    function hasPendingRewards(address _borrower) public view override returns (bool) {

        if (Troves[_borrower].status != Status.active) {
            return false;
        }

        return (rewardSnapshots[_borrower].ETH < L_ETH);
    }

    function getEntireDebtAndColl(address _borrower)
        public
        view
        override
        returns (
            uint256 debt,
            uint256 coll,
            uint256 pendingLUSDDebtReward,
            uint256 pendingETHReward
        )
    {

        debt = Troves[_borrower].debt;
        coll = Troves[_borrower].coll;

        pendingLUSDDebtReward = getPendingLUSDDebtReward(_borrower);
        pendingETHReward = getPendingETHReward(_borrower);

        debt = debt.add(pendingLUSDDebtReward);
        coll = coll.add(pendingETHReward);
    }

    function removeStake(address _borrower) external override {

        _requireCallerIsBorrowerOperations();
        return _removeStake(_borrower);
    }

    function _removeStake(address _borrower) internal {

        uint256 stake = Troves[_borrower].stake;
        totalStakes = totalStakes.sub(stake);
        Troves[_borrower].stake = 0;
    }

    function updateStakeAndTotalStakes(address _borrower) external override returns (uint256) {

        _requireCallerIsBorrowerOperations();
        return _updateStakeAndTotalStakes(_borrower);
    }

    function _updateStakeAndTotalStakes(address _borrower) internal returns (uint256) {

        uint256 newStake = _computeNewStake(Troves[_borrower].coll);
        uint256 oldStake = Troves[_borrower].stake;
        Troves[_borrower].stake = newStake;

        totalStakes = totalStakes.sub(oldStake).add(newStake);
        emit TotalStakesUpdated(totalStakes);

        return newStake;
    }

    function _computeNewStake(uint256 _coll) internal view returns (uint256) {

        uint256 stake;
        if (totalCollateralSnapshot == 0) {
            stake = _coll;
        } else {
            assert(totalStakesSnapshot > 0);
            stake = _coll.mul(totalStakesSnapshot).div(totalCollateralSnapshot);
        }
        return stake;
    }

    function _redistributeDebtAndColl(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint256 _debt,
        uint256 _coll
    ) internal {

        if (_debt == 0) {
            return;
        }

        uint256 ETHNumerator = _coll.mul(DECIMAL_PRECISION).add(lastETHError_Redistribution);
        uint256 LUSDDebtNumerator = _debt.mul(DECIMAL_PRECISION).add(
            lastLUSDDebtError_Redistribution
        );

        uint256 ETHRewardPerUnitStaked = ETHNumerator.div(totalStakes);
        uint256 LUSDDebtRewardPerUnitStaked = LUSDDebtNumerator.div(totalStakes);

        lastETHError_Redistribution = ETHNumerator.sub(ETHRewardPerUnitStaked.mul(totalStakes));
        lastLUSDDebtError_Redistribution = LUSDDebtNumerator.sub(
            LUSDDebtRewardPerUnitStaked.mul(totalStakes)
        );

        L_ETH = L_ETH.add(ETHRewardPerUnitStaked);
        L_LUSDDebt = L_LUSDDebt.add(LUSDDebtRewardPerUnitStaked);

        emit LTermsUpdated(L_ETH, L_LUSDDebt);

        _activePool.decreaseLUSDDebt(_debt);
        _defaultPool.increaseLUSDDebt(_debt);
        _activePool.sendETH(address(_defaultPool), _coll);
    }

    function closeTrove(address _borrower) external override {

        _requireCallerIsBorrowerOperations();
        return _closeTrove(_borrower, Status.closedByOwner);
    }

    function _closeTrove(address _borrower, Status closedStatus) internal {

        assert(closedStatus != Status.nonExistent && closedStatus != Status.active);

        uint256 TroveOwnersArrayLength = TroveOwners.length;
        _requireMoreThanOneTroveInSystem(TroveOwnersArrayLength);

        Troves[_borrower].status = closedStatus;
        Troves[_borrower].coll = 0;
        Troves[_borrower].debt = 0;

        rewardSnapshots[_borrower].ETH = 0;
        rewardSnapshots[_borrower].LUSDDebt = 0;

        _removeTroveOwner(_borrower, TroveOwnersArrayLength);
        sortedTroves.remove(_borrower);
    }

    function _updateSystemSnapshots_excludeCollRemainder(
        IActivePool _activePool,
        uint256 _collRemainder
    ) internal {

        totalStakesSnapshot = totalStakes;

        uint256 activeColl = _activePool.getETH();
        uint256 liquidatedColl = defaultPool.getETH();
        totalCollateralSnapshot = activeColl.sub(_collRemainder).add(liquidatedColl);

        emit SystemSnapshotsUpdated(totalStakesSnapshot, totalCollateralSnapshot);
    }

    function addTroveOwnerToArray(address _borrower) external override returns (uint256 index) {

        _requireCallerIsBorrowerOperations();
        return _addTroveOwnerToArray(_borrower);
    }

    function _addTroveOwnerToArray(address _borrower) internal returns (uint128 index) {


        TroveOwners.push(_borrower);

        index = uint128(TroveOwners.length.sub(1));
        Troves[_borrower].arrayIndex = index;

        return index;
    }

    function _removeTroveOwner(address _borrower, uint256 TroveOwnersArrayLength) internal {

        Status troveStatus = Troves[_borrower].status;
        assert(troveStatus != Status.nonExistent && troveStatus != Status.active);

        uint128 index = Troves[_borrower].arrayIndex;
        uint256 length = TroveOwnersArrayLength;
        uint256 idxLast = length.sub(1);

        assert(index <= idxLast);

        address addressToMove = TroveOwners[idxLast];

        TroveOwners[index] = addressToMove;
        Troves[addressToMove].arrayIndex = index;
        emit TroveIndexUpdated(addressToMove, index);

        TroveOwners.pop();
    }


    function getTCR(uint256 _price) external view override returns (uint256) {

        return _getTCR(_price);
    }

    function checkRecoveryMode(uint256 _price) external view override returns (bool) {

        return _checkRecoveryMode(_price);
    }

    function _checkPotentialRecoveryMode(
        uint256 _entireSystemColl,
        uint256 _entireSystemDebt,
        uint256 _price
    ) internal view returns (bool) {

        uint256 TCR = LiquityMath._computeCR(_entireSystemColl, _entireSystemDebt, _price);
        return TCR < CCR;
    }


    function _updateBaseRateFromRedemption(
        uint256 _ETHDrawn,
        uint256 _price,
        uint256 _totalLUSDSupply
    ) internal returns (uint256) {

        uint256 decayedBaseRate = _calcDecayedBaseRate();

        uint256 redeemedLUSDFraction = _ETHDrawn.mul(_price).div(_totalLUSDSupply);

        uint256 newBaseRate = decayedBaseRate.add(redeemedLUSDFraction.div(BETA));
        newBaseRate = LiquityMath._min(newBaseRate, DECIMAL_PRECISION); // cap baseRate at a maximum of 100%
        assert(newBaseRate > 0); // Base rate is always non-zero after redemption

        baseRate = newBaseRate;
        emit BaseRateUpdated(newBaseRate);

        _updateLastFeeOpTime();

        return newBaseRate;
    }

    function getRedemptionRate() public view override returns (uint256) {

        return _calcRedemptionRate(baseRate);
    }

    function getRedemptionRateWithDecay() public view override returns (uint256) {

        return _calcRedemptionRate(_calcDecayedBaseRate());
    }

    function _calcRedemptionRate(uint256 _baseRate) internal view returns (uint256) {

        return
            LiquityMath._min(
                getRedemptionFeeFloor().add(_baseRate),
                DECIMAL_PRECISION // cap at a maximum of 100%
            );
    }

    function _getRedemptionFee(uint256 _ETHDrawn) internal view returns (uint256) {

        return _calcRedemptionFee(getRedemptionRate(), _ETHDrawn);
    }

    function getRedemptionFeeWithDecay(uint256 _ETHDrawn) external view override returns (uint256) {

        return _calcRedemptionFee(getRedemptionRateWithDecay(), _ETHDrawn);
    }

    function _calcRedemptionFee(uint256 _redemptionRate, uint256 _ETHDrawn)
        internal
        pure
        returns (uint256)
    {

        uint256 redemptionFee = _redemptionRate.mul(_ETHDrawn).div(DECIMAL_PRECISION);
        require(redemptionFee < _ETHDrawn, "TroveManager: Fee would eat up all returned collateral");
        return redemptionFee;
    }


    function getBorrowingRate() public view override returns (uint256) {

        return _calcBorrowingRate(baseRate);
    }

    function getBorrowingRateWithDecay() public view override returns (uint256) {

        return _calcBorrowingRate(_calcDecayedBaseRate());
    }

    function _calcBorrowingRate(uint256 _baseRate) internal view returns (uint256) {

        return LiquityMath._min(getBorrowingFeeFloor().add(_baseRate), getMaxBorrowingFee());
    }

    function getBorrowingFee(uint256 _LUSDDebt) external view override returns (uint256) {

        return _calcBorrowingFee(getBorrowingRate(), _LUSDDebt);
    }

    function getBorrowingFeeWithDecay(uint256 _LUSDDebt) external view override returns (uint256) {

        return _calcBorrowingFee(getBorrowingRateWithDecay(), _LUSDDebt);
    }

    function _calcBorrowingFee(uint256 _borrowingRate, uint256 _LUSDDebt)
        internal
        pure
        returns (uint256)
    {

        return _borrowingRate.mul(_LUSDDebt).div(DECIMAL_PRECISION);
    }

    function decayBaseRateFromBorrowing() external override {

        _requireCallerIsBorrowerOperations();

        uint256 decayedBaseRate = _calcDecayedBaseRate();
        assert(decayedBaseRate <= DECIMAL_PRECISION); // The baseRate can decay to 0

        baseRate = decayedBaseRate;
        emit BaseRateUpdated(decayedBaseRate);

        _updateLastFeeOpTime();
    }


    function _updateLastFeeOpTime() internal {

        uint256 timePassed = block.timestamp.sub(lastFeeOperationTime);

        if (timePassed >= SECONDS_IN_ONE_MINUTE) {
            lastFeeOperationTime = block.timestamp;
            emit LastFeeOpTimeUpdated(block.timestamp);
        }
    }

    function _calcDecayedBaseRate() internal view returns (uint256) {

        uint256 minutesPassed = _minutesPassedSinceLastFeeOp();
        uint256 decayFactor = LiquityMath._decPow(MINUTE_DECAY_FACTOR, minutesPassed);

        return baseRate.mul(decayFactor).div(DECIMAL_PRECISION);
    }

    function _minutesPassedSinceLastFeeOp() internal view returns (uint256) {

        return (block.timestamp.sub(lastFeeOperationTime)).div(SECONDS_IN_ONE_MINUTE);
    }


    function _requireCallerIsBorrowerOperations() internal view {

        require(
            msg.sender == borrowerOperationsAddress,
            "TroveManager: Caller is not the BorrowerOperations contract"
        );
    }

    function _requireTroveIsActive(address _borrower) internal view {

        require(
            Troves[_borrower].status == Status.active,
            "TroveManager: Trove does not exist or is closed"
        );
    }

    function _requireLUSDBalanceCoversRedemption(
        ILiquityLUSDToken _lusdToken,
        address _redeemer,
        uint256 _amount
    ) internal view {

        require(
            _lusdToken.balanceOf(_redeemer) >= _amount,
            "TroveManager: Requested redemption amount must be <= user's LUSD token balance"
        );
    }

    function _requireMoreThanOneTroveInSystem(uint256 TroveOwnersArrayLength) internal view {

        require(
            TroveOwnersArrayLength > 1 && sortedTroves.getSize() > 1,
            "TroveManager: Only one trove in the system"
        );
    }

    function _requireAmountGreaterThanZero(uint256 _amount) internal pure {

        require(_amount > 0, "TroveManager: Amount must be greater than zero");
    }

    function _requireTCRoverMCR(uint256 _price) internal view {

        require(_getTCR(_price) >= MCR, "TroveManager: Cannot redeem when TCR < MCR");
    }

    function _requireAfterBootstrapPeriod() internal view {

        uint256 systemDeploymentTime = governance.getDeploymentStartTime();
        require(
            block.timestamp >= systemDeploymentTime.add(BOOTSTRAP_PERIOD),
            "TroveManager: Redemptions are not allowed during bootstrap phase"
        );
    }

    function _requireValidMaxFeePercentage(uint256 _maxFeePercentage) internal view {

        require(
            _maxFeePercentage >= getRedemptionFeeFloor() && _maxFeePercentage <= DECIMAL_PRECISION,
            "Max fee percentage must be between min and 100%"
        );
    }


    function getTroveStatus(address _borrower) external view override returns (uint256) {

        return uint256(Troves[_borrower].status);
    }

    function getTroveStake(address _borrower) external view override returns (uint256) {

        return Troves[_borrower].stake;
    }

    function getTroveDebt(address _borrower) external view override returns (uint256) {

        return Troves[_borrower].debt;
    }

    function getTroveFrontEnd(address _borrower) external view override returns (address) {

        return Troves[_borrower].frontEndTag;
    }

    function getTroveColl(address _borrower) external view override returns (uint256) {

        return Troves[_borrower].coll;
    }


    function setTroveStatus(address _borrower, uint256 _num) external override {

        _requireCallerIsBorrowerOperations();
        Troves[_borrower].status = Status(_num);
    }

    function setTroveFrontEndTag(address _borrower, address _frontEndTag) external override {

        _requireCallerIsBorrowerOperations();
        Troves[_borrower].frontEndTag = _frontEndTag;
    }

    function increaseTroveColl(address _borrower, uint256 _collIncrease)
        external
        override
        returns (uint256)
    {

        _requireCallerIsBorrowerOperations();
        uint256 newColl = Troves[_borrower].coll.add(_collIncrease);
        Troves[_borrower].coll = newColl;
        return newColl;
    }

    function decreaseTroveColl(address _borrower, uint256 _collDecrease)
        external
        override
        returns (uint256)
    {

        _requireCallerIsBorrowerOperations();
        uint256 newColl = Troves[_borrower].coll.sub(_collDecrease);
        Troves[_borrower].coll = newColl;
        return newColl;
    }

    function increaseTroveDebt(address _borrower, uint256 _debtIncrease)
        external
        override
        returns (uint256)
    {

        _requireCallerIsBorrowerOperations();
        uint256 newDebt = Troves[_borrower].debt.add(_debtIncrease);
        Troves[_borrower].debt = newDebt;
        return newDebt;
    }

    function decreaseTroveDebt(address _borrower, uint256 _debtDecrease)
        external
        override
        returns (uint256)
    {

        _requireCallerIsBorrowerOperations();
        uint256 newDebt = Troves[_borrower].debt.sub(_debtDecrease);
        Troves[_borrower].debt = newDebt;
        return newDebt;
    }
}