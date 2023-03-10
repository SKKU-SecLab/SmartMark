

pragma solidity ^0.8.6;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BalanceHolder {


    IERC20 public token;

    mapping(address => uint256) public balanceOf;

    event LogWithdraw(
        address indexed user,
        uint256 amount
    );

    function withdraw() 
    public {

        uint256 bal = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        require(token.transfer(msg.sender, bal));
        emit LogWithdraw(msg.sender, bal);
    }

}


contract RealityETH_ERC20_v3_0 is BalanceHolder {


    address constant NULL_ADDRESS = address(0);

    bytes32 constant NULL_HASH = bytes32(0);

    uint32 constant UNANSWERED = 0;

    uint256 constant COMMITMENT_NON_EXISTENT = 0;

    uint32 constant COMMITMENT_TIMEOUT_RATIO = 8;

    uint256 constant BOND_CLAIM_FEE_PROPORTION = 40; // One 40th ie 2.5%

    bytes32 constant UNRESOLVED_ANSWER = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe;

    event LogSetQuestionFee(
        address arbitrator,
        uint256 amount
    );

    event LogNewTemplate(
        uint256 indexed template_id,
        address indexed user, 
        string question_text
    );

    event LogNewQuestion(
        bytes32 indexed question_id,
        address indexed user, 
        uint256 template_id,
        string question,
        bytes32 indexed content_hash,
        address arbitrator, 
        uint32 timeout,
        uint32 opening_ts,
        uint256 nonce,
        uint256 created
    );

    event LogMinimumBond(
        bytes32 indexed question_id,
        uint256 min_bond
    );

    event LogFundAnswerBounty(
        bytes32 indexed question_id,
        uint256 bounty_added,
        uint256 bounty,
        address indexed user 
    );

    event LogNewAnswer(
        bytes32 answer,
        bytes32 indexed question_id,
        bytes32 history_hash,
        address indexed user,
        uint256 bond,
        uint256 ts,
        bool is_commitment
    );

    event LogAnswerReveal(
        bytes32 indexed question_id, 
        address indexed user, 
        bytes32 indexed answer_hash, 
        bytes32 answer, 
        uint256 nonce, 
        uint256 bond
    );

    event LogNotifyOfArbitrationRequest(
        bytes32 indexed question_id,
        address indexed user 
    );

    event LogCancelArbitration(
        bytes32 indexed question_id
    );

    event LogFinalize(
        bytes32 indexed question_id,
        bytes32 indexed answer
    );

    event LogClaim(
        bytes32 indexed question_id,
        address indexed user,
        uint256 amount
    );

    event LogReopenQuestion(
        bytes32 indexed question_id,
        bytes32 indexed reopened_question_id
    );

    struct Question {
        bytes32 content_hash;
        address arbitrator;
        uint32 opening_ts;
        uint32 timeout;
        uint32 finalize_ts;
        bool is_pending_arbitration;
        uint256 bounty;
        bytes32 best_answer;
        bytes32 history_hash;
        uint256 bond;
        uint256 min_bond;
    }

    struct Commitment {
        uint32 reveal_ts;
        bool is_revealed;
        bytes32 revealed_answer;
    }

    struct Claim {
        address payee;
        uint256 last_bond;
        uint256 queued_funds;
    }

    uint256 nextTemplateID = 0;
    mapping(uint256 => uint256) public templates;
    mapping(uint256 => bytes32) public template_hashes;
    mapping(bytes32 => Question) public questions;
    mapping(bytes32 => Claim) public question_claims;
    mapping(bytes32 => Commitment) public commitments;
    mapping(address => uint256) public arbitrator_question_fees; 
    mapping(bytes32 => bytes32) public reopened_questions;
    mapping(bytes32 => bool) public reopener_questions;


    modifier onlyArbitrator(bytes32 question_id) {

        require(msg.sender == questions[question_id].arbitrator, "msg.sender must be arbitrator");
        _;
    }

    modifier stateAny() {

        _;
    }

    modifier stateNotCreated(bytes32 question_id) {

        require(questions[question_id].timeout == 0, "question must not exist");
        _;
    }

    modifier stateOpen(bytes32 question_id) {

        require(questions[question_id].timeout > 0, "question must exist");
        require(!questions[question_id].is_pending_arbitration, "question must not be pending arbitration");
        uint32 finalize_ts = questions[question_id].finalize_ts;
        require(finalize_ts == UNANSWERED || finalize_ts > uint32(block.timestamp), "finalization deadline must not have passed");
        uint32 opening_ts = questions[question_id].opening_ts;
        require(opening_ts == 0 || opening_ts <= uint32(block.timestamp), "opening date must have passed"); 
        _;
    }

    modifier statePendingArbitration(bytes32 question_id) {

        require(questions[question_id].is_pending_arbitration, "question must be pending arbitration");
        _;
    }

    modifier stateOpenOrPendingArbitration(bytes32 question_id) {

        require(questions[question_id].timeout > 0, "question must exist");
        uint32 finalize_ts = questions[question_id].finalize_ts;
        require(finalize_ts == UNANSWERED || finalize_ts > uint32(block.timestamp), "finalization dealine must not have passed");
        uint32 opening_ts = questions[question_id].opening_ts;
        require(opening_ts == 0 || opening_ts <= uint32(block.timestamp), "opening date must have passed"); 
        _;
    }

    modifier stateFinalized(bytes32 question_id) {

        require(isFinalized(question_id), "question must be finalized");
        _;
    }

    modifier bondMustDoubleAndMatchMinimum(bytes32 question_id, uint256 tokens) {

        require(tokens > 0, "bond must be positive"); 
        uint256 current_bond = questions[question_id].bond;
        if (current_bond == 0) {
            require(tokens >= (questions[question_id].min_bond), "bond must exceed the minimum");
        } else {
            require(tokens >= (current_bond * 2), "bond must be double at least previous bond");
        }
        _;
    }

    modifier previousBondMustNotBeatMaxPrevious(bytes32 question_id, uint256 max_previous) {

        if (max_previous > 0) {
            require(questions[question_id].bond <= max_previous, "bond must exceed max_previous");
        }
        _;
    }

    constructor() {
        createTemplate('{"title": "%s", "type": "bool", "category": "%s", "lang": "%s"}');
        createTemplate('{"title": "%s", "type": "uint", "decimals": 18, "category": "%s", "lang": "%s"}');
        createTemplate('{"title": "%s", "type": "single-select", "outcomes": [%s], "category": "%s", "lang": "%s"}');
        createTemplate('{"title": "%s", "type": "multiple-select", "outcomes": [%s], "category": "%s", "lang": "%s"}');
        createTemplate('{"title": "%s", "type": "datetime", "category": "%s", "lang": "%s"}');
    }

    function setToken(IERC20 _token) 
    public
    {

        require(token == IERC20(address(0x0)), "Token can only be initialized once");
        token = _token;
    }

    function setQuestionFee(uint256 fee) 
        stateAny() 
    external {

        arbitrator_question_fees[msg.sender] = fee;
        emit LogSetQuestionFee(msg.sender, fee);
    }

    function createTemplate(string memory content) 
        stateAny()
    public returns (uint256) {

        uint256 id = nextTemplateID;
        templates[id] = block.number;
        template_hashes[id] = keccak256(abi.encodePacked(content));
        emit LogNewTemplate(id, msg.sender, content);
        nextTemplateID = id + 1;
        return id;
    }

    function createTemplateAndAskQuestion(
        string memory content, 
        string memory question, address arbitrator, uint32 timeout, uint32 opening_ts, uint256 nonce 
    ) 
    public returns (bytes32) {

        uint256 template_id = createTemplate(content);
        return askQuestion(template_id, question, arbitrator, timeout, opening_ts, nonce);
    }

    function askQuestion(uint256 template_id, string memory question, address arbitrator, uint32 timeout, uint32 opening_ts, uint256 nonce) 
    public returns (bytes32) {


        require(templates[template_id] > 0, "template must exist");

        bytes32 content_hash = keccak256(abi.encodePacked(template_id, opening_ts, question));
        bytes32 question_id = keccak256(abi.encodePacked(content_hash, arbitrator, timeout, uint256(0), address(this), msg.sender, nonce));

        emit LogNewQuestion(question_id, msg.sender, template_id, question, content_hash, arbitrator, timeout, opening_ts, nonce, block.timestamp);
        _askQuestion(question_id, content_hash, arbitrator, timeout, opening_ts, 0, 0);

        return question_id;
    }

    function askQuestionERC20(uint256 template_id, string memory question, address arbitrator, uint32 timeout, uint32 opening_ts, uint256 nonce, uint256 tokens) 
    public returns (bytes32) {


        _deductTokensOrRevert(tokens);

        require(templates[template_id] > 0, "template must exist");

        bytes32 content_hash = keccak256(abi.encodePacked(template_id, opening_ts, question));
        bytes32 question_id = keccak256(abi.encodePacked(content_hash, arbitrator, timeout, uint256(0), address(this), msg.sender, nonce));

        emit LogNewQuestion(question_id, msg.sender, template_id, question, content_hash, arbitrator, timeout, opening_ts, nonce, block.timestamp);
        _askQuestion(question_id, content_hash, arbitrator, timeout, opening_ts, 0, tokens);

        return question_id;
    }

    function askQuestionWithMinBondERC20(uint256 template_id, string memory question, address arbitrator, uint32 timeout, uint32 opening_ts, uint256 nonce, uint256 min_bond, uint256 tokens) 
    public returns (bytes32) {


        _deductTokensOrRevert(tokens);

        require(templates[template_id] > 0, "template must exist");

        bytes32 content_hash = keccak256(abi.encodePacked(template_id, opening_ts, question));
        bytes32 question_id = keccak256(abi.encodePacked(content_hash, arbitrator, timeout, min_bond, address(this), msg.sender, nonce));

        emit LogNewQuestion(question_id, msg.sender, template_id, question, content_hash, arbitrator, timeout, opening_ts, nonce, block.timestamp);
        _askQuestion(question_id, content_hash, arbitrator, timeout, opening_ts, min_bond, tokens);

        return question_id;
    }

    function _deductTokensOrRevert(uint256 tokens) 
    internal {

 
        if (tokens == 0) {
            return;
        }

        uint256 bal = balanceOf[msg.sender];

        if (bal > 0) {
            if (bal >= tokens) {
                balanceOf[msg.sender] = bal - tokens;
                return;
            } else {
                tokens = tokens - bal;
                balanceOf[msg.sender] = 0;
            }
        }
        require(token.transferFrom(msg.sender, address(this), tokens), "Transfer of tokens failed, insufficient approved balance?");
        return;

    }

    function _askQuestion(bytes32 question_id, bytes32 content_hash, address arbitrator, uint32 timeout, uint32 opening_ts, uint256 min_bond, uint256 tokens) 
        stateNotCreated(question_id)
    internal {


        require(timeout > 0, "timeout must be positive"); 
        require(timeout < 365 days, "timeout must be less than 365 days"); 

        uint256 bounty = tokens;

        if (arbitrator != NULL_ADDRESS && msg.sender != arbitrator) {
            uint256 question_fee = arbitrator_question_fees[arbitrator];
            require(bounty >= question_fee, "Tokens provided must cover question fee"); 
            bounty = bounty - question_fee;
            balanceOf[arbitrator] = balanceOf[arbitrator] + question_fee;
        }

        questions[question_id].content_hash = content_hash;
        questions[question_id].arbitrator = arbitrator;
        questions[question_id].opening_ts = opening_ts;
        questions[question_id].timeout = timeout;

        if (bounty > 0) {
            questions[question_id].bounty = bounty;
            emit LogFundAnswerBounty(question_id, bounty, bounty, msg.sender);
        }

        if (min_bond > 0) {
            questions[question_id].min_bond = min_bond;
            emit LogMinimumBond(question_id, min_bond);
        }

    }

    function fundAnswerBountyERC20(bytes32 question_id, uint256 tokens) 
        stateOpen(question_id)
    external {

        _deductTokensOrRevert(tokens);
        questions[question_id].bounty = questions[question_id].bounty + tokens;
        emit LogFundAnswerBounty(question_id, tokens, questions[question_id].bounty, msg.sender);
    }

    function submitAnswerERC20(bytes32 question_id, bytes32 answer, uint256 max_previous, uint256 tokens) 
        stateOpen(question_id)
        bondMustDoubleAndMatchMinimum(question_id, tokens)
        previousBondMustNotBeatMaxPrevious(question_id, max_previous)
    external {

        _deductTokensOrRevert(tokens);
        _addAnswerToHistory(question_id, answer, msg.sender, tokens, false);
        _updateCurrentAnswer(question_id, answer);
    }

    function submitAnswerForERC20(bytes32 question_id, bytes32 answer, uint256 max_previous, address answerer, uint256 tokens)
        stateOpen(question_id)
        bondMustDoubleAndMatchMinimum(question_id, tokens)
        previousBondMustNotBeatMaxPrevious(question_id, max_previous)
    external {

        _deductTokensOrRevert(tokens);
        require(answerer != NULL_ADDRESS, "answerer must be non-zero");
        _addAnswerToHistory(question_id, answer, answerer, tokens, false);
        _updateCurrentAnswer(question_id, answer);
    }

    function _storeCommitment(bytes32 question_id, bytes32 commitment_id) 
    internal
    {

        require(commitments[commitment_id].reveal_ts == COMMITMENT_NON_EXISTENT, "commitment must not already exist");

        uint32 commitment_timeout = questions[question_id].timeout / COMMITMENT_TIMEOUT_RATIO;
        commitments[commitment_id].reveal_ts = uint32(block.timestamp) + commitment_timeout;
    }

    function submitAnswerCommitmentERC20(bytes32 question_id, bytes32 answer_hash, uint256 max_previous, address _answerer, uint256 tokens) 
        stateOpen(question_id)
        bondMustDoubleAndMatchMinimum(question_id, tokens)
        previousBondMustNotBeatMaxPrevious(question_id, max_previous)
    external {


        _deductTokensOrRevert(tokens);

        bytes32 commitment_id = keccak256(abi.encodePacked(question_id, answer_hash, tokens));
        address answerer = (_answerer == NULL_ADDRESS) ? msg.sender : _answerer;

        _storeCommitment(question_id, commitment_id);
        _addAnswerToHistory(question_id, commitment_id, answerer, tokens, true);

    }

    function submitAnswerReveal(bytes32 question_id, bytes32 answer, uint256 nonce, uint256 bond) 
        stateOpenOrPendingArbitration(question_id)
    external {


        bytes32 answer_hash = keccak256(abi.encodePacked(answer, nonce));
        bytes32 commitment_id = keccak256(abi.encodePacked(question_id, answer_hash, bond));

        require(!commitments[commitment_id].is_revealed, "commitment must not have been revealed yet");
        require(commitments[commitment_id].reveal_ts > uint32(block.timestamp), "reveal deadline must not have passed");

        commitments[commitment_id].revealed_answer = answer;
        commitments[commitment_id].is_revealed = true;

        if (bond == questions[question_id].bond) {
            _updateCurrentAnswer(question_id, answer);
        }

        emit LogAnswerReveal(question_id, msg.sender, answer_hash, answer, nonce, bond);

    }

    function _addAnswerToHistory(bytes32 question_id, bytes32 answer_or_commitment_id, address answerer, uint256 bond, bool is_commitment) 
    internal 
    {

        bytes32 new_history_hash = keccak256(abi.encodePacked(questions[question_id].history_hash, answer_or_commitment_id, bond, answerer, is_commitment));

        if (bond > 0) {
            questions[question_id].bond = bond;
        }
        questions[question_id].history_hash = new_history_hash;

        emit LogNewAnswer(answer_or_commitment_id, question_id, new_history_hash, answerer, bond, block.timestamp, is_commitment);
    }

    function _updateCurrentAnswer(bytes32 question_id, bytes32 answer)
    internal {

        questions[question_id].best_answer = answer;
        questions[question_id].finalize_ts = uint32(block.timestamp) + questions[question_id].timeout;
    }

    function _updateCurrentAnswerByArbitrator(bytes32 question_id, bytes32 answer)
    internal {

        questions[question_id].best_answer = answer;
        questions[question_id].finalize_ts = uint32(block.timestamp);
    }

    function notifyOfArbitrationRequest(bytes32 question_id, address requester, uint256 max_previous) 
        onlyArbitrator(question_id)
        stateOpen(question_id)
        previousBondMustNotBeatMaxPrevious(question_id, max_previous)
    external {

        require(questions[question_id].finalize_ts > UNANSWERED, "Question must already have an answer when arbitration is requested");
        questions[question_id].is_pending_arbitration = true;
        emit LogNotifyOfArbitrationRequest(question_id, requester);
    }

    function cancelArbitration(bytes32 question_id) 
        onlyArbitrator(question_id)
        statePendingArbitration(question_id)
    external {

        questions[question_id].is_pending_arbitration = false;
        questions[question_id].finalize_ts = uint32(block.timestamp) + questions[question_id].timeout;
        emit LogCancelArbitration(question_id);
    }

    function submitAnswerByArbitrator(bytes32 question_id, bytes32 answer, address answerer) 
        onlyArbitrator(question_id)
        statePendingArbitration(question_id)
    public {


        require(answerer != NULL_ADDRESS, "answerer must be provided");
        emit LogFinalize(question_id, answer);

        questions[question_id].is_pending_arbitration = false;
        _addAnswerToHistory(question_id, answer, answerer, 0, false);
        _updateCurrentAnswerByArbitrator(question_id, answer);
    }

    function assignWinnerAndSubmitAnswerByArbitrator(bytes32 question_id, bytes32 answer, address payee_if_wrong, bytes32 last_history_hash, bytes32 last_answer_or_commitment_id, address last_answerer) 
    external {

        bool is_commitment = _verifyHistoryInputOrRevert(questions[question_id].history_hash, last_history_hash, last_answer_or_commitment_id, questions[question_id].bond, last_answerer);

        address payee;
        if (is_commitment && !commitments[last_answer_or_commitment_id].is_revealed) {
            require(commitments[last_answer_or_commitment_id].reveal_ts < uint32(block.timestamp), "You must wait for the reveal deadline before finalizing");
            payee = payee_if_wrong;
        } else {
            payee = (questions[question_id].best_answer == answer) ? last_answerer : payee_if_wrong;
        }
        submitAnswerByArbitrator(question_id, answer, payee);
    }


    function isFinalized(bytes32 question_id) 
    view public returns (bool) {

        uint32 finalize_ts = questions[question_id].finalize_ts;
        return ( !questions[question_id].is_pending_arbitration && (finalize_ts > UNANSWERED) && (finalize_ts <= uint32(block.timestamp)) );
    }

    function getFinalAnswer(bytes32 question_id) 
        stateFinalized(question_id)
    external view returns (bytes32) {

        return questions[question_id].best_answer;
    }

    function resultFor(bytes32 question_id) 
        stateFinalized(question_id)
    public view returns (bytes32) {

        return questions[question_id].best_answer;
    }

    function isSettledTooSoon(bytes32 question_id)
    public view returns(bool) {

        return (resultFor(question_id) == UNRESOLVED_ANSWER);
    }

    function resultForOnceSettled(bytes32 question_id)
    external view returns(bytes32) {

        bytes32 result = resultFor(question_id);
        if (result == UNRESOLVED_ANSWER) {
            bytes32 replacement_id = reopened_questions[question_id];
            require(replacement_id != bytes32(0x0), "Question was settled too soon and has not been reopened");
            result = resultFor(replacement_id);
            require(result != UNRESOLVED_ANSWER, "Question replacement was settled too soon and has not been reopened");
        }
        return result;
    }

    function reopenQuestionERC20(uint256 template_id, string memory question, address arbitrator, uint32 timeout, uint32 opening_ts, uint256 nonce, uint256 min_bond, bytes32 reopens_question_id, uint256 tokens)
    public returns (bytes32) {



        require(isSettledTooSoon(reopens_question_id), "You can only reopen questions that resolved as settled too soon");

        bytes32 content_hash = keccak256(abi.encodePacked(template_id, opening_ts, question));

        require(content_hash == questions[reopens_question_id].content_hash, "content hash mismatch");
        require(arbitrator == questions[reopens_question_id].arbitrator, "arbitrator mismatch");
        require(timeout == questions[reopens_question_id].timeout, "timeout mismatch");
        require(opening_ts == questions[reopens_question_id].opening_ts , "opening_ts mismatch");
        require(min_bond == questions[reopens_question_id].min_bond, "min_bond mismatch");

        require(!reopener_questions[reopens_question_id], "Question is already reopening a previous question");

        bytes32 existing_reopen_question_id = reopened_questions[reopens_question_id];

        bytes32 take_bounty_from_question_id = reopens_question_id;
        if (existing_reopen_question_id != bytes32(0)) {
            require(isSettledTooSoon(existing_reopen_question_id), "Question has already been reopened");
            reopener_questions[existing_reopen_question_id] = false;
            take_bounty_from_question_id = existing_reopen_question_id;
        }

        bytes32 question_id = askQuestionWithMinBondERC20(template_id, question, arbitrator, timeout, opening_ts, nonce, min_bond, tokens);

        reopened_questions[reopens_question_id] = question_id;
        reopener_questions[question_id] = true;

        questions[question_id].bounty = questions[take_bounty_from_question_id].bounty + questions[question_id].bounty;
        questions[take_bounty_from_question_id].bounty = 0;

        emit LogReopenQuestion(question_id, reopens_question_id);

        return question_id;
    }

    function getFinalAnswerIfMatches(
        bytes32 question_id, 
        bytes32 content_hash, address arbitrator, uint32 min_timeout, uint256 min_bond
    ) 
        stateFinalized(question_id)
    external view returns (bytes32) {

        require(content_hash == questions[question_id].content_hash, "content hash must match");
        require(arbitrator == questions[question_id].arbitrator, "arbitrator must match");
        require(min_timeout <= questions[question_id].timeout, "timeout must be long enough");
        require(min_bond <= questions[question_id].bond, "bond must be high enough");
        return questions[question_id].best_answer;
    }

    function claimWinnings(
        bytes32 question_id, 
        bytes32[] memory history_hashes, address[] memory addrs, uint256[] memory bonds, bytes32[] memory answers
    ) 
        stateFinalized(question_id)
    public {


        require(history_hashes.length > 0, "at least one history hash entry must be provided");

        address payee = question_claims[question_id].payee; 
        uint256 last_bond = question_claims[question_id].last_bond; 
        uint256 queued_funds = question_claims[question_id].queued_funds; 

        bytes32 last_history_hash = questions[question_id].history_hash;

        bytes32 best_answer = questions[question_id].best_answer;

        uint256 i;
        for (i = 0; i < history_hashes.length; i++) {
        
            bool is_commitment = _verifyHistoryInputOrRevert(last_history_hash, history_hashes[i], answers[i], bonds[i], addrs[i]);
            
            queued_funds = queued_funds + last_bond; 
            (queued_funds, payee) = _processHistoryItem(
                question_id, best_answer, queued_funds, payee, 
                addrs[i], bonds[i], answers[i], is_commitment);
 
            last_bond = bonds[i];

            if (last_bond != questions[question_id].bond) {
                last_bond = last_bond - last_bond / BOND_CLAIM_FEE_PROPORTION;
            }

            last_history_hash = history_hashes[i];

        }
 
        if (last_history_hash != NULL_HASH) {

            if (payee != NULL_ADDRESS) {
                _payPayee(question_id, payee, queued_funds);
                queued_funds = 0;
            }

            question_claims[question_id].payee = payee;
            question_claims[question_id].last_bond = last_bond;
            question_claims[question_id].queued_funds = queued_funds;
        } else {
            _payPayee(question_id, payee, queued_funds + last_bond);
            delete question_claims[question_id];
        }

        questions[question_id].history_hash = last_history_hash;

    }

    function _payPayee(bytes32 question_id, address payee, uint256 value) 
    internal {

        balanceOf[payee] = balanceOf[payee] + value;
        emit LogClaim(question_id, payee, value);
    }

    function _verifyHistoryInputOrRevert(
        bytes32 last_history_hash,
        bytes32 history_hash, bytes32 answer, uint256 bond, address addr
    )
    internal pure returns (bool) {

        if (last_history_hash == keccak256(abi.encodePacked(history_hash, answer, bond, addr, true)) ) {
            return true;
        }
        if (last_history_hash == keccak256(abi.encodePacked(history_hash, answer, bond, addr, false)) ) {
            return false;
        } 
        revert("History input provided did not match the expected hash");
    }

    function _processHistoryItem(
        bytes32 question_id, bytes32 best_answer, 
        uint256 queued_funds, address payee, 
        address addr, uint256 bond, bytes32 answer, bool is_commitment
    )
    internal returns (uint256, address) {


        if (is_commitment) {
            bytes32 commitment_id = answer;
            if (!commitments[commitment_id].is_revealed) {
                delete commitments[commitment_id];
                return (queued_funds, payee);
            } else {
                answer = commitments[commitment_id].revealed_answer;
                delete commitments[commitment_id];
            }
        }

        if (answer == best_answer) {

            if (payee == NULL_ADDRESS) {

                payee = addr;

                if (best_answer != UNRESOLVED_ANSWER && questions[question_id].bounty > 0) {
                    _payPayee(question_id, payee, questions[question_id].bounty);
                    questions[question_id].bounty = 0;
                }

            } else if (addr != payee) {



                uint256 answer_takeover_fee = (queued_funds >= bond) ? bond : queued_funds;
                _payPayee(question_id, payee, queued_funds - answer_takeover_fee);

                payee = addr;
                queued_funds = answer_takeover_fee;

            }

        }

        return (queued_funds, payee);

    }

    function claimMultipleAndWithdrawBalance(
        bytes32[] memory question_ids, uint256[] memory lengths, 
        bytes32[] memory hist_hashes, address[] memory addrs, uint256[] memory bonds, bytes32[] memory answers
    ) 
        stateAny() // The finalization checks are done in the claimWinnings function
    public {

        
        uint256 qi;
        uint256 i;
        for (qi = 0; qi < question_ids.length; qi++) {
            bytes32 qid = question_ids[qi];
            uint256 ln = lengths[qi];
            bytes32[] memory hh = new bytes32[](ln);
            address[] memory ad = new address[](ln);
            uint256[] memory bo = new uint256[](ln);
            bytes32[] memory an = new bytes32[](ln);
            uint256 j;
            for (j = 0; j < ln; j++) {
                hh[j] = hist_hashes[i];
                ad[j] = addrs[i];
                bo[j] = bonds[i];
                an[j] = answers[i];
                i++;
            }
            claimWinnings(qid, hh, ad, bo, an);
        }
        withdraw();
    }

    function getContentHash(bytes32 question_id) 
    public view returns(bytes32) {

        return questions[question_id].content_hash;
    }

    function getArbitrator(bytes32 question_id) 
    public view returns(address) {

        return questions[question_id].arbitrator;
    }

    function getOpeningTS(bytes32 question_id) 
    public view returns(uint32) {

        return questions[question_id].opening_ts;
    }

    function getTimeout(bytes32 question_id) 
    public view returns(uint32) {

        return questions[question_id].timeout;
    }

    function getFinalizeTS(bytes32 question_id) 
    public view returns(uint32) {

        return questions[question_id].finalize_ts;
    }

    function isPendingArbitration(bytes32 question_id) 
    public view returns(bool) {

        return questions[question_id].is_pending_arbitration;
    }

    function getBounty(bytes32 question_id) 
    public view returns(uint256) {

        return questions[question_id].bounty;
    }

    function getBestAnswer(bytes32 question_id) 
    public view returns(bytes32) {

        return questions[question_id].best_answer;
    }

    function getHistoryHash(bytes32 question_id) 
    public view returns(bytes32) {

        return questions[question_id].history_hash;
    }

    function getBond(bytes32 question_id) 
    public view returns(uint256) {

        return questions[question_id].bond;
    }

    function getMinBond(bytes32 question_id)
    public view returns(uint256) {

        return questions[question_id].min_bond;
    }

}