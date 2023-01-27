


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



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
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


pragma solidity 0.6.12;

interface ILPERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





pragma solidity 0.6.12;



interface ISnpToken is IERC20 {

    function mint(address account, uint256 amount) external returns (uint256);


    function burn(uint256 amount) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

}



pragma solidity 0.6.12;







contract SnpToken is ISnpToken, Ownable, Pausable {

    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public minters;

    uint256 private _totalSupply;

    string private _name = "SNP Token";
    string private _symbol = "SNP";
    uint8 private _decimals = 18;
    uint256 public TOTAL_SUPPLY = 3000000 ether;

    constructor() public {
        _totalSupply = 0;
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function decimals() external view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function addMinter(address _minter) external onlyOwner {

        minters[_minter] = true;
    }

    function removeMinter(address _minter) external onlyOwner {

        minters[_minter] = false;
    }

    function mint(address account, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (uint256)
    {

        require(minters[msg.sender], "SnpToken: You are not the minter");
        uint256 supply = _totalSupply.add(amount);
        if (supply > TOTAL_SUPPLY) {
            supply = TOTAL_SUPPLY;
        }
        amount = supply.sub(_totalSupply);
        _mint(account, amount);
        return amount;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "SnpToken: TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE"
            )
        );
        return true;
    }

    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "SnpToken: DECREASED_ALLOWANCE_BELOW_ZERO"
            )
        );
        return true;
    }

    function burn(uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {

        _burn(msg.sender, amount);
        return true;
    }

    function withdraw(address token, uint256 amount) public onlyOwner {

        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(
            sender != address(0),
            "SnpToken: TRANSFER_FROM_THE_ZERO_ADDRESS"
        );
        require(
            recipient != address(0),
            "SnpToken: TRANSFER_TO_THE_ZERO_ADDRESS"
        );

        _balances[sender] = _balances[sender].sub(
            amount,
            "SnpToken: TRANSFER_AMOUNT_EXCEEDS_BALANCE"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "SnpToken: APPROVE_FROM_THE_ZERO_ADDRESS");
        require(spender != address(0), "SnpToken: APPROVE_TO_THE_ZERO_ADDRESS");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "SnpToken: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "SnpToken: BURN_FROM_THE_ZERO_ADDRESS");
        _balances[account] = _balances[account].sub(
            amount,
            "SnpToken: BURN_AMOUNT_EXCEEDS_BALANCE"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}


pragma solidity 0.6.12;








contract SnpMaster is Ownable, Pausable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 depositTime; // time of deposit LP token
        string refAddress; //refer address
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool.
        uint256 lpSupply; // lp supply of LP pool.
        uint256 lastRewardBlock; // Last block number that SNP distribution occurs.
        uint256 accSnpPerShare; // Accumulated SNPs per share, times 1e12. See below.
        uint256 lockPeriod; // lock period of  LP pool
        uint256 unlockPeriod; // unlock period of  LP pool
        bool emergencyEnable; // pool withdraw emergency enable
    }

    address public governance;
    address public seeleEcosystem;
    SnpToken public snptoken;

    uint256 public snpPerBlock;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public endBlock;
    uint256 public constant MINTEND_BLOCKNUM = 11262857;

    uint256 public totalMintReward = 0;
    uint256 public totallpSupply = 0;

    uint256 public constant farmrate = 51;
    uint256 public constant ecosystemrate = 49;

    event Deposit(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        string indexed refAddress
    );
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        SnpToken _snp,
        uint256 _snpPerBlock,
        uint256 _startBlock
    ) public {
        snptoken = _snp;
        snpPerBlock = _snpPerBlock;
        startBlock = _startBlock;
        governance = msg.sender;
        seeleEcosystem = msg.sender;
        endBlock = _startBlock.add(MINTEND_BLOCKNUM);
    }

    function setGovernance(address _governance) public {

        require(msg.sender == governance, "snpmaster:!governance");
        governance = _governance;
    }

    function setSeeleEcosystem(address _seeleEcosystem) public {

        require(msg.sender == seeleEcosystem, "snpmaster:!seeleEcosystem");
        seeleEcosystem = _seeleEcosystem;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                lpSupply: 0,
                accSnpPerShare: 0,
                lockPeriod: 0,
                unlockPeriod: 0,
                emergencyEnable: false
            })
        );
    }

    function setPoolLockTime(
        uint256 _pid,
        uint256 _lockPeriod,
        uint256 _unlockPeriod
    ) public onlyOwner {

        poolInfo[_pid].lockPeriod = _lockPeriod;
        poolInfo[_pid].unlockPeriod = _unlockPeriod;
    }

    function setPoolEmergencyEnable(uint256 _pid, bool _emergencyEnable)
        public
        onlyOwner
    {

        poolInfo[_pid].emergencyEnable = _emergencyEnable;
    }

    function setEndMintBlock(uint256 _endBlock) public onlyOwner {

        endBlock = _endBlock;
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );

        PoolInfo storage pool = poolInfo[_pid];
        if (pool.lpSupply > 0) {
            uint256 lpDec = ILPERC20(address(pool.lpToken)).decimals();
            uint256 lpSupply = pool
                .lpSupply
                .mul(pool.allocPoint)
                .mul(1e18)
                .div(100)
                .div(10**lpDec);
            totallpSupply = totallpSupply.sub(lpSupply);

            lpSupply = pool.lpSupply.mul(_allocPoint).mul(1e18).div(100).div(
                10**lpDec
            );
            totallpSupply = totallpSupply.add(lpSupply);
        }

        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 lpDec = ILPERC20(address(pool.lpToken)).decimals();
        uint256 lpSupply1e18 = lpSupply.mul(1e18).div(10**lpDec);

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 snpmint = multiplier
            .mul(snpPerBlock)
            .mul(pool.allocPoint)
            .mul(lpSupply1e18)
            .div(100)
            .div(totallpSupply);

        snptoken.mint(seeleEcosystem, snpmint.mul(ecosystemrate).div(100));

        uint256 snpReward = snpmint.mul(farmrate).div(100);
        snpReward = snptoken.mint(address(this), snpReward);

        totalMintReward = totalMintReward.add(snpReward);

        pool.accSnpPerShare = pool.accSnpPerShare.add(
            snpReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        uint256 toFinal = _to > endBlock ? endBlock : _to;
        if (_from >= endBlock) {
            return 0;
        }
        return toFinal.sub(_from);
    }

    function pendingSnp(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSnpPerShare = pool.accSnpPerShare;
        uint256 lpSupply = pool.lpSupply;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 lpDec = ILPERC20(address(pool.lpToken)).decimals();
            uint256 lpSupply1e18 = lpSupply.mul(1e18).div(10**lpDec);

            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 snpmint = multiplier
                .mul(snpPerBlock)
                .mul(pool.allocPoint)
                .mul(lpSupply1e18)
                .div(100)
                .div(totallpSupply);

            uint256 snpReward = snpmint.mul(farmrate).div(100);
            accSnpPerShare = accSnpPerShare.add(
                snpReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accSnpPerShare).div(1e12).sub(user.rewardDebt);
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        string calldata _refuser
    ) public whenNotPaused {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accSnpPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            if (pending > 0 && pool.lockPeriod == 0) {
                uint256 _depositTime = now - user.depositTime;
                if (_depositTime < 1 days) {
                    uint256 _actualReward = _depositTime
                        .mul(pending)
                        .mul(1e18)
                        .div(1 days)
                        .div(1e18);
                    uint256 _goverAomunt = pending.sub(_actualReward);
                    safeSnpTransfer(governance, _goverAomunt);
                    pending = _actualReward;
                }
                safeSnpTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            pool.lpSupply = pool.lpSupply.add(_amount);
            user.depositTime = now;
            user.refAddress = _refuser;
            uint256 lpDec = ILPERC20(address(pool.lpToken)).decimals();
            uint256 lpSupply = _amount
                .mul(pool.allocPoint)
                .mul(1e18)
                .div(100)
                .div(10**lpDec);
            totallpSupply = totallpSupply.add(lpSupply);
        }
        user.rewardDebt = user.amount.mul(pool.accSnpPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount, user.refAddress);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good amount");
        if (_amount > 0 && pool.lockPeriod > 0) {
            require(
                now >= user.depositTime + pool.lockPeriod,
                "withdraw: lock time not reach"
            );
            if (pool.unlockPeriod > 0) {
                require(
                    (now - user.depositTime) % pool.lockPeriod <=
                        pool.unlockPeriod,
                    "withdraw: not in unlock time period"
                );
            }
        }

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSnpPerShare).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            uint256 _depositTime = now - user.depositTime;
            if (_depositTime < 1 days && pool.lockPeriod == 0) {
                uint256 _actualReward = _depositTime
                    .mul(pending)
                    .mul(1e18)
                    .div(1 days)
                    .div(1e18);
                uint256 _goverAomunt = pending.sub(_actualReward);
                safeSnpTransfer(governance, _goverAomunt);
                pending = _actualReward;
            }
            safeSnpTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpSupply = pool.lpSupply.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);

            uint256 lpDec = ILPERC20(address(pool.lpToken)).decimals();
            uint256 lpSupply = _amount
                .mul(pool.allocPoint)
                .mul(1e18)
                .div(100)
                .div(10**lpDec);
            totallpSupply = totallpSupply.sub(lpSupply);
        }
        user.rewardDebt = user.amount.mul(pool.accSnpPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            pool.lockPeriod == 0 || pool.emergencyEnable == true,
            "emergency withdraw: not good condition"
        );
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);

        uint256 lpDec = ILPERC20(address(pool.lpToken)).decimals();
        uint256 lpSupply = user
            .amount
            .mul(pool.allocPoint)
            .mul(1e18)
            .div(100)
            .div(10**lpDec);
        totallpSupply = totallpSupply.sub(lpSupply);

        emit EmergencyWithdraw(msg.sender, _pid, user.amount);

        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeSnpTransfer(address _to, uint256 _amount) internal {

        uint256 snpBal = snptoken.balanceOf(address(this));
        if (_amount > snpBal) {
            snptoken.transfer(_to, snpBal);
        } else {
            snptoken.transfer(_to, _amount);
        }
    }

    function setSnpPerBlock(uint256 _snpPerBlock) public onlyOwner {

        require(_snpPerBlock > 0, "!snpPerBlock-0");

        snpPerBlock = _snpPerBlock;
    }
}