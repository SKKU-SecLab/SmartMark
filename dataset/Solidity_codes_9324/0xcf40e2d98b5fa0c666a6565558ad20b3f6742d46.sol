
pragma solidity ^0.6.0;

interface IController {

    function jars(address) external view returns (address);


    function rewards() external view returns (address);


    function devfund() external view returns (address);


    function treasury() external view returns (address);


    function balanceOf(address) external view returns (uint256);


    function withdraw(address, uint256) external;


    function withdrawReward(address, uint256) external;


    function earn(address, uint256) external;


    function strategies(address) external view returns (address);

}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// File: contracts/GSN/Context.sol


pragma solidity ^0.6.0;




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
}// MIT
pragma solidity ^0.6.2;

interface IStrategy {
    function rewards() external view returns (address);

    function gauge() external view returns (address);

    function want() external view returns (address);

    function timelock() external view returns (address);

    function deposit() external;

    function withdrawForSwap(uint256) external returns (uint256);

    function withdraw(address) external;
    
    function pendingReward() external view returns (uint256);
    
    function withdraw(uint256) external;

    function withdrawReward(uint256) external;

    function skim() external;

    function withdrawAll() external returns (uint256);

    function balanceOf() external view returns (uint256);

    function getHarvestable() external view returns (uint256);

    function harvest() external;

    function setTimelock(address) external;

    function setController(address _controller) external;

    function execute(address _target, bytes calldata _data)
        external
        payable
        returns (bytes memory response);

    function execute(bytes calldata _data)
        external
        payable
        returns (bytes memory response);
}// https://github.com/iearn-finance/vaults/blob/master/contracts/vaults/yVault.sol

pragma solidity ^0.6.7;



contract PickleJarSymbiotic is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 public token;
    IERC20 public reward;

    mapping(address => uint256) public userRewardDebt;

    uint256 public accRewardPerShare;
    uint256 public lastPendingReward;
    uint256 public curPendingReward;

    uint256 public min = 10000;
    uint256 public constant max = 10000;

    address public governance;
    address public timelock;
    address public controller;

    address public gauge;
    bool public paused;
    bool public callEarnAfterDeposit;

    event Deposit(address indexed user, uint256 _amount, uint256 _shares);
    event Withdraw(address indexed user, uint256 _amount, uint256 _shares);

    constructor(
        address _token,
        address _reward,
        address _governance,
        address _timelock,
        address _controller
    )
        public
        ERC20(
            string(abi.encodePacked("pickling ", ERC20(_token).name())),
            string(abi.encodePacked("p", ERC20(_token).symbol()))
        )
    {
        _setupDecimals(ERC20(_token).decimals());
        token = IERC20(_token);
        reward = IERC20(_reward);
        governance = _governance;
        timelock = _timelock;
        controller = _controller;
        callEarnAfterDeposit = true;
    }

    function balance() public view returns (uint256) {
        return
            token.balanceOf(address(this)).add(
                IController(controller).balanceOf(address(token))
            );
    }

    function setGauge(address _gauge) external {
        require(msg.sender == governance, "!governance");
        require(_gauge != address(0), "invalid gauge");
        gauge = _gauge;
    }

    function setMin(uint256 _min) external {
        require(msg.sender == governance, "!governance");
        require(_min <= max, "numerator cannot be greater than denominator");
        min = _min;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setCallEarnAfterDeposit(bool _callEarn) external {
        require(msg.sender == governance, "!governance");
        callEarnAfterDeposit = _callEarn;
    }

    event Paused(
        address indexed gov,
        uint256 blockNumber,
        uint256 blockTimestamp
    );

    function pause() external {
        require(msg.sender == governance, "!governance");
        require(paused == false, "jar is already paused");
        paused = true;
        emit Paused(msg.sender, block.number, block.timestamp);
    }

    event Resumed(
        address indexed gov,
        uint256 blockNumber,
        uint256 blockTimestamp
    );

    function resume() external {
        require(msg.sender == governance, "!governance");
        require(paused == true, "jar is not paused");
        paused = false;
        emit Resumed(msg.sender, block.number, block.timestamp);
    }

    function setTimelock(address _timelock) public {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setController(address _controller) public {
        require(msg.sender == timelock, "!timelock");
        controller = _controller;
    }

    function available() public view returns (uint256) {
        return token.balanceOf(address(this)).mul(min).div(max);
    }

    function earn() public {
        uint256 _bal = available();
        token.safeTransfer(controller, _bal);
        IController(controller).earn(address(token), _bal);
    }

    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }

    function deposit(uint256 _amount) public whenNotPaused {
        require(_amount > 0, "Invalid amount");
        _updateAccPerShare();

        _withdrawReward();

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
        userRewardDebt[msg.sender] = balanceOf(msg.sender)
        .mul(accRewardPerShare)
        .div(1e36);

        if (callEarnAfterDeposit) earn();

        emit Deposit(msg.sender, _amount, shares);
    }

    function _updateAccPerShare() internal {
        curPendingReward = pendingReward();

        if (lastPendingReward > 0 && curPendingReward < lastPendingReward) {
            curPendingReward = 0;
            lastPendingReward = 0;
            accRewardPerShare = 0;
            userRewardDebt[msg.sender] = 0;
            return;
        }

        if (totalSupply() == 0) {
            accRewardPerShare = 0;
            return;
        }

        uint256 addedReward = curPendingReward.sub(lastPendingReward);
        accRewardPerShare = accRewardPerShare.add(
            (addedReward.mul(1e36)).div(totalSupply())
        );
    }

    function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
    }

    function harvest(address reserve, uint256 amount) external {
        require(msg.sender == controller, "!controller");
        require(reserve != address(token), "token");
        IERC20(reserve).safeTransfer(controller, amount);
    }

    function pendingReward() public view returns (uint256) {
        return
            reward.balanceOf(address(this)).add(
                IStrategy(IController(controller).strategies(address(token)))
                    .pendingReward()
            );
    }

    function pendingRewardOfUser(address user) external view returns (uint256) {
        if (totalSupply() == 0) return 0;
        uint256 allPendingReward = pendingReward();
        if (allPendingReward < lastPendingReward) return 0;

        uint256 addedReward = allPendingReward.sub(lastPendingReward);
        uint256 newAccRewardPerShare = accRewardPerShare.add(
            (addedReward.mul(1e36)).div(totalSupply())
        );

        return
            balanceOf(user).mul(newAccRewardPerShare).div(1e36).sub(
                userRewardDebt[user]
            );
    }

    function _withdrawReward() internal {
        uint256 _pending = balanceOf(msg.sender)
        .mul(accRewardPerShare)
        .div(1e36)
        .sub(userRewardDebt[msg.sender]);
        if (_pending > 0) {
            uint256 _balance = reward.balanceOf(address(this));
            if (_balance < _pending) {
                uint256 _withdraw = _pending.sub(_balance);
                IController(controller).withdrawReward(
                    address(token),
                    _withdraw
                );
                uint256 _after = reward.balanceOf(address(this));
                uint256 _diff = _after.sub(_balance);
                if (_diff < _withdraw) {
                    _pending = _balance.add(_diff);
                }
            }
            reward.safeTransfer(msg.sender, _pending);
        }
        lastPendingReward = pendingReward();
    }

    function withdraw(uint256 _shares) public whenNotPaused {
        require(balanceOf(msg.sender) >= _shares, "Invalid amount");

        _updateAccPerShare();
        _withdrawReward();

        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);
        uint256 b = token.balanceOf(address(this));
        if (b < r) {
            uint256 _withdraw = r.sub(b);
            IController(controller).withdraw(address(token), _withdraw);
            uint256 _after = token.balanceOf(address(this));
            uint256 _diff = _after.sub(b);
            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }
        token.safeTransfer(msg.sender, r);

        userRewardDebt[msg.sender] = balanceOf(msg.sender)
        .mul(accRewardPerShare)
        .div(1e36);

        emit Withdraw(msg.sender, r, _shares);
    }

    function getRatio() public view returns (uint256) {
        if (totalSupply() == 0) return 0;
        return balance().mul(1e18).div(totalSupply());
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 /*amount*/
    ) internal override {
        if (from != address(0) && to != address(0)) {
            require(from == gauge || to == gauge, "not-allowed");
        }
    }

    modifier whenNotPaused() {
        require(paused == false, "contract is paused");
        _;
    }
}// MIT

pragma solidity ^0.6.0;

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