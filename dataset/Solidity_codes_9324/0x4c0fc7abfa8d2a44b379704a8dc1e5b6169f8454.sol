pragma solidity 0.5.3;

contract SafeUtils {

    function toUint48(uint val) internal pure returns (uint48) {

        uint48 ret = uint48(val);
        require(ret == val, "toUint48 lost some value.");
        return ret;
    }
    function toUint32(uint val) internal pure returns (uint32) {

        uint32 ret = uint32(val);
        require(ret == val, "toUint32 lost some value.");
        return ret;
    }
    function toUint16(uint val) internal pure returns (uint16) {

        uint16 ret = uint16(val);
        require(ret == val, "toUint16 lost some value.");
        return ret;
    }
    function toUint8(uint val) internal pure returns (uint8) {

        uint8 ret = uint8(val);
        require(ret == val, "toUint8 lost some value.");
        return ret;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Bad safe math multiplication.");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "Attempt to divide by zero in safe math.");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "Bad subtraction in safe math.");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "Bad addition in safe math.");

        return c;
    }
}pragma solidity 0.5.3;


contract Arbitrable {


    function rule(uint _dispute, uint _ruling) public;


    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);
}pragma solidity 0.5.3;


contract Arbitrator {


    enum DisputeStatus { Waiting, Appealable, Solved }

    event DisputeCreation(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    event AppealPossible(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    event AppealDecision(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    function createDispute(uint _choices, bytes memory _extraData) public payable returns(uint disputeID);


    function arbitrationCost(bytes memory _extraData) public view returns(uint fee);


    function appeal(uint _disputeID, bytes memory _extraData) public payable;


    function appealCost(uint _disputeID, bytes memory _extraData) public view returns(uint fee);


    function appealPeriod(uint _disputeID) public view returns(uint start, uint end);


    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status);


    function currentRuling(uint _disputeID) public view returns(uint ruling);

}pragma solidity 0.5.3;


contract EvidenceProducer {

    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);
    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);
    event Evidence(Arbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);
}pragma solidity 0.5.3;



contract AgreementManager is SafeUtils, EvidenceProducer {


    uint48 constant RESOLUTION_NULL = ~(uint48(0)); // set all bits to one.

    uint constant MAX_DAYS_TO_RESPOND_TO_ARBITRATION_REQUEST = 365*30; // Approximately 30 years

    enum Party { A, B }


    uint constant PARTY_A_STAKE_PAID = 0; // Has party A fully paid their stake?
    uint constant PARTY_B_STAKE_PAID = 1; // Has party B fully paid their stake?
    uint constant PARTY_A_REQUESTED_ARBITRATION = 2; // Has party A requested arbitration?
    uint constant PARTY_B_REQUESTED_ARBITRATION = 3; // Has party B requested arbitration?
    uint constant PARTY_A_RECEIVED_DISTRIBUTION = 4;
    uint constant PARTY_B_RECEIVED_DISTRIBUTION = 5;
    uint constant PARTY_A_RESOLVED_LAST = 6;
    uint constant ARBITRATOR_RESOLVED = 7; // Did the arbitrator enter a resolution?
    uint constant ARBITRATOR_RECEIVED_DISPUTE_FEE = 8; // Did arbitrator receive the dispute fee?
    uint constant PARTY_A_DISPUTE_FEE_LIABILITY = 9;
    uint constant PARTY_B_DISPUTE_FEE_LIABILITY = 10;
    uint constant PENDING_EXTERNAL_CALL = 11;



    event AgreementCreated(uint32 indexed agreementID, bytes32 agreementHash);

    event PartyBDeposited(uint32 indexed agreementID);
    event PartyAWithdrewEarly(uint32 indexed agreementID);
    event PartyWithdrew(uint32 indexed agreementID);
    event FundsDistributed(uint32 indexed agreementID);
    event ArbitratorReceivedDisputeFee(uint32 indexed agreementID);
    event ArbitrationRequested(uint32 indexed agreementID);
    event DefaultJudgment(uint32 indexed agreementID);
    event AutomaticResolution(uint32 indexed agreementID);


    function () external {}


    function getBool(uint flagField, uint offset) internal pure returns (bool) {

        return ((flagField >> offset) & 1) == 1;
    }

    function setBool(uint32 flagField, uint offset, bool value) internal pure returns (uint32) {

        if (value) {
            return flagField | uint32(1 << offset);
        } else {
            return flagField & ~(uint32(1 << offset));
        }
    }


    function emitAgreementCreationEvents(
        uint agreementID,
        bytes32 agreementHash,
        string memory agreementURI
    )
        internal
    {

        emit MetaEvidence(agreementID, agreementURI);
        emit AgreementCreated(uint32(agreementID), agreementHash);
    }
}
pragma solidity 0.5.3;



contract AgreementManagerETH is AgreementManager {


    uint constant ETH_AMOUNT_ADJUST_FACTOR = 1000*1000*1000*1000;


    event PartyResolved(uint32 indexed agreementID, uint resolution);


    struct AgreementDataETH {
        uint48 partyAResolution; // Resolution for partyA
        uint48 partyBResolution; // Resolution for partyB
        uint48 automaticResolution;
        uint48 resolution;
        uint32 nextArbitrationStepAllowedAfterTimestamp;
        uint32 boolValues;

        address partyAAddress; // ETH address of party A
        uint48 partyAStakeAmount; // Amount that party A is required to stake
        uint48 partyAInitialArbitratorFee;

        address partyBAddress; // ETH address of party B
        uint48 partyBStakeAmount; // Amount that party B is required to stake
        uint48 partyBInitialArbitratorFee;

        address arbitratorAddress; // ETH address of Arbitrator
        uint48 disputeFee; // Fee paid to arbitrator only if there's a dispute and they do work.
        uint32 autoResolveAfterTimestamp;
        uint16 daysToRespondToArbitrationRequest;
    }


    AgreementDataETH[] agreements;


    function getResolutionNull() external pure returns (uint) {

        return resolutionToWei(RESOLUTION_NULL);
    }
    function getNumberOfAgreements() external view returns (uint) {

        return agreements.length;
    }

    function getState(
        uint agreementID
    )
        external
        view
        returns (address[3] memory, uint[16] memory, bool[12] memory, bytes memory);



    function createAgreementA(
        bytes32 agreementHash,
        string calldata agreementURI,
        address[3] calldata participants,
        uint[9] calldata quantities,
        bytes calldata arbExtraData
    )
        external
        payable
        returns (uint)
    {

        require(msg.sender == participants[0], "Only party A can call createAgreementA.");
        require(msg.value == add(quantities[0], quantities[2]), "Payment not correct.");
        require(
            (
                participants[0] != participants[1] &&
                participants[0] != participants[2] &&
                participants[1] != participants[2]
            ),
            "partyA, partyB, and arbitrator addresses must be unique."
        );
        require(
            quantities[6] >= 1 && quantities[6] <= MAX_DAYS_TO_RESPOND_TO_ARBITRATION_REQUEST,
            "Days to respond to arbitration was out of range."
        );

        AgreementDataETH memory agreement;
        agreement.partyAAddress = participants[0];
        agreement.partyBAddress = participants[1];
        agreement.arbitratorAddress = participants[2];
        agreement.partyAResolution = RESOLUTION_NULL;
        agreement.partyBResolution = RESOLUTION_NULL;
        agreement.resolution = RESOLUTION_NULL;
        agreement.partyAStakeAmount = toMillionth(quantities[0]);
        agreement.partyBStakeAmount = toMillionth(quantities[1]);
        uint sumOfStakes = add(agreement.partyAStakeAmount, agreement.partyBStakeAmount);
        require(sumOfStakes < RESOLUTION_NULL, "Stake amounts were too large.");
        agreement.partyAInitialArbitratorFee = toMillionth(quantities[2]);
        agreement.partyBInitialArbitratorFee = toMillionth(quantities[3]);
        agreement.disputeFee = toMillionth(quantities[4]);
        agreement.automaticResolution = toMillionth(quantities[5]);
        require(agreement.automaticResolution <= sumOfStakes, "Automatic resolution too large.");
        agreement.daysToRespondToArbitrationRequest = toUint16(quantities[6]);
        agreement.nextArbitrationStepAllowedAfterTimestamp = toUint32(quantities[7]);
        agreement.autoResolveAfterTimestamp = toUint32(quantities[8]);
        uint32 tempBools = setBool(0, PARTY_A_STAKE_PAID, true);
        if (add(quantities[1], quantities[3]) == 0) {
            tempBools = setBool(tempBools, PARTY_B_STAKE_PAID, true);
        }
        agreement.boolValues = tempBools;

        uint agreementID = sub(agreements.push(agreement), 1);

        storeArbitrationExtraData(agreementID, arbExtraData);

        emitAgreementCreationEvents(agreementID, agreementHash, agreementURI);

        if ((add(quantities[1], quantities[3]) == 0) && (quantities[2] > 0)) {
            payOutInitialArbitratorFee_Untrusted_Unguarded(agreementID);
        }
        return agreementID;
    }

    function depositB(uint agreementID) external payable {

        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on.");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(msg.sender == agreement.partyBAddress, "Function can only be called by party B.");
        require(!partyStakePaid(agreement, Party.B), "Party B already deposited their stake.");

        require(
            msg.value == toWei(
                add(agreement.partyBStakeAmount, agreement.partyBInitialArbitratorFee)
            ),
            "Party B deposit amount was unexpected."
        );

        setPartyStakePaid(agreement, Party.B, true);

        emit PartyBDeposited(uint32(agreementID));

        if (add(agreement.partyAInitialArbitratorFee, agreement.partyBInitialArbitratorFee) > 0) {
            payOutInitialArbitratorFee_Untrusted_Unguarded(agreementID);
        }
    }

    function resolveAsParty(uint agreementID, uint resolutionWei, bool distributeFunds) external {

        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on.");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");

        uint48 res = toMillionth(resolutionWei);
        require(
            res <= add(agreement.partyAStakeAmount, agreement.partyBStakeAmount),
            "Resolution out of range."
        );

        (Party callingParty, Party otherParty) = getCallingPartyAndOtherParty(agreement);

        if (callingParty == Party.A && !partyAResolvedLast(agreement)) {
            setPartyAResolvedLast(agreement, true);
        } else if (callingParty == Party.B && partyAResolvedLast(agreement)) {
            setPartyAResolvedLast(agreement, false);
        }

        if (partyIsCloserToWinningDefaultJudgment(agreementID, agreement, callingParty)) {
            if (
                !resolutionsAreCompatibleBothExist(
                    res,
                    partyResolution(agreement, callingParty),
                    callingParty
                )
            ) {
                updateArbitrationResponseDeadline(agreement);
            }
        }

        setPartyResolution(agreement, callingParty, res);

        emit PartyResolved(uint32(agreementID), resolutionWei);

        uint otherRes = partyResolution(agreement, otherParty);
        if (resolutionsAreCompatible(agreement, res, otherRes, callingParty)) {
            finalizeResolution_Untrusted_Unguarded(
                agreementID,
                agreement,
                res,
                distributeFunds,
                false
            );
        }
    }

    function earlyWithdrawA(uint agreementID) external {

        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(msg.sender == agreement.partyAAddress, "withdrawA must be called by party A.");
        require(
            partyStakePaid(agreement, Party.A) && !partyStakePaid(agreement, Party.B),
            "Early withdraw not allowed."
        );
        require(!partyReceivedDistribution(agreement, Party.A), "partyA already received funds.");

        setPartyReceivedDistribution(agreement, Party.A, true);

        emit PartyAWithdrewEarly(uint32(agreementID));

        msg.sender.transfer(
            toWei(add(agreement.partyAStakeAmount, agreement.partyAInitialArbitratorFee))
        );
    }

    function withdraw(uint agreementID) external {

        AgreementDataETH storage agreement = agreements[agreementID];
        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreement.resolution != RESOLUTION_NULL, "Agreement is not resolved.");

        emit PartyWithdrew(uint32(agreementID));

        distributeFundsToPartyHelper_Untrusted_Unguarded(
            agreementID,
            agreement,
            getCallingParty(agreement)
        );
    }

    function requestArbitration(uint agreementID) external payable;


    function requestDefaultJudgment(uint agreementID, bool distributeFunds) external {

        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");

        (Party callingParty, Party otherParty) = getCallingPartyAndOtherParty(agreement);

        require(
            RESOLUTION_NULL != partyResolution(agreement, callingParty),
            "requestDefaultJudgment called before party resolved."
        );
        require(
            block.timestamp > agreement.nextArbitrationStepAllowedAfterTimestamp,
            "requestDefaultJudgment not allowed yet."
        );

        emit DefaultJudgment(uint32(agreementID));

        require(
            partyFullyPaidDisputeFee_Sometimes_Untrusted_Guarded(
                agreementID,
                agreement,
                callingParty
            ),
            "Party didn't fully pay the dispute fee."
        );
        require(
            !partyFullyPaidDisputeFee_Sometimes_Untrusted_Guarded(
                agreementID,
                agreement,
                otherParty
            ),
            "Other party fully paid the dispute fee."
        );

        finalizeResolution_Untrusted_Unguarded(
            agreementID,
            agreement,
            partyResolution(agreement, callingParty),
            distributeFunds,
            false
        );
    }

    function requestAutomaticResolution(uint agreementID, bool distributeFunds) external {

        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on.");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");
        require(
            (
                !partyRequestedArbitration(agreement, Party.A) &&
                !partyRequestedArbitration(agreement, Party.B)
            ),
            "Arbitration stops auto-resolution"
        );
        require(
            msg.sender == agreement.partyAAddress || msg.sender == agreement.partyBAddress,
            "Unauthorized sender."
        );
        require(
            agreement.autoResolveAfterTimestamp > 0,
            "Agreement does not support automatic resolutions."
        );
        require(
            block.timestamp > agreement.autoResolveAfterTimestamp,
            "AutoResolution not allowed yet."
        );

        emit AutomaticResolution(uint32(agreementID));

         finalizeResolution_Untrusted_Unguarded(
            agreementID,
            agreement,
            agreement.automaticResolution,
            distributeFunds,
            false
        );
    }

    function submitEvidence(uint agreementID, string calldata evidence) external {

        AgreementDataETH storage agreement = agreements[agreementID];

        require(
            (
                msg.sender == agreement.partyAAddress ||
                msg.sender == agreement.partyBAddress ||
                msg.sender == agreement.arbitratorAddress
            ),
            "Unauthorized sender."
        );

        emit Evidence(Arbitrator(agreement.arbitratorAddress), agreementID, msg.sender, evidence);
    }




    function partyResolution(
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (uint48)
    {

        if (party == Party.A) return agreement.partyAResolution;
        else return agreement.partyBResolution;
    }

    function partyAddress(
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (address)
    {

        if (party == Party.A) return agreement.partyAAddress;
        else return agreement.partyBAddress;
    }

    function partyStakePaid(
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (bool)
    {

        if (party == Party.A) return getBool(agreement.boolValues, PARTY_A_STAKE_PAID);
        else return getBool(agreement.boolValues, PARTY_B_STAKE_PAID);
    }

    function partyRequestedArbitration(
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (bool)
    {

        if (party == Party.A) return getBool(agreement.boolValues, PARTY_A_REQUESTED_ARBITRATION);
        else return getBool(agreement.boolValues, PARTY_B_REQUESTED_ARBITRATION);
    }

    function partyReceivedDistribution(
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (bool)
    {

        if (party == Party.A) return getBool(agreement.boolValues, PARTY_A_RECEIVED_DISTRIBUTION);
        else return getBool(agreement.boolValues, PARTY_B_RECEIVED_DISTRIBUTION);
    }

    function partyAResolvedLast(AgreementDataETH storage agreement) internal view returns (bool) {

        return getBool(agreement.boolValues, PARTY_A_RESOLVED_LAST);
    }

    function arbitratorResolved(AgreementDataETH storage agreement) internal view returns (bool) {

        return getBool(agreement.boolValues, ARBITRATOR_RESOLVED);
    }

    function arbitratorReceivedDisputeFee(
        AgreementDataETH storage agreement
    )
        internal
        view
        returns (bool)
    {

        return getBool(agreement.boolValues, ARBITRATOR_RECEIVED_DISPUTE_FEE);
    }

    function partyDisputeFeeLiability(
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (bool)
    {

        if (party == Party.A) return getBool(agreement.boolValues, PARTY_A_DISPUTE_FEE_LIABILITY);
        else return getBool(agreement.boolValues, PARTY_B_DISPUTE_FEE_LIABILITY);
    }

    function pendingExternalCall(
        AgreementDataETH storage agreement
    )
        internal
        view
        returns (bool)
    {

        return getBool(agreement.boolValues, PENDING_EXTERNAL_CALL);
    }


    function setPartyResolution(
        AgreementDataETH storage agreement,
        Party party,
        uint48 value
    )
        internal
    {

        if (party == Party.A) agreement.partyAResolution = value;
        else agreement.partyBResolution = value;
    }

    function setPartyStakePaid(
        AgreementDataETH storage agreement,
        Party party,
        bool value
    )
        internal
    {

        if (party == Party.A)
            agreement.boolValues = setBool(agreement.boolValues, PARTY_A_STAKE_PAID, value);
        else
            agreement.boolValues = setBool(agreement.boolValues, PARTY_B_STAKE_PAID, value);
    }

    function setPartyRequestedArbitration(
        AgreementDataETH storage agreement,
        Party party,
        bool value
    )
        internal
    {

        if (party == Party.A) {
            agreement.boolValues = setBool(
                agreement.boolValues,
                PARTY_A_REQUESTED_ARBITRATION,
                value
            );
        } else {
            agreement.boolValues = setBool(
                agreement.boolValues,
                PARTY_B_REQUESTED_ARBITRATION,
                value
            );
        }
    }

    function setPartyReceivedDistribution(
        AgreementDataETH storage agreement,
        Party party,
        bool value
    )
        internal
    {

        if (party == Party.A) {
            agreement.boolValues = setBool(
                agreement.boolValues,
                PARTY_A_RECEIVED_DISTRIBUTION,
                value
            );
        } else {
            agreement.boolValues = setBool(
                agreement.boolValues,
                PARTY_B_RECEIVED_DISTRIBUTION,
                value
            );
        }
    }

    function setPartyAResolvedLast(AgreementDataETH storage agreement, bool value) internal {

        agreement.boolValues = setBool(agreement.boolValues, PARTY_A_RESOLVED_LAST, value);
    }

    function setArbitratorResolved(AgreementDataETH storage agreement, bool value) internal {

        agreement.boolValues = setBool(agreement.boolValues, ARBITRATOR_RESOLVED, value);
    }

    function setArbitratorReceivedDisputeFee(
        AgreementDataETH storage agreement,
        bool value
    )
        internal
    {

        agreement.boolValues = setBool(
            agreement.boolValues,
            ARBITRATOR_RECEIVED_DISPUTE_FEE,
            value
        );
    }

    function setPartyDisputeFeeLiability(
        AgreementDataETH storage agreement,
        Party party,
        bool value
    )
        internal
    {

        if (party == Party.A) {
            agreement.boolValues = setBool(
                agreement.boolValues,
                PARTY_A_DISPUTE_FEE_LIABILITY,
                value
            );
        } else {
            agreement.boolValues = setBool(
                agreement.boolValues,
                PARTY_B_DISPUTE_FEE_LIABILITY,
                value
            );
        }
    }

    function setPendingExternalCall(AgreementDataETH storage agreement, bool value) internal {

        agreement.boolValues = setBool(agreement.boolValues, PENDING_EXTERNAL_CALL, value);
    }

    function getThenSetPendingExternalCall(
        AgreementDataETH storage agreement,
        bool value
    )
        internal
        returns (bool)
    {

        uint32 previousBools = agreement.boolValues;
        agreement.boolValues = setBool(previousBools, PENDING_EXTERNAL_CALL, value);
        return getBool(previousBools, PENDING_EXTERNAL_CALL);
    }


    function toWei(uint millionthValue) internal pure returns (uint) {

        return mul(millionthValue, ETH_AMOUNT_ADJUST_FACTOR);
    }

    function resolutionToWei(uint millionthValue) internal pure returns (uint) {

        if (millionthValue == RESOLUTION_NULL) {
            return uint(~0); // set all bits of a uint to 1
        }
        return mul(millionthValue, ETH_AMOUNT_ADJUST_FACTOR);
    }

    function toMillionth(uint weiValue) internal pure returns (uint48) {

        return toUint48(weiValue / ETH_AMOUNT_ADJUST_FACTOR);
    }

    function getCallingParty(AgreementDataETH storage agreement) internal view returns (Party) {

        if (msg.sender == agreement.partyAAddress) {
            return Party.A;
        } else if (msg.sender == agreement.partyBAddress) {
            return Party.B;
        } else {
            require(false, "getCallingParty must be called by a party to the agreement.");
        }
    }

    function getOtherParty(Party party) internal pure returns (Party) {

        if (party == Party.A) {
            return Party.B;
        }
        return Party.A;
    }

    function getCallingPartyAndOtherParty(
        AgreementDataETH storage agreement
    )
        internal
        view
        returns (Party, Party)
    {

        if (msg.sender == agreement.partyAAddress) {
            return (Party.A, Party.B);
        } else if (msg.sender == agreement.partyBAddress) {
            return (Party.B, Party.A);
        } else {
            require(
                false,
                "getCallingPartyAndOtherParty must be called by a party to the agreement."
            );
        }
    }

    function resolutionsAreCompatibleBothExist(
        uint resolution,
        uint otherResolution,
        Party resolutionParty
    )
        internal
        pure
        returns (bool)
    {

        if (resolutionParty == Party.A) {
            return resolution <= otherResolution;
        } else {
            return resolution >= otherResolution;
        }
    }

    function resolutionsAreCompatible(
        AgreementDataETH storage agreement,
        uint resolution,
        uint otherResolution,
        Party resolutionParty
    )
        internal
        view
        returns (bool)
    {

        if (otherResolution != RESOLUTION_NULL) {
            return resolutionsAreCompatibleBothExist(
                resolution,
                otherResolution,
                resolutionParty
            );
        }

        if (resolutionParty == Party.A) {
            return resolution == 0;
        } else {
            return resolution == add(agreement.partyAStakeAmount, agreement.partyBStakeAmount);
        }
    }

    function partyIsCloserToWinningDefaultJudgment(
        uint agreementID,
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        returns (bool);


    function getPartyArbitrationRefundInWei(
        uint agreementID,
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (uint);


    function storeArbitrationExtraData(uint agreementID, bytes memory arbExtraData) internal;


    function partyFullyPaidDisputeFee_Sometimes_Untrusted_Guarded(
        uint agreementID,
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        returns (bool);


    function agreementIsOpen(AgreementDataETH storage agreement) internal view returns (bool) {

        return agreement.resolution == RESOLUTION_NULL &&
            !partyReceivedDistribution(agreement, Party.A);

    }

    function agreementIsLockedIn(
        AgreementDataETH storage agreement
    )
        internal
        view
        returns (bool)
    {

        return partyStakePaid(agreement, Party.A) && partyStakePaid(agreement, Party.B);
    }

    function payOutInitialArbitratorFee_Untrusted_Unguarded(uint agreementID) internal {

        AgreementDataETH storage agreement = agreements[agreementID];

        uint totalInitialFeesWei = toWei(
            add(agreement.partyAInitialArbitratorFee, agreement.partyBInitialArbitratorFee)
        );

        address(uint160(agreement.arbitratorAddress)).transfer(totalInitialFeesWei);
    }

    function updateArbitrationResponseDeadline(AgreementDataETH storage agreement) internal {

        agreement.nextArbitrationStepAllowedAfterTimestamp =
            toUint32(
                add(
                    block.timestamp,
                    mul(agreement.daysToRespondToArbitrationRequest, (1 days))
                )
            );
    }

    function finalizeResolution_Untrusted_Unguarded(
        uint agreementID,
        AgreementDataETH storage agreement,
        uint48 res,
        bool distributeFundsToParties,
        bool distributeFundsToArbitrator
    )
        internal
    {

        agreement.resolution = res;
        calculateDisputeFeeLiability(agreementID, agreement);
        if (distributeFundsToParties) {
            emit FundsDistributed(uint32(agreementID));
            bool previousValue = getThenSetPendingExternalCall(agreement, true);
            distributeFundsToPartyHelper_Untrusted_Unguarded(agreementID, agreement, Party.A);
            distributeFundsToPartyHelper_Untrusted_Unguarded(agreementID, agreement, Party.B);
            setPendingExternalCall(agreement, previousValue);
        }
        if (distributeFundsToArbitrator) {
            distributeFundsToArbitratorHelper_Untrusted_Unguarded(agreementID, agreement);
        }
    }

    function distributeFundsToPartyHelper_Untrusted_Unguarded(
        uint agreementID,
        AgreementDataETH storage agreement,
        Party party
    )
        internal
    {

        require(!partyReceivedDistribution(agreement, party), "party already received funds.");
        setPartyReceivedDistribution(agreement, party, true);

        uint distributionAmount = 0;
        if (party == Party.A) {
            distributionAmount = agreement.resolution;
        } else {
            distributionAmount = sub(
                add(agreement.partyAStakeAmount, agreement.partyBStakeAmount),
                agreement.resolution
            );
        }

        uint distributionWei = add(
            toWei(distributionAmount),
            getPartyArbitrationRefundInWei(agreementID, agreement, party)
        );

        if (distributionWei > 0) {
            address(uint160(partyAddress(agreement, party))).transfer(distributionWei);
        }
    }

    function distributeFundsToArbitratorHelper_Untrusted_Unguarded(
        uint agreementID,
        AgreementDataETH storage agreement
    )
        internal
    {

        require(!arbitratorReceivedDisputeFee(agreement), "Already received dispute fee.");
        setArbitratorReceivedDisputeFee(agreement, true);

        emit ArbitratorReceivedDisputeFee(uint32(agreementID));

        uint feeAmount = agreement.disputeFee;
        if (feeAmount > 0) {
            address(uint160(agreement.arbitratorAddress)).transfer(toWei(feeAmount));
        }
    }

    function calculateDisputeFeeLiability(
        uint argreementID,
        AgreementDataETH storage agreement
    )
        internal
    {

        if (!arbitratorGetsDisputeFee(argreementID, agreement)) {
            return;
        }

        if (
            resolutionsAreCompatibleBothExist(
                agreement.partyAResolution,
                agreement.partyBResolution,
                Party.A
            )
        ) {
            if (partyAResolvedLast(agreement)) {
                setPartyDisputeFeeLiability(agreement, Party.A, true);
            } else {
                setPartyDisputeFeeLiability(agreement, Party.B, true);
            }
            return;
        }

        if (
            resolutionsAreCompatibleBothExist(
                agreement.partyAResolution,
                agreement.resolution,
                Party.A
            )
        ) {
            setPartyDisputeFeeLiability(agreement, Party.B, true);
        } else if (
            resolutionsAreCompatibleBothExist(
                agreement.partyBResolution,
                agreement.resolution,
                Party.B
            )
        ) {
            setPartyDisputeFeeLiability(agreement, Party.A, true);
        } else {
            setPartyDisputeFeeLiability(agreement, Party.A, true);
            setPartyDisputeFeeLiability(agreement, Party.B, true);
        }
    }

    function arbitratorGetsDisputeFee(
        uint argreementID,
        AgreementDataETH storage agreement
    )
        internal
        returns (bool);

}pragma solidity 0.5.3;


contract SimpleArbitrationInterface {


    function storeArbitrationExtraData(uint, bytes memory) internal { }

}
pragma solidity 0.5.3;



contract AgreementManagerETH_Simple is AgreementManagerETH, SimpleArbitrationInterface {

    event ArbitratorResolved(uint32 indexed agreementID, uint resolution);


    function getState(
        uint agreementID
    )
        external
        view
        returns (address[3] memory, uint[16] memory, bool[12] memory, bytes memory)
    {
        if (agreementID >= agreements.length) {
            address[3] memory zeroAddrs;
            uint[16] memory zeroUints;
            bool[12] memory zeroBools;
            bytes memory zeroBytes;
            return (zeroAddrs, zeroUints, zeroBools, zeroBytes);
        }

        AgreementDataETH storage agreement = agreements[agreementID];

        address[3] memory addrs = [
            agreement.partyAAddress,
            agreement.partyBAddress,
            agreement.arbitratorAddress
        ];
        uint[16] memory uints = [
            resolutionToWei(agreement.partyAResolution),
            resolutionToWei(agreement.partyBResolution),
            resolutionToWei(agreement.resolution),
            resolutionToWei(agreement.automaticResolution),
            toWei(agreement.partyAStakeAmount),
            toWei(agreement.partyBStakeAmount),
            toWei(agreement.partyAInitialArbitratorFee),
            toWei(agreement.partyBInitialArbitratorFee),
            toWei(agreement.disputeFee),
            agreement.nextArbitrationStepAllowedAfterTimestamp,
            agreement.autoResolveAfterTimestamp,
            agreement.daysToRespondToArbitrationRequest,
            0,
            0,
            0,
            0
        ];
        bool[12] memory boolVals = [
            partyStakePaid(agreement, Party.A),
            partyStakePaid(agreement, Party.B),
            partyRequestedArbitration(agreement, Party.A),
            partyRequestedArbitration(agreement, Party.B),
            partyReceivedDistribution(agreement, Party.A),
            partyReceivedDistribution(agreement, Party.B),
            partyAResolvedLast(agreement),
            arbitratorResolved(agreement),
            arbitratorReceivedDisputeFee(agreement),
            partyDisputeFeeLiability(agreement, Party.A),
            partyDisputeFeeLiability(agreement, Party.B),
            false
        ];
        bytes memory bytesVal;

        return (addrs, uints, boolVals, bytesVal);
    }


    function resolveAsArbitrator(
        uint agreementID,
        uint resolutionWei,
        bool distributeFunds
    )
        external
    {
        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");

        uint48 res = toMillionth(resolutionWei);

        require(
            msg.sender == agreement.arbitratorAddress,
            "resolveAsArbitrator can only be called by arbitrator."
        );
        require(
            res <= add(agreement.partyAStakeAmount, agreement.partyBStakeAmount),
            "Resolution out of range."
        );
        require(
            (
                partyRequestedArbitration(agreement, Party.A) &&
                partyRequestedArbitration(agreement, Party.B)
            ),
            "Arbitration not requested by both parties."
        );

        setArbitratorResolved(agreement, true);

        emit ArbitratorResolved(uint32(agreementID), resolutionWei);

        bool distributeToArbitrator = !arbitratorReceivedDisputeFee(agreement) && distributeFunds;

        finalizeResolution_Untrusted_Unguarded(
            agreementID,
            agreement,
            res,
            distributeFunds,
            distributeToArbitrator
        );
    }

    function requestArbitration(uint agreementID) external payable {
        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");
        require(agreement.arbitratorAddress != address(0), "Arbitration is disallowed.");
        require(msg.value == toWei(agreement.disputeFee), "Arbitration fee amount is incorrect.");

        Party callingParty = getCallingParty(agreement);
        require(
            RESOLUTION_NULL != partyResolution(agreement, callingParty),
            "Need to enter a resolution before requesting arbitration."
        );
        require(
            !partyRequestedArbitration(agreement, callingParty),
            "This party already requested arbitration."
        );

        bool firstArbitrationRequest =
            !partyRequestedArbitration(agreement, Party.A) &&
            !partyRequestedArbitration(agreement, Party.B);

        require(
            (
                !firstArbitrationRequest ||
                block.timestamp > agreement.nextArbitrationStepAllowedAfterTimestamp
            ),
            "Arbitration not allowed yet."
        );

        setPartyRequestedArbitration(agreement, callingParty, true);

        emit ArbitrationRequested(uint32(agreementID));

        if (firstArbitrationRequest) {
            updateArbitrationResponseDeadline(agreement);
        } else {
            emit Dispute(
                Arbitrator(agreement.arbitratorAddress),
                agreementID,
                agreementID,
                agreementID
            );
        }
    }

    function withdrawDisputeFee(uint agreementID) external {
        AgreementDataETH storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(
            (
                partyRequestedArbitration(agreement, Party.A) &&
                partyRequestedArbitration(agreement, Party.B)
            ),
            "Arbitration not requested"
        );
        require(
            msg.sender == agreement.arbitratorAddress,
            "withdrawDisputeFee can only be called by Arbitrator."
        );
        require(
            !resolutionsAreCompatibleBothExist(
                agreement.partyAResolution,
                agreement.partyBResolution,
                Party.A
            ),
            "partyA and partyB already resolved their dispute."
        );

        distributeFundsToArbitratorHelper_Untrusted_Unguarded(agreementID, agreement);
    }


    function partyFullyPaidDisputeFee_Sometimes_Untrusted_Guarded(
        uint, /*agreementID is unused in this version*/
        AgreementDataETH storage agreement,
        Party party) internal returns (bool) {

        return partyRequestedArbitration(agreement, party);
    }

    function partyIsCloserToWinningDefaultJudgment(
        uint /*agreementID*/,
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        returns (bool)
    {
        return partyRequestedArbitration(agreement, party) &&
            !partyRequestedArbitration(agreement, getOtherParty(party));
    }


    function getPartyArbitrationRefundInWei(
        uint /*agreementID*/,
        AgreementDataETH storage agreement,
        Party party
    )
        internal
        view
        returns (uint)
    {
        if (!partyRequestedArbitration(agreement, party)) {
            return 0;
        }


        if (partyDisputeFeeLiability(agreement, party)) {
            Party otherParty = getOtherParty(party);
            if (partyDisputeFeeLiability(agreement, otherParty)) {
                return toWei(agreement.disputeFee/2);
            }
            return 0; // pays the full fee
        }
        return toWei(agreement.disputeFee);
    }

    function arbitratorGetsDisputeFee(
        uint /*agreementID*/,
        AgreementDataETH storage agreement
    )
        internal
        returns (bool)
    {
        return arbitratorResolved(agreement) || arbitratorReceivedDisputeFee(agreement);
    }
}
pragma solidity 0.5.3;

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}