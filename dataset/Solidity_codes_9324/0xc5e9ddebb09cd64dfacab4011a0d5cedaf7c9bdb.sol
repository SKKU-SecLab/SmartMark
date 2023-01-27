


pragma solidity ^0.5;


library CappedMath {

    uint constant private UINT_MAX = 2**256 - 1;
    uint64 constant private UINT64_MAX = 2**64 - 1;

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

    function addCap64(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint64 c = _a + _b;
        return c >= _a ? c : UINT64_MAX;
    }


    function subCap64(uint64 _a, uint64 _b) internal pure returns (uint64) {

        if (_b > _a)
            return 0;
        else
            return _a - _b;
    }

    function mulCap64(uint64 _a, uint64 _b) internal pure returns (uint64) {

        if (_a == 0)
            return 0;

        uint64 c = _a * _b;
        return c / _a == _b ? c : UINT64_MAX;
    }
}




interface IEvidence {


    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    event Evidence(IArbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    event Dispute(IArbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

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





interface IArbitrable {


    event Ruling(IArbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    function rule(uint _disputeID, uint _ruling) external;

}



pragma solidity ^0.5.13;
pragma experimental ABIEncoderV2;

contract ProofOfHumanity is IArbitrable, IEvidence {

    using CappedMath for uint;
    using CappedMath for uint64;


    uint private constant RULING_OPTIONS = 2; // The amount of non 0 choices the arbitrator can give.
    uint private constant AUTO_PROCESSED_VOUCH = 10; // The number of vouches that will be automatically processed when executing a request.
    uint private constant FULL_REASONS_SET = 15; // Indicates that reasons' bitmap is full. 0b1111.
    uint private constant MULTIPLIER_DIVISOR = 10000; // Divisor parameter for multipliers.

    bytes32 private DOMAIN_SEPARATOR; // The EIP-712 domainSeparator specific to this deployed instance. It is used to verify the IsHumanVoucher's signature.
    bytes32 private constant IS_HUMAN_VOUCHER_TYPEHASH = 0xa9e3fa1df5c3dbef1e9cfb610fa780355a0b5e0acb0fa8249777ec973ca789dc; // The EIP-712 typeHash of IsHumanVoucher. keccak256("IsHumanVoucher(address vouchedSubmission,uint256 voucherExpirationTimestamp)").


    enum Status {
        None, // The submission doesn't have a pending status.
        Vouching, // The submission is in the state where it can be vouched for and crowdfunded.
        PendingRegistration, // The submission is in the state where it can be challenged. Or accepted to the list, if there are no challenges within the time limit.
        PendingRemoval // The submission is in the state where it can be challenged. Or removed from the list, if there are no challenges within the time limit.
    }

    enum Party {
        None, // Party per default when there is no challenger or requester. Also used for unconclusive ruling.
        Requester, // Party that made the request to change a status.
        Challenger // Party that challenged the request to change a status.
    }

    enum Reason {
        None, // No reason specified. This option should be used to challenge removal requests.
        IncorrectSubmission, // The submission does not comply with the submission rules.
        Deceased, // The submitter has existed but does not exist anymore.
        Duplicate, // The submitter is already registered. The challenger has to point to the identity already registered or to a duplicate submission.
        DoesNotExist // The submitter is not real. For example, this can be used for videos showing computer generated persons.
    }


    struct Submission {
        Status status; // The current status of the submission.
        bool registered; // Whether the submission is in the registry or not. Note that a registered submission won't have privileges (e.g. vouching) if its duration expired.
        bool hasVouched; // True if this submission used its vouch for another submission. This is set back to false once the vouch is processed.
        uint64 submissionTime; // The time when the submission was accepted to the list.
        uint64 index; // Index of a submission.
        Request[] requests; // List of status change requests made for the submission.
    }

    struct Request {
        bool disputed; // True if a dispute was raised. Note that the request can enter disputed state multiple times, once per reason.
        bool resolved; // True if the request is executed and/or all raised disputes are resolved.
        bool requesterLost; // True if the requester has already had a dispute that wasn't ruled in his favor.
        Reason currentReason; // Current reason a registration request was challenged with. Is left empty for removal requests.
        uint8 usedReasons; // Bitmap of the reasons used by challengers of this request.
        uint16 nbParallelDisputes; // Tracks the number of simultaneously raised disputes. Parallel disputes are only allowed for reason Duplicate.
        uint16 arbitratorDataID; // The index of the relevant arbitratorData struct. All the arbitrator info is stored in a separate struct to reduce gas cost.
        uint16 lastChallengeID; // The ID of the last challenge, which is equal to the total number of challenges for the request.
        uint32 lastProcessedVouch; // Stores the index of the last processed vouch in the array of vouches. It is used for partial processing of the vouches in resolved submissions.
        uint64 currentDuplicateIndex; // Stores the index of the duplicate submission provided by the challenger who is currently winning.
        uint64 challengePeriodStart; // Time when the submission can be challenged.
        address payable requester; // Address that made a request. It is left empty for the registration requests since it matches submissionID in that case.
        address payable ultimateChallenger; // Address of the challenger who won a dispute and who users that vouched for the request must pay the fines to.
        address[] vouches; // Stores the addresses of submissions that vouched for this request and whose vouches were used in this request.
        mapping(uint => Challenge) challenges; // Stores all the challenges of this request. challengeID -> Challenge.
        mapping(address => bool) challengeDuplicates; // Indicates whether a certain duplicate address has been used in a challenge or not.
    }

    struct Round {
        uint[3] paidFees; // Tracks the fees paid by each side in this round.
        Party sideFunded; // Stores the side that successfully paid the appeal fees in the latest round. Note that if both sides have paid a new round is created.
        uint feeRewards; // Sum of reimbursable fees and stake rewards available to the parties that made contributions to the side that ultimately wins a dispute.
        mapping(address => uint[3]) contributions; // Maps contributors to their contributions for each side.
    }

    struct Challenge {
        uint disputeID; // The ID of the dispute related to the challenge.
        Party ruling; // Ruling given by the arbitrator of the dispute.
        uint16 lastRoundID; // The ID of the last round.
        uint64 duplicateSubmissionIndex; // Index of a submission, which is a supposed duplicate of a challenged submission. It is only used for reason Duplicate.
        address payable challenger; // Address that challenged the request.
        mapping(uint => Round) rounds; // Tracks the info of each funding round of the challenge.
    }

    struct DisputeData {
        uint96 challengeID; // The ID of the challenge of the request.
        address submissionID; // The submission, which ongoing request was challenged.
    }

    struct ArbitratorData {
        IArbitrator arbitrator; // Address of the trusted arbitrator to solve disputes.
        uint96 metaEvidenceUpdates; // The meta evidence to be used in disputes.
        bytes arbitratorExtraData; // Extra data for the arbitrator.
    }


    address public governor; // The address that can make governance changes to the parameters of the contract.

    uint public submissionBaseDeposit; // The base deposit to make a new request for a submission.

    uint64 public submissionDuration; // Time after which the registered submission will no longer be considered registered. The submitter has to reapply to the list to refresh it.
    uint64 public renewalPeriodDuration; //  The duration of the period when the registered submission can reapply.
    uint64 public challengePeriodDuration; // The time after which a request becomes executable if not challenged. Note that this value should be less than the time spent on potential dispute's resolution, to avoid complications of parallel dispute handling.

    uint64 public requiredNumberOfVouches; // The number of registered users that have to vouch for a new registration request in order for it to enter PendingRegistration state.

    uint public sharedStakeMultiplier; // Multiplier for calculating the fee stake that must be paid in the case where arbitrator refused to arbitrate.
    uint public winnerStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that won the previous round.
    uint public loserStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that lost the previous round.

    uint public submissionCounter; // The total count of all submissions that made a registration request at some point. Includes manually added submissions as well.

    ArbitratorData[] public arbitratorDataList; // Stores the arbitrator data of the contract. Updated each time the data is changed.

    mapping(address => Submission) private submissions; // Maps the submission ID to its data. submissions[submissionID]. It is private because of getSubmissionInfo().
    mapping(address => mapping(address => bool)) public vouches; // Indicates whether or not the voucher has vouched for a certain submission. vouches[voucherID][submissionID].
    mapping(address => mapping(uint => DisputeData)) public arbitratorDisputeIDToDisputeData; // Maps a dispute ID with its data. arbitratorDisputeIDToDisputeData[arbitrator][disputeID].


    modifier onlyGovernor {require(msg.sender == governor, "The caller must be the governor"); _;}



    event VouchAdded(address indexed _submissionID, address indexed _voucher);

    event VouchRemoved(address indexed _submissionID, address indexed _voucher);

    event AddSubmission(address indexed _submissionID, uint _requestID);

    event ReapplySubmission(address indexed _submissionID, uint _requestID);

    event RemoveSubmission(address indexed _requester, address indexed _submissionID, uint _requestID);

    event SubmissionChallenged(address indexed _submissionID, uint indexed _requestID, uint _challengeID);

    event AppealContribution(address indexed _submissionID, uint indexed _challengeID, Party _party, address indexed _contributor, uint _amount);

    event HasPaidAppealFee(address indexed _submissionID, uint indexed _challengeID, Party _side);

    event ChallengeResolved(address indexed _submissionID, uint indexed _requestID, uint _challengeID);

    event ArbitratorComplete(
        IArbitrator _arbitrator,
        address indexed _governor,
        uint _submissionBaseDeposit,
        uint _submissionDuration,
        uint _challengePeriodDuration,
        uint _requiredNumberOfVouches,
        uint _sharedStakeMultiplier,
        uint _winnerStakeMultiplier,
        uint _loserStakeMultiplier
    );

    constructor(
        IArbitrator _arbitrator,
        bytes memory _arbitratorExtraData,
        string memory _registrationMetaEvidence,
        string memory _clearingMetaEvidence,
        uint _submissionBaseDeposit,
        uint64 _submissionDuration,
        uint64 _renewalPeriodDuration,
        uint64 _challengePeriodDuration,
        uint[3] memory _multipliers,
        uint64 _requiredNumberOfVouches
    ) public {
        emit MetaEvidence(0, _registrationMetaEvidence);
        emit MetaEvidence(1, _clearingMetaEvidence);

        governor = msg.sender;
        submissionBaseDeposit = _submissionBaseDeposit;
        submissionDuration = _submissionDuration;
        renewalPeriodDuration = _renewalPeriodDuration;
        challengePeriodDuration = _challengePeriodDuration;
        sharedStakeMultiplier = _multipliers[0];
        winnerStakeMultiplier = _multipliers[1];
        loserStakeMultiplier = _multipliers[2];
        requiredNumberOfVouches = _requiredNumberOfVouches;

        ArbitratorData storage arbitratorData = arbitratorDataList[arbitratorDataList.length++];
        arbitratorData.arbitrator = _arbitrator;
        arbitratorData.arbitratorExtraData = _arbitratorExtraData;
        emit ArbitratorComplete(_arbitrator, msg.sender, _submissionBaseDeposit, _submissionDuration, _challengePeriodDuration, _requiredNumberOfVouches, _multipliers[0], _multipliers[1], _multipliers[2]);

        bytes32 DOMAIN_TYPEHASH = 0x8cad95687ba82c2ce50e74f7b754645e5117c3a5bec8151c0726d5857980a866; // keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)").
        uint256 chainId;
        assembly { chainId := chainid } // block.chainid got introduced in Solidity v0.8.0.
        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256("Proof of Humanity"), chainId, address(this)));
    }



    function addSubmissionManually(address[] calldata _submissionIDs, string[] calldata _evidence, string[] calldata _names) external onlyGovernor {

        uint counter = submissionCounter;
        uint arbitratorDataID = arbitratorDataList.length - 1;
        for (uint i = 0; i < _submissionIDs.length; i++) {
            Submission storage submission = submissions[_submissionIDs[i]];
            require(submission.requests.length == 0, "Submission already been created");
            submission.index = uint64(counter);
            counter++;

            Request storage request = submission.requests[submission.requests.length++];
            submission.registered = true;

            submission.submissionTime = uint64(now);
            request.arbitratorDataID = uint16(arbitratorDataID);
            request.resolved = true;

            if (bytes(_evidence[i]).length > 0)
                emit Evidence(arbitratorDataList[arbitratorDataID].arbitrator, uint(_submissionIDs[i]), msg.sender, _evidence[i]);
        }
        submissionCounter = counter;
    }

    function removeSubmissionManually(address _submissionID) external onlyGovernor {

        Submission storage submission = submissions[_submissionID];
        require(submission.registered && submission.status == Status.None, "Wrong status");
        submission.registered = false;
    }

    function changeSubmissionBaseDeposit(uint _submissionBaseDeposit) external onlyGovernor {

        submissionBaseDeposit = _submissionBaseDeposit;
    }

    function changeDurations(uint64 _submissionDuration, uint64 _renewalPeriodDuration, uint64 _challengePeriodDuration) external onlyGovernor {

        require(_challengePeriodDuration.addCap64(_renewalPeriodDuration) < _submissionDuration, "Incorrect inputs");
        submissionDuration = _submissionDuration;
        renewalPeriodDuration = _renewalPeriodDuration;
        challengePeriodDuration = _challengePeriodDuration;
    }

    function changeRequiredNumberOfVouches(uint64 _requiredNumberOfVouches) external onlyGovernor {

        requiredNumberOfVouches = _requiredNumberOfVouches;
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

    function changeGovernor(address _governor) external onlyGovernor {

        governor = _governor;
    }

    function changeMetaEvidence(string calldata _registrationMetaEvidence, string calldata _clearingMetaEvidence) external onlyGovernor {

        ArbitratorData storage arbitratorData = arbitratorDataList[arbitratorDataList.length - 1];
        uint96 newMetaEvidenceUpdates = arbitratorData.metaEvidenceUpdates + 1;
        arbitratorDataList.push(ArbitratorData({
            arbitrator: arbitratorData.arbitrator,
            metaEvidenceUpdates: newMetaEvidenceUpdates,
            arbitratorExtraData: arbitratorData.arbitratorExtraData
        }));
        emit MetaEvidence(2 * newMetaEvidenceUpdates, _registrationMetaEvidence);
        emit MetaEvidence(2 * newMetaEvidenceUpdates + 1, _clearingMetaEvidence);
    }

    function changeArbitrator(IArbitrator _arbitrator, bytes calldata _arbitratorExtraData) external onlyGovernor {

        ArbitratorData storage arbitratorData = arbitratorDataList[arbitratorDataList.length - 1];
        arbitratorDataList.push(ArbitratorData({
            arbitrator: _arbitrator,
            metaEvidenceUpdates: arbitratorData.metaEvidenceUpdates,
            arbitratorExtraData: _arbitratorExtraData
        }));
    }


    function addSubmission(string calldata _evidence, string calldata _name) external payable {

        Submission storage submission = submissions[msg.sender];
        require(!submission.registered && submission.status == Status.None, "Wrong status");
        if (submission.requests.length == 0) {
            submission.index = uint64(submissionCounter);
            submissionCounter++;
        }
        submission.status = Status.Vouching;
        emit AddSubmission(msg.sender, submission.requests.length);
        requestRegistration(msg.sender, _evidence);
    }

    function reapplySubmission(string calldata _evidence, string calldata _name) external payable {

        Submission storage submission = submissions[msg.sender];
        require(submission.registered && submission.status == Status.None, "Wrong status");
        uint renewalAvailableAt = submission.submissionTime.addCap64(submissionDuration.subCap64(renewalPeriodDuration));
        require(now >= renewalAvailableAt, "Can't reapply yet");
        submission.status = Status.Vouching;
        emit ReapplySubmission(msg.sender, submission.requests.length);
        requestRegistration(msg.sender, _evidence);
    }

    function removeSubmission(address _submissionID, string calldata _evidence) external payable {

        Submission storage submission = submissions[_submissionID];
        require(submission.registered && submission.status == Status.None, "Wrong status");
        uint renewalAvailableAt = submission.submissionTime.addCap64(submissionDuration.subCap64(renewalPeriodDuration));
        require(now < renewalAvailableAt, "Can't remove after renewal");
        submission.status = Status.PendingRemoval;

        Request storage request = submission.requests[submission.requests.length++];
        request.requester = msg.sender;
        request.challengePeriodStart = uint64(now);

        uint arbitratorDataID = arbitratorDataList.length - 1;
        request.arbitratorDataID = uint16(arbitratorDataID);

        Round storage round = request.challenges[0].rounds[0];

        IArbitrator requestArbitrator = arbitratorDataList[arbitratorDataID].arbitrator;
        uint arbitrationCost = requestArbitrator.arbitrationCost(arbitratorDataList[arbitratorDataID].arbitratorExtraData);
        uint totalCost = arbitrationCost.addCap(submissionBaseDeposit);
        contribute(round, Party.Requester, msg.sender, msg.value, totalCost);

        require(round.paidFees[uint(Party.Requester)] >= totalCost, "You must fully fund your side");
        round.sideFunded = Party.Requester;

        emit RemoveSubmission(msg.sender, _submissionID, submission.requests.length - 1);

        if (bytes(_evidence).length > 0)
            emit Evidence(requestArbitrator, submission.requests.length - 1 + uint(_submissionID), msg.sender, _evidence);
    }

    function fundSubmission(address _submissionID) external payable {

        Submission storage submission = submissions[_submissionID];
        require(submission.status == Status.Vouching, "Wrong status");
        Request storage request = submission.requests[submission.requests.length - 1];
        Challenge storage challenge = request.challenges[0];
        Round storage round = challenge.rounds[0];

        ArbitratorData storage arbitratorData = arbitratorDataList[request.arbitratorDataID];
        uint arbitrationCost = arbitratorData.arbitrator.arbitrationCost(arbitratorData.arbitratorExtraData);
        uint totalCost = arbitrationCost.addCap(submissionBaseDeposit);
        contribute(round, Party.Requester, msg.sender, msg.value, totalCost);

        if (round.paidFees[uint(Party.Requester)] >= totalCost)
            round.sideFunded = Party.Requester;
    }

    function addVouch(address _submissionID) external {

        vouches[msg.sender][_submissionID] = true;
        emit VouchAdded(_submissionID, msg.sender);
    }

    function removeVouch(address _submissionID) external {

        vouches[msg.sender][_submissionID] = false;
        emit VouchRemoved(_submissionID, msg.sender);
    }

    function withdrawSubmission() external {

        Submission storage submission = submissions[msg.sender];
        require(submission.status == Status.Vouching, "Wrong status");
        Request storage request = submission.requests[submission.requests.length - 1];

        submission.status = Status.None;
        request.resolved = true;

        withdrawFeesAndRewards(msg.sender, msg.sender, submission.requests.length - 1, 0, 0); // Automatically withdraw for the requester.
    }

    function changeStateToPending(address _submissionID, address[] calldata _vouches, bytes[] calldata _signatures, uint[] calldata _expirationTimestamps) external {

        Submission storage submission = submissions[_submissionID];
        require(submission.status == Status.Vouching, "Wrong status");
        Request storage request = submission.requests[submission.requests.length - 1];
        {
            Challenge storage challenge = request.challenges[0];
            Round storage round = challenge.rounds[0];
            require(round.sideFunded == Party.Requester, "Requester is not funded");
        }
        uint timeOffset = now - submissionDuration; // Precompute the offset before the loop for efficiency and then compare it with the submission time to check the expiration.

        bytes2 PREFIX = "\x19\x01";
        for (uint i = 0; i < _signatures.length && request.vouches.length < requiredNumberOfVouches; i++) {
            address voucherAddress;
            {
                bytes32 messageHash = keccak256(abi.encode(IS_HUMAN_VOUCHER_TYPEHASH, _submissionID, _expirationTimestamps[i]));
                bytes32 hash = keccak256(abi.encodePacked(PREFIX, DOMAIN_SEPARATOR, messageHash));

                bytes memory signature = _signatures[i];
                bytes32 r;
                bytes32 s;
                uint8 v;
                assembly {
                    r := mload(add(signature, 0x20))
                    s := mload(add(signature, 0x40))
                    v := byte(0, mload(add(signature, 0x60)))
                }
                if (v < 27) v += 27;
                require(v == 27 || v == 28, "Invalid signature");

                voucherAddress = ecrecover(hash, v, r, s);
            }

            Submission storage voucher = submissions[voucherAddress];
            if (!voucher.hasVouched && voucher.registered && timeOffset <= voucher.submissionTime &&
            now < _expirationTimestamps[i] && _submissionID != voucherAddress) {
                request.vouches.push(voucherAddress);
                voucher.hasVouched = true;
                emit VouchAdded(_submissionID, voucherAddress);
            }
        }

        for (uint i = 0; i<_vouches.length && request.vouches.length<requiredNumberOfVouches; i++) {
            Submission storage voucher = submissions[_vouches[i]];
            if (!voucher.hasVouched && voucher.registered && timeOffset <= voucher.submissionTime &&
            vouches[_vouches[i]][_submissionID] && _submissionID != _vouches[i]) {
                request.vouches.push(_vouches[i]);
                voucher.hasVouched = true;
            }
        }
        require(request.vouches.length >= requiredNumberOfVouches, "Not enough valid vouches");
        submission.status = Status.PendingRegistration;
        request.challengePeriodStart = uint64(now);
    }

    function challengeRequest(address _submissionID, Reason _reason, address _duplicateID, string calldata _evidence) external payable {

        Submission storage submission = submissions[_submissionID];
        if (submission.status == Status.PendingRegistration)
            require(_reason != Reason.None, "Reason must be specified");
        else if (submission.status == Status.PendingRemoval)
            require(_reason == Reason.None, "Reason must be left empty");
        else
            revert("Wrong status");

        Request storage request = submission.requests[submission.requests.length - 1];
        require(now - request.challengePeriodStart <= challengePeriodDuration, "Time to challenge has passed");

        Challenge storage challenge = request.challenges[request.lastChallengeID];
        {
            Reason currentReason = request.currentReason;
            if (_reason == Reason.Duplicate) {
                require(submissions[_duplicateID].status > Status.None || submissions[_duplicateID].registered, "Wrong duplicate status");
                require(_submissionID != _duplicateID, "Can't be a duplicate of itself");
                require(currentReason == Reason.Duplicate || currentReason == Reason.None, "Another reason is active");
                require(!request.challengeDuplicates[_duplicateID], "Duplicate address already used");
                request.challengeDuplicates[_duplicateID] = true;
                challenge.duplicateSubmissionIndex = submissions[_duplicateID].index;
            } else
                require(!request.disputed, "The request is disputed");

            if (currentReason != _reason) {
                uint8 reasonBit = 1 << (uint8(_reason) - 1); // Get the bit that corresponds with reason's index.
                require((reasonBit & ~request.usedReasons) == reasonBit, "The reason has already been used");

                request.usedReasons ^= reasonBit; // Mark the bit corresponding with reason's index as 'true', to indicate that the reason was used.
                request.currentReason = _reason;
            }
        }

        Round storage round = challenge.rounds[0];
        ArbitratorData storage arbitratorData = arbitratorDataList[request.arbitratorDataID];

        uint arbitrationCost = arbitratorData.arbitrator.arbitrationCost(arbitratorData.arbitratorExtraData);
        contribute(round, Party.Challenger, msg.sender, msg.value, arbitrationCost);
        require(round.paidFees[uint(Party.Challenger)] >= arbitrationCost, "You must fully fund your side");
        round.feeRewards = round.feeRewards.subCap(arbitrationCost);
        round.sideFunded = Party.None; // Set this back to 0, since it's no longer relevant as the new round is created.

        challenge.disputeID = arbitratorData.arbitrator.createDispute.value(arbitrationCost)(RULING_OPTIONS, arbitratorData.arbitratorExtraData);
        challenge.challenger = msg.sender;

        DisputeData storage disputeData = arbitratorDisputeIDToDisputeData[address(arbitratorData.arbitrator)][challenge.disputeID];
        disputeData.challengeID = uint96(request.lastChallengeID);
        disputeData.submissionID = _submissionID;

        request.disputed = true;
        request.nbParallelDisputes++;

        challenge.lastRoundID++;
        emit SubmissionChallenged(_submissionID, submission.requests.length - 1, disputeData.challengeID);

        request.lastChallengeID++;

        emit Dispute(
            arbitratorData.arbitrator,
            challenge.disputeID,
            submission.status == Status.PendingRegistration ? 2 * arbitratorData.metaEvidenceUpdates : 2 * arbitratorData.metaEvidenceUpdates + 1,
            submission.requests.length - 1 + uint(_submissionID)
        );

        if (bytes(_evidence).length > 0)
            emit Evidence(arbitratorData.arbitrator, submission.requests.length - 1 + uint(_submissionID), msg.sender, _evidence);
    }

    function fundAppeal(address _submissionID, uint _challengeID, Party _side) external payable {

        require(_side != Party.None); // You can only fund either requester or challenger.
        Submission storage submission = submissions[_submissionID];
        require(submission.status == Status.PendingRegistration || submission.status == Status.PendingRemoval, "Wrong status");
        Request storage request = submission.requests[submission.requests.length - 1];
        require(request.disputed, "No dispute to appeal");
        require(_challengeID < request.lastChallengeID, "Challenge out of bounds");

        Challenge storage challenge = request.challenges[_challengeID];
        ArbitratorData storage arbitratorData = arbitratorDataList[request.arbitratorDataID];

        (uint appealPeriodStart, uint appealPeriodEnd) = arbitratorData.arbitrator.appealPeriod(challenge.disputeID);
        require(now >= appealPeriodStart && now < appealPeriodEnd, "Appeal period is over");

        uint multiplier;
        {
            Party winner = Party(arbitratorData.arbitrator.currentRuling(challenge.disputeID));
            if (winner == _side){
                multiplier = winnerStakeMultiplier;
            } else if (winner == Party.None){
                multiplier = sharedStakeMultiplier;
            } else {
                multiplier = loserStakeMultiplier;
                require(now-appealPeriodStart < (appealPeriodEnd-appealPeriodStart)/2, "Appeal period is over for loser");
            }
        }

        Round storage round = challenge.rounds[challenge.lastRoundID];
        require(_side != round.sideFunded, "Side is already funded");

        uint appealCost = arbitratorData.arbitrator.appealCost(challenge.disputeID, arbitratorData.arbitratorExtraData);
        uint totalCost = appealCost.addCap((appealCost.mulCap(multiplier)) / MULTIPLIER_DIVISOR);
        uint contribution = contribute(round, _side, msg.sender, msg.value, totalCost);
        emit AppealContribution(_submissionID, _challengeID, _side, msg.sender, contribution);

        if (round.paidFees[uint(_side)] >= totalCost) {
            if (round.sideFunded == Party.None) {
                round.sideFunded = _side;
            } else {
                arbitratorData.arbitrator.appeal.value(appealCost)(challenge.disputeID, arbitratorData.arbitratorExtraData);
                challenge.lastRoundID++;
                round.feeRewards = round.feeRewards.subCap(appealCost);
                round.sideFunded = Party.None; // Set this back to default in the past round as it's no longer relevant.
            }
            emit HasPaidAppealFee(_submissionID, _challengeID, _side);
        }
    }

    function executeRequest(address _submissionID) external {

        Submission storage submission = submissions[_submissionID];
        uint requestID = submission.requests.length - 1;
        Request storage request = submission.requests[requestID];
        require(now - request.challengePeriodStart > challengePeriodDuration, "Can't execute yet");
        require(!request.disputed, "The request is disputed");
        address payable requester;
        if (submission.status == Status.PendingRegistration) {
            if (!request.requesterLost) {
                submission.registered = true;
                submission.submissionTime = uint64(now);
            }
            requester = address(uint160(_submissionID));
        } else if (submission.status == Status.PendingRemoval) {
            submission.registered = false;
            requester = request.requester;
        } else
            revert("Incorrect status.");

        submission.status = Status.None;
        request.resolved = true;

        if (request.vouches.length != 0)
            processVouches(_submissionID, requestID, AUTO_PROCESSED_VOUCH);

        withdrawFeesAndRewards(requester, _submissionID, requestID, 0, 0); // Automatically withdraw for the requester.
    }

    function processVouches(address _submissionID, uint _requestID, uint _iterations) public {

        Submission storage submission = submissions[_submissionID];
        Request storage request = submission.requests[_requestID];
        require(request.resolved, "Submission must be resolved");

        uint lastProcessedVouch = request.lastProcessedVouch;
        uint endIndex = _iterations.addCap(lastProcessedVouch);
        uint vouchCount = request.vouches.length;

        if (endIndex > vouchCount)
            endIndex = vouchCount;

        Reason currentReason = request.currentReason;
        bool applyPenalty = request.ultimateChallenger != address(0x0) && (currentReason == Reason.Duplicate || currentReason == Reason.DoesNotExist);
        for (uint i = lastProcessedVouch; i < endIndex; i++) {
            Submission storage voucher = submissions[request.vouches[i]];
            voucher.hasVouched = false;
            if (applyPenalty) {
                if (voucher.status == Status.Vouching || voucher.status == Status.PendingRegistration)
                    voucher.requests[voucher.requests.length - 1].requesterLost = true;

                voucher.registered = false;
            }
        }
        request.lastProcessedVouch = uint32(endIndex);
    }

    function withdrawFeesAndRewards(address payable _beneficiary, address _submissionID, uint _requestID, uint _challengeID, uint _round) public {

        Submission storage submission = submissions[_submissionID];
        Request storage request = submission.requests[_requestID];
        Challenge storage challenge = request.challenges[_challengeID];
        Round storage round = challenge.rounds[_round];
        require(request.resolved, "Submission must be resolved");
        require(_beneficiary != address(0x0), "Beneficiary must not be empty");

        Party ruling = challenge.ruling;
        uint reward;
        if (_round != 0 && _round == challenge.lastRoundID) {
            reward = round.contributions[_beneficiary][uint(Party.Requester)] + round.contributions[_beneficiary][uint(Party.Challenger)];
        } else if (ruling == Party.None) {
            uint totalFeesInRound = round.paidFees[uint(Party.Challenger)] + round.paidFees[uint(Party.Requester)];
            uint claimableFees = round.contributions[_beneficiary][uint(Party.Challenger)] + round.contributions[_beneficiary][uint(Party.Requester)];
            reward = totalFeesInRound > 0 ? claimableFees * round.feeRewards / totalFeesInRound : 0;
        } else {
            if (_round == 0 && _beneficiary == request.ultimateChallenger && _challengeID == 0) {
                reward = round.feeRewards;
                round.feeRewards = 0;
            } else if (request.ultimateChallenger==address(0x0) || _challengeID!=0 || _round!=0) {
                uint paidFees = round.paidFees[uint(ruling)];
                reward = paidFees > 0
                    ? (round.contributions[_beneficiary][uint(ruling)] * round.feeRewards) / paidFees
                    : 0;
            }
        }
        round.contributions[_beneficiary][uint(Party.Requester)] = 0;
        round.contributions[_beneficiary][uint(Party.Challenger)] = 0;
        _beneficiary.send(reward);
    }

    function rule(uint _disputeID, uint _ruling) public {

        Party resultRuling = Party(_ruling);
        DisputeData storage disputeData = arbitratorDisputeIDToDisputeData[msg.sender][_disputeID];
        address submissionID = disputeData.submissionID;
        uint challengeID = disputeData.challengeID;
        Submission storage submission = submissions[submissionID];

        Request storage request = submission.requests[submission.requests.length - 1];
        Challenge storage challenge = request.challenges[challengeID];
        Round storage round = challenge.rounds[challenge.lastRoundID];
        ArbitratorData storage arbitratorData = arbitratorDataList[request.arbitratorDataID];

        require(address(arbitratorData.arbitrator) == msg.sender);
        require(!request.resolved);

        if (round.sideFunded == Party.Requester) // If one side paid its fees, the ruling is in its favor. Note that if the other side had also paid, an appeal would have been created.
            resultRuling = Party.Requester;
        else if (round.sideFunded == Party.Challenger)
            resultRuling = Party.Challenger;

        emit Ruling(IArbitrator(msg.sender), _disputeID, uint(resultRuling));
        executeRuling(submissionID, challengeID, resultRuling);
    }

    function submitEvidence(address _submissionID, string calldata _evidence) external {

        Submission storage submission = submissions[_submissionID];
        Request storage request = submission.requests[submission.requests.length - 1];
        ArbitratorData storage arbitratorData = arbitratorDataList[request.arbitratorDataID];

        emit Evidence(arbitratorData.arbitrator, submission.requests.length - 1 + uint(_submissionID), msg.sender, _evidence);
    }


    function requestRegistration(address _submissionID, string memory _evidence) internal {

        Submission storage submission = submissions[_submissionID];
        Request storage request = submission.requests[submission.requests.length++];

        uint arbitratorDataID = arbitratorDataList.length - 1;
        request.arbitratorDataID = uint16(arbitratorDataID);

        Round storage round = request.challenges[0].rounds[0];

        IArbitrator requestArbitrator = arbitratorDataList[arbitratorDataID].arbitrator;
        uint arbitrationCost = requestArbitrator.arbitrationCost(arbitratorDataList[arbitratorDataID].arbitratorExtraData);
        uint totalCost = arbitrationCost.addCap(submissionBaseDeposit);
        contribute(round, Party.Requester, msg.sender, msg.value, totalCost);

        if (round.paidFees[uint(Party.Requester)] >= totalCost)
            round.sideFunded = Party.Requester;

        if (bytes(_evidence).length > 0)
            emit Evidence(requestArbitrator, submission.requests.length - 1 + uint(_submissionID), msg.sender, _evidence);
    }

    function calculateContribution(uint _available, uint _requiredAmount)
        internal
        pure
        returns(uint taken, uint remainder)
    {

        if (_requiredAmount > _available)
            return (_available, 0);

        remainder = _available - _requiredAmount;
        return (_requiredAmount, remainder);
    }

    function contribute(Round storage _round, Party _side, address payable _contributor, uint _amount, uint _totalRequired) internal returns (uint) {

        uint contribution;
        uint remainingETH;
        (contribution, remainingETH) = calculateContribution(_amount, _totalRequired.subCap(_round.paidFees[uint(_side)]));
        _round.contributions[_contributor][uint(_side)] += contribution;
        _round.paidFees[uint(_side)] += contribution;
        _round.feeRewards += contribution;

        if (remainingETH != 0)
            _contributor.send(remainingETH);

        return contribution;
    }

    function executeRuling(address _submissionID, uint _challengeID, Party _winner) internal {

        Submission storage submission = submissions[_submissionID];
        uint requestID = submission.requests.length - 1;
        Status status = submission.status;

        Request storage request = submission.requests[requestID];
        uint nbParallelDisputes = request.nbParallelDisputes;

        Challenge storage challenge = request.challenges[_challengeID];

        if (status == Status.PendingRemoval) {
            if (_winner == Party.Requester)
                submission.registered = false;

            submission.status = Status.None;
            request.resolved = true;
        } else if (status == Status.PendingRegistration) {
            if (_winner == Party.Requester) {
                if (nbParallelDisputes == 1) {
                    if (!request.requesterLost) {
                        if (request.usedReasons == FULL_REASONS_SET) {
                            submission.status = Status.None;
                            submission.registered = true;
                            submission.submissionTime = uint64(now);
                            request.resolved = true;
                        } else {
                            request.disputed = false;
                            request.challengePeriodStart = uint64(now);
                            request.currentReason = Reason.None;
                        }
                    } else {
                        submission.status = Status.None;
                        request.resolved = true;
                    }
                }
            } else {
                request.requesterLost = true;
                if (nbParallelDisputes == 1) {
                    submission.status = Status.None;
                    request.resolved = true;
                }
                if (_winner==Party.Challenger && (request.ultimateChallenger==address(0x0) || challenge.duplicateSubmissionIndex<request.currentDuplicateIndex)) {
                    request.ultimateChallenger = challenge.challenger;
                    request.currentDuplicateIndex = challenge.duplicateSubmissionIndex;
                }
            }
        }
        request.nbParallelDisputes--;
        challenge.ruling = _winner;
        emit ChallengeResolved(_submissionID, requestID, _challengeID);
    }


    function isRegistered(address _submissionID) external view returns (bool) {

        Submission storage submission = submissions[_submissionID];
        return submission.registered && now - submission.submissionTime <= submissionDuration;
    }

    function getArbitratorDataListCount() external view returns (uint) {

        return arbitratorDataList.length;
    }

    function checkRequestDuplicates(address _submissionID, uint _requestID, address _duplicateID) external view returns (bool) {

        Request storage request = submissions[_submissionID].requests[_requestID];
        return request.challengeDuplicates[_duplicateID];
    }

    function getContributions(
        address _submissionID,
        uint _requestID,
        uint _challengeID,
        uint _round,
        address _contributor
    ) external view returns(uint[3] memory contributions) {

        Request storage request = submissions[_submissionID].requests[_requestID];
        Challenge storage challenge = request.challenges[_challengeID];
        Round storage round = challenge.rounds[_round];
        contributions = round.contributions[_contributor];
    }

    function getSubmissionInfo(address _submissionID)
        external
        view
        returns (
            Status status,
            uint64 submissionTime,
            uint64 index,
            bool registered,
            bool hasVouched,
            uint numberOfRequests
        )
    {

        Submission storage submission = submissions[_submissionID];
        return (
            submission.status,
            submission.submissionTime,
            submission.index,
            submission.registered,
            submission.hasVouched,
            submission.requests.length
        );
    }

    function getChallengeInfo(address _submissionID, uint _requestID, uint _challengeID)
        external
        view
        returns (
            uint16 lastRoundID,
            address challenger,
            uint disputeID,
            Party ruling,
            uint64 duplicateSubmissionIndex
        )
    {

        Request storage request = submissions[_submissionID].requests[_requestID];
        Challenge storage challenge = request.challenges[_challengeID];
        return (
            challenge.lastRoundID,
            challenge.challenger,
            challenge.disputeID,
            challenge.ruling,
            challenge.duplicateSubmissionIndex
        );
    }

    function getRequestInfo(address _submissionID, uint _requestID)
        external
        view
        returns (
            bool disputed,
            bool resolved,
            bool requesterLost,
            Reason currentReason,
            uint16 nbParallelDisputes,
            uint16 lastChallengeID,
            uint16 arbitratorDataID,
            address payable requester,
            address payable ultimateChallenger,
            uint8 usedReasons
        )
    {

        Request storage request = submissions[_submissionID].requests[_requestID];
        return (
            request.disputed,
            request.resolved,
            request.requesterLost,
            request.currentReason,
            request.nbParallelDisputes,
            request.lastChallengeID,
            request.arbitratorDataID,
            request.requester,
            request.ultimateChallenger,
            request.usedReasons
        );
    }

    function getNumberOfVouches(address _submissionID, uint _requestID) external view returns (uint) {

        Request storage request = submissions[_submissionID].requests[_requestID];
        return request.vouches.length;
    }

    function getRoundInfo(address _submissionID, uint _requestID, uint _challengeID, uint _round)
        external
        view
        returns (
            bool appealed,
            uint[3] memory paidFees,
            Party sideFunded,
            uint feeRewards
        )
    {

        Request storage request = submissions[_submissionID].requests[_requestID];
        Challenge storage challenge = request.challenges[_challengeID];
        Round storage round = challenge.rounds[_round];
        appealed = _round < (challenge.lastRoundID);
        return (
            appealed,
            round.paidFees,
            round.sideFunded,
            round.feeRewards
        );
    }
}