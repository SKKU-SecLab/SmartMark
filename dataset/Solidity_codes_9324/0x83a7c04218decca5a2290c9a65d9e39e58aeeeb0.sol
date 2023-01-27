


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
}



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
}



pragma solidity >=0.6.0 <0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}



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
}



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
}


pragma solidity ^0.6.0;


contract Governable {


    address public governance;

    constructor() public {
        governance = msg.sender;
    }

    modifier onlyGovernance {

        require(msg.sender == governance, "!governance");
        _;
    }

    function setGovernance(address _newGovernance) public onlyGovernance {

        governance = _newGovernance;
    }

}



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
}


pragma solidity ^0.6.0;





contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public governanceToken;

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    function totalSupply() public view returns(uint256) {

        return _totalSupply;
    }

    function balanceOf(address _account) public view returns(uint256) {

        return _balances[_account];
    }

    function stake(uint256 _amount) public virtual {

        _totalSupply = _totalSupply.add(_amount);
        _balances[msg.sender] = _balances[msg.sender].add(_amount);
        governanceToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _amount) public virtual {

        _totalSupply = _totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        governanceToken.transfer(msg.sender, _amount);
    }

    function _setGovernanceToken(address _newGovernanceToken) internal {

        governanceToken = IERC20(_newGovernanceToken);
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.6.0;



abstract contract IRewardDistributionRecipient is Ownable {

    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) external virtual;

    modifier onlyRewardDistribution {
        require(msg.sender == rewardDistribution, "!rewardDistribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        public
        onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }
}


pragma solidity ^0.6.0;


interface IExecutor {

    function execute(uint256 _id, uint256 _for, uint256 _against, uint256 _quorum) external;

}


pragma solidity ^0.6.0;










contract Governance is Governable, IRewardDistributionRecipient, LPTokenWrapper, Initializable {


    struct Proposal {
        uint256 id; // Unique ID of the proposal (here Counter lib can be used)
        address proposer; // An address who created the proposal
        mapping(address => uint256) forVotes; // Percentage (in base points) of governance token (votes) of 'for' side
        mapping(address => uint256) againstVotes; // Percentage (in base points) of governance token (votes) of 'against' side
        uint256 totalForVotes; // Total amount of governance token (votes) in side 'for'
        uint256 totalAgainstVotes; // Total amount of governance token (votes) in side 'against'
        uint256 start; // Block start
        uint256 end; // Start + period
        address executor; // Custom contract which can execute changes regarding to voting process end
        string hash; // An IPFS hash of the proposal document
        uint256 totalVotesAvailable; // Total amount votes that are not in voting process
        uint256 quorum; // Current quorum (in base points)
        uint256 quorumRequired; // Quorum to end the voting process
        bool open; // Proposal status
    }

    event NewProposal(uint256 _id, address _creator, uint256 _start, uint256 _duration, address _executor);

    event Vote(uint256 indexed _id, address indexed _voter, bool _vote, uint256 _weight);

    event ProposalFinished(uint256 indexed _id, uint256 _for, uint256 _against, bool _quorumReached);

    event RegisterVoter(address _voter, uint256 _votes, uint256 _totalVotes);

    event RevokeVoter(address _voter, uint256 _votes, uint256 _totalVotes);

    event RewardAdded(uint256 _reward);

    event Staked(address indexed _user, uint256 _amount);

    event Withdrawn(address indexed _user, uint256 _amount);

    event RewardPaid(address indexed _user, uint256 _reward);

    mapping(address => uint256) public voteLock;

    mapping(uint256 => Proposal) public proposals;

    mapping(address => uint256) public votes;

    mapping(address => bool) public voters;

    mapping(address => uint256) public userRewardPerTokenPaid;

    mapping(address => uint256) public rewards;

    bool public breaker = false;

    uint256 public proposalCount;

    uint256 public period = 17280;

    uint256 public lock = 17280;

    uint256 public minimum = 1e18;

    uint256 public quorum = 2000;

    uint256 public totalVotes;

    IERC20 public rewardsToken;

    uint256 public constant DURATION = 7 days;

    uint256 public periodFinish = 0;

    uint256 public rewardRate = 0;

    uint256 public rewardPerTokenStored = 0;

    uint256 public lastUpdateTime;

    function configure(
            uint256 _startId,
            address _rewardsTokenAddress,
            address _governance,
            address _governanceToken,
            address _rewardDistribution
    ) external initializer {

        proposalCount = _startId;
        rewardsToken = IERC20(_rewardsTokenAddress);
        _setGovernanceToken(_governanceToken);
        setGovernance(_governance);
        setRewardDistribution(_rewardDistribution);
    }

    function seize(IERC20 _token, uint256 _amount) external onlyGovernance {

        require(_token != rewardsToken, "!rewardsToken");
        require(_token != governanceToken, "!governanceToken");
        _token.safeTransfer(governance, _amount);
    }

    function setBreaker(bool _breaker) external onlyGovernance {

        breaker = _breaker;
    }

    function setQuorum(uint256 _quorum) external onlyGovernance {

        quorum = _quorum;
    }

    function setMinimum(uint256 _minimum) external onlyGovernance {

        minimum = _minimum;
    }

    function setPeriod(uint256 _period) external onlyGovernance {

        period = _period;
    }

    function setLock(uint256 _lock) external onlyGovernance {

        lock = _lock;
    }

    function exit() external {

        withdraw(balanceOf(_msgSender()));
        getReward();
    }

    function notifyRewardAmount(uint256 _reward)
        external
        onlyRewardDistribution
        override
        updateReward(address(0))
    {

        IERC20(rewardsToken).safeTransferFrom(_msgSender(), address(this), _reward);
        if (block.timestamp >= periodFinish) {
            rewardRate = _reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = _reward.add(leftover).div(DURATION);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(_reward);
    }

    function propose(address _executor, string memory _hash) public {

        require(votesOf(_msgSender()) > minimum, "<minimum");
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposer: _msgSender(),
            totalForVotes: 0,
            totalAgainstVotes: 0,
            start: block.number,
            end: period.add(block.number),
            executor: _executor,
            hash: _hash,
            totalVotesAvailable: totalVotes,
            quorum: 0,
            quorumRequired: quorum,
            open: true
        });
        emit NewProposal(
            proposalCount,
            _msgSender(),
            block.number,
            period,
            _executor
        );
        proposalCount++;
        voteLock[_msgSender()] = lock.add(block.number);
    }

    function execute(uint256 _id) public {

        (uint256 _for, uint256 _against, uint256 _quorum) = getStats(_id);
        require(proposals[_id].quorumRequired < _quorum, "!quorum");
        require(proposals[_id].end < block.number , "!end");
        if (proposals[_id].open) {
            tallyVotes(_id);
        }
        IExecutor(proposals[_id].executor).execute(_id, _for, _against, _quorum);
    }

    function getStats(uint256 _id)
        public
        view
        returns(
            uint256 _for,
            uint256 _against,
            uint256 _quorum
        )
    {

        _for = proposals[_id].totalForVotes;
        _against = proposals[_id].totalAgainstVotes;
        uint256 _total = _for.add(_against);
        if (_total == 0) {
          _quorum = 0;
        } else {
          _for = _for.mul(10000).div(_total);
          _against = _against.mul(10000).div(_total);
          _quorum = _total.mul(10000).div(proposals[_id].totalVotesAvailable);
        }
    }

    function tallyVotes(uint256 _id) public {

        require(proposals[_id].open, "!open");
        require(proposals[_id].end < block.number, "!end");
        (uint256 _for, uint256 _against,) = getStats(_id);
        proposals[_id].open = false;
        emit ProposalFinished(
            _id,
            _for,
            _against,
            proposals[_id].quorum >= proposals[_id].quorumRequired
        );
    }

    function votesOf(address _voter) public view returns(uint256) {

        return votes[_voter];
    }

    function register() public {

        require(!voters[_msgSender()], "voter");
        voters[_msgSender()] = true;
        votes[_msgSender()] = balanceOf(_msgSender());
        totalVotes = totalVotes.add(votes[_msgSender()]);
        emit RegisterVoter(_msgSender(), votes[_msgSender()], totalVotes);
    }

    function revoke() public {

        require(voters[_msgSender()], "!voter");
        voters[_msgSender()] = false;

        (,totalVotes) = totalVotes.trySub(votes[_msgSender()]);

        emit RevokeVoter(_msgSender(), votes[_msgSender()], totalVotes);
        votes[_msgSender()] = 0;
    }

    function voteFor(uint256 _id) public {

        require(proposals[_id].start < block.number, "<start");
        require(proposals[_id].end > block.number, ">end");

        uint256 _against = proposals[_id].againstVotes[_msgSender()];
        if (_against > 0) {
            proposals[_id].totalAgainstVotes = proposals[_id].totalAgainstVotes.sub(_against);
            proposals[_id].againstVotes[_msgSender()] = 0;
        }

        uint256 vote = votesOf(_msgSender()).sub(proposals[_id].forVotes[_msgSender()]);
        proposals[_id].totalForVotes = proposals[_id].totalForVotes.add(vote);
        proposals[_id].forVotes[_msgSender()] = votesOf(_msgSender());

        proposals[_id].totalVotesAvailable = totalVotes;
        uint256 _votes = proposals[_id].totalForVotes.add(proposals[_id].totalAgainstVotes);
        proposals[_id].quorum = _votes.mul(10000).div(totalVotes);

        voteLock[_msgSender()] = lock.add(block.number);

        emit Vote(_id, _msgSender(), true, vote);
    }

    function voteAgainst(uint256 _id) public {

        require(proposals[_id].start < block.number, "<start");
        require(proposals[_id].end > block.number, ">end");

        uint256 _for = proposals[_id].forVotes[_msgSender()];
        if (_for > 0) {
            proposals[_id].totalForVotes = proposals[_id].totalForVotes.sub(_for);
            proposals[_id].forVotes[_msgSender()] = 0;
        }

        uint256 vote = votesOf(_msgSender()).sub(proposals[_id].againstVotes[_msgSender()]);
        proposals[_id].totalAgainstVotes = proposals[_id].totalAgainstVotes.add(vote);
        proposals[_id].againstVotes[_msgSender()] = votesOf(_msgSender());

        proposals[_id].totalVotesAvailable = totalVotes;
        uint256 _votes = proposals[_id].totalForVotes.add(proposals[_id].totalAgainstVotes);
        proposals[_id].quorum = _votes.mul(10000).div(totalVotes);

        voteLock[_msgSender()] = lock.add(block.number);

        emit Vote(_id, _msgSender(), false, vote);
    }

    modifier updateReward(address _account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns(uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns(uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address _account) public view returns(uint256) {

        return
            balanceOf(_account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[_account]))
                .div(1e18)
                .add(rewards[_account]);
    }

    function stake(uint256 _amount) public override updateReward(_msgSender()) {

        require(_amount > 0, "!stake 0");
        if (voters[_msgSender()]) {
            votes[_msgSender()] = votes[_msgSender()].add(_amount);
            totalVotes = totalVotes.add(_amount);
        }
        super.stake(_amount);
        emit Staked(_msgSender(), _amount);
    }


    function withdraw(uint256 _amount) public override updateReward(_msgSender()) {

        require(_amount > 0, "!withdraw 0");
        if (voters[_msgSender()]) {
            votes[_msgSender()] = votes[_msgSender()].sub(_amount);
            totalVotes = totalVotes.sub(_amount);
        }
        if (!breaker) {
            require(voteLock[_msgSender()] < block.number, "!locked");
        }
        super.withdraw(_amount);
        emit Withdrawn(_msgSender(), _amount);
    }

    function getReward() public updateReward(_msgSender()) {

        if (!breaker) {
            require(voteLock[_msgSender()] > block.number, "!voted");
        }
        uint256 reward = earned(_msgSender());
        if (reward > 0) {
            rewards[_msgSender()] = 0;
            rewardsToken.transfer(_msgSender(), reward);
            emit RewardPaid(_msgSender(), reward);
        }
    }
}