



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
}


 

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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
}


 

pragma solidity >=0.6.0 <0.8.0;

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


 

pragma solidity >=0.6.0 <0.8.0;




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


 

pragma solidity 0.7.4;

library ErrorCode {


    string constant FORBIDDEN = 'YouSwap:FORBIDDEN';
    string constant IDENTICAL_ADDRESSES = 'YouSwap:IDENTICAL_ADDRESSES';
    string constant ZERO_ADDRESS = 'YouSwap:ZERO_ADDRESS';
    string constant INVALID_ADDRESSES = 'YouSwap:INVALID_ADDRESSES';
    string constant BALANCE_INSUFFICIENT = 'YouSwap:BALANCE_INSUFFICIENT';
    string constant REWARDTOTAL_LESS_THAN_REWARDPROVIDE = 'YouSwap:REWARDTOTAL_LESS_THAN_REWARDPROVIDE';
    string constant PARAMETER_TOO_LONG = 'YouSwap:PARAMETER_TOO_LONG';
    string constant REGISTERED = 'YouSwap:REGISTERED';
    string constant MINING_NOT_STARTED = 'YouSwap:MINING_NOT_STARTED';
    string constant END_OF_MINING = 'YouSwap:END_OF_MINING';
    string constant POOL_NOT_EXIST_OR_END_OF_MINING = 'YouSwap:POOL_NOT_EXIST_OR_END_OF_MINING';
    
}

 

pragma solidity 0.7.4;

interface IYouswapInviteV1 {


    struct UserInfo {
        address upper;//??????
        address[] lowers;//??????
        uint256 startBlock;//????????????
    }

    event InviteV1(address indexed owner, address indexed upper, uint256 indexed height);//?????????????????????????????????????????????????????????

    function inviteCount() external view returns (uint256);//????????????


    function inviteUpper1(address) external view returns (address);//????????????


    function inviteUpper2(address) external view returns (address, address);//????????????


    function inviteLower1(address) external view returns (address[] memory);//????????????


    function inviteLower2(address) external view returns (address[] memory, address[] memory);//????????????


    function inviteLower2Count(address) external view returns (uint256, uint256);//????????????

    
    function register() external returns (bool);//??????????????????


    function acceptInvitation(address) external returns (bool);//??????????????????

    
    function inviteBatch(address[] memory) external returns (uint, uint);//????????????????????????????????????????????????


}

 

pragma solidity 0.7.4;



contract YouswapInviteV1 is IYouswapInviteV1 {


    address public constant ZERO = address(0);
    uint256 public startBlock;
    address[] public inviteUserInfoV1;
    mapping(address => UserInfo) public inviteUserInfoV2;

    constructor () {
        startBlock = block.number;
    }
    
    function inviteCount() override external view returns (uint256) {

        return inviteUserInfoV1.length;
    }

    function inviteUpper1(address _owner) override external view returns (address) {

        return inviteUserInfoV2[_owner].upper;
    }

    function inviteUpper2(address _owner) override external view returns (address, address) {

        address upper1 = inviteUserInfoV2[_owner].upper;
        address upper2 = address(0);
        if (address(0) != upper1) {
            upper2 = inviteUserInfoV2[upper1].upper;
        }

        return (upper1, upper2);
    }

    function inviteLower1(address _owner) override external view returns (address[] memory) {

        return inviteUserInfoV2[_owner].lowers;
    }

    function inviteLower2(address _owner) override external view returns (address[] memory, address[] memory) {

        address[] memory lowers1 = inviteUserInfoV2[_owner].lowers;
        uint256 count = 0;
        uint256 lowers1Len = lowers1.length;
        for (uint256 i = 0; i < lowers1Len; i++) {
            count += inviteUserInfoV2[lowers1[i]].lowers.length;
        }
        address[] memory lowers;
        address[] memory lowers2 = new address[](count);
        count = 0;
        for (uint256 i = 0; i < lowers1Len; i++) {
            lowers = inviteUserInfoV2[lowers1[i]].lowers;
            for (uint256 j = 0; j < lowers.length; j++) {
                lowers2[count] = lowers[j];
                count++;
            }
        }
        
        return (lowers1, lowers2);
    }

    function inviteLower2Count(address _owner) override external view returns (uint256, uint256) {

        address[] memory lowers1 = inviteUserInfoV2[_owner].lowers;
        uint256 lowers2Len = 0;
        uint256 len = lowers1.length;
        for (uint256 i = 0; i < len; i++) {
            lowers2Len += inviteUserInfoV2[lowers1[i]].lowers.length;
        }
        
        return (lowers1.length, lowers2Len);
    }

    function register() override external returns (bool) {

        UserInfo storage user = inviteUserInfoV2[tx.origin];
        require(0 == user.startBlock, ErrorCode.REGISTERED);
        user.upper = ZERO;
        user.startBlock = block.number;
        inviteUserInfoV1.push(tx.origin);
        
        emit InviteV1(tx.origin, user.upper, user.startBlock);
        
        return true;
    }

    function acceptInvitation(address _inviter) override external returns (bool) {

        require(msg.sender != _inviter, ErrorCode.FORBIDDEN);
        UserInfo storage user = inviteUserInfoV2[msg.sender];
        require(0 == user.startBlock, ErrorCode.REGISTERED);
        UserInfo storage upper = inviteUserInfoV2[_inviter];
        if (0 == upper.startBlock) {
            upper.upper = ZERO;
            upper.startBlock = block.number;
            inviteUserInfoV1.push(_inviter);
            
            emit InviteV1(_inviter, upper.upper, upper.startBlock);
        }
        user.upper = _inviter;
        upper.lowers.push(msg.sender);
        user.startBlock = block.number;
        inviteUserInfoV1.push(msg.sender);
        
        emit InviteV1(msg.sender, user.upper, user.startBlock);

        return true;
    }

    function inviteBatch(address[] memory _invitees) override external returns (uint, uint) {

        uint len = _invitees.length;
        require(len <= 100, ErrorCode.PARAMETER_TOO_LONG);
        UserInfo storage user = inviteUserInfoV2[msg.sender];
        if (0 == user.startBlock) {
            user.upper = ZERO;
            user.startBlock = block.number;
            inviteUserInfoV1.push(msg.sender);
                        
            emit InviteV1(msg.sender, user.upper, user.startBlock);
        }
        uint count = 0;
        for (uint i = 0; i < len; i++) {
            if ((address(0) != _invitees[i]) && (msg.sender != _invitees[i])) {
                UserInfo storage lower = inviteUserInfoV2[_invitees[i]];
                if (0 == lower.startBlock) {
                    lower.upper = msg.sender;
                    lower.startBlock = block.number;
                    user.lowers.push(_invitees[i]);
                    inviteUserInfoV1.push(_invitees[i]);
                    count++;

                    emit InviteV1(_invitees[i], msg.sender, lower.startBlock);
                }
            }
        }

        return (len, count);
    }

}

 

pragma solidity 0.7.4;

interface ITokenYou {

    
    function mint(address recipient, uint256 amount) external;

    
    function decimals() external view returns (uint8);

    
}


 

pragma solidity 0.7.4;



interface IYouswapFactoryV2 {


    struct PoolViewInfo {
        address token;//token????????????
        string name;//??????
        uint256 multiple;//????????????
        uint256 priority;//??????
    }

    struct PoolStakeInfo {
        uint256 startBlock;//??????????????????
        address token;//token????????????
        uint256 amount;//????????????
        uint256 lastRewardBlock;//????????????????????????
        uint256 totalPower;//?????????
        uint256 powerRatio;//???????????????????????????
        uint256 maxStakeAmount;//??????????????????
        uint256 endBlock;//??????????????????
    }
    
    struct PoolRewardInfo {        
        address token;//??????????????????:A/B/C
        uint256 rewardTotal;//???????????????
        uint256 rewardPerBlock;//??????????????????
        uint256 rewardProvide;//?????????????????????
        uint256 rewardPerShare;//??????????????????
    }

    struct UserStakeInfo {
        uint256 startBlock;//??????????????????
        uint256 amount;//????????????
        uint256 invitePower;//????????????
        uint256 stakePower;//????????????
        uint256[] invitePendingRewards;//???????????????
        uint256[] stakePendingRewards;//???????????????
        uint256[] inviteRewardDebts;//????????????
        uint256[] stakeRewardDebts;//????????????
    }

    
    event InviteRegister(address indexed self);

    event UpdatePool(bool action, uint256 poolId, string name, address indexed token, uint256 powerRatio, uint256 maxStakeAmount, uint256 startBlock, uint256 multiple, uint256 priority, address[] tokens, uint256[] _rewardTotals, uint256[] rewardPerBlocks);

    event EndPool(uint256 poolId);    
    
    event Stake(uint256 poolId, address indexed token, address indexed from, uint256 amount);

    event UpdatePower(uint256 poolId, address token, uint256 totalPower, address indexed owner, uint256 ownerInvitePower, uint256 ownerStakePower, address indexed upper1, uint256 upper1InvitePower, address indexed upper2, uint256 upper2InvitePower);    

    event UnStake(uint256 poolId, address indexed token, address indexed to, uint256 amount);
    
    event WithdrawReward(uint256 poolId, address indexed token, address indexed to, uint256 inviteAmount, uint256 stakeAmount);
    
    event Mint(uint256 poolId, address indexed token, uint256 amount);

    event SafeWithdraw(address indexed token, address indexed to, uint256 amount);
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);
    

    function transferOwnership(address owner) external;

    
    function stake(uint256 poolId, uint256 amount) external;

    
    function unStake(uint256 poolId, uint256 amount) external;

    
    function unStakes(uint256[] memory _poolIds) external;

    
    function withdrawReward(uint256 poolId) external;


    function withdrawRewards(uint256[] memory _poolIds) external;


    function safeWithdraw(address token, address to, uint256 amount) external;

        
    function powerScale(uint256 poolId, address user) external view returns (uint256, uint256);

    
    function pendingRewardV2(uint256 poolId, address user) external view returns (address[] memory, uint256[] memory);

    
    function pendingRewardV3(uint256 poolId, address user) external view returns (address[] memory, uint256[] memory, uint256[] memory);

    
    function poolNumbers(address token) external view returns (uint256[] memory);


    function poolIdsV2() external view returns (uint256[] memory);

    
    function stakeRange(uint256 poolId) external view returns (uint256, uint256);

    
    function getPowerRatio(uint256 poolId) external view returns (uint256);


    function getRewardInfo(uint256 poolId, address user, uint256 index) external view returns (uint256, uint256, uint256, uint256);

    
    function setOperateOwner(address user, bool state) external;


    
    function addPool(string memory name, address token, uint256 powerRatio, uint256 startBlock, uint256 multiple, uint256 priority, address[] memory tokens, uint256[] memory rewardTotals, uint256[] memory rewardPerBlocks) external;

        
    function setRewardPerBlock(uint256 poolId, address token, uint256 rewardPerBlock) external;


    function setRewardTotal(uint256 poolId, address token, uint256 rewardTotal) external;


    function setName(uint256 poolId, string memory name) external;

    
    function setMultiple(uint256 poolId, uint256 multiple) external;

    
    function setPriority(uint256 poolId, uint256 priority) external;


    function setMaxStakeAmount(uint256 poolId, uint256 maxStakeAmount) external;

    
    
}

 

pragma solidity 0.7.4;




contract YouswapFactoryV2 is IYouswapFactoryV2 {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    address public constant ZERO = address(0);
    uint256 public constant INVITE_SELF_REWARD = 5;//??????????????????5%
    uint256 public constant INVITE1_REWARD = 15;//1??????????????????15%
    uint256 public constant INVITE2_REWARD = 10;//2??????????????????10%
    
    uint256 public deployBlock;//??????????????????
    address public owner;//????????????
    mapping(address => bool) public operateOwner;//????????????
    ITokenYou public you;//you contract
    YouswapInviteV1 public invite;//invite contract

    uint256 public poolCount = 0;//????????????
    uint256[] public poolIds;//??????ID
    mapping(uint256 => PoolViewInfo) public poolViewInfos;//????????????????????????poolID->PoolViewInfo
    mapping(uint256 => PoolStakeInfo) public poolStakeInfos;//?????????????????????poolID->PoolStakeInfo
    mapping(uint256 => PoolRewardInfo[]) public poolRewardInfos;//?????????????????????poolID->PoolRewardInfo[]
    mapping(uint256 => mapping(address => UserStakeInfo)) public userStakeInfos;//?????????????????????poolID->user-UserStakeInfo
    mapping(address => uint256) public tokenPendingRewards;//??????token???????????????token-amount
    mapping(address => mapping(address => uint256)) public userReceiveRewards;//????????????????????????token->user->amount
    
    modifier onlyOwner() {//??????owner??????

        require(owner == msg.sender, "YouSwap:FORBIDDEN_NOT_OWNER");
        _;
    }

    modifier onlyOperater() {//??????????????????

        require(operateOwner[msg.sender], "YouSwap:FORBIDDEN_NOT_OPERATER");
        _;
    }

    constructor (ITokenYou _you, YouswapInviteV1 _invite) {
        deployBlock = block.number;
        owner = msg.sender;
        invite = _invite;
        you = _you;
        _setOperateOwner(owner, true);//???owner??????????????????
    }

    function transferOwnership(address _owner) override external onlyOwner {

        require(ZERO != _owner, "YouSwap:INVALID_ADDRESSES");
        emit TransferOwnership(owner, _owner);
        owner = _owner;
    }
    
    function stake(uint256 poolId, uint256 amount) override external {

        require(0 < amount, "YouSwap:PARAMETER_ERROR");
        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];
        require((ZERO != poolStakeInfo.token) && (poolStakeInfo.startBlock <= block.number), "YouSwap:POOL_NOT_EXIST_OR_MINT_NOT_START");//??????????????????
        require((poolStakeInfo.powerRatio <= amount) && (poolStakeInfo.amount.add(amount) < poolStakeInfo.maxStakeAmount), "YouSwap:STAKE_AMOUNT_TOO_SMALL_OR_TOO_LARGE");
        (, uint256 startBlock) = invite.inviteUserInfoV2(msg.sender);//sender????????????????????????
        if (0 == startBlock) {
            invite.register();//sender??????????????????
            emit InviteRegister(msg.sender);
        }
        IERC20(poolStakeInfo.token).safeTransferFrom(msg.sender, address(this), amount);//??????sender??????????????????this
        (address upper1, address upper2) = invite.inviteUpper2(msg.sender);//?????????2???????????????
        initRewardInfo(poolId, msg.sender, upper1, upper2);
        uint256[] memory rewardPerShares = computeReward(poolId);//????????????????????????
        provideReward(poolId, rewardPerShares, msg.sender, upper1, upper2);//???sender??????????????????upper1???upper2?????????????????????
        addPower(poolId, msg.sender, amount, poolStakeInfo.powerRatio, upper1, upper2);//??????sender???upper1???upper2??????
        setRewardDebt(poolId, rewardPerShares, msg.sender, upper1, upper2);//??????sender???upper1???upper2??????
        emit Stake(poolId, poolStakeInfo.token, msg.sender, amount);
    }
    
    function unStake(uint256 poolId, uint256 amount) override external {

        _unStake(poolId, amount);
    }
    
    function unStakes(uint256[] memory _poolIds) override external {

        require((0 < _poolIds.length) && (50 >= _poolIds.length), "YouSwap:PARAMETER_ERROR_TOO_SHORT_OR_LONG");
        uint256 amount;
        uint256 poolId;
        for(uint i = 0; i < _poolIds.length; i++) {
            poolId = _poolIds[i];
            amount = userStakeInfos[poolId][msg.sender].amount;//sender???????????????
            if (0 < amount) {
                _unStake(poolId, amount);
            }
        }
    }
    
    function withdrawReward(uint256 poolId) override external {

        _withdrawReward(poolId);
    }

    function withdrawRewards(uint256[] memory _poolIds) override external {

        require((0 < _poolIds.length) && (50 >= _poolIds.length), "YouSwap:PARAMETER_ERROR_TOO_SHORT_OR_LONG");
        for(uint i = 0; i < _poolIds.length; i++) {
            _withdrawReward(_poolIds[i]);
        }
    }

    function safeWithdraw(address token, address to, uint256 amount) override external onlyOwner {

        require((ZERO != token) && (ZERO != to) && (0 < amount), "YouSwap:ZERO_ADDRESS_OR_ZERO_AMOUNT");
        require(IERC20(token).balanceOf(address(this)) >= amount, "YouSwap:BALANCE_INSUFFICIENT");
        IERC20(token).safeTransfer(to, amount);//?????????????????????to??????
        emit SafeWithdraw(token, to, amount);
    }
    
    function powerScale(uint256 poolId, address user) override external view returns (uint256, uint256) {

        PoolStakeInfo memory poolStakeInfo = poolStakeInfos[poolId];
        if (0 == poolStakeInfo.totalPower) {
            return (0, 0);
        }
        UserStakeInfo memory userStakeInfo = userStakeInfos[poolId][user];
        return (userStakeInfo.invitePower.add(userStakeInfo.stakePower), poolStakeInfo.totalPower);
    }
    
    function pendingRewardV2(uint256 poolId, address user) override external view returns (address[] memory, uint256[] memory) {

        PoolRewardInfo[] memory _poolRewardInfos = poolRewardInfos[poolId];
        address[] memory tokens = new address[](_poolRewardInfos.length);
        uint256[] memory pendingRewards = new uint256[](_poolRewardInfos.length);
        PoolStakeInfo memory poolStakeInfo = poolStakeInfos[poolId];
        if (ZERO != poolStakeInfo.token) {
            uint256 totalReward = 0;
            uint256 rewardPre;
            UserStakeInfo memory userStakeInfo = userStakeInfos[poolId][user];
            for(uint i = 0; i < _poolRewardInfos.length; i++) {
                PoolRewardInfo memory poolRewardInfo = _poolRewardInfos[i];
                if (poolStakeInfo.startBlock <= block.number) {
                    totalReward = 0;
                    if (userStakeInfo.invitePendingRewards.length == _poolRewardInfos.length) {
                        if (0 < poolStakeInfo.totalPower) {
                            rewardPre = block.number.sub(poolStakeInfo.lastRewardBlock).mul(poolRewardInfo.rewardPerBlock);//???????????????
                            if (poolRewardInfo.rewardProvide.add(rewardPre) >= poolRewardInfo.rewardTotal) {//?????????????????????
                                rewardPre = poolRewardInfo.rewardTotal.sub(poolRewardInfo.rewardProvide);//??????????????????
                            }
                            poolRewardInfo.rewardPerShare = poolRewardInfo.rewardPerShare.add(rewardPre.mul(1e24).div(poolStakeInfo.totalPower));//????????????????????????????????????
                        }
                        totalReward = userStakeInfo.invitePendingRewards[i];//???????????????
                        totalReward = totalReward.add(userStakeInfo.stakePendingRewards[i]);//???????????????
                        totalReward = totalReward.add(userStakeInfo.invitePower.mul(poolRewardInfo.rewardPerShare).sub(userStakeInfo.inviteRewardDebts[i]).div(1e24));//????????????????????????
                        totalReward = totalReward.add(userStakeInfo.stakePower.mul(poolRewardInfo.rewardPerShare).sub(userStakeInfo.stakeRewardDebts[i]).div(1e24));//????????????????????????
                    }
                    pendingRewards[i] = totalReward;
                }
                tokens[i] = poolRewardInfo.token;
            }
        }

        return (tokens, pendingRewards);
    }

    function pendingRewardV3(uint256 poolId, address user) override external view returns (address[] memory, uint256[] memory, uint256[] memory) {

        PoolRewardInfo[] memory _poolRewardInfos = poolRewardInfos[poolId];
        address[] memory tokens = new address[](_poolRewardInfos.length);
        uint256[] memory invitePendingRewards = new uint256[](_poolRewardInfos.length);
        uint256[] memory stakePendingRewards = new uint256[](_poolRewardInfos.length);
        PoolStakeInfo memory poolStakeInfo = poolStakeInfos[poolId];
        if (ZERO != poolStakeInfo.token) {
            uint256 inviteReward = 0;
            uint256 stakeReward = 0;
            uint256 rewardPre;
            UserStakeInfo memory userStakeInfo = userStakeInfos[poolId][user];
            for(uint i = 0; i < _poolRewardInfos.length; i++) {
                PoolRewardInfo memory poolRewardInfo = _poolRewardInfos[i];
                if (poolStakeInfo.startBlock <= block.number) {
                    inviteReward = 0;
                    stakeReward = 0;
                    if (userStakeInfo.invitePendingRewards.length == _poolRewardInfos.length) {
                        if (0 < poolStakeInfo.totalPower) {
                            rewardPre = block.number.sub(poolStakeInfo.lastRewardBlock).mul(poolRewardInfo.rewardPerBlock);//???????????????
                            if (poolRewardInfo.rewardProvide.add(rewardPre) >= poolRewardInfo.rewardTotal) {//?????????????????????
                                rewardPre = poolRewardInfo.rewardTotal.sub(poolRewardInfo.rewardProvide);//??????????????????
                            }
                            poolRewardInfo.rewardPerShare = poolRewardInfo.rewardPerShare.add(rewardPre.mul(1e24).div(poolStakeInfo.totalPower));//????????????????????????????????????
                        }
                        inviteReward = userStakeInfo.invitePendingRewards[i];//???????????????
                        stakeReward = userStakeInfo.stakePendingRewards[i];//???????????????
                        inviteReward = inviteReward.add(userStakeInfo.invitePower.mul(poolRewardInfo.rewardPerShare).sub(userStakeInfo.inviteRewardDebts[i]).div(1e24));//????????????????????????
                        stakeReward = stakeReward.add(userStakeInfo.stakePower.mul(poolRewardInfo.rewardPerShare).sub(userStakeInfo.stakeRewardDebts[i]).div(1e24));//????????????????????????
                    }
                    invitePendingRewards[i] = inviteReward;
                    stakePendingRewards[i] = stakeReward;
                }
                tokens[i] = poolRewardInfo.token;
            }
        }

        return (tokens, invitePendingRewards, stakePendingRewards);
    }
    
    function poolNumbers(address token) override external view returns (uint256[] memory) {

        uint256 count = 0;
        for (uint256 i = 0; i < poolIds.length; i++) {
            if (poolViewInfos[poolIds[i]].token == token) {
                count = count.add(1);
            }
        }
        uint256[] memory ids = new uint256[](count);
        count = 0;
        for (uint i = 0; i < poolIds.length; i++) {
            if (poolViewInfos[poolIds[i]].token == token) {
                ids[count] = poolIds[i];
                count = count.add(1);
            }
        }
        return ids;
    }

    function poolIdsV2() override external view returns (uint256[] memory) {

        return poolIds;
    }

    function stakeRange(uint256 poolId) override external view returns (uint256, uint256) {

        PoolStakeInfo memory poolStakeInfo = poolStakeInfos[poolId];
        if (ZERO == poolStakeInfo.token) {
            return (0, 0);
        }
        return (poolStakeInfo.powerRatio, poolStakeInfo.maxStakeAmount.sub(poolStakeInfo.amount));
    }
    
    function getPowerRatio(uint256 poolId) override external view returns (uint256) {

        return poolStakeInfos[poolId].powerRatio;
    }
    
    function getRewardInfo(uint256 poolId, address user, uint256 index) override external view returns (uint256, uint256, uint256, uint256) {

        UserStakeInfo memory userStakeInfo = userStakeInfos[poolId][user];
        return (userStakeInfo.invitePendingRewards[index], userStakeInfo.stakePendingRewards[index], userStakeInfo.inviteRewardDebts[index], userStakeInfo.stakeRewardDebts[index]);
    }

    function setOperateOwner(address user, bool state) override external onlyOwner {

        _setOperateOwner(user, state);
    }

    
    function addPool(string memory name, address token, uint256 powerRatio, uint256 startBlock, uint256 multiple, uint256 priority, address[] memory tokens, uint256[] memory _rewardTotals, uint256[] memory rewardPerBlocks) override external onlyOperater {

        require((ZERO != token) && (address(this) != token), "YouSwap:PARAMETER_ERROR_TOKEN");
        require(0 < powerRatio, "YouSwap:POWERRATIO_MUST_GREATER_THAN_ZERO");
        require((0 < tokens.length) && (10 >= tokens.length) && (tokens.length == _rewardTotals.length) && (tokens.length == rewardPerBlocks.length), "YouSwap:PARAMETER_ERROR_REWARD");
        startBlock = startBlock < block.number ? block.number : startBlock;//??????????????????
        uint256 poolId = poolCount.add(20000000);//??????ID?????????20000000??????v1?????????
        poolIds.push(poolId);//????????????ID
        poolCount = poolCount.add(1);//???????????????
        PoolViewInfo storage poolViewInfo = poolViewInfos[poolId];//?????????????????????
        poolViewInfo.token = token;//????????????token
        poolViewInfo.name = name;//????????????
        poolViewInfo.multiple = multiple;//????????????
        if (0 < priority) {
            poolViewInfo.priority = priority;//???????????????
        }else {
            poolViewInfo.priority = poolIds.length.mul(100).add(75);//???????????????
        }
        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];//??????????????????
        poolStakeInfo.startBlock = startBlock;//????????????
        poolStakeInfo.token = token;//????????????token
        poolStakeInfo.amount = 0;//??????????????????
        poolStakeInfo.lastRewardBlock = startBlock.sub(1);//????????????????????????
        poolStakeInfo.totalPower = 0;//???????????????
        poolStakeInfo.powerRatio = powerRatio;//???????????????????????????
        poolStakeInfo.maxStakeAmount = 0;//??????????????????
        poolStakeInfo.endBlock = 0;//??????????????????
        uint256 minRewardPerBlock = uint256(0) - uint256(1);//??????????????????
        for(uint i = 0; i < tokens.length; i++) {
            require((ZERO != tokens[i]) && (address(this) != tokens[i]), "YouSwap:PARAMETER_ERROR_TOKEN");
            require(0 < _rewardTotals[i], "YouSwap:PARAMETER_ERROR_REWARD_TOTAL");
            require(0 < rewardPerBlocks[i], "YouSwap:PARAMETER_ERROR_REWARD_PER_BLOCK");
            if (address(you) != tokens[i]) {//???you??????
                tokenPendingRewards[tokens[i]] = tokenPendingRewards[tokens[i]].add(_rewardTotals[i]);
                require(IERC20(tokens[i]).balanceOf(address(this)) >= tokenPendingRewards[tokens[i]], "YouSwap:BALANCE_INSUFFICIENT");//????????????????????????
            }
            PoolRewardInfo memory poolRewardInfo;//??????????????????
            poolRewardInfo.token = tokens[i];//??????token
            poolRewardInfo.rewardTotal = _rewardTotals[i];//?????????
            poolRewardInfo.rewardPerBlock = rewardPerBlocks[i];//????????????
            poolRewardInfo.rewardProvide = 0;//???????????????
            poolRewardInfo.rewardPerShare = 0;//??????????????????
            poolRewardInfos[poolId].push(poolRewardInfo);
            if (minRewardPerBlock > poolRewardInfo.rewardPerBlock) {
                minRewardPerBlock = poolRewardInfo.rewardPerBlock;
                poolStakeInfo.maxStakeAmount = minRewardPerBlock.mul(1e24).mul(poolStakeInfo.powerRatio).div(13);
            }
        }
        sendUpdatePoolEvent(true, poolId);
    }

    function setRewardPerBlock(uint256 poolId, address token, uint256 rewardPerBlock) override external onlyOperater {

        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];
        require((ZERO != poolStakeInfo.token) && (0 == poolStakeInfo.endBlock), "YouSwap:POOL_NOT_EXIST_OR_END_OF_MINING");//?????????????????????????????????
        computeReward(poolId);//????????????????????????
        uint256 minRewardPerBlock = uint256(0) - uint256(1);//??????????????????
        PoolRewardInfo[] storage _poolRewardInfos = poolRewardInfos[poolId];
        for(uint i = 0; i < _poolRewardInfos.length; i++) {
            if (_poolRewardInfos[i].token == token) {
                _poolRewardInfos[i].rewardPerBlock = rewardPerBlock;//????????????????????????
                sendUpdatePoolEvent(false, poolId);//????????????????????????
            }
            if (minRewardPerBlock > _poolRewardInfos[i].rewardPerBlock) {
                minRewardPerBlock = _poolRewardInfos[i].rewardPerBlock;
                poolStakeInfo.maxStakeAmount = minRewardPerBlock.mul(1e24).mul(poolStakeInfo.powerRatio).div(13);
            }
        }
    }

    function setRewardTotal(uint256 poolId, address token, uint256 rewardTotal) override external onlyOperater {

        PoolStakeInfo memory poolStakeInfo = poolStakeInfos[poolId];
        require((ZERO != poolStakeInfo.token) && (0 == poolStakeInfo.endBlock), "YouSwap:POOL_NOT_EXIST_OR_END_OF_MINING");//?????????????????????????????????
        computeReward(poolId);//????????????????????????
        PoolRewardInfo[] storage _poolRewardInfos = poolRewardInfos[poolId];
        for(uint i = 0; i < _poolRewardInfos.length; i++) {
            if (_poolRewardInfos[i].token == token) {
                require(_poolRewardInfos[i].rewardProvide <= rewardTotal, "YouSwap:REWARDTOTAL_LESS_THAN_REWARDPROVIDE");//???????????????????????????????????????
                if (address(you) != token) {//???you
                    if (_poolRewardInfos[i].rewardTotal > rewardTotal) {//??????????????????????????????
                        tokenPendingRewards[token] = tokenPendingRewards[token].sub(_poolRewardInfos[i].rewardTotal.sub(rewardTotal));//??????????????????
                    }else {//??????????????????????????????
                        tokenPendingRewards[token] = tokenPendingRewards[token].add(rewardTotal.sub(_poolRewardInfos[i].rewardTotal));//??????????????????
                    }
                    require(IERC20(token).balanceOf(address(this)) >= tokenPendingRewards[token], "YouSwap:BALANCE_INSUFFICIENT");//????????????????????????
                }
                _poolRewardInfos[i].rewardTotal = rewardTotal;//?????????????????????
                sendUpdatePoolEvent(false, poolId);//????????????????????????
            }
        }
    }

    function setName(uint256 poolId, string memory name) override external onlyOperater {

        PoolViewInfo storage poolViewInfo = poolViewInfos[poolId];
        require(ZERO != poolViewInfo.token, "YouSwap:POOL_NOT_EXIST_OR_END_OF_MINING");//??????????????????
        poolViewInfo.name = name;//??????????????????
        sendUpdatePoolEvent(false, poolId);//????????????????????????
    }
    
    function setMultiple(uint256 poolId, uint256 multiple) override external onlyOperater {

        PoolViewInfo storage poolViewInfo = poolViewInfos[poolId];
        require(ZERO != poolViewInfo.token, "YouSwap:POOL_NOT_EXIST_OR_END_OF_MINING");//??????????????????
        poolViewInfo.multiple = multiple;//??????????????????
        sendUpdatePoolEvent(false, poolId);//????????????????????????
    }
    
    function setPriority(uint256 poolId, uint256 priority) override external onlyOperater {

        PoolViewInfo storage poolViewInfo = poolViewInfos[poolId];
        require(ZERO != poolViewInfo.token, "YouSwap:POOL_NOT_EXIST_OR_END_OF_MINING");//??????????????????
        poolViewInfo.priority = priority;//??????????????????
        sendUpdatePoolEvent(false, poolId);//????????????????????????
    }
    
    function setMaxStakeAmount(uint256 poolId, uint256 maxStakeAmount) override external onlyOperater {

        uint256 _maxStakeAmount;
        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];
        require((ZERO != poolStakeInfo.token) && (0 == poolStakeInfo.endBlock), "YouSwap:POOL_NOT_EXIST_OR_END_OF_MINING");//?????????????????????????????????
        uint256 minRewardPerBlock = uint256(0) - uint256(1);//??????????????????
        PoolRewardInfo[] memory _poolRewardInfos = poolRewardInfos[poolId];
        for(uint i = 0; i < _poolRewardInfos.length; i++) {
            if (minRewardPerBlock > _poolRewardInfos[i].rewardPerBlock) {
                minRewardPerBlock = _poolRewardInfos[i].rewardPerBlock;
                _maxStakeAmount = minRewardPerBlock.mul(1e24).mul(poolStakeInfo.powerRatio).div(13);
            }
        }
        require(poolStakeInfo.powerRatio <= maxStakeAmount && poolStakeInfo.amount <= maxStakeAmount && maxStakeAmount <= _maxStakeAmount, "YouSwap:MAX_STAKE_AMOUNT_INVALID");
        poolStakeInfo.maxStakeAmount = maxStakeAmount;
        sendUpdatePoolEvent(false, poolId);//????????????????????????
    }

    
    
    function _setOperateOwner(address user, bool state) internal onlyOwner {

        operateOwner[user] = state;//??????????????????
    }

    function computeReward(uint256 poolId) internal returns (uint256[] memory) {

        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];
        PoolRewardInfo[] storage _poolRewardInfos = poolRewardInfos[poolId];
        uint256[] memory rewardPerShares = new uint256[](_poolRewardInfos.length);
        if (0 < poolStakeInfo.totalPower) {//????????????????????????
            uint finishRewardCount = 0;
            uint256 reward = 0;
            uint256 blockCount = block.number.sub(poolStakeInfo.lastRewardBlock);//????????????????????????
            for(uint i = 0; i < _poolRewardInfos.length; i++) {
                PoolRewardInfo storage poolRewardInfo = _poolRewardInfos[i];//??????????????????
                reward = blockCount.mul(poolRewardInfo.rewardPerBlock);//???????????????????????????
                if (poolRewardInfo.rewardProvide.add(reward) >= poolRewardInfo.rewardTotal) {//???????????????????????????
                    reward = poolRewardInfo.rewardTotal.sub(poolRewardInfo.rewardProvide);//??????????????????
                    finishRewardCount = finishRewardCount.add(1);//????????????token??????
                }
                poolRewardInfo.rewardProvide = poolRewardInfo.rewardProvide.add(reward);//???????????????????????????
                poolRewardInfo.rewardPerShare = poolRewardInfo.rewardPerShare.add(reward.mul(1e24).div(poolStakeInfo.totalPower));//????????????????????????
                rewardPerShares[i] = poolRewardInfo.rewardPerShare;
                if (0 < reward) {
                    emit Mint(poolId, poolRewardInfo.token, reward);//????????????
                }
            }
            poolStakeInfo.lastRewardBlock = block.number;//??????????????????
            if (finishRewardCount == _poolRewardInfos.length) {//??????????????????
                poolStakeInfo.endBlock = block.number;//??????????????????
                emit EndPool(poolId);//??????????????????
            }
        }else {
            for(uint i = 0; i < _poolRewardInfos.length; i++) {
                rewardPerShares[i] = _poolRewardInfos[i].rewardPerShare;
            }
        }
        return rewardPerShares;
    }
    
    function addPower(uint256 poolId, address user, uint256 amount, uint256 powerRatio, address upper1, address upper2) internal {

        uint256 power = amount.div(powerRatio);
        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];//??????????????????
        poolStakeInfo.amount = poolStakeInfo.amount.add(amount);//????????????????????????
        poolStakeInfo.totalPower = poolStakeInfo.totalPower.add(power);//?????????????????????
        UserStakeInfo storage userStakeInfo = userStakeInfos[poolId][user];//sender????????????
        userStakeInfo.amount = userStakeInfo.amount.add(amount);//??????sender????????????
        userStakeInfo.stakePower = userStakeInfo.stakePower.add(power);//??????sender????????????
        if (0 == userStakeInfo.startBlock) {
            userStakeInfo.startBlock = block.number;//??????????????????
        }
        uint256 upper1InvitePower = 0;//upper1????????????
        uint256 upper2InvitePower = 0;//upper2????????????
        if (ZERO != upper1) {
            uint256 inviteSelfPower = power.mul(INVITE_SELF_REWARD).div(100);//??????sender???????????????
            userStakeInfo.invitePower = userStakeInfo.invitePower.add(inviteSelfPower);//??????sender????????????
            poolStakeInfo.totalPower = poolStakeInfo.totalPower.add(inviteSelfPower);//?????????????????????
            uint256 invite1Power = power.mul(INVITE1_REWARD).div(100);//??????upper1????????????
            UserStakeInfo storage upper1StakeInfo = userStakeInfos[poolId][upper1];//upper1????????????
            upper1StakeInfo.invitePower = upper1StakeInfo.invitePower.add(invite1Power);//??????upper1????????????
            upper1InvitePower = upper1StakeInfo.invitePower;
            poolStakeInfo.totalPower = poolStakeInfo.totalPower.add(invite1Power);//?????????????????????
            if (0 == upper1StakeInfo.startBlock) {
                upper1StakeInfo.startBlock = block.number;//??????????????????
            }
            
        }
        if (ZERO != upper2) {
            uint256 invite2Power = power.mul(INVITE2_REWARD).div(100);//??????upper2????????????
            UserStakeInfo storage upper2StakeInfo = userStakeInfos[poolId][upper2];//upper2????????????
            upper2StakeInfo.invitePower = upper2StakeInfo.invitePower.add(invite2Power);//??????upper2????????????
            upper2InvitePower = upper2StakeInfo.invitePower;
            poolStakeInfo.totalPower = poolStakeInfo.totalPower.add(invite2Power);//?????????????????????
            if (0 == upper2StakeInfo.startBlock) {
                upper2StakeInfo.startBlock = block.number;//??????????????????
            }
        }
        emit UpdatePower(poolId, poolStakeInfo.token, poolStakeInfo.totalPower, user, userStakeInfo.invitePower, userStakeInfo.stakePower, upper1, upper1InvitePower, upper2, upper2InvitePower);//??????????????????
    }

    function subPower(uint256 poolId, address user, uint256 amount, uint256 powerRatio, address upper1, address upper2) internal {

        uint256 power = amount.div(powerRatio);
        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];//??????????????????
        if (poolStakeInfo.amount <= amount) {
            poolStakeInfo.amount = 0;//???????????????????????????
        }else {
            poolStakeInfo.amount = poolStakeInfo.amount.sub(amount);//???????????????????????????
        }
        if (poolStakeInfo.totalPower <= power) {
            poolStakeInfo.totalPower = 0;//?????????????????????
        }else {
            poolStakeInfo.totalPower = poolStakeInfo.totalPower.sub(power);//?????????????????????
        }
        UserStakeInfo storage userStakeInfo = userStakeInfos[poolId][user];//sender????????????
        userStakeInfo.amount = userStakeInfo.amount.sub(amount);//??????sender????????????
        if (userStakeInfo.stakePower <= power) {
            userStakeInfo.stakePower = 0;//??????sender????????????
        }else {
            userStakeInfo.stakePower = userStakeInfo.stakePower.sub(power);//??????sender????????????
        }
        uint256 upper1InvitePower = 0;
        uint256 upper2InvitePower = 0;
        if (ZERO != upper1) {
            uint256 inviteSelfPower = power.mul(INVITE_SELF_REWARD).div(100);//sender???????????????
            if (poolStakeInfo.totalPower <= inviteSelfPower) {
                poolStakeInfo.totalPower = 0;//????????????sender???????????????
            }else {
                poolStakeInfo.totalPower = poolStakeInfo.totalPower.sub(inviteSelfPower);//????????????sender???????????????
            }
            if (userStakeInfo.invitePower <= inviteSelfPower) {
                userStakeInfo.invitePower = 0;//??????sender???????????????
            }else {
                userStakeInfo.invitePower = userStakeInfo.invitePower.sub(inviteSelfPower);//??????sender???????????????
            }
            uint256 invite1Power = power.mul(INVITE1_REWARD).div(100);//upper1????????????
            if (poolStakeInfo.totalPower <= invite1Power) {
                poolStakeInfo.totalPower = 0;//????????????upper1????????????
            }else {
                poolStakeInfo.totalPower = poolStakeInfo.totalPower.sub(invite1Power);//????????????upper1????????????
            }
            UserStakeInfo storage upper1StakeInfo = userStakeInfos[poolId][upper1];
            if (upper1StakeInfo.invitePower <= invite1Power) {
                upper1StakeInfo.invitePower = 0;//??????upper1????????????
            }else {
                upper1StakeInfo.invitePower = upper1StakeInfo.invitePower.sub(invite1Power);//??????upper1????????????
            }
            upper1InvitePower = upper1StakeInfo.invitePower;
        }
        if (ZERO != upper2) {
                uint256 invite2Power = power.mul(INVITE2_REWARD).div(100);//upper2????????????
                if (poolStakeInfo.totalPower <= invite2Power) {
                    poolStakeInfo.totalPower = 0;//????????????upper2????????????
                }else {
                    poolStakeInfo.totalPower = poolStakeInfo.totalPower.sub(invite2Power);//????????????upper2????????????
                }
                UserStakeInfo storage upper2StakeInfo = userStakeInfos[poolId][upper2];
                if (upper2StakeInfo.invitePower <= invite2Power) {
                    upper2StakeInfo.invitePower = 0;//??????upper2????????????
                }else {
                    upper2StakeInfo.invitePower = upper2StakeInfo.invitePower.sub(invite2Power);//??????upper2????????????
                }
                upper2InvitePower = upper2StakeInfo.invitePower;
        }
        emit UpdatePower(poolId, poolStakeInfo.token, poolStakeInfo.totalPower, user, userStakeInfo.invitePower, userStakeInfo.stakePower, upper1, upper1InvitePower, upper2, upper2InvitePower);
    }
    
    function provideReward(uint256 poolId, uint256[] memory rewardPerShares, address user, address upper1, address upper2) internal {

        uint256 reward = 0;
        uint256 inviteReward = 0;
        uint256 stakeReward = 0;
        uint256 rewardPerShare = 0;
        address token;
        UserStakeInfo storage userStakeInfo = userStakeInfos[poolId][user];
        PoolRewardInfo[] memory _poolRewardInfos = poolRewardInfos[poolId];
        for(uint i = 0; i < _poolRewardInfos.length; i++) {
            token = _poolRewardInfos[i].token;//????????????token
            rewardPerShare = rewardPerShares[i];//????????????????????????
            if ((0 < userStakeInfo.invitePower) || (0 < userStakeInfo.stakePower)) {
                inviteReward = userStakeInfo.invitePower.mul(rewardPerShare).sub(userStakeInfo.inviteRewardDebts[i]).div(1e24);//????????????
                stakeReward = userStakeInfo.stakePower.mul(rewardPerShare).sub(userStakeInfo.stakeRewardDebts[i]).div(1e24);//????????????
                inviteReward = userStakeInfo.invitePendingRewards[i].add(inviteReward);//???????????????
                stakeReward = userStakeInfo.stakePendingRewards[i].add(stakeReward);//???????????????
                reward = inviteReward.add(stakeReward);
            }
            if (0 < reward) {
                userStakeInfo.invitePendingRewards[i] = 0;//?????????????????????
                userStakeInfo.stakePendingRewards[i] = 0;//?????????????????????
                userReceiveRewards[token][user] = userReceiveRewards[token][user].add(reward);//?????????????????????
                if (address(you) == token) {//you
                    you.mint(user, reward);//???you
                }else {//???you
                    tokenPendingRewards[token] = tokenPendingRewards[token].sub(reward);//??????????????????
                    IERC20(token).safeTransfer(user, reward);//????????????
                }
                emit WithdrawReward(poolId, token, user, inviteReward, stakeReward);
            }
            if (ZERO != upper1) {
                UserStakeInfo storage upper1StakeInfo = userStakeInfos[poolId][upper1];
                if ((0 < upper1StakeInfo.invitePower) || (0 < upper1StakeInfo.stakePower)) {
                    inviteReward = upper1StakeInfo.invitePower.mul(rewardPerShare).sub(upper1StakeInfo.inviteRewardDebts[i]).div(1e24);//????????????
                    stakeReward = upper1StakeInfo.stakePower.mul(rewardPerShare).sub(upper1StakeInfo.stakeRewardDebts[i]).div(1e24);//????????????
                    upper1StakeInfo.invitePendingRewards[i] = upper1StakeInfo.invitePendingRewards[i].add(inviteReward);//???????????????
                    upper1StakeInfo.stakePendingRewards[i] = upper1StakeInfo.stakePendingRewards[i].add(stakeReward);//???????????????
                }
            }
            if (ZERO != upper2) {
                UserStakeInfo storage upper2StakeInfo = userStakeInfos[poolId][upper2];
                if ((0 < upper2StakeInfo.invitePower) || (0 < upper2StakeInfo.stakePower)) {
                    inviteReward = upper2StakeInfo.invitePower.mul(rewardPerShare).sub(upper2StakeInfo.inviteRewardDebts[i]).div(1e24);//????????????
                    stakeReward = upper2StakeInfo.stakePower.mul(rewardPerShare).sub(upper2StakeInfo.stakeRewardDebts[i]).div(1e24);//????????????
                    upper2StakeInfo.invitePendingRewards[i] = upper2StakeInfo.invitePendingRewards[i].add(inviteReward);//???????????????
                    upper2StakeInfo.stakePendingRewards[i] = upper2StakeInfo.stakePendingRewards[i].add(stakeReward);//???????????????
                }
            }
        }
    }

    function setRewardDebt(uint256 poolId, uint256[] memory rewardPerShares, address user, address upper1, address upper2) internal {

        uint256 rewardPerShare = 0;
        UserStakeInfo storage userStakeInfo = userStakeInfos[poolId][user];
        for(uint i = 0; i < rewardPerShares.length; i++) {
            rewardPerShare = rewardPerShares[i];//????????????????????????
            userStakeInfo.inviteRewardDebts[i] = userStakeInfo.invitePower.mul(rewardPerShare);//??????sender????????????
            userStakeInfo.stakeRewardDebts[i] = userStakeInfo.stakePower.mul(rewardPerShare);//??????sender????????????
            if (ZERO != upper1) {
                UserStakeInfo storage upper1StakeInfo = userStakeInfos[poolId][upper1];
                upper1StakeInfo.inviteRewardDebts[i] = upper1StakeInfo.invitePower.mul(rewardPerShare);//??????upper1????????????
                upper1StakeInfo.stakeRewardDebts[i] = upper1StakeInfo.stakePower.mul(rewardPerShare);//??????upper1????????????
                if (ZERO != upper2) {
                    UserStakeInfo storage upper2StakeInfo = userStakeInfos[poolId][upper2];
                    upper2StakeInfo.inviteRewardDebts[i] = upper2StakeInfo.invitePower.mul(rewardPerShare);//??????upper2????????????
                    upper2StakeInfo.stakeRewardDebts[i] = upper2StakeInfo.stakePower.mul(rewardPerShare);//??????upper2????????????
                }
            }
        }
    }

    function sendUpdatePoolEvent(bool action, uint256 poolId) internal {

        PoolViewInfo memory poolViewInfo = poolViewInfos[poolId];
        PoolStakeInfo memory poolStakeInfo = poolStakeInfos[poolId];
        PoolRewardInfo[] memory _poolRewardInfos = poolRewardInfos[poolId];
        address[] memory tokens = new address[](_poolRewardInfos.length);
        uint256[] memory _rewardTotals = new uint256[](_poolRewardInfos.length);
        uint256[] memory rewardPerBlocks = new uint256[](_poolRewardInfos.length);
        for(uint i = 0; i < _poolRewardInfos.length; i++) {
            tokens[i] = _poolRewardInfos[i].token;
            _rewardTotals[i] = _poolRewardInfos[i].rewardTotal;
            rewardPerBlocks[i] = _poolRewardInfos[i].rewardPerBlock;
        }
        emit UpdatePool(action, poolId, poolViewInfo.name, poolStakeInfo.token, poolStakeInfo.powerRatio, poolStakeInfo.maxStakeAmount, poolStakeInfo.startBlock, poolViewInfo.multiple, poolViewInfo.priority, tokens, _rewardTotals, rewardPerBlocks);
    }

    function _unStake(uint256 poolId, uint256 amount) internal {        

        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];
        require((ZERO != poolStakeInfo.token) && (poolStakeInfo.startBlock <= block.number), "YouSwap:POOL_NOT_EXIST_OR_MINING_NOT_START");
        require((0 < amount) && (userStakeInfos[poolId][msg.sender].amount >= amount), "YouSwap:BALANCE_INSUFFICIENT");
        (address upper1, address upper2) = invite.inviteUpper2(msg.sender);
        initRewardInfo(poolId, msg.sender, upper1, upper2);
        uint256[] memory rewardPerShares = computeReward(poolId);//??????????????????????????????
        provideReward(poolId, rewardPerShares, msg.sender, upper1, upper2);//???sender??????????????????upper1???upper2?????????????????????
        subPower(poolId, msg.sender, amount, poolStakeInfo.powerRatio, upper1, upper2);//????????????
        setRewardDebt(poolId, rewardPerShares, msg.sender, upper1, upper2);//??????sender???upper1???upper2??????
        IERC20(poolStakeInfo.token).safeTransfer(msg.sender, amount);//?????????token
        emit UnStake(poolId, poolStakeInfo.token, msg.sender, amount);
    }    

    function _withdrawReward(uint256 poolId) internal {

        PoolStakeInfo storage poolStakeInfo = poolStakeInfos[poolId];
        require((ZERO != poolStakeInfo.token) && (poolStakeInfo.startBlock <= block.number), "YouSwap:POOL_NOT_EXIST_OR_MINING_NOT_START");
        (address upper1, address upper2) = invite.inviteUpper2(msg.sender);
        initRewardInfo(poolId, msg.sender, upper1, upper2);
        uint256[] memory rewardPerShares = computeReward(poolId);//??????????????????????????????
        provideReward(poolId, rewardPerShares, msg.sender, upper1, upper2);//???sender??????????????????upper1???upper2?????????????????????
        setRewardDebt(poolId, rewardPerShares, msg.sender, upper1, upper2);//??????sender???upper1???upper2??????
    }
    
    function initRewardInfo(uint256 poolId, address user, address upper1, address upper2) internal {

        uint count = poolRewardInfos[poolId].length;
        UserStakeInfo storage userStakeInfo = userStakeInfos[poolId][user];
        if (0 == userStakeInfo.invitePendingRewards.length) {
            for(uint i = 0; i < count; i++) {
                userStakeInfo.invitePendingRewards.push(0);//????????????????????????
                userStakeInfo.stakePendingRewards.push(0);//????????????????????????
                userStakeInfo.inviteRewardDebts.push(0);//?????????????????????
                userStakeInfo.stakeRewardDebts.push(0);//?????????????????????
            }
        }
        if (ZERO != upper1) {
            UserStakeInfo storage upper1StakeInfo = userStakeInfos[poolId][upper1];
            if (0 == upper1StakeInfo.invitePendingRewards.length) {
                for(uint i = 0; i < count; i++) {
                    upper1StakeInfo.invitePendingRewards.push(0);//????????????????????????
                    upper1StakeInfo.stakePendingRewards.push(0);//????????????????????????
                    upper1StakeInfo.inviteRewardDebts.push(0);//?????????????????????
                    upper1StakeInfo.stakeRewardDebts.push(0);//?????????????????????
                }
            }
            if (ZERO != upper2) {
                UserStakeInfo storage upper2StakeInfo = userStakeInfos[poolId][upper2];
                if (0 == upper2StakeInfo.invitePendingRewards.length) {
                    for(uint i = 0; i < count; i++) {
                        upper2StakeInfo.invitePendingRewards.push(0);//????????????????????????
                        upper2StakeInfo.stakePendingRewards.push(0);//????????????????????????
                        upper2StakeInfo.inviteRewardDebts.push(0);//?????????????????????
                        upper2StakeInfo.stakeRewardDebts.push(0);//?????????????????????
                    }
                }
            }
        }
    }

}