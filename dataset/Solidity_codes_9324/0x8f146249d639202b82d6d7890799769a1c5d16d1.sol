



pragma solidity 0.6.12;


contract BoringOwnableData {

    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address newOwner, bool direct, bool renounce) public onlyOwner {

        if (direct) {
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
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


pragma solidity 0.6.12;
library BoringMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {require((c = a - b) <= a, "BoringMath: Underflow");}

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {require(b == 0 || (c = a * b)/b == a, "BoringMath: Mul Overflow");}

    function to128(uint256 a) internal pure returns (uint128 c) {

        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }
    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }
    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}

library BoringMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {require((c = a - b) <= a, "BoringMath: Underflow");}

}

library BoringMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {require((c = a - b) <= a, "BoringMath: Underflow");}

}

library BoringMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {require((c = a - b) <= a, "BoringMath: Underflow");}

}


pragma solidity 0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

}


pragma solidity 0.6.12;


library BoringERC20 {

    function safeSymbol(IERC20 token) internal view returns(string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x95d89b41));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IERC20 token) internal view returns(string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x06fdde03));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IERC20 token) internal view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x313ce567));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x23b872dd, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
    }
}



pragma solidity 0.6.12;

interface IRewarder {

    using BoringERC20 for IERC20;
    function onSushiReward(uint256 pid, address user, address recipient, uint256 sushiAmount, uint256 newLpAmount) external;

    function pendingTokens(uint256 pid, address user, uint256 sushiAmount) external view returns (IERC20[] memory, uint256[] memory);

}




pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;





interface IMasterChefV2 {

    function lpToken(uint256 pid) external view returns (IERC20 _lpToken);

}

contract CloneRewarderTimeDual is IRewarder,  BoringOwnable{

    using BoringMath for uint256;
    using BoringMath128 for uint128;
    using BoringERC20 for IERC20;

    IERC20 public rewardToken1;
    IERC20 public rewardToken2;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt1;
        uint256 rewardDebt2;
        uint256 unpaidRewards1;
        uint256 unpaidRewards2;
    }

    struct PoolInfo {
        uint128 accToken1PerShare;
        uint128 accToken2PerShare;
        uint64 lastRewardTime;
    }

    mapping (uint256 => PoolInfo) public poolInfo;


    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    uint128 public rewardPerSecond1;
    uint128 public rewardPerSecond2;
    IERC20 public masterLpToken;
    uint256 private constant ACC_TOKEN_PRECISION = 1e12;

    address public immutable MASTERCHEF_V2;

    uint256 internal unlocked;
    modifier lock() {

        require(unlocked == 1, "LOCKED");
        unlocked = 2;
        _;
        unlocked = 1;
    }

    event LogOnReward(address indexed user, uint256 indexed pid, uint256 amount1, uint256 amount2, address indexed to);
    event LogUpdatePool(uint256 indexed pid, uint64 lastRewardTime, uint256 lpSupply, uint256 accToken1PerShare, uint256 accToken2PerShare);
    event LogRewardPerSecond(uint256 rewardPerSecond1, uint256 rewardPerSecond2);
    event LogInit(IERC20 rewardToken1, IERC20 rewardToken2, address owner, uint256 rewardPerSecond1, uint256 rewardPerSecond2, IERC20 indexed masterLpToken);

    constructor (address _MASTERCHEF_V2) public {
        MASTERCHEF_V2 = _MASTERCHEF_V2;
    }

    function init(bytes calldata data) public payable {

        require(rewardToken1 == IERC20(0), "Rewarder: already initialized");
        (rewardToken1, rewardToken2, owner, rewardPerSecond1, rewardPerSecond2, masterLpToken) = abi.decode(data, (IERC20, IERC20, address, uint128, uint128, IERC20));
        require(rewardToken1 != IERC20(0), "Rewarder: bad token");
        unlocked = 1;
        emit LogInit(rewardToken1, rewardToken2, owner, rewardPerSecond1, rewardPerSecond2, masterLpToken);
    }

    function onSushiReward (uint256 pid, address _user, address to, uint256, uint256 lpTokenAmount) onlyMCV2 lock override external {
        require(IMasterChefV2(MASTERCHEF_V2).lpToken(pid) == masterLpToken);

        PoolInfo memory pool = updatePool(pid);
        UserInfo memory _userInfo = userInfo[pid][_user];
        uint256 pending1;
        uint256 pending2;
        if (_userInfo.amount > 0) {
            pending1 =
                (_userInfo.amount.mul(pool.accToken1PerShare) / ACC_TOKEN_PRECISION).sub(
                    _userInfo.rewardDebt1
                ).add(_userInfo.unpaidRewards1);
            pending2 =
                (_userInfo.amount.mul(pool.accToken2PerShare) / ACC_TOKEN_PRECISION).sub(
                    _userInfo.rewardDebt2
                ).add(_userInfo.unpaidRewards2);

            uint256 balance1 = rewardToken1.balanceOf(address(this));
            uint256 balance2 = rewardToken2.balanceOf(address(this));

            if (pending1 > balance1) {
                rewardToken1.safeTransfer(to, balance1);
                _userInfo.unpaidRewards1 = pending1 - balance1;
            } else {
                rewardToken1.safeTransfer(to, pending1);
                _userInfo.unpaidRewards1 = 0;
            }

            if (pending2 > balance2) {
                rewardToken2.safeTransfer(to, balance2);
                _userInfo.unpaidRewards2 = pending2 - balance2;
            } else {
                rewardToken2.safeTransfer(to, pending2);
                _userInfo.unpaidRewards2 = 0;
            }
        }
        _userInfo.amount = lpTokenAmount;
        _userInfo.rewardDebt1 = lpTokenAmount.mul(pool.accToken1PerShare) / ACC_TOKEN_PRECISION;
        _userInfo.rewardDebt2 = lpTokenAmount.mul(pool.accToken2PerShare) / ACC_TOKEN_PRECISION;

        userInfo[pid][_user] = _userInfo;

        emit LogOnReward(_user, pid, pending1 - _userInfo.unpaidRewards1, pending2 - _userInfo.unpaidRewards2, to);
    }

    function pendingTokens(uint256 pid, address user, uint256) override external view returns (IERC20[] memory rewardTokens, uint256[] memory rewardAmounts) {

        IERC20[] memory _rewardTokens = new IERC20[](2);
        _rewardTokens[0] = rewardToken1;
        _rewardTokens[1] = rewardToken2;
        uint256[] memory _rewardAmounts = new uint256[](2);
        (uint256 reward1, uint256 reward2) = pendingToken(pid, user);
        _rewardAmounts[0] = reward1;
        _rewardAmounts[1] = reward2;
        return (_rewardTokens, _rewardAmounts);
    }

    function rewardRates() external view returns (uint256[] memory) {

        uint256[] memory _rewardRates = new uint256[](2);
        _rewardRates[0] = rewardPerSecond1;
        _rewardRates[1] = rewardPerSecond2;
        return (_rewardRates);
    }

    function setRewardPerSecond(uint128 _rewardPerSecond1, uint128 _rewardPerSecond2) public onlyOwner {

        rewardPerSecond1 = _rewardPerSecond1;
        rewardPerSecond2 = _rewardPerSecond2;
        emit LogRewardPerSecond(_rewardPerSecond1, _rewardPerSecond2);
    }

    function reclaimTokens(address token, uint256 amount, address payable to) public onlyOwner {

        if (token == address(0)) {
            to.transfer(amount);
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    modifier onlyMCV2 {

        require(
            msg.sender == MASTERCHEF_V2,
            "Only MCV2 can call this function."
        );
        _;
    }

    function pendingToken(uint256 _pid, address _user) public view returns (uint256 reward1, uint256 reward2) {

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accToken1PerShare = pool.accToken1PerShare;
        uint256 accToken2PerShare = pool.accToken2PerShare;
        uint256 lpSupply = IMasterChefV2(MASTERCHEF_V2).lpToken(_pid).balanceOf(MASTERCHEF_V2);
        if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            uint256 time = block.timestamp.sub(pool.lastRewardTime);
            uint256 pending1 = time.mul(rewardPerSecond1);
            uint256 pending2 = time.mul(rewardPerSecond2);
            accToken1PerShare = accToken1PerShare.add(pending1.mul(ACC_TOKEN_PRECISION) / lpSupply);
            accToken2PerShare = accToken2PerShare.add(pending2.mul(ACC_TOKEN_PRECISION) / lpSupply);
        }
        reward1 = (user.amount.mul(accToken1PerShare) / ACC_TOKEN_PRECISION).sub(user.rewardDebt1).add(user.unpaidRewards1);
        reward2 = (user.amount.mul(accToken2PerShare) / ACC_TOKEN_PRECISION).sub(user.rewardDebt2).add(user.unpaidRewards2);
    }

    function updatePool(uint256 pid) public returns (PoolInfo memory pool) {

        pool = poolInfo[pid];
        if (block.timestamp > pool.lastRewardTime) {
            uint256 lpSupply = IMasterChefV2(MASTERCHEF_V2).lpToken(pid).balanceOf(MASTERCHEF_V2);

            if (lpSupply > 0) {
                uint256 time = block.timestamp.sub(pool.lastRewardTime);
                uint256 pending1 = time.mul(rewardPerSecond1);
                uint256 pending2 = time.mul(rewardPerSecond2);
                pool.accToken1PerShare = pool.accToken1PerShare.add((pending1.mul(ACC_TOKEN_PRECISION) / lpSupply).to128());
                pool.accToken2PerShare = pool.accToken2PerShare.add((pending2.mul(ACC_TOKEN_PRECISION) / lpSupply).to128());
            }
            pool.lastRewardTime = block.timestamp.to64();
            poolInfo[pid] = pool;
            emit LogUpdatePool(pid, pool.lastRewardTime, lpSupply, pool.accToken1PerShare, pool.accToken2PerShare);
        }
    }
}