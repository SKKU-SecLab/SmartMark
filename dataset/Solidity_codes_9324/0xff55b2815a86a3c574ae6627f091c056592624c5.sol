
pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCast {
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT
pragma solidity 0.8.11;


contract DevtMine is Ownable {
    using SafeERC20 for ERC20;
    using SafeCast for uint256;
    using SafeCast for int256;

    enum Lock {
        twoWeeks,
        oneMonth,
        twoMonths
    }

    uint256 public constant LIFECYCLE = 90 days;

    ERC20 public immutable devt;
    ERC20 public immutable dvt;

    uint256 public endTimestamp;

    uint256 public maxDvtPerSecond;
    uint256 public dvtPerSecond;
    uint256 public totalRewardsEarned;

    uint256 public accDvtPerShare;
    uint256 public totalLpToken;
    uint256 public devtTotalDeposits;
    uint256 public lastRewardTimestamp;

    uint256 public immutable targetPledgeAmount;

    struct UserInfo {
        uint256 depositAmount;
        uint256 lpAmount;
        uint256 lockedUntil;
        int256 rewardDebt;
        Lock lock;
        bool isDeposit;
    }

    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 amount);
    event LogUpdateRewards(
        uint256 indexed lastRewardTimestamp,
        uint256 lpSupply,
        uint256 accDvtPerShare
    );

    function refreshDevtRate() private {
        uint256 util = utilization();
        if (util < 5e16) {
            dvtPerSecond = 0;
        } else if (util < 1e17) {
            dvtPerSecond = (maxDvtPerSecond * 5) / 10;
        } else if (util < (1e17 + 5e16)) {
            dvtPerSecond = (maxDvtPerSecond * 6) / 10;
        } else if (util < 2e17) {
            dvtPerSecond = (maxDvtPerSecond * 8) / 10;
        } else if (util < (2e17 + 5e16)) {
            dvtPerSecond = (maxDvtPerSecond * 9) / 10;
        } else {
            dvtPerSecond = maxDvtPerSecond;
        }
    }

    function updateRewards() private {
        if (
            block.timestamp > lastRewardTimestamp &&
            lastRewardTimestamp < endTimestamp &&
            endTimestamp != 0
        ) {
            uint256 lpSupply = totalLpToken;
            if (lpSupply > 0) {
                uint256 timeDelta;
                if (block.timestamp > endTimestamp) {
                    timeDelta = endTimestamp - lastRewardTimestamp;
                    lastRewardTimestamp = endTimestamp;
                } else {
                    timeDelta = block.timestamp - lastRewardTimestamp;
                    lastRewardTimestamp = block.timestamp;
                }
                uint256 dvtReward = timeDelta * dvtPerSecond;
                totalRewardsEarned += dvtReward;
                accDvtPerShare += (dvtReward * 1 ether) / lpSupply;
            }
            emit LogUpdateRewards(
                lastRewardTimestamp,
                lpSupply,
                accDvtPerShare
            );
        }
    }

    constructor(
        address _devt,
        address _dvt,
        address _owner,
        uint256 _targetPledgeAmount
    ) {
        require(_devt != address(0) && _dvt != address(0) && _owner != address(0), "set address is zero");
        require(_targetPledgeAmount != 0,"set targetPledgeAmount is zero" );
        targetPledgeAmount = _targetPledgeAmount;
        devt = ERC20(_devt);
        dvt = ERC20(_dvt);
        transferOwnership(_owner);
    }

    function init() external onlyOwner {
        require(endTimestamp == 0, "Cannot init again");
        uint256 rewardsAmount;
        if (devt == dvt) {
            rewardsAmount = dvt.balanceOf(address(this)) - devtTotalDeposits;
        } else {
            rewardsAmount = dvt.balanceOf(address(this));
        }

        require(rewardsAmount > 0, "No rewards sent");

        maxDvtPerSecond = rewardsAmount / LIFECYCLE;
        endTimestamp = block.timestamp + LIFECYCLE;
        lastRewardTimestamp = block.timestamp;

        refreshDevtRate();
    }

    function utilization() public view returns (uint256 util) {
        util = (devtTotalDeposits * 1 ether) / targetPledgeAmount;
    }

    function getBoost(Lock _lock)
        public
        pure
        returns (uint256 boost, uint256 timelock)
    {
        if (_lock == Lock.twoWeeks) {
            return (2e17, 14 days);
        } else if (_lock == Lock.oneMonth) {
            return (5e17, 30 days);
        } else if (_lock == Lock.twoMonths) {
            return (1e18, 60 days);
        } else {
            revert("Invalid lock value");
        }
    }

    function pendingRewards(address _user)
        external
        view
        returns (uint256 pending)
    {
        UserInfo storage user = userInfo[_user];
        uint256 _accDvtPerShare = accDvtPerShare;
        uint256 lpSupply = totalLpToken;
        if (block.timestamp > lastRewardTimestamp && dvtPerSecond != 0) {
            uint256 timeDelta;
            if (block.timestamp > endTimestamp) {
                timeDelta = endTimestamp - lastRewardTimestamp;
            } else {
                timeDelta = block.timestamp - lastRewardTimestamp;
            }
            uint256 dvtReward = timeDelta * dvtPerSecond;
            _accDvtPerShare += (dvtReward * 1 ether) / lpSupply;
        }

        pending = (((user.lpAmount * _accDvtPerShare) / 1 ether).toInt256() -
            user.rewardDebt).toUint256();
    }

    function deposit(uint256 _amount, Lock _lock) external {
        require(!userInfo[msg.sender].isDeposit, "Already desposit");
        updateRewards();
        require(endTimestamp != 0, "Not initialized");

        if (_lock == Lock.twoWeeks) {
            require(
                block.timestamp + 14 days  - 1 days <= endTimestamp,
                "Less than 2 weeks left"
            );
        } else if (_lock == Lock.oneMonth) {
            require(
                block.timestamp + 30 days - 2 days <= endTimestamp,
                "Less than 1 month left"
            );
        } else if (_lock == Lock.twoMonths) {
            require(
                block.timestamp + 60 days - 3 days <= endTimestamp,
                "Less than 2 months left"
            );
        } else {
            revert("Invalid lock value");
        }

        (uint256 boost, uint256 timelock) = getBoost(_lock);
        uint256 lpAmount = _amount + (_amount * boost) / 1 ether;
        devtTotalDeposits += _amount;
        totalLpToken += lpAmount;

        userInfo[msg.sender] = UserInfo(
            _amount,
            lpAmount,
            block.timestamp + timelock,
            ((lpAmount * accDvtPerShare) / 1 ether).toInt256(),
            _lock,
            true
        );

        devt.safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _amount);
        refreshDevtRate();
    }

    function withdraw() external {
        updateRewards();
        UserInfo storage user = userInfo[msg.sender];

        require(user.depositAmount > 0, "Position does not exists");

        if (block.timestamp < endTimestamp) {
            require(
                block.timestamp >= user.lockedUntil,
                "Position is still locked"
            );
        }

        totalLpToken -= user.lpAmount;
        devtTotalDeposits -= user.depositAmount;

        int256 accumulatedDvt = ((user.lpAmount * accDvtPerShare) / 1 ether)
            .toInt256();
        uint256 _pendingDvt = (accumulatedDvt - user.rewardDebt).toUint256();

        devt.safeTransfer(msg.sender, user.depositAmount);

        if (_pendingDvt != 0) {
            dvt.safeTransfer(msg.sender, _pendingDvt);
        }

        emit Harvest(msg.sender, _pendingDvt);
        emit Withdraw(msg.sender, user.depositAmount);
        delete userInfo[msg.sender];
        refreshDevtRate();
    }

    function recycleLeftovers() external onlyOwner {
        updateRewards();
        require(block.timestamp > endTimestamp, "Will not recycle before end");
        int256 recycleAmount = (LIFECYCLE * maxDvtPerSecond).toInt256() - // rewards originally sent
            (totalRewardsEarned).toInt256(); // rewards distributed to users

        if (recycleAmount > 0){
            dvt.safeTransfer(owner(), uint256(recycleAmount));
        }
            
    }
}