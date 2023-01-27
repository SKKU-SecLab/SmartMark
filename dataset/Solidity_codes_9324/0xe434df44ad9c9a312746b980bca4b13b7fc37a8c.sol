
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
}pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}pragma solidity 0.6.12;



contract YFBitcoin is ERC20("AddToken", "ADD"), Ownable {
    uint256 public transferFee = 1;

    uint256 public devFee = 300;

    address public devAddress;

    uint256 public cap;

    constructor(uint256 _cap, address _devAddress) public {
        cap = _cap;
        devAddress = _devAddress;
    }

    function setTransferFee(uint256 _fee) public onlyOwner {
        require(_fee > 0 && _fee < 1000, "YFBTC: fee should be between 0 and 10");
        transferFee = _fee;
    }

    function setDevAddress(address _devAddress) public onlyOwner {
        devAddress = _devAddress;
    }

    function burn(address sender, uint256 amount) public onlyOwner {
        _burn(sender, amount);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        _moveDelegates(_delegates[msg.sender], _delegates[recipient], amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 allowedAmount = allowance(sender, _msgSender());
        _transfer(sender, recipient, amount);
        _moveDelegates(_delegates[sender], _delegates[recipient], amount);
        _approve(sender, _msgSender(), allowedAmount.sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    mapping(address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => uint256) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "YFBTC::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "YFBTC::delegateBySig: invalid nonce");
        require(now <= expiry, "YFBTC::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {
        require(blockNumber < block.number, "YFBTC::getPriorVotes: not yet determined");

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
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying YFEs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
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
    ) internal {
        uint32 blockNumber = safe32(block.number, "YFBTC::_writeCheckpoint: block number exceeds 32 bits");

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

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            require(totalSupply().add(amount) <= cap, "YFBTC:: cap exceeded");
        }
    }
}// MIT

pragma solidity 0.6.12;

interface UniswapV2Pair{

function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
function price0CumulativeLast() external view returns (uint);
function price1CumulativeLast() external view returns (uint);

}// MIT

pragma solidity 0.6.12;


contract YFBTCMaster is Ownable {
    using SafeMath for *;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 lastRewardBlock;
        uint256 accYfbtcPerShare; // Accumulated YFBTC per share, times 1e12. See below.
        uint256 totalSupply;
    }

    struct RewardInfo {
        uint256 startBlock;
        uint256 endBlock;
        uint256 rewardFrom;
        uint256 rewardTo;
        uint256 rewardPerBlock;
    }

    uint256 public lastPrice = 0;

    uint256 public constant PERIOD = 24 hours;

    uint256 public constant CHANGE_IN_PERCENTAGE = 5;

    address public pairAddress;

    uint32 public blockTimestampLast;

    YFBitcoin public yfbtc;

    PoolInfo[] public poolInfo;


    RewardInfo[] public rewardInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public startedBlock;

    event SetDevAddress(address indexed _devAddress);
    event SetTransferFee(uint256 _fee);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdrawExceptional(address indexed user, uint256 amount);

    constructor(
        YFBitcoin _yfbtc,
        address _pairAddress,
        uint256 _startedBlock
    ) public {
        yfbtc = _yfbtc;
        pairAddress = _pairAddress;
        startedBlock = _startedBlock;
        (uint112 reserve0, uint112 reserve1, uint32 blockTime) = UniswapV2Pair(pairAddress).getReserves(); // gas savings
        blockTimestampLast = blockTime;
        lastPrice = reserve1;
        require(reserve0 != 0 && reserve1 != 0, "ORACLE: NO_RESERVES"); // ensure that there's liquidity in the pair
        addRewardSet();
    }

    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2**32);
    }

    function setDevAddress(address _devAddress) external onlyOwner {
        require(_devAddress != address(0x0), "zero address is not allowed");
        yfbtc.setDevAddress(_devAddress);
        emit SetDevAddress(_devAddress);
    }

    function setTransferFee(uint256 _fee) external onlyOwner {
        require(_fee > 0 && _fee < 1000, "YFBTC: fee should be between 0 and 10");
        yfbtc.setTransferFee(_fee);
        emit SetTransferFee(_fee);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        yfbtc.mint(_to, _amount);
    }

    function burn(address _sender, uint256 _amount) public onlyOwner {
        yfbtc.burn(_sender, _amount);
    }

    function update() public returns (bool) {
        uint32 blockTimestamp = currentBlockTimestamp();
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        if (timeElapsed >= PERIOD) {
            uint256 change = 0;
            (, uint112 _reserve1, ) = UniswapV2Pair(pairAddress).getReserves(); // gas savings

            uint256 currentPrice = _reserve1;

            if (lastPrice > currentPrice) {
                change = lastPrice.sub(currentPrice).mul(100).div(lastPrice);
            }

            if (change >= CHANGE_IN_PERCENTAGE) {
                return false;
            } else {
                lastPrice = currentPrice;
                blockTimestampLast = blockTimestamp;
            }
        }

        return true;
    }

    function updateOwnerShip(address newOwner) public onlyOwner {
        yfbtc.transferOwnership(newOwner);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(IERC20 _lpToken) external onlyOwner {
        require(address(_lpToken) != address(0), "MC: _lpToken should not be address zero");

        for (uint256 i = 0; i < poolInfo.length; i++) {
            require(address(poolInfo[i].lpToken) != address(_lpToken), "MC: DO NOT add the same LP token more than once");
        }
        uint256 lastRewardBlock = block.number > startedBlock ? block.number : startedBlock;
        poolInfo.push(PoolInfo({lpToken: _lpToken, accYfbtcPerShare: 0, lastRewardBlock: lastRewardBlock, totalSupply: 0}));
    }

    function addRewardSet() internal returns (uint256) {
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock,
                endBlock: startedBlock.add(172800),
                rewardFrom: 1900 * 10**18,
                rewardTo: 3150 * 10**18,
                rewardPerBlock: 17606095680000000
            })
        );
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock.add(172800),
                endBlock: startedBlock.add(1036800),
                rewardFrom: 3150 * 10**18,
                rewardTo: 8960 * 10**18,
                rewardPerBlock: 8641975309000000
            })
        );
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock.add(1036800),
                endBlock: startedBlock.add(2073600),
                rewardFrom: 8960 * 10**18,
                rewardTo: 16590 * 10**18,
                rewardPerBlock: 4320987654000000
            })
        );
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock.add(2073600),
                endBlock: startedBlock.add(3110400),
                rewardFrom: 16590 * 10**18,
                rewardTo: 18830 * 10**18,
                rewardPerBlock: 2160493827000000
            })
        );
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock.add(3110400),
                endBlock: startedBlock.add(4147200),
                rewardFrom: 18830 * 10**18,
                rewardTo: 19950 * 10**18,
                rewardPerBlock: 1080246914000000
            })
        );
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock.add(4147200),
                endBlock: startedBlock.add(5184000),
                rewardFrom: 19950 * 10**18,
                rewardTo: 20510 * 10**18,
                rewardPerBlock: 540123456800000
            })
        );
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock.add(5184000),
                endBlock: startedBlock.add(6220800),
                rewardFrom: 20510 * 10**18,
                rewardTo: 20790 * 10**18,
                rewardPerBlock: 270061728400000
            })
        );
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock.add(6220800),
                endBlock: startedBlock.add(7257600),
                rewardFrom: 20790 * 10**18,
                rewardTo: 20930 * 10**18,
                rewardPerBlock: 135030864200000
            })
        );
        rewardInfo.push(
            RewardInfo({
                startBlock: startedBlock.add(7257600),
                endBlock: startedBlock.add(8294400),
                rewardFrom: 20930 * 10**18,
                rewardTo: 21000 * 10**18,
                rewardPerBlock: 67515432100000
            })
        );
        return 0;
    }

    function getPoolBaseMultiplier(uint256 _pid) public view returns (uint256) {
        if (_pid == 0) {
            return 20;
        } else if (_pid == 1) {
            return 4;
        } else if (_pid == 2) {
            return 1;
        } else {
            return 1;
        }
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 difference = _to.sub(_from);
        if (difference <= 0 || _from < startedBlock) return 0;

        uint256 totalReward = 0;

        uint256 supply = yfbtc.totalSupply();

        if (supply >= rewardInfo[rewardInfo.length.sub(1)].rewardTo) return 0;

        uint256 rewardSetlength = rewardInfo.length;

        if (_to >= rewardInfo[rewardInfo.length.sub(1)].endBlock) {
            totalReward = _to.sub(_from).mul(rewardInfo[3].rewardPerBlock);
        } else {
            for (uint256 rid = 0; rid < rewardSetlength; ++rid) {
                if (_to <= rewardInfo[rid].endBlock) {
                    totalReward = totalReward.add(((_to.sub(_from)).mul(rewardInfo[rid].rewardPerBlock)));
                    break;
                } else {
                    if (rewardInfo[rid].endBlock <= _from) {
                        continue;
                    }
                    totalReward = totalReward.add(((rewardInfo[rid].endBlock.sub(_from)).mul(rewardInfo[rid].rewardPerBlock)));
                    supply = rewardInfo[rid].rewardTo;
                    _from = rewardInfo[rid].endBlock;
                }
            }
        }
        uint256 totalMultipliers = sumOfMultipliers();

        if (totalMultipliers == 0) return 0;

        uint256 rewardPerPool = totalReward.div(totalMultipliers);

        return rewardPerPool;
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        require(address(pool.lpToken) != address(0), "MC: _pid is incorrect");
        UserInfo memory user = userInfo[_pid][_user];

        uint256 accYfbtcPerShare = pool.accYfbtcPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 rewardPerPool = getMultiplier(pool.lastRewardBlock, block.number);
            accYfbtcPerShare = accYfbtcPerShare.add(rewardPerPool.mul(getPoolBaseMultiplier(_pid)).mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accYfbtcPerShare).div(1e12).sub(user.rewardDebt);
    }

    function estimateReward(
        uint256 _pid,
        address _user,
        uint256 to
    ) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        require(address(pool.lpToken) != address(0), "MC: _pid is incorrect");
        UserInfo memory user = userInfo[_pid][_user];

        uint256 accYfbtcPerShare = pool.accYfbtcPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 rewardPerPool = getMultiplier(pool.lastRewardBlock, to);
            accYfbtcPerShare = accYfbtcPerShare.add(rewardPerPool.mul(getPoolBaseMultiplier(_pid)).mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accYfbtcPerShare).div(1e12).sub(user.rewardDebt);
    }

    function sumOfMultipliers() internal view returns (uint256) {
        uint256 eligibleMultipliers = 0;
        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {
            if (poolInfo[pid].totalSupply > 0) {
                eligibleMultipliers = eligibleMultipliers.add(getPoolBaseMultiplier(pid));
            }
        }
        return eligibleMultipliers;
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.lpToken) != address(0), "MC: _pid is incorrect");

        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        bool doMint = update();

        if (doMint) {
            uint256 yfbtcReward = getMultiplier(pool.lastRewardBlock, block.number);
            if (yfbtcReward <= 0) return;

            yfbtcReward = yfbtcReward.mul(getPoolBaseMultiplier(_pid));
            pool.accYfbtcPerShare = pool.accYfbtcPerShare.add(yfbtcReward.mul(1e12).div(lpSupply));

            yfbtc.mint(address(this), yfbtcReward);
            pool.lastRewardBlock = block.number;
        }
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.lpToken) != address(0), "MC: _pid is incorrect");

        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accYfbtcPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeYfbtcTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            pool.totalSupply = pool.totalSupply.add(_amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accYfbtcPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.lpToken) != address(0), "MC: _pid is incorrect");
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accYfbtcPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeYfbtcTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            pool.totalSupply = pool.totalSupply.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accYfbtcPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.lpToken) != address(0), "MC: _pid is incorrect");
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        pool.totalSupply = pool.totalSupply.sub(amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function safeYfbtcTransfer(address _to, uint256 _amount) internal {
        uint256 yfbtcBal = yfbtc.balanceOf(address(this));
        if (_amount > yfbtcBal) {
            yfbtc.transfer(_to, yfbtcBal);
            emit EmergencyWithdrawExceptional(_to, _amount);
        } else {
            yfbtc.transfer(_to, _amount);
        }
    }
}