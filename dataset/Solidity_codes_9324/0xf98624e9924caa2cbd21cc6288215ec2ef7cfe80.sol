pragma solidity >=0.7.4;

contract TellorStorage {

    struct Details {
        uint256 value;
        address miner;
    }
    struct Dispute {
        bytes32 hash; //unique hash of dispute: keccak256(_miner,_requestId,_timestamp)
        int256 tally; //current tally of votes for - against measure
        bool executed; //is the dispute settled
        bool disputeVotePassed; //did the vote pass?
        bool isPropFork; //true for fork proposal NEW
        address reportedMiner; //miner who submitted the 'bad value' will get disputeFee if dispute vote fails
        address reportingParty; //miner reporting the 'bad value'-pay disputeFee will get reportedMiner's stake if dispute vote passes
        address proposedForkAddress; //new fork address (if fork proposal)
        mapping(bytes32 => uint256) disputeUintVars;
        mapping(address => bool) voted; //mapping of address to whether or not they voted
    }
    struct StakeInfo {
        uint256 currentStatus; //0-not Staked, 1=Staked, 2=LockedForWithdraw 3= OnDispute 4=ReadyForUnlocking 5=Unlocked
        uint256 startDate; //stake start date
    }
    struct Checkpoint {
        uint128 fromBlock; // fromBlock is the block number that the value was generated from
        uint128 value; // value is the amount of tokens at a specific block number
    }
    struct Request {
        uint256[] requestTimestamps; //array of all newValueTimestamps requested
        mapping(bytes32 => uint256) apiUintVars;
        mapping(uint256 => uint256) minedBlockNum; //[apiId][minedTimestamp]=>block.number
        mapping(uint256 => uint256) finalValues;
        mapping(uint256 => bool) inDispute; //checks if API id is in dispute or finalized.
        mapping(uint256 => address[5]) minersByValue;
        mapping(uint256 => uint256[5]) valuesByTimestamp;
    }
    uint256[51] requestQ; //uint50 array of the top50 requests by payment amount
    uint256[] public newValueTimestamps; //array of all timestamps requested
    mapping(uint256 => uint256) requestIdByTimestamp; //minedTimestamp to apiId
    mapping(uint256 => uint256) requestIdByRequestQIndex; //link from payoutPoolIndex (position in payout pool array) to apiId
    mapping(uint256 => Dispute) public disputesById; //disputeId=> Dispute details
    mapping(bytes32 => uint256) public requestIdByQueryHash; // api bytes32 gets an id = to count of requests array
    mapping(bytes32 => uint256) public disputeIdByDisputeHash; //maps a hash to an ID for each dispute
    mapping(bytes32 => mapping(address => bool)) public minersByChallenge;
    Details[5] public currentMiners; //This struct is for organizing the five mined values to find the median
    mapping(address => StakeInfo) stakerDetails; //mapping from a persons address to their staking info
    mapping(uint256 => Request) requestDetails;
    mapping(bytes32 => uint256) public uints;
    mapping(bytes32 => address) public addresses;
    mapping(bytes32 => bytes32) public bytesVars;
    mapping(address => Checkpoint[]) public balances;
    mapping(address => mapping(address => uint256)) public _allowances;
    mapping(address => bool) public migrated;
}// MIT
pragma solidity >=0.7.4;

contract TellorVariables {

    bytes32 constant _BLOCK_NUMBER =
        0x4b4cefd5ced7569ef0d091282b4bca9c52a034c56471a6061afd1bf307a2de7c; //keccak256("_BLOCK_NUMBER");
    bytes32 constant _CURRENT_CHALLENGE =
        0xd54702836c9d21d0727ffacc3e39f57c92b5ae0f50177e593bfb5ec66e3de280; //keccak256("_CURRENT_CHALLENGE");
    bytes32 constant _CURRENT_REQUESTID =
        0xf5126bb0ac211fbeeac2c0e89d4c02ac8cadb2da1cfb27b53c6c1f4587b48020; //keccak256("_CURRENT_REQUESTID");
    bytes32 constant _CURRENT_REWARD =
        0xd415862fd27fb74541e0f6f725b0c0d5b5fa1f22367d9b78ec6f61d97d05d5f8; //keccak256("_CURRENT_REWARD");
    bytes32 constant _CURRENT_TOTAL_TIPS =
        0x09659d32f99e50ac728058418d38174fe83a137c455ff1847e6fb8e15f78f77a; //keccak256("_CURRENT_TOTAL_TIPS");
    bytes32 constant _DEITY =
        0x5fc094d10c65bc33cc842217b2eccca0191ff24148319da094e540a559898961; //keccak256("_DEITY");
    bytes32 constant _DIFFICULTY =
        0xf758978fc1647996a3d9992f611883adc442931dc49488312360acc90601759b; //keccak256("_DIFFICULTY");
    bytes32 constant _DISPUTE_COUNT =
        0x310199159a20c50879ffb440b45802138b5b162ec9426720e9dd3ee8bbcdb9d7; //keccak256("_DISPUTE_COUNT");
    bytes32 constant _DISPUTE_FEE =
        0x675d2171f68d6f5545d54fb9b1fb61a0e6897e6188ca1cd664e7c9530d91ecfc; //keccak256("_DISPUTE_FEE");
    bytes32 constant _DISPUTE_ROUNDS =
        0x6ab2b18aafe78fd59c6a4092015bddd9fcacb8170f72b299074f74d76a91a923; //keccak256("_DISPUTE_ROUNDS");
    bytes32 constant _EXTENSION =
        0x2b2a1c876f73e67ebc4f1b08d10d54d62d62216382e0f4fd16c29155818207a4; //keccak256("_EXTENSION");
    bytes32 constant _FEE =
        0x1da95f11543c9b03927178e07951795dfc95c7501a9d1cf00e13414ca33bc409; //keccak256("_FEE");
    bytes32 constant _FORK_EXECUTED =
        0xda571dfc0b95cdc4a3835f5982cfdf36f73258bee7cb8eb797b4af8b17329875; //keccak256("_FORK_EXECUTED");
    bytes32 constant _LOCK =
        0xd051321aa26ce60d202f153d0c0e67687e975532ab88ce92d84f18e39895d907;
    bytes32 constant _MIGRATOR =
        0xc6b005d45c4c789dfe9e2895b51df4336782c5ff6bd59a5c5c9513955aa06307; //keccak256("_MIGRATOR");
    bytes32 constant _MIN_EXECUTION_DATE =
        0x46f7d53798d31923f6952572c6a19ad2d1a8238d26649c2f3493a6d69e425d28; //keccak256("_MIN_EXECUTION_DATE");
    bytes32 constant _MINER_SLOT =
        0x6de96ee4d33a0617f40a846309c8759048857f51b9d59a12d3c3786d4778883d; //keccak256("_MINER_SLOT");
    bytes32 constant _NUM_OF_VOTES =
        0x1da378694063870452ce03b189f48e04c1aa026348e74e6c86e10738514ad2c4; //keccak256("_NUM_OF_VOTES");
    bytes32 constant _OLD_TELLOR =
        0x56e0987db9eaec01ed9e0af003a0fd5c062371f9d23722eb4a3ebc74f16ea371; //keccak256("_OLD_TELLOR");
    bytes32 constant _ORIGINAL_ID =
        0xed92b4c1e0a9e559a31171d487ecbec963526662038ecfa3a71160bd62fb8733; //keccak256("_ORIGINAL_ID");
    bytes32 constant _OWNER =
        0x7a39905194de50bde334d18b76bbb36dddd11641d4d50b470cb837cf3bae5def; //keccak256("_OWNER");
    bytes32 constant _PAID =
        0x29169706298d2b6df50a532e958b56426de1465348b93650fca42d456eaec5fc; //keccak256("_PAID");
    bytes32 constant _PENDING_OWNER =
        0x7ec081f029b8ac7e2321f6ae8c6a6a517fda8fcbf63cabd63dfffaeaafa56cc0; //keccak256("_PENDING_OWNER");
    bytes32 constant _REQUEST_COUNT =
        0x3f8b5616fa9e7f2ce4a868fde15c58b92e77bc1acd6769bf1567629a3dc4c865; //keccak256("_REQUEST_COUNT");
    bytes32 constant _REQUEST_ID =
        0x9f47a2659c3d32b749ae717d975e7962959890862423c4318cf86e4ec220291f; //keccak256("_REQUEST_ID");
    bytes32 constant _REQUEST_Q_POSITION =
        0xf68d680ab3160f1aa5d9c3a1383c49e3e60bf3c0c031245cbb036f5ce99afaa1; //keccak256("_REQUEST_Q_POSITION");
    bytes32 constant _SLOT_PROGRESS =
        0xdfbec46864bc123768f0d134913175d9577a55bb71b9b2595fda21e21f36b082; //keccak256("_SLOT_PROGRESS");
    bytes32 constant _STAKE_AMOUNT =
        0x5d9fadfc729fd027e395e5157ef1b53ef9fa4a8f053043c5f159307543e7cc97; //keccak256("_STAKE_AMOUNT");
    bytes32 constant _STAKE_COUNT =
        0x10c168823622203e4057b65015ff4d95b4c650b308918e8c92dc32ab5a0a034b; //keccak256("_STAKE_COUNT");
    bytes32 constant _T_BLOCK =
        0xf3b93531fa65b3a18680d9ea49df06d96fbd883c4889dc7db866f8b131602dfb; //keccak256("_T_BLOCK");
    bytes32 constant _TALLY_DATE =
        0xf9e1ae10923bfc79f52e309baf8c7699edb821f91ef5b5bd07be29545917b3a6; //keccak256("_TALLY_DATE");
    bytes32 constant _TARGET_MINERS =
        0x0b8561044b4253c8df1d9ad9f9ce2e0f78e4bd42b2ed8dd2e909e85f750f3bc1; //keccak256("_TARGET_MINERS");
    bytes32 constant _TELLOR_CONTRACT =
        0x0f1293c916694ac6af4daa2f866f0448d0c2ce8847074a7896d397c961914a08; //keccak256("_TELLOR_CONTRACT");
    bytes32 constant _TELLOR_GETTERS =
        0xabd9bea65759494fe86471c8386762f989e1f2e778949e94efa4a9d1c4b3545a; //keccak256("_TELLOR_GETTERS");
    bytes32 constant _TIME_OF_LAST_NEW_VALUE =
        0x2c8b528fbaf48aaf13162a5a0519a7ad5a612da8ff8783465c17e076660a59f1; //keccak256("_TIME_OF_LAST_NEW_VALUE");
    bytes32 constant _TIME_TARGET =
        0xd4f87b8d0f3d3b7e665df74631f6100b2695daa0e30e40eeac02172e15a999e1; //keccak256("_TIME_TARGET");
    bytes32 constant _TIMESTAMP =
        0x2f9328a9c75282bec25bb04befad06926366736e0030c985108445fa728335e5; //keccak256("_TIMESTAMP");
    bytes32 constant _TOTAL_SUPPLY =
        0xe6148e7230ca038d456350e69a91b66968b222bfac9ebfbea6ff0a1fb7380160; //keccak256("_TOTAL_SUPPLY");
    bytes32 constant _TOTAL_TIP =
        0x1590276b7f31dd8e2a06f9a92867333eeb3eddbc91e73b9833e3e55d8e34f77d; //keccak256("_TOTAL_TIP");
    bytes32 constant _VALUE =
        0x9147231ab14efb72c38117f68521ddef8de64f092c18c69dbfb602ffc4de7f47; //keccak256("_VALUE");
    bytes32 constant _EIP_SLOT =
        0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;
}// MIT
pragma solidity 0.8.3;


contract TellorVars is TellorVariables {

    address constant TELLOR_ADDRESS =
        0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0; // Address of main Tellor Contract
    bytes32 constant _GOVERNANCE_CONTRACT =
        0xefa19baa864049f50491093580c5433e97e8d5e41f8db1a61108b4fa44cacd93;
    bytes32 constant _ORACLE_CONTRACT =
        0xfa522e460446113e8fd353d7fa015625a68bc0369712213a42e006346440891e;
    bytes32 constant _TREASURY_CONTRACT =
        0x1436a1a60dca0ebb2be98547e57992a0fa082eb479e7576303cbd384e934f1fa;
    bytes32 constant _SWITCH_TIME =
        0x6c0e91a96227393eb6e42b88e9a99f7c5ebd588098b549c949baf27ac9509d8f;
    bytes32 constant _MINIMUM_DISPUTE_FEE =
        0x7335d16d7e7f6cb9f532376441907fe76aa2ea267285c82892601f4755ed15f0;
}// MIT
pragma solidity 0.8.3;

interface IGovernance{

    enum VoteResult {FAILED,PASSED,INVALID}
    function setApprovedFunction(bytes4 _func, bool _val) external;

    function beginDispute(bytes32 _queryId,uint256 _timestamp) external;

    function delegate(address _delegate) external;

    function delegateOfAt(address _user, uint256 _blockNumber) external view returns (address);

    function executeVote(uint256 _disputeId) external;

    function proposeVote(address _contract,bytes4 _function, bytes calldata _data, uint256 _timestamp) external;

    function tallyVotes(uint256 _disputeId) external;

    function updateMinDisputeFee() external;

    function verify() external pure returns(uint);

    function vote(uint256 _disputeId, bool _supports, bool _invalidQuery) external;

    function voteFor(address[] calldata _addys,uint256 _disputeId, bool _supports, bool _invalidQuery) external;

    function getDelegateInfo(address _holder) external view returns(address,uint);

    function isApprovedGovernanceContract(address _contract) external view returns(bool);

    function isFunctionApproved(bytes4 _func) external view returns(bool);

    function getVoteCount() external view returns(uint256);

    function getVoteRounds(bytes32 _hash) external view returns(uint256[] memory);

    function getVoteInfo(uint256 _disputeId) external view returns(bytes32,uint256[8] memory,bool[2] memory,VoteResult,bytes memory,bytes4,address[2] memory);

    function getDisputeInfo(uint256 _disputeId) external view returns(uint256,uint256,bytes memory, address);

    function getOpenDisputesOnId(uint256 _queryId) external view returns(uint256);

    function didVote(uint256 _disputeId, address _voter) external view returns(bool);

    function testMin(uint256 a, uint256 b) external pure returns (uint256);

}// MIT
pragma solidity 0.8.3;


contract Token is TellorStorage, TellorVars {

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    ); // ERC20 Approval event
    event Transfer(address indexed _from, address indexed _to, uint256 _value); // ERC20 Transfer Event

    function allowance(address _user, address _spender)
        external
        view
        returns (uint256)
    {

        return _allowances[_user][_spender];
    }

    function allowedToTrade(address _user, uint256 _amount)
        public
        view
        returns (bool)
    {

        if (
            stakerDetails[_user].currentStatus != 0 &&
            stakerDetails[_user].currentStatus < 5
        ) {
            return (balanceOf(_user) - uints[_STAKE_AMOUNT] >= _amount);
        }
        return (balanceOf(_user) >= _amount); // Else, check if balance is greater than amount they want to spend
    }

    function approve(address _spender, uint256 _amount)
        external
        returns (bool)
    {

        require(_spender != address(0), "ERC20: approve to the zero address");
        _allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function approveAndTransferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool) {

        require(
            (IGovernance(addresses[_GOVERNANCE_CONTRACT])
                .isApprovedGovernanceContract(msg.sender) ||
                msg.sender == addresses[_TREASURY_CONTRACT] ||
                msg.sender == addresses[_ORACLE_CONTRACT]),
            "Only the Governance, Treasury, or Oracle Contract can approve and transfer tokens"
        );
        _doTransfer(_from, _to, _amount);
        return true;
    }

    function balanceOf(address _user) public view returns (uint256) {

        return balanceOfAt(_user, block.number);
    }

    function balanceOfAt(address _user, uint256 _blockNumber)
        public
        view
        returns (uint256)
    {

        TellorStorage.Checkpoint[] storage checkpoints = balances[_user];
        if (
            checkpoints.length == 0 || checkpoints[0].fromBlock > _blockNumber
        ) {
            return 0;
        } else {
            if (_blockNumber >= checkpoints[checkpoints.length - 1].fromBlock)
                return checkpoints[checkpoints.length - 1].value;
            uint256 _min = 0;
            uint256 _max = checkpoints.length - 2;
            while (_max > _min) {
                uint256 _mid = (_max + _min + 1) / 2;
                if (checkpoints[_mid].fromBlock == _blockNumber) {
                    return checkpoints[_mid].value;
                } else if (checkpoints[_mid].fromBlock < _blockNumber) {
                    _min = _mid;
                } else {
                    _max = _mid - 1;
                }
            }
            return checkpoints[_min].value;
        }
    }

    function burn(uint256 _amount) external {

        _doBurn(msg.sender, _amount);
    }

    function transfer(address _to, uint256 _amount)
        external
        returns (bool success)
    {

        _doTransfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool success) {

        require(
            _allowances[_from][msg.sender] >= _amount,
            "Allowance is wrong"
        );
        _allowances[_from][msg.sender] -= _amount;
        _doTransfer(_from, _to, _amount);
        return true;
    }

    function _doBurn(address _from, uint256 _amount) internal {

        if (_amount == 0) return;
        require(
            allowedToTrade(_from, _amount),
            "Should have sufficient balance to trade"
        );
        uint128 _previousBalance = uint128(balanceOf(_from));
        uint128 _sizedAmount = uint128(_amount);
        _updateBalanceAtNow(_from, _previousBalance - _sizedAmount);
        uints[_TOTAL_SUPPLY] -= _amount;
    }

    function _doMint(address _to, uint256 _amount) internal {

        require(_amount != 0, "Tried to mint non-positive amount");
        require(_to != address(0), "Receiver is 0 address");
        uint128 _previousBalance = uint128(balanceOf(_to));
        uint128 _sizedAmount = uint128(_amount);
        uints[_TOTAL_SUPPLY] += _amount;
        _updateBalanceAtNow(_to, _previousBalance + _sizedAmount);
        emit Transfer(address(0), _to, _amount);
    }

    function _doTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal {

        require(_amount != 0, "Tried to send non-positive amount");
        require(_to != address(0), "Receiver is 0 address");
        require(
            allowedToTrade(_from, _amount),
            "Should have sufficient balance to trade"
        );
        uint128 _previousBalance = uint128(balanceOf(_from));
        uint128 _sizedAmount = uint128(_amount);
        _updateBalanceAtNow(_from, _previousBalance - _sizedAmount);
        _previousBalance = uint128(balanceOf(_to));
        _updateBalanceAtNow(_to, _previousBalance + _sizedAmount);
        emit Transfer(_from, _to, _amount);
    }

    function _updateBalanceAtNow(address _user, uint128 _value) internal {

        Checkpoint[] storage checkpoints = balances[_user];
        if (
            checkpoints.length == 0 ||
            checkpoints[checkpoints.length - 1].fromBlock != block.number
        ) {
            checkpoints.push(
                TellorStorage.Checkpoint({
                    fromBlock: uint128(block.number),
                    value: _value
                })
            );
        } else {
            TellorStorage.Checkpoint storage oldCheckPoint = checkpoints[
                checkpoints.length - 1
            ];
            oldCheckPoint.value = _value;
        }
    }
}// MIT
pragma solidity 0.8.3;


contract TellorStaking is Token {

    event NewStaker(address _staker);
    event StakeWithdrawRequested(address _staker);
    event StakeWithdrawn(address _staker);

    function changeStakingStatus(address _reporter, uint256 _status) external {

        require(
            IGovernance(addresses[_GOVERNANCE_CONTRACT])
                .isApprovedGovernanceContract(msg.sender),
            "Only approved governance contract can change staking status"
        );
        StakeInfo storage stakes = stakerDetails[_reporter];
        stakes.currentStatus = _status;
    }

    function depositStake() external {

        require(
            balances[msg.sender][balances[msg.sender].length - 1].value >=
                uints[_STAKE_AMOUNT],
            "Balance is lower than stake amount"
        );
        require(
            stakerDetails[msg.sender].currentStatus == 0 ||
                stakerDetails[msg.sender].currentStatus == 2,
            "Reporter is in the wrong state"
        );
        uints[_STAKE_COUNT] += 1;
        stakerDetails[msg.sender] = StakeInfo({
            currentStatus: 1,
            startDate: block.timestamp // This resets their stake start date to now
        });
        emit NewStaker(msg.sender);
        IGovernance(addresses[_GOVERNANCE_CONTRACT]).updateMinDisputeFee();
    }

    function requestStakingWithdraw() external {

        StakeInfo storage stakes = stakerDetails[msg.sender];
        require(stakes.currentStatus == 1, "Reporter is not staked");
        stakes.currentStatus = 2;
        stakes.startDate = block.timestamp;
        uints[_STAKE_COUNT] -= 1;
        IGovernance(addresses[_GOVERNANCE_CONTRACT]).updateMinDisputeFee();
        emit StakeWithdrawRequested(msg.sender);
    }

    function slashReporter(address _reporter, address _disputer) external {

        require(
            IGovernance(addresses[_GOVERNANCE_CONTRACT])
                .isApprovedGovernanceContract(msg.sender),
            "Only approved governance contract can slash reporter"
        );
        stakerDetails[_reporter].currentStatus = 5; // Change status of reporter to slashed
        if (balanceOf(_reporter) >= uints[_STAKE_AMOUNT]) {
            _doTransfer(_reporter, _disputer, uints[_STAKE_AMOUNT]);
        }
        else if (balanceOf(_reporter) > 0) {
            _doTransfer(_reporter, _disputer, balanceOf(_reporter));
        }
    }

    function withdrawStake() external {

        StakeInfo storage _s = stakerDetails[msg.sender];
        require(block.timestamp - _s.startDate >= 7 days, "7 days didn't pass");
        require(_s.currentStatus == 2, "Reporter not locked for withdrawal");
        _s.currentStatus = 0; // Updates status to withdrawn
        emit StakeWithdrawn(msg.sender);
    }

    function getStakerInfo(address _staker)
        external
        view
        returns (uint256, uint256)
    {

        return (
            stakerDetails[_staker].currentStatus,
            stakerDetails[_staker].startDate
        );
    }
}// MIT
pragma solidity 0.8.3;

interface IController{

    function addresses(bytes32) external returns(address);

    function uints(bytes32) external returns(uint256);

    function burn(uint256 _amount) external;

    function changeDeity(address _newDeity) external;

    function changeOwner(address _newOwner) external;

    function changeTellorContract(address _tContract) external;

    function changeControllerContract(address _newController) external;

    function changeGovernanceContract(address _newGovernance) external;

    function changeOracleContract(address _newOracle) external;

    function changeTreasuryContract(address _newTreasury) external;

    function changeUint(bytes32 _target, uint256 _amount) external;

    function migrate() external;

    function mint(address _reciever, uint256 _amount) external;

    function init() external;

    function getDisputeIdByDisputeHash(bytes32 _hash) external view returns (uint256);

    function getLastNewValueById(uint256 _requestId) external view returns (uint256, bool);

    function retrieveData(uint256 _requestId, uint256 _timestamp) external view returns (uint256);

    function getNewValueCountbyRequestId(uint256 _requestId) external view returns (uint256);

    function getAddressVars(bytes32 _data) external view returns (address);

    function getUintVar(bytes32 _data) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function allowance(address _user, address _spender) external view  returns (uint256);

    function allowedToTrade(address _user, uint256 _amount) external view returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function approveAndTransferFrom(address _from, address _to, uint256 _amount) external returns(bool);

    function balanceOf(address _user) external view returns (uint256);

    function balanceOfAt(address _user, uint256 _blockNumber)external view returns (uint256);

    function transfer(address _to, uint256 _amount)external returns (bool success);

    function transferFrom(address _from,address _to,uint256 _amount) external returns (bool success) ;

    function depositStake() external;

    function requestStakingWithdraw() external;

    function withdrawStake() external;

    function changeStakingStatus(address _reporter, uint _status) external;

    function slashReporter(address _reporter, address _disputer) external;

    function getStakerInfo(address _staker) external view returns (uint256, uint256);

    function getTimestampbyRequestIDandIndex(uint256 _requestID, uint256 _index) external view returns (uint256);

    function getNewCurrentVariables()external view returns (bytes32 _c,uint256[5] memory _r,uint256 _d,uint256 _t);

    function beginDispute(uint256 _requestId, uint256 _timestamp,uint256 _minerIndex) external;

    function unlockDisputeFee(uint256 _disputeId) external;

    function vote(uint256 _disputeId, bool _supportsDispute) external;

    function tallyVotes(uint256 _disputeId) external;

    function tipQuery(uint,uint,bytes memory) external;

    function getNewVariablesOnDeck() external view returns (uint256[5] memory idsOnDeck, uint256[5] memory tipsOnDeck);

}// MIT
pragma solidity 0.8.3;

interface IOracle{

    function getReportTimestampByIndex(bytes32 _queryId, uint256 _index) external view returns(uint256);

    function getValueByTimestamp(bytes32 _queryId, uint256 _timestamp) external view returns(bytes memory);

    function getBlockNumberByTimestamp(bytes32 _queryId, uint256 _timestamp) external view returns(uint256);

    function getReporterByTimestamp(bytes32 _queryId, uint256 _timestamp) external view returns(address);

    function getReporterLastTimestamp(address _reporter) external view returns(uint256);

    function reportingLock() external view returns(uint256);

    function removeValue(bytes32 _queryId, uint256 _timestamp) external;

    function getReportsSubmittedByAddress(address _reporter) external view returns(uint256);

    function getTipsByUser(address _user) external view returns(uint256);

    function tipQuery(bytes32 _queryId, uint256 _tip, bytes memory _queryData) external;

    function submitValue(bytes32 _queryId, bytes calldata _value, uint256 _nonce, bytes memory _queryData) external;

    function burnTips() external;

    function verify() external pure returns(uint);

    function changeReportingLock(uint256 _newReportingLock) external;

    function changeTimeBasedReward(uint256 _newTimeBasedReward) external;

    function getTipsById(bytes32 _queryId) external view returns(uint256);

    function getTimestampCountById(bytes32 _queryId) external view returns(uint256);

    function getTimestampIndexByTimestamp(bytes32 _queryId, uint256 _timestamp) external view returns(uint256);

    function getCurrentValue(bytes32 _queryId) external view returns(bytes memory);

    function getTimeOfLastNewValue() external view returns(uint256);

}// MIT
pragma solidity 0.8.3;


contract Transition is TellorStorage, TellorVars {

    constructor(
        address _governance,
        address _oracle,
        address _treasury
    ) {
        require(_governance != address(0), "must set governance address");
        addresses[_GOVERNANCE_CONTRACT] = _governance;
        addresses[_ORACLE_CONTRACT] = _oracle;
        addresses[_TREASURY_CONTRACT] = _treasury;
    }

    function init() external {

        require(
            addresses[_GOVERNANCE_CONTRACT] == address(0),
            "Only good once"
        );
        uints[_STAKE_AMOUNT] = 100e18;
        uints[_SWITCH_TIME] = block.timestamp;
        uints[_MINIMUM_DISPUTE_FEE] = 10e18;
        Transition _controller = Transition(addresses[_TELLOR_CONTRACT]);
        addresses[_GOVERNANCE_CONTRACT] = _controller.addresses(
            _GOVERNANCE_CONTRACT
        );
        addresses[_ORACLE_CONTRACT] = _controller.addresses(_ORACLE_CONTRACT);
        addresses[_TREASURY_CONTRACT] = _controller.addresses(
            _TREASURY_CONTRACT
        );
        IController(TELLOR_ADDRESS).mint(
            addresses[_ORACLE_CONTRACT],
            105120e18
        );
        IController(TELLOR_ADDRESS).mint(
            0xAa304E98f47D4a6a421F3B1cC12581511dD69C55,
            105120e18
        );
        IController(TELLOR_ADDRESS).mint(
            0x83eB2094072f6eD9F57d3F19f54820ee0BaE6084,
            18201e18
        );
    }

    function decimals() external pure returns (uint8) {

        return 18;
    }

    function getAddressVars(bytes32 _data) external view returns (address) {

        return addresses[_data];
    }

    function getAllDisputeVars(uint256 _disputeId)
        external
        view
        returns (
            bytes32,
            bool,
            bool,
            bool,
            address,
            address,
            address,
            uint256[9] memory,
            int256
        )
    {

        Dispute storage disp = disputesById[_disputeId];
        return (
            disp.hash,
            disp.executed,
            disp.disputeVotePassed,
            disp.isPropFork,
            disp.reportedMiner,
            disp.reportingParty,
            disp.proposedForkAddress,
            [
                disp.disputeUintVars[_REQUEST_ID],
                disp.disputeUintVars[_TIMESTAMP],
                disp.disputeUintVars[_VALUE],
                disp.disputeUintVars[_MIN_EXECUTION_DATE],
                disp.disputeUintVars[_NUM_OF_VOTES],
                disp.disputeUintVars[_BLOCK_NUMBER],
                disp.disputeUintVars[_MINER_SLOT],
                disp.disputeUintVars[keccak256("quorum")],
                disp.disputeUintVars[_FEE]
            ],
            disp.tally
        );
    }

    function getDisputeIdByDisputeHash(bytes32 _hash)
        external
        view
        returns (uint256)
    {

        return disputeIdByDisputeHash[_hash];
    }

    function getDisputeUintVars(uint256 _disputeId, bytes32 _data)
        external
        view
        returns (uint256)
    {

        return disputesById[_disputeId].disputeUintVars[_data];
    }

    function getLastNewValueById(uint256 _requestId)
        external
        view
        returns (uint256, bool)
    {

        uint256 _timeCount = IOracle(addresses[_ORACLE_CONTRACT])
            .getTimestampCountById(bytes32(_requestId));
        if (_timeCount != 0) {
            return (
                retrieveData(
                    _requestId,
                    IOracle(addresses[_ORACLE_CONTRACT])
                        .getReportTimestampByIndex(
                            bytes32(_requestId),
                            _timeCount - 1
                        )
                ),
                true
            );
        } else {
            Request storage _request = requestDetails[_requestId];
            if (_request.requestTimestamps.length != 0) {
                return (
                    retrieveData(
                        _requestId,
                        _request.requestTimestamps[
                            _request.requestTimestamps.length - 1
                        ]
                    ),
                    true
                );
            } else {
                return (0, false);
            }
        }
    }

    function getNewCurrentVariables()
        external
        view
        returns (
            bytes32 _c,
            uint256[5] memory _r,
            uint256 _diff,
            uint256 _tip
        )
    {

        _r = [uint256(1), uint256(1), uint256(1), uint256(1), uint256(1)];
        _diff = 0;
        _tip = 0;
        _c = keccak256(
            abi.encode(
                IOracle(addresses[_ORACLE_CONTRACT]).getTimeOfLastNewValue()
            )
        );
    }

    function getNewValueCountbyRequestId(uint256 _requestId)
        external
        view
        returns (uint256)
    {

        uint256 _val = IOracle(addresses[_ORACLE_CONTRACT])
            .getTimestampCountById(bytes32(_requestId));
        if (_val > 0) {
            return _val;
        } else {
            return requestDetails[_requestId].requestTimestamps.length;
        }
    }

    function getTimestampbyRequestIDandIndex(uint256 _requestId, uint256 _index)
        external
        view
        returns (uint256)
    {

        try
            IOracle(addresses[_ORACLE_CONTRACT]).getReportTimestampByIndex(
                bytes32(_requestId),
                _index
            )
        returns (uint256 _val) {
            return _val;
        } catch {
            return requestDetails[_requestId].requestTimestamps[_index];
        }
    }

    function getUintVar(bytes32 _data) external view returns (uint256) {

        return uints[_data];
    }

    function isMigrated(address _addy) external view returns (bool) {

        return migrated[_addy];
    }

    function name() external pure returns (string memory) {

        return "Tellor Tributes";
    }

    function retrieveData(uint256 _requestId, uint256 _timestamp)
        public
        view
        returns (uint256)
    {

        if (_timestamp < uints[_SWITCH_TIME]) {
            return requestDetails[_requestId].finalValues[_timestamp];
        }
        return
            _sliceUint(
                IOracle(addresses[_ORACLE_CONTRACT]).getValueByTimestamp(
                    bytes32(_requestId),
                    _timestamp
                )
            );
    }

    function symbol() external pure returns (string memory) {

        return "TRB";
    }

    function totalSupply() external view returns (uint256) {

        return uints[_TOTAL_SUPPLY];
    }

    fallback() external {
        address _addr = 0x2754da26f634E04b26c4deCD27b3eb144Cf40582; // Main Tellor address (Harcode this in?)
        bytes4 _function;
        for (uint256 i = 0; i < 4; i++) {
            _function |= bytes4(msg.data[i] & 0xFF) >> (i * 8);
        }
        require(
            _function ==
                bytes4(
                    bytes32(keccak256("beginDispute(uint256,uint256,uint256)"))
                ) ||
                _function == bytes4(bytes32(keccak256("vote(uint256,bool)"))) ||
                _function ==
                bytes4(bytes32(keccak256("tallyVotes(uint256)"))) ||
                _function ==
                bytes4(bytes32(keccak256("unlockDisputeFee(uint256)"))),
            "function should be allowed"
        ); //should autolock out after a week (no disputes can begin past a week)
        (bool _result, ) = _addr.delegatecall(msg.data);
        assembly {
            returndatacopy(0, 0, returndatasize())
            switch _result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _sliceUint(bytes memory _b) public pure returns (uint256 _x) {

        uint256 _number = 0;
        for (uint256 _i = 0; _i < _b.length; _i++) {
            _number = _number * 2**8;
            _number = _number + uint8(_b[_i]);
        }
        return _number;
    }
}// MIT
pragma solidity 0.8.3;


contract Getters is TellorStorage, TellorVars {

    function getNewValueCountbyQueryId(bytes32 _queryId)
        public
        view
        returns (uint256)
    {

        return (
            IOracle(addresses[_ORACLE_CONTRACT]).getTimestampCountById(_queryId)
        );
    }

    function getTimestampbyQueryIdandIndex(bytes32 _queryId, uint256 _index)
        public
        view
        returns (uint256)
    {

        return (
            IOracle(addresses[_ORACLE_CONTRACT]).getReportTimestampByIndex(
                _queryId,
                _index
            )
        );
    }

    function retrieveData(bytes32 _queryId, uint256 _timestamp)
        public
        view
        returns (bytes memory)
    {

        return (
            IOracle(addresses[_ORACLE_CONTRACT]).getValueByTimestamp(
                _queryId,
                _timestamp
            )
        );
    }
}// MIT
pragma solidity 0.8.3;


contract Controller is TellorStaking, Transition, Getters {

    event NewContractAddress(address _newContract, string _contractName);

    constructor(
        address _governance,
        address _oracle,
        address _treasury
    ) Transition(_governance, _oracle, _treasury) {}

    function changeControllerContract(address _newController) external {

        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the Controller contract address"
        );
        require(_isValid(_newController));
        addresses[_TELLOR_CONTRACT] = _newController; //name _TELLOR_CONTRACT is hardcoded in
        assembly {
            sstore(_EIP_SLOT, _newController)
        }
        emit NewContractAddress(_newController, "Controller");
    }

    function changeGovernanceContract(address _newGovernance) external {

        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the Governance contract address"
        );
        require(_isValid(_newGovernance));
        addresses[_GOVERNANCE_CONTRACT] = _newGovernance;
        emit NewContractAddress(_newGovernance, "Governance");
    }

    function changeOracleContract(address _newOracle) external {

        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the Oracle contract address"
        );
        require(_isValid(_newOracle));
        addresses[_ORACLE_CONTRACT] = _newOracle;
        emit NewContractAddress(_newOracle, "Oracle");
    }

    function changeTreasuryContract(address _newTreasury) external {

        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the Treasury contract address"
        );
        require(_isValid(_newTreasury));
        addresses[_TREASURY_CONTRACT] = _newTreasury;
        emit NewContractAddress(_newTreasury, "Treasury");
    }

    function changeUint(bytes32 _target, uint256 _amount) external {

        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT],
            "Only the Governance contract can change the uint"
        );
        uints[_target] = _amount;
    }

    function migrate() external {

        require(!migrated[msg.sender], "Already migrated");
        _doMint(
            msg.sender,
            IController(addresses[_OLD_TELLOR]).balanceOf(msg.sender)
        );
        migrated[msg.sender] = true;
    }

    function mint(address _receiver, uint256 _amount) external {

        require(
            msg.sender == addresses[_GOVERNANCE_CONTRACT] ||
                msg.sender == addresses[_TREASURY_CONTRACT] ||
                msg.sender == TELLOR_ADDRESS,
            "Only governance, treasury, or master can mint tokens"
        );
        _doMint(_receiver, _amount);
    }

    function verify() external pure returns (uint256) {

        return 9999;
    }

    function _isValid(address _contract) internal returns (bool) {

        (bool _success, bytes memory _data) = address(_contract).call(
            abi.encodeWithSelector(0xfc735e99, "") // verify() signature
        );
        require(
            _success && abi.decode(_data, (uint256)) > 9000, // An arbitrary number to ensure that the contract is valid
            "New contract is invalid"
        );
        return true;
    }
}