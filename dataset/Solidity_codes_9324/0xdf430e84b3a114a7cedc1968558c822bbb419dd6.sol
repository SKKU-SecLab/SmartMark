
pragma solidity ^0.5.0;

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

contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

contract Base is Initializable, Context, Ownable {

    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {

        Ownable.initialize(_msgSender());
    }

}

contract ModuleNames {

    string public constant MODULE_ACCESS            = "access";
    string public constant MODULE_PTOKEN            = "ptoken";
    string public constant MODULE_CURVE             = "curve";
    string public constant MODULE_FUNDS             = "funds";
    string public constant MODULE_LIQUIDITY         = "liquidity";
    string public constant MODULE_LOAN              = "loan";
    string public constant MODULE_LOAN_LIMTS        = "loan_limits";
    string public constant MODULE_LOAN_PROPOSALS    = "loan_proposals";

    string public constant MODULE_LTOKEN            = "ltoken";
}

contract Module is Base, ModuleNames {

    event PoolAddressChanged(address newPool);
    address public pool;

    function initialize(address _pool) public initializer {

        Base.initialize();
        setPool(_pool);
    }

    function setPool(address _pool) public onlyOwner {

        require(_pool != ZERO_ADDRESS, "Module: pool address can't be zero");
        pool = _pool;
        emit PoolAddressChanged(_pool);        
    }

    function getModuleAddress(string memory module) public view returns(address){

        require(pool != ZERO_ADDRESS, "Module: no pool");
        (bool success, bytes memory result) = pool.staticcall(abi.encodeWithSignature("get(string)", module));
        
        if (!success) assembly {
            revert(add(result, 32), result)
        }

        address moduleAddress = abi.decode(result, (address));
        require(moduleAddress != ZERO_ADDRESS, "Module: requested module not found");
        return moduleAddress;
    }

}


interface IPToken {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;


    function distribute(uint256 amount) external;

    function claimDistributions(address account) external returns(uint256);

    function claimDistributions(address account, uint256 lastDistribution) external returns(uint256);

    function claimDistributions(address[] calldata accounts) external;

    function claimDistributions(address[] calldata accounts, uint256 toDistribution) external;

    function fullBalanceOf(address account) external view returns(uint256);

    function calculateDistributedAmount(uint256 startDistribution, uint256 nextDistribution, uint256 initialBalance) external view returns(uint256);

    function nextDistribution() external view returns(uint256);


}

interface IFundsModule {

    event Status(uint256 lBalance, uint256 lDebts, uint256 lProposals, uint256 pEnterPrice, uint256 pExitPrice);

    function depositLTokens(address from, uint256 amount) external;

    function withdrawLTokens(address to, uint256 amount) external;


    function withdrawLTokens(address to, uint256 amount, uint256 poolFee) external;


    function depositPTokens(address from, uint256 amount) external;


    function withdrawPTokens(address to, uint256 amount) external;


    function mintPTokens(address to, uint256 amount) external;


    function distributePTokens(uint256 amount) external;


    function burnPTokens(address from, uint256 amount) external;


    function lockPTokens(address[] calldata from, uint256[] calldata amount) external;


    function mintAndLockPTokens(uint256 amount) external;


    function unlockAndWithdrawPTokens(address to, uint256 amount) external;


    function burnLockedPTokens(uint256 amount) external;


    function calculatePoolEnter(uint256 lAmount) external view returns(uint256);


    function calculatePoolEnter(uint256 lAmount, uint256 liquidityCorrection) external view returns(uint256);

    
    function calculatePoolExit(uint256 lAmount) external view returns(uint256);


    function calculatePoolExitInverse(uint256 pAmount) external view returns(uint256, uint256, uint256);


    function calculatePoolExitWithFee(uint256 lAmount) external view returns(uint256);


    function calculatePoolExitWithFee(uint256 lAmount, uint256 liquidityCorrection) external view returns(uint256);


    function lBalance() external view returns(uint256);


    function pBalanceOf(address account) external view returns(uint256);


}

contract DistributionToken is ERC20, ERC20Mintable {

    using SafeMath for uint256;
    uint256 public constant DISTRIBUTION_AGGREGATION_PERIOD = 24*60*60;

    event DistributionCreated(uint256 amount, uint256 totalSupply);
    event DistributionsClaimed(address account, uint256 amount, uint256 fromDistribution, uint256 toDistribution);
    event DistributionAccumulatorIncreased(uint256 amount);

    struct Distribution {
        uint256 amount;         // Amount of tokens being distributed during the event
        uint256 totalSupply;    // Total supply before distribution
    }

    Distribution[] public distributions;                   // Array of all distributions
    mapping(address => uint256) public nextDistributions;  // Map account to first distribution not yet processed

    uint256 public nextDistributionTimestamp;      //Timestamp when next distribuition should be fired regardles of accumulated tokens
    uint256 public distributionAccumulator;        //Tokens accumulated for next distribution

    function distribute(uint256 amount) external onlyMinter {

        distributionAccumulator = distributionAccumulator.add(amount);
        emit DistributionAccumulatorIncreased(amount);
        _createDistributionIfReady();
    }

    function createDistribution() external onlyMinter {

        require(distributionAccumulator > 0, "DistributionToken: nothing to distribute");
        _createDistribution();
    }

    function claimDistributions(address account) external returns(uint256) {

        _createDistributionIfReady();
        uint256 amount = _updateUserBalance(account, distributions.length);
        if (amount > 0) userBalanceChanged(account);
        return amount;
    }
    
    function claimDistributions(address account, uint256 toDistribution) external returns(uint256) {

        require(toDistribution < distributions.length, "DistributionToken: lastDistribution too hight");
        require(nextDistributions[account] < toDistribution, "DistributionToken: no distributions to claim");
        uint256 amount = _updateUserBalance(account, toDistribution+1); //+1 is safe because we've already checked toDistribution < distributions.length
        if (amount > 0) userBalanceChanged(account);
        return amount;
    }

    function claimDistributions(address[] calldata accounts) external {

        _createDistributionIfReady();
        for (uint256 i=0; i < accounts.length; i++){
            uint256 amount = _updateUserBalance(accounts[i], distributions.length);
            if (amount > 0) userBalanceChanged(accounts[i]);
        }
    }

    function claimDistributions(address[] calldata accounts, uint256 toDistribution) external {

        require(toDistribution < distributions.length, "DistributionToken: lastDistribution too hight");
        for (uint256 i=0; i < accounts.length; i++){
            uint256 amount = _updateUserBalance(accounts[i], toDistribution+1);
            if (amount > 0) userBalanceChanged(accounts[i]);
        }
    }

    function fullBalanceOf(address account) public view returns(uint256){

        if (account == address(this)) return 0;  //Token itself only holds tokens for others
        uint256 distributionBalance = distributionBalanceOf(account);
        uint256 unclaimed = calculateClaimAmount(account);
        return distributionBalance.add(unclaimed);
    }

    function calculateUnclaimedDistributions(address account) public view returns(uint256) {

        return calculateClaimAmount(account);
    }

    function calculateDistributedAmount(uint256 fromDistribution, uint256 toDistribution, uint256 initialBalance) public view returns(uint256) {

        require(fromDistribution < toDistribution, "DistributionToken: startDistribution is too high");
        require(toDistribution <= distributions.length, "DistributionToken: nextDistribution is too high");
        return _calculateDistributedAmount(fromDistribution, toDistribution, initialBalance);
    }

    function nextDistribution() public view returns(uint256){

        return distributions.length;
    }

    function distributionBalanceOf(address account) public view returns(uint256) {

        return balanceOf(account);
    }

    function distributionTotalSupply() public view returns(uint256){

        return totalSupply();
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        _createDistributionIfReady();
        _updateUserBalance(sender);
        _updateUserBalance(recipient);
        super._transfer(sender, recipient, amount);
        userBalanceChanged(sender);
        userBalanceChanged(recipient);
    }

    function _mint(address account, uint256 amount) internal {

        _createDistributionIfReady();
        _updateUserBalance(account);
        super._mint(account, amount);
        userBalanceChanged(account);
    }
    
    function _burn(address account, uint256 amount) internal {

        _createDistributionIfReady();
        _updateUserBalance(account);
        super._burn(account, amount);
        userBalanceChanged(account);
    }

    function _updateUserBalance(address account) internal returns(uint256) {

        return _updateUserBalance(account, distributions.length);
    }

    function _updateUserBalance(address account, uint256 toDistribution) internal returns(uint256) {

        uint256 fromDistribution = nextDistributions[account];
        if (fromDistribution >= toDistribution) return 0;
        uint256 distributionAmount = calculateClaimAmount(account, toDistribution);
        nextDistributions[account] = toDistribution;
        if (distributionAmount == 0) return 0;
        super._transfer(address(this), account, distributionAmount);
        emit DistributionsClaimed(account, distributionAmount, fromDistribution, toDistribution);
        return distributionAmount;
    }

    function _createDistributionIfReady() internal {

        if (!isReadyForDistribution()) return;
        _createDistribution();
    }
    
    function _createDistribution() internal {

        uint256 currentTotalSupply = distributionTotalSupply();
        distributions.push(Distribution({
            amount:distributionAccumulator,
            totalSupply: currentTotalSupply
        }));
        super._mint(address(this), distributionAccumulator); //Use super because we overloaded _mint in this contract and need old behaviour
        emit DistributionCreated(distributionAccumulator, currentTotalSupply);

        distributionAccumulator = 0;
        nextDistributionTimestamp = now.sub(now % DISTRIBUTION_AGGREGATION_PERIOD).add(DISTRIBUTION_AGGREGATION_PERIOD);
    }

    function userBalanceChanged(address /*account*/) internal {

    }

    function calculateClaimAmount(address account) internal view returns(uint256) {

        if (nextDistributions[account] >= distributions.length) return 0;
        return calculateClaimAmount(account, distributions.length);
    }

    function calculateClaimAmount(address account, uint256 toDistribution) internal view returns(uint256) {

        assert(toDistribution <= distributions.length);
        return _calculateDistributedAmount(nextDistributions[account], toDistribution, distributionBalanceOf(account));
    }

    function _calculateDistributedAmount(uint256 fromDistribution, uint256 toDistribution, uint256 initialBalance) internal view returns(uint256) {

        uint256 next = fromDistribution;
        uint256 balance = initialBalance;
        if (initialBalance == 0) return 0;
        while (next < toDistribution) {
            uint256 da = balance.mul(distributions[next].amount).div(distributions[next].totalSupply);
            balance = balance.add(da);
            next++;
        }
        return balance.sub(initialBalance);
    }

    function isReadyForDistribution() internal view returns(bool) {

        return (distributionAccumulator > 0) && (now >= nextDistributionTimestamp);
    }
}

contract PToken is Module, IPToken, ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable, DistributionToken {



    function initialize(address _pool) public initializer {

        Module.initialize(_pool);
        ERC20Detailed.initialize("Akropolis Sparta Pool Token", "ASPT", 18);
        ERC20Mintable.initialize(_msgSender());
    }

    function transfer(address to, uint256 value) public returns (bool) {

        address funds = getModuleAddress(MODULE_FUNDS);
        requireAllowedParties(_msgSender(), to, funds);
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        address funds = getModuleAddress(MODULE_FUNDS);
        if (_msgSender() == funds) {
            _transfer(from, to, value);
            return true;
        } else {
            requireAllowedParties(from, to, funds);
            return super.transferFrom(from, to, value);
        }
    }

    function burnFrom(address account, uint256 amount) public {

        address funds = getModuleAddress(MODULE_FUNDS);
        if (_msgSender() == funds) {
            _burn(account, amount);
        } else {
            super.burnFrom(account, amount);
        }
    }

    function distributionBalanceOf(address account) public view returns(uint256) {

        IFundsModule funds = fundsModule();
        if (account == address(funds)) {
            return 0; //FundsModule itself does not receive distributions
        }
        uint256 fundsBalance = funds.pBalanceOf(account);
        return super.distributionBalanceOf(account).add(fundsBalance);
    }

    function distributionTotalSupply() public view returns(uint256){

        IFundsModule funds = fundsModule();
        uint256 fullSupply = super.distributionTotalSupply();
        uint256 locked = funds.pBalanceOf(address(funds));
        return fullSupply.sub(locked);
    }

    function fundsModule() internal view returns(IFundsModule) {

        return IFundsModule(getModuleAddress(MODULE_FUNDS));
    }

    function requireAllowedParties(address from, address to, address funds) private pure{

        require(funds == from || funds == to, "PToken: only transfers to/from FundsModule allowed");
    }
}