
pragma solidity ^0.8.0;

interface WiseTokenInterface {


    function currentWiseDay()
        external view
        returns (uint64);


    function approve(
        address _spender,
        uint256 _value
    )
        external
        returns (bool success);


    function generateID(
        address x,
        uint256 y,
        bytes1 z
    )
        external
        pure
        returns (bytes16 b);


    function createStakeWithETH(
        uint64 _lockDays,
        address _referrer
    )
        external
        payable
        returns (bytes16, uint256, bytes16 referralID);


    function createStakeWithToken(
        address _tokenAddress,
        uint256 _tokenAmount,
        uint64 _lockDays,
        address _referrer
    )
        external
        returns (bytes16, uint256, bytes16 referralID);


    function createStake(
        uint256 _stakedAmount,
        uint64 _lockDays,
        address _referrer
    )
        external
        returns (bytes16, uint256, bytes16 referralID);


    function endStake(
        bytes16 _stakeID
    )
        external
        returns (uint256);


    function checkMatureStake(
        address _staker,
        bytes16 _stakeID
    )
        external
        view
        returns (bool isMature);


    function balanceOf(
        address account
    ) external view returns (uint256);


    function checkStakeByID(
        address _staker,
        bytes16 _stakeID
    )
        external
        view
        returns (
            uint256 startDay,
            uint256 lockDays,
            uint256 finalDay,
            uint256 closeDay,
            uint256 scrapeDay,
            uint256 stakedAmount,
            uint256 stakesShares,
            uint256 rewardAmount,
            uint256 penaltyAmount,
            bool isActive,
            bool isMature
        );

}// --🦉--

pragma solidity ^0.8.0;


interface UniswapRouter {

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (
        uint[] memory amounts
    );

}

contract InsuranceDeclaration {


    WiseTokenInterface public immutable WISE_CONTRACT;
    UniswapRouter public immutable UNISWAP_ROUTER;

    address constant wiseToken =
    0x66a0f676479Cee1d7373f3DC2e2952778BfF5bd6;

    address constant uniswapRouter =
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address public constant WETH =
    0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;


    uint256 public totalStaked; // - just to track amount of total tokens staked
    uint256 public totalCovers; // - amount of tokens we need to cover
    uint256 public totalBufferStaked;  // - to track amount of tokens dedicated to buffer stakes
    uint256 public totalPublicDebth;   // - amount of tokens we own to public contributors
    uint256 public totalPublicRewards; // - amount of token we allocate to public payouts (to public contribs)
    uint256 public totalMasterProfits; // - tracking profits for the master, to know how much can be taken

    uint256 public teamContribution; // initial funding from the team

    uint256 public coverageThreshold;

    uint256 public payoutThreshold;

    uint256 public penaltyThresholdA;
    uint256 public penaltyThresholdB;

    uint256 public penaltyA;
    uint256 public penaltyB;

    uint256 public stakePercent;

    uint256 public principalCut; // (0%-10%)

    uint256 public interestCut; // (0%-10%)

    uint256 public publicRewardPercent;

    uint256 public publicDebthCap;

    uint256 public bufferStakeCap;

    uint256 public maximumBufferStakeDuration;

    bool public allowInsurance;

    bool public allowPublicContributions;

    bool public getBufferStakeInterest;

    uint256 constant MAX_STAKE_DAYS = 1095; // constant cannot be adjusted 3 years

    address payable public insuranceMaster; // master is a MultiSigWallet
    address payable public insuranceWorker; // worker can be defined by master

    struct InsuranceStake {
        bytes16 stakeID;
        uint256 bufferAmount;
        uint256 stakedAmount;
        uint256 matureAmount;
        uint256 emergencyAmount;
        address currentOwner;
        bool isActive;
    }

    struct BufferStake {
        uint256 stakedAmount;
        bytes16 stakeID;
        bool isActive;
    }

    struct OwnerlessStake {
        uint256 stakeIndex;
        address originalOwner;
    }

    uint256 public bufferStakeCount;
    uint256 public ownerlessStakeCount;
    uint256 public insuranceStakeCount;

    uint256 public activeInsuranceStakeCount;
    uint256 public activeOwnerlessStakeCount;
    uint256 public activeBufferStakeCount;

    mapping (address => uint256) public insuranceStakeCounts;
    mapping (address => mapping(uint256 => InsuranceStake)) public insuranceStakes;

    mapping (uint256 => BufferStake) public bufferStakes;
    mapping (uint256 => OwnerlessStake) public ownerlessStakes;

    mapping (address => uint256) public publicReward;

    modifier onlyMaster() {

        require(
            msg.sender == insuranceMaster,
            'WiseInsurance: not an agent'
        );
        _;
    }

    modifier onlyWorker() {

        require(
            msg.sender == insuranceWorker,
            'WiseInsurance: not a worker'
        );
        _;
    }

    event TreasuryFunded(
        uint256 amount,
        address funder,
        uint256 total
    );

    event InsurancStakeOpened(
        bytes16 indexed stakeID,
        uint256 stakedAmount,
        uint256 returnAmount,
        address indexed originalOwner,
        uint256 indexed stakeIndex,
        bytes16 referralID
    );

    event EmergencyExitStake(
        address indexed stakeOwner,
        uint256 indexed stakeIndex,
        bytes16 indexed stakeID,
        uint256 returnAfterFee,
        uint256 returnAmount,
        uint64 currentWiseDay
    );

    event NewOwnerlessStake(
        uint256 indexed ownerlessIndex,
        uint256 indexed stakeIndex,
        address indexed stakeOwner
    );

    event InsuranceStakeClosed(
        address indexed staker,
        uint256 indexed stakeIndex,
        bytes16 indexed stakeID,
        uint256 returnAmount,
        uint256 rewardAfterFee
    );

    event OwnerlessStakeClosed(
        uint256 ownerlessIndex,
        address indexed staker,
        uint256 indexed stakeIndex,
        bytes16 indexed stakeID,
        uint256 stakedAmount,
        uint256 rewardAmount
    );

    event BufferStakeOpened(
        bytes16 indexed stakeID,
        uint256 stakedAmount,
        bytes16 indexed referralID
    );

    event BufferStakeClosed(
        bytes16 indexed stakeID,
        uint256 stakedAmount,
        uint256 rewardAmount
    );

    event PublicContributionsOpened(
        bool indexed status
    );

    event PublicProfit(
        address indexed contributor,
        uint256 amount,
        uint256 publicDebth,
        uint256 publicRewards
    );

    event ProfitsTaken(
        uint256 profitAmount,
        uint256 remainingBuffer
    );

    event publicRewardsGiven(
        uint256 rewardAmount,
        uint256 totalPublicDebth,
        uint256 totalPublicRewards
    );

    event DeveloperFundsRouted(
        uint256 fundsAmount
    );

    event checkStake(
        uint256 startDay,
        uint256 lockDays,
        uint256 finalDay,
        uint256 closeDay,
        uint256 scrapeDay,
        uint256 stakedAmount,
        uint256 stakesShares,
        uint256 rewardAmount,
        uint256 penaltyAmount,
        bool isActive,
        bool isMature
    );

    constructor() {

        WISE_CONTRACT = WiseTokenInterface(
            wiseToken
        );

        UNISWAP_ROUTER = UniswapRouter(
            uniswapRouter
        );

        stakePercent = 90;
        payoutThreshold = 10;
        coverageThreshold = 3;

        penaltyThresholdA = 0;
        penaltyThresholdB = 0;

        penaltyA = 0;
        penaltyB = 0;

        insuranceMaster = payable(0xfEc4264F728C056bD528E9e012cf4D943bd92b53);
        insuranceWorker = payable(0x9404f4B0846A2cD5c659c1edD52BA60abF1F10F4);

        allowInsurance = true;
    }

    address ZERO_ADDRESS = address(0x0);

    string TRANSFER_FAILED = 'WiseInsurance: transfer failed';

    string NOT_YOUR_STAKE = 'WiseInsurance: stake ownership already renounced';
    string NOT_MATURE_STAKE = 'WiseInsurance: stake is not mature';
    string NOT_ACTIVE_STAKE = 'WiseInsurance: stake already closed';
    string NOT_OWNERLESS_STAKE = 'WiseInsurance: stake is not ownerless';

    string MATURED_STAKE = 'WiseInsurance: stake already matured';
    string BELOW_COVERAGE_THRESHOLD = 'WiseInsurance: below coverage threshold';
    string BELOW_PAYOUT_THRESHOLD = 'WiseInsurance: below payout threshold';
    string PUBLIC_CONTRIBUTIONS_DISABLED = 'WiseInsurance: public contributions closed';
    string DECREASE_STAKE_DURATION = 'WiseInsurance: lockDays exceeded';
    string INSURANCE_DISABLED = 'WiseInsurance: disabled';
    string NO_REWARD_FOR_CONTRIBUTOR = 'WiseInsurance: no rewards for contributor';
    string NO_PUBLIC_DEBTH = 'WiseInsurance: no public debth';
    string NO_PUBLIC_REWARD_AVAILABLE = 'WiseInsurance: no rewards in public pot';
    string EXCEEDING_PUBLIC_DEBTH_CAP = 'WiseInsurance: exceeding public debth cap';
    string PUBLIC_DEBTH_NOT_PAID = 'WiseInsurance: public debth not paid';
    string PUBLIC_CONTRIBUTION_MUST_BE_DISABLED = 'WiseInsurance: public contributions must be disabled';
}// --🦉--

pragma solidity ^0.8.0;


contract InsuranceHelper is InsuranceDeclaration {



	function _increaseTotalStaked(
	    uint256 _amount
	)
	    internal
	{

	    totalStaked =
	    totalStaked + _amount;
	}

	function _decreaseTotalStaked(
	    uint256 _amount
	)
	    internal
	{

	    totalStaked =
	    totalStaked - _amount;
	}

	function _increaseTotalCovers(
	    uint256 _amount
	)
	    internal
	{

	    totalCovers =
	    totalCovers + _amount;
	}

	function _decreaseTotalCovers(
	    uint256 _amount
	)
	    internal
	{

	    totalCovers =
	    totalCovers - _amount;
	}

	function _increaseTotalBufferStaked(
	    uint256 _amount
	)
	    internal
	{

	    totalBufferStaked =
	    totalBufferStaked + _amount;
	}

	function _decreaseTotalBufferStaked(
	    uint256 _amount
	)
	    internal
	{

	    totalBufferStaked =
	    totalBufferStaked - _amount;
	}

	function _increaseTotalMasterProfits(
	    uint256 _amount
	)
	    internal
	{

	    totalMasterProfits =
	    totalMasterProfits + _amount;
	}

	function _decreaseTotalMasterProfits(
	    uint256 _amount
	)
	    internal
	{

	    totalMasterProfits =
	    totalMasterProfits > _amount ?
	    totalMasterProfits - _amount : 0;
	}

    function _increaseActiveInsuranceStakeCount()
        internal
    {

        activeInsuranceStakeCount++;
    }

    function _decreaseActiveInsuranceStakeCount()
        internal
    {

        activeInsuranceStakeCount--;
    }

    function _increaseActiveOwnerlessStakeCount()
        internal
    {

        activeOwnerlessStakeCount++;
    }

    function _decreaseActiveOwnerlessStakeCount()
        internal
    {

        activeOwnerlessStakeCount--;
    }

    function _increaseActiveBufferStakeCount()
        internal
    {

        activeBufferStakeCount++;
    }

    function _decreaseActiveBufferStakeCount()
        internal
    {

        activeBufferStakeCount--;
    }

    function _increaseOwnerlessStakeCount()
        internal
    {

        ownerlessStakeCount++;
    }

    function _increaseBufferStakeCount()
        internal
    {

        bufferStakeCount++;
    }

    function _trackOwnerlessStake(
        address _originalOwner,
        uint256 _stakeIndex
    )
        internal
    {

        ownerlessStakes[ownerlessStakeCount].stakeIndex = _stakeIndex;
        ownerlessStakes[ownerlessStakeCount].originalOwner = _originalOwner;
    }

    function _increaseInsuranceStakeCounts(
        address _staker
    )
        internal
    {

        insuranceStakeCount++;
        insuranceStakeCounts[_staker]++;
    }

    function _increasePublicDebth(
        uint256 _amount
    )
        internal
    {

        totalPublicDebth =
        totalPublicDebth + _amount;
    }

    function _decreasePublicDebth(
        uint256 _amount
    )
        internal
    {

        totalPublicDebth =
        totalPublicDebth - _amount;
    }

    function _increasePublicReward(
        address _contributor,
        uint256 _amount
    )
        internal
    {

        publicReward[_contributor] =
        publicReward[_contributor] + _amount;
    }

    function _decreasePublicReward(
        address _contributor,
        uint256 _amount
    )
        internal
    {

        publicReward[_contributor] =
        publicReward[_contributor] - _amount;
    }

    function _increasePublicRewards(
        uint256 _amount
    )
        internal
    {

        totalPublicRewards =
        totalPublicRewards + _amount;
    }

    function _decreasePublicRewards(
        uint256 _amount
    )
        internal
    {

        totalPublicRewards =
        totalPublicRewards - _amount;
    }

    function _renounceStakeOwnership(
        address _staker,
        uint256 _stakeIndex
    )
        internal
    {

        insuranceStakes[_staker][_stakeIndex].currentOwner = ZERO_ADDRESS;
    }

    function _calculateEmergencyAmount(
        uint256 _stakedAmount,
        uint256 _principalCut
    )
        internal
        pure
        returns (uint256)
    {

        uint256 percent = 100 - _principalCut;
        return _stakedAmount * percent / 100;
    }

    function _calculateMatureAmount(
        uint256 _stakedAmount,
        uint256 _bufferAmount,
        uint256 _principalCut
    )
        internal
        pure
        returns (uint256)
    {

        uint256 percent = 100 - _principalCut;
        return (_stakedAmount + _bufferAmount) * percent / 100;
    }

    function _deactivateStake(
        address _staker,
        uint256 _stakeIndex
    )
        internal
    {

        insuranceStakes[_staker][_stakeIndex].isActive = false;
    }

    function stakesPagination(
        address _staker,
        uint256 _offset,
        uint256 _length
    )
        external
        view
        returns (bytes16[] memory _stakes)
    {

        uint256 start = _offset > 0 &&
            insuranceStakeCounts[_staker] > _offset ?
            insuranceStakeCounts[_staker] - _offset : insuranceStakeCounts[_staker];

        uint256 finish = _length > 0 &&
            start > _length ?
            start - _length : 0;

        uint256 i;

        _stakes = new bytes16[](start - finish);

        for (uint256 _stakeIndex = start; _stakeIndex > finish; _stakeIndex--) {
            bytes16 _stakeID = getStakeID(_staker, _stakeIndex - 1);
            if (insuranceStakes[_staker][_stakeIndex - 1].stakedAmount > 0) {
                _stakes[i] = _stakeID; i++;
            }
        }
    }


    function getBufferAmount(
        address _staker,
        uint256 _stakeIndex

    )
        public
        view
        returns (uint256)
    {

        return insuranceStakes[_staker][_stakeIndex].bufferAmount;
    }

    function getEmergencyAmount(
        address _staker,
        uint256 _stakeIndex

    )
        public
        view
        returns (uint256)
    {

        return insuranceStakes[_staker][_stakeIndex].emergencyAmount;
    }

    function getMatureAmount(
        address _staker,
        uint256 _stakeIndex

    )
        public
        view
        returns (uint256)
    {

        return insuranceStakes[_staker][_stakeIndex].matureAmount;
    }

    function getStakedAmount(
        address _staker,
        uint256 _stakeIndex

    )
        public
        view
        returns (uint256)
    {

        return insuranceStakes[_staker][_stakeIndex].stakedAmount;
    }

    function getStakeData(
        uint256 _ownerlessStakeIndex
    )
        public
        view
        returns (address, uint256)
    {

        return (
            ownerlessStakes[_ownerlessStakeIndex].originalOwner,
            ownerlessStakes[_ownerlessStakeIndex].stakeIndex
        );
    }

    function checkActiveStake(
        address _staker,
        uint256 _stakeIndex
    )
        public
        view
        returns (bool)
    {

        return insuranceStakes[_staker][_stakeIndex].isActive;
    }

    function checkOwnership(
        address _staker,
        uint256 _stakeIndex
    )
        public
        view
        returns (bool)
    {

        return insuranceStakes[_staker][_stakeIndex].currentOwner == _staker;
    }

    function checkOwnerlessStake(
        address _staker,
        uint256 _stakeIndex
    )
        public
        view
        returns (bool)
    {

        return insuranceStakes[_staker][_stakeIndex].currentOwner == ZERO_ADDRESS;
    }

    function applyFee(
        uint256 _totalReward,
        uint256 _interestCut
    )
        public
        pure
        returns (uint256)
    {

        uint256 percent = 100 - _interestCut;
        return _totalReward * percent / 100;
    }

    function penaltyFee(
        uint256 _toReturn,
        uint256 _matureLevel
    )
        public
        view
        returns (uint256)
    {

        uint256 penaltyPercent;

        if (_matureLevel <= penaltyThresholdB) {
            penaltyPercent = penaltyB;
        }

        if (_matureLevel <= penaltyThresholdA) {
            penaltyPercent = penaltyA;
        }

        uint256 percent = 100 - penaltyPercent;
        return _toReturn * percent / 100;
    }

    function checkMatureLevel(
        address _staker,
        bytes16 _stakeID
    )
        public
        view
        returns (uint256)
    {


        (   uint256 startDay,
            uint256 lockDays,
            uint256 finalDay,
            uint256 closeDay,
            uint256 scrapeDay,
            uint256 stakedAmount,
            uint256 stakesShares,
            uint256 rewardAmount,
            uint256 penaltyAmount,
            bool isActive,
            bool isMature
        ) = WISE_CONTRACT.checkStakeByID(
            _staker,
            _stakeID
        );

        return 100 - (_daysLeft(WISE_CONTRACT.currentWiseDay(), finalDay) * 100 / lockDays);
    }

    function _daysLeft(
        uint256 _startDate,
        uint256 _endDate
    )
        internal
        pure
        returns (uint256)
    {

        return _startDate > _endDate ? 0 : _endDate - _startDate;
    }

    function getStakeID(
        address _staker,
        uint256 _stakeIndex

    )
        public
        view
        returns (bytes16)
    {

        return insuranceStakes[_staker][_stakeIndex].stakeID;
    }


    function enablePublicContribution()
        external
        onlyMaster
    {

        allowPublicContributions = true;
        emit PublicContributionsOpened(true);
    }

    function disablePublicContribution()
        external
        onlyMaster
    {

        allowPublicContributions = false;
        emit PublicContributionsOpened(false);
    }

    function switchBufferStakeInterest(
        bool _asDeveloperFunds
    )
        external
        onlyMaster
    {

        getBufferStakeInterest = _asDeveloperFunds;
    }

    bytes4 private constant TRANSFER = bytes4(
        keccak256(
            bytes(
                'transfer(address,uint256)'
            )
        )
    );

    bytes4 private constant TRANSFER_FROM = bytes4(
        keccak256(
            bytes(
                'transferFrom(address,address,uint256)'
            )
        )
    );

    function safeTransfer(
        address _token,
        address _to,
        uint256 _value
    )
        internal
    {

        (bool success, bytes memory data) = _token.call(
            abi.encodeWithSelector(
                TRANSFER,
                _to,
                _value
            )
        );

        require(
            success && (
                data.length == 0 || abi.decode(
                    data, (bool)
                )
            ),
            TRANSFER_FAILED
        );
    }

    function safeTransferFrom(
        address _token,
        address _from,
        address _to,
        uint _value
    )
        internal
    {

        (bool success, bytes memory data) = _token.call(
            abi.encodeWithSelector(
                TRANSFER_FROM,
                _from,
                _to,
                _value
            )
        );

        require(
            success && (
                data.length == 0 || abi.decode(
                    data, (bool)
                )
            ),
            TRANSFER_FAILED
        );
    }
}// --🦉--

pragma solidity ^0.8.0;


contract WiseInsurance is InsuranceHelper {


    function createStakeBulk(
        uint256[] memory _stakedAmount,
        uint64[] memory _lockDays,
        address[] memory _referrer
    )
        external
    {

        for(uint256 i = 0; i < _stakedAmount.length; i++) {
            createStake(
                _stakedAmount[i],
                _lockDays[i],
                _referrer[i]
            );
        }
    }

    function createStakeWithETH(
        uint64 _lockDays,
        address _referrer
    )
        external
        payable
    {

        address[] memory path = new address[](2);
            path[0] = WETH;
            path[1] = wiseToken;

        uint256[] memory amounts =
        UNISWAP_ROUTER.swapExactETHForTokens{value: msg.value}(
            1,
            path,
            msg.sender,
            block.timestamp + 2 hours
        );

        createStake(
            amounts[1],
            _lockDays,
            _referrer
        );
    }

    function createStake(
        uint256 _stakedAmount,
        uint64 _lockDays,
        address _referrer
    )
        public
    {

        require(
            _lockDays <= MAX_STAKE_DAYS,
            DECREASE_STAKE_DURATION
        );

        require(
            allowInsurance == true,
            INSURANCE_DISABLED
        );

        uint256 toStake =  _stakedAmount * stakePercent / 100;
        uint256 toBuffer = _stakedAmount - toStake;

        uint256 toReturn = _calculateEmergencyAmount(
            toStake,
            principalCut
        );

        uint256 matureReturn = _calculateMatureAmount(
            toStake,
            toBuffer,
            principalCut
        );

        address staker = msg.sender;

        safeTransferFrom(
            wiseToken,
            staker,
            address(this),
            _stakedAmount
        );

        _increaseTotalStaked(
            toStake
        );

        _increaseTotalCovers(
            toReturn
        );

        require(
            getCoveredPercent() >= coverageThreshold,
            BELOW_COVERAGE_THRESHOLD
        );

        (bytes16 stakeID, uint256 stakedAmount, bytes16 referralID) =

        WISE_CONTRACT.createStake(
            toStake,
            _lockDays,
            _referrer
        );

        uint256 stakeIndex = insuranceStakeCounts[staker];

        insuranceStakes[staker][stakeIndex].stakeID = stakeID;
        insuranceStakes[staker][stakeIndex].stakedAmount = toStake;
        insuranceStakes[staker][stakeIndex].bufferAmount = toBuffer;
        insuranceStakes[staker][stakeIndex].matureAmount = matureReturn;
        insuranceStakes[staker][stakeIndex].emergencyAmount = toReturn;
        insuranceStakes[staker][stakeIndex].currentOwner = staker;
        insuranceStakes[staker][stakeIndex].isActive = true;

        _increaseInsuranceStakeCounts(staker);
        _increaseActiveInsuranceStakeCount();

        emit InsurancStakeOpened(
            stakeID,
            stakedAmount,
            toReturn,
            staker,
            stakeIndex,
            referralID
        );
    }

    function endStake(
        uint256 _stakeIndex
    )
        external
    {

        address _staker = msg.sender;

        if (checkMatureStake(
            _staker,
            _stakeIndex
        ) == false) {

            _emergencyExitStake(
                _staker,
                _stakeIndex
            );

        } else {

            _endMatureStake(
                _staker,
                _stakeIndex
            );
        }
    }

    function _emergencyExitStake(
        address _staker,
        uint256 _stakeIndex
    )
        internal
    {

        require(
            checkActiveStake(
                _staker,
                _stakeIndex
            ) == true,
            NOT_ACTIVE_STAKE
        );

        require(
            checkOwnership(
                _staker,
                _stakeIndex
            ) == true,
            NOT_YOUR_STAKE
        );

        _renounceStakeOwnership(
            _staker,
            _stakeIndex
        );

        _trackOwnerlessStake(
            _staker,
            _stakeIndex
        );

        emit NewOwnerlessStake (
            ownerlessStakeCount,
            _stakeIndex,
            _staker
        );

        _increaseOwnerlessStakeCount();
        _increaseActiveOwnerlessStakeCount();

        uint256 toReturn = getEmergencyAmount(
            _staker,
            _stakeIndex
        );

        bytes16 stakeID = getStakeID(
            _staker,
            _stakeIndex
        );

        uint256 matureLevel = checkMatureLevel(
            address(this),
            stakeID
        );

        uint256 amountAfterFee = penaltyFee(
            toReturn,
            matureLevel
        );

        safeTransfer(
            wiseToken,
            _staker,
            amountAfterFee
        );

        _increaseTotalMasterProfits(
            toReturn - amountAfterFee
        );

        _decreaseTotalCovers(
            toReturn
        );

        emit EmergencyExitStake(
            _staker,
            _stakeIndex,
            stakeID,
            amountAfterFee,
            toReturn,
            WISE_CONTRACT.currentWiseDay()
        );
    }

    function endMatureStake(
        address _staker,
        uint256 _stakeIndex
    )
        external
        onlyWorker
    {

        _endMatureStake(
            _staker,
            _stakeIndex
        );
    }

    function _endMatureStake(
        address _staker,
        uint256 _stakeIndex
    )
        internal
    {

        require(
            checkOwnership(
                _staker,
                _stakeIndex
            ) == true,
            NOT_YOUR_STAKE
        );

        require(
            checkMatureStake(
                _staker,
                _stakeIndex
            ) == true,
            NOT_MATURE_STAKE
        );

        require(
            checkActiveStake(
                _staker,
                _stakeIndex
            ) == true,
            NOT_ACTIVE_STAKE
        );

        _deactivateStake(
            _staker,
            _stakeIndex
        );

        _decreaseActiveInsuranceStakeCount();

        bytes16 stakeID = getStakeID(
            _staker,
            _stakeIndex
        );

        uint256 totalReward = WISE_CONTRACT.endStake(
            stakeID
        );

        uint256 stakedAmount = getStakedAmount(
            _staker,
            _stakeIndex
        );

        uint256 returnAmount = getMatureAmount(
            _staker,
            _stakeIndex
        );

        uint256 emergencyAmount = getEmergencyAmount(
            _staker,
            _stakeIndex
        );

        safeTransfer(
            wiseToken,
            _staker,
            returnAmount
        );

        uint256 rewardAfterFee = applyFee(
            totalReward,
            interestCut
        );

        safeTransfer(
            wiseToken,
            _staker,
            rewardAfterFee
        );

        _increaseTotalMasterProfits(
            stakedAmount > returnAmount ?
            stakedAmount - returnAmount : 0
        );

        _increaseTotalMasterProfits(
            totalReward - rewardAfterFee
        );

        _decreaseTotalStaked(
            stakedAmount
        );

        _decreaseTotalCovers(
            emergencyAmount
        );

        emit InsuranceStakeClosed(
            _staker,
            _stakeIndex,
            stakeID,
            returnAmount,
            rewardAfterFee
        );
    }

    function endOwnerlessStake(
        uint256 _ownerlessStakeIndex
    )
        external
        onlyWorker
    {

        (address staker, uint256 stakeIndex) =
        getStakeData(_ownerlessStakeIndex);

        require(
            checkOwnerlessStake(
                staker,
                stakeIndex
            ) == true,
            NOT_OWNERLESS_STAKE
        );

        require(
            checkMatureStake(
                staker,
                stakeIndex
            ) == true,
            NOT_MATURE_STAKE
        );

        require(
            checkActiveStake(
                staker,
                stakeIndex
            ) == true,
            NOT_ACTIVE_STAKE
        );

        _deactivateStake(
            staker,
            stakeIndex
        );

        _decreaseActiveInsuranceStakeCount();
        _decreaseActiveOwnerlessStakeCount();

        bytes16 stakeID = getStakeID(
            staker,
            stakeIndex
        );

        uint256 totalReward = WISE_CONTRACT.endStake(
            stakeID
        );

        uint256 stakedAmount = getStakedAmount(
            staker,
            stakeIndex
        );

        uint256 emergencyAmount = getEmergencyAmount(
            staker,
            stakeIndex
        );

        uint256 bufferAmount = getBufferAmount(
            staker,
            stakeIndex
        );

        _increaseTotalMasterProfits(
            totalReward
        );

        _increaseTotalMasterProfits(
            stakedAmount - emergencyAmount + bufferAmount
        );

        _decreaseTotalStaked(
            stakedAmount
        );

        emit OwnerlessStakeClosed (
            _ownerlessStakeIndex,
            staker,
            stakeIndex,
            stakeID,
            stakedAmount,
            totalReward
        );
    }

    function contributeAsPublic(
        uint256 _amount
    )
        external
    {

        address contributor = msg.sender;

        require(
            allowPublicContributions == true,
            PUBLIC_CONTRIBUTIONS_DISABLED
        );

        safeTransferFrom(
            wiseToken,
            contributor,
            address(this),
            _amount
        );

        uint256 percent = 100 + publicRewardPercent;
        uint256 toReturn = _amount * percent / 100;

        _increasePublicReward(
            contributor,
            toReturn
        );

        _increasePublicDebth(
            toReturn
        );

        require(
            totalPublicDebth <= publicDebthCap,
            EXCEEDING_PUBLIC_DEBTH_CAP
        );

        emit TreasuryFunded(
            _amount,
            contributor,
            getCurrentBuffer()
        );
    }

    function takePublicProfits()
        external
    {

        issuePublicProfits(
            msg.sender
        );
    }

    function issuePublicProfits(
        address _contributor
    )
        public
    {

        require(
            publicReward[_contributor] > 0,
            NO_REWARD_FOR_CONTRIBUTOR
        );

        require(
            totalPublicDebth > 0,
            NO_PUBLIC_DEBTH
        );

        require(
            totalPublicRewards > 0,
            NO_PUBLIC_REWARD_AVAILABLE
        );

        uint256 amount = publicReward[_contributor];

        _decreasePublicDebth(
            amount
        );

        _decreasePublicRewards(
            amount
        );

        _decreasePublicReward(
            _contributor,
            amount
        );

        safeTransfer(
            wiseToken,
            _contributor,
            amount
        );

        emit PublicProfit(
            _contributor,
            amount,
            totalPublicDebth,
            totalPublicRewards
        );
    }

    function givePublicRewards(
        uint256 _amount
    )
        external
        onlyMaster
    {

        _decreaseTotalMasterProfits(
            _amount
        );

        _increasePublicRewards(
            _amount
        );

        require(
            totalPublicRewards <= totalPublicDebth
        );

        require(
            getCoveredPercent(totalPublicRewards) >= payoutThreshold,
            BELOW_PAYOUT_THRESHOLD
        );

        require(
            allowPublicContributions == false,
            PUBLIC_CONTRIBUTION_MUST_BE_DISABLED
        );

        emit publicRewardsGiven(
            _amount,
            totalPublicDebth,
            totalPublicRewards
        );
    }

    function takeMasterProfits(
        uint256 _amount
    )
        external
        onlyMaster
    {

        require(
            totalPublicDebth == 0,
            PUBLIC_DEBTH_NOT_PAID
        );

        safeTransfer(
            wiseToken,
            insuranceMaster,
            _amount
        );

        if (activeInsuranceStakeCount > 0) {
            require(
                _amount <= totalMasterProfits
            );
        }

        _decreaseTotalMasterProfits(
            _amount
        );

        require(
            getCoveredPercent() >= payoutThreshold,
            BELOW_PAYOUT_THRESHOLD
        );

        emit ProfitsTaken(
            _amount,
            getCurrentBuffer()
        );
    }

    function openBufferStake(
        uint256 _amount,
        uint64 _duration,
        address _referrer
    )
        external
        onlyWorker
    {

        require(
            _duration <= maximumBufferStakeDuration
        );

        (bytes16 stakeID, uint256 stakedAmount, bytes16 referralID) =

        WISE_CONTRACT.createStake(
            _amount,
            _duration,
            _referrer
        );

        bufferStakes[bufferStakeCount].stakedAmount = _amount;
        bufferStakes[bufferStakeCount].stakeID = stakeID;
        bufferStakes[bufferStakeCount].isActive = true;

        _increaseTotalBufferStaked(
            _amount
        );

        require(
            totalBufferStaked <= bufferStakeCap
        );

        require(
            getCoveredPercent(_amount) >= coverageThreshold
        );

        _increaseBufferStakeCount();
        _increaseActiveBufferStakeCount();

        emit BufferStakeOpened(
            stakeID,
            stakedAmount,
            referralID
        );
    }

    function closeBufferStake(
        uint256 _stakeIndex
    )
        external
        onlyWorker
    {

        require(
            bufferStakes[_stakeIndex].isActive,
            NOT_ACTIVE_STAKE
        );

        bufferStakes[_stakeIndex].isActive = false;

        bytes16 stakeID = bufferStakes[_stakeIndex].stakeID;

        require(
            checkMatureStake(stakeID) == true,
            NOT_MATURE_STAKE
        );

        uint256 reward = WISE_CONTRACT.endStake(
            stakeID
        );

        uint256 staked = bufferStakes[_stakeIndex].stakedAmount;

        if (getBufferStakeInterest) {
            _withdrawDeveloperFunds(reward);
        } else {
            _increaseTotalMasterProfits(reward);
        }

        _decreaseTotalBufferStaked(
            staked
        );

        _decreaseActiveBufferStakeCount();

        emit BufferStakeClosed(
            stakeID,
            staked,
            reward
        );
    }

    function enableInsurance()
        external
        onlyMaster
    {

        allowInsurance = true;
    }

    function disableInsurance()
        external
        onlyMaster
    {

        allowInsurance = false;
    }

    function changeInsuranceWorker(
        address payable _newInsuranceWorker
    )
        external
        onlyMaster
    {

        insuranceWorker = _newInsuranceWorker;
    }

    function changeStakePercent(
        uint256 _newStakePercent
    )
        external
        onlyMaster
    {

        require(
            _newStakePercent >= 85 &&
            _newStakePercent <= 100
        );

        stakePercent = _newStakePercent;
    }

    function changeInterestCut(
        uint256 _newInterestCut
    )
        external
        onlyMaster
    {

        require(
            _newInterestCut >= 0 &&
            _newInterestCut <= 10
        );

        interestCut = _newInterestCut;
    }

    function changePrincipalCut(
        uint256 _newPrincipalCut
    )
        external
        onlyMaster
    {

        require(
            _newPrincipalCut >= 0 &&
            _newPrincipalCut <= 10
        );

        principalCut = _newPrincipalCut;
    }

    function changePublicRewardPercent(
        uint256 _newPublicRewardPercent
    )
        external
        onlyMaster
    {

        require(
            _newPublicRewardPercent >= 0 &&
            _newPublicRewardPercent <= 50
        );

        publicRewardPercent = _newPublicRewardPercent;
    }

    function changePublicDebthCap(
        uint256 _newPublicDebthCap
    )
        external
        onlyMaster
    {

        publicDebthCap = _newPublicDebthCap;
    }

    function changeMaximumBufferStakeDuration(
        uint256 _newMaximumBufferStakeDuration
    )
        external
        onlyMaster
    {

        maximumBufferStakeDuration = _newMaximumBufferStakeDuration;
    }

    function changeBufferStakeCap(
        uint256 _newBufferStakeCap
    )
        external
        onlyMaster
    {

        bufferStakeCap = _newBufferStakeCap;
    }

    function changePenaltyThresholds(
        uint256 _newPenaltyThresholdA,
        uint256 _newPenaltyThresholdB,
        uint256 _newPenaltyA,
        uint256 _newPenaltyB
    )
        external
        onlyMaster
    {

        require(
            _newPenaltyThresholdB <= 50 &&
            _newPenaltyB <= 15 &&
            _newPenaltyA <= 25
        );

        require(
            _newPenaltyB <= _newPenaltyA &&
            _newPenaltyThresholdA <= _newPenaltyThresholdB
        );

        _newPenaltyThresholdA = _newPenaltyThresholdA;
        _newPenaltyThresholdB = _newPenaltyThresholdB;

        penaltyA = _newPenaltyA;
        penaltyB = _newPenaltyB;
    }

    function changePayoutThreshold(
        uint256 _newPayoutThreshold
    )
        external
        onlyMaster
    {

        require(
            _newPayoutThreshold >= coverageThreshold
        );

        payoutThreshold = _newPayoutThreshold;
    }

    function changeCoverageThreshold(
        uint256 _newCoverageThreshold
    )
        external
        onlyMaster
    {

        coverageThreshold = _newCoverageThreshold;
    }

    function getCurrentBuffer() public view returns (uint256) {

        return WISE_CONTRACT.balanceOf(
            address(this)
        );
    }

    function getCoveredPercent() public view returns (uint256) {

		return totalCovers == 0 ? 100 : getCurrentBuffer() * 100 / totalCovers;
	}

    function getCoveredPercent(uint256 _amount) public view returns (uint256) {

		return totalCovers == 0 ? 100 : (getCurrentBuffer() - _amount) * 100 / totalCovers;
	}

    function checkMatureStake(
        bytes16 _stakeID
    )
        public
        view
        returns (bool)
    {

        return WISE_CONTRACT.checkMatureStake(
            address(this),
            _stakeID
        );
    }

    function canStake()
        external
        view
        returns (bool)
    {

        return getCoveredPercent() >= coverageThreshold;
    }

    function checkMatureStake(
        address _stakeOwner,
        uint256 _stakeIndex
    )
        public
        view
        returns (bool)
    {

        return WISE_CONTRACT.checkMatureStake(
            address(this),
            insuranceStakes[_stakeOwner][_stakeIndex].stakeID
        );
    }

    function _withdrawDeveloperFunds(
        uint256 _amount
    )
        internal
    {

        safeTransfer(
            wiseToken,
            insuranceMaster,
            _amount
        );

        emit DeveloperFundsRouted(
            _amount
        );
    }

    function withdrawOriginalFunds()
        external
        onlyMaster
    {

        uint256 amount = teamContribution;
        teamContribution = 0;
        safeTransfer(
            wiseToken,
            insuranceMaster,
            amount
        );
    }

    function fundTreasury(
        uint256 _amount
    )
        external
        onlyMaster
    {

        teamContribution =
        teamContribution + _amount;

        safeTransferFrom(
            wiseToken,
            insuranceMaster,
            address(this),
            _amount
        );
    }

    function saveTokens(
        address _tokenAddress,
        uint256 _tokenAmount
    )
        external
    {

        require(
            _tokenAddress != wiseToken
        );

        safeTransfer(
            _tokenAddress,
            insuranceMaster,
            _tokenAmount
        );
    }
}