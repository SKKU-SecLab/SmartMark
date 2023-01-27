
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
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
}// agpl-3.0
pragma solidity 0.8.4;
pragma abicoder v2;

library DistributionTypes {

    struct AssetConfigInput {
        uint128 emissionPerSecond;
        uint256 totalStaked;
        address underlyingAsset;
    }

    struct UserStakeInput {
        address underlyingAsset;
        uint256 stakedByUser;
        uint256 totalStaked;
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
}// agpl-3.0
pragma solidity 0.8.4;



contract DistributionManager is Initializable, OwnableUpgradeable {

    using SafeMath for uint256;

    struct AssetData {
        uint128 emissionPerSecond;
        uint128 lastUpdateTimestamp;
        uint256 index;
        mapping(address => uint256) users;
    }

    uint256 public DISTRIBUTION_END;

    uint8 public constant PRECISION = 18;

    mapping(address => AssetData) public assets;

    event AssetConfigUpdated(
        address indexed _asset,
        uint256 _emissionPerSecond
    );
    event AssetIndexUpdated(address indexed _asset, uint256 _index);
    event DistributionEndUpdated(uint256 newDistributionEnd);

    event UserIndexUpdated(
        address indexed user,
        address indexed asset,
        uint256 index
    );

    function __DistributionManager_init(uint256 _distributionDuration)
        internal
        initializer
    {

        __Ownable_init();
        DISTRIBUTION_END = block.timestamp.add(_distributionDuration);
    }

    function setDistributionEnd(uint256 _distributionEnd) external onlyOwner {

        DISTRIBUTION_END = _distributionEnd;
        emit DistributionEndUpdated(_distributionEnd);
    }

    function _configureAssets(
        DistributionTypes.AssetConfigInput[] memory _assetsConfigInput
    ) internal onlyOwner {

        for (uint256 i = 0; i < _assetsConfigInput.length; i++) {
            AssetData storage assetConfig = assets[
                _assetsConfigInput[i].underlyingAsset
            ];

            _updateAssetStateInternal(
                _assetsConfigInput[i].underlyingAsset,
                assetConfig,
                _assetsConfigInput[i].totalStaked
            );

            assetConfig.emissionPerSecond = _assetsConfigInput[i]
                .emissionPerSecond;

            emit AssetConfigUpdated(
                _assetsConfigInput[i].underlyingAsset,
                _assetsConfigInput[i].emissionPerSecond
            );
        }
    }

    function _updateAssetStateInternal(
        address _underlyingAsset,
        AssetData storage _assetConfig,
        uint256 _totalStaked
    ) internal returns (uint256) {

        uint256 oldIndex = _assetConfig.index;
        uint128 lastUpdateTimestamp = _assetConfig.lastUpdateTimestamp;

        if (block.timestamp == lastUpdateTimestamp) {
            return oldIndex;
        }
        uint256 newIndex = _getAssetIndex(
            oldIndex,
            _assetConfig.emissionPerSecond,
            lastUpdateTimestamp,
            _totalStaked
        );

        if (newIndex != oldIndex) {
            _assetConfig.index = newIndex;
            emit AssetIndexUpdated(_underlyingAsset, newIndex);
        }

        _assetConfig.lastUpdateTimestamp = uint128(block.timestamp);

        return newIndex;
    }

    function _updateUserAssetInternal(
        address _user,
        address _asset,
        uint256 _stakedByUser,
        uint256 _totalStaked
    ) internal returns (uint256) {

        AssetData storage assetData = assets[_asset];
        uint256 userIndex = assetData.users[_user];
        uint256 accruedRewards = 0;

        uint256 newIndex = _updateAssetStateInternal(
            _asset,
            assetData,
            _totalStaked
        );
        if (userIndex != newIndex) {
            if (_stakedByUser != 0) {
                accruedRewards = _getRewards(
                    _stakedByUser,
                    newIndex,
                    userIndex
                );
            }

            assetData.users[_user] = newIndex;
            emit UserIndexUpdated(_user, _asset, newIndex);
        }
        return accruedRewards;
    }

    function _claimRewards(
        address _user,
        DistributionTypes.UserStakeInput[] memory _stakes
    ) internal returns (uint256) {

        uint256 accruedRewards = 0;

        for (uint256 i = 0; i < _stakes.length; i++) {
            accruedRewards = accruedRewards.add(
                _updateUserAssetInternal(
                    _user,
                    _stakes[i].underlyingAsset,
                    _stakes[i].stakedByUser,
                    _stakes[i].totalStaked
                )
            );
        }

        return accruedRewards;
    }

    function _getUnclaimedRewards(
        address _user,
        DistributionTypes.UserStakeInput[] memory _stakes
    ) internal view returns (uint256) {

        uint256 accruedRewards = 0;

        for (uint256 i = 0; i < _stakes.length; i++) {
            AssetData storage assetConfig = assets[_stakes[i].underlyingAsset];
            uint256 assetIndex = _getAssetIndex(
                assetConfig.index,
                assetConfig.emissionPerSecond,
                assetConfig.lastUpdateTimestamp,
                _stakes[i].totalStaked
            );

            accruedRewards = accruedRewards.add(
                _getRewards(
                    _stakes[i].stakedByUser,
                    assetIndex,
                    assetConfig.users[_user]
                )
            );
        }
        return accruedRewards;
    }

    function _getRewards(
        uint256 _principalUserBalance,
        uint256 _reserveIndex,
        uint256 _userIndex
    ) internal pure returns (uint256) {

        return
            _principalUserBalance.mul(_reserveIndex.sub(_userIndex)).div(
                10**uint256(PRECISION)
            );
    }

    function _getAssetIndex(
        uint256 _currentIndex,
        uint256 _emissionPerSecond,
        uint128 _lastUpdateTimestamp,
        uint256 _totalBalance
    ) internal view returns (uint256) {

        if (
            _emissionPerSecond == 0 ||
            _totalBalance == 0 ||
            _lastUpdateTimestamp == block.timestamp ||
            _lastUpdateTimestamp >= DISTRIBUTION_END
        ) {
            return _currentIndex;
        }

        uint256 currentTimestamp = block.timestamp > DISTRIBUTION_END
            ? DISTRIBUTION_END
            : block.timestamp;
        uint256 timeDelta = currentTimestamp.sub(_lastUpdateTimestamp);
        return
            _emissionPerSecond
                .mul(timeDelta)
                .mul(10**uint256(PRECISION))
                .div(_totalBalance)
                .add(_currentIndex);
    }

    function getUserAssetData(address _user, address _asset)
        public
        view
        returns (uint256)
    {

        return assets[_asset].users[_user];
    }
}// agpl-3.0
pragma solidity 0.8.4;

interface IScaledBalanceToken {

    function getScaledUserBalanceAndSupply(address _user)
        external
        view
        returns (uint256, uint256);


    function scaledTotalSupply() external view returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;


interface IIncentivesController {

    event RewardsAccrued(address indexed _user, uint256 _amount);

    event RewardsClaimed(address indexed _user, uint256 _amount);

    function configureAssets(
        IScaledBalanceToken[] calldata _assets,
        uint256[] calldata _emissionsPerSecond
    ) external;


    function handleAction(
        address _user,
        uint256 _totalSupply,
        uint256 _userBalance
    ) external;


    function getRewardsBalance(
        IScaledBalanceToken[] calldata _assets,
        address _user
    ) external view returns (uint256);


    function claimRewards(
        IScaledBalanceToken[] calldata _assets,
        uint256 _amount
    ) external returns (uint256);


    function getUserUnclaimedRewards(address _user)
        external
        view
        returns (uint256);

}// agpl-3.0
pragma solidity 0.8.4;





contract BendProtocolIncentivesController is
    IIncentivesController,
    DistributionManager
{

    using SafeMath for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public REWARD_TOKEN;
    address public REWARDS_VAULT;

    mapping(address => uint256) internal usersUnclaimedRewards;
    mapping(address => bool) public authorizedAssets;

    function initialize(
        address _rewardToken,
        address _rewardsVault,
        uint128 _distributionDuration
    ) external initializer {

        __DistributionManager_init(_distributionDuration);
        REWARD_TOKEN = IERC20Upgradeable(_rewardToken);
        REWARDS_VAULT = _rewardsVault;
    }

    function configureAssets(
        IScaledBalanceToken[] calldata _assets,
        uint256[] calldata _emissionsPerSecond
    ) external override onlyOwner {

        require(
            _assets.length == _emissionsPerSecond.length,
            "INVALID_CONFIGURATION"
        );

        DistributionTypes.AssetConfigInput[]
            memory assetsConfig = new DistributionTypes.AssetConfigInput[](
                _assets.length
            );

        for (uint256 i = 0; i < _assets.length; i++) {
            authorizedAssets[address(_assets[i])] = true;
            assetsConfig[i].underlyingAsset = address(_assets[i]);
            assetsConfig[i].emissionPerSecond = uint128(_emissionsPerSecond[i]);

            require(
                assetsConfig[i].emissionPerSecond == _emissionsPerSecond[i],
                "INVALID_CONFIGURATION"
            );

            assetsConfig[i].totalStaked = _assets[i].scaledTotalSupply();
        }
        _configureAssets(assetsConfig);
    }

    function handleAction(
        address _user,
        uint256 _totalSupply,
        uint256 _userBalance
    ) external override {

        require(authorizedAssets[msg.sender], "Sender Unauthorized");
        uint256 accruedRewards = _updateUserAssetInternal(
            _user,
            msg.sender,
            _userBalance,
            _totalSupply
        );
        if (accruedRewards != 0) {
            usersUnclaimedRewards[_user] = usersUnclaimedRewards[_user].add(
                accruedRewards
            );
            emit RewardsAccrued(_user, accruedRewards);
        }
    }

    function getRewardsBalance(
        IScaledBalanceToken[] calldata _assets,
        address _user
    ) external view override returns (uint256) {

        uint256 unclaimedRewards = usersUnclaimedRewards[_user];

        DistributionTypes.UserStakeInput[]
            memory userState = new DistributionTypes.UserStakeInput[](
                _assets.length
            );
        for (uint256 i = 0; i < _assets.length; i++) {
            userState[i].underlyingAsset = address(_assets[i]);
            (
                userState[i].stakedByUser,
                userState[i].totalStaked
            ) = IScaledBalanceToken(_assets[i]).getScaledUserBalanceAndSupply(
                _user
            );
        }
        unclaimedRewards = unclaimedRewards.add(
            _getUnclaimedRewards(_user, userState)
        );
        return unclaimedRewards;
    }

    function getUserUnclaimedRewards(address _user)
        external
        view
        override
        returns (uint256)
    {

        return usersUnclaimedRewards[_user];
    }

    function claimRewards(
        IScaledBalanceToken[] calldata _assets,
        uint256 _amount
    ) external override returns (uint256) {

        if (_amount == 0) {
            return 0;
        }
        address user = msg.sender;
        uint256 unclaimedRewards = usersUnclaimedRewards[user];

        DistributionTypes.UserStakeInput[]
            memory userState = new DistributionTypes.UserStakeInput[](
                _assets.length
            );
        for (uint256 i = 0; i < _assets.length; i++) {
            userState[i].underlyingAsset = address(_assets[i]);
            (
                userState[i].stakedByUser,
                userState[i].totalStaked
            ) = IScaledBalanceToken(_assets[i]).getScaledUserBalanceAndSupply(
                user
            );
        }

        uint256 accruedRewards = _claimRewards(user, userState);
        if (accruedRewards != 0) {
            unclaimedRewards = unclaimedRewards.add(accruedRewards);
            emit RewardsAccrued(user, accruedRewards);
        }

        if (unclaimedRewards == 0) {
            return 0;
        }

        uint256 amountToClaim = _amount > unclaimedRewards
            ? unclaimedRewards
            : _amount;
        usersUnclaimedRewards[user] = unclaimedRewards - amountToClaim; // Safe due to the previous line

        IERC20Upgradeable(REWARD_TOKEN).safeTransferFrom(
            REWARDS_VAULT,
            msg.sender,
            amountToClaim
        );

        emit RewardsClaimed(msg.sender, amountToClaim);

        return amountToClaim;
    }
}