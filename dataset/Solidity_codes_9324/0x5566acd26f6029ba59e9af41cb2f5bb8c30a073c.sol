
pragma solidity 0.7.6;

interface IPolydexPair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}// MIT

pragma solidity 0.7.6;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH transfer failed');
    }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity 0.7.6;

abstract contract Ownable is Context {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}// MIT
pragma solidity 0.7.6;

contract Metadata {

    struct TokenMetadata {
        address routerAddress;
        string imageUrl;
        bool isAdded;
    }

    mapping(address => TokenMetadata) public tokenMeta;

    function updateMeta(
        address _tokenAddress,
        address _routerAddress,
        string memory _imageUrl
    ) internal {

        if (_tokenAddress != address(0)) {
            tokenMeta[_tokenAddress] = TokenMetadata({
                routerAddress: _routerAddress,
                imageUrl: _imageUrl,
                isAdded: true
            });
        }
    }

    function updateMetaURL(address _tokenAddress, string memory _imageUrl)
        internal
    {

        TokenMetadata storage meta = tokenMeta[_tokenAddress];
        require(meta.isAdded, "Invalid token address");

        meta.imageUrl = _imageUrl;
    }
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

pragma solidity 0.7.6;


contract StakingPoolTimeStamp is Ownable, ReentrancyGuard, Metadata {

    using SafeMath for uint256;
    using SafeMath for uint16;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 nextHarvestUntil; // When can the user harvest again.
        mapping(IERC20 => uint256) rewardDebt; // Reward debt.
        mapping(IERC20 => uint256) rewardLockedUp; // Reward locked up.
        mapping(address => bool) whiteListedHandlers;
    }

    struct RewardInfo {
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 accRewardPerShare;
        uint256 lastRewardBlockTimestamp; // Last block timestamp that rewards distribution occurs.
        uint256 blockRewardPerSec;
        IERC20 rewardToken; // Address of reward token contract.
    }

    struct FarmInfo {
        uint256 numFarmers;
        uint256 harvestInterval; // Harvest interval in seconds
        IERC20 inputToken;
        uint16 withdrawalFeeBP; // Deposit fee in basis points
        uint256 endTimestamp;
    }

    address public feeAddress;
    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 14 days;

    uint16 public constant MAXIMUM_WITHDRAWAL_FEE_BP = 1000;

    uint256 public totalInputTokensStaked;

    mapping(IERC20 => uint256) public totalLockedUpRewards;

    FarmInfo public farmInfo;

    mapping(address => bool) public activeRewardTokens;

    mapping(address => UserInfo) public userInfo;

    RewardInfo[] public rewardPool;

    bool public initialized;

    uint256 public maxAllowedDeposit;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardLockedUp(address indexed user, uint256 amountLockedUp);
    event RewardTokenAdded(IERC20 _rewardToken);
    event FeeAddressChanged(address _feeAddress);
    event RewardPoolUpdated(uint256 _rewardInfoIndex);
    event UserWhitelisted(address _primaryUser, address _whitelistedUser);
    event UserBlacklisted(address _primaryUser, address _blacklistedUser);
    event BlockRewardUpdated(uint256 _blockReward, uint256 _rewardPoolIndex);
    event RewardTokenURLUpdated(string _url, uint256 _rewardPoolIndex);
    event WithdrawalFeeChanged(uint16 _withdrawalFee);
    event HarvestIntervalChanged(uint256 _harvestInterval);
    event MaxAllowedDepositUpdated(uint256 _maxAllowedDeposit);

    constructor() {
        initialized = true;
    }

    struct LocalVars {
        uint256 _amount;
        uint256 _startTimestamp;
        uint256 _endTimestamp;
        uint256 _blockReward;
        IERC20 _rewardToken;
    }

    LocalVars private _localVars;

    function init(bytes memory extraData) external {

        require(initialized == false, "Contract already initialized");

        (
            _localVars._rewardToken,
            farmInfo.inputToken,
            _localVars._startTimestamp,
            _localVars._endTimestamp,
            _localVars._amount
        ) = abi.decode(extraData, (IERC20, IERC20, uint256, uint256, uint256));

        string memory _rewardTokenUrl;
        (
            ,
            ,
            ,
            ,
            ,
            _localVars._blockReward,
            farmInfo.harvestInterval,
            feeAddress,
            farmInfo.withdrawalFeeBP,
            owner // StakingPoolFactory owner address
        ) = abi.decode(
            extraData,
            (
                IERC20,
                IERC20,
                uint256,
                uint256,
                uint256,
                uint256,
                uint256,
                address,
                uint16,
                address
            )
        );
        address routerAddress;
        string memory inputTokenUrl;

        (
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            _rewardTokenUrl,
            inputTokenUrl,
            routerAddress,
            farmInfo.endTimestamp,
            maxAllowedDeposit
        ) = abi.decode(
            extraData,
            (
                IERC20,
                IERC20,
                uint256,
                uint256,
                uint256,
                uint256,
                uint256,
                address,
                uint16,
                address,
                string,
                string,
                address,
                uint256,
                uint256
            )
        );

        updateMeta(address(farmInfo.inputToken), routerAddress, inputTokenUrl);
        updateMeta(
            address(_localVars._rewardToken),
            address(0),
            _rewardTokenUrl
        );

        require(
            farmInfo.withdrawalFeeBP <= MAXIMUM_WITHDRAWAL_FEE_BP,
            "add: invalid withdrawal fee basis points"
        );
        require(
            farmInfo.harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "add: invalid harvest interval"
        );

        TransferHelper.safeTransferFrom(
            address(_localVars._rewardToken),
            msg.sender,
            address(this),
            _localVars._amount
        );
        require(
            farmInfo.endTimestamp >= block.timestamp,
            "End block timestamp must be greater than current timestamp"
        );
        require(
            farmInfo.endTimestamp > _localVars._startTimestamp,
            "Invalid start timestamp"
        );
        require(
            farmInfo.endTimestamp >= _localVars._endTimestamp,
            "Invalid end timestamp"
        );
        require(
            _localVars._endTimestamp > _localVars._startTimestamp,
            "Invalid start and end timestamp"
        );

        rewardPool.push(
            RewardInfo({
                startTimestamp: _localVars._startTimestamp,
                endTimestamp: _localVars._endTimestamp,
                rewardToken: _localVars._rewardToken,
                lastRewardBlockTimestamp: block.timestamp >
                    _localVars._startTimestamp
                    ? block.timestamp
                    : _localVars._startTimestamp,
                blockRewardPerSec: _localVars._blockReward,
                accRewardPerShare: 0
            })
        );

        activeRewardTokens[address(_localVars._rewardToken)] = true;
        initialized = true;
    }

    function getMultiplier(
        uint256 _fromTimestamp,
        uint256 _rewardInfoIndex,
        uint256 _toTimestamp
    ) public view returns (uint256) {

        RewardInfo memory rewardInfo = rewardPool[_rewardInfoIndex];
        uint256 _from = _fromTimestamp >= rewardInfo.startTimestamp
            ? _fromTimestamp
            : rewardInfo.startTimestamp;
        uint256 to = rewardInfo.endTimestamp > _toTimestamp
            ? _toTimestamp
            : rewardInfo.endTimestamp;
        if (_from > to) {
            return 0;
        }

        return to.sub(_from, "from getMultiplier");
    }

    function updateMaxAllowedDeposit(uint256 _maxAllowedDeposit)
        external
        onlyOwner
    {

        maxAllowedDeposit = _maxAllowedDeposit;
        emit MaxAllowedDepositUpdated(_maxAllowedDeposit);
    }

    function updateRewardTokenURL(uint256 _rewardTokenIndex, string memory _url)
        external
        onlyOwner
    {

        RewardInfo storage rewardInfo = rewardPool[_rewardTokenIndex];
        updateMetaURL(address(rewardInfo.rewardToken), _url);
        emit RewardTokenURLUpdated(_url, _rewardTokenIndex);
    }

    function updateWithdrawalFee(uint16 _withdrawalFee, bool _massUpdate)
        external
        onlyOwner
    {

        require(
            _withdrawalFee <= MAXIMUM_WITHDRAWAL_FEE_BP,
            "invalid withdrawal fee basis points"
        );

        if (_massUpdate) {
            massUpdatePools();
        }

        farmInfo.withdrawalFeeBP = _withdrawalFee;
        emit WithdrawalFeeChanged(_withdrawalFee);
    }

    function updateHarvestInterval(uint256 _harvestInterval, bool _massUpdate)
        external
        onlyOwner
    {

        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "invalid harvest intervals"
        );

        if (_massUpdate) {
            massUpdatePools();
        }

        farmInfo.harvestInterval = _harvestInterval;
        emit HarvestIntervalChanged(_harvestInterval);
    }

    function rescueFunds(IERC20 _token, address _recipient) external onlyOwner {

        TransferHelper.safeTransfer(
            address(_token),
            _recipient,
            _token.balanceOf(address(this))
        );
    }

    function addRewardToken(
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        IERC20 _rewardToken, // Address of reward token contract.
        uint256 _lastRewardTimestamp,
        uint256 _blockReward,
        uint256 _amount,
        string memory _tokenUrl,
        bool _massUpdate
    ) external onlyOwner nonReentrant {

        require(
            farmInfo.endTimestamp > _startTimestamp,
            "Invalid start end timestamp"
        );
        require(
            farmInfo.endTimestamp >= _endTimestamp,
            "Invalid end timestamp"
        );
        require(_endTimestamp > _startTimestamp, "Invalid end timestamp");
        require(address(_rewardToken) != address(0), "Invalid reward token");
        require(
            activeRewardTokens[address(_rewardToken)] == false,
            "Reward Token already added"
        );

        require(
            _lastRewardTimestamp >= block.timestamp,
            "Last RewardBlock must be greater than currentBlock"
        );

        if (_massUpdate) {
            massUpdatePools();
        }

        rewardPool.push(
            RewardInfo({
                startTimestamp: _startTimestamp,
                endTimestamp: _endTimestamp,
                rewardToken: _rewardToken,
                lastRewardBlockTimestamp: _lastRewardTimestamp,
                blockRewardPerSec: _blockReward,
                accRewardPerShare: 0
            })
        );

        activeRewardTokens[address(_rewardToken)] = true;

        TransferHelper.safeTransferFrom(
            address(_rewardToken),
            msg.sender,
            address(this),
            _amount
        );

        updateMeta(address(_rewardToken), address(0), _tokenUrl);

        emit RewardTokenAdded(_rewardToken);
    }

    function massUpdatePools() public {

        uint256 totalRewardPool = rewardPool.length;
        for (uint256 i = 0; i < totalRewardPool; i++) {
            updatePool(i);
        }
    }

    function pendingReward(address _user, uint256 _rewardInfoIndex)
        external
        view
        returns (uint256)
    {

        UserInfo storage user = userInfo[_user];
        RewardInfo memory rewardInfo = rewardPool[_rewardInfoIndex];
        uint256 accRewardPerShare = rewardInfo.accRewardPerShare;
        uint256 lpSupply = totalInputTokensStaked;

        if (
            block.timestamp > rewardInfo.lastRewardBlockTimestamp &&
            lpSupply != 0
        ) {
            uint256 multiplier = getMultiplier(
                rewardInfo.lastRewardBlockTimestamp,
                _rewardInfoIndex,
                block.timestamp
            );
            uint256 tokenReward = multiplier.mul(rewardInfo.blockRewardPerSec);
            accRewardPerShare = accRewardPerShare.add(
                tokenReward.mul(1e18).div(lpSupply)
            );
        }

        uint256 pending = user.amount.mul(accRewardPerShare).div(1e18).sub(
            user.rewardDebt[rewardInfo.rewardToken]
        );
        return pending.add(user.rewardLockedUp[rewardInfo.rewardToken]);
    }

    function canHarvest(address _user) public view returns (bool) {

        UserInfo storage user = userInfo[_user];
        return ((block.timestamp >= user.nextHarvestUntil) &&
            (block.timestamp > farmInfo.endTimestamp));
    }

    function getHarvestUntil(address _user) external view returns (uint256) {

        UserInfo storage user = userInfo[_user];
        return user.nextHarvestUntil;
    }

    function updatePool(uint256 _rewardInfoIndex) public {

        RewardInfo storage rewardInfo = rewardPool[_rewardInfoIndex];
        if (block.timestamp <= rewardInfo.lastRewardBlockTimestamp) {
            return;
        }
        uint256 lpSupply = totalInputTokensStaked;

        if (lpSupply == 0) {
            rewardInfo.lastRewardBlockTimestamp = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(
            rewardInfo.lastRewardBlockTimestamp,
            _rewardInfoIndex,
            block.timestamp
        );
        uint256 tokenReward = multiplier.mul(rewardInfo.blockRewardPerSec);
        rewardInfo.accRewardPerShare = rewardInfo.accRewardPerShare.add(
            tokenReward.mul(1e18).div(lpSupply)
        );
        rewardInfo.lastRewardBlockTimestamp = block.timestamp <
            rewardInfo.endTimestamp
            ? block.timestamp
            : rewardInfo.endTimestamp;

        emit RewardPoolUpdated(_rewardInfoIndex);
    }

    function deposit(uint256 _amount) external nonReentrant {

        _deposit(_amount, msg.sender);
    }

    function depositFor(uint256 _amount, address _user) external nonReentrant {

        _deposit(_amount, _user);
    }

    function _deposit(uint256 _amount, address _user) internal {

        require(
            totalInputTokensStaked.add(_amount) <= maxAllowedDeposit,
            "Max allowed deposit exceeded"
        );
        UserInfo storage user = userInfo[_user];
        user.whiteListedHandlers[_user] = true;
        payOrLockupPendingReward(_user, _user);
        if (user.amount == 0 && _amount > 0) {
            farmInfo.numFarmers++;
        }
        if (_amount > 0) {
            farmInfo.inputToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
        }
        totalInputTokensStaked = totalInputTokensStaked.add(_amount);
        updateRewardDebt(_user);
        emit Deposit(_user, _amount);
    }

    function withdraw(uint256 _amount) external nonReentrant {

        _withdraw(_amount, msg.sender, msg.sender);
    }

    function withdrawFor(uint256 _amount, address _user) external nonReentrant {

        UserInfo storage user = userInfo[_user];
        require(
            user.whiteListedHandlers[msg.sender],
            "Handler not whitelisted to withdraw"
        );
        _withdraw(_amount, _user, msg.sender);
    }

    function _withdraw(
        uint256 _amount,
        address _user,
        address _withdrawer
    ) internal {

        require(
            block.timestamp >= farmInfo.endTimestamp,
            "Cannot withdraw before end block timestamp"
        );
        UserInfo storage user = userInfo[_user];
        require(user.amount >= _amount, "INSUFFICIENT");
        payOrLockupPendingReward(_user, _withdrawer);
        if (user.amount == _amount && _amount > 0) {
            farmInfo.numFarmers--;
        }

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            if (farmInfo.withdrawalFeeBP > 0) {
                uint256 withdrawalFee = _amount
                    .mul(farmInfo.withdrawalFeeBP)
                    .div(10000);
                farmInfo.inputToken.safeTransfer(feeAddress, withdrawalFee);
                farmInfo.inputToken.safeTransfer(
                    address(_withdrawer),
                    _amount.sub(withdrawalFee)
                );
            } else {
                farmInfo.inputToken.safeTransfer(address(_withdrawer), _amount);
            }
        }
        totalInputTokensStaked = totalInputTokensStaked.sub(_amount);
        updateRewardDebt(_user);
        emit Withdraw(_user, _amount);
    }

    function emergencyWithdraw() external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        farmInfo.inputToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        if (user.amount > 0) {
            farmInfo.numFarmers--;
        }
        totalInputTokensStaked = totalInputTokensStaked.sub(user.amount);
        user.amount = 0;

        uint256 totalRewardPools = rewardPool.length;
        for (uint256 i = 0; i < totalRewardPools; i++) {
            user.rewardDebt[rewardPool[i].rewardToken] = 0;
        }
    }

    function whitelistHandler(address _handler) external {

        UserInfo storage user = userInfo[msg.sender];
        user.whiteListedHandlers[_handler] = true;
        emit UserWhitelisted(msg.sender, _handler);
    }

    function removeWhitelistedHandler(address _handler) external {

        UserInfo storage user = userInfo[msg.sender];
        user.whiteListedHandlers[_handler] = false;
        emit UserBlacklisted(msg.sender, _handler);
    }

    function isUserWhiteListed(address _owner, address _user)
        external
        view
        returns (bool)
    {

        UserInfo storage user = userInfo[_owner];
        return user.whiteListedHandlers[_user];
    }

    function payOrLockupPendingReward(address _user, address _withdrawer)
        internal
    {

        UserInfo storage user = userInfo[_user];
        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(
                farmInfo.harvestInterval
            );
        }

        bool canUserHarvest = canHarvest(_user);

        uint256 totalRewardPools = rewardPool.length;
        for (uint256 i = 0; i < totalRewardPools; i++) {
            RewardInfo storage rewardInfo = rewardPool[i];

            updatePool(i);

            uint256 userRewardDebt = user.rewardDebt[rewardInfo.rewardToken];
            uint256 userRewardLockedUp = user.rewardLockedUp[
                rewardInfo.rewardToken
            ];
            uint256 pending = user
                .amount
                .mul(rewardInfo.accRewardPerShare)
                .div(1e18)
                .sub(userRewardDebt);
            if (canUserHarvest) {
                if (pending > 0 || userRewardLockedUp > 0) {
                    uint256 totalRewards = pending.add(userRewardLockedUp);
                    totalLockedUpRewards[
                        rewardInfo.rewardToken
                    ] = totalLockedUpRewards[rewardInfo.rewardToken].sub(
                        userRewardLockedUp
                    );
                    user.rewardLockedUp[rewardInfo.rewardToken] = 0;
                    user.nextHarvestUntil = block.timestamp.add(
                        farmInfo.harvestInterval
                    );
                    _safeRewardTransfer(
                        _withdrawer,
                        totalRewards,
                        rewardInfo.rewardToken
                    );
                }
            } else if (pending > 0) {
                user.rewardLockedUp[rewardInfo.rewardToken] = user
                    .rewardLockedUp[rewardInfo.rewardToken]
                    .add(pending);
                totalLockedUpRewards[
                    rewardInfo.rewardToken
                ] = totalLockedUpRewards[rewardInfo.rewardToken].add(pending);
                emit RewardLockedUp(_user, pending);
            }
        }
    }

    function updateRewardDebt(address _user) internal {

        UserInfo storage user = userInfo[_user];
        uint256 totalRewardPools = rewardPool.length;
        for (uint256 i = 0; i < totalRewardPools; i++) {
            RewardInfo storage rewardInfo = rewardPool[i];

            user.rewardDebt[rewardInfo.rewardToken] = user
                .amount
                .mul(rewardInfo.accRewardPerShare)
                .div(1e18);
        }
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {

        require(_feeAddress != address(0), "setFeeAddress: invalid address");
        feeAddress = _feeAddress;
        emit FeeAddressChanged(feeAddress);
    }

    function updateBlockReward(
        uint256 _blockReward,
        uint256 _rewardTokenIndex,
        bool _massUpdate
    ) external onlyOwner {

        if (_massUpdate) {
            massUpdatePools();
        }

        rewardPool[_rewardTokenIndex].blockRewardPerSec = _blockReward;
        emit BlockRewardUpdated(_blockReward, _rewardTokenIndex);
    }

    function transferRewardToken(uint256 _rewardTokenIndex, uint256 _amount)
        external
        onlyOwner
    {

        RewardInfo storage rewardInfo = rewardPool[_rewardTokenIndex];

        TransferHelper.safeTransfer(
            address(rewardInfo.rewardToken),
            msg.sender,
            _amount
        );
    }

    function _safeRewardTransfer(
        address _to,
        uint256 _amount,
        IERC20 _rewardToken
    ) private {

        uint256 rewardBal = _rewardToken.balanceOf(address(this));
        if (_amount > rewardBal) {
            TransferHelper.safeTransfer(address(_rewardToken), _to, rewardBal);
        } else {
            TransferHelper.safeTransfer(address(_rewardToken), _to, _amount);
        }
    }
}