

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

interface IPoolTokenBalanceChangeRecipient {

    function poolTokenBalanceChanged(address user) external; 

}


pragma solidity ^0.5.12;

interface IDefiProtocol {

    function handleDeposit(address token, uint256 amount) external;


    function handleDeposit(address[] calldata tokens, uint256[] calldata amounts) external;


    function withdraw(address beneficiary, address token, uint256 amount) external;


    function withdraw(address beneficiary, uint256[] calldata amounts) external;


    function claimRewards() external returns(address[] memory tokens, uint256[] memory amounts);


    function withdrawReward(address token, address user, uint256 amount) external;


    function balanceOf(address token) external returns(uint256);


    function balanceOfAll() external returns(uint256[] memory); 


    function optimalProportions() external returns(uint256[] memory);


    function normalizedBalance() external returns(uint256);


    function supportedTokens() external view returns(address[] memory);


    function supportedTokensCount() external view returns(uint256);


    function supportedRewardTokens() external view returns(address[] memory);


    function isSupportedRewardToken(address token) external view returns(bool);


    function canSwapToToken(address token) external view returns(bool);


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

interface IAccessModule {

    enum Operation {
        Deposit,
        Withdraw
    }
    
    function isOperationAllowed(Operation operation, address sender) external view returns(bool);

}


pragma solidity ^0.5.12;




contract AccessChecker is Module {

    modifier operationAllowed(IAccessModule.Operation operation) {

        IAccessModule am = IAccessModule(getModuleAddress(MODULE_ACCESS));
        require(am.isOperationAllowed(operation, _msgSender()), "AccessChecker: operation not allowed");
        _;
    }
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




contract CapperRole is Initializable, Context {

    using Roles for Roles.Role;

    event CapperAdded(address indexed account);
    event CapperRemoved(address indexed account);

    Roles.Role private _cappers;

    function initialize(address sender) public initializer {

        if (!isCapper(sender)) {
            _addCapper(sender);
        }
    }

    modifier onlyCapper() {

        require(isCapper(_msgSender()), "CapperRole: caller does not have the Capper role");
        _;
    }

    function isCapper(address account) public view returns (bool) {

        return _cappers.has(account);
    }

    function addCapper(address account) public onlyCapper {

        _addCapper(account);
    }

    function renounceCapper() public {

        _removeCapper(_msgSender());
    }

    function _addCapper(address account) internal {

        _cappers.add(account);
        emit CapperAdded(account);
    }

    function _removeCapper(address account) internal {

        _cappers.remove(account);
        emit CapperRemoved(account);
    }

    uint256[50] private ______gap;
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








contract RewardDistributions is Base, AccessChecker {

    using SafeMath for uint256;

    struct RewardTokenDistribution {
        address poolToken;                  // PoolToken which holders will receive reward
        uint256 totalShares;                // Total shares of PoolToken participating in this distribution
        address[] rewardTokens;             // List of reward tokens being distributed 
        mapping(address=>uint256) amounts; 
    }

    struct UserProtocolRewards {
        mapping(address=>uint256) amounts;  // Maps address of reward token to amount beeing distributed
    }
    struct RewardBalance {
        uint256 nextDistribution;
        mapping(address => uint256) shares;     // Maps PoolToken to amount of user shares participating in distributions
        mapping(address => UserProtocolRewards) rewardsByProtocol; //Maps PoolToken to ProtocolRewards struct (map of reward tokens to their balances);
    }

    RewardTokenDistribution[] rewardDistributions;
    mapping(address=>RewardBalance) rewardBalances; //Mapping users to their RewardBalance





    function rewardBalanceOf(address user, address poolToken, address[] memory rewardTokens) public view returns(uint256[] memory) {

        RewardBalance storage rb = rewardBalances[user];
        UserProtocolRewards storage upr = rb.rewardsByProtocol[poolToken];
        uint256[] memory balances = new uint256[](rewardTokens.length);
        uint256 i;
        for(i=0; i < rewardTokens.length; i++){
            balances[i] = upr.amounts[rewardTokens[i]];
        }
        uint256 next = rb.nextDistribution;
        while (next < rewardDistributions.length) {
            RewardTokenDistribution storage d = rewardDistributions[next];
            next++;

            uint256 sh = rb.shares[d.poolToken];
            if (sh == 0 || poolToken != d.poolToken) continue;
            for(i=0; i < rewardTokens.length; i++){
                uint256 distrAmount = d.amounts[rewardTokens[i]];
                balances[i] = balances[i].add(distrAmount.mul(sh).div(d.totalShares));
            }
        }
        return balances;
    }








}


pragma solidity ^0.5.12;











contract SavingsModule is Module, AccessChecker, RewardDistributions, CapperRole {

    uint256 constant MAX_UINT256 = uint256(-1);

    event ProtocolRegistered(address protocol, address poolToken);
    event YieldDistribution(address indexed poolToken, uint256 amount);
    event DepositToken(address indexed protocol, address indexed token, uint256 dnAmount);
    event Deposit(address indexed protocol, address indexed user, uint256 nAmount, uint256 nFee);
    event WithdrawToken(address indexed protocol, address indexed token, uint256 dnAmount);
    event Withdraw(address indexed protocol, address indexed user, uint256 nAmount, uint256 nFee);
    event UserCapEnabledChange(bool enabled);
    event UserCapChanged(address indexed protocol, address indexed user, uint256 newCap);
    event DefaultUserCapChanged(address indexed protocol, uint256 newCap);
    event ProtocolCapEnabledChange(bool enabled);
    event ProtocolCapChanged(address indexed protocol, uint256 newCap);
    event VipUserEnabledChange(bool enabled);
    event VipUserChanged(address indexed protocol, address indexed user, bool isVip);

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct ProtocolInfo {
        PoolToken poolToken;
        uint256 previousBalance;
        uint256 lastRewardDistribution;
        address[] supportedRewardTokens;
        mapping(address => uint256) userCap; //Limit of pool tokens which can be minted for a user during deposit
        uint256 withdrawAllSlippage;         //Allowed slippage for withdrawAll function in wei
        mapping(address=>bool) isVipUser;       
    }

    struct TokenData {
        uint8 decimals;
    }

    address[] registeredTokens;
    IDefiProtocol[] registeredProtocols;
    address[] registeredRewardTokens;
    mapping(address => TokenData) tokens;
    mapping(address => ProtocolInfo) protocols; //Mapping of protocol to data we need to calculate APY and do distributions
    mapping(address => address) poolTokenToProtocol;    //Mapping of pool tokens to protocols
    mapping(address => bool) private rewardTokenRegistered;     //marks registered reward tokens
    bool public userCapEnabled;
    bool public protocolCapEnabled;
    mapping(address=>uint256) public defaultUserCap;
    mapping(address=>uint256) public protocolCap;
    bool public vipUserEnabled;                         // Enable VIP user (overrides protocol cap)


    function initialize(address _pool) public initializer {

        Module.initialize(_pool);
        CapperRole.initialize(_msgSender());
    }

    function setUserCapEnabled(bool _userCapEnabled) public onlyCapper {

        userCapEnabled = _userCapEnabled;
        emit UserCapEnabledChange(userCapEnabled);
    }



    function setVipUserEnabled(bool _vipUserEnabled) public onlyCapper {

        vipUserEnabled = _vipUserEnabled;
        emit VipUserEnabledChange(_vipUserEnabled);
    }

    function setVipUser(address _protocol, address user, bool isVip) public onlyCapper {

        protocols[_protocol].isVipUser[user] = isVip;
        emit VipUserChanged(_protocol, user, isVip);
    }
    
    function setDefaultUserCap(address _protocol, uint256 cap) public onlyCapper {

        defaultUserCap[_protocol] = cap;
        emit DefaultUserCapChanged(_protocol, cap);
    }

    function setProtocolCapEnabled(bool _protocolCapEnabled) public onlyCapper {

        protocolCapEnabled = _protocolCapEnabled;
        emit ProtocolCapEnabledChange(protocolCapEnabled);
    }

    function setProtocolCap(address _protocol, uint256 cap) public onlyCapper {

        protocolCap[_protocol] = cap;
        emit ProtocolCapChanged(_protocol, cap);
    }

    function setWithdrawAllSlippage(address _protocol, uint256 slippageWei) public onlyOwner {

        protocols[_protocol].withdrawAllSlippage = slippageWei;
    }

    function registerProtocol(IDefiProtocol protocol, PoolToken poolToken) public onlyOwner {

        uint256 i;
        for (i = 0; i < registeredProtocols.length; i++){
            if (address(registeredProtocols[i]) == address(protocol)) revert("SavingsModule: protocol already registered");
        }
        registeredProtocols.push(protocol);
        protocols[address(protocol)] = ProtocolInfo({
            poolToken: poolToken,
            previousBalance: protocol.normalizedBalance(),
            lastRewardDistribution: 0,
            supportedRewardTokens: protocol.supportedRewardTokens(),
            withdrawAllSlippage:0
        });
        for(i=0; i < protocols[address(protocol)].supportedRewardTokens.length; i++) {
            address rtkn = protocols[address(protocol)].supportedRewardTokens[i];
            if(!rewardTokenRegistered[rtkn]){
                rewardTokenRegistered[rtkn] = true;
                registeredRewardTokens.push(rtkn);
            }
        }
        poolTokenToProtocol[address(poolToken)] = address(protocol);
        address[] memory supportedTokens = protocol.supportedTokens();
        for (i = 0; i < supportedTokens.length; i++) {
            address tkn = supportedTokens[i];
            if (!isTokenRegistered(tkn)){
                registeredTokens.push(tkn);
                tokens[tkn].decimals = ERC20Detailed(tkn).decimals();
            }
        }
        uint256 normalizedBalance= protocols[address(protocol)].previousBalance;
        if(normalizedBalance > 0) {
            uint256 ts = poolToken.totalSupply();
            if(ts < normalizedBalance) {
                poolToken.mint(_msgSender(), normalizedBalance.sub(ts));
            }
        }
        emit ProtocolRegistered(address(protocol), address(poolToken));
    }

    function updateProtocolRewardTokens(IDefiProtocol protocol) public onlyOwner {

        ProtocolInfo storage pi = protocols[address(protocol)];
        pi.supportedRewardTokens = protocol.supportedRewardTokens();
        for(uint256 i=0; i < pi.supportedRewardTokens.length; i++) {
            address rtkn = pi.supportedRewardTokens[i];
            if(!rewardTokenRegistered[rtkn]){
                rewardTokenRegistered[rtkn] = true;
                registeredRewardTokens.push(rtkn);
            }
        }
        emit ProtocolRegistered(address(protocol), poolTokenByProtocol(address(protocol)));
    }



            


    function deposit(address[] memory _protocols, address[] memory _tokens, uint256[] memory _dnAmounts) 
    public operationAllowed(IAccessModule.Operation.Deposit) 
    returns(uint256[] memory) 
    {

        require(_protocols.length == _tokens.length && _tokens.length == _dnAmounts.length, "SavingsModule: size of arrays does not match");
        uint256[] memory ptAmounts = new uint256[](_protocols.length);
        for (uint256 i=0; i < _protocols.length; i++) {
            address[] memory tkns = new address[](1);
            tkns[0] = _tokens[i];
            uint256[] memory amnts = new uint256[](1);
            amnts[0] = _dnAmounts[i];
            ptAmounts[i] = deposit(_protocols[i], tkns, amnts);
        }
        return ptAmounts;
    }

    function deposit(address _protocol, address[] memory _tokens, uint256[] memory _dnAmounts)
    public operationAllowed(IAccessModule.Operation.Deposit)
    returns(uint256) 
    {


        uint256 nAmount;
        for (uint256 i=0; i < _tokens.length; i++) {
            nAmount = nAmount.add(normalizeTokenAmount(_tokens[i], _dnAmounts[i]));
        }

        uint256 nBalanceBefore = distributeYieldInternal(_protocol);
        depositToProtocol(_protocol, _tokens, _dnAmounts);
        uint256 nBalanceAfter = updateProtocolBalance(_protocol);

        PoolToken poolToken = PoolToken(protocols[_protocol].poolToken);
        uint256 nDeposit = nBalanceAfter.sub(nBalanceBefore);

        uint256 cap;
        if(userCapEnabled) {
            cap = userCap(_protocol, _msgSender());
        }

        uint256 fee;
        if(nAmount > nDeposit) {
            fee = nAmount - nDeposit;
            poolToken.mint(_msgSender(), nDeposit);
        } else {
            fee = 0;
            poolToken.mint(_msgSender(), nAmount);
            uint256 yield = nDeposit - nAmount;
            if (yield > 0) {
                createYieldDistribution(poolToken, yield);
            }
        }

        if(protocolCapEnabled) {
            if( !(vipUserEnabled && protocols[_protocol].isVipUser[_msgSender()]) ) {
                uint256 ptTS = poolToken.totalSupply();
                require(ptTS <= protocolCap[_protocol], "SavingsModule: deposit exeeds protocols cap");
            }
        }

        if(userCapEnabled) {
            require(cap >= nAmount.sub(fee), "SavingsModule: deposit exeeds user cap");
        }

        emit Deposit(_protocol, _msgSender(), nAmount, fee);
        return nDeposit;
    }

    function depositToProtocol(address _protocol, address[] memory _tokens, uint256[] memory _dnAmounts) internal {

        require(_tokens.length == _dnAmounts.length, "SavingsModule: count of tokens does not match count of amounts");
        for (uint256 i=0; i < _tokens.length; i++) {
            address tkn = _tokens[i];
            IERC20(tkn).safeTransferFrom(_msgSender(), _protocol, _dnAmounts[i]);
            IDefiProtocol(_protocol).handleDeposit(tkn, _dnAmounts[i]);
            emit DepositToken(_protocol, tkn, _dnAmounts[i]);
        }
    }

    function withdrawAll(address _protocol, uint256 nAmount)
    public operationAllowed(IAccessModule.Operation.Withdraw)
    returns(uint256) 
    {


        PoolToken poolToken = PoolToken(protocols[_protocol].poolToken);

        uint256 nBalanceBefore = distributeYieldInternal(_protocol);
        withdrawFromProtocolProportionally(_msgSender(), IDefiProtocol(_protocol), nAmount, nBalanceBefore);
        uint256 nBalanceAfter = updateProtocolBalance(_protocol);

        uint256 yield;
        uint256 actualAmount;
        if(nBalanceAfter.add(nAmount) > nBalanceBefore) {
            yield = nBalanceAfter.add(nAmount).sub(nBalanceBefore);
            actualAmount = nAmount;
        }else{
            actualAmount = nBalanceBefore.sub(nBalanceAfter);
            require(actualAmount.sub(nAmount) <= protocols[_protocol].withdrawAllSlippage, "SavingsModule: withdrawal fee exeeds slippage");
        }


        poolToken.burnFrom(_msgSender(), actualAmount);
        emit Withdraw(_protocol, _msgSender(), actualAmount, 0);

        if (yield > 0) {
            createYieldDistribution(poolToken, yield);
        }

        return actualAmount;
    }

    function withdraw(address _protocol, address token, uint256 dnAmount, uint256 maxNAmount)
    public operationAllowed(IAccessModule.Operation.Withdraw)
    returns(uint256){


        uint256 nAmount = normalizeTokenAmount(token, dnAmount);

        uint256 nBalanceBefore = distributeYieldInternal(_protocol);
        withdrawFromProtocolOne(_msgSender(), IDefiProtocol(_protocol), token, dnAmount);
        uint256 nBalanceAfter = updateProtocolBalance(_protocol);

        uint256 yield;
        uint256 actualAmount;
        uint256 fee;
        if(nBalanceAfter.add(nAmount) > nBalanceBefore) {
            yield = nBalanceAfter.add(nAmount).sub(nBalanceBefore);
            actualAmount = nAmount;
        }else{
            actualAmount = nBalanceBefore.sub(nBalanceAfter);
            if (actualAmount > nAmount) fee = actualAmount-nAmount;
        }

        require(maxNAmount == 0 || actualAmount <= maxNAmount, "SavingsModule: provided maxNAmount is too low");


        PoolToken poolToken = PoolToken(protocols[_protocol].poolToken);
        poolToken.burnFrom(_msgSender(), actualAmount);
        emit WithdrawToken(_protocol, token, dnAmount);
        emit Withdraw(_protocol, _msgSender(), actualAmount, fee);


        if (yield > 0) {
            createYieldDistribution(poolToken, yield);
        }

        return actualAmount;
    }

    function distributeYield() public {

        for(uint256 i=0; i<registeredProtocols.length; i++) {
            distributeYieldInternal(address(registeredProtocols[i]));
        }
    }

    function userCap(address _protocol, address user) public view returns(uint256) {

        uint256 balance = protocols[_protocol].poolToken.balanceOf(user);
        uint256 cap;
        if(balance < defaultUserCap[_protocol]) {
            cap = defaultUserCap[_protocol] - balance;
        }
        return cap;
    }

    function isVipUser(address _protocol, address user) view public returns(bool){

        return protocols[_protocol].isVipUser[user];
    }

    function poolTokenByProtocol(address _protocol) public view returns(address) {

        return address(protocols[_protocol].poolToken);
    }

    function protocolByPoolToken(address _poolToken) public view returns(address) {

        return poolTokenToProtocol[_poolToken];
    }

    function rewardTokensByProtocol(address _protocol) public view returns(address[] memory) {

        return protocols[_protocol].supportedRewardTokens;
    }

    function registeredPoolTokens() public view returns(address[] memory poolTokens) {

        poolTokens = new address[](registeredProtocols.length);
        for(uint256 i=0; i<poolTokens.length; i++){
            poolTokens[i] = address(protocols[address(registeredProtocols[i])].poolToken);
        }
    }

    function supportedProtocols() public view returns(IDefiProtocol[] memory) {

        return registeredProtocols;
    }

    function supportedRewardTokens() public view returns(address[] memory) {

        return registeredRewardTokens;
    }

    function withdrawFromProtocolProportionally(address beneficiary, IDefiProtocol protocol, uint256 nAmount, uint256 currentProtocolBalance) internal {

        uint256[] memory balances = protocol.balanceOfAll();
        uint256[] memory amounts = new uint256[](balances.length);
        address[] memory _tokens = protocol.supportedTokens();
        for (uint256 i = 0; i < amounts.length; i++) {
            amounts[i] = balances[i].mul(nAmount).div(currentProtocolBalance);
            emit WithdrawToken(address(protocol), _tokens[i], amounts[i]);
        }
        protocol.withdraw(beneficiary, amounts);
    }

    function withdrawFromProtocolOne(address beneficiary, IDefiProtocol protocol, address token, uint256 dnAmount) internal {

        protocol.withdraw(beneficiary, token, dnAmount);
    }

    function distributeYieldInternal(address _protocol) internal returns(uint256){

        uint256 currentBalance = IDefiProtocol(_protocol).normalizedBalance();
        ProtocolInfo storage pi = protocols[_protocol];
        PoolToken poolToken = PoolToken(pi.poolToken);
        if(currentBalance > pi.previousBalance) {
            uint256 yield = currentBalance.sub(pi.previousBalance);
            pi.previousBalance = currentBalance;
            createYieldDistribution(poolToken, yield);
        }
        return currentBalance;
    }

    function createYieldDistribution(PoolToken poolToken, uint256 yield) internal {

        poolToken.distribute(yield);
        emit YieldDistribution(address(poolToken), yield);
    }

    function updateProtocolBalance(address _protocol) internal returns(uint256){

        uint256 currentBalance = IDefiProtocol(_protocol).normalizedBalance();
        protocols[_protocol].previousBalance = currentBalance;
        return currentBalance;
    }

    function isTokenRegistered(address token) private view returns(bool) {

        for (uint256 i = 0; i < registeredTokens.length; i++){
            if (registeredTokens[i] == token) return true;
        }
        return false;
    }

    function isPoolToken(address token) internal view returns(bool) {

        for (uint256 i = 0; i < registeredProtocols.length; i++){
            IDefiProtocol protocol = registeredProtocols[i];
            if (address(protocols[address(protocol)].poolToken) == token) return true;
        }
        return false;
    }

    function normalizeTokenAmount(address token, uint256 amount) private view returns(uint256) {

        uint256 decimals = tokens[token].decimals;
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.div(10**(decimals-18));
        } else if (decimals < 18) {
            return amount.mul(10**(18 - decimals));
        }
    }

    function denormalizeTokenAmount(address token, uint256 amount) private view returns(uint256) {

        uint256 decimals = tokens[token].decimals;
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.mul(10**(decimals-18));
        } else if (decimals < 18) {
            return amount.div(10**(18 - decimals));
        }
    }

}


pragma solidity ^0.5.12;




contract RewardManagerRole is Initializable, Context {

    using Roles for Roles.Role;

    event RewardManagerAdded(address indexed account);
    event RewardManagerRemoved(address indexed account);

    Roles.Role private _managers;

    function initialize(address sender) public initializer {

        if (!isRewardManager(sender)) {
            _addRewardManager(sender);
        }
    }

    modifier onlyRewardManager() {

        require(isRewardManager(_msgSender()), "RewardManagerRole: caller does not have the RewardManager role");
        _;
    }

    function addRewardManager(address account) public onlyRewardManager {

        _addRewardManager(account);
    }

    function renounceRewardManager() public {

        _removeRewardManager(_msgSender());
    }

    function isRewardManager(address account) public view returns (bool) {

        return _managers.has(account);
    }

    function _addRewardManager(address account) internal {

        _managers.add(account);
        emit RewardManagerAdded(account);
    }

    function _removeRewardManager(address account) internal {

        _managers.remove(account);
        emit RewardManagerRemoved(account);
    }

}


pragma solidity ^0.5.12;







contract RewardVestingModule is Module, RewardManagerRole {

    event RewardTokenRegistered(address indexed protocol, address token);
    event EpochRewardAdded(address indexed protocol, address indexed token, uint256 epoch, uint256 amount);
    event RewardClaimed(address indexed protocol, address indexed token, uint256 claimPeriodStart, uint256 claimPeriodEnd, uint256 claimAmount);

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Epoch {
        uint256 end;        // Timestamp of Epoch end
        uint256 amount;     // Amount of reward token for this protocol on this epoch
    }

    struct RewardInfo {
        Epoch[] epochs;
        uint256 lastClaim; // Timestamp of last claim
    }

    struct ProtocolRewards {
        address[] tokens;
        mapping(address=>RewardInfo) rewardInfo;
    }

    mapping(address => ProtocolRewards) internal rewards;
    uint256 public defaultEpochLength;

    function initialize(address _pool) public initializer {

        Module.initialize(_pool);
        RewardManagerRole.initialize(_msgSender());
        defaultEpochLength = 7*24*60*60;
    }

    function getRewardInfo(address protocol, address token) public view returns(uint256 lastClaim, uint256 epochCount) {

        ProtocolRewards storage r = rewards[protocol];
        RewardInfo storage ri = r.rewardInfo[token];
        return (ri.lastClaim, ri.epochs.length);
    }

    function registerRewardToken(address protocol, address token, uint256 firstEpochStart) public onlyRewardManager {

        if(firstEpochStart == 0) firstEpochStart = block.timestamp;
        ProtocolRewards storage r = rewards[protocol];
        RewardInfo storage ri = r.rewardInfo[token];
        require(ri.epochs.length == 0, "RewardVesting: token already registered for this protocol");
        r.tokens.push(token);
        ri.epochs.push(Epoch({
            end: firstEpochStart,
            amount: 0
        }));
        emit RewardTokenRegistered(protocol, token);
    }

    function setDefaultEpochLength(uint256 _defaultEpochLength) public onlyRewardManager {

        defaultEpochLength = _defaultEpochLength;
    }

    function getEpochInfo(address protocol, address token, uint256 epoch) public view returns(uint256 epochStart, uint256 epochEnd, uint256 rewardAmount) {

        ProtocolRewards storage r = rewards[protocol];
        RewardInfo storage ri = r.rewardInfo[token];
        require(ri.epochs.length > 0, "RewardVesting: protocol or token not registered");
        require (epoch < ri.epochs.length, "RewardVesting: epoch number too high");
        if(epoch == 0) {
            epochStart = 0;
        }else {
            epochStart = ri.epochs[epoch-1].end;
        }
        epochEnd = ri.epochs[epoch].end;
        rewardAmount = ri.epochs[epoch].amount;
        return (epochStart, epochEnd, rewardAmount);
    }

    function getLastCreatedEpoch(address protocol, address token) public view returns(uint256) {

        ProtocolRewards storage r = rewards[protocol];
        RewardInfo storage ri = r.rewardInfo[token];
        require(ri.epochs.length > 0, "RewardVesting: protocol or token not registered");
        return ri.epochs.length-1;       
    }

    function claimRewards() public {

        address protocol = _msgSender();
        ProtocolRewards storage r = rewards[protocol];
        if(r.tokens.length == 0) return;    //This allows claims from protocols which are not yet registered without reverting
        for(uint256 i=0; i < r.tokens.length; i++){
            _claimRewards(protocol, r.tokens[i]);
        }
    }

    function claimRewards(address protocol, address token) public {

        _claimRewards(protocol, token);
    }

    function _claimRewards(address protocol, address token) internal {

        ProtocolRewards storage r = rewards[protocol];
        RewardInfo storage ri = r.rewardInfo[token];
        uint256 epochsLength = ri.epochs.length;
        require(epochsLength > 0, "RewardVesting: protocol or token not registered");

        Epoch storage lastEpoch = ri.epochs[epochsLength-1];
        uint256 previousClaim = ri.lastClaim;
        if(previousClaim == lastEpoch.end) return; // Nothing to claim yet

        if(lastEpoch.end < block.timestamp) {
            ri.lastClaim = lastEpoch.end;
        }else{
            ri.lastClaim = block.timestamp;
        }
        
        uint256 claimAmount;
        Epoch storage ep = ri.epochs[0];
        uint256 i;
        for(i = epochsLength-1; i > 0; i--) {
            ep = ri.epochs[i];
            if(ep.end < block.timestamp) {  // We've found last fully-finished epoch
                if(i < epochsLength-1) {    // We have already started current epoch
                    i++;                    //    Go back to currently-running epoch
                    ep = ri.epochs[i];
                }
                break;
            }
        }
        if(ep.end > block.timestamp) {
            uint256 epStart = ri.epochs[i-1].end;
            uint256 claimStart = (previousClaim > epStart)?previousClaim:epStart;
            uint256 epochClaim = ep.amount.mul(block.timestamp.sub(claimStart)).div(ep.end.sub(epStart));
            claimAmount = claimAmount.add(epochClaim);
            i--;
        }
        for(i; i > 0; i--) {
            ep = ri.epochs[i];
            uint256 epStart = ri.epochs[i-1].end;
            if(ep.end > previousClaim) {
                if(previousClaim > epStart) {
                    uint256 epochClaim = ep.amount.mul(ep.end.sub(previousClaim)).div(ep.end.sub(epStart));
                    claimAmount = claimAmount.add(epochClaim);
                } else {
                    claimAmount = claimAmount.add(ep.amount);
                }
            } else {
                break;
            }
        }
        IERC20(token).safeTransfer(protocol, claimAmount);
        emit RewardClaimed(protocol, token, previousClaim, ri.lastClaim, claimAmount);
    }

    function createEpoch(address protocol, address token, uint256 epochEnd, uint256 amount) public onlyRewardManager {

        ProtocolRewards storage r = rewards[protocol];
        RewardInfo storage ri = r.rewardInfo[token];
        uint256 epochsLength = ri.epochs.length;
        require(epochsLength > 0, "RewardVesting: protocol or token not registered");
        uint256 prevEpochEnd = ri.epochs[epochsLength-1].end;
        require(epochEnd > prevEpochEnd, "RewardVesting: new epoch should end after previous");
        ri.epochs.push(Epoch({
            end: epochEnd,
            amount:0
        }));            
        _addReward(protocol, token, epochsLength, amount);
    }

    function addReward(address protocol, address token, uint256 epoch, uint256 amount) public onlyRewardManager {

        _addReward(protocol, token, epoch, amount);
    }

    function addRewards(address[] calldata protocols, address[] calldata tokens, uint256[] calldata epochs, uint256[] calldata amounts) external onlyRewardManager {

        require(
            (protocols.length == tokens.length) && 
            (protocols.length == epochs.length) && 
            (protocols.length == amounts.length),
            "RewardVesting: array lengths do not match");
        for(uint256 i=0; i<protocols.length; i++) {
            _addReward(protocols[i], tokens[i], epochs[i], amounts[i]);
        }
    }

    function _addReward(address protocol, address token, uint256 epoch, uint256 amount) internal {

        ProtocolRewards storage r = rewards[protocol];
        RewardInfo storage ri = r.rewardInfo[token];
        uint256 epochsLength = ri.epochs.length;
        require(epochsLength > 0, "RewardVesting: protocol or token not registered");
        if(epoch == 0) epoch = epochsLength; // creating a new epoch
        if (epoch == epochsLength) {
            uint256 epochEnd = ri.epochs[epochsLength-1].end.add(defaultEpochLength);
            if(epochEnd < block.timestamp) epochEnd = block.timestamp; //This generally should not happen, but just in case - we generate only one epoch since previous end
            ri.epochs.push(Epoch({
                end: epochEnd,
                amount: amount
            }));            
        } else  {
            require(epochsLength > epoch, "RewardVesting: epoch is too high");
            Epoch storage ep = ri.epochs[epoch];
            require(ep.end > block.timestamp, "RewardVesting: epoch already finished");
            ep.amount = ep.amount.add(amount);
        }
        emit EpochRewardAdded(protocol, token, epoch, amount);
        IERC20(token).safeTransferFrom(_msgSender(), address(this), amount);
    }


}


pragma solidity ^0.5.12;


interface IERC900 {

  event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
  event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

  function stake(uint256 amount, bytes calldata data) external;


  function stakeFor(address user, uint256 amount, bytes calldata data) external;

  function unstake(uint256 amount, bytes calldata data) external;

  function totalStakedFor(address addr) external  view returns (uint256);

  function totalStaked() external  view returns (uint256);

  function token() external  view returns (address);

  function supportsHistory() external  pure returns (bool);


}


pragma solidity ^0.5.12;






contract StakingPoolBase is Module, IERC900, CapperRole  {

  using SafeMath for uint256;

  ERC20 stakingToken;

  uint256 public defaultLockInDuration;

  mapping (address => StakeContract) public stakeHolders;

  struct Stake {
    uint256 unlockedTimestamp;
    uint256 actualAmount;
    address stakedFor;
  }

  struct StakeContract {
    uint256 totalStakedFor;

    uint256 personalStakeIndex;

    Stake[] personalStakes;

    bool exists;
  }

  bool public userCapEnabled;

  mapping(address => uint256) public userCap; //Limit of pool tokens which can be minted for a user during deposit

  
  uint256 public defaultUserCap;
  bool public stakingCapEnabled;
  uint256 public stakingCap;


  bool public vipUserEnabled;
  mapping(address => bool) public isVipUser;

  uint256 internal totalStakedAmount;

  uint256 public coeffScore;
  


  event VipUserEnabledChange(bool enabled);
  event VipUserChanged(address indexed user, bool isVip);

  event StakingCapChanged(uint256 newCap);
  event StakingCapEnabledChange(bool enabled);

  event DefaultUserCapChanged(uint256 newCap);

  event UserCapEnabledChange(bool enabled);

  event UserCapChanged(address indexed user, uint256 newCap);
  event Staked(address indexed user, uint256 amount, uint256 totalStacked, bytes data);
  event Unstaked(address indexed user, uint256 amount, uint256 totalStacked, bytes data);
  event setLockInDuration(uint256 defaultLockInDuration);

  event CoeffScoreUpdated(uint256 coeff);
  modifier canStake(address _address, uint256 _amount) {

    require(
      stakingToken.transferFrom(_address, address(this), _amount),
      "Stake required");

    _;
  }


  modifier isUserCapEnabledForStakeFor(uint256 stake) {


    if (stakingCapEnabled && !(vipUserEnabled && isVipUser[_msgSender()])) {
        require((stakingCap > totalStaked() && (stakingCap-totalStaked() >= stake)), "StakingModule: stake exeeds staking cap");
    }

    if(userCapEnabled) {
          uint256 cap = userCap[_msgSender()];
          if (defaultUserCap > 0) {
              uint256 totalStaked = totalStakedFor(_msgSender());
              if (defaultUserCap >= totalStaked) {
                cap = defaultUserCap.sub(totalStaked);
              } else {
                 cap = 0;
              }
          }
          
          require(cap >= stake, "StakingModule: stake exeeds cap");
          cap = cap.sub(stake);
          userCap[_msgSender()] = cap;
          emit UserCapChanged(_msgSender(), cap);  
    }
      
    _;
  }


  modifier isUserCapEnabledForUnStakeFor(uint256 unStake) {

     _;

     if(userCapEnabled){
        uint256 cap = userCap[_msgSender()];
        cap = cap.add(unStake);

        if (cap > defaultUserCap) {
            cap = defaultUserCap;
        }

        userCap[_msgSender()] = cap;
        emit UserCapChanged(_msgSender(), cap);
     }
  }

  modifier checkUserCapDisabled() {

    require(isUserCapEnabled() == false, "UserCapEnabled");
    _;
  }

  modifier checkUserCapEnabled() {

    require(isUserCapEnabled(), "UserCapDisabled");
    _;
  }
 

  function initialize(address _pool, ERC20 _stakingToken, uint256 _defaultLockInDuration) public initializer {

        stakingToken = _stakingToken;
        defaultLockInDuration = _defaultLockInDuration;
        Module.initialize(_pool);

        CapperRole.initialize(_msgSender());
  }

  function setDefaultLockInDuration(uint256 _defaultLockInDuration) public onlyOwner {

      defaultLockInDuration = _defaultLockInDuration;
      emit setLockInDuration(_defaultLockInDuration);
  }

  function setUserCapEnabled(bool _userCapEnabled) public onlyCapper {

      userCapEnabled = _userCapEnabled;
      emit UserCapEnabledChange(userCapEnabled);
  }

  function setStakingCapEnabled(bool _stakingCapEnabled) public onlyCapper {

      stakingCapEnabled= _stakingCapEnabled;
      emit StakingCapEnabledChange(stakingCapEnabled);
  }

  function setDefaultUserCap(uint256 _newCap) public onlyCapper {

      defaultUserCap = _newCap;
      emit DefaultUserCapChanged(_newCap);
  }

  function setStakingCap(uint256 _newCap) public onlyCapper {

      stakingCap = _newCap;
      emit StakingCapChanged(_newCap);
  }

  function setUserCap(address user, uint256 cap) public onlyCapper {

      userCap[user] = cap;
      emit UserCapChanged(user, cap);
  }

  function setUserCap(address[] memory users, uint256[] memory caps) public onlyCapper {

        require(users.length == caps.length, "SavingsModule: arrays length not match");
        for(uint256 i=0;  i < users.length; i++) {
            userCap[users[i]] = caps[i];
            emit UserCapChanged(users[i], caps[i]);
        }
  }


  function setVipUserEnabled(bool _vipUserEnabled) public onlyCapper {

      vipUserEnabled = _vipUserEnabled;
      emit VipUserEnabledChange(_vipUserEnabled);
  }

  function setVipUser(address user, bool isVip) public onlyCapper {

      isVipUser[user] = isVip;
      emit VipUserChanged(user, isVip);
  }


  function setCoeffScore(uint256 coeff) public onlyCapper {

    coeffScore = coeff;

    emit CoeffScoreUpdated(coeff);
  }

  function isUserCapEnabled() public view returns(bool) {

    return userCapEnabled;
  }


  function iStakingCapEnabled() public view returns(bool) {

    return stakingCapEnabled;
  }

  function getPersonalStakeUnlockedTimestamps(address _address) external view returns (uint256[] memory) {

    uint256[] memory timestamps;
    (timestamps,,) = getPersonalStakes(_address);

    return timestamps;
  }


  

  function getPersonalStakeActualAmounts(address _address) external view returns (uint256[] memory) {

    uint256[] memory actualAmounts;
    (,actualAmounts,) = getPersonalStakes(_address);

    return actualAmounts;
  }

  function getPersonalStakeTotalAmount(address _address) public view returns(uint256) {

    uint256[] memory actualAmounts;
    (,actualAmounts,) = getPersonalStakes(_address);
    uint256 totalStake;
    for(uint256 i=0; i <actualAmounts.length; i++) {
      totalStake = totalStake.add(actualAmounts[i]);
    }
    return totalStake;
  }

  function getPersonalStakeForAddresses(address _address) external view returns (address[] memory) {

    address[] memory stakedFor;
    (,,stakedFor) = getPersonalStakes(_address);

    return stakedFor;
  }

  function stake(uint256 _amount, bytes memory _data) public isUserCapEnabledForStakeFor(_amount) {

    createStake(
      _msgSender(),
      _amount,
      defaultLockInDuration,
      _data);
  }

  function stakeFor(address _user, uint256 _amount, bytes memory _data) public checkUserCapDisabled {

    createStake(
      _user,
      _amount,
      defaultLockInDuration,
      _data);
  }

  function unstake(uint256 _amount, bytes memory _data) public {

    withdrawStake(
      _amount,
      _data);
  }

  function unstakeAllUnlocked(bytes memory _data) public returns(uint256) {

     uint256 unstakeAllAmount = 0;
     uint256 personalStakeIndex = stakeHolders[_msgSender()].personalStakeIndex;

     for(uint256 i=personalStakeIndex; i<stakeHolders[_msgSender()].personalStakes.length; i++) {
       
       if (stakeHolders[_msgSender()].personalStakes[i].unlockedTimestamp <= block.timestamp) {
           unstakeAllAmount = unstakeAllAmount+stakeHolders[_msgSender()].personalStakes[i].actualAmount;
           withdrawStake(stakeHolders[_msgSender()].personalStakes[i].actualAmount, _data);
       }
     }

     return unstakeAllAmount;
  }

  function totalStakedFor(address _address) public view returns (uint256) {

    return stakeHolders[_address].totalStakedFor;
  }

  function totalScoresFor(address _address) public view returns (uint256) {

    return stakeHolders[_address].totalStakedFor.mul(coeffScore).div(10**18);
  }


  function totalStaked() public view returns (uint256) {

    return totalStakedAmount;
  }

  function token() public view returns (address) {

    return address(stakingToken);
  }

  function supportsHistory() public pure returns (bool) {

    return false;
  }

  function getPersonalStakes(
    address _address
  )
    public view
    returns(uint256[] memory, uint256[] memory, address[] memory)
  {

    StakeContract storage stakeContract = stakeHolders[_address];

    uint256 arraySize = stakeContract.personalStakes.length - stakeContract.personalStakeIndex;
    uint256[] memory unlockedTimestamps = new uint256[](arraySize);
    uint256[] memory actualAmounts = new uint256[](arraySize);
    address[] memory stakedFor = new address[](arraySize);

    for (uint256 i = stakeContract.personalStakeIndex; i < stakeContract.personalStakes.length; i++) {
      uint256 index = i - stakeContract.personalStakeIndex;
      unlockedTimestamps[index] = stakeContract.personalStakes[i].unlockedTimestamp;
      actualAmounts[index] = stakeContract.personalStakes[i].actualAmount;
      stakedFor[index] = stakeContract.personalStakes[i].stakedFor;
    }

    return (
      unlockedTimestamps,
      actualAmounts,
      stakedFor
    );
  }

  function createStake(
    address _address,
    uint256 _amount,
    uint256 _lockInDuration,
    bytes memory _data)
    internal
    canStake(_msgSender(), _amount)
  {

    if (!stakeHolders[_msgSender()].exists) {
      stakeHolders[_msgSender()].exists = true;
    }

    stakeHolders[_address].totalStakedFor = stakeHolders[_address].totalStakedFor.add(_amount);
    stakeHolders[_msgSender()].personalStakes.push(
      Stake(
        block.timestamp.add(_lockInDuration),
        _amount,
        _address)
      );

    totalStakedAmount = totalStakedAmount.add(_amount);
    emit Staked(
      _address,
      _amount,
      totalStakedFor(_address),
      _data);
  }

  function withdrawStake(
    uint256 _amount,
    bytes memory _data)
    internal isUserCapEnabledForUnStakeFor(_amount)
  {

    Stake storage personalStake = stakeHolders[_msgSender()].personalStakes[stakeHolders[_msgSender()].personalStakeIndex];

    require(
      personalStake.unlockedTimestamp <= block.timestamp,
      "The current stake hasn't unlocked yet");

    require(
      personalStake.actualAmount == _amount,
      "The unstake amount does not match the current stake");

    require(
      stakingToken.transfer(_msgSender(), _amount),
      "Unable to withdraw stake");

    stakeHolders[personalStake.stakedFor].totalStakedFor = stakeHolders[personalStake.stakedFor]
      .totalStakedFor.sub(personalStake.actualAmount);

    personalStake.actualAmount = 0;
    stakeHolders[_msgSender()].personalStakeIndex++;

    totalStakedAmount = totalStakedAmount.sub(_amount);

    emit Unstaked(
      personalStake.stakedFor,
      _amount,
      totalStakedFor(personalStake.stakedFor),
      _data);
  }

  uint256[49] private ______gap;
}


pragma solidity ^0.5.12; 





contract StakingPool is StakingPoolBase {

    event RewardTokenRegistered(address token);
    event RewardDistributionCreated(address token, uint256 amount, uint256 totalShares);
    event RewardWithdraw(address indexed user, address indexed rewardToken, uint256 amount);

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct RewardDistribution {
        uint256 totalShares;
        uint256 amount;
    }

    struct UserRewardInfo {
        mapping(address=>uint256) nextDistribution; //Next unclaimed distribution
    }

    struct RewardData {
        RewardDistribution[] distributions;
        uint256 unclaimed;
    }

    RewardVestingModule public rewardVesting;
    address[] internal registeredRewardTokens;
    mapping(address=>RewardData) internal rewards;
    mapping(address=>UserRewardInfo) internal userRewards;


    modifier onlyRewardDistributionModule() {

        require(_msgSender() == getModuleAddress(MODULE_REWARD_DISTR), "StakingPool: calls allowed from RewardDistributionModule only");
        _;
    }

    function setRewardVesting(address _rewardVesting) public onlyOwner {

        rewardVesting = RewardVestingModule(_rewardVesting);
    }

    function registerRewardToken(address token) public onlyOwner {

        require(!isRegisteredRewardToken(token), "StakingPool: already registered");
        registeredRewardTokens.push(token);
        emit RewardTokenRegistered(token);
    }

    function claimRewardsFromVesting() public onlyCapper{

        _claimRewardsFromVesting();
    }

    function isRegisteredRewardToken(address token) public view returns(bool) {

        for(uint256 i=0; i<registeredRewardTokens.length; i++){
            if(token == registeredRewardTokens[i]) return true;
        }
        return false;
    }

    function supportedRewardTokens() public view returns(address[] memory) {

        return registeredRewardTokens;
    }

    function withdrawRewards() public returns(uint256[] memory){

        return _withdrawRewards(_msgSender());
    }

    function withdrawRewardsFor(address user, address rewardToken) public onlyRewardDistributionModule returns(uint256) {

        return _withdrawRewards(user, rewardToken);
    }


    function rewardBalanceOf(address user, address token) public view returns(uint256) {

        RewardData storage rd = rewards[token];
        if(rd.unclaimed == 0) return 0; //Either token not registered or everything is already claimed
        uint256 shares = getPersonalStakeTotalAmount(user);
        if(shares == 0) return 0;
        UserRewardInfo storage uri = userRewards[user];
        uint256 reward;
        for(uint256 i=uri.nextDistribution[token]; i < rd.distributions.length; i++) {
            RewardDistribution storage rdistr = rd.distributions[i];
            uint256 r = shares.mul(rdistr.amount).div(rdistr.totalShares);
            reward = reward.add(r);
        }
        return reward;
    }

    function _withdrawRewards(address user) internal returns(uint256[] memory rwrds) {

        rwrds = new uint256[](registeredRewardTokens.length);
        for(uint256 i=0; i<registeredRewardTokens.length; i++){
            rwrds[i] = _withdrawRewards(user, registeredRewardTokens[i]);
        }
        return rwrds;
    }

    function _withdrawRewards(address user, address token) internal returns(uint256){

        UserRewardInfo storage uri = userRewards[user];
        RewardData storage rd = rewards[token];
        if(rd.distributions.length == 0) { //No distributions = nothing to do
            return 0;
        }
        uint256 rwrds = rewardBalanceOf(user, token);
        uri.nextDistribution[token] = rd.distributions.length;
        if(rwrds > 0){
            rewards[token].unclaimed = rewards[token].unclaimed.sub(rwrds);
            IERC20(token).transfer(user, rwrds);
            emit RewardWithdraw(user, token, rwrds);
        }
        return rwrds;
    }

    function createStake(address _address, uint256 _amount, uint256 _lockInDuration, bytes memory _data) internal {

        _withdrawRewards(_address);
        super.createStake(_address, _amount, _lockInDuration, _data);
    }

    function withdrawStake(uint256 _amount, bytes memory _data) internal {

        _withdrawRewards(_msgSender());
        super.withdrawStake(_amount, _data);
    }


    function _claimRewardsFromVesting() internal {

        rewardVesting.claimRewards();
        for(uint256 i=0; i < registeredRewardTokens.length; i++){
            address rt = registeredRewardTokens[i];
            uint256 expectedBalance = rewards[rt].unclaimed;
            if(rt == address(stakingToken)){
                expectedBalance = expectedBalance.add(totalStaked());
            }
            uint256 actualBalance = IERC20(rt).balanceOf(address(this));
            uint256 distributionAmount = actualBalance.sub(expectedBalance);
            if(actualBalance > expectedBalance) {
                uint256 totalShares = totalStaked();
                rewards[rt].distributions.push(RewardDistribution({
                    totalShares: totalShares,
                    amount: distributionAmount
                }));
                rewards[rt].unclaimed = rewards[rt].unclaimed.add(distributionAmount);
                emit RewardDistributionCreated(rt, distributionAmount, totalShares);
            }
        }
    }

}


pragma solidity ^0.5.12;











contract RewardDistributionModule is Module, IPoolTokenBalanceChangeRecipient, AccessChecker {

    uint256 public constant DISTRIBUTION_AGGREGATION_PERIOD = 24*60*60;

    event ProtocolRegistered(address protocol, address poolToken);
    event RewardDistribution(address indexed poolToken, address indexed rewardToken, uint256 amount, uint256 totalShares);
    event RewardWithdraw(address indexed user, address indexed rewardToken, uint256 amount);

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct RewardTokenDistribution {
        address poolToken;                  // PoolToken which holders will receive reward
        uint256 totalShares;                // Total shares of PoolToken participating in this distribution
        address[] rewardTokens;             // List of reward tokens being distributed 
        mapping(address=>uint256) amounts; 
    }

    struct UserProtocolRewards {
        uint256 shares;
        mapping(address=>uint256) amounts;  // Maps address of reward token to amount beeing distributed
    }
    struct RewardBalance {
        uint256 nextDistribution;
        mapping(address => UserProtocolRewards) rewardsByPT; //Maps PoolToken to ProtocolRewards struct (map of reward tokens to their balances);
    }

    struct ProtocolInfo {
        address poolToken;
        uint256 lastRewardDistributionTimestamp;
        address[] rewardTokens;
    }

    RewardTokenDistribution[] rewardDistributions;
    mapping(address=>RewardBalance) rewardBalances; //Mapping users to their RewardBalance

    address[] internal registeredRewardTokens;
    address[] internal registeredPoolTokens;
    mapping(address=>bool) public isRewardToken;
    mapping(address=>address) internal poolTokenToProtocol;
    mapping(address=>ProtocolInfo) public protocolInfo;
    mapping(address=>bool) public userRewardsMigrated;


    function initialize(address _pool) public initializer {

        Module.initialize(_pool);
    }

    function registerProtocol(address _protocol, address _poolToken) public onlyOwner {

        require(protocolInfo[_protocol].poolToken == address(0), "RewardDistributionModule: protocol already registered");
        require(poolTokenToProtocol[_poolToken] == address(0), "RewardDistributionModule: poolToken already registered");

        registeredPoolTokens.push(_poolToken);
        poolTokenToProtocol[_poolToken] = _protocol;

        address[] memory rTokens = IDefiProtocol(_protocol).supportedRewardTokens();

        protocolInfo[_protocol] = ProtocolInfo({
            poolToken: _poolToken,
            lastRewardDistributionTimestamp: 0,
            rewardTokens: rTokens
        });

        for(uint256 i=0; i < rTokens.length; i++) {
            if(!isRewardToken[rTokens[i]]){
                isRewardToken[rTokens[i]] = true;
                registeredRewardTokens.push(rTokens[i]);
            }
        }

        emit ProtocolRegistered(_protocol, _poolToken);
    }    


    function poolTokenByProtocol(address _protocol) public view returns(address) {

        return protocolInfo[_protocol].poolToken;
    }
    function protocolByPoolToken(address _poolToken) public view returns(address)  {

        return poolTokenToProtocol[_poolToken];
    }
    function supportedPoolTokens() public view returns(address[] memory) {

        return registeredPoolTokens;
    }
    function supportedRewardTokens() public view returns(address[] memory) {

        return registeredRewardTokens;
    }

    function poolTokenBalanceChanged(address user) public {

        address token = _msgSender();
        require(isPoolToken(token), "RewardDistributionModule: PoolToken is not registered");

        _updateRewardBalance(user, rewardDistributions.length);
        uint256 newAmount = PoolToken(token).distributionBalanceOf(user);
        rewardBalances[user].rewardsByPT[token].shares = newAmount;
    }

    function distributeRewards() public {

        for(uint256 i=0; i<registeredPoolTokens.length; i++) {
            distributeRewardIfRequired(poolTokenToProtocol[registeredPoolTokens[i]]);
        }
    }


    function distributeRewardsForced(address _protocol) public onlyOwner {

        protocolInfo[_protocol].lastRewardDistributionTimestamp = now;
        distributeReward(_protocol);
    }

    function distributeRewardIfRequired(address _protocol) internal {

        if(!isRewardDistributionRequired(_protocol)) return;
        protocolInfo[_protocol].lastRewardDistributionTimestamp = now;
        distributeReward(_protocol);
    }

    function isRewardDistributionRequired(address _protocol) internal view returns(bool) {

        uint256 lrd = protocolInfo[_protocol].lastRewardDistributionTimestamp;
        return now.sub(lrd) > DISTRIBUTION_AGGREGATION_PERIOD;
    }

    function withdrawReward() public returns(uint256[] memory) {

        return withdrawReward(supportedRewardTokens());
    }

    function withdrawReward(address[] memory rewardTokens)
    public operationAllowed(IAccessModule.Operation.Withdraw)
    returns(uint256[] memory)
    {

        address user = _msgSender();
        uint256[] memory rAmounts = new uint256[](rewardTokens.length);
        updateRewardBalance(user);
        for(uint256 i=0; i < rewardTokens.length; i++) {
            rAmounts[i] = _withdrawReward(user, rewardTokens[i]);
        }
        return rAmounts;
    }

    function withdrawReward(address poolToken, address rewardToken) 
    public operationAllowed(IAccessModule.Operation.Withdraw)
    returns(uint256){

        address user = _msgSender();
        updateRewardBalance(user);
        return _withdrawReward(user, poolToken, rewardToken);
    }

    function withdrawReward(address[] memory poolTokens, address[] memory rewardTokens) 
    public operationAllowed(IAccessModule.Operation.Withdraw)
    returns(uint256[] memory){

        require(poolTokens.length == rewardTokens.length, "RewardDistributionModule: array length mismatch");

        address akroStaking = getModuleAddress(MODULE_STAKING_AKRO);
        address adelStaking = getModuleAddress(MODULE_STAKING_ADEL);

        uint256[] memory amounts = new uint256[](poolTokens.length);
        address user = _msgSender();
        updateRewardBalance(user);
        for(uint256 i=0; i < poolTokens.length; i++) {
            if(poolTokens[i] == akroStaking || poolTokens[i] == adelStaking){
                amounts[i] = StakingPool(poolTokens[i]).withdrawRewardsFor(user, rewardTokens[i]);
            }else{
                amounts[i] = _withdrawReward(user, poolTokens[i], rewardTokens[i]);
            }
        }
        return amounts;
    }



    function rewardBalanceOf(address user, address poolToken, address rewardToken) public view returns(uint256 amounts) {

        if(!userRewardsMigrated[user]){
            address[] memory rtkns = new address[](1);
            rtkns[0] = rewardToken;
            return savingsModule().rewardBalanceOf(user, poolToken, rtkns)[0];
        }

        RewardBalance storage rb = rewardBalances[user];
        UserProtocolRewards storage upr = rb.rewardsByPT[poolToken];
        uint256 balance = upr.amounts[rewardToken];
        uint256 next = rb.nextDistribution;
        while (next < rewardDistributions.length) {
            RewardTokenDistribution storage d = rewardDistributions[next];
            next++;

            uint256 sh = rb.rewardsByPT[d.poolToken].shares;
            if (sh == 0 || poolToken != d.poolToken) continue;
            uint256 distrAmount = d.amounts[rewardToken];
            balance = balance.add(distrAmount.mul(sh).div(d.totalShares));
        }
        return balance;
    }

    function rewardBalanceOf(address user, address poolToken, address[] calldata rewardTokens) external view returns(uint256[] memory) {

        if(!userRewardsMigrated[user]) return savingsModule().rewardBalanceOf(user, poolToken, rewardTokens);

        RewardBalance storage rb = rewardBalances[user];
        UserProtocolRewards storage upr = rb.rewardsByPT[poolToken];
        uint256[] memory balances = new uint256[](rewardTokens.length);
        uint256 i;
        for(i=0; i < rewardTokens.length; i++){
            balances[i] = upr.amounts[rewardTokens[i]];
        }
        uint256 next = rb.nextDistribution;
        while (next < rewardDistributions.length) {
            RewardTokenDistribution storage d = rewardDistributions[next];
            next++;

            uint256 sh = rb.rewardsByPT[d.poolToken].shares;
            if (sh == 0 || poolToken != d.poolToken) continue;
            for(i=0; i < rewardTokens.length; i++){
                uint256 distrAmount = d.amounts[rewardTokens[i]];
                balances[i] = balances[i].add(distrAmount.mul(sh).div(d.totalShares));
            }
        }
        return balances;
    }


    function updateRewardBalance(address user) public {

        _updateRewardBalance(user, rewardDistributions.length);
    }

    function updateRewardBalance(address user, uint256 toDistribution) public {

        _updateRewardBalance(user, toDistribution);
    }

    function distributeReward(address _protocol) internal {

        (address[] memory _tokens, uint256[] memory _amounts) = IDefiProtocol(_protocol).claimRewards();
        if(_tokens.length > 0) {
            address poolToken = poolTokenByProtocol(_protocol);
            distributeReward(poolToken, _tokens, _amounts);
        }
    }

    function storedRewardBalance(address user, address poolToken, address rewardToken) public view 
    returns(uint256 nextDistribution, uint256 poolTokenShares, uint256 storedReward) {

        RewardBalance storage rb = rewardBalances[user];
        nextDistribution = rb.nextDistribution;
        poolTokenShares = rb.rewardsByPT[poolToken].shares;
        storedReward = rb.rewardsByPT[poolToken].amounts[rewardToken];
    }

    function rewardDistribution(uint256 num) public view 
    returns(address poolToken, uint256 totalShares, address[] memory rewardTokens, uint256[] memory amounts){

        RewardTokenDistribution storage d = rewardDistributions[num];
        poolToken = d.poolToken;
        totalShares = d.totalShares;
        rewardTokens = d.rewardTokens;
        amounts = new uint256[](rewardTokens.length);
        for(uint256 i=0; i < rewardTokens.length; i++) {
            address tkn = rewardTokens[i];
            amounts[i] = d.amounts[tkn];
        }
    }

    function rewardDistributionCount() public view returns(uint256){

        return rewardDistributions.length;
    }

    function distributeReward(address poolToken, address[] memory rewardTokens, uint256[] memory amounts) internal {

        rewardDistributions.push(RewardTokenDistribution({
            poolToken: poolToken,
            totalShares: PoolToken(poolToken).distributionTotalSupply(),
            rewardTokens:rewardTokens
        }));
        uint256 idx = rewardDistributions.length - 1;
        RewardTokenDistribution storage rd = rewardDistributions[idx];
        for(uint256 i = 0; i < rewardTokens.length; i++) {
            rd.amounts[rewardTokens[i]] = amounts[i];  
            emit RewardDistribution(poolToken, rewardTokens[i], amounts[i], rd.totalShares);
        }
    }

    function migrateRewards(address[] calldata users) external {

        for(uint256 i=0; i<users.length;i++){
            migrateUserRewards(users[i]);
        }
    }

    function migrateUserRewards(address user) internal {

        if(userRewardsMigrated[user]) return; //Skip already migrated
        RewardBalance storage rb =rewardBalances[user];

        SavingsModule sm = savingsModule();
        IDefiProtocol[] memory protocols = sm.supportedProtocols();
        for(uint256 i=0; i<protocols.length; i++) {
            address _protocol = address(protocols[i]);
            address _poolToken = protocolInfo[_protocol].poolToken;
            UserProtocolRewards storage upr = rb.rewardsByPT[_poolToken];
            upr.shares = PoolToken(_poolToken).distributionBalanceOf(user);
            address[] memory rtkns = sm.rewardTokensByProtocol(_protocol);
            uint256[] memory balances = sm.rewardBalanceOf(user, _poolToken, rtkns);
            for(uint256 j=0; j<rtkns.length; j++){
                upr.amounts[rtkns[j]] = balances[j];
            }
        }
        userRewardsMigrated[user] = true;
    }

    function _withdrawReward(address user, address rewardToken) internal returns(uint256) {

        uint256 totalAmount;
        for(uint256 i=0; i < registeredPoolTokens.length; i++) {
            address poolToken = registeredPoolTokens[i];
            uint256 amount = rewardBalances[user].rewardsByPT[poolToken].amounts[rewardToken];
            if(amount > 0){
                totalAmount = totalAmount.add(amount);
                rewardBalances[user].rewardsByPT[poolToken].amounts[rewardToken] = 0;
                IDefiProtocol protocol = IDefiProtocol(protocolByPoolToken(poolToken));
                protocol.withdrawReward(rewardToken, user, amount);
            }
        }
        if(totalAmount > 0) {
            emit RewardWithdraw(user, rewardToken, totalAmount);
        }
        return totalAmount;
    }

    function _withdrawReward(address user, address poolToken, address rewardToken) internal returns(uint256) {

        uint256 amount = rewardBalances[user].rewardsByPT[poolToken].amounts[rewardToken];
        require(amount > 0, "RewardDistributionModule: nothing to withdraw");
        rewardBalances[user].rewardsByPT[poolToken].amounts[rewardToken] = 0;
        IDefiProtocol protocol = IDefiProtocol(protocolByPoolToken(poolToken));
        protocol.withdrawReward(rewardToken, user, amount);
        emit RewardWithdraw(user, rewardToken, amount);
        return amount;
    }

    function _updateRewardBalance(address user, uint256 toDistribution) internal {

        require(toDistribution <= rewardDistributions.length, "RewardDistributionModule: toDistribution index is too high");
        if(!userRewardsMigrated[user]) migrateUserRewards(user);

        RewardBalance storage rb = rewardBalances[user];
        uint256 next = rb.nextDistribution;
        if(next >= toDistribution) return;

        if(next == 0 && rewardDistributions.length > 0){
            bool hasDeposit;
            for(uint256 i=0; i< registeredPoolTokens.length; i++){
                address poolToken = registeredPoolTokens[i];
                if(rb.rewardsByPT[poolToken].shares != 0) {
                    hasDeposit = true;
                    break;
                }
            }
            if(!hasDeposit){
                rb.nextDistribution = rewardDistributions.length;
                return;
            }
        }

        while (next < toDistribution) {
            RewardTokenDistribution storage d = rewardDistributions[next];
            next++;
            UserProtocolRewards storage upr = rb.rewardsByPT[d.poolToken]; 
            uint256 sh = upr.shares;
            if (sh == 0) continue;
            for (uint256 i=0; i < d.rewardTokens.length; i++) {
                address rToken = d.rewardTokens[i];
                uint256 distrAmount = d.amounts[rToken];
                upr.amounts[rToken] = upr.amounts[rToken].add(distrAmount.mul(sh).div(d.totalShares));

            }
        }
        rb.nextDistribution = next;
    }

    function savingsModule() internal view returns (SavingsModule) {

        return SavingsModule(getModuleAddress(MODULE_SAVINGS));
    }

    function isPoolToken(address _token) internal view returns(bool) {

        return (poolTokenToProtocol[_token] != address(0));
    }
}