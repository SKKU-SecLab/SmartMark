
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
}// UNLICENSED

pragma solidity =0.6.12;

interface IVirtualBalanceWrapperFactory {

    function createWrapper(address _op) external returns (address);

}

interface IVirtualBalanceWrapper {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function stakeFor(address _for, uint256 _amount) external returns (bool);

    function withdrawFor(address _for, uint256 amount) external returns (bool);

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
}// UNLICENSED

pragma solidity =0.6.12;

interface IBaseReward {

    function earned(address account) external view returns (uint256);

    function stake(address _for) external;

    function withdraw(address _for) external;

    function getReward(address _for) external;

    function notifyRewardAmount(uint256 reward) external;

    function addOwner(address _newOwner) external;

    function addOwners(address[] calldata _newOwners) external;

    function removeOwner(address _owner) external;

    function isOwner(address _owner) external view returns (bool);

}// UNLICENSED

pragma solidity =0.6.12;


contract BaseReward is ReentrancyGuard, IBaseReward {

    using Address for address payable;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public rewardToken;
    uint256 public constant duration = 7 days;

    mapping(address => bool) private owners;
    address public virtualBalance;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user);
    event Withdrawn(address indexed user);
    event RewardPaid(address indexed user, uint256 reward);
    event NewOwner(address indexed sender, address operator);
    event RemoveOwner(address indexed sender, address operator);

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyOwners() {

        require(isOwner(msg.sender), "BaseReward: caller is not an owner");
        _;
    }

    constructor(
        address _reward,
        address _virtualBalance,
        address _owner
    ) public {
        rewardToken = _reward;
        virtualBalance = _virtualBalance;
        owners[_owner] = true;
    }

    function totalSupply() public view returns (uint256) {

        return IVirtualBalanceWrapper(virtualBalance).totalSupply();
    }

    function balanceOf(address _for) public view returns (uint256) {

        return IVirtualBalanceWrapper(virtualBalance).balanceOf(_for);
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
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view override returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function addOwner(address _newOwner) public override onlyOwners {

        require(!isOwner(_newOwner), "BaseReward: address is already owner");

        owners[_newOwner] = true;

        emit NewOwner(msg.sender, _newOwner);
    }

    function addOwners(address[] calldata _newOwners) external override onlyOwners {

        for (uint256 i = 0; i < _newOwners.length; i++) {
            addOwner(_newOwners[i]);
        }
    }

    function removeOwner(address _owner) external override onlyOwners {

        require(isOwner(_owner), "BaseReward: address is not owner");

        owners[_owner] = false;

        emit RemoveOwner(msg.sender, _owner);
    }

    function isOwner(address _owner) public view override returns (bool) {

        return owners[_owner];
    }

    function stake(address _for) public override updateReward(_for) onlyOwners {

        emit Staked(_for);
    }

    function withdraw(address _for)
        public
        override
        updateReward(_for)
        onlyOwners
    {

        emit Withdrawn(_for);
    }

    function getReward(address _for)
        public
        override
        nonReentrant
        updateReward(_for)
    {

        uint256 reward = earned(_for);

        if (reward > 0) {
            rewards[_for] = 0;

            if (rewardToken != address(0)) {
                IERC20(rewardToken).safeTransfer(_for, reward);
            } else {
                require(
                    address(this).balance >= reward,
                    "BaseReward: !address(this).balance"
                );

                payable(_for).sendValue(reward);
            }

            emit RewardPaid(_for, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        override
        updateReward(address(0))
        onlyOwners
    {

        require(
            reward < uint256(-1) / 1e18,
            "the notified reward cannot invoke multiplication overflow"
        );

        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(duration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(duration);
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(duration);
        emit RewardAdded(reward);
    }

    receive() external payable {}
}// UNLICENSED

pragma solidity =0.6.12;


contract SupplyRewardFactory {

    event NewOwner(address indexed sender, address operator);
    event RemoveOwner(address indexed sender, address operator);
    event CreateReward(address pool, address rewardToken);

    mapping(address => bool) private owners;

    modifier onlyOwners() {

        require(
            isOwner(msg.sender),
            "SupplyRewardFactory: caller is not an owner"
        );
        _;
    }

    constructor() public {
        owners[msg.sender] = true;
    }

    function addOwner(address _newOwner) public onlyOwners {

        require(
            !isOwner(_newOwner),
            "SupplyRewardFactory: address is already owner"
        );

        owners[_newOwner] = true;

        emit NewOwner(msg.sender, _newOwner);
    }

    function addOwners(address[] calldata _newOwners) external onlyOwners {

        for (uint256 i = 0; i < _newOwners.length; i++) {
            addOwner(_newOwners[i]);
        }
    }

    function removeOwner(address _owner) external onlyOwners {

        require(isOwner(_owner), "SupplyRewardFactory: address is not owner");

        owners[_owner] = false;

        emit RemoveOwner(msg.sender, _owner);
    }

    function isOwner(address _owner) public view returns (bool) {

        return owners[_owner];
    }

    function createReward(
        address _rewardToken,
        address _virtualBalance,
        address _owner
    ) public onlyOwners returns (address) {

        BaseReward pool = new BaseReward(
            _rewardToken,
            _virtualBalance,
            _owner
        );

        emit CreateReward(address(pool), _rewardToken);

        return address(pool);
    }
}