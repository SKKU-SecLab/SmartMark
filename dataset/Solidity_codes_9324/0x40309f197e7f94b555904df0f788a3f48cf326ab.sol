pragma solidity ^0.8.3;

interface IVotingVault {

    function queryVotePower(
        address user,
        uint256 blockNumber,
        bytes calldata extraData
    ) external returns (uint256);

}// Apache-2.0
pragma solidity >=0.7.0;

contract Authorizable {


    address public owner;
    mapping(address => bool) public authorized;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Sender not owner");
        _;
    }

    modifier onlyAuthorized() {

        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    function isAuthorized(address who) public view returns (bool) {

        return authorized[who];
    }

    function authorize(address who) external onlyOwner() {

        _authorize(who);
    }

    function deauthorize(address who) external onlyOwner() {

        authorized[who] = false;
    }

    function setOwner(address who) public onlyOwner() {

        owner = who;
    }

    function _authorize(address who) internal {

        authorized[who] = true;
    }
}// Apache-2.0
pragma solidity ^0.8.3;

contract ReentrancyBlock {

    bool private _entered;
    modifier nonReentrant() {

        require(!_entered, "Reentrancy");
        _entered = true;
        _;
        _entered = false;
    }
}// Apache-2.0
pragma solidity ^0.8.3;

interface ICoreVoting {

    function approvedVaults(address vault) external view returns (bool);

}// Apache-2.0
pragma solidity ^0.8.3;


contract CoreVoting is Authorizable, ReentrancyBlock, ICoreVoting {

    uint256 public baseQuorum;

    uint256 public constant DAY_IN_BLOCKS = 6496;

    uint256 public lockDuration = DAY_IN_BLOCKS * 3;

    uint256 public extraVoteTime = DAY_IN_BLOCKS * 5;

    uint256 public minProposalPower;

    uint256 public proposalCount;

    mapping(address => mapping(bytes4 => uint256)) private _quorums;

    function quorums(address target, bytes4 functionSelector)
        public
        view
        returns (uint256)
    {

        uint256 storedQuorum = _quorums[target][functionSelector];

        if (storedQuorum == 0) {
            return baseQuorum;
        } else {
            return storedQuorum;
        }
    }

    mapping(address => bool) public override approvedVaults;

    mapping(uint256 => Proposal) public proposals;

    mapping(address => mapping(uint256 => Vote)) public votes;

    enum Ballot { YES, NO, MAYBE }

    struct Proposal {
        bytes32 proposalHash;
        uint128 created;
        uint128 unlock;
        uint128 expiration;
        uint128 quorum;
        uint128[3] votingPower;
        uint128 lastCall;
    }

    struct Vote {
        uint128 votingPower;
        Ballot castBallot;
    }

    event ProposalCreated(
        uint256 proposalId,
        uint256 created,
        uint256 execution,
        uint256 expiration
    );

    event ProposalExecuted(uint256 proposalId);

    event Voted(address indexed voter, uint256 indexed proposalId, Vote vote);

    constructor(
        address _timelock,
        uint256 _baseQuorum,
        uint256 _minProposalPower,
        address _gsc,
        address[] memory votingVaults
    ) Authorizable() {
        baseQuorum = _baseQuorum;
        minProposalPower = _minProposalPower;
        for (uint256 i = 0; i < votingVaults.length; i++) {
            approvedVaults[votingVaults[i]] = true;
        }
        setOwner(address(_timelock));
        _authorize(_gsc);
    }

    function proposal(
        address[] calldata votingVaults,
        bytes[] calldata extraVaultData,
        address[] calldata targets,
        bytes[] calldata calldatas,
        uint256 lastCall,
        Ballot ballot
    ) external {

        require(targets.length == calldatas.length, "array length mismatch");
        require(targets.length != 0, "empty proposal");

        bytes32 proposalHash = keccak256(abi.encode(targets, calldatas));

        uint256 quorum;
        for (uint256 i = 0; i < targets.length; i++) {
            bytes4 selector = _getSelector(calldatas[i]);
            uint256 unitQuorum = _quorums[targets[i]][selector];

            unitQuorum = unitQuorum == 0 ? baseQuorum : unitQuorum;
            if (unitQuorum > quorum) {
                quorum = unitQuorum;
            }
        }

        require(
            lastCall > block.number + lockDuration + extraVoteTime,
            "expires before voting ends"
        );

        proposals[proposalCount] = Proposal(
            proposalHash,
            uint128(block.number - 1),
            uint128(block.number + lockDuration),
            uint128(block.number + lockDuration + extraVoteTime),
            uint128(quorum),
            proposals[proposalCount].votingPower,
            uint128(lastCall)
        );

        uint256 votingPower =
            vote(votingVaults, extraVaultData, proposalCount, ballot);

        uint256 minPower =
            quorum <= minProposalPower ? quorum : minProposalPower;
        if (!isAuthorized(msg.sender)) {
            require(votingPower >= minPower, "insufficient voting power");
        }

        emit ProposalCreated(
            proposalCount,
            block.number,
            block.number + lockDuration,
            block.number + lockDuration + extraVoteTime
        );

        proposalCount += 1;
    }

    function vote(
        address[] memory votingVaults,
        bytes[] memory extraVaultData,
        uint256 proposalId,
        Ballot ballot
    ) public returns (uint256) {

        require(proposals[proposalId].created != 0, "proposal does not exist");
        require(block.number <= proposals[proposalId].expiration, "Expired");

        uint128 votingPower;

        for (uint256 i = 0; i < votingVaults.length; i++) {
            for (uint256 j = i + 1; j < votingVaults.length; j++) {
                require(votingVaults[i] != votingVaults[j], "duplicate vault");
            }
            require(approvedVaults[votingVaults[i]], "unverified vault");
            votingPower += uint128(
                IVotingVault(votingVaults[i]).queryVotePower(
                    msg.sender,
                    proposals[proposalId].created,
                    extraVaultData[i]
                )
            );
        }

        if (votes[msg.sender][proposalId].votingPower > 0) {
            proposals[proposalId].votingPower[
                uint256(votes[msg.sender][proposalId].castBallot)
            ] -= votes[msg.sender][proposalId].votingPower;
        }
        votes[msg.sender][proposalId] = Vote(votingPower, ballot);

        proposals[proposalId].votingPower[uint256(ballot)] += votingPower;

        emit Voted(msg.sender, proposalId, votes[msg.sender][proposalId]);

        return votingPower;
    }

    function execute(
        uint256 proposalId,
        address[] memory targets,
        bytes[] memory calldatas
    ) external nonReentrant {

        require(block.number >= proposals[proposalId].unlock, "not unlocked");
        require(proposals[proposalId].unlock != 0, "Previously executed");
        require(
            block.number < proposals[proposalId].lastCall,
            "past last call timestamp"
        );

        require(
            keccak256(abi.encode(targets, calldatas)) ==
                proposals[proposalId].proposalHash,
            "hash mismatch"
        );

        uint128[3] memory results = proposals[proposalId].votingPower;
        bool passesQuorum =
            results[0] + results[1] + results[2] >=
                proposals[proposalId].quorum;
        bool majorityInFavor = results[0] > results[1];

        require(passesQuorum && majorityInFavor, "Cannot execute");

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, ) = targets[i].call(calldatas[i]);
            require(success, "Call failed");
        }
        emit ProposalExecuted(proposalId);

        delete proposals[proposalId];
    }

    function getProposalVotingPower(uint256 proposalId)
        external
        view
        returns (uint128[3] memory)
    {

        return proposals[proposalId].votingPower;
    }

    function setCustomQuorum(
        address target,
        bytes4 selector,
        uint256 quorum
    ) external onlyOwner {

        _quorums[target][selector] = quorum;
    }

    function changeVaultStatus(address vault, bool isValid) external onlyOwner {

        approvedVaults[vault] = isValid;
    }

    function setDefaultQuorum(uint256 quorum) external onlyOwner {

        baseQuorum = quorum;
    }

    function setMinProposalPower(uint256 _minProposalPower) external onlyOwner {

        minProposalPower = _minProposalPower;
    }

    function setLockDuration(uint256 _lockDuration) external onlyOwner {

        lockDuration = _lockDuration;
    }

    function changeExtraVotingTime(uint256 _extraVoteTime) external onlyOwner {

        extraVoteTime = _extraVoteTime;
    }

    function _getSelector(bytes memory _calldata)
        internal
        pure
        returns (bytes4 out)
    {

        assembly {
            out := and(
                mload(add(_calldata, 32)),
                0xFFFFFFFFF0000000000000000000000000000000000000000000000000000000
            )
        }
    }
}