




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
}





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
}






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





abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




contract ProxyStorage {

    bool public initalized;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(uint144 => uint256) attributes_Depricated;

    address owner_;
    address pendingOwner_;

    mapping(address => address) public delegates; // A record of votes checkpoints for each account, by index
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints; // A record of votes checkpoints for each account, by index
    mapping(address => uint32) public numCheckpoints; // The number of checkpoints for each account
    mapping(address => uint256) public nonces;

}








abstract contract ERC20 is ProxyStorage, Context {
    using SafeMath for uint256;
    using Address for address;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


    function name() public virtual pure returns (string memory);

    function symbol() public virtual pure returns (string memory);

    function decimals() public virtual pure returns (uint8) {
        return 18;
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowance[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowance[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        balanceOf[sender] = balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply = totalSupply.add(amount);
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        balanceOf[account] = balanceOf[account].sub(amount, "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}





interface IVoteToken {

    function delegate(address delegatee) external;


    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function getCurrentVotes(address account) external view returns (uint96);


    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);

}

interface IVoteTokenWithERC20 is IVoteToken, IERC20 {}







abstract contract VoteToken is ERC20, IVoteToken {
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    function delegate(address delegatee) public override {

        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "TrustToken::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "TrustToken::delegateBySig: invalid nonce");
        require(now <= expiry, "TrustToken::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) public virtual override view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) public virtual override view returns (uint96) {
        require(blockNumber < block.number, "TrustToken::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = safe96(_balanceOf(delegator), "StkTruToken: uint96 overflow");
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _balanceOf(address account) internal view virtual returns (uint256) {
        return balanceOf[account];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal virtual override {
        super._transfer(_from, _to, _value);
        _moveDelegates(delegates[_from], delegates[_to], safe96(_value, "StkTruToken: uint96 overflow"));
    }

    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);
        _moveDelegates(address(0), delegates[account], safe96(amount, "StkTruToken: uint96 overflow"));
    }

    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);
        _moveDelegates(delegates[account], address(0), safe96(amount, "StkTruToken: uint96 overflow"));
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "TrustToken::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "TrustToken::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {
        uint32 blockNumber = safe32(block.number, "TrustToken::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}





interface ITrueDistributor {

    function trustToken() external view returns (IERC20);


    function farm() external view returns (address);


    function distribute() external;


    function nextDistribution() external view returns (uint256);


    function empty() external;

}





contract StkClaimableContract is ProxyStorage {

    function owner() public view returns (address) {

        return owner_;
    }

    function pendingOwner() public view returns (address) {

        return pendingOwner_;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner_ = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {

        require(msg.sender == owner_, "only owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner_);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner_ = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        address _pendingOwner = pendingOwner_;
        emit OwnershipTransferred(owner_, _pendingOwner);
        owner_ = _pendingOwner;
        pendingOwner_ = address(0);
    }
}





interface IPauseableContract {

    function setPauseStatus(bool pauseStatus) external;

}



pragma solidity 0.6.10;



contract StkTruToken is VoteToken, StkClaimableContract, IPauseableContract, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 private constant PRECISION = 1e30;
    uint256 private constant MIN_DISTRIBUTED_AMOUNT = 100e8;

    struct FarmRewards {
        uint256 cumulativeRewardPerToken;
        mapping(address => uint256) previousCumulatedRewardPerToken;
        mapping(address => uint256) claimableReward;
        uint256 totalClaimedRewards;
        uint256 totalFarmRewards;
    }

    struct ScheduledTfUsdRewards {
        uint64 timestamp;
        uint96 amount;
    }


    IERC20 public tru;
    IERC20 public tfusd;
    ITrueDistributor public distributor;
    address public liquidator;

    uint256 public stakeSupply;

    mapping(address => uint256) private cooldowns;
    uint256 public cooldownTime;
    uint256 public unstakePeriodDuration;

    mapping(IERC20 => FarmRewards) public farmRewards;

    uint32[] public sortedScheduledRewardIndices;
    ScheduledTfUsdRewards[] public scheduledRewards;
    uint256 public undistributedTfusdRewards;
    uint32 public nextDistributionIndex;

    mapping(address => bool) public whitelistedFeePayers;

    mapping(address => uint256) public receivedDuringCooldown;

    bool public pauseStatus;

    IERC20 public feeToken;


    event Stake(address indexed staker, uint256 amount);
    event Unstake(address indexed staker, uint256 burntAmount);
    event Claim(address indexed who, IERC20 indexed token, uint256 amountClaimed);
    event Withdraw(uint256 amount);
    event Cooldown(address indexed who, uint256 endTime);
    event CooldownTimeChanged(uint256 newUnstakePeriodDuration);
    event UnstakePeriodDurationChanged(uint256 newUnstakePeriodDuration);
    event FeePayerWhitelistingStatusChanged(address payer, bool status);
    event PauseStatusChanged(bool pauseStatus);
    event FeeTokenChanged(IERC20 token);
    event LiquidatorChanged(address liquidator);

    modifier joiningNotPaused() {

        require(!pauseStatus, "StkTruToken: Joining the pool is paused");
        _;
    }

    modifier onlyLiquidator() {

        require(msg.sender == liquidator, "StkTruToken: Can be called only by the liquidator");
        _;
    }

    modifier onlyWhitelistedPayers() {

        require(whitelistedFeePayers[msg.sender], "StkTruToken: Can be called only by whitelisted payers");
        _;
    }

    modifier distribute() {

        if (distributor.nextDistribution() > MIN_DISTRIBUTED_AMOUNT && distributor.farm() == address(this)) {
            distributor.distribute();
        }
        _;
    }

    modifier update(address account) {

        updateTotalRewards(tru);
        updateClaimableRewards(tru, account);
        updateTotalRewards(tfusd);
        updateClaimableRewards(tfusd, account);
        updateTotalRewards(feeToken);
        updateClaimableRewards(feeToken, account);
        _;
    }

    modifier updateRewards(address account, IERC20 token) {

        if (token == tru) {
            updateTotalRewards(tru);
            updateClaimableRewards(tru, account);
        } else if (token == tfusd) {
            updateTotalRewards(tfusd);
            updateClaimableRewards(tfusd, account);
        } else if (token == feeToken) {
            updateTotalRewards(feeToken);
            updateClaimableRewards(feeToken, account);
        }
        _;
    }

    function initialize(
        IERC20 _tru,
        IERC20 _tfusd,
        IERC20 _feeToken,
        ITrueDistributor _distributor,
        address _liquidator
    ) public {

        require(!initalized, "StkTruToken: Already initialized");
        tru = _tru;
        tfusd = _tfusd;
        feeToken = _feeToken;
        distributor = _distributor;
        liquidator = _liquidator;

        cooldownTime = 14 days;
        unstakePeriodDuration = 2 days;

        owner_ = msg.sender;
        initalized = true;
    }

    function setFeeToken(IERC20 _feeToken) external onlyOwner {

        require(rewardBalance(feeToken) == 0, "StkTruToken: Cannot replace fee token with underlying rewards");
        feeToken = _feeToken;
        emit FeeTokenChanged(_feeToken);
    }

    function setLiquidator(address _liquidator) external onlyOwner {

        liquidator = _liquidator;
        emit LiquidatorChanged(_liquidator);
    }

    function setPayerWhitelistingStatus(address payer, bool status) external onlyOwner {

        whitelistedFeePayers[payer] = status;
        emit FeePayerWhitelistingStatusChanged(payer, status);
    }

    function setCooldownTime(uint256 newCooldownTime) external onlyOwner {

        require(newCooldownTime <= 100 * 365 days, "StkTruToken: Cooldown too large");

        cooldownTime = newCooldownTime;
        emit CooldownTimeChanged(newCooldownTime);
    }

    function setPauseStatus(bool status) external override onlyOwner {

        pauseStatus = status;
        emit PauseStatusChanged(status);
    }

    function setUnstakePeriodDuration(uint256 newUnstakePeriodDuration) external onlyOwner {

        require(newUnstakePeriodDuration > 0, "StkTruToken: Unstake period cannot be 0");
        require(newUnstakePeriodDuration <= 100 * 365 days, "StkTruToken: Unstake period too large");

        unstakePeriodDuration = newUnstakePeriodDuration;
        emit UnstakePeriodDurationChanged(newUnstakePeriodDuration);
    }

    function stake(uint256 amount) external distribute update(msg.sender) joiningNotPaused {

        _stakeWithoutTransfer(amount);
        tru.safeTransferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint256 amount) external distribute update(msg.sender) nonReentrant {

        require(amount > 0, "StkTruToken: Cannot unstake 0");

        require(unstakable(msg.sender) >= amount, "StkTruToken: Insufficient balance");
        require(unlockTime(msg.sender) <= block.timestamp, "StkTruToken: Stake on cooldown");

        _claim(tru);
        _claim(tfusd);
        _claim(feeToken);

        uint256 amountToTransfer = amount.mul(stakeSupply).div(totalSupply);

        _burn(msg.sender, amount);
        stakeSupply = stakeSupply.sub(amountToTransfer);

        tru.safeTransfer(msg.sender, amountToTransfer);

        emit Unstake(msg.sender, amount);
    }

    function cooldown() public {

        cooldowns[msg.sender] = block.timestamp;
        receivedDuringCooldown[msg.sender] = 0;

        emit Cooldown(msg.sender, block.timestamp.add(cooldownTime));
    }

    function withdraw(uint256 amount) external onlyLiquidator {

        stakeSupply = stakeSupply.sub(amount);
        tru.safeTransfer(liquidator, amount);

        emit Withdraw(amount);
    }

    function unlockTime(address account) public view returns (uint256) {

        if (cooldowns[account] == 0 || cooldowns[account].add(cooldownTime).add(unstakePeriodDuration) < block.timestamp) {
            return type(uint256).max;
        }
        return cooldowns[account].add(cooldownTime);
    }

    function payFee(uint256 amount, uint256 endTime) external onlyWhitelistedPayers {

        require(endTime < type(uint64).max, "StkTruToken: time overflow");
        require(amount < type(uint96).max, "StkTruToken: amount overflow");

        tfusd.safeTransferFrom(msg.sender, address(this), amount);
        undistributedTfusdRewards = undistributedTfusdRewards.add(amount.div(2));
        scheduledRewards.push(ScheduledTfUsdRewards({amount: uint96(amount.div(2)), timestamp: uint64(endTime)}));

        uint32 newIndex = findPositionForTimestamp(endTime);
        insertAt(newIndex, uint32(scheduledRewards.length) - 1);
    }

    function claim() external distribute update(msg.sender) {

        _claim(tru);
        _claim(tfusd);
        _claim(feeToken);
    }

    function claimRewards(IERC20 token) external distribute updateRewards(msg.sender, token) {

        require(token == tfusd || token == tru || token == feeToken, "Token not supported for rewards");
        _claim(token);
    }

    function claimRestake(uint256 extraStakeAmount) external distribute update(msg.sender) {

        uint256 amount = _claimWithoutTransfer(tru).add(extraStakeAmount);
        _stakeWithoutTransfer(amount);
        if (extraStakeAmount > 0) {
            tru.safeTransferFrom(msg.sender, address(this), extraStakeAmount);
        }
    }

    function claimable(address account, IERC20 token) external view returns (uint256) {

        uint256 pending = token == tru ? distributor.nextDistribution() : 0;
        uint256 newTotalFarmRewards = rewardBalance(token)
            .add(pending > MIN_DISTRIBUTED_AMOUNT ? pending : 0)
            .add(farmRewards[token].totalClaimedRewards)
            .mul(PRECISION);
        uint256 totalBlockReward = newTotalFarmRewards.sub(farmRewards[token].totalFarmRewards);
        uint256 nextCumulativeRewardPerToken = farmRewards[token].cumulativeRewardPerToken.add(totalBlockReward.div(totalSupply));
        return
            farmRewards[token].claimableReward[account].add(
                balanceOf[account]
                    .mul(nextCumulativeRewardPerToken.sub(farmRewards[token].previousCumulatedRewardPerToken[account]))
                    .div(PRECISION)
            );
    }

    function unstakable(address staker) public view returns (uint256) {

        if (unlockTime(staker) == type(uint256).max) {
            return balanceOf[staker];
        }
        if (receivedDuringCooldown[staker] > balanceOf[staker]) {
            return 0;
        }
        return balanceOf[staker].sub(receivedDuringCooldown[staker]);
    }

    function getPriorVotes(address account, uint256 blockNumber) public override view returns (uint96) {

        uint96 votes = super.getPriorVotes(account, blockNumber);
        return safe96(stakeSupply.mul(votes).div(totalSupply), "StkTruToken: uint96 overflow");
    }

    function getCurrentVotes(address account) public override view returns (uint96) {

        uint96 votes = super.getCurrentVotes(account);
        return safe96(stakeSupply.mul(votes).div(totalSupply), "StkTruToken: uint96 overflow");
    }

    function decimals() public override pure returns (uint8) {

        return 8;
    }

    function rounding() public pure returns (uint8) {

        return 8;
    }

    function name() public override pure returns (string memory) {

        return "Staked TrueFi";
    }

    function symbol() public override pure returns (string memory) {

        return "stkTRU";
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override distribute update(sender) {

        updateClaimableRewards(tru, recipient);
        updateClaimableRewards(tfusd, recipient);
        updateClaimableRewards(feeToken, recipient);
        if (unlockTime(recipient) != type(uint256).max) {
            receivedDuringCooldown[recipient] = receivedDuringCooldown[recipient].add(amount);
        }
        if (unlockTime(sender) != type(uint256).max) {
            receivedDuringCooldown[sender] = receivedDuringCooldown[sender].sub(min(receivedDuringCooldown[sender], amount));
        }
        super._transfer(sender, recipient, amount);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function _claim(IERC20 token) internal {

        uint256 rewardToClaim = _claimWithoutTransfer(token);
        if (rewardToClaim > 0) {
            token.safeTransfer(msg.sender, rewardToClaim);
        }
    }

    function _claimWithoutTransfer(IERC20 token) internal returns (uint256) {

        uint256 rewardToClaim = farmRewards[token].claimableReward[msg.sender];
        farmRewards[token].totalClaimedRewards = farmRewards[token].totalClaimedRewards.add(rewardToClaim);
        farmRewards[token].claimableReward[msg.sender] = 0;
        emit Claim(msg.sender, token, rewardToClaim);
        return rewardToClaim;
    }

    function _stakeWithoutTransfer(uint256 amount) internal {

        require(amount > 0, "StkTruToken: Cannot stake 0");

        if (cooldowns[msg.sender] != 0 && cooldowns[msg.sender].add(cooldownTime).add(unstakePeriodDuration) > block.timestamp) {
            cooldown();
        }

        if (delegates[msg.sender] == address(0)) {
            delegates[msg.sender] = msg.sender;
        }

        uint256 amountToMint = stakeSupply == 0 ? amount : amount.mul(totalSupply).div(stakeSupply);
        _mint(msg.sender, amountToMint);
        stakeSupply = stakeSupply.add(amount);
        emit Stake(msg.sender, amount);
    }

    function rewardBalance(IERC20 token) internal view returns (uint256) {

        if (address(token) == address(0)) {
            return 0;
        }
        if (token == tru) {
            return token.balanceOf(address(this)).sub(stakeSupply);
        }
        if (token == tfusd) {
            return token.balanceOf(address(this)).sub(undistributedTfusdRewards);
        }
        if (token == feeToken) {
            return token.balanceOf(address(this));
        }
        return 0;
    }

    function distributeScheduledRewards() internal {

        uint32 index = nextDistributionIndex;
        while (index < scheduledRewards.length && scheduledRewards[sortedScheduledRewardIndices[index]].timestamp < block.timestamp) {
            undistributedTfusdRewards = undistributedTfusdRewards.sub(scheduledRewards[sortedScheduledRewardIndices[index]].amount);
            index++;
        }
        if (nextDistributionIndex != index) {
            nextDistributionIndex = index;
        }
    }

    function updateTotalRewards(IERC20 token) internal {

        if (token == tfusd) {
            distributeScheduledRewards();
        }
        uint256 newTotalFarmRewards = rewardBalance(token).add(farmRewards[token].totalClaimedRewards).mul(PRECISION);
        if (newTotalFarmRewards == farmRewards[token].totalFarmRewards) {
            return;
        }
        uint256 totalBlockReward = newTotalFarmRewards.sub(farmRewards[token].totalFarmRewards);
        farmRewards[token].totalFarmRewards = newTotalFarmRewards;
        if (totalSupply > 0) {
            farmRewards[token].cumulativeRewardPerToken = farmRewards[token].cumulativeRewardPerToken.add(
                totalBlockReward.div(totalSupply)
            );
        }
    }

    function updateClaimableRewards(IERC20 token, address user) internal {

        if (balanceOf[user] > 0) {
            farmRewards[token].claimableReward[user] = farmRewards[token].claimableReward[user].add(
                balanceOf[user]
                    .mul(farmRewards[token].cumulativeRewardPerToken.sub(farmRewards[token].previousCumulatedRewardPerToken[user]))
                    .div(PRECISION)
            );
        }
        farmRewards[token].previousCumulatedRewardPerToken[user] = farmRewards[token].cumulativeRewardPerToken;
    }

    function findPositionForTimestamp(uint256 timestamp) internal view returns (uint32 i) {

        for (i = nextDistributionIndex; i < sortedScheduledRewardIndices.length; i++) {
            if (scheduledRewards[sortedScheduledRewardIndices[i]].timestamp > timestamp) {
                break;
            }
        }
    }

    function insertAt(uint32 index, uint32 value) internal {

        sortedScheduledRewardIndices.push(0);
        for (uint32 j = uint32(sortedScheduledRewardIndices.length) - 1; j > index; j--) {
            sortedScheduledRewardIndices[j] = sortedScheduledRewardIndices[j - 1];
        }
        sortedScheduledRewardIndices[index] = value;
    }
}