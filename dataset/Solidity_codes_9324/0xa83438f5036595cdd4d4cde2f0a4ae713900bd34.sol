


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
}




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
}




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
}






contract Defensible {

  modifier defend(BannedContractList bannedContractList) {

    require(
      (msg.sender == tx.origin) || bannedContractList.isApproved(msg.sender),
      "This smart contract has not been approved"
    );
    _;
  }
}




pragma experimental ABIEncoderV2;

interface IMushroomFactory  {

    function costPerMushroom() external returns (uint256);

    function getRemainingMintableForMySpecies(uint256 numMushrooms) external view returns (uint256);

    function growMushrooms(address recipient, uint256 numMushrooms) external;

}




interface IMission  {

    function sendSpores(address recipient, uint256 amount) external;

    function approvePool(address pool) external;

    function revokePool(address pool) external;

}




interface IMiniMe {

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


    function balanceOfAt(address account, uint256 blockNumber) external view returns (uint256);

    function totalSupplyAt(uint256 blockNumber) external view returns (uint256);

}





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

}




pragma solidity ^0.6.0;
// pragma experimental ABIEncoderV2;



contract SporePool is OwnableUpgradeSafe, ReentrancyGuardUpgradeSafe, PausableUpgradeSafe, Defensible {

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

    address public rateVote;

    IMiniMe public enokiToken;
    address public enokiDaoAgent;
    


    function initialize(
        address _sporeToken,
        address _stakingToken,
        address _mission,
        address _bannedContractList,
        address _devRewardAddress,
        address _enokiDaoAgent,
        uint256[3] memory uintParams
    ) public virtual initializer {

        __Context_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Ownable_init_unchained();

        sporeToken = ISporeToken(_sporeToken);
        stakingToken = IERC20(_stakingToken);

        mission = IMission(_mission);
        bannedContractList = BannedContractList(_bannedContractList);


        devRewardPercentage = uintParams[0];
        devRewardAddress = _devRewardAddress;

        stakingEnabledTime = uintParams[1];
        sporesPerSecond = uintParams[2];

        enokiDaoAgent = _enokiDaoAgent;

        emit SporeRateChange(sporesPerSecond);
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

        require(amount > 0, "Cannot stake 0");
        require(now > stakingEnabledTime, "Cannot stake before staking enabled");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public virtual updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function harvest(uint256 mushroomsToGrow)
        public
        nonReentrant
        updateReward(msg.sender)
        returns (
            uint256 toDev,
            uint256 toDao,
            uint256 remainingReward
        )
    {

        uint256 reward = rewards[msg.sender];

        if (reward > 0) {
            remainingReward = reward;
            toDev = 0;
            toDao = 0;
            rewards[msg.sender] = 0;

            if (mushroomsToGrow > 0) {
                uint256 totalCost = mushroomFactory.costPerMushroom().mul(mushroomsToGrow);

                require(reward >= totalCost, "Not enough rewards to grow the number of mushrooms specified");

                toDev = totalCost.mul(devRewardPercentage).div(MAX_PERCENTAGE);

                if (toDev > 0) {
                    mission.sendSpores(devRewardAddress, toDev);
                    emit DevRewardPaid(devRewardAddress, toDev);
                }

                toDao = totalCost.sub(toDev);

                mission.sendSpores(enokiDaoAgent, toDao);
                emit DaoRewardPaid(enokiDaoAgent, toDao);

                remainingReward = reward.sub(totalCost);
                mushroomFactory.growMushrooms(msg.sender, mushroomsToGrow);
                emit MushroomsGrown(msg.sender, mushroomsToGrow);
            }

            if (remainingReward > 0) {
                mission.sendSpores(msg.sender, remainingReward);
                emit RewardPaid(msg.sender, remainingReward);
            }
        }
    }

    function emergencyWithdraw() external nonReentrant {

        withdraw(_balances[msg.sender]);
    }


    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

        require(tokenAddress != address(stakingToken) && tokenAddress != address(sporeToken), "Cannot withdraw the staking or rewards tokens");

        IERC20(tokenAddress).transfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setMushroomFactory(address mushroomFactory_) external onlyOwner {

        mushroomFactory = IMushroomFactory(mushroomFactory_);
    }

    function pauseStaking() external onlyOwner {

        _pause();
    }

    function unpauseStaking() external onlyOwner {

        _unpause();
    }

    function setRateVote(address _rateVote) external onlyOwner {

        rateVote = _rateVote;
    }

    function changeRate(uint256 percentage) external onlyRateVote {

        sporesPerSecond = sporesPerSecond.mul(percentage).div(MAX_PERCENTAGE);
        emit SporeRateChange(sporesPerSecond);
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

    modifier onlyRateVote() {

        require(msg.sender == rateVote, "onlyRateVote");
        _;
    }


    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event DevRewardPaid(address indexed user, uint256 reward);
    event DaoRewardPaid(address indexed user, uint256 reward);
    event MushroomsGrown(address indexed user, uint256 number);
    event Recovered(address token, uint256 amount);
    event SporeRateChange(uint256 newRate);
}