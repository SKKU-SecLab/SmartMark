
pragma solidity 0.6.12;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

interface Burnable {
    function burn(uint256 amount) external returns (bool);
}

interface IStrategy {
    function rewards() external view returns (address);

    function gauge() external view returns (address);

    function underlying() external view returns (address);

    function timelock() external view returns (address);

    function vault() external view returns (address);

    function deposit() external;

    function withdraw(uint256) external;

    function withdrawAll() external returns (uint256);

    function balanceOf() external view returns (uint256);

    function harvest() external;

    function salvage(address) external;

    function setTimelock(address _timelock) external;

    function setGovernance(address _governance) external;

    function setTreasury(address _treasury) external;
}

contract YvsVault is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 internal token;
    IERC20 internal yvs;

    address public underlying;

    address public controller;

    uint256 public min = 9500;
    uint256 public constant max = 10000;

    uint256 public burnFee = 5000;
    uint256 public constant burnFeeMax = 7500;
    uint256 public constant burnFeeMin = 2500;
    uint256 public constant burnFeeBase = 10000;

    uint256 public withdrawalFee = 25;
    uint256 public constant withdrawalFeeMax = 25;
    uint256 public constant withdrawalFeeBase = 10000;

    uint256 public minDepositPeriod = 7 days;

    bool public isActive = false;

    address public governance;
    address public treasury;
    address public timelock;
    address public strategy;

    mapping(address => uint256) public depositBlocks;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public issued;
    mapping(address => uint256) public tiers;
    uint256[] public multiplierCosts;
    uint256 internal constant tierMultiplier = 5;
    uint256 internal constant tierBase = 100;
    uint256 public totalDeposited = 0;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event SharesIssued(address indexed user, uint256 amount);
    event SharesPurged(address indexed user, uint256 amount);
    event ClaimRewards(address indexed user, uint256 amount);
    event MultiplierPurchased(address indexed user, uint256 tiers, uint256 totalCost);

    constructor(address _underlying, address _yvs, address _governance, address _treasury, address _timelock)
        public
        ERC20(
            string(abi.encodePacked("yvsie ", ERC20(_underlying).name())),
            string(abi.encodePacked("yvs", ERC20(_underlying).symbol()))
        )
    {
        require(address(_underlying) != address(_yvs), "!underlying");

        _setupDecimals(ERC20(_underlying).decimals());
        token = IERC20(_underlying);
        yvs = IERC20(_yvs);
        underlying = _underlying;
        governance = _governance;
        treasury = _treasury;
        timelock = _timelock;

        multiplierCosts.push(5000000000000000000); // 5 $yvs
        multiplierCosts.push(10000000000000000000); // 10 $yvs
        multiplierCosts.push(20000000000000000000); // 20 $yvs
        multiplierCosts.push(40000000000000000000); // 40 $yvs
        multiplierCosts.push(80000000000000000000); // 80 $yvs
    }

    function balance() public view returns (uint256) {
        return
            token.balanceOf(address(this)).add(
                IStrategy(strategy).balanceOf()
            );
    }

    function setActive(bool _isActive) external isGovernance {
        isActive = _isActive;
    }

    function setMin(uint256 _min) external isGovernance {
        require(_min <= max, "min>max");
        min = _min;
    }

    function setGovernance(address _governance) external isGovernance {
        governance = _governance;
    }

    function setTreasury(address _treasury) external isGovernance {
        treasury = _treasury;
    }

    function setTimelock(address _timelock) external isTimelock {
        timelock = _timelock;
    }

    function setStrategy(address _strategy) external isTimelock {
        require(IStrategy(_strategy).underlying() == address(token), '!underlying');
        strategy = _strategy;
    }

    function setController(address _controller) external isGovernance {
        require(controller == address(0), "!controller");
        controller = _controller;
    }

    function setBurnFee(uint256 _burnFee) public isTimelock {
        require(_burnFee <= burnFeeMax, 'max');
        require(_burnFee >= burnFeeMin, 'min');
        burnFee = _burnFee;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external isTimelock {
        require(_withdrawalFee <= withdrawalFeeMax, "!max");
        withdrawalFee = _withdrawalFee;
    }

    function addMultiplier(uint256 _cost) public isTimelock returns (uint256 index) {
        multiplierCosts.push(_cost);
        index = multiplierCosts.length - 1;
    }

    function setMultiplier(uint256 index, uint256 _cost) public isTimelock {
        multiplierCosts[index] = _cost;
    }

    function available() public view returns (uint256) {
        return token.balanceOf(address(this)).mul(min).div(max);
    }

    function earn() public {
        require(isActive, 'earn: !active');
        require(strategy != address(0), 'earn: !strategy');
        uint256 _bal = available();
        token.safeTransfer(strategy, _bal);
        IStrategy(strategy).deposit();
    }

    function deposit(uint256 _amount) public nonReentrant {
        require(!address(msg.sender).isContract() && msg.sender == tx.origin, "deposit: !contract");
        require(isActive, 'deposit: !vault');
        require(strategy != address(0), 'deposit: !strategy');
        
        uint256 _pool = balance();
        uint256 _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = token.balanceOf(address(this));
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        deposits[msg.sender] = deposits[msg.sender].add(_amount);
        totalDeposited = totalDeposited.add(_amount);
        uint256 shares = 0;
        if (totalSupply() == 0) {
            uint256 userMultiplier = tiers[msg.sender].mul(tierMultiplier).add(tierBase); // 5 %, 10 %, 15 %, 20 %, 25 %
            shares = _amount.mul(userMultiplier).div(tierBase);
        } else {
            uint256 userMultiplier = tiers[msg.sender].mul(tierMultiplier).add(tierBase); // 5 %, 10 %, 15 %, 20 %, 25 %
            shares = (_amount.mul(userMultiplier).div(tierBase).mul(totalSupply())).div(_pool);
        }

        _mint(msg.sender, shares);
        issued[msg.sender] = issued[msg.sender].add(shares);
        depositBlocks[msg.sender] = block.number;
        emit Deposit(msg.sender, _amount);
        emit SharesIssued(msg.sender, shares);
    }

    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }

    function withdraw(uint256 _amount) public nonReentrant {
        require(!address(msg.sender).isContract() && msg.sender == tx.origin, "withdraw: !no contract");
        require(block.number >= depositBlocks[msg.sender].add(minDepositPeriod), 'withdraw: !minDepositPeriod');
        require(_amount > 0, '!positive');
        require(_amount <= deposits[msg.sender], '>deposit');
        require(issued[msg.sender] > 0, '!deposit');

        uint256 shares = issued[msg.sender];
        uint256 p = (_amount.mul(1e18).div(deposits[msg.sender]));
        uint256 r = shares.mul(p).div(1e18);

        require(balanceOf(msg.sender) >= r, "!shares");
        _burn(msg.sender, r);
        issued[msg.sender] = issued[msg.sender].sub(r);

        uint256 rewards = balance().sub(totalDeposited);
        uint256 userRewards = 0;
        if (rewards > 0) {
            userRewards = (rewards.mul(shares)).div(totalSupply());
        }

        if (userRewards > 0) {
            userRewards = userRewards.mul(p).div(1e18);
        }

        uint256 withdrawAmount = _amount.add(userRewards);

        uint256 b = token.balanceOf(address(this));
        if (b < withdrawAmount) {
            uint256 _withdraw = withdrawAmount.sub(b);
            IStrategy(strategy).withdraw(_withdraw);
            uint256 _after = token.balanceOf(address(this));
            uint256 _diff = _after.sub(b);
            if (_diff < _withdraw) {
                withdrawAmount = b.add(_diff);
            }
        }

        deposits[msg.sender] = deposits[msg.sender].sub(_amount);
        totalDeposited = totalDeposited.sub(_amount);

        uint256 _withdrawalFee = _amount.mul(withdrawalFee).div(withdrawalFeeBase);
        token.safeTransfer(treasury, _withdrawalFee);
        token.safeTransfer(msg.sender, withdrawAmount.sub(_withdrawalFee));

        emit Withdraw(msg.sender, _amount);
        emit SharesPurged(msg.sender, r);
        emit ClaimRewards(msg.sender, userRewards);
    }

    function withdrawAll() external {
        withdraw(deposits[msg.sender]);
    }

    function pendingRewards(address account) external view returns (uint256 pending) {
        uint256 rewards = balance().sub(totalDeposited);
        uint256 shares = issued[account];
        if (rewards > 0) {
            pending = (rewards.mul(shares)).div(totalSupply());
        }
    }

    function purchaseMultiplier(uint256 _tiers) external returns (uint256 newTier) {
        require(isActive, '!active');
        require(strategy != address(0), '!strategy');
        require(_tiers > 0, '!tiers');
        uint256 multipliersLength = multiplierCosts.length;
        require(tiers[msg.sender].add(_tiers) <= multipliersLength, '!max');

        uint256 totalCost = 0;
        uint256 lastMultiplier = tiers[msg.sender].add(_tiers);
        for (uint256 i = tiers[msg.sender]; i < multipliersLength; i++) {
            if (i == lastMultiplier) {
                break;
            }
            totalCost = totalCost.add(multiplierCosts[i]);
        }

        require(IERC20(yvs).balanceOf(msg.sender) >= totalCost, '!yvs');
        yvs.safeTransferFrom(msg.sender, address(this), totalCost);
        newTier = tiers[msg.sender].add(_tiers);
        tiers[msg.sender] = newTier;
        emit MultiplierPurchased(msg.sender, _tiers, totalCost);
    }

    function distribute() external restricted {
        uint256 b = yvs.balanceOf(address(this));
        if (b > 0) {
            uint256 toBurn = b.mul(burnFee).div(burnFeeBase);
            uint256 leftover = b.sub(toBurn);
            Burnable(address(yvs)).burn(toBurn);
            yvs.safeTransfer(treasury, leftover);
        }
    }

    function salvage(address reserve, uint256 amount) external isGovernance {
        require(reserve != address(token), "!token");
        require(reserve != address(yvs), "!yvs");
        IERC20(reserve).safeTransfer(treasury, amount);
    }

    function getMultiplier() external view returns (uint256) {
        return tiers[msg.sender];
    }

    function getNextMultiplierCost() external view returns (uint256) {
        require(tiers[msg.sender] < multiplierCosts.length, '!all');
        return multiplierCosts[tiers[msg.sender]];
    }

    function getCountOfMultipliers() external view returns (uint256) {
        return multiplierCosts.length;
    }

    function getRatio() public view returns (uint256) {
        return (balance().sub(totalDeposited)).mul(1e18).div(totalSupply());
    }


    modifier restricted {
        require(
            (msg.sender == tx.origin && !address(msg.sender).isContract()) ||
                msg.sender == governance ||
                msg.sender == controller
        );

        _;
    }

    modifier isTimelock {
        require(
            msg.sender == timelock, 
            "!timelock"
        );

        _;
    }

    modifier isGovernance {
        require(
            msg.sender == governance, 
            "!governance"
        );

        _;
    }
}