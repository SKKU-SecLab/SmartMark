
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
pragma solidity 0.8.7;


contract KyokoVesting is
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public vestingToken;

    struct InitVestingInfo {
        address beneficiary;
        uint256 fullyVestedAmount;
        uint256 startDate; // 0 indicates start "now"
        uint256 cliffSec;
        uint256 durationSec;
        bool isRevocable;
    }

    struct VestingInfo {
        address beneficiary;
        uint256 fullyVestedAmount;
        uint256 withdrawnVestedAmount;
        uint256 startDate;
        uint256 cliffDate;
        uint256 durationSec;
        bool isRevocable; //true rep the token vesting rule can be revoked
        bool revocationStatus; //true rep the current status is revocation
        uint256 revokeDate; //the date of modify isRevocable to true
    }

    mapping(address => VestingInfo[]) vestingMapping;

    event GrantVestedTokens(
        address indexed beneficiary,
        uint256 fullyVestedAmount,
        uint256 startDate,
        uint256 cliffSec,
        uint256 durationSec,
        bool isRevocable
    );

    event ModifyVestedTokens(
        address indexed beneficiary,
        uint256 fullyVestedAmount,
        uint256 startDate,
        uint256 cliffSec,
        uint256 durationSec,
        bool isRevocable
    );

    event RemoveVestedTokens(
        address indexed beneficiary,
        uint256 index,
        uint256 fullyVestedAmount,
        uint256 withdrawnVestedAmount
    );

    event RevokeVesting(address indexed beneficiary, uint256 index);

    event RestoreReleaseState(address indexed beneficiary, uint256 index);

    event WithdrawPendingVestingTokens(
        uint256 indexed index,
        uint256 pendingVestedAmount,
        address indexed beneficiary,
        uint256 claimTimestamp
    );

    event Withdraw(address indexed recipient, uint256 amount);


    function initialize(address _token) public virtual initializer {

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        vestingToken = IERC20Upgradeable(_token);
    }

    function grantVestedTokens(
        address _beneficiary,
        uint256 _fullyVestedAmount,
        uint256 _startDate, // 0 indicates start "now"
        uint256 _cliffSec,
        uint256 _durationSec,
        bool _isRevocable
    ) public onlyOwner returns (bool) {

        require(
            _beneficiary != address(0x0),
            "the beneficiary must be not zero address"
        );
        require(
            _fullyVestedAmount > 0,
            "The amount of vesting tokens must be greater than 0"
        );
        require(
            _durationSec >= _cliffSec,
            "The total token release cycle must be greater than the cliff period"
        );

        if (_startDate == 0) {
            _startDate = block.timestamp;
        }

        uint256 _cliffDate = _startDate + _cliffSec;

        VestingInfo[] storage vestingArray = vestingMapping[_beneficiary];
        vestingArray.push(
            VestingInfo({
                beneficiary: _beneficiary,
                fullyVestedAmount: _fullyVestedAmount,
                withdrawnVestedAmount: 0,
                startDate: _startDate,
                cliffDate: _cliffDate,
                durationSec: _durationSec,
                isRevocable: _isRevocable,
                revocationStatus: false,
                revokeDate: 0
            })
        );


        emit GrantVestedTokens(
            _beneficiary,
            _fullyVestedAmount,
            _startDate,
            _cliffSec,
            _durationSec,
            _isRevocable
        );

        return true;
    }

    function grantListVestedTokens(InitVestingInfo[] calldata vestingInfoArray)
        public
        onlyOwner
    {

        for (uint8 i = 0; i < vestingInfoArray.length; i++) {
            InitVestingInfo memory vestingInfo = vestingInfoArray[i];
            grantVestedTokens(
                vestingInfo.beneficiary,
                vestingInfo.fullyVestedAmount,
                vestingInfo.startDate,
                vestingInfo.cliffSec,
                vestingInfo.durationSec,
                vestingInfo.isRevocable
            );
        }
    }

    function modifyVestedTokens(
        address _beneficiary,
        uint256 _index,
        uint256 _fullyVestedAmount,
        uint256 _startDate,
        uint256 _cliffSec,
        uint256 _durationSec,
        bool _isRevocable
    ) public onlyOwner {

        require(_beneficiary != address(0), "beneficiary is empty");
        require(_fullyVestedAmount > 0, "amount must greater than 0");
        require(_durationSec >= _cliffSec, "duration error");
        require(_startDate != 0, "the startDate must not be zero");

        uint256 _cliffDate = _startDate + _cliffSec;

        VestingInfo storage vestingInfo = vestingMapping[_beneficiary][_index];

        if (_fullyVestedAmount != vestingInfo.fullyVestedAmount) {
            if (_fullyVestedAmount > vestingInfo.fullyVestedAmount) {
                vestingToken.safeTransferFrom(
                    _msgSender(),
                    address(this),
                    _fullyVestedAmount - vestingInfo.fullyVestedAmount
                );
            } else {
                vestingToken.safeTransfer(
                    _msgSender(),
                    vestingInfo.fullyVestedAmount - _fullyVestedAmount
                );
            }
        }

        vestingInfo.fullyVestedAmount = _fullyVestedAmount;
        vestingInfo.startDate = _startDate;
        vestingInfo.cliffDate = _cliffDate;
        vestingInfo.durationSec = _durationSec;
        vestingInfo.isRevocable = _isRevocable;

        emit ModifyVestedTokens(
            _beneficiary,
            _fullyVestedAmount,
            _startDate,
            _cliffSec,
            _durationSec,
            _isRevocable
        );
    }

    function removeVestedTokens(address _beneficiary, uint256 _index)
        public
        onlyOwner
    {

        VestingInfo[] storage vestingArray = vestingMapping[_beneficiary];

        uint256 tempFullyVestedAmount = vestingArray[_index].fullyVestedAmount;
        uint256 tempWithdrawnVestedAmount = vestingArray[_index]
            .withdrawnVestedAmount;

        vestingArray[_index] = vestingArray[vestingArray.length - 1];
        vestingArray.pop();

        vestingToken.safeTransfer(
            _msgSender(),
            tempFullyVestedAmount - tempWithdrawnVestedAmount
        );

        emit RemoveVestedTokens(
            _beneficiary,
            _index,
            tempFullyVestedAmount,
            tempWithdrawnVestedAmount
        );
    }

    function revokeVesting(address _beneficiary, uint256 _index)
        public
        onlyOwner
        returns (bool)
    {

        VestingInfo storage vestingInfo = vestingMapping[_beneficiary][_index];
        require(vestingInfo.isRevocable, "this vesting can not revoke");
        require(!vestingInfo.revocationStatus, "this vesting already revoke");

        require(
            block.timestamp < vestingInfo.startDate + vestingInfo.durationSec,
            "the beneficiary's vesting have already complete release"
        );

        vestingInfo.revocationStatus = true;
        vestingInfo.revokeDate = block.timestamp;

        emit RevokeVesting(_beneficiary, _index);
        return true;
    }

    function restoreReleaseState(address _beneficiary, uint256 _index)
        public
        onlyOwner
        returns (bool)
    {

        VestingInfo storage vestingInfo = vestingMapping[_beneficiary][_index];
        require(vestingInfo.isRevocable, "this vesting can not revoke");
        require(
            vestingInfo.revocationStatus,
            "this vesting is normal release state"
        );

        require(
            block.timestamp < vestingInfo.startDate + vestingInfo.durationSec,
            "the beneficiary's vesting have already complete release"
        );

        vestingInfo.revocationStatus = false;
        vestingInfo.revokeDate = 0;

        emit RestoreReleaseState(_beneficiary, _index);
        return true;
    }

    function withdrawPendingVestingTokens(uint256 _index)
        public
        whenNotPaused
        nonReentrant
        returns (bool, uint256)
    {

        VestingInfo storage vestingInfo = vestingMapping[_msgSender()][_index];
        (, uint256 pendingVestedAmount) = _vestingSchedule(vestingInfo);

        require(pendingVestedAmount > 0, "the pending vested amount is zero.");

        vestingInfo.withdrawnVestedAmount += pendingVestedAmount;

        vestingToken.safeTransfer(_msgSender(), pendingVestedAmount);

        emit WithdrawPendingVestingTokens(
            _index,
            pendingVestedAmount,
            msg.sender,
            block.timestamp
        );

        return (true, pendingVestedAmount);
    }

    function queryTokenVestingInfo(address _beneficiary)
        public
        view
        returns (VestingInfo[] memory)
    {

        return vestingMapping[_beneficiary];
    }

    function queryTokenVestingsAmount(address _beneficiary)
        public
        view
        returns (uint256 allVestedAmount, uint256 pendingVestedAmount)
    {

        VestingInfo[] memory vestingArray = queryTokenVestingInfo(_beneficiary);
        if (vestingArray.length == 0) {
            return (0, 0);
        }
        for (uint256 i = 0; i < vestingArray.length; i++) {
            VestingInfo memory vestingInfo = vestingArray[i];
            (
                uint256 tempVestedAmount,
                uint256 tempPendingAmount
            ) = _vestingSchedule(vestingInfo);
            allVestedAmount += tempVestedAmount;
            pendingVestedAmount += tempPendingAmount;
        }
    }

    function queryTokenVestingAmount(address _beneficiary, uint256 _index)
        public
        view
        returns (uint256 allVestedAmount, uint256 pendingVestedAmount)
    {

        VestingInfo[] memory vestingArray = queryTokenVestingInfo(_beneficiary);
        if (vestingArray.length == 0 || _index >= vestingArray.length) {
            return (0, 0);
        }
        VestingInfo memory vestingInfo = vestingArray[_index];
        (allVestedAmount, pendingVestedAmount) = _vestingSchedule(vestingInfo);
    }

    function _vestingSchedule(VestingInfo memory vestingInfo)
        internal
        view
        returns (uint256 allVestedAmount, uint256 pendingVestedAmount)
    {

        uint256 _startDate = vestingInfo.startDate;
        uint256 _cliffDate = vestingInfo.cliffDate;
        uint256 _durationSec = vestingInfo.durationSec;
        uint256 _fullyVestedAmount = vestingInfo.fullyVestedAmount;
        uint256 _withdrawnVestedAmount = vestingInfo.withdrawnVestedAmount;

        uint256 _endDate = _startDate + _durationSec;
        uint256 _releaseTotalTime = _durationSec - (_cliffDate - _startDate);

        uint256 curentTime = getCurrentTime();

        bool _isRevocable = vestingInfo.isRevocable;
        bool _revocationStatus = vestingInfo.revocationStatus;
        uint256 _revokeDate = vestingInfo.revokeDate;
        uint256 disableAmount = 0;
        if (_isRevocable && _revocationStatus && _revokeDate != 0) {
            if (_revokeDate <= _startDate || _revokeDate < _cliffDate) {
                return (0, 0);
            } else {
                uint256 disableTime = (
                    curentTime > _endDate ? _endDate : curentTime
                ) - _revokeDate;
                disableAmount =
                    (disableTime * _fullyVestedAmount * 100) /
                    _releaseTotalTime /
                    100;
            }
        }

        if (curentTime <= _startDate || curentTime < _cliffDate) {
            return (0, 0);
        } else if (curentTime >= _endDate) {
            return (
                _fullyVestedAmount - disableAmount,
                _fullyVestedAmount - _withdrawnVestedAmount - disableAmount
            );
        } else {
            uint256 _releaseRemainTime = curentTime - _cliffDate;
            uint256 temp = (_releaseRemainTime * _fullyVestedAmount * 100) /
                _releaseTotalTime /
                100;

            return (
                temp - disableAmount,
                temp - _withdrawnVestedAmount - disableAmount
            );
        }
    }

    function getCurrentTime() public view virtual returns (uint256) {

        return block.timestamp;
    }

    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }

    function withdraw(uint256 amount) public onlyOwner {

        uint256 balance = vestingToken.balanceOf(address(this));
        require(balance >= amount, "amount is error");

        vestingToken.safeTransfer(_msgSender(), amount);
        emit Withdraw(_msgSender(), amount);
    }
}