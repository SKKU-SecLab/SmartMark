
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
}// Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


library LibReignStorage {


    bytes32 constant STORAGE_POSITION = keccak256("org.sovreign.reign.storage");

    struct Checkpoint {
        uint256 timestamp;
        uint256 amount;
    }

    struct EpochBalance {
        uint128 epochId;
        uint128 multiplier;
        uint256 startBalance;
        uint256 newDeposits;
    }

    struct Stake {
        uint256 timestamp;
        uint256 amount;
        uint256 expiryTimestamp;
        address delegatedTo;
        uint256 stakingBoost;
    }

    struct Storage {
        bool initialized;
        mapping(address => Stake[]) userStakeHistory;
        mapping(address => EpochBalance[]) userBalanceHistory;
        mapping(address => uint128) lastWithdrawEpochId;
        Checkpoint[] reignStakedHistory;
        mapping(address => Checkpoint[]) delegatedPowerHistory;
        IERC20 reign; // the reign Token
        uint256 epoch1Start;
        uint256 epochDuration;
    }

    function reignStorage() internal pure returns (Storage storage ds) {

        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}// Apache-2.0
pragma solidity 0.7.6;


interface IReign {

    function BASE_MULTIPLIER() external view returns (uint256);


    function deposit(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function lock(uint256 timestamp) external;


    function delegate(address to) external;


    function stopDelegate() external;


    function lockCreatorBalance(address user, uint256 timestamp) external;


    function balanceOf(address user) external view returns (uint256);


    function balanceAtTs(address user, uint256 timestamp)
        external
        view
        returns (uint256);


    function stakeAtTs(address user, uint256 timestamp)
        external
        view
        returns (LibReignStorage.Stake memory);


    function votingPower(address user) external view returns (uint256);


    function votingPowerAtTs(address user, uint256 timestamp)
        external
        view
        returns (uint256);


    function reignStaked() external view returns (uint256);


    function reignStakedAtTs(uint256 timestamp) external view returns (uint256);


    function delegatedPower(address user) external view returns (uint256);


    function delegatedPowerAtTs(address user, uint256 timestamp)
        external
        view
        returns (uint256);


    function stakingBoost(address user) external view returns (uint256);


    function stackingBoostAtTs(address user, uint256 timestamp)
        external
        view
        returns (uint256);


    function userLockedUntil(address user) external view returns (uint256);


    function userDelegatedTo(address user) external view returns (address);


    function userLastAction(address user) external view returns (uint256);


    function reignCirculatingSupply() external view returns (uint256);


    function getEpochDuration() external view returns (uint256);


    function getEpoch1Start() external view returns (uint256);


    function getCurrentEpoch() external view returns (uint128);


    function stakingBoostAtEpoch(address, uint128)
        external
        view
        returns (uint256);


    function getEpochUserBalance(address, uint128)
        external
        view
        returns (uint256);

}// Apache-2.0
pragma solidity 0.7.6;

interface IPoolRouter {

    function getPoolTokens() external view returns (address[] memory);


    function getTokenWeights() external view returns (uint256[] memory);

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
}// Apache-2.0
pragma solidity 0.7.6;


contract BasketBalancer {

    using SafeMath for uint256;

    uint256 public fullAllocation;
    uint128 public lastEpochUpdate;
    uint256 public lastEpochEnd;
    uint256 public maxDelta;

    address[] private allTokens;

    mapping(address => uint256) public continuousVote;
    mapping(address => uint256) private tokenAllocation;
    mapping(address => uint256) private tokenAllocationBefore;
    mapping(address => mapping(uint128 => bool)) private votedInEpoch;

    IReign private reign;
    address public poolRouter;
    address public reignDAO;
    address public reignDiamond;

    event UpdateAllocation(
        uint128 indexed epoch,
        address indexed pool,
        uint256 indexed allocation
    );
    event VoteOnAllocation(
        address indexed sender,
        address indexed pool,
        uint256 indexed allocation,
        uint128 epoch
    );

    event NewToken(address indexed pool, uint256 indexed allocation);
    event RemoveToken(address indexed pool);

    modifier onlyDAO() {

        require(msg.sender == reignDAO, "Only the DAO can execute this");
        _;
    }

    constructor(
        address _reignDiamond,
        address _reignDAO,
        address _poolRouter,
        uint256 _maxDelta
    ) {
        uint256 amountAllocated = 0;

        address[] memory tokens = IPoolRouter(_poolRouter).getPoolTokens();
        uint256[] memory weights = IPoolRouter(_poolRouter).getTokenWeights();

        for (uint256 i = 0; i < tokens.length; i++) {
            tokenAllocation[tokens[i]] = weights[i];
            tokenAllocationBefore[tokens[i]] = weights[i];
            continuousVote[tokens[i]] = weights[i];
            amountAllocated = amountAllocated.add(weights[i]);
        }
        fullAllocation = amountAllocated;

        lastEpochUpdate = 0;
        maxDelta = _maxDelta;
        allTokens = tokens;
        reign = IReign(_reignDiamond);
        reignDiamond = _reignDiamond;
        reignDAO = _reignDAO;
        poolRouter = _poolRouter;
    }

    function updateBasketBalance() public onlyDAO {

        uint128 _epochId = getCurrentEpoch();
        require(lastEpochUpdate < _epochId, "Epoch is not over");

        for (uint256 i = 0; i < allTokens.length; i++) {
            uint256 _currentValue = continuousVote[allTokens[i]]; // new vote outcome
            uint256 _previousValue = tokenAllocation[allTokens[i]]; // before this vote

            tokenAllocation[allTokens[i]] = (_currentValue.add(_previousValue))
                .div(2);

            tokenAllocationBefore[allTokens[i]] = _previousValue;

            emit UpdateAllocation(
                _epochId,
                allTokens[i],
                tokenAllocation[allTokens[i]]
            );
        }

        lastEpochUpdate = _epochId;
        lastEpochEnd = block.timestamp;
    }

    function updateAllocationVote(
        address[] calldata tokens,
        uint256[] calldata allocations
    ) external {

        uint128 _epoch = getCurrentEpoch();

        require(
            tokens.length == allTokens.length,
            "Need to vote for all tokens"
        );
        require(
            tokens.length == allocations.length,
            "Need to have same length"
        );
        require(reign.balanceOf(msg.sender) > 0, "Not allowed to vote");

        require(
            votedInEpoch[msg.sender][_epoch] == false,
            "Can not vote twice in an epoch"
        );

        uint256 _votingPower = reign.votingPowerAtTs(msg.sender, lastEpochEnd);
        uint256 _totalPower = reign.reignStaked();

        uint256 _remainingPower = _totalPower.sub(_votingPower);

        uint256 amountAllocated = 0;
        for (uint256 i = 0; i < allTokens.length; i++) {
            require(allTokens[i] == tokens[i], "tokens have incorrect order");
            uint256 _votedFor = allocations[i];
            uint256 _current = continuousVote[allTokens[i]];
            amountAllocated = amountAllocated.add(_votedFor);

            if (_votedFor > _current) {
                require(_votedFor - _current <= maxDelta, "Above Max Delta");
            } else {
                require(_current - _votedFor <= maxDelta, "Above Max Delta");
            }
            continuousVote[allTokens[i]] = (
                _current.mul(_remainingPower).add(_votedFor.mul(_votingPower))
            )
                .div(_totalPower);

            emit VoteOnAllocation(msg.sender, allTokens[i], _votedFor, _epoch);
        }

        require(
            amountAllocated == fullAllocation,
            "Allocation is not complete"
        );

        votedInEpoch[msg.sender][_epoch] = true;
    }

    function addToken(address token, uint256 allocation)
        external
        onlyDAO
        returns (uint256)
    {

        allTokens.push(token);
        tokenAllocationBefore[token] = allocation;
        tokenAllocation[token] = allocation;
        continuousVote[token] = allocation;

        fullAllocation = fullAllocation.add(allocation);

        emit NewToken(token, allocation);

        return allTokens.length;
    }

    function removeToken(address token) external onlyDAO returns (uint256) {

        require(tokenAllocation[token] != 0, "Token is not part of Basket");

        fullAllocation = fullAllocation.sub(continuousVote[token]);

        uint256 index;
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (allTokens[i] == token) {
                index = i;
                break;
            }
        }

        for (uint256 i = index; i < allTokens.length - 1; i++) {
            allTokens[i] = allTokens[i + 1];
        }
        allTokens.pop();

        tokenAllocationBefore[token] = 0;
        tokenAllocation[token] = 0;
        continuousVote[token] = 0;

        emit RemoveToken(token);

        return allTokens.length;
    }


    function setRouter(address _poolRouter) public onlyDAO {

        poolRouter = _poolRouter;
    }

    function setReignDAO(address _reignDAO) public onlyDAO {

        reignDAO = _reignDAO;
    }

    function setMaxDelta(uint256 _maxDelta) public onlyDAO {

        maxDelta = _maxDelta;
    }


    function getTargetAllocation(address pool) public view returns (uint256) {

        return tokenAllocation[pool];
    }

    function getCurrentEpoch() public view returns (uint128) {

        return reign.getCurrentEpoch();
    }

    function getTokens() external view returns (address[] memory) {

        return allTokens;
    }

    function hasVotedInEpoch(address user, uint128 epoch)
        external
        view
        returns (bool)
    {

        return votedInEpoch[user][epoch];
    }
}