

pragma solidity 0.6.12;




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
}


interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}


library Roles {

    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


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
}


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
}


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
}


contract MinterRole is Initializable, ContextUpgradeable {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public virtual initializer {

        __Context_init_unchained();
        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}


contract VestedAkroSenderRole is Initializable, ContextUpgradeable {

    using Roles for Roles.Role;

    event SenderAdded(address indexed account);
    event SenderRemoved(address indexed account);

    Roles.Role private _senders;

    function initialize(address sender) public virtual initializer {

        __Context_init_unchained();
        if (!isSender(sender)) {
            _addSender(sender);
        }
    }

    modifier onlySender() {

        require(isSender(_msgSender()), "SenderRole: caller does not have the Sender role");
        _;
    }

    function isSender(address account) public view returns (bool) {

        return _senders.has(account);
    }

    function addSender(address account) public onlySender {

        _addSender(account);
    }

    function renounceSender() public {

        _removeSender(_msgSender());
    }

    function _addSender(address account) internal {

        _senders.add(account);
        emit SenderAdded(account);
    }

    function _removeSender(address account) internal {

        _senders.remove(account);
        emit SenderRemoved(account);
    }

    uint256[50] private ______gap;
}


contract VestedAkro is OwnableUpgradeable, IERC20Upgradeable, MinterRole, VestedAkroSenderRole {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event Locked(address indexed holder, uint256 amount);
    event Unlocked(address indexed holder, uint256 amount);
    event AkroAdded(uint256 amount);

    struct VestedBatch {
        uint256 amount; // Full amount of vAKRO vested in this batch
        uint256 start; // Vesting start time;
        uint256 end; // Vesting end time
        uint256 claimed; // vAKRO already claimed from this batch to unlocked balance of holder
    }

    struct Balance {
        VestedBatch[] batches; // Array of vesting batches
        uint256 locked; // Amount locked in batches
        uint256 unlocked; // Amount of unlocked vAKRO (which either was previously claimed, or received from Minter)
        uint256 firstUnclaimedBatch; // First batch which is not fully claimed
    }

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public override totalSupply;
    IERC20Upgradeable public akro;
    uint256 public vestingPeriod; //set by owner of this VestedAkro token
    uint256 public vestingStart; //set by owner, default value 01 May 2021, 00:00:00 GMT+0
    uint256 public vestingCliff; //set by owner, cliff for akro unlock, 1 month by default
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => Balance) private holders;

    uint256 public swapToAkroRateNumerator; //Amount of 1 vAkro for 1 AKRO - 1 by default
    uint256 public swapToAkroRateDenominator;

    function initialize(address _akro, uint256 _vestingPeriod) public initializer {

        __Ownable_init();
        MinterRole.initialize(_msgSender());
        VestedAkroSenderRole.initialize(_msgSender());

        _name = "Vested AKRO";
        _symbol = "vAKRO";
        _decimals = 18;

        akro = IERC20Upgradeable(_akro);
        require(_vestingPeriod > 0, "VestedAkro: vestingPeriod should be > 0");
        vestingPeriod = _vestingPeriod;
        vestingStart = 1619827200; //01 May 2021, 00:00:00 GMT+0
        vestingCliff = 31 * 24 * 60 * 60; //1 month - 31 day in May

        swapToAkroRateNumerator = 1;
        swapToAkroRateDenominator = 1;
    }

    function initialize(address sender) public override(MinterRole, VestedAkroSenderRole) {}


    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override onlySender returns (bool) {

        require(isSender(sender), "VestedAkro: sender should have VestedAkroSender role");

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()].sub(amount, "VestedAkro: transfer amount exceeds allowance"));
        return true;
    }

    function transfer(address recipient, uint256 amount) public override onlySender returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function setVestingPeriod(uint256 _vestingPeriod) public onlyOwner {

        require(_vestingPeriod > 0, "VestedAkro: vestingPeriod should be > 0");
        vestingPeriod = _vestingPeriod;
    }

    function setVestingStart(uint256 _vestingStart) public onlyOwner {

        require(_vestingStart > 0, "VestedAkro: vestingStart should be > 0");
        vestingStart = _vestingStart;
    }

    function setVestingCliff(uint256 _vestingCliff) public onlyOwner {

        vestingCliff = _vestingCliff;
    }

    function setSwapRate(uint256 _swapRateNumerator, uint256 _swapRateDenominator) external onlyOwner {

        require(_swapRateDenominator > 0, "Incorrect value");
        swapToAkroRateNumerator = _swapRateNumerator;
        swapToAkroRateDenominator = _swapRateDenominator;
    }

    function mint(address beneficiary, uint256 amount) public onlyMinter {

        totalSupply = totalSupply.add(amount);
        holders[beneficiary].unlocked = holders[beneficiary].unlocked.add(amount);
        emit Transfer(address(0), beneficiary, amount);
    }

    function burnFrom(address sender, uint256 amount) public onlyMinter {

        require(amount > 0, "Incorrect amount");
        require(sender != address(0), "Zero address");

        require(block.timestamp <= vestingStart, "Vesting has started");

        Balance storage b = holders[sender];

        require(b.locked >= amount, "Insufficient vAkro");
        require(b.batches.length > 0 || b.firstUnclaimedBatch < b.batches.length, "Nothing to burn");

        totalSupply = totalSupply.sub(amount);
        b.locked = b.locked.sub(amount);

        uint256 batchAmount = b.batches[b.firstUnclaimedBatch].amount;
        b.batches[b.firstUnclaimedBatch].amount = batchAmount.sub(amount);

        emit Transfer(sender, address(0), amount);
    }

    function addAkroLiquidity(uint256 _amount) public onlyMinter {

        require(_amount > 0, "Incorrect amount");

        IERC20Upgradeable(akro).safeTransferFrom(_msgSender(), address(this), _amount);

        emit AkroAdded(_amount);
    }

    function unlockAvailable(address holder) public returns (uint256) {

        require(holders[holder].batches.length > 0, "VestedAkro: nothing to unlock");
        claimAllFromBatches(holder);
        return holders[holder].unlocked;
    }

    function unlockAndRedeemAll() public returns (uint256) {

        address beneficiary = _msgSender();
        claimAllFromBatches(beneficiary);
        return redeemAllUnlocked();
    }

    function redeemAllUnlocked() public returns (uint256) {

        address beneficiary = _msgSender();
        require(!isSender(beneficiary), "VestedAkro: VestedAkroSender is not allowed to redeem");
        uint256 amount = holders[beneficiary].unlocked;
        if (amount == 0) return 0;

        uint256 akroAmount = amount.mul(swapToAkroRateNumerator).div(swapToAkroRateDenominator);
        require(akro.balanceOf(address(this)) >= akroAmount, "Not enough AKRO");

        holders[beneficiary].unlocked = 0;
        totalSupply = totalSupply.sub(amount);

        akro.transfer(beneficiary, akroAmount);

        emit Transfer(beneficiary, address(0), amount);
        return amount;
    }

    function balanceOfAkro(address account) public view returns (uint256) {

        Balance storage b = holders[account];
        uint256 amount = b.locked.add(b.unlocked);
        uint256 akroAmount = amount.mul(swapToAkroRateNumerator).div(swapToAkroRateDenominator);
        return akroAmount;
    }

    function balanceOf(address account) public view override returns (uint256) {

        Balance storage b = holders[account];
        return b.locked.add(b.unlocked);
    }

    function balanceInfoOf(address account)
        public
        view
        returns (
            uint256 locked,
            uint256 unlocked,
            uint256 unlockable
        )
    {

        Balance storage b = holders[account];
        return (b.locked, b.unlocked, calculateClaimableFromBatches(account));
    }

    function batchesInfoOf(address account) public view returns (uint256 firstUnclaimedBatch, uint256 totalBatches) {

        Balance storage b = holders[account];
        return (b.firstUnclaimedBatch, b.batches.length);
    }

    function batchInfo(address account, uint256 batch)
        public
        view
        returns (
            uint256 amount,
            uint256 start,
            uint256 end,
            uint256 claimed,
            uint256 claimable
        )
    {

        VestedBatch storage vb = holders[account].batches[batch];
        (claimable, ) = calculateClaimableFromBatch(vb);
        return (vb.amount, vestingStart, vestingStart.add(vestingPeriod), vb.claimed, claimable);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "VestedAkro: approve from the zero address");
        require(spender != address(0), "VestedAkro: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), "VestedAkro: transfer from the zero address");
        require(recipient != address(0), "VestedAkro: transfer to the zero address");

        holders[sender].unlocked = holders[sender].unlocked.sub(amount, "VestedAkro: transfer amount exceeds unlocked balance");
        createOrModifyBatch(recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    function createOrModifyBatch(address holder, uint256 amount) internal {

        Balance storage b = holders[holder];

        if (b.batches.length == 0 || b.firstUnclaimedBatch == b.batches.length) {
            b.batches.push(VestedBatch({amount: amount, start: vestingStart, end: vestingStart.add(vestingPeriod), claimed: 0}));
        } else {
            uint256 batchAmount = b.batches[b.firstUnclaimedBatch].amount;
            b.batches[b.firstUnclaimedBatch].amount = batchAmount.add(amount);
        }
        b.locked = b.locked.add(amount);
        emit Locked(holder, amount);
    }

    function claimAllFromBatches(address holder) internal {

        claimAllFromBatches(holder, holders[holder].batches.length);
    }

    function claimAllFromBatches(address holder, uint256 tillBatch) internal {

        Balance storage b = holders[holder];
        bool firstUnclaimedFound;
        uint256 claiming;
        for (uint256 i = b.firstUnclaimedBatch; i < tillBatch; i++) {
            (uint256 claimable, bool fullyClaimable) = calculateClaimableFromBatch(b.batches[i]);
            if (claimable > 0) {
                b.batches[i].claimed = b.batches[i].claimed.add(claimable);
                claiming = claiming.add(claimable);
            }
            if (!fullyClaimable && !firstUnclaimedFound) {
                b.firstUnclaimedBatch = i;
                firstUnclaimedFound = true;
            }
        }
        if (!firstUnclaimedFound) {
            b.firstUnclaimedBatch = b.batches.length;
        }
        if (claiming > 0) {
            b.locked = b.locked.sub(claiming);
            b.unlocked = b.unlocked.add(claiming);
            emit Unlocked(holder, claiming);
        }
    }

    function calculateClaimableFromBatches(address holder) internal view returns (uint256) {

        Balance storage b = holders[holder];
        uint256 claiming;
        for (uint256 i = b.firstUnclaimedBatch; i < b.batches.length; i++) {
            (uint256 claimable, ) = calculateClaimableFromBatch(b.batches[i]);
            claiming = claiming.add(claimable);
        }
        return claiming;
    }

    function calculateClaimableFromBatch(VestedBatch storage vb) internal view returns (uint256, bool) {

        if (now < vestingStart.add(vestingCliff)) {
            return (0, false); // No unlcoks before cliff period is over
        }
        if (now >= vestingStart.add(vestingPeriod)) {
            return (vb.amount.sub(vb.claimed), true);
        }
        uint256 claimable = (vb.amount.mul(now.sub(vestingStart)).div(vestingPeriod)).sub(vb.claimed);
        return (claimable, false);
    }
}