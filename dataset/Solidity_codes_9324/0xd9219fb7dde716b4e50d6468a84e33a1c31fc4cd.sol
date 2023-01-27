
pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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
}// MIT
pragma solidity 0.6.12;


library SafeRatioMath {

    using SafeMathUpgradeable for uint256;

    uint256 private constant BASE = 10**18;

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(BASE).div(b);
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(b).div(BASE);
    }

    function rdivup(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a.mul(BASE).add(b.sub(1)).div(b);
    }

}// MIT
pragma solidity 0.6.12;

contract Ownable {

    address payable public owner;

    address payable public pendingOwner;

    event NewOwner(address indexed previousOwner, address indexed newOwner);
    event NewPendingOwner(
        address indexed oldPendingOwner,
        address indexed newPendingOwner
    );

    modifier onlyOwner() {

        require(owner == msg.sender, "onlyOwner: caller is not the owner");
        _;
    }

    function __Ownable_init() internal {

        owner = msg.sender;
        emit NewOwner(address(0), msg.sender);
    }

    function _setPendingOwner(address payable newPendingOwner)
        external
        onlyOwner
    {

        require(
            newPendingOwner != address(0) && newPendingOwner != pendingOwner,
            "_setPendingOwner: New owenr can not be zero address and owner has been set!"
        );

        address oldPendingOwner = pendingOwner;

        pendingOwner = newPendingOwner;

        emit NewPendingOwner(oldPendingOwner, newPendingOwner);
    }

    function _acceptOwner() external {

        require(
            msg.sender == pendingOwner,
            "_acceptOwner: Only for pending owner!"
        );

        address oldOwner = owner;
        address oldPendingOwner = pendingOwner;

        owner = pendingOwner;

        pendingOwner = address(0);

        emit NewOwner(oldOwner, owner);
        emit NewPendingOwner(oldPendingOwner, pendingOwner);
    }

    uint256[50] private __gap;
}// MIT
pragma solidity 0.6.12;


abstract contract ERC20Permit {
    using SafeMathUpgradeable for uint256;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x576144ed657c8304561e56ca632e17751956250114636e8c01f64a7f2c6d98cf;
    mapping(address => uint256) public erc20Nonces;

    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external virtual {
        require(_deadline >= block.timestamp, "permit: EXPIRED!");
        uint256 _currentNonce = erc20Nonces[_owner];

        bytes32 _digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            _owner,
                            _spender,
                            _getChainId(),
                            _value,
                            _currentNonce,
                            _deadline
                        )
                    )
                )
            );
        address _recoveredAddress = ecrecover(_digest, _v, _r, _s);
        require(
            _recoveredAddress != address(0) && _recoveredAddress == _owner,
            "permit: INVALID_SIGNATURE!"
        );
        erc20Nonces[_owner] = _currentNonce.add(1);
        _approveERC20(_owner, _spender, _value);
    }

    function _getChainId() internal pure virtual returns (uint256) {
        uint256 _chainId;
        assembly {
            _chainId := chainid()
        }
        return _chainId;
    }

    function _approveERC20(address _owner, address _spender, uint256 _amount) internal virtual;
}// MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

contract GovernanceToken {

    string public constant name = "dForce Vote Escrow Token";

    string public constant symbol = "veDF";

    uint8 public constant decimals = 18;

    mapping (address => mapping (address => uint96)) internal allowances;

    mapping (address => uint96) internal balances;

    mapping (address => address) public delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint256) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function allowance(address account, address spender) external view returns (uint256) {

        return allowances[account][spender];
    }

    function approve(address spender, uint256 rawAmount) external returns (bool) {

        uint96 amount;
        if (rawAmount == uint256(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(rawAmount, "veDF::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {

        return balances[account];
    }






    function delegate(address delegatee) public {

        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) public {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "veDF::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "veDF::delegateBySig: invalid nonce");
        require(now <= expiry, "veDF::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint96) {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint96) {

        require(blockNumber < block.number, "veDF::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }




    function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "veDF::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "veDF::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {

        uint32 blockNumber = safe32(block.number, "veDF::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal pure returns (uint256) {

        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
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
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


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
}// MIT
pragma solidity 0.6.12;


contract veDF is Initializable, Ownable, ReentrancyGuardUpgradeable, GovernanceToken, ERC20Permit {

    using SafeRatioMath for uint256;
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint256 internal constant BASE = 1e18;

    uint256 internal constant MIN_STEP = 1 weeks;

    uint256 internal constant MAX_STEP = 4 * 52 weeks;

    IERC20Upgradeable internal stakedDF;

    uint96 public totalSupply;

    struct Locker {
        uint32 dueTime;
        uint32 duration;
        uint96 amount;
    }

    mapping(address => Locker) internal lockers;

    EnumerableSetUpgradeable.AddressSet internal minters;

    event Lock(
        address caller,
        address recipient,
        uint256 underlyingAmount,
        uint96 tokenAmount,
        uint32 dueTime,
        uint32 duration
    );

    event UnLock(
        address caller,
        address from,
        uint256 underlyingAmount,
        uint96 tokenAmount
    );

    event MinterAdded(address minter);

    event MinterRemoved(address minter);

    constructor(IERC20Upgradeable _stakedDF) public {
        initialize(_stakedDF);
    }

    function initialize(IERC20Upgradeable _stakedDF) public initializer {

        __Ownable_init();
        __ReentrancyGuard_init();

        stakedDF = _stakedDF;
    }

    modifier isDurationValid(uint256 _dur) {

        require(
            _dur > 0 && _dur <= MAX_STEP,
            "duration is not valid."
        );
        _;
    }

    modifier isDueTimeValid(uint256 _due) {

        require(_due > block.timestamp, "due time is not valid.");
        _;
    }


    modifier onlyMinter() {

        require(minters.contains(msg.sender), "caller is not minter.");
        _;
    }

    function _addMinter(address _minter) external onlyOwner {

        require(_minter != address(0), "_minter not accepted zero address.");
        if (minters.add(_minter)) {
            emit MinterAdded(_minter);
        }
    }

    function _removeMinter(address _minter) external onlyOwner {

        require(_minter != address(0), "invalid minter address.");
        if (minters.remove(_minter)) {
            emit MinterRemoved(_minter);
        }
    }


    function isvDF() external pure returns (bool) {

        return true;
    }


    function _mint(address _account, uint96 _amount) internal {

        require(_account != address(0), "not allowed to mint to zero address.");

        totalSupply = add96(totalSupply, _amount, "total supply overflows.");
        balances[_account] = add96(
            balances[_account],
            _amount,
            "amount overflows."
        );
        emit Transfer(address(0), _account, _amount);

        _moveDelegates(delegates[address(0)], delegates[_account], _amount);
    }

    function _burn(address _account, uint96 _amount) internal {

        require(_account != address(0), "_burn: Burn from the zero address!");

        balances[_account] = sub96(
            balances[_account],
            _amount,
            "burn amount exceeds balance."
        );
        totalSupply = sub96(totalSupply, _amount, "total supply underflows.");
        emit Transfer(_account, address(0), _amount);

        _moveDelegates(delegates[_account], delegates[address(0)], _amount);
    }

    function _burnFrom(
        address _from,
        address _caller,
        uint96 _amount
    ) internal {

        if (_caller != _from) {
            uint96 _spenderAllowance = allowances[_from][_caller];

            if (_spenderAllowance != uint96(-1)) {
                uint96 _newAllowance = sub96(
                    _spenderAllowance,
                    _amount,
                    "burn amount exceeds spender's allowance."
                );
                allowances[_from][_caller] = _newAllowance;

                emit Approval(_from, _caller, _newAllowance);
            }
        }

        _burn(_from, _amount);
    }

    function _approveERC20(address _owner, address _spender, uint256 _rawAmount) internal override {

        uint96 _amount;
        if (_rawAmount == uint256(-1)) {
            _amount = uint96(-1);
        } else {
            _amount = safe96(_rawAmount, "veDF::approve: amount exceeds 96 bits");
        }

        allowances[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }

    function _weightedRate(uint256 _d)
        internal
        pure
        returns (uint256 _multipier)
    {

        _multipier = (_d * BASE) / MAX_STEP;
    }

    function _weightedExchange(uint256 _amount, uint256 _duration)
        internal
        pure
        returns (uint96)
    {

        return
            safe96(
                _amount.rmul(_weightedRate(_duration)),
                "weighted rate overflow."
            );
    }

    function _lock(
        address _caller,
        address _recipient,
        uint256 _amount,
        uint256 _duration
    ) internal isDurationValid(_duration) returns (uint96 _minted) {

        require(_amount > 0, "not allowed zero amount.");

        Locker storage _locker = lockers[_recipient];
        require(
            _locker.dueTime == 0,
            "due time refuses to create a new lock."
        );

        _minted = _weightedExchange(_amount, _duration);

        _locker.dueTime = safe32(
            (block.timestamp).add(_duration),
            "due time overflow."
        );
        _locker.duration = safe32(_duration, "duration overflow.");
        _locker.amount = safe96(_amount, "locked amount overflow.");

        emit Lock(
            _caller,
            _recipient,
            _amount,
            _minted,
            _locker.dueTime,
            _locker.duration
        );

        _mint(_recipient, _minted);
    }

    function _unLock(address _caller, address _from)
        internal
        returns (uint96 _burned)
    {

        Locker storage _locker = lockers[_from];
        require(
            uint256(_locker.dueTime) < block.timestamp,
            "due time not meeted."
        );

        _burned = balances[_from];
        _burnFrom(_from, _caller, _burned);

        uint256 _amount = uint256(_locker.amount);
        delete lockers[_from];

        emit UnLock(_caller, _from, _amount, _burned);
    }


    function create(
        address _recipient,
        uint256 _amount,
        uint256 _duration
    ) external onlyMinter nonReentrant returns (uint96) {

        stakedDF.safeTransferFrom(msg.sender, address(this), _amount);
        return _lock(msg.sender, _recipient, _amount, _duration);
    }

    function refill(address _recipient, uint256 _amount)
        external
        onlyMinter
        nonReentrant
        isDueTimeValid(lockers[_recipient].dueTime)
        returns (uint96 _refilled)
    {

        require(_amount > 0, "not allowed to add zero amount in lock-up");

        stakedDF.safeTransferFrom(msg.sender, address(this), _amount);

        Locker storage _locker = lockers[_recipient];
        _refilled = _weightedExchange(
            _amount,
            uint256(_locker.dueTime).sub(block.timestamp)
        );
        _locker.amount = safe96(
            uint256(_locker.amount).add(_amount),
            "refilled amount overflow."
        );
        emit Lock(
            msg.sender,
            _recipient,
            _amount,
            _refilled,
            _locker.dueTime,
            _locker.duration
        );

        _mint(_recipient, _refilled);
    }

    function extend(address _recipient, uint256 _duration)
        external
        onlyMinter
        nonReentrant
        isDueTimeValid(lockers[_recipient].dueTime)
        isDurationValid(uint256(lockers[_recipient].duration).add(_duration))
        returns (uint96 _extended)
    {

        Locker storage _locker = lockers[_recipient];
        _extended = _weightedExchange(uint256(_locker.amount), _duration);
        _locker.dueTime = safe32(
            uint256(_locker.dueTime).add(_duration),
            "extended due time overflow."
        );
        _locker.duration = safe32(
            uint256(_locker.duration).add(_duration),
            "extended duration overflow."
        );
        emit Lock(
            msg.sender,
            _recipient,
            0,
            _extended,
            _locker.dueTime,
            _locker.duration
        );

        _mint(_recipient, _extended);
    }

    function withdraw(address _from)
        external
        onlyMinter
        nonReentrant
        returns (uint96 _unlocked)
    {

        uint256 _amount = lockers[_from].amount;
        _unlocked = _unLock(msg.sender, _from);
        stakedDF.safeTransfer(msg.sender, _amount);
    }

    function withdraw2(address _from)
        external
        onlyMinter
        nonReentrant
        returns (uint96 _unlocked)
    {

        uint256 _amount = lockers[_from].amount;
        _unlocked = _unLock(msg.sender, _from);
        stakedDF.safeTransfer(_from, _amount);
    }

    function refresh(
        address _recipient,
        uint256 _amount,
        uint256 _duration
    ) external onlyMinter nonReentrant returns (uint96 _refreshed, uint256 _refund) {

        uint256 outstanding = uint256(lockers[_recipient].amount);
        if (_amount > outstanding) {
            stakedDF.safeTransferFrom(
                msg.sender,
                address(this),
                _amount - outstanding
            );
        }

        _unLock(msg.sender, _recipient);
        _refreshed = _lock(msg.sender, _recipient, _amount, _duration);

        if (_amount < outstanding) {
            _refund = outstanding - _amount;
            stakedDF.safeTransfer(msg.sender, _refund);
        }
    }

    function refresh2(
        address _recipient,
        uint256 _amount,
        uint256 _duration
    ) external onlyMinter nonReentrant returns (uint96 _refreshed) {

        uint256 outstanding = uint256(lockers[_recipient].amount);
        if (_amount > outstanding) {
            stakedDF.safeTransferFrom(
                msg.sender,
                address(this),
                _amount - outstanding
            );
        }

        _unLock(msg.sender, _recipient);
        _refreshed = _lock(msg.sender, _recipient, _amount, _duration);

        if (_amount < outstanding)
            stakedDF.safeTransfer(_recipient, outstanding - _amount);
    }


    function getMinters() external view returns (address[] memory _minters) {

        uint256 _len = minters.length();
        _minters = new address[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _minters[i] = minters.at(i);
        }
    }

    function getLocker(address _lockerAddress) external view returns (uint32 ,uint32 ,uint96) {

        Locker storage _locker = lockers[_lockerAddress];
        return (_locker.dueTime, _locker.duration, _locker.amount);
    }

    function calcBalanceReceived(address _lockerAddress, uint256 _amount, uint256 _duration)
        external
        view
        returns (uint256)
    {

        Locker storage _locker = lockers[_lockerAddress];
        if (_locker.dueTime < block.timestamp)
            return _amount.rmul(_weightedRate(_duration));

        uint256 _receiveAmount = uint256(_locker.amount).rmul(_weightedRate(_duration));
        return _receiveAmount.add(_amount.rmul(_weightedRate(uint256(_locker.dueTime).add(_duration).sub(block.timestamp))));
    }
}