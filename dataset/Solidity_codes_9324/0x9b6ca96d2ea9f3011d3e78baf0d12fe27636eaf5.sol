
pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
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

pragma solidity 0.8.3;


interface TokenLike is IERC20 {

    function deposit() external payable;


    function withdraw(uint256) external;

}// MIT

pragma solidity 0.8.3;

interface IPoolRewards {

    event RewardAdded(address indexed rewardToken, uint256 reward, uint256 rewardDuration);
    event RewardPaid(address indexed user, address indexed rewardToken, uint256 reward);
    event RewardTokenAdded(address indexed rewardToken, address[] existingRewardTokens);

    function claimReward(address) external;


    function notifyRewardAmount(
        address _rewardToken,
        uint256 _rewardAmount,
        uint256 _rewardDuration
    ) external;


    function notifyRewardAmount(
        address[] memory _rewardTokens,
        uint256[] memory _rewardAmounts,
        uint256[] memory _rewardDurations
    ) external;


    function updateReward(address) external;


    function claimable(address _account)
        external
        view
        returns (address[] memory _rewardTokens, uint256[] memory _claimableAmounts);


    function lastTimeRewardApplicable(address _rewardToken) external view returns (uint256);


    function rewardForDuration()
        external
        view
        returns (address[] memory _rewardTokens, uint256[] memory _rewardForDuration);


    function rewardPerToken()
        external
        view
        returns (address[] memory _rewardTokens, uint256[] memory _rewardPerTokenRate);

}// MIT

pragma solidity 0.8.3;

interface IVesperPool is IERC20 {

    function deposit() external payable;


    function deposit(uint256 _share) external;


    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts) external returns (bool);


    function excessDebt(address _strategy) external view returns (uint256);


    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;


    function poolRewards() external returns (address);


    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) external;


    function reportLoss(uint256 _loss) external;


    function resetApproval() external;


    function sweepERC20(address _fromToken) external;


    function withdraw(uint256 _amount) external;


    function withdrawETH(uint256 _amount) external;


    function whitelistedWithdraw(uint256 _amount) external;


    function governor() external view returns (address);


    function keepers() external view returns (address[] memory);


    function isKeeper(address _address) external view returns (bool);


    function maintainers() external view returns (address[] memory);


    function isMaintainer(address _address) external view returns (bool);


    function feeCollector() external view returns (address);


    function pricePerShare() external view returns (uint256);


    function strategy(address _strategy)
        external
        view
        returns (
            bool _active,
            uint256 _interestFee,
            uint256 _debtRate,
            uint256 _lastRebalance,
            uint256 _totalDebt,
            uint256 _totalLoss,
            uint256 _totalProfit,
            uint256 _debtRatio
        );


    function stopEverything() external view returns (bool);


    function token() external view returns (IERC20);


    function tokensHere() external view returns (uint256);


    function totalDebtOf(address _strategy) external view returns (uint256);


    function totalValue() external view returns (uint256);


    function withdrawFee() external view returns (uint256);


    function getPricePerShare() external view returns (uint256);

}// MIT

pragma solidity 0.8.3;


contract PoolRewardsStorage {

    address public pool;

    address[] public rewardTokens;

    mapping(address => bool) public isRewardToken;

    mapping(address => uint256) public periodFinish;

    mapping(address => uint256) public rewardRates;

    mapping(address => uint256) public rewardDuration;

    mapping(address => uint256) public lastUpdateTime;

    mapping(address => uint256) public rewardPerTokenStored;

    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;

    mapping(address => mapping(address => uint256)) public rewards;
}

contract PoolRewards is Initializable, IPoolRewards, ReentrancyGuard, PoolRewardsStorage {

    string public constant VERSION = "4.0.0";
    using SafeERC20 for IERC20;

    function initialize(address _pool, address[] memory _rewardTokens) public initializer {

        require(_pool != address(0), "pool-address-is-zero");
        require(_rewardTokens.length != 0, "invalid-reward-tokens");
        pool = _pool;
        rewardTokens = _rewardTokens;
        for (uint256 i = 0; i < _rewardTokens.length; i++) {
            isRewardToken[_rewardTokens[i]] = true;
        }
    }

    modifier onlyAuthorized() {

        require(msg.sender == IVesperPool(pool).governor(), "not-authorized");
        _;
    }

    function notifyRewardAmount(
        address[] memory _rewardTokens,
        uint256[] memory _rewardAmounts,
        uint256[] memory _rewardDurations
    ) external virtual override onlyAuthorized {

        _notifyRewardAmount(_rewardTokens, _rewardAmounts, _rewardDurations, IERC20(pool).totalSupply());
    }

    function notifyRewardAmount(
        address _rewardToken,
        uint256 _rewardAmount,
        uint256 _rewardDuration
    ) external virtual override onlyAuthorized {

        _notifyRewardAmount(_rewardToken, _rewardAmount, _rewardDuration, IERC20(pool).totalSupply());
    }

    function addRewardToken(address _newRewardToken) external onlyAuthorized {

        require(_newRewardToken != address(0), "reward-token-address-zero");
        require(!isRewardToken[_newRewardToken], "reward-token-already-exist");
        emit RewardTokenAdded(_newRewardToken, rewardTokens);
        rewardTokens.push(_newRewardToken);
        isRewardToken[_newRewardToken] = true;
    }

    function claimReward(address _account) external virtual override nonReentrant {

        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _balance = IERC20(pool).balanceOf(_account);
        uint256 _len = rewardTokens.length;
        for (uint256 i = 0; i < _len; i++) {
            address _rewardToken = rewardTokens[i];
            _updateReward(_rewardToken, _account, _totalSupply, _balance);

            uint256 _reward = rewards[_rewardToken][_account];
            if (_reward != 0 && _reward <= IERC20(_rewardToken).balanceOf(address(this))) {
                _claimReward(_rewardToken, _account, _reward);
                emit RewardPaid(_account, _rewardToken, _reward);
            }
        }
    }

    function updateReward(address _account) external override {

        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _balance = IERC20(pool).balanceOf(_account);
        uint256 _len = rewardTokens.length;
        for (uint256 i = 0; i < _len; i++) {
            _updateReward(rewardTokens[i], _account, _totalSupply, _balance);
        }
    }

    function claimable(address _account)
        external
        view
        virtual
        override
        returns (address[] memory _rewardTokens, uint256[] memory _claimableAmounts)
    {

        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _balance = IERC20(pool).balanceOf(_account);
        uint256 _len = rewardTokens.length;
        _claimableAmounts = new uint256[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _claimableAmounts[i] = _claimable(rewardTokens[i], _account, _totalSupply, _balance);
        }
        _rewardTokens = rewardTokens;
    }

    function getRewardTokens() external view returns (address[] memory) {

        return rewardTokens;
    }

    function lastTimeRewardApplicable(address _rewardToken) public view override returns (uint256) {

        return block.timestamp < periodFinish[_rewardToken] ? block.timestamp : periodFinish[_rewardToken];
    }

    function rewardForDuration()
        external
        view
        override
        returns (address[] memory _rewardTokens, uint256[] memory _rewardForDuration)
    {

        uint256 _len = rewardTokens.length;
        _rewardForDuration = new uint256[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _rewardForDuration[i] = rewardRates[rewardTokens[i]] * rewardDuration[rewardTokens[i]];
        }
        _rewardTokens = rewardTokens;
    }

    function rewardPerToken()
        external
        view
        override
        returns (address[] memory _rewardTokens, uint256[] memory _rewardPerTokenRate)
    {

        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _len = rewardTokens.length;
        _rewardPerTokenRate = new uint256[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _rewardPerTokenRate[i] = _rewardPerToken(rewardTokens[i], _totalSupply);
        }
        _rewardTokens = rewardTokens;
    }

    function _claimable(
        address _rewardToken,
        address _account,
        uint256 _totalSupply,
        uint256 _balance
    ) internal view returns (uint256) {

        uint256 _rewardPerTokenAvailable =
            _rewardPerToken(_rewardToken, _totalSupply) - userRewardPerTokenPaid[_rewardToken][_account];
        uint256 _rewardsEarnedSinceLastUpdate = (_balance * _rewardPerTokenAvailable) / 1e18;
        return rewards[_rewardToken][_account] + _rewardsEarnedSinceLastUpdate;
    }

    function _claimReward(
        address _rewardToken,
        address _account,
        uint256 _reward
    ) internal virtual {

        rewards[_rewardToken][_account] = 0;
        IERC20(_rewardToken).safeTransfer(_account, _reward);
    }

    function _notifyRewardAmount(
        address[] memory _rewardTokens,
        uint256[] memory _rewardAmounts,
        uint256[] memory _rewardDurations,
        uint256 _totalSupply
    ) internal {

        uint256 _len = _rewardTokens.length;
        uint256 _amountsLen = _rewardAmounts.length;
        uint256 _durationsLen = _rewardDurations.length;
        require(_len != 0, "invalid-reward-tokens");
        require(_amountsLen != 0, "invalid-reward-amounts");
        require(_durationsLen != 0, "invalid-reward-durations");
        require(_len == _amountsLen && _len == _durationsLen, "array-length-mismatch");
        for (uint256 i = 0; i < _len; i++) {
            _notifyRewardAmount(_rewardTokens[i], _rewardAmounts[i], _rewardDurations[i], _totalSupply);
        }
    }

    function _notifyRewardAmount(
        address _rewardToken,
        uint256 _rewardAmount,
        uint256 _rewardDuration,
        uint256 _totalSupply
    ) internal {

        require(_rewardToken != address(0), "incorrect-reward-token");
        require(_rewardAmount != 0, "incorrect-reward-amount");
        require(_rewardDuration != 0, "incorrect-reward-duration");
        require(isRewardToken[_rewardToken], "invalid-reward-token");

        rewardPerTokenStored[_rewardToken] = _rewardPerToken(_rewardToken, _totalSupply);
        if (block.timestamp >= periodFinish[_rewardToken]) {
            rewardRates[_rewardToken] = _rewardAmount / _rewardDuration;
        } else {
            uint256 remainingPeriod = periodFinish[_rewardToken] - block.timestamp;

            uint256 leftover = remainingPeriod * rewardRates[_rewardToken];
            rewardRates[_rewardToken] = (_rewardAmount + leftover) / _rewardDuration;
        }
        uint256 balance = IERC20(_rewardToken).balanceOf(address(this));
        require(rewardRates[_rewardToken] <= (balance / _rewardDuration), "rewards-too-high");
        rewardDuration[_rewardToken] = _rewardDuration;
        lastUpdateTime[_rewardToken] = block.timestamp;
        periodFinish[_rewardToken] = block.timestamp + _rewardDuration;
        emit RewardAdded(_rewardToken, _rewardAmount, _rewardDuration);
    }

    function _rewardPerToken(address _rewardToken, uint256 _totalSupply) internal view returns (uint256) {

        if (_totalSupply == 0) {
            return rewardPerTokenStored[_rewardToken];
        }

        uint256 _timeSinceLastUpdate = lastTimeRewardApplicable(_rewardToken) - lastUpdateTime[_rewardToken];
        uint256 _rewardsSinceLastUpdate = _timeSinceLastUpdate * rewardRates[_rewardToken];
        uint256 _rewardsPerTokenSinceLastUpdate = (_rewardsSinceLastUpdate * 1e18) / _totalSupply;
        return rewardPerTokenStored[_rewardToken] + _rewardsPerTokenSinceLastUpdate;
    }

    function _updateReward(
        address _rewardToken,
        address _account,
        uint256 _totalSupply,
        uint256 _balance
    ) internal {

        uint256 _rewardPerTokenStored = _rewardPerToken(_rewardToken, _totalSupply);
        rewardPerTokenStored[_rewardToken] = _rewardPerTokenStored;
        lastUpdateTime[_rewardToken] = lastTimeRewardApplicable(_rewardToken);
        if (_account != address(0)) {
            rewards[_rewardToken][_account] = _claimable(_rewardToken, _account, _totalSupply, _balance);
            userRewardPerTokenPaid[_rewardToken][_account] = _rewardPerTokenStored;
        }
    }
}// MIT

pragma solidity 0.8.3;


contract VesperEarnDrip is PoolRewards {

    TokenLike internal constant WETH = TokenLike(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    using SafeERC20 for IERC20;

    event DripRewardPaid(address indexed user, address indexed rewardToken, uint256 reward);
    event GrowTokenUpdated(address indexed oldGrowToken, address indexed newGrowToken);

    address public growToken;

    receive() external payable {
        require(msg.sender == address(WETH), "deposits-not-allowed");
    }

    function claimable(address _account)
        external
        view
        override
        returns (address[] memory _rewardTokens, uint256[] memory _claimableAmounts)
    {

        uint256 _totalSupply = IERC20(pool).totalSupply();
        uint256 _balance = IERC20(pool).balanceOf(_account);
        uint256 _len = rewardTokens.length;
        _claimableAmounts = new uint256[](_len);
        for (uint256 i = 0; i < _len; i++) {
            uint256 _claimableAmount = _claimable(rewardTokens[i], _account, _totalSupply, _balance);
            if (rewardTokens[i] == growToken) {
                _claimableAmount = _calculateRewardInDripToken(growToken, _claimableAmount);
            }
            _claimableAmounts[i] = _claimableAmount;
        }
        _rewardTokens = rewardTokens;
    }

    function notifyRewardAmount(
        address _rewardToken,
        uint256 _rewardAmount,
        uint256 _rewardDuration
    ) external override {

        (bool isStrategy, , , , , , , ) = IVesperPool(pool).strategy(msg.sender);
        require(
            msg.sender == IVesperPool(pool).governor() || (isRewardToken[_rewardToken] && isStrategy),
            "not-authorized"
        );
        super._notifyRewardAmount(_rewardToken, _rewardAmount, _rewardDuration, IVesperPool(pool).totalSupply());
    }

    function updateGrowToken(address _newGrowToken) external onlyAuthorized {

        require(_newGrowToken != address(0), "grow-token-address-zero");
        require(isRewardToken[_newGrowToken], "grow-token-not-reward-token");
        emit GrowTokenUpdated(growToken, _newGrowToken);
        growToken = _newGrowToken;
    }

    function _claimReward(
        address _rewardToken,
        address _account,
        uint256 _reward
    ) internal override {

        if (_rewardToken == growToken) {
            uint256 _rewardInDripToken = _calculateRewardInDripToken(_rewardToken, _reward);
            if (_rewardInDripToken != 0) {
                rewards[_rewardToken][_account] = 0;

                IERC20 _dripToken = IVesperPool(_rewardToken).token();
                uint256 _dripBalanceBefore = _dripToken.balanceOf(address(this));
                IVesperPool(_rewardToken).withdraw(_reward);
                uint256 _dripTokenAmount = _dripToken.balanceOf(address(this)) - _dripBalanceBefore;
                if (address(_dripToken) == address(WETH)) {
                    WETH.withdraw(_dripTokenAmount);
                    Address.sendValue(payable(_account), _dripTokenAmount);
                } else {
                    _dripToken.safeTransfer(_account, _dripTokenAmount);
                }
                emit DripRewardPaid(_account, address(_dripToken), _dripTokenAmount);
            }
        } else {
            super._claimReward(_rewardToken, _account, _reward);
        }
    }

    function _calculateRewardInDripToken(address _rewardToken, uint256 _reward) private view returns (uint256) {

        uint256 _pricePerShare;
        try IVesperPool(_rewardToken).pricePerShare() returns (uint256 _pricePerShareV3) {
            _pricePerShare = _pricePerShareV3;
        } catch {
            _pricePerShare = IVesperPool(_rewardToken).getPricePerShare();
        }
        return (_pricePerShare * _reward) / 1e18;
    }
}