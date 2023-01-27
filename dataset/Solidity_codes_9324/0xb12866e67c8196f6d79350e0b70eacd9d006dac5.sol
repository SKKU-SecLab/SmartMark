

pragma solidity >=0.6 <0.7.0;


contract PollenParams {


    address internal constant pollenDaoAddress = 0x99c0268759d26616AeC761c28336eccd72CCa39A;
    address internal constant plnTokenAddress = 0xF4db951000acb9fdeA6A9bCB4afDe42dd52311C7;
    address internal constant stemTokenAddress = 0xd12ABa72Cad68a63D9C5c6EBE5461fe8fA774B60;
    address internal constant rateQuoterAddress = 0xB7692BBC55C0a8B768E5b523d068B5552fbF7187;

    uint32 internal constant mintStartBlock = 11565019; // Jan-01-2021 00:00:00 +UTC
    uint32 internal constant mintBlocks = 9200000; // ~ 46 months
    uint32 internal constant extraMintBlocks = 600000; // ~ 92 days

    address internal constant rewardsPoolAddress = 0x99c0268759d26616AeC761c28336eccd72CCa39A;
    address internal constant foundationPoolAddress = 0x30dDD235bEd94fdbCDc197513a638D6CAa261EC7;
    address internal constant reservePoolAddress = 0xf8617006b4CD2db7385c1cb613885f1292e51b2e;
    address internal constant marketPoolAddress = 0x256d986bc1d994C36f412b9ED8A269314bA93bc9;
    address internal constant foundersPoolAddress = 0xd7Cc88bB603DceAFB5E8290d8188C8BF36fD742B;

    uint256 internal constant minVestedStemRewarded = 2e4 * 1e18;

    uint32 internal constant defaultVotingExpiryDelay = 12 * 3600;
    uint32 internal constant defaultExecutionOpenDelay = 6 * 3600;
    uint32 internal constant defaultExecutionExpiryDelay = 24 * 3600;
}





interface IPollenTypes {

    enum ProposalType {Invest, Divest}

    enum OrderType {Market, Limit}

    enum BaseCcyType {Asset, Pollen}

    enum ProposalStatus {Null, Submitted, Executed, Rejected, Passed, Pended, Expired}

    enum VoterState {Null, VotedYes, VotedNo}

    enum TokenType {ERC20}

    enum RewardKind {ForVoting, ForProposal, ForExecution, ForStateUpdate, ForPlnHeld}

    struct Proposal {
        ProposalState state;
        ProposalParams params;
        ProposalTerms terms;
    }

    struct ProposalState {
        ProposalStatus status;
        uint96 yesVotes;
        uint96 noVotes;
    }

    struct ProposalParams {
        uint32 votingOpen;
        uint32 votingExpiry;
        uint32 executionOpen;
        uint32 executionExpiry;
        uint32 snapshotId;
        uint96 passVotes; // lowest bit used for `isExclPools` flag
    }

    struct ProposalTerms {
        ProposalType proposalType;
        OrderType orderType;
        BaseCcyType baseCcyType;
        TokenType assetTokenType;
        uint8 votingTermsId; // must be 0 (reserved for upgrades)
        uint64 __reserved1; // reserved for upgrades
        address submitter;
        address executor;
        uint96 __reserved2;
        address assetTokenAddress;
        uint96 pollenAmount;
        uint256 assetTokenAmount;
    }

    struct VoteData {
        VoterState state;
        uint96 votesNum;
    }

    struct Execution {
        uint32 timestamp;
        uint224 quoteCcyAmount;
    }

    struct VotingTerms {
        bool isEnabled;
        bool isExclPools;
        uint8 quorum;
        uint32 votingExpiryDelay;
        uint32 executionOpenDelay;
        uint32 executionExpiryDelay;
    }

    struct RewardParams {
        uint16 forVotingPoints;
        uint16 forProposalPoints;
        uint16 forExecutionPoints;
        uint16 forStateUpdPoints;
        uint16 forPlnDayPoints;
        uint176 __reserved;
    }

    struct RewardTotals {
        uint32 lastAccumBlock;
        uint112 accStemPerPoint;
        uint112 totalPoints;
    }

    struct Reward {
        address member;
        RewardKind kind;
        uint256 points;
    }

    struct MemberRewards {
        uint32 lastUpdateBlock;
        uint64 points;
        uint64 entitled;
        uint96 adjustment;
    }
}


pragma experimental ABIEncoderV2;



interface IStemGrantor is IPollenTypes {


    function getMemberPoints(address member) external view returns(uint256);


    function getMemberRewards(address member) external view  returns(MemberRewards memory);


    function getPendingStem(address member) external view returns(uint256);


    function getRewardTotals() external view  returns(RewardTotals memory);


    function withdrawRewards(address member) external;


    event PointsRewarded(address indexed member, RewardKind indexed kind, uint256 points);

    event RewardWithdrawal(address indexed member, uint256 amount);

    event StemAllocation(uint256 amount);
}



library SafeUint {

    function safe112(uint256 n) internal pure returns(uint112) {

        require(n < 2**112, "SafeUint:UNSAFE_UINT112");
        return uint112(n);
    }

    function safe96(uint256 n) internal pure returns(uint96) {

        require(n < 2**96, "SafeUint:UNSAFE_UINT96");
        return uint96(n);
    }

    function safe64(uint256 n) internal pure returns(uint64) {

        require(n < 2**64, "SafeUint:UNSAFE_UINT64");
        return uint64(n);
    }

    function safe32(uint256 n) internal pure returns(uint32) {

        require(n < 2**32, "SafeUint:UNSAFE_UINT32");
        return uint32(n);
    }

    function safe16(uint256 n) internal pure returns(uint16) {

        require(n < 2**16, "SafeUint:UNSAFE_UINT16");
        return uint16(n);
    }

    function safe8(uint256 n) internal pure returns(uint8) {

        require(n < 256, "SafeUint:UNSAFE_UINT8");
        return uint8(n);
    }
}


pragma solidity ^0.6.0;

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
}









abstract contract StemGrantor is IStemGrantor {
    using SafeMath for uint256;
    using SafeUint for uint256;


    uint256[50] private __gap;

    RewardTotals private _rewardTotals;

    mapping(address => MemberRewards) private _membersRewards;

    function getMemberPoints(address member) public view override returns(uint256)
    {
        return _membersRewards[member].points;
    }

    function getMemberRewards(
        address member
    ) external view  override returns(MemberRewards memory) {
        return _membersRewards[member];
    }

    function getPendingStem(
        address member
    ) external view override returns(uint256 stemAmount)
    {
        MemberRewards memory memberRewards = _membersRewards[member];
        if (memberRewards.points == 0 && memberRewards.entitled == 0 ) return 0;

        uint256 pendingStem = _getPendingRewardStem();
        RewardTotals memory forecastedTotals = _rewardTotals;
        if (forecastedTotals.totalPoints != 0) {
            _computeRewardTotals(forecastedTotals, 0, pendingStem, block.number);
        }

        stemAmount = _computeMemberRewards(
            memberRewards,
            forecastedTotals.accStemPerPoint,
            0,
            block.number
        );
    }

    function getRewardTotals() external view  override returns(RewardTotals memory) {
        return _rewardTotals;
    }

    function withdrawRewards(address member) external override
    {
        (uint256 accStemPerPoint, ) = _updateRewardTotals(0);

        MemberRewards memory memberRewards = _membersRewards[member];
        uint256 stemAmount = _computeMemberRewards(
            memberRewards,
            accStemPerPoint,
            0,
            block.number
        );
        require(stemAmount != 0, "nothing to withdraw");
        _membersRewards[member] = memberRewards;

        _sendStemTo(member, stemAmount);
        emit RewardWithdrawal(member, stemAmount);
    }


    function _getPendingRewardStem() internal view virtual returns (uint256 amount);
    function _withdrawRewardStem() internal virtual returns(uint256 amount);
    function _sendStemTo(address member, uint256 amount) internal virtual;

    function _rewardMember(Reward memory reward) internal
    {
        (uint256 accStemPerPoint, bool isFirstGrant) = _updateRewardTotals(reward.points);
        _bookReward(reward, accStemPerPoint, isFirstGrant);
    }

    function _rewardMembers(Reward[2] memory rewards) internal
    {
        uint256 totalPoints = rewards[0].points + rewards[1].points;
        (uint256 accStemPerPoint, bool isFirstGrant) = _updateRewardTotals(totalPoints);
        _bookReward(rewards[0], accStemPerPoint, isFirstGrant);
        if (rewards[1].points != 0) {
            _bookReward(rewards[1], accStemPerPoint, isFirstGrant);
        }
    }


    function _updateRewardTotals(
        uint256 pointsToAdd
    ) private returns (uint256 accStemPerPoint, bool isFirstGrant)
    {
        uint256 stemToAdd = 0;
        RewardTotals memory totals = _rewardTotals;

        uint256 blockNow = block.number;
        {
            bool isNeverGranted = totals.accStemPerPoint == 0;
            bool isDistributable = (blockNow > totals.lastAccumBlock) && (// once a block
                (totals.totalPoints != 0) || // there are points to distribute between
                (isNeverGranted && pointsToAdd != 0) // it may be the 1st distribution
            );
            if (isDistributable) {
                stemToAdd = _withdrawRewardStem();
                if (stemToAdd != 0) emit StemAllocation(stemToAdd);
            }
        }

        isFirstGrant = _computeRewardTotals(totals, pointsToAdd, stemToAdd, blockNow);
        _rewardTotals = totals;
        accStemPerPoint = totals.accStemPerPoint;
    }

    function _bookReward(Reward memory reward, uint256 accStemPerPoint, bool isFirstGrant)
    private
    {
        MemberRewards memory memberRewards = _membersRewards[reward.member];

        uint256 pointsToAdd = reward.points;
        if (isFirstGrant) {
            memberRewards.points = (pointsToAdd + memberRewards.points).safe64();
            pointsToAdd = 0;
        }

        uint256 stemRewarded = _computeMemberRewards(
            memberRewards,
            accStemPerPoint,
            pointsToAdd,
            block.number
        );
        memberRewards.entitled = _stemToEntitledAmount(
            stemRewarded,
            uint256(memberRewards.entitled)
        );
        _membersRewards[reward.member] = memberRewards;

        emit PointsRewarded(reward.member, reward.kind, reward.points);
    }

    function _computeRewardTotals(
        RewardTotals memory totals,
        uint256 pointsToAdd,
        uint256 stemToAdd,
        uint256 blockNow
    ) internal pure returns(bool isFirstGrant)
    {

        isFirstGrant = (totals.accStemPerPoint == 0) && (stemToAdd != 0);

        uint256 oldPoints = totals.totalPoints;
        if (pointsToAdd != 0) {
            totals.totalPoints = pointsToAdd.add(totals.totalPoints).safe112();
            if (isFirstGrant) oldPoints = pointsToAdd.add(oldPoints);
        }

        if (stemToAdd != 0) {
            uint256 accStemPerPoint = uint256(totals.accStemPerPoint).add(
                stemToAdd.mul(1e6).div(oldPoints) // divider can't be 0
            );
            totals.accStemPerPoint = accStemPerPoint.safe112();
            totals.lastAccumBlock = blockNow.safe32();
        }
    }

    function _computeMemberRewards(
        MemberRewards memory memberRewards,
        uint256 accStemPerPoint,
        uint256 pointsToAdd,
        uint256 blockNow
    ) internal pure returns(uint256 stemAmount)
    {

        stemAmount = _entitledAmountToStemAmount(memberRewards.entitled);
        memberRewards.entitled = 0;
        uint256 oldPoints = memberRewards.points;
        if (pointsToAdd != 0) {
            memberRewards.points = oldPoints.add(pointsToAdd).safe64();
        }

        memberRewards.lastUpdateBlock = blockNow.safe32();
        if (oldPoints != 0) {
            stemAmount = stemAmount.add(
                (accStemPerPoint.mul(oldPoints) / 1e6)
                .sub(memberRewards.adjustment)
            );
        }

        memberRewards.adjustment = (
            accStemPerPoint.mul(memberRewards.points) / 1e6
        ).safe96();
    }

    function _entitledAmountToStemAmount(
        uint64 entitled
    ) private pure returns(uint256 stemAmount) {
        stemAmount = uint256(entitled) * 1e6;
    }

    function _stemToEntitledAmount(
        uint256 stemAmount,
        uint256 prevEntitled
    ) private pure returns(uint64 entitledAmount) {
        uint256 _entitled = prevEntitled.add(stemAmount / 1e6);
        entitledAmount = _entitled < 2**64 ? uint64(_entitled) : 2*64 - 1;
    }
}







interface IPollenDAO is IPollenTypes, IStemGrantor {

    function version() external pure returns (string memory);


    function getPollenAddress() external pure returns(address);


    function getStemAddress() external pure returns(address);


    function getRateQuoterAddress() external pure returns(address);


    function getPollenPrice() external returns(uint256);


    function getProposalCount() external view returns(uint256);


    function getProposal(uint256 proposalId) external view returns(
        ProposalTerms memory terms,
        ProposalParams memory params,
        string memory descriptionCid
    );


    function getProposalState(uint256 proposalId) external view returns(
        ProposalState memory state
    );


    function getVoteData(address voter, uint256 proposalId) external view returns(VoteData memory);


    function getAssets() external view returns (address[] memory);


    function getVotingTerms(uint256 termsId) external view returns(VotingTerms memory);


    function submit(
        ProposalType proposalType,
        OrderType orderType,
        BaseCcyType baseCcyType,
        uint256 termsId,
        TokenType assetTokenType,
        address assetTokenAddress,
        uint256 assetTokenAmount,
        uint256 pollenAmount,
        address executor,
        string memory descriptionCid
    ) external;


    function voteOn(uint256 proposalId, bool vote) external;


    function execute(uint256 proposalId, bytes calldata data) external;


    function redeem(uint256 pollenAmount) external;


    function updateProposalStatus(uint256 proposalId) external;


    function updateRewardPool() external;


    event AssetAdded(address indexed asset);

    event AssetRemoved(address indexed asset);

    event Submitted(
        uint256 proposalId,
        ProposalType proposalType,
        address submitter,
        uint256 snapshotId
    );

    event VotedOn(
        uint256 proposalId,
        address voter,
        bool vote,
        uint256 votes
    );

    event PollenPrice(uint256 price);

    event Executed(
        uint256 proposalId,
        uint256 amount
    );

    event Redeemed(
        address sender,
        uint256 pollenAmount
    );

    event StatusChanged(
        uint proposalId,
        ProposalStatus newStatus,
        ProposalStatus oldStatus
    );

    event VotingTermsSwitched(
        uint256 termsId,
        bool isEnabled
    );

    event RewardParamsUpdated();

    event NewOwner(
        address newOwner,
        address oldOwner
    );
}






interface IPollenDaoAdmin is IPollenTypes {

    function initialize() external;


    function setOwner(address newOwner) external;


    function addAsset(address asset) external;


    function removeAsset(address asset) external;


    function addVotingTerms(VotingTerms memory terms) external;


    function switchVotingTerms(uint256 termsId, bool isEnabled) external;


    function updatePlnWhitelist(
        address[] calldata accounts,
        bool whitelisted
    ) external;


    function updateRewardParams(RewardParams memory _rewardParams) external;

}




interface IMintableBurnable {


    function mint(uint256 amount) external;


    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;

}





interface IWhitelist {


    function isWhitelisted(address account) external view returns (bool);


    function updateWhitelist(address[] calldata accounts, bool whitelisted) external;


    event Whitelist(address addr, bool whitelisted);
}





interface IOwnable {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;


    function renounceOwnership() external;

}




interface ISnapshot {


    event Snapshot(uint256 id);

    function snapshot() external returns (uint256);


    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);


    function totalSupplyAt(uint256 snapshotId) external view returns(uint256);

}


pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}









interface IPollen is IERC20, IOwnable, ISnapshot, IMintableBurnable, IWhitelist {

    function initialize(string memory name, string memory symbol) external;

}



interface IPollenCallee {

    function onExecute(address sender, uint amountIn, uint amountOut, bytes calldata data) external;

}




interface IRateQuoter {


    enum RateTypes { Spot, Fixed }
    enum RateBase { Usd, Eth }
    enum QuoteType { Direct, Indirect }

    struct PriceFeed {
        address feed;
        address asset;
        RateBase base;
        QuoteType side;
        uint8 decimals;
        uint16 maxDelaySecs;
        uint8 priority;
    }

    function initialize() external;


    function quotePrice(address asset) external returns (uint256 rate, uint256 updatedAt);


    function getPriceFeedData(address asset) external view returns (PriceFeed memory);


    function addPriceFeed(PriceFeed memory priceFeed) external;


    function addPriceFeeds(PriceFeed[] memory priceFeeds) external;


    function removePriceFeed(address feed) external;


    event PriceFeedAdded(address indexed asset, address feed);
    event PriceFeedRemoved(address asset);

}





interface IStemVesting {


    struct StemVestingPool {
        bool isRestricted; // if `true`, the 'wallet' only may trigger withdrawal
        uint32 startBlock;
        uint32 endBlock;
        uint32 lastVestedBlock;
        uint128 perBlockStemScaled; // scaled (multiplied) by 1e6
    }

    function initialize(
        address foundationWallet,
        address reserveWallet,
        address foundersWallet,
        address marketWallet
    ) external;


    function getVestingPoolParams(address wallet) external view returns(StemVestingPool memory);


    function getPoolPendingStem(address wallet) external view returns(uint256 amount);


    function withdrawPoolStem(address wallet) external returns (uint256 amount);


    event VestingPool(address indexed wallet);
    event StemWithdrawal(address indexed wallet, uint256 amount);
}



library AddressSet {

    struct Set {
        address[] elements;
        mapping(address => uint256) indexes;
    }

    function add(Set storage self, address value) internal returns (bool)
    {

        if (self.indexes[value] != 0 || value == address(0)) {
            return false;
        }

        self.elements.push(value);
        self.indexes[value] = self.elements.length;
        return true;
    }

    function remove(Set storage self, address value) internal returns (bool)
    {

        if (self.indexes[value] == 0) {
            return false;
        }

        delete(self.elements[self.indexes[value] - 1]);
        self.indexes[value] = 0;
        return true;
    }

    function contains(Set storage self, address value) internal view returns (bool)
    {

        return self.indexes[value] != 0;
    }
}


pragma solidity 0.6.12;

library SafeMath96 {


    function add(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add(uint96 a, uint96 b) internal pure returns (uint96) {

        return add(a, b, "SafeMath96: addition overflow");
    }

    function sub(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub(uint96 a, uint96 b) internal pure returns (uint96) {

        return sub(a, b, "SafeMath96: subtraction overflow");
    }

    function fromUint(uint n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function fromUint(uint n) internal pure returns (uint96) {

        return fromUint(n, "SafeMath96: exceeds 96 bits");
    }
}


pragma solidity 0.6.12;

library SafeMath32 {


    function add(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        uint32 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {

        return add(a, b, "SafeMath32: addition overflow");
    }

    function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {

        return sub(a, b, "SafeMath32: subtraction overflow");
    }

    function fromUint(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function fromUint(uint n) internal pure returns (uint32) {

        return fromUint(n, "SafeMath32: exceeds 32 bits");
    }
}


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;




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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;


contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
}
























contract PollenDAO_v1 is
    Initializable,
    ReentrancyGuardUpgradeSafe,
    PollenParams,
    StemGrantor,
    IPollenDAO,
    IPollenDaoAdmin
{

    using AddressSet for AddressSet.Set;
    using SafeMath for uint256;
    using SafeUint for uint256;
    using SafeMath96 for uint96;
    using SafeMath32 for uint32;
    using SafeERC20 for IERC20;

    uint256 internal constant plnInitialRate = 400e12; // 1ETH = 2500 PLN

    uint16 internal constant forVotingDefaultPoints = 100;
    uint16 internal constant forProposalDefaultPoints = 300;
    uint16 internal constant forExecutionDefaultPoints = 500;
    uint16 internal constant forStateUpdDefaultPoints = 10;
    uint16 internal constant forPlnDayDefaultPoints = 5;
    uint16 internal constant maxForSingleMemberSharePercents = 20;

    uint8 internal constant defaultQuorum = 30;

    uint256 internal constant minDelay = 60;
    uint256 internal constant maxDelay = 3600 * 24 * 365;

    uint256[50] private __gap;

    address private _owner;

    uint32 private _proposalCount;

    uint16 private _votingTermsNum;

    AddressSet.Set private _assets;

    RewardParams public rewardParams;

    mapping(uint256 => VotingTerms) internal _votingTerms;

    mapping(uint256 => Proposal) internal _proposals;

    mapping(uint256 => string) private _descriptionCids;

    mapping(uint256 => Execution) private _executions;

    mapping(address => mapping(uint256 => VoteData)) private _voteData;

    modifier onlyOwner() {

        require(_owner == msg.sender, "PollenDAO: unauthorised call");
        _;
    }

    modifier revertZeroAddress(address _address) {

        require(_address != address(0), "PollenDAO: invalid address");
        _;
    }

    function initialize() external override initializer {

        __ReentrancyGuard_init_unchained();
        _owner = msg.sender;
        _addVotingTerms(
            VotingTerms(
                true, // is enabled
                true, // do not count vesting pools' votes
                defaultQuorum,
                defaultVotingExpiryDelay,
                defaultExecutionOpenDelay,
                defaultExecutionExpiryDelay
            )
        );
        _initRewardParams(
            RewardParams(
                forVotingDefaultPoints,
                forProposalDefaultPoints,
                forExecutionDefaultPoints,
                forStateUpdDefaultPoints,
                forPlnDayDefaultPoints,
                0 // reserved
            )
        );
    }

    function version() external pure override returns (string memory) {

        return "v1";
    }

    function getPollenAddress() external pure override returns(address) {

        return address(_plnAddress());
    }

    function getStemAddress() external pure override returns(address) {

        return _stemAddress();
    }

    function getRateQuoterAddress() external pure override returns(address) {

        return _rateQuoterAddress();
    }

    function getPollenPrice() public override returns(uint256) {

        return _getPollenPrice();
    }

    function getProposalCount() external view override returns(uint256) {

        return _proposalCount;
    }

    function getProposal(uint proposalId) external view override returns (
        ProposalTerms memory terms,
        ProposalParams memory params,
        string memory descriptionCid
    ) {

        _validateProposalId(proposalId);
        terms = _proposals[proposalId].terms;
        params = _proposals[proposalId].params;
        descriptionCid = _descriptionCids[proposalId];
    }

    function getProposalState(
        uint256 proposalId
    ) external view override returns(ProposalState memory state) {

        _validateProposalId(proposalId);
        state = _proposals[proposalId].state;
    }

    function getVoteData(
        address voter,
        uint256 proposalId
    ) external view override returns(VoteData memory) {

        _validateProposalId(proposalId);
        return (_voteData[voter][proposalId]);
    }

    function getAssets() external view override returns (address[] memory) {

        return _assets.elements;
    }

    function getVotingTerms(
        uint256 termsId
    ) external view override returns(VotingTerms memory) {

        return _getTermSheet(termsId);
    }

    function submit(
        ProposalType proposalType,
        OrderType orderType,
        BaseCcyType baseCcyType,
        uint256 termsId,
        TokenType assetTokenType,
        address assetTokenAddress,
        uint256 assetTokenAmount,
        uint256 pollenAmount,
        address executor,
        string memory descriptionCid
    ) external override revertZeroAddress(assetTokenAddress) {

        require(
            IWhitelist(_plnAddress()).isWhitelisted(msg.sender),
            "PollenDAO: unauthorized"
        );
        require(proposalType <= ProposalType.Divest, "PollenDAO: invalid proposal type");
        require(orderType <= OrderType.Limit, "PollenDAO: invalid order type");
        require(baseCcyType <= BaseCcyType.Pollen, "PollenDAO: invalid base ccy type");
        require(assetTokenType == TokenType.ERC20, "PollenDAO: invalid asset type");
        require(_assets.contains(assetTokenAddress), "PollenDAO: unsupported asset");
        require(executor != address(0), "PollenDAO: invalid executor");
        {
            bool isAssetFixed = baseCcyType == BaseCcyType.Asset;
            bool isMarket = orderType == OrderType.Market;
            require(
                isAssetFixed ? assetTokenAmount != 0 : pollenAmount != 0,
                "PollenDAO: zero base amount"
            );
            require(
                isMarket || (isAssetFixed ? pollenAmount != 0 : assetTokenAmount != 0),
                "PollenDAO: invalid quoted amount"
            );
        }

        uint256 proposalId = _proposalCount;
        _proposalCount = (proposalId + 1).safe32();

        _proposals[proposalId].terms = ProposalTerms(
            proposalType,
            orderType,
            baseCcyType,
            assetTokenType,
            termsId.safe8(),
            0, // reserved
            msg.sender,
            executor,
            0, // reserved
            assetTokenAddress,
            pollenAmount.safe96(),
            assetTokenAmount
        );
        _descriptionCids[proposalId] = descriptionCid;

        uint256 snapshotId = 0;

        if (proposalId == 0) {
            uint32 expiry = now.safe32();
            _proposals[proposalId].params = ProposalParams(
                expiry,     // voting open
                expiry,     // voting expiry
                expiry,     // exec open
                expiry.add( // exec expiry
                    defaultExecutionExpiryDelay
                ),
                uint32(snapshotId),
                0           // no voting (zero passVotes)
            );
            _proposals[proposalId].state = ProposalState(ProposalStatus.Passed, 0, 0);
        } else {
            VotingTerms memory terms = _getTermSheet(termsId);
            require(terms.isEnabled, "PollenDAO: disabled terms");
            uint32 votingOpen = now.safe32();
            uint32 votingExpiry = votingOpen.add(terms.votingExpiryDelay);
            uint32 execOpen = votingExpiry.add(terms.executionOpenDelay);
            uint32 execExpiry = execOpen.add(terms.executionExpiryDelay);

            uint256 totalVotes;
            (snapshotId, totalVotes) = _takeSnapshot(terms.isExclPools);
            uint256 passVotes = (totalVotes.mul(terms.quorum) / 100) | 1;
            if (!terms.isExclPools) passVotes -= 1; // even, if pools included

            ProposalParams memory params = ProposalParams(
                votingOpen,
                votingExpiry,
                execOpen,
                execExpiry,
                snapshotId.safe32(),
                passVotes.safe96()
            );
            _proposals[proposalId].params = params;
            _proposals[proposalId].state = ProposalState(ProposalStatus.Submitted, 0, 0);

            uint256 senderVotes = _getVotesOfAt(msg.sender, snapshotId);
            if (senderVotes != 0) {
                _doVoteAndReward(proposalId, params, msg.sender, true, senderVotes);
            }
        }

        emit Submitted(proposalId, proposalType, msg.sender, snapshotId);
    }

    function voteOn(uint256 proposalId, bool vote) external override {

        _validateProposalId(proposalId);
        (ProposalStatus newStatus, ) = _updateProposalStatus(proposalId, ProposalStatus.Null);
        _revertWrongStatus(newStatus, ProposalStatus.Submitted);

        uint256 newVotes = _getVotesOfAt(msg.sender, _proposals[proposalId].params.snapshotId);
        require(newVotes != 0, "PollenDAO: no votes to vote with");

       _doVoteAndReward(proposalId, _proposals[proposalId].params, msg.sender, vote, newVotes);
    }

    function execute(uint256 proposalId, bytes calldata data) external override nonReentrant {

        _validateProposalId(proposalId);

        ProposalTerms memory terms = _proposals[proposalId].terms;
        require(terms.executor == msg.sender, "PollenDAO: unauthorized executor");

        (ProposalStatus newStatus,  ) = _updateProposalStatus(proposalId, ProposalStatus.Null);
        _revertWrongStatus(newStatus, ProposalStatus.Pended);

        IPollen pollen = IPollen(_plnAddress());
        uint256 pollenAmount;
        uint256 assetAmount;
        bool isPollenFixed = terms.baseCcyType == BaseCcyType.Pollen;
        {
            IRateQuoter rateQuoter = IRateQuoter(_rateQuoterAddress());
            (uint256 assetRate, ) = rateQuoter.quotePrice(terms.assetTokenAddress);
            uint256 plnRate = _getPollenPrice();

            if (isPollenFixed) {
                pollenAmount = terms.pollenAmount;
                assetAmount = pollenAmount.mul(plnRate).div(assetRate);
            } else {
                assetAmount = terms.assetTokenAmount;
                pollenAmount = assetAmount.mul(assetRate).div(plnRate);
            }
        }

        bool isLimitOrder = terms.orderType == OrderType.Limit;
        if (terms.proposalType == ProposalType.Invest) {
            if (isLimitOrder) {
                if (isPollenFixed) {
                    if (terms.assetTokenAmount > assetAmount)
                        assetAmount = terms.assetTokenAmount;
                } else {
                    if (terms.pollenAmount < pollenAmount)
                        pollenAmount = terms.pollenAmount;
                }
            }

            pollen.mint(pollenAmount);
            pollen.transfer(msg.sender, pollenAmount);

            if (data.length > 0) {
                IPollenCallee(msg.sender).onExecute(msg.sender, assetAmount, pollenAmount, data);
            }

            IERC20(terms.assetTokenAddress)
            .safeTransferFrom(msg.sender, address(this), assetAmount);
        }
        else if (terms.proposalType == ProposalType.Divest) {
            if (isLimitOrder) {
                if (isPollenFixed) {
                    if (terms.assetTokenAmount < assetAmount)
                        assetAmount = terms.assetTokenAmount;
                } else {
                    if (terms.pollenAmount > pollenAmount)
                        pollenAmount = terms.pollenAmount;
                }
            }

            IERC20(terms.assetTokenAddress).safeTransfer(msg.sender, assetAmount);

            if (data.length > 0) {
                IPollenCallee(msg.sender).onExecute(msg.sender, pollenAmount, assetAmount, data);
            }

            pollen.burnFrom(msg.sender, pollenAmount);
        } else {
            revert("unsupported proposal type");
        }

        uint256 quotedAmount = isPollenFixed ? assetAmount : pollenAmount;

        _executions[proposalId] = Execution(uint32(block.timestamp), uint224(quotedAmount));
        _updateProposalStatus(proposalId, ProposalStatus.Executed);

        emit Executed(proposalId, quotedAmount);

        {
            RewardParams memory p = rewardParams;
            Reward[2] memory rewards;
            rewards[0] = Reward(terms.submitter, RewardKind.ForProposal, p.forProposalPoints);
            rewards[1] = Reward(msg.sender, RewardKind.ForExecution, p.forExecutionPoints);
            _rewardMembers(rewards);
        }
    }

    function redeem(uint256 pollenAmount) external override nonReentrant {

        require(pollenAmount != 0, "PollenDAO: can't redeem zero");

        IPollen pollen = IPollen(_plnAddress());
        uint256 totalSupply = pollen.totalSupply();
        pollen.burnFrom(msg.sender, pollenAmount);

        for (uint256 i=0; i < _assets.elements.length; i++) {
            IERC20 asset = IERC20(_assets.elements[i]);
            if (address(asset) != address(0)) {
                uint256 assetBalance = asset.balanceOf(address(this));
                if (assetBalance == 0) {
                    continue;
                }
                uint256 assetAmount = assetBalance.mul(pollenAmount).div(totalSupply);
                asset.transfer(
                    msg.sender,
                    assetAmount > assetBalance ? assetBalance : assetAmount
                );
            }
        }

        emit Redeemed(
            msg.sender,
            pollenAmount
        );
    }

    function updateProposalStatus(uint256 proposalId) external override {

        (ProposalStatus newStatus,  ProposalStatus oldStatus) = _updateProposalStatus(
            proposalId,
            ProposalStatus.Null
        );
        if (oldStatus != newStatus) {
            RewardParams memory params = rewardParams;
            _rewardMember(Reward(msg.sender, RewardKind.ForStateUpdate, params.forStateUpdPoints));
        }
    }

    function updateRewardPool() external override nonReentrant {

        uint256 pendingStem = IStemVesting(_stemAddress()).getPoolPendingStem(address(this));
        if (pendingStem >= minVestedStemRewarded) {
            RewardParams memory params = rewardParams;
            _rewardMember(Reward(msg.sender, RewardKind.ForStateUpdate, params.forStateUpdPoints));
        }
    }

    function setOwner(address newOwner) external override onlyOwner revertZeroAddress(newOwner) {

        address oldOwner = _owner;
        _owner = newOwner;
        emit NewOwner(newOwner, oldOwner);
    }

    function addAsset(address asset) external override onlyOwner revertZeroAddress(asset) {

        require(!_assets.contains(asset), "PollenDAO: already added");
        require(_assets.add(asset));
        emit AssetAdded(asset);
    }

    function removeAsset(address asset) external override onlyOwner revertZeroAddress(asset) {

        require(_assets.contains(asset), "PollenDAO: unknown asset");
        require(IERC20(asset).balanceOf(address(this)) == 0, "PollenDAO: asset has balance");
        require(_assets.remove(asset));
        emit AssetRemoved(asset);
    }

    function addVotingTerms(VotingTerms memory terms) external override onlyOwner {

        _addVotingTerms(terms);
    }

    function switchVotingTerms(
        uint256 termsId,
        bool isEnabled
    ) external override onlyOwner {

        require(termsId < _votingTermsNum, "PollenDAO: invalid termsId");
        _votingTerms[termsId].isEnabled =  isEnabled;
        emit VotingTermsSwitched(termsId, isEnabled);
    }

    function updatePlnWhitelist(
        address[] calldata accounts,
        bool whitelisted
    ) external override onlyOwner {

        IWhitelist(_plnAddress()).updateWhitelist(accounts, whitelisted);
    }

    function updateRewardParams(RewardParams memory _rewardParams) external override onlyOwner
    {

        _initRewardParams(_rewardParams);
    }

    function preventUseWithoutProxy() external initializer {

    }

    function _addVotingTerms(VotingTerms memory t) internal returns(uint termsId) {

        require(t.quorum <= 100, "PollenDAO: invalid quorum");
        require(
            t.votingExpiryDelay > minDelay &&
            t.executionOpenDelay > minDelay &&
            t.executionExpiryDelay > minDelay &&
            t.votingExpiryDelay < maxDelay &&
            t.executionOpenDelay < maxDelay &&
            t.executionExpiryDelay < maxDelay,
            "PollenDAO: invalid delays"
        );
        termsId = _votingTermsNum;
        _votingTerms[termsId] = t;
        _votingTermsNum = uint16(termsId) + 1;
        emit VotingTermsSwitched(termsId, t.isEnabled);
    }

    function _initRewardParams(RewardParams memory _rewardParams) internal {

        rewardParams = _rewardParams;
        emit RewardParamsUpdated();
    }

    function _updateProposalStatus(
        uint256 proposalId,
        ProposalStatus knownNewStatus
    ) internal returns(ProposalStatus newStatus, ProposalStatus oldStatus)
    {

        ProposalState memory state = _proposals[proposalId].state;
        oldStatus = state.status;
        if (knownNewStatus != ProposalStatus.Null) {
            newStatus = knownNewStatus;
        } else {
            ProposalParams memory params = _proposals[proposalId].params;
            newStatus = _computeProposalStatus(state, params, now);
        }
        if (oldStatus != newStatus) {
            _proposals[proposalId].state.status = newStatus;
            emit StatusChanged(proposalId, newStatus, oldStatus);
        }
    }

    function _computeProposalStatus(
        ProposalState memory state,
        ProposalParams memory params,
        uint256 timeNow
    ) internal pure returns (ProposalStatus) {


        ProposalStatus curStatus = state.status;

        if (
            curStatus == ProposalStatus.Submitted &&
            timeNow >= params.votingExpiry
        ) {
            if (
                (state.yesVotes > state.noVotes) &&
                (state.yesVotes >= params.passVotes)
            ) {
                curStatus = ProposalStatus.Passed;
            } else {
                return ProposalStatus.Rejected;
            }
        }

        if (curStatus == ProposalStatus.Passed) {
            if (timeNow >= params.executionExpiry) return ProposalStatus.Expired;
            if (timeNow >= params.executionOpen) return ProposalStatus.Pended;
        }

        if (
            curStatus == ProposalStatus.Pended &&
            timeNow >= params.executionExpiry
        ) return ProposalStatus.Expired;

        return curStatus;
    }

    function _doVoteAndReward(
        uint256 proposalId,
        ProposalParams memory params,
        address voter,
        bool vote,
        uint256 numOfVotes
    )
    private {

        bool isExclPools = (params.passVotes & 1) == 1;
        if (isExclPools) _revertOnPool(voter);

        bool isNewVote = _addVote(proposalId, voter, vote, numOfVotes);
        if (!isNewVote) return;

        RewardParams memory p = rewardParams;
        Reward[2] memory rewards;
        rewards[0] = Reward(voter, RewardKind.ForVoting, p.forVotingPoints);

        if (proposalId != 0 && p.forPlnDayPoints != 0) {
            uint256 plnBalance = _getPlnBalanceAt(voter, params.snapshotId);
            uint256 secs = params.votingOpen - _proposals[proposalId - 1].params.votingOpen;
            uint256 points = plnBalance.mul(p.forPlnDayPoints)
                .mul(secs)
                .div(86400) // per day
                .div(1e18); // PLN decimals
            rewards[1] = Reward(voter, RewardKind.ForPlnHeld, points);
        }

        _rewardMembers(rewards);
    }

    function _addVote(uint256 proposalId, address voter, bool vote, uint256 numOfVotes)
    private
    returns(bool isNewVote)
    {

        ProposalState memory proposalState = _proposals[proposalId].state;

        VoteData memory prevVote =  _voteData[voter][proposalId];
        isNewVote = prevVote.state == VoterState.Null;

        if (prevVote.state == VoterState.VotedYes) {
            proposalState.yesVotes = proposalState.yesVotes.sub(prevVote.votesNum);
        } else if (prevVote.state == VoterState.VotedNo) {
            proposalState.noVotes = proposalState.noVotes.sub(prevVote.votesNum);
        }

        VoteData memory newVote;
        newVote.votesNum = numOfVotes.safe96();
        if (vote) {
            proposalState.yesVotes = proposalState.yesVotes.add(newVote.votesNum);
            newVote.state = VoterState.VotedYes;
        } else {
            proposalState.noVotes = proposalState.noVotes.add(newVote.votesNum);
            newVote.state = VoterState.VotedNo;
        }

        _proposals[proposalId].state = proposalState;
        _voteData[voter][proposalId] = newVote;
        emit VotedOn(proposalId, voter, vote, newVote.votesNum);
    }

    function _getPollenPrice() internal virtual returns(uint256 price) {

        uint256 totalVal;
        uint256 plnBal = IERC20(_plnAddress()).totalSupply();
        if (plnBal != 0) {
            IRateQuoter rateQuoter = IRateQuoter(_rateQuoterAddress());
            for (uint i; i < _assets.elements.length; i++) {
                uint256 assetBal = IERC20(_assets.elements[i]).balanceOf(address(this));
                if (assetBal == 0) continue;
                (uint256 assetRate, ) = rateQuoter.quotePrice(_assets.elements[i]);
                totalVal = totalVal.add(assetRate.mul(assetBal));
            }
            price = totalVal == 0 ? 0 : totalVal.div(plnBal);
        } else {
            price = plnInitialRate;
        }
        emit PollenPrice(price);
    }

    function _sendStemTo(address member, uint256 amount) internal override {

        IERC20(_stemAddress()).safeTransfer(member, amount);
    }

    function _getPendingRewardStem() internal view override returns(uint256 amount) {

        amount = IStemVesting(_stemAddress()).getPoolPendingStem(address(this));
    }

    function _withdrawRewardStem() internal virtual override returns(uint256 amount) {

        amount = IStemVesting(_stemAddress()).withdrawPoolStem(address(this));
    }

    function _takeSnapshot(
        bool isExclPools
    ) internal virtual returns (uint256 snapshotId, uint256 totalVotes) {

        {
            IPollen stem = IPollen(_stemAddress());
            uint256 plnSnapId = IPollen(_plnAddress()).snapshot();
            uint256 stmSnapId = stem.snapshot();
            snapshotId = _encodeSnapshotId(plnSnapId, stmSnapId);
            totalVotes = stem.totalSupplyAt(stmSnapId);
        }
        {
            if (isExclPools && (totalVotes != 0)) {
                totalVotes = totalVotes
                .sub(_getVotesOfAt(foundationPoolAddress, snapshotId))
                .sub(_getVotesOfAt(reservePoolAddress, snapshotId))
                .sub(_getVotesOfAt(foundersPoolAddress, snapshotId));
            }
        }
    }

    function _getVotesOfAt(
        address member,
        uint256 snapshotId
    ) internal virtual view returns(uint) {

        ( , uint256 stmSnapId) = _decodeSnapshotId(snapshotId);
        return IPollen(_stemAddress()).balanceOfAt(member, stmSnapId);
    }

    function _getTotalVotesAt(uint256 snapshotId) internal view  virtual returns(uint256) {

        (, uint256 stmSnapId) = _decodeSnapshotId(snapshotId);
        return IPollen(_stemAddress()).totalSupplyAt(stmSnapId);
    }

    function _getPlnBalanceAt(
        address member,
        uint256 snapshotId
    ) internal view  virtual returns(uint256) {

        (uint256 plnSnapId, ) = _decodeSnapshotId(snapshotId);
        return IPollen(_plnAddress()).balanceOfAt(member, plnSnapId);
    }

    function _revertOnPool(address account) internal pure virtual {

        require(
            account != foundationPoolAddress &&
            account != reservePoolAddress &&
            account != marketPoolAddress &&
            account != foundersPoolAddress,
            "PollenDAO: pools not allowed"
        );
    }

    function _validateProposalId(uint256 proposalId) private view {

        require(proposalId < _proposalCount, "PollenDAO: invalid proposal id");
    }

    function _getTermSheet(uint256 termsId) private view returns(VotingTerms memory terms) {

        terms = _votingTerms[termsId];
        require(terms.quorum != 0, "PollenDAO: invalid termsId");
    }

    function _encodeSnapshotId(
        uint plnSnapId,
        uint stmSnapId
    ) private pure returns(uint256) {

        if (plnSnapId == stmSnapId) return plnSnapId;
        return (plnSnapId << 16) | stmSnapId;
    }

    function _decodeSnapshotId(
        uint256 encodedId
    ) private pure returns(uint256 plnSnapId, uint256 stmSnapId) {

        if ((encodedId & 0xFFFF0000) == 0) return (encodedId, encodedId);
        plnSnapId = encodedId >> 16;
        stmSnapId = encodedId & 0xFFFF;
    }

    function _revertWrongStatus(
        ProposalStatus status,
        ProposalStatus expectedStatus
    ) private pure {

        require(status == expectedStatus, "PollenDAO: wrong proposal status");
    }

    function _plnAddress() internal pure virtual returns(address) {

        return plnTokenAddress;
    }
    function _stemAddress() internal pure virtual returns(address) {

        return stemTokenAddress;
    }
    function _rateQuoterAddress() internal pure virtual returns(address) {

        return rateQuoterAddress;
    }
}