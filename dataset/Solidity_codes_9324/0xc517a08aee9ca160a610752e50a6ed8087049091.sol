
pragma solidity 0.8.4;

contract OwnerController {

    address private _owner;
    address private _controller;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event ControlTransferred(
        address indexed previousController,
        address indexed newController
    );

    constructor() {
        _owner = msg.sender;
        _controller = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        emit ControlTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function controller() public view returns (address) {

        return _controller;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "oc1");
        _;
    }

    modifier onlyController() {

        require(_controller == msg.sender, "oc2");
        _;
    }

    function requireOwner() internal view {

        require(_owner == msg.sender, "oc1");
    }

    function requireController() internal view {

        require(_controller == msg.sender, "oc2");
    }

    function transferOwnership(address newOwner) public virtual {

        requireOwner();
        require(newOwner != address(0), "oc3");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferControl(address newController) public virtual {

        requireOwner();
        require(newController != address(0), "oc4");
        emit ControlTransferred(_controller, newController);
        _controller = newController;
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
}/*
IPool

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;

interface IPool {

    function stakingTokens() external view returns (address[] memory);


    function rewardTokens() external view returns (address[] memory);


    function stakingBalances(address user)
        external
        view
        returns (uint256[] memory);


    function stakingTotals() external view returns (uint256[] memory);


    function rewardBalances() external view returns (uint256[] memory);


    function usage() external view returns (uint256);


    function stakingModule() external view returns (address);


    function rewardModule() external view returns (address);


    function stake(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external;


    function unstake(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external;


    function claim(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external;


    function update() external;


    function clean() external;


    function gysrBalance() external view returns (uint256);


    function withdraw(uint256 amount) external;

}/*
IPoolFactory

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;

interface IPoolFactory {

    function treasury() external view returns (address);


    function fee() external view returns (uint256);

}/*
IEvents

https://github.com/gysr-io/core

MIT
 */

pragma solidity 0.8.4;

interface IEvents {

    event Staked(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event Unstaked(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event Claimed(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );

    event RewardsDistributed(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event RewardsFunded(
        address indexed token,
        uint256 amount,
        uint256 shares,
        uint256 timestamp
    );
    event RewardsUnlocked(address indexed token, uint256 shares);
    event RewardsExpired(
        address indexed token,
        uint256 amount,
        uint256 shares,
        uint256 timestamp
    );

    event GysrSpent(address indexed user, uint256 amount);
    event GysrVested(address indexed user, uint256 amount);
    event GysrWithdrawn(uint256 amount);
}/*
IStakingModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;




abstract contract IStakingModule is OwnerController, IEvents {
    uint256 public constant DECIMALS = 18;

    function tokens() external view virtual returns (address[] memory);

    function balances(address user)
        external
        view
        virtual
        returns (uint256[] memory);

    function factory() external view virtual returns (address);

    function totals() external view virtual returns (uint256[] memory);

    function stake(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function unstake(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function claim(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function update(address user) external virtual;

    function clean() external virtual;
}/*
IRewardModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;




abstract contract IRewardModule is OwnerController, IEvents {
    uint256 public constant DECIMALS = 18;

    function tokens() external view virtual returns (address[] memory);

    function balances() external view virtual returns (uint256[] memory);

    function usage() external view virtual returns (uint256);

    function factory() external view virtual returns (address);

    function stake(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function unstake(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function claim(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function update(address user) external virtual;

    function clean() external virtual;
}/*
Pool

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;



contract Pool is IPool, IEvents, ReentrancyGuard, OwnerController {

    using SafeERC20 for IERC20;

    uint256 public constant DECIMALS = 18;

    IStakingModule private immutable _staking;
    IRewardModule private immutable _reward;

    IERC20 private immutable _gysr;
    IPoolFactory private immutable _factory;
    uint256 private _gysrVested;

    constructor(
        address staking_,
        address reward_,
        address gysr_,
        address factory_
    ) {
        _staking = IStakingModule(staking_);
        _reward = IRewardModule(reward_);
        _gysr = IERC20(gysr_);
        _factory = IPoolFactory(factory_);
    }


    function stakingTokens() external view override returns (address[] memory) {

        return _staking.tokens();
    }

    function rewardTokens() external view override returns (address[] memory) {

        return _reward.tokens();
    }

    function stakingBalances(address user)
        external
        view
        override
        returns (uint256[] memory)
    {

        return _staking.balances(user);
    }

    function stakingTotals() external view override returns (uint256[] memory) {

        return _staking.totals();
    }

    function rewardBalances()
        external
        view
        override
        returns (uint256[] memory)
    {

        return _reward.balances();
    }

    function usage() external view override returns (uint256) {

        return _reward.usage();
    }

    function stakingModule() external view override returns (address) {

        return address(_staking);
    }

    function rewardModule() external view override returns (address) {

        return address(_reward);
    }

    function stake(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external override nonReentrant {

        (address account, uint256 shares) =
            _staking.stake(msg.sender, amount, stakingdata);
        (uint256 spent, uint256 vested) =
            _reward.stake(account, msg.sender, shares, rewarddata);
        _processGysr(spent, vested);
    }

    function unstake(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external override nonReentrant {

        (address account, uint256 shares) =
            _staking.unstake(msg.sender, amount, stakingdata);
        (uint256 spent, uint256 vested) =
            _reward.unstake(account, msg.sender, shares, rewarddata);
        _processGysr(spent, vested);
    }

    function claim(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external override nonReentrant {

        (address account, uint256 shares) =
            _staking.claim(msg.sender, amount, stakingdata);
        (uint256 spent, uint256 vested) =
            _reward.claim(account, msg.sender, shares, rewarddata);
        _processGysr(spent, vested);
    }

    function update() external override nonReentrant {

        _staking.update(msg.sender);
        _reward.update(msg.sender);
    }

    function clean() external override nonReentrant {

        requireController();
        _staking.clean();
        _reward.clean();
    }

    function gysrBalance() external view override returns (uint256) {

        return _gysrVested;
    }

    function withdraw(uint256 amount) external override {

        requireController();
        require(amount > 0, "p1");
        require(amount <= _gysrVested, "p2");

        _gysr.safeTransfer(msg.sender, amount);

        _gysrVested = _gysrVested - amount;

        emit GysrWithdrawn(amount);
    }

    function transferControl(address newController) public override {

        super.transferControl(newController);
        _staking.transferControl(newController);
        _reward.transferControl(newController);
    }


    function _processGysr(uint256 spent, uint256 vested) private {

        if (spent > 0) {
            _gysr.safeTransferFrom(msg.sender, address(this), spent);
        }

        if (vested > 0) {
            uint256 fee = (vested * _factory.fee()) / 10**DECIMALS;
            if (fee > 0) {
                _gysr.safeTransfer(_factory.treasury(), fee);
            }
            _gysrVested = _gysrVested + vested - fee;
        }
    }
}/*
IModuleFactory

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;

interface IModuleFactory {

    event ModuleCreated(address indexed user, address module);

    function createModule(bytes calldata data) external returns (address);

}/*
PoolFactory

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;


contract PoolFactory is IPoolFactory, OwnerController {

    event PoolCreated(address indexed user, address pool);
    event FeeUpdated(uint256 previous, uint256 updated);
    event TreasuryUpdated(address previous, address updated);
    event WhitelistUpdated(
        address indexed factory,
        uint256 previous,
        uint256 updated
    );

    enum ModuleFactoryType {Unknown, Staking, Reward}

    uint256 public constant MAX_FEE = 20 * 10**16; // 20%

    mapping(address => bool) public map;
    address[] public list;
    address private _gysr;
    address private _treasury;
    uint256 private _fee;
    mapping(address => ModuleFactoryType) public whitelist;

    constructor(address gysr_, address treasury_) {
        _gysr = gysr_;
        _treasury = treasury_;
        _fee = MAX_FEE;
    }

    function create(
        address staking,
        address reward,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external returns (address) {

        require(whitelist[staking] == ModuleFactoryType.Staking, "f1");
        require(whitelist[reward] == ModuleFactoryType.Reward, "f2");

        address stakingModule =
            IModuleFactory(staking).createModule(stakingdata);
        address rewardModule = IModuleFactory(reward).createModule(rewarddata);

        Pool pool = new Pool(stakingModule, rewardModule, _gysr, address(this));

        IStakingModule(stakingModule).transferOwnership(address(pool));
        IRewardModule(rewardModule).transferOwnership(address(pool));
        pool.transferControl(msg.sender); // this also sets controller for modules
        pool.transferOwnership(msg.sender);

        map[address(pool)] = true;
        list.push(address(pool));

        emit PoolCreated(msg.sender, address(pool));
        return address(pool);
    }

    function treasury() external view override returns (address) {

        return _treasury;
    }

    function fee() external view override returns (uint256) {

        return _fee;
    }

    function setTreasury(address treasury_) external {

        requireController();
        emit TreasuryUpdated(_treasury, treasury_);
        _treasury = treasury_;
    }

    function setFee(uint256 fee_) external {

        requireController();
        require(fee_ <= MAX_FEE, "f3");
        emit FeeUpdated(_fee, fee_);
        _fee = fee_;
    }

    function setWhitelist(address factory_, uint256 type_) external {

        requireController();
        require(type_ <= uint256(ModuleFactoryType.Reward), "f4");
        require(factory_ != address(0), "f5");
        emit WhitelistUpdated(factory_, uint256(whitelist[factory_]), type_);
        whitelist[factory_] = ModuleFactoryType(type_);
    }

    function count() public view returns (uint256) {

        return list.length;
    }
}