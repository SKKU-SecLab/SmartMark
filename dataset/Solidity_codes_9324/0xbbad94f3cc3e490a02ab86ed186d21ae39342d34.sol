pragma solidity >=0.6 <0.7.0;


contract PollenParams {


    address internal constant pollenDaoAddress = 0x99c0268759d26616AeC761c28336eccd72CCa39A;
    address internal constant plnTokenAddress = 0xF4db951000acb9fdeA6A9bCB4afDe42dd52311C7;
    address internal constant stemTokenAddress = 0xd12ABa72Cad68a63D9C5c6EBE5461fe8fA774B60;
    address internal constant rateQuoterAddress = 0xB7692BBC55C0a8B768E5b523d068B5552fbF7187;

    uint32 internal constant mintStartBlock = 11565019; // Jan-01-2021 00:00:00 +UTC
    uint32 internal constant mintBlocks = 9200000; // ~ 46 months
    uint32 internal constant extraMintBlocks = 600000; // ~ 92 days

    uint32 internal constant defaultVotingExpiryDelay = 12 * 3600;
    uint32 internal constant defaultExecutionOpenDelay = 6 * 3600;
    uint32 internal constant defaultExecutionExpiryDelay = 24 * 3600;
}pragma solidity >=0.4.24 <0.7.0;


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
}pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {


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
}pragma solidity ^0.6.0;

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

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
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;


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
}pragma solidity ^0.6.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.6.0;


contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {



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


    uint256[44] private __gap;
}pragma solidity ^0.6.0;


abstract contract ERC20SnapshotUpgradeSafe is Initializable, ERC20UpgradeSafe {
    function __ERC20Snapshot_init() internal initializer {
        __Context_init_unchained();
        __ERC20Snapshot_init_unchained();
    }

    function __ERC20Snapshot_init_unchained() internal initializer {


    }


    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _transfer(address from, address to, uint256 value) internal virtual override {
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);

        super._transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal virtual override {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._mint(account, value);
    }

    function _burn(address account, uint256 value) internal virtual override {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._burn(account, value);
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _currentSnapshotId.current(), "ERC20Snapshot: nonexistent id");


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
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    uint256[46] private __gap;
}// MIT



contract PollenToken is OwnableUpgradeSafe, ERC20SnapshotUpgradeSafe {


    uint256 internal constant MAX_SUPPLY = 2 ** 96 - 1;

    uint256[50] private __gap;

    function _initialize(
        string memory name,
        string memory symbol
    ) internal initializer {

        __Ownable_init();
        __ERC20_init_unchained(name, symbol);
        __ERC20Snapshot_init_unchained();
    }

    function mint(uint256 amount) external onlyOwner
    {

        require(
            totalSupply().add(amount) <= MAX_SUPPLY,
            "Pollen: Total supply exceeds 96 bits"
        );
        _mint(_msgSender(), amount);
    }

    function burn(uint256 amount) external
    {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) external {

        uint256 decreasedAllowance = allowance(account, _msgSender())
            .sub(amount, "Pollen: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    function snapshot() external onlyOwner returns (uint256)
    {

        return super._snapshot();
    }
}pragma solidity >=0.6 <0.7.0;
pragma experimental ABIEncoderV2;


interface IStemVesting {


    struct StemVestingPool {
        bool isRestricted; // if `true`, the 'wallet' only may trigger withdrawal
        uint32 startBlock;
        uint32 endBlock;
        uint32 lastVestedBlock;
        uint128 perBlockStemScaled; // scaled (multiplied) by 1e6
    }

    function initialize(
        address foundationWallet,
        address reserveWallet,
        address foundersWallet,
        address marketWallet
    ) external;


    function getVestingPoolParams(address wallet) external view returns(StemVestingPool memory);


    function getPoolPendingStem(address wallet) external view returns(uint256 amount);


    function withdrawPoolStem(address wallet) external returns (uint256 amount);


    event VestingPool(address indexed wallet);
    event StemWithdrawal(address indexed wallet, uint256 amount);
}// MIT



contract Stem_v1 is PollenToken, PollenParams, IStemVesting {

    using SafeMath for uint256;


    uint256 private constant targetSupply = 100e24; // 100 millions

    uint32 internal constant mintEndBlock = mintStartBlock + mintBlocks;
    uint32 internal constant extraMintEndBlock = mintStartBlock + extraMintBlocks;
    uint256 internal constant unlockBlock = extraMintEndBlock;

    uint128 internal constant scaledPerBlockFoundationStem = 8 * 1e18 * 1e12 / extraMintBlocks;
    uint128 internal constant scaledPerBlockReserveStem =    4 * 1e18 * 1e12 / extraMintBlocks;
    uint128 internal constant scaledPerBlockFoundersStem =  20 * 1e18 * 1e12 / mintBlocks;
    uint128 internal constant scaledPerBlockMarketingStem =  5 * 1e18 * 1e12 / mintBlocks;
    uint128 internal constant scaledPerBlockRewardStem =    63 * 1e18 * 1e12 / mintBlocks;

    mapping(address => StemVestingPool) internal _vestingPools;

    constructor(bool doPreventUseWithoutProxy) public {
        if (doPreventUseWithoutProxy) {
            __Ownable_init();
        }
    }

    function initialize(
        address foundationWallet,
        address reserveWallet,
        address foundersWallet,
        address marketWallet
    ) external override initializer {

        _initialize("STEM token", "STEM");

        address pollenDAO = _pollenDAO();
        transferOwnership(pollenDAO);

        _initVestingPool( // Reward Pool
            StemVestingPool(
                true, // 'pollenDAO' only may trigger withdrawals
                _mintStartBlock(),
                _mintEndBlock(),
                _mintStartBlock(),
                scaledPerBlockRewardStem
            ),
            pollenDAO
        );
        _initVestingPool( // Foundation Pool
            StemVestingPool(
                false, // anyone may trigger withdrawals
                _mintStartBlock(),
                _extraMintEndBlock(),
                _mintStartBlock(),
                scaledPerBlockFoundationStem
            ),
            foundationWallet
        );
        _initVestingPool( // Reserve Pool
            StemVestingPool(
                true, // 'reserveWallet' only may trigger withdrawals
                _mintStartBlock(),
                _extraMintEndBlock(),
                _mintStartBlock(),
                scaledPerBlockReserveStem
            ),
            reserveWallet
        );
        _initVestingPool( // Founders&Team Pool
            StemVestingPool(
                false, // anyone may trigger withdrawals
                _mintStartBlock(),
                _mintEndBlock(),
                _mintStartBlock(),
                scaledPerBlockFoundersStem
            ),
            foundersWallet
        );
        _initVestingPool( // Marketing&Advisors Pool
            StemVestingPool(
                false, // anyone may trigger withdrawals
                _mintStartBlock(),
                _mintEndBlock(),
                _mintStartBlock(),
                scaledPerBlockMarketingStem
            ),
            marketWallet
        );
    }

    function getVestingPoolParams(
        address wallet
    ) external view override returns(StemVestingPool memory) {

        return _vestingPools[wallet];
    }

    function getPoolPendingStem(
        address wallet
    ) external view override returns(uint256 amount) {

        StemVestingPool memory pool = _vestingPools[wallet];
        amount = _computeVestingToPool(pool, block.number);
    }

    function withdrawPoolStem(
        address wallet
    ) external override returns (uint256 amount) {

        StemVestingPool memory pool = _vestingPools[wallet];
        require(!pool.isRestricted || msg.sender == wallet, "STEM: unauthorized");
        amount = _computeVestingToPool(pool, block.number);
        if (amount != 0) {
            _vestingPools[wallet] = pool;
            _mintTo(wallet, amount);
        }

        emit StemWithdrawal(wallet, amount);
    }


    function _mintTo(address account, uint256 amount) internal {

        require(
            totalSupply().add(amount) <= targetSupply,
            "STEM: Total supply exceeds 100 millions"
        );
        _mint(account, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {

        require(
            block.number > _unlockBlock() || from == address(0) || from == _pollenDAO(),
            "STEM: token locked"
        );
        super._beforeTokenTransfer(from, to, amount);
    }

    function _initVestingPool(StemVestingPool memory pool, address wallet) internal {

        require(wallet != address(0), "zero wallet address");
        require(
            pool.startBlock != 0 && pool.perBlockStemScaled != 0,
            "STEM: invalid pool params"
        );
        _vestingPools[wallet] = pool;
        emit VestingPool(wallet);
    }

    function _computeVestingToPool(
        StemVestingPool memory pool,
        uint256 blockNow
    ) internal pure returns (uint256 stemToVest) {

        require(pool.perBlockStemScaled != 0, "STEM: unknown pool");
        stemToVest = 0;

        if (
            pool.lastVestedBlock < pool.endBlock &&
            blockNow > pool.startBlock &&
            blockNow > pool.lastVestedBlock
        ) {
            uint256 fromBlock = pool.lastVestedBlock > pool.startBlock
            ? pool.lastVestedBlock
            : pool.startBlock;
            uint256 toBlock = blockNow > pool.endBlock
            ? pool.endBlock
            : blockNow;

            if (toBlock > fromBlock) {
                stemToVest = toBlock.sub(fromBlock).mul(pool.perBlockStemScaled)/1e6;
                pool.lastVestedBlock = uint32(blockNow);
            }
        }
    }

    function _pollenDAO() internal pure virtual returns(address) { return pollenDaoAddress; }

    function _mintStartBlock() internal pure virtual returns(uint32) { return mintStartBlock; }

    function _mintEndBlock() internal pure virtual returns(uint32) { return mintEndBlock; }

    function _extraMintEndBlock() internal pure virtual returns(uint32) { return extraMintEndBlock; }

    function _unlockBlock() internal pure virtual returns(uint256) { return unlockBlock; }

}