
pragma solidity =0.8.9;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, 'Address: low-level call failed');
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

        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, 'Address: insufficient balance for call');
        require(isContract(target), 'Address: call to non-contract');

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, 'Address: low-level static call failed');
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), 'Address: static call to non-contract');

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

pragma solidity =0.8.9;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, 'CIAI');

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
        require(_initializing, 'CINI');
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// GNU GPLv3

pragma solidity =0.8.9;



abstract contract ERC2771ContextUpgradeable is Initializable {

    address public trustedForwarder;


    function __ERC2771ContextUpgradeable_init(address tForwarder) internal initializer {
        __ERC2771ContextUpgradeable_init_unchained(tForwarder);
    }


    function __ERC2771ContextUpgradeable_init_unchained(address tForwarder) internal {
        trustedForwarder = tForwarder;
    }


    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == trustedForwarder;
    }


    function _msgSender() internal view virtual returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }


    function _msgData() internal view virtual returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
}// GNU GPLv3


pragma solidity =0.8.9;



abstract contract OwnableUpgradeable is Initializable, ERC2771ContextUpgradeable {
    address private _owner;
    address private _master;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init(address master, address trustedForwarder) internal initializer {
        __Ownable_init_unchained(master);
        __ERC2771ContextUpgradeable_init(trustedForwarder);
    }

    function __Ownable_init_unchained(address masterAddress) internal initializer {
        _transferOwnership(_msgSender());
        _master = masterAddress;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), 'ONA');
        _;
    }

    modifier onlyMaster() {
        require(_master == _msgSender(), 'OMA');
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(_master);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'INA');
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// GNU GPLv3

pragma solidity =0.8.9;



library TransferHelpers {


    function safeTransferFrom(
        address target,
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = target.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, amount));
        require(success && data.length > 0, 'STFF');
    }


    function safeTransfer(
        address target,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = target.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && data.length > 0, 'STF');
    }


    function safeTransferParentChainToken(address to, uint256 value) internal {

        (bool success, ) = to.call{value: uint128(value)}(new bytes(0));
        require(success, 'STPCF');
    }
}// GNU GPLv3

pragma solidity =0.8.9;

interface IWETH {


    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);



    function withdraw(uint256) external;

}// GNU GPLv3

pragma solidity =0.8.9;

abstract contract UnifarmRewardRegistryUpgradeableStorage {
    receive() external payable {}

    uint256 public refPercentage;

    struct ReferralConfiguration {
        address userAddress;
        uint256 referralPercentage;
    }

    mapping(address => mapping(address => uint256)) public rewardCap;

    mapping(address => bytes) internal _rewards;

    mapping(address => ReferralConfiguration) public referralConfig;

    address public multiCall;
}// GNU GPLv3

pragma solidity =0.8.9;

interface IUnifarmRewardRegistryUpgradeable {


    function distributeRewards(
        address cohortId,
        address userAddress,
        address influencerAddress,
        uint256 rValue,
        bool hasContainsWrappedToken
    ) external;



    function addInfluencers(address[] memory userAddresses, uint256[] memory referralPercentages) external;



    function updateMulticall(address newMultiCallAddress) external;



    function updateRefPercentage(uint256 newRefPercentage) external;



    function setRewardTokenDetails(address cohortId, bytes calldata rewards) external;



    function setRewardCap(
        address cohortId,
        address[] memory rewardTokenAddresses,
        uint256[] memory rewards
    ) external returns (bool);



    function safeWithdrawEth(address withdrawableAddress, uint256 amount) external returns (bool);



    function safeWithdrawAll(
        address withdrawableAddress,
        address[] memory tokens,
        uint256[] memory amounts
    ) external;



    function getRewardTokens(address cohortId) external view returns (address[] memory rewardTokens, uint256[] memory pbr);



    function getInfluencerReferralPercentage(address influencerAddress) external view returns (uint256 referralPercentage);


    event UpdatedRefPercentage(uint256 newRefPercentage);

    event SetRewardTokenDetails(address indexed cohortId, bytes rewards);
}// GNU GPLv3

pragma solidity =0.8.9;



contract UnifarmRewardRegistryUpgradeable is
    IUnifarmRewardRegistryUpgradeable,
    UnifarmRewardRegistryUpgradeableStorage,
    Initializable,
    OwnableUpgradeable
{


    modifier onlyMulticallOrOwner() {

        onlyOwnerOrMulticall();
        _;
    }


    function onlyOwnerOrMulticall() internal view {

        require(_msgSender() == multiCall || _msgSender() == owner(), 'IS');
    }


    function __UnifarmRewardRegistryUpgradeable_init(
        address masterAddress,
        address trustedForwarder,
        address multiCall_,
        uint256 referralPercentage
    ) external initializer {

        __UnifarmRewardRegistryUpgradeable_init_unchained(multiCall_, referralPercentage);
        __Ownable_init(masterAddress, trustedForwarder);
    }


    function __UnifarmRewardRegistryUpgradeable_init_unchained(address multiCall_, uint256 referralPercentage) internal {

        multiCall = multiCall_;
        refPercentage = referralPercentage;
    }


    function updateRefPercentage(uint256 newRefPercentage) external override onlyMulticallOrOwner {

        refPercentage = newRefPercentage;
        emit UpdatedRefPercentage(newRefPercentage);
    }


    function addInfluencers(address[] memory userAddresses, uint256[] memory referralPercentages) external override onlyMulticallOrOwner {

        require(userAddresses.length == referralPercentages.length, 'AIF');
        uint8 usersLength = uint8(userAddresses.length);
        uint8 k;
        while (k < usersLength) {
            referralConfig[userAddresses[k]] = ReferralConfiguration({userAddress: userAddresses[k], referralPercentage: referralPercentages[k]});
            k++;
        }
    }


    function updateMulticall(address newMultiCallAddress) external onlyOwner {

        require(newMultiCallAddress != multiCall, 'SMA');
        multiCall = newMultiCallAddress;
    }


    function setRewardCap(
        address cohortId,
        address[] memory rewardTokenAddresses,
        uint256[] memory rewards
    ) external override onlyMulticallOrOwner returns (bool) {

        require(cohortId != address(0), 'ICI');
        require(rewardTokenAddresses.length == rewards.length, 'IL');
        uint8 rewardTokensLength = uint8(rewardTokenAddresses.length);
        for (uint8 v = 0; v < rewardTokensLength; v++) {
            require(rewards[v] > 0, 'IRA');
            rewardCap[cohortId][rewardTokenAddresses[v]] = rewards[v];
        }
        return true;
    }


    function setRewardTokenDetails(address cohortId, bytes calldata rewards) external onlyMulticallOrOwner {

        require(cohortId != address(0), 'ICI');
        _rewards[cohortId] = rewards;
        emit SetRewardTokenDetails(cohortId, rewards);
    }


    function getRewardTokens(address cohortId) public view returns (address[] memory rewardTokens, uint256[] memory pbr) {

        bytes memory rewardByte = _rewards[cohortId];
        (rewardTokens, pbr) = abi.decode(rewardByte, (address[], uint256[]));
    }


    function getInfluencerReferralPercentage(address influencerAddress) public view override returns (uint256 referralPercentage) {

        ReferralConfiguration memory referral = referralConfig[influencerAddress];
        bool isConfigurationAvailable = referral.userAddress != address(0);
        if (isConfigurationAvailable) {
            referralPercentage = referral.referralPercentage;
        } else {
            referralPercentage = refPercentage;
        }
    }


    function sendOne(
        address cohortId,
        address rewardTokenAddress,
        address user,
        address referralAddress,
        uint256 referralPercentage,
        uint256 pbr1,
        uint256 rValue,
        bool hasContainWrapToken
    ) internal {

        uint256 rewardValue = (pbr1 * rValue) / (1e12);
        require(rewardCap[cohortId][rewardTokenAddress] >= rewardValue, 'RCR');
        uint256 refEarned = (rewardValue * referralPercentage) / (100000);
        uint256 userEarned = rewardValue - refEarned;
        bool zero = referralAddress != address(0);
        if (hasContainWrapToken) {
            IWETH(rewardTokenAddress).withdraw(rewardValue);
            if (zero) TransferHelpers.safeTransferParentChainToken(referralAddress, refEarned);
            TransferHelpers.safeTransferParentChainToken(user, userEarned);
        } else {
            if (zero) TransferHelpers.safeTransfer(rewardTokenAddress, referralAddress, refEarned);
            TransferHelpers.safeTransfer(rewardTokenAddress, user, userEarned);
        }
        rewardCap[cohortId][rewardTokenAddress] = rewardCap[cohortId][rewardTokenAddress] - rewardValue;
    }


    function sendMulti(
        address cohortId,
        address[] memory rewardTokens,
        uint256[] memory pbr,
        address userAddress,
        address referralAddress,
        uint256 referralPercentage,
        uint256 rValue
    ) internal {

        uint8 rTokensLength = uint8(rewardTokens.length);
        for (uint8 r = 1; r < rTokensLength; r++) {
            uint256 exactReward = (pbr[r] * rValue) / 1e12;
            require(rewardCap[cohortId][rewardTokens[r]] >= exactReward, 'RCR');
            uint256 refEarned = (exactReward * referralPercentage) / 100000;
            uint256 userEarned = exactReward - refEarned;
            if (referralAddress != address(0)) TransferHelpers.safeTransfer(rewardTokens[r], referralAddress, refEarned);
            TransferHelpers.safeTransfer(rewardTokens[r], userAddress, userEarned);
            rewardCap[cohortId][rewardTokens[r]] = rewardCap[cohortId][rewardTokens[r]] - exactReward;
        }
    }


    function distributeRewards(
        address cohortId,
        address userAddress,
        address influcenerAddress,
        uint256 rValue,
        bool hasContainsWrappedToken
    ) external override {

        require(_msgSender() == cohortId, 'IS');
        (address[] memory rewardTokens, uint256[] memory pbr) = getRewardTokens(cohortId);
        uint256 referralPercentage = getInfluencerReferralPercentage(influcenerAddress);
        sendOne(cohortId, rewardTokens[0], userAddress, influcenerAddress, referralPercentage, pbr[0], rValue, hasContainsWrappedToken);
        sendMulti(cohortId, rewardTokens, pbr, userAddress, influcenerAddress, referralPercentage, rValue);
    }


    function safeWithdrawEth(address withdrawableAddress, uint256 amount) external onlyOwner returns (bool) {

        require(withdrawableAddress != address(0), 'IWA');
        TransferHelpers.safeTransferParentChainToken(withdrawableAddress, amount);
        return true;
    }


    function safeWithdrawAll(
        address withdrawableAddress,
        address[] memory tokens,
        uint256[] memory amounts
    ) external onlyOwner {

        require(withdrawableAddress != address(0), 'IWA');
        require(tokens.length == amounts.length, 'SF');
        uint8 i = 0;
        uint8 tokensLength = uint8(tokens.length);
        while (i < tokensLength) {
            TransferHelpers.safeTransfer(tokens[i], withdrawableAddress, amounts[i]);
            i++;
        }
    }

    uint256[49] private __gap;
}