
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library SignedSafeMath {

    function mul(int256 a, int256 b) internal pure returns (int256) {

        return a * b;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        return a + b;
    }
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// contracts/LockletToken.sol

pragma solidity 0.8.3;


contract LockletToken is ERC20 {
    uint256 private _initialSupply;
    uint256 private _totalSupply;

    constructor() ERC20("Locklet", "LKT") {
        _initialSupply = 150000000 * 10**18;
        _totalSupply = _initialSupply;
        _mint(msg.sender, _initialSupply);
    }

    function burn(uint256 amount) external returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
}// contracts/LockletTokenVault.sol

pragma solidity 0.8.3;



contract LockletTokenVault is AccessControl, Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint16;

    using SignedSafeMath for int256;

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    address public lockletTokenAddress;

    struct RecipientCallData {
        address recipientAddress;
        uint256 amount;
    }

    struct Recipient {
        address recipientAddress;
        uint256 amount;
        uint16 daysClaimed;
        uint256 amountClaimed;
        bool isActive;
    }

    struct Lock {
        uint256 creationTime;
        address tokenAddress;
        uint256 startTime;
        uint16 durationInDays;
        address initiatorAddress;
        bool isRevocable;
        bool isRevoked;
        bool isActive;
    }

    struct LockWithRecipients {
        uint256 index;
        Lock lock;
        Recipient[] recipients;
    }

    uint256 private _nextLockIndex;
    Lock[] private _locks;
    mapping(uint256 => Recipient[]) private _locksRecipients;

    mapping(address => uint256[]) private _initiatorsLocksIndexes;
    mapping(address => uint256[]) private _recipientsLocksIndexes;

    mapping(address => mapping(address => uint256)) private _refunds;

    address private _stakersRedisAddress;
    address private _foundationRedisAddress;
    bool private _isDeprecated;


    uint256 private _creationFlatFeeLktAmount;
    uint256 private _revocationFlatFeeLktAmount;

    uint256 private _creationPercentFee;



    event LockAdded(uint256 indexed lockIndex);
    event LockedTokensClaimed(uint256 indexed lockIndex, address indexed recipientAddress, uint256 claimedAmount);
    event LockRevoked(uint256 indexed lockIndex, uint256 unlockedAmount, uint256 remainingLockedAmount);
    event LockRefundPulled(address indexed recipientAddress, address indexed tokenAddress, uint256 refundedAmount);


    constructor(address lockletTokenAddr) {
        lockletTokenAddress = lockletTokenAddr;

        _nextLockIndex = 0;

        _stakersRedisAddress = address(0);
        _foundationRedisAddress = 0x25Bd291bE258E90e7A0648aC5c690555aA9e8930;
        _isDeprecated = false;

        _creationFlatFeeLktAmount = 0;
        _revocationFlatFeeLktAmount = 0;
        _creationPercentFee = 0;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(GOVERNOR_ROLE, msg.sender);
    }

    function addLock(
        address tokenAddress,
        uint256 totalAmount,
        uint16 cliffInDays,
        uint16 durationInDays,
        RecipientCallData[] calldata recipientsData,
        bool isRevocable,
        bool payFeesWithLkt
    ) external nonReentrant whenNotPaused contractNotDeprecated {
        require(Address.isContract(tokenAddress), "LockletTokenVault: Token address is not a contract");
        ERC20 token = ERC20(tokenAddress);

        require(totalAmount > 0, "LockletTokenVault: The total amount is equal to zero");

        if (payFeesWithLkt) {
            LockletToken lktToken = lockletToken();

            if (_creationFlatFeeLktAmount > 0) {
                require(lktToken.balanceOf(msg.sender) >= _creationFlatFeeLktAmount, "LockletTokenVault: Not enough LKT to pay fees");
                require(lktToken.transferFrom(msg.sender, address(this), _creationFlatFeeLktAmount));

                uint256 burnAmount = _creationFlatFeeLktAmount.mul(45).div(100);
                uint256 stakersRedisAmount = _creationFlatFeeLktAmount.mul(45).div(100);
                uint256 foundationRedisAmount = _creationFlatFeeLktAmount.mul(10).div(100);

                require(lktToken.burn(burnAmount));
                require(lktToken.transfer(_stakersRedisAddress, stakersRedisAmount));
                require(lktToken.transfer(_foundationRedisAddress, foundationRedisAmount));
            }

            require(token.balanceOf(msg.sender) >= totalAmount, "LockletTokenVault: Token insufficient balance");
            require(token.transferFrom(msg.sender, address(this), totalAmount));
        } else {
            uint256 creationPercentFeeAmount = 0;
            if (_creationPercentFee > 0) {
                creationPercentFeeAmount = totalAmount.mul(_creationPercentFee).div(10000);
            }

            uint256 totalAmountWithFees = totalAmount.add(creationPercentFeeAmount);

            require(token.balanceOf(msg.sender) >= totalAmountWithFees, "LockletTokenVault: Token insufficient balance");
            require(token.transferFrom(msg.sender, address(this), totalAmountWithFees));

            if (creationPercentFeeAmount > 0) {
                uint256 stakersRedisAmount = creationPercentFeeAmount.mul(90).div(100);
                uint256 foundationRedisAmount = creationPercentFeeAmount.mul(10).div(100);

                require(token.transfer(_stakersRedisAddress, stakersRedisAmount));
                require(token.transfer(_foundationRedisAddress, foundationRedisAmount));
            }
        }

        uint256 lockIndex = _nextLockIndex;
        _nextLockIndex = _nextLockIndex.add(1);

        Lock memory lock = Lock({
            creationTime: blockTime(),
            tokenAddress: tokenAddress,
            startTime: blockTime().add(cliffInDays * 1 days),
            durationInDays: durationInDays,
            initiatorAddress: msg.sender,
            isRevocable: durationInDays > 1 ? isRevocable : false,
            isRevoked: false,
            isActive: true
        });

        _locks.push(lock);
        _initiatorsLocksIndexes[msg.sender].push(lockIndex);

        uint256 totalAmountCheck = 0;

        for (uint256 i = 0; i < recipientsData.length; i++) {
            RecipientCallData calldata recipientData = recipientsData[i];

            uint256 unlockedAmountPerDay = recipientData.amount.div(durationInDays);
            require(unlockedAmountPerDay > 0, "LockletTokenVault: The unlocked amount per day is equal to zero");

            totalAmountCheck = totalAmountCheck.add(recipientData.amount);

            Recipient memory recipient = Recipient({
                recipientAddress: recipientData.recipientAddress,
                amount: recipientData.amount,
                daysClaimed: 0,
                amountClaimed: 0,
                isActive: true
            });

            _recipientsLocksIndexes[recipientData.recipientAddress].push(lockIndex);
            _locksRecipients[lockIndex].push(recipient);
        }

        require(totalAmountCheck == totalAmount, "LockletTokenVault: The calculated total amount is not equal to the actual total amount");

        emit LockAdded(lockIndex);
    }

    function claimLockedTokens(uint256 lockIndex) external nonReentrant whenNotPaused {
        Lock storage lock = _locks[lockIndex];
        require(lock.isActive == true, "LockletTokenVault: Lock not existing");
        require(lock.isRevoked == false, "LockletTokenVault: This lock has been revoked");

        Recipient[] storage recipients = _locksRecipients[lockIndex];

        int256 recipientIndex = getRecipientIndexByAddress(recipients, msg.sender);
        require(recipientIndex != -1, "LockletTokenVault: Forbidden");

        Recipient storage recipient = recipients[uint256(recipientIndex)];

        uint16 daysVested;
        uint256 unlockedAmount;
        (daysVested, unlockedAmount) = calculateClaim(lock, recipient);
        require(unlockedAmount > 0, "LockletTokenVault: The amount of unlocked tokens is equal to zero");

        recipient.daysClaimed = uint16(recipient.daysClaimed.add(daysVested));
        recipient.amountClaimed = uint256(recipient.amountClaimed.add(unlockedAmount));

        ERC20 token = ERC20(lock.tokenAddress);

        require(token.transfer(recipient.recipientAddress, unlockedAmount), "LockletTokenVault: Unlocked tokens transfer failed");
        emit LockedTokensClaimed(lockIndex, recipient.recipientAddress, unlockedAmount);
    }

    function revokeLock(uint256 lockIndex) external nonReentrant whenNotPaused {
        Lock storage lock = _locks[lockIndex];
        require(lock.isActive == true, "LockletTokenVault: Lock not existing");
        require(lock.initiatorAddress == msg.sender, "LockletTokenVault: Forbidden");
        require(lock.isRevocable == true, "LockletTokenVault: Lock not revocable");
        require(lock.isRevoked == false, "LockletTokenVault: This lock has already been revoked");

        lock.isRevoked = true;

        if (_revocationFlatFeeLktAmount > 0) {
            LockletToken lktToken = lockletToken();
            require(lktToken.balanceOf(msg.sender) >= _revocationFlatFeeLktAmount, "LockletTokenVault: Not enough LKT to pay fees");
            require(lktToken.transferFrom(msg.sender, address(this), _revocationFlatFeeLktAmount));

            uint256 burnAmount = _revocationFlatFeeLktAmount.mul(45).div(100);
            uint256 stakersRedisAmount = _revocationFlatFeeLktAmount.mul(45).div(100);
            uint256 foundationRedisAmount = _revocationFlatFeeLktAmount.mul(10).div(100);

            require(lktToken.burn(burnAmount));
            require(lktToken.transfer(_stakersRedisAddress, stakersRedisAmount));
            require(lktToken.transfer(_foundationRedisAddress, foundationRedisAmount));
        }

        Recipient[] storage recipients = _locksRecipients[lockIndex];

        address tokenAddr = lock.tokenAddress;
        address initiatorAddr = lock.initiatorAddress;

        uint256 totalAmount = 0;
        uint256 totalUnlockedAmount = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            Recipient storage recipient = recipients[i];

            totalAmount = totalAmount.add(recipient.amount);

            uint16 daysVested;
            uint256 unlockedAmount;
            (daysVested, unlockedAmount) = calculateClaim(lock, recipient);

            if (unlockedAmount > 0) {
                address recipientAddr = recipient.recipientAddress;
                _refunds[recipientAddr][tokenAddr] = _refunds[recipientAddr][tokenAddr].add(unlockedAmount);
            }

            totalUnlockedAmount = totalUnlockedAmount.add(recipient.amountClaimed.add(unlockedAmount));
        }

        uint256 totalLockedAmount = totalAmount.sub(totalUnlockedAmount);
        _refunds[initiatorAddr][tokenAddr] = _refunds[initiatorAddr][tokenAddr].add(totalLockedAmount);

        emit LockRevoked(lockIndex, totalUnlockedAmount, totalLockedAmount);
    }

    function pullRefund(address tokenAddress) external nonReentrant whenNotPaused {
        uint256 refundAmount = getRefundAmount(tokenAddress);
        require(refundAmount > 0, "LockletTokenVault: No refund found for this token");

        _refunds[msg.sender][tokenAddress] = 0;

        ERC20 token = ERC20(tokenAddress);
        require(token.transfer(msg.sender, refundAmount), "LockletTokenVault: Refund tokens transfer failed");

        emit LockRefundPulled(msg.sender, tokenAddress, refundAmount);
    }


    function getLock(uint256 lockIndex) public view returns (LockWithRecipients memory) {
        Lock storage lock = _locks[lockIndex];
        require(lock.isActive == true, "LockletTokenVault: Lock not existing");

        return LockWithRecipients({index: lockIndex, lock: lock, recipients: _locksRecipients[lockIndex]});
    }

    function getLocksLength() public view returns (uint256) {
        return _locks.length;
    }

    function getLocks(int256 page, int256 pageSize) public view returns (LockWithRecipients[] memory) {
        require(getLocksLength() > 0, "LockletTokenVault: There is no lock");

        int256 queryStartLockIndex = int256(getLocksLength()).sub(pageSize.mul(page)).add(pageSize).sub(1);
        require(queryStartLockIndex >= 0, "LockletTokenVault: Out of bounds");

        int256 queryEndLockIndex = queryStartLockIndex.sub(pageSize).add(1);
        if (queryEndLockIndex < 0) {
            queryEndLockIndex = 0;
        }

        int256 currentLockIndex = queryStartLockIndex;
        require(uint256(currentLockIndex) <= getLocksLength().sub(1), "LockletTokenVault: Out of bounds");

        LockWithRecipients[] memory results = new LockWithRecipients[](uint256(pageSize));
        uint256 index = 0;

        for (currentLockIndex; currentLockIndex >= queryEndLockIndex; currentLockIndex--) {
            uint256 currentLockIndexAsUnsigned = uint256(currentLockIndex);
            if (currentLockIndexAsUnsigned <= getLocksLength().sub(1)) {
                results[index] = getLock(currentLockIndexAsUnsigned);
            }

            index++;
        }

        return results;
    }

    function getLocksByInitiator(address initiatorAddress) public view returns (LockWithRecipients[] memory) {
        uint256 initiatorLocksLength = _initiatorsLocksIndexes[initiatorAddress].length;
        require(initiatorLocksLength > 0, "LockletTokenVault: The initiator has no lock");

        LockWithRecipients[] memory results = new LockWithRecipients[](initiatorLocksLength);

        for (uint256 index = 0; index < initiatorLocksLength; index++) {
            uint256 lockIndex = _initiatorsLocksIndexes[initiatorAddress][index];
            results[index] = getLock(lockIndex);
        }

        return results;
    }

    function getLocksByRecipient(address recipientAddress) public view returns (LockWithRecipients[] memory) {
        uint256 recipientLocksLength = _recipientsLocksIndexes[recipientAddress].length;
        require(recipientLocksLength > 0, "LockletTokenVault: The recipient has no lock");

        LockWithRecipients[] memory results = new LockWithRecipients[](recipientLocksLength);

        for (uint256 index = 0; index < recipientLocksLength; index++) {
            uint256 lockIndex = _recipientsLocksIndexes[recipientAddress][index];
            results[index] = getLock(lockIndex);
        }

        return results;
    }

    function getRefundAmount(address tokenAddress) public view returns (uint256) {
        return _refunds[msg.sender][tokenAddress];
    }

    function getClaimByLockAndRecipient(uint256 lockIndex, address recipientAddress) public view returns (uint16, uint256) {
        Lock storage lock = _locks[lockIndex];
        require(lock.isActive == true, "LockletTokenVault: Lock not existing");

        Recipient[] storage recipients = _locksRecipients[lockIndex];

        int256 recipientIndex = getRecipientIndexByAddress(recipients, recipientAddress);
        require(recipientIndex != -1, "LockletTokenVault: Forbidden");

        Recipient storage recipient = recipients[uint256(recipientIndex)];

        uint16 daysVested;
        uint256 unlockedAmount;
        (daysVested, unlockedAmount) = calculateClaim(lock, recipient);

        return (daysVested, unlockedAmount);
    }

    function getCreationFlatFeeLktAmount() public view returns (uint256) {
        return _creationFlatFeeLktAmount;
    }

    function getRevocationFlatFeeLktAmount() public view returns (uint256) {
        return _revocationFlatFeeLktAmount;
    }

    function getCreationPercentFee() public view returns (uint256) {
        return _creationPercentFee;
    }

    function isDeprecated() public view returns (bool) {
        return _isDeprecated;
    }

    function getRecipientIndexByAddress(Recipient[] storage recipients, address recipientAddress) private view returns (int256) {
        int256 recipientIndex = -1;
        for (uint256 i = 0; i < recipients.length; i++) {
            if (recipients[i].recipientAddress == recipientAddress) {
                recipientIndex = int256(i);
                break;
            }
        }
        return recipientIndex;
    }

    function calculateClaim(Lock storage lock, Recipient storage recipient) private view returns (uint16, uint256) {
        require(recipient.amountClaimed < recipient.amount, "LockletTokenVault: The recipient has already claimed the maximum amount");

        if (blockTime() < lock.startTime) {
            return (0, 0);
        }

        uint256 elapsedDays = blockTime().sub(lock.startTime).div(1 days);

        if (elapsedDays >= lock.durationInDays) {
            uint256 remainingAmount = recipient.amount.sub(recipient.amountClaimed);
            return (lock.durationInDays, remainingAmount);
        } else {
            uint16 daysVested = uint16(elapsedDays.sub(recipient.daysClaimed));
            uint256 unlockedAmountPerDay = recipient.amount.div(uint256(lock.durationInDays));
            uint256 unlockedAmount = uint256(daysVested.mul(unlockedAmountPerDay));
            return (daysVested, unlockedAmount);
        }
    }

    function blockTime() private view returns (uint256) {
        return block.timestamp;
    }

    function lockletToken() private view returns (LockletToken) {
        return LockletToken(lockletTokenAddress);
    }



    function setCreationFlatFeeLktAmount(uint256 amount) external onlyGovernor {
        require(amount >= 0, "LockletTokenVault: Invalid value");
        _creationFlatFeeLktAmount = amount;
    }

    function setRevocationFlatFeeLktAmount(uint256 amount) external onlyGovernor {
        require(amount >= 0, "LockletTokenVault: Invalid value");
        _revocationFlatFeeLktAmount = amount;
    }

    function setCreationPercentFee(uint256 amount) external onlyGovernor {
        require(amount >= 0 && amount <= 10000, "LockletTokenVault: Invalid value");
        _creationPercentFee = amount;
    }

    function setStakersRedisAddress(address addr) external onlyGovernor {
        require(addr != address(0), "LockletTokenVault: Invalid value");
        _stakersRedisAddress = addr;
    }

    function pause() external onlyGovernor {
        _pause();
    }

    function unpause() external onlyGovernor {
        _unpause();
    }

    function setDeprecated(bool deprecated) external onlyGovernor {
        _isDeprecated = deprecated;
    }



    modifier onlyGovernor() {
        require(hasRole(GOVERNOR_ROLE, msg.sender), "LockletTokenVault: Caller is not a GOVERNOR");
        _;
    }

    modifier contractNotDeprecated() {
        require(!_isDeprecated, "LockletTokenVault: This version of the contract is deprecated");
        _;
    }

}