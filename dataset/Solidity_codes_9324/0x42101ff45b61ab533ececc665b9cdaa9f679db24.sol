pragma solidity 0.6.12;


contract PausePool{

    
    mapping(uint256 => bool) private pausedPool;

    event PoolPaused(uint256 indexed _pid, bool _paused);

    modifier whenNotPaused(uint256 _pid) {

        require(!pausedPool[_pid], "Pausable: paused");
        _;
    }

    function pausePoolViaPid(uint256 _pid, bool _paused) internal {

        pausedPool[_pid] = _paused;
        emit PoolPaused(_pid, _paused);
    }
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}pragma solidity 0.6.12;




contract SilToken is ERC20, Ownable {
    uint256 public maxMint;
    bool public mintOver;
    constructor ( uint256 _maxMint ) ERC20("SIL Finance Token V2", "SIL") public  {
        maxMint = _maxMint;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {

        if(totalSupply().add(_amount) <= maxMint ) {
            _mint(_to, _amount);
            _moveDelegates(address(0), _delegates[_to], _amount);
        }else {
            mintOver = true;
            uint256 mintAmount = maxMint - totalSupply();
             _mint(_to, mintAmount);
            _moveDelegates(address(0), _delegates[_to], mintAmount);
        }
    }

    function reduce(uint256 _reduceAmount) public onlyOwner() {
        require(_reduceAmount.add(totalSupply()) < maxMint , "Reduce over amount");
        maxMint = maxMint.sub(_reduceAmount);
    }


    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CYZ::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CYZ::delegateBySig: invalid nonce");
        require(now <= expiry, "CYZ::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "CYZ::getPriorVotes: not yet determined");

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

    function _transfer(address sender, address recipient, uint256 amount) internal override virtual {
        super._transfer(sender, recipient, amount);
        _moveDelegates(_delegates[sender], _delegates[recipient], amount);
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying SUSHIs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "CYZ::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}pragma solidity 0.6.12;

interface IMatchPair {
    
    function stake(uint256 _index, address _user,uint256 _amount) external;  // owner
    function untakeToken(uint256 _index, address _user,uint256 _amount) external returns (uint256 _tokenAmount, uint256 _leftAmount);// owner

    function token(uint256 _index) external view  returns (address);

    function queueTokenAmount(uint256 _index) external view  returns (uint256);
    function maxAcceptAmount(uint256 _index, uint256 _molecular, uint256 _denominator, uint256 _inputAmount) external view returns (uint256);

}pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
}pragma solidity >=0.5.0;

interface IMintRegulator {

    function getScale() external view returns (uint256 _molecular, uint256 _denominator);
}pragma solidity 0.6.12;

interface IProxyRegistry {
    function getProxy(uint256 _index) external view returns(address);
}// MIT

pragma solidity >=0.6.0 <0.8.0;
abstract contract UpgradeabilityOwner is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initOwner(address _initOwner) internal {
        require(_owner == address(0), "Ownable: had inited");
        _owner = _initOwner;
        emit OwnershipTransferred(address(0), _initOwner);
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
}// MIT
pragma solidity 0.6.12;


contract TrustList is UpgradeabilityOwner {
    
    mapping(address => bool) whiteMap;

    event WhiteListUpdate(address indexed _account, bool _trustable);

    function updateList(address _account, bool _trustable) public  onlyOwner() {
        whiteMap[_account] = _trustable;

        emit WhiteListUpdate(_account, _trustable);
    }

    function trustable(address _account) internal returns (bool) {
        return whiteMap[_account];
    }

}pragma solidity 0.6.12;






contract SilMaster is TrustList, IProxyRegistry, PausePool{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 buff;       // if not `0`,1000-based, allow NFT Manager adjust the value of buff 

        uint256 totalDeposit;
        uint256 totalWithdraw;
    }

    struct PoolInfo {
        IMatchPair matchPair;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SILs to distribute per block.

        uint256 lastRewardBlock;  // Last block number that SILs distribution occurs by token0.

        uint256 totalDeposit0;  // totol deposit token0
        uint256 totalDeposit1;  // totol deposit token0

        uint256 accSilPerShare0; // Accumulated SILs per share, times 1e12. See below.
        uint256 accSilPerShare1; // Accumulated SILs per share, times 1e12. See below.
    }

    uint256 constant public VERSION = 2;
    bool private initialized;
    SilToken public sil;
    address public devaddr;
    address public ecosysaddr;
    address public repurchaseaddr;
    address public nftProphet;

    address public WETH;
    address public mintRegulator;
    uint256 public bonusEndBlock;
    uint256 public baseSilPerBlock;
    uint256 public silPerBlock;
    uint256 public bonus_multiplier;
    uint256 public maxAcceptMultiple;
    uint256 public maxAcceptMultipleDenominator;

    uint256 public totalAllocPoint;
    uint256 public startBlock;
    uint256 public periodFinish;
    uint256 public feeRewardRate;
    bool public whaleSpear;
    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo0;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo1;
    mapping (uint256 => address) public matchPairRegistry;
    mapping (uint256 => bool) public matchPairPause;
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 indexed index, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 indexed index, uint256 amount);
    event SilPerBlockUpdated(address indexed user, uint256 _molecular, uint256 _denominator);
    event WithdrawSilToken(address indexed user, uint256 indexed pid, uint256 silAmount0, uint256 silAmount1);

    function initialize(
            SilToken _sil,
            address _devaddr,
            address _ecosysaddr,
            address _repurchaseaddr,
            address _weth,
            address _owner
        ) public {
        require(!initialized, "Contract instance has already been initialized");
        initialized = true;

        sil = _sil;
        devaddr = _devaddr;
        ecosysaddr = _ecosysaddr;
        repurchaseaddr = _repurchaseaddr;
        WETH = _weth;
        initOwner(_owner);
    }

    function initSetting(
        uint256 _silPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _bonus_multiplier)
        external
        onlyOwner()
    {
        require(initialized, "Not initialized");
        require(startBlock == 0, "Init only once");
        silPerBlock = _silPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        baseSilPerBlock = _silPerBlock;
        bonus_multiplier = _bonus_multiplier;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    function setMintRegulator(address _regulator) external onlyOwner() {
        mintRegulator = _regulator;
    }
    function matchPairRegister(uint256 _index, address _implementation) external onlyOwner() {
        matchPairRegistry[_index] = _implementation;
    }
    function setWhaleSpearRange(uint _maxAcceptMultiple, uint _maxAcceptMultipleDenominator) external onlyOwner() {
        maxAcceptMultiple = _maxAcceptMultiple;
        maxAcceptMultipleDenominator = _maxAcceptMultipleDenominator;
    }

    function holdWhaleSpear(bool _hold) external onlyOwner {
        require(maxAcceptMultiple > 0 && maxAcceptMultipleDenominator >0, "require call setWhaleSpearRange() first");
        whaleSpear = _hold;
    }
    
    function setNFTProphet(address _nftProphet) external onlyOwner()  {
        nftProphet = _nftProphet;
    }
    
    function updateSilPerBlock() public {
        require(mintRegulator != address(0), "IMintRegulator not setting");

        (uint256 _molecular, uint256 _denominator)  = IMintRegulator(mintRegulator).getScale();
        uint256 silPerBlockNew = baseSilPerBlock.mul(_molecular).div(_denominator);
        if(silPerBlock != silPerBlockNew) {
             massUpdatePools();
             silPerBlock = silPerBlockNew;
        }
    
        emit SilPerBlockUpdated(msg.sender, _molecular, _denominator);
    }
    function reduceSil(uint256 _reduceAmount) external onlyOwner() {

        baseSilPerBlock = baseSilPerBlock.sub(baseSilPerBlock.mul(_reduceAmount).div(sil.maxMint()));
        sil.reduce(_reduceAmount);
        massUpdatePools();
        if(mintRegulator != address(0)) {
            updateSilPerBlock();
        }else {
            silPerBlock = baseSilPerBlock;
        }

    }

    function add(uint256 _allocPoint, IMatchPair _matchPair) external onlyOwner {

        massUpdatePools();
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            matchPair: _matchPair,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            totalDeposit0: 0,
            totalDeposit1: 0,
            accSilPerShare0: 0,
            accSilPerShare1: 0
            }));
    }
   
    function set(uint256 _pid, uint256 _allocPoint) external onlyOwner {

        massUpdatePools();
        
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        if(_from < startBlock) {
            _from = startBlock;
        }

        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(bonus_multiplier);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).mul(bonus_multiplier).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    function pendingSil(uint256 _pid, uint256 _index, address _user) external view   returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = _index == 0? userInfo0[_pid][_user] : userInfo1[_pid][_user];

        uint256 accSilPerShare = _index == 0? pool.accSilPerShare0 : pool.accSilPerShare1;
        uint256 lpSupply = _index == 0? pool.totalDeposit0 : pool.totalDeposit1;


        if (block.number > pool.lastRewardBlock && lpSupply != 0) {            
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            
            uint256 silReward = multiplier.mul(silPerBlock).mul(pool.allocPoint).div(totalAllocPoint);//
            uint256 totalMint = sil.totalSupply();
            if(sil.maxMint()< totalMint.add(silReward)) {
                silReward = sil.maxMint().sub(totalMint);
            }
            silReward = getFeeRewardAmount(pool.allocPoint, pool.lastRewardBlock).add(silReward);
            accSilPerShare = accSilPerShare.add(silReward.mul(1e12).div(lpSupply).div(2));
        } 
        return  amountBuffed(user.amount, user.buff).mul(accSilPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 totalDeposit0 = pool.totalDeposit0;
        uint256 totalDeposit1 = pool.totalDeposit1;

        if(totalDeposit0.add(totalDeposit1) > 0 ) {
            uint256 silReward;
            if(!sil.mintOver()) {
                uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
                silReward = multiplier.mul(silPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            }
            silReward = getFeeRewardAmount(pool.allocPoint, pool.lastRewardBlock).add(silReward);
            if(totalDeposit0 > 0) {
                pool.accSilPerShare0 = pool.accSilPerShare0.add(silReward.mul(1e12).div(totalDeposit0).div(2));
            }
            if(totalDeposit1 > 0) {
                pool.accSilPerShare1 = pool.accSilPerShare1.add(silReward.mul(1e12).div(totalDeposit1).div(2));
            }
            if(totalDeposit0 ==0 || totalDeposit1==0) {
                silReward = silReward.div(2);
            }



            if(silReward > 0){        
                sil.mint(devaddr, silReward.mul(17).div(68)); // 17%
                sil.mint(ecosysaddr, silReward.mul(15).div(68)); // 15%
                sil.mint(address(this), silReward); // 68%
            }
        }
        
        pool.lastRewardBlock = block.number;
    }

    function getFeeRewardAmount(uint allocPoint, uint256 lastRewardBlock ) private view returns (uint256 feeReward) {
        if(feeRewardRate > 0) {

            uint256 endPoint = block.number < periodFinish ? block.number : periodFinish;
            if(endPoint > lastRewardBlock) {
                feeReward = endPoint.sub(lastRewardBlock).mul(feeRewardRate).mul(allocPoint).div(totalAllocPoint);
            }
        }
    }

    function batchGrantBuff(uint256[] calldata _pid, uint256[] calldata _index, uint256[] calldata _value, address[] calldata _user) public {
        require(msg.sender == nftProphet, "Grant buff: Prophet allowed");
        require(_pid.length > 0 , "_pid.length is zore");
        require(_pid.length ==  _index.length ,   "Require length equal: pid, index");
        require(_index.length ==  _value.length , "Require length equal: index, _value");
        require(_value.length ==  _user.length ,  "Require length equal: _value, _user");
        
        uint256 length = _pid.length;

        for (uint256 i = 0; i < length; i++) {
           grantBuff(_pid[i], _index[i], _value[i], _user[i]);
        }
    }

    function grantBuff(uint256 _pid, uint256 _index, uint256 _value, address _user) public {
        require(msg.sender == nftProphet, "Grant buff: Prophet allowed");
        require(_index < 2, "Index must 0 or 1" );

        UserInfo storage user = _index == 0  ? userInfo0[_pid][_user] : userInfo1[_pid][_user];
        if (user.amount > 0) { // && !sil.mintOver()
            updatePool(_pid);

            PoolInfo storage pool = poolInfo[_pid];
            uint256 accPreShare;
            if(_index == 0) {
               accPreShare = pool.accSilPerShare0;
               pool.totalDeposit0 = pool.totalDeposit0
                                    .sub(amountBuffed(user.amount, user.buff))
                                    .add(amountBuffed(user.amount, _value));
            }else {
               accPreShare = pool.accSilPerShare1;
               pool.totalDeposit1 = pool.totalDeposit1
                                    .sub(amountBuffed(user.amount, user.buff))
                                    .add(amountBuffed(user.amount, _value));
            }

            uint256 pending = amountBuffed(user.amount, user.buff).mul(accPreShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeSilTransfer(_user, pending);
            }
            user.rewardDebt = amountBuffed(user.amount, _value).mul(accPreShare).div(1e12);
        }
        user.buff = _value;
    }

    function depositEth(uint256 _pid, uint256 _index ) external payable {
        uint256 _amount = msg.value;
        uint256 acceptAmount;
        PoolInfo storage pool = poolInfo[_pid];
        if(whaleSpear) {
            acceptAmount = pool.matchPair.maxAcceptAmount(_index, maxAcceptMultiple, maxAcceptMultipleDenominator, _amount);
        }else {
            acceptAmount = _amount;
        }
        require(pool.matchPair.token(_index) == WETH, "DepositEth: Index incorrect");
        IWETH(WETH).deposit{value: acceptAmount}();
        deposit(_pid, _index, acceptAmount);
        if(_amount > acceptAmount) {
            safeTransferETH(msg.sender , _amount.sub(acceptAmount));
        }
    }

    function deposit(uint256 _pid, uint256 _index,  uint256 _amount) whenNotPaused(_pid) public  {
        require(_index < 2, "Index must 0 or 1" );
        checkAccount(msg.sender);
        bool _index0 = _index == 0;
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = _index0 ? userInfo0[_pid][msg.sender] : userInfo1[_pid][msg.sender];
        updatePool(_pid);
        if(whaleSpear) {

            _amount = pool.matchPair.maxAcceptAmount(_index, maxAcceptMultiple, maxAcceptMultipleDenominator, _amount);

        }
        
        uint256 accPreShare = _index0 ? pool.accSilPerShare0 : pool.accSilPerShare1;
       
        if (user.amount > 0) {//&& !sil.mintOver()
            uint256 pending = amountBuffed(user.amount, user.buff).mul(accPreShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeSilTransfer(msg.sender, pending);
            }
        }

        if(_amount > 0) {
            address tokenTarget = pool.matchPair.token(_index);
            if(tokenTarget == WETH) {
                safeTransfer(WETH, address(pool.matchPair), _amount);
            }else{
                safeTransferFrom( pool.matchPair.token(_index), msg.sender,  address(pool.matchPair), _amount);
            }
            pool.matchPair.stake(_index, msg.sender, _amount);
            user.amount = user.amount.add(_amount);
            user.totalDeposit = user.totalDeposit.add(_amount); 
            if(_index0) {
                pool.totalDeposit0 = pool.totalDeposit0.add(amountBuffed(_amount, user.buff));
            }else {
                pool.totalDeposit1 = pool.totalDeposit1.add(amountBuffed(_amount, user.buff));
            }
        }


        user.rewardDebt = amountBuffed(user.amount, user.buff).mul(accPreShare).div(1e12);
        emit Deposit(msg.sender, _pid, _index, _amount);
    }

    function withdrawToken(uint256 _pid, uint256 _index, uint256 _amount) external {
        require(_index < 2, "Index must 0 or 1" );
        address _user = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];

        (uint256 untakeTokenAmount, uint256 leftAmount) = pool.matchPair.untakeToken(_index, _user, _amount);
        address targetToken = pool.matchPair.token(_index);


        uint256 userAmount = untakeTokenAmount.mul(995).div(1000);

        withdraw(_pid, _index, _user, untakeTokenAmount, leftAmount);
        if(targetToken == WETH) {

            IWETH(WETH).withdraw(untakeTokenAmount);

            safeTransferETH(_user, userAmount);
            safeTransferETH(repurchaseaddr, untakeTokenAmount.sub(userAmount) );
        }else {
            safeTransfer(pool.matchPair.token(_index),  _user, userAmount);
            safeTransfer(pool.matchPair.token(_index),  repurchaseaddr, untakeTokenAmount.sub(userAmount));
        }
    }
    function withdraw( uint256 _pid, uint256 _index, address _user, uint256 _amount, uint256 _leftAmount) whenNotPaused(_pid)  private {
        
        bool _index0 = _index == 0;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = _index0? userInfo0[_pid][_user] :  userInfo1[_pid][_user];
        user.totalWithdraw = user.totalWithdraw.add(_amount);

        updatePool(_pid);

        uint256 accPreShare = _index0 ? pool.accSilPerShare0 : pool.accSilPerShare1;
        uint256 pending = amountBuffed(user.amount, user.buff).mul(accPreShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeSilTransfer(_user, pending);
        }

        if(_index0) {
            pool.totalDeposit0 = pool.totalDeposit0
                                .add(amountBuffed(_leftAmount, user.buff))
                                .sub(amountBuffed(user.amount, user.buff));
        }else {
             pool.totalDeposit1 = pool.totalDeposit1
                                .add(amountBuffed(_leftAmount, user.buff))
                                .sub(amountBuffed(user.amount, user.buff));
        }
        user.amount = _leftAmount;
        user.rewardDebt = amountBuffed(user.amount, user.buff).mul(accPreShare).div(1e12);
        emit Withdraw(_user, _pid, _index, _amount);
    }
    function withdrawSil(uint256 _pid) external {

        updatePool(_pid);

        uint256 silAmount0 = withdrawSilCalcu(_pid, 0, msg.sender);
        uint256 silAmount1 = withdrawSilCalcu(_pid, 1, msg.sender);

        safeSilTransfer(msg.sender, silAmount0.add(silAmount1));
        
        emit WithdrawSilToken(msg.sender, _pid, silAmount0, silAmount1);
    }

    function withdrawSilCalcu(uint256 _pid, uint256 _index,  address _user) private returns (uint256 silAmount) {
        bool _index0 = _index == 0;
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = _index0 ? userInfo0[_pid][_user] : userInfo1[_pid][_user];
        
        uint256 accPreShare = _index0 ? pool.accSilPerShare0 : pool.accSilPerShare1;

        if (user.amount > 0) {
            silAmount = amountBuffed(user.amount, user.buff).mul(accPreShare).div(1e12).sub(user.rewardDebt);
        }
        user.rewardDebt = amountBuffed(user.amount, user.buff).mul(accPreShare).div(1e12);
    }

    function safeSilTransfer(address _to, uint256 _amount) internal {
        uint256 silBal = sil.balanceOf(address(this));
        if (_amount > silBal) {
            require(sil.transfer(_to, silBal),'SafeSilTransfer: transfer failed');
        } else {
            require(sil.transfer(_to, _amount),'SafeSilTransfer: transfer failed');
        }
    }

    function amountBuffed(uint256 amount, uint256 buff) private pure returns (uint256) {
        if(buff == 0) {
            return amount;
        }else {
            return amount.mul(buff).div(1000);
        }
    }

    function mintableAmount(uint256 _pid, uint256 _index, address _user) external view returns (uint256) {

        UserInfo storage user = _index == 0? userInfo0[_pid][_user] :  userInfo1[_pid][msg.sender];
        return user.amount;
    }


    function getProxy(uint256 _index) external  view override returns(address) {
        require(!matchPairPause[_index], "Proxy paused, waiting upgrade via governance");
        return matchPairRegistry[_index];
    }

    function pauseProxy(uint256 _pid, bool _paused) external {
        require(msg.sender == devaddr, "dev sender required");
        matchPairPause[_pid] = _paused;
    }

    function pause(uint256 _pid, bool _paused) external {
        require(msg.sender == devaddr, "dev sender required");
        pausePoolViaPid(_pid, _paused);
    }
    function dev(address _devaddr) external {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function ecosys(address _ecosysaddraddr) external {
        require(msg.sender == ecosysaddr, "ecosys: wut?");
        ecosysaddr = _ecosysaddraddr;
    }
    
    function repurchase(address _repurchaseaddr) external {
        require(msg.sender == repurchaseaddr, "repurchase: wut?");
        repurchaseaddr = _repurchaseaddr;
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'MasterTransfer: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'MasterTransfer: TRANSFER_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'MasterTransfer: ETH_TRANSFER_FAILED');
    }

    function notifyRewardAmount(uint256 reward, uint256 duration)
        onlyOwner
        external
    {
        massUpdatePools();
        if (block.number >= periodFinish) {
            feeRewardRate = reward.div(duration);
        } else {
            uint256 remaining = periodFinish.sub(block.number);
            uint256 leftover = remaining.mul(feeRewardRate);
            feeRewardRate = reward.add(leftover).div(duration);
        }
        periodFinish = block.number.add(duration);

    }

    function checkAccount(address _account) private {
        require(_account == tx.origin || trustable(_account) , "High risk account");
    }

    receive() external payable {
        require(msg.sender == WETH, "only accept from WETH"); // only accept ETH via fallback from the WETH contract
    }
}