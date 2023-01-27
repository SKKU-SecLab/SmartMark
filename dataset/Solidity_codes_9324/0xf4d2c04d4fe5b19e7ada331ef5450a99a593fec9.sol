


// Adapted to use pragma ^0.5.8 and satisfy our linter rules

pragma solidity ^0.5.8;


contract ERC20 {

    function totalSupply() public view returns (uint256);


    function balanceOf(address _who) public view returns (uint256);


    function allowance(address _owner, address _spender) public view returns (uint256);


    function transfer(address _to, uint256 _value) public returns (bool);


    function approve(address _spender, uint256 _value) public returns (bool);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



pragma solidity ^0.5.8;



library SafeERC20 {

    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferCallData = abi.encodeWithSelector(
            TRANSFER_SELECTOR,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferCallData);
    }

    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {

        bytes memory transferFromCallData = abi.encodeWithSelector(
            _token.transferFrom.selector,
            _from,
            _to,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), transferFromCallData);
    }

    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {

        bytes memory approveCallData = abi.encodeWithSelector(
            _token.approve.selector,
            _spender,
            _amount
        );
        return invokeAndCheckSuccess(address(_token), approveCallData);
    }

    function invokeAndCheckSuccess(address _addr, bytes memory _calldata) private returns (bool) {

        bool ret;
        assembly {
            let ptr := mload(0x40)    // free memory pointer

            let success := call(
                gas,                  // forward all gas
                _addr,                // address
                0,                    // no value
                add(_calldata, 0x20), // calldata start
                mload(_calldata),     // calldata length
                ptr,                  // write output over free memory
                0x20                  // uint256 return
            )

            if gt(success, 0) {
                switch returndatasize

                case 0 {
                    ret := 1
                }

                case 0x20 {
                    ret := eq(mload(ptr), 1)
                }

                default { }
            }
        }
        return ret;
    }
}



pragma solidity >=0.4.24 <0.6.0;


library SafeMath {

    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}



pragma solidity ^0.5.8;


library SafeMath64 {

    string private constant ERROR_ADD_OVERFLOW = "MATH64_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH64_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH64_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH64_DIV_ZERO";

    function mul(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint256 c = uint256(_a) * uint256(_b);
        require(c < 0x010000000000000000, ERROR_MUL_OVERFLOW); // 2**64 (less gas this way)

        return uint64(c);
    }

    function div(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint64 c = _a / _b;

        return c;
    }

    function sub(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint64 c = _a - _b;

        return c;
    }

    function add(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint64 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}



pragma solidity ^0.5.8;


library Uint256Helpers {

    uint256 private constant MAX_UINT8 = uint8(-1);
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_UINT8_NUMBER_TOO_BIG = "UINT8_NUMBER_TOO_BIG";
    string private constant ERROR_UINT64_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint8(uint256 a) internal pure returns (uint8) {

        require(a <= MAX_UINT8, ERROR_UINT8_NUMBER_TOO_BIG);
        return uint8(a);
    }

    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_UINT64_NUMBER_TOO_BIG);
        return uint64(a);
    }
}


pragma solidity ^0.5.8;



interface IArbitrator {

    function createDispute(uint256 _possibleRulings, bytes calldata _metadata) external returns (uint256);


    function closeEvidencePeriod(uint256 _disputeId) external;


    function executeRuling(uint256 _disputeId) external;


    function getDisputeFees() external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);


    function getSubscriptionFees(address _subscriber) external view returns (address recipient, ERC20 feeToken, uint256 feeAmount);

}


pragma solidity ^0.5.8;


interface ERC165 {

    function supportsInterface(bytes4 _interfaceId) external pure returns (bool);

}


pragma solidity ^0.5.8;




contract IArbitrable is ERC165 {

    bytes4 internal constant ERC165_INTERFACE_ID = bytes4(0x01ffc9a7);
    bytes4 internal constant ARBITRABLE_INTERFACE_ID = bytes4(0x88f3ee69);

    event Ruled(IArbitrator indexed arbitrator, uint256 indexed disputeId, uint256 ruling);

    event EvidenceSubmitted(uint256 indexed disputeId, address indexed submitter, bytes evidence, bool finished);

    function submitEvidence(uint256 _disputeId, bytes calldata _evidence, bool _finished) external;


    function rule(uint256 _disputeId, uint256 _ruling) external;


    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {

        return _interfaceId == ARBITRABLE_INTERFACE_ID || _interfaceId == ERC165_INTERFACE_ID;
    }
}


pragma solidity ^0.5.8;




interface IDisputeManager {

    enum DisputeState {
        PreDraft,
        Adjudicating,
        Ruled
    }

    enum AdjudicationState {
        Invalid,
        Committing,
        Revealing,
        Appealing,
        ConfirmingAppeal,
        Ended
    }

    function createDispute(IArbitrable _subject, uint8 _possibleRulings, bytes calldata _metadata) external returns (uint256);


    function closeEvidencePeriod(IArbitrable _subject, uint256 _disputeId) external;


    function draft(uint256 _disputeId) external;


    function createAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external;


    function confirmAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external;


    function computeRuling(uint256 _disputeId) external returns (IArbitrable subject, uint8 finalRuling);


    function settlePenalties(uint256 _disputeId, uint256 _roundId, uint256 _jurorsToSettle) external;


    function settleReward(uint256 _disputeId, uint256 _roundId, address _juror) external;


    function settleAppealDeposit(uint256 _disputeId, uint256 _roundId) external;


    function getDisputeFees() external view returns (ERC20 feeToken, uint256 feeAmount);


    function getDispute(uint256 _disputeId) external view
        returns (IArbitrable subject, uint8 possibleRulings, DisputeState state, uint8 finalRuling, uint256 lastRoundId, uint64 createTermId);


    function getRound(uint256 _disputeId, uint256 _roundId) external view
        returns (
            uint64 draftTerm,
            uint64 delayedTerms,
            uint64 jurorsNumber,
            uint64 selectedJurors,
            uint256 jurorFees,
            bool settledPenalties,
            uint256 collectedTokens,
            uint64 coherentJurors,
            AdjudicationState state
        );


    function getAppeal(uint256 _disputeId, uint256 _roundId) external view
        returns (address maker, uint64 appealedRuling, address taker, uint64 opposedRuling);


    function getNextRoundDetails(uint256 _disputeId, uint256 _roundId) external view
        returns (
            uint64 nextRoundStartTerm,
            uint64 nextRoundJurorsNumber,
            DisputeState newDisputeState,
            ERC20 feeToken,
            uint256 totalFees,
            uint256 jurorFees,
            uint256 appealDeposit,
            uint256 confirmAppealDeposit
        );


    function getJuror(uint256 _disputeId, uint256 _roundId, address _juror) external view returns (uint64 weight, bool rewarded);

}


pragma solidity ^0.5.8;



library PctHelpers {

    using SafeMath for uint256;

    uint256 internal constant PCT_BASE = 10000; // ‱ (1 / 10,000)

    function isValid(uint16 _pct) internal pure returns (bool) {

        return _pct <= PCT_BASE;
    }

    function pct(uint256 self, uint16 _pct) internal pure returns (uint256) {

        return self.mul(uint256(_pct)) / PCT_BASE;
    }

    function pct256(uint256 self, uint256 _pct) internal pure returns (uint256) {

        return self.mul(_pct) / PCT_BASE;
    }

    function pctIncrease(uint256 self, uint16 _pct) internal pure returns (uint256) {

        return self.mul(PCT_BASE + uint256(_pct)) / PCT_BASE;
    }
}


pragma solidity ^0.5.8;


interface ICRVotingOwner {

    function ensureCanCommit(uint256 _voteId) external;


    function ensureCanCommit(uint256 _voteId, address _voter) external;


    function ensureCanReveal(uint256 _voteId, address _voter) external returns (uint64);

}


pragma solidity ^0.5.8;



interface ICRVoting {

    function create(uint256 _voteId, uint8 _possibleOutcomes) external;


    function getWinningOutcome(uint256 _voteId) external view returns (uint8);


    function getOutcomeTally(uint256 _voteId, uint8 _outcome) external view returns (uint256);


    function isValidOutcome(uint256 _voteId, uint8 _outcome) external view returns (bool);


    function getVoterOutcome(uint256 _voteId, address _voter) external view returns (uint8);


    function hasVotedInFavorOf(uint256 _voteId, uint8 _outcome, address _voter) external view returns (bool);


    function getVotersInFavorOf(uint256 _voteId, uint8 _outcome, address[] calldata _voters) external view returns (bool[] memory);

}


pragma solidity ^0.5.8;



interface ITreasury {

    function assign(ERC20 _token, address _to, uint256 _amount) external;


    function withdraw(ERC20 _token, address _to, uint256 _amount) external;

}


pragma solidity ^0.5.8;



interface IJurorsRegistry {


    function assignTokens(address _juror, uint256 _amount) external;


    function burnTokens(uint256 _amount) external;


    function draft(uint256[7] calldata _params) external returns (address[] memory jurors, uint256 length);


    function slashOrUnlock(uint64 _termId, address[] calldata _jurors, uint256[] calldata _lockedAmounts, bool[] calldata _rewardedJurors)
        external
        returns (uint256 collectedTokens);


    function collectTokens(address _juror, uint256 _amount, uint64 _termId) external returns (bool);


    function lockWithdrawals(address _juror, uint64 _termId) external;


    function activeBalanceOfAt(address _juror, uint64 _termId) external view returns (uint256);


    function totalActiveBalanceAt(uint64 _termId) external view returns (uint256);

}


pragma solidity ^0.5.8;



interface ISubscriptions {

    function isUpToDate(address _subscriber) external view returns (bool);


    function getOwedFeesDetails(address _subscriber) external view returns (ERC20, uint256, uint256);

}



pragma solidity ^0.5.8;


contract IsContract {

    function isContract(address _target) internal view returns (bool) {

        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}



pragma solidity ^0.5.8;



contract TimeHelpers {

    using Uint256Helpers for uint256;

    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }

    function getBlockNumber64() internal view returns (uint64) {

        return getBlockNumber().toUint64();
    }

    function getTimestamp() internal view returns (uint256) {

        return block.timestamp; // solium-disable-line security/no-block-members
    }

    function getTimestamp64() internal view returns (uint64) {

        return getTimestamp().toUint64();
    }
}


pragma solidity ^0.5.8;


interface IClock {

    function ensureCurrentTerm() external returns (uint64);


    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64);


    function ensureCurrentTermRandomness() external returns (bytes32);


    function getLastEnsuredTermId() external view returns (uint64);


    function getCurrentTermId() external view returns (uint64);


    function getNeededTermTransitions() external view returns (uint64);


    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness);


    function getTermRandomness(uint64 _termId) external view returns (bytes32);

}


pragma solidity ^0.5.8;





contract CourtClock is IClock, TimeHelpers {

    using SafeMath64 for uint64;

    string private constant ERROR_TERM_DOES_NOT_EXIST = "CLK_TERM_DOES_NOT_EXIST";
    string private constant ERROR_TERM_DURATION_TOO_LONG = "CLK_TERM_DURATION_TOO_LONG";
    string private constant ERROR_TERM_RANDOMNESS_NOT_YET = "CLK_TERM_RANDOMNESS_NOT_YET";
    string private constant ERROR_TERM_RANDOMNESS_UNAVAILABLE = "CLK_TERM_RANDOMNESS_UNAVAILABLE";
    string private constant ERROR_BAD_FIRST_TERM_START_TIME = "CLK_BAD_FIRST_TERM_START_TIME";
    string private constant ERROR_TOO_MANY_TRANSITIONS = "CLK_TOO_MANY_TRANSITIONS";
    string private constant ERROR_INVALID_TRANSITION_TERMS = "CLK_INVALID_TRANSITION_TERMS";
    string private constant ERROR_CANNOT_DELAY_STARTED_COURT = "CLK_CANNOT_DELAY_STARTED_COURT";
    string private constant ERROR_CANNOT_DELAY_PAST_START_TIME = "CLK_CANNOT_DELAY_PAST_START_TIME";

    uint64 internal constant MAX_AUTO_TERM_TRANSITIONS_ALLOWED = 1;

    uint64 internal constant MAX_TERM_DURATION = 365 days;

    uint64 internal constant MAX_FIRST_TERM_DELAY_PERIOD = 2 * MAX_TERM_DURATION;

    struct Term {
        uint64 startTime;              // Timestamp when the term started
        uint64 randomnessBN;           // Block number for entropy
        bytes32 randomness;            // Entropy from randomnessBN block hash
    }

    uint64 private termDuration;

    uint64 private termId;

    mapping (uint64 => Term) private terms;

    event Heartbeat(uint64 previousTermId, uint64 currentTermId);
    event StartTimeDelayed(uint64 previousStartTime, uint64 currentStartTime);

    modifier termExists(uint64 _termId) {

        require(_termId <= termId, ERROR_TERM_DOES_NOT_EXIST);
        _;
    }

    constructor(uint64[2] memory _termParams) public {
        uint64 _termDuration = _termParams[0];
        uint64 _firstTermStartTime = _termParams[1];

        require(_termDuration < MAX_TERM_DURATION, ERROR_TERM_DURATION_TOO_LONG);
        require(_firstTermStartTime >= getTimestamp64() + _termDuration, ERROR_BAD_FIRST_TERM_START_TIME);
        require(_firstTermStartTime <= getTimestamp64() + MAX_FIRST_TERM_DELAY_PERIOD, ERROR_BAD_FIRST_TERM_START_TIME);

        termDuration = _termDuration;

        terms[0].startTime = _firstTermStartTime - _termDuration;
    }

    function ensureCurrentTerm() external returns (uint64) {

        return _ensureCurrentTerm();
    }

    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64) {

        return _heartbeat(_maxRequestedTransitions);
    }

    function ensureCurrentTermRandomness() external returns (bytes32) {

        uint64 currentTermId = termId;
        Term storage term = terms[currentTermId];
        bytes32 termRandomness = term.randomness;
        if (termRandomness != bytes32(0)) {
            return termRandomness;
        }

        bytes32 newRandomness = _computeTermRandomness(currentTermId);
        require(newRandomness != bytes32(0), ERROR_TERM_RANDOMNESS_UNAVAILABLE);
        term.randomness = newRandomness;
        return newRandomness;
    }

    function getTermDuration() external view returns (uint64) {

        return termDuration;
    }

    function getLastEnsuredTermId() external view returns (uint64) {

        return _lastEnsuredTermId();
    }

    function getCurrentTermId() external view returns (uint64) {

        return _currentTermId();
    }

    function getNeededTermTransitions() external view returns (uint64) {

        return _neededTermTransitions();
    }

    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness) {

        Term storage term = terms[_termId];
        return (term.startTime, term.randomnessBN, term.randomness);
    }

    function getTermRandomness(uint64 _termId) external view termExists(_termId) returns (bytes32) {

        return _computeTermRandomness(_termId);
    }

    function _ensureCurrentTerm() internal returns (uint64) {

        uint64 requiredTransitions = _neededTermTransitions();
        require(requiredTransitions <= MAX_AUTO_TERM_TRANSITIONS_ALLOWED, ERROR_TOO_MANY_TRANSITIONS);

        if (uint256(requiredTransitions) == 0) {
            return termId;
        }

        return _heartbeat(requiredTransitions);
    }

    function _heartbeat(uint64 _maxRequestedTransitions) internal returns (uint64) {

        uint64 neededTransitions = _neededTermTransitions();
        uint256 transitions = uint256(_maxRequestedTransitions < neededTransitions ? _maxRequestedTransitions : neededTransitions);
        require(transitions > 0, ERROR_INVALID_TRANSITION_TERMS);

        uint64 blockNumber = getBlockNumber64();
        uint64 previousTermId = termId;
        uint64 currentTermId = previousTermId;
        for (uint256 transition = 1; transition <= transitions; transition++) {
            Term storage previousTerm = terms[currentTermId++];
            Term storage currentTerm = terms[currentTermId];
            _onTermTransitioned(currentTermId);

            currentTerm.startTime = previousTerm.startTime.add(termDuration);

            currentTerm.randomnessBN = blockNumber + 1;
        }

        termId = currentTermId;
        emit Heartbeat(previousTermId, currentTermId);
        return currentTermId;
    }

    function _delayStartTime(uint64 _newFirstTermStartTime) internal {

        require(_currentTermId() == 0, ERROR_CANNOT_DELAY_STARTED_COURT);

        Term storage term = terms[0];
        uint64 currentFirstTermStartTime = term.startTime.add(termDuration);
        require(_newFirstTermStartTime > currentFirstTermStartTime, ERROR_CANNOT_DELAY_PAST_START_TIME);

        term.startTime = _newFirstTermStartTime - termDuration;
        emit StartTimeDelayed(currentFirstTermStartTime, _newFirstTermStartTime);
    }

    function _onTermTransitioned(uint64 _termId) internal;


    function _lastEnsuredTermId() internal view returns (uint64) {

        return termId;
    }

    function _currentTermId() internal view returns (uint64) {

        return termId.add(_neededTermTransitions());
    }

    function _neededTermTransitions() internal view returns (uint64) {

        uint64 currentTermStartTime = terms[termId].startTime;
        if (getTimestamp64() < currentTermStartTime) {
            return uint64(0);
        }

        return (getTimestamp64() - currentTermStartTime) / termDuration;
    }

    function _computeTermRandomness(uint64 _termId) internal view returns (bytes32) {

        Term storage term = terms[_termId];
        require(getBlockNumber64() > term.randomnessBN, ERROR_TERM_RANDOMNESS_NOT_YET);
        return blockhash(term.randomnessBN);
    }
}


pragma solidity ^0.5.8;



interface IConfig {


    function getConfig(uint64 _termId) external view
        returns (
            ERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        );


    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct);


    function getMinActiveBalance(uint64 _termId) external view returns (uint256);


    function areWithdrawalsAllowedFor(address _holder) external view returns (bool);

}


pragma solidity ^0.5.8;



contract CourtConfigData {

    struct Config {
        FeesConfig fees;                        // Full fees-related config
        DisputesConfig disputes;                // Full disputes-related config
        uint256 minActiveBalance;               // Minimum amount of tokens jurors have to activate to participate in the Court
    }

    struct FeesConfig {
        ERC20 token;                            // ERC20 token to be used for the fees of the Court
        uint16 finalRoundReduction;             // Permyriad of fees reduction applied for final appeal round (‱ - 1/10,000)
        uint256 jurorFee;                       // Amount of tokens paid to draft a juror to adjudicate a dispute
        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting jurors
        uint256 settleFee;                      // Amount of tokens paid per round to cover the costs of slashing jurors
    }

    struct DisputesConfig {
        uint64 evidenceTerms;                   // Max submitting evidence period duration in terms
        uint64 commitTerms;                     // Committing period duration in terms
        uint64 revealTerms;                     // Revealing period duration in terms
        uint64 appealTerms;                     // Appealing period duration in terms
        uint64 appealConfirmTerms;              // Confirmation appeal period duration in terms
        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)
        uint64 firstRoundJurorsNumber;          // Number of jurors drafted on first round
        uint64 appealStepFactor;                // Factor in which the jurors number is increased on each appeal
        uint64 finalRoundLockTerms;             // Period a coherent juror in the final round will remain locked
        uint256 maxRegularAppealRounds;         // Before the final appeal
        uint256 appealCollateralFactor;         // Permyriad multiple of dispute fees required to appeal a preliminary ruling (‱ - 1/10,000)
        uint256 appealConfirmCollateralFactor;  // Permyriad multiple of dispute fees required to confirm appeal (‱ - 1/10,000)
    }

    struct DraftConfig {
        ERC20 feeToken;                         // ERC20 token to be used for the fees of the Court
        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted juror (‱ - 1/10,000)
        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting jurors
    }
}


pragma solidity ^0.5.8;







contract CourtConfig is IConfig, CourtConfigData {

    using SafeMath64 for uint64;
    using PctHelpers for uint256;

    string private constant ERROR_TOO_OLD_TERM = "CONF_TOO_OLD_TERM";
    string private constant ERROR_INVALID_PENALTY_PCT = "CONF_INVALID_PENALTY_PCT";
    string private constant ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT = "CONF_INVALID_FINAL_ROUND_RED_PCT";
    string private constant ERROR_INVALID_MAX_APPEAL_ROUNDS = "CONF_INVALID_MAX_APPEAL_ROUNDS";
    string private constant ERROR_LARGE_ROUND_PHASE_DURATION = "CONF_LARGE_ROUND_PHASE_DURATION";
    string private constant ERROR_BAD_INITIAL_JURORS_NUMBER = "CONF_BAD_INITIAL_JURORS_NUMBER";
    string private constant ERROR_BAD_APPEAL_STEP_FACTOR = "CONF_BAD_APPEAL_STEP_FACTOR";
    string private constant ERROR_ZERO_COLLATERAL_FACTOR = "CONF_ZERO_COLLATERAL_FACTOR";
    string private constant ERROR_ZERO_MIN_ACTIVE_BALANCE = "CONF_ZERO_MIN_ACTIVE_BALANCE";

    uint64 internal constant MAX_ADJ_STATE_DURATION = 8670;

    uint256 internal constant MAX_REGULAR_APPEAL_ROUNDS_LIMIT = 10;

    uint64 private configChangeTermId;

    Config[] private configs;

    mapping (uint64 => uint256) private configIdByTerm;

    mapping (address => bool) private withdrawalsAllowed;

    event NewConfig(uint64 fromTermId, uint64 courtConfigId);
    event AutomaticWithdrawalsAllowedChanged(address indexed holder, bool allowed);

    constructor(
        ERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
    {
        configs.length = 1;
        _setConfig(
            0,
            0,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        );
    }

    function setAutomaticWithdrawals(bool _allowed) external {

        withdrawalsAllowed[msg.sender] = _allowed;
        emit AutomaticWithdrawalsAllowedChanged(msg.sender, _allowed);
    }

    function getConfig(uint64 _termId) external view
        returns (
            ERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        );


    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct);


    function getMinActiveBalance(uint64 _termId) external view returns (uint256);


    function areWithdrawalsAllowedFor(address _holder) external view returns (bool) {

        return withdrawalsAllowed[_holder];
    }

    function getConfigChangeTermId() external view returns (uint64) {

        return configChangeTermId;
    }

    function _ensureTermConfig(uint64 _termId) internal {

        uint256 currentConfigId = configIdByTerm[_termId];
        if (currentConfigId == 0) {
            uint256 previousConfigId = configIdByTerm[_termId.sub(1)];
            configIdByTerm[_termId] = previousConfigId;
        }
    }

    function _setConfig(
        uint64 _termId,
        uint64 _fromTermId,
        ERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        internal
    {

        require(_termId == 0 || _fromTermId > _termId, ERROR_TOO_OLD_TERM);

        require(_appealCollateralParams[0] > 0 && _appealCollateralParams[1] > 0, ERROR_ZERO_COLLATERAL_FACTOR);

        require(PctHelpers.isValid(_pcts[0]), ERROR_INVALID_PENALTY_PCT);
        require(PctHelpers.isValid(_pcts[1]), ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT);

        require(_roundParams[0] > 0, ERROR_BAD_INITIAL_JURORS_NUMBER);

        require(_roundParams[1] > 0, ERROR_BAD_APPEAL_STEP_FACTOR);

        uint256 _maxRegularAppealRounds = _roundParams[2];
        bool isMaxAppealRoundsValid = _maxRegularAppealRounds > 0 && _maxRegularAppealRounds <= MAX_REGULAR_APPEAL_ROUNDS_LIMIT;
        require(isMaxAppealRoundsValid, ERROR_INVALID_MAX_APPEAL_ROUNDS);

        for (uint i = 0; i < _roundStateDurations.length; i++) {
            require(_roundStateDurations[i] > 0 && _roundStateDurations[i] < MAX_ADJ_STATE_DURATION, ERROR_LARGE_ROUND_PHASE_DURATION);
        }

        require(_minActiveBalance > 0, ERROR_ZERO_MIN_ACTIVE_BALANCE);

        if (configChangeTermId > _termId) {
            configIdByTerm[configChangeTermId] = 0;
        } else {
            configs.length++;
        }

        uint64 courtConfigId = uint64(configs.length - 1);
        Config storage config = configs[courtConfigId];

        config.fees = FeesConfig({
            token: _feeToken,
            jurorFee: _fees[0],
            draftFee: _fees[1],
            settleFee: _fees[2],
            finalRoundReduction: _pcts[1]
        });

        config.disputes = DisputesConfig({
            evidenceTerms: _roundStateDurations[0],
            commitTerms: _roundStateDurations[1],
            revealTerms: _roundStateDurations[2],
            appealTerms: _roundStateDurations[3],
            appealConfirmTerms: _roundStateDurations[4],
            penaltyPct: _pcts[0],
            firstRoundJurorsNumber: _roundParams[0],
            appealStepFactor: _roundParams[1],
            maxRegularAppealRounds: _maxRegularAppealRounds,
            finalRoundLockTerms: _roundParams[3],
            appealCollateralFactor: _appealCollateralParams[0],
            appealConfirmCollateralFactor: _appealCollateralParams[1]
        });

        config.minActiveBalance = _minActiveBalance;

        configIdByTerm[_fromTermId] = courtConfigId;
        configChangeTermId = _fromTermId;

        emit NewConfig(_fromTermId, courtConfigId);
    }

    function _getConfigAt(uint64 _termId, uint64 _lastEnsuredTermId) internal view
        returns (
            ERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        )
    {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);

        FeesConfig storage feesConfig = config.fees;
        feeToken = feesConfig.token;
        fees = [feesConfig.jurorFee, feesConfig.draftFee, feesConfig.settleFee];

        DisputesConfig storage disputesConfig = config.disputes;
        roundStateDurations = [
            disputesConfig.evidenceTerms,
            disputesConfig.commitTerms,
            disputesConfig.revealTerms,
            disputesConfig.appealTerms,
            disputesConfig.appealConfirmTerms
        ];
        pcts = [disputesConfig.penaltyPct, feesConfig.finalRoundReduction];
        roundParams = [
            disputesConfig.firstRoundJurorsNumber,
            disputesConfig.appealStepFactor,
            uint64(disputesConfig.maxRegularAppealRounds),
            disputesConfig.finalRoundLockTerms
        ];
        appealCollateralParams = [disputesConfig.appealCollateralFactor, disputesConfig.appealConfirmCollateralFactor];

        minActiveBalance = config.minActiveBalance;
    }

    function _getDraftConfig(uint64 _termId,  uint64 _lastEnsuredTermId) internal view
        returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct)
    {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);
        return (config.fees.token, config.fees.draftFee, config.disputes.penaltyPct);
    }

    function _getMinActiveBalance(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {

        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);
        return config.minActiveBalance;
    }

    function _getConfigFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (Config storage) {

        uint256 id = _getConfigIdFor(_termId, _lastEnsuredTermId);
        return configs[id];
    }

    function _getConfigIdFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {

        if (_termId <= _lastEnsuredTermId) {
            return configIdByTerm[_termId];
        }

        uint64 scheduledChangeTermId = configChangeTermId;
        if (scheduledChangeTermId <= _termId) {
            return configIdByTerm[scheduledChangeTermId];
        }

        return configIdByTerm[_lastEnsuredTermId];
    }
}


pragma solidity ^0.5.8;





contract Controller is IsContract, CourtClock, CourtConfig {

    string private constant ERROR_SENDER_NOT_GOVERNOR = "CTR_SENDER_NOT_GOVERNOR";
    string private constant ERROR_INVALID_GOVERNOR_ADDRESS = "CTR_INVALID_GOVERNOR_ADDRESS";
    string private constant ERROR_IMPLEMENTATION_NOT_CONTRACT = "CTR_IMPLEMENTATION_NOT_CONTRACT";
    string private constant ERROR_INVALID_IMPLS_INPUT_LENGTH = "CTR_INVALID_IMPLS_INPUT_LENGTH";

    address private constant ZERO_ADDRESS = address(0);

    bytes32 internal constant DISPUTE_MANAGER = 0x14a6c70f0f6d449c014c7bbc9e68e31e79e8474fb03b7194df83109a2d888ae6;

    bytes32 internal constant TREASURY = 0x06aa03964db1f7257357ef09714a5f0ca3633723df419e97015e0c7a3e83edb7;

    bytes32 internal constant VOTING = 0x7cbb12e82a6d63ff16fe43977f43e3e2b247ecd4e62c0e340da8800a48c67346;

    bytes32 internal constant JURORS_REGISTRY = 0x3b21d36b36308c830e6c4053fb40a3b6d79dde78947fbf6b0accd30720ab5370;

    bytes32 internal constant SUBSCRIPTIONS = 0x2bfa3327fe52344390da94c32a346eeb1b65a8b583e4335a419b9471e88c1365;

    struct Governor {
        address funds;      // This address can be unset at any time. It is allowed to recover funds from the ControlledRecoverable modules
        address config;     // This address is meant not to be unset. It is allowed to change the different configurations of the whole system
        address modules;    // This address can be unset at any time. It is allowed to plug/unplug modules from the system
    }

    Governor private governor;

    mapping (bytes32 => address) internal modules;

    event ModuleSet(bytes32 id, address addr);
    event FundsGovernorChanged(address previousGovernor, address currentGovernor);
    event ConfigGovernorChanged(address previousGovernor, address currentGovernor);
    event ModulesGovernorChanged(address previousGovernor, address currentGovernor);

    modifier onlyFundsGovernor {

        require(msg.sender == governor.funds, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    modifier onlyConfigGovernor {

        require(msg.sender == governor.config, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    modifier onlyModulesGovernor {

        require(msg.sender == governor.modules, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

    constructor(
        uint64[2] memory _termParams,
        address[3] memory _governors,
        ERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
        CourtClock(_termParams)
        CourtConfig(_feeToken, _fees, _roundStateDurations, _pcts, _roundParams, _appealCollateralParams, _minActiveBalance)
    {
        _setFundsGovernor(_governors[0]);
        _setConfigGovernor(_governors[1]);
        _setModulesGovernor(_governors[2]);
    }

    function setConfig(
        uint64 _fromTermId,
        ERC20 _feeToken,
        uint256[3] calldata _fees,
        uint64[5] calldata _roundStateDurations,
        uint16[2] calldata _pcts,
        uint64[4] calldata _roundParams,
        uint256[2] calldata _appealCollateralParams,
        uint256 _minActiveBalance
    )
        external
        onlyConfigGovernor
    {

        uint64 currentTermId = _ensureCurrentTerm();
        _setConfig(
            currentTermId,
            _fromTermId,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        );
    }

    function delayStartTime(uint64 _newFirstTermStartTime) external onlyConfigGovernor {

        _delayStartTime(_newFirstTermStartTime);
    }

    function changeFundsGovernor(address _newFundsGovernor) external onlyFundsGovernor {

        require(_newFundsGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setFundsGovernor(_newFundsGovernor);
    }

    function changeConfigGovernor(address _newConfigGovernor) external onlyConfigGovernor {

        require(_newConfigGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setConfigGovernor(_newConfigGovernor);
    }

    function changeModulesGovernor(address _newModulesGovernor) external onlyModulesGovernor {

        require(_newModulesGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setModulesGovernor(_newModulesGovernor);
    }

    function ejectFundsGovernor() external onlyFundsGovernor {

        _setFundsGovernor(ZERO_ADDRESS);
    }

    function ejectModulesGovernor() external onlyModulesGovernor {

        _setModulesGovernor(ZERO_ADDRESS);
    }

    function setModule(bytes32 _id, address _addr) external onlyModulesGovernor {

        _setModule(_id, _addr);
    }

    function setModules(bytes32[] calldata _ids, address[] calldata _addresses) external onlyModulesGovernor {

        require(_ids.length == _addresses.length, ERROR_INVALID_IMPLS_INPUT_LENGTH);

        for (uint256 i = 0; i < _ids.length; i++) {
            _setModule(_ids[i], _addresses[i]);
        }
    }

    function getConfig(uint64 _termId) external view
        returns (
            ERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        )
    {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getConfigAt(_termId, lastEnsuredTermId);
    }

    function getDraftConfig(uint64 _termId) external view returns (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct) {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getDraftConfig(_termId, lastEnsuredTermId);
    }

    function getMinActiveBalance(uint64 _termId) external view returns (uint256) {

        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getMinActiveBalance(_termId, lastEnsuredTermId);
    }

    function getFundsGovernor() external view returns (address) {

        return governor.funds;
    }

    function getConfigGovernor() external view returns (address) {

        return governor.config;
    }

    function getModulesGovernor() external view returns (address) {

        return governor.modules;
    }

    function getModule(bytes32 _id) external view returns (address) {

        return _getModule(_id);
    }

    function getDisputeManager() external view returns (address) {

        return _getDisputeManager();
    }

    function getTreasury() external view returns (address) {

        return _getModule(TREASURY);
    }

    function getVoting() external view returns (address) {

        return _getModule(VOTING);
    }

    function getJurorsRegistry() external view returns (address) {

        return _getModule(JURORS_REGISTRY);
    }

    function getSubscriptions() external view returns (address) {

        return _getSubscriptions();
    }

    function _setFundsGovernor(address _newFundsGovernor) internal {

        emit FundsGovernorChanged(governor.funds, _newFundsGovernor);
        governor.funds = _newFundsGovernor;
    }

    function _setConfigGovernor(address _newConfigGovernor) internal {

        emit ConfigGovernorChanged(governor.config, _newConfigGovernor);
        governor.config = _newConfigGovernor;
    }

    function _setModulesGovernor(address _newModulesGovernor) internal {

        emit ModulesGovernorChanged(governor.modules, _newModulesGovernor);
        governor.modules = _newModulesGovernor;
    }

    function _setModule(bytes32 _id, address _addr) internal {

        require(isContract(_addr), ERROR_IMPLEMENTATION_NOT_CONTRACT);
        modules[_id] = _addr;
        emit ModuleSet(_id, _addr);
    }

    function _onTermTransitioned(uint64 _termId) internal {

        _ensureTermConfig(_termId);
    }

    function _getDisputeManager() internal view returns (address) {

        return _getModule(DISPUTE_MANAGER);
    }

    function _getSubscriptions() internal view returns (address) {

        return _getModule(SUBSCRIPTIONS);
    }

    function _getModule(bytes32 _id) internal view returns (address) {

        return modules[_id];
    }
}


pragma solidity ^0.5.8;





contract ConfigConsumer is CourtConfigData {

    function _courtConfig() internal view returns (IConfig);


    function _getConfigAt(uint64 _termId) internal view returns (Config memory) {

        (ERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance) = _courtConfig().getConfig(_termId);

        Config memory config;

        config.fees = FeesConfig({
            token: _feeToken,
            jurorFee: _fees[0],
            draftFee: _fees[1],
            settleFee: _fees[2],
            finalRoundReduction: _pcts[1]
        });

        config.disputes = DisputesConfig({
            evidenceTerms: _roundStateDurations[0],
            commitTerms: _roundStateDurations[1],
            revealTerms: _roundStateDurations[2],
            appealTerms: _roundStateDurations[3],
            appealConfirmTerms: _roundStateDurations[4],
            penaltyPct: _pcts[0],
            firstRoundJurorsNumber: _roundParams[0],
            appealStepFactor: _roundParams[1],
            maxRegularAppealRounds: _roundParams[2],
            finalRoundLockTerms: _roundParams[3],
            appealCollateralFactor: _appealCollateralParams[0],
            appealConfirmCollateralFactor: _appealCollateralParams[1]
        });

        config.minActiveBalance = _minActiveBalance;

        return config;
    }

    function _getDraftConfig(uint64 _termId) internal view returns (DraftConfig memory) {

        (ERC20 feeToken, uint256 draftFee, uint16 penaltyPct) = _courtConfig().getDraftConfig(_termId);
        return DraftConfig({ feeToken: feeToken, draftFee: draftFee, penaltyPct: penaltyPct });
    }

    function _getMinActiveBalance(uint64 _termId) internal view returns (uint256) {

        return _courtConfig().getMinActiveBalance(_termId);
    }
}


pragma solidity ^0.5.8;











contract Controlled is IsContract, ConfigConsumer {

    string private constant ERROR_CONTROLLER_NOT_CONTRACT = "CTD_CONTROLLER_NOT_CONTRACT";
    string private constant ERROR_SENDER_NOT_CONTROLLER = "CTD_SENDER_NOT_CONTROLLER";
    string private constant ERROR_SENDER_NOT_CONFIG_GOVERNOR = "CTD_SENDER_NOT_CONFIG_GOVERNOR";
    string private constant ERROR_SENDER_NOT_DISPUTES_MODULE = "CTD_SENDER_NOT_DISPUTES_MODULE";

    Controller internal controller;

    modifier onlyConfigGovernor {

        require(msg.sender == _configGovernor(), ERROR_SENDER_NOT_CONFIG_GOVERNOR);
        _;
    }

    modifier onlyController() {

        require(msg.sender == address(controller), ERROR_SENDER_NOT_CONTROLLER);
        _;
    }

    modifier onlyDisputeManager() {

        require(msg.sender == address(_disputeManager()), ERROR_SENDER_NOT_DISPUTES_MODULE);
        _;
    }

    constructor(Controller _controller) public {
        require(isContract(address(_controller)), ERROR_CONTROLLER_NOT_CONTRACT);
        controller = _controller;
    }

    function getController() external view returns (Controller) {

        return controller;
    }

    function _ensureCurrentTerm() internal returns (uint64) {

        return _clock().ensureCurrentTerm();
    }

    function _getLastEnsuredTermId() internal view returns (uint64) {

        return _clock().getLastEnsuredTermId();
    }

    function _getCurrentTermId() internal view returns (uint64) {

        return _clock().getCurrentTermId();
    }

    function _configGovernor() internal view returns (address) {

        return controller.getConfigGovernor();
    }

    function _disputeManager() internal view returns (IDisputeManager) {

        return IDisputeManager(controller.getDisputeManager());
    }

    function _treasury() internal view returns (ITreasury) {

        return ITreasury(controller.getTreasury());
    }

    function _voting() internal view returns (ICRVoting) {

        return ICRVoting(controller.getVoting());
    }

    function _votingOwner() internal view returns (ICRVotingOwner) {

        return ICRVotingOwner(address(_disputeManager()));
    }

    function _jurorsRegistry() internal view returns (IJurorsRegistry) {

        return IJurorsRegistry(controller.getJurorsRegistry());
    }

    function _subscriptions() internal view returns (ISubscriptions) {

        return ISubscriptions(controller.getSubscriptions());
    }

    function _clock() internal view returns (IClock) {

        return IClock(controller);
    }

    function _courtConfig() internal view returns (IConfig) {

        return IConfig(controller);
    }
}


pragma solidity ^0.5.8;





contract ControlledRecoverable is Controlled {

    using SafeERC20 for ERC20;

    string private constant ERROR_SENDER_NOT_FUNDS_GOVERNOR = "CTD_SENDER_NOT_FUNDS_GOVERNOR";
    string private constant ERROR_INSUFFICIENT_RECOVER_FUNDS = "CTD_INSUFFICIENT_RECOVER_FUNDS";
    string private constant ERROR_RECOVER_TOKEN_FUNDS_FAILED = "CTD_RECOVER_TOKEN_FUNDS_FAILED";

    event RecoverFunds(ERC20 token, address recipient, uint256 balance);

    modifier onlyFundsGovernor {

        require(msg.sender == controller.getFundsGovernor(), ERROR_SENDER_NOT_FUNDS_GOVERNOR);
        _;
    }

    constructor(Controller _controller) Controlled(_controller) public {
    }

    function recoverFunds(ERC20 _token, address _to) external onlyFundsGovernor {

        uint256 balance = _token.balanceOf(address(this));
        require(balance > 0, ERROR_INSUFFICIENT_RECOVER_FUNDS);
        require(_token.safeTransfer(_to, balance), ERROR_RECOVER_TOKEN_FUNDS_FAILED);
        emit RecoverFunds(_token, _to, balance);
    }
}


pragma solidity ^0.5.8;
















contract DisputeManager is ControlledRecoverable, ICRVotingOwner, IDisputeManager {

    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using PctHelpers for uint256;
    using Uint256Helpers for uint256;

    string private constant ERROR_VOTER_WEIGHT_ZERO = "DM_VOTER_WEIGHT_ZERO";
    string private constant ERROR_SENDER_NOT_VOTING = "DM_SENDER_NOT_VOTING";

    string private constant ERROR_SENDER_NOT_DISPUTE_SUBJECT = "DM_SENDER_NOT_DISPUTE_SUBJECT";
    string private constant ERROR_EVIDENCE_PERIOD_IS_CLOSED = "DM_EVIDENCE_PERIOD_IS_CLOSED";
    string private constant ERROR_TERM_OUTDATED = "DM_TERM_OUTDATED";
    string private constant ERROR_DISPUTE_DOES_NOT_EXIST = "DM_DISPUTE_DOES_NOT_EXIST";
    string private constant ERROR_INVALID_RULING_OPTIONS = "DM_INVALID_RULING_OPTIONS";
    string private constant ERROR_SUBSCRIPTION_NOT_PAID = "DM_SUBSCRIPTION_NOT_PAID";
    string private constant ERROR_DEPOSIT_FAILED = "DM_DEPOSIT_FAILED";
    string private constant ERROR_BAD_MAX_DRAFT_BATCH_SIZE = "DM_BAD_MAX_DRAFT_BATCH_SIZE";

    string private constant ERROR_ROUND_IS_FINAL = "DM_ROUND_IS_FINAL";
    string private constant ERROR_ROUND_DOES_NOT_EXIST = "DM_ROUND_DOES_NOT_EXIST";
    string private constant ERROR_INVALID_ADJUDICATION_STATE = "DM_INVALID_ADJUDICATION_STATE";
    string private constant ERROR_ROUND_ALREADY_DRAFTED = "DM_ROUND_ALREADY_DRAFTED";
    string private constant ERROR_DRAFT_TERM_NOT_REACHED = "DM_DRAFT_TERM_NOT_REACHED";
    string private constant ERROR_ROUND_NOT_APPEALED = "DM_ROUND_NOT_APPEALED";
    string private constant ERROR_INVALID_APPEAL_RULING = "DM_INVALID_APPEAL_RULING";

    string private constant ERROR_PREV_ROUND_NOT_SETTLED = "DM_PREVIOUS_ROUND_NOT_SETTLED";
    string private constant ERROR_ROUND_ALREADY_SETTLED = "DM_ROUND_ALREADY_SETTLED";
    string private constant ERROR_ROUND_NOT_SETTLED = "DM_ROUND_PENALTIES_NOT_SETTLED";
    string private constant ERROR_JUROR_ALREADY_REWARDED = "DM_JUROR_ALREADY_REWARDED";
    string private constant ERROR_WONT_REWARD_NON_VOTER_JUROR = "DM_WONT_REWARD_NON_VOTER_JUROR";
    string private constant ERROR_WONT_REWARD_INCOHERENT_JUROR = "DM_WONT_REWARD_INCOHERENT_JUROR";
    string private constant ERROR_ROUND_APPEAL_ALREADY_SETTLED = "DM_APPEAL_ALREADY_SETTLED";

    uint8 internal constant MIN_RULING_OPTIONS = 2;

    uint8 internal constant MAX_RULING_OPTIONS = MIN_RULING_OPTIONS;

    uint256 internal constant FINAL_ROUND_WEIGHT_PRECISION = 1000;

    uint256 internal constant VOTE_ID_MASK = 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    struct Dispute {
        IArbitrable subject;           // Arbitrable associated to a dispute
        uint64 createTermId;           // Term ID when the dispute was created
        uint8 possibleRulings;         // Number of possible rulings jurors can vote for each dispute
        uint8 finalRuling;             // Winning ruling of a dispute
        DisputeState state;            // State of a dispute: pre-draft, adjudicating, or ruled
        AdjudicationRound[] rounds;    // List of rounds for each dispute
    }

    struct AdjudicationRound {
        uint64 draftTermId;            // Term from which the jurors of a round can be drafted
        uint64 jurorsNumber;           // Number of jurors drafted for a round
        bool settledPenalties;         // Whether or not penalties have been settled for a round
        uint256 jurorFees;             // Total amount of fees to be distributed between the winning jurors of a round
        address[] jurors;              // List of jurors drafted for a round
        mapping (address => JurorState) jurorsStates; // List of states for each drafted juror indexed by address
        uint64 delayedTerms;           // Number of terms a round was delayed based on its requested draft term id
        uint64 selectedJurors;         // Number of jurors selected for a round, to allow drafts to be batched
        uint64 coherentJurors;         // Number of drafted jurors that voted in favor of the dispute final ruling
        uint64 settledJurors;          // Number of jurors whose rewards were already settled
        uint256 collectedTokens;       // Total amount of tokens collected from losing jurors
        Appeal appeal;                 // Appeal-related information of a round
    }

    struct JurorState {
        uint64 weight;                 // Weight computed for a juror on a round
        bool rewarded;                 // Whether or not a drafted juror was rewarded
    }

    struct Appeal {
        address maker;                 // Address of the appealer
        uint8 appealedRuling;          // Ruling appealing in favor of
        address taker;                 // Address of the one confirming an appeal
        uint8 opposedRuling;           // Ruling opposed to an appeal
        bool settled;                  // Whether or not an appeal has been settled
    }

    struct DraftParams {
        uint256 disputeId;            // Identification number of the dispute to be drafted
        uint256 roundId;              // Identification number of the round to be drafted
        uint64 termId;                // Identification number of the current term of the Court
        bytes32 draftTermRandomness;  // Randomness of the term in which the dispute was requested to be drafted
        DraftConfig config;           // Draft config of the Court at the draft term
    }

    struct NextRoundDetails {
        uint64 startTerm;              // Term ID from which the next round will start
        uint64 jurorsNumber;           // Jurors number for the next round
        DisputeState newDisputeState;  // New state for the dispute associated to the given round after the appeal
        ERC20 feeToken;                // ERC20 token used for the next round fees
        uint256 totalFees;             // Total amount of fees to be distributed between the winning jurors of the next round
        uint256 jurorFees;             // Total amount of fees for a regular round at the given term
        uint256 appealDeposit;         // Amount to be deposit of fees for a regular round at the given term
        uint256 confirmAppealDeposit;  // Total amount of fees for a regular round at the given term
    }

    uint64 public maxJurorsPerDraftBatch;

    Dispute[] internal disputes;

    event DisputeStateChanged(uint256 indexed disputeId, DisputeState indexed state);
    event EvidencePeriodClosed(uint256 indexed disputeId, uint64 indexed termId);
    event NewDispute(uint256 indexed disputeId, IArbitrable indexed subject, uint64 indexed draftTermId, uint64 jurorsNumber, bytes metadata);
    event JurorDrafted(uint256 indexed disputeId, uint256 indexed roundId, address indexed juror);
    event RulingAppealed(uint256 indexed disputeId, uint256 indexed roundId, uint8 ruling);
    event RulingAppealConfirmed(uint256 indexed disputeId, uint256 indexed roundId, uint64 indexed draftTermId, uint256 jurorsNumber);
    event RulingComputed(uint256 indexed disputeId, uint8 indexed ruling);
    event PenaltiesSettled(uint256 indexed disputeId, uint256 indexed roundId, uint256 collectedTokens);
    event RewardSettled(uint256 indexed disputeId, uint256 indexed roundId, address juror, uint256 tokens, uint256 fees);
    event AppealDepositSettled(uint256 indexed disputeId, uint256 indexed roundId);
    event MaxJurorsPerDraftBatchChanged(uint64 previousMaxJurorsPerDraftBatch, uint64 currentMaxJurorsPerDraftBatch);

    modifier onlyVoting() {

        ICRVoting voting = _voting();
        require(msg.sender == address(voting), ERROR_SENDER_NOT_VOTING);
        _;
    }

    modifier disputeExists(uint256 _disputeId) {

        _checkDisputeExists(_disputeId);
        _;
    }

    modifier roundExists(uint256 _disputeId, uint256 _roundId) {

        _checkRoundExists(_disputeId, _roundId);
        _;
    }

    constructor(Controller _controller, uint64 _maxJurorsPerDraftBatch, uint256 _skippedDisputes) ControlledRecoverable(_controller) public {
        _setMaxJurorsPerDraftBatch(_maxJurorsPerDraftBatch);
        _skipDisputes(_skippedDisputes);
    }

    function createDispute(IArbitrable _subject, uint8 _possibleRulings, bytes calldata _metadata) external onlyController returns (uint256) {

        uint64 termId = _ensureCurrentTerm();
        require(_possibleRulings >= MIN_RULING_OPTIONS && _possibleRulings <= MAX_RULING_OPTIONS, ERROR_INVALID_RULING_OPTIONS);

        uint256 disputeId = disputes.length++;
        Dispute storage dispute = disputes[disputeId];
        dispute.subject = _subject;
        dispute.possibleRulings = _possibleRulings;
        dispute.createTermId = termId;

        Config memory config = _getConfigAt(termId);
        uint64 jurorsNumber = config.disputes.firstRoundJurorsNumber;
        uint64 draftTermId = termId.add(config.disputes.evidenceTerms);
        emit NewDispute(disputeId, _subject, draftTermId, jurorsNumber, _metadata);

        (ERC20 feeToken, uint256 jurorFees, uint256 totalFees) = _getRegularRoundFees(config.fees, jurorsNumber);
        _createRound(disputeId, DisputeState.PreDraft, draftTermId, jurorsNumber, jurorFees);

        _depositAmount(address(_subject), feeToken, totalFees);
        return disputeId;
    }

    function closeEvidencePeriod(IArbitrable _subject, uint256 _disputeId) external onlyController roundExists(_disputeId, 0) {

        Dispute storage dispute = disputes[_disputeId];
        AdjudicationRound storage round = dispute.rounds[0];
        require(dispute.subject == _subject, ERROR_SENDER_NOT_DISPUTE_SUBJECT);

        uint64 termId = _ensureCurrentTerm();
        uint64 newDraftTermId = termId.add(1);
        require(newDraftTermId < round.draftTermId, ERROR_EVIDENCE_PERIOD_IS_CLOSED);

        round.draftTermId = newDraftTermId;
        emit EvidencePeriodClosed(_disputeId, termId);
    }

    function draft(uint256 _disputeId) external disputeExists(_disputeId) {

        IClock clock = _clock();
        uint64 requiredTransitions = _clock().getNeededTermTransitions();
        require(uint256(requiredTransitions) == 0, ERROR_TERM_OUTDATED);
        uint64 currentTermId = _getLastEnsuredTermId();

        Dispute storage dispute = disputes[_disputeId];
        require(dispute.state == DisputeState.PreDraft, ERROR_ROUND_ALREADY_DRAFTED);

        uint256 roundId = dispute.rounds.length - 1;
        AdjudicationRound storage round = dispute.rounds[roundId];
        uint64 draftTermId = round.draftTermId;
        require(draftTermId <= currentTermId, ERROR_DRAFT_TERM_NOT_REACHED);
        bytes32 draftTermRandomness = clock.ensureCurrentTermRandomness();

        DraftConfig memory config = _getDraftConfig(draftTermId);
        bool draftEnded = _draft(round, _buildDraftParams(_disputeId, roundId, currentTermId, draftTermRandomness, config));

        if (draftEnded) {
            round.delayedTerms = currentTermId - draftTermId;
            dispute.state = DisputeState.Adjudicating;
            emit DisputeStateChanged(_disputeId, DisputeState.Adjudicating);
        }
    }

    function createAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external roundExists(_disputeId, _roundId) {

        Dispute storage dispute = disputes[_disputeId];
        Config memory config = _getDisputeConfig(dispute);
        _ensureAdjudicationState(dispute, _roundId, AdjudicationState.Appealing, config.disputes);

        ICRVoting voting = _voting();
        uint256 voteId = _getVoteId(_disputeId, _roundId);
        uint8 roundWinningRuling = voting.getWinningOutcome(voteId);
        require(roundWinningRuling != _ruling && voting.isValidOutcome(voteId, _ruling), ERROR_INVALID_APPEAL_RULING);

        AdjudicationRound storage round = dispute.rounds[_roundId];
        Appeal storage appeal = round.appeal;
        appeal.maker = msg.sender;
        appeal.appealedRuling = _ruling;
        emit RulingAppealed(_disputeId, _roundId, _ruling);

        NextRoundDetails memory nextRound = _getNextRoundDetails(round, _roundId, config);
        _depositAmount(msg.sender, nextRound.feeToken, nextRound.appealDeposit);
    }

    function confirmAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external roundExists(_disputeId, _roundId) {

        Dispute storage dispute = disputes[_disputeId];
        Config memory config = _getDisputeConfig(dispute);
        _ensureAdjudicationState(dispute, _roundId, AdjudicationState.ConfirmingAppeal, config.disputes);

        AdjudicationRound storage round = dispute.rounds[_roundId];
        Appeal storage appeal = round.appeal;
        uint256 voteId = _getVoteId(_disputeId, _roundId);
        require(appeal.appealedRuling != _ruling && _voting().isValidOutcome(voteId, _ruling), ERROR_INVALID_APPEAL_RULING);

        NextRoundDetails memory nextRound = _getNextRoundDetails(round, _roundId, config);
        DisputeState newDisputeState = nextRound.newDisputeState;
        uint256 newRoundId = _createRound(_disputeId, newDisputeState, nextRound.startTerm, nextRound.jurorsNumber, nextRound.jurorFees);

        appeal.taker = msg.sender;
        appeal.opposedRuling = _ruling;
        emit RulingAppealConfirmed(_disputeId, newRoundId, nextRound.startTerm, nextRound.jurorsNumber);

        _depositAmount(msg.sender, nextRound.feeToken, nextRound.confirmAppealDeposit);
    }

    function computeRuling(uint256 _disputeId) external disputeExists(_disputeId) returns (IArbitrable subject, uint8 finalRuling) {

        Dispute storage dispute = disputes[_disputeId];
        subject = dispute.subject;

        Config memory config = _getDisputeConfig(dispute);
        finalRuling = _ensureFinalRuling(dispute, _disputeId, config);

        if (dispute.state != DisputeState.Ruled) {
            dispute.state = DisputeState.Ruled;
            emit RulingComputed(_disputeId, finalRuling);
        }
    }

    function settlePenalties(uint256 _disputeId, uint256 _roundId, uint256 _jurorsToSettle) external roundExists(_disputeId, _roundId) {

        Dispute storage dispute = disputes[_disputeId];
        require(_roundId == 0 || dispute.rounds[_roundId - 1].settledPenalties, ERROR_PREV_ROUND_NOT_SETTLED);

        AdjudicationRound storage round = dispute.rounds[_roundId];
        require(!round.settledPenalties, ERROR_ROUND_ALREADY_SETTLED);

        Config memory config = _getDisputeConfig(dispute);
        uint8 finalRuling = _ensureFinalRuling(dispute, _disputeId, config);

        uint256 voteId = _getVoteId(_disputeId, _roundId);
        if (round.settledJurors == 0) {
            ICRVoting voting = _voting();
            round.coherentJurors = uint64(voting.getOutcomeTally(voteId, finalRuling));
        }

        ITreasury treasury = _treasury();
        ERC20 feeToken = config.fees.token;
        if (_isRegularRound(_roundId, config)) {
            uint256 jurorsSettled = _settleRegularRoundPenalties(round, voteId, finalRuling, config.disputes.penaltyPct, _jurorsToSettle, config.minActiveBalance);
            treasury.assign(feeToken, msg.sender, config.fees.settleFee.mul(jurorsSettled));
        } else {
            round.settledPenalties = true;
        }

        if (round.settledPenalties) {
            uint256 collectedTokens = round.collectedTokens;
            emit PenaltiesSettled(_disputeId, _roundId, collectedTokens);
            _burnCollectedTokensIfNecessary(dispute, round, _roundId, treasury, feeToken, collectedTokens);
        }
    }

    function settleReward(uint256 _disputeId, uint256 _roundId, address _juror) external roundExists(_disputeId, _roundId) {

        Dispute storage dispute = disputes[_disputeId];
        AdjudicationRound storage round = dispute.rounds[_roundId];
        require(round.settledPenalties, ERROR_ROUND_NOT_SETTLED);

        JurorState storage jurorState = round.jurorsStates[_juror];
        require(!jurorState.rewarded, ERROR_JUROR_ALREADY_REWARDED);
        require(uint256(jurorState.weight) > 0, ERROR_WONT_REWARD_NON_VOTER_JUROR);
        jurorState.rewarded = true;

        ICRVoting voting = _voting();
        uint256 voteId = _getVoteId(_disputeId, _roundId);
        require(voting.hasVotedInFavorOf(voteId, dispute.finalRuling, _juror), ERROR_WONT_REWARD_INCOHERENT_JUROR);

        uint256 collectedTokens = round.collectedTokens;
        IJurorsRegistry jurorsRegistry = _jurorsRegistry();

        uint256 rewardTokens;
        if (collectedTokens > 0) {
            rewardTokens = _getRoundWeightedAmount(round, jurorState, collectedTokens);
            jurorsRegistry.assignTokens(_juror, rewardTokens);
        }

        Config memory config = _getDisputeConfig(dispute);
        uint256 rewardFees = _getRoundWeightedAmount(round, jurorState, round.jurorFees);
        _treasury().assign(config.fees.token, _juror, rewardFees);

        if (!_isRegularRound(_roundId, config)) {
            DisputesConfig memory disputesConfig = config.disputes;
            jurorsRegistry.lockWithdrawals(
                _juror,
                round.draftTermId + disputesConfig.commitTerms + disputesConfig.revealTerms + disputesConfig.finalRoundLockTerms
            );
        }

        emit RewardSettled(_disputeId, _roundId, _juror, rewardTokens, rewardFees);
    }

    function settleAppealDeposit(uint256 _disputeId, uint256 _roundId) external roundExists(_disputeId, _roundId) {

        Dispute storage dispute = disputes[_disputeId];
        AdjudicationRound storage round = dispute.rounds[_roundId];
        require(round.settledPenalties, ERROR_ROUND_NOT_SETTLED);

        Appeal storage appeal = round.appeal;
        require(_existsAppeal(appeal), ERROR_ROUND_NOT_APPEALED);
        require(!appeal.settled, ERROR_ROUND_APPEAL_ALREADY_SETTLED);
        appeal.settled = true;
        emit AppealDepositSettled(_disputeId, _roundId);

        Config memory config = _getDisputeConfig(dispute);
        NextRoundDetails memory nextRound = _getNextRoundDetails(round, _roundId, config);
        ERC20 feeToken = nextRound.feeToken;
        uint256 totalFees = nextRound.totalFees;
        uint256 appealDeposit = nextRound.appealDeposit;
        uint256 confirmAppealDeposit = nextRound.confirmAppealDeposit;

        ITreasury treasury = _treasury();
        if (!_isAppealConfirmed(appeal)) {
            treasury.assign(feeToken, appeal.maker, appealDeposit);
            return;
        }

        uint8 finalRuling = dispute.finalRuling;
        uint256 totalDeposit = appealDeposit.add(confirmAppealDeposit);
        if (appeal.appealedRuling == finalRuling) {
            treasury.assign(feeToken, appeal.maker, totalDeposit.sub(totalFees));
        } else if (appeal.opposedRuling == finalRuling) {
            treasury.assign(feeToken, appeal.taker, totalDeposit.sub(totalFees));
        } else {
            uint256 feesRefund = totalFees / 2;
            treasury.assign(feeToken, appeal.maker, appealDeposit.sub(feesRefund));
            treasury.assign(feeToken, appeal.taker, confirmAppealDeposit.sub(feesRefund));
        }
    }

    function ensureCanCommit(uint256 _voteId) external {

        (Dispute storage dispute, uint256 roundId) = _decodeVoteId(_voteId);
        Config memory config = _getDisputeConfig(dispute);

        _ensureAdjudicationState(dispute, roundId, AdjudicationState.Committing, config.disputes);
    }

    function ensureCanCommit(uint256 _voteId, address _voter) external onlyVoting {

        (Dispute storage dispute, uint256 roundId) = _decodeVoteId(_voteId);
        Config memory config = _getDisputeConfig(dispute);

        _ensureAdjudicationState(dispute, roundId, AdjudicationState.Committing, config.disputes);
        uint64 weight = _computeJurorWeight(dispute, roundId, _voter, config);
        require(weight > 0, ERROR_VOTER_WEIGHT_ZERO);
    }

    function ensureCanReveal(uint256 _voteId, address _voter) external returns (uint64) {

        (Dispute storage dispute, uint256 roundId) = _decodeVoteId(_voteId);
        Config memory config = _getDisputeConfig(dispute);

        _ensureAdjudicationState(dispute, roundId, AdjudicationState.Revealing, config.disputes);
        AdjudicationRound storage round = dispute.rounds[roundId];
        return _getJurorWeight(round, _voter);
    }

    function setMaxJurorsPerDraftBatch(uint64 _maxJurorsPerDraftBatch) external onlyConfigGovernor {

        _setMaxJurorsPerDraftBatch(_maxJurorsPerDraftBatch);
    }

    function getDisputeFees() external view returns (ERC20 feeToken, uint256 totalFees) {

        uint64 currentTermId = _getCurrentTermId();
        Config memory config = _getConfigAt(currentTermId);
        (feeToken,, totalFees) = _getRegularRoundFees(config.fees, config.disputes.firstRoundJurorsNumber);
    }

    function getDispute(uint256 _disputeId) external view disputeExists(_disputeId)
        returns (IArbitrable subject, uint8 possibleRulings, DisputeState state, uint8 finalRuling, uint256 lastRoundId, uint64 createTermId)
    {

        Dispute storage dispute = disputes[_disputeId];

        subject = dispute.subject;
        possibleRulings = dispute.possibleRulings;
        state = dispute.state;
        finalRuling = dispute.finalRuling;
        createTermId = dispute.createTermId;
        lastRoundId = dispute.rounds.length - 1;
    }

    function getRound(uint256 _disputeId, uint256 _roundId) external view roundExists(_disputeId, _roundId)
        returns (
            uint64 draftTerm,
            uint64 delayedTerms,
            uint64 jurorsNumber,
            uint64 selectedJurors,
            uint256 jurorFees,
            bool settledPenalties,
            uint256 collectedTokens,
            uint64 coherentJurors,
            AdjudicationState state
        )
    {

        Dispute storage dispute = disputes[_disputeId];
        state = _adjudicationStateAt(dispute, _roundId, _getCurrentTermId(), _getDisputeConfig(dispute).disputes);

        AdjudicationRound storage round = dispute.rounds[_roundId];
        draftTerm = round.draftTermId;
        delayedTerms = round.delayedTerms;
        jurorsNumber = round.jurorsNumber;
        selectedJurors = round.selectedJurors;
        jurorFees = round.jurorFees;
        settledPenalties = round.settledPenalties;
        coherentJurors = round.coherentJurors;
        collectedTokens = round.collectedTokens;
    }

    function getAppeal(uint256 _disputeId, uint256 _roundId) external view roundExists(_disputeId, _roundId)
        returns (address maker, uint64 appealedRuling, address taker, uint64 opposedRuling)
    {

        Appeal storage appeal = disputes[_disputeId].rounds[_roundId].appeal;

        maker = appeal.maker;
        appealedRuling = appeal.appealedRuling;
        taker = appeal.taker;
        opposedRuling = appeal.opposedRuling;
    }

    function getNextRoundDetails(uint256 _disputeId, uint256 _roundId) external view
        returns (
            uint64 nextRoundStartTerm,
            uint64 nextRoundJurorsNumber,
            DisputeState newDisputeState,
            ERC20 feeToken,
            uint256 totalFees,
            uint256 jurorFees,
            uint256 appealDeposit,
            uint256 confirmAppealDeposit
        )
    {

        _checkRoundExists(_disputeId, _roundId);

        Dispute storage dispute = disputes[_disputeId];
        Config memory config = _getDisputeConfig(dispute);
        require(_isRegularRound(_roundId, config), ERROR_ROUND_IS_FINAL);

        AdjudicationRound storage round = dispute.rounds[_roundId];
        NextRoundDetails memory nextRound = _getNextRoundDetails(round, _roundId, config);
        return (
            nextRound.startTerm,
            nextRound.jurorsNumber,
            nextRound.newDisputeState,
            nextRound.feeToken,
            nextRound.totalFees,
            nextRound.jurorFees,
            nextRound.appealDeposit,
            nextRound.confirmAppealDeposit
        );
    }

    function getJuror(uint256 _disputeId, uint256 _roundId, address _juror) external view roundExists(_disputeId, _roundId)
        returns (uint64 weight, bool rewarded)
    {

        Dispute storage dispute = disputes[_disputeId];
        AdjudicationRound storage round = dispute.rounds[_roundId];
        Config memory config = _getDisputeConfig(dispute);

        if (_isRegularRound(_roundId, config)) {
            weight = _getJurorWeight(round, _juror);
        } else {
            IJurorsRegistry jurorsRegistry = _jurorsRegistry();
            uint256 activeBalance = jurorsRegistry.activeBalanceOfAt(_juror, round.draftTermId);
            weight = _getMinActiveBalanceMultiple(activeBalance, config.minActiveBalance);
        }

        rewarded = round.jurorsStates[_juror].rewarded;
    }

    function _createRound(uint256 _disputeId, DisputeState _disputeState, uint64 _draftTermId, uint64 _jurorsNumber, uint256 _jurorFees) internal
        returns (uint256)
    {

        Dispute storage dispute = disputes[_disputeId];
        dispute.state = _disputeState;

        uint256 roundId = dispute.rounds.length++;
        AdjudicationRound storage round = dispute.rounds[roundId];
        round.draftTermId = _draftTermId;
        round.jurorsNumber = _jurorsNumber;
        round.jurorFees = _jurorFees;

        ICRVoting voting = _voting();
        uint256 voteId = _getVoteId(_disputeId, roundId);
        voting.create(voteId, dispute.possibleRulings);
        return roundId;
    }

    function _ensureAdjudicationState(Dispute storage _dispute, uint256 _roundId, AdjudicationState _state, DisputesConfig memory _config)
        internal
    {

        uint64 termId = _ensureCurrentTerm();
        AdjudicationState roundState = _adjudicationStateAt(_dispute, _roundId, termId, _config);
        require(roundState == _state, ERROR_INVALID_ADJUDICATION_STATE);
    }

    function _ensureFinalRuling(Dispute storage _dispute, uint256 _disputeId, Config memory _config) internal returns (uint8) {

        if (uint256(_dispute.finalRuling) > 0) {
            return _dispute.finalRuling;
        }

        uint256 lastRoundId = _dispute.rounds.length - 1;
        _ensureAdjudicationState(_dispute, lastRoundId, AdjudicationState.Ended, _config.disputes);

        AdjudicationRound storage lastRound = _dispute.rounds[lastRoundId];
        Appeal storage lastAppeal = lastRound.appeal;
        bool isRoundAppealedAndNotConfirmed = _existsAppeal(lastAppeal) && !_isAppealConfirmed(lastAppeal);
        uint8 finalRuling = isRoundAppealedAndNotConfirmed
            ? lastAppeal.appealedRuling
            : _voting().getWinningOutcome(_getVoteId(_disputeId, lastRoundId));

        _dispute.finalRuling = finalRuling;
        return finalRuling;
    }

    function _settleRegularRoundPenalties(
        AdjudicationRound storage _round,
        uint256 _voteId,
        uint8 _finalRuling,
        uint16 _penaltyPct,
        uint256 _jurorsToSettle,
        uint256 _minActiveBalance
    )
        internal
        returns (uint256)
    {

        uint64 termId = _ensureCurrentTerm();
        uint256 roundSettledJurors = _round.settledJurors;
        uint256 batchSettledJurors = _round.jurors.length.sub(roundSettledJurors);

        if (_jurorsToSettle > 0 && batchSettledJurors > _jurorsToSettle) {
            batchSettledJurors = _jurorsToSettle;
        } else {
            _round.settledPenalties = true;
        }

        _round.settledJurors = uint64(roundSettledJurors.add(batchSettledJurors));

        IJurorsRegistry jurorsRegistry = _jurorsRegistry();
        address[] memory jurors = new address[](batchSettledJurors);
        uint256[] memory penalties = new uint256[](batchSettledJurors);
        for (uint256 i = 0; i < batchSettledJurors; i++) {
            address juror = _round.jurors[roundSettledJurors + i];
            jurors[i] = juror;
            penalties[i] = _minActiveBalance.pct(_penaltyPct).mul(_round.jurorsStates[juror].weight);
        }

        bool[] memory jurorsInFavor = _voting().getVotersInFavorOf(_voteId, _finalRuling, jurors);
        _round.collectedTokens = _round.collectedTokens.add(jurorsRegistry.slashOrUnlock(termId, jurors, penalties, jurorsInFavor));
        return batchSettledJurors;
    }

    function _computeJurorWeight(Dispute storage _dispute, uint256 _roundId, address _juror, Config memory _config) internal returns (uint64) {

        AdjudicationRound storage round = _dispute.rounds[_roundId];

        return _isRegularRound(_roundId, _config)
            ? _getJurorWeight(round, _juror)
            : _computeJurorWeightForFinalRound(_config, round, _juror);
    }

    function _computeJurorWeightForFinalRound(Config memory _config, AdjudicationRound storage _round, address _juror) internal
        returns (uint64)
    {

        IJurorsRegistry jurorsRegistry = _jurorsRegistry();
        uint256 activeBalance = jurorsRegistry.activeBalanceOfAt(_juror, _round.draftTermId);
        uint64 weight = _getMinActiveBalanceMultiple(activeBalance, _config.minActiveBalance);

        if (weight == 0) {
            return uint64(0);
        }

        uint256 weightedPenalty = activeBalance.pct(_config.disputes.penaltyPct);

        if (!jurorsRegistry.collectTokens(_juror, weightedPenalty, _getLastEnsuredTermId())) {
            return uint64(0);
        }

        _round.jurorsStates[_juror].weight = weight;
        _round.collectedTokens = _round.collectedTokens.add(weightedPenalty);

        return weight;
    }

    function _setMaxJurorsPerDraftBatch(uint64 _maxJurorsPerDraftBatch) internal {

        require(_maxJurorsPerDraftBatch > 0, ERROR_BAD_MAX_DRAFT_BATCH_SIZE);
        emit MaxJurorsPerDraftBatchChanged(maxJurorsPerDraftBatch, _maxJurorsPerDraftBatch);
        maxJurorsPerDraftBatch = _maxJurorsPerDraftBatch;
    }

    function _depositAmount(address _from, ERC20 _token, uint256 _amount) internal {

        if (_amount > 0) {
            ITreasury treasury = _treasury();
            require(_token.safeTransferFrom(_from, address(treasury), _amount), ERROR_DEPOSIT_FAILED);
        }
    }

    function _getJurorWeight(AdjudicationRound storage _round, address _juror) internal view returns (uint64) {

        return _round.jurorsStates[_juror].weight;
    }

    function _getNextRoundDetails(AdjudicationRound storage _round, uint256 _roundId, Config memory _config) internal view
        returns (NextRoundDetails memory)
    {

        NextRoundDetails memory nextRound;
        DisputesConfig memory disputesConfig = _config.disputes;

        uint64 delayedDraftTerm = _round.draftTermId.add(_round.delayedTerms);
        uint64 currentRoundAppealStartTerm = delayedDraftTerm.add(disputesConfig.commitTerms).add(disputesConfig.revealTerms);
        nextRound.startTerm = currentRoundAppealStartTerm.add(disputesConfig.appealTerms).add(disputesConfig.appealConfirmTerms);

        if (_roundId >= disputesConfig.maxRegularAppealRounds.sub(1)) {
            nextRound.newDisputeState = DisputeState.Adjudicating;
            IJurorsRegistry jurorsRegistry = _jurorsRegistry();
            uint256 totalActiveBalance = jurorsRegistry.totalActiveBalanceAt(nextRound.startTerm);
            uint64 jurorsNumber = _getMinActiveBalanceMultiple(totalActiveBalance, _config.minActiveBalance);
            nextRound.jurorsNumber = jurorsNumber;
            (nextRound.feeToken, nextRound.jurorFees, nextRound.totalFees) = _getFinalRoundFees(_config.fees, jurorsNumber);
        } else {
            nextRound.newDisputeState = DisputeState.PreDraft;
            nextRound.jurorsNumber = _getNextRegularRoundJurorsNumber(_round, disputesConfig);
            (nextRound.feeToken, nextRound.jurorFees, nextRound.totalFees) = _getRegularRoundFees(_config.fees, nextRound.jurorsNumber);
        }

        nextRound.appealDeposit = nextRound.totalFees.pct256(disputesConfig.appealCollateralFactor);
        nextRound.confirmAppealDeposit = nextRound.totalFees.pct256(disputesConfig.appealConfirmCollateralFactor);
        return nextRound;
    }

    function _getNextRegularRoundJurorsNumber(AdjudicationRound storage _round, DisputesConfig memory _config) internal view returns (uint64) {

        uint64 jurorsNumber = _round.jurorsNumber.mul(_config.appealStepFactor);
        if (uint256(jurorsNumber) % 2 == 0) {
            jurorsNumber++;
        }
        return jurorsNumber;
    }

    function _adjudicationStateAt(Dispute storage _dispute, uint256 _roundId, uint64 _termId, DisputesConfig memory _config) internal view
        returns (AdjudicationState)
    {

        AdjudicationRound storage round = _dispute.rounds[_roundId];

        uint256 numberOfRounds = _dispute.rounds.length;
        if (_dispute.state == DisputeState.Ruled || _roundId < numberOfRounds.sub(1)) {
            return AdjudicationState.Ended;
        }

        uint64 draftFinishedTermId = round.draftTermId.add(round.delayedTerms);
        if (_dispute.state == DisputeState.PreDraft || _termId < draftFinishedTermId) {
            return AdjudicationState.Invalid;
        }

        uint64 revealStartTerm = draftFinishedTermId.add(_config.commitTerms);
        if (_termId < revealStartTerm) {
            return AdjudicationState.Committing;
        }

        uint64 appealStartTerm = revealStartTerm.add(_config.revealTerms);
        if (_termId < appealStartTerm) {
            return AdjudicationState.Revealing;
        }

        bool maxAppealReached = numberOfRounds > _config.maxRegularAppealRounds;
        if (maxAppealReached) {
            return AdjudicationState.Ended;
        }

        bool isLastRoundAppealed = _existsAppeal(round.appeal);
        uint64 appealConfirmationStartTerm = appealStartTerm.add(_config.appealTerms);
        if (!isLastRoundAppealed) {
            if (_termId < appealConfirmationStartTerm) {
                return AdjudicationState.Appealing;
            } else {
                return AdjudicationState.Ended;
            }
        }

        uint64 appealConfirmationEndTerm = appealConfirmationStartTerm.add(_config.appealConfirmTerms);
        if (_termId < appealConfirmationEndTerm) {
            return AdjudicationState.ConfirmingAppeal;
        }

        return AdjudicationState.Ended;
    }

    function _getDisputeConfig(Dispute storage _dispute) internal view returns (Config memory) {

        return _getConfigAt(_dispute.createTermId);
    }

    function _existsAppeal(Appeal storage _appeal) internal view returns (bool) {

        return _appeal.maker != address(0);
    }

    function _isAppealConfirmed(Appeal storage _appeal) internal view returns (bool) {

        return _appeal.taker != address(0);
    }

    function _checkDisputeExists(uint256 _disputeId) internal view {

        require(_disputeId < disputes.length, ERROR_DISPUTE_DOES_NOT_EXIST);
    }

    function _checkRoundExists(uint256 _disputeId, uint256 _roundId) internal view {

        _checkDisputeExists(_disputeId);
        require(_roundId < disputes[_disputeId].rounds.length, ERROR_ROUND_DOES_NOT_EXIST);
    }

    function _decodeVoteId(uint256 _voteId) internal view returns (Dispute storage dispute, uint256 roundId) {

        uint256 disputeId = _voteId >> 128;
        roundId = _voteId & VOTE_ID_MASK;
        _checkRoundExists(disputeId, roundId);
        dispute = disputes[disputeId];
    }

    function _getVoteId(uint256 _disputeId, uint256 _roundId) internal pure returns (uint256) {

        return (_disputeId << 128) + _roundId;
    }

    function _getRoundWeightedAmount(
        AdjudicationRound storage _round,
        JurorState storage _jurorState,
        uint256 _amount
    )
        internal
        view
        returns (uint256)
    {

        return _amount.mul(_jurorState.weight) / _round.coherentJurors;
    }

    function _getRegularRoundFees(FeesConfig memory _config, uint64 _jurorsNumber) internal pure
        returns (ERC20 feeToken, uint256 jurorFees, uint256 totalFees)
    {

        feeToken = _config.token;
        jurorFees = uint256(_jurorsNumber).mul(_config.jurorFee);
        uint256 draftAndSettleFees = (_config.draftFee.add(_config.settleFee)).mul(uint256(_jurorsNumber));
        totalFees = jurorFees.add(draftAndSettleFees);
    }

    function _getFinalRoundFees(FeesConfig memory _config, uint64 _jurorsNumber) internal pure
        returns (ERC20 feeToken, uint256 jurorFees, uint256 totalFees)
    {

        feeToken = _config.token;
        jurorFees = (uint256(_jurorsNumber).mul(_config.jurorFee) / FINAL_ROUND_WEIGHT_PRECISION).pct(_config.finalRoundReduction);
        totalFees = jurorFees;
    }

    function _isRegularRound(uint256 _roundId, Config memory _config) internal pure returns (bool) {

        return _roundId < _config.disputes.maxRegularAppealRounds;
    }

    function _getMinActiveBalanceMultiple(uint256 _activeBalance, uint256 _minActiveBalance) internal pure returns (uint64) {

        if (_activeBalance < _minActiveBalance) {
            return 0;
        }

        return (FINAL_ROUND_WEIGHT_PRECISION.mul(_activeBalance) / _minActiveBalance).toUint64();
    }

    function _buildDraftParams(uint256 _disputeId, uint256 _roundId, uint64 _termId, bytes32 _draftTermRandomness, DraftConfig memory _config)
        private
        pure
        returns (DraftParams memory)
    {

        return DraftParams({
            disputeId: _disputeId,
            roundId: _roundId,
            termId: _termId,
            draftTermRandomness: _draftTermRandomness,
            config: _config
        });
    }

    function _draft(AdjudicationRound storage _round, DraftParams memory _draftParams) private returns (bool) {

        uint64 jurorsNumber = _round.jurorsNumber;
        uint64 selectedJurors = _round.selectedJurors;
        uint64 maxJurorsPerBatch = maxJurorsPerDraftBatch;
        uint64 jurorsToBeDrafted = jurorsNumber.sub(selectedJurors);
        uint64 requestedJurors = jurorsToBeDrafted < maxJurorsPerBatch ? jurorsToBeDrafted : maxJurorsPerBatch;

        uint256[7] memory params = [
            uint256(_draftParams.draftTermRandomness),
            _draftParams.disputeId,
            uint256(_draftParams.termId),
            uint256(selectedJurors),
            uint256(requestedJurors),
            uint256(jurorsNumber),
            uint256(_draftParams.config.penaltyPct)
        ];

        IJurorsRegistry jurorsRegistry = _jurorsRegistry();
        (address[] memory jurors, uint256 draftedJurors) = jurorsRegistry.draft(params);

        uint64 newSelectedJurors = selectedJurors.add(uint64(draftedJurors));
        _round.selectedJurors = newSelectedJurors;
        _updateRoundDraftedJurors(_draftParams.disputeId, _draftParams.roundId, _round, jurors, draftedJurors);
        bool draftEnded = newSelectedJurors == jurorsNumber;

        uint256 draftFees = _draftParams.config.draftFee.mul(draftedJurors);
        _treasury().assign(_draftParams.config.feeToken, msg.sender, draftFees);
        return draftEnded;
    }

    function _updateRoundDraftedJurors(
        uint256 _disputeId,
        uint256 _roundId,
        AdjudicationRound storage _round,
        address[] memory _jurors,
        uint256 _draftedJurors
    )
        private
    {

        for (uint256 i = 0; i < _draftedJurors; i++) {
            address juror = _jurors[i];
            JurorState storage jurorState = _round.jurorsStates[juror];

            if (uint256(jurorState.weight) == 0) {
                _round.jurors.push(juror);
            }

            jurorState.weight = jurorState.weight.add(1);
            emit JurorDrafted(_disputeId, _roundId, juror);
        }
    }

    function _burnCollectedTokensIfNecessary(
        Dispute storage _dispute,
        AdjudicationRound storage _round,
        uint256 _roundId,
        ITreasury _courtTreasury,
        ERC20 _feeToken,
        uint256 _collectedTokens
    )
        private
    {

        if (_round.coherentJurors > 0) {
            return;
        }

        if (_collectedTokens > 0) {
            IJurorsRegistry jurorsRegistry = _jurorsRegistry();
            jurorsRegistry.burnTokens(_collectedTokens);
        }

        if (_roundId == 0) {
            _courtTreasury.assign(_feeToken, address(_dispute.subject), _round.jurorFees);
        } else {
            uint256 refundFees = _round.jurorFees / 2;
            Appeal storage triggeringAppeal = _dispute.rounds[_roundId - 1].appeal;
            _courtTreasury.assign(_feeToken, triggeringAppeal.maker, refundFees);
            _courtTreasury.assign(_feeToken, triggeringAppeal.taker, refundFees);
        }
    }

    function _skipDisputes(uint256 _skippedDisputes) private {

        assert(disputes.length == 0);
        disputes.length = _skippedDisputes;
    }
}