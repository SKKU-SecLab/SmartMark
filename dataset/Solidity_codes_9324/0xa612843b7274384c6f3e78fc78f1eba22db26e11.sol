


// Adapted to use pragma ^0.5.8 and satisfy our linter rules

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
        uint16 finalRoundReduction;             // Permyriad of fees reduction applied for final appeal round (??? - 1/10,000)
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
        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted juror (??? - 1/10,000)
        uint64 firstRoundJurorsNumber;          // Number of jurors drafted on first round
        uint64 appealStepFactor;                // Factor in which the jurors number is increased on each appeal
        uint64 finalRoundLockTerms;             // Period a coherent juror in the final round will remain locked
        uint256 maxRegularAppealRounds;         // Before the final appeal
        uint256 appealCollateralFactor;         // Permyriad multiple of dispute fees required to appeal a preliminary ruling (??? - 1/10,000)
        uint256 appealConfirmCollateralFactor;  // Permyriad multiple of dispute fees required to confirm appeal (??? - 1/10,000)
    }

    struct DraftConfig {
        ERC20 feeToken;                         // ERC20 token to be used for the fees of the Court
        uint16 penaltyPct;                      // Permyriad of min active tokens balance to be locked for each drafted juror (??? - 1/10,000)
        uint256 draftFee;                       // Amount of tokens paid per round to cover the costs of drafting jurors
    }
}


pragma solidity ^0.5.8;



library PctHelpers {

    using SafeMath for uint256;

    uint256 internal constant PCT_BASE = 10000; // ??? (1 / 10,000)

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



interface ISubscriptions {

    function isUpToDate(address _subscriber) external view returns (bool);


    function getOwedFeesDetails(address _subscriber) external view returns (ERC20, uint256, uint256);

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







contract CRVoting is Controlled, ICRVoting {

    using SafeMath for uint256;

    string private constant ERROR_VOTE_ALREADY_EXISTS = "CRV_VOTE_ALREADY_EXISTS";
    string private constant ERROR_VOTE_DOES_NOT_EXIST = "CRV_VOTE_DOES_NOT_EXIST";
    string private constant ERROR_VOTE_ALREADY_COMMITTED = "CRV_VOTE_ALREADY_COMMITTED";
    string private constant ERROR_VOTE_ALREADY_REVEALED = "CRV_VOTE_ALREADY_REVEALED";
    string private constant ERROR_INVALID_OUTCOME = "CRV_INVALID_OUTCOME";
    string private constant ERROR_INVALID_OUTCOMES_AMOUNT = "CRV_INVALID_OUTCOMES_AMOUNT";
    string private constant ERROR_INVALID_COMMITMENT_SALT = "CRV_INVALID_COMMITMENT_SALT";

    uint8 internal constant OUTCOME_MISSING = uint8(0);
    uint8 internal constant OUTCOME_LEAKED = uint8(1);
    uint8 internal constant OUTCOME_REFUSED = uint8(2);
    uint8 internal constant MIN_POSSIBLE_OUTCOMES = uint8(2);
    uint8 internal constant MAX_POSSIBLE_OUTCOMES = uint8(-1) - 3;

    struct CastVote {
        bytes32 commitment;                         // Hash of the outcome casted by the voter
        uint8 outcome;                              // Outcome submitted by the voter
    }

    struct Vote {
        uint8 winningOutcome;                       // Outcome winner of a vote instance
        uint8 maxAllowedOutcome;                    // Highest outcome allowed for the vote instance
        mapping (address => CastVote) votes;        // Mapping of voters addresses to their casted votes
        mapping (uint8 => uint256) outcomesTally;   // Tally for each of the possible outcomes
    }

    mapping (uint256 => Vote) internal voteRecords;

    event VotingCreated(uint256 indexed voteId, uint8 possibleOutcomes);
    event VoteCommitted(uint256 indexed voteId, address indexed voter, bytes32 commitment);
    event VoteRevealed(uint256 indexed voteId, address indexed voter, uint8 outcome);
    event VoteLeaked(uint256 indexed voteId, address indexed voter, uint8 outcome, address leaker);

    modifier voteExists(uint256 _voteId) {

        Vote storage vote = voteRecords[_voteId];
        require(_existsVote(vote), ERROR_VOTE_DOES_NOT_EXIST);
        _;
    }

    constructor(Controller _controller) Controlled(_controller) public {
    }

    function create(uint256 _voteId, uint8 _possibleOutcomes) external onlyDisputeManager {

        require(_possibleOutcomes >= MIN_POSSIBLE_OUTCOMES && _possibleOutcomes <= MAX_POSSIBLE_OUTCOMES, ERROR_INVALID_OUTCOMES_AMOUNT);

        Vote storage vote = voteRecords[_voteId];
        require(!_existsVote(vote), ERROR_VOTE_ALREADY_EXISTS);

        vote.maxAllowedOutcome = OUTCOME_REFUSED + _possibleOutcomes;
        emit VotingCreated(_voteId, _possibleOutcomes);
    }

    function commit(uint256 _voteId, bytes32 _commitment) external voteExists(_voteId) {

        CastVote storage castVote = voteRecords[_voteId].votes[msg.sender];
        require(castVote.commitment == bytes32(0), ERROR_VOTE_ALREADY_COMMITTED);
        _ensureVoterCanCommit(_voteId, msg.sender);

        castVote.commitment = _commitment;
        emit VoteCommitted(_voteId, msg.sender, _commitment);
    }

    function leak(uint256 _voteId, address _voter, uint8 _outcome, bytes32 _salt) external voteExists(_voteId) {

        CastVote storage castVote = voteRecords[_voteId].votes[_voter];
        _checkValidSalt(castVote, _outcome, _salt);
        _ensureCanCommit(_voteId);

        castVote.outcome = OUTCOME_LEAKED;
        emit VoteLeaked(_voteId, _voter, _outcome, msg.sender);
    }

    function reveal(uint256 _voteId, uint8 _outcome, bytes32 _salt) external voteExists(_voteId) {

        Vote storage vote = voteRecords[_voteId];
        CastVote storage castVote = vote.votes[msg.sender];
        _checkValidSalt(castVote, _outcome, _salt);
        require(_isValidOutcome(vote, _outcome), ERROR_INVALID_OUTCOME);

        uint256 weight = _ensureVoterCanReveal(_voteId, msg.sender);

        castVote.outcome = _outcome;
        _updateTally(vote, _outcome, weight);
        emit VoteRevealed(_voteId, msg.sender, _outcome);
    }

    function getMaxAllowedOutcome(uint256 _voteId) external view voteExists(_voteId) returns (uint8) {

        Vote storage vote = voteRecords[_voteId];
        return vote.maxAllowedOutcome;
    }

    function getWinningOutcome(uint256 _voteId) external view voteExists(_voteId) returns (uint8) {

        Vote storage vote = voteRecords[_voteId];
        uint8 winningOutcome = vote.winningOutcome;
        return winningOutcome == OUTCOME_MISSING ? OUTCOME_REFUSED : winningOutcome;
    }

    function getOutcomeTally(uint256 _voteId, uint8 _outcome) external view voteExists(_voteId) returns (uint256) {

        Vote storage vote = voteRecords[_voteId];
        return vote.outcomesTally[_outcome];
    }

    function isValidOutcome(uint256 _voteId, uint8 _outcome) external view voteExists(_voteId) returns (bool) {

        Vote storage vote = voteRecords[_voteId];
        return _isValidOutcome(vote, _outcome);
    }

    function getVoterOutcome(uint256 _voteId, address _voter) external view voteExists(_voteId) returns (uint8) {

        Vote storage vote = voteRecords[_voteId];
        return vote.votes[_voter].outcome;
    }

    function hasVotedInFavorOf(uint256 _voteId, uint8 _outcome, address _voter) external view voteExists(_voteId) returns (bool) {

        Vote storage vote = voteRecords[_voteId];
        return vote.votes[_voter].outcome == _outcome;
    }

    function getVotersInFavorOf(uint256 _voteId, uint8 _outcome, address[] calldata _voters) external view voteExists(_voteId)
        returns (bool[] memory)
    {

        Vote storage vote = voteRecords[_voteId];
        bool[] memory votersInFavor = new bool[](_voters.length);

        for (uint256 i = 0; i < _voters.length; i++) {
            votersInFavor[i] = _outcome == vote.votes[_voters[i]].outcome;
        }
        return votersInFavor;
    }

    function hashVote(uint8 _outcome, bytes32 _salt) external pure returns (bytes32) {

        return _hashVote(_outcome, _salt);
    }

    function _ensureCanCommit(uint256 _voteId) internal {

        ICRVotingOwner owner = _votingOwner();
        owner.ensureCanCommit(_voteId);
    }

    function _ensureVoterCanCommit(uint256 _voteId, address _voter) internal {

        ICRVotingOwner owner = _votingOwner();
        owner.ensureCanCommit(_voteId, _voter);
    }

    function _ensureVoterCanReveal(uint256 _voteId, address _voter) internal returns (uint256) {

        ICRVotingOwner owner = _votingOwner();
        uint64 weight = owner.ensureCanReveal(_voteId, _voter);
        return uint256(weight);
    }

    function _checkValidSalt(CastVote storage _castVote, uint8 _outcome, bytes32 _salt) internal view {

        require(_castVote.outcome == OUTCOME_MISSING, ERROR_VOTE_ALREADY_REVEALED);
        require(_castVote.commitment == _hashVote(_outcome, _salt), ERROR_INVALID_COMMITMENT_SALT);
    }

    function _isValidOutcome(Vote storage _vote, uint8 _outcome) internal view returns (bool) {

        return _outcome >= OUTCOME_REFUSED && _outcome <= _vote.maxAllowedOutcome;
    }

    function _existsVote(Vote storage _vote) internal view returns (bool) {

        return _vote.maxAllowedOutcome != OUTCOME_MISSING;
    }

    function _hashVote(uint8 _outcome, bytes32 _salt) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_outcome, _salt));
    }

    function _updateTally(Vote storage _vote, uint8 _outcome, uint256 _weight) private {

        if (!_isValidOutcome(_vote, _outcome)) {
            return;
        }

        uint256 newOutcomeTally = _vote.outcomesTally[_outcome].add(_weight);
        _vote.outcomesTally[_outcome] = newOutcomeTally;

        uint8 winningOutcome = _vote.winningOutcome;
        uint256 winningOutcomeTally = _vote.outcomesTally[winningOutcome];
        if (newOutcomeTally > winningOutcomeTally || (newOutcomeTally == winningOutcomeTally && _outcome < winningOutcome)) {
            _vote.winningOutcome = _outcome;
        }
    }
}