
pragma solidity >=0.6.0 <0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.6.12;

interface IController {


    function governance() external view returns (address);


    function rewardToken() external view returns (address);


    function treasury() external view returns (address);


    function numVaults() external view returns (uint256);


    function vaults(uint256 _vaultId) external view returns (address);

}// MIT
pragma solidity 0.6.12;


interface IVault {


    function token() external view returns (address);


    function controller() external view returns (address);


    function governance() external view returns (address);


    function strategist() external view returns (address);


    function balance() external view returns (uint256);


    function getPricePerFullShare() external view returns (uint256);


    function approvedStrategies(address _strategy) external view returns (bool);


    function activeStrategy() external view returns (address); 


    function emergencyMode() external view returns (bool);


    function deposit(uint256 _amount) external;


    function withdraw(uint256 _shares) external;


    function exit() external;


    function claimReward() external returns (uint256);


    function notifyRewardAmount(uint256 _rewardAmount) external;


    function addRewards(uint256 _rewardAmount) external;


    function setStrategist(address _strategist) external;


    function setEmergencyMode(bool _active) external;


    function setActiveStrategy(address _strategy) external;


    function earn() external;


    function harvest() external;

}// MIT
pragma solidity 0.6.12;

interface IStrategy {


    function vault() external view returns (address);


    function controller() external view returns (address);


    function token() external view returns (address);


    function governance() external view returns (address);


    function strategist() external view returns (address);


    function performanceFee() external view returns (uint256);


    function withdrawalFee() external view returns (uint256);


    function balanceOf() external view returns (uint256);


    function deposit() external;


    function withdraw(uint256 _amount) external;


    function withdrawAll() external returns (uint256);


    function harvest() external;

}// MIT
pragma solidity 0.6.12;



contract VaultBase is ERC20Upgradeable, IVault {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    address public override token;
    address public override controller;
    address public override strategist;
    mapping(address => bool) public override approvedStrategies;
    address public override activeStrategy;
    bool public override emergencyMode;
    mapping(address => uint256) public lockBlocks;

    uint256[50] private __gap;

    event StrategistUpdated(address indexed oldStrategist, address indexed newStrategist);
    event StrategyUpdated(address indexed strategy, bool indexed approved);
    event ActiveStrategyUpdated(address indexed oldStrategy, address indexed newStrategy);
    event EmergencyModeUpdated(bool indexed active);
    event Deposited(address indexed user, address indexed token, uint256 amount, uint256 shareAmount);
    event Withdrawn(address indexed user, address indexed token, uint256 amount, uint256 shareAmount);

    function initialize(address _token, address _controller, string memory _nameOverride, string memory _symbolOverride) public virtual initializer {

        require(_token != address(0x0), "want not set");
        require(_controller != address(0x0), "controller not set");

        token = _token;
        controller = _controller;
        strategist = msg.sender;

        ERC20Upgradeable want = ERC20Upgradeable(_token);
        string memory name;
        string memory symbol;
        if (bytes(_nameOverride).length > 0) {
            name = _nameOverride;
        } else {
            name = string(abi.encodePacked(want.name(), " Vault"));
        }
        if (bytes(_symbolOverride).length > 0) {
            symbol = _symbolOverride;
        } else {
            symbol = string(abi.encodePacked(want.symbol(), "v"));
        }
        __ERC20_init(name, symbol);
        _setupDecimals(want.decimals());
    }

    function governance() public view override returns (address) {

        return IController(controller).governance();
    }

    modifier onlyGovernance() {

        require(msg.sender == governance(), "not governance");
        _;
    }

    modifier onlyStrategist() {

        require(msg.sender == governance() || msg.sender == strategist, "not strategist");
        _;
    }

    modifier notEmergencyMode() {

        require(!emergencyMode, "emergency mode");
        _;
    }

    modifier blockUnlocked() {

        require(lockBlocks[msg.sender] < block.number, "block locked");
        _;
    }

    function _updateLockBlock() internal {

        lockBlocks[msg.sender] = block.number;
    }

    function balance() public override view returns (uint256) {

        IERC20Upgradeable want = IERC20Upgradeable(token);
        return activeStrategy == address(0x0) ? want.balanceOf(address(this)) :
            want.balanceOf(address(this)).add(IStrategy(activeStrategy).balanceOf());
    }

    function setStrategist(address _strategist) public override onlyStrategist {

        address oldStrategist = strategist;
        strategist = _strategist;
        emit StrategistUpdated(oldStrategist, _strategist);
    }

    function setEmergencyMode(bool _active) public override onlyStrategist {

        emergencyMode = _active;
        address currentStrategy = activeStrategy;
        if (_active && currentStrategy != address(0x0)) {
            IStrategy(currentStrategy).withdrawAll();
            activeStrategy = address(0x0);

            emit ActiveStrategyUpdated(currentStrategy, address(0x0));
        }

        emit EmergencyModeUpdated(_active);
    }

    function approveStrategy(address _strategy, bool _approved) public onlyGovernance {

        approvedStrategies[_strategy] = _approved;
        emit StrategyUpdated(_strategy, _approved);
    }

    function setActiveStrategy(address _strategy) public override onlyStrategist notEmergencyMode {

        require(_strategy == address(0x0) || approvedStrategies[_strategy], "strategy not approved");
        address oldStrategy = activeStrategy;
        require(oldStrategy != _strategy, "same strategy");

        if (oldStrategy != address(0x0)) {
            IStrategy(oldStrategy).withdrawAll();
        }

        activeStrategy = _strategy;
        earn();
        emit ActiveStrategyUpdated(oldStrategy, _strategy);
    }

    function earn() public override onlyStrategist notEmergencyMode {

        if (activeStrategy == address(0x0)) return;
        IERC20Upgradeable want = IERC20Upgradeable(token);
        uint256 _bal = want.balanceOf(address(this));
        if (_bal > 0) {
            want.safeTransfer(activeStrategy, _bal);
        }
        IStrategy(activeStrategy).deposit();
    }

    function harvest() public override onlyStrategist notEmergencyMode {

        require(activeStrategy != address(0x0), "no strategy");
        IStrategy(activeStrategy).harvest();
    }

    function deposit(uint256 _amount) public virtual override notEmergencyMode blockUnlocked {

        require(_amount > 0, "zero amount");
        _updateLockBlock();
        IERC20Upgradeable want = IERC20Upgradeable(token);
        if (_amount == uint256(-1)) {
            _amount = want.balanceOf(msg.sender);
        }

        uint256 _pool = balance();
        uint256 _before = want.balanceOf(address(this));
        want.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = want.balanceOf(address(this));
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount.mul(totalSupply())).div(_pool);
        }
        _mint(msg.sender, shares);

        emit Deposited(msg.sender, address(want), _amount, shares);
    }

    function withdraw(uint256 _shares) public virtual override blockUnlocked {

        require(_shares > 0, "zero amount");
        _updateLockBlock();
        IERC20Upgradeable want = IERC20Upgradeable(token);
        if (_shares == uint256(-1)) {
            _shares = balanceOf(msg.sender);
        }
        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint256 b = want.balanceOf(address(this));
        if (b < r) {
            uint256 _withdraw = r.sub(b);
            require(activeStrategy != address(0x0), "no strategy");
            IStrategy(activeStrategy).withdraw(_withdraw);
            uint256 _after = want.balanceOf(address(this));
            uint256 _diff = _after.sub(b);
            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }

        want.safeTransfer(msg.sender, r);
        
        emit Withdrawn(msg.sender, address(want), r, _shares);
    }

    function transfer(address recipient, uint256 amount) public virtual override blockUnlocked returns (bool) {

        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override blockUnlocked returns (bool) {

        return super.transferFrom(sender, recipient, amount);
    }

    function salvage() public onlyStrategist {

        uint256 amount = address(this).balance;
        address payable target = payable(IController(controller).treasury());
        (bool success, ) = target.call{value: amount}(new bytes(0));
        require(success, 'ETH salvage failed');
    }

    function salvageToken(address _tokenAddress) public onlyStrategist {

        require(_tokenAddress != token, "cannot salvage");

        IERC20Upgradeable target = IERC20Upgradeable(_tokenAddress);
        target.safeTransfer(IController(controller).treasury(), target.balanceOf(address(this)));
    }

    function getPricePerFullShare() public override view returns (uint256) {

        if (totalSupply() == 0) return 0;
        return balance().mul(1e18).div(totalSupply());
    }

    function exit() public virtual override {

        withdraw(uint256(-1));
    }

    function claimReward() public virtual override returns (uint256) {

        revert("reward is not supported");
    }

    function notifyRewardAmount(uint256) public virtual override {

        revert("reward is not supported");
    }

    function addRewards(uint256) public virtual override {

        revert("reward is not supported");
    }
}// MIT
pragma solidity 0.6.12;


contract Vault is VaultBase {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    uint256 public constant DURATION = 7 days;      // Rewards are vested for a fixed duration of 7 days.
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public claimed;

    uint256[50] private __gap;

    event RewardAdded(address indexed rewardToken, uint256 rewardAmount);
    event RewardClaimed(address indexed rewardToken, address indexed user, uint256 rewardAmount);

    modifier updateReward(address _account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return MathUpgradeable.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address _account) public view returns (uint256) {

        return
            balanceOf(_account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[_account]))
                .div(1e18)
                .add(rewards[_account]);
    }

    function deposit(uint256 _amount) public virtual override updateReward(msg.sender) {

        super.deposit(_amount);
    }

    function withdraw(uint256 _shares) public virtual override updateReward(msg.sender) {

        super.withdraw(_shares);
    }

    function exit() public virtual override {

        withdraw(uint256(-1));
        claimReward();
    }

    function claimReward() public virtual override updateReward(msg.sender) returns (uint256) {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            claimed[msg.sender] = claimed[msg.sender].add(reward);
            rewards[msg.sender] = 0;
            address rewardToken = IController(controller).rewardToken();
            IERC20Upgradeable(rewardToken).safeTransfer(msg.sender, reward);
            emit RewardClaimed(rewardToken, msg.sender, reward);
        }

        return reward;
    }

    function notifyRewardAmount(uint256 _reward) public virtual override updateReward(address(0)) {

        require(msg.sender == controller, "not controller");

        address rewardToken = IController(controller).rewardToken();
        if (block.timestamp >= periodFinish) {
            rewardRate = _reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = _reward.add(leftover).div(DURATION);
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);

        emit RewardAdded(rewardToken, _reward);
    }

    function addRewards(uint256 _reward) public virtual override updateReward(address(0)) {

        require(_reward > 0, "zero amount");

        address rewardToken = IController(controller).rewardToken();

        uint256 _totalSupply = totalSupply();
        if (_totalSupply != 0) {
            IERC20Upgradeable(rewardToken).safeTransferFrom(msg.sender, address(this), _reward);
            rewardPerTokenStored = rewardPerTokenStored.add(_reward.mul(1e18).div(_totalSupply));
        } else {
            IERC20Upgradeable(rewardToken).safeTransferFrom(msg.sender, IController(controller).treasury(), _reward);
        }

        emit RewardAdded(rewardToken, _reward);
    }
}