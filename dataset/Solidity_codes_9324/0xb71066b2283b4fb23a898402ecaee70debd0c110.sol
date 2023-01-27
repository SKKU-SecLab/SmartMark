



pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




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
}




pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}



pragma solidity ^0.8.0;





library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface IUniswapV2Pair {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);

}

interface IUniFactory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);

}

contract DLock is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IUniFactory public uniswapFactory;

    struct UserInfo {
        EnumerableSet.AddressSet lockedTokens; //  records of user's locked tokens
        mapping(address => uint256[]) locksForToken; // toekn address -> lock id
    }

    struct TokenLock {
        uint256 lockDate; // locked date
        uint256 amount; // locked tokens amount
        uint256 initialAmount; // the initial lock amount
        uint256 unlockDate; // unlock date
        uint256 lockID; // lock id per token
        address owner; // lock owner
    }

    mapping(address => UserInfo) private users; // user address -> user info

    EnumerableSet.AddressSet private lockedTokens;
    mapping(address => TokenLock[]) public tokenLocks;

    struct FeeStruct {
        uint256 ethFee; // fee to lock
    }

    FeeStruct public gFees;

    address payable devaddr;
    address payable multiSigAddr;

    event onDeposit(
        address indexed Token,
        address indexed user,
        uint256 amount,
        uint256 lockDate,
        uint256 unlockDate
    );
    event onWithdraw(address indexed Token, uint256 amount);
    event onTranferLockOwnership(
        address indexed Token,
        address indexed oldOwner,
        address newOwner
    );
    event onRelock(address indexed Token, uint256 amount);

    constructor(IUniFactory _uniswapFactory, address payable _devAddress, address payable _multiSigAddr) {
        devaddr = _devAddress;
        multiSigAddr = _multiSigAddr;
        gFees.ethFee = 75000000000000000; // initial fee set to 0.075 ETH
        uniswapFactory = _uniswapFactory;
    }

    function setDev(address payable _devAddress) external {

        require(_msgSender() == multiSigAddr);
        devaddr = _devAddress;
    }

    function setMultiSig(address payable _multiSigAddr) external {

        require(_msgSender() == multiSigAddr);
        multiSigAddr = _multiSigAddr;
    }

    function setFees(uint256 _ethFee) external {

        require(_msgSender() == multiSigAddr);
        gFees.ethFee = _ethFee;
    }

    function lockTokens(
        address _lockToken,
        uint256 _amount,
        uint256 _unlock_date,
        uint256 _is_lp_tokens,
        address payable _lock_owner
    ) external payable nonReentrant {

        require(_unlock_date < 10000000000, "DLock: TIMESTAMP INVALID"); // no milliseconds
        require(_amount > 0, "DLock: INSUFFICIENT"); // no 0 tokens

        if (_is_lp_tokens == 1) {
            IUniswapV2Pair lpair = IUniswapV2Pair(address(_lockToken));
            address factoryPairAddress = uniswapFactory.getPair(
                lpair.token0(),
                lpair.token1()
            );
            require(
                factoryPairAddress == address(_lockToken),
                "DLock: NOT UNIV2"
            );
            TransferHelper.safeTransferFrom(
                _lockToken,
                address(msg.sender),
                address(this),
                _amount
            );
        } else {
            TransferHelper.safeTransferFrom(
                _lockToken,
                address(msg.sender),
                address(this),
                _amount
            );
        }

        uint256 ethFee = gFees.ethFee;
        require(msg.value == ethFee, "DLock: FEE NOT MET");
        if (ethFee > 0) {
            devaddr.transfer(ethFee);
        }

        TokenLock memory the_lock;
        the_lock.lockDate = block.timestamp;
        the_lock.amount = _amount;
        the_lock.initialAmount = _amount;
        the_lock.unlockDate = _unlock_date;
        the_lock.lockID = tokenLocks[_lockToken].length;
        the_lock.owner = _lock_owner;

        tokenLocks[_lockToken].push(the_lock);
        lockedTokens.add(_lockToken);

        UserInfo storage user = users[_lock_owner];
        user.lockedTokens.add(_lockToken);
        uint256[] storage user_locks = user.locksForToken[_lockToken];
        user_locks.push(the_lock.lockID);

        emit onDeposit(
            _lockToken,
            msg.sender,
            the_lock.amount,
            the_lock.lockDate,
            the_lock.unlockDate
        );
    }

    function relock(
        address _lockToken,
        uint256 _index,
        uint256 _lock_id,
        uint256 _unlock_date
    ) external payable nonReentrant {

        require(_unlock_date < 10000000000, "DLock: TIMESTAMP INVALID");
        uint256 lock_id = users[msg.sender].locksForToken[_lockToken][_index];
        TokenLock storage userLock = tokenLocks[_lockToken][lock_id];
        require(
            lock_id == _lock_id && userLock.owner == msg.sender,
            "DLock: LOCK DOES NOT MATCH"
        );
        require(userLock.unlockDate < _unlock_date, "DLock: UNLOCK BEFORE");

        uint256 ethFee = gFees.ethFee;
        require(msg.value == ethFee, "DLock: FEE NOT MET");
        if (ethFee > 0) {
            devaddr.transfer(ethFee);
        }

        userLock.unlockDate = _unlock_date;

        emit onRelock(_lockToken, userLock.amount);
    }

    function withdraw(
        address _lockToken,
        uint256 _index,
        uint256 _lock_id,
        uint256 _amount
    ) external nonReentrant {

        require(_amount > 0, "DLock: ZERO WITHDRAWL NOT ALLOWED");
        uint256 lock_id = users[msg.sender].locksForToken[_lockToken][_index];
        TokenLock storage userLock = tokenLocks[_lockToken][lock_id];
        require(
            lock_id == _lock_id && userLock.owner == msg.sender,
            "DLock: LOCK DOES NOT MATCH"
        );
        require(
            userLock.unlockDate < block.timestamp,
            "DLock: UNLOCK DATE NOT DUE"
        );
        userLock.amount = userLock.amount.sub(_amount);

        if (userLock.amount == 0) {
            uint256[] storage userLocks = users[msg.sender].locksForToken[
                _lockToken
            ];
            userLocks[_index] = userLocks[userLocks.length - 1];
            userLocks.pop();
            if (userLocks.length == 0) {
                users[msg.sender].lockedTokens.remove(_lockToken);
            }
        }

        TransferHelper.safeTransfer(_lockToken, msg.sender, _amount);
        emit onWithdraw(_lockToken, _amount);
    }

    function incrementLock(
        address _lockToken,
        uint256 _index,
        uint256 _lock_id,
        uint256 _amount
    ) external payable nonReentrant {

        require(_amount > 0, "DLock: ZERO AMOUNT");
        uint256 lock_id = users[msg.sender].locksForToken[_lockToken][_index];
        TokenLock storage userLock = tokenLocks[_lockToken][lock_id];
        require(
            lock_id == _lock_id && userLock.owner == msg.sender,
            "DLock: LOCK DOES NOT MATCH"
        );

        TransferHelper.safeTransferFrom(
            _lockToken,
            address(msg.sender),
            address(this),
            _amount
        );

        uint256 ethFee = gFees.ethFee;
        require(msg.value == ethFee, "DLock: FEE NOT MET");
        if (ethFee > 0) {
            devaddr.transfer(ethFee);
        }
        
        userLock.amount = userLock.amount.add(_amount);

        emit onDeposit(
            _lockToken,
            msg.sender,
            _amount,
            userLock.lockDate,
            userLock.unlockDate
        );
    }

    function transferLockOwnership(
        address _lockToken,
        uint256 _index,
        uint256 _lock_id,
        address payable _new_owner
    ) external {

        require(msg.sender != _new_owner, "Dlock: YOU ARE ALREADY THE OWNER");
        uint256 lock_id = users[msg.sender].locksForToken[_lockToken][_index];
        TokenLock storage transferredLock = tokenLocks[_lockToken][lock_id];
        require(
            lock_id == _lock_id && transferredLock.owner == msg.sender,
            "DLock: LOCK DOES NOT MATCH"
        ); // ensures correct lock is affected

        UserInfo storage user = users[_new_owner];
        user.lockedTokens.add(_lockToken);
        uint256[] storage user_locks = user.locksForToken[_lockToken];
        user_locks.push(transferredLock.lockID);

        uint256[] storage userLocks = users[msg.sender].locksForToken[
            _lockToken
        ];
        userLocks[_index] = userLocks[userLocks.length - 1];
        userLocks.pop();
        if (userLocks.length == 0) {
            users[msg.sender].lockedTokens.remove(_lockToken);
        }
        transferredLock.owner = _new_owner;

        emit onTranferLockOwnership(_lockToken, msg.sender, _new_owner);
    }

    function getTotalLocksForToken(address _lockToken)
        external
        view
        returns (uint256)
    {

        return tokenLocks[_lockToken].length;
    }

    function getLocksByTokenAddress(address _lockToken)
        external
        view
        returns (TokenLock[] memory)
    {

        return tokenLocks[_lockToken];
    }

    function getLocksByTokenAddressAndId(address _lockToken, uint256 _id)
        external
        view
        returns (TokenLock memory)
    {

        return tokenLocks[_lockToken][_id];
    }

    function getTotalLockedTokens() external view returns (uint256) {

        return lockedTokens.length();
    }

    function getLockedTokenAt(uint256 _index) external view returns (address) {

        return lockedTokens.at(_index);
    }

    function getUserTotalLockedTokens(address _user)
        external
        view
        returns (uint256)
    {

        UserInfo storage user = users[_user];
        return user.lockedTokens.length();
    }

    function getUserLockedTokenAt(address _user, uint256 _index)
        external
        view
        returns (address)
    {

        UserInfo storage user = users[_user];
        return user.lockedTokens.at(_index);
    }

    function getUserTotalLocksForToken(address _user, address _lockToken)
        external
        view
        returns (uint256)
    {

        UserInfo storage user = users[_user];
        return user.locksForToken[_lockToken].length;
    }

    function getUserFull(address _user)
        external
        view
        returns (address[] memory)
    {

        UserInfo storage user = users[_user];
        return user.lockedTokens.values();
    }

    function getAllLockAddresses() external view returns (address[] memory) {

        return lockedTokens.values();
    }

    function getUserLockForTokenAt(
        address _user,
        address _lockToken,
        uint256 _index
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        )
    {

        uint256 lockID = users[_user].locksForToken[_lockToken][_index];
        TokenLock storage tokenLock = tokenLocks[_lockToken][lockID];
        return (
            tokenLock.lockDate,
            tokenLock.amount,
            tokenLock.initialAmount,
            tokenLock.unlockDate,
            tokenLock.lockID,
            tokenLock.owner
        );
    }
}