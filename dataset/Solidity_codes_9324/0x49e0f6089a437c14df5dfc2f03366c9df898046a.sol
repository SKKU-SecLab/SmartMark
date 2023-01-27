
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

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
}// None
pragma solidity 0.6.12;


abstract contract IRewardDistributionRecipient is Ownable {
    address rewardDistribution;

    function notifyRewardAmount(uint256 reward) external virtual;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution) external onlyOwner {
        rewardDistribution = _rewardDistribution;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// None
pragma solidity 0.6.12;


contract TokenToVotePowerStaking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 internal stakingToken;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function getStakingToken() external view returns(IERC20 _stakingToken){
        return stakingToken;
    }

    constructor(IERC20 _stakingToken) public {
        stakingToken = _stakingToken;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
    }
}// None
pragma solidity 0.6.12;


contract VotingPowerFees is TokenToVotePowerStaking, ReentrancyGuard {
    IERC20 internal feesToken;

    uint256 internal accumulatedRatio = 0;

    uint256 internal lastBal = 0;

    mapping(address => uint256) public userAccumulatedRatio;

    function getFeesToken() external view returns (IERC20 _feesToken) {
        return feesToken;
    }

    function getAccumulatedRatio() external view returns (uint256 _accumulatedRatio) {
        return accumulatedRatio;
    }

    function getLastBal() external view returns (uint256 _lastBal) {
        return lastBal;
    }

    function getUserAccumulatedRatio(address _user) external view returns (uint256 _userAccumulatedRatio) {
        return userAccumulatedRatio[_user];
    }

    constructor(IERC20 _stakingToken, IERC20 _feesToken) public TokenToVotePowerStaking(_stakingToken) {
        feesToken = _feesToken;
    }

    function updateFees() public {
        if (totalSupply() > 0) {
            uint256 _lastBal = IERC20(feesToken).balanceOf(address(this));
            if (_lastBal > 0) {
                uint256 _diff = _lastBal.sub(lastBal);
                if (_diff > 0) {
                    uint256 _ratio = _diff.mul(1e18).div(totalSupply());
                    if (_ratio > 0) {
                        accumulatedRatio = accumulatedRatio.add(_ratio);
                        lastBal = _lastBal;
                    }
                }
            }
        }
    }

    function withdrawFees() external {
        _withdrawFeesFor(msg.sender);
    }

    function _withdrawFeesFor(address recipient) nonReentrant internal {
        updateFees();
        uint256 _supplied = balanceOf(recipient);
        if (_supplied > 0) {
            uint256 _supplyIndex = userAccumulatedRatio[recipient];
            userAccumulatedRatio[recipient] = accumulatedRatio;
            uint256 _delta = accumulatedRatio.sub(_supplyIndex);
            if (_delta > 0) {
                uint256 _share = _supplied.mul(_delta).div(1e18);

                IERC20(feesToken).safeTransfer(recipient, _share);
                lastBal = IERC20(feesToken).balanceOf(address(this));
            }
        } else {
            userAccumulatedRatio[recipient] = accumulatedRatio;
        }
    }
}// None
pragma solidity 0.6.12;


contract VotingPowerFeesAndRewards is IRewardDistributionRecipient, VotingPowerFees{
    uint256 internal constant DURATION = 7 days;

    uint256 internal periodFinish = 0;

    uint256 internal rewardRate = 0;

    IERC20 internal rewardsToken;

    uint256 internal lastUpdateTime;

    uint256 internal rewardPerTokenStored;

    mapping(address => uint256) internal userRewardPerTokenPaid;

    mapping(address => uint256) internal rewards;

    function getDuration() external pure returns (uint256 _DURATION) {
        return DURATION;
    }

    function getPeriodFinish() external view returns (uint256 _periodFinish) {
        return periodFinish;
    }

    function getRewardRate() external view returns (uint256 _rewardRate) {
        return rewardRate;
    }

    function getRewardsToken() external view returns (IERC20 _rewardsToken) {
        return rewardsToken;
    }

    function getLastUpdateTime() external view returns (uint256 _lastUpdateTime) {
        return lastUpdateTime;
    }

    function getRewardPerTokenStored() external view returns (uint256 _rewardPerTokenStored) {
        return rewardPerTokenStored;
    }

    function getUserRewardPerTokenPaid(address _user) external view returns (uint256 _userRewardPerTokenPaid) {
        return userRewardPerTokenPaid[_user];
    }

    function getRewards(address _user) external view returns (uint256 _rewards) {
        return rewards[_user];
    }

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        IERC20 _stakingToken,
        IERC20 _feesToken,
        IERC20 _rewardsToken
    ) public VotingPowerFees(_stakingToken, _feesToken) {
        rewardsToken = _rewardsToken;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(
                rewards[account]
            );
    }

    function getReward() nonReentrant external updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward) external override onlyRewardDistribution updateReward(address(0)) {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(DURATION);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }
}// MIT

pragma solidity 0.6.12;

interface IGovernance {
    function withdraw(uint256) external;

    function getReward() external;

    function stake(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function exit() external;

    function voteFor(uint256) external;

    function voteAgainst(uint256) external;
}// None
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract Governance is VotingPowerFeesAndRewards {
    uint256 internal proposalCount;
    uint256 internal period = 3 days; // voting period in blocks ~ 17280 3 days for 15s/block
    uint256 internal minimum = 1e18;
    address internal governance;
    mapping(address => uint256) public voteLock; // period that your sake it locked to keep it for voting

    struct Proposal {
        uint256 id;
        address proposer;
        string ipfsCid;
        mapping(address => uint256) forVotes;
        mapping(address => uint256) againstVotes;
        uint256 totalForVotes;
        uint256 totalAgainstVotes;
        uint256 start; // block start;
        uint256 end; // start + period
    }

    mapping(uint256 => Proposal) public proposals;

    event NewGovernanceAddress(address newGovernance);
    event NewMinimumValue(uint256 newMinimum);
    event NewPeriodValue(uint256 newPeriod);

    modifier onlyGovernance() {
        require(msg.sender == governance, "!governance");
        _;
    }


    function getProposalCount() external view returns (uint256 _proposalCount) {
        return proposalCount;
    }

    function getPeriod() external view returns (uint256 _period) {
        return period;
    }

    function getMinimum() external view returns (uint256 _minimum) {
        return minimum;
    }

    function getGovernance() external view returns (address _governance) {
        return governance;
    }

    function getVoteLock(address _user) external view returns (uint256 _voteLock) {
        return voteLock[_user];
    }

    function getProposal(uint256 _proposalId)
        external
        view
        returns (
            uint256 id,
            address proposer,
            string memory ipfsCid,
            uint256 totalForVotes,
            uint256 totalAgainstVotes,
            uint256 start,
            uint256 end
        )
    {
        return (
            proposals[_proposalId].id,
            proposals[_proposalId].proposer,
            proposals[_proposalId].ipfsCid,
            proposals[_proposalId].totalForVotes,
            proposals[_proposalId].totalAgainstVotes,
            proposals[_proposalId].start,
            proposals[_proposalId].end
        );
    }

    function getProposals(uint256 _fromId, uint256 _toId)
        external
        view
        returns (
            uint256[] memory id,
            address[] memory proposer,
            string[] memory ipfsCid,
            uint256[] memory totalForVotes,
            uint256[] memory totalAgainstVotes,
            uint256[] memory start,
            uint256[] memory end
        )
    {
        require(_fromId < _toId, "invalid range");
        uint256 numberOfProposals = _toId.sub(_fromId);
        id = new uint256[](numberOfProposals);
        proposer = new address[](numberOfProposals);
        ipfsCid = new string[](numberOfProposals);
        totalForVotes = new uint256[](numberOfProposals);
        totalAgainstVotes = new uint256[](numberOfProposals);
        start = new uint256[](numberOfProposals);
        end = new uint256[](numberOfProposals);
        for (uint256 i = 0; i < numberOfProposals; i = i.add(1)) {
            uint256 proposalId = _fromId.add(i);
            id[i] = proposals[proposalId].id;
            proposer[i] = proposals[proposalId].proposer;
            ipfsCid[i] = proposals[proposalId].ipfsCid;
            totalForVotes[i] = proposals[proposalId].totalForVotes;
            totalAgainstVotes[i] = proposals[proposalId].totalAgainstVotes;
            start[i] = proposals[proposalId].start;
            end[i] = proposals[proposalId].end;
        }
    }

    function getProposalForVotes(uint256 _proposalId, address _user) external view returns (uint256 forVotes) {
        return (proposals[_proposalId].forVotes[_user]);
    }

    function getProposalAgainstVotes(uint256 _proposalId, address _user) external view returns (uint256 againstVotes) {
        return (proposals[_proposalId].againstVotes[_user]);
    }

    constructor(
        IERC20 _stakingToken,
        IERC20 _feesToken,
        IERC20 _rewardsToken,
        address _governance
    ) public VotingPowerFeesAndRewards(_stakingToken, _feesToken, _rewardsToken) {
        governance = _governance;
    }


    function seize(IERC20 _token, uint256 _amount) external onlyGovernance {
        require(_token != feesToken, "feesToken");
        require(_token != rewardsToken, "rewardsToken");
        require(_token != stakingToken, "stakingToken");
        _token.safeTransfer(governance, _amount);
    }

    function setStakingToken(IERC20 _stakingToken) external onlyGovernance {
        stakingToken = _stakingToken;
    }

    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
        emit NewGovernanceAddress(governance);
    }

    function setMinimum(uint256 _minimum) external onlyGovernance {
        minimum = _minimum;
        emit NewMinimumValue(minimum);
    }

    function setPeriod(uint256 _period) external onlyGovernance {
        period = _period;
        emit NewPeriodValue(period);
    }

    function propose(string calldata _ipfsCid) external {
        require(balanceOf(msg.sender) >= minimum, "<minimum");
        proposals[proposalCount++] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            ipfsCid: _ipfsCid,
            totalForVotes: 0,
            totalAgainstVotes: 0,
            start: block.timestamp,
            end: period.add(block.timestamp)
        });

        voteLock[msg.sender] = period.add(block.timestamp);
    }

    function revokeProposal(uint256 _id) external {
        require(proposals[_id].proposer == msg.sender, "!proposer");
        proposals[_id].end = 0;
    }

    function voteFor(uint256 id) external {
        require(proposals[id].start < block.timestamp, "<start");
        require(proposals[id].end > block.timestamp, ">end");
        uint256 votes = balanceOf(msg.sender).sub(proposals[id].forVotes[msg.sender]);
        proposals[id].totalForVotes = proposals[id].totalForVotes.add(votes);
        proposals[id].forVotes[msg.sender] = balanceOf(msg.sender);
        if (voteLock[msg.sender] < proposals[id].end) {
            voteLock[msg.sender] = proposals[id].end;
        }
    }

    function voteAgainst(uint256 id) external {
        require(proposals[id].start < block.timestamp, "<start");
        require(proposals[id].end > block.timestamp, ">end");
        uint256 votes = balanceOf(msg.sender).sub(proposals[id].againstVotes[msg.sender]);
        proposals[id].totalAgainstVotes = proposals[id].totalAgainstVotes.add(votes);
        proposals[id].againstVotes[msg.sender] = balanceOf(msg.sender);

        if (voteLock[msg.sender] < proposals[id].end) {
            voteLock[msg.sender] = proposals[id].end;
        }
    }

    function stake(uint256 amount) public override updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) nonReentrant public override updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(voteLock[msg.sender] < block.timestamp, "!locked");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }
}