
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature(
                    "upgradeTo(address)",
                    oldImplementation
                )
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _setImplementation(newImplementation);
            emit Upgraded(newImplementation);
        }
    }

    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}// MIT

pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(address _logic, address admin_, bytes memory _data) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// MIT

pragma solidity ^0.8.0;


contract ProxyAdmin is Ownable {


    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(TransparentUpgradeableProxy proxy, address implementation, bytes memory data) public payable virtual onlyOwner {

        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
}// LGPL-3.0-or-later
pragma solidity 0.8.3;

uint256 constant ONE_PERCENT = 10**25;
uint256 constant DECIMAL = ONE_PERCENT * 100;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;// GPL-3.0
pragma solidity 0.8.3;



contract TokenFarming is OwnableUpgradeable, PausableUpgradeable {

    IERC20 public stakeToken;
    IERC20 public distributionToken;

    uint256 public rewardPerBlock;

    uint256 public cumulativeSum;
    uint256 public lastUpdate;

    uint256 public totalPoolStaked;

    uint256 public startDate;

    struct UserInfo {
        uint256 stakedAmount;
        uint256 lastCumulativeSum;
        uint256 aggregatedReward;
    }

    mapping(address => UserInfo) public userInfos;

    event TokensStaked(address _staker, uint256 _stakeAmount);
    event TokensWithdrawn(address _staker, uint256 _withdrawAmount);
    event RewardsClaimed(address _claimer, uint256 _rewardsAmount);

    function initTokenFarming(
        address _stakeToken,
        address _distributioToken,
        uint256 _rewardPerBlock
    ) external initializer() {

        __Pausable_init_unchained();
        __Ownable_init();
        stakeToken = IERC20(_stakeToken);
        distributionToken = IERC20(_distributioToken);
        rewardPerBlock = _rewardPerBlock;
        startDate = block.timestamp;
    }

    modifier updateRewards() {

        _updateUserRewards(_updateCumulativeSum());
        _;
    }

    function updateRewardPerBlock(uint256 _newRewardPerBlock) external onlyOwner {

        _updateCumulativeSum();
        rewardPerBlock = _newRewardPerBlock;
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    function stake(uint256 _stakeAmount) external updateRewards whenNotPaused() {

        userInfos[msg.sender].stakedAmount += _stakeAmount;
        totalPoolStaked += _stakeAmount;

        stakeToken.transferFrom(msg.sender, address(this), _stakeAmount);

        emit TokensStaked(msg.sender, _stakeAmount);
    }

    function withdrawFunds(uint256 _amountToWithdraw) public updateRewards {

        uint256 _currentStakedAmount = userInfos[msg.sender].stakedAmount;

        require(
            _currentStakedAmount >= _amountToWithdraw,
            "TokenFarming: Not enough staked tokens to withdraw"
        );

        userInfos[msg.sender].stakedAmount = _currentStakedAmount - _amountToWithdraw;
        totalPoolStaked -= _amountToWithdraw;

        stakeToken.transfer(msg.sender, _amountToWithdraw);

        emit TokensWithdrawn(msg.sender, _amountToWithdraw);
    }

    function claimRewards() public updateRewards {

        uint256 _currentRewards = _applySlashing(userInfos[msg.sender].aggregatedReward);

        require(_currentRewards > 0, "TokenFarming: Nothing to claim");

        delete userInfos[msg.sender].aggregatedReward;

        distributionToken.transfer(msg.sender, _currentRewards);

        emit RewardsClaimed(msg.sender, _currentRewards);
    }

    function claimAndWithdraw() external {

        withdrawFunds(userInfos[msg.sender].stakedAmount);
        claimRewards();
    }

    function getAPY(
        address _userAddr,
        uint256 _stakeTokenPrice,
        uint256 _distributionTokenPrice
    ) external view returns (uint256 _resultAPY) {

        uint256 _userStakeAmount = userInfos[_userAddr].stakedAmount;

        if (_userStakeAmount > 0) {
            uint256 _newCumulativeSum =
                _getNewCumulativeSum(
                    rewardPerBlock,
                    totalPoolStaked,
                    cumulativeSum,
                    BLOCKS_PER_YEAR
                );

            uint256 _totalReward =
                ((_newCumulativeSum - userInfos[_userAddr].lastCumulativeSum) * _userStakeAmount) /
                    DECIMAL;

            _resultAPY =
                (_totalReward * _distributionTokenPrice * DECIMAL) /
                (_stakeTokenPrice * _userStakeAmount);
        }
    }

    function getTotalAPY(uint256 _stakeTokenPrice, uint256 _distributionTokenPrice)
        external
        view
        returns (uint256)
    {

        uint256 _totalPool = totalPoolStaked;

        if (_totalPool > 0) {
            uint256 _totalRewards = distributionToken.balanceOf(address(this));
            return
                (_totalRewards * _distributionTokenPrice * DECIMAL) /
                (_totalPool * _stakeTokenPrice);
        }
        return 0;
    }

    function _applySlashing(uint256 _rewards) private view returns (uint256) {

        if (block.timestamp < startDate + 150 days) {
            return (_rewards * (block.timestamp - startDate)) / 150 days;
        }

        return _rewards;
    }

    function _updateCumulativeSum() internal returns (uint256 _newCumulativeSum) {

        uint256 _totalPool = totalPoolStaked;
        uint256 _lastUpdate = lastUpdate;
        _lastUpdate = _lastUpdate == 0 ? block.number : _lastUpdate;

        if (_totalPool > 0) {
            _newCumulativeSum = _getNewCumulativeSum(
                rewardPerBlock,
                _totalPool,
                cumulativeSum,
                block.number - _lastUpdate
            );

            cumulativeSum = _newCumulativeSum;
        }

        lastUpdate = block.number;
    }

    function _getNewCumulativeSum(
        uint256 _rewardPerBlock,
        uint256 _totalPool,
        uint256 _prevAP,
        uint256 _blocksDelta
    ) internal pure returns (uint256) {

        uint256 _newPrice = (_rewardPerBlock * DECIMAL) / _totalPool;
        return _blocksDelta * _newPrice + _prevAP;
    }

    function _updateUserRewards(uint256 _newCumulativeSum) internal {

        UserInfo storage userInfo = userInfos[msg.sender];

        uint256 _currentUserStakedAmount = userInfo.stakedAmount;

        if (_currentUserStakedAmount > 0) {
            userInfo.aggregatedReward +=
                ((_newCumulativeSum - userInfo.lastCumulativeSum) * _currentUserStakedAmount) /
                DECIMAL;
        }

        userInfo.lastCumulativeSum = _newCumulativeSum;
    }

    function getLatestUserRewards(address _userAddr) public view returns (uint256) {

        uint256 _totalPool = totalPoolStaked;
        uint256 _lastUpdate = lastUpdate;

        uint256 _newCumulativeSum;

        _lastUpdate = _lastUpdate == 0 ? block.number : _lastUpdate;

        if (_totalPool > 0) {
            _newCumulativeSum = _getNewCumulativeSum(
                rewardPerBlock,
                _totalPool,
                cumulativeSum,
                block.number - _lastUpdate
            );
        }

        UserInfo memory userInfo = userInfos[_userAddr];

        uint256 _currentUserStakedAmount = userInfo.stakedAmount;
        uint256 _agregatedRewards = userInfo.aggregatedReward;

        if (_currentUserStakedAmount > 0) {
            _agregatedRewards =
                _agregatedRewards +
                ((_newCumulativeSum - userInfo.lastCumulativeSum) * _currentUserStakedAmount) /
                DECIMAL;
        }

        return _agregatedRewards;
    }

    function getLatestUserRewardsAfterSlashing(address _userAddr) external view returns (uint256) {

        return _applySlashing(getLatestUserRewards(_userAddr));
    }

    function transferStuckERC20(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {

        require(address(_token) != address(stakeToken), "Not possible to withdraw stake token");
        _token.transfer(_to, _amount);
    }
}// GPL-3.0
pragma solidity 0.8.3;


contract Factory is Ownable {

    event FarmingDeployed(address _farmingImp, address _farmingProxy, address _proxyAdmin);

    function deployFarmingContract(
        address _stakeToken,
        address _distributionToken,
        uint256 _rewardPerBlock
    )
        external
        onlyOwner
        returns (
            address,
            address,
            address
        )
    {

        TokenFarming _farmingImp = new TokenFarming();
        ProxyAdmin _proxyAdmin = new ProxyAdmin();
        TransparentUpgradeableProxy _proxy =
            new TransparentUpgradeableProxy(address(_farmingImp), address(_proxyAdmin), "");
        TokenFarming _farmingProxy = TokenFarming(address(_proxy));
        _farmingProxy.initTokenFarming(_stakeToken, _distributionToken, _rewardPerBlock);
        _farmingProxy.transferOwnership(msg.sender);
        _proxyAdmin.transferOwnership(msg.sender);

        emit FarmingDeployed(address(_farmingImp), address(_farmingProxy), address(_proxyAdmin));
        return (address(_farmingImp), address(_farmingProxy), address(_proxyAdmin));
    }
}