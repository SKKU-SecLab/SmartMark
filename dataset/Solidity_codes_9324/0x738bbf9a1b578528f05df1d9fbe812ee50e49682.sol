
pragma solidity ^0.8.0;

interface IERC20 {

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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// Apache-2.0
pragma solidity ^0.8.4;



contract Staking2 is Initializable, ReentrancyGuardUpgradeable {

    using SafeMath for uint256;

    uint128 constant private BASE_MULTIPLIER = uint128(1 * 10 ** 18);

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

    address guardianAddress;
    mapping(address => bool) isApproved;

    mapping(address => uint256) private _accrued;

    function initialize(address _guardianAddress, uint256 _epoch1Start, uint256 _epochDuration) public initializer {

        guardianAddress = _guardianAddress;
        epoch1Start = _epoch1Start;
        epochDuration = _epochDuration;
    }


    function approveAccess(address addr) public{

        require(msg.sender == guardianAddress, "caller must be guardian");
        isApproved[addr] = true;
    }

    function revokeAccess(address addr) public{

        require(msg.sender == guardianAddress, "caller must be guardian");
        isApproved[addr] = false;
    }

    function deposit(address tokenAddress, address wallet, uint256 amount) public nonReentrant {

        require(isApproved[msg.sender], "Caller must be an approved");
        require(amount > 0, "Staking: Amount must be > 0");

        IERC20 token = IERC20(tokenAddress);
        uint256 stakedBalance = _getBalance(balances[wallet][tokenAddress]).add(amount);

        {

            _setBalance(wallet, tokenAddress, stakedBalance);
        }

        uint128 currentEpoch = getCurrentEpoch();
        uint128 currentMultiplier = currentEpochMultiplier();

        if (!epochIsInitialized(tokenAddress, currentEpoch)) {
            address[] memory tokens = new address[](1);
            tokens[0] = tokenAddress;
            manualEpochInit(tokens, currentEpoch);
        }

        Pool storage pNextEpoch = poolSize[tokenAddress][currentEpoch + 1];
        pNextEpoch.size = token.balanceOf(address(this));
        pNextEpoch.set = true;

        Checkpoint[] storage checkpoints = balanceCheckpoints[wallet][tokenAddress];

        uint256 balanceBefore = getEpochUserBalance(wallet, tokenAddress, currentEpoch);

        if (checkpoints.length == 0) {
            checkpoints.push(Checkpoint(currentEpoch, currentMultiplier, 0, amount));

            checkpoints.push(Checkpoint(currentEpoch + 1, BASE_MULTIPLIER, amount, 0));
        } else {
            uint256 last = checkpoints.length - 1;

            if (checkpoints[last].epochId < currentEpoch) {
                uint128 multiplier = computeNewMultiplier(
                    getCheckpointBalance(checkpoints[last]),
                    BASE_MULTIPLIER,
                    amount,
                    currentMultiplier
                );
                checkpoints.push(Checkpoint(currentEpoch, multiplier, getCheckpointBalance(checkpoints[last]), amount));
                checkpoints.push(Checkpoint(currentEpoch + 1, BASE_MULTIPLIER, stakedBalance, 0));
            }
            else if (checkpoints[last].epochId == currentEpoch) {
                checkpoints[last].multiplier = computeNewMultiplier(
                    getCheckpointBalance(checkpoints[last]),
                    checkpoints[last].multiplier,
                    amount,
                    currentMultiplier
                );
                checkpoints[last].newDeposits = checkpoints[last].newDeposits.add(amount);

                checkpoints.push(Checkpoint(currentEpoch + 1, BASE_MULTIPLIER, stakedBalance, 0));
            }
            else {
                if (last >= 1 && checkpoints[last - 1].epochId == currentEpoch) {
                    checkpoints[last - 1].multiplier = computeNewMultiplier(
                        getCheckpointBalance(checkpoints[last - 1]),
                        checkpoints[last - 1].multiplier,
                        amount,
                        currentMultiplier
                    );
                    checkpoints[last - 1].newDeposits = checkpoints[last - 1].newDeposits.add(amount);
                }

                checkpoints[last].startBalance = stakedBalance;
            }
        }

        uint256 balanceAfter = getEpochUserBalance(wallet, tokenAddress, currentEpoch);

        poolSize[tokenAddress][currentEpoch].size = poolSize[tokenAddress][currentEpoch].size.add(balanceAfter.sub(balanceBefore));

        emit Deposit(wallet, tokenAddress, amount);
    }

    function withdraw(address tokenAddress, address wallet, uint256 amount) public nonReentrant {

        require(isApproved[msg.sender], "Caller must be an approved");

        uint256 stakedBalance = _getBalance(balances[wallet][tokenAddress]);
        require(stakedBalance >= amount, "Staking: balance too small");

        stakedBalance = stakedBalance.sub(amount);
        _setBalance(wallet, tokenAddress, stakedBalance);

        IERC20 token = IERC20(tokenAddress);
        token.transfer(wallet, amount);

        uint128 currentEpoch = getCurrentEpoch();

        lastWithdrawEpochId[tokenAddress] = currentEpoch;

        if (!epochIsInitialized(tokenAddress, currentEpoch)) {
            address[] memory tokens = new address[](1);
            tokens[0] = tokenAddress;
            manualEpochInit(tokens, currentEpoch);
        }

        Pool storage pNextEpoch = poolSize[tokenAddress][currentEpoch + 1];
        pNextEpoch.size = token.balanceOf(address(this));
        pNextEpoch.set = true;

        Checkpoint[] storage checkpoints = balanceCheckpoints[wallet][tokenAddress];
        uint256 last = checkpoints.length - 1;


        if (checkpoints[last].epochId < currentEpoch) {
            checkpoints.push(Checkpoint(currentEpoch, BASE_MULTIPLIER, stakedBalance, 0));

            poolSize[tokenAddress][currentEpoch].size = poolSize[tokenAddress][currentEpoch].size.sub(amount);
        }
        else if (checkpoints[last].epochId == currentEpoch) {
            checkpoints[last].startBalance = stakedBalance;
            checkpoints[last].newDeposits = 0;
            checkpoints[last].multiplier = BASE_MULTIPLIER;

            poolSize[tokenAddress][currentEpoch].size = poolSize[tokenAddress][currentEpoch].size.sub(amount);
        }
        else {
            Checkpoint storage currentEpochCheckpoint = checkpoints[last - 1];

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

            checkpoints[last].startBalance = stakedBalance;
        }

        emit Withdraw(wallet, tokenAddress, amount);
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
                require(epochIsInitialized(tokens[i], epochId - 1), "Staking: previous epoch not initialized");

                p.size = poolSize[tokens[i]][epochId - 1].size;
                p.set = true;
            }
        }

        emit ManualEpochInit(msg.sender, epochId, tokens);
    }

    function manualBatchEpochInit(address[] memory tokens, uint128 startingEpochId, uint128 endingEpochId) public {

        require(endingEpochId <= getCurrentEpoch(), "can't init a future epoch");
        for (uint128 i = startingEpochId; i <= endingEpochId; i++) {
            manualEpochInit(tokens, i);
        }
    }

    function emergencyWithdraw(address tokenAddress) public {

        require((getCurrentEpoch() - lastWithdrawEpochId[tokenAddress]) >= 10, "At least 10 epochs must pass without success");

        uint256 totalUserBalance = _getBalance(balances[msg.sender][tokenAddress]);
        require(totalUserBalance > 0, "Amount must be > 0");

        _setBalance(msg.sender, tokenAddress, 0);

        IERC20 token = IERC20(tokenAddress);
        token.transfer(msg.sender, totalUserBalance);

        emit EmergencyWithdraw(msg.sender, tokenAddress, totalUserBalance);
    }

    function getEpochUserBalance(address user, address token, uint128 epochId) public view returns (uint256) {

        Checkpoint[] storage checkpoints = balanceCheckpoints[user][token];

        if (checkpoints.length == 0 || epochId < checkpoints[0].epochId) {
            return 0;
        }

        uint min = 0;
        uint max = checkpoints.length - 1;

        if (epochId >= checkpoints[max].epochId) {
            return getCheckpointEffectiveBalance(checkpoints[max]);
        }

        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].epochId <= epochId) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return getCheckpointEffectiveBalance(checkpoints[min]);
    }

    function balanceOf(address user, address token) public view returns (uint256) {

        return _getBalance(balances[user][token]);
    }

    function getCurrentEpoch() public view returns (uint128) {

        if (block.timestamp < epoch1Start) {
            return 0;
        }

        return uint128((block.timestamp - epoch1Start) / epochDuration + 1);
    }

    function getEpochPoolSize(address tokenAddress, uint128 epochId) public view returns (uint256) {

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
        uint256 currentEpochEnd = epoch1Start + currentEpoch * epochDuration;
        uint256 timeLeft = currentEpochEnd - block.timestamp;
        uint128 multiplier = uint128(timeLeft * BASE_MULTIPLIER / epochDuration);

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



    uint256 constant BASE_MASK     = 0xffffffffffffffffffffffff000000000000000000000000;
    uint256 constant BALANCE_MASK  = 0x000000000000000000000000ffffffffffffffffffffffff;

    uint256 constant SHIFT = 2 ** 128;

    uint256 constant SECONDS_PER_YEAR = 31104000;

    uint256 constant STARTING_TIME = 1654041600;

    function _getBalance(uint256 balanceStorage) private view returns (uint256) {

        return balanceStorage & BALANCE_MASK;
    }

    function _getBase(uint256 balanceStorage) private view returns (uint256) {

        uint256 base = (balanceStorage & BASE_MASK).div(SHIFT);

        if (base == 0) {
            base = block.timestamp;
            if (_getBalance(balanceStorage) > 0) {
                base = STARTING_TIME;
            }
        }
        return base;
    }

    function _getTokenSeconds(uint256 balanceStorage) private view returns (uint256) {

        return (block.timestamp.sub(_getBase(balanceStorage)).mul(_getBalance(balanceStorage)));
    }

    function _setBalance(address account, address tokenAddress, uint256 balance) private {

        uint256 balanceStorage = balances[account][tokenAddress];

        if (balance == 0) {
            _accrued[account] += _getTokenSeconds(balanceStorage).div(SECONDS_PER_YEAR);
            balances[account][tokenAddress] = 0;
        } else {
            uint256 newBase = block.timestamp;
            if (_getTokenSeconds(balanceStorage).div(balance) < block.timestamp) {
                newBase = block.timestamp.sub(_getTokenSeconds(balanceStorage).div(balance));
            } else {
                _accrued[account] += _getTokenSeconds(balanceStorage).div(SECONDS_PER_YEAR);
            }
            balances[account][tokenAddress] = newBase.mul(SHIFT) | (balance & BALANCE_MASK);
        }
    }

    function getAndClearReward(address account, address tokenAddress) external returns (uint256) {

        require(isApproved[msg.sender], "Caller must be an approved");

        uint256 reward = _getTokenSeconds(balances[account][tokenAddress]).div(SECONDS_PER_YEAR);

        reward += _accrued[account];
        _accrued[account] = 0;

        balances[account][tokenAddress] = block.timestamp.mul(SHIFT) | ((balances[account][tokenAddress]) & BALANCE_MASK);

        return reward;
    }
}