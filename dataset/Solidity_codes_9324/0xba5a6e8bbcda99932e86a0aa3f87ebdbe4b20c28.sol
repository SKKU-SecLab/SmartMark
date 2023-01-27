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

contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}pragma solidity 0.5.3;




contract AgreementManagerERC20 is AgreementManager {


    uint constant MAX_TOKEN_POWER = 50;


    event PartyResolved(
        uint32 indexed agreementID,
        uint resolutionTokenA,
        uint resolutionTokenB
    );


    struct AgreementDataERC20 {

        uint48 partyAResolutionTokenA; // Party A's resolution for tokenA
        uint48 partyAResolutionTokenB; // Party A's resolution for tokenB
        uint48 partyBResolutionTokenA; // Party B's resolution for tokenA
        uint48 partyBResolutionTokenB; // Party B's resolution for tokenB
        uint32 nextArbitrationStepAllowedAfterTimestamp;
        uint32 boolValues;

        address partyAToken; // Address of the token contract that party A stakes (or 0x0 if ETH)
        uint48 resolutionTokenA;
        uint48 resolutionTokenB;

        address partyBToken; // Address of the token contract that party A stakes (or 0x0 if ETH)
        uint48 automaticResolutionTokenA;
        uint48 automaticResolutionTokenB;

        address arbitratorToken;
        uint8 partyATokenPower;
        uint8 partyBTokenPower;
        uint8 arbitratorTokenPower;

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


    AgreementDataERC20[] agreements;


    function getResolutionNull() external pure returns (uint, uint) {

        return (resolutionToWei(RESOLUTION_NULL, 0), resolutionToWei(RESOLUTION_NULL, 0));
    }
    function getNumberOfAgreements() external view returns (uint) {

        return agreements.length;
    }

    function getState(
        uint agreementID
    )
        external
        view
        returns (address[6] memory, uint[23] memory, bool[12] memory, bytes memory);



    function createAgreementA(
        bytes32 agreementHash,
        string calldata agreementURI,
        address[6] calldata addresses,
        uint[13] calldata quantities,
        bytes calldata arbExtraData
    )
        external
        payable
        returns (uint)
    {

        require(msg.sender == addresses[0], "Only party A can call createAgreementA.");
        require(
            (
                quantities[10] <= MAX_TOKEN_POWER &&
                quantities[11] <= MAX_TOKEN_POWER &&
                quantities[12] <= MAX_TOKEN_POWER
            ),
            "Token power too large."
        );
        require(
            (
                addresses[0] != addresses[1] &&
                addresses[0] != addresses[2] &&
                addresses[1] != addresses[2]
            ),
            "partyA, partyB, and arbitrator addresses must be unique."
        );
        require(
            quantities[7] >= 1 && quantities[7] <= MAX_DAYS_TO_RESPOND_TO_ARBITRATION_REQUEST,
            "Days to respond to arbitration was out of range."
        );

        AgreementDataERC20 memory agreement;
        agreement.partyAAddress = addresses[0];
        agreement.partyBAddress = addresses[1];
        agreement.arbitratorAddress = addresses[2];
        agreement.partyAToken = addresses[3];
        agreement.partyBToken = addresses[4];
        agreement.arbitratorToken = addresses[5];
        agreement.partyAResolutionTokenA = RESOLUTION_NULL;
        agreement.partyAResolutionTokenB = RESOLUTION_NULL;
        agreement.partyBResolutionTokenA = RESOLUTION_NULL;
        agreement.partyBResolutionTokenB = RESOLUTION_NULL;
        agreement.resolutionTokenA = RESOLUTION_NULL;
        agreement.resolutionTokenB = RESOLUTION_NULL;
        agreement.partyAStakeAmount = toLargerUnit(quantities[0], quantities[10]);
        agreement.partyBStakeAmount = toLargerUnit(quantities[1], quantities[11]);
        require(
            (
                agreement.partyAStakeAmount < RESOLUTION_NULL &&
                agreement.partyBStakeAmount < RESOLUTION_NULL
            ),
            "Stake amounts were too large. Consider increasing the token powers."
        );
        agreement.partyAInitialArbitratorFee = toLargerUnit(quantities[2], quantities[12]);
        agreement.partyBInitialArbitratorFee = toLargerUnit(quantities[3], quantities[12]);
        agreement.disputeFee = toLargerUnit(quantities[4], quantities[12]);
        agreement.automaticResolutionTokenA = toLargerUnit(quantities[5], quantities[10]);
        agreement.automaticResolutionTokenB = toLargerUnit(quantities[6], quantities[11]);
        require(
            (
                agreement.automaticResolutionTokenA <= agreement.partyAStakeAmount &&
                agreement.automaticResolutionTokenB <= agreement.partyBStakeAmount
            ),
            "Automatic resolution was too large."
        );
        agreement.daysToRespondToArbitrationRequest = toUint16(quantities[7]);
        agreement.nextArbitrationStepAllowedAfterTimestamp = toUint32(quantities[8]);
        agreement.autoResolveAfterTimestamp = toUint32(quantities[9]);
        agreement.partyATokenPower = toUint8(quantities[10]);
        agreement.partyBTokenPower = toUint8(quantities[11]);
        agreement.arbitratorTokenPower = toUint8(quantities[12]);
        uint32 tempBools = setBool(0, PARTY_A_STAKE_PAID, true);
        if (add(quantities[1], quantities[3]) == 0) {
            tempBools = setBool(tempBools, PARTY_B_STAKE_PAID, true);
        }
        agreement.boolValues = tempBools;

        uint agreementID = sub(agreements.push(agreement), 1);

        checkContractSpecificConditionsForCreation(agreement.arbitratorToken);

        storeArbitrationExtraData(agreementID, arbExtraData);

        emitAgreementCreationEvents(agreementID, agreementHash, agreementURI);

        verifyDeposit_Untrusted_Guarded(agreements[agreementID], Party.A);

        if ((add(quantities[1], quantities[3]) == 0) && (quantities[2] > 0)) {
            payOutInitialArbitratorFee_Untrusted_Unguarded(agreements[agreementID]);
        }

        return agreementID;
    }

    function depositB(uint agreementID) external payable {

        AgreementDataERC20 storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on.");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(msg.sender == agreement.partyBAddress, "Function can only be called by party B.");
        require(!partyStakePaid(agreement, Party.B), "Party B already deposited their stake.");

        setPartyStakePaid(agreement, Party.B, true);

        emit PartyBDeposited(uint32(agreementID));

        verifyDeposit_Untrusted_Guarded(agreement, Party.B);

        if (add(agreement.partyAInitialArbitratorFee, agreement.partyBInitialArbitratorFee) > 0) {
            payOutInitialArbitratorFee_Untrusted_Unguarded(agreement);
        }
    }

    function resolveAsParty(
        uint agreementID,
        uint resTokenA,
        uint resTokenB,
        bool distributeFunds
    )
        external
    {

        AgreementDataERC20 storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on.");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");

        uint48 resA = toLargerUnit(resTokenA, agreement.partyATokenPower);
        uint48 resB = toLargerUnit(resTokenB, agreement.partyBTokenPower);
        require(resA <= agreement.partyAStakeAmount, "Resolution out of range for token A.");
        require(resB <= agreement.partyBStakeAmount, "Resolution out of range for token B.");

        (Party callingParty, Party otherParty) = getCallingPartyAndOtherParty(agreement);

        if (callingParty == Party.A && !partyAResolvedLast(agreement)) {
            setPartyAResolvedLast(agreement, true);
        } else if (callingParty == Party.B && partyAResolvedLast(agreement)) {
            setPartyAResolvedLast(agreement, false);
        }

        if (partyIsCloserToWinningDefaultJudgment(agreementID, agreement, callingParty)) {
            (uint oldResA, uint oldResB) = partyResolution(agreement, callingParty);
            if (
                !resolutionsAreCompatibleBothExist(
                    agreement,
                    resA,
                    resB,
                    oldResA,
                    oldResB,
                    callingParty
                )
            ) {
                updateArbitrationResponseDeadline(agreement);
            }
        }

        setPartyResolution(agreement, callingParty, resA, resB);

        emit PartyResolved(uint32(agreementID), resA, resB);

        (uint otherResA, uint otherResB) = partyResolution(agreement, otherParty);
        if (
            resolutionsAreCompatible(
                agreement,
                resA,
                resB,
                otherResA,
                otherResB,
                callingParty
            )
        ) {
            finalizeResolution_Untrusted_Unguarded(
                agreementID,
                agreement,
                resA,
                resB,
                distributeFunds,
                false
            );
        }
    }

    function earlyWithdrawA(uint agreementID) external {

        AgreementDataERC20 storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(msg.sender == agreement.partyAAddress, "earlyWithdrawA not called by party A.");
        require(
            partyStakePaid(agreement, Party.A) && !partyStakePaid(agreement, Party.B),
            "Early withdraw not allowed."
        );
        require(!partyReceivedDistribution(agreement, Party.A), "partyA already received funds.");

        setPartyReceivedDistribution(agreement, Party.A, true);

        emit PartyAWithdrewEarly(uint32(agreementID));

        executeDistribution_Untrusted_Unguarded(
            agreement.partyAAddress,
            agreement.partyAToken,
            toWei(agreement.partyAStakeAmount, agreement.partyATokenPower),
            agreement.arbitratorToken,
            toWei(agreement.partyAInitialArbitratorFee, agreement.arbitratorTokenPower)
        );
    }

    function withdraw(uint agreementID) external {

        AgreementDataERC20 storage agreement = agreements[agreementID];
        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreement.resolutionTokenA != RESOLUTION_NULL, "Agreement not resolved.");

        emit PartyWithdrew(uint32(agreementID));

        distributeFundsToPartyHelper_Untrusted_Unguarded(
            agreementID,
            agreement,
            getCallingParty(agreement)
        );
    }

    function requestArbitration(uint agreementID) external payable;


    function requestDefaultJudgment(uint agreementID, bool distributeFunds) external {

        AgreementDataERC20 storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on.");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");

        (Party callingParty, Party otherParty) = getCallingPartyAndOtherParty(agreement);

        require(
            !partyResolutionIsNull(agreement, callingParty),
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

        (uint48 partyResA, uint48 partyResB) = partyResolution(
            agreement,
            callingParty
        );

        finalizeResolution_Untrusted_Unguarded(
            agreementID,
            agreement,
            partyResA,
            partyResB,
            distributeFunds,
            false
        );
    }

    function requestAutomaticResolution(uint agreementID, bool distributeFunds) external {

        AgreementDataERC20 storage agreement = agreements[agreementID];

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
            agreement.automaticResolutionTokenA,
            agreement.automaticResolutionTokenB,
            distributeFunds,
            false
        );
    }

    function submitEvidence(uint agreementID, string calldata evidence) external {

        AgreementDataERC20 storage agreement = agreements[agreementID];

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
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (uint48, uint48)
    {

        if (party == Party.A)
            return (agreement.partyAResolutionTokenA, agreement.partyAResolutionTokenB);
        else
            return (agreement.partyBResolutionTokenA, agreement.partyBResolutionTokenB);
    }

    function partyResolutionIsNull(
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (bool)
    {

        if (party == Party.A) return agreement.partyAResolutionTokenA == RESOLUTION_NULL;
        else return agreement.partyBResolutionTokenA == RESOLUTION_NULL;
    }

    function partyAddress(
        AgreementDataERC20 storage agreement,
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
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (bool)
    {

        if (party == Party.A) return getBool(agreement.boolValues, PARTY_A_STAKE_PAID);
        else return getBool(agreement.boolValues, PARTY_B_STAKE_PAID);
    }

    function partyStakeAmount(
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (uint48)
    {

        if (party == Party.A) return agreement.partyAStakeAmount;
        else return agreement.partyBStakeAmount;
    }

    function partyInitialArbitratorFee(
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (uint48)
    {

        if (party == Party.A) return agreement.partyAInitialArbitratorFee;
        else return agreement.partyBInitialArbitratorFee;
    }

    function partyRequestedArbitration(
        AgreementDataERC20 storage agreement,
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
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (bool)
    {

        if (party == Party.A) return getBool(agreement.boolValues, PARTY_A_RECEIVED_DISTRIBUTION);
        else return getBool(agreement.boolValues, PARTY_B_RECEIVED_DISTRIBUTION);
    }

    function partyToken(
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (address)
    {

        if (party == Party.A) return agreement.partyAToken;
        else return agreement.partyBToken;
    }

    function partyTokenPower(
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (uint8)
    {

        if (party == Party.A) return agreement.partyATokenPower;
        else return agreement.partyBTokenPower;
    }

    function partyAResolvedLast(
        AgreementDataERC20 storage agreement
    )
        internal
        view
        returns (bool)
    {

        return getBool(agreement.boolValues, PARTY_A_RESOLVED_LAST);
    }

    function arbitratorResolved(
        AgreementDataERC20 storage agreement
    )
        internal
        view
        returns (bool)
    {

        return getBool(agreement.boolValues, ARBITRATOR_RESOLVED);
    }

    function arbitratorReceivedDisputeFee(
        AgreementDataERC20 storage agreement
    )
        internal
        view
        returns (bool)
    {

        return getBool(agreement.boolValues, ARBITRATOR_RECEIVED_DISPUTE_FEE);
    }

    function partyDisputeFeeLiability(
        AgreementDataERC20 storage agreement,
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
        AgreementDataERC20 storage agreement
    )
        internal
        view
        returns (bool)
    {

        return getBool(agreement.boolValues, PENDING_EXTERNAL_CALL);
    }


    function setPartyResolution(
        AgreementDataERC20 storage agreement,
        Party party,
        uint48 valueTokenA,
        uint48 valueTokenB
    )
        internal
    {

        if (party == Party.A) {
            agreement.partyAResolutionTokenA = valueTokenA;
            agreement.partyAResolutionTokenB = valueTokenB;
        } else {
            agreement.partyBResolutionTokenA = valueTokenA;
            agreement.partyBResolutionTokenB = valueTokenB;
        }
    }

    function setPartyStakePaid(
        AgreementDataERC20 storage agreement,
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
        AgreementDataERC20 storage agreement,
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
        AgreementDataERC20 storage agreement,
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

    function setPartyAResolvedLast(AgreementDataERC20 storage agreement, bool value) internal {

        agreement.boolValues = setBool(agreement.boolValues, PARTY_A_RESOLVED_LAST, value);
    }

    function setArbitratorResolved(AgreementDataERC20 storage agreement, bool value) internal {

        agreement.boolValues = setBool(agreement.boolValues, ARBITRATOR_RESOLVED, value);
    }

    function setArbitratorReceivedDisputeFee(
        AgreementDataERC20 storage agreement,
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
        AgreementDataERC20 storage agreement,
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

    function setPendingExternalCall(AgreementDataERC20 storage agreement, bool value) internal {

        agreement.boolValues = setBool(agreement.boolValues, PENDING_EXTERNAL_CALL, value);
    }

    function getThenSetPendingExternalCall(
        AgreementDataERC20 storage agreement,
        bool value
    )
        internal
        returns (bool)
    {

        uint32 previousBools = agreement.boolValues;
        agreement.boolValues = setBool(previousBools, PENDING_EXTERNAL_CALL, value);
        return getBool(previousBools, PENDING_EXTERNAL_CALL);
    }


    function toWei(uint value, uint tokenPower) internal pure returns (uint) {

        return mul(value, (10 ** tokenPower));
    }

    function resolutionToWei(uint value, uint tokenPower) internal pure returns (uint) {

        if (value == RESOLUTION_NULL) {
            return uint(~0); // set all bits of a uint to 1
        }
        return mul(value, (10 ** tokenPower));
    }

    function toLargerUnit(uint weiValue, uint tokenPower) internal pure returns (uint48) {

        return toUint48(weiValue / (10 ** tokenPower));
    }

    function getCallingParty(AgreementDataERC20 storage agreement) internal view returns (Party) {

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
        AgreementDataERC20 storage agreement
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
        AgreementDataERC20 storage agreement,
        uint resolutionTokenA,
        uint resolutionTokenB,
        uint otherResolutionTokenA,
        uint otherResolutionTokenB,
        Party resolutionParty
    )
        internal
        view
        returns (bool)
    {

        if (agreement.partyAToken != agreement.partyBToken) {
            if (resolutionParty == Party.A) {
                return resolutionTokenA <= otherResolutionTokenA &&
                    resolutionTokenB <= otherResolutionTokenB;
            } else {
                return otherResolutionTokenA <= resolutionTokenA &&
                    otherResolutionTokenB <= resolutionTokenB;
            }
        }

        uint resSum = add(
            resolutionToWei(resolutionTokenA, agreement.partyATokenPower),
            resolutionToWei(resolutionTokenB, agreement.partyBTokenPower)
        );
        uint otherSum = add(
            resolutionToWei(otherResolutionTokenA, agreement.partyATokenPower),
            resolutionToWei(otherResolutionTokenB, agreement.partyBTokenPower)
        );
        if (resolutionParty == Party.A) {
            return resSum <= otherSum;
        } else {
            return otherSum <= resSum;
        }
    }

    function resolutionsAreCompatible(
        AgreementDataERC20 storage agreement,
        uint resolutionTokenA,
        uint resolutionTokenB,
        uint otherResolutionTokenA,
        uint otherResolutionTokenB,
        Party resolutionParty
    )
        internal
        view
        returns (bool)
    {

        if (otherResolutionTokenA != RESOLUTION_NULL) {
            return resolutionsAreCompatibleBothExist(
                agreement,
                resolutionTokenA,
                resolutionTokenB,
                otherResolutionTokenA,
                otherResolutionTokenB,
                resolutionParty
            );
        }

        if (resolutionParty == Party.A) {
            return resolutionTokenA == 0 && resolutionTokenB == 0;
        } else {
            return resolutionTokenA == agreement.partyAStakeAmount &&
                resolutionTokenB == agreement.partyBStakeAmount;
        }
    }

    function partyIsCloserToWinningDefaultJudgment(
        uint agreementID,
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        returns (bool);


    function getPartyArbitrationRefundInWei(
        uint agreementID,
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        view
        returns (uint);


    function storeArbitrationExtraData(uint agreementID, bytes memory arbExtraData) internal;


    function checkContractSpecificConditionsForCreation(address arbitratorToken) internal;


    function partyFullyPaidDisputeFee_Sometimes_Untrusted_Guarded(
        uint agreementID,
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
        returns (bool);


    function agreementIsOpen(AgreementDataERC20 storage agreement) internal view returns (bool) {

        return agreement.resolutionTokenA == RESOLUTION_NULL &&
            !partyReceivedDistribution(agreement, Party.A);
    }

    function agreementIsLockedIn(
        AgreementDataERC20 storage agreement
    )
        internal
        view
        returns (bool)
    {

        return partyStakePaid(agreement, Party.A) && partyStakePaid(agreement, Party.B);
    }

    function updateArbitrationResponseDeadline(AgreementDataERC20 storage agreement) internal {

        agreement.nextArbitrationStepAllowedAfterTimestamp =
            toUint32(
                add(
                    block.timestamp,
                    mul(agreement.daysToRespondToArbitrationRequest, (1 days))
                )
            );
    }

    function payOutInitialArbitratorFee_Untrusted_Unguarded(
        AgreementDataERC20 storage agreement
    )
        internal
    {

        uint totalInitialFeesWei = toWei(
            add(agreement.partyAInitialArbitratorFee, agreement.partyBInitialArbitratorFee),
            agreement.arbitratorTokenPower
        );

        sendFunds_Untrusted_Unguarded(
            agreement.arbitratorAddress,
            agreement.arbitratorToken,
            totalInitialFeesWei
        );
    }

    function sendFunds_Untrusted_Unguarded(
        address to,
        address token,
        uint amount
    )
        internal
    {

        if (amount == 0) {
            return;
        }
        if (token == address(0)) {
            address(uint160(to)).transfer(amount);
        } else {
            require(ERC20Interface(token).transfer(to, amount), "ERC20 transfer failed.");
        }
    }

    function receiveFunds_Untrusted_Unguarded(
        address token,
        uint amount
    )
        internal
    {

        if (token == address(0)) {
            require(msg.value == amount, "ETH value received was not what was expected.");
        } else if (amount > 0) {
            require(
                ERC20Interface(token).transferFrom(msg.sender, address(this), amount),
                "ERC20 transfer failed."
            );
        }
    }

    function verifyDeposit_Untrusted_Guarded(
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
    {

        address partyTokenAddress = partyToken(agreement, party);

        if (partyTokenAddress != address(0) && agreement.arbitratorToken != address(0)) {
            require(msg.value == 0, "ETH was sent, but none was needed.");
        }

        bool previousValue = getThenSetPendingExternalCall(agreement, true);
        if (partyTokenAddress == agreement.arbitratorToken) {
            receiveFunds_Untrusted_Unguarded(
                partyTokenAddress,
                add(
                    toWei(partyStakeAmount(agreement, party), partyTokenPower(agreement, party)),
                    toWei(
                        partyInitialArbitratorFee(agreement, party),
                        agreement.arbitratorTokenPower
                    )
                )
            );
        } else {
            receiveFunds_Untrusted_Unguarded(
                partyTokenAddress,
                toWei(partyStakeAmount(agreement, party), partyTokenPower(agreement, party))
            );
            receiveFunds_Untrusted_Unguarded(
                agreement.arbitratorToken,
                toWei(
                    partyInitialArbitratorFee(agreement, party),
                    agreement.arbitratorTokenPower
                )
            );
        }
        setPendingExternalCall(agreement, previousValue);
    }

    function executeDistribution_Untrusted_Unguarded(
        address to,
        address token1,
        uint amount1,
        address token2,
        uint amount2
    )
        internal
    {

        if (token1 == token2) {
            sendFunds_Untrusted_Unguarded(to, token1, add(amount1, amount2));
        } else {
            sendFunds_Untrusted_Unguarded(to, token1, amount1);
            sendFunds_Untrusted_Unguarded(to, token2, amount2);
        }
    }

    function executeDistribution_Untrusted_Unguarded(
        address to,
        address token1,
        uint amount1,
        address token2,
        uint amount2,
        address token3,
        uint amount3
    )
        internal
    {


        if (token1 == token2 && token1 == token3) {
            sendFunds_Untrusted_Unguarded(to, token1, add(amount1, add(amount2, amount3)));
        } else if (token1 == token2) {
            sendFunds_Untrusted_Unguarded(to, token1, add(amount1, amount2));
            sendFunds_Untrusted_Unguarded(to, token3, amount3);
        } else if (token1 == token3) {
            sendFunds_Untrusted_Unguarded(to, token1, add(amount1, amount3));
            sendFunds_Untrusted_Unguarded(to, token2, amount2);
        } else if (token2 == token3) {
            sendFunds_Untrusted_Unguarded(to, token1, amount1);
            sendFunds_Untrusted_Unguarded(to, token2, add(amount2, amount3));
        } else {
            sendFunds_Untrusted_Unguarded(to, token1, amount1);
            sendFunds_Untrusted_Unguarded(to, token2, amount2);
            sendFunds_Untrusted_Unguarded(to, token3, amount3);
        }
    }

    function finalizeResolution_Untrusted_Unguarded(
        uint agreementID,
        AgreementDataERC20 storage agreement,
        uint48 resA,
        uint48 resB,
        bool distributeFundsToParties,
        bool distributeFundsToArbitrator
    )
        internal
    {

        agreement.resolutionTokenA = resA;
        agreement.resolutionTokenB = resB;
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
        AgreementDataERC20 storage agreement,
        Party party
    )
        internal
    {

        require(!partyReceivedDistribution(agreement, party), "party already received funds.");
        setPartyReceivedDistribution(agreement, party, true);

        uint distributionAmountA = 0;
        uint distributionAmountB = 0;
        if (party == Party.A) {
            distributionAmountA = agreement.resolutionTokenA;
            distributionAmountB = agreement.resolutionTokenB;
        } else {
            distributionAmountA = sub(agreement.partyAStakeAmount, agreement.resolutionTokenA);
            distributionAmountB = sub(agreement.partyBStakeAmount, agreement.resolutionTokenB);
        }

        uint arbRefundWei = getPartyArbitrationRefundInWei(agreementID, agreement, party);

        executeDistribution_Untrusted_Unguarded(
            partyAddress(agreement, party),
            agreement.partyAToken, toWei(distributionAmountA, agreement.partyATokenPower),
            agreement.partyBToken, toWei(distributionAmountB, agreement.partyBTokenPower),
            agreement.arbitratorToken, arbRefundWei);
    }

    function distributeFundsToArbitratorHelper_Untrusted_Unguarded(
        uint agreementID,
        AgreementDataERC20 storage agreement
    )
        internal
    {

        require(!arbitratorReceivedDisputeFee(agreement), "Already received dispute fee.");
        setArbitratorReceivedDisputeFee(agreement, true);

        emit ArbitratorReceivedDisputeFee(uint32(agreementID));

        sendFunds_Untrusted_Unguarded(
            agreement.arbitratorAddress,
            agreement.arbitratorToken,
            toWei(agreement.disputeFee, agreement.arbitratorTokenPower)
        );
    }

    function calculateDisputeFeeLiability(
        uint argreementID,
        AgreementDataERC20 storage agreement
    )
        internal
    {

        if (!arbitratorGetsDisputeFee(argreementID, agreement)) {
            return;
        }

        if (
            resolutionsAreCompatibleBothExist(
                agreement,
                agreement.partyAResolutionTokenA,
                agreement.partyAResolutionTokenB,
                agreement.partyBResolutionTokenA,
                agreement.partyBResolutionTokenB,
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
                agreement,
                agreement.partyAResolutionTokenA,
                agreement.partyAResolutionTokenB,
                agreement.resolutionTokenA,
                agreement.resolutionTokenB,
                Party.A
            )
        ) {
            setPartyDisputeFeeLiability(agreement, Party.B, true);
        } else if (
            resolutionsAreCompatibleBothExist(
                agreement,
                agreement.partyBResolutionTokenA,
                agreement.partyBResolutionTokenB,
                agreement.resolutionTokenA,
                agreement.resolutionTokenB,
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
        AgreementDataERC20 storage agreement
    )
        internal
        returns (bool);

}
pragma solidity 0.5.3;


contract SimpleArbitrationInterface {


    function storeArbitrationExtraData(uint, bytes memory) internal { }

}
pragma solidity 0.5.3;



contract AgreementManagerERC20_Simple is AgreementManagerERC20, SimpleArbitrationInterface {

    event ArbitratorResolved(
        uint32 indexed agreementID,
        uint resolutionTokenA,
        uint resolutionTokenB
    );


    function getState(
        uint agreementID
    )
        external
        view
        returns (address[6] memory, uint[23] memory, bool[12] memory, bytes memory)
    {
        if (agreementID >= agreements.length) {
            address[6] memory zeroAddrs;
            uint[23] memory zeroUints;
            bool[12] memory zeroBools;
            bytes memory zeroBytes;
            return (zeroAddrs, zeroUints, zeroBools, zeroBytes);
        }

        AgreementDataERC20 storage agreement = agreements[agreementID];

        address[6] memory addrs = [
            agreement.partyAAddress,
            agreement.partyBAddress,
            agreement.arbitratorAddress,
            agreement.partyAToken,
            agreement.partyBToken,
            agreement.arbitratorToken
        ];
        uint[23] memory uints = [
            resolutionToWei(agreement.partyAResolutionTokenA, agreement.partyATokenPower),
            resolutionToWei(agreement.partyAResolutionTokenB, agreement.partyBTokenPower),
            resolutionToWei(agreement.partyBResolutionTokenA, agreement.partyATokenPower),
            resolutionToWei(agreement.partyBResolutionTokenB, agreement.partyBTokenPower),
            resolutionToWei(agreement.resolutionTokenA, agreement.partyATokenPower),
            resolutionToWei(agreement.resolutionTokenB, agreement.partyBTokenPower),
            resolutionToWei(agreement.automaticResolutionTokenA, agreement.partyATokenPower),
            resolutionToWei(agreement.automaticResolutionTokenB, agreement.partyBTokenPower),
            toWei(agreement.partyAStakeAmount, agreement.partyATokenPower),
            toWei(agreement.partyBStakeAmount, agreement.partyBTokenPower),
            toWei(agreement.partyAInitialArbitratorFee, agreement.arbitratorTokenPower),
            toWei(agreement.partyBInitialArbitratorFee, agreement.arbitratorTokenPower),
            toWei(agreement.disputeFee, agreement.arbitratorTokenPower),
            agreement.nextArbitrationStepAllowedAfterTimestamp,
            agreement.autoResolveAfterTimestamp,
            agreement.daysToRespondToArbitrationRequest,
            agreement.partyATokenPower,
            agreement.partyBTokenPower,
            agreement.arbitratorTokenPower,
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
        uint resTokenA,
        uint resTokenB,
        bool distributeFunds
    )
        external
    {
        AgreementDataERC20 storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");

        uint48 resA = toLargerUnit(resTokenA, agreement.partyATokenPower);
        uint48 resB = toLargerUnit(resTokenB, agreement.partyBTokenPower);

        require(
            msg.sender == agreement.arbitratorAddress,
            "resolveAsArbitrator can only be called by arbitrator."
        );
        require(resA <= agreement.partyAStakeAmount, "Resolution out of range for token A.");
        require(resB <= agreement.partyBStakeAmount, "Resolution out of range for token B.");
        require(
            (
                partyRequestedArbitration(agreement, Party.A) &&
                partyRequestedArbitration(agreement, Party.B)
            ),
            "Arbitration not requested by both parties."
        );

        setArbitratorResolved(agreement, true);

        emit ArbitratorResolved(uint32(agreementID), resA, resB);

        bool distributeToArbitrator = !arbitratorReceivedDisputeFee(agreement) && distributeFunds;

        finalizeResolution_Untrusted_Unguarded(
            agreementID,
            agreement,
            resA,
            resB,
            distributeFunds,
            distributeToArbitrator
        );
    }

    function requestArbitration(uint agreementID) external payable {
        AgreementDataERC20 storage agreement = agreements[agreementID];

        require(!pendingExternalCall(agreement), "Reentrancy protection is on");
        require(agreementIsOpen(agreement), "Agreement not open.");
        require(agreementIsLockedIn(agreement), "Agreement not locked in.");
        require(agreement.arbitratorAddress != address(0), "Arbitration is disallowed.");
        if (agreement.arbitratorToken != address(0)) {
            require(msg.value == 0, "ETH was sent, but none was needed.");
        }

        Party callingParty = getCallingParty(agreement);
        require(
            !partyResolutionIsNull(agreement, callingParty),
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

        receiveFunds_Untrusted_Unguarded(
            agreement.arbitratorToken,
            toWei(agreement.disputeFee, agreement.arbitratorTokenPower)
        );
    }

    function withdrawDisputeFee(uint agreementID) external {
        AgreementDataERC20 storage agreement = agreements[agreementID];

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
                agreement,
                agreement.partyAResolutionTokenA,
                agreement.partyAResolutionTokenB,
                agreement.partyBResolutionTokenA,
                agreement.partyBResolutionTokenB,
                Party.A
            ),
            "partyA and partyB already resolved their dispute."
        );

        distributeFundsToArbitratorHelper_Untrusted_Unguarded(agreementID, agreement);
    }


    function checkContractSpecificConditionsForCreation(address arbitratorToken) internal { }

    function partyFullyPaidDisputeFee_Sometimes_Untrusted_Guarded(
        uint, /*agreementID is unused in this version*/
        AgreementDataERC20 storage agreement,
        Party party) internal returns (bool) {

        return partyRequestedArbitration(agreement, party);
    }

    function partyIsCloserToWinningDefaultJudgment(
        uint /*agreementID*/,
        AgreementDataERC20 storage agreement,
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
        AgreementDataERC20 storage agreement,
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
                return toWei(agreement.disputeFee/2, agreement.arbitratorTokenPower);
            }
            return 0; // party pays the full fee
        }
        return toWei(agreement.disputeFee, agreement.arbitratorTokenPower);
    }

    function arbitratorGetsDisputeFee(
        uint /*agreementID*/,
        AgreementDataERC20 storage agreement
    )
        internal
        returns (bool)
    {
        return arbitratorResolved(agreement) || arbitratorReceivedDisputeFee(agreement);
    }
}
