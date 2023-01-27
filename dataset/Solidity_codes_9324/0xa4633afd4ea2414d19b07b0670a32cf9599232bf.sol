
pragma solidity 0.5.7;


contract INXMMaster {


    address public tokenAddress;

    address public owner;


    uint public pauseTime;

    function delegateCallBack(bytes32 myid) external;


    function masterInitialized() public view returns(bool);

    
    function isInternal(address _add) public view returns(bool);


    function isPause() public view returns(bool check);


    function isOwner(address _add) public view returns(bool);


    function isMember(address _add) public view returns(bool);

    
    function checkIsAuthToGoverned(address _add) public view returns(bool);


    function updatePauseTime(uint _time) public;


    function dAppLocker() public view returns(address _add);


    function dAppToken() public view returns(address _add);


    function getLatestAddress(bytes2 _contractName) public view returns(address payable contractAddress);

}pragma solidity 0.5.7;



contract Iupgradable {


    INXMMaster public ms;
    address public nxMasterAddress;

    modifier onlyInternal {

        require(ms.isInternal(msg.sender));
        _;
    }

    modifier isMemberAndcheckPause {

        require(ms.isPause() == false && ms.isMember(msg.sender) == true);
        _;
    }

    modifier onlyOwner {

        require(ms.isOwner(msg.sender));
        _;
    }

    modifier checkPause {

        require(ms.isPause() == false);
        _;
    }

    modifier isMember {

        require(ms.isMember(msg.sender), "Not member");
        _;
    }

    function  changeDependentContractAddress() public;

    function changeMasterAddress(address _masterAddress) public {

        if (address(ms) != address(0)) {
            require(address(ms) == msg.sender, "Not master");
        }
        ms = INXMMaster(_masterAddress);
        nxMasterAddress = _masterAddress;
    }

}
pragma solidity 0.5.7;


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

pragma solidity 0.5.7;



contract ClaimsData is Iupgradable {

    using SafeMath for uint;

    struct Claim {
        uint coverId;
        uint dateUpd;
    }

    struct Vote {
        address voter;
        uint tokens;
        uint claimId;
        int8 verdict;
        bool rewardClaimed;
    }

    struct ClaimsPause {
        uint coverid;
        uint dateUpd;
        bool submit;
    }

    struct ClaimPauseVoting {
        uint claimid;
        uint pendingTime;
        bool voting;
    }

    struct RewardDistributed {
        uint lastCAvoteIndex;
        uint lastMVvoteIndex;

    }

    struct ClaimRewardDetails {
        uint percCA;
        uint percMV;
        uint tokenToBeDist;

    }

    struct ClaimTotalTokens {
        uint accept;
        uint deny;
    }

    struct ClaimRewardStatus {
        uint percCA;
        uint percMV;
    }

    ClaimRewardStatus[] internal rewardStatus;

    Claim[] internal allClaims;
    Vote[] internal allvotes;
    ClaimsPause[] internal claimPause;
    ClaimPauseVoting[] internal claimPauseVotingEP;

    mapping(address => RewardDistributed) internal voterVoteRewardReceived;
    mapping(uint => ClaimRewardDetails) internal claimRewardDetail;
    mapping(uint => ClaimTotalTokens) internal claimTokensCA;
    mapping(uint => ClaimTotalTokens) internal claimTokensMV;
    mapping(uint => int8) internal claimVote;
    mapping(uint => uint) internal claimsStatus;
    mapping(uint => uint) internal claimState12Count;
    mapping(uint => uint[]) internal claimVoteCA;
    mapping(uint => uint[]) internal claimVoteMember;
    mapping(address => uint[]) internal voteAddressCA;
    mapping(address => uint[]) internal voteAddressMember;
    mapping(address => uint[]) internal allClaimsByAddress;
    mapping(address => mapping(uint => uint)) internal userClaimVoteCA;
    mapping(address => mapping(uint => uint)) internal userClaimVoteMember;
    mapping(address => uint) public userClaimVotePausedOn;

    uint internal claimPauseLastsubmit;
    uint internal claimStartVotingFirstIndex;
    uint public pendingClaimStart;
    uint public claimDepositTime;
    uint public maxVotingTime;
    uint public minVotingTime;
    uint public payoutRetryTime;
    uint public claimRewardPerc;
    uint public minVoteThreshold;
    uint public maxVoteThreshold;
    uint public majorityConsensus;
    uint public pauseDaysCA;
   
    event ClaimRaise(
        uint indexed coverId,
        address indexed userAddress,
        uint claimId,
        uint dateSubmit
    );

    event VoteCast(
        address indexed userAddress,
        uint indexed claimId,
        bytes4 indexed typeOf,
        uint tokens,
        uint submitDate,
        int8 verdict
    );

    constructor() public {
        pendingClaimStart = 1;
        maxVotingTime = 48 * 1 hours;
        minVotingTime = 12 * 1 hours;
        payoutRetryTime = 24 * 1 hours;
        allvotes.push(Vote(address(0), 0, 0, 0, false));
        allClaims.push(Claim(0, 0));
        claimDepositTime = 7 days;
        claimRewardPerc = 20;
        minVoteThreshold = 5;
        maxVoteThreshold = 10;
        majorityConsensus = 70;
        pauseDaysCA = 3 days;
        _addRewardIncentive();
    }

    function setpendingClaimStart(uint _start) external onlyInternal {

        require(pendingClaimStart <= _start);
        pendingClaimStart = _start;
    }

    function setRewardDistributedIndexCA(address _voter, uint caIndex) external onlyInternal {

        voterVoteRewardReceived[_voter].lastCAvoteIndex = caIndex;

    }

    function setUserClaimVotePausedOn(address user) external {

        require(ms.checkIsAuthToGoverned(msg.sender));
        userClaimVotePausedOn[user] = now;
    }

    function setRewardDistributedIndexMV(address _voter, uint mvIndex) external onlyInternal {


        voterVoteRewardReceived[_voter].lastMVvoteIndex = mvIndex;
    }

    function setClaimRewardDetail(
        uint claimid,
        uint percCA,
        uint percMV,
        uint tokens
    )
        external
        onlyInternal
    {

        claimRewardDetail[claimid].percCA = percCA;
        claimRewardDetail[claimid].percMV = percMV;
        claimRewardDetail[claimid].tokenToBeDist = tokens;
    }

    function setRewardClaimed(uint _voteid, bool claimed) external onlyInternal {

        allvotes[_voteid].rewardClaimed = claimed;
    }

    function changeFinalVerdict(uint _claimId, int8 _verdict) external onlyInternal {

        claimVote[_claimId] = _verdict;
    }
    
    function addClaim(
        uint _claimId,
        uint _coverId,
        address _from,
        uint _nowtime
    )
        external
        onlyInternal
    {

        allClaims.push(Claim(_coverId, _nowtime));
        allClaimsByAddress[_from].push(_claimId);
    }

    function addVote(
        address _voter,
        uint _tokens,
        uint claimId,
        int8 _verdict
    ) 
        external
        onlyInternal
    {

        allvotes.push(Vote(_voter, _tokens, claimId, _verdict, false));
    }

    function addClaimVoteCA(uint _claimId, uint _voteid) external onlyInternal {

        claimVoteCA[_claimId].push(_voteid);
    }

    function setUserClaimVoteCA(
        address _from,
        uint _claimId,
        uint _voteid
    )
        external
        onlyInternal
    {

        userClaimVoteCA[_from][_claimId] = _voteid;
        voteAddressCA[_from].push(_voteid);
    }

    function setClaimTokensCA(uint _claimId, int8 _vote, uint _tokens) external onlyInternal {

        if (_vote == 1)
            claimTokensCA[_claimId].accept = claimTokensCA[_claimId].accept.add(_tokens);
        if (_vote == -1)
            claimTokensCA[_claimId].deny = claimTokensCA[_claimId].deny.add(_tokens);
    }

    function setClaimTokensMV(uint _claimId, int8 _vote, uint _tokens) external onlyInternal {

        if (_vote == 1)
            claimTokensMV[_claimId].accept = claimTokensMV[_claimId].accept.add(_tokens);
        if (_vote == -1)
            claimTokensMV[_claimId].deny = claimTokensMV[_claimId].deny.add(_tokens);
    }

    function addClaimVotemember(uint _claimId, uint _voteid) external onlyInternal {

        claimVoteMember[_claimId].push(_voteid);
    }

    function setUserClaimVoteMember(
        address _from,
        uint _claimId,
        uint _voteid
    )
        external
        onlyInternal
    {

        userClaimVoteMember[_from][_claimId] = _voteid;
        voteAddressMember[_from].push(_voteid);

    }

    function updateState12Count(uint _claimId, uint _cnt) external onlyInternal {

        claimState12Count[_claimId] = claimState12Count[_claimId].add(_cnt);
    }

    function setClaimStatus(uint _claimId, uint _stat) external onlyInternal {

        claimsStatus[_claimId] = _stat;
    }

    function setClaimdateUpd(uint _claimId, uint _dateUpd) external onlyInternal {

        allClaims[_claimId].dateUpd = _dateUpd;
    }

    function setClaimAtEmergencyPause(
        uint _coverId,
        uint _dateUpd,
        bool _submit
    )
        external
        onlyInternal
    {

        claimPause.push(ClaimsPause(_coverId, _dateUpd, _submit));
    }

    function setClaimSubmittedAtEPTrue(uint _index, bool _submit) external onlyInternal {

        claimPause[_index].submit = _submit;
    }

    function setFirstClaimIndexToSubmitAfterEP(
        uint _firstClaimIndexToSubmit
    )
        external
        onlyInternal
    {

        claimPauseLastsubmit = _firstClaimIndexToSubmit;
    }

    function setPendingClaimDetails(
        uint _claimId,
        uint _pendingTime,
        bool _voting
    )
        external
        onlyInternal
    {

        claimPauseVotingEP.push(ClaimPauseVoting(_claimId, _pendingTime, _voting));
    }

    function setPendingClaimVoteStatus(uint _claimId, bool _vote) external onlyInternal {

        claimPauseVotingEP[_claimId].voting = _vote;
    }
    
    function setFirstClaimIndexToStartVotingAfterEP(
        uint _claimStartVotingFirstIndex
    )
        external
        onlyInternal
    {

        claimStartVotingFirstIndex = _claimStartVotingFirstIndex;
    }

    function callVoteEvent(
        address _userAddress,
        uint _claimId,
        bytes4 _typeOf,
        uint _tokens,
        uint _submitDate,
        int8 _verdict
    )
        external
        onlyInternal
    {

        emit VoteCast(
            _userAddress,
            _claimId,
            _typeOf,
            _tokens,
            _submitDate,
            _verdict
        );
    }

    function callClaimEvent(
        uint _coverId,
        address _userAddress,
        uint _claimId,
        uint _datesubmit
    ) 
        external
        onlyInternal
    {

        emit ClaimRaise(_coverId, _userAddress, _claimId, _datesubmit);
    }

    function getUintParameters(bytes8 code) external view returns (bytes8 codeVal, uint val) {

        codeVal = code;
        if (code == "CAMAXVT") {
            val = maxVotingTime / (1 hours);

        } else if (code == "CAMINVT") {

            val = minVotingTime / (1 hours);

        } else if (code == "CAPRETRY") {

            val = payoutRetryTime / (1 hours);

        } else if (code == "CADEPT") {

            val = claimDepositTime / (1 days);

        } else if (code == "CAREWPER") {

            val = claimRewardPerc;

        } else if (code == "CAMINTH") {

            val = minVoteThreshold;

        } else if (code == "CAMAXTH") {

            val = maxVoteThreshold;

        } else if (code == "CACONPER") {

            val = majorityConsensus;

        } else if (code == "CAPAUSET") {
            val = pauseDaysCA / (1 days);
        }
    
    }

    function getClaimOfEmergencyPauseByIndex(
        uint _index
    ) 
        external
        view
        returns(
            uint coverId,
            uint dateUpd,
            bool submit
        )
    {

        coverId = claimPause[_index].coverid;
        dateUpd = claimPause[_index].dateUpd;
        submit = claimPause[_index].submit;
    }

    function getAllClaimsByIndex(
        uint _claimId
    )
        external
        view
        returns(
            uint coverId,
            int8 vote,
            uint status,
            uint dateUpd,
            uint state12Count
        )
    {

        return(
            allClaims[_claimId].coverId,
            claimVote[_claimId],
            claimsStatus[_claimId],
            allClaims[_claimId].dateUpd,
            claimState12Count[_claimId]
        );
    }

    function getUserClaimVoteCA(
        address _add,
        uint _claimId
    )
        external
        view
        returns(uint idVote)
    {

        return userClaimVoteCA[_add][_claimId];
    }

    function getUserClaimVoteMember(
        address _add,
        uint _claimId
    )
        external
        view
        returns(uint idVote)
    {

        return userClaimVoteMember[_add][_claimId];
    }

    function getAllVoteLength() external view returns(uint voteCount) {

        return allvotes.length.sub(1); //Start Index always from 1.
    }

    function getClaimStatusNumber(uint _claimId) external view returns(uint claimId, uint statno) {

        return (_claimId, claimsStatus[_claimId]);
    }

    function getRewardStatus(uint statusNumber) external view returns(uint percCA, uint percMV) {

        return (rewardStatus[statusNumber].percCA, rewardStatus[statusNumber].percMV);
    }

    function getClaimState12Count(uint _claimId) external view returns(uint num) {

        num = claimState12Count[_claimId];
    }

    function getClaimDateUpd(uint _claimId) external view returns(uint dateupd) {

        dateupd = allClaims[_claimId].dateUpd;
    }

    function getAllClaimsByAddress(address _member) external view returns(uint[] memory claimarr) {

        return allClaimsByAddress[_member];
    }

    function getClaimsTokenCA(
        uint _claimId
    )
        external
        view
        returns(
            uint claimId,
            uint accept,
            uint deny
        )
    {

        return (
            _claimId,
            claimTokensCA[_claimId].accept,
            claimTokensCA[_claimId].deny
        );
    }

    function getClaimsTokenMV(
        uint _claimId
    )
        external
        view
        returns(
            uint claimId,
            uint accept,
            uint deny
        )
    {

        return (
            _claimId,
            claimTokensMV[_claimId].accept,
            claimTokensMV[_claimId].deny
        );
    }

    function getCaClaimVotesToken(uint _claimId) external view returns(uint claimId, uint cnt) {

        claimId = _claimId;
        cnt = 0;
        for (uint i = 0; i < claimVoteCA[_claimId].length; i++) {
            cnt = cnt.add(allvotes[claimVoteCA[_claimId][i]].tokens);
        }
    }

    function getMemberClaimVotesToken(
        uint _claimId
    )   
        external
        view
        returns(uint claimId, uint cnt)
    {

        claimId = _claimId;
        cnt = 0;
        for (uint i = 0; i < claimVoteMember[_claimId].length; i++) {
            cnt = cnt.add(allvotes[claimVoteMember[_claimId][i]].tokens);
        }
    }

    function getVoteDetails(uint _voteid)
    external view
    returns(
        uint tokens,
        uint claimId,
        int8 verdict,
        bool rewardClaimed
        )
    {

        return (
            allvotes[_voteid].tokens,
            allvotes[_voteid].claimId,
            allvotes[_voteid].verdict,
            allvotes[_voteid].rewardClaimed
        );
    }

    function getVoterVote(uint _voteid) external view returns(address voter) {

        return allvotes[_voteid].voter;
    }

    function getClaim(
        uint _claimId
    )
        external
        view
        returns(
            uint claimId,
            uint coverId,
            int8 vote,
            uint status,
            uint dateUpd,
            uint state12Count
        )
    {

        return (
            _claimId,
            allClaims[_claimId].coverId,
            claimVote[_claimId],
            claimsStatus[_claimId],
            allClaims[_claimId].dateUpd,
            claimState12Count[_claimId]
            );
    }

    function getClaimVoteLength(
        uint _claimId,
        uint8 _ca
    )
        external
        view
        returns(uint claimId, uint len)
    {

        claimId = _claimId;
        if (_ca == 1)
            len = claimVoteCA[_claimId].length;
        else
            len = claimVoteMember[_claimId].length;
    }

    function getVoteVerdict(
        uint _claimId,
        uint _index,
        uint8 _ca
    )
        external
        view
        returns(int8 ver)
    {

        if (_ca == 1)
            ver = allvotes[claimVoteCA[_claimId][_index]].verdict;
        else
            ver = allvotes[claimVoteMember[_claimId][_index]].verdict;
    }

    function getVoteToken(
        uint _claimId,
        uint _index,
        uint8 _ca
    )   
        external
        view
        returns(uint tok)
    {

        if (_ca == 1)
            tok = allvotes[claimVoteCA[_claimId][_index]].tokens;
        else
            tok = allvotes[claimVoteMember[_claimId][_index]].tokens;
    }

    function getVoteVoter(
        uint _claimId,
        uint _index,
        uint8 _ca
    )
        external
        view
        returns(address voter)
    {

        if (_ca == 1)
            voter = allvotes[claimVoteCA[_claimId][_index]].voter;
        else
            voter = allvotes[claimVoteMember[_claimId][_index]].voter;
    }

    function getUserClaimCount(address _add) external view returns(uint len) {

        len = allClaimsByAddress[_add].length;
    }

    function getClaimLength() external view returns(uint len) {

        len = allClaims.length.sub(pendingClaimStart);
    }

    function actualClaimLength() external view returns(uint len) {

        len = allClaims.length;
    }

    function getClaimFromNewStart(
        uint _index,
        address _add
    )
        external
        view
        returns(
            uint coverid,
            uint claimId,
            int8 voteCA,
            int8 voteMV,
            uint statusnumber
        )
    {

        uint i = pendingClaimStart.add(_index);
        coverid = allClaims[i].coverId;
        claimId = i;
        if (userClaimVoteCA[_add][i] > 0)
            voteCA = allvotes[userClaimVoteCA[_add][i]].verdict;
        else
            voteCA = 0;

        if (userClaimVoteMember[_add][i] > 0)
            voteMV = allvotes[userClaimVoteMember[_add][i]].verdict;
        else
            voteMV = 0;

        statusnumber = claimsStatus[i];
    }

    function getUserClaimByIndex(
        uint _index,
        address _add
    )
        external
        view
        returns(
            uint status,
            uint coverid,
            uint claimId
        )
    {

        claimId = allClaimsByAddress[_add][_index];
        status = claimsStatus[claimId];
        coverid = allClaims[claimId].coverId;
    }

    function getAllVotesForClaim(
        uint _claimId
    )
        external
        view
        returns(
            uint claimId,
            uint[] memory ca,
            uint[] memory mv
        )
    {

        return (_claimId, claimVoteCA[_claimId], claimVoteMember[_claimId]);
    }

    function getTokensClaim(
        address _of,
        uint _claimId
    )
        external
        view
        returns(
            uint claimId,
            uint tokens
        )
    {

        return (_claimId, allvotes[userClaimVoteCA[_of][_claimId]].tokens);
    }

    function getRewardDistributedIndex(
        address _voter
    ) 
        external
        view
        returns(
            uint lastCAvoteIndex,
            uint lastMVvoteIndex
        )
    {

        return (
            voterVoteRewardReceived[_voter].lastCAvoteIndex,
            voterVoteRewardReceived[_voter].lastMVvoteIndex
        );
    }

    function getClaimRewardDetail(
        uint claimid
    ) 
        external
        view
        returns(
            uint percCA,
            uint percMV,
            uint tokens
        )
    {

        return (
            claimRewardDetail[claimid].percCA,
            claimRewardDetail[claimid].percMV,
            claimRewardDetail[claimid].tokenToBeDist
        );
    }

    function getClaimCoverId(uint _claimId) external view returns(uint claimId, uint coverid) {

        return (_claimId, allClaims[_claimId].coverId);
    }

    function getClaimVote(uint _claimId, int8 _verdict) external view returns(uint claimId, uint token) {

        claimId = _claimId;
        token = 0;
        for (uint i = 0; i < claimVoteCA[_claimId].length; i++) {
            if (allvotes[claimVoteCA[_claimId][i]].verdict == _verdict)
                token = token.add(allvotes[claimVoteCA[_claimId][i]].tokens);
        }
    }

    function getClaimMVote(uint _claimId, int8 _verdict) external view returns(uint claimId, uint token) {

        claimId = _claimId;
        token = 0;
        for (uint i = 0; i < claimVoteMember[_claimId].length; i++) {
            if (allvotes[claimVoteMember[_claimId][i]].verdict == _verdict)
                token = token.add(allvotes[claimVoteMember[_claimId][i]].tokens);
        }
    }

    function getVoteAddressCA(address _voter, uint index) external view returns(uint) {

        return voteAddressCA[_voter][index];
    }

    function getVoteAddressMember(address _voter, uint index) external view returns(uint) {

        return voteAddressMember[_voter][index];
    }

    function getVoteAddressCALength(address _voter) external view returns(uint) {

        return voteAddressCA[_voter].length;
    }

    function getVoteAddressMemberLength(address _voter) external view returns(uint) {

        return voteAddressMember[_voter].length;
    }

    function getFinalVerdict(uint _claimId) external view returns(int8 verdict) {

        return claimVote[_claimId];
    }

    function getLengthOfClaimSubmittedAtEP() external view returns(uint len) {

        len = claimPause.length;
    }

    function getFirstClaimIndexToSubmitAfterEP() external view returns(uint indexToSubmit) {

        indexToSubmit = claimPauseLastsubmit;
    }
    
    function getLengthOfClaimVotingPause() external view returns(uint len) {

        len = claimPauseVotingEP.length;
    }

    function getPendingClaimDetailsByIndex(
        uint _index
    )
        external
        view
        returns(
            uint claimId,
            uint pendingTime,
            bool voting
        )
    {

        claimId = claimPauseVotingEP[_index].claimid;
        pendingTime = claimPauseVotingEP[_index].pendingTime;
        voting = claimPauseVotingEP[_index].voting;
    }

    function getFirstClaimIndexToStartVotingAfterEP() external view returns(uint firstindex) {

        firstindex = claimStartVotingFirstIndex;
    }

    function updateUintParameters(bytes8 code, uint val) public {

        require(ms.checkIsAuthToGoverned(msg.sender));
        if (code == "CAMAXVT") {
            _setMaxVotingTime(val * 1 hours);

        } else if (code == "CAMINVT") {

            _setMinVotingTime(val * 1 hours);

        } else if (code == "CAPRETRY") {

            _setPayoutRetryTime(val * 1 hours);

        } else if (code == "CADEPT") {

            _setClaimDepositTime(val * 1 days);

        } else if (code == "CAREWPER") {

            _setClaimRewardPerc(val);

        } else if (code == "CAMINTH") {

            _setMinVoteThreshold(val);

        } else if (code == "CAMAXTH") {

            _setMaxVoteThreshold(val);

        } else if (code == "CACONPER") {

            _setMajorityConsensus(val);

        } else if (code == "CAPAUSET") {
            _setPauseDaysCA(val * 1 days);
        } else {

            revert("Invalid param code");
        }
    
    }

    function changeDependentContractAddress() public onlyInternal {}


    function _pushStatus(uint percCA, uint percMV) internal {

        rewardStatus.push(ClaimRewardStatus(percCA, percMV));
    }

    function _addRewardIncentive() internal {

        _pushStatus(0, 0); //0  Pending-Claim Assessor Vote
        _pushStatus(0, 0); //1 Pending-Claim Assessor Vote Denied, Pending Member Vote
        _pushStatus(0, 0); //2 Pending-CA Vote Threshold not Reached Accept, Pending Member Vote
        _pushStatus(0, 0); //3 Pending-CA Vote Threshold not Reached Deny, Pending Member Vote
        _pushStatus(0, 0); //4 Pending-CA Consensus not reached Accept, Pending Member Vote
        _pushStatus(0, 0); //5 Pending-CA Consensus not reached Deny, Pending Member Vote
        _pushStatus(100, 0); //6 Final-Claim Assessor Vote Denied
        _pushStatus(100, 0); //7 Final-Claim Assessor Vote Accepted
        _pushStatus(0, 100); //8 Final-Claim Assessor Vote Denied, MV Accepted
        _pushStatus(0, 100); //9 Final-Claim Assessor Vote Denied, MV Denied
        _pushStatus(0, 0); //10 Final-Claim Assessor Vote Accept, MV Nodecision
        _pushStatus(0, 0); //11 Final-Claim Assessor Vote Denied, MV Nodecision
        _pushStatus(0, 0); //12 Claim Accepted Payout Pending
        _pushStatus(0, 0); //13 Claim Accepted No Payout 
        _pushStatus(0, 0); //14 Claim Accepted Payout Done
    }

    function _setMaxVotingTime(uint _time) internal {

        maxVotingTime = _time;
    }

    function _setMinVotingTime(uint _time) internal {

        minVotingTime = _time;
    }

    function _setMinVoteThreshold(uint val) internal {

        minVoteThreshold = val;
    }

    function _setMaxVoteThreshold(uint val) internal {

        maxVoteThreshold = val;
    }
    
    function _setMajorityConsensus(uint val) internal {

        majorityConsensus = val;
    }

    function _setPayoutRetryTime(uint _time) internal {

        payoutRetryTime = _time;
    }

    function _setClaimRewardPerc(uint _val) internal {


        claimRewardPerc = _val;
    }
  
    function _setClaimDepositTime(uint _time) internal {


        claimDepositTime = _time;
    }

    function _setPauseDaysCA(uint val) internal {

        pauseDaysCA = val;
    }
}
