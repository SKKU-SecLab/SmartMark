

pragma solidity 0.5.17;


library CappedMath {

    uint constant private UINT_MAX = 2**256 - 1;

    function addCap(uint _a, uint _b) internal pure returns (uint) {

        uint c = _a + _b;
        return c >= _a ? c : UINT_MAX;
    }

    function subCap(uint _a, uint _b) internal pure returns (uint) {

        if (_b > _a)
            return 0;
        else
            return _a - _b;
    }

    function mulCap(uint _a, uint _b) internal pure returns (uint) {

        if (_a == 0)
            return 0;

        uint c = _a * _b;
        return c / _a == _b ? c : UINT_MAX;
    }
}




library CappedMath128 {

    uint128 private constant UINT128_MAX = 2**128 - 1;

    function addCap(uint128 _a, uint128 _b) internal pure returns (uint128) {

        uint128 c = _a + _b;
        return c >= _a ? c : UINT128_MAX;
    }

    function subCap(uint128 _a, uint128 _b) internal pure returns (uint128) {

        if (_b > _a) return 0;
        else return _a - _b;
    }

    function mulCap(uint128 _a, uint128 _b) internal pure returns (uint128) {

        if (_a == 0) return 0;

        uint128 c = _a * _b;
        return c / _a == _b ? c : UINT128_MAX;
    }
}

 


interface IArbitrable {


    event Ruling(IArbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    function rule(uint _disputeID, uint _ruling) external;

}




interface IArbitrator {


    enum DisputeStatus {Waiting, Appealable, Solved}

    event DisputeCreation(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    event AppealPossible(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    event AppealDecision(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    function createDispute(uint _choices, bytes calldata _extraData) external payable returns(uint disputeID);


    function arbitrationCost(bytes calldata _extraData) external view returns(uint cost);


    function appeal(uint _disputeID, bytes calldata _extraData) external payable;


    function appealCost(uint _disputeID, bytes calldata _extraData) external view returns(uint cost);


    function appealPeriod(uint _disputeID) external view returns(uint start, uint end);


    function disputeStatus(uint _disputeID) external view returns(DisputeStatus status);


    function currentRuling(uint _disputeID) external view returns(uint ruling);


}


interface IEvidence {


    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    event Evidence(IArbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    event Dispute(IArbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

}




contract LightGeneralizedTCR is IArbitrable, IEvidence {

    using CappedMath for uint256;
    using CappedMath128 for uint128;


    enum Status {
        Absent, // The item is not in the registry.
        Registered, // The item is in the registry.
        RegistrationRequested, // The item has a request to be added to the registry.
        ClearingRequested // The item has a request to be removed from the registry.
    }

    enum Party {
        None, // Party per default when there is no challenger or requester. Also used for unconclusive ruling.
        Requester, // Party that made the request to change a status.
        Challenger // Party that challenges the request to change a status.
    }

    enum RequestType {
        Registration, // Identifies a request to register an item to the registry.
        Clearing // Identifies a request to remove an item from the registry.
    }

    enum DisputeStatus {
        None, // No dispute was created.
        AwaitingRuling, // Dispute was created, but the final ruling was not given yet.
        Resolved // Dispute was ruled.
    }


    struct Item {
        Status status; // The current status of the item.
        uint128 sumDeposit; // The total deposit made by the requester and the challenger (if any).
        uint120 requestCount; // The number of requests.
        mapping(uint256 => Request) requests; // List of status change requests made for the item in the form requests[requestID].
    }

    struct Request {
        RequestType requestType;
        uint64 submissionTime; // Time when the request was made. Used to track when the challenge period ends.
        uint24 arbitrationParamsIndex; // The index for the arbitration params for the request.
        address payable requester; // Address of the requester.
        address payable challenger; // Address of the challenger, if any.
    }

    struct DisputeData {
        uint256 disputeID; // The ID of the dispute on the arbitrator.
        DisputeStatus status; // The current status of the dispute.
        Party ruling; // The ruling given to a dispute. Only set after it has been resolved.
        uint240 roundCount; // The number of rounds.
        mapping(uint256 => Round) rounds; // Data of the different dispute rounds. rounds[roundId].
    }

    struct Round {
        Party sideFunded; // Stores the side that successfully paid the appeal fees in the latest round. Note that if both sides have paid a new round is created.
        uint256 feeRewards; // Sum of reimbursable fees and stake rewards available to the parties that made contributions to the side that ultimately wins a dispute.
        uint256[3] amountPaid; // Tracks the sum paid for each Party in this round.
        mapping(address => uint256[3]) contributions; // Maps contributors to their contributions for each side in the form contributions[address][party].
    }

    struct ArbitrationParams {
        IArbitrator arbitrator; // The arbitrator trusted to solve disputes for this request.
        bytes arbitratorExtraData; // The extra data for the trusted arbitrator of this request.
    }


    uint256 public constant RULING_OPTIONS = 2; // The amount of non 0 choices the arbitrator can give.
    uint256 private constant RESERVED_ROUND_ID = 0; // For compatibility with GeneralizedTCR consider the request/challenge cycle the first round (index 0).


    bool private initialized;

    address public relayerContract; // The contract that is used to add or remove items directly to speed up the interchain communication.
    address public governor; // The address that can make changes to the parameters of the contract.

    uint256 public submissionBaseDeposit; // The base deposit to submit an item.
    uint256 public removalBaseDeposit; // The base deposit to remove an item.
    uint256 public submissionChallengeBaseDeposit; // The base deposit to challenge a submission.
    uint256 public removalChallengeBaseDeposit; // The base deposit to challenge a removal request.
    uint256 public challengePeriodDuration; // The time after which a request becomes executable if not challenged.

    uint256 public winnerStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that won the previous round.
    uint256 public loserStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that lost the previous round.
    uint256 public sharedStakeMultiplier; // Multiplier for calculating the fee stake that must be paid in the case where arbitrator refused to arbitrate.
    uint256 public constant MULTIPLIER_DIVISOR = 10000; // Divisor parameter for multipliers.

    mapping(bytes32 => Item) public items; // Maps the item ID to its data in the form items[_itemID].
    mapping(address => mapping(uint256 => bytes32)) public arbitratorDisputeIDToItemID; // Maps a dispute ID to the ID of the item with the disputed request in the form arbitratorDisputeIDToItemID[arbitrator][disputeID].
    mapping(bytes32 => mapping(uint256 => DisputeData)) public requestsDisputeData; // Maps an item and a request to the data of the dispute related to them. requestsDisputeData[itemID][requestIndex]
    ArbitrationParams[] public arbitrationParamsChanges;


    modifier onlyGovernor() {

        require(msg.sender == governor, "The caller must be the governor.");
        _;
    }

    modifier onlyRelayer() {

        require(msg.sender == relayerContract, "The caller must be the relay.");
        _;
    }


    event ItemStatusChange(bytes32 indexed _itemID, bool _updatedDirectly);

    event NewItem(bytes32 indexed _itemID, string _data, bool _addedDirectly);

    event RequestSubmitted(bytes32 indexed _itemID, uint256 _evidenceGroupID);

    event Contribution(
        bytes32 indexed _itemID,
        uint256 _requestID,
        uint256 _roundID,
        address indexed _contributor,
        uint256 _contribution,
        Party _side
    );

    event ConnectedTCRSet(address indexed _connectedTCR);

    event RewardWithdrawn(
        address indexed _beneficiary,
        bytes32 indexed _itemID,
        uint256 _request,
        uint256 _round,
        uint256 _reward
    );

    function initialize(
        IArbitrator _arbitrator,
        bytes calldata _arbitratorExtraData,
        address _connectedTCR,
        string calldata _registrationMetaEvidence,
        string calldata _clearingMetaEvidence,
        address _governor,
        uint256[4] calldata _baseDeposits,
        uint256 _challengePeriodDuration,
        uint256[3] calldata _stakeMultipliers,
        address _relayerContract
    ) external {

        require(!initialized, "Already initialized.");

        emit ConnectedTCRSet(_connectedTCR);

        governor = _governor;
        submissionBaseDeposit = _baseDeposits[0];
        removalBaseDeposit = _baseDeposits[1];
        submissionChallengeBaseDeposit = _baseDeposits[2];
        removalChallengeBaseDeposit = _baseDeposits[3];
        challengePeriodDuration = _challengePeriodDuration;
        sharedStakeMultiplier = _stakeMultipliers[0];
        winnerStakeMultiplier = _stakeMultipliers[1];
        loserStakeMultiplier = _stakeMultipliers[2];
        relayerContract = _relayerContract;

        _doChangeArbitrationParams(_arbitrator, _arbitratorExtraData, _registrationMetaEvidence, _clearingMetaEvidence);

        initialized = true;
    }



    function addItemDirectly(string calldata _item) external onlyRelayer {

        bytes32 itemID = keccak256(abi.encodePacked(_item));
        Item storage item = items[itemID];
        require(item.status == Status.Absent, "Item must be absent to be added.");

        if (item.requestCount == 0) {
            emit NewItem(itemID, _item, true);
        }

        item.status = Status.Registered;

        emit ItemStatusChange(itemID, true);
    }

    function removeItemDirectly(bytes32 _itemID) external onlyRelayer {

        Item storage item = items[_itemID];
        require(item.status == Status.Registered, "Item must be registered to be removed.");

        item.status = Status.Absent;

        emit ItemStatusChange(_itemID, true);
    }

    function addItem(string calldata _item) external payable {

        bytes32 itemID = keccak256(abi.encodePacked(_item));
        Item storage item = items[itemID];

        require(item.requestCount < uint120(-1), "Too many requests for item.");
        require(item.status == Status.Absent, "Item must be absent to be added.");

        if (item.requestCount == 0) {
            emit NewItem(itemID, _item, false);
        }

        Request storage request = item.requests[item.requestCount++];
        uint256 arbitrationParamsIndex = arbitrationParamsChanges.length - 1;
        IArbitrator arbitrator = arbitrationParamsChanges[arbitrationParamsIndex].arbitrator;
        bytes storage arbitratorExtraData = arbitrationParamsChanges[arbitrationParamsIndex].arbitratorExtraData;

        uint256 arbitrationCost = arbitrator.arbitrationCost(arbitratorExtraData);
        uint256 totalCost = arbitrationCost.addCap(submissionBaseDeposit);
        require(msg.value >= totalCost, "You must fully fund the request.");

        item.sumDeposit = uint128(totalCost);
        item.status = Status.RegistrationRequested;

        request.requestType = RequestType.Registration;
        request.submissionTime = uint64(block.timestamp);
        request.arbitrationParamsIndex = uint24(arbitrationParamsIndex);
        request.requester = msg.sender;

        emit RequestSubmitted(itemID, getEvidenceGroupID(itemID, item.requestCount - 1));

        emit Contribution(itemID, item.requestCount - 1, RESERVED_ROUND_ID, msg.sender, totalCost, Party.Requester);

        if (msg.value > totalCost) {
            msg.sender.send(msg.value - totalCost);
        }
    }

    function removeItem(bytes32 _itemID, string calldata _evidence) external payable {

        Item storage item = items[_itemID];

        require(item.requestCount < uint120(-1), "Too many requests for item.");
        require(item.status == Status.Registered, "Item must be registered to be removed.");

        Request storage request = item.requests[item.requestCount++];
        uint256 arbitrationParamsIndex = arbitrationParamsChanges.length - 1;
        IArbitrator arbitrator = arbitrationParamsChanges[arbitrationParamsIndex].arbitrator;
        bytes storage arbitratorExtraData = arbitrationParamsChanges[arbitrationParamsIndex].arbitratorExtraData;

        uint256 arbitrationCost = arbitrator.arbitrationCost(arbitratorExtraData);
        uint256 totalCost = arbitrationCost.addCap(removalBaseDeposit);
        require(msg.value >= totalCost, "You must fully fund the request.");

        item.sumDeposit = uint128(totalCost);
        item.status = Status.ClearingRequested;

        request.submissionTime = uint64(block.timestamp);
        request.arbitrationParamsIndex = uint24(arbitrationParamsIndex);
        request.requester = msg.sender;
        request.requestType = RequestType.Clearing;

        uint256 evidenceGroupID = getEvidenceGroupID(_itemID, item.requestCount - 1);

        emit RequestSubmitted(_itemID, evidenceGroupID);

        emit Contribution(_itemID, item.requestCount - 1, RESERVED_ROUND_ID, msg.sender, totalCost, Party.Requester);

        if (bytes(_evidence).length > 0) {
            emit Evidence(arbitrator, evidenceGroupID, msg.sender, _evidence);
        }

        if (msg.value > totalCost) {
            msg.sender.send(msg.value - totalCost);
        }
    }

    function challengeRequest(bytes32 _itemID, string calldata _evidence) external payable {

        Item storage item = items[_itemID];
        require(item.status > Status.Registered, "The item must have a pending request.");

        uint256 lastRequestIndex = item.requestCount - 1;
        Request storage request = item.requests[lastRequestIndex];
        require(
            block.timestamp - request.submissionTime <= challengePeriodDuration,
            "Challenges must occur during the challenge period."
        );

        DisputeData storage disputeData = requestsDisputeData[_itemID][lastRequestIndex];
        require(disputeData.status == DisputeStatus.None, "The request should not have already been disputed.");

        ArbitrationParams storage arbitrationParams = arbitrationParamsChanges[request.arbitrationParamsIndex];
        IArbitrator arbitrator = arbitrationParams.arbitrator;

        uint256 arbitrationCost = arbitrator.arbitrationCost(arbitrationParams.arbitratorExtraData);
        uint256 totalCost;
        {
            uint256 challengerBaseDeposit = item.status == Status.RegistrationRequested
                ? submissionChallengeBaseDeposit
                : removalChallengeBaseDeposit;
            totalCost = arbitrationCost.addCap(challengerBaseDeposit);
        }
        require(msg.value >= totalCost, "You must fully fund the challenge.");

        emit Contribution(_itemID, lastRequestIndex, RESERVED_ROUND_ID, msg.sender, totalCost, Party.Challenger);

        item.sumDeposit = item.sumDeposit.addCap(uint128(totalCost)).subCap(uint128(arbitrationCost));

        request.challenger = msg.sender;

        disputeData.disputeID = arbitrator.createDispute.value(arbitrationCost)(
            RULING_OPTIONS,
            arbitrationParams.arbitratorExtraData
        );
        disputeData.status = DisputeStatus.AwaitingRuling;
        disputeData.roundCount = 2;

        arbitratorDisputeIDToItemID[address(arbitrator)][disputeData.disputeID] = _itemID;

        uint256 metaEvidenceID = 2 * request.arbitrationParamsIndex + uint256(request.requestType);
        uint256 evidenceGroupID = getEvidenceGroupID(_itemID, lastRequestIndex);
        emit Dispute(arbitrator, disputeData.disputeID, metaEvidenceID, evidenceGroupID);

        if (bytes(_evidence).length > 0) {
            emit Evidence(arbitrator, evidenceGroupID, msg.sender, _evidence);
        }

        if (msg.value > totalCost) {
            msg.sender.send(msg.value - totalCost);
        }
    }

    function fundAppeal(bytes32 _itemID, Party _side) external payable {

        require(_side > Party.None, "Invalid side.");

        Item storage item = items[_itemID];
        require(item.status > Status.Registered, "The item must have a pending request.");

        uint256 lastRequestIndex = item.requestCount - 1;
        Request storage request = item.requests[lastRequestIndex];

        DisputeData storage disputeData = requestsDisputeData[_itemID][lastRequestIndex];
        require(
            disputeData.status == DisputeStatus.AwaitingRuling,
            "A dispute must have been raised to fund an appeal."
        );

        ArbitrationParams storage arbitrationParams = arbitrationParamsChanges[request.arbitrationParamsIndex];
        IArbitrator arbitrator = arbitrationParams.arbitrator;

        uint256 lastRoundIndex = disputeData.roundCount - 1;
        Round storage round = disputeData.rounds[lastRoundIndex];
        require(round.sideFunded != _side, "Side already fully funded.");

        uint256 multiplier;
        {
            (uint256 appealPeriodStart, uint256 appealPeriodEnd) = arbitrator.appealPeriod(disputeData.disputeID);
            require(
                block.timestamp >= appealPeriodStart && block.timestamp < appealPeriodEnd,
                "Contributions must be made within the appeal period."
            );

            Party winner = Party(arbitrator.currentRuling(disputeData.disputeID));
            if (winner == Party.None) {
                multiplier = sharedStakeMultiplier;
            } else if (_side == winner) {
                multiplier = winnerStakeMultiplier;
            } else {
                multiplier = loserStakeMultiplier;
                require(
                    block.timestamp < (appealPeriodStart + appealPeriodEnd) / 2,
                    "The loser must contribute during the first half of the appeal period."
                );
            }
        }

        uint256 appealCost = arbitrator.appealCost(disputeData.disputeID, arbitrationParams.arbitratorExtraData);
        uint256 totalCost = appealCost.addCap(appealCost.mulCap(multiplier) / MULTIPLIER_DIVISOR);
        contribute(_itemID, lastRequestIndex, lastRoundIndex, uint256(_side), msg.sender, msg.value, totalCost);

        if (round.amountPaid[uint256(_side)] >= totalCost) {
            if (round.sideFunded == Party.None) {
                round.sideFunded = _side;
            } else {
                round.sideFunded = Party.None;

                arbitrator.appeal.value(appealCost)(disputeData.disputeID, arbitrationParams.arbitratorExtraData);
                disputeData.roundCount++;
                round.feeRewards = round.feeRewards.subCap(appealCost);
            }
        }
    }

    function withdrawFeesAndRewards(
        address payable _beneficiary,
        bytes32 _itemID,
        uint256 _requestID,
        uint256 _roundID
    ) external {

        DisputeData storage disputeData = requestsDisputeData[_itemID][_requestID];

        require(disputeData.status == DisputeStatus.Resolved, "Request must be resolved.");

        Round storage round = disputeData.rounds[_roundID];

        uint256 reward;
        if (_roundID == disputeData.roundCount - 1) {
            reward =
                round.contributions[_beneficiary][uint256(Party.Requester)] +
                round.contributions[_beneficiary][uint256(Party.Challenger)];
        } else if (disputeData.ruling == Party.None) {
            uint256 totalFeesInRound = round.amountPaid[uint256(Party.Challenger)] +
                round.amountPaid[uint256(Party.Requester)];
            uint256 claimableFees = round.contributions[_beneficiary][uint256(Party.Challenger)] +
                round.contributions[_beneficiary][uint256(Party.Requester)];
            reward = totalFeesInRound > 0 ? (claimableFees * round.feeRewards) / totalFeesInRound : 0;
        } else {
            reward = round.amountPaid[uint256(disputeData.ruling)] > 0
                ? (round.contributions[_beneficiary][uint256(disputeData.ruling)] * round.feeRewards) /
                    round.amountPaid[uint256(disputeData.ruling)]
                : 0;
        }
        round.contributions[_beneficiary][uint256(Party.Requester)] = 0;
        round.contributions[_beneficiary][uint256(Party.Challenger)] = 0;

        if (reward > 0) {
            _beneficiary.send(reward);
            emit RewardWithdrawn(_beneficiary, _itemID, _requestID, _roundID, reward);
        }
    }

    function executeRequest(bytes32 _itemID) external {

        Item storage item = items[_itemID];
        uint256 lastRequestIndex = items[_itemID].requestCount - 1;

        Request storage request = item.requests[lastRequestIndex];
        require(
            block.timestamp - request.submissionTime > challengePeriodDuration,
            "Time to challenge the request must pass."
        );

        DisputeData storage disputeData = requestsDisputeData[_itemID][lastRequestIndex];
        require(disputeData.status == DisputeStatus.None, "The request should not be disputed.");

        if (item.status == Status.RegistrationRequested) {
            item.status = Status.Registered;
        } else if (item.status == Status.ClearingRequested) {
            item.status = Status.Absent;
        } else {
            revert("There must be a request.");
        }

        emit ItemStatusChange(_itemID, false);

        uint256 sumDeposit = item.sumDeposit;
        item.sumDeposit = 0;

        if (sumDeposit > 0) {
            request.requester.send(sumDeposit);
        }
    }

    function rule(uint256 _disputeID, uint256 _ruling) external {

        require(_ruling <= RULING_OPTIONS, "Invalid ruling option");

        bytes32 itemID = arbitratorDisputeIDToItemID[msg.sender][_disputeID];
        Item storage item = items[itemID];
        uint256 lastRequestIndex = items[itemID].requestCount - 1;
        Request storage request = item.requests[lastRequestIndex];

        DisputeData storage disputeData = requestsDisputeData[itemID][lastRequestIndex];
        require(disputeData.status == DisputeStatus.AwaitingRuling, "The request must not be resolved.");

        ArbitrationParams storage arbitrationParams = arbitrationParamsChanges[request.arbitrationParamsIndex];
        require(address(arbitrationParams.arbitrator) == msg.sender, "Only the arbitrator can give a ruling");

        uint256 finalRuling;
        Round storage round = disputeData.rounds[disputeData.roundCount - 1];

        if (round.sideFunded == Party.Requester) {
            finalRuling = uint256(Party.Requester);
        } else if (round.sideFunded == Party.Challenger) {
            finalRuling = uint256(Party.Challenger);
        } else {
            finalRuling = _ruling;
        }

        emit Ruling(IArbitrator(msg.sender), _disputeID, finalRuling);

        Party winner = Party(finalRuling);

        disputeData.status = DisputeStatus.Resolved;
        disputeData.ruling = winner;

        uint256 sumDeposit = item.sumDeposit;
        item.sumDeposit = 0;

        if (winner == Party.None) {
            item.status = item.status == Status.RegistrationRequested ? Status.Absent : Status.Registered;

            uint256 halfSumDeposit = sumDeposit / 2;

            request.requester.send(halfSumDeposit);
            request.challenger.send(halfSumDeposit);
        } else if (winner == Party.Requester) {
            item.status = item.status == Status.RegistrationRequested ? Status.Registered : Status.Absent;

            request.requester.send(sumDeposit);
        } else {
            item.status = item.status == Status.RegistrationRequested ? Status.Absent : Status.Registered;

            request.challenger.send(sumDeposit);
        }

        emit ItemStatusChange(itemID, false);
    }

    function submitEvidence(bytes32 _itemID, string calldata _evidence) external {

        Item storage item = items[_itemID];
        uint256 lastRequestIndex = item.requestCount - 1;

        Request storage request = item.requests[lastRequestIndex];
        ArbitrationParams storage arbitrationParams = arbitrationParamsChanges[request.arbitrationParamsIndex];

        emit Evidence(
            arbitrationParams.arbitrator,
            getEvidenceGroupID(_itemID, lastRequestIndex),
            msg.sender,
            _evidence
        );
    }


    function changeChallengePeriodDuration(uint256 _challengePeriodDuration) external onlyGovernor {

        challengePeriodDuration = _challengePeriodDuration;
    }

    function changeSubmissionBaseDeposit(uint256 _submissionBaseDeposit) external onlyGovernor {

        submissionBaseDeposit = _submissionBaseDeposit;
    }

    function changeRemovalBaseDeposit(uint256 _removalBaseDeposit) external onlyGovernor {

        removalBaseDeposit = _removalBaseDeposit;
    }

    function changeSubmissionChallengeBaseDeposit(uint256 _submissionChallengeBaseDeposit) external onlyGovernor {

        submissionChallengeBaseDeposit = _submissionChallengeBaseDeposit;
    }

    function changeRemovalChallengeBaseDeposit(uint256 _removalChallengeBaseDeposit) external onlyGovernor {

        removalChallengeBaseDeposit = _removalChallengeBaseDeposit;
    }

    function changeGovernor(address _governor) external onlyGovernor {

        governor = _governor;
    }

    function changeSharedStakeMultiplier(uint256 _sharedStakeMultiplier) external onlyGovernor {

        sharedStakeMultiplier = _sharedStakeMultiplier;
    }

    function changeWinnerStakeMultiplier(uint256 _winnerStakeMultiplier) external onlyGovernor {

        winnerStakeMultiplier = _winnerStakeMultiplier;
    }

    function changeLoserStakeMultiplier(uint256 _loserStakeMultiplier) external onlyGovernor {

        loserStakeMultiplier = _loserStakeMultiplier;
    }

    function changeConnectedTCR(address _connectedTCR) external onlyGovernor {

        emit ConnectedTCRSet(_connectedTCR);
    }

    function changeRelayerContract(address _relayerContract) external onlyGovernor {

        relayerContract = _relayerContract;
    }

    function changeArbitrationParams(
        IArbitrator _arbitrator,
        bytes calldata _arbitratorExtraData,
        string calldata _registrationMetaEvidence,
        string calldata _clearingMetaEvidence
    ) external onlyGovernor {

        _doChangeArbitrationParams(_arbitrator, _arbitratorExtraData, _registrationMetaEvidence, _clearingMetaEvidence);
    }


    function _doChangeArbitrationParams(
        IArbitrator _arbitrator,
        bytes memory _arbitratorExtraData,
        string memory _registrationMetaEvidence,
        string memory _clearingMetaEvidence
    ) internal {

        emit MetaEvidence(2 * arbitrationParamsChanges.length, _registrationMetaEvidence);
        emit MetaEvidence(2 * arbitrationParamsChanges.length + 1, _clearingMetaEvidence);

        arbitrationParamsChanges.push(
            ArbitrationParams({arbitrator: _arbitrator, arbitratorExtraData: _arbitratorExtraData})
        );
    }

    function contribute(
        bytes32 _itemID,
        uint256 _requestID,
        uint256 _roundID,
        uint256 _side,
        address payable _contributor,
        uint256 _amount,
        uint256 _totalRequired
    ) internal {

        Round storage round = requestsDisputeData[_itemID][_requestID].rounds[_roundID];
        uint256 pendingAmount = _totalRequired.subCap(round.amountPaid[_side]);

        uint256 contribution; // Amount contributed.
        uint256 remainingETH; // Remaining ETH to send back.
        if (pendingAmount > _amount) {
            contribution = _amount;
        } else {
            contribution = pendingAmount;
            remainingETH = _amount - pendingAmount;
        }

        round.contributions[_contributor][_side] += contribution;
        round.amountPaid[_side] += contribution;
        round.feeRewards += contribution;

        if (remainingETH > 0) {
            _contributor.send(remainingETH);
        }

        if (contribution > 0) {
            emit Contribution(_itemID, _requestID, _roundID, msg.sender, contribution, Party(_side));
        }
    }


    function getEvidenceGroupID(bytes32 _itemID, uint256 _requestID) public pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked(_itemID, _requestID)));
    }

    function arbitrator() external view returns (IArbitrator) {

        return arbitrationParamsChanges[arbitrationParamsChanges.length - 1].arbitrator;
    }

    function arbitratorExtraData() external view returns (bytes memory) {

        return arbitrationParamsChanges[arbitrationParamsChanges.length - 1].arbitratorExtraData;
    }

    function metaEvidenceUpdates() external view returns (uint256) {

        return arbitrationParamsChanges.length;
    }

    function getContributions(
        bytes32 _itemID,
        uint256 _requestID,
        uint256 _roundID,
        address _contributor
    ) external view returns (uint256[3] memory contributions) {

        DisputeData storage disputeData = requestsDisputeData[_itemID][_requestID];
        Round storage round = disputeData.rounds[_roundID];
        contributions = round.contributions[_contributor];
    }

    function getItemInfo(bytes32 _itemID)
        external
        view
        returns (
            Status status,
            uint256 numberOfRequests,
            uint256 sumDeposit
        )
    {

        Item storage item = items[_itemID];
        return (item.status, item.requestCount, item.sumDeposit);
    }

    function getRequestInfo(bytes32 _itemID, uint256 _requestID)
        external
        view
        returns (
            bool disputed,
            uint256 disputeID,
            uint256 submissionTime,
            bool resolved,
            address payable[3] memory parties,
            uint256 numberOfRounds,
            Party ruling,
            IArbitrator requestArbitrator,
            bytes memory requestArbitratorExtraData,
            uint256 metaEvidenceID
        )
    {

        Item storage item = items[_itemID];
        require(item.requestCount > _requestID, "Request does not exist.");

        Request storage request = items[_itemID].requests[_requestID];

        submissionTime = request.submissionTime;
        parties[uint256(Party.Requester)] = request.requester;
        parties[uint256(Party.Challenger)] = request.challenger;

        (disputed, disputeID, numberOfRounds, ruling) = getRequestDisputeData(_itemID, _requestID);

        (requestArbitrator, requestArbitratorExtraData, metaEvidenceID) = getRequestArbitrationParams(
            _itemID,
            _requestID
        );
        resolved = getRequestResolvedStatus(_itemID, _requestID);
    }

    function getRequestDisputeData(bytes32 _itemID, uint256 _requestID)
        internal
        view
        returns (
            bool disputed,
            uint256 disputeID,
            uint256 numberOfRounds,
            Party ruling
        )
    {

        DisputeData storage disputeData = requestsDisputeData[_itemID][_requestID];

        return (
            disputeData.status >= DisputeStatus.AwaitingRuling,
            disputeData.disputeID,
            disputeData.roundCount,
            disputeData.ruling
        );
    }

    function getRequestArbitrationParams(bytes32 _itemID, uint256 _requestID)
        internal
        view
        returns (
            IArbitrator arbitrator,
            bytes memory arbitratorExtraData,
            uint256 metaEvidenceID
        )
    {

        Request storage request = items[_itemID].requests[_requestID];
        ArbitrationParams storage arbitrationParams = arbitrationParamsChanges[request.arbitrationParamsIndex];

        return (
            arbitrationParams.arbitrator,
            arbitrationParams.arbitratorExtraData,
            2 * request.arbitrationParamsIndex + uint256(request.requestType)
        );
    }

    function getRequestResolvedStatus(bytes32 _itemID, uint256 _requestID) internal view returns (bool resolved) {

        Item storage item = items[_itemID];

        if (item.requestCount == 0) {
            return false;
        }

        if (_requestID < item.requestCount - 1) {
            return true;
        }

        return item.sumDeposit == 0;
    }

    function getRoundInfo(
        bytes32 _itemID,
        uint256 _requestID,
        uint256 _roundID
    )
        external
        view
        returns (
            bool appealed,
            uint256[3] memory amountPaid,
            bool[3] memory hasPaid,
            uint256 feeRewards
        )
    {

        Item storage item = items[_itemID];
        require(item.requestCount > _requestID, "Request does not exist.");

        DisputeData storage disputeData = requestsDisputeData[_itemID][_requestID];
        require(disputeData.roundCount > _roundID, "Round does not exist");

        Round storage round = disputeData.rounds[_roundID];
        appealed = _roundID < disputeData.roundCount - 1;

        hasPaid[uint256(Party.Requester)] = appealed || round.sideFunded == Party.Requester;
        hasPaid[uint256(Party.Challenger)] = appealed || round.sideFunded == Party.Challenger;

        return (appealed, round.amountPaid, hasPaid, round.feeRewards);
    }
}



contract LightGTCRFactory {

    event NewGTCR(LightGeneralizedTCR indexed _address);

    LightGeneralizedTCR[] public instances;
    address public GTCR;

    constructor(address _GTCR) public {
        GTCR = _GTCR;
    }

    function deploy(
        IArbitrator _arbitrator,
        bytes memory _arbitratorExtraData,
        address _connectedTCR,
        string memory _registrationMetaEvidence,
        string memory _clearingMetaEvidence,
        address _governor,
        uint256[4] memory _baseDeposits,
        uint256 _challengePeriodDuration,
        uint256[3] memory _stakeMultipliers,
        address _relayContract
    ) public {

        LightGeneralizedTCR instance = clone(GTCR);
        instance.initialize(
            _arbitrator,
            _arbitratorExtraData,
            _connectedTCR,
            _registrationMetaEvidence,
            _clearingMetaEvidence,
            _governor,
            _baseDeposits,
            _challengePeriodDuration,
            _stakeMultipliers,
            _relayContract
        );
        instances.push(instance);
        emit NewGTCR(instance);
    }

    function clone(address _implementation) internal returns (LightGeneralizedTCR instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, _implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != LightGeneralizedTCR(0), "ERC1167: create failed");
    }

    function count() external view returns (uint256) {

        return instances.length;
    }
}