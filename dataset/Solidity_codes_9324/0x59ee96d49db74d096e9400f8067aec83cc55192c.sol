

pragma solidity 0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

interface IUniswapV2Router02 {

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidityETH(
            address token,
            uint liquidity,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline
    ) external returns (uint amountToken, uint amountETH);

}

interface IUniswapV2Pair is IERC20 {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}


contract MunchLPStaking is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IUniswapV2Pair;

    IERC20 _munchToken;
    IUniswapV2Pair _lpToken;
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address charityAddress;

    uint256 _lastRewardBlock;

    uint256 _accERC20PerShare = 0;

    struct UserInfo {
        uint256 amount;             // How many LP tokens the user has provided.
        uint256 rewardDebt;         // Reward debt. See explanation below.
        uint lastDepositTime;
        uint percentToCharity;      // as an int: 50% is stored as 50
    }

    uint256 public paidOut = 0;
    uint256 public rewardPerBlock;

    uint public constant cliffTime = 1 minutes;

    mapping (address => UserInfo) public userInfo;

    uint public minPercentToCharity;

    uint public startBlock;
    uint public endBlock;

    uint256 public fundsAdded;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(address lpToken, address munchToken, uint rewards) public {
        _munchToken = IERC20(munchToken);
        _lpToken = IUniswapV2Pair(lpToken);
        rewardPerBlock = rewards;
        startBlock = 0;
        endBlock = 0;
        minPercentToCharity = 50;

        charityAddress = address(_munchToken);
        
        _lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        
        _munchToken.approve(address(_uniswapV2Router), type(uint).max);
        _lpToken.approve(address(_uniswapV2Router), type(uint).max);
    }

    function setMinPercentToCharity(uint percent) public onlyOwner {

        minPercentToCharity = percent;
    }

    function setCharityAddress(address addy) public onlyOwner {

        charityAddress = addy;
    }

    function fund(uint256 amount) public onlyOwner {

        require(startBlock == 0 || block.number < endBlock, "fund: too late, the farm is closed");

        _munchToken.safeTransferFrom(address(msg.sender), address(this), amount);
        if (startBlock == 0) {
            startBlock = block.number;
            endBlock = startBlock;
        }
        endBlock += amount.div(rewardPerBlock);

        fundsAdded = fundsAdded.add(amount);
    }

    function fund(uint256 amount, uint256 rewards) public onlyOwner {

        require(startBlock > 0 && block.number < endBlock, "fund: Farm is closed or not yet started");
        _munchToken.safeTransferFrom(address(msg.sender), address(this), amount);
        changeReward(rewards);

        fundsAdded = fundsAdded.add(amount);
    }

    function changeReward(uint256 rewards) public onlyOwner {

        require(startBlock > 0, "Not started yet");
        updatePool();
        rewardPerBlock = rewards;
        uint256 amount = _munchToken.balanceOf(address(this));
        
        uint refBlock = block.number > startBlock ? block.number : startBlock;
        endBlock = refBlock + amount.div(rewardPerBlock);
    }

    function pending(address _user) external view returns (uint256) {

        UserInfo storage user = userInfo[_user];
        uint256 lpSupply = _lpToken.balanceOf(address(this));
        uint256 accERC20PerShare = _accERC20PerShare;

        if (block.number > _lastRewardBlock && lpSupply != 0) {
            uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
            uint256 nrOfBlocks = lastBlock.sub(_lastRewardBlock);
            accERC20PerShare = accERC20PerShare.add(nrOfBlocks.mul(rewardPerBlock).mul(1e36).div(lpSupply));
        }

        return user.amount.mul(accERC20PerShare).div(1e36).sub(user.rewardDebt);
    }

    function totalPending() external view returns (uint256) {

        if (block.number <= startBlock) {
            return 0;
        }

        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
        return rewardPerBlock.mul(lastBlock - startBlock).sub(paidOut);
    }

    function updatePool() public {

        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (lastBlock <= _lastRewardBlock) {
            return;
        }
        uint256 lpSupply = _lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            _lastRewardBlock = lastBlock;
            return;
        }

        uint256 nrOfBlocks = lastBlock.sub(_lastRewardBlock);
        uint256 erc20Reward = nrOfBlocks.mul(rewardPerBlock);

        _accERC20PerShare = _accERC20PerShare.add(erc20Reward.mul(1e36).div(lpSupply));
        _lastRewardBlock = lastBlock;
    }

    function deposit(uint256 amount, uint percentToCharity) public {

        require(block.number < endBlock, 'Farm is now closed');
        require(percentToCharity >= minPercentToCharity && minPercentToCharity <= 100, 'Invalid charity value');
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        if (user.amount > 0) {
            uint256 pendingAmount = user.amount.mul(_accERC20PerShare).div(1e36).sub(user.rewardDebt);
            erc20Transfer(msg.sender, pendingAmount, user.percentToCharity);
        }
        _lpToken.safeTransferFrom(address(msg.sender), address(this), amount);
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.amount.mul(_accERC20PerShare).div(1e36);
        user.lastDepositTime = block.timestamp;
        user.percentToCharity = percentToCharity;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= amount, "withdraw: can't withdraw more than deposit");
        require(amount == 0 || block.timestamp.sub(user.lastDepositTime) > cliffTime, "You recently staked, please wait before withdrawing.");
        updatePool();
        uint256 pendingAmount = user.amount.mul(_accERC20PerShare).div(1e36).sub(user.rewardDebt);
        erc20Transfer(msg.sender, pendingAmount, user.percentToCharity);
        user.amount = user.amount.sub(amount);
        user.rewardDebt = user.amount.mul(_accERC20PerShare).div(1e36);
        _lpToken.safeTransfer(address(msg.sender), amount);
        emit Withdraw(msg.sender, amount);
    }

    function emergencyWithdraw() public {

        UserInfo storage user = userInfo[msg.sender];
        _lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function erc20Transfer(address to, uint256 amount, uint percentToCharity) internal {

        uint256 toCharity = amount.mul(percentToCharity).div(100);
        uint256 toHolder = amount.sub(toCharity);
        if (toCharity > 0) {
            _munchToken.transfer(charityAddress, toCharity);
        }
        if (toHolder > 0) {
            _munchToken.transfer(to, toHolder);
        }

        paidOut += amount;
    }

    function erc20Withdraw(address to) onlyOwner public {

        require(block.timestamp >= endBlock + 6 * 7 days, "Not allowed until 6 weeks after end of farming.");
        uint256 amount = _munchToken.balanceOf(address(this));
        _munchToken.transfer(to, amount);
    }

    function ethWithdraw(address payable to) onlyOwner public {

        uint256 balance = address(this).balance;
        require(balance > 0, "Balance is zero.");
        to.transfer(balance);
    }

    receive() external payable {}
    
    function provideLiquidity(uint256 amount) external payable {

        _munchToken.transferFrom(msg.sender, address(this), amount);
        _uniswapV2Router.addLiquidityETH{value: msg.value}(address(_munchToken), amount, amount.mul(99).div(100), msg.value.mul(99).div(100), msg.sender, block.timestamp);
    }

    function removeLiquidity(uint256 amount) external {

        _lpToken.transferFrom(msg.sender, address(this), amount);
        (uint256 munchBal, uint256 ethBal,) = _lpToken.getReserves();
        uint256 share = amount.div(_lpToken.totalSupply());
        (uint256 munchWithdrawn, uint256 ethWithdrawn) = _uniswapV2Router.removeLiquidityETH(address(_munchToken), amount, share.mul(munchBal).mul(99).div(100), share.mul(ethBal).mul(99).div(100), address(this), block.timestamp);
        _munchToken.transfer(msg.sender, munchWithdrawn);
        (bool success, ) = msg.sender.call{value: ethWithdrawn}("");
        require(success, "Transfer failed.");
    }
}