
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

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

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT
pragma solidity ^0.8.10;

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

}/**
 * @notice This is a copy of openzeppelin ERC20 contract with removed state variables.
 * Removing state variables has been necessary due to proxy pattern usage.
 * Changes to Openzeppelin ERC20 https://github.com/OpenZeppelin/openzeppelin-contracts/blob/de99bccbfd4ecd19d7369d01b070aa72c64423c9/contracts/token/ERC20/ERC20.sol:
 * - Remove state variables _name, _symbol, _decimals
 * - Use state variables balances, allowances, totalSupply from ProxyStorage
 * - Remove constructor
 * - Solidity version changed from ^0.6.0 to 0.6.10
 * - Contract made abstract
 * - Remove inheritance from IERC20 because of ProxyStorage name conflicts
 *
 * See also: ClaimableOwnable.sol and ProxyStorage.sol
 */


pragma solidity ^0.8.10;



abstract contract ERC20 is ProxyStorage, Context {
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
        _approve(sender, _msgSender(), allowance[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowance[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowance[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        balanceOf[sender] = balanceOf[sender] - amount;
        balanceOf[recipient] = balanceOf[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply = totalSupply + amount;
        balanceOf[account] = balanceOf[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        balanceOf[account] = balanceOf[account] - amount;
        totalSupply = totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}// MIT
pragma solidity ^0.8.10;


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

interface IVoteTokenWithERC20 is IVoteToken, IERC20 {}// MIT


pragma solidity ^0.8.10;


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
        require(block.timestamp <= expiry, "TrustToken::delegateBySig: signature expired");
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), block.chainid, address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "TrustToken::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "TrustToken::delegateBySig: invalid nonce");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) public view virtual override returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getDelegate(address account) public view returns (address) {
        return delegates[account] == address(0) ? account : delegates[account];
    }

    function getPriorVotes(address account, uint256 blockNumber) public view virtual override returns (uint96) {
        require(blockNumber < block.number, "TrustToken::getPriorVotes: not yet determined");

        uint32 checkpointsNumber = numCheckpoints[account];
        if (checkpointsNumber == 0) {
            return 0;
        }

        mapping(uint32 => Checkpoint) storage userCheckpoints = checkpoints[account];

        if (userCheckpoints[checkpointsNumber - 1].fromBlock <= blockNumber) {
            return userCheckpoints[checkpointsNumber - 1].votes;
        }

        if (userCheckpoints[0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = checkpointsNumber - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory checkpoint = userCheckpoints[center];
            if (checkpoint.fromBlock == blockNumber) {
                return checkpoint.votes;
            } else if (checkpoint.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return userCheckpoints[lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        require(delegatee != address(0), "StkTruToken: cannot delegate to AddressZero");
        address currentDelegate = getDelegate(delegator);

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
        _moveDelegates(getDelegate(_from), getDelegate(_to), safe96(_value, "StkTruToken: uint96 overflow"));
    }

    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);
        _moveDelegates(address(0), getDelegate(account), safe96(amount, "StkTruToken: uint96 overflow"));
    }

    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);
        _moveDelegates(getDelegate(account), address(0), safe96(amount, "StkTruToken: uint96 overflow"));
    }

    function _moveDelegates(
        address source,
        address destination,
        uint96 amount
    ) internal {
        if (source != destination && amount > 0) {
            if (source != address(0)) {
                uint32 sourceCheckpointsNumber = numCheckpoints[source];
                uint96 sourceOldVotes = sourceCheckpointsNumber > 0 ? checkpoints[source][sourceCheckpointsNumber - 1].votes : 0;
                uint96 sourceNewVotes = sourceOldVotes - amount;
                _writeCheckpoint(source, sourceCheckpointsNumber, sourceOldVotes, sourceNewVotes);
            }

            if (destination != address(0)) {
                uint32 destinationCheckpointsNumber = numCheckpoints[destination];
                uint96 destinationOldVotes = destinationCheckpointsNumber > 0
                    ? checkpoints[destination][destinationCheckpointsNumber - 1].votes
                    : 0;
                uint96 destinationNewVotes = destinationOldVotes + amount;
                _writeCheckpoint(destination, destinationCheckpointsNumber, destinationOldVotes, destinationNewVotes);
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
}// MIT
pragma solidity ^0.8.10;


interface ITrueDistributor {

    function trustToken() external view returns (IERC20);


    function farm() external view returns (address);


    function distribute() external;


    function nextDistribution() external view returns (uint256);


    function empty() external;

}// MIT
pragma solidity ^0.8.10;


contract StkClaimableContract is ProxyStorage {

    function owner() public view returns (address) {

        return owner_;
    }

    function pendingOwner() public view returns (address) {

        return pendingOwner_;
    }

    event OwnershipTransferred(address indexed currentOwner, address indexed newPendingOwner);
    event OwnershipClaimed(address indexed currentOwner, address indexed newOwner);

    constructor() {
        owner_ = msg.sender;
        emit OwnershipClaimed(address(0), msg.sender);
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
        emit OwnershipTransferred(owner_, newOwner);
    }

    function claimOwnership() public onlyPendingOwner {

        address _pendingOwner = pendingOwner_;
        emit OwnershipClaimed(owner_, _pendingOwner);
        owner_ = _pendingOwner;
        pendingOwner_ = address(0);
    }
}// MIT

pragma solidity ^0.8.10;

interface IPauseableContract {

    function setPauseStatus(bool pauseStatus) external;

}// MIT
pragma solidity ^0.8.10;



contract StkTruToken is VoteToken, StkClaimableContract, IPauseableContract, ReentrancyGuard {

    using SafeERC20 for IERC20;

    uint256 private constant PRECISION = 1e30;
    uint256 private constant MIN_DISTRIBUTED_AMOUNT = 100e8;
    uint256 private constant MAX_COOLDOWN = 100 * 365 days;
    uint256 private constant MAX_UNSTAKE_PERIOD = 100 * 365 days;
    uint32 private constant SCHEDULED_REWARDS_BATCH_SIZE = 32;

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

    mapping(address => uint256) internal cooldowns;
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

    Checkpoint[] internal _totalSupplyCheckpoints;


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

    modifier distribute() {

        if (distributor.nextDistribution() >= MIN_DISTRIBUTED_AMOUNT && distributor.farm() == address(this)) {
            distributor.distribute();
        }
        _;
    }

    modifier update(address account) {

        _update(account);
        _;
    }

    function _update(address account) internal {

        updateTotalRewards(tru);
        updateClaimableRewards(tru, account);
        updateTotalRewards(tfusd);
        updateClaimableRewards(tfusd, account);
        updateTotalRewards(feeToken);
        updateClaimableRewards(feeToken, account);
    }

    modifier updateRewards(address account, IERC20 token) {

        if (token == tru || token == tfusd || token == feeToken) {
            updateTotalRewards(token);
            updateClaimableRewards(token, account);
        }
        _;
    }

    constructor() {
        initalized = true;
    }

    function initialize(
        IERC20 _tru,
        IERC20 _tfusd,
        IERC20 _feeToken,
        ITrueDistributor _distributor,
        address _liquidator
    ) public {

        require(!initalized, "StkTruToken: Already initialized");
        require(address(_tru) != address(0), "StkTruToken: TRU token address must not be 0");
        require(address(_tfusd) != address(0), "StkTruToken: tfUSD token address must not be 0");
        require(address(_feeToken) != address(0), "StkTruToken: fee token address must not be 0");
        tru = _tru;
        tfusd = _tfusd;
        feeToken = _feeToken;
        distributor = _distributor;
        liquidator = _liquidator;

        cooldownTime = 14 days;
        unstakePeriodDuration = 2 days;

        initTotalSupplyCheckpoints();

        owner_ = msg.sender;
        initalized = true;
    }

    function initTotalSupplyCheckpoints() public onlyOwner {

        require(_totalSupplyCheckpoints.length == 0, "StakeTruToken: Total supply checkpoints already initialized");
        _totalSupplyCheckpoints.push(Checkpoint({fromBlock: SafeCast.toUint32(block.number), votes: SafeCast.toUint96(totalSupply)}));
    }

    function _mint(address account, uint256 amount) internal virtual override {

        super._mint(account, amount);
        _writeTotalSupplyCheckpoint(_add, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override {

        super._burn(account, amount);
        _writeTotalSupplyCheckpoint(_subtract, amount);
    }

    function setFeeToken(IERC20 _feeToken) external onlyOwner {

        require(address(_feeToken) != address(0), "StkTruToken: fee token address must not be 0");
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

        require(newCooldownTime <= MAX_COOLDOWN, "StkTruToken: Cooldown too large");

        cooldownTime = newCooldownTime;
        emit CooldownTimeChanged(newCooldownTime);
    }

    function setPauseStatus(bool status) external override onlyOwner {

        pauseStatus = status;
        emit PauseStatusChanged(status);
    }

    function setUnstakePeriodDuration(uint256 newUnstakePeriodDuration) external onlyOwner {

        require(newUnstakePeriodDuration > 0, "StkTruToken: Unstake period cannot be 0");
        require(newUnstakePeriodDuration <= MAX_UNSTAKE_PERIOD, "StkTruToken: Unstake period too large");

        unstakePeriodDuration = newUnstakePeriodDuration;
        emit UnstakePeriodDurationChanged(newUnstakePeriodDuration);
    }

    function stake(uint256 amount) external distribute update(msg.sender) {

        require(!pauseStatus, "StkTruToken: Can be called only when not paused");
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

        uint256 amountToTransfer = (amount * stakeSupply) / totalSupply;

        _burn(msg.sender, amount);
        stakeSupply = stakeSupply - amountToTransfer;

        tru.safeTransfer(msg.sender, amountToTransfer);

        emit Unstake(msg.sender, amount);
    }

    function cooldown() public {

        cooldowns[msg.sender] = block.timestamp;
        receivedDuringCooldown[msg.sender] = 0;

        emit Cooldown(msg.sender, block.timestamp + cooldownTime);
    }

    function withdraw(uint256 amount) external {

        require(msg.sender == liquidator, "StkTruToken: Can be called only by the liquidator");
        require(amount <= stakeSupply, "StkTruToken: Insufficient stake supply");
        stakeSupply = stakeSupply - amount;
        tru.safeTransfer(liquidator, amount);

        emit Withdraw(amount);
    }

    function unlockTime(address account) public view returns (uint256) {

        uint256 cooldownStart = cooldowns[account];
        if (cooldownStart == 0 || cooldownStart + cooldownTime + unstakePeriodDuration < block.timestamp) {
            return type(uint256).max;
        }
        return cooldownStart + cooldownTime;
    }

    function payFee(uint256 amount, uint256 endTime) external {

        require(whitelistedFeePayers[msg.sender], "StkTruToken: Can be called only by whitelisted payers");
        require(endTime <= type(uint64).max, "StkTruToken: time overflow");
        require(amount <= type(uint96).max, "StkTruToken: amount overflow");

        tfusd.safeTransferFrom(msg.sender, address(this), amount);
        uint256 halfAmount = amount / 2;
        undistributedTfusdRewards = undistributedTfusdRewards + halfAmount;
        scheduledRewards.push(ScheduledTfUsdRewards({amount: uint96(amount - halfAmount), timestamp: uint64(endTime)}));

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

        uint256 amount = _claimWithoutTransfer(tru) + extraStakeAmount;
        _stakeWithoutTransfer(amount);
        if (extraStakeAmount > 0) {
            tru.safeTransferFrom(msg.sender, address(this), extraStakeAmount);
        }
    }

    function claimable(address account, IERC20 token) external view returns (uint256) {

        FarmRewards storage rewards = farmRewards[token];
        uint256 pendingReward = token == tru ? distributor.nextDistribution() : 0;
        uint256 newTotalFarmRewards = (rewardBalance(token) +
            (pendingReward >= MIN_DISTRIBUTED_AMOUNT ? pendingReward : 0) +
            (rewards.totalClaimedRewards)) * PRECISION;
        uint256 totalBlockReward = newTotalFarmRewards - rewards.totalFarmRewards;
        uint256 nextCumulativeRewardPerToken = rewards.cumulativeRewardPerToken + (totalBlockReward / totalSupply);
        return
            rewards.claimableReward[account] +
            ((balanceOf[account] * (nextCumulativeRewardPerToken - (rewards.previousCumulatedRewardPerToken[account]))) / PRECISION);
    }

    function unstakable(address staker) public view returns (uint256) {

        uint256 stakerBalance = balanceOf[staker];

        if (unlockTime(staker) == type(uint256).max) {
            return stakerBalance;
        }

        if (receivedDuringCooldown[staker] > stakerBalance) {
            return 0;
        }
        return stakerBalance - receivedDuringCooldown[staker];
    }

    function getPriorVotes(address account, uint256 blockNumber) public view override returns (uint96) {

        uint96 votes = super.getPriorVotes(account, blockNumber);
        return safe96((stakeSupply * votes) / totalSupply, "StkTruToken: uint96 overflow");
    }

    function getPastVotes(address account, uint256 blockNumber) public view returns (uint96) {

        return super.getPriorVotes(account, blockNumber);
    }

    function getPastTotalSupply(uint256 blockNumber) public view returns (uint256) {

        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_totalSupplyCheckpoints, blockNumber);
    }

    function getCurrentVotes(address account) public view override returns (uint96) {

        uint96 votes = super.getCurrentVotes(account);
        return safe96((stakeSupply * votes) / totalSupply, "StkTruToken: uint96 overflow");
    }

    function decimals() public pure override returns (uint8) {

        return 8;
    }

    function rounding() public pure returns (uint8) {

        return 8;
    }

    function name() public pure override returns (string memory) {

        return "Staked TrueFi";
    }

    function symbol() public pure override returns (string memory) {

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
            receivedDuringCooldown[recipient] = receivedDuringCooldown[recipient] + amount;
        }
        if (unlockTime(sender) != type(uint256).max) {
            receivedDuringCooldown[sender] = receivedDuringCooldown[sender] - min(receivedDuringCooldown[sender], amount);
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

        FarmRewards storage rewards = farmRewards[token];

        uint256 rewardToClaim = rewards.claimableReward[msg.sender];
        rewards.totalClaimedRewards = rewards.totalClaimedRewards + rewardToClaim;
        rewards.claimableReward[msg.sender] = 0;
        emit Claim(msg.sender, token, rewardToClaim);
        return rewardToClaim;
    }

    function _stakeWithoutTransfer(uint256 amount) internal {

        require(amount > 0, "StkTruToken: Cannot stake 0");

        if (cooldowns[msg.sender] != 0 && cooldowns[msg.sender] + cooldownTime + unstakePeriodDuration >= block.timestamp) {
            cooldown();
        }

        uint256 amountToMint = stakeSupply == 0 ? amount : (amount * totalSupply) / stakeSupply;
        _mint(msg.sender, amountToMint);
        stakeSupply = stakeSupply + amount;
        emit Stake(msg.sender, amount);
    }

    function rewardBalance(IERC20 token) internal view returns (uint256) {

        if (token == tru) {
            return token.balanceOf(address(this)) - stakeSupply;
        }
        if (token == tfusd) {
            return token.balanceOf(address(this)) - undistributedTfusdRewards;
        }
        if (token == feeToken) {
            return token.balanceOf(address(this));
        }
        return 0;
    }

    function distributeScheduledRewards() internal {

        uint32 index = nextDistributionIndex;
        uint32 batchLimitIndex = index + SCHEDULED_REWARDS_BATCH_SIZE;
        uint32 end = batchLimitIndex < scheduledRewards.length ? batchLimitIndex : uint32(scheduledRewards.length);
        uint256 _undistributedTfusdRewards = undistributedTfusdRewards;

        while (index < end) {
            ScheduledTfUsdRewards storage rewards = scheduledRewards[sortedScheduledRewardIndices[index]];
            if (rewards.timestamp >= block.timestamp) {
                break;
            }
            _undistributedTfusdRewards = _undistributedTfusdRewards - rewards.amount;
            index++;
        }

        undistributedTfusdRewards = _undistributedTfusdRewards;

        if (nextDistributionIndex != index) {
            nextDistributionIndex = index;
        }
    }

    function updateTotalRewards(IERC20 token) internal {

        if (token == tfusd) {
            distributeScheduledRewards();
        }
        FarmRewards storage rewards = farmRewards[token];

        uint256 newTotalFarmRewards = (rewardBalance(token) + rewards.totalClaimedRewards) * PRECISION;
        if (newTotalFarmRewards == rewards.totalFarmRewards) {
            return;
        }
        uint256 totalBlockReward = newTotalFarmRewards - rewards.totalFarmRewards;
        rewards.totalFarmRewards = newTotalFarmRewards;
        if (totalSupply > 0) {
            rewards.cumulativeRewardPerToken = rewards.cumulativeRewardPerToken + totalBlockReward / totalSupply;
        }
    }

    function updateClaimableRewards(IERC20 token, address user) internal {

        FarmRewards storage rewards = farmRewards[token];

        if (balanceOf[user] > 0) {
            rewards.claimableReward[user] =
                rewards.claimableReward[user] +
                (balanceOf[user] * (rewards.cumulativeRewardPerToken - rewards.previousCumulatedRewardPerToken[user])) /
                PRECISION;
        }

        rewards.previousCumulatedRewardPerToken[user] = rewards.cumulativeRewardPerToken;
    }

    function findPositionForTimestamp(uint256 timestamp) internal view returns (uint32 i) {

        uint256 length = sortedScheduledRewardIndices.length;
        for (i = nextDistributionIndex; i < length; i++) {
            if (scheduledRewards[sortedScheduledRewardIndices[i]].timestamp > timestamp) {
                return i;
            }
        }
        return i;
    }

    function insertAt(uint32 index, uint32 value) internal {

        sortedScheduledRewardIndices.push(0);
        for (uint32 j = uint32(sortedScheduledRewardIndices.length) - 1; j > index; j--) {
            sortedScheduledRewardIndices[j] = sortedScheduledRewardIndices[j - 1];
        }
        sortedScheduledRewardIndices[index] = value;
    }

    function _writeTotalSupplyCheckpoint(function(uint256, uint256) view returns (uint256) op, uint256 delta)
        internal
        returns (uint256 oldWeight, uint256 newWeight)
    {

        uint256 checkpointsNumber = _totalSupplyCheckpoints.length;
        require(checkpointsNumber > 0, "StakeTruToken: total supply checkpoints not initialized");
        Checkpoint storage lastCheckpoint = _totalSupplyCheckpoints[checkpointsNumber - 1];

        oldWeight = lastCheckpoint.votes;
        newWeight = op(oldWeight, delta);

        if (lastCheckpoint.fromBlock == block.number) {
            lastCheckpoint.votes = SafeCast.toUint96(newWeight);
        } else {
            _totalSupplyCheckpoints.push(
                Checkpoint({fromBlock: SafeCast.toUint32(block.number), votes: SafeCast.toUint96(newWeight)})
            );
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {

        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {

        return a - b;
    }

    function _checkpointsLookup(Checkpoint[] storage checkpoints, uint256 blockNumber) internal view returns (uint256) {

        uint256 high = checkpoints.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (checkpoints[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : checkpoints[high - 1].votes;
    }

    function matchVotesToBalance() external onlyOwner {

        address[7] memory accounts = [
            0xD68C599A549E8518b2E0daB9cD437C930ac2f12B,
            0x4b1A187d7e6D8f2Eb3AC46961DB3468fB824E991,
            0x57dCb790617D6b8fBe4cDBb3d9b14328A448904f,
            0xF80E102624Eb7A3925Cf807A870FbEf3C760d520,
            0xFe713259F66673076571DfDfbF62F77C138e41A5,
            0x4a88FB2A8A5b7B27ad9E8F7728492485744A1e3f,
            0x4DE8eDFFbDc8eC8b6b8399731D7a9340F90C7663
        ];

        for (uint256 i = 0; i < accounts.length; i++) {
            _matchVotesToBalance(accounts[i]);
        }

        _matchVotesToBalanceAndDelegatorBalance();
    }

    function _matchVotesToBalance(address account) internal {

        uint96 currentVotes = getCurrentVotes(account);
        uint96 balance = safe96(this.balanceOf(account), "StakeTruToken: balance exceeds 96 bits");
        address delegatee = delegates[account];
        if ((delegatee == account || delegatee == address(0)) && currentVotes < balance) {
            _writeCheckpoint(account, numCheckpoints[account], currentVotes, balance);
        }
    }

    function _matchVotesToBalanceAndDelegatorBalance() internal {

        address account = 0xe5D0Ef77AED07C302634dC370537126A2CD26590;
        address delegator = 0xd2c3385f511575851e5bbCd87C59A26Da9Ff71F2;

        uint96 accountBalance = safe96(this.balanceOf(account), "StakeTruToken: balance exceeds 96 bits");
        uint96 delegatorBalance = safe96(this.balanceOf(delegator), "StakeTruToken: balance exceeds 96 bits");

        uint96 currentVotes = getCurrentVotes(account);
        uint96 totalBalance = accountBalance + delegatorBalance;
        if (delegates[account] == address(0) && currentVotes < totalBalance) {
            _writeCheckpoint(account, numCheckpoints[account], currentVotes, totalBalance);
        }
    }
}