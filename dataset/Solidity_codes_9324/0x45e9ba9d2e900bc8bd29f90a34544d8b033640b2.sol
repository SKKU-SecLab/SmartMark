
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
}// BUSL-1.1
pragma solidity 0.7.6;

interface IOrionGovernance
{

    function stake(uint56 adding_amount) external;

    function withdraw(uint56 removing_amount) external;


    function acceptNewLockAmount(address user, uint56 new_lock_amount) external;


    function acceptLock(address user, uint56 lock_increase_amount) external;

    function acceptUnlock(address user, uint56 lock_decrease_amount) external;


    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);


    function getReward() external;

    function exit() external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// BUSL-1.1
pragma solidity 0.7.6;
pragma abicoder v2;


contract OrionGovernance is IOrionGovernance, ReentrancyGuardUpgradeable, OwnableUpgradeable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserData
    {
        uint56 balance;
        uint56 locked_balance;
    }

    struct UserVault
    {
        uint56 amount;
        uint64 created_time;
    }


    IERC20 public staking_token_;

    mapping(address => UserData) public balances_;

    address public voting_contract_address_;

    uint56 public total_balance_;

    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    mapping(address => uint56) public user_burn_votes_;
    uint64 public burn_vote_end_;
    uint56 public total_votes_burn_;
    uint56 public total_votes_dont_burn_;

    mapping(address => UserVault[]) public vaults_;
    uint64 public extra_fee_seconds;
    uint16 public extra_fee_percent;  //  0 - 1000, where 1000
    uint16 public basic_fee_percent;  //  0 - 999

    uint56 public fee_total;



    function initialize(address staking_token) public initializer {

        require(staking_token != address(0), "OGI0");
        OwnableUpgradeable.__Ownable_init();
        staking_token_ = IERC20(staking_token);
    }

    function setVotingContractAddress(address voting_contract_address) external onlyOwner
    {

        voting_contract_address_ = voting_contract_address;
    }

    function lastTimeRewardApplicable() override public view returns (uint256) {

        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() override public view returns (uint256) {

        if (total_balance_ == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(uint(total_balance_))
        );
    }

    function earned(address account) override public view returns (uint256) {

        return uint(balances_[account].balance).mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function getRewardForDuration() override external view returns (uint256) {

        return rewardRate.mul(rewardsDuration);
    }

    function stake(uint56 adding_amount) override public nonReentrant updateReward(msg.sender)
    {

        require(adding_amount > 0, "CNS0");
        staking_token_.safeTransferFrom(msg.sender, address(this), adding_amount);

        uint56 balance = balances_[msg.sender].balance;
        balance += adding_amount;
        require(balance >= adding_amount, "OF(1)");
        balances_[msg.sender].balance = balance;

        uint56 total_balance = total_balance_;
        total_balance += adding_amount;
        require(total_balance >= adding_amount, "OF(3)");  //  Maybe not needed
        total_balance_ = total_balance;

        emit Staked(msg.sender, uint256(adding_amount));
    }

    function withdraw(uint56 removing_amount) override public nonReentrant updateReward(msg.sender)
    {

        require(removing_amount > 0, "CNW0");

        uint56 balance = balances_[msg.sender].balance;
        require(balance >= removing_amount, "CNW1");
        balance -= removing_amount;
        balances_[msg.sender].balance= balance;

        uint56 total_balance = total_balance_;
        require(total_balance >= removing_amount, "CNW2");
        total_balance -= removing_amount;
        total_balance_ = total_balance;

        uint56 locked_balance = balances_[msg.sender].locked_balance;
        require(locked_balance <= balance, "CNW3");

        if(voteBurnAvailable())
            require(user_burn_votes_[msg.sender] <= balance, "CNW4");

        vaults_[msg.sender].push(UserVault({
            amount: removing_amount,
            created_time: uint64(block.timestamp)}));

        emit Withdrawn(msg.sender, uint256(removing_amount));
    }

    function vaultWithdraw(uint index) public nonReentrant
    {

        UserVault memory vault = vaults_[msg.sender][index];
        uint fee_percent = basic_fee_percent;
        if(vault.created_time + extra_fee_seconds > block.timestamp)
            fee_percent += extra_fee_percent;

        uint vault_amount = uint(vault.amount);
        uint fee_orn = vault_amount.mul(fee_percent).div(1000);

        fee_total += uint56(fee_orn);

        uint len = vaults_[msg.sender].length;

        if(index < len-1)
            vaults_[msg.sender][index] = vaults_[msg.sender][len-1];

        vaults_[msg.sender].pop();

        staking_token_.safeTransfer(msg.sender, vault_amount.sub(fee_orn));
    }

    function setVaultParameters(uint16 extra_fee_percent_, uint64 extra_fee_seconds_, uint16 basic_fee_percent_) external onlyOwner
    {

        require(extra_fee_percent_ + basic_fee_percent_ < 1000, "VF_1");
        extra_fee_percent = extra_fee_percent_;
        extra_fee_seconds = extra_fee_seconds_;
        basic_fee_percent = basic_fee_percent_;
    }

    function burn(uint56 burn_size, address to) external onlyOwner
    {

        require(burn_size <= fee_total, "OW_CNB");
        fee_total -= burn_size;
        staking_token_.safeTransfer(to, burn_size);
    }

    function getReward() virtual override public nonReentrant updateReward(msg.sender) {

        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            staking_token_.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() virtual override external {

        withdraw(balances_[msg.sender].balance);
        getReward();
    }

    function acceptNewLockAmount(
        address user,
        uint56 new_lock_amount
    ) external override onlyVotingContract
    {

        uint56 balance = balances_[user].balance;
        require(balance >= new_lock_amount, "Cannot lock");
        balances_[user].locked_balance = new_lock_amount;
    }

    function acceptLock(
        address user,
        uint56 lock_increase_amount
    )  external override onlyVotingContract
    {

        require(lock_increase_amount > 0, "Can't inc by 0");

        uint56 balance = balances_[user].balance;
        uint56 locked_balance = balances_[user].locked_balance;

        locked_balance += lock_increase_amount;
        require(locked_balance >= lock_increase_amount, "OF(4)");
        require(locked_balance <= balance, "can't lock more");

        balances_[user].locked_balance = locked_balance;
    }

    function acceptUnlock(
        address user,
        uint56 lock_decrease_amount
    )  external override onlyVotingContract
    {

        require(lock_decrease_amount > 0, "Can't dec by 0");

        uint56 locked_balance = balances_[user].locked_balance;
        require(locked_balance >= lock_decrease_amount, "Can't unlock more");

        locked_balance -= lock_decrease_amount;
        balances_[user].locked_balance = locked_balance;
    }

    function getBalance(address user) public view returns(uint56)
    {

        return balances_[user].balance;
    }

    function getLockedBalance(address user) public view returns(uint56)
    {

        return balances_[user].locked_balance;
    }

    function getTotalBalance() public view returns(uint56)
    {

        return total_balance_;
    }

    function getTotalLockedBalance(address user) public view returns(uint56)
    {

        uint56 locked_balance = balances_[user].locked_balance;
        if(voteBurnAvailable())
        {
            uint56 burn_vote_balance = user_burn_votes_[user];
            if(burn_vote_balance > locked_balance)
                locked_balance = burn_vote_balance;
        }

        return locked_balance;
    }

    function getVaults(address wallet) public view returns(UserVault[] memory)
    {

        return vaults_[wallet];
    }

    function getAvailableWithdrawBalance(address user) public view returns(uint56)
    {

        return balances_[user].balance - getTotalLockedBalance(user);
    }

    function notifyRewardAmount(uint256 reward, uint256 _rewardsDuration) external onlyOwner updateReward(address(0)) {

        require((_rewardsDuration> 1 days) && (_rewardsDuration < 365 days), "Incorrect rewards duration");
        rewardsDuration = _rewardsDuration;
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        uint balance = staking_token_.balanceOf(address(this)); //  TODO: review
        require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    function emergencyAssetWithdrawal(address asset) external onlyOwner {

        IERC20 token = IERC20(asset);
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }

    function voteBurn(uint56 voting_amount, bool vote_for_burn) public
    {

        require(voteBurnAvailable(), "VB_FIN");
        uint56 balance = balances_[msg.sender].balance;
        uint56 voted_balance = user_burn_votes_[msg.sender];
        require(balance >= voted_balance, "VB_OF");
        require(voting_amount <= balance - voted_balance, "VB_NE_ORN");
        user_burn_votes_[msg.sender] = voted_balance + voting_amount;
        if(vote_for_burn)
            total_votes_burn_ += voting_amount;
        else
            total_votes_dont_burn_ += voting_amount;
    }

    function voteBurnAvailable() public view returns(bool)
    {

        return (block.timestamp <= burn_vote_end_);
    }

    function setBurnVoteEnd(uint64 burn_vote_end) external onlyOwner
    {

        burn_vote_end_ = burn_vote_end;
    }

    modifier onlyVotingContract()
    {

        require(msg.sender == voting_contract_address_, "must be voting");
        _;
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

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}