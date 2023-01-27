
pragma solidity 0.5.17;


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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
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

contract ERC20Detailed is Initializable, IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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

    uint256[50] private ______gap;
}

contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}

library Roles {

    struct Role {
        mapping (address => bool) bearer;
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

contract MinterRole is Initializable, Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public initializer {

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

contract ERC20Mintable is Initializable, ERC20, MinterRole {

    function initialize(address sender) public initializer {

        MinterRole.initialize(sender);
    }

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }

    uint256[50] private ______gap;
}

contract ERC20Burnable is Initializable, Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }

    uint256[50] private ______gap;
}

interface ATMTokenInterface {


    event NewCap(uint256 newCap);

    event NewVesting(address beneficiary, uint256 amount, uint256 deadline);

    event VestingClaimed(address beneficiary, uint256 amount);

    event RevokeVesting(address beneficiary, uint256 amount, uint256 deadline);

    event Snapshot(uint256 id);


    function setCap(uint256 newcap) external;


    function mint(address account, uint256 amount) external returns (bool);


    function mintVesting(
        address account,
        uint256 amount,
        uint256 cliff,
        uint256 vestingTime
    ) external;


    function revokeVesting(address account, uint256 vestingId) external;


    function withdrawVested() external;


    function balanceOfAt(address account, uint256 snapshotId)
        external
        view
        returns (uint256);


    function totalSupplyAt(uint256 snapshotId) external view returns (uint256);

}

contract TInitializable {


    bool private _isInitialized;


    modifier isNotInitialized() {

        require(!_isInitialized, "CONTRACT_ALREADY_INITIALIZED");
        _;
    }

    modifier isInitialized() {

        require(_isInitialized, "CONTRACT_NOT_INITIALIZED");
        _;
    }



    function initialized() external view returns (bool) {

        return _isInitialized;
    }


    function _initialize() internal {

        _isInitialized = true;
    }

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

library Arrays {

    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}

interface IATMSettings {


    event ATMPaused(address indexed atm, address indexed account);

    event ATMUnpaused(address indexed account, address indexed atm);

    event MarketToAtmSet(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed atm,
        address account
    );

    event MarketToAtmUpdated(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed oldAtm,
        address newAtm,
        address account
    );

    event MarketToAtmRemoved(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed oldAtm,
        address account
    );





    function pauseATM(address atmAddress) external;


    function unpauseATM(address atmAddress) external;


    function isATMPaused(address atmAddress) external view returns (bool);


    function setATMToMarket(
        address borrowedToken,
        address collateralToken,
        address atmAddress
    ) external;


    function updateATMToMarket(
        address borrowedToken,
        address collateralToken,
        address newAtmAddress
    ) external;


    function removeATMToMarket(address borrowedToken, address collateralToken) external;


    function getATMForMarket(address borrowedToken, address collateralToken)
        external
        view
        returns (address);


    function isATMForMarket(
        address borrowedToken,
        address collateralToken,
        address atmAddress
    ) external view returns (bool);

}

contract ATMToken is
    ATMTokenInterface,
    ERC20Detailed,
    ERC20Mintable,
    ERC20Burnable,
    TInitializable
{

    using SafeMath for uint256;
    using Arrays for uint256[];

    modifier onlyOwner() {

        require(msg.sender == _owner, "CALLER_IS_NOT_OWNER");
        _;
    }

    modifier whenNotPaused() {

        require(!settings.isATMPaused(atmAddress), "ATM_IS_PAUSED");
        _;
    }

    uint256 private _cap;
    uint256 private _maxVestingsPerWallet;
    address private _owner;
    Snapshots private _totalSupplySnapshots;
    uint256 private _currentSnapshotId;
    IATMSettings public settings;
    address public atmAddress;

    struct VestingTokens {
        address account;
        uint256 amount;
        uint256 start;
        uint256 cliff;
        uint256 deadline;
    }

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => mapping(uint256 => VestingTokens)) private _vestingBalances; // Mapping user address to vestings id, which in turn is mapped to the VestingTokens struct
    mapping(address => uint256) public vestingsCount;
    mapping(address => uint256) public assignedTokens;
    mapping(address => Snapshots) private _accountBalanceSnapshots;


    function initialize(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 cap,
        uint256 maxVestingsPerWallet,
        address atmSettingsAddress,
        address atm
    ) public initializer {

        require(cap > 0, "CAP_CANNOT_BE_ZERO");
        super.initialize(name, symbol, decimals);
        _cap = cap;
        _maxVestingsPerWallet = maxVestingsPerWallet;
        _owner = msg.sender;
        settings = IATMSettings(atmSettingsAddress);
        atmAddress = atm;
    }

    function cap() external view returns (uint256) {

        return _cap;
    }

    function setCap(uint256 newCap) external onlyOwner() whenNotPaused() {

        _cap = newCap;
        emit NewCap(_cap);
    }

    function mint(address account, uint256 amount)
        public
        onlyOwner()
        whenNotPaused()
        returns (bool)
    {

        require(account != address(0x0), "MINT_TO_ZERO_ADDRESS_NOT_ALLOWED");
        _beforeTokenTransfer(address(0x0), account, amount);
        _mint(account, amount);
        _snapshot();
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();
        return true;
    }

    function mintVesting(
        address account,
        uint256 amount,
        uint256 cliff,
        uint256 vestingTime
    ) public onlyOwner() whenNotPaused() {

        require(account != address(0x0), "MINT_TO_ZERO_ADDRESS_NOT_ALLOWED");
        require(vestingsCount[account] < _maxVestingsPerWallet, "MAX_VESTINGS_REACHED");
        _beforeTokenTransfer(address(0x0), account, amount);
        uint256 vestingId = vestingsCount[account]++;
        vestingsCount[account] += 1;
        VestingTokens memory vestingTokens = VestingTokens(
            account,
            amount,
            block.timestamp,
            block.timestamp + cliff,
            block.timestamp + vestingTime
        );
        _mint(address(this), amount);
        _snapshot();
        _updateAccountSnapshot(address(this));
        _updateTotalSupplySnapshot();
        assignedTokens[account] += amount;
        _vestingBalances[account][vestingId] = vestingTokens;
        emit NewVesting(account, amount, vestingTime);
    }

    function revokeVesting(address account, uint256 vestingId)
        public
        onlyOwner()
        whenNotPaused()
    {

        require(assignedTokens[account] > 0, "ACCOUNT_DOESNT_HAVE_VESTING");
        VestingTokens memory vestingTokens = _vestingBalances[account][vestingId];

        uint256 unvestedTokens = _returnUnvestedTokens(
            vestingTokens.amount,
            block.timestamp,
            vestingTokens.start,
            vestingTokens.cliff,
            vestingTokens.deadline
        );
        assignedTokens[account] -= unvestedTokens;
        _burn(address(this), unvestedTokens);
        _snapshot();
        _updateAccountSnapshot(address(this));
        _updateTotalSupplySnapshot();
        emit RevokeVesting(account, unvestedTokens, vestingTokens.deadline);
        delete _vestingBalances[account][vestingId];
    }

    function withdrawVested() public whenNotPaused() {

        require(assignedTokens[msg.sender] > 0, "ACCOUNT_DOESNT_HAVE_VESTING");

        uint256 transferableTokens = _transferableTokens(msg.sender, block.timestamp);
        approve(msg.sender, transferableTokens);
        _snapshot();
        _updateAccountSnapshot(msg.sender);
        _updateAccountSnapshot(address(this));
        assignedTokens[msg.sender] -= transferableTokens;
        emit VestingClaimed(msg.sender, transferableTokens);
    }

    function _beforeTokenTransfer(address from, address, uint256 amount) internal view {

        require(
            from == address(0) && totalSupply().add(amount) <= _cap,
            "ERC20_CAP_EXCEEDED"
        ); // When minting tokens
    }

    function _transferableTokens(address _account, uint256 _time)
        internal
        view
        returns (uint256)
    {

        uint256 totalVestings = vestingsCount[_account];
        uint256 totalAssigned = assignedTokens[_account];
        uint256 nonTransferable = 0;
        for (uint256 i = 0; i < totalVestings; i++) {
            VestingTokens storage vestingTokens = _vestingBalances[_account][i];
            nonTransferable = _returnUnvestedTokens(
                vestingTokens.amount,
                _time,
                vestingTokens.start,
                vestingTokens.cliff,
                vestingTokens.deadline
            );
        }
        uint256 transferable = totalAssigned - nonTransferable;
        return transferable;
    }

    function _returnUnvestedTokens(
        uint256 amount,
        uint256 time,
        uint256 start,
        uint256 cliff,
        uint256 deadline
    ) internal pure returns (uint256) {

        if (time >= deadline) {
            return 0;
        } else if (time < cliff) {
            return amount;
        } else {
            uint256 eligibleTokens = amount.mul(time.sub(start) / deadline.sub(start));
            return amount.sub(eligibleTokens);
        }
    }

    function _snapshot() internal returns (uint256) {

        _currentSnapshotId = _currentSnapshotId.add(1);
        uint256 currentId = _currentSnapshotId;
        emit Snapshot(currentId);
        return currentId;
    }

    function balanceOfAt(address account, uint256 snapshotId)
        external
        view
        returns (uint256)
    {

        (bool snapshotted, uint256 value) = _valueAt(
            snapshotId,
            _accountBalanceSnapshots[account]
        );

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) external view returns (uint256) {

        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private
        view
        returns (bool, uint256)
    {

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {

        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {

        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {

        uint256 currentId = _currentSnapshotId;
        snapshots.ids.push(currentId);
        snapshots.values.push(currentValue);
    }
}