
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
}// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol

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
}// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// File: @openzeppelin/contracts/utils/Address.sol

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

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function decimals() external view returns (uint8) {

        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");


        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");


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

}// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
}// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

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
}// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.6.0;


contract Ownable is ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function init(address sender) public initializer {

        _owner = sender;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.6.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// File: @openzeppelin/contracts/utils/EnumerableSet.sol

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
}// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
pragma experimental ABIEncoderV2;

pragma solidity 0.6.12;



interface Dao {

    function getVotingStatus(address _user) external view returns (bool);

}

contract MasterChef is Ownable, ReentrancyGuardUpgradeable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt;
        bool cooldown;
        uint256 timestamp;
        uint256 totalUserBaseMul;
        uint256 totalReward;
        uint256 cooldowntimestamp;
        uint256 preBlockReward;
        uint256 totalClaimedReward;
        uint256 claimedToday;
        uint256 claimedTimestamp;
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 lastRewardBlock; // Last block number that ASTRs distribution occurs.
        uint256 accASTRPerShare; // Accumulated ASTRs per share, times 1e12. See below.
        uint256 totalBaseMultiplier; // Total rm count of all user
    }

    address public ASTR;
    address public lmpooladdr;
    address public daaAddress;
    address public daoAddress;
    address public devaddr;
    uint256 public bonusEndBlock;
    uint256 public ASTRPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 1; //no Bonus
    mapping(IERC20 => bool) public lpTokensStatus;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public startBlock;
    address public timelock;
    mapping(uint256 => bool) public vaultList;

    struct StakeInfo {
        uint256 amount;
        uint256 totalAmount;
        uint256 timestamp;
        uint256 vault;
        bool deposit;
    }

    mapping(uint256 => mapping(address => uint256)) private userStakingTrack;
    mapping(uint256 => mapping(address => mapping(uint256 => StakeInfo)))
        public stakeInfo;
    mapping(uint256 => mapping(address => uint256)) public coolDownStart;
    uint256 private dayseconds = 86400;
    mapping(uint256 => address[]) public userAddressesInPool;
    enum RewardType {INDIVIDUAL, FLAT, TVL_ADJUSTED}
    uint256 public ASTRPoolId;
    uint256 private ABP = 6500;

    struct HighestAstaStaker {
        uint256 deposited;
        address addr;
    }
    mapping(uint256 => HighestAstaStaker[]) public highestStakerInPool;

    modifier onlyDaaOrDAO() {

        require(
            daaAddress == _msgSender() || daoAddress == _msgSender(),
            "depositFromDaaAndDAO: caller is not the DAA/DAO"
        );
        _;
    }

    modifier onlyDao() {

        require(daoAddress == _msgSender(), "Caller is not the DAO");
        _;
    }

    modifier onlyLmPool() {

        require(lmpooladdr == _msgSender(), "Caller is not the LmPool");
        _;
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    function initialize(
        address _astr,
        address _devaddr,
        uint256 _ASTRPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) external initializer {

        require(_astr != address(0), "Zero Address");
        require(_devaddr != address(0), "Zero Address");
        Ownable.init(_devaddr);
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        ASTR = _astr;
        devaddr = _devaddr;
        ASTRPerBlock = _ASTRPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function getStakerList(uint256 _pid) public view returns (HighestAstaStaker[] memory) {

        return highestStakerInPool[_pid];
    }

    function add(IERC20 _lpToken) external onlyOwner {

        require(address(_lpToken) != address(0), "Zero Address");
        require(lpTokensStatus[_lpToken] != true, "LP token already added");
        if (ASTR == address(_lpToken)) {
            ASTRPoolId = poolInfo.length;
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                lastRewardBlock: lastRewardBlock,
                accASTRPerShare: 0,
                totalBaseMultiplier: 0
            })
        );
        lpTokensStatus[_lpToken] = true;
    }

    function addVault(uint256 val) external onlyOwner {

        vaultList[val] = true;
    }

    function setLmPoolAddress(address _lmpooladdr) external onlyOwner {

        require(_lmpooladdr != address(0), "Zero Address");
        lmpooladdr = _lmpooladdr;
    }

    function setDaoAddress(address _daoAddress) external onlyOwner {

        require(_daoAddress != address(0), "Zero Address");
        daoAddress = _daoAddress;
    }

    function setTimeLockAddress(address _timeLock) external onlyOwner {

        require(_timeLock != address(0), "Zero Address");
        timelock = _timeLock;
    }

    function setDaaAddress(address _address) external {

        require(_address != address(0), "Zero Address");
        require(
            msg.sender == owner() || msg.sender == address(timelock),
            "Can only be called by the owner/timelock"
        );
        require(daaAddress != _address, "Already updated");
        daaAddress = _address;
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _to.sub(bonusEndBlock)
                );
        }
    }

    function getRewardMultiplier(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {

        uint256 lockupMultiplier = vaultMultiplier(_pid, _user);

        uint256 stakingscoreMultiplier = 10;
        uint256 stakingscoreval = stakingScore(_pid, _user);
        uint256 eightk = 800000 * 10**18;
        uint256 threek = 300000 * 10**18;
        uint256 onek = 100000 * 10**18;

        if (stakingscoreval >= eightk) {
            stakingscoreMultiplier = 17;
        } else if (stakingscoreval >= threek) {
            stakingscoreMultiplier = 13;
        } else if (stakingscoreval >= onek) {
            stakingscoreMultiplier = 12;
        }
        return stakingscoreMultiplier.add(lockupMultiplier).sub(10);
    }

    function vaultMultiplier(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {

        uint256 vaultMul;
        uint256 depositCount;
        uint256 countofstake = userStakingTrack[_pid][_user];
        for (uint256 i = 1; i <= countofstake; i++) {
            StakeInfo memory stkInfo = stakeInfo[_pid][_user][i];
            if (stkInfo.deposit == true) {
                depositCount++;
                if (stkInfo.vault == 12) {
                    vaultMul = vaultMul.add(18);
                } else if (stkInfo.vault == 9) {
                    vaultMul = vaultMul.add(13);
                } else if (stkInfo.vault == 6) {
                    vaultMul = vaultMul.add(11);
                } else {
                    vaultMul = vaultMul.add(10);
                }
            }
        }
        if (depositCount > 0) {
            return vaultMul.div(depositCount);
        } else {
            return 10;
        }
    }

    function getPremiumPayoutBonus(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {

        uint256 stakingscoreaddition;
        uint256 stakingscorevalue = stakingScore(_pid, _user);
        uint256 eightk = 800000 * 10**18;
        uint256 threek = 300000 * 10**18;
        uint256 onek = 100000 * 10**18;

        if (stakingscorevalue >= eightk) {
            stakingscoreaddition = 20;
        } else if (stakingscorevalue >= threek) {
            stakingscoreaddition = 10;
        } else if (stakingscorevalue >= onek) {
            stakingscoreaddition = 5;
        }
        return stakingscoreaddition;
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        uint256 vault
    ) external nonReentrant{

        require(vaultList[vault] == true, "no vault");
        PoolInfo storage pool = poolInfo[_pid];
        updateBlockReward(_pid, msg.sender);
        UserInfo storage user = userInfo[_pid][msg.sender];
        addUserAddress(msg.sender, _pid);
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
        }
        userStakingTrack[_pid][msg.sender] = userStakingTrack[_pid][msg.sender]
            .add(1);
        uint256 userstakeid = userStakingTrack[_pid][msg.sender];
        StakeInfo storage staker = stakeInfo[_pid][msg.sender][userstakeid];
        staker.amount = _amount;
        staker.totalAmount = user.amount;
        staker.timestamp = block.timestamp;
        staker.vault = vault;
        staker.deposit = true;

        user.timestamp = block.timestamp;
        addHighestStakedUser(_pid, user.amount, msg.sender);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function depositFromDaaAndDAO(
        uint256 _pid,
        uint256 _amount,
        uint256 vault,
        address _sender,
        bool isPremium
    ) external onlyDaaOrDAO nonReentrant{

        require(vaultList[vault] == true, "no vault");
        PoolInfo storage pool = poolInfo[_pid];
        updateBlockReward(_pid, _sender);
        UserInfo storage user = userInfo[_pid][_sender];
        addUserAddress(_sender, _pid);
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            uint256 bonusAmount =
                getBonusAmount(_pid, _sender, _amount, isPremium);
            _amount = _amount.add(bonusAmount);            
            user.amount = user.amount.add(_amount);
        }
        userStakingTrack[_pid][_sender] = userStakingTrack[_pid][_sender].add(
            1
        );
        uint256 userstakeid = userStakingTrack[_pid][_sender];
        StakeInfo storage staker = stakeInfo[_pid][_sender][userstakeid];
        staker.amount = _amount;
        staker.totalAmount = user.amount;
        staker.timestamp = block.timestamp;
        staker.vault = vault;
        staker.deposit = true;

        user.timestamp = block.timestamp;
        addHighestStakedUser(_pid, user.amount, _sender);
        emit Deposit(_sender, _pid, _amount);
    }

    function getBonusAmount(
        uint256 _pid,
        address _user,
        uint256 _amount,
        bool isPremium
    ) private view returns (uint256) {

        uint256 ppb;
        if (isPremium) {
            ppb = getPremiumPayoutBonus(_pid, _user).add(20);
        } else {
            ppb = getPremiumPayoutBonus(_pid, _user);
        }
        uint256 bonusAmount = _amount.mul(ppb).div(1000);
        return bonusAmount;
    }

    function withdraw(uint256 _pid, bool _withStake) external {

        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = viewEligibleAmount(_pid, msg.sender);
        require(_amount > 0, "withdraw: not good");
        if (user.cooldown == false) {
            user.cooldown = true;
            user.cooldowntimestamp = block.timestamp;
            return;
        } else {
            if (
                block.timestamp > user.cooldowntimestamp.add(dayseconds.mul(8))
            ) {
                user.cooldown = true;
                user.cooldowntimestamp = block.timestamp;
                return;
            } else {
                require(user.cooldown == true, "withdraw: cooldown status");
                require(
                    block.timestamp >=
                        user.cooldowntimestamp.add(dayseconds.mul(7)),
                    "withdraw: cooldown period"
                );
                require(
                    block.timestamp <=
                        user.cooldowntimestamp.add(dayseconds.mul(8)),
                    "withdraw: open window"
                );
                _withdraw(_pid, _withStake);
            }
        }
    }

    function _withdraw(uint256 _pid, bool _withStake) private {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        withdrawASTRReward(_pid, _withStake);
        uint256 _amount = checkEligibleAmount(_pid, msg.sender, true);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accASTRPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        user.cooldown = false;
        user.cooldowntimestamp = 0;
        user.totalUserBaseMul = 0;
        removeHighestStakedUser(_pid, user.amount, msg.sender);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function viewEligibleAmount(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {

        uint256 eligibleAmount = 0;
        uint256 countofstake = userStakingTrack[_pid][_user];
        for (uint256 i = 1; i <= countofstake; i++) {
            StakeInfo storage stkInfo = stakeInfo[_pid][_user][i];
            if (stkInfo.deposit == true) {
                uint256 mintsec = 86400;
                uint256 vaultdays = stkInfo.vault.mul(30);
                uint256 timeaftervaultmonth =
                    stkInfo.timestamp.add(vaultdays.mul(mintsec));
                if (block.timestamp >= timeaftervaultmonth) {
                    eligibleAmount = eligibleAmount.add(stkInfo.amount);
                }
            }
        }
        return eligibleAmount;
    }

    function checkEligibleAmount(
        uint256 _pid,
        address _user,
        bool _withUpdate
    ) private returns (uint256) {

        uint256 eligibleAmount = 0;
        uint256 countofstake = userStakingTrack[_pid][_user];
        for (uint256 i = 1; i <= countofstake; i++) {
            StakeInfo storage stkInfo = stakeInfo[_pid][_user][i];
            if (stkInfo.deposit == true) {
                uint256 mintsec = 86400;
                uint256 vaultdays = stkInfo.vault.mul(30);
                uint256 timeaftervaultmonth =
                    stkInfo.timestamp.add(vaultdays.mul(mintsec));
                if (block.timestamp >= timeaftervaultmonth) {
                    eligibleAmount = eligibleAmount.add(stkInfo.amount);
                    if (_withUpdate) {
                        stkInfo.deposit = false;
                    }
                }
            }
        }
        return eligibleAmount;
    }

    function emergencyWithdraw(uint256 _pid) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        user.amount = 0;
        user.totalReward = 0;
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdrawASTR(address recipient, uint256 amount)
        external
        onlyOwner
    {

        require(
            amount > 0 && recipient != address(0),
            "amount and recipient address can not be 0"
        );
        safeASTRTransfer(recipient, amount);
    }

    function safeASTRTransfer(address _to, uint256 _amount) internal {

        uint256 ASTRBal = IERC20(ASTR).balanceOf(address(this));
        require(!(_amount > ASTRBal), "Insufficient amount on chef contract");
        IERC20(ASTR).safeTransfer(_to, _amount);
    }

    function dev(address _devaddr) external {

        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function stakingScore(uint256 _pid, address _userAddress)
        public
        view
        returns (uint256)
    {

        uint256 timeofstakes;
        uint256 amountstaked;
        uint256 daysecondss = 86400;
        uint256 daysOfStakingscore = 60;
        UserInfo storage user = userInfo[_pid][_userAddress];
        uint256 countofstake = userStakingTrack[_pid][_userAddress];
        uint256 stakingscorenett = 0;
        uint256 userStakingScores = 0;

        for (uint256 i = 1; i <= countofstake; i++) {
            StakeInfo memory stkInfo = stakeInfo[_pid][_userAddress][i];
            if (stkInfo.deposit == true) {
                timeofstakes = stkInfo.timestamp;
                amountstaked = stkInfo.amount;
                uint256 vaultMonth = stkInfo.vault;
                stakingscorenett = calcstakingscore(
                    timeofstakes,
                    vaultMonth,
                    amountstaked,
                    stakingscorenett,
                    daysOfStakingscore,
                    daysecondss
                );
                userStakingScores = userStakingScores.add(stakingscorenett);
                if (userStakingScores > user.amount) {
                    userStakingScores = user.amount;
                }
            } else {
                userStakingScores = 0;
            }
        }
        return userStakingScores;
    }

    function calcstakingscore(
        uint256 timeofstakes,
        uint256 vaultMonth,
        uint256 amountstaked,
        uint256 stakingscorenett,
        uint256 daysOfStakingscore,
        uint256 daysecondss
    ) internal view returns (uint256) {

        uint256 stakeIndays = 0;
        uint256 month = 12;
        uint256 daysByMonthConstant = daysOfStakingscore.div(month);
        uint256 diffInTimestamp = block.timestamp.sub(timeofstakes);
        if (diffInTimestamp > daysecondss) {
            stakeIndays = diffInTimestamp.div(daysecondss);
        } else {
            stakeIndays = 0;
        }

        if (stakeIndays > 60) {
            stakeIndays = 60;
        }

        if (vaultMonth == 12) {
            if (stakeIndays == 0) {
                amountstaked = 0;
            }
            stakingscorenett = amountstaked;
        } else {
            if (vaultMonth != 0) {
                daysOfStakingscore = daysOfStakingscore.sub(
                    daysByMonthConstant.mul(vaultMonth)
                );
            }
            stakingscorenett = amountstaked.mul(stakeIndays).div(
                daysOfStakingscore
            );
        }
        return stakingscorenett;
    }

    function addUserAddress(address _user, uint256 _pid) private {

        address[] storage adds = userAddressesInPool[_pid];
        if (userStakingTrack[_pid][_user] == 0) {
            adds.push(_user);
        }
    }

    function distributeReward(
        uint256 _pid,
        RewardType _type,
        uint256 _amount
    ) external onlyOwner {

        if (_type == RewardType.INDIVIDUAL) {
            distributeIndividualReward(_pid, _amount);
        } else if (_type == RewardType.FLAT) {
            distributeFlatReward(_amount);
        } else if (_type == RewardType.TVL_ADJUSTED) {
            distributeTvlAdjustedReward(_amount);
        }
    }

    function distributeIndividualReward(uint256 _pid, uint256 _amount) private {

        uint256 poolBaseMul = 0;
        address[] memory adds = userAddressesInPool[_pid];
        for (uint256 i = 0; i < adds.length; i++) {
            UserInfo storage user = userInfo[_pid][adds[i]];
            uint256 mul = getRewardMultiplier(ASTRPoolId, adds[i]);
            user.totalUserBaseMul = user.amount.mul(mul);
            poolBaseMul = poolBaseMul.add(user.totalUserBaseMul);
        }
        for (uint256 i = 0; i < adds.length; i++) {
            UserInfo storage user = userInfo[_pid][adds[i]];
            uint256 sharePercentage =
                user.totalUserBaseMul.mul(10000).div(poolBaseMul);
            user.totalReward = user.totalReward.add(
                (_amount.mul(sharePercentage)).div(10000)
            );
        }
    }

    function distributeFlatReward(uint256 _amount) private {

        uint256 allPoolBaseMul = 0;
        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            address[] memory adds = userAddressesInPool[pid];
            for (uint256 i = 0; i < adds.length; i++) {
                UserInfo storage user = userInfo[pid][adds[i]];
                uint256 mul = getRewardMultiplier(ASTRPoolId, adds[i]);
                user.totalUserBaseMul = user.amount.mul(mul);
                allPoolBaseMul = allPoolBaseMul.add(user.totalUserBaseMul);
            }
        }

        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            address[] memory adds = userAddressesInPool[pid];
            for (uint256 i = 0; i < adds.length; i++) {
                UserInfo storage user = userInfo[pid][adds[i]];
                uint256 sharePercentage =
                    user.totalUserBaseMul.mul(10000).div(allPoolBaseMul);
                user.totalReward = user.totalReward.add(
                    (_amount.mul(sharePercentage)).div(10000)
                );
            }
        }
    }

    function distributeTvlAdjustedReward(uint256 _amount) private {

        uint256 totalTvl = 0;
        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            uint256 tvl = pool.lpToken.balanceOf(address(this));
            totalTvl = totalTvl.add(tvl);
        }
        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            uint256 tvl = pool.lpToken.balanceOf(address(this));
            uint256 poolRewardShare = tvl.mul(10000).div(totalTvl);
            uint256 reward = (_amount.mul(poolRewardShare)).div(10000);
            distributeIndividualReward(pid, reward);
        }
    }

    function addHighestStakedUser(
        uint256 _pid,
        uint256 _amount,
        address user
    ) private {

        uint256 i;
        HighestAstaStaker[] storage higheststaker = highestStakerInPool[_pid];
        for (i = 0; i < higheststaker.length; i++) {
            if (higheststaker[i].addr == user) {
                higheststaker[i].deposited = _amount;
                quickSort(_pid, 0, higheststaker.length - 1);
                return;
            }
        }

        if (higheststaker.length < 100) {
            higheststaker.push(HighestAstaStaker(_amount, user));
        } else {
            if (higheststaker[0].deposited < _amount) {
                higheststaker[0].deposited = _amount;
                higheststaker[0].addr = user;
            }
        }
        quickSort(_pid, 0, higheststaker.length - 1);
    }

    function checkHighestStaker(uint256 _pid, address user)
        external
        view
        returns (bool)
    {

        HighestAstaStaker[] storage higheststaker = highestStakerInPool[_pid];
        uint256 i = 0;
        for (i; i < higheststaker.length; i++) {
            if (higheststaker[i].addr == user) {
                return true;
            }
        }
    }

    function checkStakingScoreForDelegation(uint256 _pid, address user)
        external
        view
        returns (bool)
    {

        uint256 sscore = stakingScore(_pid, user);
        uint256 onek = 100000 * 10**18;
        if (sscore == onek) {
            return true;
        } else {
            return false;
        }
    }

    function updateBlockReward(uint256 _pid, address _sender) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 PoolEndBlock = block.number;
        if (block.number > bonusEndBlock) {
            PoolEndBlock = bonusEndBlock;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = PoolEndBlock;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, PoolEndBlock);
        uint256 blockReward = multiplier.mul(ASTRPerBlock);
        UserInfo storage currentUser = userInfo[_pid][_sender];
        uint256 totalPoolBaseMul = 0;
        address[] memory adds = userAddressesInPool[_pid];
        for (uint256 i = 0; i < adds.length; i++) {
            UserInfo storage user = userInfo[_pid][adds[i]];
            if (user.amount > 0) {
                uint256 mul = getRewardMultiplier(ASTRPoolId, adds[i]);
                if (_sender != adds[i]) {
                    user.preBlockReward = user.preBlockReward.add(blockReward);
                }
                totalPoolBaseMul = totalPoolBaseMul.add(user.amount.mul(mul));
            }
        }
        updateCurBlockReward(
            currentUser,
            blockReward,
            totalPoolBaseMul,
            _sender
        );
        pool.lastRewardBlock = PoolEndBlock;
    }

    function updateCurBlockReward(
        UserInfo storage currentUser,
        uint256 blockReward,
        uint256 totalPoolBaseMul,
        address _sender
    ) private {

        uint256 userBaseMul =
            currentUser.amount.mul(getRewardMultiplier(ASTRPoolId, _sender));
        uint256 totalBlockReward = blockReward.add(currentUser.preBlockReward);
        uint256 sharePercentage = userBaseMul.mul(10000).div(totalPoolBaseMul);
        currentUser.totalReward = currentUser.totalReward.add(
            (totalBlockReward.mul(sharePercentage).div(totalPoolBaseMul)).div(10000)
        );
        currentUser.preBlockReward = 0;
    }

    function viewRewardInfo(uint256 _pid) external view returns (uint256) {

        UserInfo memory currentUser = userInfo[_pid][msg.sender];
        PoolInfo memory pool = poolInfo[_pid];
        uint256 totalReward = currentUser.totalReward;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return totalReward;
        }

        if (block.number <= pool.lastRewardBlock) {
            return totalReward;
        }

        uint256 PoolEndBlock = block.number;
        if (block.number > bonusEndBlock) {
            PoolEndBlock = bonusEndBlock;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, PoolEndBlock);
        uint256 blockReward = multiplier.mul(ASTRPerBlock);

        uint256 totalPoolBaseMul = 0;
        address[] memory adds = userAddressesInPool[_pid];
        for (uint256 i = 0; i < adds.length; i++) {
            UserInfo storage user = userInfo[_pid][adds[i]];
            uint256 mul = getRewardMultiplier(ASTRPoolId, adds[i]);
            totalPoolBaseMul = totalPoolBaseMul.add(user.amount.mul(mul));
        }
        uint256 userBaseMul =
            currentUser.amount.mul(getRewardMultiplier(ASTRPoolId, msg.sender));
        uint256 totalBlockReward = blockReward.add(currentUser.preBlockReward);
        uint256 sharePercentage = userBaseMul.mul(10000).div(totalPoolBaseMul);
        return
            currentUser.totalReward.add(
                (totalBlockReward.mul(sharePercentage)).div(10000)
            );
    }

    function distributeExitFeeShare(uint256 _amount) external {

        require(_amount > 0, "Amount should not be zero");
        distributeIndividualReward(ASTRPoolId, _amount);
    }

    function quickSort(
        uint256 _pid,
        uint256 left,
        uint256 right
    ) internal {

        HighestAstaStaker[] storage arr = highestStakerInPool[_pid];
        if (left >= right) return;
        uint256 divtwo = 2;
        uint256 p = arr[(left + right) / divtwo].deposited; // p = the pivot element
        uint256 i = left;
        uint256 j = right;
        while (i < j) {
            while (arr[i].deposited < p) ++i;
            while (arr[j].deposited > p) --j; // arr[j] > p means p still to the left, so j > 0
            if (arr[i].deposited > arr[j].deposited) {
                (arr[i].deposited, arr[j].deposited) = (
                    arr[j].deposited,
                    arr[i].deposited
                );
                (arr[i].addr, arr[j].addr) = (arr[j].addr, arr[i].addr);
            } else ++i;
        }
        if (j > left) quickSort(_pid, left, j - 1); // j > left, so j > 0
        quickSort(_pid, j + 1, right);
    }

    function removeHighestStakedUser(uint256 _pid, uint256 _amount, address user) private {

        HighestAstaStaker[] storage highestStaker = highestStakerInPool[_pid];
        for (uint256 i = 0; i < highestStaker.length; i++) {
            if (highestStaker[i].addr == user) {
                delete highestStaker[i];
                if(_amount > 0) {
                    addHighestStakedUser(_pid, _amount, user);
                }
                return;
            }
        }
    }

    function votingPower(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        uint256 stakingsScore = stakingScore(_pid, _user);

        uint256 rewardMult = getRewardMultiplier(_pid, _user);
        uint256 votingpower = (stakingsScore.mul(rewardMult)).div(10);
        return votingpower;
    }

    function withdrawASTRReward(uint256 _pid, bool _withStake) public nonReentrant{


        updateBlockReward(_pid, msg.sender);
        UserInfo storage currentUser = userInfo[_pid][msg.sender];
        if (_withStake) {
            uint256 _amount = currentUser.totalReward;
            _stakeASTRReward(msg.sender, ASTRPoolId, _amount);
            updateClaimedReward(currentUser, _amount);
        } else {
            uint256 dayInSecond = 86400;
            uint256 dayCount =
                (block.timestamp.sub(currentUser.timestamp)).div(dayInSecond);
            if (dayCount >= 90) {
                dayCount = 90;
            }
            slashExitFee(currentUser, _pid, dayCount);
        }
        currentUser.totalReward = 0;
    }

    function stakeASTRReward(
        address _currUserAddr,
        uint256 _pid,
        uint256 _amount
    ) external onlyLmPool {

        _stakeASTRReward(_currUserAddr, _pid, _amount);
    }

    function _stakeASTRReward(
        address _currUserAddr,
        uint256 _pid,
        uint256 _amount
    ) private {

        UserInfo storage currentUser = userInfo[_pid][_currUserAddr];
        addUserAddress(_currUserAddr, _pid);
        if (_amount > 0) {
            currentUser.amount = currentUser.amount.add(_amount);
            userStakingTrack[_pid][_currUserAddr] = userStakingTrack[_pid][
                _currUserAddr
            ]
                .add(1);
            uint256 userstakeid = userStakingTrack[_pid][_currUserAddr];
            StakeInfo storage staker =
                stakeInfo[_pid][_currUserAddr][userstakeid];
            staker.amount = _amount;
            staker.totalAmount = currentUser.amount;
            staker.timestamp = block.timestamp;
            staker.vault = 3;
            staker.deposit = true;

            currentUser.timestamp = block.timestamp;
        }
    }

    function slashExitFee(
        UserInfo storage currentUser,
        uint256 _pid,
        uint256 dayCount
    ) private {

        uint256 totalReward = currentUser.totalReward;
        uint256 sfr = uint256(90).sub(dayCount);
        uint256 fee = totalReward.mul(sfr).div(100);
        uint256 claimableReward = totalReward.sub(fee);
        if (claimableReward > 0) {
            safeASTRTransfer(msg.sender, claimableReward);
            currentUser.totalReward = 0;
        }
        distributeIndividualReward(_pid, fee);
        updateClaimedReward(currentUser, claimableReward);
    }

    function updateClaimedReward(UserInfo storage currentUser, uint256 _amount) private {

        currentUser.totalClaimedReward = currentUser.totalClaimedReward.add(_amount);
        uint256 day = block.timestamp.sub(currentUser.claimedTimestamp).div(dayseconds);
        if(day == 0) {
            currentUser.claimedToday = currentUser.claimedToday.add(_amount);
        }else{
            currentUser.claimedToday = _amount;
            uint256 todayDaySeconds = block.timestamp % dayseconds;
            currentUser.claimedTimestamp = block.timestamp.sub(todayDaySeconds);
        }
    }

    function getTodayReward(uint256 _pid) external view returns (uint256) {

        UserInfo memory currentUser = userInfo[_pid][msg.sender];
        uint256 day = block.timestamp.sub(currentUser.claimedTimestamp).div(dayseconds);
        uint256 claimedToday;
        if(day == 0) {
            claimedToday = currentUser.claimedToday;
        }else{
            claimedToday = 0;
        }
        return claimedToday;
    }
}