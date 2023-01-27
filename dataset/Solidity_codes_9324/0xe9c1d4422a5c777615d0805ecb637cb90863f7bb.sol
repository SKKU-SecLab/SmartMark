



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



pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;






contract RewardVesting {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public reward;

    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }
    mapping(address => LockedBalance[]) private _userEarnings;
    uint256 public duration = 86400;

    struct Balances {
        uint256 earned;
    }

    mapping(address => Balances) public userBalances;

    uint256 public accumulatedPenalty = 0;

    address public governance;

    address public pendingGovernance;

    address public rewardSource;

    event EarningAdd(address indexed user, uint256 amount);
    event EarningWithdraw(address indexed user, uint256 amount, uint256 penaltyAmount);

    event PendingGovernanceUpdated(
      address pendingGovernance
    );

    event GovernanceUpdated(
      address governance
    );


    constructor(address _governance) public {
      require(_governance != address(0), "RewardVesting: governance address cannot be 0x0");
      governance = _governance;
    }

    function initialize(IERC20 _reward, address _rewardSource) external onlyGovernance {

        require(reward == IERC20(0), "Already initialized");
        require(_rewardSource != address(0), "Zero address");
        reward = _reward;
        rewardSource = _rewardSource;
    }

    modifier onlyGovernance() {

      require(msg.sender == governance, "RewardVesting: only governance");
      _;
    }

    function setPendingGovernance(address _pendingGovernance) external onlyGovernance {

      require(_pendingGovernance != address(0), "RewardVesting: pending governance address cannot be 0x0");
      pendingGovernance = _pendingGovernance;

      emit PendingGovernanceUpdated(_pendingGovernance);
    }

    function acceptGovernance() external {

      require(msg.sender == pendingGovernance, "RewardVesting: only pending governance");

      address _pendingGovernance = pendingGovernance;
      governance = _pendingGovernance;

      emit GovernanceUpdated(_pendingGovernance);
    }


    function transferPenalty(address transferTo) external onlyGovernance {

        reward.safeTransfer(transferTo, accumulatedPenalty);
        accumulatedPenalty = 0;
    }

    function addEarning(address user, uint256 amount, uint256 durationInSecs) external {

        require(msg.sender == rewardSource, "Not from reward source");
        _addPendingEarning(user, amount, durationInSecs);
        reward.safeTransferFrom(msg.sender, address(this), amount);
    }

    function _addPendingEarning(address user, uint256 amount, uint256 durationInSecs) internal {

        Balances storage bal = userBalances[user];
        bal.earned = bal.earned.add(amount);

        uint256 unlockTime = block.timestamp.div(duration).mul(duration).add(durationInSecs);
        LockedBalance[] storage earnings = _userEarnings[user];
        uint256 idx = earnings.length;

        if (idx == 0 || earnings[idx-1].unlockTime < unlockTime) {
            earnings.push(LockedBalance({amount: amount, unlockTime: unlockTime}));
        } else {
            earnings[idx-1].amount = earnings[idx-1].amount.add(amount);
        }
        emit EarningAdd(user, amount);
    }

    function withdrawEarning(uint256 amount) public {

        require(amount > 0, "Cannot withdraw 0");
        Balances storage bal = userBalances[msg.sender];
        uint256 penaltyAmount = 0;

        uint256 remaining = amount;
        bal.earned = bal.earned.sub(remaining);
        for (uint i = 0; ; i++) {
            uint256 earnedAmount = _userEarnings[msg.sender][i].amount;
            if (earnedAmount == 0) {
                continue;
            }
            if (penaltyAmount == 0 && _userEarnings[msg.sender][i].unlockTime > block.timestamp) {
                penaltyAmount = remaining;
                require(bal.earned >= remaining, "Insufficient balance after penalty");
                bal.earned = bal.earned.sub(remaining);
                if (bal.earned == 0) {
                    delete _userEarnings[msg.sender];
                    break;
                }
                remaining = remaining.mul(2);
            }
            if (remaining <= earnedAmount) {
                _userEarnings[msg.sender][i].amount = earnedAmount.sub(remaining);
                break;
            } else {
                delete _userEarnings[msg.sender][i];
                remaining = remaining.sub(earnedAmount);
            }
        }


        reward.safeTransfer(msg.sender, amount);

        accumulatedPenalty = accumulatedPenalty + penaltyAmount;

        emit EarningWithdraw(msg.sender, amount, penaltyAmount);
    }

    function withdrawableEarning(
        address user
    )
        public
        view
        returns (uint256 amount, uint256 penaltyAmount, uint256 amountWithoutPenalty)
    {

        Balances storage bal = userBalances[user];

        if (bal.earned > 0) {
            uint256 length = _userEarnings[user].length;
            for (uint i = 0; i < length; i++) {
                uint256 earnedAmount = _userEarnings[user][i].amount;
                if (earnedAmount == 0) {
                    continue;
                }
                if (_userEarnings[user][i].unlockTime > block.timestamp) {
                    break;
                }
                amountWithoutPenalty = amountWithoutPenalty.add(earnedAmount);
            }
            
            if (bal.earned.sub(amountWithoutPenalty) % 2 == 0) {
                penaltyAmount = bal.earned.sub(amountWithoutPenalty).div(2);
            } else {
                penaltyAmount = bal.earned.sub(amountWithoutPenalty).div(2) + 1;
            }
        }
        amount = bal.earned.sub(penaltyAmount);

        return (amount, penaltyAmount, amountWithoutPenalty);
    }

    function earnedBalances(
        address user
    )
        public
        view
        returns (uint total, uint[2][] memory earningsData)
    {

        LockedBalance[] storage earnings = _userEarnings[user];
        uint idx;
        for (uint i = 0; i < earnings.length; i++) {
            if (earnings[i].unlockTime > block.timestamp) {
                if (idx == 0) {
                    earningsData = new uint[2][](earnings.length - i);
                }
                earningsData[idx][0] = earnings[i].amount;
                earningsData[idx][1] = earnings[i].unlockTime;
                idx++;
                total = total.add(earnings[i].amount);
            }
        }
        return (total, earningsData);
    }
}