



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



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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



pragma solidity ^0.6.0;




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
        if (returndata.length > 0) {// Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {// Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}




pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

}


pragma solidity ^0.6.0;


contract MyERC20Token is ERC20, Ownable {

    address public minter;
    address public burner;

    constructor (string memory name, string memory symbol, address _minter, address _burner) public ERC20(name, symbol) {
        minter = _minter;
        burner = _burner;
    }

    function setBurner(address _newBurner) external onlyOwner {
        burner = _newBurner;
    }

    function mint(address _to, uint256 _amount) public {
        require(msg.sender == minter, "Only minter can mint this token");
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) public {
        require(msg.sender == burner, "Only burner can burn this token");
        _burn(msg.sender, _amount);
    }

}


pragma solidity >=0.5.0;


contract IronToken is MyERC20Token {
    constructor (address _minter, address _burner) public MyERC20Token("Dungeon Iron", "IRON", _minter, _burner) {}
}


pragma solidity >=0.5.0;


contract KnightToken is MyERC20Token {
    constructor (address _minter, address _burner) public MyERC20Token("Dungeon Knight", "KNIGHT", _minter, _burner) {}
}


pragma solidity >=0.5.0;


contract DungeonMaster is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct NormalUserInfo {
        uint256 amountStaked;
        uint256 debt;
    }

    struct NormalPoolInfo {
        IERC20 stakeToken;
        MyERC20Token receiveToken;
        uint256 stakedSupply;
        uint256 uncollectedAmount;
        uint256 rewardPerBlock;
        uint256 stakeChestAmount;
        uint256 receiveChestAmount;
        uint256 lastUpdateBlock;
        uint256 accumulatedRewardPerStake; // is in 1e12 to allow for cases where stake supply is more than block reward
    }

    NormalPoolInfo[] public normalPoolInfo;
    mapping(uint256 => mapping(address => NormalUserInfo)) public normalUserInfo;


    struct BurnUserInfo {
        uint256 amountStaked;
        uint256 startBlock;

    }

    struct BurnPoolInfo {
        MyERC20Token burningStakeToken;
        MyERC20Token receiveToken;
        uint256 blockRate; // reward is created every x blocks
        uint256 rewardRate; // reward distributed per blockrate
        uint256 burnRate; // token burned per blockrate
        uint256 stakeChestAmount;
        uint256 receiveChestAmount;
    }

    BurnPoolInfo[] public burnPoolInfo;
    mapping(uint256 => mapping(address => BurnUserInfo)) public burnUserInfo;


    struct MultiBurnUserInfo {
        uint256 amountStakedOfEach;
        uint256 startBlock;

    }

    struct MultiBurnPoolInfo {
        MyERC20Token[] burningStakeTokens;
        MyERC20Token receiveToken;
        uint256 blockRate; // reward is created every x blocks
        uint256 rewardRate; // reward distributed per blockrate
        uint256 burnRate; // token burned per blockrate
        uint256 stakeChestAmount;
    }

    MultiBurnPoolInfo[] public multiBurnPoolInfo;
    mapping(uint256 => mapping(address => MultiBurnUserInfo)) public multiBurnUserInfo;


    uint256 public raidBlock;
    uint256 public raidFrequency;
    uint256 public returnIfNotInRaidPercentage = 25; // 25% of knights will return if you miss the raid block
    uint256 public raidWinLootPercentage = 25; // 25% of chest will be rewarded based on knights provided
    uint256 public raidWinPercentage = 5; // 5% of total supplied knights must be in raid to win

    address[] public participatedInRaid;

    mapping(address => uint256)[] public knightsProvidedInRaid;
    mapping(address => uint256) public raidShare;


    bool public votingActive = false;
    uint256 public voted = 0;
    address[] public voters;
    mapping(address => uint256) voteAmount;

    address public devaddr;
    uint public depositChestFee = 25;
    uint public chestRewardPercentage = 500;

    uint256 public startBlock;
    KnightToken public knightToken;

    constructor(
        address _devaddr,
        uint256 _startBlock,
        uint256 _depositChestFee
    ) public {
        devaddr = _devaddr;
        startBlock = _startBlock;
        depositChestFee = _depositChestFee;
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    function setDepositChestFee(uint256 _depositChestFee) public onlyOwner {
        require(_depositChestFee <= 100, "deposit chest fee can be max 1%");
        depositChestFee = _depositChestFee;
    }

    function setChestRewardPercentage(uint256 _chestRewardPercentage) public onlyOwner {
        require(_chestRewardPercentage <= 1000, "chest reward percentage can be max 10%");
        chestRewardPercentage = _chestRewardPercentage;
    }

    function setKnightToken(KnightToken _knight) public onlyOwner {
        knightToken = _knight;
    }

    function setRaidWinLootPercentage(uint256 _percentage) public onlyOwner {
        require(_percentage >= 10, "minimum of 10% must be distributed");
        raidWinLootPercentage = _percentage;
    }

    function setRaidWinPercentage(uint256 _percentage) public onlyOwner {
        require(_percentage <= 50, "maximum of 50% must take part");
        raidWinPercentage = _percentage;
    }

    function getBlocks(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    function isStarted() public view returns (bool) {
        return startBlock <= block.number;
    }


    function addNormalPool(IERC20 _stakeToken, MyERC20Token _receiveToken, uint256 _rewardPerBlock) public onlyOwner {
        uint256 lastUpdateBlock = block.number > startBlock ? block.number : startBlock;
        normalPoolInfo.push(NormalPoolInfo(_stakeToken, _receiveToken, 0, 0, _rewardPerBlock.mul(1e18), 0, 0, lastUpdateBlock, 0));
    }

    function normalPoolLength() external view returns (uint256) {
        return normalPoolInfo.length;
    }

    function normalPending(uint256 _pid, address _user) external view returns (uint256, IERC20) {
        NormalPoolInfo storage pool = normalPoolInfo[_pid];
        NormalUserInfo storage user = normalUserInfo[_pid][_user];
        uint256 rewardPerStake = pool.accumulatedRewardPerStake;
        if (block.number > pool.lastUpdateBlock && pool.stakedSupply != 0) {
            uint256 blocks = getBlocks(pool.lastUpdateBlock, block.number);
            uint256 reward = pool.rewardPerBlock.mul(blocks);
            rewardPerStake = rewardPerStake.add(reward.mul(1e12).div(pool.stakedSupply));
        }
        return (user.amountStaked.mul(rewardPerStake).div(1e12).sub(user.debt), pool.receiveToken);
    }

    function updateNormalPool(uint256 _pid) public {
        NormalPoolInfo storage pool = normalPoolInfo[_pid];
        if (block.number <= pool.lastUpdateBlock) {
            return;
        }
        if (pool.stakedSupply == 0) {
            pool.lastUpdateBlock = block.number;
            return;
        }
        uint256 blocks = getBlocks(pool.lastUpdateBlock, block.number);
        uint256 reward = blocks.mul(pool.rewardPerBlock);
        uint256 poolReward = reward.mul(10000 - 500 - chestRewardPercentage).div(10000);
        pool.receiveToken.mint(address(this), poolReward);
        pool.receiveToken.mint(devaddr, reward.mul(5).div(100));
        pool.receiveChestAmount = pool.receiveChestAmount.add(reward.mul(chestRewardPercentage).div(10000));
        pool.receiveToken.mint(address(this), reward.mul(chestRewardPercentage).div(10000));
        pool.uncollectedAmount = pool.uncollectedAmount.add(poolReward);
        pool.accumulatedRewardPerStake = pool.accumulatedRewardPerStake.add(poolReward.mul(1e12).div(pool.stakedSupply));
        pool.lastUpdateBlock = block.number;
    }

    function depositNormalPool(uint256 _pid, uint256 _amount) public {
        require(startBlock <= block.number, "not yet started.");

        NormalPoolInfo storage pool = normalPoolInfo[_pid];
        NormalUserInfo storage user = normalUserInfo[_pid][msg.sender];
        updateNormalPool(_pid);

        if (user.amountStaked > 0) {
            uint256 pending = user.amountStaked.mul(pool.accumulatedRewardPerStake).div(1e12).sub(user.debt);
            require(pool.uncollectedAmount >= pending, "not enough uncollected tokens anymore");
            pool.receiveToken.transfer(address(msg.sender), pending);
            pool.uncollectedAmount = pool.uncollectedAmount - pending;
        }
        pool.stakeToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        uint256 chestAmount = _amount.mul(depositChestFee).div(10000);
        user.amountStaked = user.amountStaked.add(_amount).sub(chestAmount);
        pool.stakedSupply = pool.stakedSupply.add(_amount.sub(chestAmount));
        pool.stakeChestAmount = pool.stakeChestAmount.add(chestAmount);
        user.debt = user.amountStaked.mul(pool.accumulatedRewardPerStake).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdrawNormalPool(uint256 _pid, uint256 _amount) public {
        NormalPoolInfo storage pool = normalPoolInfo[_pid];
        NormalUserInfo storage user = normalUserInfo[_pid][msg.sender];
        require(user.amountStaked >= _amount, "withdraw: not good");
        updateNormalPool(_pid);

        uint256 pending = user.amountStaked.mul(pool.accumulatedRewardPerStake).div(1e12).sub(user.debt);
        require(pool.uncollectedAmount >= pending, "not enough uncollected tokens anymore");
        pool.receiveToken.transfer(address(msg.sender), pending);
        pool.uncollectedAmount = pool.uncollectedAmount - pending;

        user.amountStaked = user.amountStaked.sub(_amount);
        user.debt = user.amountStaked.mul(pool.accumulatedRewardPerStake).div(1e12);
        pool.stakeToken.safeTransfer(address(msg.sender), _amount);
        pool.stakedSupply = pool.stakedSupply.sub(_amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdrawNormalPool(uint256 _pid) public {
        NormalPoolInfo storage pool = normalPoolInfo[_pid];
        NormalUserInfo storage user = normalUserInfo[_pid][msg.sender];
        emit EmergencyWithdraw(msg.sender, _pid, user.amountStaked);
        pool.stakedSupply = pool.stakedSupply.sub(user.amountStaked);
        pool.stakeToken.safeTransfer(address(msg.sender), user.amountStaked);
        user.amountStaked = 0;
    }

    function collectNormalPool(uint256 _pid) public {
        NormalPoolInfo storage pool = normalPoolInfo[_pid];
        NormalUserInfo storage user = normalUserInfo[_pid][msg.sender];
        updateNormalPool(_pid);
        uint256 pending = user.amountStaked.mul(pool.accumulatedRewardPerStake).div(1e12).sub(user.debt);
        require(pool.uncollectedAmount >= pending, "not enough uncollected tokens anymore");
        pool.receiveToken.transfer(address(msg.sender), pending);
        pool.uncollectedAmount = pool.uncollectedAmount.sub(pending);
        user.debt = user.amountStaked.mul(pool.accumulatedRewardPerStake).div(1e12);
    }


    function addBurnPool(MyERC20Token _stakeToken, MyERC20Token _receiveToken, uint256 _blockRate, uint256 _rewardRate, uint256 _burnRate) public onlyOwner {
        burnPoolInfo.push(BurnPoolInfo(_stakeToken, _receiveToken, _blockRate, _rewardRate.mul(1e15), _burnRate.mul(1e15), 0, 0));
    }

    function burnPoolLength() external view returns (uint256) {
        return burnPoolInfo.length;
    }

    function burnPending(uint256 _pid, address _user) external view returns (uint256, uint256, IERC20) {
        BurnPoolInfo storage pool = burnPoolInfo[_pid];
        BurnUserInfo storage user = burnUserInfo[_pid][_user];
        uint256 blocks = getBlocks(user.startBlock, block.number);
        uint256 ticks = blocks.div(pool.blockRate);
        uint256 burned = ticks.mul(pool.burnRate);
        uint256 reward = 0;
        if (burned > user.amountStaked) {
            reward = user.amountStaked.mul(1e5).div(pool.burnRate).mul(pool.rewardRate).div(1e5);
            burned = user.amountStaked;
        }
        else {
            reward = ticks.mul(pool.rewardRate);
        }
        return (reward, burned, pool.receiveToken);
    }

    function depositBurnPool(uint256 _pid, uint256 _amount) public {
        require(startBlock <= block.number, "not yet started.");

        BurnPoolInfo storage pool = burnPoolInfo[_pid];
        BurnUserInfo storage user = burnUserInfo[_pid][msg.sender];

        if (user.amountStaked > 0) {
            collectBurnPool(_pid);
        }
        pool.burningStakeToken.transferFrom(address(msg.sender), address(this), _amount);
        uint256 chestAmount = _amount.mul(depositChestFee).div(10000);
        pool.stakeChestAmount = pool.stakeChestAmount.add(chestAmount);
        user.amountStaked = user.amountStaked.add(_amount).sub(chestAmount);
        user.startBlock = block.number;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdrawBurnPool(uint256 _pid, uint256 _amount) public {
        BurnPoolInfo storage pool = burnPoolInfo[_pid];
        BurnUserInfo storage user = burnUserInfo[_pid][msg.sender];

        collectBurnPool(_pid);

        if (user.amountStaked < _amount) {
            _amount = user.amountStaked;
        }
        user.amountStaked = user.amountStaked.sub(_amount);
        pool.burningStakeToken.transfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function collectBurnPool(uint256 _pid) public returns (uint256) {
        BurnPoolInfo storage pool = burnPoolInfo[_pid];
        BurnUserInfo storage user = burnUserInfo[_pid][msg.sender];
        uint256 blocks = getBlocks(user.startBlock, block.number);
        uint256 ticks = blocks.div(pool.blockRate);
        uint256 burned = ticks.mul(pool.burnRate);
        uint256 reward = 0;
        if (burned > user.amountStaked) {
            reward = user.amountStaked.mul(1e5).div(pool.burnRate).mul(pool.rewardRate).div(1e5);
            burned = user.amountStaked;
            user.amountStaked = 0;
        }
        else {
            reward = ticks.mul(pool.rewardRate);
            user.amountStaked = user.amountStaked.sub(burned);
        }
        pool.burningStakeToken.burn(burned);

        uint256 userAmount = reward.mul(10000 - 500 - chestRewardPercentage).div(10000);
        uint256 chestAmount = reward.mul(chestRewardPercentage).div(10000);
        uint256 devAmount = reward.mul(500).div(10000);
        pool.receiveToken.mint(msg.sender, userAmount);
        pool.receiveToken.mint(address(this), chestAmount);
        pool.receiveToken.mint(devaddr, devAmount);
        pool.receiveChestAmount = pool.receiveChestAmount.add(chestAmount);
        user.startBlock = block.number;
        return (reward);
    }


    function addMultiBurnPool(MyERC20Token[] memory _stakeTokens, MyERC20Token _receiveToken, uint256 _blockRate, uint256 _rewardRate, uint256 _burnRate) public onlyOwner {
        multiBurnPoolInfo.push(MultiBurnPoolInfo(_stakeTokens, _receiveToken, _blockRate, _rewardRate.mul(1e15), _burnRate.mul(1e15), 0));
    }

    function multiBurnPoolLength() external view returns (uint256) {
        return multiBurnPoolInfo.length;
    }

    function multiBurnPending(uint256 _pid, address _user) external view returns (uint256, uint256, IERC20) {
        MultiBurnPoolInfo storage pool = multiBurnPoolInfo[_pid];
        MultiBurnUserInfo storage user = multiBurnUserInfo[_pid][_user];
        uint256 blocks = getBlocks(user.startBlock, block.number);
        uint256 ticks = blocks.div(pool.blockRate);
        uint256 burned = ticks.mul(pool.burnRate);
        uint256 reward = 0;
        if (burned > user.amountStakedOfEach) {
            reward = user.amountStakedOfEach.mul(1e5).div(pool.burnRate).mul(pool.rewardRate).div(1e5);
            burned = user.amountStakedOfEach;
        }
        else {
            reward = ticks.mul(pool.rewardRate);
        }
        return (reward, burned, pool.receiveToken);
    }

    function depositMultiBurnPool(uint256 _pid, uint256 _amount) public {
        require(startBlock <= block.number, "not yet started.");

        MultiBurnPoolInfo storage pool = multiBurnPoolInfo[_pid];
        MultiBurnUserInfo storage user = multiBurnUserInfo[_pid][msg.sender];

        if (user.amountStakedOfEach > 0) {
            collectMultiBurnPool(_pid);
        }
        for (uint i = 0; i < pool.burningStakeTokens.length; i++) {
            MyERC20Token stakeToken = pool.burningStakeTokens[i];
            stakeToken.transferFrom(address(msg.sender), address(this), _amount);
        }
        uint256 chestAmount = _amount.mul(depositChestFee).div(10000);
        pool.stakeChestAmount = pool.stakeChestAmount.add(chestAmount);
        user.amountStakedOfEach = user.amountStakedOfEach.add(_amount).sub(chestAmount);
        user.startBlock = block.number;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdrawMultiBurnPool(uint256 _pid, uint256 _amount) public {
        MultiBurnPoolInfo storage pool = multiBurnPoolInfo[_pid];
        MultiBurnUserInfo storage user = multiBurnUserInfo[_pid][msg.sender];
        updateNormalPool(_pid);

        collectMultiBurnPool(_pid);

        if (user.amountStakedOfEach < _amount) {
            _amount = user.amountStakedOfEach;
        }

        user.amountStakedOfEach = user.amountStakedOfEach.sub(_amount);
        for (uint i = 0; i < pool.burningStakeTokens.length; i++) {
            MyERC20Token stakeToken = pool.burningStakeTokens[i];
            stakeToken.transfer(address(msg.sender), _amount);
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function collectMultiBurnPool(uint256 _pid) public returns (uint256) {
        MultiBurnPoolInfo storage pool = multiBurnPoolInfo[_pid];
        MultiBurnUserInfo storage user = multiBurnUserInfo[_pid][msg.sender];
        uint256 blocks = getBlocks(user.startBlock, block.number);
        uint256 ticks = blocks.div(pool.blockRate);
        uint256 burned = ticks.mul(pool.burnRate);
        uint256 reward = 0;
        if (burned > user.amountStakedOfEach) {
            reward = user.amountStakedOfEach.mul(1e5).div(pool.burnRate).mul(pool.rewardRate).div(1e5);
            burned = user.amountStakedOfEach;
            user.amountStakedOfEach = 0;
        }
        else {
            reward = ticks.mul(pool.rewardRate);
            user.amountStakedOfEach = user.amountStakedOfEach.sub(burned);
        }
        for (uint i = 0; i < pool.burningStakeTokens.length; i++) {
            MyERC20Token token = pool.burningStakeTokens[i];
            token.burn(burned);
        }

        uint256 userAmount = reward.mul(100 - 5).div(100);
        uint256 devAmount = reward.mul(5).div(100);
        pool.receiveToken.mint(msg.sender, userAmount);
        pool.receiveToken.mint(devaddr, devAmount);
        user.startBlock = block.number;
        return (reward);
    }


    function allowRaids(uint256 _raidFrequency) public onlyOwner {
        raidFrequency = _raidFrequency;
        raidBlock = block.number.add(raidFrequency);
        knightsProvidedInRaid.push();
    }

    function joinRaid(uint256 _amount) public returns (bool) {
        require(startBlock <= block.number, "not yet started.");

        knightToken.transferFrom(address(msg.sender), address(this), _amount);
        if (block.number == raidBlock) {
            uint256 currentRaidId = knightsProvidedInRaid.length.sub(1);

            if (knightsProvidedInRaid[currentRaidId][msg.sender] != 0) {
                return false;
            }
            knightsProvidedInRaid[currentRaidId][msg.sender] = _amount;
            participatedInRaid.push(msg.sender);
            return true;
        }
        else {
            uint256 returnAmount = _amount.mul(returnIfNotInRaidPercentage).div(100);
            uint256 burnAmount = _amount.sub(returnAmount);
            knightToken.burn(burnAmount);
            knightToken.transfer(address(msg.sender), returnAmount);
            return false;
        }
    }

    function checkAndCalculateRaidShares() public {
        require(block.number > raidBlock, "raid not started!");
        uint256 totalKnights = 0;
        uint256 currentRaidId = knightsProvidedInRaid.length.sub(1);
        for (uint i = 0; i < participatedInRaid.length; i++) {
            address user = participatedInRaid[i];
            totalKnights = totalKnights.add(knightsProvidedInRaid[currentRaidId][user]);
        }
        if (totalKnights < knightToken.totalSupply().div(raidWinPercentage)) {
            knightToken.burn(totalKnights);
            delete participatedInRaid;
            knightsProvidedInRaid.push();
            raidBlock = raidBlock.add(raidFrequency);
            return;
        }

        for (uint i = 0; i < participatedInRaid.length; i++) {
            address user = participatedInRaid[i];
            uint256 knights = knightsProvidedInRaid[currentRaidId][user];
            uint256 userShare = knights.mul(1e12).div(totalKnights);
            raidShare[user] = userShare;
        }

        knightToken.burn(totalKnights);
        delete participatedInRaid;
        knightsProvidedInRaid.push();
        raidBlock = raidBlock.add(raidFrequency);
    }

    function claimRaidRewards() public {
        uint256 userShare = raidShare[msg.sender];
        address user = msg.sender;
        for (uint j = 0; j < normalPoolInfo.length; j++) {
            NormalPoolInfo storage poolInfo = normalPoolInfo[j];
            uint256 stakeChestShare = poolInfo.stakeChestAmount.mul(userShare).div(1e12).mul(raidWinLootPercentage).div(100);
            uint256 receiveChestShare = poolInfo.receiveChestAmount.mul(userShare).div(1e12).mul(raidWinLootPercentage).div(100);
            poolInfo.stakeToken.transfer(user, stakeChestShare);
            poolInfo.receiveToken.transfer(user, receiveChestShare);
            poolInfo.stakeChestAmount = poolInfo.stakeChestAmount.sub(stakeChestShare);
            poolInfo.receiveChestAmount = poolInfo.receiveChestAmount.sub(receiveChestShare);
        }

        for (uint j = 0; j < burnPoolInfo.length; j++) {
            BurnPoolInfo storage poolInfo = burnPoolInfo[j];
            uint256 stakeChestShare = poolInfo.stakeChestAmount.mul(userShare).div(1e12).mul(raidWinLootPercentage).div(100);
            uint256 receiveChestShare = poolInfo.receiveChestAmount.mul(userShare).div(1e12).mul(raidWinLootPercentage).div(100);
            poolInfo.burningStakeToken.transfer(user, stakeChestShare);
            poolInfo.receiveToken.transfer(user, receiveChestShare);
            poolInfo.stakeChestAmount = poolInfo.stakeChestAmount.sub(stakeChestShare);
            poolInfo.receiveChestAmount = poolInfo.receiveChestAmount.sub(receiveChestShare);
        }

        for (uint j = 0; j < multiBurnPoolInfo.length; j++) {
            MultiBurnPoolInfo storage poolInfo = multiBurnPoolInfo[j];
            uint256 stakeChestShare = poolInfo.stakeChestAmount.mul(userShare).div(1e12).mul(raidWinLootPercentage).div(100);
            for (uint x = 0; x < poolInfo.burningStakeTokens.length; x++) {
                poolInfo.burningStakeTokens[x].transfer(user, stakeChestShare);
            }
            poolInfo.stakeChestAmount = poolInfo.stakeChestAmount.sub(stakeChestShare);
        }

        raidShare[msg.sender] = 0;
    }


    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function activateVoting() public onlyOwner {
        votingActive = true;
    }

    function vote(uint256 _amount) public {
        require(votingActive);
        require(voteAmount[msg.sender] == 0);
        knightToken.transferFrom(address(msg.sender), address(this), _amount);
        voted = voted.add(_amount);
        voters.push(msg.sender);
        voteAmount[msg.sender] = _amount;
    }

    function drainChest() public onlyOwner {
        require(votingActive);
        require(voted >= knightToken.totalSupply().div(10).mul(100));

        for (uint i = 0; i < voters.length; i++) {
            address user = voters[i];
            uint256 knights = voteAmount[user];
            uint256 userShare = knights.mul(1e12).div(voted);
            for (uint j = 0; j < normalPoolInfo.length; j++) {
                NormalPoolInfo storage poolInfo = normalPoolInfo[j];
                uint256 stakeChestShare = poolInfo.stakeChestAmount.mul(userShare).div(1e12);
                uint256 receiveChestShare = poolInfo.receiveChestAmount.mul(userShare).div(1e12);
                poolInfo.stakeToken.transfer(user, stakeChestShare);
                poolInfo.receiveToken.transfer(user, receiveChestShare);
                poolInfo.stakeChestAmount = poolInfo.stakeChestAmount.sub(stakeChestShare);
                poolInfo.receiveChestAmount = poolInfo.receiveChestAmount.sub(receiveChestShare);
            }

            for (uint j = 0; j < burnPoolInfo.length; j++) {
                BurnPoolInfo storage poolInfo = burnPoolInfo[j];
                uint256 stakeChestShare = poolInfo.stakeChestAmount.mul(userShare).div(1e12);
                uint256 receiveChestShare = poolInfo.receiveChestAmount.mul(userShare).div(1e12);
                poolInfo.burningStakeToken.transfer(user, stakeChestShare);
                poolInfo.receiveToken.transfer(user, receiveChestShare);
                poolInfo.stakeChestAmount = poolInfo.stakeChestAmount.sub(stakeChestShare);
                poolInfo.receiveChestAmount = poolInfo.receiveChestAmount.sub(receiveChestShare);
            }

            for (uint j = 0; j < multiBurnPoolInfo.length; j++) {
                MultiBurnPoolInfo storage poolInfo = multiBurnPoolInfo[j];
                uint256 stakeChestShare = poolInfo.stakeChestAmount.mul(userShare).div(1e12);
                for (uint x = 0; x < poolInfo.burningStakeTokens.length; x++) {
                    poolInfo.burningStakeTokens[x].transfer(user, stakeChestShare);
                }
                poolInfo.stakeChestAmount = poolInfo.stakeChestAmount.sub(stakeChestShare);
            }

            knightToken.transfer(user, voteAmount[user]);
            delete voteAmount[user];
        }


        votingActive = false;
        delete voters;
    }
}