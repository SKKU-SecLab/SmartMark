


pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity 0.6.12;


contract OwnableData {

    address public owner;
    address public pendingOwner;
}

contract Ownable is OwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address newOwner, bool direct, bool renounce) public onlyOwner {

        if (direct) {
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {

        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}



pragma solidity ^0.6.0;

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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.0;

interface IVStrike {

    function mint(address recipient, uint256 amount) external returns (bool);

    function burnFrom(address account, uint256 amount) external;

}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;




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



pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}



pragma solidity ^0.6.0;

interface IStrikeBoostFarm {

    function move(uint256 pid, address sender, address recipient, uint256 amount) external;

}



pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}



pragma solidity ^0.6.2;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}



pragma solidity ^0.6.2;


interface IBoostToken is IERC721Enumerable {

    function updateStakeTime(uint tokenId, bool isStake) external;


    function getTokenOwner(uint tokenId) external view returns(address);

}



pragma solidity 0.6.12;











contract StrikeBoostFarm is IStrikeBoostFarm, Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 pendingAmount; // non-eligible lp amount for reward
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 depositedDate; // Latest deposited date
        uint256[] boostFactors;
        uint256 boostRewardDebt; // Boost Reward debt. See explanation below.
        uint256 boostedDate; // Latest boosted date
        uint256 accBoostReward;
        uint256 accBaseReward;
    }
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. STRIKEs to distribute per block.
        uint256 lastRewardBlock; // Last block number that STRIKEs distribution occurs.
        uint256 accRewardPerShare; // Accumulated STRIKEs per share, times 1e12. See below.
        uint256 totalBoostCount; // Total valid boosted accounts count.
        uint256 rewardEligibleSupply; // total LP supply of users which staked boost token.
    }
    address public strk;
    address public vStrk;
    address public rewardToken;
    uint256 public bonusEndBlock;
    uint256 public rewardPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 10;
    uint256 public constant VSTRK_RATE = 10;
    PoolInfo[] private poolInfo;
    uint256 private lpSupplyOfStrikePool;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public claimBaseRewardTime = 1 days;
    uint256 public unstakableTime = 2 days;
    uint256 public initialBoostMultiplier = 20;
    uint256 public boostMultiplierFactor = 10;

    uint16 public minimumValidBoostCount = 1;
    uint16 public maximumBoostCount = 20;
    IBoostToken public boostFactor;
    mapping (uint256 => bool) public isBoosted;
    uint256 public claimBoostRewardTime = 30 days;
    mapping(uint256 => address[]) private boostedUsers;

    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 private accMulFactor = 1e12;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event ClaimBaseRewards(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event ClaimBoostRewards(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event Boost(address indexed user, uint256 indexed pid, uint256 tokenId);
    event UnBoost(address indexed user, uint256 indexed pid, uint256 tokenId);

    constructor(
        address _strk,
        address _rewardToken,
        address _vStrk,
        address _boost,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) public {
        strk = _strk;
        rewardToken = _rewardToken;
        vStrk = _vStrk;
        boostFactor = IBoostToken(_boost);
        rewardPerBlock = _rewardPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }


    function getPoolInfo(uint _pid) external view returns (
        IERC20 lpToken,
        uint256 lpSupply,
        uint256 allocPoint,
        uint256 lastRewardBlock,
        uint accRewardPerShare,
        uint totalBoostCount,
        uint256 rewardEligibleSupply
    ) {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 amount;
        if (strk == address(pool.lpToken)) {
            amount = lpSupplyOfStrikePool;
        } else {
            amount = pool.lpToken.balanceOf(address(this));
        }
        return (
            pool.lpToken,
            amount,
            pool.allocPoint,
            pool.lastRewardBlock,
            pool.accRewardPerShare,
            pool.totalBoostCount,
            pool.rewardEligibleSupply
        );
    }

    function getUserInfo(uint256 _pid, address _user) external view returns(
        uint256 amount,
        uint256 pendingAmount,
        uint256 rewardDebt,
        uint256 depositedDate,
        uint256[] memory boostFactors,
        uint256 boostRewardDebt,
        uint256 boostedDate,
        uint256 accBoostReward,
        uint256 accBaseReward
    ) {

        UserInfo storage user = userInfo[_pid][_user];

        return (
            user.amount,
            user.pendingAmount,
            user.rewardDebt,
            user.depositedDate,
            user.boostFactors,
            user.boostRewardDebt,
            user.boostedDate,
            user.accBoostReward,
            user.accBaseReward
        );
    }

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0,
                totalBoostCount: 0,
                rewardEligibleSupply: 0
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setRewardPerBlock(
        uint256 speed
    ) public onlyOwner {

        rewardPerBlock = speed;
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _to.sub(bonusEndBlock)
                );
        }
    }

    function getValidBoostFactors(uint256 userBoostFactors) internal view returns (uint256) {

        uint256 validBoostFactors = userBoostFactors > minimumValidBoostCount ? userBoostFactors - minimumValidBoostCount : 0;

        return validBoostFactors;
    }

    function getBoostMultiplier(uint256 boostFactorCount) internal view returns (uint256) {

        if (boostFactorCount <= minimumValidBoostCount) {
            return 0;
        }
        uint256 initBoostCount = boostFactorCount.sub(minimumValidBoostCount + 1);

        return initBoostCount.mul(boostMultiplierFactor).add(initialBoostMultiplier);
    }

    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;

        if (block.number > pool.lastRewardBlock && pool.rewardEligibleSupply > 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward =
                multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accRewardPerShare = accRewardPerShare.add(
                reward.mul(accMulFactor).div(pool.rewardEligibleSupply)
            );
        }
        uint256 boostMultiplier = getBoostMultiplier(user.boostFactors.length);
        uint256 baseReward = user.amount.mul(accRewardPerShare).div(accMulFactor).sub(user.rewardDebt);
        uint256 boostReward = boostMultiplier.mul(baseReward).div(100).add(user.accBoostReward).sub(user.boostRewardDebt);
        return baseReward.add(boostReward).add(user.accBaseReward);
    }

    function pendingBaseReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;

        if (block.number > pool.lastRewardBlock && pool.rewardEligibleSupply > 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward =
                multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accRewardPerShare = accRewardPerShare.add(
                reward.mul(accMulFactor).div(pool.rewardEligibleSupply)
            );
        }

        uint256 newReward = user.amount.mul(accRewardPerShare).div(accMulFactor).sub(user.rewardDebt);
        return newReward.add(user.accBaseReward);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        if (pool.rewardEligibleSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward =
            multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        pool.accRewardPerShare = pool.accRewardPerShare.add(
            reward.mul(accMulFactor).div(pool.rewardEligibleSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function checkRewardEligible(uint boost) internal view returns(bool) {

        if (boost >= minimumValidBoostCount) {
            return true;
        }

        return false;
    }

    function checkRewardClaimEligible(uint depositedTime) internal view returns(bool) {

        if (block.timestamp - depositedTime > claimBaseRewardTime) {
            return true;
        }

        return false;
    }

    function _claimBaseRewards(uint256 _pid, address _user) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        bool claimEligible = checkRewardClaimEligible(user.depositedDate);

        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 boostMultiplier = getBoostMultiplier(user.boostFactors.length);

        uint256 baseReward = user.amount.mul(accRewardPerShare).div(accMulFactor).sub(user.rewardDebt);
        uint256 boostReward = boostMultiplier.mul(baseReward).div(100);
        user.accBoostReward = user.accBoostReward.add(boostReward);
        uint256 rewards;

        if (claimEligible && baseReward > 0) {
            rewards = baseReward.add(user.accBaseReward);
            safeRewardTransfer(_user, rewards);
            user.accBaseReward = 0;
        } else {
            rewards = 0;
            user.accBaseReward = baseReward.add(user.accBaseReward);
        }

        emit ClaimBaseRewards(_user, _pid, rewards);

        user.depositedDate = block.timestamp;
    }

    function claimBaseRewards(uint256 _pid) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        bool claimEligible = checkRewardClaimEligible(user.depositedDate);
        require(claimEligible == true, "not claim eligible");
        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
    }

    function deposit(uint256 _pid, uint256 _amount) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        bool rewardEligible = checkRewardEligible(user.boostFactors.length);

        _claimBaseRewards(_pid, msg.sender);

        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        if (strk == address(pool.lpToken)) {
            lpSupplyOfStrikePool = lpSupplyOfStrikePool.add(_amount);
        }
        if (rewardEligible) {
            user.amount = user.amount.add(user.pendingAmount).add(_amount);
            pool.rewardEligibleSupply = pool.rewardEligibleSupply.add(_amount);
            user.pendingAmount = 0;
        } else {
            user.pendingAmount = user.pendingAmount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
        if (_amount > 0) {
            IVStrike(vStrk).mint(msg.sender, _amount.mul(VSTRK_RATE));
        }
        user.boostedDate = block.timestamp;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount + user.pendingAmount >= _amount, "withdraw: not good");
        require(block.timestamp - user.depositedDate > unstakableTime, "not eligible to withdraw");
        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);
        if (user.amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.rewardEligibleSupply = pool.rewardEligibleSupply.sub(_amount);
        } else {
            user.pendingAmount = user.pendingAmount.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
        user.accBoostReward = 0;
        user.boostRewardDebt = 0;
        user.boostedDate = block.timestamp;
        if (strk == address(pool.lpToken)) {
            lpSupplyOfStrikePool = lpSupplyOfStrikePool.sub(_amount);
        }
        if (_amount > 0) {
            IVStrike(vStrk).burnFrom(msg.sender, _amount.mul(VSTRK_RATE));
        }
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function move(uint256 _pid, address _sender, address _recipient, uint256 _vstrikeAmount) override external nonReentrant {

        require(vStrk == msg.sender);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage sender = userInfo[_pid][_sender];
        UserInfo storage recipient = userInfo[_pid][_recipient];

        uint256 amount = _vstrikeAmount.div(VSTRK_RATE);

        require(sender.amount + sender.pendingAmount >= amount, "transfer exceeds amount");
        require(block.timestamp - sender.depositedDate > unstakableTime, "not eligible to undtake");
        updatePool(_pid);
        _claimBaseRewards(_pid, _sender);

        if (sender.amount > 0) {
            sender.amount = sender.amount.sub(amount);
        } else {
            sender.pendingAmount = sender.pendingAmount.sub(amount);
        }
        sender.rewardDebt = sender.amount.mul(pool.accRewardPerShare).div(accMulFactor);
        sender.boostedDate = block.timestamp;
        sender.accBoostReward = 0;
        sender.boostRewardDebt = 0;

        bool claimEligible = checkRewardClaimEligible(recipient.depositedDate);
        bool rewardEligible = checkRewardEligible(recipient.boostFactors.length);

        if (claimEligible && rewardEligible) {
            _claimBaseRewards(_pid, _recipient);
        }

        if (rewardEligible) {
            recipient.amount = recipient.amount.add(recipient.pendingAmount).add(amount);
            recipient.pendingAmount = 0;
        } else {
            recipient.pendingAmount = recipient.pendingAmount.add(amount);
        }
        recipient.rewardDebt = recipient.amount.mul(pool.accRewardPerShare).div(accMulFactor);
        recipient.boostedDate = block.timestamp;
    }

    function emergencyWithdraw(uint256 _pid) external nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount.add(user.pendingAmount));
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        if (user.amount > 0) {
            pool.rewardEligibleSupply = pool.rewardEligibleSupply.sub(user.amount);
        }
        user.amount = 0;
        user.pendingAmount = 0;
        user.rewardDebt = 0;
        user.boostRewardDebt = 0;
        user.accBoostReward = 0;
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal {

        uint256 availableBal = IERC20(rewardToken).balanceOf(address(this));

        if (strk == rewardToken) {
            if (availableBal > lpSupplyOfStrikePool) {
                availableBal = availableBal - lpSupplyOfStrikePool;
            } else {
                availableBal = 0;
            }
        }

        if (_amount > availableBal) {
            IERC20(rewardToken).transfer(_to, availableBal);
        } else {
            IERC20(rewardToken).transfer(_to, _amount);
        }
    }

    function setAccMulFactor(uint256 _factor) external onlyOwner {

        accMulFactor = _factor;
    }

    function updateInitialBoostMultiplier(uint _initialBoostMultiplier) external onlyOwner {

        initialBoostMultiplier = _initialBoostMultiplier;
    }

    function updatedBoostMultiplierFactor(uint _boostMultiplierFactor) external onlyOwner {

        boostMultiplierFactor = _boostMultiplierFactor;
    }

    function updateRewardToken(address _reward) external onlyOwner {

        rewardToken = _reward;
    }

    function updateClaimBaseRewardTime(uint256 _claimBaseRewardTime) external onlyOwner {

        claimBaseRewardTime = _claimBaseRewardTime;
    }

    function updateUnstakableTime(uint256 _unstakableTime) external onlyOwner {

        unstakableTime = _unstakableTime;
    }

    function getBoostedUserCount(uint256 _pid) external view returns(uint256) {

        return boostedUsers[_pid].length;
    }

    function pendingBoostReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;

        if (block.number > pool.lastRewardBlock && pool.rewardEligibleSupply > 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward =
                multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accRewardPerShare = accRewardPerShare.add(
                reward.mul(accMulFactor).div(pool.rewardEligibleSupply)
            );
        }

        uint256 boostMultiplier = getBoostMultiplier(user.boostFactors.length);
        uint256 baseReward = user.amount.mul(accRewardPerShare).div(accMulFactor).sub(user.rewardDebt);
        uint256 boostReward = boostMultiplier.mul(baseReward).div(100);
        return user.accBoostReward.sub(user.boostRewardDebt).add(boostReward);
    }

    function getTotalPendingBoostRewards() external view returns (uint256) {

        uint256 totalRewards;
        for (uint i; i < poolInfo.length; i++) {
            PoolInfo storage pool = poolInfo[i];
            uint256 accRewardPerShare = pool.accRewardPerShare;

            for (uint j; j < boostedUsers[i].length; j++) {
                UserInfo storage user = userInfo[i][boostedUsers[i][j]];

                if (block.number > pool.lastRewardBlock && pool.rewardEligibleSupply > 0) {
                    uint256 multiplier =
                        getMultiplier(pool.lastRewardBlock, block.number);
                    uint256 reward =
                        multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(
                            totalAllocPoint
                        );
                    accRewardPerShare = accRewardPerShare.add(
                        reward.mul(accMulFactor).div(pool.rewardEligibleSupply)
                    );
                }
                uint256 boostMultiplier = getBoostMultiplier(user.boostFactors.length);
                uint256 baseReward = user.amount.mul(accRewardPerShare).div(accMulFactor).sub(user.rewardDebt);
                uint256 initBoostReward = boostMultiplier.mul(baseReward).div(100);
                uint256 boostReward = user.accBoostReward.sub(user.boostRewardDebt).add(initBoostReward);
                totalRewards = totalRewards.add(boostReward);
            }
        }

        return totalRewards;
    }

    function getClaimablePendingBoostRewards() external view returns (uint256) {

        uint256 totalRewards;
        for (uint i; i < poolInfo.length; i++) {
            PoolInfo storage pool = poolInfo[i];
            uint256 accRewardPerShare = pool.accRewardPerShare;

            for (uint j; j < boostedUsers[i].length; j++) {
                UserInfo storage user = userInfo[i][boostedUsers[i][j]];

                if (block.timestamp - user.boostedDate >= claimBoostRewardTime) {
                    if (block.number > pool.lastRewardBlock && pool.rewardEligibleSupply > 0) {
                        uint256 multiplier =
                            getMultiplier(pool.lastRewardBlock, block.number);
                        uint256 reward =
                            multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(
                                totalAllocPoint
                            );
                        accRewardPerShare = accRewardPerShare.add(
                            reward.mul(accMulFactor).div(pool.rewardEligibleSupply)
                        );
                    }
                    uint256 boostMultiplier = getBoostMultiplier(user.boostFactors.length);
                    uint256 baseReward = user.amount.mul(accRewardPerShare).div(accMulFactor).sub(user.rewardDebt);
                    uint256 initBoostReward = boostMultiplier.mul(baseReward).div(100);
                    uint256 boostReward = user.accBoostReward.sub(user.boostRewardDebt).add(initBoostReward);
                    totalRewards = totalRewards.add(boostReward);
                }
            }
        }

        return totalRewards;
    }

    function claimBoostReward(uint256 _pid) external {

        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.timestamp - user.boostedDate > claimBoostRewardTime, "not eligible to claim");
        PoolInfo storage pool = poolInfo[_pid];
        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
        uint256 boostReward = user.accBoostReward.sub(user.boostRewardDebt);
        safeRewardTransfer(msg.sender, boostReward);
        emit ClaimBoostRewards(msg.sender, _pid, boostReward);
        user.boostRewardDebt = user.boostRewardDebt.add(boostReward);
        user.boostedDate = block.timestamp;
    }

    function _boost(uint256 _pid, uint _tokenId) internal {

        require (isBoosted[_tokenId] == false, "already boosted");

        boostFactor.transferFrom(msg.sender, address(this), _tokenId);
        boostFactor.updateStakeTime(_tokenId, true);

        isBoosted[_tokenId] = true;

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (user.pendingAmount > 0) {
            user.amount = user.pendingAmount;
            pool.rewardEligibleSupply = pool.rewardEligibleSupply.add(user.amount);
            user.pendingAmount = 0;
        }
        user.boostFactors.push(_tokenId);
        pool.totalBoostCount = pool.totalBoostCount + 1;

        emit Boost(msg.sender, _pid, _tokenId);
    }

    function boost(uint256 _pid, uint _tokenId) external {

        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount + user.pendingAmount > 0, "no stake tokens");
        require(user.boostFactors.length + 1 <= maximumBoostCount);
        PoolInfo storage pool = poolInfo[_pid];
        if (user.boostFactors.length == 0) {
            boostedUsers[_pid].push(msg.sender);
        }
        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);

        _boost(_pid, _tokenId);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
        user.boostedDate = block.timestamp;
    }

    function boostPartially(uint _pid, uint tokenAmount) external {

        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount + user.pendingAmount > 0, "no stake tokens");
        require(user.boostFactors.length + tokenAmount <= maximumBoostCount);
        PoolInfo storage pool = poolInfo[_pid];
        if (user.boostFactors.length == 0) {
            boostedUsers[_pid].push(msg.sender);
        }
        uint256 ownerTokenCount = boostFactor.balanceOf(msg.sender);
        require(tokenAmount <= ownerTokenCount);
        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);

        for (uint i; i < tokenAmount; i++) {
            uint _tokenId = boostFactor.tokenOfOwnerByIndex(msg.sender, 0);

            _boost(_pid, _tokenId);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
        user.boostedDate = block.timestamp;
    }

    function boostAll(uint _pid, uint256[] memory _tokenIds) external {

        uint256 tokenIdLength = _tokenIds.length;
        require(tokenIdLength > 0, "");
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount + user.pendingAmount > 0, "no stake tokens");
        uint256 ownerTokenCount = boostFactor.balanceOf(msg.sender);
        require(ownerTokenCount > 0, "");
        PoolInfo storage pool = poolInfo[_pid];
        if (user.boostFactors.length == 0) {
            boostedUsers[_pid].push(msg.sender);
        }
        uint256 availableTokenAmount = maximumBoostCount - user.boostFactors.length;
        require(availableTokenAmount > 0, "overflow maximum boosting");

        if (tokenIdLength < availableTokenAmount) {
            availableTokenAmount = tokenIdLength;
        }
        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);

        for (uint256 i; i < availableTokenAmount; i++) {
            _boost(_pid, _tokenIds[i]);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
        user.boostedDate = block.timestamp;
    }

    function _unBoost(uint _pid, uint _tokenId) internal {

        require (isBoosted[_tokenId] == true);

        boostFactor.transferFrom(address(this), msg.sender, _tokenId);
        boostFactor.updateStakeTime(_tokenId, false);

        isBoosted[_tokenId] = false;

        emit UnBoost(msg.sender, _pid, _tokenId);
    }

    function unBoost(uint _pid, uint _tokenId) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.boostFactors.length > 0, "");
        uint factorLength = user.boostFactors.length;

        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);

        _unBoost(_pid, _tokenId);
        uint dfId; // will be deleted factor index
        for (uint j; j < factorLength; j++) {
            if (_tokenId == user.boostFactors[j]) {
                dfId = j;
                break;
            }
        }
        user.boostFactors[dfId] = user.boostFactors[factorLength - 1];
        user.boostFactors.pop();
        pool.totalBoostCount = pool.totalBoostCount - 1;

        user.boostedDate = block.timestamp;
        user.accBoostReward = 0;
        user.boostRewardDebt = 0;

        uint boostedUserCount = boostedUsers[_pid].length;
        if (user.boostFactors.length == 0) {
            user.pendingAmount = user.amount;
            user.amount = 0;
            pool.rewardEligibleSupply = pool.rewardEligibleSupply.sub(user.pendingAmount);

            uint index;
            for (uint j; j < boostedUserCount; j++) {
                if (address(msg.sender) == address(boostedUsers[_pid][j])) {
                    index = j;
                    break;
                }
            }
            boostedUsers[_pid][index] = boostedUsers[_pid][boostedUserCount - 1];
            boostedUsers[_pid].pop();
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
    }

    function unBoostPartially(uint _pid, uint tokenAmount) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.boostFactors.length > 0, "");
        require(tokenAmount <= user.boostFactors.length, "");
        uint factorLength = user.boostFactors.length;

        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);

        for (uint i = 1; i <= tokenAmount; i++) {
            uint index = factorLength - i;
            uint _tokenId = user.boostFactors[index];

            _unBoost(_pid, _tokenId);
            user.boostFactors.pop();
            pool.totalBoostCount = pool.totalBoostCount - 1;
        }
        user.boostedDate = block.timestamp;
        user.accBoostReward = 0;
        user.boostRewardDebt = 0;

        uint boostedUserCount = boostedUsers[_pid].length;
        if (user.boostFactors.length == 0) {
            user.pendingAmount = user.amount;
            user.amount = 0;
            pool.rewardEligibleSupply = pool.rewardEligibleSupply.sub(user.pendingAmount);

            uint index;
            for (uint j; j < boostedUserCount; j++) {
                if (address(msg.sender) == address(boostedUsers[_pid][j])) {
                    index = j;
                    break;
                }
            }
            boostedUsers[_pid][index] = boostedUsers[_pid][boostedUserCount - 1];
            boostedUsers[_pid].pop();
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
    }

    function unBoostAll(uint _pid) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint factorLength = user.boostFactors.length;
        require(factorLength > 0, "");

        updatePool(_pid);
        _claimBaseRewards(_pid, msg.sender);

        for (uint i = 0; i < factorLength; i++) {
            uint _tokenId = user.boostFactors[i];
            _unBoost(_pid, _tokenId);
        }
        delete user.boostFactors;
        pool.totalBoostCount = pool.totalBoostCount - factorLength;
        user.boostedDate = block.timestamp;

        user.accBoostReward = 0;
        user.boostRewardDebt = 0;

        uint boostedUserCount = boostedUsers[_pid].length;
        if (user.boostFactors.length == 0) {
            user.pendingAmount = user.amount;
            user.amount = 0;
            pool.rewardEligibleSupply = pool.rewardEligibleSupply.sub(user.pendingAmount);

            uint index;
            for (uint j; j < boostedUserCount; j++) {
                if (address(msg.sender) == address(boostedUsers[_pid][j])) {
                    index = j;
                    break;
                }
            }
            boostedUsers[_pid][index] = boostedUsers[_pid][boostedUserCount - 1];
            boostedUsers[_pid].pop();
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(accMulFactor);
    }

    function setBoostFactor(
        address _address
    ) external onlyOwner {

        boostFactor = IBoostToken(_address);
    }

    function updateClaimBoostRewardTime(uint256 _claimBoostRewardTime) external onlyOwner {

        claimBoostRewardTime = _claimBoostRewardTime;
    }

    function updateMinimumValidBoostCount(uint16 _count) external onlyOwner {

        minimumValidBoostCount = _count;
    }

    function updateMaximumBoostCount(uint16 _count) external onlyOwner {

        maximumBoostCount = _count;
    }
}