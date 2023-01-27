
pragma solidity 0.8.0;
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
contract TokenTimelock {

    using SafeERC20 for IERC20;

    IERC20 immutable private _token;

    address immutable private _beneficiary;

    uint256 immutable private _releaseTime;

    constructor (IERC20 token_, address beneficiary_, uint256 releaseTime_) {
        require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
    }

    function token() public view virtual returns (IERC20) {

        return _token;
    }

    function beneficiary() public view virtual returns (address) {

        return _beneficiary;
    }

    function releaseTime() public view virtual returns (uint256) {

        return _releaseTime;
    }

    function release() public virtual {

        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        token().safeTransfer(beneficiary(), amount);
    }
}
contract ArtemisTimeLock is TokenTimelock {

    using SafeERC20 for IERC20;

    uint256 immutable internal maxTranches;

    uint256 immutable internal trancheWeeks;

    uint256 immutable internal tranchePercent;

    uint256 immutable internal startTime;

    uint256 internal tranchesReleased;

    uint256 internal disperseAmount;

    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 releaseTime_,
        uint256 _startTime,
        uint256 _trancheWeeks,
        uint256 _maxTranches,
        uint256 _tranchePercent
    )
    TokenTimelock(
        token_,
        beneficiary_,
        releaseTime_
    )
    {
        require(beneficiary_ != address(0), "ArtemisTimeLockFactory: beneficiary has zero address");

        require(_maxTranches * _tranchePercent == 10000, "TokenTimeLock: percents and tranches do not = 100%");

        trancheWeeks = _trancheWeeks;
        maxTranches = _maxTranches;
        tranchePercent = _tranchePercent;
        startTime = _startTime;
    }

    function release() public override {

        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 _remaining_balance = token().balanceOf(address(this));

        require(_remaining_balance > 0, "TokenTimelock: no tokens to release");

        if (disperseAmount == 0) {

            disperseAmount = uint256(token().balanceOf(address(this))) * tranchePercent / 10000;
        }

        uint256 currentTranche = uint256(block.timestamp - startTime) / (trancheWeeks * 1 weeks);

        if (currentTranche >= maxTranches) {

            tranchesReleased++;

            token().safeTransfer(beneficiary(), token().balanceOf(address(this)));

        } else if (currentTranche > tranchesReleased) {

            tranchesReleased++;

            token().safeTransfer(beneficiary(), disperseAmount);
        } else {

            revert("TokenTimelock: tranche unavailable, release requested too early.");
        }
    }
}
contract ArtemisTimeLockFactory {

    mapping(uint256 => address) public timeLocks;

    function createTimeLock(
        uint256 _timeLockId,
        IERC20 token_,
        address beneficiary_,
        uint256 releaseTime_,
        uint256 _startTime,
        uint256 _trancheWeeks,
        uint256 _maxTranches,
        uint256 _tranchePercent
    ) external {

        require(timeLocks[_timeLockId] == address(0), "ArtemisTimeLockFactory: timeLock ID already in use.");

        ArtemisTimeLock timeLock = new ArtemisTimeLock(
            token_,
            beneficiary_,
            releaseTime_,
            _startTime,
            _trancheWeeks,
            _maxTranches,
            _tranchePercent
        );

        timeLocks[_timeLockId] = address(timeLock);
    }
}