

pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;


library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract ReentrancyGuard {

    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    function ReentrancyGuardInitialize() internal {

        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

abstract contract VersionedInitializable {
    uint256 private lastInitializedRevision = 0;

    bool private initializing;

    modifier initializer() {
        uint256 revision = getRevision();
        require(
            initializing ||
                isConstructor() ||
                revision > lastInitializedRevision,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            lastInitializedRevision = revision;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function getRevision() internal virtual pure returns (uint256);

    function isConstructor() private view returns (bool) {
        uint256 cs;
        assembly {
            cs := extcodesize(address())
        }
        return cs == 0;
    }

    uint256[16] private ______gap;
}

interface Executor {

    function execute(
        uint256,
        uint256,
        uint256,
        uint256
    ) external;

}

contract FortubeGovernance is ReentrancyGuard, VersionedInitializable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    event RegisterVoter(address voter, uint256 votes, uint256 totalVotes);
    event RevokeVoter(address voter, uint256 votes, uint256 totalVotes);
    event NewProposal(
        uint256 id,
        address creator,
        uint256 start,
        uint256 duration,
        address executor
    );
    event Vote(
        uint256 indexed id,
        address indexed voter,
        bool vote,
        uint256 weight
    );
    event ProposalFinished(
        uint256 indexed id,
        uint256 _for,
        uint256 _against,
        bool quorumReached
    );
    event Staked(address indexed user, bytes32 select, uint256 amount, uint256 supply);
    event Withdrawn(address indexed user, bytes32 receipt);

    struct Select {
        uint256 duration;
        uint256 exrate; //GFOR生成比率
        uint256 reward; //FOR的周期收益率
        uint256 __RESERVED__0;
        uint256 __RESERVED__1;
        uint256 __RESERVED__2;
    }

    struct Staking {
        address account;
        uint256 amount;
        uint256 start;
        uint256 duration;
        uint256 exrate;
        uint256 reward;
        uint256 __RESERVED__0;
        uint256 __RESERVED__1;
        uint256 __RESERVED__2;
    }

    struct Proposal {
        uint256 id;
        address proposer;
        mapping(address => uint256) forVotes;
        mapping(address => uint256) againstVotes;
        uint256 totalForVotes;
        uint256 totalAgainstVotes;
        uint256 start; // block start;
        uint256 end; // start + period
        address executor;
        string hash;
        uint256 totalVotesAvailable;
        uint256 quorum;
        uint256 quorumRequired;
        bool open;
    }


    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public votes;
    mapping(address => bool) public voters;
    mapping(address => uint256) public voteLock; // period that your sake it locked to keep it for voting
    uint256 public totalVotes;
    uint256 public proposalCount;

    uint256 public period; // voting period in blocks
    uint256 public lock; // vote lock in block
    uint256 public minimum;
    uint256 public quorum;


    bool public breaker = false;

    address public governance;
    address public staketoken;
    address public rewarder; //奖励支付者


    uint8 public decimals;
    string public name;
    string public symbol;

    uint256 private _totalSupply;
    uint256 private _totalStake;


    mapping(bytes32 => Select) private _selects; //锁仓选项
    mapping(address => uint256) private _stakes; //锁仓额度
    mapping(address => uint256) private _balances; //GFOR额度
    mapping(address => bytes32[]) private _receipts; //锁仓记录回执
    mapping(bytes32 => Staking) private _stakings; //锁仓记录

    uint256 private _stakeNonce = 0;


    function getRevision() internal override pure returns (uint256) {

        return uint256(0x1);
    }

    function initialize(
        address _governance,
        address _staketoken,
        address _rewarder
    ) public initializer {

        ReentrancyGuard.ReentrancyGuardInitialize();

        governance = _governance;
        staketoken = _staketoken;
        rewarder = _rewarder;

        decimals = 18;
        name = "ForTube Governance Token";
        symbol = "GFOR";
    }

    function totalStake() public view returns (uint256) {

        return _totalStake;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function stakeOf(address account) public view returns (uint256) {

        return _stakes[account];
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function receipts(address account) public view returns (bytes32[] memory) {

        return _receipts[account];
    }

    function staking(bytes32 receipt) public view returns (Staking memory) {

        return _stakings[receipt];
    }

    function getSelect(bytes32 select)
        public
        view
        returns (Select memory)
    {

        return _selects[select];
    }


    function seize(address _token, uint256 amount) external {

        require(msg.sender == governance, "!governance");
        require(_token != staketoken, "can not staketoken");
        IERC20(_token).safeTransfer(governance, amount);
    }


    function setBreaker(bool _breaker) external {

        require(msg.sender == governance, "!governance");
        breaker = _breaker;
    }


    function setGovernance(address _governance) public {

        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setQuorum(uint256 _quorum) public {

        require(msg.sender == governance, "!governance");
        quorum = _quorum;
    }

    function setMinimum(uint256 _minimum) public {

        require(msg.sender == governance, "!governance");
        minimum = _minimum;
    }

    function setPeriod(uint256 _period) public {

        require(msg.sender == governance, "!governance");
        period = _period;
    }

    function setLock(uint256 _lock) public {

        require(msg.sender == governance, "!governance");
        lock = _lock;
    }
    
    function setRewarder(address _rewarder) public {

        require(msg.sender == governance, "!governance");
        rewarder = _rewarder;
    }

    function addSelect(
        bytes32 select,
        uint256 duration,
        uint256 exrate,
        uint256 reward
    ) public {

        require(msg.sender == governance, "!governance");
        _selects[select].duration = duration;
        _selects[select].exrate = exrate;
        _selects[select].reward = reward;
    }


    function propose(address executor, string memory hash) public {

        require(votesOf(msg.sender) > minimum, "<minimum");
        proposals[proposalCount++] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            totalForVotes: 0,
            totalAgainstVotes: 0,
            start: block.number,
            end: period.add(block.number),
            executor: executor,
            hash: hash,
            totalVotesAvailable: totalVotes,
            quorum: 0,
            quorumRequired: quorum,
            open: true
        });

        emit NewProposal(
            proposalCount,
            msg.sender,
            block.number,
            period,
            executor
        );
        voteLock[msg.sender] = lock.add(block.number);
    }

    function execute(uint256 id) public {

        (uint256 _for, uint256 _against, uint256 _quorum) = getStats(id);
        require(proposals[id].quorumRequired < _quorum, "!quorum");
        require(proposals[id].end < block.number, "!end");
        if (proposals[id].open == true) {
            tallyVotes(id);
        }
        Executor(proposals[id].executor).execute(id, _for, _against, _quorum);
    }

    function getStats(uint256 id)
        public
        view
        returns (
            uint256 _for,
            uint256 _against,
            uint256 _quorum
        )
    {

        _for = proposals[id].totalForVotes;
        _against = proposals[id].totalAgainstVotes;

        uint256 _total = _for.add(_against);
        _for = _for.mul(10000).div(_total);
        _against = _against.mul(10000).div(_total);

        _quorum = _total.mul(10000).div(proposals[id].totalVotesAvailable);
    }

    function getVoterStats(uint256 id, address voter)
        public
        view
        returns (uint256, uint256)
    {

        return (
            proposals[id].forVotes[voter],
            proposals[id].againstVotes[voter]
        );
    }

    function tallyVotes(uint256 id) public {

        require(proposals[id].open == true, "!open");
        require(proposals[id].end < block.number, "!end");

        (uint256 _for, uint256 _against, ) = getStats(id);
        bool _quorum = false;
        if (proposals[id].quorum >= proposals[id].quorumRequired) {
            _quorum = true;
        }
        proposals[id].open = false;
        emit ProposalFinished(id, _for, _against, _quorum);
    }

    function votesOf(address voter) public view returns (uint256) {

        return votes[voter];
    }

    function register() public {

        require(voters[msg.sender] == false, "voter");
        voters[msg.sender] = true;
        votes[msg.sender] = balanceOf(msg.sender);
        totalVotes = totalVotes.add(votes[msg.sender]);
        emit RegisterVoter(msg.sender, votes[msg.sender], totalVotes);
    }

    function revoke() public {

        require(voters[msg.sender] == true, "!voter");
        voters[msg.sender] = false;
        if (totalVotes < votes[msg.sender]) {
            totalVotes = 0;
        } else {
            totalVotes = totalVotes.sub(votes[msg.sender]);
        }
        emit RevokeVoter(msg.sender, votes[msg.sender], totalVotes);
        votes[msg.sender] = 0;
    }

    function voteFor(uint256 id) public {

        require(proposals[id].start < block.number, "<start");
        require(proposals[id].end > block.number, ">end");

        uint256 _against = proposals[id].againstVotes[msg.sender];
        if (_against > 0) {
            proposals[id].totalAgainstVotes = proposals[id]
                .totalAgainstVotes
                .sub(_against);
            proposals[id].againstVotes[msg.sender] = 0;
        }

        uint256 vote = votesOf(msg.sender).sub(
            proposals[id].forVotes[msg.sender]
        );
        proposals[id].totalForVotes = proposals[id].totalForVotes.add(vote);
        proposals[id].forVotes[msg.sender] = votesOf(msg.sender);

        proposals[id].totalVotesAvailable = totalVotes;
        uint256 _votes = proposals[id].totalForVotes.add(
            proposals[id].totalAgainstVotes
        );
        proposals[id].quorum = _votes.mul(10000).div(totalVotes);

        voteLock[msg.sender] = lock.add(block.number);

        emit Vote(id, msg.sender, true, vote);
    }

    function voteAgainst(uint256 id) public {

        require(proposals[id].start < block.number, "<start");
        require(proposals[id].end > block.number, ">end");

        uint256 _for = proposals[id].forVotes[msg.sender];
        if (_for > 0) {
            proposals[id].totalForVotes = proposals[id].totalForVotes.sub(_for);
            proposals[id].forVotes[msg.sender] = 0;
        }

        uint256 vote = votesOf(msg.sender).sub(
            proposals[id].againstVotes[msg.sender]
        );
        proposals[id].totalAgainstVotes = proposals[id].totalAgainstVotes.add(
            vote
        );
        proposals[id].againstVotes[msg.sender] = votesOf(msg.sender);

        proposals[id].totalVotesAvailable = totalVotes;
        uint256 _votes = proposals[id].totalForVotes.add(
            proposals[id].totalAgainstVotes
        );
        proposals[id].quorum = _votes.mul(10000).div(totalVotes);

        voteLock[msg.sender] = lock.add(block.number);

        emit Vote(id, msg.sender, false, vote);
    }


    function stake(bytes32 select, uint256 amount) public {

        require(false, "stake was disable");
        require(amount > 0, "Cannot stake 0");
        uint256 supply = _onstake(select, amount);
        if (voters[msg.sender] == true) {
            votes[msg.sender] = votes[msg.sender].add(supply);
            totalVotes = totalVotes.add(supply);
        }
        emit Staked(msg.sender, select, amount, supply);
    }

    function withdraw(bytes32 receipt) public {

        uint256 supply = _onwithdraw(receipt);
        if (voters[msg.sender] == true) {
            votes[msg.sender] = votes[msg.sender].sub(supply);
            totalVotes = totalVotes.sub(supply);
        }
        if (breaker == false) {
            require(voteLock[msg.sender] < block.number, "!locked");
        }
        emit Withdrawn(msg.sender, receipt);
    }

    function _onstake(bytes32 select, uint256 amount)
        internal
        returns (uint256)
    {

        Staking memory staking = Staking(
            msg.sender,
            amount,
            now,
            _selects[select].duration,
            _selects[select].exrate,
            _selects[select].reward,
            0,
            0,
            0
        );
        bytes32 receipt = keccak256(abi.encode(_stakeNonce++, staking));
        _stakings[receipt] = staking;
        _receipts[msg.sender].push(receipt);
        _totalStake = _totalStake.add(amount);
        _stakes[msg.sender] = _stakes[msg.sender].add(amount);
        uint256 supply = amount.mul(_stakings[receipt].exrate).div(1e18);
        require(supply > 0, "!supply");
        _totalSupply = _totalSupply.add(supply);
        _balances[msg.sender] = _balances[msg.sender].add(supply);
        IERC20(staketoken).safeTransferFrom(msg.sender, address(this), amount);
        return supply;
    }

    function _onwithdraw(bytes32 receipt) internal returns (uint256) {

        uint256 at = _findReceipt(msg.sender, receipt);
        require(at != uint256(-1), "not found receipt");
        Staking memory _staking = _stakings[receipt];
        require(now > _staking.start.add(_staking.duration), "stake has not expired"); //到期

        uint256 amount = _staking.amount;
        _totalStake = _totalStake.sub(amount);
        _stakes[msg.sender] = _stakes[msg.sender].sub(amount);
        uint256 supply = amount.mul(_staking.exrate).div(1e18);
        require(supply > 0, "!supply");
        _totalSupply = _totalSupply.sub(supply);
        _balances[msg.sender] = _balances[msg.sender].sub(supply);

        uint256 last = _receipts[msg.sender].length - 1;
        _receipts[msg.sender][at] = _receipts[msg.sender][last];
        _receipts[msg.sender].pop();
        delete _stakings[receipt];

        IERC20(staketoken).safeTransfer(msg.sender, amount);
        if(_staking.reward != 0) {
            uint256 reward = amount.mul(_staking.reward).div(1e18);
            IERC20(staketoken).safeTransferFrom(rewarder, msg.sender, reward);
        }
        return supply;
    }

    function _findReceipt(address account, bytes32 receipt)
        internal
        view
        returns (uint256)
    {

        uint256 length = _receipts[account].length;
        for (uint256 i = 0; i < length; ++i) {
            if (receipt == _receipts[account][i]) {
                return i;
            }
        }
        return uint256(-1);
    }
}