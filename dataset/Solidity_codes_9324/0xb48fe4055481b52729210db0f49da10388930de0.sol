
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}pragma solidity ^0.8.4;


interface IXLPToken is IERC20 {

    function mint(address to, uint256 amount) external;

}

interface IUnifiedFarm {

    struct LockedStake {
        bytes32 kek_id;
        uint256 start_timestamp;
        uint256 liquidity;
        uint256 ending_timestamp;
        uint256 lock_multiplier; // 6 decimals of precision. 1x = 1000000
    }
    function stakeLocked(uint256 liquidity, uint256 secs) external;

    function getReward(address destination_address) external returns (uint256[] memory);

    function withdrawLocked(bytes32 kek_id, address destination_address) external;

    function lockAdditional(bytes32 kek_id, uint256 addl_liq) external;

    function stakerSetVeFXSProxy(address proxy_address) external;

    function stakerToggleMigrator(address migrator_address) external;

    function lock_time_for_max_multiplier() external view returns (uint256);

    function lock_time_min() external view returns (uint256);

    function getAllRewardTokens() external view returns (address[] memory);

    function lockedLiquidityOf(address account) external view returns (uint256);

    function lockedStakesOf(address account) external view returns (LockedStake[] memory);

}

interface IStableSwap {

    function coins(uint256 j) external view returns (address);

    function calc_token_amount(uint256[2] calldata _amounts, bool _is_deposit) external view returns (uint256);

    function add_liquidity(uint256[2] calldata _amounts, uint256 _min_mint_amount, address destination) external returns (uint256);

    function get_dy(int128 _from, int128 _to, uint256 _from_amount) external view returns (uint256);

    function remove_liquidity(uint256 _amount, uint256[2] calldata _min_amounts) external returns (uint256[2] memory);

    function fee() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);

    function remove_liquidity_imbalance(uint256[2] memory amounts, uint256 _max_burn_amount, address _receiver) external returns (uint256);

}

contract LiquidityOps is Ownable {

    using SafeERC20 for IERC20;
    using SafeERC20 for IXLPToken;

    IUnifiedFarm public lpFarm;          // frax unified lp farm
    IXLPToken public xlpToken;           // stax lp receipt;
    IERC20 public lpToken;               // lp pair token

    IStableSwap public curveStableSwap;

    address public rewardsManager;
    address public feeCollector;
    address public pegDefender;
    address public operator;
    
    bool public operatorOnlyMode;

    int128 public inputTokenIndex;
    int128 public staxReceiptTokenIndex;

    LockRate public lockRate;  

    struct LockRate {
        uint128 numerator;
        uint128 denominator;
    }

    FeeRate public feeRate;
    struct FeeRate {
        uint128 numerator;
        uint128 denominator;
    }

    IERC20[] public rewardTokens;

    uint256 public farmLockTime;

    uint256 internal constant CURVE_FEE_DENOMINATOR = 1e10;

    event SetLockParams(uint128 numerator, uint128 denominator);
    event SetFeeParams(uint128 numerator, uint128 denominator);
    event Locked(uint256 amountLocked);
    event LiquidityAdded(uint256 lpAmount, uint256 xlpAmount, uint256 curveTokenAmount);
    event LiquidityRemoved(uint256 lpAmount, uint256 xlpAmount, uint256 curveTokenAmount);
    event WithdrawAndReLock(bytes32 _kekId, uint256 amount);
    event RewardHarvested(address token, address to, uint256 distributionAmount, uint256 feeAmount);
    event RewardClaimed(uint256[] data);
    event SetVeFXSProxy(address proxy);
    event MigratorToggled(address migrator);
    event RewardsManagerSet(address manager);
    event FeeCollectorSet(address feeCollector);
    event TokenRecovered(address user, uint256 amount);
    event CoinExchanged(address coinSent, uint256 amountSent, uint256 amountReceived);
    event RemovedLiquidityImbalance(uint256 _amount0, uint256 _amounts1, uint256 burnAmount);
    event PegDefenderSet(address defender);
    event FarmLockTimeSet(uint256 secs);
    event OperatorOnlyModeSet(bool value);
    event OperatorSet(address operator);

    constructor(
        address _lpFarm,
        address _lpToken,
        address _xlpToken,
        address _curveStableSwap,
        address _rewardsManager,
        address _feeCollector
    ) {
        lpFarm = IUnifiedFarm(_lpFarm);
        lpToken = IERC20(_lpToken);
        xlpToken = IXLPToken(_xlpToken);

        curveStableSwap = IStableSwap(_curveStableSwap);
        (staxReceiptTokenIndex, inputTokenIndex) = curveStableSwap.coins(0) == address(xlpToken)
            ? (int128(0), int128(1))
            : (int128(1), int128(0));

        rewardsManager = _rewardsManager;
        feeCollector = _feeCollector;
        
        lockRate.numerator = 100;
        lockRate.denominator = 100;

        feeRate.numerator = 0;
        feeRate.denominator = 100;

        farmLockTime = lpFarm.lock_time_for_max_multiplier();

        operatorOnlyMode = false;
    }

    function setLockParams(uint128 _numerator, uint128 _denominator) external onlyOwner {

        require(_denominator > 0 && _numerator <= _denominator, "invalid params");
        lockRate.numerator = _numerator;
        lockRate.denominator = _denominator;

        emit SetLockParams(_numerator, _denominator);
    }

    function setRewardsManager(address _manager) external onlyOwner {

        require(_manager != address(0), "invalid address");
        rewardsManager = _manager;

        emit RewardsManagerSet(_manager);
    }

    function setFeeParams(uint128 _numerator, uint128 _denominator) external onlyOwner {

        require(_denominator > 0 && _numerator <= _denominator, "invalid params");
        feeRate.numerator = _numerator;
        feeRate.denominator = _denominator;

        emit SetFeeParams(_numerator, _denominator);
    }

    function setFeeCollector(address _feeCollector) external onlyOwner {

        require(_feeCollector != address(0), "invalid address");
        feeCollector = _feeCollector;

        emit FeeCollectorSet(_feeCollector);
    }

    function setFarmLockTime(uint256 _secs) external onlyOwner {

        require(_secs >= lpFarm.lock_time_min(), "Minimum lock time not met");
        require(_secs <= lpFarm.lock_time_for_max_multiplier(),"Trying to lock for too long");
        farmLockTime = _secs;
        emit FarmLockTimeSet(_secs);
    }

    function setLPFarm(address _lpFarm) external onlyOwner {

        require(_lpFarm != address(0), "invalid address");
        lpFarm = IUnifiedFarm(_lpFarm);
    }

    function setRewardTokens() external {

        address[] memory tokens = lpFarm.getAllRewardTokens();
        for (uint i=0; i<tokens.length; i++) {
            rewardTokens.push(IERC20(tokens[i]));
        }
    }

    function setPegDefender(address _pegDefender) external onlyOwner {

        pegDefender = _pegDefender;
        emit PegDefenderSet(_pegDefender);
    }

    function setOperatorOnlyMode(bool _operatorOnlyMode) external onlyOwner {

        operatorOnlyMode = _operatorOnlyMode;
        emit OperatorOnlyModeSet(_operatorOnlyMode);
    }

    function setOperator(address _operator) external onlyOwner {

        operator = _operator;
        emit OperatorSet(_operator);
    }

    function exchange(
        address _coinIn,
        uint256 _amount,
        uint256 _minAmountOut
    ) external onlyPegDefender {

        (int128 in_index, int128 out_index) = (staxReceiptTokenIndex, inputTokenIndex);

        if (_coinIn == address(xlpToken)) {
            uint256 balance = xlpToken.balanceOf(address(this));
            require(_amount <= balance, "not enough tokens");
            xlpToken.safeIncreaseAllowance(address(curveStableSwap), _amount);
        } else if (_coinIn == address(lpToken)) {
            uint256 balance = lpToken.balanceOf(address(this));
            require(_amount <= balance, "not enough tokens");
            lpToken.safeIncreaseAllowance(address(curveStableSwap), _amount);
            (in_index, out_index) = (inputTokenIndex, staxReceiptTokenIndex);
        } else {
            revert("unknown token");
        }

        uint256 amountReceived = curveStableSwap.exchange(in_index, out_index, _amount, _minAmountOut);

        emit CoinExchanged(_coinIn, _amount, amountReceived);
    }

    function removeLiquidityImbalance(
        uint256[2] memory _amounts,
        uint256 _maxBurnAmount
    ) external onlyPegDefender {

        require(curveStableSwap.balanceOf(address(this)) > 0, "no liquidity");
        uint256 burnAmount = curveStableSwap.remove_liquidity_imbalance(_amounts, _maxBurnAmount, address(this));

        emit RemovedLiquidityImbalance(_amounts[0], _amounts[1], burnAmount);
    }

    function lockInGauge(uint256 liquidity) private {

        lpToken.safeIncreaseAllowance(address(lpFarm), liquidity);

        IUnifiedFarm.LockedStake[] memory lockedStakes = lpFarm.lockedStakesOf(address(this));
        uint256 lockedStakesLength = lockedStakes.length;

        if (lockedStakesLength == 0 || block.timestamp >= lockedStakes[lockedStakesLength - 1].ending_timestamp) {
            lpFarm.stakeLocked(liquidity, farmLockTime);
        } else {
            lpFarm.lockAdditional(lockedStakes[lockedStakesLength - 1].kek_id, liquidity);
        }
        
        emit Locked(liquidity);
    }

    function addLiquidity(uint256 _amount, uint256 _minCurveAmountOut) private {

        uint256[2] memory amounts = [_amount, _amount];
        
        xlpToken.mint(address(this), _amount);

        lpToken.safeIncreaseAllowance(address(curveStableSwap), _amount);
        xlpToken.safeIncreaseAllowance(address(curveStableSwap), _amount);

        uint256 liquidity = curveStableSwap.add_liquidity(amounts, _minCurveAmountOut, address(this));
        emit LiquidityAdded(_amount, _amount, liquidity);
    }

    function removeLiquidity(
        uint256 _liquidity,
        uint256 _lpAmountMin,
        uint256 _xlpAmountMin
    ) external onlyPegDefender {

        uint256 balance = curveStableSwap.balanceOf(address(this));
        require(balance >= _liquidity, "not enough tokens");

        uint256 receivedXlpAmount;
        uint256 receivedLpAmount;
        if (staxReceiptTokenIndex == 0) {
            uint256[2] memory balances = curveStableSwap.remove_liquidity(_liquidity, [_xlpAmountMin, _lpAmountMin]);
            receivedXlpAmount = balances[0];
            receivedLpAmount = balances[1];
        } else {
            uint256[2] memory balances = curveStableSwap.remove_liquidity(_liquidity, [_lpAmountMin, _xlpAmountMin]);
            receivedXlpAmount = balances[1];
            receivedLpAmount = balances[0];
        }

        emit LiquidityRemoved(receivedLpAmount, receivedXlpAmount, _liquidity);
    }

    function applyLiquidityAmounts(uint256 _liquidity) private view returns (uint256 lockAmount, uint256 addLiquidityAmount) {

        lockAmount = (_liquidity * lockRate.numerator) / lockRate.denominator;
        unchecked {
            addLiquidityAmount = _liquidity - lockAmount;
        }
    }

    function minCurveLiquidityAmountOut(uint256 _liquidity, uint256 _modelSlippage) external view returns (uint256 minCurveTokenAmount) {

        uint256 feeAndSlippage = _modelSlippage + curveStableSwap.fee();
        require(feeAndSlippage <= CURVE_FEE_DENOMINATOR, "invalid slippage");
        (, uint256 addLiquidityAmount) = applyLiquidityAmounts(_liquidity);
        
        minCurveTokenAmount = 0;
        if (addLiquidityAmount > 0) {
            uint256[2] memory amounts = [addLiquidityAmount, addLiquidityAmount];
            minCurveTokenAmount = curveStableSwap.calc_token_amount(amounts, true);
            unchecked {
                minCurveTokenAmount -= minCurveTokenAmount * feeAndSlippage / CURVE_FEE_DENOMINATOR;
            }
        }
    }

    function applyLiquidity(uint256 _liquidity, uint256 _minCurveTokenAmount) external onlyOperator {

        require(_liquidity <= lpToken.balanceOf(address(this)), "not enough liquidity");
        (uint256 lockAmount, uint256 addLiquidityAmount) = applyLiquidityAmounts(_liquidity);

        if (lockAmount > 0) {
            lockInGauge(lockAmount);
        }

        if (addLiquidityAmount > 0) {
            addLiquidity(addLiquidityAmount, _minCurveTokenAmount);
        }
    }

    function withdrawAndRelock(bytes32 _oldKekId) external {

        uint256 lpTokensBefore = lpToken.balanceOf(address(this));
        lpFarm.withdrawLocked(_oldKekId, address(this));
        uint256 lpTokensAfter = lpToken.balanceOf(address(this));
        uint256 lockAmount;
        unchecked {
            lockAmount = lpTokensAfter - lpTokensBefore;
        }

        require(lockAmount > 0, "nothing to withdraw");
        lpToken.safeIncreaseAllowance(address(lpFarm), lockAmount);

        IUnifiedFarm.LockedStake[] memory lockedStakes = lpFarm.lockedStakesOf(address(this));
        uint256 lockedStakesLength = lockedStakes.length;
        if (block.timestamp >= lockedStakes[lockedStakesLength - 1].ending_timestamp) {
            lpFarm.stakeLocked(lockAmount, farmLockTime);
        } else {
            lpFarm.lockAdditional(lockedStakes[lockedStakesLength - 1].kek_id, lockAmount);
        }

        emit WithdrawAndReLock(_oldKekId, lockAmount);
    }

    function getReward() external returns (uint256[] memory data) {

        data = lpFarm.getReward(address(this));

        emit RewardClaimed(data);
    }

    function _getFeeAmount(uint256 _amount) internal view returns (uint256) {

        return (_amount * feeRate.numerator) / feeRate.denominator;
    }

    function harvestRewards() external {

        for (uint i=0; i<rewardTokens.length; i++) {
            IERC20 token = rewardTokens[i];
            uint256 amount = token.balanceOf(address(this));
            uint256 feeAmount = _getFeeAmount(amount);

            if (feeAmount > 0) {
                amount -= feeAmount;
                token.safeTransfer(feeCollector, feeAmount);
            }
            if (amount > 0) {
                token.safeTransfer(rewardsManager, amount);
            }

            emit RewardHarvested(address(token), rewardsManager, amount, feeAmount);
        }
    }

    function setVeFXSProxy(address _proxy) external onlyOwner {

        lpFarm.stakerSetVeFXSProxy(_proxy);

        emit SetVeFXSProxy(_proxy);
    }

    function withdrawLocked(bytes32 kek_id, address destination_address) external onlyOwner {

        lpFarm.withdrawLocked(kek_id, destination_address);
    }
    
    function stakerToggleMigrator(address _migrator) external onlyOwner {

        lpFarm.stakerToggleMigrator(_migrator);

        emit MigratorToggled(_migrator);
    }

    function recoverToken(address _token, address _to, uint256 _amount) external onlyOwnerOrPegDefender {

        for (uint i=0; i<rewardTokens.length; i++) {
            require(_token != address(rewardTokens[i]), "can't recover reward token this way");
        }

        _transferToken(IERC20(_token), _to, _amount);

        emit TokenRecovered(_to, _amount);
    }

    function _transferToken(IERC20 _token, address _to, uint256 _amount) internal {

        uint256 balance = _token.balanceOf(address(this));
        require(_amount <= balance, "not enough tokens");
        _token.safeTransfer(_to, _amount);
    }

    modifier onlyPegDefender() {

        require(msg.sender == pegDefender, "not defender");
        _;
    }

    modifier onlyOwnerOrPegDefender {

        require(msg.sender == owner() || msg.sender == pegDefender, "only owner or defender");
        _;
    }

    modifier onlyOperator {

        require(!operatorOnlyMode || msg.sender == operator, "not operator");
        _;
    }
}