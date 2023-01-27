pragma solidity ^0.6.0;

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

contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
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


contract PausableUpgradeSafe is Initializable, ContextUpgradeSafe {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;


    function __Pausable_init() internal initializer {

        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {



        _paused = false;

    }


    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
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
}// MIT

pragma solidity ^0.6.0;


contract BannedContractList is Initializable, OwnableUpgradeSafe {

    mapping(address => bool) banned;

    function initialize() public initializer {

        __Ownable_init();
    }

    function isApproved(address toCheck) external view returns (bool) {

        return !banned[toCheck];
    }

    function isBanned(address toCheck) external view returns (bool) {

        return banned[toCheck];
    }

    function approveContract(address toApprove) external onlyOwner {

        banned[toApprove] = false;
    }

    function banContract(address toBan) external onlyOwner {

        banned[toBan] = true;
    }
}// MIT

pragma solidity ^0.6.0;


contract Defensible {

  modifier defend(BannedContractList bannedContractList) {

    require(
      (msg.sender == tx.origin) || bannedContractList.isApproved(msg.sender),
      "This smart contract has not been approved"
    );
    _;
  }
}// MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IMushroomFactory  {

    function costPerMushroom() external returns (uint256);

    function getRemainingMintableForMySpecies(uint256 numMushrooms) external view returns (uint256);

    function growMushrooms(address recipient, uint256 numMushrooms) external;

}// MIT

pragma solidity ^0.6.0;

interface IMission  {

    function sendSpores(address recipient, uint256 amount) external;

    function approvePool(address pool) external;

    function revokePool(address pool) external;

}// MIT

pragma solidity ^0.6.0;

interface ISporeToken {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    function burn(uint256 amount) external;


    function mint(address to, uint256 amount) external;


    function addInitialLiquidityTransferRights(address account) external;


    function enableTransfers() external;


    function addMinter(address account) external;


    function removeMinter(address account) external;

}pragma solidity ^0.6.0;



contract SporePoolV2 is OwnableUpgradeSafe, ReentrancyGuardUpgradeSafe, PausableUpgradeSafe, Defensible {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    ISporeToken public sporeToken;
    IERC20 public stakingToken;
    uint256 public sporesPerSecond = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public constant MAX_PERCENTAGE = 100;
    uint256 public devRewardPercentage;
    address public devRewardAddress;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;

    IMushroomFactory public mushroomFactory;
    IMission public mission;
    BannedContractList public bannedContractList;

    uint256 public stakingEnabledTime;

    uint256 public votingEnabledTime;
    uint256 public nextVoteAllowedAt;
    uint256 public lastVoteNonce;
    uint256 public voteDuration;

    address public enokiDaoAgent;

    uint256 public decreaseRateMultiplier;
    uint256 public increaseRateMultiplier;

    mapping(address => bool) rewardHarvested;


    function initialize(
        address _sporeToken,
        address _stakingToken,
        address _mushroomFactory,
        address _mission,
        address _bannedContractList,
        address _devRewardAddress,
        address daoAgent_,
        uint256[5] memory uintParams
    ) virtual public initializer {

        __Context_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Ownable_init_unchained();

        sporeToken = ISporeToken(_sporeToken);
        stakingToken = IERC20(_stakingToken);
        mushroomFactory = IMushroomFactory(_mushroomFactory);
        mission = IMission(_mission);
        bannedContractList = BannedContractList(_bannedContractList);

        decreaseRateMultiplier = 50;
        increaseRateMultiplier = 150;


        sporesPerSecond = uintParams[4];

        devRewardPercentage = uintParams[0];
        devRewardAddress = _devRewardAddress;

        stakingEnabledTime = uintParams[1];
        votingEnabledTime = uintParams[2];
        nextVoteAllowedAt = uintParams[2];
        voteDuration = uintParams[3];
        lastVoteNonce = 0;

        enokiDaoAgent = daoAgent_;
    }

    function totalSupply() external view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {

        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return block.timestamp;
    }

    function rewardPerToken() public view returns (uint256) {

        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored.add(lastTimeRewardApplicable().sub(lastUpdateTime).mul(sporesPerSecond).mul(1e18).div(_totalSupply));
    }

    function earned(address account) public view returns (uint256) {

        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }


    function stake(uint256 amount) external virtual nonReentrant defend(bannedContractList) whenNotPaused updateReward(msg.sender) {

        revert("Staking disabled");
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public virtual nonReentrant updateReward(msg.sender) {

        if (amount > 0) {
            _totalSupply = _totalSupply.sub(amount);
            _balances[msg.sender] = _balances[msg.sender].sub(amount);
            stakingToken.safeTransfer(msg.sender, amount);
            emit Withdrawn(msg.sender, amount);
        }
        if (!rewardHarvested[msg.sender]) {
            harvest(0);
        }
    }

    function harvest(uint256 mushroomsToGrow) internal /*nonReentrant updateReward(msg.sender)*/ {

        require(mushroomsToGrow == 0, "Growing mushrooms is disabled");
        require(!rewardHarvested[msg.sender], "Reward already harvested");

        uint256 reward = rewards[msg.sender];

        if (reward > 0) {
            uint256 remainingReward = reward;
            rewards[msg.sender] = 0;

            if (mushroomsToGrow > 0) {
                uint256 totalCost = mushroomFactory.costPerMushroom().mul(mushroomsToGrow);

                require(
                    mushroomsToGrow <= mushroomFactory.getRemainingMintableForMySpecies(mushroomsToGrow),
                    "Number of mushrooms specified exceeds cap"
                );
                require(reward >= totalCost, "Not enough rewards to grow the number of mushrooms specified");

                uint256 toDev = totalCost.mul(devRewardPercentage).div(MAX_PERCENTAGE);

                if (toDev > 0) {
                    mission.sendSpores(devRewardAddress, toDev);
                }

                mission.sendSpores(enokiDaoAgent, totalCost.sub(toDev));

                remainingReward = reward.sub(totalCost);
                mushroomFactory.growMushrooms(msg.sender, mushroomsToGrow);
            }

            if (remainingReward > 0) {
                uint256 oneMonthReward = 2_592_000 * sporesPerSecond;
                uint256 limitedReward = 
                    (oneMonthReward > remainingReward)?
                    remainingReward : oneMonthReward;

                rewardHarvested[msg.sender] = true;

                mission.sendSpores(msg.sender, limitedReward);
                emit RewardPaid(msg.sender, limitedReward);
            }
        }
    }

    function emergencyWithdraw() external {

        withdraw(_balances[msg.sender]);
    }


    function reduceRate(uint256 voteNonce) public onlyDAO {

        require(now >= votingEnabledTime, "SporePool: Voting not enabled yet");
        require(now >= nextVoteAllowedAt, "SporePool: Previous rate change vote too soon");
        require(voteNonce == lastVoteNonce.add(1), "SporePool: Incorrect vote nonce");

        sporesPerSecond = sporesPerSecond.mul(decreaseRateMultiplier).div(MAX_PERCENTAGE);

        nextVoteAllowedAt = now.add(voteDuration);
        lastVoteNonce = voteNonce.add(1);
    }

    function increaseRate(uint256 voteNonce) public onlyDAO {

        require(now >= votingEnabledTime, "SporePool: Voting not enabled yet");
        require(now >= nextVoteAllowedAt, "SporePool: Previous rate change vote too soon");
        require(voteNonce == lastVoteNonce.add(1), "SporePool: Incorrect vote nonce");

        sporesPerSecond = sporesPerSecond.mul(increaseRateMultiplier).div(MAX_PERCENTAGE);

        nextVoteAllowedAt = now.add(voteDuration);
        lastVoteNonce = voteNonce.add(1);
    }


    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

        require(tokenAddress != address(stakingToken) && tokenAddress != address(sporeToken), "Cannot withdraw the staking or rewards tokens");

        IERC20(tokenAddress).transfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }


    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyDAO {

        require(msg.sender == enokiDaoAgent, "SporePool: Only Enoki DAO agent can call");
        _;
    }


    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event Recovered(address token, uint256 amount);
}