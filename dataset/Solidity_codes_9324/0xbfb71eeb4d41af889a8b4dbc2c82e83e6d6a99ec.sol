


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
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

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

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


pragma solidity ^0.6.0;




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


pragma solidity ^0.6.0;

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
}


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}


pragma solidity 0.6.12;






contract SakeToken is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "SakeToken";
    string private _symbol = "SAKE";
    uint8 private _decimals = 18;

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

        _moveDelegates(_delegates[sender], _delegates[recipient], amount);
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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    function mint(address _to, uint256 _amount) public onlyOwner {

        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
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
        require(signatory != address(0), "SAKE::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "SAKE::delegateBySig: invalid nonce");
        require(now <= expiry, "SAKE::delegateBySig: signature expired");
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

        require(blockNumber < block.number, "SAKE::getPriorVotes: not yet determined");

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

    function _delegate(address delegator, address delegatee)
        internal
    {

        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying SAKEs (not scaled);
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

        uint32 blockNumber = safe32(block.number, "SAKE::_writeCheckpoint: block number exceeds 32 bits");

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
}


pragma solidity 0.6.12;







contract SakeMasterV2 is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 amountStoken; // How many S tokens the user has provided.
        uint256 amountLPtoken; // How many LP tokens the user has provided.
        uint256 pengdingSake; // record sake amount when user withdraw lp.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 lastWithdrawBlock; // user last withdraw time;

    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        IERC20 sToken; // Address of S token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. SAKEs to distribute per block.
        uint256 lastRewardBlock; // Last block number that SAKEs distribution occurs.
        uint256 accSakePerShare; // Accumulated SAKEs per share, times 1e12. See below.
        uint256 multiplierSToken; // times 1e8;
        bool sakeLockSwitch; // true-have sake withdraw interval,default 1 months;false-no withdraw interval,but have sake withdraw fee,default 10%
    }

    SakeToken public sake;
    address public sakeMaker;
    address public admin;
    address public sakeFeeAddress;
    uint256 public tradeMiningSpeedUpEndBlock;
    uint256 public yieldFarmingIIEndBlock;
    uint256 public tradeMiningEndBlock;
    uint256 public tradeMiningSpeedUpEndBlockNum = 192000;
    uint256 public yieldFarmingIIEndBlockNum = 1152000;
    uint256 public tradeMiningEndBlockNum = 2304000;
    uint256 public sakePerBlockYieldFarming = 5 * 10**18;
    uint256 public sakePerBlockTradeMining = 10 * 10**18;
    uint256 public constant BONUS_MULTIPLIER = 2;
    uint256 public withdrawInterval = 192000;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint8 public lpFeeRatio = 0;
    uint8 public sakeFeeRatio = 10;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amountLPtoken, uint256 amountStoken);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amountLPtoken);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amountLPtoken);

    constructor(
        SakeToken _sake,
        address _admin,
        address _sakeMaker,
        address _sakeFeeAddress,
        uint256 _startBlock
    ) public {
        sake = _sake;
        admin = _admin;
        sakeMaker = _sakeMaker;
        sakeFeeAddress = _sakeFeeAddress;
        startBlock = _startBlock;
        tradeMiningSpeedUpEndBlock = startBlock.add(tradeMiningSpeedUpEndBlockNum);
        yieldFarmingIIEndBlock = startBlock.add(yieldFarmingIIEndBlockNum);
        tradeMiningEndBlock = startBlock.add(tradeMiningEndBlockNum);
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function _checkValidity(IERC20 _lpToken, IERC20 _sToken) internal view {

        for (uint256 i = 0; i < poolInfo.length; i++) {
            require(poolInfo[i].lpToken != _lpToken && poolInfo[i].sToken != _sToken, "pool exist");
        }
    }

    function add(
        uint256 _allocPoint,
        uint256 _multiplierSToken,
        IERC20 _lpToken,
        IERC20 _sToken,
        bool _withUpdate
    ) public {

        require(msg.sender == admin, "add:Call must come from admin.");
        if (_withUpdate) {
            massUpdatePools();
        }
        _checkValidity(_lpToken, _sToken);
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                sToken: _sToken,
                allocPoint: _allocPoint,
                multiplierSToken: _multiplierSToken,
                lastRewardBlock: lastRewardBlock,
                accSakePerShare: 0,
                sakeLockSwitch: true
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public {

        require(msg.sender == admin, "set:Call must come from admin.");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMultiplierSToken(
        uint256 _pid,
        uint256 _multiplierSToken,
        bool _withUpdate
    ) public {

        require(msg.sender == admin, "sms:Call must come from admin.");
        if (_withUpdate) {
            massUpdatePools();
        }
        poolInfo[_pid].multiplierSToken = _multiplierSToken;
    }

    function setSakeLockSwitch(
        uint256 _pid,
        bool _sakeLockSwitch,
        bool _withUpdate
    ) public {

        require(msg.sender == admin, "s:Call must come from admin.");
        if (_withUpdate) {
            massUpdatePools();
        }
        poolInfo[_pid].sakeLockSwitch = _sakeLockSwitch;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256 multipY, uint256 multipT) {

        uint256 _toFinalY = _to > yieldFarmingIIEndBlock ? yieldFarmingIIEndBlock : _to;
        uint256 _toFinalT = _to > tradeMiningEndBlock ? tradeMiningEndBlock : _to;
        if (_from >= yieldFarmingIIEndBlock) {
            multipY = 0;
        } else {
            multipY = _toFinalY.sub(_from);
        }
        if (_from >= tradeMiningEndBlock) {
            multipT = 0;
        } else {
            if (_toFinalT <= tradeMiningSpeedUpEndBlock) {
                multipT = _toFinalT.sub(_from).mul(BONUS_MULTIPLIER);
            } else {
                if (_from < tradeMiningSpeedUpEndBlock) {
                    multipT = tradeMiningSpeedUpEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                        _toFinalT.sub(tradeMiningSpeedUpEndBlock)
                    );
                } else {
                    multipT = _toFinalT.sub(_from);
                }
            }
        }
    }

    function getSakePerBlock(uint256 blockNum) public view returns (uint256) {

        if (blockNum <= tradeMiningSpeedUpEndBlock) {
            return sakePerBlockYieldFarming.add(sakePerBlockTradeMining.mul(BONUS_MULTIPLIER));
        } else if (blockNum > tradeMiningSpeedUpEndBlock && blockNum <= yieldFarmingIIEndBlock) {
            return sakePerBlockYieldFarming.add(sakePerBlockTradeMining);
        } else if (blockNum > yieldFarmingIIEndBlock && blockNum <= tradeMiningEndBlock) {
            return sakePerBlockTradeMining;
        } else {
            return 0;
        }
    }

    function handoverSakeMintage(address newOwner) public onlyOwner {

        sake.transferOwnership(newOwner);
    }

    function pendingSake(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSakePerShare = pool.accSakePerShare;
        uint256 lpTokenSupply = pool.lpToken.balanceOf(address(this));
        uint256 sTokenSupply = pool.sToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpTokenSupply != 0) {
            uint256 totalSupply = lpTokenSupply.add(sTokenSupply.mul(pool.multiplierSToken).div(1e8));
            (uint256 multipY, uint256 multipT) = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 sakeRewardY = multipY.mul(sakePerBlockYieldFarming).mul(pool.allocPoint).div(totalAllocPoint);
            uint256 sakeRewardT = multipT.mul(sakePerBlockTradeMining).mul(pool.allocPoint).div(totalAllocPoint);
            uint256 sakeReward = sakeRewardY.add(sakeRewardT);
            accSakePerShare = accSakePerShare.add(sakeReward.mul(1e12).div(totalSupply));
        }
        return user.amount.mul(accSakePerShare).div(1e12).add(user.pengdingSake).sub(user.rewardDebt);
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
        uint256 lpTokenSupply = pool.lpToken.balanceOf(address(this));
        uint256 sTokenSupply = pool.sToken.balanceOf(address(this));
        if (lpTokenSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        (uint256 multipY, uint256 multipT) = getMultiplier(pool.lastRewardBlock, block.number);
        if (multipY == 0 && multipT == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 sakeRewardY = multipY.mul(sakePerBlockYieldFarming).mul(pool.allocPoint).div(totalAllocPoint);
        uint256 sakeRewardT = multipT.mul(sakePerBlockTradeMining).mul(pool.allocPoint).div(totalAllocPoint);
        uint256 sakeReward = sakeRewardY.add(sakeRewardT);
        uint256 totalSupply = lpTokenSupply.add(sTokenSupply.mul(pool.multiplierSToken).div(1e8));
        if (sake.owner() == address(this)) {
            sake.mint(address(this), sakeRewardT);
        }
        pool.accSakePerShare = pool.accSakePerShare.add(sakeReward.mul(1e12).div(totalSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(
        uint256 _pid,
        uint256 _amountlpToken,
        uint256 _amountsToken
    ) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (_amountlpToken <= 0 && user.pengdingSake == 0) {
            require(user.amountLPtoken > 0, "deposit:invalid");
        }
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSakePerShare).div(1e12).add(user.pengdingSake).sub(user.rewardDebt);
        uint256 _originAmountStoken = user.amountStoken;
        user.amountLPtoken = user.amountLPtoken.add(_amountlpToken);
        user.amountStoken = user.amountStoken.add(_amountsToken);
        user.amount = user.amount.add(_amountlpToken.add(_amountsToken.mul(pool.multiplierSToken).div(1e8)));
        user.pengdingSake = pending;
        if (pool.sakeLockSwitch) {
            if (block.number > (user.lastWithdrawBlock.add(withdrawInterval))) {
                user.lastWithdrawBlock = block.number;
                user.pengdingSake = 0;
                user.amountStoken = _amountsToken;
                user.amount = user.amountLPtoken.add(_amountsToken.mul(pool.multiplierSToken).div(1e8));
                pool.sToken.safeTransfer(address(1), _originAmountStoken);
                if (pending > 0) {
                    _safeSakeTransfer(msg.sender, pending);
                }
            }
        } else {
            user.lastWithdrawBlock = block.number;
            user.pengdingSake = 0;
            if (_amountlpToken == 0 && _amountsToken == 0) {
                user.amountStoken = 0;
                user.amount = user.amountLPtoken;
                pool.sToken.safeTransfer(address(1), _originAmountStoken);
            }
            if (pending > 0) {
                uint256 sakeFee = pending.mul(sakeFeeRatio).div(100);
                uint256 sakeToUser = pending.sub(sakeFee);
                _safeSakeTransfer(msg.sender, sakeToUser);
                _safeSakeTransfer(sakeFeeAddress, sakeFee);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accSakePerShare).div(1e12);
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amountlpToken);
        pool.sToken.safeTransferFrom(address(msg.sender), address(this), _amountsToken);
        emit Deposit(msg.sender, _pid, _amountlpToken, _amountsToken);
    }

    function withdraw(uint256 _pid, uint256 _amountLPtoken) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amountLPtoken >= _amountLPtoken, "withdraw: LP amount not enough");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSakePerShare).div(1e12).add(user.pengdingSake).sub(user.rewardDebt);
        user.amountLPtoken = user.amountLPtoken.sub(_amountLPtoken);
        uint256 _amountStoken = user.amountStoken;
        user.amountStoken = 0;
        user.amount = user.amountLPtoken;
        user.rewardDebt = user.amount.mul(pool.accSakePerShare).div(1e12);
        if (pool.sakeLockSwitch) {
            if (block.number > (user.lastWithdrawBlock.add(withdrawInterval))) {
                user.lastWithdrawBlock = block.number;
                user.pengdingSake = 0;
                _safeSakeTransfer(msg.sender, pending);
            } else {
                user.pengdingSake = pending;
            }
        } else {
            user.lastWithdrawBlock = block.number;
            user.pengdingSake = 0;
            uint256 sakeFee = pending.mul(sakeFeeRatio).div(100);
            uint256 sakeToUser = pending.sub(sakeFee);
            _safeSakeTransfer(msg.sender, sakeToUser);
            _safeSakeTransfer(sakeFeeAddress, sakeFee);
        }
        uint256 lpTokenFee;
        uint256 lpTokenToUser;
        if (block.number < tradeMiningEndBlock) {
            lpTokenFee = _amountLPtoken.mul(lpFeeRatio).div(100);
            pool.lpToken.safeTransfer(sakeMaker, lpTokenFee);
        }
        lpTokenToUser = _amountLPtoken.sub(lpTokenFee);
        pool.lpToken.safeTransfer(address(msg.sender), lpTokenToUser);
        pool.sToken.safeTransfer(address(1), _amountStoken);
        emit Withdraw(msg.sender, _pid, lpTokenToUser);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amountLPtoken > 0, "withdraw: LP amount not enough");
        uint256 _amountLPtoken = user.amountLPtoken;
        uint256 _amountStoken = user.amountStoken;
        user.amount = 0;
        user.amountLPtoken = 0;
        user.amountStoken = 0;
        user.rewardDebt = 0;

        uint256 lpTokenFee;
        uint256 lpTokenToUser;
        if (block.number < tradeMiningEndBlock) {
            lpTokenFee = _amountLPtoken.mul(lpFeeRatio).div(100);
            pool.lpToken.safeTransfer(sakeMaker, lpTokenFee);
        }
        lpTokenToUser = _amountLPtoken.sub(lpTokenFee);
        pool.lpToken.safeTransfer(address(msg.sender), lpTokenToUser);
        pool.sToken.safeTransfer(address(1), _amountStoken);
        emit EmergencyWithdraw(msg.sender, _pid, lpTokenToUser);
    }

    function _safeSakeTransfer(address _to, uint256 _amount) internal {

        uint256 sakeBal = sake.balanceOf(address(this));
        if (_amount > sakeBal) {
            sake.transfer(_to, sakeBal);
        } else {
            sake.transfer(_to, _amount);
        }
    }

    function setAdmin(address _adminaddr) public onlyOwner {

        require(_adminaddr != address(0), "invalid address");
        admin = _adminaddr;
    }

    function setSakeMaker(address _sakeMaker) public {

        require(msg.sender == admin, "sm:Call must come from admin.");
        require(_sakeMaker != address(0), "invalid address");
        sakeMaker = _sakeMaker;
    }

    function setSakeFeeAddress(address _sakeFeeAddress) public {

        require(msg.sender == admin, "sf:Call must come from admin.");
        require(_sakeFeeAddress != address(0), "invalid address");
        sakeFeeAddress = _sakeFeeAddress;
    }

    function setTradeMiningSpeedUpEndBlock(uint256 _endBlock) public {

        require(msg.sender == admin, "tmsu:Call must come from admin.");
        require(_endBlock > startBlock, "invalid endBlock");
        tradeMiningSpeedUpEndBlock = _endBlock;
    }

    function setYieldFarmingIIEndBlock(uint256 _endBlock) public {

        require(msg.sender == admin, "yf:Call must come from admin.");
        require(_endBlock > startBlock, "invalid endBlock");
        yieldFarmingIIEndBlock = _endBlock;
    }

    function setTradeMiningEndBlock(uint256 _endBlock) public {

        require(msg.sender == admin, "tm:Call must come from admin.");
        require(_endBlock > startBlock, "invalid endBlock");
        tradeMiningEndBlock = _endBlock;
    }

    function setSakeFeeRatio(uint8 newRatio) public {

        require(msg.sender == admin, "sfr:Call must come from admin.");
        require(newRatio >= 0 && newRatio <= 100, "invalid ratio");
        sakeFeeRatio = newRatio;
    }

    function setLpFeeRatio(uint8 newRatio) public {

        require(msg.sender == admin, "lp:Call must come from admin.");
        require(newRatio >= 0 && newRatio <= 100, "invalid ratio");
        lpFeeRatio = newRatio;
    }

    function setWithdrawInterval(uint256 _blockNum) public {

        require(msg.sender == admin, "i:Call must come from admin.");
        withdrawInterval = _blockNum;
    }

    function setSakePerBlockYieldFarming(uint256 _sakePerBlockYieldFarming, bool _withUpdate) public {

        require(msg.sender == admin, "yield:Call must come from admin.");
        if (_withUpdate) {
            massUpdatePools();
        }
        sakePerBlockYieldFarming = _sakePerBlockYieldFarming;
    }

    function setSakePerBlockTradeMining(uint256 _sakePerBlockTradeMining, bool _withUpdate) public {

        require(msg.sender == admin, "trade:Call must come from admin.");
        if (_withUpdate) {
            massUpdatePools();
        }
        sakePerBlockTradeMining = _sakePerBlockTradeMining;
    }
}