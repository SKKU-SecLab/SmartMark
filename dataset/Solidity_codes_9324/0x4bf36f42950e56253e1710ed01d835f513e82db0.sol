
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// agpl-3.0
pragma solidity 0.8.4;

interface ILockupV2 {

    struct LockParam {
        address beneficiary;
        uint256 percentage;
    }

    struct Locked {
        uint256 amount;
        uint256 slope;
    }

    event Lock(
        address indexed provider,
        address indexed beneficiary,
        uint256 value,
        uint256 ts
    );

    event BeneficiaryTransferred(
        address indexed previousBeneficiary,
        address indexed newBeneficiary,
        uint256 ts
    );

    event Withdrawn(address indexed beneficiary, uint256 value, uint256 ts);

    function lockEndTime() external view returns (uint256);


    function transferBeneficiary(
        address _oldBeneficiary,
        address _newBeneficiary
    ) external;


    function createLock(LockParam[] memory _beneficiaries, uint256 _totalAmount)
        external;


    function withdrawable(address _beneficiary) external view returns (uint256);


    function withdraw() external;


    function lockedAmount(address _beneficiary) external view returns (uint256);


    function createVeLock(uint256 _lockedBendAmount, uint256 _unlockTime)
        external;


    function increaseVeAmount(uint256 _lockedBendAmount) external;


    function increaseVeUnlockTime(uint256 _unlockTime) external;


    function withdrawVeLock() external;


    function delegateVote(bytes32 _snapshotId, address _delegatee) external;


    function clearDelegateVote(bytes32 _snapshotId) external;


    function refundVeRewards() external;

}// MIT
pragma solidity 0.8.4;

interface ISnapshotDelegation {

    function clearDelegate(bytes32 _id) external;


    function setDelegate(bytes32 _id, address _delegate) external;


    function delegation(address _address, bytes32 _id)
        external
        view
        returns (address);

}// agpl-3.0
pragma solidity 0.8.4;

interface IVeBend {

    struct Point {
        int256 bias;
        int256 slope;
        uint256 ts;
        uint256 blk;
    }

    struct LockedBalance {
        int256 amount;
        uint256 end;
    }

    event Deposit(
        address indexed provider,
        address indexed beneficiary,
        uint256 value,
        uint256 indexed locktime,
        uint256 _type,
        uint256 ts
    );
    event Withdraw(address indexed provider, uint256 value, uint256 ts);

    event Supply(uint256 prevSupply, uint256 supply);

    function createLock(uint256 _value, uint256 _unlockTime) external;


    function createLockFor(
        address _beneficiary,
        uint256 _value,
        uint256 _unlockTime
    ) external;


    function increaseAmount(uint256 _value) external;


    function increaseAmountFor(address _beneficiary, uint256 _value) external;


    function increaseUnlockTime(uint256 _unlockTime) external;


    function checkpointSupply() external;


    function withdraw() external;


    function getLocked(address _addr) external returns (LockedBalance memory);


    function getUserPointEpoch(address _userAddress)
        external
        view
        returns (uint256);


    function epoch() external view returns (uint256);


    function getUserPointHistory(address _userAddress, uint256 _index)
        external
        view
        returns (Point memory);


    function getSupplyPointHistory(uint256 _index)
        external
        view
        returns (Point memory);

}// agpl-3.0
pragma solidity 0.8.4;

interface ILendPoolAddressesProvider {

    function getLendPool() external view returns (address);

}// agpl-3.0
pragma solidity 0.8.4;

interface IFeeDistributor {

    event Distributed(uint256 time, uint256 tokenAmount);

    event Claimed(
        address indexed recipient,
        uint256 amount,
        uint256 claimEpoch,
        uint256 maxEpoch
    );

    function lastDistributeTime() external view returns (uint256);


    function distribute() external;


    function claim(bool weth) external returns (uint256);


    function claimable(address _addr) external view returns (uint256);


    function addressesProvider()
        external
        view
        returns (ILendPoolAddressesProvider);


    function bendCollector() external view returns (address);

}// agpl-3.0
pragma solidity 0.8.4;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;


    function approve(address, uint256) external returns (bool);


    function transfer(address, uint256) external returns (bool);


    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);


    function balanceOf(address) external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;

interface ILockup {

    struct LockParam {
        address beneficiary;
        uint256 thousandths;
    }

    struct Locked {
        uint256 amount;
        uint256 slope;
    }

    event Lock(
        address indexed provider,
        address indexed beneficiary,
        uint256 value,
        uint256 ts
    );

    event BeneficiaryTransferred(
        address indexed previousBeneficiary,
        address indexed newBeneficiary,
        uint256 ts
    );

    event Withdrawn(address indexed beneficiary, uint256 value, uint256 ts);

    function lockEndTime() external view returns (uint256);


    function delegateSnapshotVotePower(
        address delegation,
        bytes32 _id,
        address _delegate
    ) external;


    function clearDelegateSnapshotVotePower(address delegation, bytes32 _id)
        external;


    function transferBeneficiary(
        address _oldBeneficiary,
        address _newBeneficiary
    ) external;


    function createLock(
        LockParam[] memory _beneficiaries,
        uint256 _totalAmount,
        uint256 _unlockStartTime
    ) external;


    function withdrawable(address _beneficiary) external view returns (uint256);


    function withdraw(address _beneficiary) external;


    function lockedAmount(address _beneficiary) external view returns (uint256);


    function claim() external;


    function emergencyWithdraw() external;

}// agpl-3.0
pragma solidity 0.8.4;

contract LockupBendV1Storage {

    IERC20Upgradeable public bendToken;
    IVeBend public veBend;
    IFeeDistributor public feeDistributor;

    ILockup[3] internal lockups; // deprecated
    mapping(address => uint256) internal feeIndexs; // deprecated
    mapping(address => uint256) internal locked; // deprecated

    mapping(address => bool) public authedBeneficiaries;

    uint256 internal feeIndex; // deprecated
    uint256 internal feeIndexlastUpdateTimestamp; // deprecated
    uint256 internal totalLocked; // deprecated

    IWETH public WETH;
    ISnapshotDelegation public snapshotDelegation;
}// agpl-3.0
pragma solidity 0.8.4;


library PercentageMath {

    uint256 constant PERCENTAGE_FACTOR = 1e4; //percentage plus two decimals
    uint256 constant HALF_PERCENT = PERCENTAGE_FACTOR / 2;
    uint256 constant ONE_PERCENT = 1e2; //100, 1%
    uint256 constant TEN_PERCENT = 1e3; //1000, 10%
    uint256 constant ONE_THOUSANDTH_PERCENT = 1e1; //10, 0.1%
    uint256 constant ONE_TEN_THOUSANDTH_PERCENT = 1; //1, 0.01%

    function percentMul(uint256 value, uint256 percentage)
        internal
        pure
        returns (uint256)
    {

        if (value == 0 || percentage == 0) {
            return 0;
        }

        require(
            value <= (type(uint256).max - HALF_PERCENT) / percentage,
            "Math multiplication overflow"
        );

        return (value * percentage + HALF_PERCENT) / PERCENTAGE_FACTOR;
    }

    function percentDiv(uint256 value, uint256 percentage)
        internal
        pure
        returns (uint256)
    {

        require(percentage != 0, "Math division by zero");
        uint256 halfPercentage = percentage / 2;

        require(
            value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR,
            "Math multiplication overflow"
        );

        return (value * PERCENTAGE_FACTOR + halfPercentage) / percentage;
    }
}// agpl-3.0
pragma solidity 0.8.4;

interface ILendPool {

    function withdraw(
        address reserve,
        uint256 amount,
        address to
    ) external returns (uint256);


    function deposit(
        address reserve,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

}// agpl-3.0
pragma solidity 0.8.4;


contract LockupBendV2 is
    ILockupV2,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    LockupBendV1Storage
{

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using PercentageMath for uint256;

    uint256 public constant ONE_YEAR_SECONDS = 365 * 86400; // 1 years
    uint8 public constant PRECISION = 10;

    uint256 public unlockStartTime;
    uint256 public override lockEndTime;
    mapping(address => Locked) public locks;

    modifier onlyAuthed() {

        require(authedBeneficiaries[_msgSender()], "Sender not authed");
        _;
    }

    function initialize(
        address _wethAddr,
        address _bendTokenAddr,
        address _veBendAddr,
        address _feeDistributorAddr,
        address _snapshotDelegationAddr
    ) external initializer {

        __Ownable_init();
        __ReentrancyGuard_init();
        WETH = IWETH(_wethAddr);
        snapshotDelegation = ISnapshotDelegation(_snapshotDelegationAddr);
        bendToken = IERC20Upgradeable(_bendTokenAddr);
        veBend = IVeBend(_veBendAddr);
        feeDistributor = IFeeDistributor(_feeDistributorAddr);
    }

    function approve() external onlyOwner {

        bendToken.safeApprove(address(veBend), type(uint256).max);
        require(
            WETH.approve(
                feeDistributor.addressesProvider().getLendPool(),
                type(uint256).max
            ),
            "Approve WETH failed"
        );
    }

    function transferBeneficiary(
        address _oldBeneficiary,
        address _newBeneficiary
    ) external override onlyOwner {

        require(
            _oldBeneficiary != _newBeneficiary,
            "Beneficiary can't be same"
        );
        require(
            _newBeneficiary != address(0),
            "New beneficiary can't be zero address"
        );
        require(
            authedBeneficiaries[_oldBeneficiary],
            "Old beneficiary not authed"
        );

        authedBeneficiaries[_oldBeneficiary] = false;
        authedBeneficiaries[_newBeneficiary] = true;

        if (locks[_oldBeneficiary].amount > 0) {
            _withdraw(_oldBeneficiary);
            Locked memory _oldLocked = locks[_oldBeneficiary];

            Locked memory _newLocked = locks[_newBeneficiary];

            _newLocked.amount += _oldLocked.amount;
            _newLocked.slope += _oldLocked.slope;

            locks[_newBeneficiary] = _newLocked;

            _oldLocked.amount = 0;
            _oldLocked.slope = 0;

            locks[_oldBeneficiary] = _oldLocked;

            emit BeneficiaryTransferred(
                _oldBeneficiary,
                _newBeneficiary,
                block.timestamp
            );
        }
    }

    function createLock(LockParam[] memory _beneficiaries, uint256 _totalAmount)
        external
        override
        onlyOwner
    {

        require(
            unlockStartTime == 0 && lockEndTime == 0,
            "Can't create lock twice"
        );
        require(
            bendToken.balanceOf(address(this)) >= _totalAmount,
            "Bend Insufficient"
        );
        uint256 _now = block.timestamp;
        uint256 _firstDelayTime = ONE_YEAR_SECONDS;
        uint256 _unlockTime = 3 * ONE_YEAR_SECONDS;
        unlockStartTime = _now + _firstDelayTime;
        lockEndTime = unlockStartTime + _unlockTime;
        uint256 checkPercentage = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            LockParam memory _lp = _beneficiaries[i];
            require(
                _lp.percentage <= PercentageMath.PERCENTAGE_FACTOR,
                "percentage should be less than 10000"
            );
            checkPercentage += _lp.percentage;
            uint256 _lockAmount = _totalAmount.percentMul(_lp.percentage);
            _createLock(_lp.beneficiary, _lockAmount, _unlockTime);
            authedBeneficiaries[_lp.beneficiary] = true;
        }

        require(
            checkPercentage == PercentageMath.PERCENTAGE_FACTOR,
            "The sum of percentage should be 10000"
        );
    }

    function _createLock(
        address _beneficiary,
        uint256 _value,
        uint256 _unlockTime
    ) internal {

        Locked memory _locked = locks[_beneficiary];

        require(_value > 0, "Need non-zero lock value");
        require(_locked.amount == 0, "Can't lock twice");

        _locked.amount = _value;
        _locked.slope = (_locked.amount * 10**PRECISION) / _unlockTime;
        locks[_beneficiary] = _locked;

        emit Lock(msg.sender, _beneficiary, _value, block.timestamp);
    }

    function lockedAmount(address _beneficiary)
        external
        view
        override
        returns (uint256)
    {

        return _lockedAmount(_beneficiary);
    }

    function _lockedAmount(address _beneficiary)
        internal
        view
        returns (uint256)
    {

        Locked memory _locked = locks[_beneficiary];
        if (block.timestamp <= unlockStartTime) {
            return _locked.amount;
        }
        if (block.timestamp >= lockEndTime) {
            return 0;
        }
        return
            (_locked.slope * (lockEndTime - block.timestamp)) / 10**PRECISION;
    }

    function withdrawable(address _beneficiary)
        external
        view
        override
        returns (uint256)
    {

        return locks[_beneficiary].amount - _lockedAmount(_beneficiary);
    }

    function withdraw() external override onlyAuthed {

        _withdraw(msg.sender);
    }

    function _withdraw(address _beneficiary) internal nonReentrant {

        uint256 _value = locks[_beneficiary].amount -
            _lockedAmount(_beneficiary);

        if (_value > 0) {
            locks[_beneficiary].amount -= _value;
            bendToken.safeTransfer(_beneficiary, _value);

            emit Withdrawn(_beneficiary, _value, block.timestamp);
        }
    }

    function withdrawVeLock() external override onlyOwner {

        veBend.withdraw();
    }

    function createVeLock(uint256 _lockedBendAmount, uint256 _unlockTime)
        external
        override
        onlyOwner
    {

        veBend.createLock(_lockedBendAmount, _unlockTime);
    }

    function increaseVeAmount(uint256 _lockedBendAmount)
        external
        override
        onlyOwner
    {

        veBend.increaseAmount(_lockedBendAmount);
    }

    function increaseVeUnlockTime(uint256 _unlockTime)
        external
        override
        onlyOwner
    {

        veBend.increaseUnlockTime(_unlockTime);
    }

    function delegateVote(bytes32 _snapshotId, address _delegatee)
        external
        override
        onlyOwner
    {

        snapshotDelegation.setDelegate(_snapshotId, _delegatee);
    }

    function clearDelegateVote(bytes32 _snapshotId)
        external
        override
        onlyOwner
    {

        snapshotDelegation.clearDelegate(_snapshotId);
    }

    function refundVeRewards() external override nonReentrant {

        uint256 balanceBefore = WETH.balanceOf(address(this));
        feeDistributor.claim(true);
        uint256 balanceDelta = WETH.balanceOf(address(this)) - balanceBefore;
        if (balanceDelta > 0) {
            ILendPool(feeDistributor.addressesProvider().getLendPool()).deposit(
                    address(WETH),
                    balanceDelta,
                    feeDistributor.bendCollector(),
                    0
                );
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

library AddressUpgradeable {

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
}