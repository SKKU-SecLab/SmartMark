pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;


contract GovernorBravoEvents {

    event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, uint startBlock, uint endBlock, string description);

    event VoteCast(address indexed voter, uint proposalId, uint8 support, uint votes, string reason);

    event ProposalCanceled(uint id);

    event ProposalQueued(uint id, uint eta);

    event ProposalExecuted(uint id);

    event VotingDelaySet(uint oldVotingDelay, uint newVotingDelay);

    event VotingPeriodSet(uint oldVotingPeriod, uint newVotingPeriod);

    event NewImplementation(address oldImplementation, address newImplementation);

    event QuorumPercentageSet(uint oldQuorumPercentage, uint newQuorumPercentage);

    event StakingAddressSet(address oldStaking, address newStaking);

    event ProposalThresholdSet(uint oldProposalThreshold, uint newProposalThreshold);

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);
}

contract GovernorBravoDelegatorStorage {

    address public admin;

    address public pendingAdmin;

    address public implementation;

    address public guardian;
}


contract GovernorBravoDelegateStorageV1 is GovernorBravoDelegatorStorage {


    uint public votingDelay;

    uint public votingPeriod;

    uint public proposalThresholdPercentage;

    uint public initialProposalId;

    uint public proposalCount;

    TimelockInterface public timelock;

    StakingInterface public staking;

    uint public quorumPercentage;


    mapping (uint => Proposal) public proposals;

    mapping (address => uint) public latestProposalIds;

    mapping (uint => uint) public quorumVotesForProposal;


    struct Proposal {
        uint id;

        address proposer;

        uint eta;

        address[] targets;

        uint[] values;

        string[] signatures;

        bytes[] calldatas;

        uint startBlock;

        uint endBlock;

        uint forVotes;

        uint againstVotes;

        uint abstainVotes;

        bool canceled;

        bool executed;

        mapping (address => Receipt) receipts;
    }

    struct Receipt {
        bool hasVoted;

        uint8 support;

        uint96 votes;
    }

    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
}

interface TimelockInterface {

    function delay() external view returns (uint);

    function GRACE_PERIOD() external view returns (uint);

    function acceptAdmin() external;

    function queuedTransactions(bytes32 hash) external view returns (bool);

    function queueTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external returns (bytes32);

    function cancelTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external;

    function executeTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external payable returns (bytes memory);

}


interface StakingInterface {

    function votingBalanceOf(
        address account,
        uint proposalCount)
        external
        view
        returns (uint totalVotes);


    function votingBalanceOfNow(
        address account)
        external
        view
        returns (uint totalVotes);


    function _setProposalVals(
        address account,
        uint proposalCount)
        external
        returns (uint);

}


interface GovernorAlpha {

    function proposalCount() external returns (uint);

}pragma solidity ^0.5.16;


contract GovernorBravoDelegate is GovernorBravoDelegateStorageV1, GovernorBravoEvents {


    string public constant name = "Ooki Governor Bravo";

    uint public constant MIN_PROPOSAL_THRESHOLD = 0.5e18; // 0.5% of OOKI

    uint public constant MAX_PROPOSAL_THRESHOLD = 2e18; // 2% of OOKI

    uint public constant MIN_VOTING_PERIOD = 5760; // About 24 hours

    uint public constant MAX_VOTING_PERIOD = 80640; // About 2 weeks

    uint public constant MIN_VOTING_DELAY = 1;

    uint public constant MAX_VOTING_DELAY = 40320; // About 1 week

    uint public constant MIN_QUORUM_PERCENTAGE = 2e18; // 2% of total OOKI supply

    uint public constant MAX_QUORUM_PERCENTAGE = 6e18; // 6% of total OOKI supply

    uint public constant proposalMaxOperations = 100; // 100 actions

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint8 support)");


    function initialize(address timelock_, address staking_, uint votingPeriod_, uint votingDelay_, uint proposalThresholdPercentage_, uint quorumPercentage_) public {

        require(address(timelock) == address(0), "GovernorBravo::initialize: can only initialize once");
        require(msg.sender == admin, "GovernorBravo::initialize: admin only");
        require(timelock_ != address(0), "GovernorBravo::initialize: invalid timelock address");
        require(staking_ != address(0), "GovernorBravo::initialize: invalid STAKING address");
        require(votingPeriod_ >= MIN_VOTING_PERIOD && votingPeriod_ <= MAX_VOTING_PERIOD, "GovernorBravo::initialize: invalid voting period");
        require(votingDelay_ >= MIN_VOTING_DELAY && votingDelay_ <= MAX_VOTING_DELAY, "GovernorBravo::initialize: invalid voting delay");
        require(proposalThresholdPercentage_ >= MIN_PROPOSAL_THRESHOLD && proposalThresholdPercentage_ <= MAX_PROPOSAL_THRESHOLD, "GovernorBravo::initialize: invalid proposal threshold");
        require(quorumPercentage_ >= MIN_QUORUM_PERCENTAGE && quorumPercentage_ <= MAX_QUORUM_PERCENTAGE, "GovernorBravo::initialize: invalid quorum percentage");

        timelock = TimelockInterface(timelock_);
        staking = StakingInterface(staking_);
        votingPeriod = votingPeriod_;
        votingDelay = votingDelay_;
        proposalThresholdPercentage = proposalThresholdPercentage_;
        quorumPercentage = quorumPercentage_;

        guardian = msg.sender;
    }

    function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) public returns (uint) {

        require(targets.length == values.length && targets.length == signatures.length && targets.length == calldatas.length, "GovernorBravo::propose: proposal function information arity mismatch");
        require(targets.length != 0, "GovernorBravo::propose: must provide actions");
        require(targets.length <= proposalMaxOperations, "GovernorBravo::propose: too many actions");

        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
            ProposalState proposersLatestProposalState = state(latestProposalId);
            require(proposersLatestProposalState != ProposalState.Active, "GovernorBravo::propose: one live proposal per proposer, found an already active proposal");
            require(proposersLatestProposalState != ProposalState.Pending, "GovernorBravo::propose: one live proposal per proposer, found an already pending proposal");
        }

        uint proposalId = proposalCount + 1;
        require(staking._setProposalVals(msg.sender, proposalId) > proposalThreshold(), "GovernorBravo::propose: proposer votes below proposal threshold");
        proposalCount = proposalId;

        uint startBlock = add256(block.number, votingDelay);
        uint endBlock = add256(startBlock, votingPeriod);

        Proposal memory newProposal = Proposal({
            id: proposalId,
            proposer: msg.sender,
            eta: 0,
            targets: targets,
            values: values,
            signatures: signatures,
            calldatas: calldatas,
            startBlock: startBlock,
            endBlock: endBlock,
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            canceled: false,
            executed: false
        });

        proposals[proposalId] = newProposal;
        latestProposalIds[msg.sender] = proposalId;
        quorumVotesForProposal[proposalId] = quorumVotes();

        emit ProposalCreated(proposalId, msg.sender, targets, values, signatures, calldatas, startBlock, endBlock, description);
        return proposalId;
    }

    function queue(uint proposalId) external {

        require(state(proposalId) == ProposalState.Succeeded, "GovernorBravo::queue: proposal can only be queued if it is succeeded");
        Proposal storage proposal = proposals[proposalId];
        uint eta = add256(block.timestamp, timelock.delay());
        for (uint i = 0; i < proposal.targets.length; i++) {
            queueOrRevertInternal(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], eta);
        }
        proposal.eta = eta;
        emit ProposalQueued(proposalId, eta);
    }

    function queueOrRevertInternal(address target, uint value, string memory signature, bytes memory data, uint eta) internal {

        require(!timelock.queuedTransactions(keccak256(abi.encode(target, value, signature, data, eta))), "GovernorBravo::queueOrRevertInternal: identical proposal action already queued at eta");
        timelock.queueTransaction(target, value, signature, data, eta);
    }

    function execute(uint proposalId) external payable {

        require(state(proposalId) == ProposalState.Queued, "GovernorBravo::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.executeTransaction.value(proposal.values[i])(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint proposalId) external {

        require(state(proposalId) != ProposalState.Executed, "GovernorBravo::cancel: cannot cancel executed proposal");

        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer || staking.votingBalanceOfNow(proposal.proposer) < proposalThreshold() || msg.sender == guardian, "GovernorBravo::cancel: proposer above threshold");

        proposal.canceled = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.cancelTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }

        emit ProposalCanceled(proposalId);
    }

    function quorumVotes() public view returns (uint256) {

        uint256 totalSupply = IERC20(0x0De05F6447ab4D22c8827449EE4bA2D5C288379B) // OOKI
            .totalSupply();
        return totalSupply * quorumPercentage / 1e20;
    }

    function proposalThreshold() public view returns (uint256) {

        uint256 totalSupply = IERC20(0x0De05F6447ab4D22c8827449EE4bA2D5C288379B) // OOKI
            .totalSupply();
        return totalSupply * proposalThresholdPercentage / 1e20;
    }

    function getActions(uint proposalId) external view returns (address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas) {

        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory) {

        return proposals[proposalId].receipts[voter];
    }

    function state(uint proposalId) public view returns (ProposalState) {

        require(proposalCount >= proposalId && proposalId > initialProposalId, "GovernorBravo::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < quorumVotesForProposal[proposalId]) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.timestamp >= add256(proposal.eta, timelock.GRACE_PERIOD())) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }

    function castVote(uint proposalId, uint8 support) external {

        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support), "");
    }

    function castVoteWithReason(uint proposalId, uint8 support, string calldata reason) external {

        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support), reason);
    }

    function castVoteBySig(uint proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) public {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainIdInternal(), address(this)));
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GovernorBravo::castVoteBySig: invalid signature");
        emit VoteCast(signatory, proposalId, support, castVoteInternal(signatory, proposalId, support), "");
    }


    function castVotes(uint[] calldata proposalIds, uint8[] calldata supportVals) external {

        require(proposalIds.length == supportVals.length, "count mismatch");
        for (uint256 i = 0; i < proposalIds.length; i++) {
            emit VoteCast(msg.sender, proposalIds[i], supportVals[i], castVoteInternal(msg.sender, proposalIds[i], supportVals[i]), "");
        }
    }

    function castVotesWithReason(uint[] calldata proposalIds, uint8[] calldata supportVals, string[] calldata reasons) external {

        require(proposalIds.length == supportVals.length && proposalIds.length == reasons.length, "count mismatch");
        for (uint256 i = 0; i < proposalIds.length; i++) {
            emit VoteCast(msg.sender, proposalIds[i], supportVals[i], castVoteInternal(msg.sender, proposalIds[i], supportVals[i]), reasons[i]);
        }
    }

    function castVotesBySig(uint[] calldata proposalIds, uint8[] calldata supportVals, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {

        require(proposalIds.length == supportVals.length && proposalIds.length == vs.length && proposalIds.length == rs.length && proposalIds.length == ss.length, "count mismatch");
        for (uint256 i = 0; i < proposalIds.length; i++) {
            castVoteBySig(proposalIds[i], supportVals[i], vs[i], rs[i], ss[i]);
        }
    }

    function castVoteInternal(address voter, uint proposalId, uint8 support) internal returns (uint96) {

        require(state(proposalId) == ProposalState.Active, "GovernorBravo::castVoteInternal: voting is closed");
        require(support <= 2, "GovernorBravo::castVoteInternal: invalid vote type");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "GovernorBravo::castVoteInternal: voter already voted");
        uint96 votes = uint96(staking.votingBalanceOf(voter, proposalId));

        if (support == 0) {
            proposal.againstVotes = add256(proposal.againstVotes, votes);
        } else if (support == 1) {
            proposal.forVotes = add256(proposal.forVotes, votes);
        } else if (support == 2) {
            proposal.abstainVotes = add256(proposal.abstainVotes, votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        return votes;
    }

    function __setVotingDelay(uint newVotingDelay) external {

        require(msg.sender == admin, "GovernorBravo::__setVotingDelay: admin only");
        require(newVotingDelay >= MIN_VOTING_DELAY && newVotingDelay <= MAX_VOTING_DELAY, "GovernorBravo::__setVotingDelay: invalid voting delay");
        uint oldVotingDelay = votingDelay;
        votingDelay = newVotingDelay;

        emit VotingDelaySet(oldVotingDelay, votingDelay);
    }

    function __setVotingPeriod(uint newVotingPeriod) external {

        require(msg.sender == admin, "GovernorBravo::__setVotingPeriod: admin only");
        require(newVotingPeriod >= MIN_VOTING_PERIOD && newVotingPeriod <= MAX_VOTING_PERIOD, "GovernorBravo::__setVotingPeriod: invalid voting period");
        uint oldVotingPeriod = votingPeriod;
        votingPeriod = newVotingPeriod;

        emit VotingPeriodSet(oldVotingPeriod, votingPeriod);
    }

    function __setQuorumPercentage(uint newQuorumPercentage) external {

        require(msg.sender == admin, "GovernorBravo::__setQuorumPercentage: admin only");
        require(newQuorumPercentage >= MIN_QUORUM_PERCENTAGE && newQuorumPercentage <= MAX_QUORUM_PERCENTAGE, "GovernorBravo::__setQuorumPercentage: invalid quorum percentage");
        uint oldQuorumPercentage = quorumPercentage;
        quorumPercentage = newQuorumPercentage;

        emit QuorumPercentageSet(oldQuorumPercentage, newQuorumPercentage);
    }

    function __setStaking(address newStaking) external {

        require(msg.sender == admin, "GovernorBravo::__setStaking: admin only");
        require(newStaking != address(0) , "GovernorBravo::__setStaking: invalid address");
        address oldStaking = address(staking);
        staking = StakingInterface(newStaking);

        emit StakingAddressSet(oldStaking, newStaking);
    }

    function __setProposalThresholdPercentage(uint newProposalThresholdPercentage) external {

        require(msg.sender == admin, "GovernorBravo::__setProposalThreshold: admin only");
        require(newProposalThresholdPercentage >= MIN_PROPOSAL_THRESHOLD && newProposalThresholdPercentage <= MAX_PROPOSAL_THRESHOLD, "GovernorBravo::__setProposalThreshold: invalid proposal threshold");
        uint oldProposalThresholdPercentage = proposalThresholdPercentage;
        proposalThresholdPercentage = newProposalThresholdPercentage;

        emit ProposalThresholdSet(oldProposalThresholdPercentage, proposalThresholdPercentage);
    }

    function __setPendingLocalAdmin(address newPendingAdmin) external {

        require(msg.sender == admin, "GovernorBravo:__setPendingLocalAdmin: admin only");

        address oldPendingAdmin = pendingAdmin;

        pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function __acceptLocalAdmin() external {

        require(msg.sender == pendingAdmin && msg.sender != address(0), "GovernorBravo:__acceptLocalAdmin: pending admin only");

        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        admin = pendingAdmin;

        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function __changeGuardian(address guardian_) public {

        require(msg.sender == guardian, "GovernorBravo::__changeGuardian: sender must be gov guardian");
        require(guardian_ != address(0), "GovernorBravo::__changeGuardian: not allowed");
        guardian = guardian_;
    }

    function __acceptAdmin() public {

        require(msg.sender == guardian, "GovernorBravo::__acceptAdmin: sender must be gov guardian");
        timelock.acceptAdmin();
    }

    function __abdicate() public {

        require(msg.sender == guardian, "GovernorBravo::__abdicate: sender must be gov guardian");
        guardian = address(0);
    }

    function __queueSetTimelockPendingAdmin(address newPendingAdmin, uint eta) public {

        require(msg.sender == guardian, "GovernorBravo::__queueSetTimelockPendingAdmin: sender must be gov guardian");
        timelock.queueTransaction(address(timelock), 0, "setPendingAdmin(address)", abi.encode(newPendingAdmin), eta);
    }

    function __executeSetTimelockPendingAdmin(address newPendingAdmin, uint eta) public {

        require(msg.sender == guardian, "GovernorBravo::__executeSetTimelockPendingAdmin: sender must be gov guardian");
        timelock.executeTransaction(address(timelock), 0, "setPendingAdmin(address)", abi.encode(newPendingAdmin), eta);
    }

    function add256(uint256 a, uint256 b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint) {

        require(b <= a, "subtraction underflow");
        return a - b;
    }

    function getChainIdInternal() internal pure returns (uint) {

        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}