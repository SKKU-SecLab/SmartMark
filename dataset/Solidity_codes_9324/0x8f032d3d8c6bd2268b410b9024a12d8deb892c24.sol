

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

contract ICurveFiDeposit { 

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_uamount) external;

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_uamount, bool donate_dust) external;

    function withdraw_donated_dust() external;


    function coins(int128 i) external view returns (address);

    function underlying_coins (int128 i) external view returns (address);
    function curve() external view returns (address);

    function token() external view returns (address);

    function calc_withdraw_one_coin (uint256 _token_amount, int128 i) external view returns (uint256);
}


pragma solidity ^0.5.12;

interface ICurveFiSwap { 

    function balances(int128 i) external view returns(uint256);

    function A() external view returns(uint256);

    function fee() external view returns(uint256);

    function coins(int128 i) external view returns (address);

}


pragma solidity ^0.5.16;

interface ICurveFiLiquidityGauge {

    function lp_token() external returns(address);

    function crv_token() external returns(address);

 
    function balanceOf(address addr) external view returns (uint256);

    function deposit(uint256 _value) external;

    function withdraw(uint256 _value) external;


    function claimable_tokens(address addr) external returns (uint256);

    function minter() external view returns(address); //use minter().mint(gauge_addr) to claim CRV

}


pragma solidity ^0.5.16;

interface ICurveFiMinter {

    function mint(address gauge_addr) external;

}


pragma solidity ^0.5.12;

contract ICErc20 { 




    function transfer(address dst, uint amount) external returns (bool);

    function transferFrom(address src, address dst, uint amount) external returns (bool);

    function approve(address spender, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function accrueInterest() external returns (uint256);



    function mint(uint mintAmount) external returns (uint256);

    function redeem(uint redeemTokens) external returns (uint256);

    function redeemUnderlying(uint redeemAmount) external returns (uint256);


}


pragma solidity ^0.5.16;

interface IComptroller {

    function claimComp(address holder) external;

    function claimComp(address[] calldata holders, address[] calldata cTokens, bool borrowers, bool suppliers) external;

    function getCompAddress() external view returns (address);

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
    string internal constant MODULE_STAKING           = "staking";
    string internal constant MODULE_DCA               = "dca";
    string internal constant MODULE_REWARD            = "reward";

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
            if(ep.end >= block.timestamp) {
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
            if(ep.end > previousClaim) {
                claimAmount = claimAmount.add(ep.amount);
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











contract ProtocolBase is Module, DefiOperatorRole, IDefiProtocol {

    uint256 constant MAX_UINT256 = uint256(-1);

    event RewardTokenClaimed(address indexed token, uint256 amount);

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address=>uint256) public rewardBalances;    //Mapping of already claimed amounts of reward tokens

    function initialize(address _pool) public initializer {

        Module.initialize(_pool);
        DefiOperatorRole.initialize(_msgSender());
    }

    function supportedRewardTokens() public view returns(address[] memory) {

        return defaultRewardTokens();
    }

    function isSupportedRewardToken(address token) public view returns(bool) {

        address[] memory srt = supportedRewardTokens();
        for(uint256 i=0; i < srt.length; i++) {
            if(srt[i] == token) return true;
        }
        return false;
    }

    function cliamRewardsFromProtocol() internal;


    function claimRewards() public onlyDefiOperator returns(address[] memory tokens, uint256[] memory amounts){

        cliamRewardsFromProtocol();
        claimDefaultRewards();

        address[] memory rewardTokens = supportedRewardTokens();
        uint256[] memory rewardAmounts = new uint256[](rewardTokens.length);
        uint256 receivedRewardTokensCount;
        for(uint256 i = 0; i < rewardTokens.length; i++) {
            address rtkn = rewardTokens[i];
            uint256 newBalance = IERC20(rtkn).balanceOf(address(this));
            if(newBalance > rewardBalances[rtkn]) {
                receivedRewardTokensCount++;
                rewardAmounts[i] = newBalance.sub(rewardBalances[rtkn]);
                rewardBalances[rtkn] = newBalance;
            }
        }

        tokens = new address[](receivedRewardTokensCount);
        amounts = new uint256[](receivedRewardTokensCount);
        if(receivedRewardTokensCount > 0) {
            uint256 j;
            for(uint256 i = 0; i < rewardTokens.length; i++) {
                if(rewardAmounts[i] > 0) {
                    tokens[j] = rewardTokens[i];
                    amounts[j] = rewardAmounts[i];
                    j++;
                }
            }
        }
    }

    function withdrawReward(address token, address user, uint256 amount) public onlyDefiOperator {

        require(isSupportedRewardToken(token), "ProtocolBase: not reward token");
        rewardBalances[token] = rewardBalances[token].sub(amount);
        IERC20(token).safeTransfer(user, amount);
    }

    function claimDefaultRewards() internal {

        RewardVestingModule rv = RewardVestingModule(getModuleAddress(MODULE_REWARD));
        rv.claimRewards();
    }

    function defaultRewardTokens() internal view returns(address[] memory) {

        address[] memory rt = new address[](2);
        return defaultRewardTokensFillArray(rt);
    }
    function defaultRewardTokensFillArray(address[] memory rt) internal view returns(address[] memory) {

        require(rt.length >= 2, "ProtocolBase: not enough space in array");
        rt[0] = getModuleAddress(TOKEN_AKRO);
        rt[1] = getModuleAddress(TOKEN_ADEL);
        return rt;
    }
    function defaultRewardTokensCount() internal pure returns(uint256) {

        return 2;
    }
}


pragma solidity ^0.5.12;












contract CurveFiProtocol is ProtocolBase {

    bool public constant DONATE_DUST = false;    
    uint256 constant MAX_UINT256 = uint256(-1);

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event CurveFiSetup(address swap, address deposit, address liquidityGauge);
    event TokenRegistered(address indexed token);
    event TokenUnregistered(address indexed token);

    ICurveFiSwap public curveFiSwap;
    ICurveFiDeposit public curveFiDeposit;
    ICurveFiLiquidityGauge public curveFiLPGauge;
    ICurveFiMinter public curveFiMinter;
    IERC20 public curveFiToken;
    address public crvToken;
    address[] internal _registeredTokens;
    uint256 public slippageMultiplier; //Multiplier to work-around slippage & fees when witharawing one token
    mapping(address => uint8) public decimals;

    function nCoins() internal returns(uint256);

    function deposit_add_liquidity(uint256[] memory amounts, uint256 min_mint_amount) internal;

    function deposit_remove_liquidity_imbalance(uint256[] memory amounts, uint256 max_burn_amount) internal;


    function initialize(address _pool) public initializer {

        ProtocolBase.initialize(_pool);
        _registeredTokens = new address[](nCoins());
        slippageMultiplier = 1.01*1e18;     //Max slippage - 1%, if more - tx will fail
    }

    function setCurveFi(address deposit, address liquidityGauge) public onlyDefiOperator {

        if (address(curveFiDeposit) != address(0)) {
            for (uint256 i=0; i < _registeredTokens.length; i++){
                if (_registeredTokens[i] != address(0)) {
                    _unregisterToken(_registeredTokens[i]);
                    _registeredTokens[i] = address(0);
                }
            }
        }
        curveFiDeposit = ICurveFiDeposit(deposit);
        curveFiSwap = ICurveFiSwap(curveFiDeposit.curve());
        curveFiToken = IERC20(curveFiDeposit.token());

        curveFiLPGauge = ICurveFiLiquidityGauge(liquidityGauge);
        curveFiMinter = ICurveFiMinter(curveFiLPGauge.minter());
        address lpToken = curveFiLPGauge.lp_token();
        require(lpToken == address(curveFiToken), "CurveFiProtocol: LP tokens do not match");
        crvToken = curveFiLPGauge.crv_token();

        IERC20(curveFiToken).safeApprove(address(curveFiDeposit), MAX_UINT256);
        IERC20(curveFiToken).safeApprove(address(curveFiLPGauge), MAX_UINT256);
        for (uint256 i=0; i < _registeredTokens.length; i++){
            address token = curveFiDeposit.underlying_coins(int128(i));
            _registerToken(token, i);
        }
        emit CurveFiSetup(address(curveFiSwap), address(curveFiDeposit), address(curveFiLPGauge));
    }

    function setSlippageMultiplier(uint256 _slippageMultiplier) public onlyDefiOperator {

        require(_slippageMultiplier >= 1e18, "CurveFiYModule: multiplier should be > 1");
        slippageMultiplier = _slippageMultiplier;
    }

    function handleDeposit(address token, uint256 amount) public onlyDefiOperator {

        uint256[] memory amounts = new uint256[](nCoins());
        for (uint256 i=0; i < _registeredTokens.length; i++){
            amounts[i] = IERC20(_registeredTokens[i]).balanceOf(address(this)); // Check balance which is left after previous withdrawal
            if (_registeredTokens[i] == token) {
                require(amounts[i] >= amount, "CurveFiYProtocol: requested amount is not deposited");
            }
        }
        deposit_add_liquidity(amounts, 0);
        stakeCurveFiToken();
    }

    function handleDeposit(address[] memory tokens, uint256[] memory amounts) public onlyDefiOperator {

        require(tokens.length == amounts.length, "CurveFiYProtocol: count of tokens does not match count of amounts");
        require(amounts.length == nCoins(), "CurveFiYProtocol: amounts count does not match registered tokens");
        uint256[] memory amnts = new uint256[](nCoins());
        for (uint256 i=0; i < _registeredTokens.length; i++){
            uint256 idx = getTokenIndex(tokens[i]);
            amnts[idx] = IERC20(_registeredTokens[idx]).balanceOf(address(this)); // Check balance which is left after previous withdrawal
            require(amnts[idx] >= amounts[i], "CurveFiYProtocol: requested amount is not deposited");
        }
        deposit_add_liquidity(amnts, 0);
        stakeCurveFiToken();
    }

    function withdraw(address beneficiary, address token, uint256 amount) public onlyDefiOperator {

        uint256 tokenIdx = getTokenIndex(token);
        uint256 available = IERC20(token).balanceOf(address(this));
        if(available < amount) {
            uint256 wAmount = amount.sub(available); //Count tokens left after previous withdrawal

            uint256 nAmount = normalizeAmount(token, wAmount);
            uint256 nBalance = normalizedBalance();

            uint256 poolShares = curveFiTokenBalance();
            uint256 withdrawShares = poolShares.mul(nAmount).mul(slippageMultiplier).div(nBalance).div(1e18); //Increase required amount to some percent, so that we definitely have enough to withdraw

            unstakeCurveFiToken(withdrawShares);
            deposit_remove_liquidity_one_coin(withdrawShares, tokenIdx, wAmount);

            available = IERC20(token).balanceOf(address(this));
            require(available >= amount, "CurveFiYProtocol: failed to withdraw required amount");
        }
        IERC20 ltoken = IERC20(token);
        ltoken.safeTransfer(beneficiary, amount);
    }

    function withdraw(address beneficiary, uint256[] memory amounts) public onlyDefiOperator {

        require(amounts.length == nCoins(), "CurveFiYProtocol: wrong amounts array length");

        uint256 nWithdraw;
        uint256[] memory amnts = new uint256[](nCoins());
        uint256 i;
        for (i = 0; i < _registeredTokens.length; i++){
            address tkn = _registeredTokens[i];
            uint256 available = IERC20(tkn).balanceOf(address(this));
            if(available < amounts[i]){
                amnts[i] = amounts[i].sub(available);
            }else{
                amnts[i] = 0;
            }
            nWithdraw = nWithdraw.add(normalizeAmount(tkn, amnts[i]));
        }

        uint256 nBalance = normalizedBalance();
        uint256 poolShares = curveFiTokenBalance();
        uint256 withdrawShares = poolShares.mul(nWithdraw).mul(slippageMultiplier).div(nBalance).div(1e18); //Increase required amount to some percent, so that we definitely have enough to withdraw

        unstakeCurveFiToken(withdrawShares);
        deposit_remove_liquidity_imbalance(amnts, withdrawShares);
        
        for (i = 0; i < _registeredTokens.length; i++){
            IERC20 lToken = IERC20(_registeredTokens[i]);
            uint256 lBalance = lToken.balanceOf(address(this));
            uint256 lAmount = (lBalance <= amounts[i])?lBalance:amounts[i]; // Rounding may prevent Curve.Fi to return exactly requested amount
            lToken.safeTransfer(beneficiary, lAmount);
        }
    }

    function supportedRewardTokens() public view returns(address[] memory) {

        uint256 defaultRTCount = defaultRewardTokensCount();
        address[] memory rtokens = new address[](defaultRTCount+1);
        rtokens = defaultRewardTokensFillArray(rtokens);
        rtokens[defaultRTCount] = address(crvToken);
        return rtokens;
    }

    function cliamRewardsFromProtocol() internal {

        curveFiMinter.mint(address(curveFiLPGauge));
    }

    function balanceOf(address token) public returns(uint256) {

        uint256 tokenIdx = getTokenIndex(token);

        uint256 cfBalance = curveFiTokenBalance();
        uint256 cfTotalSupply = curveFiToken.totalSupply();
        uint256 tokenCurveFiBalance = curveFiSwap.balances(int128(tokenIdx));
        
        return tokenCurveFiBalance.mul(cfBalance).div(cfTotalSupply);
    }
    
    function balanceOfAll() public returns(uint256[] memory balances) {

        uint256 cfBalance = curveFiTokenBalance();
        uint256 cfTotalSupply = curveFiToken.totalSupply();

        balances = new uint256[](_registeredTokens.length);
        for (uint256 i=0; i < _registeredTokens.length; i++){
            uint256 tcfBalance = curveFiSwap.balances(int128(i));
            balances[i] = tcfBalance.mul(cfBalance).div(cfTotalSupply);
        }
    }

    function normalizedBalance() public returns(uint256) {

        uint256[] memory balances = balanceOfAll();
        uint256 summ;
        for (uint256 i=0; i < _registeredTokens.length; i++){
            summ = summ.add(normalizeAmount(_registeredTokens[i], balances[i]));
        }
        return summ;
    }

    function optimalProportions() public returns(uint256[] memory) {

        uint256[] memory amounts = balanceOfAll();
        uint256 summ;
        for (uint256 i=0; i < _registeredTokens.length; i++){
            amounts[i] = normalizeAmount(_registeredTokens[i], amounts[i]);
            summ = summ.add(amounts[i]);
        }
        for (uint256 i=0; i < _registeredTokens.length; i++){
            amounts[i] = amounts[i].div(summ);
        }
        return amounts;
    }
    

    function supportedTokens() public view returns(address[] memory){

        return _registeredTokens;
    }

    function supportedTokensCount() public view returns(uint256) {

        return _registeredTokens.length;
    }

    function getTokenIndex(address token) public view returns(uint256) {

        for (uint256 i=0; i < _registeredTokens.length; i++){
            if (_registeredTokens[i] == token){
                return i;
            }
        }
        revert("CurveFiYProtocol: token not registered");
    }

    function canSwapToToken(address token) public view returns(bool) {

        for (uint256 i=0; i < _registeredTokens.length; i++){
            if (_registeredTokens[i] == token){
                return true;
            }
        }
        return false;
    }

    function deposit_remove_liquidity_one_coin(uint256 _token_amount, uint256 i, uint256 min_uamount) internal {

        curveFiDeposit.remove_liquidity_one_coin(_token_amount, int128(i), min_uamount, DONATE_DUST);
    }

    function normalizeAmount(address token, uint256 amount) internal view returns(uint256) {

        uint256 _decimals = uint256(decimals[token]);
        if (_decimals == 18) {
            return amount;
        } else if (_decimals > 18) {
            return amount.div(10**(_decimals-18));
        } else if (_decimals < 18) {
            return amount.mul(10**(18-_decimals));
        }
    }

    function denormalizeAmount(address token, uint256 amount) internal view returns(uint256) {

        uint256 _decimals = uint256(decimals[token]);
        if (_decimals == 18) {
            return amount;
        } else if (_decimals > 18) {
            return amount.mul(10**(_decimals-18));
        } else if (_decimals < 18) {
            return amount.div(10**(18-_decimals));
        }
    }

    function curveFiTokenBalance() internal view returns(uint256) {

        uint256 notStaked = curveFiToken.balanceOf(address(this));
        uint256 staked = curveFiLPGauge.balanceOf(address(this));
        return notStaked.add(staked);
    }

    function stakeCurveFiToken() internal {

        uint256 cftBalance = curveFiToken.balanceOf(address(this));
        curveFiLPGauge.deposit(cftBalance);
    }

    function unstakeCurveFiToken(uint256 amount) internal {

        curveFiLPGauge.withdraw(amount);
    }

    function _registerToken(address token, uint256 idx) private {

        _registeredTokens[idx] = token;
        IERC20 ltoken = IERC20(token);
        ltoken.safeApprove(address(curveFiDeposit), MAX_UINT256);
        decimals[token] = ERC20Detailed(token).decimals();
        emit TokenRegistered(token);
    }

    function _unregisterToken(address token) private {

        uint256 balance = IERC20(token).balanceOf(address(this));

        if (balance > 0){
            withdraw(token, _msgSender(), balance);   //This updates withdrawalsSinceLastDistribution
        }
        emit TokenUnregistered(token);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.12;

contract ICurveFiDeposit_Y { 

    function add_liquidity (uint256[4] calldata uamounts, uint256 min_mint_amount) external;
    function remove_liquidity (uint256 _amount, uint256[4] calldata min_uamounts) external;
    function remove_liquidity_imbalance (uint256[4] calldata uamounts, uint256 max_burn_amount) external;
}


pragma solidity ^0.5.12;

contract IYErc20 { 


    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function deposit(uint256 amount) external;

    function withdraw(uint256 shares) external;

    function getPricePerFullShare() external view returns (uint256);


    function token() external returns(address);


}


pragma solidity ^0.5.12;




contract CurveFiProtocol_Y_Base is CurveFiProtocol {


    struct PriceData {
        uint256 price;
        uint256 lastUpdateBlock;
    }

    address[] public yTokens;
    mapping(address=>PriceData) internal yPricePerFullShare;

    function upgrade() public onlyOwner() {

        require(yTokens.length == 0, "CurveFiProtocol_Y_Base: already upgraded"); 
        for(uint256 i=0; i<_registeredTokens.length; i++) {
            address yToken = curveFiDeposit.coins(int128(i));
            yTokens.push(yToken);
        }
    }

    function setCurveFi(address deposit, address liquidityGauge) public onlyDefiOperator {

        super.setCurveFi(deposit, liquidityGauge);
        for(uint256 i=0; i<_registeredTokens.length; i++) {
            address yToken = curveFiDeposit.coins(int128(i));
            yTokens.push(yToken);
        }
    }

    function balanceOf(address token) public returns(uint256) {

        uint256 tokenIdx = getTokenIndex(token);

        uint256 cfBalance = curveFiTokenBalance();
        uint256 cfTotalSupply = curveFiToken.totalSupply();
        uint256 yTokenCurveFiBalance = curveFiSwap.balances(int128(tokenIdx));
        
        uint256 yTokenShares = yTokenCurveFiBalance.mul(cfBalance).div(cfTotalSupply);
        uint256 tokenBalance = getPricePerFullShare(yTokens[tokenIdx]).mul(yTokenShares).div(1e18); //getPricePerFullShare() returns balance of underlying token multiplied by 1e18

        return tokenBalance;
    }
    
    function balanceOfAll() public returns(uint256[] memory balances) {

        IERC20 cfToken = IERC20(curveFiDeposit.token());
        uint256 cfBalance = curveFiTokenBalance();
        uint256 cfTotalSupply = cfToken.totalSupply();

        balances = new uint256[](_registeredTokens.length);
        for (uint256 i=0; i < _registeredTokens.length; i++){
            uint256 ycfBalance = curveFiSwap.balances(int128(i));
            uint256 yShares = ycfBalance.mul(cfBalance).div(cfTotalSupply);
            balances[i] = getPricePerFullShare(yTokens[i]).mul(yShares).div(1e18); //getPricePerFullShare() returns balance of underlying token multiplied by 1e18
        }
    }

    function lastYPricePerFullShare(address yToken) public view returns(uint256 lastUpdateBlock, uint256 price) {

        PriceData storage pd = yPricePerFullShare[yToken];
        return (pd.lastUpdateBlock, pd.price);
    }

    function getPricePerFullShare(address yToken) internal returns(uint256) {

        PriceData storage pd = yPricePerFullShare[yToken];
        if(pd.lastUpdateBlock < block.number) {
            pd.price = IYErc20(yToken).getPricePerFullShare();
            pd.lastUpdateBlock = block.number;
        }
        return pd.price;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.12;



contract CurveFiProtocol_Y is CurveFiProtocol_Y_Base {

    uint256 private constant N_COINS = 4;

    function nCoins() internal returns(uint256) {

        return N_COINS;
    }

    function convertArray(uint256[] memory amounts) internal pure returns(uint256[N_COINS] memory) {

        require(amounts.length == N_COINS, "CurveFiProtocol_Y: wrong token count");
        uint256[N_COINS] memory amnts = [uint256(0), uint256(0), uint256(0), uint256(0)];
        for(uint256 i=0; i < N_COINS; i++){
            amnts[i] = amounts[i];
        }
        return amnts;
    }

    function deposit_add_liquidity(uint256[] memory amounts, uint256 min_mint_amount) internal {

        ICurveFiDeposit_Y(address(curveFiDeposit)).add_liquidity(convertArray(amounts), min_mint_amount);
    }

    function deposit_remove_liquidity_imbalance(uint256[] memory amounts, uint256 max_burn_amount) internal {

        ICurveFiDeposit_Y(address(curveFiDeposit)).remove_liquidity_imbalance(convertArray(amounts), max_burn_amount);
    }

}