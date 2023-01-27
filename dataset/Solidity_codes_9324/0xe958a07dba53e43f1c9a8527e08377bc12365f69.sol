
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
}// GPL-3.0
pragma solidity ^0.8.0;

library Errors {

    string public constant ZERO_ADDRESS = "100";
    string public constant ZERO_AMOUNT = "101";
    string public constant INVALID_ADDRESS = "102";
    string public constant INVALID_AMOUNT = "103";
    string public constant NO_PENDING_REWARD = "104";
    string public constant INVALID_PID = "105";
    string public constant INVALID_POOL_ADDRESS = "106";
    string public constant UNAUTHORIZED = "107";
    string public constant ALREADY_EXISTS = "108";
    string public constant SAME_ALLOCPOINT = "109";
    string public constant INVALID_REWARD_PER_BLOCK = "110";
    string public constant INSUFFICIENT_REWARDS = "111";
    string public constant EXCEED_MAX_HARVESTER_FEE = "112";
    string public constant EXCEED_MAX_FEE = "113";
    string public constant INVALID_INDEX = "114";
    string public constant INVALID_REQUEST = "115";
}// GPL-3.0
pragma solidity ^0.8.0;

interface IBentCVX {

    function deposit(uint256 _amount) external;

}// MIT

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
}// GPL-3.0
pragma solidity ^0.8.0;


interface IBentPool {

    function lpToken() external view returns (address);

}// GPL-3.0
pragma solidity ^0.8.0;


interface IBentPoolManager {

    function feeInfo()
        external
        view
        returns (
            uint256,
            address,
            uint256,
            address,
            uint256
        );


    function rewardToken() external view returns (address);


    function mint(address user, uint256 cvxAmount) external;

}// GPL-3.0
pragma solidity ^0.8.0;

interface IConvexBooster {

    function poolInfo(uint256)
        external
        view
        returns (
            address,
            address,
            address,
            address,
            address,
            bool
        );


    function deposit(
        uint256,
        uint256,
        bool
    ) external returns (bool);


    function depositAll(uint256, bool) external returns (bool);


    function withdraw(uint256, uint256) external returns (bool);


    function withdrawAll(uint256) external returns (bool);


    function rewardClaimed(
        uint256,
        address,
        uint256
    ) external returns (bool);

}// GPL-3.0
pragma solidity ^0.8.0;

interface IBaseRewardPool {

    function getReward(address, bool) external returns (bool);


    function getReward() external returns (bool);


    function earned(address) external view returns (uint256);


    function balanceOf(address) external view returns (uint256);


    function extraRewards(uint256) external view returns (address);


    function withdrawAndUnwrap(uint256, bool) external returns (bool);


    function extraRewardsLength() external view returns (uint256);

}// GPL-3.0
pragma solidity ^0.8.0;


interface IConvexToken is IERC20 {

    function reductionPerCliff() external view returns (uint256);


    function totalCliffs() external view returns (uint256);


    function maxSupply() external view returns (uint256);

}// GPL-3.0
pragma solidity ^0.8.0;

interface IVirtualBalanceRewardPool {

    function getReward(address) external;


    function getReward() external;


    function balanceOf(address) external view returns (uint256);


    function earned(address) external view returns (uint256);


    function rewardToken() external view returns (address);

}// GPL-3.0
pragma solidity ^0.8.0;



contract BentLocker is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    event Deposit(address indexed user, uint256 amount, uint256 shares);
    event Withdraw(address indexed user, uint256 amount, uint256 shares);
    event ClaimAll(address indexed user);
    event Claim(address indexed user, uint256[] pids);

    struct PoolData {
        address rewardToken;
        uint256 accRewardPerShare; // Accumulated Rewards per share, times 1e36. See below.
        uint256 rewardRate;
        uint256 reserves;
    }
    struct LockedBalance {
        uint256 amount;
        uint256 unlockAt;
    }
    struct Epoch {
        uint256 supply;
        uint256 startAt;
    }
    struct StreamInfo {
        uint256 windowLength;
        uint256 endRewardBlock; // end block of rewards stream
    }

    IERC20Upgradeable public bent;
    IBentCVX public bentCVX;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public rewardPoolsCount;
    mapping(uint256 => PoolData) public rewardPools;
    mapping(address => bool) public isRewardToken;
    mapping(uint256 => mapping(address => uint256)) internal userRewardDebt;
    mapping(uint256 => mapping(address => uint256)) internal userPendingRewards;

    uint256 internal firstEpoch; // first epoch start in week
    uint256 public epochLength; // 1 weeks
    uint256 public lockDurationInEpoch; // in lock group = 8 weeks
    mapping(address => mapping(uint256 => uint256)) public userLocks; // user => epoch => locked balance

    uint256 lastRewardBlock; // last block of rewards streamed
    StreamInfo public bentStreamInfo; // only for bentCVX rewards
    StreamInfo public votiumStreamInfo; // for non-bentCVX rewards

    function initialize(
        address _bent,
        address _bentCVX,
        address[] memory _rewardTokens,
        uint256 bentWindowLength, // 7 days
        uint256 votiumWindowLength, // 15 days
        uint256 _epochLength, // 1 weeks
        uint256 _lockDurationInEpoch // in lock group = 8 weeks
    ) public initializer {

        __Ownable_init();
        __ReentrancyGuard_init();

        bent = IERC20Upgradeable(_bent);
        bentCVX = IBentCVX(_bentCVX);

        addRewardTokens(_rewardTokens);

        bentStreamInfo.windowLength = bentWindowLength;
        votiumStreamInfo.windowLength = votiumWindowLength;
        epochLength = _epochLength;
        lockDurationInEpoch = _lockDurationInEpoch;

        firstEpoch = block.timestamp / epochLength;
    }

    function name() external pure returns (string memory) {

        return "weBENT";
    }

    function decimals() external pure returns (uint256) {

        return 18;
    }

    function addRewardTokens(address[] memory _rewardTokens) public onlyOwner {

        uint256 length = _rewardTokens.length;
        for (uint256 i = 0; i < length; i++) {
            require(!isRewardToken[_rewardTokens[i]], Errors.ALREADY_EXISTS);
            rewardPools[rewardPoolsCount + i].rewardToken = _rewardTokens[i];
            isRewardToken[_rewardTokens[i]] = true;
        }
        rewardPoolsCount += length;
    }

    function removeRewardToken(uint256 _index) external onlyOwner {

        require(_index < rewardPoolsCount, Errors.INVALID_INDEX);

        isRewardToken[rewardPools[_index].rewardToken] = false;
        delete rewardPools[_index];
    }

    function currentEpoch() public view returns (uint256) {

        return block.timestamp / epochLength - firstEpoch;
    }

    function epochExpireAt(uint256 epoch) public view returns (uint256) {

        return (firstEpoch + epoch + 1) * epochLength;
    }

    function unlockableBalances(address user) public view returns (uint256) {

        uint256 lastEpoch = currentEpoch();
        uint256 fromLockedEpoch = lastEpoch >= lockDurationInEpoch
            ? lastEpoch - lockDurationInEpoch + 1
            : 0;

        uint256 locked;
        for (uint256 i = fromLockedEpoch; i <= lastEpoch; i++) {
            locked += userLocks[user][i];
        }
        return balanceOf[user] - locked;
    }

    function lockedBalances(address user)
        external
        view
        returns (
            uint256 unlockable,
            uint256 locked,
            LockedBalance[] memory lockData
        )
    {

        uint256 lastEpoch = currentEpoch();
        uint256 fromLockedEpoch = lastEpoch >= lockDurationInEpoch
            ? lastEpoch - lockDurationInEpoch + 1
            : 0;

        lockData = new LockedBalance[](lastEpoch - fromLockedEpoch + 1);
        for (uint256 i = fromLockedEpoch; i <= lastEpoch; i++) {
            uint256 amount = userLocks[user][i];
            lockData[i - fromLockedEpoch] = LockedBalance(
                amount,
                epochExpireAt(i)
            );
            locked += amount;
        }
        return (balanceOf[user] - locked, locked, lockData);
    }

    function pendingReward(address user)
        external
        view
        returns (uint256[] memory pending)
    {

        uint256 _rewardPoolsCount = rewardPoolsCount;
        pending = new uint256[](_rewardPoolsCount);

        if (totalSupply != 0) {
            uint256[] memory addedRewards = _calcAddedRewards();
            for (uint256 i = 0; i < _rewardPoolsCount; ++i) {
                PoolData memory pool = rewardPools[i];
                if (pool.rewardToken == address(0)) {
                    continue;
                }
                uint256 newAccRewardPerShare = pool.accRewardPerShare +
                    ((addedRewards[i] * 1e36) / totalSupply);

                pending[i] =
                    userPendingRewards[i][user] +
                    ((balanceOf[user] * newAccRewardPerShare) / 1e36) -
                    userRewardDebt[i][user];
            }
        }
    }

    function deposit(uint256 _amount) external nonReentrant {

        require(_amount != 0, Errors.ZERO_AMOUNT);

        _updateAccPerShare(true);

        uint256 shares = _amount;
        if (totalSupply != 0) {
            shares = (shares * totalSupply) / bent.balanceOf(address(this));
        }

        bent.safeTransferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, shares);

        _updateUserRewardDebt();

        emit Deposit(msg.sender, _amount, shares);
    }

    function withdraw(uint256 _shares) external nonReentrant {

        require(
            unlockableBalances(msg.sender) >= _shares && _shares != 0,
            Errors.INVALID_AMOUNT
        );

        _updateAccPerShare(true);

        uint256 amount = _shares;
        if (totalSupply != 0) {
            amount = (amount * bent.balanceOf(address(this))) / totalSupply;
        }

        _burn(msg.sender, _shares);

        bent.safeTransfer(msg.sender, amount);

        _updateUserRewardDebt();

        emit Withdraw(msg.sender, amount, _shares);
    }

    function claimAll() external virtual nonReentrant {

        _updateAccPerShare(true);

        bool claimed = false;
        uint256 _rewardPoolsCount = rewardPoolsCount;
        for (uint256 i = 0; i < _rewardPoolsCount; ++i) {
            uint256 claimAmount = _claim(i);
            if (claimAmount > 0) {
                claimed = true;
            }
        }
        require(claimed, Errors.NO_PENDING_REWARD);

        _updateUserRewardDebt();

        emit ClaimAll(msg.sender);
    }

    function claim(uint256[] memory pids) external nonReentrant {

        _updateAccPerShare(true);

        bool claimed = false;
        for (uint256 i = 0; i < pids.length; ++i) {
            uint256 claimAmount = _claim(pids[i]);
            if (claimAmount > 0) {
                claimed = true;
            }
        }
        require(claimed, Errors.NO_PENDING_REWARD);

        _updateUserRewardDebt();

        emit Claim(msg.sender, pids);
    }

    function onReward() external nonReentrant {

        _updateAccPerShare(false);

        bool isBentAvaialble = false;
        bool isVotiumAvailable = false;

        for (uint256 i = 0; i < rewardPoolsCount; ++i) {
            PoolData storage pool = rewardPools[i];
            if (pool.rewardToken == address(0)) {
                continue;
            }

            uint256 newRewards = IERC20Upgradeable(pool.rewardToken).balanceOf(
                address(this)
            ) - pool.reserves;

            if (newRewards == 0) {
                continue;
            }

            StreamInfo memory streamInfo = bentStreamInfo;
            isBentAvaialble = true;
            if (pool.rewardToken != address(bentCVX)) {
                streamInfo = votiumStreamInfo;
                isVotiumAvailable = true;
            }

            if (streamInfo.endRewardBlock > lastRewardBlock) {
                pool.rewardRate =
                    (pool.rewardRate *
                        (streamInfo.endRewardBlock - lastRewardBlock) +
                        newRewards *
                        1e36) /
                    streamInfo.windowLength;
            } else {
                pool.rewardRate = (newRewards * 1e36) / streamInfo.windowLength;
            }

            pool.reserves += newRewards;
        }

        if (isBentAvaialble) {
            bentStreamInfo.endRewardBlock =
                lastRewardBlock +
                bentStreamInfo.windowLength;
        }
        if (isVotiumAvailable) {
            votiumStreamInfo.endRewardBlock =
                lastRewardBlock +
                votiumStreamInfo.windowLength;
        }
    }

    function bentBalanceOf(address user) external view returns (uint256) {

        if (totalSupply == 0) {
            return 0;
        }

        return (balanceOf[user] * bent.balanceOf(address(this))) / totalSupply;
    }


    function _updateAccPerShare(bool withdrawReward) internal {

        uint256[] memory addedRewards = _calcAddedRewards();
        uint256 _rewardPoolsCount = rewardPoolsCount;
        for (uint256 i = 0; i < _rewardPoolsCount; ++i) {
            PoolData storage pool = rewardPools[i];
            if (pool.rewardToken == address(0)) {
                continue;
            }

            if (totalSupply == 0) {
                pool.accRewardPerShare = block.number;
            } else {
                pool.accRewardPerShare +=
                    (addedRewards[i] * (1e36)) /
                    totalSupply;
            }

            if (withdrawReward) {
                uint256 pending = ((balanceOf[msg.sender] *
                    pool.accRewardPerShare) / 1e36) -
                    userRewardDebt[i][msg.sender];

                if (pending > 0) {
                    userPendingRewards[i][msg.sender] += pending;
                }
            }
        }

        lastRewardBlock = block.number;
    }

    function _calcAddedRewards()
        internal
        view
        returns (uint256[] memory addedRewards)
    {

        uint256 bentStreamDuration = _calcRewardDuration(
            bentStreamInfo.windowLength,
            bentStreamInfo.endRewardBlock
        );
        uint256 votiumStreamDuration = _calcRewardDuration(
            votiumStreamInfo.windowLength,
            votiumStreamInfo.endRewardBlock
        );

        uint256 _rewardPoolsCount = rewardPoolsCount;
        addedRewards = new uint256[](_rewardPoolsCount);
        for (uint256 i = 0; i < _rewardPoolsCount; ++i) {
            if (rewardPools[i].rewardToken == address(bentCVX)) {
                addedRewards[i] =
                    (rewardPools[i].rewardRate * bentStreamDuration) /
                    1e36;
            } else {
                addedRewards[i] =
                    (rewardPools[i].rewardRate * votiumStreamDuration) /
                    1e36;
            }
        }
    }

    function _calcRewardDuration(uint256 windowLength, uint256 endRewardBlock)
        internal
        view
        returns (uint256)
    {

        uint256 startBlock = endRewardBlock > lastRewardBlock + windowLength
            ? endRewardBlock - windowLength
            : lastRewardBlock;
        uint256 endBlock = block.number > endRewardBlock
            ? endRewardBlock
            : block.number;
        return endBlock > startBlock ? endBlock - startBlock : 0;
    }

    function _updateUserRewardDebt() internal {

        uint256 _rewardPoolsCount = rewardPoolsCount;
        for (uint256 i = 0; i < _rewardPoolsCount; ++i) {
            if (rewardPools[i].rewardToken != address(0)) {
                userRewardDebt[i][msg.sender] =
                    (balanceOf[msg.sender] * rewardPools[i].accRewardPerShare) /
                    1e36;
            }
        }
    }

    function _claim(uint256 pid) internal returns (uint256 claimAmount) {

        claimAmount = userPendingRewards[pid][msg.sender];
        if (claimAmount > 0) {
            IERC20Upgradeable(rewardPools[pid].rewardToken).safeTransfer(
                msg.sender,
                claimAmount
            );
            rewardPools[pid].reserves -= claimAmount;
            userPendingRewards[pid][msg.sender] = 0;
        }
    }

    function _mint(address _user, uint256 _amount) internal {

        balanceOf[_user] += _amount;
        totalSupply += _amount;

        userLocks[_user][currentEpoch()] += _amount;
    }

    function _burn(address _user, uint256 _amount) internal {

        balanceOf[_user] -= _amount;
        totalSupply -= _amount;
    }
}