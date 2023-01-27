


pragma solidity 0.6.12;


interface ICongressMembersRegistry {

    function isMember(address _address) external view returns (bool);

    function getMinimalQuorum() external view returns (uint256);

}



pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract TokensFarmCongress {

    string public constant name = "TokensFarmCongress";

    ICongressMembersRegistry membersRegistry;

    uint public proposalCount;

    struct Proposal {
        uint id;

        address proposer;

        address[] targets;

        uint[] values;

        string[] signatures;

        bytes[] calldatas;

        uint forVotes;

        uint againstVotes;

        bool canceled;

        bool executed;

        uint timestamp;

        mapping (address => Receipt) receipts;
    }

    struct Receipt {
        bool hasVoted;

        bool support;
    }

    mapping (uint => Proposal) public proposals;

    event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, string description);

    event VoteCast(address voter, uint proposalId, bool support);

    event ProposalCanceled(uint id);

    event ProposalExecuted(uint id);

    event ReceivedEther(address sender, uint amount);

    event ExecuteTransaction(address indexed target, uint value, string signature,  bytes data);

    modifier onlyMember {

        require(
            membersRegistry.isMember(msg.sender) == true,
            "Only TokensFarmCongress member can call this function"
        );
        _;
    }

    function setMembersRegistry(
        address _membersRegistry
    )
        external
    {

        require(
            address(membersRegistry) == address(0x0),
            "TokensFarmCongress:setMembersRegistry: membersRegistry is already set"
        );
        membersRegistry = ICongressMembersRegistry(_membersRegistry);
    }

    function propose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    )
        external
        onlyMember
        returns (uint)
    {

        require(
            targets.length == values.length &&
            targets.length == signatures.length &&
            targets.length == calldatas.length,
            "TokensFarmCongress::propose: proposal function information arity mismatch"
        );

        require(targets.length != 0, "TokensFarmCongress::propose: must provide actions");

        proposalCount++;

        Proposal memory newProposal = Proposal({
        id: proposalCount,
        proposer: msg.sender,
        targets: targets,
        values: values,
        signatures: signatures,
        calldatas: calldatas,
        forVotes: 0,
        againstVotes: 0,
        canceled: false,
        executed: false,
        timestamp: block.timestamp
        });

        proposals[newProposal.id] = newProposal;

        emit ProposalCreated(newProposal.id, msg.sender, targets, values, signatures, calldatas, description);
        return newProposal.id;
    }

    function castVote(
        uint proposalId,
        bool support
    )
        external
        onlyMember
    {

        return _castVote(msg.sender, proposalId, support);
    }

    function _castVote(
        address voter,
        uint proposalId,
        bool support
    )
        internal
    {

        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(!receipt.hasVoted, "TokensFarmCongress::_castVote: voter already voted");

        if (support) {
            proposal.forVotes = add256(proposal.forVotes, 1);
        } else {
            proposal.againstVotes = add256(proposal.againstVotes, 1);
        }

        receipt.hasVoted = true;
        receipt.support = support;

        emit VoteCast(voter, proposalId, support);
    }

    function execute(
        uint proposalId
    )
        external
        onlyMember
        payable
    {

        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed && !proposal.canceled, "Proposal was canceled or executed");
        proposal.executed = true;
        require(proposal.forVotes >= membersRegistry.getMinimalQuorum(), "Not enough votes in favor");

        for (uint i = 0; i < proposal.targets.length; i++) {
            bytes memory callData;

            if (bytes(proposal.signatures[i]).length == 0) {
                callData = proposal.calldatas[i];
            } else {
                callData = abi.encodePacked(
                    bytes4(keccak256(bytes(proposal.signatures[i]))),
                    proposal.calldatas[i]
                );
            }

            (bool success,) = proposal.targets[i].call{value:proposal.values[i]}(callData);

            require(
                success,
                "TokensFarmCongress::executeTransaction: Transaction execution reverted."
            );

            emit ExecuteTransaction(
                proposal.targets[i],
                proposal.values[i],
                proposal.signatures[i],
                proposal.calldatas[i]
            );
        }

        emit ProposalExecuted(proposalId);
    }

    function cancel(
        uint proposalId
    )
        external
        onlyMember
    {

        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed && !proposal.canceled, "TokensFarmCongress:cancel: Proposal already executed or canceled");
        require(block.timestamp >= proposal.timestamp + 259200, "TokensFarmCongress:cancel: Time lock hasn't ended yet");
        require(proposal.forVotes < membersRegistry.getMinimalQuorum(), "TokensFarmCongress:cancel: Proposal already reached quorum");
        proposal.canceled = true;
        emit ProposalCanceled(proposalId);
    }

    function getActions(
        uint proposalId
    )
        external
        view
        returns (
            address[] memory targets,
            uint[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas
        )
    {

        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

    function getMembersRegistry()
        external
        view
        returns (address)
    {

        return address(membersRegistry);
    }

    function add256(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint)
    {

        uint c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    receive()
        external
        payable
    {
        emit ReceivedEther(msg.sender, msg.value);
    }
}