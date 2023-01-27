

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


contract StakingPoolADEL is StakingPool {

}