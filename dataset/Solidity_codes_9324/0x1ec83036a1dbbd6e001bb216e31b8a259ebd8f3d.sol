
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


interface IBrincGovToken is IERC20Upgradeable {

    function mint(address _to, uint256 _amount) external;


    function mintToTreasury(uint256 _amount) external;


    function getTreasuryOwner() external view returns (address);

}

interface IStakedBrincGovToken {

    function mint(address _to, uint256 _amount) external;


    function burnFrom(address _to, uint256 _amount) external;

}


contract BrincStaking is OwnableUpgradeable {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for IBrincGovToken;
    enum StakeMode {MODE1, MODE2, MODE3, MODE4, MODE5, MODE6}
    struct UserInfo {
        uint256 brcStakedAmount; // Amount of BRC tokens the user will stake.
        uint256 gBrcStakedAmount; // Amount of gBRC tokens the user will stake.
        uint256 blockNumber; // Stake block number.
        uint256 rewardDebt; // Receivable reward. See explanation below.
        StakeMode mode; // Stake mode


    }
    struct PoolInfo {
        uint256 supply; // Weighted balance of Brinc tokens in the pool
        uint256 lockBlockCount; // Lock block count
        uint256 weight; // Weight for the pool
        uint256 accGovBrincPerShare; // Accumulated govBrinc tokens per share, times 1e12. See below.
        bool brcOnly;
    }

    uint256 lastRewardBlock;

    IERC20Upgradeable public brincToken;
    IBrincGovToken public govBrincToken;
    IStakedBrincGovToken public stakedGovBrincToken;
    uint256 public govBrincPerBlock;
    mapping(StakeMode => PoolInfo) public poolInfo;
    mapping(address => UserInfo[]) public userInfo;

    uint256 public ratioBrcToGov;

    uint256 public treasuryRewardBalance;

    bool public paused;
    uint256 public pausedBlock;

    uint256 private govTokenOverMinted;

    uint256 public govBrincTokenMaxSupply;

    event Deposit(address indexed user, uint256 amount, StakeMode mode);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event TreasuryMint(uint256 amount);

    event LockBlockCountChanged(
        StakeMode mode,
        uint256 oldLockBlockCount,
        uint256 newLockBlockCount
    );
    event WeightChanged(
        StakeMode mode,
        uint256 oldWeight,
        uint256 newWeight
    );
    event GovBrincPerBlockChanged(
        uint256 oldGovBrincPerBlock,
        uint256 newGovBrincPerBlock
    );
    event RatioBrcToGovChanged(
        uint256 oldRatioBrcToGov, 
        uint256 newRatioBrcToGov
    );

    event Paused();
    event Resumed();

    function initialize(
        IERC20Upgradeable _brincToken,
        IBrincGovToken _brincGovToken,
        IStakedBrincGovToken _stakedGovBrincToken,
        uint256 _govBrincPerBlock,
        uint256 _ratioBrcToGov,
        uint256 _govBrincTokenMaxSupply
    ) initializer public {

        brincToken = _brincToken;
        govBrincToken = _brincGovToken;
        stakedGovBrincToken = _stakedGovBrincToken;
        govBrincPerBlock = _govBrincPerBlock;
        lastRewardBlock = block.number;
        ratioBrcToGov = _ratioBrcToGov;
        govBrincTokenMaxSupply = _govBrincTokenMaxSupply;
        paused = false;
        pausedBlock = 0;
        poolInfo[StakeMode.MODE1] = PoolInfo({
            supply: 0,
            lockBlockCount: uint256(199384), // 30 days in block count. 1 block = 13 seconds
            weight: 10,
            accGovBrincPerShare: 0,
            brcOnly: true
        });
        poolInfo[StakeMode.MODE2] = PoolInfo({
            supply: 0,
            lockBlockCount: uint256(398769), // 60 days in block count. 1 block = 13 seconds
            weight: 15,
            accGovBrincPerShare: 0,
            brcOnly: true
        });
        poolInfo[StakeMode.MODE3] = PoolInfo({
            supply: 0,
            lockBlockCount: uint256(598153), // 90 days in block count. 1 block = 13 seconds
            weight: 25,
            accGovBrincPerShare: 0,
            brcOnly: true
        });
        poolInfo[StakeMode.MODE4] = PoolInfo({
            supply: 0,
            lockBlockCount: uint256(199384), // 30 days in block count. 1 block = 13 seconds
            weight: 80,
            accGovBrincPerShare: 0,
            brcOnly: false
        });
        poolInfo[StakeMode.MODE5] = PoolInfo({
            supply: 0,
            lockBlockCount: uint256(398769), // 60 days in block count. 1 block = 13 seconds
            weight: 140,
            accGovBrincPerShare: 0,
            brcOnly: false
        });
        poolInfo[StakeMode.MODE6] = PoolInfo({
            supply: 0,
            lockBlockCount: uint256(598153), // 90 days in block count. 1 block = 13 seconds
            weight: 256,
            accGovBrincPerShare: 0,
            brcOnly: false
        });

        __Ownable_init();
    }

    modifier isNotPaused {

     require(paused == false, "paused: operations are paused by admin");
     _;
   }

    function pause() public onlyOwner {

        paused = true;
        pausedBlock = block.number;
        emit Paused();
    }

    function resume() public onlyOwner {

        paused = false;
        pausedBlock = 0;
        emit Resumed();
    }

    function isPaused() public view returns(bool) {

        return paused;
    }

    function getPausedBlock() public view returns(uint256) {

        return pausedBlock;
    }

    function getLastRewardBlock() public view returns(uint256) {

        return lastRewardBlock;
    }

    function getBrincTokenAddress() public view returns(address) {

        return address(brincToken);
    }

    function getGovTokenAddress() public view returns(address) {

        return address(govBrincToken);
    }

    function getGovBrincPerBlock() public view returns(uint256) {

        return govBrincPerBlock;
    }

    function getRatioBtoG() public view returns(uint256) {

        return ratioBrcToGov;
    }

    function getPoolSupply(StakeMode _mode) public view returns(uint256) {

        return poolInfo[_mode].supply;
    }

    function getPoolLockBlockCount(StakeMode _mode) public view returns(uint256) {

        return poolInfo[_mode].lockBlockCount;
    }
    
    function getPoolWeight(StakeMode _mode) public view returns(uint256) {

        return poolInfo[_mode].weight;
    }

    function getPoolAccGovBrincPerShare(StakeMode _mode) public view returns(uint256) {

        return poolInfo[_mode].accGovBrincPerShare;
    }

    function getUserInfo(address _address, uint256 _index) public view returns(UserInfo memory) {

        require(userInfo[_address].length > 0, "getUserInfo: user has not made any stakes");
        return userInfo[_address][_index];
    }

    function getStakeCount() public view returns (uint256) {

        return userInfo[_msgSender()].length;
    }

    function getTotalSupplyOfAllPools() private view returns (uint256) {

        uint256 totalSupply;

        totalSupply = totalSupply.add(
            poolInfo[StakeMode.MODE1].supply.mul(poolInfo[StakeMode.MODE1].weight)
        )
        .add(
            poolInfo[StakeMode.MODE2].supply.mul(poolInfo[StakeMode.MODE2].weight)
        )
        .add(
            poolInfo[StakeMode.MODE3].supply.mul(poolInfo[StakeMode.MODE3].weight)
        )
        .add(
            poolInfo[StakeMode.MODE4].supply.mul(poolInfo[StakeMode.MODE4].weight)
        )
        .add(
            poolInfo[StakeMode.MODE5].supply.mul(poolInfo[StakeMode.MODE5].weight)
        )
        .add(
            poolInfo[StakeMode.MODE6].supply.mul(poolInfo[StakeMode.MODE6].weight)
        );

        return totalSupply;
    }


    function pendingRewards(address _user, uint256 _id) public view returns (uint256, bool) {

        require(_id < userInfo[_user].length, "pendingRewards: invalid stake id");

        UserInfo storage user = userInfo[_user][_id];

        bool withdrawable; // false

        if (block.number >= user.blockNumber) {
            withdrawable = true;
        }

        PoolInfo storage pool = poolInfo[user.mode];
        uint256 accGovBrincPerShare = pool.accGovBrincPerShare;
        uint256 totalSupply = getTotalSupplyOfAllPools();
        if (block.number > lastRewardBlock && pool.supply != 0) {
            uint256 multiplier;
            if (paused) {
                multiplier = pausedBlock.sub(lastRewardBlock);
            } else {
                multiplier = block.number.sub(lastRewardBlock);
            }
            
            uint256 govBrincReward =
                multiplier
                    .mul(govBrincPerBlock)
                    .mul(pool.supply) // supply is the number of staked Brinc tokens
                    .mul(pool.weight)
                    .div(totalSupply);
            accGovBrincPerShare = accGovBrincPerShare.add(
                govBrincReward.mul(1e12).div(pool.supply)
            );
        }
        return
            (user.brcStakedAmount.mul(accGovBrincPerShare).div(1e12).sub(user.rewardDebt), withdrawable);
    }

    function totalRewards(address _user) external view returns (uint256) {

        UserInfo[] storage stakes = userInfo[_user];
        uint256 total;
        for (uint256 i = 0; i < stakes.length; i++) {
            (uint256 reward, bool withdrawable) = pendingRewards(_user, i);
            if (withdrawable) {
                total = total.add(reward);
            }
        }

        return total;
    }

    function updateLockBlockCount(StakeMode _mode, uint256 _updatedLockBlockCount) public onlyOwner {

        PoolInfo storage pool = poolInfo[_mode];
        uint256 oldLockBlockCount = pool.lockBlockCount;
        pool.lockBlockCount = _updatedLockBlockCount;
        emit LockBlockCountChanged(_mode, oldLockBlockCount, _updatedLockBlockCount);
    }

    function updateWeight(StakeMode _mode, uint256 _weight) public onlyOwner {

        massUpdatePools();
        PoolInfo storage pool = poolInfo[_mode];
        uint256 oldWeight = pool.weight;
        pool.weight = _weight;
        emit WeightChanged(_mode, oldWeight, _weight);
    }

    function updateGovBrincPerBlock(uint256 _updatedGovBrincPerBlock) public onlyOwner {

        massUpdatePools();
        uint256 oldGovBrincPerBlock = govBrincPerBlock;
        govBrincPerBlock = _updatedGovBrincPerBlock;
        emit GovBrincPerBlockChanged(oldGovBrincPerBlock, govBrincPerBlock);
    }

    function updateRatioBrcToGov(uint256 _updatedRatioBrcToGov) public onlyOwner {

        uint256 oldRatioBrcToGov = ratioBrcToGov;
        ratioBrcToGov = _updatedRatioBrcToGov;
        emit RatioBrcToGovChanged(oldRatioBrcToGov, ratioBrcToGov);
    }

    function updateGovBrincTokenMaxSupply(uint256 _updatedGovBrincTokenMaxSupply) public onlyOwner {

        uint256 oldGovBrincTokenMaxSupply = govBrincTokenMaxSupply;
        govBrincTokenMaxSupply = _updatedGovBrincTokenMaxSupply;
        emit RatioBrcToGovChanged(oldGovBrincTokenMaxSupply, govBrincTokenMaxSupply);
    }

    function treasuryMint() public onlyOwner {

        require(treasuryRewardBalance > 0, "treasuryMint: not enough balance to mint");
        uint256 balanceToMint;
        balanceToMint = treasuryRewardBalance;
        treasuryRewardBalance = 0;
        govBrincToken.mintToTreasury(balanceToMint);
        emit TreasuryMint(balanceToMint);
    }

    function massUpdatePools() internal isNotPaused {

        uint256 totalSupply = getTotalSupplyOfAllPools();
        if (totalSupply == 0) {
            if (block.number > lastRewardBlock) {
                uint256 multiplier = block.number.sub(lastRewardBlock);
                uint256 unusedReward = multiplier.mul(govBrincPerBlock);
                treasuryRewardBalance = treasuryRewardBalance.add(unusedReward);
            }
        } else {
            uint256 govBrincReward;
            govBrincReward = govBrincReward.add(updatePool(StakeMode.MODE1));
            govBrincReward = govBrincReward.add(updatePool(StakeMode.MODE2));
            govBrincReward = govBrincReward.add(updatePool(StakeMode.MODE3));
            govBrincReward = govBrincReward.add(updatePool(StakeMode.MODE4));
            govBrincReward = govBrincReward.add(updatePool(StakeMode.MODE5));
            govBrincReward = govBrincReward.add(updatePool(StakeMode.MODE6));

            if (govTokenOverMinted >= govBrincReward) {
                govTokenOverMinted = govTokenOverMinted.sub(govBrincReward);
            } else {
                uint256 mintAmount = govBrincReward.sub(govTokenOverMinted);
                govTokenOverMinted = 0;
                uint256 gBRCTotalSupply = govBrincToken.totalSupply();
                if (gBRCTotalSupply.add(mintAmount) > govBrincTokenMaxSupply) {
                    mintAmount = govBrincTokenMaxSupply.sub(gBRCTotalSupply);
                }
                if (mintAmount > 0) {
                    govBrincToken.mint(address(this), mintAmount);
                }
            }
        }
        lastRewardBlock = block.number;
    }

    function updatePool(StakeMode mode) internal isNotPaused returns (uint256) {

        PoolInfo storage pool = poolInfo[mode];
        if (block.number <= lastRewardBlock) {
            return 0;
        }
        if (pool.supply == 0) {
            return 0;
        }
        uint256 totalSupply = getTotalSupplyOfAllPools();
        uint256 multiplier = block.number.sub(lastRewardBlock);
        uint256 govBrincReward =
            multiplier
                .mul(govBrincPerBlock)
                .mul(pool.supply)
                .mul(pool.weight)
                .div(totalSupply);
        pool.accGovBrincPerShare = pool.accGovBrincPerShare.add(
            govBrincReward.mul(1e12).div(pool.supply)
        );
        return govBrincReward;
    }

    function deposit(uint256 _amount, StakeMode _mode) public {

        require(_amount > 0, "deposit: invalid amount");
        UserInfo memory user;
        massUpdatePools();
        PoolInfo storage pool = poolInfo[_mode];
        brincToken.safeTransferFrom(msg.sender, address(this), _amount);
        user.brcStakedAmount = _amount;
        if (!pool.brcOnly) {
            govBrincToken.safeTransferFrom(
                msg.sender,
                address(this),
                _amount.mul(ratioBrcToGov).div(1e10)
            );
            user.gBrcStakedAmount = _amount.mul(ratioBrcToGov).div(1e10);
            stakedGovBrincToken.mint(msg.sender, user.gBrcStakedAmount);
        }
        user.blockNumber = block.number.add(pool.lockBlockCount);
        user.rewardDebt = user.brcStakedAmount.mul(pool.accGovBrincPerShare).div(1e12);
        user.mode = _mode;

        pool.supply = pool.supply.add(user.brcStakedAmount);
        emit Deposit(msg.sender, _amount, _mode);

        userInfo[msg.sender].push(user);
    }

    function withdraw(uint256 _id) public {

        require(_id < userInfo[msg.sender].length, "withdraw: invalid stake id");

        UserInfo memory user = userInfo[msg.sender][_id];
        require(user.brcStakedAmount > 0, "withdraw: nothing to withdraw");
        require(user.blockNumber <= block.number, "withdraw: stake is still locked");
        massUpdatePools();
        PoolInfo storage pool = poolInfo[user.mode];
        uint256 pending =
            user.brcStakedAmount.mul(pool.accGovBrincPerShare).div(1e12).sub(user.rewardDebt);
        safeGovBrincTransfer(msg.sender, pending + user.gBrcStakedAmount);
        stakedGovBrincToken.burnFrom(msg.sender, user.gBrcStakedAmount);
        uint256 _amount = user.brcStakedAmount;
        brincToken.safeTransfer(msg.sender, _amount);
        pool.supply = pool.supply.sub(_amount);
        emit Withdraw(msg.sender, _amount);

        _removeStake(msg.sender, _id);
    }

    function emergencyWithdraw(uint256 _id) public {

        require(_id < userInfo[msg.sender].length, "emergencyWithdraw: invalid stake id");

        UserInfo storage user = userInfo[msg.sender][_id];
        require(user.brcStakedAmount > 0, "emergencyWithdraw: nothing to withdraw");
        PoolInfo storage pool = poolInfo[user.mode];
        safeGovBrincTransfer(msg.sender, user.gBrcStakedAmount);
        stakedGovBrincToken.burnFrom(msg.sender, user.gBrcStakedAmount);

        uint256 pendingReward =
            user.brcStakedAmount.mul(pool.accGovBrincPerShare).div(1e12).sub(user.rewardDebt);
        govTokenOverMinted = govTokenOverMinted.add(pendingReward);

        delete user.gBrcStakedAmount;
        uint256 _amount = user.brcStakedAmount;
        delete user.brcStakedAmount;
        brincToken.safeTransfer(msg.sender, _amount);
        pool.supply = pool.supply.sub(_amount);
        emit EmergencyWithdraw(msg.sender, _amount);

        _removeStake(msg.sender, _id);
    }

    function _removeStake(address _user, uint256 _id) internal {

        userInfo[_user][_id] = userInfo[_user][userInfo[_user].length - 1];
        userInfo[_user].pop();
    }

    function safeGovBrincTransfer(address _to, uint256 _amount) internal {

        uint256 govBrincBal = govBrincToken.balanceOf(address(this));
        if (_amount > govBrincBal) {
            govBrincToken.transfer(_to, govBrincBal);
        } else {
            govBrincToken.transfer(_to, _amount);
        }
    }

    function rescueTokens(address to, IERC20Upgradeable token) public onlyOwner {

        uint bal = token.balanceOf(address(this));
        require(bal > 0);
        token.transfer(to, bal);
    }
}