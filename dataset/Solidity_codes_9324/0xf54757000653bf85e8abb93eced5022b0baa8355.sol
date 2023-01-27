
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

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
}// MIT

pragma solidity ^0.6.2;

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
}// MIT

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
}// MIT

pragma solidity ^0.6.0;

contract ReentrancyGuard {


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
}pragma solidity 0.6.12;

library SafeMath96 {


    function add(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add(uint96 a, uint96 b) internal pure returns (uint96) {

        return add(a, b, "SafeMath96: addition overflow");
    }

    function sub(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub(uint96 a, uint96 b) internal pure returns (uint96) {

        return sub(a, b, "SafeMath96: subtraction overflow");
    }

    function fromUint(uint n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function fromUint(uint n) internal pure returns (uint96) {

        return fromUint(n, "SafeMath96: exceeds 96 bits");
    }
}pragma solidity 0.6.12;

library SafeMath32 {


    function add(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        uint32 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {

        return add(a, b, "SafeMath32: addition overflow");
    }

    function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {

        return sub(a, b, "SafeMath32: subtraction overflow");
    }

    function fromUint(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function fromUint(uint n) internal pure returns (uint32) {

        return fromUint(n, "SafeMath32: exceeds 32 bits");
    }
}pragma solidity 0.6.12;


contract ArchbishopV2 is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeMath96 for uint96;
    using SafeMath32 for uint32;

    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 wAmount; // Weighted amount = lptAmount + (stAmount * pool.sTokenWeight)
        uint256 stAmount; // How many S tokens the user has provided
        uint256 lptAmount; // How many LP tokens the user has provided
        uint96 pendingKing; // $KING tokens pending to be given to user
        uint96 rewardDebt; // Reward debt (see explanation below)
        uint32 lastWithdrawBlock; // User last withdraw time

    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract
        uint32 allocPoint; // Allocation points assigned to this pool (for $KINGs distribution)
        uint32 lastRewardBlock; // Last block number that $KINGs distribution occurs
        uint32 sTokenWeight; // "Weight" of LP token in SToken, times 1e8
        IERC20 sToken; // Address of S token contract
        bool kingLock; // if true, withdraw interval, or withdraw fees otherwise, applied on $KING withdrawals
        uint256 accKingPerShare; // Accumulated $KINGs per share, times 1e12 (see above)
    }

    address public king;

    address public kingServant;
    uint8 public lpFeePct = 0;

    address public courtJester;
    uint8 public kingFeePct = 0;
    uint32 public withdrawInterval;

    uint96 public kingPerLptFarmingBlock;
    uint96 public kingPerStFarmingBlock;
    uint32 public totalAllocPoint;

    uint32 public startBlock;
    uint32 public lptFarmingEndBlock;
    uint32 public stFarmingEndBlock;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event Deposit(
        address indexed user,
        uint256 indexed pid,
        uint256 lptAmount,
        uint256 stAmount
    );
    event Withdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 lptAmount
    );
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 lptAmount
    );

    constructor(
        address _king,
        address _kingServant,
        address _courtJester,
        uint256 _startBlock,
        uint256 _withdrawInterval
    ) public {
        king = _nonZeroAddr(_king);
        kingServant = _nonZeroAddr(_kingServant);
        courtJester = _nonZeroAddr(_courtJester);
        startBlock = SafeMath32.fromUint(_startBlock);
        withdrawInterval = SafeMath32.fromUint(_withdrawInterval);
    }

    function setFarmingParams(
        uint256 _kingPerLptFarmingBlock,
        uint256 _kingPerStFarmingBlock,
        uint256 _lptFarmingEndBlock,
        uint256 _stFarmingEndBlock
    ) external onlyOwner {

        uint32 _startBlock = startBlock;
        require(_lptFarmingEndBlock >= _startBlock, "ArchV2:INVALID_lptFarmEndBlock");
        require(_stFarmingEndBlock >= _startBlock, "ArchV2:INVALID_stFarmEndBlock");
        _setFarmingParams(
            SafeMath96.fromUint(_kingPerLptFarmingBlock),
            SafeMath96.fromUint(_kingPerStFarmingBlock),
            SafeMath32.fromUint(_lptFarmingEndBlock),
            SafeMath32.fromUint(_stFarmingEndBlock)
        );
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(
        uint256 allocPoint,
        uint256 sTokenWeight,
        IERC20 lpToken,
        IERC20 sToken,
        bool withUpdate
    ) public onlyOwner {

        require(_isMissingPool(lpToken, sToken), "ArchV2::add:POOL_EXISTS");
        uint32 _allocPoint = SafeMath32.fromUint(allocPoint);

        if (withUpdate) massUpdatePools();

        uint32 curBlock = curBlock();
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: lpToken,
                sToken: sToken,
                allocPoint: SafeMath32.fromUint(_allocPoint),
                sTokenWeight: SafeMath32.fromUint(sTokenWeight),
                lastRewardBlock: curBlock > startBlock ? curBlock : startBlock,
                accKingPerShare: 0,
                kingLock: true
            })
        );
    }

    function setAllocation(
        uint256 pid,
        uint256 allocPoint,
        bool withUpdate
    ) public onlyOwner {

        _validatePid(pid);
        if (withUpdate) massUpdatePools();

        uint32 _allocPoint = SafeMath32.fromUint(allocPoint);

        totalAllocPoint = totalAllocPoint.sub(poolInfo[pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[pid].allocPoint = _allocPoint;
    }

    function setSTokenWeight(
        uint256 pid,
        uint256 sTokenWeight,
        bool withUpdate
    ) public onlyOwner {

        _validatePid(pid);
        if (withUpdate) massUpdatePools();

        poolInfo[pid].sTokenWeight = SafeMath32.fromUint(sTokenWeight);
    }

    function setKingLock(
        uint256 pid,
        bool _kingLock,
        bool withUpdate
    ) public onlyOwner {

        _validatePid(pid);
        if (withUpdate) massUpdatePools();

        poolInfo[pid].kingLock = _kingLock;
    }

    function getMultiplier(uint256 from, uint256 to)
        public
        view
        returns (uint256 lpt, uint256 st)
    {

        (uint32 _lpt, uint32 _st) = _getMultiplier(
            SafeMath32.fromUint(from),
            SafeMath32.fromUint(to)
        );
        lpt = uint256(_lpt);
        st = uint256(_st);
    }

    function getKingPerBlock(uint256 blockNum) public view returns (uint256) {

        return
            (blockNum > stFarmingEndBlock ? 0 : kingPerStFarmingBlock).add(
                blockNum > lptFarmingEndBlock ? 0 : kingPerLptFarmingBlock
            );
    }

    function pendingKing(uint256 pid, address _user)
        external
        view
        returns (uint256)
    {

        _validatePid(pid);
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][_user];

        uint256 kingPerShare = pool.accKingPerShare;

        uint32 curBlock = curBlock();
        uint256 lptSupply = pool.lpToken.balanceOf(address(this));

        if (curBlock > pool.lastRewardBlock && lptSupply != 0) {
            (uint32 lptFactor, uint32 stFactor) = _getMultiplier(
                pool.lastRewardBlock,
                curBlock
            );
            uint96 kingReward = _kingReward(
                lptFactor,
                stFactor,
                pool.allocPoint
            );
            if (kingReward != 0) {
                uint256 stSupply = pool.sToken.balanceOf(address(this));
                uint256 wSupply = _weighted(
                    lptSupply,
                    stSupply,
                    pool.sTokenWeight
                );
                kingPerShare = _accShare(kingPerShare, kingReward, wSupply);
            }
        }

        return
            _accPending(
                user.pendingKing,
                user.wAmount,
                user.rewardDebt,
                kingPerShare
            );
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    function updatePool(uint256 pid) public {

        _validatePid(pid);
        _updatePool(pid);
    }

    function deposit(
        uint256 pid,
        uint256 lptAmount,
        uint256 stAmount
    ) public nonReentrant {

        require(lptAmount != 0, "deposit: zero LP token amount");
        _validatePid(pid);

        _updatePool(pid);

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        uint256 oldStAmount = user.stAmount;
        uint96 pendingKingAmount = _accPending(
            user.pendingKing,
            user.wAmount,
            user.rewardDebt,
            pool.accKingPerShare
        );
        user.lptAmount = user.lptAmount.add(lptAmount);
        user.stAmount = user.stAmount.add(stAmount);
        user.wAmount = _accWeighted(
            user.wAmount,
            lptAmount,
            stAmount,
            pool.sTokenWeight
        );

        uint32 curBlock = curBlock();
        if (
            _sendKingToken(
                msg.sender,
                pendingKingAmount,
                pool.kingLock,
                curBlock.sub(user.lastWithdrawBlock)
            )
        ) {
            user.lastWithdrawBlock = curBlock;
            user.pendingKing = 0;
            pool.sToken.safeTransfer(address(1), oldStAmount);
        } else {
            user.pendingKing = pendingKingAmount;
        }
        user.rewardDebt = _pending(user.wAmount, 0, pool.accKingPerShare);

        pool.lpToken.safeTransferFrom(msg.sender, address(this), lptAmount);
        if (stAmount != 0)
            pool.sToken.safeTransferFrom(msg.sender, address(this), stAmount);

        emit Deposit(msg.sender, pid, lptAmount, stAmount);
    }

    function withdraw(uint256 pid, uint256 lptAmount) public nonReentrant {

        _validatePid(pid);
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        uint256 preLptAmount = user.wAmount;
        require(preLptAmount >= lptAmount, "withdraw: LP amount not enough");

        user.lptAmount = preLptAmount.sub(lptAmount);
        uint256 stAmount = user.stAmount;

        _updatePool(pid);
        uint96 pendingKingAmount = _accPending(
            user.pendingKing,
            user.wAmount,
            user.rewardDebt,
            pool.accKingPerShare
        );
        user.wAmount = user.lptAmount;
        user.rewardDebt = _pending(user.wAmount, 0, pool.accKingPerShare);
        user.stAmount = 0;
        uint32 curBlock = curBlock();

        if (
            _sendKingToken(
                msg.sender,
                pendingKingAmount,
                pool.kingLock,
                curBlock.sub(user.lastWithdrawBlock)
            )
        ) {
            user.lastWithdrawBlock = curBlock;
            user.pendingKing = 0;
        } else {
            user.pendingKing = pendingKingAmount;
        }

        uint256 sentLptAmount = lptAmount == 0
            ? 0
            : _sendLptAndBurnSt(msg.sender, pool, lptAmount, stAmount);
        emit Withdraw(msg.sender, pid, sentLptAmount);
    }

    function emergencyWithdraw(uint256 pid) public {

        _validatePid(pid);
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        uint256 lptAmount = user.lptAmount;
        user.lptAmount = 0; // serves as "non-reentrant"
        require(lptAmount > 0, "withdraw: zero LP token amount");

        uint32 curBlock = curBlock();
        uint256 stAmount = user.stAmount;
        user.wAmount = 0;
        user.stAmount = 0;
        user.rewardDebt = 0;
        user.pendingKing = 0;
        user.lastWithdrawBlock = curBlock;

        uint256 sentLptAmount = _sendLptAndBurnSt(
            msg.sender,
            pool,
            lptAmount,
            stAmount
        );
        emit EmergencyWithdraw(msg.sender, pid, sentLptAmount);
    }

    function setKingServant(address _kingServant) public onlyOwner {

        kingServant = _nonZeroAddr(_kingServant);
    }

    function setCourtJester(address _courtJester) public onlyOwner {

        courtJester = _nonZeroAddr(_courtJester);
    }

    function setKingFeePct(uint256 newPercent) public onlyOwner {

        kingFeePct = _validPercent(newPercent);
    }

    function setLpFeePct(uint256 newPercent) public onlyOwner {

        lpFeePct = _validPercent(newPercent);
    }

    function setWithdrawInterval(uint256 _blocks) public onlyOwner {

        withdrawInterval = SafeMath32.fromUint(_blocks);
    }

    function _updatePool(uint256 pid) internal {

        PoolInfo storage pool = poolInfo[pid];
        uint32 lastUpdateBlock = pool.lastRewardBlock;

        uint32 curBlock = curBlock();
        if (curBlock <= lastUpdateBlock) return;
        pool.lastRewardBlock = curBlock;

        (uint32 lptFactor, uint32 stFactor) = _getMultiplier(
            lastUpdateBlock,
            curBlock
        );
        if (lptFactor == 0 && stFactor == 0) return;

        uint256 lptSupply = pool.lpToken.balanceOf(address(this));
        if (lptSupply == 0) return;

        uint256 stSupply = pool.sToken.balanceOf(address(this));
        uint256 wSupply = _weighted(lptSupply, stSupply, pool.sTokenWeight);

        uint96 kingReward = _kingReward(lptFactor, stFactor, pool.allocPoint);
        pool.accKingPerShare = _accShare(
            pool.accKingPerShare,
            kingReward,
            wSupply
        );
    }

    function _sendKingToken(
        address user,
        uint96 amount,
        bool kingLock,
        uint32 blocksSinceLastWithdraw
    ) internal returns (bool isSent) {

        isSent = true;
        if (amount == 0) return isSent;

        uint256 feeAmount = 0;
        uint256 userAmount = 0;

        if (!kingLock) {
            userAmount = amount;
            if (kingFeePct != 0) {
                feeAmount = uint256(amount).mul(kingFeePct).div(100);
                userAmount = userAmount.sub(feeAmount);

                IERC20(king).safeTransfer(courtJester, feeAmount);
            }
        } else if (blocksSinceLastWithdraw > withdrawInterval) {
            userAmount = amount;
        } else {
            return isSent = false;
        }

        uint256 balance = IERC20(king).balanceOf(address(this));
        IERC20(king).safeTransfer(
            user,
            userAmount > balance ? balance : userAmount
        );
    }

    function _sendLptAndBurnSt(
        address user,
        PoolInfo storage pool,
        uint256 lptAmount,
        uint256 stAmount
    ) internal returns (uint256) {

        uint256 userLptAmount = lptAmount;

        if (curBlock() < stFarmingEndBlock && lpFeePct != 0) {
            uint256 lptFee = lptAmount.mul(lpFeePct).div(100);
            userLptAmount = userLptAmount.sub(lptFee);

            pool.lpToken.safeTransfer(kingServant, lptFee);
        }

        if (userLptAmount != 0) pool.lpToken.safeTransfer(user, userLptAmount);
        if (stAmount != 0) pool.sToken.safeTransfer(address(1), stAmount);

        return userLptAmount;
    }

    function _safeKingTransfer(address _to, uint256 _amount) internal {

        uint256 kingBal = IERC20(king).balanceOf(address(this));
        IERC20(king).safeTransfer(_to, _amount > kingBal ? kingBal : _amount);
    }

    function _setFarmingParams(
        uint96 _kingPerLptFarmingBlock,
        uint96 _kingPerStFarmingBlock,
        uint32 _lptFarmingEndBlock,
        uint32 _stFarmingEndBlock
    ) internal {

        require(
            _lptFarmingEndBlock >= lptFarmingEndBlock,
            "ArchV2::lptFarmingEndBlock"
        );
        require(
            _stFarmingEndBlock >= stFarmingEndBlock,
            "ArchV2::stFarmingEndBlock"
        );

        if (lptFarmingEndBlock != _lptFarmingEndBlock)
            lptFarmingEndBlock = _lptFarmingEndBlock;
        if (stFarmingEndBlock != _stFarmingEndBlock)
            stFarmingEndBlock = _stFarmingEndBlock;

        (uint32 lptFactor, uint32 stFactor) = _getMultiplier(
            curBlock(),
            2**32 - 1
        );
        uint256 minBalance = (
            uint256(_kingPerLptFarmingBlock).mul(uint256(stFactor))
        )
            .add(uint256(_kingPerStFarmingBlock).mul(uint256(lptFactor)));
        require(
            IERC20(king).balanceOf(address(this)) >= minBalance,
            "ArchV2::LOW_$KING_BALANCE"
        );

        kingPerLptFarmingBlock = _kingPerLptFarmingBlock;
        kingPerStFarmingBlock = _kingPerStFarmingBlock;
    }

    function _isMissingPool(IERC20 lpToken, IERC20 sToken)
        internal
        view
        returns (bool)
    {

        _revertZeroAddress(address(lpToken));
        _revertZeroAddress(address(lpToken));
        for (uint256 i = 0; i < poolInfo.length; i++) {
            if (
                poolInfo[i].lpToken == lpToken || poolInfo[i].sToken == sToken
            ) {
                return false;
            }
        }
        return true;
    }

    function _getMultiplier(uint32 _from, uint32 _to)
        internal
        view
        returns (uint32 lpt, uint32 st)
    {

        uint32 start = _from > startBlock ? _from : startBlock;

        uint32 end = _to > lptFarmingEndBlock ? lptFarmingEndBlock : _to;
        lpt = _from < lptFarmingEndBlock ? end.sub(start) : 0;

        end = _to > stFarmingEndBlock ? stFarmingEndBlock : _to;
        st = _from < stFarmingEndBlock ? end.sub(start) : 0;
    }

    function _accPending(
        uint96 prevPending,
        uint256 amount,
        uint96 rewardDebt,
        uint256 accPerShare
    ) internal pure returns (uint96) {

        return
            amount == 0
                ? prevPending
                : prevPending.add(_pending(amount, rewardDebt, accPerShare));
    }

    function _pending(
        uint256 amount,
        uint96 rewardDebt,
        uint256 accPerShare
    ) internal pure returns (uint96) {

        return
            amount == 0
                ? 0
                : SafeMath96.fromUint(
                    amount.mul(accPerShare).div(1e12).sub(uint256(rewardDebt)),
                    "ArchV2::pending:overflow"
                );
    }

    function _kingReward(
        uint32 lptFactor,
        uint32 stFactor,
        uint32 allocPoint
    ) internal view returns (uint96) {

        uint32 _totalAllocPoint = totalAllocPoint;
        uint96 lptReward = _reward(
            lptFactor,
            kingPerLptFarmingBlock,
            allocPoint,
            _totalAllocPoint
        );
        if (stFactor == 0) return lptReward;

        uint96 stReward = _reward(
            stFactor,
            kingPerStFarmingBlock,
            allocPoint,
            _totalAllocPoint
        );
        return lptReward.add(stReward);
    }

    function _reward(
        uint32 factor,
        uint96 rewardPerBlock,
        uint32 allocPoint,
        uint32 _totalAllocPoint
    ) internal pure returns (uint96) {

        return
            SafeMath96.fromUint(
                uint256(factor)
                    .mul(uint256(rewardPerBlock))
                    .mul(uint256(allocPoint))
                    .div(uint256(_totalAllocPoint))
            );
    }

    function _accShare(
        uint256 prevShare,
        uint96 reward,
        uint256 supply
    ) internal pure returns (uint256) {

        return prevShare.add(uint256(reward).mul(1e12).div(supply));
    }

    function _accWeighted(
        uint256 prevAmount,
        uint256 lptAmount,
        uint256 stAmount,
        uint32 sTokenWeight
    ) internal pure returns (uint256) {

        return prevAmount.add(_weighted(lptAmount, stAmount, sTokenWeight));
    }

    function _weighted(
        uint256 lptAmount,
        uint256 stAmount,
        uint32 sTokenWeight
    ) internal pure returns (uint256) {

        if (stAmount == 0 || sTokenWeight == 0) {
            return lptAmount;
        }
        return lptAmount.add(stAmount.mul(sTokenWeight).div(1e8));
    }

    function _nonZeroAddr(address _address) private pure returns (address) {

        _revertZeroAddress(_address);
        return _address;
    }

    function curBlock() private view returns (uint32) {

        return SafeMath32.fromUint(block.number);
    }

    function _validPercent(uint256 percent) private pure returns (uint8) {

        require(percent <= 100, "ArchV2::INVALID_PERCENT");
        return uint8(percent);
    }

    function _revertZeroAddress(address _address) internal pure {

        require(_address != address(0), "ArchV2::ZERO_ADDRESS");
    }

    function _validatePid(uint256 pid) private view returns (uint256) {

        require(pid < poolInfo.length, "ArchV2::INVALID_POOL_ID");
        return pid;
    }
}