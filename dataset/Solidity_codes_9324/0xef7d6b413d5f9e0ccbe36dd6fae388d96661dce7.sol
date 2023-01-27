

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


pragma solidity ^0.5.12;











contract SavingsCap is CapperRole {


    event UserCapEnabledChange(bool enabled);
    event UserCapChanged(address indexed protocol, address indexed user, uint256 newCap);
    event DefaultUserCapChanged(address indexed protocol, uint256 newCap);
    event ProtocolCapEnabledChange(bool enabled);
    event ProtocolCapChanged(address indexed protocol, uint256 newCap);
    event VipUserEnabledChange(bool enabled);
    event VipUserChanged(address indexed protocol, address indexed user, bool isVip);

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct ProtocolCapInfo {
        mapping(address => uint256) userCap; //Limit of pool tokens which can be minted for a user during deposit
        mapping(address=>bool) isVipUser;       
    }

    mapping(address => ProtocolCapInfo) protocolsCapInfo; //Mapping of protocol to data we need to calculate APY and do distributions

    bool public userCapEnabled;
    bool public protocolCapEnabled;
    mapping(address=>uint256) public defaultUserCap;
    mapping(address=>uint256) public protocolCap;
    bool public vipUserEnabled;                         // Enable VIP user (overrides protocol cap)


    function initialize(address _capper) public initializer {

        CapperRole.initialize(_capper);
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

        protocolsCapInfo[_protocol].isVipUser[user] = isVip;
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

    function getUserCapLeft(address _protocol, uint256 _balance) view public returns(uint256) {

        uint256 cap;
        if (_balance < defaultUserCap[_protocol]) {
            cap = defaultUserCap[_protocol] - _balance;
        }
        return cap;
    }

    function isVipUser(address _protocol, address user) view public returns(bool){

        return protocolsCapInfo[_protocol].isVipUser[user];
    }

    function isProtocolCapExceeded(uint256 _poolSupply, address _protocol, address _user) view public returns(bool) {

        if (protocolCapEnabled) {
            if ( !(vipUserEnabled && isVipUser(_protocol, _user)) ) {
                if (_poolSupply > protocolCap[_protocol]) {
                    return true;
                }
            }
        }
        return false;
    }

}


pragma solidity ^0.5.12;




contract VaultOperatorRole is Initializable, Context {

    using Roles for Roles.Role;

    event VaultOperatorAdded(address indexed account);
    event VaultOperatorRemoved(address indexed account);

    Roles.Role private _managers;

    function initialize(address sender) public initializer {

        if (!isVaultOperator(sender)) {
            _addVaultOperator(sender);
        }
    }

    modifier onlyVaultOperator() {

        require(isVaultOperator(_msgSender()), "VaultOperatorRole: caller does not have the VaultOperator role");
        _;
    }

    function addVaultOperator(address account) public onlyVaultOperator {

        _addVaultOperator(account);
    }

    function renounceVaultOperator() public {

        _removeVaultOperator(_msgSender());
    }

    function isVaultOperator(address account) public view returns (bool) {

        return _managers.has(account);
    }

    function _addVaultOperator(address account) internal {

        _managers.add(account);
        emit VaultOperatorAdded(account);
    }

    function _removeVaultOperator(address account) internal {

        _managers.remove(account);
        emit VaultOperatorRemoved(account);
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

interface IStrategyCurveFiSwapCrv {

    event CrvClaimed(string indexed id, address strategy, uint256 amount);

    function curveFiTokenBalance() external view returns(uint256);

    function performStrategyStep1() external;

    function performStrategyStep2(bytes calldata _data, address _token) external;

}


pragma solidity ^0.5.12;













contract VaultSavingsModule is Module, IVaultSavings, AccessChecker, RewardDistributions, SavingsCap, VaultOperatorRole {

    uint256 constant MAX_UINT256 = uint256(-1);

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct VaultInfo {
        VaultPoolToken poolToken;
        uint256 previousBalance;
    }

    address[] internal registeredVaults;
    mapping(address => VaultInfo) vaults;
    mapping(address => address) poolTokenToVault;

    function initialize(address _pool) public initializer {

        Module.initialize(_pool);
        SavingsCap.initialize(_msgSender());
        VaultOperatorRole.initialize(_msgSender());
    }

    function registerVault(IVaultProtocol protocol, VaultPoolToken poolToken) public onlyOwner {

        require(!isVaultRegistered(address(protocol)), "Vault is already registered");

        registeredVaults.push(address(protocol));
        
        vaults[address(protocol)] = VaultInfo({
            poolToken: poolToken,
            previousBalance: protocol.normalizedBalance()
        });

        poolTokenToVault[address(poolToken)] = address(protocol);

        uint256 normalizedBalance = vaults[address(protocol)].previousBalance;
        if(normalizedBalance > 0) {
            uint256 ts = poolToken.totalSupply();
            if(ts < normalizedBalance) {
                poolToken.mint(_msgSender(), normalizedBalance.sub(ts));
            }
        }
        emit VaultRegistered(address(protocol), address(poolToken));
    }

    function deposit(address _protocol, address[] memory _tokens, uint256[] memory _dnAmounts)
    public operationAllowed(IAccessModule.Operation.Deposit)
    returns(uint256) 
    {

        require(isVaultRegistered(_protocol), "Vault is not registered");
        depositToProtocol(_protocol, _tokens, _dnAmounts);

        uint256 nAmount;
        for (uint256 i=0; i < _tokens.length; i++) {
            nAmount = nAmount.add(CalcUtils.normalizeAmount(_tokens[i], _dnAmounts[i]));
        }
        
        VaultPoolToken poolToken = VaultPoolToken(vaults[_protocol].poolToken);
        poolToken.mint(_msgSender(), nAmount);

        require(!isProtocolCapExceeded(poolToken.totalSupply(), _protocol, _msgSender()), "Deposit exeeds protocols cap");

        uint256 cap;
        if (userCapEnabled) {
            cap = userCap(_protocol, _msgSender());
            require(cap >= nAmount, "Deposit exeeds user cap");
        }

        emit Deposit(_protocol, _msgSender(), nAmount, 0);
        return nAmount;
    }

    function deposit(address[] memory _protocols, address[] memory _tokens, uint256[] memory _dnAmounts) 
    public operationAllowed(IAccessModule.Operation.Deposit) 
    returns(uint256[] memory) 
    {

        require(_protocols.length == _tokens.length && _tokens.length == _dnAmounts.length, "Size of arrays does not match");
        uint256[] memory ptAmounts = new uint256[](_protocols.length);
        address[] memory tkns = new address[](1);
        uint256[] memory amnts = new uint256[](1);
        for (uint256 i=0; i < _protocols.length; i++) {
            tkns[0] = _tokens[i];
            amnts[0] = _dnAmounts[i];
            ptAmounts[i] = deposit(_protocols[i], tkns, amnts);
        }
        return ptAmounts;
    }

    function depositToProtocol(address _protocol, address[] memory _tokens, uint256[] memory _dnAmounts) internal {

        for (uint256 i=0; i < _tokens.length; i++) {
            address tkn = _tokens[i];
            IERC20(tkn).safeTransferFrom(_msgSender(), _protocol, _dnAmounts[i]);
            IVaultProtocol(_protocol).depositToVault(_msgSender(), tkn, _dnAmounts[i]);
            emit DepositToken(_protocol, tkn, _dnAmounts[i]);
        }
    }

    function withdraw(address _vaultProtocol, address[] memory _tokens, uint256[] memory _amounts, bool isQuick)
    public operationAllowed(IAccessModule.Operation.Withdraw)
    returns(uint256)
    {

        require(isVaultRegistered(_vaultProtocol), "Vault is not registered");
        require(_tokens.length == _amounts.length, "Size of arrays does not match");

        VaultPoolToken poolToken = VaultPoolToken(vaults[_vaultProtocol].poolToken);

        uint256 actualAmount;
        uint256 normAmount;
        for (uint256 i = 0; i < _amounts.length; i++) {
            normAmount = CalcUtils.normalizeAmount(_tokens[i], _amounts[i]);
            actualAmount = actualAmount.add(normAmount);

            emit WithdrawToken(address(_vaultProtocol), _tokens[i], normAmount);
        }

        if (isQuick) {
            uint256 yield = quickWithdraw(_vaultProtocol, _tokens, _amounts, normAmount);
            if (yield > 0) {
                createYieldDistribution(poolToken, yield);
            }
        }
        else {
            if (_tokens.length == 1) {
                IVaultProtocol(_vaultProtocol).withdrawFromVault(_msgSender(), _tokens[0], _amounts[0]);
            }
            else {
                IVaultProtocol(_vaultProtocol).withdrawFromVault(_msgSender(), _tokens, _amounts);
            }
        }

        poolToken.burnFrom(_msgSender(), actualAmount);
        emit Withdraw(_vaultProtocol, _msgSender(), actualAmount, 0);

        return actualAmount;
    }

    function quickWithdraw(address _vaultProtocol, address[] memory _tokens, uint256[] memory _amounts, uint256 normAmount) internal
    returns(uint256) {

        uint256 nBalanceBefore = distributeYieldInternal(_vaultProtocol);

        IVaultProtocol(_vaultProtocol).quickWithdraw(_msgSender(), _tokens, _amounts);
        
        uint256 nBalanceAfter = updateProtocolBalance(_vaultProtocol);


        uint256 yield;
        uint256 calcBalanceAfter = nBalanceBefore.sub(normAmount);
        if (nBalanceAfter > calcBalanceAfter) {
            yield = nBalanceAfter.sub(calcBalanceAfter);
        }
        return yield;
    }

    function withdrawAll(address[] memory _vaults, address[] memory _tokens, uint256[] memory _dnAmounts)
    public operationAllowed(IAccessModule.Operation.Withdraw)
    returns(uint256[] memory) 
    {

        require(_tokens.length == _dnAmounts.length, "Size of arrays does not match");

        uint256[] memory ptAmounts = new uint256[](_vaults.length);
        uint256 curInd;
        uint256 lim;
        uint256 nTokens;
        for (uint256 i=0; i < _vaults.length; i++) {
            nTokens = IVaultProtocol(_vaults[i]).supportedTokensCount();
            lim = curInd + nTokens;
            
            require(_tokens.length >= lim, "Incorrect tokens length");
            
            address[] memory tkns = new address[](nTokens);
            uint256[] memory amnts = new uint256[](nTokens);

            for (uint256 j = curInd; j < lim; j++) {
                tkns[j-curInd] = _tokens[j];
                amnts[j-curInd] = _dnAmounts[j];
            }

            ptAmounts[i] = withdraw(_vaults[i], tkns, amnts, false);

            curInd += nTokens;
        }
        return ptAmounts;
    }

    function claimAllRequested(address _vaultProtocol) public
    {

        require(isVaultRegistered(_vaultProtocol), "Vault is not registered");
        IVaultProtocol(_vaultProtocol).claimRequested(_msgSender());
    }

    function handleOperatorActions(address _vaultProtocol, address _strategy, address _token) public onlyVaultOperator {

        uint256 totalDeposit;
        uint256 totalWithdraw;

        VaultPoolToken poolToken = VaultPoolToken(vaults[_vaultProtocol].poolToken);

        uint256 nBalanceBefore = distributeYieldInternal(_vaultProtocol);
        if (_token == address(0)) {
            (totalDeposit, totalWithdraw) = IVaultProtocol(_vaultProtocol).operatorAction(_strategy);
        }
        else {
            (totalDeposit, totalWithdraw) = IVaultProtocol(_vaultProtocol).operatorActionOneCoin(_strategy, _token);
        }
        uint256 nBalanceAfter = updateProtocolBalance(_vaultProtocol);

        uint256 yield;
        uint256 calcBalanceAfter = nBalanceBefore.add(totalDeposit).sub(totalWithdraw);
        if (nBalanceAfter > calcBalanceAfter) {
            yield = nBalanceAfter.sub(calcBalanceAfter);
        }

        if (yield > 0) {
            createYieldDistribution(poolToken, yield);
        }
    }

    function clearProtocolStorage(address _vaultProtocol) public onlyVaultOperator {

        IVaultProtocol(_vaultProtocol).clearOnHoldDeposits();
        IVaultProtocol(_vaultProtocol).clearWithdrawRequests();
    }

    function distributeYield(address _vaultProtocol) public {

        distributeYieldInternal(_vaultProtocol);
    }

    function setVaultRemainder(address _vaultProtocol, uint256 _amount, uint256 _index) public onlyVaultOperator {

        IVaultProtocol(_vaultProtocol).setRemainder(_amount, _index);
    }

    function callStrategyStep(address _vaultProtocol, address _strategy, bool _distrYield, bytes memory _strategyData) public onlyVaultOperator {

        require(IVaultProtocol(_vaultProtocol).isStrategyRegistered(_strategy), "Strategy is not registered");
        uint256 oldVaultBalance = IVaultProtocol(_vaultProtocol).normalizedVaultBalance();

        (bool success, bytes memory result) = _strategy.call(_strategyData);

        if(!success) assembly {
            revert(add(result,32), result)  //Reverts with same revert reason
        }

        if (_distrYield) {
            uint256 newVaultBalance;
            newVaultBalance = IVaultProtocol(_vaultProtocol).normalizedVaultBalance();
            if (newVaultBalance > oldVaultBalance) {
                uint256 yield = newVaultBalance.sub(oldVaultBalance);
                vaults[_vaultProtocol].previousBalance = vaults[_vaultProtocol].previousBalance.add(yield);
                createYieldDistribution(vaults[_vaultProtocol].poolToken, yield);
            }
        }
    }

    function poolTokenByProtocol(address _vaultProtocol) public view returns(address) {

        return address(vaults[_vaultProtocol].poolToken);
    }

    function protocolByPoolToken(address _poolToken) public view returns(address) {

        return poolTokenToVault[_poolToken];
    }

    function userCap(address _protocol, address user) public view returns(uint256) {

        uint256 balance = vaults[_protocol].poolToken.balanceOf(user);
        return getUserCapLeft(_protocol, balance);
    }

    function isVaultRegistered(address _protocol) public view returns(bool) {

        for (uint256 i = 0; i < registeredVaults.length; i++){
            if (registeredVaults[i] == _protocol) return true;
        }
        return false;
    }

    function supportedVaults() public view returns(address[] memory) {

        return registeredVaults;
    }

    function distributeYieldInternal(address _vaultProtocol) internal returns(uint256){

        uint256 currentBalance = IVaultProtocol(_vaultProtocol).normalizedBalance();
        VaultInfo storage pi = vaults[_vaultProtocol];
        VaultPoolToken poolToken = VaultPoolToken(pi.poolToken);
        if(currentBalance > pi.previousBalance) {
            uint256 yield = currentBalance.sub(pi.previousBalance);
            pi.previousBalance = currentBalance;
            createYieldDistribution(poolToken, yield);
        }
        return currentBalance;
    }

    function createYieldDistribution(VaultPoolToken poolToken, uint256 yield) internal {

        poolToken.distribute(yield);
        emit YieldDistribution(address(poolToken), yield);
    }

    function updateProtocolBalance(address _protocol) internal returns(uint256){

        uint256 currentBalance = IVaultProtocol(_protocol).normalizedBalance();
        vaults[_protocol].previousBalance = currentBalance;
        return currentBalance;
    }
}