

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.12;

contract IVaultProtocol {

    event DepositToVault(address indexed _user, address indexed _token, uint256 _amount);
    event WithdrawFromVault(address indexed _user, address indexed _token, uint256 _amount);
    event WithdrawRequestCreated(address indexed _user, address indexed _token, uint256 _amount);
    event DepositByOperator(uint256 _amount);
    event WithdrawByOperator(uint256 _amount);
    event WithdrawRequestsResolved(uint256 _totalDeposit, uint256 _totalWithdraw);
    event StrategyRegistered(address indexed _vault, address indexed _strategy, string _id);

    event Claimed(address indexed _vault, address indexed _user, address _token, uint256 _amount);
    event DepositsCleared(address indexed _vault);
    event RequestsCleared(address indexed _vault);


    function registerStrategy(address _strategy) external;


    function depositToVault(address _user, address _token, uint256 _amount) external;

    function depositToVault(address _user, address[] calldata  _tokens, uint256[] calldata _amounts) external;


    function withdrawFromVault(address _user, address _token, uint256 _amount) external;

    function withdrawFromVault(address _user, address[] calldata  _tokens, uint256[] calldata _amounts) external;


    function operatorAction(address _strategy) external returns(uint256, uint256);

    function operatorActionOneCoin(address _strategy, address _token) external returns(uint256, uint256);

    function clearOnHoldDeposits() external;

    function clearWithdrawRequests() external;

    function setRemainder(uint256 _amount, uint256 _index) external;


    function quickWithdraw(address _user, address[] calldata _tokens, uint256[] calldata _amounts) external;

    function quickWithdrawStrategy() external view returns(address);


    function claimRequested(address _user) external;


    function normalizedBalance() external returns(uint256);

    function normalizedBalance(address _strategy) external returns(uint256);

    function normalizedVaultBalance() external view returns(uint256);


    function supportedTokens() external view returns(address[] memory);

    function supportedTokensCount() external view returns(uint256);


    function isStrategyRegistered(address _strategy) external view returns(bool);

    function registeredStrategies() external view returns(address[] memory);


    function isTokenRegistered(address _token) external view returns (bool);

    function tokenRegisteredInd(address _token) external view returns(uint256);


    function totalClaimableAmount(address _token) external view returns (uint256);

    function claimableAmount(address _user, address _token) external view returns (uint256);


    function amountOnHold(address _user, address _token) external view returns (uint256);


    function amountRequested(address _user, address _token) external view returns (uint256);

}


pragma solidity >=0.4.24 <0.7.0;


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


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;





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


pragma solidity ^0.5.0;



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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




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


pragma solidity ^0.5.0;




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


pragma solidity ^0.5.0;




contract ERC20Burnable is Initializable, Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.12;

interface IPoolTokenBalanceChangeRecipient {

    function poolTokenBalanceChanged(address user) external; 

}


pragma solidity ^0.5.0;



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


pragma solidity ^0.5.12;




contract Base is Initializable, Context, Ownable {

    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {

        Ownable.initialize(_msgSender());
    }

}


pragma solidity ^0.5.12;

contract ModuleNames {

    string internal constant MODULE_ACCESS            = "access";
    string internal constant MODULE_SAVINGS           = "savings";
    string internal constant MODULE_INVESTING         = "investing";
    string internal constant MODULE_STAKING_AKRO      = "staking";
    string internal constant MODULE_STAKING_ADEL      = "stakingAdel";
    string internal constant MODULE_DCA               = "dca";
    string internal constant MODULE_REWARD            = "reward";
    string internal constant MODULE_REWARD_DISTR      = "rewardDistributions";
    string internal constant MODULE_VAULT             = "vault";

    string internal constant TOKEN_AKRO               = "akro";    
    string internal constant TOKEN_ADEL               = "adel";    

    string internal constant CONTRACT_RAY             = "ray";
}


pragma solidity ^0.5.12;



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


pragma solidity ^0.5.12;




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

        require(toDistribution <= distributions.length, "DistributionToken: lastDistribution too hight");
        require(nextDistributions[account] < toDistribution, "DistributionToken: no distributions to claim");
        uint256 amount = _updateUserBalance(account, toDistribution);
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

        require(toDistribution <= distributions.length, "DistributionToken: lastDistribution too hight");
        for (uint256 i=0; i < accounts.length; i++){
            uint256 amount = _updateUserBalance(accounts[i], toDistribution);
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
        if (distributionAmount == 0) return 0;
        nextDistributions[account] = toDistribution;
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


pragma solidity ^0.5.12;








contract PoolToken is Module, ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable, DistributionToken {


    bool allowTransfers;

    function initialize(address _pool, string memory poolName, string memory poolSymbol) public initializer {

        Module.initialize(_pool);
        ERC20Detailed.initialize(poolName, poolSymbol, 18);
        ERC20Mintable.initialize(_msgSender());
    }

    function setAllowTransfers(bool _allowTransfers) public onlyOwner {

        allowTransfers = _allowTransfers;
    }

    function burnFrom(address from, uint256 value) public {

        if (isMinter(_msgSender())) {
            _burn(from, value);
        }else{
            super.burnFrom(from, value);
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        if( !allowTransfers && 
            (sender != address(this)) //transfers from *this* used for distributions
        ){
            revert("PoolToken: transfers between users disabled");
        }
        super._transfer(sender, recipient, amount);
    } 

    function userBalanceChanged(address account) internal {

        IPoolTokenBalanceChangeRecipient rewardDistrModule = IPoolTokenBalanceChangeRecipient(getModuleAddress(MODULE_REWARD_DISTR));
        rewardDistrModule.poolTokenBalanceChanged(account);
    }

    function distributionBalanceOf(address account) public view returns(uint256) {

        return (account == address(this))?0:super.distributionBalanceOf(account);
    }

    function distributionTotalSupply() public view returns(uint256) {

        return super.distributionTotalSupply().sub(balanceOf(address(this))); 
    }

}


pragma solidity ^0.5.12;

interface IOperableToken {

    function increaseOnHoldValue(address _user, uint256 _amount) external;

    function decreaseOnHoldValue(address _user, uint256 _amount) external;

    function onHoldBalanceOf(address _user) external view returns (uint256);

}


pragma solidity ^0.5.12;



contract VaultPoolToken is PoolToken, IOperableToken {


    uint256 internal toBeMinted;

    mapping(address => uint256) internal onHoldAmount;
    uint256 totalOnHold;

    function _mint(address account, uint256 amount) internal {

        _createDistributionIfReady();
        toBeMinted = amount;
        _updateUserBalance(account);
        toBeMinted = 0;
        ERC20._mint(account, amount);
        userBalanceChanged(account);
    }

    function increaseOnHoldValue(address _user, uint256 _amount) public onlyMinter {

        onHoldAmount[_user] = onHoldAmount[_user].add(_amount);
        totalOnHold = totalOnHold.add(_amount);
    }

    function decreaseOnHoldValue(address _user, uint256 _amount) public onlyMinter {

        if (onHoldAmount[_user] >= _amount) {
            _updateUserBalance(_user);

            onHoldAmount[_user] = onHoldAmount[_user].sub(_amount);
            if (distributions.length > 0 && nextDistributions[_user] < distributions.length) {
                nextDistributions[_user] = distributions.length;
            }
            totalOnHold = totalOnHold.sub(_amount);

            userBalanceChanged(_user);
        }
    }

    function onHoldBalanceOf(address _user) public view returns (uint256) {

        return onHoldAmount[_user];
    }


    function fullBalanceOf(address account) public view returns(uint256){

        if (account == address(this)) return 0;  //Token itself only holds tokens for others
        uint256 unclaimed = calculateClaimAmount(account);
        return balanceOf(account).add(unclaimed);
    }

    function distributionBalanceOf(address account) public view returns(uint256) {

        if (balanceOf(account).add(toBeMinted) <= onHoldAmount[account])
            return 0;
        return balanceOf(account).add(toBeMinted).sub(onHoldAmount[account]);
    }

    function distributionTotalSupply() public view returns(uint256){

        return totalSupply().sub(totalOnHold);
    }

    function userBalanceChanged(address account) internal {

    }
}


pragma solidity ^0.5.12;



contract IVaultSavings {

    event VaultRegistered(address protocol, address poolToken);
    event YieldDistribution(address indexed poolToken, uint256 amount);
    event DepositToken(address indexed protocol, address indexed token, uint256 dnAmount);
    event Deposit(address indexed protocol, address indexed user, uint256 nAmount, uint256 nFee);
    event WithdrawToken(address indexed protocol, address indexed token, uint256 dnAmount);
    event Withdraw(address indexed protocol, address indexed user, uint256 nAmount, uint256 nFee);

    function deposit(address[] calldata _protocols, address[] calldata _tokens, uint256[] calldata _dnAmounts) external returns(uint256[] memory);

    function deposit(address _protocol, address[] calldata _tokens, uint256[] calldata _dnAmounts) external returns(uint256);

    function withdraw(address _vaultProtocol, address[] calldata _tokens, uint256[] calldata _amounts, bool isQuick) external returns(uint256);


    function poolTokenByProtocol(address _protocol) external view returns(address);

    function supportedVaults() public view returns(address[] memory);

    function isVaultRegistered(address _protocol) public view returns(bool);


    function registerVault(IVaultProtocol protocol, VaultPoolToken poolToken) external;


    function handleOperatorActions(address _vaultProtocol, address _strategy, address _token) external;


    function claimAllRequested(address _vaultProtocol) external;

}


pragma solidity ^0.5.12;

contract IDefiStrategy { 

    function handleDeposit(address token, uint256 amount) external;


    function handleDeposit(address[] calldata tokens, uint256[] calldata amounts) external;


    function withdraw(address beneficiary, address token, uint256 amount) external;


    function withdraw(address beneficiary, uint256[] calldata amounts) external;


    function setVault(address _vault) external;


    function normalizedBalance() external returns(uint256);

    function balanceOf(address token) external returns(uint256);

    function balanceOfAll() external returns(uint256[] memory balances);


    function getStrategyId() external view returns(string memory);

}


pragma solidity ^0.5.12;




contract DefiOperatorRole is Initializable, Context {

    using Roles for Roles.Role;

    event DefiOperatorAdded(address indexed account);
    event DefiOperatorRemoved(address indexed account);

    Roles.Role private _operators;

    function initialize(address sender) public initializer {

        if (!isDefiOperator(sender)) {
            _addDefiOperator(sender);
        }
    }

    modifier onlyDefiOperator() {

        require(isDefiOperator(_msgSender()), "DefiOperatorRole: caller does not have the DefiOperator role");
        _;
    }

    function addDefiOperator(address account) public onlyDefiOperator {

        _addDefiOperator(account);
    }

    function renounceDefiOperator() public {

        _removeDefiOperator(_msgSender());
    }

    function isDefiOperator(address account) public view returns (bool) {

        return _operators.has(account);
    }

    function _addDefiOperator(address account) internal {

        _operators.add(account);
        emit DefiOperatorAdded(account);
    }

    function _removeDefiOperator(address account) internal {

        _operators.remove(account);
        emit DefiOperatorRemoved(account);
    }

}


pragma solidity ^0.5.12;



library CalcUtils {

     using SafeMath for uint256;

    function normalizeAmount(address coin, uint256 amount) internal view returns(uint256) {

        uint8 decimals = ERC20Detailed(coin).decimals();
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.div(uint256(10)**(decimals-18));
        } else if (decimals < 18) {
            return amount.mul(uint256(10)**(18 - decimals));
        }
    }

    function denormalizeAmount(address coin, uint256 amount) internal view returns(uint256) {

        uint256 decimals = ERC20Detailed(coin).decimals();
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.mul(uint256(10)**(decimals-18));
        } else if (decimals < 18) {
            return amount.div(uint256(10)**(18 - decimals));
        }
    }

}


pragma solidity ^0.5.12;











contract VaultProtocol is Module, IVaultProtocol, DefiOperatorRole {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address[] internal strategies;
    address[] internal registeredVaultTokens;

    mapping(address => uint256[]) internal balancesOnHold;
    address[] internal usersDeposited; //for operator's conveniency
    uint256[] lastProcessedDeposits;

    mapping(address => uint256[]) internal balancesRequested;
    address[] internal usersRequested; //for operator's conveniency
    uint256[] lastProcessedRequests;

    mapping(address => uint256[]) internal balancesToClaim;
    uint256[] internal claimableTokens;

    address public quickStrategy;

    bool internal availableEnabled;
    uint256[] internal remainders;

    function initialize(address _pool, address[] memory tokens) public initializer {

        Module.initialize(_pool);
        DefiOperatorRole.initialize(_msgSender());

        registeredVaultTokens = new address[](tokens.length);
        claimableTokens = new uint256[](tokens.length);
        lastProcessedRequests = new uint256[](tokens.length);
        lastProcessedDeposits = new uint256[](tokens.length);

        remainders = new uint256[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            registeredVaultTokens[i] = tokens[i];
        }

        availableEnabled = false;
    }

    function registerStrategy(address _strategy) public onlyDefiOperator {

        strategies.push(_strategy);
        IDefiStrategy(_strategy).setVault(address(this));

        emit StrategyRegistered(address(this), _strategy, IDefiStrategy(_strategy).getStrategyId());
    }

    function setQuickWithdrawStrategy(address _strategy) public onlyDefiOperator {

        require(isStrategyRegistered(_strategy), "Strategy is not registered");
        quickStrategy = _strategy;
    }

    function setRemainder(uint256 _amount, uint256 _index) public onlyDefiOperator {

        require(_index < supportedTokensCount());
        remainders[_index] = _amount;
    }

    function setAvailableEnabled(bool value) public onlyDefiOperator {

        availableEnabled = value;
    }

    function depositToVault(address _user, address _token, uint256 _amount) public onlyDefiOperator {

        require(_user != address(0), "Incorrect user address");
        require(_token != address(0), "Incorrect token address");
        require(_amount > 0, "No tokens to be deposited");

        uint256 ind;
        bool hasToken;

        (hasToken, ind) = tokenInfo(_token, registeredVaultTokens);
        require(hasToken, "Token is not registered in the vault");


        if (balancesOnHold[_user].length == 0) {
            balancesOnHold[_user] = new uint256[](supportedTokensCount());
        }
        usersDeposited.push(_user);
        balancesOnHold[_user][ind] = balancesOnHold[_user][ind].add(_amount);

        IVaultSavings vaultSavings = IVaultSavings(getModuleAddress(MODULE_VAULT));
        address vaultPoolToken = vaultSavings.poolTokenByProtocol(address(this));
        IOperableToken(vaultPoolToken).increaseOnHoldValue(_user, CalcUtils.normalizeAmount(_token, _amount));

        emit DepositToVault(_user, _token, _amount);
    }

    function depositToVault(address _user, address[] memory  _tokens, uint256[] memory _amounts) public onlyDefiOperator {

        require(_tokens.length > 0, "No tokens to be deposited");
        require(_tokens.length == _amounts.length, "Incorrect amounts");

        for (uint256 i = 0; i < _tokens.length; i++) {
            depositToVault(_user, _tokens[i], _amounts[i]);
        }
    }

    function withdrawFromVault(address _user, address _token, uint256 _amount) public onlyDefiOperator {

        require(_user != address(0), "Incorrect user address");
        require(_token != address(0), "Incorrect token address");

        if (_amount == 0) return;

        uint256 indReg;
        bool hasToken;

        (hasToken, indReg) = tokenInfo(_token, registeredVaultTokens);
        require(hasToken, "Token is not registered in the vault");


        if (availableEnabled && (IERC20(_token).balanceOf(address(this)).sub(claimableTokens[indReg]) >= _amount.add(remainders[indReg]))) {
            decreaseOnHoldDeposit(_user, _token, _amount);

            IERC20(_token).safeTransfer(_user, _amount);

            emit WithdrawFromVault(_user, _token, _amount);
        }
        else {
            if (balancesRequested[_user].length == 0) {
                balancesRequested[_user] = new uint256[](supportedTokensCount());
            }
            usersRequested.push(_user);
            balancesRequested[_user][indReg] = balancesRequested[_user][indReg].add(_amount);

            decreaseOnHoldDeposit(_user, _token, _amount);

            emit WithdrawRequestCreated(_user, _token, _amount);
        }
    }

    function withdrawFromVault(address _user, address[] memory  _tokens, uint256[] memory _amounts) public onlyDefiOperator {

        require(_tokens.length > 0, "No tokens to be withdrawn");
        require(_tokens.length == _amounts.length, "Incorrect amounts");

        for (uint256 i = 0; i < _tokens.length; i++) {
            withdrawFromVault(_user, _tokens[i], _amounts[i]);
        }
    }

        function quickWithdraw(address _user, address[] memory _tokens, uint256[] memory _amounts) public onlyDefiOperator {

        require(quickStrategy != address(0), "No strategy for quick withdraw");
        require(_tokens.length == 1 || _amounts.length == supportedTokensCount(), "Incorrect number of tokens");

        if (_tokens.length == 1) {
            IDefiStrategy(quickStrategy).withdraw(_user, _tokens[0], _amounts[0]);
        }
        else {
            IDefiStrategy(quickStrategy).withdraw(_user, _amounts);
        }
    }

    function claimRequested(address _user) public {

        if (balancesToClaim[_user].length == 0) return;
        for (uint256 i = 0; i < balancesToClaim[_user].length; i++) {
            address token = registeredVaultTokens[i];
            uint256 amount = balancesToClaim[_user][i];

            if (amount > 0) {
                IERC20(token).safeTransfer(_user, amount);
                claimableTokens[i] = claimableTokens[i].sub(amount);
                emit Claimed(address(this), _user, token, amount);
            }
        }
        delete balancesToClaim[_user];
    }

    function operatorAction(address _strategy) public onlyDefiOperator returns(uint256, uint256) {

        require(isStrategyRegistered(_strategy), "Strategy is not registered");

        processOnHoldDeposit();

        address _user;
        uint256[] memory withdrawAmounts = new uint256[](registeredVaultTokens.length);
        uint256 lastProcessedRequest = minProcessed(lastProcessedRequests);
        uint256 amountToWithdraw;

        for (uint256 i = lastProcessedRequest; i < usersRequested.length; i++) {
            _user = usersRequested[i];
            for (uint256 j = 0; j < balancesRequested[_user].length; j++) {
                amountToWithdraw = requestToClaim(_user, j);
                if (amountToWithdraw > 0) {
                    withdrawAmounts[j] = withdrawAmounts[j].add(amountToWithdraw);
                }
            }
        }
        if (usersRequested.length > lastProcessedRequest) {
            setProcessed(lastProcessedRequests, usersRequested.length);
        }

        uint256[] memory depositAmounts = new uint256[](registeredVaultTokens.length);
        uint256 totalDeposit = 0;
        uint256 totalWithdraw = 0;
        for (uint256 i = 0; i < registeredVaultTokens.length; i++) {
            depositAmounts[i] = IERC20(registeredVaultTokens[i]).balanceOf(address(this)).sub(claimableTokens[i]);
            depositAmounts[i] = handleRemainders(depositAmounts[i], i);

            IERC20(registeredVaultTokens[i]).safeApprove(address(_strategy), depositAmounts[i]);

            totalDeposit = totalDeposit.add(CalcUtils.normalizeAmount(registeredVaultTokens[i], depositAmounts[i]));

            totalWithdraw = totalWithdraw.add(CalcUtils.normalizeAmount(registeredVaultTokens[i], withdrawAmounts[i]));
        }
        if (totalDeposit > 0) {
            IDefiStrategy(_strategy).handleDeposit(registeredVaultTokens, depositAmounts);
            emit DepositByOperator(totalDeposit);
        }

        if (totalWithdraw > 0) {
            IDefiStrategy(_strategy).withdraw(address(this), withdrawAmounts);
            emit WithdrawByOperator(totalWithdraw);
            for (uint256 i = 0; i < claimableTokens.length; i++) {
                claimableTokens[i] = claimableTokens[i].add(withdrawAmounts[i]);
            }
        }
        emit WithdrawRequestsResolved(totalDeposit, totalWithdraw);
        return (totalDeposit, totalWithdraw);
    }

    function operatorActionOneCoin(address _strategy, address _token) public onlyDefiOperator returns(uint256, uint256) {

        require(isStrategyRegistered(_strategy), "Strategy is not registered");

        bool isReg;
        uint256 ind;

        (isReg, ind) = tokenInfo(_token, registeredVaultTokens);
        require(isReg, "Token is not supported");

        processOnHoldDeposit(ind);

        address _user;
        uint256 totalWithdraw = 0;
        uint256 amountToWithdraw;
        for (uint256 i = lastProcessedRequests[ind]; i < usersRequested.length; i++) {
            _user = usersRequested[i];

            amountToWithdraw = requestToClaim(_user, ind);
            
            if (amountToWithdraw > 0) {
                totalWithdraw = totalWithdraw.add(amountToWithdraw);
            }
        }
        lastProcessedRequests[ind] = usersRequested.length;

        uint256 totalDeposit = IERC20(_token).balanceOf(address(this)).sub(claimableTokens[ind]);
        totalDeposit = handleRemainders(totalDeposit, ind);

        IERC20(_token).safeApprove(address(_strategy), totalDeposit);

        if (totalDeposit > 0) {
            IDefiStrategy(_strategy).handleDeposit(_token, totalDeposit);
            emit DepositByOperator(totalDeposit);
        }

        if (totalWithdraw > 0) {
            IDefiStrategy(_strategy).withdraw(address(this), _token, totalWithdraw);
            emit WithdrawByOperator(totalWithdraw);
            claimableTokens[ind] = claimableTokens[ind].add(totalWithdraw);
        }
        emit WithdrawRequestsResolved(totalDeposit, totalWithdraw);
        return (CalcUtils.normalizeAmount(registeredVaultTokens[ind], totalDeposit),
                CalcUtils.normalizeAmount(registeredVaultTokens[ind], totalWithdraw));
    }

    function clearOnHoldDeposits() public onlyDefiOperator {

        require(minProcessed(lastProcessedDeposits) == usersDeposited.length, "There are unprocessed deposits");

        address _user;
        for (uint256 i = 0; i < usersDeposited.length; i++) {
            _user = usersDeposited[i];
            balancesOnHold[_user].length = 0;
        }
        delete usersDeposited;
        setProcessed(lastProcessedDeposits, 0);
        emit DepositsCleared(address(this));
    }

    function clearWithdrawRequests() public onlyDefiOperator {

        require(minProcessed(lastProcessedRequests) == usersRequested.length, "There are unprocessed requests");

        address _user;
        for (uint256 i = 0; i < usersRequested.length; i++) {
            _user = usersRequested[i];
            balancesRequested[_user].length = 0;
        }
        delete usersRequested;
        setProcessed(lastProcessedRequests, 0);
        emit RequestsCleared(address(this));
    }


    function normalizedBalance(address _strategy) public returns(uint256) {

        require(isStrategyRegistered(_strategy), "Strategy is not registered");
        return IDefiStrategy(_strategy).normalizedBalance();
    }

    function normalizedBalance() public returns(uint256) {

        uint256 total;
        for (uint256 i = 0; i < strategies.length; i++) {
            total = total.add(IDefiStrategy(strategies[i]).normalizedBalance());
        }
        return total;
    }

    function normalizedVaultBalance() public view returns(uint256) {

        uint256 summ;
        for (uint256 i=0; i < registeredVaultTokens.length; i++) {
            uint256 balance = IERC20(registeredVaultTokens[i]).balanceOf(address(this));
            summ = summ.add(CalcUtils.normalizeAmount(registeredVaultTokens[i], balance));
        }
        return summ;
    }

    function totalClaimableAmount(address _token) public view returns (uint256) {

        uint256 indReg = tokenRegisteredInd(_token);

        return claimableTokens[indReg];
    }

    function claimableAmount(address _user, address _token) public view returns (uint256) {

        return tokenAmount(balancesToClaim, _user, _token);
    }

    function amountOnHold(address _user, address _token) public view returns (uint256) {

        return tokenAmount(balancesOnHold, _user, _token);
    }

    function amountRequested(address _user, address _token) public view returns (uint256) {

        return tokenAmount(balancesRequested, _user, _token);
    }

    function quickWithdrawStrategy() public view returns(address) {

        return quickStrategy;
    }

    function getRemainder(uint256 _index) public  view returns(uint256) {

        require(_index < supportedTokensCount());
        return remainders[_index];
    }

    function supportedTokens() public view returns(address[] memory) {

        return registeredVaultTokens;
    }

    function supportedTokensCount() public view returns(uint256) {

        return registeredVaultTokens.length;
    }

    function isStrategyRegistered(address _strategy) public view returns(bool) {

        for (uint256 i = 0; i < strategies.length; i++) {
            if (strategies[i] == _strategy) {
                return true;
            }
        }
        return false;
    }

    function registeredStrategies() public view returns(address[] memory) {

        return strategies;
    }

    function isTokenRegistered(address _token) public view returns (bool) {

        bool isReg = false;
        for (uint i = 0; i < registeredVaultTokens.length; i++) {
            if (registeredVaultTokens[i] == _token) {
                isReg = true;
                break;
            }
        }
        return isReg;
    }

    function tokenRegisteredInd(address _token) public view returns (uint256) {

        uint256 ind = 0;
        for (uint i = 0; i < registeredVaultTokens.length; i++) {
            if (registeredVaultTokens[i] == _token) {
                ind = i;
                break;
            }
        }
        return ind;
    }

    function tokenAmount(mapping(address => uint256[]) storage _amounts, address _user, address _token) internal view returns(uint256) {

        uint256 ind = tokenRegisteredInd(_token);
        if (_amounts[_user].length == 0)
            return 0;
        else
            return _amounts[_user][ind];
    }

    function tokenInfo(address _token, address[] storage tokensArr) internal view returns (bool, uint256) {

        uint256 ind = 0;
        bool isToken = false;
        for (uint i = 0; i < tokensArr.length; i++) {
            if (tokensArr[i] == _token) {
                ind = i;
                isToken = true;
                break;
            }
        }
        return (isToken, ind);
    }

    function processOnHoldDeposit() internal {

        IVaultSavings vaultSavings = IVaultSavings(getModuleAddress(MODULE_VAULT));
        IOperableToken vaultPoolToken = IOperableToken(vaultSavings.poolTokenByProtocol(address(this)));

        address _user;
        uint256 lastProcessedDeposit = minProcessed(lastProcessedDeposits);
        for (uint256 i = lastProcessedDeposit; i < usersDeposited.length; i++) {
            _user = usersDeposited[i];
            for (uint256 j = 0; j < balancesOnHold[_user].length; j++) {
                if (balancesOnHold[_user][j] > 0) {
                    vaultPoolToken.decreaseOnHoldValue(_user, CalcUtils.normalizeAmount(registeredVaultTokens[j], balancesOnHold[_user][j]));
                    balancesOnHold[_user][j] = 0;
                }
            }
        }
        if (usersDeposited.length > lastProcessedDeposit) {
            setProcessed(lastProcessedDeposits, usersDeposited.length);
        }
    }

    function processOnHoldDeposit(uint256 coinNum) internal {

        require(coinNum < supportedTokensCount(), "Incorrect coin index");
        IVaultSavings vaultSavings = IVaultSavings(getModuleAddress(MODULE_VAULT));
        IOperableToken vaultPoolToken = IOperableToken(vaultSavings.poolTokenByProtocol(address(this)));

        address _user;
        for (uint256 i = lastProcessedDeposits[coinNum]; i < usersDeposited.length; i++) {
            _user = usersDeposited[i];
            if (balancesOnHold[_user][coinNum] > 0) {
                vaultPoolToken.decreaseOnHoldValue(_user, CalcUtils.normalizeAmount(registeredVaultTokens[coinNum], balancesOnHold[_user][coinNum]));
                balancesOnHold[_user][coinNum] = 0;
            }
        }
        if (usersDeposited.length > lastProcessedDeposits[coinNum])
            lastProcessedDeposits[coinNum] = usersDeposited.length;
    }

    function decreaseOnHoldDeposit(address _user, address _token, uint256 _amount) internal {

        uint256 ind = tokenRegisteredInd(_token);
        if (balancesOnHold[_user].length == 0 || balancesOnHold[_user][ind] == 0) return;

        IVaultSavings vaultSavings = IVaultSavings(getModuleAddress(MODULE_VAULT));
        IOperableToken vaultPoolToken = IOperableToken(vaultSavings.poolTokenByProtocol(address(this)));

        if (balancesOnHold[_user][ind] > _amount) {
            vaultPoolToken.decreaseOnHoldValue(_user, CalcUtils.normalizeAmount(registeredVaultTokens[ind], _amount));
            balancesOnHold[_user][ind] = balancesOnHold[_user][ind].sub(_amount);
        }
        else {
            vaultPoolToken.decreaseOnHoldValue(_user, CalcUtils.normalizeAmount(registeredVaultTokens[ind], balancesOnHold[_user][ind]));
            balancesOnHold[_user][ind] = 0;
        }
    }

    function addClaim(address _user, address _token, uint256 _amount) internal {

        uint256 ind = tokenRegisteredInd(_token);

        if (balancesToClaim[_user].length == 0) {
            balancesToClaim[_user] = new uint256[](supportedTokensCount());
        }
        balancesToClaim[_user][ind] = balancesToClaim[_user][ind].add(_amount);
    }

    function requestToClaim(address _user, uint256 _ind) internal returns(uint256) {

        uint256 amount = balancesRequested[_user][_ind];
        address token = registeredVaultTokens[_ind];
        uint256 amountToWithdraw;
        uint256 tokenBalance;
        if (amount > 0) {
            addClaim(_user, token, amount);
                    
            tokenBalance = IERC20(token).balanceOf(address(this)).sub(claimableTokens[_ind]);
            tokenBalance = handleRemainders(tokenBalance, _ind);

            if (tokenBalance >= amount) {
                claimableTokens[_ind] = claimableTokens[_ind].add(amount);
            }
            else {
                if (tokenBalance > 0) {
                    claimableTokens[_ind] = claimableTokens[_ind].add(tokenBalance);
                    amountToWithdraw = amount.sub(tokenBalance);
                }
                else {
                    amountToWithdraw = amount;
                }
            }

            balancesRequested[_user][_ind] = 0;
        }
        return amountToWithdraw;
    }

    function setProcessed(uint256[] storage processedValues, uint256 value) internal {

        for (uint256 i = 0; i < processedValues.length; i++) {
            processedValues[i] = value;
        }
    }

    function minProcessed(uint256[] storage processedValues) internal view returns(uint256) {

        uint256 min = processedValues[0];
        for (uint256 i = 1; i < processedValues.length; i++) {
            if (processedValues[i] < min) {
                min = processedValues[i];
            }
        }
        return min;
    }

    function handleRemainders(uint256 _amount, uint256 _ind) internal view returns(uint256) {

        if (_amount >= remainders[_ind]) {
            return _amount.sub(remainders[_ind]);
        }
        else {
            return 0;
        }
    }
}