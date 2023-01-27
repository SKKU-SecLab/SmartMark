
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
pragma solidity 0.7.6;


abstract contract Permissions {
    address public governance;
    address public pendingGovernance;
    address internal initializer;

    event GovernanceClaimed(address newGovernance, address previousGovernance);

    event TransferGovernancePending(address pendingGovernance);

    constructor(address _governance) {
        require(_governance != address(0), "ZERO_ADDRESS");
        initializer = msg.sender;
        governance = _governance;
    }

    modifier initialized() {
        require(initializer == address(0), "NOT_INITIALIZED");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "ONLY_GOVERNANCE");
        _;
    }

    function claimGovernance() public {
        require(pendingGovernance == msg.sender, "WRONG_GOVERNANCE");
        emit GovernanceClaimed(pendingGovernance, governance);
        governance = pendingGovernance;
        pendingGovernance = address(0);
    }

    function transferGovernance(address _governance) public onlyGovernance {
        require(_governance != address(0), "ZERO_ADDRESS");
        pendingGovernance = _governance;

        emit TransferGovernancePending(pendingGovernance);
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
pragma solidity 0.7.6;


abstract contract Withdrawable is Permissions {
    using SafeERC20 for IERC20;

    event EtherWithdraw(uint256 amount, address sendTo);
    event TokenWithdraw(IERC20 token, uint256 amount, address sendTo);

    function withdrawEther(uint256 amount, address payable sendTo) external onlyGovernance {
        (bool success, ) = sendTo.call{value: amount}("");
        require(success, "WITHDRAW_FAILED");
        emit EtherWithdraw(amount, sendTo);
    }

    function withdrawToken(
        IERC20 token,
        uint256 amount,
        address sendTo
    ) external onlyGovernance {
        token.safeTransfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }
}

pragma solidity 0.7.6;


interface IPENDLE is IERC20 {

    function initiateConfigChanges(
        uint256 _emissionRateMultiplierNumerator,
        uint256 _terminalInflationRateNumerator,
        address _liquidityIncentivesRecipient,
        bool _isBurningAllowed
    ) external;


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function burn(uint256 amount) external returns (bool);


    function applyConfigChanges() external;


    function claimLiquidityEmissions() external returns (uint256 totalEmissions);


    function isPendleToken() external view returns (bool);


    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256);


    function startTime() external view returns (uint256);


    function configChangesInitiated() external view returns (uint256);


    function emissionRateMultiplierNumerator() external view returns (uint256);


    function terminalInflationRateNumerator() external view returns (uint256);


    function liquidityIncentivesRecipient() external view returns (address);


    function isBurningAllowed() external view returns (bool);


    function pendingEmissionRateMultiplierNumerator() external view returns (uint256);


    function pendingTerminalInflationRateNumerator() external view returns (uint256);


    function pendingLiquidityIncentivesRecipient() external view returns (address);


    function pendingIsBurningAllowed() external view returns (bool);

}

pragma solidity 0.7.6;


interface IPendleTokenDistribution {

    event ClaimedTokens(
        address _claimer,
        uint256 _timeDuration,
        uint256 _claimableFunds,
        uint256 _amountClaimed
    );

    function pendleToken() external view returns (IPENDLE);

}
pragma solidity 0.7.6;


contract PendleTokenDistribution is Permissions, IPendleTokenDistribution {

    using SafeMath for uint256;

    IPENDLE public override pendleToken;

    uint256[] public timeDurations;
    uint256[] public claimableFunds;
    mapping(uint256 => bool) public claimed;
    uint256 public numberOfDurations;

    constructor(
        address _governance,
        uint256[] memory _timeDurations,
        uint256[] memory _claimableFunds
    ) Permissions(_governance) {
        require(_timeDurations.length == _claimableFunds.length, "MISMATCH_ARRAY_LENGTH");
        numberOfDurations = _timeDurations.length;
        for (uint256 i = 0; i < numberOfDurations; i++) {
            timeDurations.push(_timeDurations[i]);
            claimableFunds.push(_claimableFunds[i]);
        }
    }

    function initialize(IPENDLE _pendleToken) external {

        require(msg.sender == initializer, "FORBIDDEN");
        require(address(_pendleToken) != address(0), "ZERO_ADDRESS");
        require(_pendleToken.isPendleToken(), "INVALID_PENDLE_TOKEN");
        require(_pendleToken.balanceOf(address(this)) > 0, "UNDISTRIBUTED_PENDLE_TOKEN");
        pendleToken = _pendleToken;
        initializer = address(0);
    }

    function claimTokens(uint256 timeDurationIndex) public onlyGovernance {

        require(timeDurationIndex < numberOfDurations, "INVALID_INDEX");
        require(!claimed[timeDurationIndex], "ALREADY_CLAIMED");
        claimed[timeDurationIndex] = true;

        uint256 claimableTimestamp = pendleToken.startTime().add(timeDurations[timeDurationIndex]);
        require(block.timestamp >= claimableTimestamp, "NOT_CLAIMABLE_YET");
        uint256 currentPendleBalance = pendleToken.balanceOf(address(this));

        uint256 amount =
            claimableFunds[timeDurationIndex] < currentPendleBalance
                ? claimableFunds[timeDurationIndex]
                : currentPendleBalance;
        require(pendleToken.transfer(governance, amount), "FAIL_PENDLE_TRANSFER");
        emit ClaimedTokens(
            governance,
            timeDurations[timeDurationIndex],
            claimableFunds[timeDurationIndex],
            amount
        );
    }
}
