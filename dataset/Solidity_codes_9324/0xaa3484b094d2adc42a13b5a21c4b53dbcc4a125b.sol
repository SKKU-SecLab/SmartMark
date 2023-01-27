
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
}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT
pragma solidity ^0.8.7;
interface ITimeLockPool {

    function deposit(uint256 _amount, uint256 _duration, address _receiver) external;

}//MIT
pragma solidity ^0.8.7;


contract SipherIBCO is Ownable {

    using SafeERC20 for IERC20;

    event Claim(address indexed account, uint256 userShare, uint256 sipherAmount);
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event ClaimAndDepositToStake(address indexed account, uint256 amount, uint256 duration);

    
    uint256 public constant DECIMALS = 10 ** 18; // Sipher Token has the same decimals as Ether (18)
    uint256 public constant START = 1638752400; // Monday, December 6, 2021 1:00 AM UTC
    uint256 public constant END = START + 3 days; // Thursday, December 9, 2021 1:00 AM UTC
    uint256 public constant TOTAL_DISTRIBUTE_AMOUNT = 40000000 * DECIMALS;
    uint256 public constant MINIMAL_PROVIDE_AMOUNT = 3200 ether;
    uint256 public totalProvided = 0;
    ITimeLockPool public SipherStakingPool;

    mapping(address => uint256) public provided;
    mapping(address => uint256) private accumulated;

    IERC20 public immutable SIPHER;

    constructor(IERC20 sipher) {
        SIPHER = sipher;
    }

    function deposit() external payable {

        require(START <= block.timestamp, "The offering has not started yet");
        require(block.timestamp <= END, "The offering has already ended");
        require(SIPHER.balanceOf(address(this)) == TOTAL_DISTRIBUTE_AMOUNT, "Insufficient SIPHER token in contract");

        totalProvided += msg.value;
        provided[msg.sender] += msg.value;

        accumulated[msg.sender] = Math.max(accumulated[msg.sender], provided[msg.sender]);

        emit Deposit(msg.sender, msg.value);
    }

    function getUserDeposited(address _user) external view returns (uint256) {

        return provided[_user];
    }

    function claim() external {

        require(block.timestamp > END, "The offering has not ended");
        require(provided[msg.sender] > 0, "Empty balance");

        uint256 userShare = provided[msg.sender];
        uint256 sipherAmount = _getEstReceivedToken(msg.sender);
        provided[msg.sender] = 0;

        SIPHER.safeTransfer(msg.sender, sipherAmount);

        emit Claim(msg.sender, userShare, sipherAmount);
    }

    function _withdrawCap(uint256 userAccumulated) internal pure returns (uint256 withdrawableAmount) {

        if (userAccumulated <= 1 ether) {
            return userAccumulated;
        }

        if (userAccumulated <= 150 ether) {
            uint256 accumulatedTotalInETH = userAccumulated / DECIMALS;
            uint256 takeBackPercentage = (3 * accumulatedTotalInETH**2 + 70897 - 903 * accumulatedTotalInETH) / 1000;
            return (userAccumulated * takeBackPercentage) / 100;
        }

        return (userAccumulated * 3) / 100;
    }

    function _getWithdrawableAmount(address _user) internal view returns (uint256) {

        uint256 userAccumulated = accumulated[_user];
        return Math.min(_withdrawCap(userAccumulated), provided[_user] - _getLockedAmount(_user));
    }

    function getWithdrawableAmount(address _user) external view returns (uint256) {

        return _getWithdrawableAmount(_user);
    }

    function _getEstReceivedToken(address _user) internal view returns (uint256) {

        uint256 userShare = provided[_user];
        return (TOTAL_DISTRIBUTE_AMOUNT * userShare) / Math.max(totalProvided, MINIMAL_PROVIDE_AMOUNT);
    }

    function getLockAmountAfterDeposit(address _user, uint256 amount) external view returns (uint256) {

        uint256 userAccumulated = Math.max(provided[_user] + amount, accumulated[_user]);
        return userAccumulated - _withdrawCap(userAccumulated);
    }

    function getAccumulatedAfterDeposit(address _user, uint256 amount) external view returns (uint256) {

        return Math.max(provided[_user] + amount, accumulated[_user]);
    }

    function withdraw(uint256 amount) external {

        require(block.timestamp > START && block.timestamp < END, "Only withdrawable during the Offering duration");

        require(amount <= provided[msg.sender], "Insufficient balance");

        require(amount <= _getWithdrawableAmount(msg.sender), "Invalid amount");

        provided[msg.sender] -= amount;

        totalProvided -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    function getEstTokenPrice() public view returns (uint256) {

        return (Math.max(totalProvided, MINIMAL_PROVIDE_AMOUNT) * DECIMALS) / TOTAL_DISTRIBUTE_AMOUNT;
    }

    function getEstReceivedToken(address _user) external view returns (uint256) {

        return _getEstReceivedToken(_user);
    }

    function getLockedAmount(address _user) external view returns (uint256) {

        return _getLockedAmount(_user);
    }

    function _getLockedAmount(address _user) internal view returns (uint256) {

        uint256 userAccumulated = accumulated[_user];
        return userAccumulated - _withdrawCap(userAccumulated);
    }

    function withdrawSaleFunds() external onlyOwner {

        require(END < block.timestamp, "The offering has not ended");
        require(address(this).balance > 0, "Contract's balance is empty");

        payable(owner()).transfer(address(this).balance);
    }

    function withdrawRemainedSIPHER() external onlyOwner {

        require(END < block.timestamp, "The offering has not ended");
        require(totalProvided < MINIMAL_PROVIDE_AMOUNT, "Total provided must be less than minimal provided");

        uint256 remainedSipher = TOTAL_DISTRIBUTE_AMOUNT -
            ((TOTAL_DISTRIBUTE_AMOUNT * totalProvided) / MINIMAL_PROVIDE_AMOUNT);
        SIPHER.safeTransfer(owner(), remainedSipher);
    }

    function withdrawUnclaimedSIPHER() external onlyOwner {

        require(END + 30 days < block.timestamp, "Withdrawal is unavailable");
        require(SIPHER.balanceOf(address(this)) != 0, "No token to withdraw");

        SIPHER.safeTransfer(owner(), SIPHER.balanceOf(address(this)));
    }

    function setApproveForStaking(address _sipherStakingPool) external onlyOwner {

        require(block.timestamp < END, "Only allow edit before the Offer ends");
        require(_sipherStakingPool != address(0), "Invalid address");

        SipherStakingPool = ITimeLockPool(_sipherStakingPool);
        SIPHER.safeApprove(_sipherStakingPool, type(uint256).max);
    }

    function claimAndDepositForStaking(uint256 amount, uint256 duration) external {

        require(block.timestamp > END, "The offering has not ended");
        require(duration >= 600, "Minimum duration is 10 minutes");
        require(amount <= _getEstReceivedToken(msg.sender) && amount > 0, "Invalid amount");

        provided[msg.sender] -= (amount * getEstTokenPrice()) / DECIMALS;

        SipherStakingPool.deposit(amount, duration, msg.sender);

        emit ClaimAndDepositToStake(msg.sender, amount, duration);
    }
}