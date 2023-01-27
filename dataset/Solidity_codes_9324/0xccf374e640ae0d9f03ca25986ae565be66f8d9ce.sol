
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;




interface IUni {

    function delegate(address delegatee) external;

    function balanceOf(address account) external view returns (uint);

    function transfer(address dst, uint rawAmount) external returns (bool);

    function transferFrom(address src, address dst, uint rawAmount) external returns (bool);

}

interface IGovernorAlpha {

    function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) external returns (uint);

    function castVote(uint proposalId, bool support) external;

}

contract AutonomousSway {

    bool public immutable sway = false;
    
    address payable public immutable author;

    address[] public targets;
    uint[] public values;
    string[] public signatures;
    bytes[] public calldatas;
    string public description;

    address public immutable uni;
    address public immutable governor;

    uint public swayProposalId;
    bool public terminated;

    event CrowdProposalProposed(address indexed proposal, address indexed author, uint proposalId);
    event CrowdProposalTerminated(address indexed proposal, address indexed author);
    event CrowdProposalVoted(address indexed proposal, uint proposalId);

    constructor(address payable author_,
                address[] memory targets_,
                uint[] memory values_,
                string[] memory signatures_,
                bytes[] memory calldatas_,
                string memory description_,
                address uni_,
	        address governor_) {
                    author = author_;

                    targets = targets_;
                    values = values_;
                    signatures = signatures_;
                    calldatas = calldatas_;
                    description = description_;
		    governor = governor_;

                    uni = uni_;

                    terminated = false;

                    IUni(uni_).delegate(address(this));
                }

                function propose() external returns (uint) {

                    require(swayProposalId == 0, 'CrowdProposal::propose: gov proposal already exists');
                    require(!terminated, 'CrowdProposal::propose: proposal has been terminated');

                    swayProposalId = IGovernorAlpha(governor).propose(targets, values, signatures, calldatas, description);

                    emit CrowdProposalProposed(address(this), author, swayProposalId);
                    return swayProposalId;
                }

                function terminate() external {

                    require(msg.sender == author, 'CrowdProposal::terminate: only author can terminate');
                    require(!terminated, 'CrowdProposal::terminate: proposal has been already terminated');

                    terminated = true;

                    IUni(uni).transfer(author, IUni(uni).balanceOf(address(this)));

                    emit CrowdProposalTerminated(address(this), author);
                }

                function vote(uint proposal_id) external returns (bool) {

                    IGovernorAlpha(governor).castVote(proposal_id, sway);

                    emit CrowdProposalVoted(address(this), proposal_id);
                    return (true);
                }
}

contract AutonomousSwayFactory {

    address public immutable uni;
    address public immutable sway;
    uint public immutable uniStakeAmount;

    event CrowdProposalCreated(address indexed proposal, address indexed author, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, string description);

    constructor(address uni_,
                address sway_,
                uint uniStakeAmount_) {
                    uni = uni_;
                    uniStakeAmount = uniStakeAmount_;
		    sway = sway_;
                }


                function createCrowdProposal(address[] memory targets,
                                             uint[] memory values,
                                             string[] memory signatures,
                                             bytes[] memory calldatas,
                                             string memory description) external {

                                                 
                                                 AutonomousSway proposal = new AutonomousSway(msg.sender, targets, values, signatures, calldatas, description, uni, sway);

                                                 emit CrowdProposalCreated(address(proposal), msg.sender, targets, values, signatures, calldatas, description);

                                                 IUni(uni).transferFrom(msg.sender, address(proposal), uniStakeAmount);
                                             }
}