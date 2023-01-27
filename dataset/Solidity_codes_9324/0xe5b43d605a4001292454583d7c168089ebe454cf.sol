
pragma solidity ^0.8.3;

interface IStakingFactory {

    event PoolCreated(address indexed sender, address indexed newPool);

    function createPool(
        address _stakingToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _bufferBlocks
    ) external returns (address);


    function ours(address _a) external view returns (bool);


    function listCount() external view returns (uint256);


    function listAt(uint256 _idx) external view returns (address);

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
}// MIT

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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}//MIT

pragma solidity ^0.8.3;


struct RewardSettings {
    IERC20 rewardToken;
    uint256 totalRewards;
}

struct PendingRewards {
    IERC20 rewardToken;
    uint256 pendingReward;
}

struct EarnedRewards {
    IERC20 rewardToken;
    uint256 earnedReward;
}

interface IStakingRewards {

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);
    event UnclaimedRecovered(address token, uint256 amount);
    event RewardsExtended(uint256 newEndBlock);

    function deposit(uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    function emergencyWithdraw() external;


    function claimRewards() external;


    function claimReward(uint256 _rid) external;


    function add(IERC20 _rewardToken, uint256 _totalRewards) external;


    function addMulti(RewardSettings[] memory _poolSettings) external;


    function recoverERC20(address _tokenAddress, uint256 _tokenAmount) external;


    function recoverUnclaimedRewards() external;


    function extendRewards(
        uint256 _newEndBlock,
        uint256[] memory _newTotalRewards
    ) external;


    function rewardsLength() external view returns (uint256);


    function balanceOf(address _user) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function getPendingRewards(uint256 _rid, address _user)
        external
        view
        returns (uint256);


    function getAllPendingRewards(address _user)
        external
        view
        returns (PendingRewards[] memory);


    function getRewardsForDuration()
        external
        view
        returns (RewardSettings[] memory);


    function earned(address _user)
        external
        view
        returns (EarnedRewards[] memory);

}//MIT

pragma solidity ^0.8.3;


contract StakingRewards is Ownable, ReentrancyGuard, IStakingRewards {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    modifier notStopped {

        require(!isStopped, "Rewards have stopped");
        _;
    }

    modifier onlyRewardsPeriod {

        require(block.number < endBlock, "Rewards period ended");
        _;
    }

    struct RewardInfo {
        IERC20 rewardToken;
        uint256 lastRewardBlock; // Last block number that reward token distribution occurs.
        uint256 rewardPerBlock; // How many reward tokens to distribute per block.
        uint256 totalRewards;
        uint256 accTokenPerShare; // Accumulated token per share, times 1e18.
    }
    RewardInfo[] private rewardInfo;

    IERC20 public immutable stakingToken; // token to be staked for rewards

    uint256 public immutable startBlock; // block number when reward period starts
    uint256 public endBlock; // block number when reward period ends

    uint256 public immutable bufferBlocks;

    bool public isStopped;

    mapping(address => uint256) private userAmount;
    mapping(uint256 => mapping(address => uint256)) private rewardDebt; // rewardDebt[rewardId][user] = N
    mapping(uint256 => mapping(address => uint256)) private rewardPaid; // rewardPaid[rewardId][user] = N

    EnumerableSet.AddressSet private pooledTokens;

    uint8 private constant MAX_POOLED_TOKENS = 5;

    constructor(
        address _stakingToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _bufferBlocks
    ) {
        _startBlock = (_startBlock == 0) ? block.number : _startBlock;

        require(
            _endBlock > block.number && _endBlock > _startBlock,
            "Invalid end block"
        );

        stakingToken = IERC20(_stakingToken);
        startBlock = _startBlock;
        endBlock = _endBlock;
        bufferBlocks = _bufferBlocks;
    }

    function deposit(uint256 _amount)
        external
        override
        notStopped
        nonReentrant
    {

        updateAllRewards();

        uint256 _currentAmount = userAmount[msg.sender];
        uint256 _balanceBefore = stakingToken.balanceOf(address(this));

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        _amount = stakingToken.balanceOf(address(this)) - _balanceBefore;

        uint256 _newUserAmount = _currentAmount + _amount;

        if (_currentAmount > 0) {
            for (uint256 i = 0; i < rewardInfo.length; i++) {
                RewardInfo memory _reward = rewardInfo[i];

                uint256 _pending =
                    ((_currentAmount * _reward.accTokenPerShare) / 1e18) -
                        rewardDebt[i][msg.sender];

                rewardDebt[i][msg.sender] =
                    (_newUserAmount * _reward.accTokenPerShare) /
                    1e18;

                rewardPaid[i][msg.sender] += _pending;

                _reward.rewardToken.safeTransfer(msg.sender, _pending);
            }
        } else {
            for (uint256 i = 0; i < rewardInfo.length; i++) {
                RewardInfo memory _reward = rewardInfo[i];

                rewardDebt[i][msg.sender] =
                    (_amount * _reward.accTokenPerShare) /
                    1e18;
            }
        }

        userAmount[msg.sender] = _newUserAmount;

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external override nonReentrant {

        updateAllRewards();

        uint256 _currentAmount = userAmount[msg.sender];

        require(_currentAmount >= _amount, "withdraw: not good");

        uint256 newUserAmount = _currentAmount - _amount;

        if (!isStopped) {
            for (uint256 i = 0; i < rewardInfo.length; i++) {
                RewardInfo memory _reward = rewardInfo[i];

                uint256 _pending =
                    ((_currentAmount * _reward.accTokenPerShare) / 1e18) -
                        rewardDebt[i][msg.sender];

                rewardDebt[i][msg.sender] =
                    (newUserAmount * _reward.accTokenPerShare) /
                    1e18;

                rewardPaid[i][msg.sender] += _pending;

                _reward.rewardToken.safeTransfer(msg.sender, _pending);
            }
        }

        userAmount[msg.sender] = newUserAmount;

        stakingToken.safeTransfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() external override nonReentrant {

        for (uint256 i = 0; i < rewardInfo.length; i++) {
            rewardDebt[i][msg.sender] = 0;
        }

        stakingToken.safeTransfer(msg.sender, userAmount[msg.sender]);
        userAmount[msg.sender] = 0;
        emit EmergencyWithdraw(msg.sender, userAmount[msg.sender]);
    }

    function claimRewards() external override notStopped nonReentrant {

        for (uint256 i = 0; i < rewardInfo.length; i++) _claimReward(i);
    }

    function claimReward(uint256 _rid)
        external
        override
        notStopped
        nonReentrant
    {

        _claimReward(_rid);
    }

    function add(IERC20 _rewardToken, uint256 _totalRewards)
        external
        override
        nonReentrant
        onlyOwner
        onlyRewardsPeriod
    {

        require(rewardInfo.length < MAX_POOLED_TOKENS, "Pool is full");
        _add(_rewardToken, _totalRewards);
    }

    function addMulti(RewardSettings[] memory _rewardSettings)
        external
        override
        nonReentrant
        onlyOwner
        onlyRewardsPeriod
    {

        require(
            rewardInfo.length + _rewardSettings.length < MAX_POOLED_TOKENS,
            "Pool is full"
        );
        for (uint8 i = 0; i < _rewardSettings.length; i++)
            _add(
                _rewardSettings[i].rewardToken,
                _rewardSettings[i].totalRewards
            );
    }

    function recoverERC20(address _tokenAddress, uint256 _tokenAmount)
        external
        override
        onlyOwner
    {

        require(
            _tokenAddress != address(stakingToken) &&
                !pooledTokens.contains(_tokenAddress),
            "Cannot recover"
        );
        IERC20(_tokenAddress).safeTransfer(msg.sender, _tokenAmount);
        emit Recovered(_tokenAddress, _tokenAmount);
    }

    function recoverUnclaimedRewards() external override onlyOwner notStopped {

        require(
            block.number > endBlock + bufferBlocks,
            "Not allowed to reclaim"
        );
        isStopped = true;
        for (uint8 i = 0; i < rewardInfo.length; i++) {
            IERC20 _token = IERC20(rewardInfo[i].rewardToken);
            uint256 _amount = _token.balanceOf(address(this));
            rewardInfo[i].lastRewardBlock = block.number;
            _token.safeTransfer(msg.sender, _amount);
            emit UnclaimedRecovered(address(_token), _amount);
        }
    }

    function extendRewards(
        uint256 _newEndBlock,
        uint256[] memory _newTotalRewards
    ) external override onlyOwner notStopped nonReentrant {

        require(block.number > endBlock, "Rewards not ended");
        require(_newEndBlock > block.number, "Invalid end block");
        require(
            _newTotalRewards.length == rewardInfo.length,
            "Pool length mismatch"
        );

        for (uint8 i = 0; i < _newTotalRewards.length; i++) {
            updateReward(i);
            uint256 _balanceBefore =
                IERC20(rewardInfo[i].rewardToken).balanceOf(address(this));
            IERC20(rewardInfo[i].rewardToken).safeTransferFrom(
                msg.sender,
                address(this),
                _newTotalRewards[i]
            );
            _newTotalRewards[i] =
                IERC20(rewardInfo[i].rewardToken).balanceOf(address(this)) -
                _balanceBefore;
            uint256 _rewardPerBlock =
                _newTotalRewards[i] / (_newEndBlock - block.number);
            rewardInfo[i].rewardPerBlock = _rewardPerBlock;
            rewardInfo[i].totalRewards += _newTotalRewards[i];
        }

        endBlock = _newEndBlock;

        emit RewardsExtended(_newEndBlock);
    }

    function rewardsLength() external view override returns (uint256) {

        return rewardInfo.length;
    }

    function balanceOf(address _user) external view override returns (uint256) {

        return userAmount[_user];
    }

    function totalSupply() external view override returns (uint256) {

        return stakingToken.balanceOf(address(this));
    }

    function getPendingRewards(uint256 _rid, address _user)
        external
        view
        override
        returns (uint256)
    {

        return _getPendingRewards(_rid, _user);
    }

    function getAllPendingRewards(address _user)
        external
        view
        override
        returns (PendingRewards[] memory)
    {

        PendingRewards[] memory _pendingRewards =
            new PendingRewards[](rewardInfo.length);
        for (uint8 i = 0; i < rewardInfo.length; i++) {
            _pendingRewards[i] = PendingRewards({
                rewardToken: rewardInfo[i].rewardToken,
                pendingReward: _getPendingRewards(i, _user)
            });
        }
        return _pendingRewards;
    }

    function earned(address _user)
        external
        view
        override
        returns (EarnedRewards[] memory)
    {

        EarnedRewards[] memory earnedRewards =
            new EarnedRewards[](rewardInfo.length);
        for (uint8 i = 0; i < rewardInfo.length; i++) {
            earnedRewards[i] = EarnedRewards({
                rewardToken: rewardInfo[i].rewardToken,
                earnedReward: rewardPaid[i][_user] +
                    _getPendingRewards(i, _user)
            });
        }
        return earnedRewards;
    }

    function getRewardsForDuration()
        external
        view
        override
        returns (RewardSettings[] memory)
    {

        RewardSettings[] memory _rewardSettings =
            new RewardSettings[](rewardInfo.length);
        for (uint8 i = 0; i < rewardInfo.length; i++) {
            _rewardSettings[i] = RewardSettings({
                rewardToken: rewardInfo[i].rewardToken,
                totalRewards: rewardInfo[i].totalRewards
            });
        }
        return _rewardSettings;
    }

    function updateReward(uint256 _rid) public {

        RewardInfo storage _reward = rewardInfo[_rid];

        if (block.number <= _reward.lastRewardBlock) {
            return;
        }
        uint256 _lpSupply = stakingToken.balanceOf(address(this));

        if (_lpSupply == 0) {
            _reward.lastRewardBlock = block.number;
            return;
        }

        uint256 _tokenReward = getMultiplier(_reward) * _reward.rewardPerBlock;

        _reward.accTokenPerShare += (_tokenReward * 1e18) / _lpSupply;

        _reward.lastRewardBlock = block.number;
    }

    function updateAllRewards() public {

        uint256 _length = rewardInfo.length;
        for (uint256 pid = 0; pid < _length; pid++) {
            updateReward(pid);
        }
    }

    function getMultiplier(RewardInfo memory _reward)
        internal
        view
        returns (uint256 _multiplier)
    {

        uint256 _lastBlock =
            (block.number > endBlock) ? endBlock : block.number;
        _multiplier = (_lastBlock > _reward.lastRewardBlock)
            ? _lastBlock - _reward.lastRewardBlock
            : 0;
    }

    function _getPendingRewards(uint256 _rid, address _user)
        internal
        view
        returns (uint256)
    {

        if (isStopped) return 0;

        RewardInfo storage _reward = rewardInfo[_rid];

        uint256 _amount = userAmount[_user];
        uint256 _debt = rewardDebt[_rid][_user];

        uint256 _rewardPerBlock = _reward.rewardPerBlock;

        uint256 _accTokenPerShare = _reward.accTokenPerShare;

        uint256 _lpSupply = stakingToken.balanceOf(address(this));

        if (block.number > _reward.lastRewardBlock && _lpSupply != 0) {
            uint256 reward = getMultiplier(_reward) * _rewardPerBlock;
            _accTokenPerShare += ((reward * 1e18) / _lpSupply);
        }

        return ((_amount * _accTokenPerShare) / 1e18) - _debt;
    }

    function _add(IERC20 _rewardToken, uint256 _totalRewards) internal {

        require(
            address(_rewardToken) != address(stakingToken),
            "rewardToken = stakingToken"
        );
        require(!pooledTokens.contains(address(_rewardToken)), "pool exists");

        uint256 _balanceBefore = _rewardToken.balanceOf(address(this));
        _rewardToken.safeTransferFrom(msg.sender, address(this), _totalRewards);
        _totalRewards = _rewardToken.balanceOf(address(this)) - _balanceBefore;

        require(_totalRewards != 0, "No rewards");

        uint256 _lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;

        pooledTokens.add(address(_rewardToken));

        uint256 _rewardPerBlock = _totalRewards / (endBlock - _lastRewardBlock);

        rewardInfo.push(
            RewardInfo({
                rewardToken: _rewardToken,
                rewardPerBlock: _rewardPerBlock,
                totalRewards: _totalRewards,
                lastRewardBlock: _lastRewardBlock,
                accTokenPerShare: 0
            })
        );
    }

    function _claimReward(uint256 _rid) internal {

        updateReward(_rid);

        uint256 _amount = userAmount[msg.sender];

        uint256 _debt = rewardDebt[_rid][msg.sender];

        RewardInfo memory _reward = rewardInfo[_rid];

        uint256 pending = ((_amount * _reward.accTokenPerShare) / 1e18) - _debt;

        rewardPaid[_rid][msg.sender] += pending;

        rewardDebt[_rid][msg.sender] =
            (_amount * _reward.accTokenPerShare) /
            1e18;

        _reward.rewardToken.safeTransfer(msg.sender, pending);
    }
}//MIT

pragma solidity ^0.8.3;


contract StakingFactory is IStakingFactory {

    address[] private allPools;
    mapping(address => bool) private isOurs;

    function createPool(
        address _stakingToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _bufferBlocks
    ) external override returns (address listaddr) {

        listaddr = address(
            new StakingRewards(
                _stakingToken,
                _startBlock,
                _endBlock,
                _bufferBlocks
            )
        );

        StakingRewards(listaddr).transferOwnership(msg.sender);

        allPools.push(listaddr);
        isOurs[listaddr] = true;

        emit PoolCreated(msg.sender, listaddr);
    }

    function ours(address _a) external view override returns (bool) {

        return isOurs[_a];
    }

    function listCount() external view override returns (uint256) {

        return allPools.length;
    }

    function listAt(uint256 _idx) external view override returns (address) {

        require(_idx < allPools.length, "Index exceeds list length");
        return allPools[_idx];
    }
}