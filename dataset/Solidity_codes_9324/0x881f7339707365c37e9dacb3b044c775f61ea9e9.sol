
pragma solidity 0.8.6;

interface IENS {

    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setRecord(
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external;


    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;


    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address owner
    ) external returns (bytes32);


    function setResolver(bytes32 node, address resolver) external;


    function setOwner(bytes32 node, address owner) external;


    function setTTL(bytes32 node, uint64 ttl) external;


    function setApprovalForAll(address operator, bool approved) external;


    function owner(bytes32 node) external view returns (address);


    function resolver(bytes32 node) external view returns (address);


    function ttl(bytes32 node) external view returns (uint64);


    function recordExists(bytes32 node) external view returns (bool);


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

}




contract Ownable {

    address public owner;
    address private nextOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    modifier onlyOwner() {

        require(isOwner(), "caller is not the owner.");
        _;
    }

    modifier onlyNextOwner() {

        require(isNextOwner(), "current owner must set caller as next owner.");
        _;
    }

    constructor(address owner_) {
        owner = owner_;
        emit OwnershipTransferred(address(0), owner);
    }

    function transferOwnership(address nextOwner_) external onlyOwner {

        require(nextOwner_ != address(0), "Next owner is the zero address.");

        nextOwner = nextOwner_;
    }

    function cancelOwnershipTransfer() external onlyOwner {

        delete nextOwner;
    }

    function acceptOwnership() external onlyNextOwner {

        delete nextOwner;

        owner = msg.sender;

        emit OwnershipTransferred(owner, msg.sender);
    }

    function renounceOwnership() external onlyOwner {

        owner = address(0);

        emit OwnershipTransferred(owner, address(0));
    }

    function isOwner() public view returns (bool) {

        return msg.sender == owner;
    }

    function isNextOwner() public view returns (bool) {

        return msg.sender == nextOwner;
    }
}




interface IGovernable {

    function changeGovernor(address governor_) external;


    function isGovernor() external view returns (bool);


    function governor() external view returns (address);

}





contract Governable is Ownable, IGovernable {


    address public override governor;


    modifier onlyGovernance() {

        require(isOwner() || isGovernor(), "caller is not governance");
        _;
    }

    modifier onlyGovernor() {

        require(isGovernor(), "caller is not governor");
        _;
    }


    constructor(address owner_) Ownable(owner_) {}


    function changeGovernor(address governor_) public override onlyGovernance {

        governor = governor_;
    }


    function isGovernor() public view override returns (bool) {

        return msg.sender == governor;
    }
}




interface IDistributionLogic {

    function version() external returns (uint256);


    function distribute(address tributary, uint256 contribution) external;


    function claim(address claimant) external;


    function claimable(address claimant) external view returns (uint256);


    function increaseAwards(address member, uint256 amount) external;

}




interface IDistributionStorage {

    function registered(address claimant) external view returns (uint256);

}




interface IMirrorTokenLogic is IGovernable {

    function version() external returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function mint(address to, uint256 amount) external;


    function setTreasuryConfig(address newTreasuryConfig) external;

}




interface IMirrorTokenStorage {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

}




interface IMirrorTreasury {

    function transferFunds(address payable to, uint256 value) external;


    function transferERC20(
        address token,
        address to,
        uint256 value
    ) external;


    function contributeWithTributary(address tributary) external payable;


    function contribute(uint256 amount) external payable;

}









contract MirrorGovernorV1 is Governable {

    bytes32 immutable rootNode;
    IENS public immutable ensRegistry;


    uint256 public proposalCount;
    uint256 public surveyCount;
    uint256 public constant proposalMaxOperations = 10;
    uint256 public minProposalDuration = 5760;
    uint256 public minSurveyDuration = 5760;
    mapping(address => uint256) public latestProposalIds;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => Survey) public surveys;
    address distributionModel;
    address token;
    address treasury;
    uint256 votingReward = 15;


    enum ProposalState {
        Canceled,
        Active,
        Decided,
        Executed,
        Pending
    }

    enum SurveyState {
        Active,
        Decided
    }

    struct Call {
        address target;
        uint96 value;
        bytes data;
    }


    struct Proposal {
        Call call;
        uint256 id;
        address proposer;
        bool canceled;
        bool executed;
        uint256 startBlock;
        uint256 endBlock;
    }

    struct Survey {
        uint256 id;
        address creator;
        uint256 startBlock;
        uint256 endBlock;
    }

    mapping(uint256 => mapping(address => bool)) votedOnSurvey;
    mapping(uint256 => mapping(address => bool)) votedOnProposal;


    event ProposalCreated(uint256 id, address proposer, string description);
    event VoteCast(
        string label,
        address indexed voter,
        uint256 indexed proposalId,
        bool shouldExecute
    );
    event ProposalExecuted(uint256 id);
    event ProposalCanceled(uint256 id);

    event SurveyCreated(
        uint256 id,
        address creator,
        string description,
        uint256 duration
    );
    event SurveyResponse(
        uint256 indexed surveyId,
        string label,
        address indexed voter,
        string content
    );


    event ChangeDistributionModel(address oldModel, address newModel);
    event ChangeToken(address oldToken, address newToken);
    event ChangeTreasury(address oldTreasury, address newTreasury);
    event ChangeVotingReward(uint256 oldReward, uint256 newReward);


    constructor(
        address owner_,
        bytes32 rootNode_,
        address ensRegistry_,
        address token_,
        address distributionModel_
    ) Governable(owner_) {
        rootNode = rootNode_;
        ensRegistry = IENS(ensRegistry_);
        distributionModel = distributionModel_;
        token = token_;
    }


    function changeDistributionModel(address distributionModel_)
        public
        onlyGovernance
    {

        emit ChangeDistributionModel(distributionModel, distributionModel_);
        distributionModel = distributionModel_;
    }

    function changeToken(address token_) public onlyGovernance {

        emit ChangeToken(token, token_);
        token = token_;
    }

    function changeTreasury(address treasury_) public onlyGovernance {

        emit ChangeTreasury(treasury, treasury_);
        treasury = treasury_;
    }

    function changeVotingReward(uint256 votingReward_) public onlyGovernance {

        emit ChangeVotingReward(votingReward, votingReward_);
        votingReward = votingReward_;
    }

    function changeProposalDuration(uint256 newProposalDuration)
        public
        onlyGovernance
    {

        minProposalDuration = newProposalDuration;
    }

    function changeSurveyDuration(uint256 newSurveyDuration)
        public
        onlyGovernance
    {

        minSurveyDuration = newSurveyDuration;
    }


    function createSurvey(
        string memory description,
        uint256 duration,
        string calldata creatorLabel
    ) public returns (uint256) {

        require(
            isMirrorDAO(creatorLabel, msg.sender),
            "must be registered to create"
        );
        require(duration >= minSurveyDuration, "survey duration is too short");

        surveyCount++;
        Survey memory newSurvey = Survey({
            id: surveyCount,
            creator: msg.sender,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        surveys[newSurvey.id] = newSurvey;

        emit SurveyCreated(newSurvey.id, msg.sender, description, duration);
        return newSurvey.id;
    }

    function respond(
        uint256 surveyId,
        string calldata label,
        string calldata voteContent
    ) external {

        require(isMirrorDAO(label, msg.sender), "needs to be a member");
        require(
            surveyState(surveyId) == SurveyState.Active,
            "survey must be active"
        );
        require(!votedOnSurvey[surveyId][msg.sender], "already voted");

        votedOnSurvey[surveyId][msg.sender] = true;
        emit SurveyResponse(surveyId, label, msg.sender, voteContent);
        _applyReward();
    }


    function assertSenderCanPropose(string calldata proposerLabel)
        internal
        view
    {

        require(
            isMirrorDAO(proposerLabel, msg.sender),
            "must be registered to create"
        );

        uint256 latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
            ProposalState proposersLatestProposalState = proposalState(
                latestProposalId
            );
            require(
                proposersLatestProposalState != ProposalState.Active,
                "one live proposal per proposer, found an already active proposal"
            );
            require(
                proposersLatestProposalState != ProposalState.Pending,
                "one live proposal per proposer, found an already pending proposal"
            );
        }
    }

    function initProposal(
        Proposal memory newProposal,
        string memory description
    ) internal returns (uint256) {

        proposalCount++;
        proposals[newProposal.id] = newProposal;
        latestProposalIds[newProposal.proposer] = newProposal.id;

        emit ProposalCreated(newProposal.id, msg.sender, description);
        return newProposal.id;
    }

    function propose(
        Call calldata call,
        string memory description,
        uint256 duration,
        string calldata proposerLabel
    ) public returns (uint256) {

        assertSenderCanPropose(proposerLabel);
        require(
            duration >= minProposalDuration,
            "proposal duration is too short"
        );

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            call: call,
            canceled: false,
            executed: false,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        return initProposal(newProposal, description);
    }

    function createMintProposal(
        address receiver,
        uint256 amount,
        string calldata description,
        uint256 duration,
        string calldata proposerLabel
    ) public {

        assertSenderCanPropose(proposerLabel);

        bytes memory data = abi.encodeWithSelector(
            IMirrorTokenLogic(token).mint.selector,
            receiver,
            amount
        );

        Call memory call = Call({target: token, value: 0, data: data});

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            call: call,
            canceled: false,
            executed: false,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        initProposal(newProposal, description);
    }

    function createETHTransferProposal(
        address payable receiver,
        uint256 amount,
        string calldata description,
        uint256 duration,
        string calldata proposerLabel
    ) public {

        assertSenderCanPropose(proposerLabel);

        bytes memory data = abi.encodeWithSelector(
            IMirrorTreasury(treasury).transferFunds.selector,
            receiver,
            amount
        );

        Call memory call = Call({target: treasury, value: 0, data: data});

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            call: call,
            canceled: false,
            executed: false,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        initProposal(newProposal, description);
    }

    function createERC20TransferProposal(
        address erc20Token,
        address receiver,
        uint256 amount,
        string calldata description,
        uint256 duration,
        string calldata proposerLabel
    ) public {

        assertSenderCanPropose(proposerLabel);

        bytes memory data = abi.encodeWithSelector(
            IMirrorTreasury(treasury).transferERC20.selector,
            erc20Token,
            receiver,
            amount
        );

        Call memory call = Call({target: treasury, value: 0, data: data});

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            call: call,
            canceled: false,
            executed: false,
            startBlock: block.number,
            endBlock: block.number + duration
        });

        initProposal(newProposal, description);
    }

    function castVote(
        string calldata label,
        uint256 proposalId,
        bool shouldExecute
    ) external {

        require(isMirrorDAO(label, msg.sender), "needs to be a member");
        require(
            proposalState(proposalId) == ProposalState.Active,
            "proposal must be active"
        );
        require(!votedOnProposal[proposalId][msg.sender], "already voted");

        votedOnProposal[proposalId][msg.sender] = true;
        emit VoteCast(label, msg.sender, proposalId, shouldExecute);
        _applyReward();
    }


    function votingPower(address voter) public view returns (uint256) {

        if (IDistributionStorage(distributionModel).registered(voter) == 0) {
            return 0;
        }

        uint256 balance = IMirrorTokenStorage(token).balanceOf(voter);
        uint256 claimable = IDistributionLogic(distributionModel).claimable(
            voter
        );

        return balance + claimable;
    }


    function executeProposal(uint256 proposalId) external payable onlyOwner {

        Proposal storage proposal = proposals[proposalId];
        require(
            proposalState(proposalId) == ProposalState.Decided,
            "proposal undecided"
        );
        proposal.executed = true;
        _executeTransaction(proposal.call);
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint256 proposalId) external {

        require(
            proposalState(proposalId) != ProposalState.Executed,
            "cancel: cannot cancel executed proposal"
        );

        Proposal storage proposal = proposals[proposalId];

        require(
            msg.sender == proposal.proposer || msg.sender == owner,
            "only proposer or gov owner can cancel"
        );

        proposal.canceled = true;

        emit ProposalCanceled(proposalId);
    }


    function isMirrorDAO(string calldata label, address claimant)
        public
        view
        returns (bool mirrorDAO)
    {

        bytes32 labelNode = keccak256(abi.encodePacked(label));
        bytes32 node = keccak256(abi.encodePacked(rootNode, labelNode));

        mirrorDAO = claimant == ensRegistry.owner(node);
    }

    function proposalState(uint256 proposalId)
        public
        view
        returns (ProposalState)
    {

        require(proposalCount >= proposalId, "invalid proposal id");
        Proposal storage proposal = proposals[proposalId];

        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else {
            return ProposalState.Decided;
        }
    }

    function surveyState(uint256 surveyId) public view returns (SurveyState) {

        require(surveyCount >= surveyId && surveyId > 0, "invalid survey id");

        if (block.number <= surveys[surveyId].endBlock) {
            return SurveyState.Active;
        } else {
            return SurveyState.Decided;
        }
    }


    function _executeTransaction(Call memory call) internal {

        (bool ok, ) = call.target.call{value: uint256(call.value)}(call.data);

        require(ok, "execute transaction failed");
    }

    function _applyReward() internal {

        IDistributionLogic(distributionModel).increaseAwards(
            msg.sender,
            votingReward
        );
    }
}