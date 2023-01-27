


pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {



        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract ReentrancyGuard {

    bool private _ENTERED_;

    modifier preventReentrant() {

        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}


library DecimalMath {

    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d).divCeil(10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(10**18).divCeil(d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {

        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {

        return uint256(10**36).divCeil(target);
    }
}


contract InitializableOwnable {

    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier notInitialized() {

        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    function initOwner(address newOwner) public notInitialized {

        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}


contract Ownable {

    address public _OWNER_;
    address public _NEW_OWNER_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    constructor() internal {
        _OWNER_ = msg.sender;
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() external {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}



interface IRewardVault {

    function reward(address to, uint256 amount) external;

    function withdrawLeftOver(address to, uint256 amount) external; 

    function syncValue() external;

    function _TOTAL_REWARD_() external view returns(uint256);

}

contract RewardVault is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public _REWARD_RESERVE_;
    uint256 public _TOTAL_REWARD_;
    address public _REWARD_TOKEN_;

    event DepositReward(uint256 totalReward, uint256 inputReward, uint256 rewardReserve);

    constructor(address _rewardToken) public {
        _REWARD_TOKEN_ = _rewardToken;
    }

    function reward(address to, uint256 amount) external onlyOwner {

        require(_REWARD_RESERVE_ >= amount, "VAULT_NOT_ENOUGH");
        _REWARD_RESERVE_ = _REWARD_RESERVE_.sub(amount);
        IERC20(_REWARD_TOKEN_).safeTransfer(to, amount);
    }

    function withdrawLeftOver(address to,uint256 amount) external onlyOwner {

        require(_REWARD_RESERVE_ >= amount, "VAULT_NOT_ENOUGH");
        _REWARD_RESERVE_ = _REWARD_RESERVE_.sub(amount);
        IERC20(_REWARD_TOKEN_).safeTransfer(to, amount);
    }

    function syncValue() external {

        uint256 rewardBalance = IERC20(_REWARD_TOKEN_).balanceOf(address(this));
        uint256 rewardInput = rewardBalance.sub(_REWARD_RESERVE_);

        _TOTAL_REWARD_ = _TOTAL_REWARD_.add(rewardInput);
        _REWARD_RESERVE_ = rewardBalance;

        emit DepositReward(_TOTAL_REWARD_, rewardInput, _REWARD_RESERVE_);
    }
}




contract BaseMine is InitializableOwnable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    struct RewardTokenInfo {
        address rewardToken;
        uint256 startBlock;
        uint256 endBlock;
        address rewardVault;
        uint256 rewardPerBlock;
        uint256 accRewardPerShare;
        uint256 lastRewardBlock;
        uint256 workThroughReward;
        uint256 lastFlagBlock;
        mapping(address => uint256) userRewardPerSharePaid;
        mapping(address => uint256) userRewards;
    }

    RewardTokenInfo[] public rewardTokenInfos;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;


    event Claim(uint256 indexed i, address indexed user, uint256 reward);
    event UpdateReward(uint256 indexed i, uint256 rewardPerBlock);
    event UpdateEndBlock(uint256 indexed i, uint256 endBlock);
    event NewRewardToken(uint256 indexed i, address rewardToken);
    event RemoveRewardToken(address rewardToken);
    event WithdrawLeftOver(address owner, uint256 i);


    function getPendingReward(address user, uint256 i) public view returns (uint256) {

        require(i<rewardTokenInfos.length, "DODOMineV3: REWARD_ID_NOT_FOUND");
        RewardTokenInfo storage rt = rewardTokenInfos[i];
        uint256 accRewardPerShare = rt.accRewardPerShare;
        if (rt.lastRewardBlock != block.number) {
            accRewardPerShare = _getAccRewardPerShare(i);
        }
        return
            DecimalMath.mulFloor(
                balanceOf(user), 
                accRewardPerShare.sub(rt.userRewardPerSharePaid[user])
            ).add(rt.userRewards[user]);
    }

    function getPendingRewardByToken(address user, address rewardToken) external view returns (uint256) {

        return getPendingReward(user, getIdByRewardToken(rewardToken));
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address user) public view returns (uint256) {

        return _balances[user];
    }

    function getRewardTokenById(uint256 i) external view returns (address) {

        require(i<rewardTokenInfos.length, "DODOMineV3: REWARD_ID_NOT_FOUND");
        RewardTokenInfo memory rt = rewardTokenInfos[i];
        return rt.rewardToken;
    }

    function getIdByRewardToken(address rewardToken) public view returns(uint256) {

        uint256 len = rewardTokenInfos.length;
        for (uint256 i = 0; i < len; i++) {
            if (rewardToken == rewardTokenInfos[i].rewardToken) {
                return i;
            }
        }
        require(false, "DODOMineV3: TOKEN_NOT_FOUND");
    }

    function getRewardNum() external view returns(uint256) {

        return rewardTokenInfos.length;
    }

    function getVaultByRewardToken(address rewardToken) public view returns(address) {

        uint256 len = rewardTokenInfos.length;
        for (uint256 i = 0; i < len; i++) {
            if (rewardToken == rewardTokenInfos[i].rewardToken) {
                return rewardTokenInfos[i].rewardVault;
            }
        }
        require(false, "DODOMineV3: TOKEN_NOT_FOUND");
    }

    function getVaultDebtByRewardToken(address rewardToken) public view returns(uint256) {

        uint256 len = rewardTokenInfos.length;
        for (uint256 i = 0; i < len; i++) {
            if (rewardToken == rewardTokenInfos[i].rewardToken) {
                uint256 totalDepositReward = IRewardVault(rewardTokenInfos[i].rewardVault)._TOTAL_REWARD_();
                uint256 gap = rewardTokenInfos[i].endBlock.sub(rewardTokenInfos[i].lastFlagBlock);
                uint256 totalReward = rewardTokenInfos[i].workThroughReward.add(gap.mul(rewardTokenInfos[i].rewardPerBlock));
                if(totalDepositReward >= totalReward) {
                    return 0;
                }else {
                    return totalReward.sub(totalDepositReward);
                }
            }
        }
        require(false, "DODOMineV3: TOKEN_NOT_FOUND");
    }


    function claimReward(uint256 i) public {

        require(i<rewardTokenInfos.length, "DODOMineV3: REWARD_ID_NOT_FOUND");
        _updateReward(msg.sender, i);
        RewardTokenInfo storage rt = rewardTokenInfos[i];
        uint256 reward = rt.userRewards[msg.sender];
        if (reward > 0) {
            rt.userRewards[msg.sender] = 0;
            IRewardVault(rt.rewardVault).reward(msg.sender, reward);
            emit Claim(i, msg.sender, reward);
        }
    }

    function claimAllRewards() external {

        uint256 len = rewardTokenInfos.length;
        for (uint256 i = 0; i < len; i++) {
            claimReward(i);
        }
    }


    function addRewardToken(
        address rewardToken,
        uint256 rewardPerBlock,
        uint256 startBlock,
        uint256 endBlock
    ) external onlyOwner {

        require(rewardToken != address(0), "DODOMineV3: TOKEN_INVALID");
        require(startBlock > block.number, "DODOMineV3: START_BLOCK_INVALID");
        require(endBlock > startBlock, "DODOMineV3: DURATION_INVALID");

        uint256 len = rewardTokenInfos.length;
        for (uint256 i = 0; i < len; i++) {
            require(
                rewardToken != rewardTokenInfos[i].rewardToken,
                "DODOMineV3: TOKEN_ALREADY_ADDED"
            );
        }

        RewardTokenInfo storage rt = rewardTokenInfos.push();
        rt.rewardToken = rewardToken;
        rt.startBlock = startBlock;
        rt.lastFlagBlock = startBlock;
        rt.endBlock = endBlock;
        rt.rewardPerBlock = rewardPerBlock;
        rt.rewardVault = address(new RewardVault(rewardToken));

        uint256 rewardAmount = rewardPerBlock.mul(endBlock.sub(startBlock));
        IERC20(rewardToken).safeTransfer(rt.rewardVault, rewardAmount);
        RewardVault(rt.rewardVault).syncValue();

        emit NewRewardToken(len, rewardToken);
    }

    function setEndBlock(uint256 i, uint256 newEndBlock)
        external
        onlyOwner
    {

        require(i < rewardTokenInfos.length, "DODOMineV3: REWARD_ID_NOT_FOUND");
        _updateReward(address(0), i);
        RewardTokenInfo storage rt = rewardTokenInfos[i];


        uint256 totalDepositReward = RewardVault(rt.rewardVault)._TOTAL_REWARD_();
        uint256 gap = newEndBlock.sub(rt.lastFlagBlock);
        uint256 totalReward = rt.workThroughReward.add(gap.mul(rt.rewardPerBlock));
        require(totalDepositReward >= totalReward, "DODOMineV3: REWARD_NOT_ENOUGH");

        require(block.number < newEndBlock, "DODOMineV3: END_BLOCK_INVALID");
        require(block.number > rt.startBlock, "DODOMineV3: NOT_START");
        require(block.number < rt.endBlock, "DODOMineV3: ALREADY_CLOSE");

        rt.endBlock = newEndBlock;
        emit UpdateEndBlock(i, newEndBlock);
    }

    function setReward(uint256 i, uint256 newRewardPerBlock)
        external
        onlyOwner
    {

        require(i < rewardTokenInfos.length, "DODOMineV3: REWARD_ID_NOT_FOUND");
        _updateReward(address(0), i);
        RewardTokenInfo storage rt = rewardTokenInfos[i];
        
        require(block.number < rt.endBlock, "DODOMineV3: ALREADY_CLOSE");
        
        rt.workThroughReward = rt.workThroughReward.add((block.number.sub(rt.lastFlagBlock)).mul(rt.rewardPerBlock));
        rt.rewardPerBlock = newRewardPerBlock;
        rt.lastFlagBlock = block.number;

        uint256 totalDepositReward = RewardVault(rt.rewardVault)._TOTAL_REWARD_();
        uint256 gap = rt.endBlock.sub(block.number);
        uint256 totalReward = rt.workThroughReward.add(gap.mul(newRewardPerBlock));
        require(totalDepositReward >= totalReward, "DODOMineV3: REWARD_NOT_ENOUGH");

        emit UpdateReward(i, newRewardPerBlock);
    }

    function withdrawLeftOver(uint256 i, uint256 amount) external onlyOwner {

        require(i < rewardTokenInfos.length, "DODOMineV3: REWARD_ID_NOT_FOUND");
        
        RewardTokenInfo storage rt = rewardTokenInfos[i];
        require(block.number > rt.endBlock, "DODOMineV3: MINING_NOT_FINISHED");
        
        uint256 gap = rt.endBlock.sub(rt.lastFlagBlock);
        uint256 totalReward = rt.workThroughReward.add(gap.mul(rt.rewardPerBlock));
        uint256 totalDepositReward = IRewardVault(rt.rewardVault)._TOTAL_REWARD_();
        require(amount <= totalDepositReward.sub(totalReward), "DODOMineV3: NOT_ENOUGH");

        IRewardVault(rt.rewardVault).withdrawLeftOver(msg.sender,amount);

        emit WithdrawLeftOver(msg.sender, i);
    }


    function directTransferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "DODOMineV3: ZERO_ADDRESS");
        emit OwnershipTransferred(_OWNER_, newOwner);
        _OWNER_ = newOwner;
    }


    function _updateReward(address user, uint256 i) internal {

        RewardTokenInfo storage rt = rewardTokenInfos[i];
        if (rt.lastRewardBlock != block.number){
            rt.accRewardPerShare = _getAccRewardPerShare(i);
            rt.lastRewardBlock = block.number;
        }
        if (user != address(0)) {
            rt.userRewards[user] = getPendingReward(user, i);
            rt.userRewardPerSharePaid[user] = rt.accRewardPerShare;
        }
    }

    function _updateAllReward(address user) internal {

        uint256 len = rewardTokenInfos.length;
        for (uint256 i = 0; i < len; i++) {
            _updateReward(user, i);
        }
    }

    function _getUnrewardBlockNum(uint256 i) internal view returns (uint256) {

        RewardTokenInfo memory rt = rewardTokenInfos[i];
        if (block.number < rt.startBlock || rt.lastRewardBlock > rt.endBlock) {
            return 0;
        }
        uint256 start = rt.lastRewardBlock < rt.startBlock ? rt.startBlock : rt.lastRewardBlock;
        uint256 end = rt.endBlock < block.number ? rt.endBlock : block.number;
        return end.sub(start);
    }

    function _getAccRewardPerShare(uint256 i) internal view returns (uint256) {

        RewardTokenInfo memory rt = rewardTokenInfos[i];
        if (totalSupply() == 0) {
            return rt.accRewardPerShare;
        }
        return
            rt.accRewardPerShare.add(
                DecimalMath.divFloor(_getUnrewardBlockNum(i).mul(rt.rewardPerBlock), totalSupply())
            );
    }

}




contract ERC20MineV3 is ReentrancyGuard, BaseMine {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    address public _TOKEN_;

    function init(address owner, address token) external {

        super.initOwner(owner);
        _TOKEN_ = token;
    }


    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);


    function deposit(uint256 amount) external preventReentrant {

        require(amount > 0, "DODOMineV3: CANNOT_DEPOSIT_ZERO");

        _updateAllReward(msg.sender);

        uint256 erc20OriginBalance = IERC20(_TOKEN_).balanceOf(address(this));
        IERC20(_TOKEN_).safeTransferFrom(msg.sender, address(this), amount);
        uint256 actualStakeAmount = IERC20(_TOKEN_).balanceOf(address(this)).sub(erc20OriginBalance);
        
        _totalSupply = _totalSupply.add(actualStakeAmount);
        _balances[msg.sender] = _balances[msg.sender].add(actualStakeAmount);

        emit Deposit(msg.sender, actualStakeAmount);
    }

    function withdraw(uint256 amount) external preventReentrant {

        require(amount > 0, "DODOMineV3: CANNOT_WITHDRAW_ZERO");

        _updateAllReward(msg.sender);
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        IERC20(_TOKEN_).safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }
}