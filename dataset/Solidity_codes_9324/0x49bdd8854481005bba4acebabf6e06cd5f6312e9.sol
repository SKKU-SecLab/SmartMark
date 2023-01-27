

pragma solidity 0.6.6;

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

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }
}


pragma solidity 0.6.6;

interface IEpochUtils {

    function epochPeriodInSeconds() external view returns (uint256);


    function firstEpochStartTimestamp() external view returns (uint256);


    function getCurrentEpochNumber() external view returns (uint256);


    function getEpochNumber(uint256 timestamp) external view returns (uint256);

}


pragma solidity 0.6.6;



contract EpochUtils is IEpochUtils {

    using SafeMath for uint256;

    uint256 public override epochPeriodInSeconds;
    uint256 public override firstEpochStartTimestamp;

    function getCurrentEpochNumber() public view override returns (uint256) {

        return getEpochNumber(now);
    }

    function getEpochNumber(uint256 timestamp) public view override returns (uint256) {

        if (timestamp < firstEpochStartTimestamp || epochPeriodInSeconds == 0) {
            return 0;
        }
        return ((timestamp.sub(firstEpochStartTimestamp)).div(epochPeriodInSeconds)).add(1);
    }
}


pragma solidity 0.6.6;


contract DaoOperator {

    address public daoOperator;

    constructor(address _daoOperator) public {
        require(_daoOperator != address(0), "daoOperator is 0");
        daoOperator = _daoOperator;
    }

    modifier onlyDaoOperator() {

        require(msg.sender == daoOperator, "only daoOperator");
        _;
    }
}


pragma solidity 0.6.6;


interface IERC20 {

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function approve(address _spender, uint256 _value) external returns (bool success);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function decimals() external view returns (uint8 digits);


    function totalSupply() external view returns (uint256 supply);

}


abstract contract ERC20 is IERC20 {

}


pragma solidity 0.6.6;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


pragma solidity 0.6.6;



interface IKyberStaking is IEpochUtils {

    event Delegated(
        address indexed staker,
        address indexed representative,
        uint256 indexed epoch,
        bool isDelegated
    );
    event Deposited(uint256 curEpoch, address indexed staker, uint256 amount);
    event Withdraw(uint256 indexed curEpoch, address indexed staker, uint256 amount);

    function initAndReturnStakerDataForCurrentEpoch(address staker)
        external
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );


    function deposit(uint256 amount) external;


    function delegate(address dAddr) external;


    function withdraw(uint256 amount) external;


    function getStakerData(address staker, uint256 epoch)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );


    function getLatestStakerData(address staker)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );


    function getStakerRawData(address staker, uint256 epoch)
        external
        view
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        );

}


pragma solidity 0.6.6;



interface IKyberDao is IEpochUtils {

    event Voted(address indexed staker, uint indexed epoch, uint indexed campaignID, uint option);

    function getLatestNetworkFeeDataWithCache()
        external
        returns (uint256 feeInBps, uint256 expiryTimestamp);


    function getLatestBRRDataWithCache()
        external
        returns (
            uint256 burnInBps,
            uint256 rewardInBps,
            uint256 rebateInBps,
            uint256 epoch,
            uint256 expiryTimestamp
        );


    function handleWithdrawal(address staker, uint256 penaltyAmount) external;


    function vote(uint256 campaignID, uint256 option) external;


    function getLatestNetworkFeeData()
        external
        view
        returns (uint256 feeInBps, uint256 expiryTimestamp);


    function shouldBurnRewardForEpoch(uint256 epoch) external view returns (bool);


    function getPastEpochRewardPercentageInPrecision(address staker, uint256 epoch)
        external
        view
        returns (uint256);


    function getCurrentEpochRewardPercentageInPrecision(address staker)
        external
        view
        returns (uint256);

}


pragma solidity 0.6.6;







contract KyberStaking is IKyberStaking, EpochUtils, ReentrancyGuard {

    struct StakerData {
        uint256 stake;
        uint256 delegatedStake;
        address representative;
    }

    IERC20 public immutable kncToken;
    IKyberDao public immutable kyberDao;

    mapping(uint256 => mapping(address => StakerData)) internal stakerPerEpochData;
    mapping(address => StakerData) internal stakerLatestData;
    mapping(uint256 => mapping(address => bool)) internal hasInited;

    event WithdrawDataUpdateFailed(uint256 curEpoch, address staker, uint256 amount);

    constructor(
        IERC20 _kncToken,
        uint256 _epochPeriod,
        uint256 _startTimestamp,
        IKyberDao _kyberDao
    ) public {
        require(_epochPeriod > 0, "ctor: epoch period is 0");
        require(_startTimestamp >= now, "ctor: start in the past");
        require(_kncToken != IERC20(0), "ctor: kncToken 0");
        require(_kyberDao != IKyberDao(0), "ctor: kyberDao 0");

        epochPeriodInSeconds = _epochPeriod;
        firstEpochStartTimestamp = _startTimestamp;
        kncToken = _kncToken;
        kyberDao = _kyberDao;
    }

    function delegate(address newRepresentative) external override {

        require(newRepresentative != address(0), "delegate: representative 0");
        address staker = msg.sender;
        uint256 curEpoch = getCurrentEpochNumber();

        initDataIfNeeded(staker, curEpoch);

        address curRepresentative = stakerPerEpochData[curEpoch + 1][staker].representative;
        if (newRepresentative == curRepresentative) {
            return;
        }

        uint256 updatedStake = stakerPerEpochData[curEpoch + 1][staker].stake;

        if (curRepresentative != staker) {
            initDataIfNeeded(curRepresentative, curEpoch);

            stakerPerEpochData[curEpoch + 1][curRepresentative].delegatedStake =
                stakerPerEpochData[curEpoch + 1][curRepresentative].delegatedStake.sub(updatedStake);
            stakerLatestData[curRepresentative].delegatedStake =
                stakerLatestData[curRepresentative].delegatedStake.sub(updatedStake);

            emit Delegated(staker, curRepresentative, curEpoch, false);
        }

        stakerLatestData[staker].representative = newRepresentative;
        stakerPerEpochData[curEpoch + 1][staker].representative = newRepresentative;

        if (newRepresentative != staker) {
            initDataIfNeeded(newRepresentative, curEpoch);
            stakerPerEpochData[curEpoch + 1][newRepresentative].delegatedStake =
                stakerPerEpochData[curEpoch + 1][newRepresentative].delegatedStake.add(updatedStake);
            stakerLatestData[newRepresentative].delegatedStake =
                stakerLatestData[newRepresentative].delegatedStake.add(updatedStake);
            emit Delegated(staker, newRepresentative, curEpoch, true);
        }
    }

    function deposit(uint256 amount) external override {

        require(amount > 0, "deposit: amount is 0");

        uint256 curEpoch = getCurrentEpochNumber();
        address staker = msg.sender;

        require(
            kncToken.transferFrom(staker, address(this), amount),
            "deposit: can not get token"
        );

        initDataIfNeeded(staker, curEpoch);

        stakerPerEpochData[curEpoch + 1][staker].stake =
            stakerPerEpochData[curEpoch + 1][staker].stake.add(amount);
        stakerLatestData[staker].stake =
            stakerLatestData[staker].stake.add(amount);

        address representative = stakerPerEpochData[curEpoch + 1][staker].representative;
        if (representative != staker) {
            initDataIfNeeded(representative, curEpoch);
            stakerPerEpochData[curEpoch + 1][representative].delegatedStake =
                stakerPerEpochData[curEpoch + 1][representative].delegatedStake.add(amount);
            stakerLatestData[representative].delegatedStake =
                stakerLatestData[representative].delegatedStake.add(amount);
        }

        emit Deposited(curEpoch, staker, amount);
    }

    function withdraw(uint256 amount) external override nonReentrant {

        require(amount > 0, "withdraw: amount is 0");

        uint256 curEpoch = getCurrentEpochNumber();
        address staker = msg.sender;

        require(
            stakerLatestData[staker].stake >= amount,
            "withdraw: latest amount staked < withdrawal amount"
        );

        (bool success, ) = address(this).call(
            abi.encodeWithSignature(
                "handleWithdrawal(address,uint256,uint256)",
                staker,
                amount,
                curEpoch
            )
        );
        if (!success) {
            emit WithdrawDataUpdateFailed(curEpoch, staker, amount);
        }

        stakerLatestData[staker].stake = stakerLatestData[staker].stake.sub(amount);

        require(kncToken.transfer(staker, amount), "withdraw: can not transfer knc");
        emit Withdraw(curEpoch, staker, amount);
    }

    function initAndReturnStakerDataForCurrentEpoch(address staker)
        external
        override
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        )
    {

        require(
            msg.sender == address(kyberDao),
            "initAndReturnData: only kyberDao"
        );

        uint256 curEpoch = getCurrentEpochNumber();
        initDataIfNeeded(staker, curEpoch);

        StakerData memory stakerData = stakerPerEpochData[curEpoch][staker];
        stake = stakerData.stake;
        delegatedStake = stakerData.delegatedStake;
        representative = stakerData.representative;
    }

    function getStakerRawData(address staker, uint256 epoch)
        external
        view
        override
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        )
    {

        StakerData memory stakerData = stakerPerEpochData[epoch][staker];
        stake = stakerData.stake;
        delegatedStake = stakerData.delegatedStake;
        representative = stakerData.representative;
    }

    function getStake(address staker, uint256 epoch) external view returns (uint256) {

        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch > curEpoch + 1) {
            return 0;
        }
        uint256 i = epoch;
        while (true) {
            if (hasInited[i][staker]) {
                return stakerPerEpochData[i][staker].stake;
            }
            if (i == 0) {
                break;
            }
            i--;
        }
        return 0;
    }

    function getDelegatedStake(address staker, uint256 epoch) external view returns (uint256) {

        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch > curEpoch + 1) {
            return 0;
        }
        uint256 i = epoch;
        while (true) {
            if (hasInited[i][staker]) {
                return stakerPerEpochData[i][staker].delegatedStake;
            }
            if (i == 0) {
                break;
            }
            i--;
        }
        return 0;
    }

    function getRepresentative(address staker, uint256 epoch) external view returns (address) {

        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch > curEpoch + 1) {
            return address(0);
        }
        uint256 i = epoch;
        while (true) {
            if (hasInited[i][staker]) {
                return stakerPerEpochData[i][staker].representative;
            }
            if (i == 0) {
                break;
            }
            i--;
        }
        return staker;
    }

    function getStakerData(address staker, uint256 epoch)
        external view override
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        )
    {

        stake = 0;
        delegatedStake = 0;
        representative = address(0);

        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch > curEpoch + 1) {
            return (stake, delegatedStake, representative);
        }
        uint256 i = epoch;
        while (true) {
            if (hasInited[i][staker]) {
                stake = stakerPerEpochData[i][staker].stake;
                delegatedStake = stakerPerEpochData[i][staker].delegatedStake;
                representative = stakerPerEpochData[i][staker].representative;
                return (stake, delegatedStake, representative);
            }
            if (i == 0) {
                break;
            }
            i--;
        }
        representative = staker;
    }

    function getLatestRepresentative(address staker) external view returns (address) {

        return
            stakerLatestData[staker].representative == address(0)
                ? staker
                : stakerLatestData[staker].representative;
    }

    function getLatestDelegatedStake(address staker) external view returns (uint256) {

        return stakerLatestData[staker].delegatedStake;
    }

    function getLatestStakeBalance(address staker) external view returns (uint256) {

        return stakerLatestData[staker].stake;
    }

    function getLatestStakerData(address staker)
        external view override
        returns (
            uint256 stake,
            uint256 delegatedStake,
            address representative
        )
    {

        stake = stakerLatestData[staker].stake;
        delegatedStake = stakerLatestData[staker].delegatedStake;
        representative = stakerLatestData[staker].representative == address(0)
                ? staker
                : stakerLatestData[staker].representative;
    }

    function handleWithdrawal(
        address staker,
        uint256 amount,
        uint256 curEpoch
    ) external {

        require(msg.sender == address(this), "only staking contract");
        initDataIfNeeded(staker, curEpoch);
        stakerPerEpochData[curEpoch + 1][staker].stake =
            stakerPerEpochData[curEpoch + 1][staker].stake.sub(amount);

        address representative = stakerPerEpochData[curEpoch][staker].representative;
        uint256 curStake = stakerPerEpochData[curEpoch][staker].stake;
        uint256 lStakeBal = stakerLatestData[staker].stake.sub(amount);
        uint256 newStake = curStake.min(lStakeBal);
        uint256 reduceAmount = curStake.sub(newStake); // newStake is always <= curStake

        if (reduceAmount > 0) {
            if (representative != staker) {
                initDataIfNeeded(representative, curEpoch);
                stakerPerEpochData[curEpoch][representative].delegatedStake =
                    stakerPerEpochData[curEpoch][representative].delegatedStake.sub(reduceAmount);
            }
            stakerPerEpochData[curEpoch][staker].stake = newStake;
            if (address(kyberDao) != address(0)) {
                (bool success, ) = address(kyberDao).call(
                    abi.encodeWithSignature(
                        "handleWithdrawal(address,uint256)",
                        representative,
                        reduceAmount
                    )
                );
                if (!success) {
                    emit WithdrawDataUpdateFailed(curEpoch, staker, amount);
                }
            }
        }
        representative = stakerPerEpochData[curEpoch + 1][staker].representative;
        if (representative != staker) {
            initDataIfNeeded(representative, curEpoch);
            stakerPerEpochData[curEpoch + 1][representative].delegatedStake =
                stakerPerEpochData[curEpoch + 1][representative].delegatedStake.sub(amount);
            stakerLatestData[representative].delegatedStake =
                stakerLatestData[representative].delegatedStake.sub(amount);
        }
    }

    function initDataIfNeeded(address staker, uint256 epoch) internal {

        address representative = stakerLatestData[staker].representative;
        if (representative == address(0)) {
            stakerLatestData[staker].representative = staker;
            representative = staker;
        }

        uint256 ldStake = stakerLatestData[staker].delegatedStake;
        uint256 lStakeBal = stakerLatestData[staker].stake;

        if (!hasInited[epoch][staker]) {
            hasInited[epoch][staker] = true;
            StakerData storage stakerData = stakerPerEpochData[epoch][staker];
            stakerData.representative = representative;
            stakerData.delegatedStake = ldStake;
            stakerData.stake = lStakeBal;
        }

        if (!hasInited[epoch + 1][staker]) {
            hasInited[epoch + 1][staker] = true;
            StakerData storage nextEpochStakerData = stakerPerEpochData[epoch + 1][staker];
            nextEpochStakerData.representative = representative;
            nextEpochStakerData.delegatedStake = ldStake;
            nextEpochStakerData.stake = lStakeBal;
        }
    }
}


pragma solidity 0.6.6;



contract Utils5 {

    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20 => uint256) internal decimals;

    function getUpdateDecimals(IERC20 token) internal returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint256 tokenDecimals = decimals[token];
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }

        return tokenDecimals;
    }

    function setDecimals(IERC20 token) internal {

        if (decimals[token] != 0) return; //already set

        if (token == ETH_TOKEN_ADDRESS) {
            decimals[token] = ETH_DECIMALS;
        } else {
            decimals[token] = token.decimals();
        }
    }

    function getBalance(IERC20 token, address user) internal view returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    function getDecimals(IERC20 token) internal view returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint256 tokenDecimals = decimals[token];
        if (tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDestAmount(
        IERC20 src,
        IERC20 dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {

        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20 src,
        IERC20 dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {

        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {

        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {

        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {

        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? y : x;
    }
}


pragma solidity 0.6.6;








contract KyberDao is IKyberDao, EpochUtils, ReentrancyGuard, Utils5, DaoOperator {

    uint256 public   constant MAX_EPOCH_CAMPAIGNS = 10;
    uint256 public   constant MAX_CAMPAIGN_OPTIONS = 8;
    uint256 internal constant POWER_128 = 2**128;

    enum CampaignType {General, NetworkFee, FeeHandlerBRR}

    struct FormulaData {
        uint256 minPercentageInPrecision;
        uint256 cInPrecision;
        uint256 tInPrecision;
    }

    struct CampaignVoteData {
        uint256 totalVotes;
        uint256[] votePerOption;
    }

    struct Campaign {
        CampaignType campaignType;
        bool campaignExists;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 totalKNCSupply; // total KNC supply at the time campaign was created
        FormulaData formulaData; // formula params for concluding campaign result
        bytes link; // link to KIP, explaination of options, etc.
        uint256[] options; // data of options
        CampaignVoteData campaignVoteData; // campaign vote data: total votes + vote per option
    }

    struct BRRData {
        uint256 rewardInBps;
        uint256 rebateInBps;
    }

    uint256 public minCampaignDurationInSeconds = 4 days;
    IERC20 public immutable kncToken;
    IKyberStaking public immutable staking;

    uint256 public numberCampaigns = 0;
    mapping(uint256 => Campaign) internal campaignData;

    mapping(uint256 => uint256[]) internal epochCampaigns;
    mapping(uint256 => uint256) internal totalEpochPoints;
    mapping(address => mapping(uint256 => uint256)) public numberVotes;
    mapping(address => mapping(uint256 => uint256)) public stakerVotedOption;

    uint256 internal latestNetworkFeeResult;
    mapping(uint256 => uint256) public networkFeeCampaigns;
    BRRData internal latestBrrData;
    mapping(uint256 => uint256) public brrCampaigns;

    event NewCampaignCreated(
        CampaignType campaignType,
        uint256 indexed campaignID,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 minPercentageInPrecision,
        uint256 cInPrecision,
        uint256 tInPrecision,
        uint256[] options,
        bytes link
    );

    event CancelledCampaign(uint256 indexed campaignID);

    constructor(
        uint256 _epochPeriod,
        uint256 _startTimestamp,
        IERC20 _knc,
        uint256 _defaultNetworkFeeBps,
        uint256 _defaultRewardBps,
        uint256 _defaultRebateBps,
        address _daoOperator
    ) public DaoOperator(_daoOperator) {
        require(_epochPeriod > 0, "ctor: epoch period is 0");
        require(_startTimestamp >= now, "ctor: start in the past");
        require(_knc != IERC20(0), "ctor: knc token 0");
        require(_defaultNetworkFeeBps < BPS / 2, "ctor: network fee high");
        require(_defaultRewardBps.add(_defaultRebateBps) <= BPS, "reward plus rebate high");

        epochPeriodInSeconds = _epochPeriod;
        firstEpochStartTimestamp = _startTimestamp;
        kncToken = _knc;

        latestNetworkFeeResult = _defaultNetworkFeeBps;
        latestBrrData = BRRData({
            rewardInBps: _defaultRewardBps,
            rebateInBps: _defaultRebateBps
        });

        staking = new KyberStaking({
            _kncToken: _knc,
            _epochPeriod: _epochPeriod,
            _startTimestamp: _startTimestamp,
            _kyberDao: IKyberDao(this)
        });
    }

    modifier onlyStakingContract {

        require(msg.sender == address(staking), "only staking contract");
        _;
    }

    function handleWithdrawal(address staker, uint256 reduceAmount) external override onlyStakingContract {

        if (reduceAmount == 0) {
            return;
        }
        uint256 curEpoch = getCurrentEpochNumber();

        uint256 numVotes = numberVotes[staker][curEpoch];
        if (numVotes == 0) {
            return;
        }

        totalEpochPoints[curEpoch] = totalEpochPoints[curEpoch].sub(numVotes.mul(reduceAmount));

        uint256[] memory campaignIDs = epochCampaigns[curEpoch];

        for (uint256 i = 0; i < campaignIDs.length; i++) {
            uint256 campaignID = campaignIDs[i];

            uint256 votedOption = stakerVotedOption[staker][campaignID];
            if (votedOption == 0) {
                continue;
            } // staker has not voted yet

            Campaign storage campaign = campaignData[campaignID];
            if (campaign.endTimestamp >= now) {
                campaign.campaignVoteData.totalVotes =
                    campaign.campaignVoteData.totalVotes.sub(reduceAmount);
                campaign.campaignVoteData.votePerOption[votedOption - 1] =
                    campaign.campaignVoteData.votePerOption[votedOption - 1].sub(reduceAmount);
            }
        }
    }

    function submitNewCampaign(
        CampaignType campaignType,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 minPercentageInPrecision,
        uint256 cInPrecision,
        uint256 tInPrecision,
        uint256[] calldata options,
        bytes calldata link
    ) external onlyDaoOperator returns (uint256 campaignID) {

        uint256 campaignEpoch = getEpochNumber(startTimestamp);

        validateCampaignParams(
            campaignType,
            startTimestamp,
            endTimestamp,
            minPercentageInPrecision,
            cInPrecision,
            tInPrecision,
            options
        );

        numberCampaigns = numberCampaigns.add(1);
        campaignID = numberCampaigns;

        epochCampaigns[campaignEpoch].push(campaignID);
        if (campaignType == CampaignType.NetworkFee) {
            networkFeeCampaigns[campaignEpoch] = campaignID;
        } else if (campaignType == CampaignType.FeeHandlerBRR) {
            brrCampaigns[campaignEpoch] = campaignID;
        }

        FormulaData memory formulaData = FormulaData({
            minPercentageInPrecision: minPercentageInPrecision,
            cInPrecision: cInPrecision,
            tInPrecision: tInPrecision
        });
        CampaignVoteData memory campaignVoteData = CampaignVoteData({
            totalVotes: 0,
            votePerOption: new uint256[](options.length)
        });

        campaignData[campaignID] = Campaign({
            campaignExists: true,
            campaignType: campaignType,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            totalKNCSupply: kncToken.totalSupply(),
            link: link,
            formulaData: formulaData,
            options: options,
            campaignVoteData: campaignVoteData
        });

        emit NewCampaignCreated(
            campaignType,
            campaignID,
            startTimestamp,
            endTimestamp,
            minPercentageInPrecision,
            cInPrecision,
            tInPrecision,
            options,
            link
        );
    }

    function cancelCampaign(uint256 campaignID) external onlyDaoOperator {

        Campaign storage campaign = campaignData[campaignID];
        require(campaign.campaignExists, "cancelCampaign: campaignID doesn't exist");

        require(campaign.startTimestamp > now, "cancelCampaign: campaign already started");

        uint256 epoch = getEpochNumber(campaign.startTimestamp);

        if (campaign.campaignType == CampaignType.NetworkFee) {
            delete networkFeeCampaigns[epoch];
        } else if (campaign.campaignType == CampaignType.FeeHandlerBRR) {
            delete brrCampaigns[epoch];
        }

        delete campaignData[campaignID];

        uint256[] storage campaignIDs = epochCampaigns[epoch];
        for (uint256 i = 0; i < campaignIDs.length; i++) {
            if (campaignIDs[i] == campaignID) {
                campaignIDs[i] = campaignIDs[campaignIDs.length - 1];
                campaignIDs.pop();
                break;
            }
        }

        emit CancelledCampaign(campaignID);
    }

    function vote(uint256 campaignID, uint256 option) external override {

        validateVoteOption(campaignID, option);
        address staker = msg.sender;

        uint256 curEpoch = getCurrentEpochNumber();
        (uint256 stake, uint256 dStake, address representative) =
            staking.initAndReturnStakerDataForCurrentEpoch(staker);

        uint256 totalStake = representative == staker ? stake.add(dStake) : dStake;
        uint256 lastVotedOption = stakerVotedOption[staker][campaignID];

        CampaignVoteData storage voteData = campaignData[campaignID].campaignVoteData;

        if (lastVotedOption == 0) {
            numberVotes[staker][curEpoch]++;

            totalEpochPoints[curEpoch] = totalEpochPoints[curEpoch].add(totalStake);
            voteData.votePerOption[option - 1] =
                voteData.votePerOption[option - 1].add(totalStake);
            voteData.totalVotes = voteData.totalVotes.add(totalStake);
        } else if (lastVotedOption != option) {
            voteData.votePerOption[lastVotedOption - 1] =
                voteData.votePerOption[lastVotedOption - 1].sub(totalStake);
            voteData.votePerOption[option - 1] =
                voteData.votePerOption[option - 1].add(totalStake);
        }

        stakerVotedOption[staker][campaignID] = option;

        emit Voted(staker, curEpoch, campaignID, option);
    }

    function getLatestNetworkFeeDataWithCache()
        external
        override
        returns (uint256 feeInBps, uint256 expiryTimestamp)
    {

        (feeInBps, expiryTimestamp) = getLatestNetworkFeeData();
        latestNetworkFeeResult = feeInBps;
    }

    function getLatestBRRDataWithCache()
        external
        override
        returns (
            uint256 burnInBps,
            uint256 rewardInBps,
            uint256 rebateInBps,
            uint256 epoch,
            uint256 expiryTimestamp
        )
    {

        (burnInBps, rewardInBps, rebateInBps, epoch, expiryTimestamp) = getLatestBRRData();
        latestBrrData.rewardInBps = rewardInBps;
        latestBrrData.rebateInBps = rebateInBps;
    }

    function shouldBurnRewardForEpoch(uint256 epoch) external view override returns (bool) {

        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch >= curEpoch) {
            return false;
        }
        return totalEpochPoints[epoch] == 0;
    }

    function getListCampaignIDs(uint256 epoch) external view returns (uint256[] memory campaignIDs) {

        campaignIDs = epochCampaigns[epoch];
    }

    function getTotalEpochPoints(uint256 epoch) external view returns (uint256) {

        return totalEpochPoints[epoch];
    }

    function getCampaignDetails(uint256 campaignID)
        external
        view
        returns (
            CampaignType campaignType,
            uint256 startTimestamp,
            uint256 endTimestamp,
            uint256 totalKNCSupply,
            uint256 minPercentageInPrecision,
            uint256 cInPrecision,
            uint256 tInPrecision,
            bytes memory link,
            uint256[] memory options
        )
    {

        Campaign storage campaign = campaignData[campaignID];
        campaignType = campaign.campaignType;
        startTimestamp = campaign.startTimestamp;
        endTimestamp = campaign.endTimestamp;
        totalKNCSupply = campaign.totalKNCSupply;
        minPercentageInPrecision = campaign.formulaData.minPercentageInPrecision;
        cInPrecision = campaign.formulaData.cInPrecision;
        tInPrecision = campaign.formulaData.tInPrecision;
        link = campaign.link;
        options = campaign.options;
    }

    function getCampaignVoteCountData(uint256 campaignID)
        external
        view
        returns (uint256[] memory voteCounts, uint256 totalVoteCount)
    {

        CampaignVoteData memory voteData = campaignData[campaignID].campaignVoteData;
        totalVoteCount = voteData.totalVotes;
        voteCounts = voteData.votePerOption;
    }

    function getPastEpochRewardPercentageInPrecision(address staker, uint256 epoch)
        external
        view
        override
        returns (uint256)
    {

        uint256 curEpoch = getCurrentEpochNumber();
        if (epoch >= curEpoch) {
            return 0;
        }

        return getRewardPercentageInPrecision(staker, epoch);
    }

    function getCurrentEpochRewardPercentageInPrecision(address staker)
        external
        view
        override
        returns (uint256)
    {

        uint256 curEpoch = getCurrentEpochNumber();
        return getRewardPercentageInPrecision(staker, curEpoch);
    }

    function getCampaignWinningOptionAndValue(uint256 campaignID)
        public
        view
        returns (uint256 optionID, uint256 value)
    {

        Campaign storage campaign = campaignData[campaignID];
        if (!campaign.campaignExists) {
            return (0, 0);
        } // not exist

        if (campaign.endTimestamp > now) {
            return (0, 0);
        }

        uint256 totalSupply = campaign.totalKNCSupply;
        if (totalSupply == 0) {
            return (0, 0);
        }

        uint256 totalVotes = campaign.campaignVoteData.totalVotes;
        uint256[] memory voteCounts = campaign.campaignVoteData.votePerOption;

        uint256 winningOption = 0;
        uint256 maxVotedCount = 0;
        for (uint256 i = 0; i < voteCounts.length; i++) {
            if (voteCounts[i] > maxVotedCount) {
                winningOption = i + 1;
                maxVotedCount = voteCounts[i];
            } else if (voteCounts[i] == maxVotedCount) {
                winningOption = 0;
            }
        }

        if (winningOption == 0) {
            return (0, 0);
        }

        FormulaData memory formulaData = campaign.formulaData;

        uint256 votedPercentage = totalVotes.mul(PRECISION).div(campaign.totalKNCSupply);

        if (formulaData.minPercentageInPrecision > votedPercentage) {
            return (0, 0);
        }

        uint256 x = formulaData.tInPrecision.mul(votedPercentage).div(PRECISION);
        if (x <= formulaData.cInPrecision) {
            uint256 y = formulaData.cInPrecision.sub(x);
            if (maxVotedCount.mul(PRECISION) < y.mul(totalVotes)) {
                return (0, 0);
            }
        }

        optionID = winningOption;
        value = campaign.options[optionID - 1];
    }

    function getLatestNetworkFeeData()
        public
        view
        override
        returns (uint256 feeInBps, uint256 expiryTimestamp)
    {

        uint256 curEpoch = getCurrentEpochNumber();
        feeInBps = latestNetworkFeeResult;
        expiryTimestamp = firstEpochStartTimestamp.add(curEpoch.mul(epochPeriodInSeconds)).sub(1);
        if (curEpoch == 0) {
            return (feeInBps, expiryTimestamp);
        }
        uint256 campaignID = networkFeeCampaigns[curEpoch.sub(1)];
        if (campaignID == 0) {
            return (feeInBps, expiryTimestamp);
        }

        uint256 winningOption;
        (winningOption, feeInBps) = getCampaignWinningOptionAndValue(campaignID);
        if (winningOption == 0) {
            feeInBps = latestNetworkFeeResult;
        }
        return (feeInBps, expiryTimestamp);
    }

    function getLatestBRRData()
        public
        view
        returns (
            uint256 burnInBps,
            uint256 rewardInBps,
            uint256 rebateInBps,
            uint256 epoch,
            uint256 expiryTimestamp
        )
    {

        epoch = getCurrentEpochNumber();
        expiryTimestamp = firstEpochStartTimestamp.add(epoch.mul(epochPeriodInSeconds)).sub(1);
        rewardInBps = latestBrrData.rewardInBps;
        rebateInBps = latestBrrData.rebateInBps;

        if (epoch > 0) {
            uint256 campaignID = brrCampaigns[epoch.sub(1)];
            if (campaignID != 0) {
                uint256 winningOption;
                uint256 brrData;
                (winningOption, brrData) = getCampaignWinningOptionAndValue(campaignID);
                if (winningOption > 0) {
                    (rebateInBps, rewardInBps) = getRebateAndRewardFromData(brrData);
                }
            }
        }

        burnInBps = BPS.sub(rebateInBps).sub(rewardInBps);
    }

    function getRebateAndRewardFromData(uint256 data)
        public
        pure
        returns (uint256 rebateInBps, uint256 rewardInBps)
    {

        rewardInBps = data & (POWER_128.sub(1));
        rebateInBps = (data.div(POWER_128)) & (POWER_128.sub(1));
    }

    function getDataFromRewardAndRebateWithValidation(uint256 rewardInBps, uint256 rebateInBps)
        public
        pure
        returns (uint256 data)
    {

        require(rewardInBps.add(rebateInBps) <= BPS, "reward plus rebate high");
        data = (rebateInBps.mul(POWER_128)).add(rewardInBps);
    }

    function validateVoteOption(uint256 campaignID, uint256 option) internal view {

        Campaign storage campaign = campaignData[campaignID];
        require(campaign.campaignExists, "vote: campaign doesn't exist");

        require(campaign.startTimestamp <= now, "vote: campaign not started");
        require(campaign.endTimestamp >= now, "vote: campaign already ended");

        require(option > 0, "vote: option is 0");
        require(option <= campaign.options.length, "vote: option is not in range");
    }

    function validateCampaignParams(
        CampaignType campaignType,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 minPercentageInPrecision,
        uint256 cInPrecision,
        uint256 tInPrecision,
        uint256[] memory options
    ) internal view {

        require(startTimestamp >= now, "validateParams: start in the past");
        require(
            endTimestamp.add(1) >= startTimestamp.add(minCampaignDurationInSeconds),
            "validateParams: campaign duration is low"
        );

        uint256 startEpoch = getEpochNumber(startTimestamp);
        uint256 endEpoch = getEpochNumber(endTimestamp);

        require(
            epochCampaigns[startEpoch].length < MAX_EPOCH_CAMPAIGNS,
            "validateParams: too many campaigns"
        );

        require(startEpoch == endEpoch, "validateParams: start & end not same epoch");

        uint256 currentEpoch = getCurrentEpochNumber();
        require(
            startEpoch <= currentEpoch.add(1),
            "validateParams: only for current or next epochs"
        );

        uint256 numOptions = options.length;
        require(
            numOptions > 1 && numOptions <= MAX_CAMPAIGN_OPTIONS,
            "validateParams: invalid number of options"
        );

        if (campaignType == CampaignType.General) {
            for (uint256 i = 0; i < options.length; i++) {
                require(options[i] > 0, "validateParams: general campaign option is 0");
            }
        } else if (campaignType == CampaignType.NetworkFee) {
            require(
                networkFeeCampaigns[startEpoch] == 0,
                "validateParams: already had network fee campaign for this epoch"
            );
            for (uint256 i = 0; i < options.length; i++) {
                require(
                    options[i] < BPS / 2,
                    "validateParams: network fee must be smaller then BPS / 2"
                );
            }
        } else {
            require(
                brrCampaigns[startEpoch] == 0,
                "validateParams: already had brr campaign for this epoch"
            );
            for (uint256 i = 0; i < options.length; i++) {
                (uint256 rebateInBps, uint256 rewardInBps) =
                    getRebateAndRewardFromData(options[i]);
                require(
                    rewardInBps.add(rebateInBps) <= BPS,
                    "validateParams: rebate + reward can't be bigger than BPS"
                );
            }
        }

        require(minPercentageInPrecision <= PRECISION, "validateParams: min percentage is high");

        require(cInPrecision < POWER_128, "validateParams: c is high");

        require(tInPrecision < POWER_128, "validateParams: t is high");
    }

    function getRewardPercentageInPrecision(address staker, uint256 epoch)
        internal
        view
        returns (uint256)
    {

        uint256 numVotes = numberVotes[staker][epoch];
        if (numVotes == 0) {
            return 0;
        }

        (uint256 stake, uint256 delegatedStake, address representative) =
            staking.getStakerRawData(staker, epoch);

        uint256 totalStake = representative == staker ? stake.add(delegatedStake) : delegatedStake;
        if (totalStake == 0) {
            return 0;
        }

        uint256 points = numVotes.mul(totalStake);
        uint256 totalPts = totalEpochPoints[epoch];

        assert(points <= totalPts);

        return points.mul(PRECISION).div(totalPts);
    }
}