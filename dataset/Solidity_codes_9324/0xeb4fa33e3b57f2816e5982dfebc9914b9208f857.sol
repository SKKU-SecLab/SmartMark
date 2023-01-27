
pragma solidity ^0.8.1;

library AddressUpgradeable {

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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity 0.8.11;


interface IPancakeFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;


    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

}


interface IPancakePair {

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

}

interface IPancakeRouter01 {

    function factory() external view returns (address);

    function WETH() external view returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}// MIT

pragma solidity 0.8.11;

contract JaxProtection {


    struct RunProtection {
        bytes32 data_hash;
        uint64 request_timestamp;
        address sender;
        bool executed;
    }

    mapping(bytes4 => RunProtection) run_protection_info;

    event Request_Update(bytes4 sig, bytes data);

    function _runProtection() internal returns(bool) {

        RunProtection storage protection = run_protection_info[msg.sig];
        bytes32 data_hash = keccak256(msg.data);
        if(data_hash != protection.data_hash || protection.sender != msg.sender) {
            protection.sender = msg.sender;
            protection.data_hash = data_hash;
            protection.request_timestamp = uint64(block.timestamp);
            protection.executed = false;
            emit Request_Update(msg.sig, msg.data);
            return false;
        }
        require(!protection.executed, "Already executed");
        require(block.timestamp >= uint(protection.request_timestamp) + 2 days, "Running is Locked");
        protection.executed = true;
        return true;
    }

    modifier runProtection() {

        if(_runProtection()) {
            _;
        }
    }
}// MIT

pragma solidity 0.8.11;


interface IJaxStakeAdmin {


    function owner() external view returns(address);


    function wjxn() external view returns(IERC20MetadataUpgradeable);

    function usdt() external view returns(IERC20MetadataUpgradeable);


    function apys(uint plan) external view returns (uint);

    
    function min_unlocked_deposit_amount() external view returns (uint);

    function max_unlocked_deposit_amount() external view returns (uint);


    function min_locked_deposit_amount() external view returns (uint);

    function max_locked_deposit_amount() external view returns (uint);


    function collateral_ratio() external view returns (uint);


    function referral_ratio() external view returns (uint);


    function wjxn_default_discount_ratio() external view returns (uint);


    function lock_plans(uint plan) external view returns(uint);


    function max_unlocked_stake_amount() external view returns (uint);


    function max_locked_stake_amount() external view returns (uint);


    function get_wjxn_price() external view returns(uint);

    function is_deposit_freezed() external view returns(bool);

    function referrers(uint id) external view returns(address);

    function referrer_status(uint id) external view returns(bool);

}

contract JaxStake is Initializable, JaxProtection, ReentrancyGuardUpgradeable {

    
    using SafeERC20Upgradeable for IERC20MetadataUpgradeable;

    IJaxStakeAdmin public stakeAdmin;

    uint public total_stake_amount;
    uint public unlocked_stake_amount;
    uint public locked_stake_amount;


    struct Stake {
        uint amount;
        uint apy;
        uint reward_released;
        uint start_timestamp;
        uint harvest_timestamp;
        uint end_timestamp;
        uint unstake_timestamp;
        uint referral_id;
        address owner;
        uint plan;
        bool is_withdrawn;
    }

    Stake[] public stake_list;
    mapping(address => uint[]) public user_stakes; 
    mapping(address => bool) public is_user_unlocked_staking;

    struct Accountant {
        address account;
        address withdrawal_address;
        address withdrawal_token;
        uint withdrawal_limit;
    }

    Accountant[] public accountants;
    mapping(address => uint) public accountant_to_ids;

    event Stake_USDT(uint stake_id, uint plan, uint amount, uint referral_id);
    event Harvest(uint stake_id, uint amount);
    event Unstake(uint stake_id);
    event Add_Accountant(uint id, address account, address withdrawal_address, address withdrawal_token, uint withdrawal_limit);
    event Set_Accountant_Withdrawal_Limit(uint id, uint limit);
    event Withdraw_By_Accountant(uint id, address token, address withdrawal_address, uint amount);
    event Withdraw_By_Admin(address token, uint amount);

    modifier checkZeroAddress(address account) {

        require(account != address(0x0), "Only non-zero address");
        _;
    }

    modifier onlyOwner() {

      require(stakeAdmin.owner() == msg.sender, "Caller is not the owner");
      _;
    }

    function initialize(IJaxStakeAdmin _stakeAdmin) external initializer checkZeroAddress(address(_stakeAdmin)) {

        __ReentrancyGuard_init();
        stakeAdmin = _stakeAdmin;
        Accountant memory accountant;
        accountants.push(accountant);
    }

    function stake_usdt(uint plan, uint amount, uint referral_id) external nonReentrant {

        _stake_usdt(plan, amount, referral_id, false);    
    }

    function _stake_usdt(uint plan, uint amount, uint referral_id, bool is_restake) internal {

        require(plan <= 4, "Invalid plan");
        require(!stakeAdmin.is_deposit_freezed(), "Staking is freezed");
        IERC20MetadataUpgradeable usdt = stakeAdmin.usdt();
        if(!is_restake)
            usdt.safeTransferFrom(msg.sender, address(this), amount);
        uint collateral = stakeAdmin.wjxn().balanceOf(address(this));
        total_stake_amount += amount;
        _check_collateral(collateral, total_stake_amount);
        Stake memory stake;
        stake.amount = amount;
        stake.plan = plan;
        stake.apy = stakeAdmin.apys(plan);
        stake.owner = msg.sender;
        stake.start_timestamp = block.timestamp;
        stake.end_timestamp = block.timestamp + stakeAdmin.lock_plans(plan);
        if(plan == 0){ // Unlocked staking
            require(amount >= stakeAdmin.min_unlocked_deposit_amount() && amount <= stakeAdmin.max_unlocked_deposit_amount(), "Out of limit");
            unlocked_stake_amount += amount;
            require(unlocked_stake_amount <= stakeAdmin.max_unlocked_stake_amount(), "max unlocked stake amount");
            require(!is_user_unlocked_staking[msg.sender], "Only one unlocked staking");
            is_user_unlocked_staking[msg.sender] = true;
        }
        else { // Locked Staking
            require(amount >= stakeAdmin.min_locked_deposit_amount() && amount <= stakeAdmin.max_locked_deposit_amount(), "Out of limit");
            locked_stake_amount += amount;
            require(locked_stake_amount <= stakeAdmin.max_locked_stake_amount(), "max locked stake amount");
            if(stakeAdmin.referrer_status(referral_id)) {
                stake.referral_id = referral_id;
                uint referral_amount = amount * stakeAdmin.referral_ratio() * plan / 1e8;
                address referrer = stakeAdmin.referrers(referral_id);
                if(usdt.balanceOf(address(this)) >= referral_amount) {
                    usdt.safeTransfer(referrer, referral_amount);
                }
                else {
                    stakeAdmin.wjxn().safeTransfer(msg.sender, usdt_to_discounted_wjxn_amount(referral_amount));
                }
            }
        }
        stake.harvest_timestamp = stake.start_timestamp;
        uint stake_id = stake_list.length;
        stake_list.push(stake);
        user_stakes[msg.sender].push(stake_id);
        emit Stake_USDT(stake_id, plan, amount, referral_id);
    }
    
    function get_pending_reward(uint stake_id) public view returns(uint) {

        Stake memory stake = stake_list[stake_id];
        uint past_period = 0;
        if(stake.is_withdrawn) return 0;
        if(stake.harvest_timestamp >= stake.end_timestamp) 
            return 0;
        if(block.timestamp >= stake.end_timestamp)
            past_period = stake.end_timestamp - stake.start_timestamp;
        else
            past_period = block.timestamp - stake.start_timestamp;
        uint reward = stake.amount * stake.apy * past_period / 100 / 365 days;
        return reward - stake.reward_released;
    }

    function harvest(uint stake_id) external nonReentrant {

        require(_harvest(stake_id) > 0, "No pending reward");
    }

    function _harvest(uint stake_id) internal returns(uint pending_reward) {

        Stake storage stake = stake_list[stake_id];
        require(stake.owner == msg.sender, "Only staker");
        require(!stake.is_withdrawn, "Already withdrawn");
        pending_reward = get_pending_reward(stake_id);
        if(pending_reward == 0) 
            return 0;
        if(stakeAdmin.usdt().balanceOf(address(this)) >= pending_reward)
            stakeAdmin.usdt().safeTransfer(msg.sender, pending_reward);
        else {
            stakeAdmin.wjxn().safeTransfer(msg.sender, usdt_to_discounted_wjxn_amount(pending_reward));
        }
        stake.reward_released += pending_reward;
        stake.harvest_timestamp = block.timestamp;
        emit Harvest(stake_id, pending_reward);
    }

    function unstake(uint stake_id) external nonReentrant {

        _unstake(stake_id, false);
    }

    function _unstake(uint stake_id, bool is_restake) internal {

        require(stake_id < stake_list.length, "Invalid stake id");
        Stake storage stake = stake_list[stake_id];
        require(stake.owner == msg.sender, "Only staker");
        require(!stake.is_withdrawn, "Already withdrawn");
        require(stake.plan == 0 || stake.end_timestamp <= block.timestamp, "Locked");
        _harvest(stake_id);
        if(!is_restake) {
            if(stake.amount <= stakeAdmin.usdt().balanceOf(address(this)))
                stakeAdmin.usdt().safeTransfer(stake.owner, stake.amount);
            else 
                stakeAdmin.wjxn().safeTransfer(msg.sender, usdt_to_discounted_wjxn_amount(stake.amount));
        }
        if(stake.plan == 0) {
            unlocked_stake_amount -= stake.amount;
            is_user_unlocked_staking[msg.sender] = false;
        }
        else
            locked_stake_amount -= stake.amount;
        stake.is_withdrawn = true;
        stake.unstake_timestamp = block.timestamp;
        total_stake_amount -= stake.amount;
        emit Unstake(stake_id);
    }

    function restake(uint stake_id) external nonReentrant {

        Stake memory stake = stake_list[stake_id];
        _unstake(stake_id, true);
        _stake_usdt(stake.plan, stake.amount, stake.referral_id, true);
    }

    function usdt_to_discounted_wjxn_amount(uint usdt_amount) public view returns (uint){

        return usdt_amount * (10 ** (18 - stakeAdmin.usdt().decimals())) * 100 / (100 - stakeAdmin.wjxn_default_discount_ratio()) / stakeAdmin.get_wjxn_price();
    }

    function _check_collateral(uint collateral, uint stake_amount) internal view {

        uint collateral_in_usdt = collateral * stakeAdmin.get_wjxn_price() * (10 ** stakeAdmin.usdt().decimals()) * 100 / (stakeAdmin.collateral_ratio() * 1e18);  
        require(stake_amount <= collateral_in_usdt, "Lack of collateral");
    }

    function get_user_stakes(address user) external view returns(uint[] memory) {

        return user_stakes[user];
    }

    function add_accountant(address account, address withdrawal_address, address withdrawal_token, uint withdrawal_limit) external onlyOwner runProtection {

        require(accountant_to_ids[account] == 0, "Already exists");
        Accountant memory accountant;
        accountant.account = account;
        accountant.withdrawal_address = withdrawal_address;
        accountant.withdrawal_token = withdrawal_token;
        accountant.withdrawal_limit = withdrawal_limit;
        accountants.push(accountant);
        uint accountant_id = accountants.length - 1;
        accountant_to_ids[account] = accountant_id;
        emit Add_Accountant(accountant_id, account, withdrawal_address, withdrawal_token, withdrawal_limit);
    }

    function set_accountant_withdrawal_limit(uint id, uint limit) external onlyOwner {

        require(id > 0 && id < accountants.length, "Invalid accountant id");
        Accountant storage accountant = accountants[id];
        accountant.withdrawal_limit = limit;
        emit Set_Accountant_Withdrawal_Limit(id, limit);
    }

    function withdraw_by_accountant(uint amount) external nonReentrant runProtection {

        uint id = accountant_to_ids[msg.sender];
        require(id > 0, "Not an accountant");
        Accountant storage accountant = accountants[id];
        require(accountant.withdrawal_limit >= amount, "Out of withdrawal limit");
        IERC20MetadataUpgradeable(accountant.withdrawal_token).safeTransfer(accountant.withdrawal_address, amount);
        accountant.withdrawal_limit -= amount;
        emit Withdraw_By_Accountant(id, accountant.withdrawal_token, accountant.withdrawal_address, amount);
    }

    function withdrawByAdmin(address token, uint amount) external onlyOwner nonReentrant runProtection{

        if(token == address(stakeAdmin.wjxn())) {
            uint collateral = stakeAdmin.wjxn().balanceOf(address(this));
            require(collateral >= amount, "Out of balance");
            _check_collateral(collateral - amount, total_stake_amount);
        }
        IERC20MetadataUpgradeable(token).safeTransfer(msg.sender, amount);
        emit Withdraw_By_Admin(token, amount);
    }  

}