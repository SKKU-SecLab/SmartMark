

pragma solidity ^0.5;


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



pragma solidity ^0.5.16;



contract GeneralizedTCR is IArbitrable, IEvidence {

    using CappedMath for uint;


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


    struct Item {
        bytes data; // The data describing the item.
        Status status; // The current status of the item.
        Request[] requests; // List of status change requests made for the item in the form requests[requestID].
    }

    struct Request {
        bool disputed; // True if a dispute was raised.
        uint disputeID; // ID of the dispute, if any.
        uint submissionTime; // Time when the request was made. Used to track when the challenge period ends.
        bool resolved; // True if the request was executed and/or any raised disputes were resolved.
        address payable[3] parties; // Address of requester and challenger, if any, in the form parties[party].
        Round[] rounds; // Tracks each round of a dispute in the form rounds[roundID].
        Party ruling; // The final ruling given, if any.
        IArbitrator arbitrator; // The arbitrator trusted to solve disputes for this request.
        bytes arbitratorExtraData; // The extra data for the trusted arbitrator of this request.
        uint metaEvidenceID; // The meta evidence to be used in a dispute for this case.
    }

    struct Round {
        uint[3] amountPaid; // Tracks the sum paid for each Party in this round. Includes arbitration fees, fee stakes and deposits.
        bool[3] hasPaid; // True if the Party has fully paid its fee in this round.
        uint feeRewards; // Sum of reimbursable fees and stake rewards available to the parties that made contributions to the side that ultimately wins a dispute.
        mapping(address => uint[3]) contributions; // Maps contributors to their contributions for each side in the form contributions[address][party].
    }


    IArbitrator public arbitrator; // The arbitrator contract.
    bytes public arbitratorExtraData; // Extra data for the arbitrator contract.

    uint RULING_OPTIONS = 2; // The amount of non 0 choices the arbitrator can give.

    address public governor; // The address that can make changes to the parameters of the contract.
    uint public submissionBaseDeposit; // The base deposit to submit an item.
    uint public removalBaseDeposit; // The base deposit to remove an item.
    uint public submissionChallengeBaseDeposit; // The base deposit to challenge a submission.
    uint public removalChallengeBaseDeposit; // The base deposit to challenge a removal request.
    uint public challengePeriodDuration; // The time after which a request becomes executable if not challenged.
    uint public metaEvidenceUpdates; // The number of times the meta evidence has been updated. Used to track the latest meta evidence ID.

    uint public winnerStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that won the previous round.
    uint public loserStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that lost the previous round.
    uint public sharedStakeMultiplier; // Multiplier for calculating the fee stake that must be paid in the case where arbitrator refused to arbitrate.
    uint public constant MULTIPLIER_DIVISOR = 10000; // Divisor parameter for multipliers.

    bytes32[] public itemList; // List of IDs of all submitted items.
    mapping(bytes32 => Item) public items; // Maps the item ID to its data in the form items[_itemID].
    mapping(address => mapping(uint => bytes32)) public arbitratorDisputeIDToItem;  // Maps a dispute ID to the ID of the item with the disputed request in the form arbitratorDisputeIDToItem[arbitrator][disputeID].
    mapping(bytes32 => uint) public itemIDtoIndex; // Maps an item's ID to its position in the list in the form itemIDtoIndex[itemID].


    modifier onlyGovernor {require(msg.sender == governor, "The caller must be the governor."); _;}



    event ItemStatusChange(
      bytes32 indexed _itemID,
      uint indexed _requestIndex,
      uint indexed _roundIndex,
      bool _disputed,
      bool _resolved
    );

    event ItemSubmitted(
      bytes32 indexed _itemID,
      address indexed _submitter,
      uint indexed _evidenceGroupID,
      bytes _data
    );

    event RequestSubmitted(
      bytes32 indexed _itemID,
      uint indexed _requestIndex,
      Status indexed _requestType
    );

    event RequestEvidenceGroupID(
      bytes32 indexed _itemID,
      uint indexed _requestIndex,
      uint indexed _evidenceGroupID
    );

    event AppealContribution(
        bytes32 indexed _itemID,
        address indexed _contributor,
        uint indexed _request,
        uint _round,
        uint _amount,
        Party _side
    );

    event HasPaidAppealFee(
      bytes32 indexed _itemID,
      uint indexed _request,
      uint indexed _round,
      Party _side
    );

    event ConnectedTCRSet(address indexed _connectedTCR);

    constructor(
        IArbitrator _arbitrator,
        bytes memory _arbitratorExtraData,
        address _connectedTCR,
        string memory _registrationMetaEvidence,
        string memory _clearingMetaEvidence,
        address _governor,
        uint _submissionBaseDeposit,
        uint _removalBaseDeposit,
        uint _submissionChallengeBaseDeposit,
        uint _removalChallengeBaseDeposit,
        uint _challengePeriodDuration,
        uint[3] memory _stakeMultipliers
    ) public {
        emit MetaEvidence(0, _registrationMetaEvidence);
        emit MetaEvidence(1, _clearingMetaEvidence);
        emit ConnectedTCRSet(_connectedTCR);

        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
        governor = _governor;
        submissionBaseDeposit = _submissionBaseDeposit;
        removalBaseDeposit = _removalBaseDeposit;
        submissionChallengeBaseDeposit = _submissionChallengeBaseDeposit;
        removalChallengeBaseDeposit = _removalChallengeBaseDeposit;
        challengePeriodDuration = _challengePeriodDuration;
        sharedStakeMultiplier = _stakeMultipliers[0];
        winnerStakeMultiplier = _stakeMultipliers[1];
        loserStakeMultiplier = _stakeMultipliers[2];
    }



    function addItem(bytes calldata _item) external payable {

        bytes32 itemID = keccak256(_item);
        require(items[itemID].status == Status.Absent, "Item must be absent to be added.");
        requestStatusChange(_item, submissionBaseDeposit);
    }

    function removeItem(bytes32 _itemID,  string calldata _evidence) external payable {

        require(items[_itemID].status == Status.Registered, "Item must be registered to be removed.");
        Item storage item = items[_itemID];

        if (bytes(_evidence).length > 0) {
            uint requestIndex = item.requests.length;
            uint evidenceGroupID = uint(keccak256(abi.encodePacked(_itemID, requestIndex)));

            emit Evidence(arbitrator, evidenceGroupID, msg.sender, _evidence);
        }

        requestStatusChange(item.data, removalBaseDeposit);
    }

    function challengeRequest(bytes32 _itemID, string calldata _evidence) external payable {

        Item storage item = items[_itemID];

        require(
            item.status == Status.RegistrationRequested || item.status == Status.ClearingRequested,
            "The item must have a pending request."
        );

        Request storage request = item.requests[item.requests.length - 1];
        require(now - request.submissionTime <= challengePeriodDuration, "Challenges must occur during the challenge period.");
        require(!request.disputed, "The request should not have already been disputed.");

        request.parties[uint(Party.Challenger)] = msg.sender;

        Round storage round = request.rounds[0];
        uint arbitrationCost = request.arbitrator.arbitrationCost(request.arbitratorExtraData);
        uint challengerBaseDeposit = item.status == Status.RegistrationRequested
            ? submissionChallengeBaseDeposit
            : removalChallengeBaseDeposit;
        uint totalCost = arbitrationCost.addCap(challengerBaseDeposit);
        contribute(round, Party.Challenger, msg.sender, msg.value, totalCost);
        require(round.amountPaid[uint(Party.Challenger)] >= totalCost, "You must fully fund your side.");
        round.hasPaid[uint(Party.Challenger)] = true;

        request.disputeID = request.arbitrator.createDispute.value(arbitrationCost)(RULING_OPTIONS, request.arbitratorExtraData);
        arbitratorDisputeIDToItem[address(request.arbitrator)][request.disputeID] = _itemID;
        request.disputed = true;
        request.rounds.length++;
        round.feeRewards = round.feeRewards.subCap(arbitrationCost);

        uint evidenceGroupID = uint(keccak256(abi.encodePacked(_itemID, item.requests.length - 1)));
        emit Dispute(
            request.arbitrator,
            request.disputeID,
            request.metaEvidenceID,
            evidenceGroupID
        );

        if (bytes(_evidence).length > 0) {
            emit Evidence(request.arbitrator, evidenceGroupID, msg.sender, _evidence);
        }
    }

    function fundAppeal(bytes32 _itemID, Party _side) external payable {

        require(_side == Party.Requester || _side == Party.Challenger, "Invalid side.");
        require(
            items[_itemID].status == Status.RegistrationRequested || items[_itemID].status == Status.ClearingRequested,
            "The item must have a pending request."
        );
        Request storage request = items[_itemID].requests[items[_itemID].requests.length - 1];
        require(request.disputed, "A dispute must have been raised to fund an appeal.");
        (uint appealPeriodStart, uint appealPeriodEnd) = request.arbitrator.appealPeriod(request.disputeID);
        require(
            now >= appealPeriodStart && now < appealPeriodEnd,
            "Contributions must be made within the appeal period."
        );

        uint multiplier;
        {
            Party winner = Party(request.arbitrator.currentRuling(request.disputeID));
            Party loser;
            if (winner == Party.Requester)
                loser = Party.Challenger;
            else if (winner == Party.Challenger)
                loser = Party.Requester;
            require(_side != loser || (now-appealPeriodStart < (appealPeriodEnd-appealPeriodStart)/2), "The loser must contribute during the first half of the appeal period.");


            if (_side == winner)
                multiplier = winnerStakeMultiplier;
            else if (_side == loser)
                multiplier = loserStakeMultiplier;
            else
                multiplier = sharedStakeMultiplier;
        }

        Round storage round = request.rounds[request.rounds.length - 1];
        uint appealCost = request.arbitrator.appealCost(request.disputeID, request.arbitratorExtraData);
        uint totalCost = appealCost.addCap((appealCost.mulCap(multiplier)) / MULTIPLIER_DIVISOR);
        uint contribution = contribute(round, _side, msg.sender, msg.value, totalCost);

        emit AppealContribution(
            _itemID,
            msg.sender,
            items[_itemID].requests.length - 1,
            request.rounds.length - 1,
            contribution,
            _side
        );

        if (round.amountPaid[uint(_side)] >= totalCost) {
            round.hasPaid[uint(_side)] = true;
            emit HasPaidAppealFee(_itemID, items[_itemID].requests.length - 1, request.rounds.length - 1, _side);
        }

        if (round.hasPaid[uint(Party.Challenger)] && round.hasPaid[uint(Party.Requester)]) {
            request.arbitrator.appeal.value(appealCost)(request.disputeID, request.arbitratorExtraData);
            request.rounds.length++;
            round.feeRewards = round.feeRewards.subCap(appealCost);
        }
    }

    function withdrawFeesAndRewards(address payable _beneficiary, bytes32 _itemID, uint _request, uint _round) public {

        Item storage item = items[_itemID];
        Request storage request = item.requests[_request];
        Round storage round = request.rounds[_round];
        require(request.resolved, "Request must be resolved.");

        uint reward;
        if (!round.hasPaid[uint(Party.Requester)] || !round.hasPaid[uint(Party.Challenger)]) {
            reward = round.contributions[_beneficiary][uint(Party.Requester)] + round.contributions[_beneficiary][uint(Party.Challenger)];
        } else if (request.ruling == Party.None) {
            uint rewardRequester = round.amountPaid[uint(Party.Requester)] > 0
                ? (round.contributions[_beneficiary][uint(Party.Requester)] * round.feeRewards) / (round.amountPaid[uint(Party.Challenger)] + round.amountPaid[uint(Party.Requester)])
                : 0;
            uint rewardChallenger = round.amountPaid[uint(Party.Challenger)] > 0
                ? (round.contributions[_beneficiary][uint(Party.Challenger)] * round.feeRewards) / (round.amountPaid[uint(Party.Challenger)] + round.amountPaid[uint(Party.Requester)])
                : 0;

            reward = rewardRequester + rewardChallenger;
        } else {
            reward = round.amountPaid[uint(request.ruling)] > 0
                ? (round.contributions[_beneficiary][uint(request.ruling)] * round.feeRewards) / round.amountPaid[uint(request.ruling)]
                : 0;

        }
        round.contributions[_beneficiary][uint(Party.Requester)] = 0;
        round.contributions[_beneficiary][uint(Party.Challenger)] = 0;

        _beneficiary.send(reward);
    }

    function executeRequest(bytes32 _itemID) external {

        Item storage item = items[_itemID];
        Request storage request = item.requests[item.requests.length - 1];
        require(
            now - request.submissionTime > challengePeriodDuration,
            "Time to challenge the request must pass."
        );
        require(!request.disputed, "The request should not be disputed.");

        if (item.status == Status.RegistrationRequested)
            item.status = Status.Registered;
        else if (item.status == Status.ClearingRequested)
            item.status = Status.Absent;
        else
            revert("There must be a request.");

        request.resolved = true;
        emit ItemStatusChange(_itemID, item.requests.length - 1, request.rounds.length - 1, false, true);

        withdrawFeesAndRewards(request.parties[uint(Party.Requester)], _itemID, item.requests.length - 1, 0); // Automatically withdraw for the requester.
    }

    function rule(uint _disputeID, uint _ruling) public {

        Party resultRuling = Party(_ruling);
        bytes32 itemID = arbitratorDisputeIDToItem[msg.sender][_disputeID];
        Item storage item = items[itemID];

        Request storage request = item.requests[item.requests.length - 1];
        Round storage round = request.rounds[request.rounds.length - 1];
        require(_ruling <= RULING_OPTIONS, "Invalid ruling option");
        require(address(request.arbitrator) == msg.sender, "Only the arbitrator can give a ruling");
        require(!request.resolved, "The request must not be resolved.");

        if (round.hasPaid[uint(Party.Requester)] == true) // If one side paid its fees, the ruling is in its favor. Note that if the other side had also paid, an appeal would have been created.
            resultRuling = Party.Requester;
        else if (round.hasPaid[uint(Party.Challenger)] == true)
            resultRuling = Party.Challenger;

        emit Ruling(IArbitrator(msg.sender), _disputeID, uint(resultRuling));
        executeRuling(_disputeID, uint(resultRuling));
    }

    function submitEvidence(bytes32 _itemID, string calldata _evidence) external {

        Item storage item = items[_itemID];
        Request storage request = item.requests[item.requests.length - 1];
        require(!request.resolved, "The dispute must not already be resolved.");

        uint evidenceGroupID = uint(keccak256(abi.encodePacked(_itemID, item.requests.length - 1)));
        emit Evidence(request.arbitrator, evidenceGroupID, msg.sender, _evidence);
    }


    function changeTimeToChallenge(uint _challengePeriodDuration) external onlyGovernor {

        challengePeriodDuration = _challengePeriodDuration;
    }

    function changeSubmissionBaseDeposit(uint _submissionBaseDeposit) external onlyGovernor {

        submissionBaseDeposit = _submissionBaseDeposit;
    }

    function changeRemovalBaseDeposit(uint _removalBaseDeposit) external onlyGovernor {

        removalBaseDeposit = _removalBaseDeposit;
    }

    function changeSubmissionChallengeBaseDeposit(uint _submissionChallengeBaseDeposit) external onlyGovernor {

        submissionChallengeBaseDeposit = _submissionChallengeBaseDeposit;
    }

    function changeRemovalChallengeBaseDeposit(uint _removalChallengeBaseDeposit) external onlyGovernor {

        removalChallengeBaseDeposit = _removalChallengeBaseDeposit;
    }

    function changeGovernor(address _governor) external onlyGovernor {

        governor = _governor;
    }

    function changeSharedStakeMultiplier(uint _sharedStakeMultiplier) external onlyGovernor {

        sharedStakeMultiplier = _sharedStakeMultiplier;
    }

    function changeWinnerStakeMultiplier(uint _winnerStakeMultiplier) external onlyGovernor {

        winnerStakeMultiplier = _winnerStakeMultiplier;
    }

    function changeLoserStakeMultiplier(uint _loserStakeMultiplier) external onlyGovernor {

        loserStakeMultiplier = _loserStakeMultiplier;
    }

    function changeArbitrator(IArbitrator _arbitrator, bytes calldata _arbitratorExtraData) external onlyGovernor {

        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }

    function changeConnectedTCR(address _connectedTCR) external onlyGovernor {

        emit ConnectedTCRSet(_connectedTCR);
    }

    function changeMetaEvidence(string calldata _registrationMetaEvidence, string calldata _clearingMetaEvidence) external onlyGovernor {

        metaEvidenceUpdates++;
        emit MetaEvidence(2 * metaEvidenceUpdates, _registrationMetaEvidence);
        emit MetaEvidence(2 * metaEvidenceUpdates + 1, _clearingMetaEvidence);
    }


    function requestStatusChange(bytes memory _item, uint _baseDeposit) internal {

        bytes32 itemID = keccak256(_item);
        Item storage item = items[itemID];

        uint evidenceGroupID = uint(keccak256(abi.encodePacked(itemID, item.requests.length)));
        if (item.requests.length == 0) {
            item.data = _item;
            itemList.push(itemID);
            itemIDtoIndex[itemID] = itemList.length - 1;

            emit ItemSubmitted(itemID, msg.sender, evidenceGroupID, item.data);
        }

        Request storage request = item.requests[item.requests.length++];
        if (item.status == Status.Absent) {
            item.status = Status.RegistrationRequested;
            request.metaEvidenceID = 2 * metaEvidenceUpdates;
        } else if (item.status == Status.Registered) {
            item.status = Status.ClearingRequested;
            request.metaEvidenceID = 2 * metaEvidenceUpdates + 1;
        }

        request.parties[uint(Party.Requester)] = msg.sender;
        request.submissionTime = now;
        request.arbitrator = arbitrator;
        request.arbitratorExtraData = arbitratorExtraData;

        Round storage round = request.rounds[request.rounds.length++];

        uint arbitrationCost = request.arbitrator.arbitrationCost(request.arbitratorExtraData);
        uint totalCost = arbitrationCost.addCap(_baseDeposit);
        contribute(round, Party.Requester, msg.sender, msg.value, totalCost);
        require(round.amountPaid[uint(Party.Requester)] >= totalCost, "You must fully fund your side.");
        round.hasPaid[uint(Party.Requester)] = true;

        emit ItemStatusChange(itemID, item.requests.length - 1, request.rounds.length - 1, false, false);
        emit RequestSubmitted(itemID, item.requests.length - 1, item.status);
        emit RequestEvidenceGroupID(itemID, item.requests.length - 1, evidenceGroupID);
    }

    function calculateContribution(uint _available, uint _requiredAmount)
        internal
        pure
        returns(uint taken, uint remainder)
    {

        if (_requiredAmount > _available)
            return (_available, 0); // Take whatever is available, return 0 as leftover ETH.
        else
            return (_requiredAmount, _available - _requiredAmount);
    }

    function contribute(Round storage _round, Party _side, address payable _contributor, uint _amount, uint _totalRequired) internal returns (uint) {

        uint contribution; // Amount contributed.
        uint remainingETH; // Remaining ETH to send back.
        (contribution, remainingETH) = calculateContribution(_amount, _totalRequired.subCap(_round.amountPaid[uint(_side)]));
        _round.contributions[_contributor][uint(_side)] += contribution;
        _round.amountPaid[uint(_side)] += contribution;
        _round.feeRewards += contribution;

        _contributor.send(remainingETH); // Deliberate use of send in order to not block the contract in case of reverting fallback.

        return contribution;
    }

    function executeRuling(uint _disputeID, uint _ruling) internal {

        bytes32 itemID = arbitratorDisputeIDToItem[msg.sender][_disputeID];
        Item storage item = items[itemID];
        Request storage request = item.requests[item.requests.length - 1];

        Party winner = Party(_ruling);

        if (winner == Party.Requester) { // Execute Request.
            if (item.status == Status.RegistrationRequested)
                item.status = Status.Registered;
            else if (item.status == Status.ClearingRequested)
                item.status = Status.Absent;
        } else {
            if (item.status == Status.RegistrationRequested)
                item.status = Status.Absent;
            else if (item.status == Status.ClearingRequested)
                item.status = Status.Registered;
        }

        request.resolved = true;
        request.ruling = Party(_ruling);

        emit ItemStatusChange(itemID, item.requests.length - 1, request.rounds.length - 1, true, true);

        if (winner == Party.None) {
            withdrawFeesAndRewards(request.parties[uint(Party.Requester)], itemID, item.requests.length - 1, 0);
            withdrawFeesAndRewards(request.parties[uint(Party.Challenger)], itemID, item.requests.length - 1, 0);
        } else {
            withdrawFeesAndRewards(request.parties[uint(winner)], itemID, item.requests.length - 1, 0);
        }
    }


    function itemCount() external view returns (uint count) {

        return itemList.length;
    }

    function getContributions(
        bytes32 _itemID,
        uint _request,
        uint _round,
        address _contributor
    ) external view returns(uint[3] memory contributions) {

        Item storage item = items[_itemID];
        Request storage request = item.requests[_request];
        Round storage round = request.rounds[_round];
        contributions = round.contributions[_contributor];
    }

    function getItemInfo(bytes32 _itemID)
        external
        view
        returns (
            bytes memory data,
            Status status,
            uint numberOfRequests
        )
    {

        Item storage item = items[_itemID];
        return (
            item.data,
            item.status,
            item.requests.length
        );
    }

    function getRequestInfo(bytes32 _itemID, uint _request)
        external
        view
        returns (
            bool disputed,
            uint disputeID,
            uint submissionTime,
            bool resolved,
            address payable[3] memory parties,
            uint numberOfRounds,
            Party ruling,
            IArbitrator arbitrator,
            bytes memory arbitratorExtraData,
            uint metaEvidenceID
        )
    {

        Request storage request = items[_itemID].requests[_request];
        return (
            request.disputed,
            request.disputeID,
            request.submissionTime,
            request.resolved,
            request.parties,
            request.rounds.length,
            request.ruling,
            request.arbitrator,
            request.arbitratorExtraData,
            request.metaEvidenceID
        );
    }

    function getRoundInfo(bytes32 _itemID, uint _request, uint _round)
        external
        view
        returns (
            bool appealed,
            uint[3] memory amountPaid,
            bool[3] memory hasPaid,
            uint feeRewards
        )
    {

        Item storage item = items[_itemID];
        Request storage request = item.requests[_request];
        Round storage round = request.rounds[_round];
        return (
            _round != (request.rounds.length - 1),
            round.amountPaid,
            round.hasPaid,
            round.feeRewards
        );
    }
}



pragma solidity ^0.5.16;


contract BatchWithdraw {


    function batchRoundWithdraw(
        address _address,
        address payable _contributor,
        bytes32 _itemID,
        uint _request,
        uint _cursor,
        uint _count
    ) public {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        (,,,,,uint numberOfRounds,,,,) = gtcr.getRequestInfo(_itemID, _request);
        for (uint i = _cursor; i < numberOfRounds && (_count == 0 || i < _count); i++)
            gtcr.withdrawFeesAndRewards(_contributor, _itemID, _request, i);
    }

    function batchRequestWithdraw(
        address _address,
        address payable _contributor,
        bytes32 _itemID,
        uint _cursor,
        uint _count,
        uint _roundCursor,
        uint _roundCount
    ) external {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        (
            ,
            ,
            uint numberOfRequests
        ) = gtcr.getItemInfo(_itemID);
        for (uint i = _cursor; i < numberOfRequests && (_count == 0 || i < _count); i++)
            batchRoundWithdraw(_address, _contributor, _itemID, i, _roundCursor, _roundCount);
    }
}