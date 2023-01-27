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
}// Inspired by https://github.com/BarnBridge/BarnBridge-YieldFarming/blob/master/contracts/Staking.sol
pragma solidity 0.6.12;



contract StakingMilestones is ReentrancyGuardUpgradeSafe, OwnableUpgradeSafe {

    using SafeMath for uint256;
    using SafeMath for uint128;


    uint128 constant private BASE_MULTIPLIER = uint128(1e18);

    uint256 public epoch1Start;

    uint256 public epochDuration;

    mapping(address => mapping(address => uint256)) private balances;

    struct Pool {
        uint256 size;
        bool set;
    }

    mapping(address => mapping(uint256 => Pool)) private poolSize;

    struct Checkpoint {
        uint128 epochId;
        uint128 multiplier;
        uint256 startBalance;
        uint256 newDeposits;
    }

    mapping(address => mapping(address => Checkpoint[])) private balanceCheckpoints;

    mapping(address => uint128) private lastWithdrawEpochId;

    event Deposit(address indexed user, address indexed tokenAddress, uint256 amount);
    event Withdraw(address indexed user, address indexed tokenAddress, uint256 amount);
    event ManualEpochInit(address indexed caller, uint128 indexed epochId, address[] tokens);
    event EmergencyWithdraw(address indexed user, address indexed tokenAddress, uint256 amount);

    function initialize (uint256 _epoch1Start, uint256 _epochDuration) external initializer {
        OwnableUpgradeSafe.__Ownable_init();
        __ReentrancyGuard_init_unchained();
        epoch1Start = _epoch1Start;
        epochDuration = _epochDuration;
    }

    function deposit(address tokenAddress, uint256 amount) external nonReentrant {

        require(amount > 0, "Staking: Amount must be > 0");

        IERC20 token = IERC20(tokenAddress);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Staking: Token allowance too low");

        balances[msg.sender][tokenAddress] = balances[msg.sender][tokenAddress].add(amount);

        SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount);

        uint128 currentEpoch = getCurrentEpoch();
        uint128 currentMultiplier = currentEpochMultiplier();

        if (!epochIsInitialized(tokenAddress, currentEpoch)) {
            address[] memory tokens = new address[](1);
            tokens[0] = tokenAddress;
            manualEpochInit(tokens, currentEpoch);
        }

        Pool storage pNextEpoch = poolSize[tokenAddress][currentEpoch.add(1)];
        pNextEpoch.size = token.balanceOf(address(this));
        pNextEpoch.set = true;

        Checkpoint[] storage checkpoints = balanceCheckpoints[msg.sender][tokenAddress];

        uint256 balanceBefore = getEpochUserBalance(msg.sender, tokenAddress, currentEpoch);

        if (checkpoints.length == 0) {
            checkpoints.push(Checkpoint(currentEpoch, currentMultiplier, 0, amount));

            checkpoints.push(Checkpoint(uint128(currentEpoch.add(1)), BASE_MULTIPLIER, amount, 0));
        } else {
            uint256 last = checkpoints.length.sub(1);

            if (checkpoints[last].epochId < currentEpoch) {
                uint128 multiplier = computeNewMultiplier(
                    getCheckpointBalance(checkpoints[last]),
                    BASE_MULTIPLIER,
                    amount,
                    currentMultiplier
                );
                checkpoints.push(Checkpoint(currentEpoch, multiplier, getCheckpointBalance(checkpoints[last]), amount));
                checkpoints.push(Checkpoint(uint128(currentEpoch.add(1)), BASE_MULTIPLIER, balances[msg.sender][tokenAddress], 0));
            }
            else if (checkpoints[last].epochId == currentEpoch) {
                checkpoints[last].multiplier = computeNewMultiplier(
                    getCheckpointBalance(checkpoints[last]),
                    checkpoints[last].multiplier,
                    amount,
                    currentMultiplier
                );
                checkpoints[last].newDeposits = checkpoints[last].newDeposits.add(amount);

                checkpoints.push(Checkpoint(uint128(currentEpoch.add(1)), BASE_MULTIPLIER, balances[msg.sender][tokenAddress], 0));
            }
            else {
                if (last >= 1 && checkpoints[last.sub(1)].epochId == currentEpoch) {
                    checkpoints[last.sub(1)].multiplier = computeNewMultiplier(
                        getCheckpointBalance(checkpoints[last.sub(1)]),
                        checkpoints[last.sub(1)].multiplier,
                        amount,
                        currentMultiplier
                    );
                    checkpoints[last.sub(1)].newDeposits = checkpoints[last.sub(1)].newDeposits.add(amount);
                }

                checkpoints[last].startBalance = balances[msg.sender][tokenAddress];
            }
        }

        uint256 balanceAfter = getEpochUserBalance(msg.sender, tokenAddress, currentEpoch);

        poolSize[tokenAddress][currentEpoch].size = poolSize[tokenAddress][currentEpoch].size.add(balanceAfter.sub(balanceBefore));

        emit Deposit(msg.sender, tokenAddress, amount);
    }

    function withdraw(address tokenAddress, uint256 amount) external nonReentrant {

        require(balances[msg.sender][tokenAddress] >= amount, "Staking: balance too small");

        balances[msg.sender][tokenAddress] = balances[msg.sender][tokenAddress].sub(amount);

        IERC20 token = IERC20(tokenAddress);
        SafeERC20.safeTransfer(token, msg.sender, amount);

        uint128 currentEpoch = getCurrentEpoch();

        lastWithdrawEpochId[tokenAddress] = currentEpoch;

        if (!epochIsInitialized(tokenAddress, currentEpoch)) {
            address[] memory tokens = new address[](1);
            tokens[0] = tokenAddress;
            manualEpochInit(tokens, currentEpoch);
        }

        Pool storage pNextEpoch = poolSize[tokenAddress][currentEpoch.add(1)];
        pNextEpoch.size = token.balanceOf(address(this));
        pNextEpoch.set = true;

        Checkpoint[] storage checkpoints = balanceCheckpoints[msg.sender][tokenAddress];
        uint256 last = checkpoints.length.sub(1);


        if (checkpoints[last].epochId < currentEpoch) {
            checkpoints.push(Checkpoint(currentEpoch, BASE_MULTIPLIER, balances[msg.sender][tokenAddress], 0));

            poolSize[tokenAddress][currentEpoch].size = poolSize[tokenAddress][currentEpoch].size.sub(amount);
        }
        else if (checkpoints[last].epochId == currentEpoch) {
            checkpoints[last].startBalance = balances[msg.sender][tokenAddress];
            checkpoints[last].newDeposits = 0;
            checkpoints[last].multiplier = BASE_MULTIPLIER;

            poolSize[tokenAddress][currentEpoch].size = poolSize[tokenAddress][currentEpoch].size.sub(amount);
        }
        else {
            Checkpoint storage currentEpochCheckpoint = checkpoints[last.sub(1)];

            uint256 balanceBefore = getCheckpointEffectiveBalance(currentEpochCheckpoint);

            if (amount < currentEpochCheckpoint.newDeposits) {
                uint128 avgDepositMultiplier = uint128(
                    balanceBefore.sub(currentEpochCheckpoint.startBalance).mul(BASE_MULTIPLIER).div(currentEpochCheckpoint.newDeposits)
                );

                currentEpochCheckpoint.newDeposits = currentEpochCheckpoint.newDeposits.sub(amount);

                currentEpochCheckpoint.multiplier = computeNewMultiplier(
                    currentEpochCheckpoint.startBalance,
                    BASE_MULTIPLIER,
                    currentEpochCheckpoint.newDeposits,
                    avgDepositMultiplier
                );
            } else {
                currentEpochCheckpoint.startBalance = currentEpochCheckpoint.startBalance.sub(
                    amount.sub(currentEpochCheckpoint.newDeposits)
                );
                currentEpochCheckpoint.newDeposits = 0;
                currentEpochCheckpoint.multiplier = BASE_MULTIPLIER;
            }

            uint256 balanceAfter = getCheckpointEffectiveBalance(currentEpochCheckpoint);

            poolSize[tokenAddress][currentEpoch].size = poolSize[tokenAddress][currentEpoch].size.sub(balanceBefore.sub(balanceAfter));

            checkpoints[last].startBalance = balances[msg.sender][tokenAddress];
        }

        emit Withdraw(msg.sender, tokenAddress, amount);
    }

    function manualEpochInit(address[] memory tokens, uint128 epochId) public {

        require(epochId <= getCurrentEpoch(), "can't init a future epoch");

        for (uint i = 0; i < tokens.length; i++) {
            Pool storage p = poolSize[tokens[i]][epochId];

            if (epochId == 0) {
                p.size = uint256(0);
                p.set = true;
            } else {
                require(!epochIsInitialized(tokens[i], epochId), "Staking: epoch already initialized");
                require(epochIsInitialized(tokens[i], uint128(epochId.sub(1))), "Staking: previous epoch not initialized");

                p.size = poolSize[tokens[i]][epochId.sub(1)].size;
                p.set = true;
            }
        }

        emit ManualEpochInit(msg.sender, epochId, tokens);
    }

    function emergencyWithdraw(address tokenAddress) external nonReentrant {

        require(getCurrentEpoch().sub(lastWithdrawEpochId[tokenAddress]) >= 10, "At least 10 epochs must pass without success");

        uint256 totalUserBalance = balances[msg.sender][tokenAddress];
        require(totalUserBalance > 0, "Amount must be > 0");

        balances[msg.sender][tokenAddress] = 0;

        IERC20 token = IERC20(tokenAddress);
        SafeERC20.safeTransfer(token, msg.sender, totalUserBalance);

        emit EmergencyWithdraw(msg.sender, tokenAddress, totalUserBalance);
    }

    function getEpochUserBalance(address user, address token, uint128 epochId) public view returns (uint256) {

        Checkpoint[] storage checkpoints = balanceCheckpoints[user][token];

        if (checkpoints.length == 0 || epochId < checkpoints[0].epochId) {
            return 0;
        }

        uint min = 0;
        uint max = checkpoints.length.sub(1);

        if (epochId >= checkpoints[max].epochId) {
            return getCheckpointEffectiveBalance(checkpoints[max]);
        }

        while (max > min) {
            uint mid = (max.add(min).add(1)).div(2);
            if (checkpoints[mid].epochId <= epochId) {
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }

        return getCheckpointEffectiveBalance(checkpoints[min]);
    }

    function balanceOf(address user, address token) external view returns (uint256) {

        return balances[user][token];
    }

    function getCurrentEpoch() public view returns (uint128) {

        if (block.timestamp < epoch1Start) {
            return 0;
        }

        return uint128((block.timestamp.sub(epoch1Start)).div(epochDuration).add(1));
    }

    function getEpochPoolSize(address tokenAddress, uint128 epochId) external view returns (uint256) {

        if (epochIsInitialized(tokenAddress, epochId)) {
            return poolSize[tokenAddress][epochId].size;
        }

        if (!epochIsInitialized(tokenAddress, 0)) {
            return 0;
        }

        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }

    function currentEpochMultiplier() public view returns (uint128) {

        uint128 currentEpoch = getCurrentEpoch();
        uint256 currentEpochEnd = epoch1Start.add(currentEpoch.mul(epochDuration));
        uint256 timeLeft = currentEpochEnd.sub(block.timestamp);
        uint128 multiplier = uint128(timeLeft.mul(BASE_MULTIPLIER).div(epochDuration));

        return multiplier;
    }

    function computeNewMultiplier(uint256 prevBalance, uint128 prevMultiplier, uint256 amount, uint128 currentMultiplier) public pure returns (uint128) {

        uint256 prevAmount = prevBalance.mul(prevMultiplier).div(BASE_MULTIPLIER);
        uint256 addAmount = amount.mul(currentMultiplier).div(BASE_MULTIPLIER);
        uint128 newMultiplier = uint128(prevAmount.add(addAmount).mul(BASE_MULTIPLIER).div(prevBalance.add(amount)));

        return newMultiplier;
    }

    function epochIsInitialized(address token, uint128 epochId) public view returns (bool) {

        return poolSize[token][epochId].set;
    }

    function getCheckpointBalance(Checkpoint memory c) internal pure returns (uint256) {

        return c.startBalance.add(c.newDeposits);
    }

    function getCheckpointEffectiveBalance(Checkpoint memory c) internal pure returns (uint256) {

        return getCheckpointBalance(c).mul(c.multiplier).div(BASE_MULTIPLIER);
    }
}