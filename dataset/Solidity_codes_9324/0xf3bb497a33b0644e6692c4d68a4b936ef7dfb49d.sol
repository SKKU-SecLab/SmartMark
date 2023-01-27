
pragma solidity ^0.8.4;

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
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferNative(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: Native_TRANSFER_FAILED');
    }
}


library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

contract StakingPool is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _governors;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 lockAmount;
        uint256 releaseAmount;
    }

    struct PoolInfo {
        IERC20 lpToken;
        IERC20 rewardToken;

        uint256 timeStart;
        uint256 timeEnd;

        uint256 bonusPerSecond;
        
        uint256 lockedSeconds;  //after exit stake ,need lock time

        uint256 lpAmount;

        uint256 lastRewardTime;
        uint256 accBonusPerShare;

        uint256 lpTokenType;  //0 indicate normal token, 1 is xtoken
        IERC20  lpTokenFrom; 

        bool open; //pool status
    }

    PoolInfo[] public poolInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    struct WithdrawOrder {
        uint256 orderTime;
        uint256 amount;
    }

    mapping(uint256 => mapping(address => WithdrawOrder[])) public userWithdrawInfo;

    event Deposit(address indexed user, uint256 indexed pid, address token, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid,  address token, uint256 amount);
    event WithdrawUnlock(address indexed user, uint256 indexed pid, address token, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event GovernorAdded( address _user);
    event GovernorDeleted( address _user);

    bytes32 constant public STAKINGPOOL_CALL_HASH_TYPE = keccak256("withdrawExit(address receiver,uint256 pid,uint256 exitAmount)");

    constructor(){
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function getLockLength(uint256 _pid, address _user) public view returns (uint256) {
        return userWithdrawInfo[_pid][_user].length;
    }

    function add( IERC20 _lpToken,IERC20 _rewardToken, uint256 _timeStart, uint256 _timeEnd , uint256 _bonusPerSecond,uint256 _lockedSeconds,
        uint256 _lpTokenType, IERC20 _lpTokenFrom , bool _open) public onlyGovernor {
        
        require( _timeStart > block.timestamp && _timeEnd > _timeStart, "invalid time limit");
        
        poolInfo.push(PoolInfo({
            lpToken : _lpToken,
            rewardToken : _rewardToken,
            timeStart : _timeStart,
            timeEnd : _timeEnd,

            bonusPerSecond : _bonusPerSecond,
            lockedSeconds : _lockedSeconds,

            lpAmount : 0,
            lastRewardTime : _timeStart,
            accBonusPerShare :0,

            lpTokenType :_lpTokenType,
            lpTokenFrom : _lpTokenFrom,
            open : _open
        }));

        uint256 _amount = _timeEnd.sub(_timeStart).mul(_bonusPerSecond);

        TransferHelper.safeTransferFrom( address(_rewardToken), msg.sender, address(this), _amount);
        
    }

    function setPoolInfo( uint256 _pid, uint256 _timeStart, uint256 _timeEnd , uint256 _bonusPerSecond,uint256 _lockedSeconds,
        uint256 _lpTokenType, IERC20 _lpTokenFrom , bool _open) public onlyGovernor {
        
        require( _timeStart > block.timestamp && _timeEnd > _timeStart, "invalid time limit");
        
        PoolInfo storage pool = poolInfo[_pid];

        require( pool.timeStart > block.timestamp, "staking is enabled");

        require( block.timestamp < pool.timeStart, "pool is mining");

        uint256 _newAmount = _timeEnd.sub(_timeStart).mul(_bonusPerSecond);
        uint256 _amount = pool.timeEnd.sub(pool.timeStart).mul(pool.bonusPerSecond);

        if( _newAmount > _amount){
            TransferHelper.safeTransferFrom( address(pool.rewardToken), msg.sender, address(this), _newAmount.sub(_amount));
        }
        else if( _newAmount < _amount){
            TransferHelper.safeTransfer( address(pool.rewardToken), msg.sender , _amount.sub(_newAmount) );
        }

        pool.timeStart = _timeStart;
        pool.lastRewardTime = _timeStart;
        pool.timeEnd = _timeEnd;
        pool.bonusPerSecond = _bonusPerSecond;
        pool.lockedSeconds = _lockedSeconds;

        pool.lpTokenType = _lpTokenType;
        pool.lpTokenFrom = _lpTokenFrom;
        pool.open = _open;
    }

    function setPoolStatus( uint256 _pid,  bool _open) public onlyGovernor {
        PoolInfo storage pool = poolInfo[_pid];
        pool.open = _open;
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 number = block.timestamp ;
        if (number <= pool.lastRewardTime) {
            return;
        }

        if( pool.lastRewardTime >= pool.timeEnd){
            return;
        }

        if( number >= pool.timeEnd ){
            number = pool.timeEnd;
        }

        uint256 lpSupply = pool.lpAmount;
        if (lpSupply == 0) {
            pool.lastRewardTime = number;
            return;
        }

        uint256 multiplier = number.sub(pool.lastRewardTime);
        uint256 bonusReward = multiplier.mul(pool.bonusPerSecond);
        pool.accBonusPerShare = pool.accBonusPerShare.add(bonusReward.mul(1e12).div(lpSupply));
        pool.lastRewardTime = number;
    }


    function pending(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accBonusPerShare = pool.accBonusPerShare;
        uint256 lpSupply = pool.lpAmount;
        uint256 number = block.timestamp;

        if( number <= pool.timeStart ){
            return 0;
        }

        if( number > pool.timeEnd ){
            number = pool.timeEnd;
        }

        if (number > pool.lastRewardTime && lpSupply != 0) {
            uint256 multiplier = number.sub(pool.lastRewardTime);
            uint256 bonusReward = multiplier.mul(pool.bonusPerSecond) ;
            accBonusPerShare = accBonusPerShare.add(bonusReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accBonusPerShare).div(1e12).sub(user.rewardDebt);
    }


    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];

        require( pool.open == true , "pool is closed!");

        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = user.amount.mul(pool.accBonusPerShare).div(1e12).sub(user.rewardDebt);
            if (pendingAmount > 0) {
                TransferHelper.safeTransfer( address(pool.rewardToken), msg.sender , pendingAmount );
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);

            pool.lpAmount = pool.lpAmount.add(_amount); 
        }
        user.rewardDebt = user.amount.mul(pool.accBonusPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, address(pool.lpToken), _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);

        uint256 pendingAmount = user.amount.mul(pool.accBonusPerShare).div(1e12).sub(user.rewardDebt);
        if (pendingAmount > 0) {
            TransferHelper.safeTransfer( address(pool.rewardToken), msg.sender , pendingAmount );
        }
        if (_amount > 0  ) {
            if( pool.lockedSeconds == 0 ){
                user.amount = user.amount.sub(_amount);
                pool.lpAmount = pool.lpAmount.sub(_amount); 
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }
            else{
                user.lockAmount = user.lockAmount.add(_amount);

                userWithdrawInfo[_pid][msg.sender].push(WithdrawOrder({orderTime: block.timestamp, amount: _amount}));
            }
            
        }
        user.rewardDebt = user.amount.mul(pool.accBonusPerShare).div(1e12);
        
        emit Withdraw(msg.sender, _pid, address(pool.lpToken), _amount);
    }

    function pendingUnlock(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        uint256 unlockAmount = 0;
        uint256 checkTime = block.timestamp;

        if( user.lockAmount > 0 && pool.lockedSeconds > 0){
            WithdrawOrder[] memory orders = userWithdrawInfo[_pid][_user];
            uint256 len = orders.length;
            for (uint256 i = 0; i < len; i++) {
                if( orders[i].orderTime.add(pool.lockedSeconds) <= checkTime ){
                    unlockAmount = unlockAmount.add( orders[i].amount);
                }
                else{
                    break;//withdraw orders sorted by ordertime asc
                }
            }
        }

        return unlockAmount;
    }

    function withdrawUnlock(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(pool.lockedSeconds > 0 , "invalid pool");

        updatePool(_pid);

        uint256 unlockAmount = 0;
        uint256 checkTime = block.timestamp;

        uint256 index = 0;
        if( user.lockAmount > 0 && pool.lockedSeconds > 0){
            WithdrawOrder[] memory orders = userWithdrawInfo[_pid][msg.sender];
            uint256 len = orders.length;
            if( len > 0 ){
                index = len ;
                for (uint256 i = 0; i < len; i++) {
                    if( orders[i].orderTime.add(pool.lockedSeconds) <= checkTime ){
                        unlockAmount = unlockAmount.add( orders[i].amount);
                    }
                    else{
                        index = i;
                        break;
                    }
                }

                for (uint256 i = 0; i < len - index; i++) {
                    userWithdrawInfo[_pid][msg.sender][i] = userWithdrawInfo[_pid][msg.sender][i + index];
                }
                for (uint256 j = len -index; j < len ; j++) {
                    userWithdrawInfo[_pid][msg.sender].pop();
                }
            }     
        }

        uint256 pendingAmount = user.amount.mul(pool.accBonusPerShare).div(1e12).sub(user.rewardDebt);
        if (pendingAmount > 0) {
            TransferHelper.safeTransfer( address(pool.rewardToken), msg.sender , pendingAmount );
        }

        if (unlockAmount > 0  ) {
            user.amount = user.amount.sub(unlockAmount);
            user.lockAmount = user.lockAmount.sub(unlockAmount);
            user.releaseAmount = user.releaseAmount.add( unlockAmount );

            pool.lpAmount = pool.lpAmount.sub(unlockAmount); 
            pool.lpToken.safeTransfer(address(msg.sender), unlockAmount);
        }
        user.rewardDebt = user.amount.mul(pool.accBonusPerShare).div(1e12);

        emit WithdrawUnlock(msg.sender, _pid, address(pool.lpToken), unlockAmount);
    }


    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        if( amount > 0 && pool.lockedSeconds == 0 ){
            user.amount = 0;
            user.rewardDebt = 0;
            pool.lpToken.safeTransfer(address(msg.sender), amount);
        }
        
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function withdrawEmergency(address tokenaddress,address to) public onlyOwner{	
        TransferHelper.safeTransfer( tokenaddress, to , IERC20(tokenaddress).balanceOf(address(this)));
    }

    function withdrawEmergencyNative(address to , uint256 amount) public onlyOwner{	
        TransferHelper.safeTransferNative(to, amount);
    }

    function addGovernor(address _governor) public onlyOwner returns (bool) {
        require(_governor != address(0), "_governor is the zero address");
        emit GovernorAdded( _governor );
        return EnumerableSet.add(_governors, _governor);
    }

    function delGovernor(address _governor) public onlyOwner returns (bool) {
        require(_governor != address(0), "_governor is the zero address");
        emit GovernorDeleted( _governor );
        return EnumerableSet.remove(_governors, _governor);
    }

    function getGovernorLength() public view returns (uint256) {
        return EnumerableSet.length(_governors);
    }

    function isGovernor(address account) public view returns (bool) {
        return EnumerableSet.contains(_governors, account);
    }

    function getGovernor(uint256 _index) public view  returns (address){
        require(_index <= getGovernorLength() - 1, "index out of bounds");
        return EnumerableSet.at(_governors, _index);
    }

    modifier onlyGovernor() {
        require(isGovernor(msg.sender) || owner() == msg.sender , "caller is not the governor");
        _;
    }

}