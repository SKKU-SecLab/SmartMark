
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
}// Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


abstract contract GovernedMulti is Ownable {
    IERC20[] public rewardTokens;
    IERC20 public poolToken;

    uint256 public numRewardTokens;
    mapping(address => address) public rewardSources;
    mapping(address => uint256) public rewardRatesPerSecond;

    mapping(address => uint256) public lastSoftPullTs;

    function approveNewRewardToken(address token) public {
        require(msg.sender == owner(), "only owner can call");
        require(!isApprovedToken(token), "token already approved");
        require(token != address(poolToken), "reward token and pool token must be different");

        rewardTokens.push(IERC20(token));
        numRewardTokens++;
    }

    function setRewardSource(address token, address src) public {
        require(msg.sender == owner(), "only owner can call");
        require(src != address(0), "source cannot be 0x0");
        require(isApprovedToken(token), "token not approved");

        rewardSources[token] = src;
    }

    function setRewardRatePerSecond(address token, uint256 rate) public {
        require(msg.sender == owner(), "only owner can call");
        require(isApprovedToken(token), "token not approved");

        pullRewardFromSource(token);

        rewardRatesPerSecond[token] = rate;

        if (lastSoftPullTs[token] == 0) {
            lastSoftPullTs[token] = block.timestamp;
        }
    }

    function isApprovedToken(address token) public view returns (bool) {
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            if (address(rewardTokens[i]) == token) {
                return true;
            }
        }

        return false;
    }

    function pullRewardFromSource(address token) public virtual;
}// Apache-2.0
pragma solidity 0.7.6;


contract PoolMulti is GovernedMulti, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 constant multiplierScale = 10 ** 18;

    mapping(address => uint256) public rewardsNotTransferred;
    mapping(address => uint256) public balancesBefore;
    mapping(address => uint256) public currentMultipliers;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public userMultipliers;
    mapping(address => mapping(address => uint256)) public owed;

    uint256 public poolSize;

    event ClaimRewardToken(address indexed user, address token, uint256 amount);
    event Deposit(address indexed user, uint256 amount, uint256 balanceAfter);
    event Withdraw(address indexed user, uint256 amount, uint256 balanceAfter);

    constructor(address _owner, address _poolToken) {
        require(_poolToken != address(0), "pool token must not be 0x0");

        transferOwnership(_owner);

        poolToken = IERC20(_poolToken);
    }

    function deposit(uint256 amount) public {

        require(amount > 0, "amount must be greater than 0");

        require(
            poolToken.allowance(msg.sender, address(this)) >= amount,
            "allowance must be greater than 0"
        );

        _calculateOwed(msg.sender);

        uint256 newBalance = balances[msg.sender].add(amount);
        balances[msg.sender] = newBalance;
        poolSize = poolSize.add(amount);

        poolToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount, newBalance);
    }

    function withdraw(uint256 amount) public {

        require(amount > 0, "amount must be greater than 0");

        uint256 currentBalance = balances[msg.sender];
        require(currentBalance >= amount, "insufficient balance");

        _calculateOwed(msg.sender);

        uint256 newBalance = currentBalance.sub(amount);
        balances[msg.sender] = newBalance;
        poolSize = poolSize.sub(amount);

        poolToken.safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount, newBalance);
    }

    function claim_allTokens() public nonReentrant returns (uint256[] memory amounts){

        amounts = new uint256[](rewardTokens.length);
        _calculateOwed(msg.sender);

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            uint256 amount = _claim(address(rewardTokens[i]));
            amounts[i] = amount;
        }
    }

    function claim(address token) public nonReentrant returns (uint256){

        _calculateOwed(msg.sender);

        return _claim(token);
    }

    function withdrawAndClaim(uint256 amount) public {

        withdraw(amount);
        claim_allTokens();
    }

    function pullRewardFromSource_allTokens() public {

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            pullRewardFromSource(address(rewardTokens[i]));
        }
    }

    function pullRewardFromSource(address token) public override {

        softPullReward(token);

        uint256 amountToTransfer = rewardsNotTransferred[token];

        if (amountToTransfer == 0) {
            return;
        }

        rewardsNotTransferred[token] = 0;

        IERC20(token).safeTransferFrom(rewardSources[token], address(this), amountToTransfer);
    }

    function rewardLeft(address token) external returns (uint256) {

        softPullReward(token);

        return IERC20(token).allowance(rewardSources[token], address(this)).sub(rewardsNotTransferred[token]);
    }

    function softPullReward_allTokens() internal {

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            softPullReward(address(rewardTokens[i]));
        }
    }

    function softPullReward(address token) internal {

        uint256 lastPullTs = lastSoftPullTs[token];

        if (lastPullTs == block.timestamp) {
            return;
        }

        uint256 rate = rewardRatesPerSecond[token];
        address source = rewardSources[token];

        if (rate == 0 || source == address(0)) {
            return;
        }

        uint256 allowance = IERC20(token).allowance(source, address(this));
        uint256 rewardNotTransferred = rewardsNotTransferred[token];
        if (allowance == 0 || allowance <= rewardNotTransferred) {
            lastSoftPullTs[token] = block.timestamp;
            return;
        }

        uint256 timeSinceLastPull = block.timestamp.sub(lastPullTs);
        uint256 amountToPull = timeSinceLastPull.mul(rate);

        uint256 allowanceLeft = allowance.sub(rewardNotTransferred);
        if (amountToPull > allowanceLeft) {
            amountToPull = allowanceLeft;
        }

        rewardsNotTransferred[token] = rewardNotTransferred.add(amountToPull);
        lastSoftPullTs[token] = block.timestamp;
    }

    function ackFunds_allTokens() internal {

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            ackFunds(address(rewardTokens[i]));
        }
    }

    function ackFunds(address token) internal {

        uint256 balanceNow = IERC20(token).balanceOf(address(this)).add(rewardsNotTransferred[token]);
        uint256 balanceBeforeLocal = balancesBefore[token];

        if (balanceNow <= balanceBeforeLocal || balanceNow == 0) {
            balancesBefore[token] = balanceNow;
            return;
        }

        uint256 poolSizeLocal = poolSize;
        if (poolSizeLocal == 0) {
            return;
        }

        uint256 diff = balanceNow.sub(balanceBeforeLocal);
        uint256 multiplier = currentMultipliers[token].add(diff.mul(multiplierScale).div(poolSizeLocal));

        balancesBefore[token] = balanceNow;
        currentMultipliers[token] = multiplier;
    }

    function _calculateOwed(address user) internal {

        softPullReward_allTokens();
        ackFunds_allTokens();

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            address token = address(rewardTokens[i]);
            uint256 reward = _userPendingReward(user, token);

            owed[user][token] = owed[user][token].add(reward);
            userMultipliers[user][token] = currentMultipliers[token];
        }
    }

    function _userPendingReward(address user, address token) internal view returns (uint256) {

        uint256 multiplier = currentMultipliers[token].sub(userMultipliers[user][token]);

        return balances[user].mul(multiplier).div(multiplierScale);
    }

    function _claim(address token) internal returns (uint256) {

        uint256 amount = owed[msg.sender][token];
        if (amount == 0) {
            return 0;
        }

        if (IERC20(token).balanceOf(address(this)) < amount) {
            pullRewardFromSource(token);
        }

        owed[msg.sender][token] = 0;

        IERC20(token).safeTransfer(msg.sender, amount);

        balancesBefore[token] = balancesBefore[token].sub(amount);

        emit ClaimRewardToken(msg.sender, token, amount);

        return amount;
    }
}// Apache-2.0
pragma solidity 0.7.6;


contract PoolFactoryMulti is Ownable {

    PoolMulti[] public pools;
    uint256 public numberOfPools;

    struct RewardToken {
        address tokenAddress;
        address rewardSource;
        uint256 rewardRate;
    }

    event PoolMultiCreated(address pool);

    constructor(address _owner) {
        transferOwnership(_owner);
    }

    function deployPool(address _owner, address _poolToken, RewardToken[] calldata rewardTokens) public returns (address) {

        require(msg.sender == owner(), "only owner can call");

        PoolMulti pool = new PoolMulti(address(this), _poolToken);
        pools.push(pool);
        numberOfPools++;

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            RewardToken memory t = rewardTokens[i];
            pool.approveNewRewardToken(t.tokenAddress);

            if (t.rewardSource != address(0)) {
                require(t.rewardRate != 0, "reward rate cannot be 0");

                pool.setRewardSource(t.tokenAddress, t.rewardSource);
                pool.setRewardRatePerSecond(t.tokenAddress, t.rewardRate);
            }
        }

        pool.transferOwnership(_owner);

        emit PoolMultiCreated(address(pool));

        return address(pool);
    }
}