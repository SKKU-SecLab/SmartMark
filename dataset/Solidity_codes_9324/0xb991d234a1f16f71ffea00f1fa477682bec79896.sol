
pragma solidity 0.7.1;


interface StakingInterface {

    function stake(address token, uint128 amount) external;


    function withdraw(address token, uint128 amount) external;


    function receiveReward(address token) external returns (uint256 rewards);


    function changeStakeTarget(
        address oldTarget,
        address newTarget,
        uint128 amount
    ) external;


    function getStakingTokenAddress() external view returns (address);


    function getStartTimestamp() external view returns (uint256);


    function getTokenInfo(address token)
        external
        view
        returns (
            uint256 currentTerm,
            uint256 latestTerm,
            uint256 totalRemainingRewards,
            uint256 currentReward,
            uint256 nextTermRewards,
            uint128 currentStaking,
            uint128 nextTermStaking
        );


    function getConfigs() external view returns (uint256 startTimestamp, uint256 termInterval);


    function getStakingDestinations(address account) external view returns (address[] memory);


    function getTermInfo(address token, uint256 term)
        external
        view
        returns (
            uint128 stakeAdd,
            uint128 stakeSum,
            uint256 rewardSum
        );


    function getAccountInfo(address token, address account)
        external
        view
        returns (
            uint256 userTerm,
            uint256 stakeAmount,
            uint128 nextAddedStakeAmount,
            uint256 currentReward,
            uint256 nextLatestTermUserRewards,
            uint128 depositAmount,
            uint128 withdrawableStakingAmount
        );

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



contract StakingVote {

    using SafeMath for uint256;


    address internal _governanceAddress;
    mapping(address => uint256) internal _voteNum;


    event LogUpdateGovernanceAddress(address newAddress);


    constructor(address governanceAddress) {
        _governanceAddress = governanceAddress;
    }


    modifier isGovernance(address account) {

        require(account == _governanceAddress, "sender must be governance address");
        _;
    }


    function updateGovernanceAddress(address newGovernanceAddress)
        external
        isGovernance(msg.sender)
    {

        _governanceAddress = newGovernanceAddress;

        emit LogUpdateGovernanceAddress(newGovernanceAddress);
    }

    function voteDeposit(address account, uint256 amount) external isGovernance(msg.sender) {

        _updVoteSub(account, amount);
    }

    function voteWithdraw(address account, uint256 amount) external isGovernance(msg.sender) {

        _updVoteAdd(account, amount);
    }


    function _updVoteAdd(address account, uint256 amount) internal {

        require(_voteNum[account] + amount >= amount, "overflow the amount of votes");
        _voteNum[account] += amount;
    }

    function _updVoteSub(address account, uint256 amount) internal {

        require(_voteNum[account] >= amount, "underflow the amount of votes");
        _voteNum[account] -= amount;
    }


    function getGovernanceAddress() external view returns (address) {

        return _governanceAddress;
    }

    function getVoteNum(address account) external view returns (uint256) {

        return _voteNum[account];
    }
}


library AddressList {

    function insert(address[] storage addressList, address token) internal {

        if (token == address(0)) {
            return;
        }

        for (uint256 i = 0; i < addressList.length; i++) {
            if (addressList[i] == address(0)) {
                addressList[i] = token;
                return;
            }
        }

        addressList.push(token);
    }

    function remove(address[] storage addressList, address token) internal returns (bool success) {

        if (token == address(0)) {
            return true;
        }

        for (uint256 i = 0; i < addressList.length; i++) {
            if (addressList[i] == token) {
                delete addressList[i];
                return true;
            }
        }
    }

    function get(address[] storage addressList)
        internal
        view
        returns (address[] memory denseAddressList)
    {

        uint256 numOfElements = 0;
        for (uint256 i = 0; i < addressList.length; i++) {
            if (addressList[i] != address(0)) {
                numOfElements++;
            }
        }

        denseAddressList = new address[](numOfElements);
        uint256 j = 0;
        for (uint256 i = 0; i < addressList.length; i++) {
            if (addressList[i] != address(0)) {
                denseAddressList[j] = addressList[i];
                j++;
            }
        }
    }
}



contract StakingDestinations {

    using AddressList for address[];


    mapping(address => address[]) internal _stakingDestinations;


    function _addDestinations(address account, address token) internal {

        return _stakingDestinations[account].insert(token);
    }

    function _removeDestinations(address account, address token) internal returns (bool success) {

        return _stakingDestinations[account].remove(token);
    }

    function _getStakingDestinations(address account) internal view returns (address[] memory) {

        return _stakingDestinations[account].get();
    }
}


contract TransferETH {

    receive() external payable {}

    function _transferETH(
        address payable recipient,
        uint256 amount,
        string memory errorMessage
    ) internal {

        (bool success, ) = recipient.call{value: amount}("");
        require(success, errorMessage);
    }

    function _transferETH(address payable recipient, uint256 amount) internal {

        _transferETH(recipient, amount, "Transfer amount exceeds balance");
    }
}



library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
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


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}










contract Staking is
    StakingInterface,
    ReentrancyGuard,
    StakingVote,
    StakingDestinations,
    TransferETH
{

    using SafeMath for uint256;
    using SafeMath for uint128;
    using SafeCast for uint256;
    using SafeERC20 for IERC20;


    address internal constant ETH_ADDRESS = address(0);
    uint256 internal constant MAX_TERM = 1000;

    IERC20 internal immutable _stakingToken;
    uint256 internal immutable _startTimestamp; // timestamp of the term 0
    uint256 internal immutable _termInterval; // time interval between terms in second


    struct AccountInfo {
        uint128 stakeAmount; // active stake amount of the user at userTerm
        uint128 added; // the added amount of stake which will be merged to stakeAmount at the term+1.
        uint256 userTerm; // the term when the user executed any function last time (all the terms before the term has been already settled)
        uint256 rewards; // the total amount of rewards until userTerm
    }

    mapping(address => mapping(address => AccountInfo)) internal _accountInfo;

    struct TermInfo {
        uint128 stakeAdd; // the total added amount of stake which will be merged to stakeSum at the term+1
        uint128 stakeSum; // the total staking amount at the term
        uint256 rewardSum; // the total amount of rewards at the term
    }

    mapping(address => mapping(uint256 => TermInfo)) internal _termInfo;

    mapping(address => uint256) internal _currentTerm; // (token => term); the current term (all the info prior to this term is fixed)
    mapping(address => uint256) internal _totalRemainingRewards; // (token => amount); total unsettled amount of rewards


    event RewardAdded(address indexed token, uint256 reward);
    event Staked(address indexed token, address indexed account, uint128 amount);
    event Withdrawn(address indexed token, address indexed account, uint128 amount);
    event RewardPaid(address indexed token, address indexed account, uint256 reward);


    constructor(
        address stakingTokenAddress,
        address governance,
        uint256 startTimestamp,
        uint256 termInterval
    ) StakingVote(governance) {
        require(startTimestamp <= block.timestamp, "startTimestamp should be past time");
        _stakingToken = IERC20(stakingTokenAddress);
        _startTimestamp = startTimestamp;
        _termInterval = termInterval;
    }


    modifier updateReward(address token, address account) {

        AccountInfo memory accountInfo = _accountInfo[token][account];
        uint256 startTerm = accountInfo.userTerm;
        for (
            uint256 term = accountInfo.userTerm;
            term < _currentTerm[token] && term < startTerm + MAX_TERM;
            term++
        ) {
            TermInfo memory termInfo = _termInfo[token][term];
            if (termInfo.stakeSum != 0) {
                accountInfo.rewards = accountInfo.rewards.add(
                    accountInfo.stakeAmount.mul(termInfo.rewardSum).div(termInfo.stakeSum)
                ); // `(your stake amount) / (total stake amount) * total rewards` in each term
            }
            accountInfo.stakeAmount = accountInfo.stakeAmount.add(accountInfo.added).toUint128();
            accountInfo.added = 0;
            accountInfo.userTerm = term + 1; // calculated until this term
            if (accountInfo.stakeAmount == 0) {
                accountInfo.userTerm = _currentTerm[token];
                break; // skip unnecessary term
            }
        }
        _accountInfo[token][account] = accountInfo;
        _;
    }

    modifier updateTerm(address token) {

        if (_currentTerm[token] < _getLatestTerm()) {
            uint256 currentBalance = (token == ETH_ADDRESS)
                ? address(this).balance
                : IERC20(token).balanceOf(address(this));
            uint256 nextRewardSum = currentBalance.sub(_totalRemainingRewards[token]);

            TermInfo memory currentTermInfo = _termInfo[token][_currentTerm[token]];
            uint128 nextStakeSum = currentTermInfo
                .stakeSum
                .add(currentTermInfo.stakeAdd)
                .toUint128();
            uint256 carriedReward = currentTermInfo.stakeSum == 0 ? currentTermInfo.rewardSum : 0; // if stakeSum is 0, carried forward until someone stakes
            uint256 nextTerm = nextStakeSum == 0 ? _getLatestTerm() : _currentTerm[token] + 1; // if next stakeSum is 0, skip to latest term
            _termInfo[token][nextTerm] = TermInfo({
                stakeAdd: 0,
                stakeSum: nextStakeSum,
                rewardSum: nextRewardSum.add(carriedReward)
            });

            if (nextTerm < _getLatestTerm()) {
                _termInfo[token][_getLatestTerm()] = TermInfo({
                    stakeAdd: 0,
                    stakeSum: nextStakeSum,
                    rewardSum: 0
                });
            }

            _totalRemainingRewards[token] = currentBalance; // total amount of unpaid reward
            _currentTerm[token] = _getLatestTerm();
        }
        _;
    }


    function stake(address token, uint128 amount)
        external
        override
        nonReentrant
        updateTerm(token)
        updateReward(token, msg.sender)
    {

        if (_accountInfo[token][msg.sender].userTerm < _currentTerm[token]) {
            return;
        }

        require(amount != 0, "staking amount should be positive number");

        _updVoteAdd(msg.sender, amount);
        _stake(msg.sender, token, amount);
        _stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(address token, uint128 amount)
        external
        override
        nonReentrant
        updateTerm(token)
        updateReward(token, msg.sender)
    {

        if (_accountInfo[token][msg.sender].userTerm < _currentTerm[token]) {
            return;
        }

        require(amount != 0, "withdrawing amount should be positive number");

        _updVoteSub(msg.sender, amount);
        _withdraw(msg.sender, token, amount);
        _stakingToken.safeTransfer(msg.sender, amount);
    }

    function receiveReward(address token)
        external
        override
        nonReentrant
        updateTerm(token)
        updateReward(token, msg.sender)
        returns (uint256 rewards)
    {

        rewards = _accountInfo[token][msg.sender].rewards;
        if (rewards != 0) {
            _totalRemainingRewards[token] = _totalRemainingRewards[token].sub(rewards); // subtract the total unpaid reward
            _accountInfo[token][msg.sender].rewards = 0;
            if (token == ETH_ADDRESS) {
                _transferETH(msg.sender, rewards);
            } else {
                IERC20(token).safeTransfer(msg.sender, rewards);
            }
            emit RewardPaid(token, msg.sender, rewards);
        }
    }

    function changeStakeTarget(
        address oldTarget,
        address newTarget,
        uint128 amount
    )
        external
        override
        nonReentrant
        updateTerm(oldTarget)
        updateReward(oldTarget, msg.sender)
        updateTerm(newTarget)
        updateReward(newTarget, msg.sender)
    {

        if (
            _accountInfo[oldTarget][msg.sender].userTerm < _currentTerm[oldTarget] ||
            _accountInfo[newTarget][msg.sender].userTerm < _currentTerm[newTarget]
        ) {
            return;
        }

        require(amount != 0, "transfering amount should be positive number");

        _withdraw(msg.sender, oldTarget, amount);
        _stake(msg.sender, newTarget, amount);
    }


    function _stake(
        address account,
        address token,
        uint128 amount
    ) internal {

        AccountInfo memory accountInfo = _accountInfo[token][account];
        if (accountInfo.stakeAmount == 0 && accountInfo.added == 0) {
            _addDestinations(account, token);
        }

        _accountInfo[token][account].added = accountInfo.added.add(amount).toUint128(); // added when the term is shifted (the user)

        uint256 term = _currentTerm[token];
        _termInfo[token][term].stakeAdd = _termInfo[token][term].stakeAdd.add(amount).toUint128(); // added when the term is shifted (global)

        emit Staked(token, account, amount);
    }

    function _withdraw(
        address account,
        address token,
        uint128 amount
    ) internal {

        AccountInfo memory accountInfo = _accountInfo[token][account];
        require(
            accountInfo.stakeAmount.add(accountInfo.added) >= amount,
            "exceed withdrawable amount"
        );

        if (accountInfo.stakeAmount + accountInfo.added == amount) {
            _removeDestinations(account, token);
        }

        uint256 currentTerm = _currentTerm[token];
        TermInfo memory termInfo = _termInfo[token][currentTerm];
        if (accountInfo.added > amount) {
            accountInfo.added -= amount;
            termInfo.stakeAdd -= amount;
        } else {
            termInfo.stakeSum = termInfo.stakeSum.sub(amount - accountInfo.added).toUint128();
            termInfo.stakeAdd = termInfo.stakeAdd.sub(accountInfo.added).toUint128();
            accountInfo.stakeAmount = accountInfo
                .stakeAmount
                .sub(amount - accountInfo.added)
                .toUint128();
            accountInfo.added = 0;
        }

        _accountInfo[token][account] = accountInfo;
        _termInfo[token][currentTerm] = termInfo;

        emit Withdrawn(token, account, amount);
    }

    function _getNextTermReward(address token) internal view returns (uint256 rewards) {

        uint256 currentBalance = (token == ETH_ADDRESS)
            ? address(this).balance
            : IERC20(token).balanceOf(address(this));
        return
            (currentBalance > _totalRemainingRewards[token])
                ? currentBalance - _totalRemainingRewards[token]
                : 0;
    }

    function _getLatestTerm() internal view returns (uint256) {

        return (block.timestamp - _startTimestamp) / _termInterval;
    }


    function getStakingTokenAddress() external view override returns (address stakingTokenAddress) {

        return address(_stakingToken);
    }

    function getStartTimestamp() external view override returns (uint256) {

        return _startTimestamp;
    }

    function getConfigs()
        external
        view
        override
        returns (uint256 startTimestamp, uint256 termInterval)
    {

        startTimestamp = _startTimestamp;
        termInterval = _termInterval;
    }

    function getStakingDestinations(address account)
        external
        view
        override
        returns (address[] memory)
    {

        return _getStakingDestinations(account);
    }

    function getTokenInfo(address token)
        external
        view
        override
        returns (
            uint256 currentTerm,
            uint256 latestTerm,
            uint256 totalRemainingRewards,
            uint256 currentReward,
            uint256 nextTermRewards,
            uint128 currentStaking,
            uint128 nextTermStaking
        )
    {

        currentTerm = _currentTerm[token];
        latestTerm = _getLatestTerm();
        totalRemainingRewards = _totalRemainingRewards[token];
        currentReward = _termInfo[token][currentTerm].rewardSum;
        nextTermRewards = _getNextTermReward(token);
        TermInfo memory termInfo = _termInfo[token][_currentTerm[token]];
        currentStaking = termInfo.stakeSum;
        nextTermStaking = termInfo.stakeSum.add(termInfo.stakeAdd).toUint128();
    }

    function getTermInfo(address token, uint256 term)
        external
        view
        override
        returns (
            uint128 stakeAdd,
            uint128 stakeSum,
            uint256 rewardSum
        )
    {

        TermInfo memory termInfo = _termInfo[token][term];
        stakeAdd = termInfo.stakeAdd;
        stakeSum = termInfo.stakeSum;
        if (term == _currentTerm[token] + 1) {
            rewardSum = _getNextTermReward(token);
        } else {
            rewardSum = termInfo.rewardSum;
        }
    }

    function getAccountInfo(address token, address account)
        external
        view
        override
        returns (
            uint256 userTerm,
            uint256 stakeAmount,
            uint128 nextAddedStakeAmount,
            uint256 currentReward,
            uint256 nextLatestTermUserRewards,
            uint128 depositAmount,
            uint128 withdrawableStakingAmount
        )
    {

        AccountInfo memory accountInfo = _accountInfo[token][account];
        userTerm = accountInfo.userTerm;
        stakeAmount = accountInfo.stakeAmount;
        nextAddedStakeAmount = accountInfo.added;
        currentReward = accountInfo.rewards;
        uint256 currentTerm = _currentTerm[token];
        TermInfo memory termInfo = _termInfo[token][currentTerm];
        uint256 nextLatestTermRewards = _getNextTermReward(token);
        nextLatestTermUserRewards = termInfo.stakeSum.add(termInfo.stakeAdd) == 0
            ? 0
            : nextLatestTermRewards.mul(accountInfo.stakeAmount.add(accountInfo.added)) /
                (termInfo.stakeSum + termInfo.stakeAdd);
        depositAmount = accountInfo.stakeAmount.add(accountInfo.added).toUint128();
        uint128 availableForVoting = _voteNum[account].toUint128();
        withdrawableStakingAmount = depositAmount < availableForVoting
            ? depositAmount
            : availableForVoting;
    }
}