

pragma solidity 0.6.8;


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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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

}

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

interface IController {
    
    function rewardToken() external returns (address);
}

interface IStrategy {

    function want() external view returns (address);

    function balanceOf() external view returns (uint256);

    function deposit() external;

    function withdraw(uint256 _amount) external;

    function withdrawAll() external returns (uint256);
    
    function harvest() external;
}

contract Vault is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 public token;
    address public governance;
    address public strategist;
    address public strategy;

    event Deposited(address indexed user, address indexed token, uint256 amount, uint256 shareAmount);
    event Withdrawn(address indexed user, address indexed token, uint256 amount, uint256 shareAmount);

    constructor(string memory _name, string memory _symbol, address _token) public ERC20(_name, _symbol) {
        token = IERC20(_token);
        governance = msg.sender;
        strategist = msg.sender;
    }

    function balance() public view returns (uint256) {
        return strategy == address(0x0) ? token.balanceOf(address(this)) :
            token.balanceOf(address(this)).add(IStrategy(strategy).balanceOf());
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "not governance");
        governance = _governance;
    }

    function setStrategist(address _strategist) public {
        require(msg.sender == governance, "not governance");
        strategist = _strategist;
    }

    function setStrategy(address _strategy) public {
        require(msg.sender == governance, "not governance");
        require(address(token) == IStrategy(_strategy).want(), "different token");

        if (strategy != address(0x0)) {
            IStrategy(strategy).withdrawAll();
        }

        strategy = _strategy;
        earn();
    }

    function earn() public {
        if (strategy != address(0x0)) {
            uint256 _bal = token.balanceOf(address(this));
            token.safeTransfer(strategy, _bal);
            IStrategy(strategy).deposit();
        }
    }

    function harvest() public {
        require(msg.sender == strategist || msg.sender == governance, "not authorized");
        require(strategy != address(0x0), "no strategy");
        IStrategy(strategy).harvest();
    }

    function depositAll() public virtual {
        deposit(token.balanceOf(msg.sender));
    }

    function deposit(uint256 _amount) public virtual {
        require(_amount > 0, "zero amount");
        uint256 _pool = balance();
        uint256 _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = token.balanceOf(address(this));
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount.mul(totalSupply())).div(_pool);
        }
        _mint(msg.sender, shares);

        emit Deposited(msg.sender, address(token), _amount, shares);
    }

    function withdrawAll() public virtual {
        withdraw(balanceOf(msg.sender));
    }

    function withdraw(uint256 _shares) public virtual {
        require(_shares > 0, "zero amount");
        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint256 b = token.balanceOf(address(this));
        if (b < r) {
            uint256 _withdraw = r.sub(b);
            require(strategy != address(0x0), "no strategy");
            IStrategy(strategy).withdraw(_withdraw);
            uint256 _after = token.balanceOf(address(this));
            uint256 _diff = _after.sub(b);
            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }

        token.safeTransfer(msg.sender, r);
        emit Withdrawn(msg.sender, address(token), r, _shares);
    }

    function salvage(address _tokenAddress, uint256 _amount) public {
        require(msg.sender == strategist || msg.sender == governance, "not authorized");
        require(_tokenAddress != address(token), "cannot salvage");
        require(_amount > 0, "zero amount");
        IERC20(_tokenAddress).safeTransfer(governance, _amount);
    }

    function getPricePerFullShare() public view returns (uint256) {
        if (totalSupply() == 0) return 0;
        return balance().mul(1e18).div(totalSupply());
    }
}

contract RewardedVault is Vault {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public controller;
    uint256 public constant DURATION = 7 days;      // Rewards are vested for a fixed duration of 7 days.
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public claims;

    event RewardAdded(address indexed rewardToken, uint256 rewardAmount);
    event RewardPaid(address indexed rewardToken, address indexed user, uint256 rewardAmount);

    constructor(string memory _name, string memory _symbol, address _controller, address _vaultToken) public Vault(_name, _symbol, _vaultToken) {
        require(_controller != address(0x0), "controller not set");

        controller = _controller;
    }

    function setController(address _controller) public {
        require(msg.sender == governance, "not governance");
        require(_controller != address(0x0), "controller not set");

        controller = _controller;
    }

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
        return Math.min(block.timestamp, periodFinish);
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

    function depositAll() public virtual override updateReward(msg.sender) {
        super.depositAll();
    }

    function withdraw(uint256 _shares) public virtual override updateReward(msg.sender) {
        super.withdraw(_shares);
    }

    function withdrawAll() public virtual override updateReward(msg.sender) {
        super.withdrawAll();
    }

    function exit() external {
        withdrawAll();
        claimReward();
    }

    function claimReward() public updateReward(msg.sender) returns (uint256) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            claims[msg.sender] = claims[msg.sender].add(reward);
            rewards[msg.sender] = 0;
            address rewardToken = IController(controller).rewardToken();
            IERC20(rewardToken).safeTransfer(msg.sender, reward);
            emit RewardPaid(rewardToken, msg.sender, reward);
        }

        return reward;
    }

    function notifyRewardAmount(uint256 _reward) public updateReward(address(0)) {
        require(msg.sender == controller, "not controller");

        if (block.timestamp >= periodFinish) {
            rewardRate = _reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = _reward.add(leftover).div(DURATION);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);

        emit RewardAdded(IController(controller).rewardToken(), _reward);
    }
}

interface IMigrator {

    function want() external view returns (address);

    function get() external view returns (address);

    function migrate() external;
}

contract ACoconutVault is RewardedVault {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public migrationDue;
    bool public migrated;
    address public migrator;

    constructor(string memory _name, string memory _symbol, address _controller, address _vaultToken, uint256 _migrationDue)
        public RewardedVault(_name, _symbol, _controller, _vaultToken) {
        migrationDue = _migrationDue;
    }

    function setMigrator(address _migrator) public {
        require(msg.sender == governance, "not governance");
        require(_migrator != address(0x0), "migrator not set");
        require(!migrated, "migrated");
        require(IMigrator(_migrator).want() == address(token), "different token");
        migrator = _migrator;
    }

    function setMigrationDue(uint256 _migrationDue) public {
        require(msg.sender == governance, "not governance");
        require(!migrated, "migrated");

        migrationDue = _migrationDue;
    }

    function migrate() public {
        require(msg.sender == governance, "not governance");
        require(block.timestamp >= migrationDue, "not due");
        require(!migrated, "migrated");
        require(migrator != address(0x0), "migrator not set");

        if (strategy != address(0x0)) {
            IStrategy(strategy).harvest();
            IStrategy(strategy).withdrawAll();
        }
        IERC20(token).safeTransfer(migrator, IERC20(token).balanceOf(address(this)));

        IMigrator(migrator).migrate();
        migrated = true;

        token = IERC20(IMigrator(migrator).get());
        strategy = address(0x0);
    }
}