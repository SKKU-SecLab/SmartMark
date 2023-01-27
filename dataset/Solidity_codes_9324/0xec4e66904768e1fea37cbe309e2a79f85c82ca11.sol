

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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





library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}










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





abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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







abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}





interface IVault {

    function earned(address account) external view returns (
        uint256 claimableAmount,
        uint256 unlockedVestedTokenAmount,
        uint256 claimableRewardAmount);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);



    function stake(uint256 amount) external;


    function claim() external;

}



pragma experimental ABIEncoderV2;


contract VaultV2 is IVault, ReentrancyGuard, Pausable, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    IERC20 public vaultToken;

    uint256 public vestingPeriod;
    uint256 public vaultLimit;
    uint256 public interestRate;
    uint256 public vaultGenesis;

    struct UserVault {
        uint256 amount;
        uint256 depositTime;
        uint256 vestingPeriodEnds;
        uint256 lastUpdated;
        uint256 claimedAmount;
        uint256 totalEarned;
    }

    mapping(address => UserVault[]) public userVault;

    uint256 private _totalSupply;
    uint256 private _totalDeposit;

    mapping(address => uint256) private _balances;


    constructor(
        address _vaultToken,
        uint256 _vestingPeriod,
        uint256 _interestRate,
        uint256 _vaultLimit
    ) public {
        vaultToken = IERC20(_vaultToken);
        vaultLimit = _vaultLimit.mul(1 ether);
        interestRate = _interestRate.add(100);
        vestingPeriod = _vestingPeriod.mul(1 days);
        vaultGenesis = block.timestamp;
    }


    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }


    function rewardRate() external view returns (uint256){

        return interestRate.sub(100);
    }

    function totalSupply() external view override returns (uint256) {

        return _totalSupply;
    }

    function totalDeposits() external view returns (uint256) {

        return _totalDeposit;
    }

    function balanceOf(address account) external view override returns (uint256) {

        return _balances[account];
    }

    function getUserVaultInfo(address account) external view returns (UserVault[] memory) {

        return userVault[account];
    }

    function earned(address account) external view override
    returns (uint256 claimableAmount, uint256 unlockedVestedTokenAmount, uint256 claimableRewardAmount){

        UserVault[] memory userVaultData = userVault[account];
        uint256 claimableAmount = 0;
        uint256 unlockedVestedTokenAmount = 0;

        for (uint256 i = 0; i < userVaultData.length; i++) {
            if (userVaultData[i].amount <= userVaultData[i].claimedAmount) continue;
            uint256 currentTime =
            block.timestamp > userVaultData[i].vestingPeriodEnds
            ? userVaultData[i].vestingPeriodEnds
            : block.timestamp;
            uint256 timeSinceLastClaim = currentTime.sub(userVaultData[i].lastUpdated);
            uint256 unlockedAmount = userVaultData[i].amount.mul(timeSinceLastClaim).div(vestingPeriod);

            unlockedVestedTokenAmount = unlockedVestedTokenAmount.add(unlockedAmount);

            claimableAmount = claimableAmount.add(unlockedAmount.mul(interestRate).div(100));
        }
        uint256 claimableRewardAmount = claimableAmount - unlockedVestedTokenAmount;

        return (claimableAmount, unlockedVestedTokenAmount, claimableRewardAmount);
    }


    function stake(uint256 amount) external override nonReentrant whenNotPaused {

        require(amount > 0, 'Cannot stake 0');
        require(_totalDeposit.add(amount) <= vaultLimit, 'Vault:stake:: vault limit exceeded');

        _totalSupply = _totalSupply.add(amount);
        _totalDeposit = _totalDeposit.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);

        vaultToken.safeTransferFrom(msg.sender, address(this), amount);

        UserVault[] storage userVaultData = userVault[msg.sender];
        UserVault memory userVaultNewEntry =
        UserVault(amount, block.timestamp, block.timestamp.add(vestingPeriod), block.timestamp, 0, 0);
        userVaultData.push(userVaultNewEntry);

        emit Staked(msg.sender, amount);
    }

    function claim() public override nonReentrant {

        if (_balances[msg.sender] > 0) {
            UserVault[] storage userVaultData = userVault[msg.sender];
            uint256 claimableAmount = 0;
            for (uint256 i = 0; i < userVaultData.length; i++) {
                if (userVaultData[i].amount <= userVaultData[i].claimedAmount) continue;
                uint256 currentTime =
                block.timestamp > userVaultData[i].vestingPeriodEnds
                ? userVaultData[i].vestingPeriodEnds
                : block.timestamp;
                uint256 timeSinceLastClaim = currentTime.sub(userVaultData[i].lastUpdated);
                uint256 unlockedAmount = userVaultData[i].amount.mul(timeSinceLastClaim).div(vestingPeriod);

                if (currentTime == userVaultData[i].vestingPeriodEnds) {
                    unlockedAmount = userVaultData[i].amount.sub(userVaultData[i].claimedAmount);
                }

                claimableAmount = claimableAmount.add(unlockedAmount.mul(interestRate).div(100));
                userVaultData[i].claimedAmount = userVaultData[i].claimedAmount.add(unlockedAmount);
                userVaultData[i].totalEarned = userVaultData[i].totalEarned.add(
                    unlockedAmount.mul(interestRate).div(100)
                );
                _totalSupply = _totalSupply.sub(unlockedAmount);
                _balances[msg.sender] = _balances[msg.sender].sub(unlockedAmount);
                userVaultData[i].lastUpdated = currentTime;
            }
            vaultToken.safeTransfer(msg.sender, claimableAmount);
            emit Claimed(msg.sender, claimableAmount);
        }
    }

    function rescueRewards(uint256 amount, address token) external onlyOwner {

        IERC20 rescuedToken = IERC20(token);
        rescuedToken.safeTransfer(msg.sender, amount);
    }

    function rescueEth(uint256 amount) external onlyOwner {

        require(address(this).balance >= amount, 'amount of eth is too low');
        payable(owner()).transfer(amount);
    }


    event Staked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 reward);
}