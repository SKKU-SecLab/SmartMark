
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}


contract ForTubeGovernorEvents {

    event ProposalCreated(uint id, address proposer, bytes[] executables, uint startBlock, uint endBlock, string description);

    event VoteCast(address indexed voter, uint proposalId, uint8 support, uint votes);

    event ProposalCanceled(uint id);

    event ProposalExecuted(uint id);

    event ProposalThresholdSet(uint oldProposalThreshold, uint newProposalThreshold);

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);
}

contract ForTubeGovernorStorage {

    address public admin;

    address public pendingAdmin;

    uint public minVotingDelay; // 5760, About 24 Hours, 1 block = 15s for production

    uint public minVotingPeriod;// 5760, About 24 hours，1 block == 15s

    uint public proposalThreshold;

    uint public proposalCount;

    IFdao public fdao;

    mapping (uint => Proposal) public proposals;

    mapping (address => uint) public latestProposalIds;

    struct Proposal {
        uint id;

        address proposer;

        bytes[] executables;

        uint startBlock;

        uint endBlock;

        uint[] votes; // votes[x] is current number of votes to x in this proposal

        bool canceled;

        bool executed;

        mapping (address => Receipt) receipts;

        uint winning;
        uint options;// option count
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
        Failed,
        Succeeded,
        Executed
    }
}

interface IFdao {

    function getPriorVotes(address account, uint blockNumber) external view returns (uint96);

}


contract ForTubeGovernor is Initializable, ForTubeGovernorStorage, ForTubeGovernorEvents {

    string public constant name = "ForTube Governor";

    uint public constant MIN_PROPOSAL_THRESHOLD = 76000e18; // 76,000 FDAO


    uint public constant MAX_VOTING_PERIOD = 80640; // About 2 weeks


    uint public constant MAX_VOTING_DELAY = 40320; // About 1 week

    uint public constant quorumVotes = 400000e18; // 400,000 FDAO

    uint public constant proposalMaxOperations = 100; // 100 actions, for update so many ftokens

    function initialize(address admin_, address fdao_, uint minVotingPeriod_, uint minVotingDelay_, uint proposalThreshold_) external initializer {

        require(admin_ != address(0), "ForTubeGovernor::initialize: invalid admin address");
        require(fdao_ != address(0), "ForTubeGovernor::initialize: invalid FDAO address");
        minVotingPeriod = minVotingPeriod_; // init to 5760 (24H) in prod
        minVotingDelay = minVotingDelay_; // init to 5760 (24H) in prod
        require(minVotingDelay_ <= MAX_VOTING_DELAY, "ForTubeGovernor::propose: invalid voting delay");
        require(proposalThreshold_ >= MIN_PROPOSAL_THRESHOLD, "ForTubeGovernor::initialize: invalid proposal threshold");

        fdao = IFdao(fdao_);
        proposalThreshold = proposalThreshold_;

        admin = admin_;
    }

    function propose(bytes[] memory executables, string memory description, uint options, uint256 startBlock, uint256 votingPeriod) public returns (uint) {

        require(options >= 2, "invalid options");
        require(startBlock > block.number + minVotingDelay && startBlock <= block.number + MAX_VOTING_DELAY, "invalid block number");
        require(executables.length == options, "ForTubeGovernor::propose: executables != options");
        require(votingPeriod >= minVotingPeriod && votingPeriod <= MAX_VOTING_PERIOD, "ForTubeGovernor::propose: invalid voting period");

        require(fdao.getPriorVotes(msg.sender, sub256(block.number, 1)) >= proposalThreshold, "ForTubeGovernor::propose: proposer votes below proposal threshold");
        for (uint i = 0; i < options; i++) {
            (, address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, ) = abi.decode(executables[i], (uint[], address[], uint[], string[], bytes[], string));

            require(targets.length == values.length && targets.length == signatures.length && targets.length == calldatas.length, "ForTubeGovernor::propose: proposal function information arity mismatch");
            require(targets.length <= proposalMaxOperations, "ForTubeGovernor::propose: too many actions");
        }

        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
          ProposalState proposersLatestProposalState = state(latestProposalId);
          require(proposersLatestProposalState != ProposalState.Active, "ForTubeGovernor::propose: one live proposal per proposer, found an already active proposal");
          require(proposersLatestProposalState != ProposalState.Pending, "ForTubeGovernor::propose: one live proposal per proposer, found an already pending proposal");
        }

        uint endBlock = add256(startBlock, votingPeriod);

        uint[] memory _votes = new uint[](options);
        proposalCount++;
        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            executables: executables,
            startBlock: startBlock,
            endBlock: endBlock,
            votes: _votes,
            canceled: false,
            executed: false,
            winning: uint(-1), // invalid option, 0 is valid, so use -1 as invalid.
            options: options
        });

        proposals[newProposal.id] = newProposal;
        latestProposalIds[newProposal.proposer] = newProposal.id;

        emit ProposalCreated(newProposal.id, msg.sender, executables, startBlock, endBlock, description);
        return newProposal.id;
    }

    function execute(uint proposalId) external payable {

        require(msg.sender == admin, "ForTubeGovernor::execute: Call must come from admin.");
        require(state(proposalId) == ProposalState.Succeeded, "ForTubeGovernor::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;

        require(proposal.winning != uint(-1), "!winning");

        emit ProposalExecuted(proposalId);
    }

    function cancel(uint proposalId) external {

        require(state(proposalId) != ProposalState.Executed && state(proposalId) != ProposalState.Canceled, "ForTubeGovernor::cancel: cannot cancel executed or canceled proposal");

        Proposal storage proposal = proposals[proposalId];

        if(msg.sender != proposal.proposer) {
            require(fdao.getPriorVotes(proposal.proposer, sub256(block.number, 1)) < proposalThreshold, "ForTubeGovernor::cancel: proposer above threshold");
        }

        proposal.canceled = true;

        emit ProposalCanceled(proposalId);
    }

    function getActions(uint proposalId, uint option) external view returns (uint[] memory chain_ids, address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory descriptions) {

        Proposal storage p = proposals[proposalId];
        require(option < p.executables.length, "option out of range");
        (chain_ids, targets, values, signatures, calldatas, descriptions) = abi.decode(p.executables[option], (uint[], address[], uint[], string[], bytes[], string));
    }

    function getExecutables(uint proposalId) external view returns (bytes[] memory executeables) {

        Proposal storage p = proposals[proposalId];
        return p.executables;
    }

    function getExecutablesAt(uint proposalId, uint index) external view returns (bytes memory executeables) {

        Proposal storage p = proposals[proposalId];
        require(index < p.executables.length, "index out of range");
        return p.executables[index];
    }

    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory) {

        return proposals[proposalId].receipts[voter];
    }

    function state(uint proposalId) public view returns (ProposalState) {

        require(proposalCount >= proposalId, "ForTubeGovernor::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.winning == uint(-1) || proposal.votes[proposal.winning] < quorumVotes) {
            return ProposalState.Failed;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else {
            return ProposalState.Succeeded;
        }
    }

    function castVote(uint proposalId, uint8 support) external {

        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support));
    }

    function castVoteInternal(address voter, uint proposalId, uint8 support) internal returns (uint96) {

        require(state(proposalId) == ProposalState.Active, "ForTubeGovernor::castVoteInternal: voting is closed");
        require(support < proposals[proposalId].options, "ForTubeGovernor::castVoteInternal: invalid vote type");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "ForTubeGovernor::castVoteInternal: voter already voted");
        uint96 votes = fdao.getPriorVotes(voter, proposal.startBlock);

        proposal.votes[support] = add256(proposal.votes[support], votes);

        uint _max = proposal.winning == uint(-1) ? 0 : proposal.votes[proposal.winning];
        if (proposal.votes[support] > _max) {
            proposal.winning = support;
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        return votes;
    }

    function _setProposalThreshold(uint newProposalThreshold) external {

        require(msg.sender == admin, "ForTubeGovernor::_setProposalThreshold: admin only");
        require(newProposalThreshold >= MIN_PROPOSAL_THRESHOLD, "ForTubeGovernor::_setProposalThreshold: invalid proposal threshold");
        uint oldProposalThreshold = proposalThreshold;
        proposalThreshold = newProposalThreshold;

        emit ProposalThresholdSet(oldProposalThreshold, proposalThreshold);
    }

    function _setPendingAdmin(address newPendingAdmin) external {

        require(msg.sender == admin, "ForTubeGovernor:_setPendingAdmin: admin only");

        address oldPendingAdmin = pendingAdmin;

        pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function _acceptAdmin() external {

        require(msg.sender == pendingAdmin && msg.sender != address(0), "ForTubeGovernor:_acceptAdmin: pending admin only");

        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        admin = pendingAdmin;

        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
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
}