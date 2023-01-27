
pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
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


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) public payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal view virtual override returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal virtual {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address admin_, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);
    }

    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _admin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external virtual ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable virtual ifAdmin {

        _upgradeTo(newImplementation);
        Address.functionDelegateCall(newImplementation, data);
    }

    function _admin() internal view virtual returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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

interface IERC20Upgradeable {

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

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT
pragma solidity 0.7.6;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init(address _ownerAddress) internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained(_ownerAddress);
    }

    function __Ownable_init_unchained(address _ownerAddress) internal initializer {
        _owner = _ownerAddress;
        emit OwnershipTransferred(address(0), _ownerAddress);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function safeTransferOwnership(address newOwner, bool safely) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        if (safely) {
            _pendingOwner = newOwner;
        } else {
            emit OwnershipTransferred(_owner, newOwner);
            _owner = newOwner;
            _pendingOwner = address(0);
        }
    }

    function safeAcceptOwnership() public virtual {
        require(_msgSender() == _pendingOwner, "acceptOwnership: Call must come from pendingOwner.");
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
    }

    uint256[48] private __gap;
}// GPL-3.0-or-later
pragma solidity 0.7.6;



contract ZoneStakingUpgradeable is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    struct Type {
        bool enabled;
        uint16 lockDay;
        uint256 rewardRate;
        uint256 stakedAmount;
    }

    struct Stake {
        bool exist;
        uint8 typeIndex;
        uint256 stakedTs;   // timestamp when staked
        uint256 unstakedTs; // timestamp when unstaked
        uint256 stakedAmount;   // token amount user staked
        uint256 rewardAmount;   // reward amount when user unstaked
    }

    uint256 private constant DENOMINATOR = 10000;

    Type[] public types;
    mapping(address => Stake) public stakes;
    uint256 public totalStakedAmount;
    uint256 public totalUnstakedAmount;

    uint256 public stakeLimit;
    uint256 public minStakeAmount;
    bool public earlyUnstakeAllowed;

    IERC20Upgradeable public zoneToken;

    address public governorTimelock;

    uint256 public totalUnstakedAmountWithReward;

    address private constant user1 = 0x83b4271b054818a93325c7299f006AEc2E90ef96;
    uint256 public user1LastUnlockTs;
    uint256 public user1ZonePerSec;

    event AddType(bool enable, uint16 lockDay, uint256 rewardRate);
    event ChangeType(uint8 typeIndex, bool enable, uint16 lockDay, uint256 rewardRate);
    event SetStakeLimit(uint256 newStakeLimit);
    event SetMinStakeAmount(uint256 newMinStakeAmount);
    event SetEarlyUnstakeAllowed(bool newAllowed);
    event SetVault(address indexed newVault);
    event Staked(address indexed staker, uint256 amount, uint8 typeIndex);
    event Unstaked(address indexed staker, uint256 stakedAmount, uint256 reward);

    modifier onlyOwnerOrCommunity() {

        address sender = _msgSender();
        require((owner() == sender) || (governorTimelock == sender), "The caller should be owner or governor");
        _;
    }

    function initialize(
        address _ownerAddress,
        address _zoneToken,
        address _governorTimelock,
        bool[] memory _typeEnables,
        uint16[] memory _lockDays,
        uint256[] memory _rewardRates
    ) public initializer {

        require(_ownerAddress != address(0), "Owner address is invalid");

        stakeLimit = 2500000e18; // 2.5M ZONE
        minStakeAmount = 1e18; // 1 ZONE
        earlyUnstakeAllowed = true;

        __Ownable_init(_ownerAddress);
        __ReentrancyGuard_init();
        zoneToken = IERC20Upgradeable(_zoneToken);
        governorTimelock = _governorTimelock;

        _addTypes(_typeEnables, _lockDays, _rewardRates);
    }

    function setGovernorTimelock(address _governorTimelock) external onlyOwner()  {

        governorTimelock = _governorTimelock;
    }

    function getAllTypes() public view returns(bool[] memory enables, uint16[] memory lockDays, uint256[] memory rewardRates) {

        enables = new bool[](types.length);
        lockDays = new uint16[](types.length);
        rewardRates = new uint256[](types.length);

        for (uint i = 0; i < types.length; i ++) {
            enables[i] = types[i].enabled;
            lockDays[i] = types[i].lockDay;
            rewardRates[i] = types[i].rewardRate;
        }
    }

    function addTypes(
        bool[] memory _enables,
        uint16[] memory _lockDays,
        uint256[] memory _rewardRates
    ) external onlyOwner() {

        _addTypes(_enables, _lockDays, _rewardRates);
    }

    function _addTypes(
        bool[] memory _enables,
        uint16[] memory _lockDays,
        uint256[] memory _rewardRates
    ) internal {

        require(
            _lockDays.length == _rewardRates.length
            && _lockDays.length == _enables.length,
            "Mismatched data"
        );
        require((types.length + _lockDays.length) <= type(uint8).max, "Too much");

        for (uint256 i = 0; i < _lockDays.length; i ++) {
            require(_rewardRates[i] < DENOMINATOR/2, "Too large rewardRate");
            Type memory _type = Type({
                enabled: _enables[i],
                lockDay: _lockDays[i],
                rewardRate: _rewardRates[i],
                stakedAmount: 0
            });
            types.push(_type);
            emit AddType (_type.enabled, _type.lockDay, _type.rewardRate);
        }
    }

    function changeType(
        uint8 _typeIndex,
        bool _enable,
        uint16 _lockDay,
        uint256 _rewardRate
    ) external onlyOwnerOrCommunity() {

        require(_typeIndex < types.length, "Invalid typeIndex");
        require(_rewardRate < DENOMINATOR/2, "Too large rewardRate");

        Type storage _type = types[_typeIndex];
        _type.enabled = _enable;
        _type.lockDay = _lockDay;
        _type.rewardRate = _rewardRate;
        emit ChangeType (_typeIndex, _type.enabled, _type.lockDay, _type.rewardRate);
    }

    function leftCapacity() public view returns(uint256) {

        uint256 spent = totalUnstakedAmountWithReward.add(totalStakedAmount).sub(totalUnstakedAmount);
        return stakeLimit.sub(spent);
    }

    function isStaked(address account) public view returns (bool) {

        return (stakes[account].exist && stakes[account].unstakedTs == 0) ? true : false;
    }

    function setStakeLimit(uint256 _stakeLimit) external onlyOwnerOrCommunity() {

        uint256 spent = totalUnstakedAmountWithReward.add(totalStakedAmount).sub(totalUnstakedAmount);
        require(spent <= _stakeLimit, "The limit is too small");
        stakeLimit = _stakeLimit;
        emit SetStakeLimit(stakeLimit);
    }

    function setMinStakeAmount(uint256 _minStakeAmount) external onlyOwnerOrCommunity() {

        minStakeAmount = _minStakeAmount;
        emit SetMinStakeAmount(minStakeAmount);
    }

    function setEarlyUnstakeAllowed(bool allow) external onlyOwnerOrCommunity() {

        earlyUnstakeAllowed = allow;
        emit SetEarlyUnstakeAllowed(earlyUnstakeAllowed);
    }

    function startStake(uint256 amount, uint8 typeIndex) external nonReentrant() {

        address staker = _msgSender();
        uint256 capacity = leftCapacity();
        require(0 < capacity, "Already closed");
        require(isStaked(staker) == false, "Already staked");
        require(minStakeAmount <= amount, "The staking amount is too small");
        require(amount <= capacity, "Exceed the staking limit");
        require(typeIndex < types.length, "Invalid typeIndex");
        require(types[typeIndex].enabled, "The type disabled");

        zoneToken.safeTransferFrom(staker, address(this), amount);

        stakes[staker] = Stake({
            exist: true,
            typeIndex: typeIndex,
            stakedTs: block.timestamp,
            unstakedTs: 0,
            stakedAmount: amount,
            rewardAmount: 0
        });
        totalStakedAmount = totalStakedAmount.add(amount);
        types[typeIndex].stakedAmount = types[typeIndex].stakedAmount.add(amount);

        emit Staked(staker, amount, typeIndex);
    }

    function endStake() external nonReentrant() {

        address staker = _msgSender();
        require(isStaked(staker), "Not staked");

        if (staker == user1) {
            endStakeForUser1(staker);
        } else {
            uint8 typeIndex = stakes[staker].typeIndex;
            uint256 stakedAmount = stakes[staker].stakedAmount;
            (uint256 claimIn, uint256 reward) = _calcReward(stakes[staker].stakedTs, stakedAmount, typeIndex);
            require(earlyUnstakeAllowed || claimIn == 0, "Locked still");
            stakes[staker].unstakedTs = block.timestamp;
            stakes[staker].rewardAmount = (claimIn == 0) ? reward : 0;

            totalUnstakedAmount = totalUnstakedAmount.add(stakedAmount);
            if (0 < stakes[staker].rewardAmount) {
                totalUnstakedAmountWithReward = totalUnstakedAmountWithReward.add(stakedAmount);
            }
            types[typeIndex].stakedAmount = types[typeIndex].stakedAmount.sub(stakedAmount);

            zoneToken.safeTransfer(staker, stakedAmount.add(stakes[staker].rewardAmount));

            emit Unstaked(staker, stakedAmount, stakes[staker].rewardAmount);
        }
    }

    function endStakeForUser1(address staker) private {

        require(0 < user1LastUnlockTs, "Blacklisted");
        uint256 allowedAmount = user1ZonePerSec.mul(block.timestamp - user1LastUnlockTs);
        uint256 stakedAmount = stakes[staker].stakedAmount;

        if (allowedAmount < stakedAmount) {
            stakes[staker].stakedAmount = stakes[staker].stakedAmount - allowedAmount;
        } else {
            allowedAmount = stakedAmount;
            stakes[staker].unstakedTs = block.timestamp;
        }

        user1LastUnlockTs = block.timestamp;
        if (0 < allowedAmount) {
            zoneToken.safeTransfer(staker, allowedAmount);
        }
    }

    function _calcReward(
        uint256 stakedTs,
        uint256 stakedAmount,
        uint8 typeIndex
    ) internal view returns (uint256 claimIn, uint256 rewardAmount) {

        if (types[typeIndex].enabled == false) {
            return (0, 0);
        }

        uint256 unlockTs = stakedTs + (types[typeIndex].lockDay * 1 days);
        claimIn = (block.timestamp < unlockTs) ? unlockTs - block.timestamp : 0;
        rewardAmount = stakedAmount.mul(types[typeIndex].rewardRate).div(DENOMINATOR);
        return (claimIn, rewardAmount);
    }

    function getStakeInfo(
        address staker
    ) external view returns (uint256 stakedAmount, uint8 typeIndex, uint256 claimIn, uint256 rewardAmount, uint256 capacity) {

        Stake memory stake = stakes[staker];
        if (isStaked(staker)) {
            stakedAmount = stake.stakedAmount;
            typeIndex = stake.typeIndex;
            (claimIn, rewardAmount) = _calcReward(stake.stakedTs, stake.stakedAmount, stake.typeIndex);
            return (stakedAmount, typeIndex, claimIn, rewardAmount, 0);
        }
        return (0, 0, 0, 0, leftCapacity());
    }

    function fund(address _from, uint256 _amount) external {

        require(_from != address(0), '_from is invalid');
        require(0 < _amount, '_amount is invalid');
        require(_amount <= zoneToken.balanceOf(_from), 'Insufficient balance');
        zoneToken.safeTransferFrom(_from, address(this), _amount);
    }

    function finish() external onlyOwner() {

        for (uint i = 0; i < types.length; i ++) {
            if (types[i].enabled) {
                types[i].enabled = false;
            }
        }
        uint256 amount = zoneToken.balanceOf(address(this));
        amount = amount.add(totalUnstakedAmount).sub(totalStakedAmount);
        if (0 < amount) {
            zoneToken.safeTransfer(owner(), amount);
        }
    }

    function allowEndStakeForUser1() external onlyOwner() {

        user1LastUnlockTs = block.timestamp;
        user1ZonePerSec = 4606544 * 1e10; // 0.04606544 ZONE per second
    }

    function setUser1ZonePerSec(uint256 _user1ZonePerSec) external onlyOwner() {

        user1ZonePerSec = _user1ZonePerSec;
    }
}

contract ZoneStakingUpgradeableProxy is TransparentUpgradeableProxy {

    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) public {
    }
}