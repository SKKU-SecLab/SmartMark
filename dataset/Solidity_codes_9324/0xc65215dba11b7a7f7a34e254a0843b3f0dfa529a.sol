
pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}


library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

library UInt256Lib {

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    function toInt256Safe(uint256 a) internal pure returns (int256) {

        require(a <= MAX_INT256);
        return int256(a);
    }
}

interface IOracle {

    function getData() external returns (uint256, bool);

}

interface B4seI {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external returns (uint256);


    function rebase(uint256 epoch, int256 supplyDelta)
        external
        returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);

}

interface StabilizerI {

    function owner() external returns (address);


    function checkStabilizerAndGetReward(
        int256 supplyDelta_,
        int256 rebaseLag_,
        uint256 exchangeRate_,
        uint256 b4sePolicyBalance
    ) external returns (uint256 rewardAmount_);

}

contract B4sePolicy is Ownable, Initializable {

    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch_,
        uint256 exchangeRate_,
        int256 requestedSupplyAdjustment_,
        int256 rebaseLag_,
        uint256 timestampSec_
    );

    event LogSetDeviationThreshold(
        uint256 lowerDeviationThreshold_,
        uint256 upperDeviationThreshold_
    );

    event LogSetDefaultRebaseLag(
        uint256 defaultPositiveRebaseLag_,
        uint256 defaultNegativeRebaseLag_
    );

    event LogSetUseDefaultRebaseLag(bool useDefaultRebaseLag_);

    event LogUsingDefaultRebaseLag(int256 defaultRebaseLag_);

    event LogSetRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_
    );

    event LogSetOracle(address oracle_);

    event LogNewLagBreakpoint(
        bool indexed selected,
        int256 indexed lowerDelta_,
        int256 indexed upperDelta_,
        int256 lag_
    );

    event LogUpdateBreakpoint(
        bool indexed selected,
        int256 indexed lowerDelta_,
        int256 indexed upperDelta_,
        int256 lag_
    );

    event LogDeleteBreakpoint(
        bool indexed selected,
        int256 lowerDelta_,
        int256 upperDelta_,
        int256 lag_
    );

    event LogSelectedBreakpoint(
        int256 lowerDelta_,
        int256 upperDelta_,
        int256 lag_
    );

    event LogSetPriceTargetRate(uint256 setPriceTargetRate_);

    event LogDeleteStabilizerPool(StabilizerI pool_);

    event LogAddNewStabilizerPool(StabilizerI pool_);

    event LogSetStabilizerPoolEnabled(uint256 index_, bool enabled_);

    event LogRewardSentToStabilizer(
        uint256 index,
        StabilizerI poolI,
        uint256 transferAmount
    );

    struct LagBreakpoint {
        int256 lowerDelta;
        int256 upperDelta;
        int256 lag;
    }

    struct StabilizerPool {
        bool enabled;
        StabilizerI pool;
    }

    B4seI public b4se;

    IOracle public oracle;

    uint256 public upperDeviationThreshold;
    uint256 public lowerDeviationThreshold;

    bool public useDefaultRebaseLag;

    uint256 public defaultPositiveRebaseLag;

    uint256 public defaultNegativeRebaseLag;

    LagBreakpoint[] public upperLagBreakpoints;
    LagBreakpoint[] public lowerLagBreakpoints;

    uint256 public minRebaseTimeIntervalSec;

    uint256 public lastRebaseTimestampSec;

    uint256 public rebaseWindowOffsetSec;

    uint256 public rebaseWindowLengthSec;

    StabilizerPool[] public stabilizerPools;

    uint256 public priceTargetRate = 10**DECIMALS;

    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    address public orchestrator;

    modifier onlyOrchestrator() {

        require(msg.sender == orchestrator);
        _;
    }

    modifier indexInBounds(uint256 index) {

        require(
            index < stabilizerPools.length,
            "Index must be less than array length"
        );
        _;
    }

    function initialize(address b4se_, address orchestrator_)
        external
        initializer
        onlyOwner
    {

        b4se = B4seI(b4se_);
        orchestrator = orchestrator_;

        upperDeviationThreshold = 5 * 10**(DECIMALS - 2);
        lowerDeviationThreshold = 5 * 10**(DECIMALS - 2);

        useDefaultRebaseLag = false;
        defaultPositiveRebaseLag = 30;
        defaultNegativeRebaseLag = 30;

        minRebaseTimeIntervalSec = 24 hours;
        lastRebaseTimestampSec = 0;
        rebaseWindowOffsetSec = 72000;
        rebaseWindowLengthSec = 15 minutes;

        priceTargetRate = 10**DECIMALS;

        epoch = 0;
    }

    function addNewStabilizerPool(address pool_) external onlyOwner {

        StabilizerPool memory instance = StabilizerPool(
            false,
            StabilizerI(pool_)
        );

        require(
            instance.pool.owner() == owner(),
            "Must have the same owner as policy contract"
        );

        stabilizerPools.push(instance);
        emit LogAddNewStabilizerPool(instance.pool);
    }

    function deleteStabilizerPool(uint256 index)
        external
        indexInBounds(index)
        onlyOwner
    {

        StabilizerPool memory instanceToDelete = stabilizerPools[index];
        require(
            !instanceToDelete.enabled,
            "Only a disabled pool can be deleted"
        );
        uint256 length = stabilizerPools.length.sub(1);
        if (index < length) {
            stabilizerPools[index] = stabilizerPools[length];
        }
        emit LogDeleteStabilizerPool(instanceToDelete.pool);
        stabilizerPools.pop();
        delete instanceToDelete;
    }

    function setStabilizerPoolEnabled(uint256 index, bool enabled)
        external
        indexInBounds(index)
        onlyOwner
    {

        StabilizerPool storage instance = stabilizerPools[index];
        instance.enabled = enabled;
        emit LogSetStabilizerPoolEnabled(index, instance.enabled);
    }

    function setPriceTargetRate(uint256 priceTargetRate_) external onlyOwner {

        require(priceTargetRate_ > 0);
        priceTargetRate = priceTargetRate_;
        emit LogSetPriceTargetRate(priceTargetRate_);
    }

    function setOracle(address oracle_) external onlyOwner {

        oracle = IOracle(oracle_);
        emit LogSetOracle(oracle_);
    }

    function rebase() external onlyOrchestrator {

        require(inRebaseWindow(), "Not in rebase window");

        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);

        lastRebaseTimestampSec = now.sub(now.mod(minRebaseTimeIntervalSec)).add(
            rebaseWindowOffsetSec
        );

        epoch = epoch.add(1);

        uint256 exchangeRate;
        bool rateValid;
        (exchangeRate, rateValid) = oracle.getData();
        require(rateValid);

        if (exchangeRate > MAX_RATE) {
            exchangeRate = MAX_RATE;
        }

        int256 supplyDelta = computeSupplyDelta(exchangeRate, priceTargetRate);
        int256 rebaseLag;

        if (supplyDelta != 0) {
            rebaseLag = getRebaseLag(supplyDelta);

            supplyDelta = supplyDelta.div(rebaseLag);
        }

        if (
            supplyDelta > 0 &&
            b4se.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY
        ) {
            supplyDelta = (MAX_SUPPLY.sub(b4se.totalSupply())).toInt256Safe();
        }

        checkStabilizers(supplyDelta, rebaseLag, exchangeRate);

        uint256 supplyAfterRebase = b4se.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        emit LogRebase(epoch, exchangeRate, supplyDelta, rebaseLag, now);
    }

    function updateSupplyDelta(int256 supplyDelta) external onlyOwner {

        
        epoch = epoch.add(1);

        uint256 supplyAfterRebase = b4se.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
    }

    function checkStabilizers(
        int256 supplyDelta_,
        int256 rebaseLag_,
        uint256 exchangeRate_
    ) internal {

        for (
            uint256 index = 0;
            index < stabilizerPools.length;
            index = index.add(1)
        ) {
            StabilizerPool memory instance = stabilizerPools[index];
            if (instance.enabled) {
                uint256 rewardToTransfer = instance
                    .pool
                    .checkStabilizerAndGetReward(
                    supplyDelta_,
                    rebaseLag_,
                    exchangeRate_,
                    b4se.balanceOf(address(this))
                );

                if (rewardToTransfer != 0) {
                    b4se.transfer(address(instance.pool), rewardToTransfer);
                    emit LogRewardSentToStabilizer(
                        index,
                        instance.pool,
                        rewardToTransfer
                    );
                }
            }
        }
    }

    function getRebaseLag(int256 supplyDelta_) private returns (int256) {

        int256 lag;
        int256 supplyDeltaAbs = supplyDelta_.abs();

        if (!useDefaultRebaseLag) {
            if (supplyDelta_ < 0) {
                lag = findBreakpoint(supplyDeltaAbs, lowerLagBreakpoints);
            } else {
                lag = findBreakpoint(supplyDeltaAbs, upperLagBreakpoints);
            }
            if (lag != 0) {
                return lag;
            }
        }

        if (supplyDelta_ < 0) {
            emit LogUsingDefaultRebaseLag(
                defaultNegativeRebaseLag.toInt256Safe()
            );
            return defaultNegativeRebaseLag.toInt256Safe();
        } else {
            emit LogUsingDefaultRebaseLag(
                defaultPositiveRebaseLag.toInt256Safe()
            );
            return defaultPositiveRebaseLag.toInt256Safe();
        }
    }

    function findBreakpoint(int256 supplyDelta, LagBreakpoint[] memory array)
        internal
        returns (int256)
    {

        LagBreakpoint memory instance;

        for (uint256 index = 0; index < array.length; index = index.add(1)) {
            instance = array[index];

            if (supplyDelta < instance.lowerDelta) {
                break;
            }
            if (supplyDelta <= instance.upperDelta) {
                emit LogSelectedBreakpoint(
                    instance.lowerDelta,
                    instance.upperDelta,
                    instance.lag
                );
                return instance.lag;
            }
        }
        return 0;
    }

    function setDefaultRebaseLags(
        uint256 defaultPositiveRebaseLag_,
        uint256 defaultNegativeRebaseLag_
    ) external onlyOwner {

        require(
            defaultPositiveRebaseLag_ > 0 && defaultNegativeRebaseLag_ > 0,
            "Lag must be greater than zero"
        );

        defaultPositiveRebaseLag = defaultPositiveRebaseLag_;
        defaultNegativeRebaseLag = defaultNegativeRebaseLag_;
        emit LogSetDefaultRebaseLag(
            defaultPositiveRebaseLag,
            defaultNegativeRebaseLag
        );
    }

    function setUseDefaultRebaseLag(bool useDefaultRebaseLag_)
        external
        onlyOwner
    {

        useDefaultRebaseLag = useDefaultRebaseLag_;
        emit LogSetUseDefaultRebaseLag(useDefaultRebaseLag);
    }

    function addNewLagBreakpoint(
        bool select,
        int256 lowerDelta_,
        int256 upperDelta_,
        int256 lag_
    ) public onlyOwner {

        require(
            lowerDelta_ >= 0 && lowerDelta_ < upperDelta_,
            "Lower delta must be less than upper delta"
        );
        require(lag_ > 0, "Lag can't be zero");

        LagBreakpoint memory newPoint = LagBreakpoint(
            lowerDelta_,
            upperDelta_,
            lag_
        );

        LagBreakpoint memory lastPoint;
        uint256 length;

        if (select) {
            length = upperLagBreakpoints.length;
            if (length > 0) {
                lastPoint = upperLagBreakpoints[length.sub(1)];
                require(lastPoint.upperDelta <= lowerDelta_);
            }

            upperLagBreakpoints.push(newPoint);
        } else {
            length = lowerLagBreakpoints.length;
            if (length > 0) {
                lastPoint = lowerLagBreakpoints[length.sub(1)];
                require(lastPoint.upperDelta <= lowerDelta_);
            }

            lowerLagBreakpoints.push(newPoint);
        }
        emit LogNewLagBreakpoint(select, lowerDelta_, upperDelta_, lag_);
    }

    function updateLagBreakpoint(
        bool select,
        uint256 index,
        int256 lowerDelta_,
        int256 upperDelta_,
        int256 lag_
    ) public onlyOwner {

        LagBreakpoint storage instance;

        require(
            lowerDelta_ >= 0 && lowerDelta_ < upperDelta_,
            "Lower delta must be less than upper delta"
        );
        require(lag_ > 0, "Lag can't be zero");

        if (select) {
            withinPointRange(
                index,
                lowerDelta_,
                upperDelta_,
                upperLagBreakpoints
            );
            instance = upperLagBreakpoints[index];
        } else {
            withinPointRange(
                index,
                lowerDelta_,
                upperDelta_,
                lowerLagBreakpoints
            );
            instance = lowerLagBreakpoints[index];
        }
        instance.lowerDelta = lowerDelta_;
        instance.upperDelta = upperDelta_;
        instance.lag = lag_;
        emit LogUpdateBreakpoint(select, lowerDelta_, upperDelta_, lag_);
    }

    function withinPointRange(
        uint256 index,
        int256 lowerDelta_,
        int256 upperDelta_,
        LagBreakpoint[] memory array
    ) internal pure {

        uint256 length = array.length;
        require(length > 0, "Can't update empty breakpoint array");
        require(index <= length.sub(1), "Index higher than elements avaiable");

        LagBreakpoint memory lowerPoint;
        LagBreakpoint memory upperPoint;

        if (index == 0) {
            if (length == 1) {
                return;
            }
            upperPoint = array[index.add(1)];
            require(upperDelta_ <= upperPoint.lowerDelta);
        } else if (index == length.sub(1)) {
            lowerPoint = array[index.sub(1)];
            require(lowerDelta_ >= lowerPoint.upperDelta);
        } else {
            upperPoint = array[index.add(1)];
            lowerPoint = array[index.sub(1)];
            require(
                lowerDelta_ >= lowerPoint.upperDelta &&
                    upperDelta_ <= upperPoint.lowerDelta
            );
        }
    }

    function deleteLagBreakpoint(bool select) public onlyOwner {

        LagBreakpoint memory instanceToDelete;
        if (select) {
            require(
                upperLagBreakpoints.length > 0,
                "Can't delete empty breakpoint array"
            );
            instanceToDelete = upperLagBreakpoints[upperLagBreakpoints
                .length
                .sub(1)];
            upperLagBreakpoints.pop();
        } else {
            require(
                lowerLagBreakpoints.length > 0,
                "Can't delete empty breakpoint array"
            );
            instanceToDelete = lowerLagBreakpoints[lowerLagBreakpoints
                .length
                .sub(1)];
            lowerLagBreakpoints.pop();
        }
        emit LogDeleteBreakpoint(
            select,
            instanceToDelete.lowerDelta,
            instanceToDelete.upperDelta,
            instanceToDelete.lag
        );
        delete instanceToDelete;
    }

    function setDeviationThresholds(
        uint256 upperDeviationThreshold_,
        uint256 lowerDeviationThreshold_
    ) external onlyOwner {

        upperDeviationThreshold = upperDeviationThreshold_;
        lowerDeviationThreshold = lowerDeviationThreshold_;
        emit LogSetDeviationThreshold(
            upperDeviationThreshold,
            lowerDeviationThreshold
        );
    }

    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_
    ) external onlyOwner {

        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;

        emit LogSetRebaseTimingParameters(
            minRebaseTimeIntervalSec_,
            rebaseWindowOffsetSec_,
            rebaseWindowLengthSec_
        );
    }

    function inRebaseWindow() public view returns (bool) {

        return (now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            now.mod(minRebaseTimeIntervalSec) <
            (rebaseWindowOffsetSec.add(rebaseWindowLengthSec)));
    }

    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        private
        view
        returns (int256)
    {

        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

        int256 targetRateSigned = targetRate.toInt256Safe();
        return
            b4se
                .totalSupply()
                .toInt256Safe()
                .mul(rate.toInt256Safe().sub(targetRateSigned))
                .div(targetRateSigned);
    }

    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        private
        view
        returns (bool)
    {

        uint256 upperThreshold = targetRate.mul(upperDeviationThreshold).div(
            10**DECIMALS
        );

        uint256 lowerThreshold = targetRate.mul(lowerDeviationThreshold).div(
            10**DECIMALS
        );

        return
            (rate >= targetRate && rate.sub(targetRate) < upperThreshold) ||
            (rate < targetRate && targetRate.sub(rate) < lowerThreshold);
    }
}