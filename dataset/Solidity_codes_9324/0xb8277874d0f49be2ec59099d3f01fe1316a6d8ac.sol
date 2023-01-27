
pragma solidity 0.4.26;

contract IContractId {

    function contractId() public pure returns (bytes32 id, uint256 version);

}

contract ITokenSnapshots {



    function totalSupplyAt(uint256 snapshotId)
        public
        constant
        returns(uint256);


    function balanceOfAt(address owner, uint256 snapshotId)
        public
        constant
        returns (uint256);


    function currentSnapshotId()
        public
        constant
        returns (uint256);

}

contract IVotingCenter is IContractId {


    function addProposal(
        bytes32 proposalId,
        ITokenSnapshots token,
        uint32 campaignDuration,
        uint256 campaignQuorumFraction,
        uint32 votingPeriod,
        address votingLegalRep,
        uint32 offchainVotePeriod,
        uint256 totalVotingPower,
        uint256 action,
        bytes actionPayload,
        bool enableObserver
    )
        public;


    function vote(bytes32 proposalId, bool voteInFavor)
        public;


    function addOffchainVote(bytes32 proposalId, uint256 inFavor, uint256 against, string documentUri)
        public;



    function tally(bytes32 proposalId)
        public
        constant
        returns(
            uint8 s,
            uint256 inFavor,
            uint256 against,
            uint256 offchainInFavor,
            uint256 offchainAgainst,
            uint256 tokenVotingPower,
            uint256 totalVotingPower,
            uint256 campaignQuorumTokenAmount,
            address initiator,
            bool hasObserverInterface
        );


    function offchainVoteDocumentUri(bytes32 proposalId)
        public
        constant
        returns (string);


    function timedProposal(bytes32 proposalId)
        public
        constant
        returns (
            uint8 s,
            address token,
            uint256 snapshotId,
            address initiator,
            address votingLegalRep,
            uint256 campaignQuorumTokenAmount,
            uint256 offchainVotingPower,
            uint256 action,
            bytes actionPayload,
            bool enableObserver,
            uint32[5] deadlines
        );


    function proposal(bytes32 proposalId)
        public
        constant
        returns (
            uint8 s,
            address token,
            uint256 snapshotId,
            address initiator,
            address votingLegalRep,
            uint256 campaignQuorumTokenAmount,
            uint256 offchainVotingPower,
            uint256 action,
            bytes actionPayload,
            bool enableObserver,
            uint32[5] deadlines
        );


    function getVote(bytes32 proposalId, address voter)
        public
        constant
        returns (uint8);


    function hasProposal(bytes32 proposalId)
        public
        constant
        returns (bool);


    function getVotingPower(bytes32 proposalId, address voter)
        public
        constant
        returns (uint256);

}

contract IVotingController is IContractId {

    function onAddProposal(bytes32 proposalId, address initiator, address token)
        public
        constant
        returns (bool);


    function onChangeVotingController(address sender, IVotingController newController)
        public
        constant
        returns (bool);

}

library Math {


    function absDiff(uint256 v1, uint256 v2)
        internal
        pure
        returns(uint256)
    {

        return v1 > v2 ? v1 - v2 : v2 - v1;
    }

    function divRound(uint256 v, uint256 d)
        internal
        pure
        returns(uint256)
    {

        return add(v, d/2) / d;
    }

    function decimalFraction(uint256 amount, uint256 frac)
        internal
        pure
        returns(uint256)
    {

        return proportion(amount, frac, 10**18);
    }

    function proportion(uint256 amount, uint256 part, uint256 total)
        internal
        pure
        returns(uint256)
    {

        return divRound(mul(amount, part), total);
    }


    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a > b ? a : b;
    }
}

contract IVotingObserver {

    function onProposalStateTransition(
        bytes32 proposalId,
        uint8 oldState,
        uint8 newState)
        public;


    function votingResult(address votingCenter, bytes32 proposalId)
        public
        constant
        returns (bool inFavor);

}

library VotingProposal {


    uint256 private constant STATES_COUNT = 5;


    enum State {
        Campaigning,
        Public,
        Reveal,
        Tally,
        Final
    }

    enum TriState {
        Abstain,
        InFavor,
        Against
    }

    struct Proposal {
        ITokenSnapshots token;
        uint256 snapshotId;
        uint256 inFavor;
        uint256 against;
        uint256 offchainInFavor;
        uint256 offchainAgainst;

        uint256 campaignQuorumTokenAmount;

        uint256 offchainVotingPower;

        IVotingObserver initiator;
        address votingLegalRep;

        uint256 action;
        bytes actionPayload;
        string offchainVoteDocumentUri;

        uint32[STATES_COUNT] deadlines;

        State state;

        bool observing;

        mapping (address => TriState) hasVoted;
    }


    event LogProposalStateTransition(
        bytes32 indexed proposalId,
        address initiator,
        address votingLegalRep,
        address token,
        State oldState,
        State newState
    );


    function isVotingOpen(VotingProposal.Proposal storage p)
        internal
        constant
        returns (bool)
    {

        return p.state == State.Campaigning || p.state == State.Public;
    }

    function isRelayOpen(VotingProposal.Proposal storage p)
        internal
        constant
        returns (bool)
    {

        return isVotingOpen(p) || p.state == State.Reveal;
    }

    function initialize(
        Proposal storage p,
        bytes32 proposalId,
        ITokenSnapshots token,
        uint256 snapshotId,
        uint32 campaignDuration,
        uint256 campaignQuorumFraction,
        uint32 votingPeriod,
        address votingLegalRep,
        uint32 offchainVotePeriod,
        uint256 totalVotingPower,
        uint256 action,
        bool enableObserver
    )
        internal
    {

        uint256 totalTokenVotes = token.totalSupplyAt(snapshotId);
        require(totalTokenVotes > 0, "NF_VC_EMPTY_TOKEN");
        require(totalVotingPower == 0 || totalVotingPower >= totalTokenVotes, "NF_VC_TOTPOWER_LT_TOKEN");

        uint32[STATES_COUNT] memory deadlines;
        uint32 t = uint32(now);
        deadlines[0] = t;
        deadlines[1] = t + campaignDuration;
        deadlines[2] = deadlines[3] = t + votingPeriod;
        deadlines[4] = deadlines[3] + (totalVotingPower == totalTokenVotes ? 0 : offchainVotePeriod);

        p.token = token;
        p.snapshotId = snapshotId;
        p.observing = enableObserver;

        p.votingLegalRep = votingLegalRep;
        p.offchainVotingPower = totalVotingPower > 0 ? Math.sub(totalVotingPower, totalTokenVotes) : 0;

        p.campaignQuorumTokenAmount = Math.decimalFraction(totalTokenVotes + p.offchainVotingPower, campaignQuorumFraction);
        require(p.campaignQuorumTokenAmount <= totalTokenVotes, "NF_VC_NO_CAMP_VOTING_POWER");

        p.initiator = IVotingObserver(msg.sender);
        p.deadlines = deadlines;
        p.state = State.Campaigning;
        p.action = action;

        advanceLogicState(p, proposalId);
    }

    function advanceTimedState(Proposal storage p, bytes32 proposalId)
        internal
    {

        uint32 t = uint32(now);
        if (p.state == State.Campaigning && t >= p.deadlines[uint32(State.Public)]) {
            transitionTo(p, proposalId, State.Final);
        }
        while(p.state != State.Final && t >= p.deadlines[uint32(p.state) + 1]) {
            transitionTo(p, proposalId, State(uint8(p.state) + 1));
        }
    }

    function advanceLogicState(Proposal storage p, bytes32 proposalId)
        internal
    {

        if (p.state == State.Campaigning && p.inFavor + p.against >= p.campaignQuorumTokenAmount) {
            transitionTo(p, proposalId, State.Public);
        }
        if (p.state == State.Tally && p.offchainAgainst + p.offchainInFavor > 0) {
            transitionTo(p, proposalId, State.Final);
        }
    }

    function transitionTo(Proposal storage p, bytes32 proposalId, State newState)
        private
    {

        State oldState = p.state;
        uint32 delta;
        uint32 deadline = p.deadlines[uint256(oldState) + 1];
        if (uint32(now) < deadline) {
            delta = deadline - uint32(now);
        }
        if (delta > 0) {
            uint32[STATES_COUNT] memory newDeadlines = p.deadlines;
            for (uint256 ii = uint256(oldState) + 1; ii < STATES_COUNT; ii += 1) {
                newDeadlines[ii] -= delta;
            }
            p.deadlines = newDeadlines;
        }
        p.state = newState;

        if (oldState == State.Campaigning && newState == State.Final) {
            return;
        }

        emit LogProposalStateTransition(proposalId, p.initiator, p.votingLegalRep, p.token, oldState, newState);
        if (p.observing) {
            bytes4 sel = p.initiator.onProposalStateTransition.selector;
            (address(p.initiator)).call(
                abi.encodeWithSelector(sel, proposalId, oldState, newState)
                );
        }
    }
}

contract VotingCenter is IVotingCenter {


    using VotingProposal for VotingProposal.Proposal;


    modifier withStateTransition(bytes32 proposalId) {

        VotingProposal.Proposal storage p = ensureExistingProposal(proposalId);
        VotingProposal.advanceTimedState(p, proposalId);
        _;
        VotingProposal.advanceLogicState(p, proposalId);
    }

    modifier withTimedTransition(bytes32 proposalId) {

        VotingProposal.Proposal storage p = ensureExistingProposal(proposalId);
        VotingProposal.advanceTimedState(p, proposalId);
        _;
    }

    modifier withVotingOpen(bytes32 proposalId) {

        VotingProposal.Proposal storage p = _proposals[proposalId];
        require(VotingProposal.isVotingOpen(p), "NV_VC_VOTING_CLOSED");
        _;
    }

    modifier withRelayingOpen(bytes32 proposalId) {

        VotingProposal.Proposal storage p = _proposals[proposalId];
        require(VotingProposal.isRelayOpen(p), "NV_VC_VOTING_CLOSED");
        _;
    }

    modifier onlyTally(bytes32 proposalId) {

        VotingProposal.Proposal storage p = _proposals[proposalId];
        require(p.state == VotingProposal.State.Tally, "NV_VC_NOT_TALLYING");
        _;
    }


    mapping (bytes32 => VotingProposal.Proposal) private _proposals;
    IVotingController private _votingController;



    event LogProposalStateTransition(
        bytes32 indexed proposalId,
        address initiator,
        address votingLegalRep,
        address token,
        VotingProposal.State oldState,
        VotingProposal.State newState
    );

    event LogVoteCast(
        bytes32 indexed proposalId,
        address initiator,
        address token,
        address voter,
        bool voteInFavor,
        uint256 power
    );

    event LogOffChainProposalResult(
        bytes32 indexed proposalId,
        address initiator,
        address token,
        address votingLegalRep,
        uint256 inFavor,
        uint256 against,
        string documentUri
    );

    event LogChangeVotingController(
        address oldController,
        address newController,
        address by
    );


    constructor(IVotingController controller) public {
        _votingController = controller;
    }



    function addProposal(
        bytes32 proposalId,
        ITokenSnapshots token,
        uint32 campaignDuration,
        uint256 campaignQuorumFraction,
        uint32 votingPeriod,
        address votingLegalRep,
        uint32 offchainVotePeriod,
        uint256 totalVotingPower,
        uint256 action,
        bytes actionPayload,
        bool enableObserver
    )
        public
    {

        require(token != address(0));
        VotingProposal.Proposal storage p = _proposals[proposalId];

        require(p.token == address(0), "NF_VC_P_ID_NON_UNIQ");
        require(campaignDuration <= votingPeriod, "NF_VC_CAMPAIGN_OVR_TOTAL");
        require(campaignQuorumFraction <= 10**18, "NF_VC_INVALID_CAMPAIGN_Q");
        require(
            campaignQuorumFraction == 0 && campaignDuration == 0 ||
            campaignQuorumFraction > 0 && campaignDuration > 0,
            "NF_VC_CAMP_INCONSISTENT"
        );
        require(
            offchainVotePeriod > 0 && totalVotingPower > 0 && votingLegalRep != address(0) ||
            offchainVotePeriod == 0 && totalVotingPower == 0 && votingLegalRep == address(0),
            "NF_VC_TALLY_INCONSISTENT"
        );

        uint256 sId = token.currentSnapshotId() - 1;

        p.initialize(
            proposalId,
            token,
            sId,
            campaignDuration,
            campaignQuorumFraction,
            votingPeriod,
            votingLegalRep,
            offchainVotePeriod,
            totalVotingPower,
            action,
            enableObserver
        );
        p.actionPayload = actionPayload;
        require(_votingController.onAddProposal(proposalId, msg.sender, token), "NF_VC_CTR_ADD_REJECTED");
    }

    function vote(bytes32 proposalId, bool voteInFavor)
        public
        withStateTransition(proposalId)
        withVotingOpen(proposalId)
    {

        VotingProposal.Proposal storage p = _proposals[proposalId];
        require(p.hasVoted[msg.sender] == VotingProposal.TriState.Abstain, "NF_VC_ALREADY_VOTED");
        castVote(p, proposalId, voteInFavor, msg.sender);
    }

    function addOffchainVote(bytes32 proposalId, uint256 inFavor, uint256 against, string documentUri)
        public
        withStateTransition(proposalId)
        onlyTally(proposalId)
    {

        VotingProposal.Proposal storage p = _proposals[proposalId];
        require(msg.sender == p.votingLegalRep, "NF_VC_ONLY_VOTING_LEGAL_REP");
        require(inFavor + against <= p.offchainVotingPower, "NF_VC_EXCEEDS_OFFLINE_V_POWER");
        require(inFavor + against > 0, "NF_VC_NO_OFF_EMPTY_VOTE");

        p.offchainInFavor = inFavor;
        p.offchainAgainst = against;
        p.offchainVoteDocumentUri = documentUri;

        emit LogOffChainProposalResult(proposalId, p.initiator, p.token, msg.sender, inFavor, against, documentUri);
    }

    function tally(bytes32 proposalId)
        public
        constant
        withTimedTransition(proposalId)
        returns(
            uint8 s,
            uint256 inFavor,
            uint256 against,
            uint256 offchainInFavor,
            uint256 offchainAgainst,
            uint256 tokenVotingPower,
            uint256 totalVotingPower,
            uint256 campaignQuorumTokenAmount,
            address initiator,
            bool hasObserverInterface
        )
    {

        VotingProposal.Proposal storage p = ensureExistingProposal(proposalId);

        s = uint8(p.state);
        inFavor = p.inFavor;
        against = p.against;
        offchainInFavor = p.offchainInFavor;
        offchainAgainst = p.offchainAgainst;
        initiator = p.initiator;
        hasObserverInterface = p.observing;
        tokenVotingPower = p.token.totalSupplyAt(p.snapshotId);
        totalVotingPower = tokenVotingPower + p.offchainVotingPower;
        campaignQuorumTokenAmount = p.campaignQuorumTokenAmount;
    }

    function offchainVoteDocumentUri(bytes32 proposalId)
        public
        constant
        returns (string)
    {

        VotingProposal.Proposal storage p = ensureExistingProposal(proposalId);
        return p.offchainVoteDocumentUri;
    }

    function timedProposal(bytes32 proposalId)
        public
        withTimedTransition(proposalId)
        constant
        returns (
            uint8 s,
            address token,
            uint256 snapshotId,
            address initiator,
            address votingLegalRep,
            uint256 campaignQuorumTokenAmount,
            uint256 offchainVotingPower,
            uint256 action,
            bytes actionPayload,
            bool enableObserver,
            uint32[5] deadlines
        )
    {

        VotingProposal.Proposal storage p = ensureExistingProposal(proposalId);

        s = uint8(p.state);
        token = p.token;
        snapshotId = p.snapshotId;
        enableObserver = p.observing;
        campaignQuorumTokenAmount = p.campaignQuorumTokenAmount;
        initiator = p.initiator;
        votingLegalRep = p.votingLegalRep;
        offchainVotingPower = p.offchainVotingPower;
        deadlines = p.deadlines;
        action = p.action;
        actionPayload = p.actionPayload;
    }

    function proposal(bytes32 proposalId)
        public
        constant
        returns (
            uint8 s,
            address token,
            uint256 snapshotId,
            address initiator,
            address votingLegalRep,
            uint256 campaignQuorumTokenAmount,
            uint256 offchainVotingPower,
            uint256 action,
            bytes actionPayload,
            bool enableObserver,
            uint32[5] deadlines
            )
    {

        VotingProposal.Proposal storage p = ensureExistingProposal(proposalId);

        s = uint8(p.state);
        token = p.token;
        snapshotId = p.snapshotId;
        enableObserver = p.observing;
        campaignQuorumTokenAmount = p.campaignQuorumTokenAmount;
        initiator = p.initiator;
        votingLegalRep = p.votingLegalRep;
        offchainVotingPower = p.offchainVotingPower;
        deadlines = p.deadlines;
        action = p.action;
        actionPayload = p.actionPayload;
    }

    function getVote(bytes32 proposalId, address voter)
        public
        constant
        returns (uint8)
    {

        VotingProposal.Proposal storage p = ensureExistingProposal(proposalId);
        return uint8(p.hasVoted[voter]);
    }

    function hasProposal(bytes32 proposalId)
        public
        constant
        returns (bool)
    {

        VotingProposal.Proposal storage p = _proposals[proposalId];
        return p.token != address(0);
    }

    function getVotingPower(bytes32 proposalId, address voter)
        public
        constant
        returns (uint256)
    {

        VotingProposal.Proposal storage p = ensureExistingProposal(proposalId);
        return p.token.balanceOfAt(voter, p.snapshotId);
    }


    function contractId()
        public
        pure
        returns (bytes32 id, uint256 version)
    {

        return (0xbbf540c4111754f6dbce914d5e55e1c0cb26515adbc288b5ea8baa544adfbfa4, 0);
    }


    function votingController()
        public
        constant
        returns (IVotingController)
    {

        return _votingController;
    }

    function changeVotingController(IVotingController newController)
        public
    {

        require(_votingController.onChangeVotingController(msg.sender, newController), "NF_VC_CHANGING_CTR_REJECTED");
        address oldController = address(_votingController);
        _votingController = newController;
        emit LogChangeVotingController(oldController, address(newController), msg.sender);
    }


    function relayedVote(
        bytes32 proposalId,
        bool voteInFavor,
        address voter,
        bytes32 r,
        bytes32 s,
        uint8 v
    )
        public
        withStateTransition(proposalId)
        withRelayingOpen(proposalId)
    {

        assert(isValidSignature(proposalId, voteInFavor, voter, r, s, v));
        VotingProposal.Proposal storage p = _proposals[proposalId];
        require(p.hasVoted[voter] == VotingProposal.TriState.Abstain, "NF_VC_ALREADY_VOTED");
        castVote(p, proposalId, voteInFavor, voter);
    }

    function batchRelayedVotes(
        bytes32 proposalId,
        bool[] votePreferences,
        bytes32[] r,
        bytes32[] s,
        uint8[] v
    )
        public
        withStateTransition(proposalId)
        withRelayingOpen(proposalId)
    {

        assert(
            votePreferences.length == r.length && r.length == s.length && s.length == v.length
        );
        relayBatchInternal(
            proposalId,
            votePreferences,
            r, s, v
        );
    }

    function handleStateTransitions(bytes32 proposalId)
        public
        withTimedTransition(proposalId)
    {}



    function isValidSignature(
        bytes32 proposalId,
        bool voteInFavor,
        address voter,
        bytes32 r,
        bytes32 s,
        uint8 v
    )
        public
        constant
        returns (bool)
    {

        return ecrecoverVoterAddress(proposalId, voteInFavor, r, s, v) == voter;
    }

    function ecrecoverVoterAddress(
        bytes32 proposalId,
        bool voteInFavor,
        bytes32 r,
        bytes32 s,
        uint8 v
    )
        public
        constant
        returns (address)
    {

        return ecrecover(
            keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(byte(0), address(this), proposalId, voteInFavor)))),
            v, r, s);
    }


    function ensureExistingProposal(bytes32 proposalId)
        internal
        constant
        returns (VotingProposal.Proposal storage p)
    {

        p = _proposals[proposalId];
        require(p.token != address(0), "NF_VC_PROP_NOT_EXIST");
        return p;
    }


    function castVote(VotingProposal.Proposal storage p, bytes32 proposalId, bool voteInFavor, address voter)
        private
    {

        uint256 power = p.token.balanceOfAt(voter, p.snapshotId);
        if (voteInFavor) {
            p.inFavor = Math.add(p.inFavor, power);
        } else {
            p.against = Math.add(p.against, power);
        }
        markVoteCast(p, proposalId, voter, voteInFavor, power);
    }

    function relayBatchInternal(
        bytes32 proposalId,
        bool[] votePreferences,
        bytes32[] r,
        bytes32[] s,
        uint8[] v
    )
        private
    {

        uint256 inFavor;
        uint256 against;
        VotingProposal.Proposal storage p = _proposals[proposalId];
        for (uint256 i = 0; i < votePreferences.length; i++) {
            uint256 power = relayBatchElement(
                p,
                proposalId,
                votePreferences[i],
                r[i], s[i], v[i]);
            if (votePreferences[i]) {
                inFavor = Math.add(inFavor, power);
            } else {
                against = Math.add(against, power);
            }
        }
        p.inFavor = Math.add(p.inFavor, inFavor);
        p.against = Math.add(p.against, against);
    }

    function relayBatchElement(
        VotingProposal.Proposal storage p,
        bytes32 proposalId,
        bool voteInFavor,
        bytes32 r,
        bytes32 s,
        uint8 v
    )
        private
        returns (uint256 power)
    {

        address voter = ecrecoverVoterAddress(
            proposalId,
            voteInFavor,
            r, s, v
        );
        if (p.hasVoted[voter] == VotingProposal.TriState.Abstain) {
            power = p.token.balanceOfAt(voter, p.snapshotId);
            markVoteCast(p, proposalId, voter, voteInFavor, power);
        }
    }

    function markVoteCast(VotingProposal.Proposal storage p, bytes32 proposalId, address voter, bool voteInFavor, uint256 power)
        private
    {

        if (power > 0) {
            p.hasVoted[voter] = voteInFavor ? VotingProposal.TriState.InFavor : VotingProposal.TriState.Against;
            emit LogVoteCast(proposalId, p.initiator, p.token, voter, voteInFavor, power);
        }
    }
}