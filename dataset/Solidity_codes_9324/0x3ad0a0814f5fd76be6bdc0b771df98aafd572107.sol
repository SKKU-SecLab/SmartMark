
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}//GPL-3.0-or-later
pragma solidity >=0.6.0;

library SafeMath96 {

    function add96(uint96 a, uint96 b) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, "SafeMath96: addition overflow");
        return c;
    }

    function sub96(uint96 a, uint96 b) internal pure returns (uint96) {

        require(b <= a, "SafeMath96: subtraction overflow");
        return a - b;
    }

    function mul96(uint96 a, uint96 b) internal pure returns (uint96) {

        if (a == 0) {
            return 0;
        }

        uint96 c = a * b;
        require(c / a == b, "SafeMath96: multiplication overflow");
        return c;
    }
}// MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract TracerMultisigDAO is Initializable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath96 for uint96;

    IERC20 public govToken;
    uint32 public warmUp; // time before voting can start
    uint32 public coolingOff; // cooling off period in hours
    uint32 public proposalDuration; // proposal duration in days
    uint32 public lockDuration; // time tokens are not withdrawable after voting or proposing
    uint32 public maxProposalTargets;
    uint96 public proposalThreshold;
    uint256 public totalStaked;
    uint256 internal proposalCounter;
    uint8 public quorumDivisor;

    struct Stake {
        uint96 stakedAmount;
        uint256 lockedUntil;
    }

    enum ProposalState {PROPOSED, PASSED, EXECUTED, REJECTED}

    struct Proposal {
        address proposer;
        uint96 yes;
        uint96 no;
        ProposalState state;
        uint256 startTime;
        uint256 expiryTime;
        uint256 passTime;
        address[] targets;
        bytes[] proposalData;
        mapping(address => uint256) stakerTokensVoted;
        bool allowMultisig;
        string proposalURI;
    }

    mapping(address => Stake) public stakers;
    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 proposalId);
    event ProposalPassed(uint256 proposalId);
    event ProposalRejected(uint256 proposalId);
    event TargetExecuted(uint256 proposalId, address target, bytes returnData);
    event ProposalExecuted(uint256 proposalId);
    event UserVote(address voter, bool side, uint256 proposalId, uint96 amount);
    event UserStake(address staker, uint96 amount);
    event UserWithdraw(address staker, uint96 amount);

    address public multisig;
    bool public multisigInitialized;

    event SetMultisig(address multisig);
    event MultisigVote(uint256 proposalId);

    function initialize(
        address _govToken,
        uint32 _maxProposalTargets,
        uint32 _warmUp,
        uint32 _coolingOff,
        uint32 _proposalDuration,
        uint32 _lockDuration,
        uint96 _proposalThreshold,
        uint8 _quorumDivisor
    ) public initializer {

        maxProposalTargets = _maxProposalTargets;
        govToken = IERC20(_govToken);
        warmUp = _warmUp;
        coolingOff = _coolingOff;
        proposalDuration = _proposalDuration;
        lockDuration = _lockDuration;
        proposalThreshold = _proposalThreshold;
        quorumDivisor = _quorumDivisor;
    }

    function initializeMultisig(address _multisig) external {

        require(!multisigInitialized, "DAO: Multisig address already initialized");
        multisigInitialized = true;
        multisig = _multisig;
        emit SetMultisig(multisig);
    }

    function name() external pure returns (string memory) {

        return "MultisigDAOUpgradeable";
    }

    receive() external payable {}

    function getStaked(address account) public view returns (uint96) {

        return stakers[account].stakedAmount;
    }

    function stake(uint96 amount) external {

        govToken.safeTransferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].stakedAmount = stakers[msg.sender]
            .stakedAmount
            .add96(amount);
        totalStaked = totalStaked.add(amount);
        emit UserStake(msg.sender, amount);
    }

    function withdraw(uint96 amount) external {

        Stake memory staker = stakers[msg.sender];
        require(
            staker.lockedUntil < block.timestamp,
            "DAO: Tokens are vote locked"
        );
        stakers[msg.sender].stakedAmount = staker.stakedAmount.sub96(amount);
        totalStaked = totalStaked.sub(amount);
        govToken.safeTransfer(msg.sender, amount);
        emit UserWithdraw(msg.sender, amount);
    }


    function propose(
        address[] memory targets,
        bytes[] memory proposalData,
        bool _allowMultisig,
        string memory _proposalURI
    )
        public
        onlyMultisigOrStaker()
    {

        uint96 userStaked = getStaked(msg.sender);
        require(
            userStaked >= proposalThreshold || msg.sender == multisig,
            "DAO: staked amount < threshold"
        );
        require(targets.length != 0, "DAO: 0 targets");
        require(targets.length < maxProposalTargets, "DAO: Too many targets");
        require(
            targets.length == proposalData.length,
            "DAO: Argument length mismatch"
        );
        stakers[msg.sender].lockedUntil = block.timestamp.add(lockDuration);
        proposals[proposalCounter] = Proposal({
            targets: targets,
            proposalData: proposalData,
            proposer: msg.sender,
            yes: userStaked,
            no: 0,
            startTime: block.timestamp.add(warmUp),
            expiryTime: block.timestamp.add(
                uint256(proposalDuration).add(warmUp)
            ),
            passTime: 0,
            state: ProposalState.PROPOSED,
            allowMultisig: _allowMultisig,
            proposalURI: _proposalURI
        });
        proposals[proposalCounter].stakerTokensVoted[msg.sender] = userStaked;
        emit UserVote(msg.sender, true, proposalCounter, userStaked);
        emit ProposalCreated(proposalCounter);
        proposalCounter += 1;
    }

    function execute(uint256 proposalId) external {

        require(
            proposals[proposalId].state == ProposalState.PASSED,
            "DAO: Proposal state != PASSED"
        );
        require(
            block.timestamp.sub(coolingOff) >= proposals[proposalId].passTime,
            "DAO: Cooling off period not done"
        );
        proposals[proposalId].state = ProposalState.EXECUTED;
        for (uint256 i = 0; i < proposals[proposalId].targets.length; i++) {
            (bool success, bytes memory data) =
                proposals[proposalId].targets[i].call(
                    proposals[proposalId].proposalData[i]
                );
            require(success, "DAO: Failed target execution");
            emit TargetExecuted(
                proposalId,
                proposals[proposalId].targets[i],
                data
            );
        }
        emit ProposalExecuted(proposalId);
    }

    function vote(
        uint256 proposalId,
        bool userVote,
        uint96 amount
    ) external onlyStaker() {

        uint256 stakedAmount = getStaked(msg.sender);
        require(
            proposals[proposalId].startTime < block.timestamp,
            "DAO: Proposal warming up"
        );
        require(
            proposals[proposalId].proposer != msg.sender,
            "DAO: Proposer cannot vote"
        );
        require(
            proposals[proposalId].state == ProposalState.PROPOSED,
            "DAO: Proposal not voteable"
        );
        require(
            proposals[proposalId].expiryTime > block.timestamp,
            "DAO: Proposal Expired"
        );
        require(
            proposals[proposalId].stakerTokensVoted[msg.sender].add(amount) <=
                stakedAmount,
            "DAO: staked amount < voting amount"
        );

        stakers[msg.sender].lockedUntil = block.timestamp.add(lockDuration);
        proposals[proposalId].stakerTokensVoted[msg.sender] = proposals[
            proposalId
        ]
            .stakerTokensVoted[msg.sender]
            .add(amount);

        uint96 votes;
        emit UserVote(msg.sender, userVote, proposalId, amount);
        if (userVote) {
            votes = proposals[proposalId].yes.add96(uint96(amount));
            proposals[proposalId].yes = votes;
            if (votes >= totalStaked.div(quorumDivisor)) {
                proposals[proposalId].passTime = block.timestamp;
                proposals[proposalId].state = ProposalState.PASSED;
                emit ProposalPassed(proposalId);
            }
        } else {
            votes = proposals[proposalId].no.add96(uint96(amount));
            proposals[proposalId].no = votes;
            if (votes >= totalStaked.div(quorumDivisor)) {
                proposals[proposalId].state = ProposalState.REJECTED;
                emit ProposalRejected(proposalId);
            }
        }
    }

    function multisigVoteFor(uint256 proposalId) external onlyMultisig() {

        _multisigVote(proposalId, true);
    }

    function multisigVoteAgainst(uint256 proposalId) external onlyMultisig() {

        _multisigVote(proposalId, false);
    }

    function _multisigVote(uint256 proposalId, bool voteSuccess) private onlyMultisig() {

        Proposal memory proposal = proposals[proposalId];
        require(proposal.allowMultisig, "DAO: Proposal does not allow multisig");
        require(proposal.state != ProposalState.EXECUTED, "DAO: Proposal already executed");
        require(
            proposal.startTime < block.timestamp,
            "DAO: Proposal warming up"
        );
        if (!voteSuccess) {
            proposal.state = ProposalState.REJECTED;
            return;
        }
        require(
            proposal.state != ProposalState.REJECTED,
            "DAO: Proposal rejected"
        );
        require(
            block.timestamp < proposal.expiryTime.add(coolingOff),
            "DAO: Multisig's deadline has passed"
        );

        emit MultisigVote(proposalId);
        proposals[proposalId].state = ProposalState.EXECUTED;

        for (uint256 i = 0; i < proposal.targets.length; i++) {
            (bool success, bytes memory data) =
                proposal.targets[i].call(
                    proposal.proposalData[i]
                );
            require(success, "DAO: Failed target execution");
            emit TargetExecuted(
                proposalId,
                proposal.targets[i],
                data
            );
        }
    }

    function getProposalURI(uint256 proposalId) public view returns (string memory) {

        return proposals[proposalId].proposalURI;
    }

    function setCoolingOff(uint32 newCoolingOff) public onlyGov() {

        coolingOff = newCoolingOff;
    }

    function setWarmUp(uint32 newWarmup) public onlyGov() {

        warmUp = newWarmup;
    }

    function setProposalDuration(uint32 newProposalDuration) public onlyGov() {

        proposalDuration = newProposalDuration;
    }

    function setLockDuration(uint32 newLockDuration) public onlyGov() {

        lockDuration = newLockDuration;
    }

    function setMaxProposalTargets(uint32 newMaxProposalTargets)
        public
        onlyGov()
    {

        maxProposalTargets = newMaxProposalTargets;
    }

    function setProposalThreshold(uint96 newThreshold) public onlyGov() {

        proposalThreshold = newThreshold;
    }

    function setQuorumDivisor(uint8 newQuorumDivisor) public onlyGov() {

        quorumDivisor = newQuorumDivisor;
    }

    function setMultisig(address newMultisig) public onlyGov() {

        multisig = newMultisig;
        emit SetMultisig(multisig);
    }

    function withdrawERC20(
        address token,
        address to,
        uint256 amount
    ) public onlyGov() {

        require(
            token != address(govToken),
            "DAO: Attempt to withdraw gov token"
        );
        IERC20(token).transfer(to, amount);
    }

    function withdrawETH(address payable to, uint256 amount) public onlyGov() {

        to.transfer(amount);
    }

    modifier onlyGov() {

        require(msg.sender == address(this), "DAO: Caller not governance");
        _;
    }

    modifier onlyStaker() {

        require(getStaked(msg.sender) > 0, "DAO: Caller not staked");
        _;
    }

    modifier onlyMultisig() {

        require(msg.sender == multisig, "DAO: Caller not multisig");
        _;
    }

    modifier onlyMultisigOrStaker() {

        require(msg.sender == multisig || getStaked(msg.sender) > 0, "DAO: Caller not multisig or staker");
        _;
    }
}
