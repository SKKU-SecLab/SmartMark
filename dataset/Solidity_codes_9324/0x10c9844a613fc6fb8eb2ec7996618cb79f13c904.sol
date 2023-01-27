


pragma solidity ^0.8.0;

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



pragma solidity ^0.8.0;




pragma solidity ^0.8.0;

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


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.8.4;


contract PugStaking {

    using SafeERC20 for IERC20;
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping(address => UserInfo) public userStakingInfo;
    uint256 totalStaked;
    uint256 accRewardPerShare;
    mapping(address => address) baseTokens;

    address pugToken;
    address pugFactory;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardWithdrawn(address indexed user, uint256 amount);

    modifier onlyPugFactory {

        require(msg.sender == pugFactory, "Not pug factory");
        _;
    }

    constructor(address _pugToken, address _pugFactory) {
        pugToken = _pugToken;
        pugFactory = _pugFactory;
    }

    function addPug(address _baseToken, address _pug) public onlyPugFactory {

        baseTokens[_pug] = _baseToken;
    }

    function addRewards(uint256 _amount) public {

        require(baseTokens[msg.sender] != address(0), "Not a pug");
        if(totalStaked != 0) {
            accRewardPerShare += _amount * 1e12 / totalStaked;
        }
    }

    function deposit(uint256 _amount) external {

        UserInfo memory stakingInfo = userStakingInfo[msg.sender];
        uint256 _accRewardPerShare = accRewardPerShare;
        if(stakingInfo.amount != 0) {
            uint256 pendingReward = (_accRewardPerShare * stakingInfo.amount / 1e12) - stakingInfo.rewardDebt;
            transferRewards(msg.sender, pendingReward);
        }
        IERC20(pugToken).transferFrom(msg.sender, address(this), _amount);
        uint256 userDeposit = stakingInfo.amount + _amount;
        userStakingInfo[msg.sender] = UserInfo(userDeposit, userDeposit * _accRewardPerShare / 1e12);
        totalStaked += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {

        UserInfo memory stakingInfo = userStakingInfo[msg.sender];
        uint256 _accRewardPerShare = accRewardPerShare;
        uint256 pendingReward = (_accRewardPerShare * stakingInfo.amount / 1e12) - stakingInfo.rewardDebt;
        transferRewards(msg.sender, pendingReward);
        uint256 userDeposit = stakingInfo.amount - _amount;
        userStakingInfo[msg.sender] = UserInfo(userDeposit, userDeposit * _accRewardPerShare / 1e12);
        totalStaked -= _amount;
        IERC20(pugToken).transfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }

    function withdrawRewards(address _user) external {

        UserInfo memory stakingInfo = userStakingInfo[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        uint256 pendingReward = (_accRewardPerShare * stakingInfo.amount / 1e12) - stakingInfo.rewardDebt;
        userStakingInfo[_user].rewardDebt = stakingInfo.amount * _accRewardPerShare / 1e12;
        transferRewards(_user, pendingReward);
    }

    function transferRewards(address to, uint256 amount) internal {

        if(amount == 0) {
            return;
        }
        address _pugToken = pugToken;
        uint256 balance = IERC20(_pugToken).balanceOf(address(this));
        uint256 toTransfer;
        if(amount > balance) {
            toTransfer = balance;
        } else {
            toTransfer = amount;
        }
        IERC20(_pugToken).transfer(to, toTransfer);
        emit RewardWithdrawn(to, toTransfer);
    }
}