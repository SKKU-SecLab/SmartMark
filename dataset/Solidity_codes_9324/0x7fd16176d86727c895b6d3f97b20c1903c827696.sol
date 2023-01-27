



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




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
}




pragma solidity ^0.8.0;

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;




contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}




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
}


pragma solidity ^0.8.0;




interface IUniswapV2Router01 {
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

interface IEXPO {
    function withdrawableDividendOf(address account) external view returns (uint256);
    function claim() external;
    function transferFrom(address, address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ExpoCompoundVault is Ownable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 compoundedExpo;
    }

    IEXPO public immutable expo;
    uint256 public accExpoPerShare;
    uint256 public totalDeposited;
    uint256 public compoundAtAmount = 0.1 ether;
    uint256 public startTime;
    uint256 public lastRewardTime;
    uint256 public totalPeriods;
    uint256 public totalCompoundedExpo;
    uint256 public totalETHCompounded;
    bool public launched;
    IUniswapV2Router02 public uniswapV2Router;
    mapping (address => UserInfo) public userInfo;
    mapping (address => bool) public isAuthorized;

    event Deposit(address indexed user, uint256 amount);
    event Compound(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        IEXPO _expo
    ) {
        expo = _expo;
        startTime = block.timestamp;
        lastRewardTime = block.timestamp;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        isAuthorized[owner()] = true;
    }

    receive() external payable {}

    function _update() internal {
        if (block.timestamp > lastRewardTime) {
            uint256 stakedEXPO = totalDeposited;
            if (stakedEXPO > 0) {
                uint256 ethToCompound = IEXPO(expo).withdrawableDividendOf(address(this));
                uint256 threshold = compoundAtAmount;
                if (address(this).balance + ethToCompound >= threshold) {
                    if (address(this).balance < threshold) {
                        IEXPO(expo).claim();
                    }

                    uint256 expoReward = swapForEXPO(threshold);

                    totalETHCompounded += threshold;
                    totalCompoundedExpo += expoReward;
                    accExpoPerShare += (expoReward * 1e18) / stakedEXPO;
                    totalPeriods++;
                }
            }
            lastRewardTime = block.timestamp;
        }
    }

    function deposit(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        _update();
        uint256 pending;
        if (user.amount > 0) {
            pending = (user.amount * accExpoPerShare / 1e18) - user.rewardDebt;
            user.compoundedExpo += pending;
            emit Compound(msg.sender, pending);
        }
        user.amount += _amount + pending;
        totalDeposited += _amount + pending;
        user.rewardDebt = user.amount * accExpoPerShare / 1e18;
        expo.transferFrom(address(msg.sender), address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 uAmount = user.amount;
        _update();
        uint256 pending = (uAmount * accExpoPerShare / 1e18) - user.rewardDebt;
        require(uAmount + pending >= _amount, "withdraw: not good");
        if (pending > _amount) {
            user.compoundedExpo += (pending - _amount);
            emit Compound(msg.sender, pending - _amount);
        }
        uAmount = uAmount + pending - _amount;
        totalDeposited = totalDeposited + pending - _amount;
        user.amount = uAmount;
        user.rewardDebt = uAmount * accExpoPerShare / 1e18;
        safeExpoTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() public {
        UserInfo storage user = userInfo[msg.sender];
        uint amount = user.amount;
        uint256 pending = (amount * accExpoPerShare / 1e18) - user.rewardDebt;
        user.amount = 0;
        totalDeposited -= amount;
        user.rewardDebt = 0;

        safeExpoTransfer(address(msg.sender), amount + pending);
        emit EmergencyWithdraw(msg.sender, amount + pending);

    }

    function safeExpoTransfer(address _to, uint256 _amount) internal {
        uint256 expoBal = expo.balanceOf(address(this));
        if (_amount > expoBal) {
            expo.transfer(_to, expoBal);
        } else {
            expo.transfer(_to, _amount);
        }
    }

    function update() public {
        require(isAuthorized[msg.sender]);
        uint256 stakedEXPO = totalDeposited;
        if (stakedEXPO > 0) {
            IEXPO(expo).claim();

            uint256 ethToCompound = address(this).balance;
            uint256 expoReward = swapForEXPO(ethToCompound);

            totalETHCompounded += ethToCompound;
            totalCompoundedExpo += expoReward;
            accExpoPerShare += (expoReward * 1e18) / stakedEXPO;
            totalPeriods++;
        }
        lastRewardTime = block.timestamp;

    }

    function swapForEXPO(uint256 amount) private returns (uint256) {
        uint256 before = expo.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(expo);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(this),
            block.timestamp
        );

        return expo.balanceOf(address(this)) - before;
    }

    function setCompoundAtAmount(uint256 amount) external onlyOwner {
        compoundAtAmount = amount;
    }

    function setAuthorized(address user, bool value) external onlyOwner {
         isAuthorized[user] = value;
    }

    function launch() public onlyOwner {
        require(!launched, "Already launched.");
        totalDeposited = 0;
        totalCompoundedExpo = 0;
        totalETHCompounded = 0;
        totalPeriods = 0;
        startTime = block.timestamp;
        lastRewardTime = block.timestamp;
        launched = true;
    }

    function emergencyERC20Withdraw(address token, address recipient) external onlyOwner {
         require(token != address(expo), "Cannot withdraw EXPO");
         IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
    }

    function emergencyETHWithdraw(address recipient) external onlyOwner {
         (bool success, ) = recipient.call{value: address(this).balance}("");
         require(success, "Unable to withdraw ETH.");
    }

    function balance(address user) public view returns (uint256) {
        UserInfo memory _user = userInfo[user];
        uint256 pending = (_user.amount * accExpoPerShare / 1e18) - _user.rewardDebt;
        return _user.amount + pending;
    }

    function pendingRewards(address user) public view returns (uint256) {
        UserInfo memory _user = userInfo[user];
        return (_user.amount * accExpoPerShare / 1e18) - _user.rewardDebt;
    }

    function getPlatformAPR() public view returns (uint256) {
        if (totalDeposited > totalCompoundedExpo) {
            return (((totalCompoundedExpo * 365 days * 100 * 10**6) / (totalDeposited - totalCompoundedExpo)) / (lastRewardTime - startTime));
        }
        return 0;
    }

    function getPlatformAPY() public view returns (uint256) {
        uint256 principal = totalDeposited - totalCompoundedExpo;
        uint256 periodsPerYear = (totalPeriods * 365 days) / (lastRewardTime - startTime);

        uint256 APRPerPeriod = getPlatformAPR() / periodsPerYear;

        uint256 compBal = principal;
        for (uint256 i = 0; i < periodsPerYear; i++) {
            compBal = ( compBal * ((100 * 10**8) + APRPerPeriod) ) / (100 * 10**8);
        }

        return ((compBal - principal) * 100 * 10**2) / principal;
    }

    function getUserAPY(address user) public view returns (uint256) {
        UserInfo memory _user = userInfo[user];
        uint256 principal = _user.amount - _user.compoundedExpo;
        uint256 periodsPerYear = (totalPeriods * 365 days) / (lastRewardTime - startTime);

        uint256 APRPerPeriod = getPlatformAPR() / periodsPerYear;

        uint256 compBal = principal;
        for (uint256 i = 0; i < periodsPerYear; i++) {
            compBal = ( compBal * ((100 * 10**8) + APRPerPeriod) ) / (100 * 10**8);
        }

        return ((compBal - principal) * 100 * 10**2) / principal;
    }

}