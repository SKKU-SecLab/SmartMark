pragma solidity ^0.8.4;

interface ERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}// MIT
pragma solidity ^0.8.4;

contract UniqueKeyGenerator {

    uint256 private salt;

    function generateKey(address a) internal view returns (bytes32) {

        return keccak256(abi.encode(uint256(uint160(a)) + salt));
    }

    function generateKey(uint256 u) internal view returns (bytes32) {

        return keccak256(abi.encode(u + salt));
    }

    function addSalt() internal {

        salt += 100000000;
    }
}// MIT
pragma solidity ^0.8.4;


abstract contract VotingSystem is UniqueKeyGenerator {
    mapping(bytes32 => bool) internal isCandidate;
    
    mapping(bytes32 => uint256) internal votes;
    struct VotingCycle {
        uint256 id;
        address[] candidates;
        address leader;
        uint256 leaderVotes;
        bool tied;
    }
    VotingCycle internal currentVotingCycle;

    mapping(bytes32 => bool) internal voted;

    mapping(bytes32 => bool) internal addedProposal;

    VotingStatus internal currentStatus;
    enum VotingStatus { INACTIVE, ACTIVE }
    enum StartVotingOutcome { STARTED, UNCONTESTED, NO_CANDIDATES }
    enum StopVotingOutcome { STOPPED, NO_VOTES, TIE }
    address internal latestWinner;
    uint256 internal numVotesHeld;

    event VotingActive(uint256 votingSessionNumber);
    event VotingInactive(address winner, uint256 numVotes);
    event VotingExtended();
    event VotingPostponed(string reason);
    event VoteUncontested(address winner);
    event VoteCounted(address indexed voter, address indexed vote);
    event CandidateAdded(address indexed candidate, address indexed addedBy);

    string constant duplicateCandidateMsg = "The proposed candidate has already been added.";
    string constant alreadyAddedCandidateMsg = "The sender's address has already proposed a candidate";
    string constant alreadyVotedMsg = "The sender's address has already voted this cycle";
    string constant noMatchingCandidateMsg = "No matching candidate exists this voting cycle";
    string constant votingInactiveMsg = "Votes cannot be cast while voting state is INACTIVE (0)";
    string constant votingActiveMsg = "Candidates cannot be proposed while voting state is ACTIVE (2)";

    function startVoting() internal returns (StartVotingOutcome outcome, address winner) {
        assert(currentStatus == VotingStatus.INACTIVE);
        if (currentVotingCycle.candidates.length != 0 && currentVotingCycle.candidates.length > 1) {
            currentStatus = VotingStatus.ACTIVE;
            numVotesHeld++;
            emit VotingActive(numVotesHeld);
            return (StartVotingOutcome.STARTED, address(0));
        }
        if (currentVotingCycle.candidates.length == 1) {
            numVotesHeld++;
            latestWinner = currentVotingCycle.candidates[0];
            emit VoteUncontested(latestWinner);
            resetVotingState();
            return (StartVotingOutcome.UNCONTESTED, latestWinner);
        }
        emit VotingPostponed("No candidates");
        return (StartVotingOutcome.NO_CANDIDATES, address(0));
    }

    function stopVoting() internal returns (StopVotingOutcome outcome, address winner) {
        assert(currentStatus == VotingStatus.ACTIVE);
        if (currentVotingCycle.leader == address(0)) {
            currentStatus = VotingStatus.INACTIVE;
            emit VotingPostponed("No votes cast");
            return (StopVotingOutcome.NO_VOTES, address(0));
        }
        if (currentVotingCycle.tied) {
            emit VotingExtended();
            return (StopVotingOutcome.TIE, address(0));
        }
        currentStatus = VotingStatus.INACTIVE;
        emit VotingInactive(currentVotingCycle.leader, currentVotingCycle.leaderVotes);
        latestWinner = currentVotingCycle.leader;
        resetVotingState();
        return (StopVotingOutcome.STOPPED, latestWinner);
    }

    function addCandidate(address candidate, address proposer) internal {
        require(currentStatus == VotingStatus.INACTIVE, votingActiveMsg);
        bytes32 proposerKey = generateKey(proposer);
        bytes32 candidateKey = generateKey(candidate);
        require(!addedProposal[proposerKey], alreadyAddedCandidateMsg);
        require(!isCandidate[candidateKey], duplicateCandidateMsg);
        isCandidate[candidateKey] = true;
        addedProposal[proposerKey] = true;
        currentVotingCycle.candidates.push(candidate);
        emit CandidateAdded(candidate, proposer);
    }

    function voteForCandidate(address vote, address voter) internal {
        require(currentStatus == VotingStatus.ACTIVE, votingInactiveMsg);
        bytes32 voteKey = generateKey(vote);
        bytes32 voterKey = generateKey(voter);
        require(!voted[voterKey], alreadyVotedMsg);
        require(isCandidate[voteKey], noMatchingCandidateMsg);
        votes[voteKey]++;
        voted[voterKey] = true;
        adjustLeader(vote, votes[voteKey]);
        emit VoteCounted(voter, vote);
    }

    function adjustLeader(address vote, uint256 numVotes) private {
        if (numVotes == currentVotingCycle.leaderVotes) {
            currentVotingCycle.tied = true;
        } else if (numVotes > currentVotingCycle.leaderVotes) {
            currentVotingCycle.leaderVotes = numVotes;
            currentVotingCycle.leader = vote;
            currentVotingCycle.tied = false;
        }
    }

    function resetVotingState() private {
        VotingCycle memory vc;
        vc.id = currentVotingCycle.id + 1;
        currentVotingCycle = vc;
        addSalt();
        postVoteCleanUp();
    }

    function postVoteCleanUp() internal virtual;


    function getVotingStatus() public view returns (VotingStatus) {
        return currentStatus;
    }

    function isVotingActive() public view returns (bool) {
        return currentStatus == VotingStatus.ACTIVE;
    }

    function getIsCandidate(address a) public view returns (bool) {
        return isCandidate[generateKey(a)];
    }

    function getNumberOfVotes(address a) public view returns (uint256) {
        return votes[generateKey(a)];
    }

    function getCurrentLeader() public view returns (address) {
        return currentVotingCycle.leader;
    }

    function getCurrentLeaderVoteCount() public view returns (uint256) {
        return currentVotingCycle.leaderVotes;
    }

    function getCurrentVotingCycleId() public view returns (uint256) {
        return currentVotingCycle.id;
    }

    function isCurrentlyTied() public view returns (bool) {
        return currentVotingCycle.tied;
    }

    function hasAlreadyVoted(address a) public view returns (bool) {
        return voted[generateKey(a)];
    }

    function hasAlreadyAddedCandidate(address a) public view returns (bool) {
        return addedProposal[generateKey(a)];
    }

    function mostRecentWinner() public view returns (address) {
        return latestWinner;
    }

    function totalVoteSessionsHeld() public view returns (uint256) {
        return numVotesHeld;
    }
}// MIT
pragma solidity ^0.8.4;



contract Tontoken is ERC20, VotingSystem {

    uint256 private _totalSupply;
    uint256 private allTimeMatchAmount;
    uint8 private borkMatchRateShift; // percent of each transaction to be held by contract for eventual donation
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    struct BorkPoolRecipient {
        address addr;
        string name; // optional
        string description; // optional
        string website; // optional
    }
    mapping(bytes32 => BorkPoolRecipient) private potentialRecipients;
    uint256 numPotentialRecipients;

    uint256 private minVoterThreshold;
    uint256 private minProposalThreshold;
    mapping(bytes32 => uint256) private lockedBorks;
    mapping(address => address) private delegatedVoters;
    uint256 private lastVotingBlock; // block number of recent voting events
    uint256 private numBlocks7Days;
    uint256 private numBlocks1Day;

    event BorksMatched(address indexed from, address indexed to, uint256 amount, uint256 matched);
    event VotingRightsDelegated(address indexed delegate, address indexed voter);
    event DelegatedRightsRemoved(address indexed delegate, address indexed voter);
    
    string constant insufficientFundsMsg = "Insufficient funds to complete the transfer. Perhaps some are locked?";
    string constant cannotSendToZeroMsg = "Funds cannot be burned (sent to the zero address)";
    string constant insufficientAllowanceMsg = "The allowance of the transaction sender is insufficient to complete the transfer";
    string constant zeroDonationMsg = "Donations must be greater than or equal to 1 Bork";
    string constant voterMinimumMsg = "10000 TONT minimum balance required to vote";
    string constant proposalMinimumMsg = "50000 TONT minimum balance required to add potential recipients";
    string constant zeroSpenderMsg = "The zero address cannot be designated as a spender";
    string constant balanceNotApprovedMsg = "A spender cannot be approved a balance higher than the approver's balance";

    constructor(bool publicNet) {
        _totalSupply = 1000000000000; // initial supply of 1,000,000 Tontokens
        borkMatchRateShift = 6; // ~1.5% (+- 64 borks)
        balances[msg.sender] = _totalSupply;
        minVoterThreshold = 10000000000; // at least 10,000 Tontokens to vote
        minProposalThreshold = 50000000000; // at least 50,000 Tontokens to propose
        lastVotingBlock = block.number;
        if (publicNet) {
            numBlocks7Days = 40320;
            numBlocks1Day = 5760;
        } else {
            numBlocks7Days = 7;
            numBlocks1Day = 1;
        }
    }

    function name() override public pure returns (string memory) {

        return "Tontoken";
    }

    function symbol() override public pure returns (string memory) {

        return "TONT";
    }

    function decimals() override public pure returns (uint8) {

        return 6;
    }

    function totalSupply() override public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address _owner) override public view returns (uint256) {

        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) override public returns (bool) {

        validateTransfer(msg.sender, _to, _value);
        executeTransfer(msg.sender, _to, _value);
        orchestrateVoting();
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool) {

        require(allowed[msg.sender][_from] >= _value, insufficientAllowanceMsg);
        validateTransfer(_from, _to, _value);
        allowed[msg.sender][_from] -= _value;
        executeTransfer(_from, _to, _value);
        orchestrateVoting();
        return true;
    }
    
    function approve(address _spender, uint256 _value) override public returns (bool) {

        require(_spender != address(0), zeroSpenderMsg);
        require(balances[msg.sender] >= _value, balanceNotApprovedMsg);
        if (allowed[_spender][msg.sender] != 0) {
            allowed[_spender][msg.sender] = 0;
        }
        allowed[_spender][msg.sender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) override public view returns (uint256) {

        return allowed[_spender][_owner];
    }

    function executeTransfer(address from, address to, uint256 value) private {

        uint256 matched;
        if (from != address(this)) {
            matched = applyBorkMatch(value, from, to);
        }
        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        mintBorks(matched);
    }

    function validateTransfer(address from, address to, uint256 value) private view {

        require(getSendableBalance(from) >= value, insufficientFundsMsg);
        require(to != address(0), cannotSendToZeroMsg);
    }

    function applyBorkMatch(uint256 value, address from, address to) private returns (uint256 matchAmt) {

        uint256 matched;
        if (value < 64) {
            matched = 1;
        } else {
            matched = value >> borkMatchRateShift;
        }
        balances[address(this)] += matched;
        allTimeMatchAmount += matched;
        emit BorksMatched(from, to, value, matched);
        return matched;
    }

    function mintBorks(uint256 numBorks) private {

        _totalSupply += numBorks;
    }

    function enterVote(address vote) public {

        require(balanceOf(msg.sender) >= minVoterThreshold, voterMinimumMsg);
        lockBorks(msg.sender, minVoterThreshold);
        super.voteForCandidate(vote, msg.sender);
    }

    function enterDelegatedVote(address voter, address vote) public {

        require(delegatedVoters[voter] == msg.sender);
        require(balanceOf(voter) >= minVoterThreshold, voterMinimumMsg);
        lockBorks(voter, minVoterThreshold);
        super.voteForCandidate(vote, voter);
    }

    function delegateVoter(address delegate) public {

        delegatedVoters[msg.sender] = delegate;
        emit VotingRightsDelegated(delegate, msg.sender);
    }

    function dischargeDelegatedVoter() public {

        emit DelegatedRightsRemoved(delegatedVoters[msg.sender], msg.sender);
        delete delegatedVoters[msg.sender];
    }

    function addBorkPoolRecipient(address recipient) private {

        require(balanceOf(msg.sender) >= minProposalThreshold, proposalMinimumMsg);
        require(recipient != address(0));
        lockBorks(msg.sender, minProposalThreshold);
        super.addCandidate(recipient, msg.sender);
    }

    function proposeBorkPoolRecipient(address recipient) public {

        addBorkPoolRecipient(recipient);
        appendBorkPoolRecipient(BorkPoolRecipient(recipient, "", "", ""));
    }

    function proposeBorkPoolRecipient(address recipient, string memory _name, string memory description, string memory website) public {

        addBorkPoolRecipient(recipient);
        appendBorkPoolRecipient(BorkPoolRecipient(recipient, _name, description, website));
    }

    function appendBorkPoolRecipient(BorkPoolRecipient memory recipient) private {

        potentialRecipients[generateKey(numPotentialRecipients)] = recipient;
        numPotentialRecipients++;
    }

    function lockBorks(address owner, uint256 toLock) private {

        lockedBorks[generateKey(owner)] += toLock;
    }

    function getSendableBalance(address owner) public view returns (uint256) {

        bytes32 generatedOwnerKey = generateKey(owner);
        if (lockedBorks[generatedOwnerKey] >= balances[owner]) {
            return 0;
        }
        return balances[owner] - lockedBorks[generatedOwnerKey];
    }

    function shouldStartVoting() private view returns (bool) {

        return currentStatus == VotingStatus.INACTIVE && block.number - lastVotingBlock >= numBlocks7Days;
    }

    function shouldEndVoting() private view returns (bool) {

        return currentStatus == VotingStatus.ACTIVE && block.number - lastVotingBlock >= numBlocks1Day;
    }

    function orchestrateVoting() private {

        if (shouldStartVoting()) {
            (StartVotingOutcome outcome, address winner) = super.startVoting();
            if (outcome == StartVotingOutcome.UNCONTESTED) {
                distributeBorkPool(winner);
            }
            lastVotingBlock = block.number;
        } else if (shouldEndVoting()) {
            (StopVotingOutcome outcome, address winner) = super.stopVoting();
            if (outcome == StopVotingOutcome.STOPPED) {
                distributeBorkPool(winner);
            }
            lastVotingBlock = block.number;
        }
    }

    function distributeBorkPool(address recipient) private {

        executeTransfer(address(this), recipient, balanceOf(address(this)));
    }

    function postVoteCleanUp() override internal {

        delete numPotentialRecipients;
    }

    function donate(uint256 value) public {

        require(value != 0, zeroDonationMsg);
        validateTransfer(msg.sender, address(this), value);
        executeTransfer(msg.sender, address(this), value);
    }


    function getLockedBorks(address owner) public view returns (uint256) {

        return lockedBorks[generateKey(owner)];
    }

    function getBorkPoolCandidateAddresses() public view returns (address[] memory) {

        return currentVotingCycle.candidates;
    }

    function getBorkPoolCandidates() public view returns (BorkPoolRecipient[] memory) {

        BorkPoolRecipient[] memory allRecipients = new BorkPoolRecipient[](numPotentialRecipients);
        for (uint256 i; i < numPotentialRecipients; i++) {
            allRecipients[i] = potentialRecipients[generateKey(i)];
        }
        return allRecipients;
    }

    function borkPool() public view returns (uint256) {

        return balanceOf(address(this));
    }

    function getVotingMinimum() public view returns (uint256) {

        return minVoterThreshold;
    }

    function getProposalMinimum() public view returns (uint256) {

        return minProposalThreshold;
    }

    function totalBorksMatched() public view returns (uint256) {

        return allTimeMatchAmount;
    }

    function getLastVotingBlock() public view returns (uint256) {

        return lastVotingBlock;
    }

    function getActiveVotingLength() public view returns (uint256) {

        return numBlocks1Day;
    }

    function getInactiveVotingLength() public view returns (uint256) {

        return numBlocks7Days;
    }
}