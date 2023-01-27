
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;


contract AXL_Flexible_Staking is Ownable {

    using SafeERC20 for IERC20;

    struct UserData {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
    }

    struct PoolData {
        IERC20 stakingToken;
        uint256 lastRewardBlock;  
        uint256 accRewardPerShare;
    }

    IERC20 public rewardToken;
    uint256 public rewardPerBlock = 1 * 1e18; // 1 token
    uint public totalStaked;
    uint256 public endBlock;


    PoolData public liquidityMining;
    mapping(address => UserData) public userData;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    function updateRewardToken(IERC20 _newRewadToken) external onlyOwner {

        rewardToken = _newRewadToken;
    }

    function setPoolData(IERC20 _rewardToken, IERC20 _stakingToken) external onlyOwner {

        require(address(rewardToken) == address(0) && address(liquidityMining.stakingToken) == address(0), 'Token is already set');
        rewardToken = _rewardToken;
        liquidityMining = PoolData({stakingToken : _stakingToken, lastRewardBlock : 0, accRewardPerShare : 0});
    }

    function startMining(uint256 startBlock) external onlyOwner {

        require(liquidityMining.lastRewardBlock == 0, 'Mining already started');
        liquidityMining.lastRewardBlock = startBlock;
    }

    function endMining(uint256 _endBlock) external onlyOwner {

        endBlock = _endBlock;
    }

 
    function updatePool() internal { 

        if (endBlock != 0) {
            require(endBlock > block.number, 'Mining has ended');
        }       
        require(liquidityMining.lastRewardBlock > 0 && block.number >= liquidityMining.lastRewardBlock, 'Mining not yet started');
        if (block.number <= liquidityMining.lastRewardBlock) {
            return;
        }
        uint256 stakingTokenSupply = totalStaked;
        if (stakingTokenSupply == 0) {
            liquidityMining.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - liquidityMining.lastRewardBlock;
        uint256 tokensReward = multiplier * rewardPerBlock;
        liquidityMining.accRewardPerShare = liquidityMining.accRewardPerShare + (tokensReward * 1e18 / stakingTokenSupply);
        liquidityMining.lastRewardBlock = block.number;
    }

    function deposit(uint256 amount) external {

        if (endBlock != 0) {
            require(endBlock > block.number, 'Mining has ended');
        }
        UserData storage user = userData[msg.sender];
        updatePool();

        uint256 accRewardPerShare = liquidityMining.accRewardPerShare;

        if (user.amount > 0) {
            uint256 pending = (user.amount * accRewardPerShare / 1e18) - user.rewardDebt;
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards + pending;
            }
        }
        if (amount > 0) {
            liquidityMining.stakingToken.safeTransferFrom(address(msg.sender), address(this), amount);
            user.amount = user.amount + amount;
        }
        totalStaked = totalStaked + amount;
        
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {

        if (endBlock != 0) {
            require(endBlock > block.number, 'Mining has ended');
        }
        UserData storage user = userData[msg.sender];
        require(user.amount >= amount, "Withdrawing amount is more than staked amount");
        updatePool();

        uint256 accRewardPerShare = liquidityMining.accRewardPerShare;

        uint256 pending = (user.amount * accRewardPerShare / 1e18) - user.rewardDebt;
        if (pending > 0) {
            user.pendingRewards = user.pendingRewards + pending;
        }
        if (amount > 0) {
            user.amount = user.amount - amount;
            liquidityMining.stakingToken.safeTransfer(address(msg.sender), amount);
        }
        totalStaked = totalStaked - amount;
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
        emit Withdraw(msg.sender, amount);
    }

    function claim() external {

        if (endBlock != 0) {
            require(endBlock > block.number, 'Mining has been ended');
        }
        UserData storage user = userData[msg.sender];
        updatePool();

        uint256 accRewardPerShare = liquidityMining.accRewardPerShare;

        uint256 pending = (user.amount * accRewardPerShare / 1e18) - user.rewardDebt;
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards + pending;
            uint256 tempBalance = rewardToken.balanceOf(address(this));
            require(totalStaked + user.pendingRewards <= tempBalance, 'Insufficient reward tokens for this transfer');
            uint256 claimedAmount = safeRewardTransfer(msg.sender, user.pendingRewards);
            emit Claim(msg.sender, claimedAmount);
            user.pendingRewards = user.pendingRewards - claimedAmount;
        }
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
    }

    function safeRewardTransfer(address to, uint256 amount) internal returns (uint256) {

        uint256 balance = rewardToken.balanceOf(address(this));
        require(amount > 0, 'Reward amount must be more than zero');
        require(balance > 0, 'Insufficient reward tokens for this transfer');
        if (amount > balance) {
            rewardToken.transfer(to, balance);
            return balance;
        }
        rewardToken.transfer(to, amount);
        return amount;
    }

    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {

        require(_rewardPerBlock > 0, "Reward per block must be more than zero");
        rewardPerBlock = _rewardPerBlock;
    }

    
    function pendingRewards(address _user) external view returns (uint256) {

        if (endBlock != 0) {
            require(endBlock > block.number, 'Mining has ended');
        }
        if (liquidityMining.lastRewardBlock == 0 || block.number < liquidityMining.lastRewardBlock) {
            return 0;
        }

        UserData storage user = userData[_user];
        uint256 accRewardPerShare = liquidityMining.accRewardPerShare;
        uint256 stakingTokenSupply = totalStaked;

        if (block.number > liquidityMining.lastRewardBlock && stakingTokenSupply != 0) {
            uint256 perBlock = rewardPerBlock;
            uint256 multiplier = block.number - liquidityMining.lastRewardBlock;
            uint256 reward = multiplier * perBlock;
            accRewardPerShare = accRewardPerShare + (reward * 1e18 / stakingTokenSupply);
        }

        return (user.amount * accRewardPerShare / 1e18) - user.rewardDebt + user.pendingRewards;
    }

    function extraTokensWithdraw() external onlyOwner {

        require(endBlock != 0, 'Set end block');
        require(block.number > endBlock, 'Mining in progress');
        uint256 rewardSupply = rewardToken.balanceOf(address(this));
        if(rewardToken == liquidityMining.stakingToken)
        {
            rewardSupply = rewardSupply - totalStaked;
        } 
        safeRewardTransfer(msg.sender,rewardSupply);
        rewardSupply = 0;
    }


    function lateWithdraw(uint256 amount) external {

        require(endBlock != 0, 'Mining should be stopped');
        require(endBlock < block.number, 'Mining should be stopped');
        UserData storage user = userData[msg.sender];
        require(user.amount >= amount, "Withdrawing amount is more than staked amount");
        if (amount > 0) {
            user.amount = user.amount - amount;
            liquidityMining.stakingToken.safeTransfer(address(msg.sender), amount);
        }
        totalStaked = totalStaked - amount;
        emit Withdraw(msg.sender, amount);
    }

}