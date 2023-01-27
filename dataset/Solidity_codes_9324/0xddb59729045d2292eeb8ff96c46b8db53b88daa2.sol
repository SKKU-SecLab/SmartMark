pragma solidity 0.7.4;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256 c) {

        if (b > 0) {
            c = a + b;
            assert(c >= a);
        } else {
            c = a + b;
            assert(c <= a);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a : b;
    }

    function max(int256 a, int256 b) internal pure returns (uint256) {

        return a > b ? uint256(a) : uint256(b);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256 c) {

        if (b > 0) {
            c = a - b;
            assert(c <= a);
        } else {
            c = a - b;
            assert(c >= a);
        }
    }
}// MIT
pragma solidity 0.7.4;

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
pragma solidity 0.7.4;

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
pragma solidity 0.7.4;


contract TellorTransfer is TellorStorage, TellorVariables {

    using SafeMath for uint256;

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    ); //ERC20 Approval event
    event Transfer(address indexed _from, address indexed _to, uint256 _value); //ERC20 Transfer Event

    function allowance(address _user, address _spender)
        public
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
            if (balanceOf(_user).sub(uints[_STAKE_AMOUNT]) >= _amount) {
                return true;
            }
            return false;
        }
        return (balanceOf(_user) >= _amount);
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {

        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
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
            uint256 min = 0;
            uint256 max = checkpoints.length - 2;
            while (max > min) {
                uint256 mid = (max + min + 1) / 2;
                if (checkpoints[mid].fromBlock == _blockNumber) {
                    return checkpoints[mid].value;
                } else if (checkpoints[mid].fromBlock < _blockNumber) {
                    min = mid;
                } else {
                    max = mid - 1;
                }
            }
            return checkpoints[min].value;
        }
    }

    function transfer(address _to, uint256 _amount)
        public
        returns (bool success)
    {

        _doTransfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {

        require(
            _allowances[_from][msg.sender] >= _amount,
            "Allowance is wrong"
        );
        _allowances[_from][msg.sender] -= _amount;
        _doTransfer(_from, _to, _amount);
        return true;
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
        uint128 previousBalance = uint128(balanceOf(_from));
        uint128 _sizedAmount  = uint128(_amount);
        _updateBalanceAtNow(_from, previousBalance - _sizedAmount);
        previousBalance = uint128(balanceOf(_to));
        require(
            previousBalance + _sizedAmount >= previousBalance,
            "Overflow happened"
        ); // Check for overflow
        _updateBalanceAtNow(_to, previousBalance + _sizedAmount);
        emit Transfer(_from, _to, _amount);
    }

    function _doMint(address _to, uint256 _amount) internal {

        require(_amount != 0, "Tried to mint non-positive amount");
        require(_to != address(0), "Receiver is 0 address");
        uint128 previousBalance = uint128(balanceOf(_to));
        uint128 _sizedAmount  = uint128(_amount);
        require(
            previousBalance + _sizedAmount >= previousBalance,
            "Overflow happened"
        );
        uint256 previousSupply = uints[_TOTAL_SUPPLY];
        require(
            previousSupply + _amount >= previousSupply,
            "Overflow happened"
        );
        uints[_TOTAL_SUPPLY] += _amount;
        _updateBalanceAtNow(_to, previousBalance + _sizedAmount);
        emit Transfer(address(0), _to, _amount);
    }

    function _doBurn(address _from, uint256 _amount) internal {

        if (_amount == 0) return;
        require(
            allowedToTrade(_from, _amount),
            "Should have sufficient balance to trade"
        );
        uint128 previousBalance = uint128(balanceOf(_from));
        uint128 _sizedAmount  = uint128(_amount);
        require(
            previousBalance - _sizedAmount <= previousBalance,
            "Overflow happened"
        );
        uint256 previousSupply = uints[_TOTAL_SUPPLY];
        require(
            previousSupply - _amount <= previousSupply,
            "Overflow happened"
        );
        _updateBalanceAtNow(_from, previousBalance - _sizedAmount);
        uints[_TOTAL_SUPPLY] -= _amount;
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
            TellorStorage.Checkpoint storage oldCheckPoint =
                checkpoints[checkpoints.length - 1];
            oldCheckPoint.value = _value;
        }
    }
}// MIT
pragma solidity 0.7.4;

contract Utilities {

    function _getMax5(uint256[51] memory data)
        internal
        pure
        returns (uint256[5] memory max, uint256[5] memory maxIndex)
    {

        uint256 min5 = data[1];
        uint256 minI = 0;
        for (uint256 j = 0; j < 5; j++) {
            max[j] = data[j + 1]; //max[0]=data[1]
            maxIndex[j] = j + 1; //maxIndex[0]= 1
            if (max[j] < min5) {
                min5 = max[j];
                minI = j;
            }
        }
        for (uint256 i = 6; i < data.length; i++) {
            if (data[i] > min5) {
                max[minI] = data[i];
                maxIndex[minI] = i;
                min5 = data[i];
                for (uint256 j = 0; j < 5; j++) {
                    if (max[j] < min5) {
                        min5 = max[j];
                        minI = j;
                    }
                }
            }
        }
    }
}// MIT
pragma solidity 0.7.4;

contract TellorGetters is TellorStorage, TellorVariables, Utilities {

    using SafeMath for uint256;

    function didMine(bytes32 _challenge, address _miner)
        external
        view
        returns (bool)
    {

        return minersByChallenge[_challenge][_miner];
    }

    function didVote(uint256 _disputeId, address _address)
        external
        view
        returns (bool)
    {

        return disputesById[_disputeId].voted[_address];
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

    function getMinedBlockNum(uint256 _requestId, uint256 _timestamp)
        external
        view
        returns (uint256)
    {

        return requestDetails[_requestId].minedBlockNum[_timestamp];
    }

    function getMinersByRequestIdAndTimestamp(
        uint256 _requestId,
        uint256 _timestamp
    ) external view returns (address[5] memory) {

        return requestDetails[_requestId].minersByValue[_timestamp];
    }

    function getNewValueCountbyRequestId(uint256 _requestId)
        external
        view
        returns (uint256)
    {

        return requestDetails[_requestId].requestTimestamps.length;
    }

    function getRequestIdByRequestQIndex(uint256 _index)
        external
        view
        returns (uint256)
    {

        require(_index <= 50, "RequestQ index is above 50");
        return requestIdByRequestQIndex[_index];
    }

    function getRequestQ() external view returns (uint256[51] memory) {

        return requestQ;
    }

    function getRequestUintVars(uint256 _requestId, bytes32 _data)
        external
        view
        returns (uint256)
    {

        return requestDetails[_requestId].apiUintVars[_data];
    }

    function getRequestVars(uint256 _requestId)
        external
        view
        returns (uint256, uint256)
    {

        Request storage _request = requestDetails[_requestId];
        return (
            _request.apiUintVars[_REQUEST_Q_POSITION],
            _request.apiUintVars[_TOTAL_TIP]
        );
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

    function getSubmissionsByTimestamp(uint256 _requestId, uint256 _timestamp)
        external
        view
        returns (uint256[5] memory)
    {

        return requestDetails[_requestId].valuesByTimestamp[_timestamp];
    }

    function getTimestampbyRequestIDandIndex(uint256 _requestID, uint256 _index)
        external
        view
        returns (uint256)
    {

        return requestDetails[_requestID].requestTimestamps[_index];
    }

    function getUintVar(bytes32 _data) external view returns (uint256) {

        return uints[_data];
    }

    function isInDispute(uint256 _requestId, uint256 _timestamp)
        external
        view
        returns (bool)
    {

        return requestDetails[_requestId].inDispute[_timestamp];
    }

    function retrieveData(uint256 _requestId, uint256 _timestamp)
        public
        view
        returns (uint256)
    {

        return requestDetails[_requestId].finalValues[_timestamp];
    }

    function totalSupply() external view returns (uint256) {

        return uints[_TOTAL_SUPPLY];
    }

    function name() external pure returns (string memory) {

        return "Tellor Tributes";
    }

    function symbol() external pure returns (string memory) {

        return "TRB";
    }

    function decimals() external pure returns (uint8) {

        return 18;
    }

    function getNewCurrentVariables()
        external
        view
        returns (
            bytes32 _challenge,
            uint256[5] memory _requestIds,
            uint256 _diff,
            uint256 _tip
        )
    {

        for (uint256 i = 0; i < 5; i++) {
            _requestIds[i] = currentMiners[i].value;
        }
        return (
            bytesVars[_CURRENT_CHALLENGE],
            _requestIds,
            uints[_DIFFICULTY],
            uints[_CURRENT_TOTAL_TIPS]
        );
    }

    function getNewVariablesOnDeck()
        external
        view
        returns (uint256[5] memory idsOnDeck, uint256[5] memory tipsOnDeck)
    {

        idsOnDeck = getTopRequestIDs();
        for (uint256 i = 0; i < 5; i++) {
            tipsOnDeck[i] = requestDetails[idsOnDeck[i]].apiUintVars[
                _TOTAL_TIP
            ];
        }
    }

    function getTopRequestIDs()
        public
        view
        returns (uint256[5] memory _requestIds)
    {

        uint256[5] memory _max;
        uint256[5] memory _index;
        (_max, _index) = _getMax5(requestQ);
        for (uint256 i = 0; i < 5; i++) {
            if (_max[i] != 0) {
                _requestIds[i] = requestIdByRequestQIndex[_index[i]];
            } else {
                _requestIds[i] = currentMiners[4 - i].value;
            }
        }
    }
}// MIT
pragma solidity 0.7.4;


contract Extension is TellorGetters {

    using SafeMath for uint256;
    
    event DisputeVoteTallied(
        uint256 indexed _disputeID,
        int256 _result,
        address indexed _reportedMiner,
        address _reportingParty,
        bool _passed
    );
    event StakeWithdrawn(address indexed _sender); //Emits when a staker is block.timestamp no longer staked
    event StakeWithdrawRequested(address indexed _sender); //Emits when a staker begins the 7 day withdraw period
    event NewStake(address indexed _sender); //Emits upon new staker
    event NewTellorAddress(address _newTellor);
    function depositStake() external{

        _newStake(msg.sender);
        updateMinDisputeFee();
    }

    function requestStakingWithdraw() external {

        StakeInfo storage stakes = stakerDetails[msg.sender];
        require(stakes.currentStatus == 1, "Miner is not staked");
        stakes.currentStatus = 2;
        stakes.startDate = block.timestamp - (block.timestamp % 86400);
        uints[_STAKE_COUNT] -= 1;
        updateMinDisputeFee();
        emit StakeWithdrawRequested(msg.sender);
    }

    function tallyVotes(uint256 _disputeId) external {

        Dispute storage disp = disputesById[_disputeId];
        require(disp.executed == false, "Dispute has been already executed");
        require(
            block.timestamp >= disp.disputeUintVars[_MIN_EXECUTION_DATE],
            "Time for voting haven't elapsed"
        );
        require(
            disp.reportingParty != address(0),
            "reporting Party is address 0"
        );
        int256 _tally = disp.tally;
        if (_tally > 0) {
            if (disp.isPropFork == false) {
                disp.disputeVotePassed = true;
                StakeInfo storage stakes = stakerDetails[disp.reportedMiner];
                if (stakes.currentStatus == 3) {
                    stakes.currentStatus = 4;
                }
            } else if (uint256(_tally) >= ((uints[_TOTAL_SUPPLY] * 5) / 100)) {
                disp.disputeVotePassed = true;
            }
        }
        disp.disputeUintVars[_TALLY_DATE] = block.timestamp;
        disp.executed = true;
        emit DisputeVoteTallied(
            _disputeId,
            _tally,
            disp.reportedMiner,
            disp.reportingParty,
            disp.disputeVotePassed
        );
    }

    function updateMinDisputeFee() public {

        uint256 _stakeAmt = uints[_STAKE_AMOUNT];
        uint256 _trgtMiners = uints[_TARGET_MINERS];
        uints[_DISPUTE_FEE] = SafeMath.max(
            15e18,
            (_stakeAmt -
                ((_stakeAmt *
                    (SafeMath.min(_trgtMiners, uints[_STAKE_COUNT]) * 1000)) /
                    _trgtMiners) /
                1000)
        );
    }

    function updateTellor(uint256 _disputeId) external {

        bytes32 _hash = disputesById[_disputeId].hash;
        uint256 origID = disputeIdByDisputeHash[_hash];
        uint256 lastID =
            disputesById[origID].disputeUintVars[
                keccak256(
                    abi.encode(
                        disputesById[origID].disputeUintVars[_DISPUTE_ROUNDS]
                    )
                )
            ];
        TellorStorage.Dispute storage disp = disputesById[lastID];
        require(disp.isPropFork, "must be a fork proposal");
        require(
            disp.disputeUintVars[_FORK_EXECUTED] == 0,
            "update Tellor has already been run"
        );
        require(disp.disputeVotePassed == true, "vote needs to pass");
        require(disp.disputeUintVars[_TALLY_DATE] > 0, "vote needs to be tallied");
        require(
            block.timestamp - disp.disputeUintVars[_TALLY_DATE] > 1 days,
            "Time for voting for further disputes has not passed"
        );
        disp.disputeUintVars[_FORK_EXECUTED] = 1;
        address _newTellor =disp.proposedForkAddress;
        addresses[_TELLOR_CONTRACT] = _newTellor; 
        assembly {
            sstore(_EIP_SLOT, _newTellor)
        }
        emit NewTellorAddress(_newTellor);
    }

    function withdrawStake() external {

        StakeInfo storage stakes = stakerDetails[msg.sender];
        require(
            block.timestamp - (block.timestamp % 86400) - stakes.startDate >=
                7 days,
            "7 days didn't pass"
        );
        require(
            stakes.currentStatus == 2,
            "Miner was not locked for withdrawal"
        );
        stakes.currentStatus = 0;
        emit StakeWithdrawn(msg.sender);
    }

    function _newStake(address _staker) internal {

        require(
            balances[_staker][balances[_staker].length - 1].value >=
                uints[_STAKE_AMOUNT],
            "Balance is lower than stake amount"
        );
        require(
            stakerDetails[_staker].currentStatus == 0 ||
                stakerDetails[_staker].currentStatus == 2,
            "Miner is in the wrong state"
        );
        uints[_STAKE_COUNT] += 1;
        stakerDetails[_staker] = StakeInfo({
            currentStatus: 1, 
            startDate: block.timestamp//this resets their stake start date to now
        });
        emit NewStake(_staker);
    }
}// MIT
pragma solidity 0.7.4;


contract TellorStake is TellorTransfer {

    using SafeMath for uint256;
    using SafeMath for int256;

    uint256 private constant CURRENT_VERSION = 2999;

    event NewDispute(
        uint256 indexed _disputeId,
        uint256 indexed _requestId,
        uint256 _timestamp,
        address _miner
    );
    event Voted(
        uint256 indexed _disputeID,
        bool _position,
        address indexed _voter,
        uint256 indexed _voteWeight
    );

    function beginDispute(
        uint256 _requestId,
        uint256 _timestamp,
        uint256 _minerIndex
    ) external {

        Request storage _request = requestDetails[_requestId];
        require(_request.minedBlockNum[_timestamp] != 0, "Mined block is 0");
        require(_minerIndex < 5, "Miner index is wrong");
        address _miner = _request.minersByValue[_timestamp][_minerIndex];
        uints[keccak256(abi.encodePacked(_miner,"DisputeCount"))]++;
        bytes32 _hash =
            keccak256(abi.encodePacked(_miner, _requestId, _timestamp));
        uints[_DISPUTE_COUNT]++;
        uint256 disputeId = uints[_DISPUTE_COUNT];
        uint256 hashId = disputeIdByDisputeHash[_hash];
        if (hashId != 0) {
            disputesById[disputeId].disputeUintVars[_ORIGINAL_ID] = hashId;
        } else {
            require(block.timestamp - _timestamp < 7 days, "Dispute must be started within a week of bad value");
            disputeIdByDisputeHash[_hash] = disputeId;
            hashId = disputeId;
        }
        uint256 dispRounds = _updateLastId(disputeId,hashId);
        uint256 _fee;
        if (_minerIndex == 2) {
            requestDetails[_requestId].apiUintVars[_DISPUTE_COUNT] =
                requestDetails[_requestId].apiUintVars[_DISPUTE_COUNT] +
                1;
            _fee =
                uints[_STAKE_AMOUNT] *
                requestDetails[_requestId].apiUintVars[_DISPUTE_COUNT];
        } else {
            _fee = uints[_DISPUTE_FEE] * dispRounds;
        }
        disputesById[disputeId].hash = _hash;
        disputesById[disputeId].isPropFork = false;
        disputesById[disputeId].reportedMiner = _miner;
        disputesById[disputeId].reportingParty = msg.sender;
        disputesById[disputeId].proposedForkAddress = address(0);
        disputesById[disputeId].executed = false;
        disputesById[disputeId].disputeVotePassed = false;
        disputesById[disputeId].tally = 0;
        disputesById[disputeId].disputeUintVars[_REQUEST_ID] = _requestId;
        disputesById[disputeId].disputeUintVars[_TIMESTAMP] = _timestamp;
        disputesById[disputeId].disputeUintVars[_VALUE] = _request
            .valuesByTimestamp[_timestamp][_minerIndex];
        disputesById[disputeId].disputeUintVars[_MIN_EXECUTION_DATE] =
            block.timestamp +
            2 days *
            dispRounds;
        disputesById[disputeId].disputeUintVars[_BLOCK_NUMBER] = block.number;
        disputesById[disputeId].disputeUintVars[_MINER_SLOT] = _minerIndex;
        disputesById[disputeId].disputeUintVars[_FEE] = _fee;
        _doTransfer(msg.sender, address(this), _fee);
        if (_minerIndex == 2) {
            _request.inDispute[_timestamp] = true;
            _request.finalValues[_timestamp] = 0;
        }
        stakerDetails[_miner].currentStatus = 3;
        emit NewDispute(disputeId, _requestId, _timestamp, _miner);
    }

    function proposeFork(address _propNewTellorAddress) external {

        require(uints[_LOCK] == 0, "no rentrancy");
        uints[_LOCK] = 1;
        _verify(_propNewTellorAddress);
        uints[_LOCK] = 0;
        bytes32 _hash = keccak256(abi.encode(_propNewTellorAddress));
        uints[_DISPUTE_COUNT]++;
        uint256 disputeId = uints[_DISPUTE_COUNT];
        if (disputeIdByDisputeHash[_hash] != 0) {
            disputesById[disputeId].disputeUintVars[
                _ORIGINAL_ID
            ] = disputeIdByDisputeHash[_hash];
        } else {
            disputeIdByDisputeHash[_hash] = disputeId;
        }
        uint256 dispRounds = _updateLastId(disputeId,disputeIdByDisputeHash[_hash]);
        disputesById[disputeId].hash = _hash;
        disputesById[disputeId].isPropFork = true;
        disputesById[disputeId].reportedMiner = msg.sender;
        disputesById[disputeId].reportingParty = msg.sender;
        disputesById[disputeId].proposedForkAddress = _propNewTellorAddress;
        disputesById[disputeId].tally = 0;
        _doTransfer(msg.sender, address(this), 100e18 * 2**(dispRounds - 1)); //This is the fork fee (just 100 tokens flat, no refunds.  Goes up quickly to dispute a bad vote)
        disputesById[disputeId].disputeUintVars[_BLOCK_NUMBER] = block.number;
        disputesById[disputeId].disputeUintVars[_MIN_EXECUTION_DATE] =
            block.timestamp +
            7 days;
    }

    function unlockDisputeFee(uint256 _disputeId) external {

        require(_disputeId <= uints[_DISPUTE_COUNT], "dispute does not exist");
        uint256 origID = disputeIdByDisputeHash[disputesById[_disputeId].hash];
        uint256 lastID =
            disputesById[origID].disputeUintVars[
                keccak256(
                    abi.encode(
                        disputesById[origID].disputeUintVars[_DISPUTE_ROUNDS]
                    )
                )
            ];
        if (lastID == 0) {
            lastID = origID;
        }
        Dispute storage disp = disputesById[origID];
        Dispute storage last = disputesById[lastID];
        uint256 dispRounds = disp.disputeUintVars[_DISPUTE_ROUNDS];
        if (dispRounds == 0) {
            dispRounds = 1;
        }
        uint256 _id;
        require(disp.disputeUintVars[_PAID] == 0, "already paid out");
        require(!disp.isPropFork, "function not callable fork fork proposals");
        require(disp.disputeUintVars[_TALLY_DATE] > 0, "vote needs to be tallied");
        require(
            block.timestamp - last.disputeUintVars[_TALLY_DATE] > 1 days,
            "Time for a follow up dispute hasn't elapsed"
        );
        StakeInfo storage stakes = stakerDetails[disp.reportedMiner];
        disp.disputeUintVars[_PAID] = 1;
        if (last.disputeVotePassed == true) {
            stakes.startDate = block.timestamp - (block.timestamp % 86400);
            uints[_STAKE_COUNT] -= 1;
            uint256 _transferAmount = uints[_STAKE_AMOUNT];
            if(balanceOf(disp.reportedMiner)  < uints[_STAKE_AMOUNT]){
                _transferAmount = balanceOf(disp.reportedMiner);
            }
            if (stakes.currentStatus == 4) {
                stakes.currentStatus = 5;
                _doTransfer(
                    disp.reportedMiner,
                    disp.reportingParty,
                    _transferAmount
                );
                stakes.currentStatus = 0;
            }
            for (uint256 i = 0; i < dispRounds; i++) {
                _id = disp.disputeUintVars[
                    keccak256(abi.encode(dispRounds - i))
                ];
                if (_id == 0) {
                    _id = origID;
                }
                Dispute storage disp2 = disputesById[_id];
                _doTransfer(
                    address(this),
                    disp2.reportingParty,
                    disp2.disputeUintVars[_FEE]
                );
            }
        } else {
            if(uints[keccak256(abi.encodePacked(last.reportedMiner,"DisputeCount"))] == 1){
                stakes.currentStatus = 1;
            }
            TellorStorage.Request storage _request =
                requestDetails[disp.disputeUintVars[_REQUEST_ID]];
            if (disp.disputeUintVars[_MINER_SLOT] == 2) {
                _request.finalValues[disp.disputeUintVars[_TIMESTAMP]] = disp
                    .disputeUintVars[_VALUE];
            }
            if (_request.inDispute[disp.disputeUintVars[_TIMESTAMP]] == true) {
                _request.inDispute[disp.disputeUintVars[_TIMESTAMP]] = false;
            }
            for (uint256 i = 0; i < dispRounds; i++) {
                _id = disp.disputeUintVars[
                    keccak256(abi.encode(dispRounds - i))
                ];
                if (_id != 0) {
                    last = disputesById[_id]; //handling if happens during an upgrade
                }
                _doTransfer(
                    address(this),
                    last.reportedMiner,
                    disputesById[_id].disputeUintVars[_FEE]
                );
            }
        }
        uints[keccak256(abi.encodePacked(last.reportedMiner,"DisputeCount"))]--;
        if (disp.disputeUintVars[_MINER_SLOT] == 2) {
            requestDetails[disp.disputeUintVars[_REQUEST_ID]].apiUintVars[
                _DISPUTE_COUNT
            ]--;
        }
    }

    function verify() external virtual returns (uint256) {

        return CURRENT_VERSION;
    }

    function vote(uint256 _disputeId, bool _supportsDispute) external {

        require(_disputeId <= uints[_DISPUTE_COUNT], "dispute does not exist");
        Dispute storage disp = disputesById[_disputeId];
        require(!disp.executed, "the dispute has already been executed");
        uint256 voteWeight = balanceOfAt(msg.sender, disp.disputeUintVars[_BLOCK_NUMBER]);
        require(disp.voted[msg.sender] != true, "Sender has already voted");
        require(voteWeight != 0, "User balance is 0");
        require(
            stakerDetails[msg.sender].currentStatus != 3,
            "Miner is under dispute"
        );
        disp.voted[msg.sender] = true;
        disp.disputeUintVars[_NUM_OF_VOTES] += 1;
        if (_supportsDispute) {
            disp.tally = disp.tally.add(int256(voteWeight));
        } else {
            disp.tally = disp.tally.sub(int256(voteWeight));
        }
        emit Voted(_disputeId, _supportsDispute, msg.sender, voteWeight);
    }

    function _updateLastId(uint _disputeId,uint _origId) internal returns(uint256 _dispRounds){

        _dispRounds = disputesById[_origId].disputeUintVars[_DISPUTE_ROUNDS] + 1;
        disputesById[_origId].disputeUintVars[_DISPUTE_ROUNDS] = _dispRounds;
        disputesById[_origId].disputeUintVars[
            keccak256(abi.encode(_dispRounds))
        ] = _disputeId;
        if (_disputeId != _origId) {
            uint256 _lastId =
            disputesById[_origId].disputeUintVars[keccak256(abi.encode(_dispRounds - 1))];
            require(
                disputesById[_lastId].disputeUintVars[_MIN_EXECUTION_DATE] <=
                    block.timestamp,
                "Dispute is already open"
            );
            if (disputesById[_lastId].executed) {
                require(
                    block.timestamp - disputesById[_lastId].disputeUintVars[_TALLY_DATE] <=
                        1 days,
                    "Time for voting haven't elapsed"
                );
            }
        }
    }
    
    function _verify(address _newTellor) internal {

        (bool success, bytes memory data) =
            address(_newTellor).call(
                abi.encodeWithSelector(0xfc735e99, "") //verify() signature
            );
        require(
            success && abi.decode(data, (uint256)) > CURRENT_VERSION, //we could enforce versioning through this return value, but we're almost in the size limit.
            "new tellor is invalid"
        );
    }

}// MIT
pragma solidity 0.7.4;

interface ITellor {

    event NewTellorAddress(address _newTellor);
    event NewDispute(
        uint256 indexed _disputeId,
        uint256 indexed _requestId,
        uint256 _timestamp,
        address _miner
    );
    event Voted(
        uint256 indexed _disputeID,
        bool _position,
        address indexed _voter,
        uint256 indexed _voteWeight
    );
    event DisputeVoteTallied(
        uint256 indexed _disputeID,
        int256 _result,
        address indexed _reportedMiner,
        address _reportingParty,
        bool _passed
    );
    event TipAdded(
        address indexed _sender,
        uint256 indexed _requestId,
        uint256 _tip,
        uint256 _totalTips
    );
    event NewChallenge(
        bytes32 indexed _currentChallenge,
        uint256[5] _currentRequestId,
        uint256 _difficulty,
        uint256 _totalTips
    );
    event NewValue(
        uint256[5] _requestId,
        uint256 _time,
        uint256[5] _value,
        uint256 _totalTips,
        bytes32 indexed _currentChallenge
    );
    event NonceSubmitted(
        address indexed _miner,
        string _nonce,
        uint256[5] _requestId,
        uint256[5] _value,
        bytes32 indexed _currentChallenge,
        uint256 _slot
    );
    event NewStake(address indexed _sender); //Emits upon new staker
    event StakeWithdrawn(address indexed _sender); //Emits when a staker is now no longer staked
    event StakeWithdrawRequested(address indexed _sender); //Emits when a staker begins the 7 day withdraw period
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    event Transfer(address indexed _from, address indexed _to, uint256 _value); //ERC20 Transfer Event

    function changeDeity(address _newDeity) external;

    function changeOwner(address _newOwner) external;

    function changeTellorContract(address _tellorContract) external;

    function depositStake() external;

    function requestStakingWithdraw() external;

    function tallyVotes(uint256 _disputeId) external;

    function updateMinDisputeFee() external;

    function updateTellor(uint256 _disputeId) external;

    function withdrawStake() external;

    function addTip(uint256 _requestId, uint256 _tip) external;

    function changeExtension(address _extension) external;

    function changeMigrator(address _migrator) external;

    function migrate() external;

    function migrateFor(
        address _destination,
        uint256 _amount,
        bool _bypass
    ) external;

    function migrateForBatch(
        address[] calldata _destination,
        uint256[] calldata _amount
    ) external;

    function migrateFrom(
        address _origin,
        address _destination,
        uint256 _amount,
        bool _bypass
    ) external;

    function migrateFromBatch(
        address[] calldata _origin,
        address[] calldata _destination,
        uint256[] calldata _amount
    ) external;

    function submitMiningSolution(
        string calldata _nonce,
        uint256[5] calldata _requestIds,
        uint256[5] calldata _values
    ) external;

    function didMine(bytes32 _challenge, address _miner)
        external
        view
        returns (bool);

    function didVote(uint256 _disputeId, address _address)
        external
        view
        returns (bool);

    function getAddressVars(bytes32 _data) external view returns (address);

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
        );

    function getDisputeIdByDisputeHash(bytes32 _hash)
        external
        view
        returns (uint256);

    function getDisputeUintVars(uint256 _disputeId, bytes32 _data)
        external
        view
        returns (uint256);

    function getLastNewValue() external view returns (uint256, bool);

    function getLastNewValueById(uint256 _requestId)
        external
        view
        returns (uint256, bool);

    function getMinedBlockNum(uint256 _requestId, uint256 _timestamp)
        external
        view
        returns (uint256);

    function getMinersByRequestIdAndTimestamp(
        uint256 _requestId,
        uint256 _timestamp
    ) external view returns (address[5] memory);


    function getNewValueCountbyRequestId(uint256 _requestId)
        external
        view
        returns (uint256);

    function getRequestIdByRequestQIndex(uint256 _index)
        external
        view
        returns (uint256);

    function getRequestIdByTimestamp(uint256 _timestamp)
        external
        view
        returns (uint256);

    function getRequestQ() external view returns (uint256[51] memory);

    function getRequestUintVars(uint256 _requestId, bytes32 _data)
        external
        view
        returns (uint256);

    function getRequestVars(uint256 _requestId)
        external
        view
        returns (uint256, uint256);

    function getStakerInfo(address _staker)
        external
        view
        returns (uint256, uint256);

    function getSubmissionsByTimestamp(uint256 _requestId, uint256 _timestamp)
        external
        view
        returns (uint256[5] memory);

    function getTimestampbyRequestIDandIndex(uint256 _requestID, uint256 _index)
        external
        view
        returns (uint256);

    function getUintVar(bytes32 _data) external view returns (uint256);

    function isInDispute(uint256 _requestId, uint256 _timestamp)
        external
        view
        returns (bool);

    function retrieveData(uint256 _requestId, uint256 _timestamp)
        external
        view
        returns (uint256);

    function totalSupply() external view returns (uint256);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function getNewCurrentVariables()
        external
        view
        returns (
            bytes32 _challenge,
            uint256[5] memory _requestIds,
            uint256 _difficulty,
            uint256 _tip
        );

    function getNewVariablesOnDeck()
        external
        view
        returns (uint256[5] memory idsOnDeck, uint256[5] memory tipsOnDeck
        );

    function getTopRequestIDs()
        external
        view
        returns (uint256[5] memory _requestIds);

    function beginDispute(
        uint256 _requestId,
        uint256 _timestamp,
        uint256 _minerIndex
    ) external;

    function proposeFork(address _propNewTellorAddress) external;

    function unlockDisputeFee(uint256 _disputeId) external;

    function verify() external returns (uint256);

    function vote(uint256 _disputeId, bool _supportsDispute) external;

    function approve(address _spender, uint256 _amount) external returns (bool);

    function allowance(address _user, address _spender)
        external
        view
        returns (uint256);

    function allowedToTrade(address _user, uint256 _amount)
        external
        view
        returns (bool);

    function balanceOf(address _user) external view returns (uint256);

    function balanceOfAt(address _user, uint256 _blockNumber)
        external
        view
        returns (uint256);

    function transfer(address _to, uint256 _amount) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    function theLazyCoon(address _address, uint256 _amount) external;

    function testSubmitMiningSolution(
        string calldata _nonce,
        uint256[5] calldata _requestId,
        uint256[5] calldata _value
    ) external;

    function manuallySetDifficulty(uint256 _diff) external;

    function testgetMax5(uint256[51] memory requests)
        external
        view
        returns (uint256[5] memory _max, uint256[5] memory _index);

}// MIT
pragma solidity 0.7.4;


contract Tellor is TellorStake,Utilities {

    using SafeMath for uint256;

    event TipAdded(
        address indexed _sender,
        uint256 indexed _requestId,
        uint256 _tip,
        uint256 _totalTips
    );
    event NewChallenge(
        bytes32 indexed _currentChallenge,
        uint256[5] _currentRequestId,
        uint256 _difficulty,
        uint256 _totalTips
    );
    event NewValue(
        uint256[5] _requestId,
        uint256 _time,
        uint256[5] _value,
        uint256 _totalTips,
        bytes32 indexed _currentChallenge
    );
    event NonceSubmitted(
        address indexed _miner,
        string _nonce,
        uint256[5] _requestId,
        uint256[5] _value,
        bytes32 indexed _currentChallenge,
        uint256 _slot
    );

    address immutable extensionAddress;
    
    constructor(address _ext) {
        extensionAddress = _ext;
    }

    function addTip(uint256 _requestId, uint256 _tip) external {

        require(_requestId != 0, "RequestId is 0");
        require(_tip != 0, "Tip should be greater than 0");
        uint256 _count = uints[_REQUEST_COUNT] + 1;
        if (_requestId == _count) {
            uints[_REQUEST_COUNT] = _count;
        } else {
            require(_requestId < _count, "RequestId is not less than count");
        }
        _doBurn(msg.sender, _tip);
        _updateOnDeck(_requestId, _tip);
        emit TipAdded(
            msg.sender,
            _requestId,
            _tip,
            requestDetails[_requestId].apiUintVars[_TOTAL_TIP]
        );
    }

    function migrate() external {

        _migrate(msg.sender);
    }

    function migrateFor(
        address _destination,
        uint256 _amount,
        bool _bypass
    ) external {

        require(msg.sender == addresses[_DEITY], "not allowed");
        _migrateFor(_destination, _amount, _bypass);
    }

    function submitMiningSolution(
        string calldata _nonce,
        uint256[5] calldata _requestIds,
        uint256[5] calldata _values
    ) external {

        bytes32 _hashMsgSender = keccak256(abi.encode(msg.sender));
        require(
            uints[_hashMsgSender] == 0 ||
                block.timestamp - uints[_hashMsgSender] > 15 minutes,
            "Miner can only win rewards once per 15 min"
        );
        if (uints[_SLOT_PROGRESS] != 4) {
            _verifyNonce(_nonce);
        }
        uints[_hashMsgSender] = block.timestamp;
        _submitMiningSolution(_nonce, _requestIds, _values);
    }

    function _adjustDifficulty() internal {

        uint256 timeDiff = block.timestamp - uints[_TIME_OF_LAST_NEW_VALUE];
        int256 _change = int256(SafeMath.min(1200, timeDiff));
        int256 _diff = int256(uints[_DIFFICULTY]);
        _change = (_diff * (int256(uints[_TIME_TARGET]) - _change)) / 4000;
        if (_change == 0) {
            _change = 1;
        }
        uints[_DIFFICULTY] = uint256(SafeMath.max(_diff + _change, 1));
    }

    function _getMin(uint256[51] memory _data)
        internal
        pure
        returns (uint256 min, uint256 minIndex)
    {

        minIndex = _data.length - 1;
        min = _data[minIndex];
        for (uint256 i = _data.length - 2; i > 0; i--) {
            if (_data[i] < min) {
                min = _data[i];
                minIndex = i;
            }
        }
    }

    function _getTopRequestIDs()
        internal
        view
        returns (uint256[5] memory _requestIds)
    {

        uint256[5] memory _max;
        uint256[5] memory _index;
        (_max, _index) = _getMax5(requestQ);
        for (uint256 i = 0; i < 5; i++) {
            if (_max[i] != 0) {
                _requestIds[i] = requestIdByRequestQIndex[_index[i]];
            } else {
                _requestIds[i] = currentMiners[4 - i].value;
            }
        }
    }

    function _migrate(address _user) internal {

        require(!migrated[_user], "Already migrated");
        _doMint(_user, ITellor(addresses[_OLD_TELLOR]).balanceOf(_user));
        migrated[_user] = true;
    }

    function _migrateFor(
        address _destination,
        uint256 _amount,
        bool _bypass
    ) internal {

        if (!_bypass) require(!migrated[_destination], "already migrated");
        _doMint(_destination, _amount);
        migrated[_destination] = true;
    }

    function _newBlock(string memory _nonce, uint256[5] memory _requestIds)
        internal
    {

        Request storage _tblock = requestDetails[uints[_T_BLOCK]];
        bytes32 _currChallenge = bytesVars[_CURRENT_CHALLENGE];
        uint256 _previousTime = uints[_TIME_OF_LAST_NEW_VALUE];
        uint256 _timeOfLastNewValueVar = block.timestamp;
        uints[_TIME_OF_LAST_NEW_VALUE] = _timeOfLastNewValueVar;
        uint256[5] memory a;
        uint256[5] memory b;
        for (uint256 k = 0; k < 5; k++) {
            for (uint256 i = 1; i < 5; i++) {
                uint256 temp = _tblock.valuesByTimestamp[k][i];
                address temp2 = _tblock.minersByValue[k][i];
                uint256 j = i;
                while (j > 0 && temp < _tblock.valuesByTimestamp[k][j - 1]) {
                    _tblock.valuesByTimestamp[k][j] = _tblock.valuesByTimestamp[
                        k
                    ][j - 1];
                    _tblock.minersByValue[k][j] = _tblock.minersByValue[k][
                        j - 1
                    ];
                    j--;
                }
                if (j < i) {
                    _tblock.valuesByTimestamp[k][j] = temp;
                    _tblock.minersByValue[k][j] = temp2;
                }
            }
            Request storage _request = requestDetails[_requestIds[k]];
            a = _tblock.valuesByTimestamp[k];
            _request.finalValues[_timeOfLastNewValueVar] = a[2];
            b[k] = a[2];
            _request.minersByValue[_timeOfLastNewValueVar] = _tblock
                .minersByValue[k];
            _request.valuesByTimestamp[_timeOfLastNewValueVar] = _tblock
                .valuesByTimestamp[k];
            delete _tblock.minersByValue[k];
            delete _tblock.valuesByTimestamp[k];
            _request.requestTimestamps.push(_timeOfLastNewValueVar);
            _request.minedBlockNum[_timeOfLastNewValueVar] = block.number;
            _request.apiUintVars[_TOTAL_TIP] = 0;
        }
        emit NewValue(
            _requestIds,
            _timeOfLastNewValueVar,
            b,
            uints[_CURRENT_TOTAL_TIPS],
            _currChallenge
        );
        newValueTimestamps.push(_timeOfLastNewValueVar);
        address[5] memory miners =
            requestDetails[_requestIds[0]].minersByValue[
                _timeOfLastNewValueVar
            ];
        _payReward(miners, _previousTime);
        uints[_T_BLOCK]++;
        uint256[5] memory _topId = _getTopRequestIDs();
        for (uint256 i = 0; i < 5; i++) {
            currentMiners[i].value = _topId[i];
            requestQ[
                requestDetails[_topId[i]].apiUintVars[_REQUEST_Q_POSITION]
            ] = 0;
            uints[_CURRENT_TOTAL_TIPS] += requestDetails[_topId[i]].apiUintVars[
                _TOTAL_TIP
            ];
        }
        _currChallenge = keccak256(
            abi.encode(_nonce, _currChallenge, blockhash(block.number - 1))
        );
        bytesVars[_CURRENT_CHALLENGE] = _currChallenge; // Save hash for next proof
        emit NewChallenge(
            _currChallenge,
            _topId,
            uints[_DIFFICULTY],
            uints[_CURRENT_TOTAL_TIPS]
        );
    }

    function _payReward(address[5] memory miners, uint256 _previousTime)
        internal
    {

        uint256 _timeDiff = block.timestamp - _previousTime;
        uint256 reward = (_timeDiff * uints[_CURRENT_REWARD]) / 300;
        uint256 _tip = uints[_CURRENT_TOTAL_TIPS] / 10;
        uint256 _devShare = reward / 2;
        _doMint(miners[0], reward + _tip);
        _doMint(miners[1], reward + _tip);
        _doMint(miners[2], reward + _tip);
        _doMint(miners[3], reward + _tip);
        _doMint(miners[4], reward + _tip);
        _doMint(addresses[_OWNER], _devShare);
        uints[_CURRENT_TOTAL_TIPS] = 0;
    }

    function _submitMiningSolution(
        string memory _nonce,
        uint256[5] memory _requestIds,
        uint256[5] memory _values
    ) internal {

        bytes32 _hashMsgSender = keccak256(abi.encode(msg.sender));
        require(
            stakerDetails[msg.sender].currentStatus == 1,
            "Miner status is not staker"
        );
        require(
            _requestIds[0] == currentMiners[0].value,
            "Request ID is wrong"
        );
        require(
            _requestIds[1] == currentMiners[1].value,
            "Request ID is wrong"
        );
        require(
            _requestIds[2] == currentMiners[2].value,
            "Request ID is wrong"
        );
        require(
            _requestIds[3] == currentMiners[3].value,
            "Request ID is wrong"
        );
        require(
            _requestIds[4] == currentMiners[4].value,
            "Request ID is wrong"
        );
        uints[_hashMsgSender] = block.timestamp;
        bytes32 _currChallenge = bytesVars[_CURRENT_CHALLENGE];
        uint256 _slotP = uints[_SLOT_PROGRESS];
        require(
            minersByChallenge[_currChallenge][msg.sender] == false,
            "Miner already submitted the value"
        );
        minersByChallenge[_currChallenge][msg.sender] = true;
        Request storage _tblock = requestDetails[uints[_T_BLOCK]];
        _tblock.valuesByTimestamp[0][_slotP] = _values[0];
        _tblock.valuesByTimestamp[1][_slotP] = _values[1];
        _tblock.valuesByTimestamp[2][_slotP] = _values[2];
        _tblock.valuesByTimestamp[3][_slotP] = _values[3];
        _tblock.valuesByTimestamp[4][_slotP] = _values[4];
        _tblock.minersByValue[0][_slotP] = msg.sender;
        _tblock.minersByValue[1][_slotP] = msg.sender;
        _tblock.minersByValue[2][_slotP] = msg.sender;
        _tblock.minersByValue[3][_slotP] = msg.sender;
        _tblock.minersByValue[4][_slotP] = msg.sender;
        if (_slotP + 1 == 4) {
            _adjustDifficulty();
        }
        emit NonceSubmitted(
            msg.sender,
            _nonce,
            _requestIds,
            _values,
            _currChallenge,
            _slotP
        );
        if (_slotP + 1 == 5) {
            _newBlock(_nonce, _requestIds);
            uints[_SLOT_PROGRESS] = 0;
        } else {
            uints[_SLOT_PROGRESS]++;
        }
    }

    function _updateOnDeck(uint256 _requestId, uint256 _tip) internal {

        Request storage _request = requestDetails[_requestId];
        _request.apiUintVars[_TOTAL_TIP] = _request.apiUintVars[_TOTAL_TIP].add(
            _tip
        );
        if (
            currentMiners[0].value == _requestId ||
            currentMiners[1].value == _requestId ||
            currentMiners[2].value == _requestId ||
            currentMiners[3].value == _requestId ||
            currentMiners[4].value == _requestId
        ) {
            uints[_CURRENT_TOTAL_TIPS] += _tip;
        } else {
            if (_request.apiUintVars[_REQUEST_Q_POSITION] == 0) {
                uint256 _min;
                uint256 _index;
                (_min, _index) = _getMin(requestQ);
                if (_request.apiUintVars[_TOTAL_TIP] > _min || _min == 0) {
                    requestQ[_index] = _request.apiUintVars[_TOTAL_TIP];
                    requestDetails[requestIdByRequestQIndex[_index]]
                        .apiUintVars[_REQUEST_Q_POSITION] = 0;
                    requestIdByRequestQIndex[_index] = _requestId;
                    _request.apiUintVars[_REQUEST_Q_POSITION] = _index;
                }
            } else {
                requestQ[_request.apiUintVars[_REQUEST_Q_POSITION]] += _tip;
            }
        }
    }

    function _verifyNonce(string memory _nonce) internal view {

        require(
            uint256(
                sha256(
                    abi.encodePacked(
                        ripemd160(
                            abi.encodePacked(
                                keccak256(
                                    abi.encodePacked(
                                        bytesVars[_CURRENT_CHALLENGE],
                                        msg.sender,
                                        _nonce
                                    )
                                )
                            )
                        )
                    )
                )
            ) %
                uints[_DIFFICULTY] ==
                0 ||
                block.timestamp - uints[_TIME_OF_LAST_NEW_VALUE] >= 15 minutes,
            "Incorrect nonce for current challenge"
        );
    }

    fallback() external {
        address addr = extensionAddress;
        (bool result, ) =  addr.delegatecall(msg.data);
        assembly {
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }
}