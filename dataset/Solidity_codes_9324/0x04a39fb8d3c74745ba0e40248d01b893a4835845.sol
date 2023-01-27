

pragma solidity 0.6.12;





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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
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



pragma solidity ^0.6.0;

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
}



pragma solidity ^0.6.0;


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
}



pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}




interface INBUNIERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

interface ICOREGlobals {

    function TransferHandler() external returns (address);

    function CoreBuyer() external returns (address);

}
interface ICOREBuyer {

    function ensureFee(uint256, uint256, uint256) external;  

}
interface ICORETransferHandler{

    function getVolumeOfTokenInCoreBottomUnits(address) external returns(uint256);

}

contract FannyVault is OwnableUpgradeSafe {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Deposit(address indexed by, address indexed forWho, uint256 indexed depositID, uint256 amount, uint256 multiplier);
    event Withdraw(address indexed user, uint256 indexed creditPenalty, uint256 amount);
    event COREBurned(address indexed from, uint256 value);

    struct UserDeposit {
        uint256 amountCORE;
        uint256 startedLockedTime;
        uint256 amountTimeLocked;
        uint256 multiplier;
        bool withdrawed;
    }

    struct UserInfo {
        uint256 amountCredit; // This is with locking multiplier
        uint256 rewardDebt; 
        UserDeposit[] deposits;
    }


    struct PoolInfo {
        uint256 accFannyPerShare; 
        bool withdrawable; 
        bool depositable;
    }

    IERC20 public CORE;
    IERC20 public FANNY;

    address public COREBurnPileNFT;

    PoolInfo public fannyPoolInfo;
    mapping(address => UserInfo) public userInfo;

    uint256 public totalFarmableFannies;

    uint256 public blocksFarmingActive;
    uint256 public blockFarmingStarted;
    uint256 public blockFarmingEnds;
    uint256 public fannyPerBlock;
    uint256 public totalShares;
    uint256 public totalBlocksToCreditRemaining;
    uint256 private lastBlockUpdate;
    uint256 private coreBalance;
    bool private locked;

    modifier lock() {

        require(locked == false, 'FANNY Vault: LOCKED');
        locked = true;
        _;
        locked = false;
    }

    function initialize(address _fanny, uint256 farmableFanniesInWholeUnits, uint256 _blocksFarmingActive) public initializer {

        OwnableUpgradeSafe.__Ownable_init();
        CORE = IERC20(0x62359Ed7505Efc61FF1D56fEF82158CcaffA23D7);
        FANNY = IERC20(_fanny);

        totalFarmableFannies = farmableFanniesInWholeUnits*1e18;
        blocksFarmingActive = _blocksFarmingActive;
    }

    function startFarming() public onlyOwner {

        require(FANNY.balanceOf(address(this)) == totalFarmableFannies, "Not enough fannies in the contract - shameful");
        blockFarmingStarted = block.number + 300; // 300 is for deposits to roll in before rewards start
        lastBlockUpdate = block.number + 300; // 300 is for deposits to roll in before rewards start
        blockFarmingEnds = blockFarmingStarted.add(blocksFarmingActive);
        totalBlocksToCreditRemaining = blockFarmingEnds.sub(blockFarmingStarted);
        fannyPerBlock = totalFarmableFannies.div(totalBlocksToCreditRemaining);
        fannyPoolInfo.depositable = true;

        fannyPoolInfo.withdrawable = true;

    }

    function fanniesLeft() public view returns (uint256) {

        return totalBlocksToCreditRemaining * fannyPerBlock;
    }

    function _burn(uint256 _amount) internal {

        require(COREBurnPileNFT !=  address(0), "Burning NFT is not set");
        safeWithdrawCORE(COREBurnPileNFT, _amount) ;
        emit COREBurned(msg.sender, _amount);
    }

    function setBurningNFT(address _burningNFTAddress) public onlyOwner {

        require(COREBurnPileNFT == address(0), "Already set");
        COREBurnPileNFT = _burningNFTAddress;
    }


    function toggleWithdrawals(bool _withdrawable) public onlyOwner {

        fannyPoolInfo.withdrawable = _withdrawable;
    }
    function toggleDepositable(bool _depositable) public onlyOwner {

        fannyPoolInfo.depositable = _depositable;
    }

    function fannyReadyToClaim(address _user) public view returns (uint256) {

        PoolInfo memory pool = fannyPoolInfo;
        UserInfo memory user = userInfo[_user];
        uint256 accFannyPerShare = pool.accFannyPerShare;

        return user.amountCredit.mul(accFannyPerShare).div(1e12).sub(user.rewardDebt);
    }


    function updatePool() public  { // This is safe to be called publically caues its deterministic

        if(lastBlockUpdate == block.number) {  return; } // save gas on consecutive same block calls
        if(totalShares == 0) {  return; } // div0 error
        if(blockFarmingStarted > block.number ) { return; }
        PoolInfo storage pool = fannyPoolInfo;
        uint256 deltaBlocks = block.number.sub(lastBlockUpdate);
        if(deltaBlocks > totalBlocksToCreditRemaining) {
            deltaBlocks = totalBlocksToCreditRemaining;
        }
        uint256 numFannyToCreditpool = deltaBlocks.mul(fannyPerBlock);
        totalBlocksToCreditRemaining = totalBlocksToCreditRemaining.sub(deltaBlocks);
        uint256 fannyPerShare = numFannyToCreditpool.mul(1e12).div(totalShares);
        pool.accFannyPerShare = pool.accFannyPerShare.add(fannyPerShare);
        lastBlockUpdate = block.number;
    }


    function changeTotalBlocksRemaining(uint256 amount, bool isSubstraction) public onlyOwner {

        if(isSubstraction) {
            totalBlocksToCreditRemaining = totalBlocksToCreditRemaining.sub(amount);
        } else {
            totalBlocksToCreditRemaining = totalBlocksToCreditRemaining.add(amount);
        }
    }

    function totalWithdrawableCORE(address user) public view returns (uint256 withdrawableCORE) {

        UserInfo memory user = userInfo[user];
        uint256 lengthUserDeposits = user.deposits.length;

        for (uint256 i = 0; i < lengthUserDeposits; i++) {
            UserDeposit memory currentDeposit = user.deposits[i]; // MEMORY BE CAREFUL

            if(currentDeposit.withdrawed == false  // If it has not yet been withdrawed
                        &&  // And
                block.timestamp > currentDeposit.startedLockedTime.add(currentDeposit.amountTimeLocked)) 
                {
                    uint256 amountCOREInThisDeposit = currentDeposit.amountCORE; //gas savings we use it twice
                    withdrawableCORE = withdrawableCORE.add(amountCOREInThisDeposit);
                }
        }
    }


    function totalDepositedCOREAndNotWithdrawed(address user) public view returns (uint256 totalDeposited) {

        UserInfo memory user = userInfo[user];
        uint256 lengthUserDeposits = user.deposits.length;

        for (uint256 i = 0; i < lengthUserDeposits; i++) {
            UserDeposit memory currentDeposit = user.deposits[i]; 
            if(currentDeposit.withdrawed == false) {
                uint256 amountCOREInThisDeposit = currentDeposit.amountCORE; 
                totalDeposited = totalDeposited.add(amountCOREInThisDeposit);
            }
        }
    }



    function numberDepositsOfuser(address user) public view returns (uint256) {

        UserInfo memory user = userInfo[user];
        return user.deposits.length;
    }



    function _deposit(uint256 _amount, uint256 multiplier, address forWho) internal {

        require(block.number < blockFarmingEnds, "Farming has ended or not started");
        PoolInfo storage pool = fannyPoolInfo; // Just memory is fine we don't write to it.
        require(pool.depositable, "Pool Deposits are closed");
        UserInfo storage user = userInfo[forWho];

        require(multiplier <= 25, "Sanity check failure for multiplier");
        require(multiplier > 0, "Sanity check failure for multiplier");

        uint256 depositID = user.deposits.length;
        if(multiplier != 25) { // multiplier of 25 is a burn
            user.deposits.push(
                UserDeposit({
                    amountCORE : _amount,
                    startedLockedTime : block.timestamp,
                    amountTimeLocked : multiplier > 1 ? multiplier * 4 weeks : 0,
                    withdrawed : false,
                    multiplier : multiplier
                })
            );
        }

        _amount = _amount.mul(multiplier); // Safe math just in case
        updatePool();
        
        updateAndPayOutPending(forWho);

        if(_amount > 0) {
            user.amountCredit = user.amountCredit.add(_amount);
        }

        user.rewardDebt = user.amountCredit.mul(pool.accFannyPerShare).div(1e12);
        totalShares = totalShares.add(_amount);
    
        emit Deposit(msg.sender, forWho, depositID, _amount, multiplier);
    }


    function burnFor25XCredit(uint256 _amount) lock public {

        safeTransferCOREFromPersonToThisContract(_amount, msg.sender);
        _burn(_amount);
        _deposit(_amount, 25, msg.sender);
    }


    function deposit(uint256 _amount, uint256 lockTimeWeeks) lock public {

        safeTransferCOREFromPersonToThisContract(_amount, msg.sender);
       _deposit(_amount, getMultiplier(lockTimeWeeks), msg.sender);
    }

    function depositFor(uint256 _amount, uint256 lockTimeWeeks, address forWho) lock public {

        safeTransferCOREFromPersonToThisContract(_amount, msg.sender);
       _deposit(_amount, getMultiplier(lockTimeWeeks), forWho);

    }

    function getMultiplier(uint256 lockTimeWeeks) internal pure returns (uint256 multiplier) {

        require(lockTimeWeeks <= 48, "Lock time is too large.");
        if(lockTimeWeeks >= 8) { // Multiplier starts now
            multiplier = lockTimeWeeks/4; // max 12 min 2 in this branch
        } else {
            multiplier = 1; // else multiplier is 1 and is non-locked
        }
    }

    function safeTransferCOREFromPersonToThisContract(uint256 _amount, address person) internal {

        uint256 beforeBalance = CORE.balanceOf(address(this));
        safeTransferFrom(address(CORE), person, address(this), _amount);
        uint256 afterBalance = CORE.balanceOf(address(this));
        require(afterBalance.sub(beforeBalance) == _amount, "Didn't get enough CORE, most likely FOT is ON");
    }


    function withdrawAllWithdrawableCORE() lock public {

        UserInfo memory user = userInfo[msg.sender];// MEMORY BE CAREFUL
        uint256 lenghtUserDeposits = user.deposits.length;
        require(user.amountCredit > 0, "Nothing to withdraw 1");
        require(lenghtUserDeposits > 0, "No deposits");
        uint256 withdrawableCORE;
        uint256 creditPenalty;

        for (uint256 i = 0; i < lenghtUserDeposits; i++) {
            UserDeposit memory currentDeposit = user.deposits[i]; // MEMORY BE CAREFUL
            if(currentDeposit.withdrawed == false  // If it has not yet been withdrawed
                        &&  // And
                block.timestamp > currentDeposit.startedLockedTime.add(currentDeposit.amountTimeLocked)) 
                {

                    userInfo[msg.sender].deposits[i].withdrawed = true; // this writes to storage
                    uint256 amountCOREInThisDeposit = currentDeposit.amountCORE; //gas savings we use it twice

                    creditPenalty = creditPenalty.add(amountCOREInThisDeposit.mul(currentDeposit.multiplier));
                    withdrawableCORE = withdrawableCORE.add(amountCOREInThisDeposit);
                }
        }

        require(withdrawableCORE > 0, "Nothing to withdraw 2");
        require(creditPenalty >= withdrawableCORE, "Sanity check failure. Penalty should be bigger or equal to withdrawable");

        _withdraw(msg.sender, msg.sender, withdrawableCORE, creditPenalty);

    }


    function _withdraw(address from, address to, uint256 amountToWithdraw, uint256 creditPenalty) internal {

        PoolInfo storage pool = fannyPoolInfo; 
        require(pool.withdrawable, "Withdrawals are closed.");
        UserInfo storage user = userInfo[from];

        updatePool();
        updateAndPayOutPending(from);
        user.amountCredit = user.amountCredit.sub(creditPenalty, "Coudn't validate user credit amounts");
        user.rewardDebt = user.amountCredit.mul(pool.accFannyPerShare).div(1e12); // divide out the change buffer
        totalShares = totalShares.sub(creditPenalty, "Coudn't validate total shares");
        safeWithdrawCORE(to, amountToWithdraw);
        emit Withdraw(from, creditPenalty, amountToWithdraw);
    }

    function claimFanny(address forWho) public lock {

        UserInfo storage user = userInfo[forWho];
        PoolInfo storage pool = fannyPoolInfo; // Just memory is fine we don't write to it.
        updatePool();
        updateAndPayOutPending(forWho);
        user.rewardDebt = user.amountCredit.mul(pool.accFannyPerShare).div(1e12); 
    } 

    function claimFanny() public {

        claimFanny(msg.sender);
    }
    
    function withdrawDeposit(uint256 depositID) public lock {

        _withdrawDeposit(depositID, msg.sender, msg.sender);
    }
    

    function _withdrawDeposit(uint256 depositID, address from, address to)  internal   {

        UserDeposit memory currentDeposit = userInfo[from].deposits[depositID]; // MEMORY BE CAREFUL

        uint256 creditPenalty;
        uint256 withdrawableCORE;

        if(
            currentDeposit.withdrawed == false && 
            block.timestamp > currentDeposit.startedLockedTime.add(currentDeposit.amountTimeLocked)) 
        {
            userInfo[from].deposits[depositID].withdrawed = true; // this writes to storage
            uint256 amountCOREInThisDeposit = currentDeposit.amountCORE; //gas savings we use it twice

            creditPenalty = creditPenalty.add(amountCOREInThisDeposit.mul(currentDeposit.multiplier));
            withdrawableCORE = withdrawableCORE.add(amountCOREInThisDeposit);
        }

        require(withdrawableCORE > 0, "Nothing to withdraw");
        require(creditPenalty >= withdrawableCORE, "Sanity check failure. Penalty should be bigger or equal to withdrawable");
        require(creditPenalty > 0, "Sanity fail, withdrawing CORE and inccuring no credit penalty");
        _withdraw(from, to, withdrawableCORE, creditPenalty);

    }


    function updateAndPayOutPending(address from) internal {

        uint256 pending = fannyReadyToClaim(from);
        if(pending > 0) {
            safeFannyTransfer(from, pending);
        }
    }


    function safeFannyTransfer(address _to, uint256 _amount) internal {

        
        uint256 _fannyBalance = FANNY.balanceOf(address(this));

        if (_amount > _fannyBalance) {
            safeTransfer(address(FANNY), _to, _fannyBalance);
        } else {
            safeTransfer(address(FANNY), _to, _amount);
        }
    }

    function safeWithdrawCORE(address _to, uint256 _amount) internal {

        uint256 balanceBefore = CORE.balanceOf(_to);
        safeTransfer(address(CORE), _to, _amount);
        uint256 balanceAfter = CORE.balanceOf(_to);
        require(balanceAfter.sub(balanceBefore) == _amount, "Failed to withdraw CORE tokens successfully, make sure FOT is off");
    }


    function safeTransfer(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'MUH FANNY: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'MUH FANNY: TRANSFER_FROM_FAILED');
    }

}