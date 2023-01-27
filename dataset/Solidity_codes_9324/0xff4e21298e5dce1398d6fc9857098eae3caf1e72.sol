
pragma solidity ^0.5.16;

contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.16;


library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }
}


pragma solidity ^0.5.16;

pragma experimental ABIEncoderV2;

contract CouncilDilution is Owned {

    using SafeDecimalMath for uint;


    uint public numOfSeats;

    uint public proposalPeriod;


    string public latestElectionHash;

    struct ElectionLog {
        string electionHash;
        mapping(address => uint) votesForMember;
        mapping(address => bool) councilMembers;
        uint created;
    }

    struct ProposalLog {
        string proposalHash;
        string electionHash;
        uint start;
        uint end;
        bool exist;
    }

    struct DilutionReceipt {
        string proposalHash;
        address memberDiluted;
        uint totalDilutionValue;
        address[] dilutors;
        mapping(address => uint) voterDilutions;
        bool exist;
    }

    mapping(string => ElectionLog) public electionHashToLog;

    mapping(address => mapping(address => uint)) public latestDelegatedVoteWeight;

    mapping(address => uint) public latestVotingWeight;

    mapping(string => mapping(address => address)) public electionMemberVotedFor;

    mapping(string => mapping(address => bool)) public hasAddressDilutedForProposal;

    mapping(string => ProposalLog) public proposalHashToLog;

    mapping(string => mapping(address => DilutionReceipt)) public proposalHashToMemberDilution;


    event ElectionLogged(
        string electionHash,
        address[] nominatedCouncilMembers,
        address[] voters,
        address[] nomineesVotedFor,
        uint[] assignedVoteWeights
    );

    event ProposalLogged(string proposalHash, string electionHash, uint start, uint end);

    event DilutionCreated(
        string proposalHash,
        address memberDiluted,
        uint totalDilutionValueBefore,
        uint totalDilutionValueAfter
    );

    event DilutionModified(
        string proposalHash,
        address memberDiluted,
        uint totalDilutionValueBefore,
        uint totalDilutionValueAfter
    );

    event SeatsModified(uint previousNumberOfSeats, uint newNumberOfSeats);

    event ProposalPeriodModified(uint previousProposalPeriod, uint newProposalPeriod);


    constructor(uint _numOfSeats) public Owned(msg.sender) {
        numOfSeats = _numOfSeats;
        proposalPeriod = 3 days;
    }


    function logElection(
        string memory electionHash,
        address[] memory nominatedCouncilMembers,
        address[] memory voters,
        address[] memory nomineesVotedFor,
        uint[] memory assignedVoteWeights
    ) public onlyOwner() returns (string memory) {

        require(bytes(electionHash).length > 0, "empty election hash provided");
        require(voters.length > 0, "empty voters array provided");
        require(nomineesVotedFor.length > 0, "empty nomineesVotedFor array provided");
        require(assignedVoteWeights.length > 0, "empty assignedVoteWeights array provided");
        require(nominatedCouncilMembers.length == numOfSeats, "invalid number of council members");

        ElectionLog memory newElectionLog = ElectionLog(electionHash, now);

        electionHashToLog[electionHash] = newElectionLog;

        for (uint i = 0; i < voters.length; i++) {
            latestDelegatedVoteWeight[voters[i]][nomineesVotedFor[i]] = assignedVoteWeights[i];
            latestVotingWeight[nomineesVotedFor[i]] = latestVotingWeight[nomineesVotedFor[i]] + assignedVoteWeights[i];
            electionMemberVotedFor[electionHash][voters[i]] = nomineesVotedFor[i];
        }

        for (uint j = 0; j < nominatedCouncilMembers.length; j++) {
            electionHashToLog[electionHash].votesForMember[nominatedCouncilMembers[j]] = latestVotingWeight[
                nominatedCouncilMembers[j]
            ];
            electionHashToLog[electionHash].councilMembers[nominatedCouncilMembers[j]] = true;
        }

        latestElectionHash = electionHash;

        emit ElectionLogged(electionHash, nominatedCouncilMembers, voters, nomineesVotedFor, assignedVoteWeights);

        return electionHash;
    }

    function logProposal(string memory proposalHash) public returns (string memory) {

        require(!proposalHashToLog[proposalHash].exist, "proposal hash is not unique");
        require(bytes(proposalHash).length > 0, "proposal hash must not be empty");

        uint start = now;

        uint end = start + proposalPeriod;

        ProposalLog memory newProposalLog = ProposalLog(proposalHash, latestElectionHash, start, end, true);

        proposalHashToLog[proposalHash] = newProposalLog;

        emit ProposalLogged(proposalHash, latestElectionHash, start, end);

        return proposalHash;
    }

    function dilute(string memory proposalHash, address memberToDilute) public {

        require(memberToDilute != address(0), "member to dilute must be a valid address");
        require(
            electionHashToLog[latestElectionHash].councilMembers[memberToDilute],
            "member to dilute must be a nominated council member"
        );
        require(proposalHashToLog[proposalHash].exist, "proposal does not exist");
        require(
            latestDelegatedVoteWeight[msg.sender][memberToDilute] > 0,
            "sender has not delegated voting weight for member"
        );
        require(now < proposalHashToLog[proposalHash].end, "dilution can only occur within the proposal voting period");
        require(hasAddressDilutedForProposal[proposalHash][msg.sender] == false, "sender has already diluted");

        if (proposalHashToMemberDilution[proposalHash][memberToDilute].exist) {
            DilutionReceipt storage receipt = proposalHashToMemberDilution[proposalHash][memberToDilute];

            uint originalTotalDilutionValue = receipt.totalDilutionValue;

            receipt.dilutors.push(msg.sender);
            receipt.voterDilutions[msg.sender] = latestDelegatedVoteWeight[msg.sender][memberToDilute];
            receipt.totalDilutionValue = receipt.totalDilutionValue + latestDelegatedVoteWeight[msg.sender][memberToDilute];

            hasAddressDilutedForProposal[proposalHash][msg.sender] = true;

            emit DilutionCreated(
                proposalHash,
                receipt.memberDiluted,
                originalTotalDilutionValue,
                receipt.totalDilutionValue
            );
        } else {
            address[] memory dilutors;
            DilutionReceipt memory newDilutionReceipt = DilutionReceipt(proposalHash, memberToDilute, 0, dilutors, true);

            proposalHashToMemberDilution[proposalHash][memberToDilute] = newDilutionReceipt;

            uint originalTotalDilutionValue = proposalHashToMemberDilution[proposalHash][memberToDilute].totalDilutionValue;

            proposalHashToMemberDilution[proposalHash][memberToDilute].dilutors.push(msg.sender);

            proposalHashToMemberDilution[proposalHash][memberToDilute].voterDilutions[
                msg.sender
            ] = latestDelegatedVoteWeight[msg.sender][memberToDilute];

            proposalHashToMemberDilution[proposalHash][memberToDilute].totalDilutionValue = latestDelegatedVoteWeight[
                msg.sender
            ][memberToDilute];

            hasAddressDilutedForProposal[proposalHash][msg.sender] = true;

            emit DilutionCreated(
                proposalHash,
                memberToDilute,
                originalTotalDilutionValue,
                proposalHashToMemberDilution[proposalHash][memberToDilute].totalDilutionValue
            );
        }
    }

    function invalidateDilution(string memory proposalHash, address memberToUndilute) public {

        require(memberToUndilute != address(0), "member to undilute must be a valid address");
        require(proposalHashToLog[proposalHash].exist, "proposal does not exist");
        require(
            proposalHashToMemberDilution[proposalHash][memberToUndilute].exist,
            "dilution receipt does not exist for this member and proposal hash"
        );
        require(
            proposalHashToMemberDilution[proposalHash][memberToUndilute].voterDilutions[msg.sender] > 0 &&
                hasAddressDilutedForProposal[proposalHash][msg.sender] == true,
            "voter has no dilution weight"
        );
        require(now < proposalHashToLog[proposalHash].end, "undo dilution can only occur within the proposal voting period");

        address caller = msg.sender;

        DilutionReceipt storage receipt = proposalHashToMemberDilution[proposalHash][memberToUndilute];

        uint originalTotalDilutionValue = receipt.totalDilutionValue;

        uint voterDilutionValue = receipt.voterDilutions[msg.sender];

        hasAddressDilutedForProposal[proposalHash][msg.sender] = false;

        for (uint i = 0; i < receipt.dilutors.length; i++) {
            if (receipt.dilutors[i] == caller) {
                receipt.dilutors[i] = receipt.dilutors[receipt.dilutors.length - 1];
                break;
            }
        }

        receipt.dilutors.pop();

        receipt.voterDilutions[msg.sender] = 0;
        receipt.totalDilutionValue = receipt.totalDilutionValue - voterDilutionValue;

        emit DilutionModified(proposalHash, receipt.memberDiluted, originalTotalDilutionValue, receipt.totalDilutionValue);
    }


    function getValidProposals(string[] memory proposalHashes) public view returns (string[] memory) {

        string[] memory validHashes = new string[](proposalHashes.length);

        for (uint i = 0; i < proposalHashes.length; i++) {
            string memory proposalHash = proposalHashes[i];
            if (proposalHashToLog[proposalHash].exist) {
                validHashes[i] = (proposalHashToLog[proposalHash].proposalHash);
            }
        }

        return validHashes;
    }

    function getDilutedWeightForProposal(string memory proposalHash, address councilMember) public view returns (uint) {

        require(proposalHashToLog[proposalHash].exist, "proposal does not exist");

        string memory electionHash = proposalHashToLog[proposalHash].electionHash;

        require(electionHashToLog[electionHash].councilMembers[councilMember], "address must be a nominated council member");

        uint originalWeight = electionHashToLog[electionHash].votesForMember[councilMember];
        uint penaltyValue = proposalHashToMemberDilution[proposalHash][councilMember].totalDilutionValue;

        return (originalWeight - penaltyValue).divideDecimal(originalWeight);
    }

    function getDilutorsForDilutionReceipt(string memory proposalHash, address memberDiluted)
        public
        view
        returns (address[] memory)
    {

        return proposalHashToMemberDilution[proposalHash][memberDiluted].dilutors;
    }

    function getVoterDilutionWeightingForDilutionReceipt(
        string memory proposalHash,
        address memberDiluted,
        address voter
    ) public view returns (uint) {

        return proposalHashToMemberDilution[proposalHash][memberDiluted].voterDilutions[voter];
    }


    function modifySeats(uint _numOfSeats) public onlyOwner() {

        require(_numOfSeats > 0, "number of seats must be greater than zero");
        uint oldNumOfSeats = numOfSeats;
        numOfSeats = _numOfSeats;

        emit SeatsModified(oldNumOfSeats, numOfSeats);
    }

    function modifyProposalPeriod(uint _proposalPeriod) public onlyOwner() {

        uint oldProposalPeriod = proposalPeriod;
        proposalPeriod = _proposalPeriod;

        emit ProposalPeriodModified(oldProposalPeriod, proposalPeriod);
    }
}