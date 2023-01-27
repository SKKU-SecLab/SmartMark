

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




pragma solidity ^0.6.2;

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


pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


pragma solidity 0.6.12;




contract TenetToken is ERC20("Tenet", "TEN"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }
    function burn(address _account, uint256 _amount) public onlyOwner {
        _burn(_account, _amount);
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
        require(signatory != address(0), "delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "delegateBySig: invalid nonce");
        require(now <= expiry, "delegateBySig: signature expired");
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
        require(blockNumber < block.number, "getPriorVotes: not yet determined");

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
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying TNTs (not scaled);
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
        uint32 blockNumber = safe32(block.number, "_writeCheckpoint: block number exceeds 32 bits");

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




pragma solidity 0.6.12;


contract TenetMine is Ownable {
    using SafeMath for uint256;
    struct MinePeriodInfo {
        uint256 tenPerBlockPeriod;
        uint256 totalTenPeriod;
    }
    uint256 public bonusEndBlock;
    uint256 public bonus_multiplier;
    uint256 public bonusTenPerBlock;
    uint256 public startBlock;
    uint256 public endBlock;
    uint256 public subBlockNumerPeriod;
    uint256 public totalSupply;
    MinePeriodInfo[] public allMinePeriodInfo;

    constructor(
        uint256 _startBlock,   
        uint256 _bonusEndBlockOffset,
        uint256 _bonus_multiplier,
        uint256 _bonusTenPerBlock,
        uint256 _subBlockNumerPeriod,
        uint256[] memory _tenPerBlockPeriod
    ) public {
        startBlock = _startBlock>0 ? _startBlock : block.number + 1;
        bonusEndBlock = startBlock.add(_bonusEndBlockOffset);
        bonus_multiplier = _bonus_multiplier;
        bonusTenPerBlock = _bonusTenPerBlock;
        subBlockNumerPeriod = _subBlockNumerPeriod;
        totalSupply = bonusEndBlock.sub(startBlock).mul(bonusTenPerBlock).mul(bonus_multiplier);
        for (uint256 i = 0; i < _tenPerBlockPeriod.length; i++) {
            allMinePeriodInfo.push(MinePeriodInfo({
                tenPerBlockPeriod: _tenPerBlockPeriod[i],
                totalTenPeriod: totalSupply
            }));
            totalSupply = totalSupply.add(subBlockNumerPeriod.mul(_tenPerBlockPeriod[i]));
        }
        endBlock = bonusEndBlock.add(subBlockNumerPeriod.mul(_tenPerBlockPeriod.length));        
    }
    function set_startBlock(uint256 _startBlock) public onlyOwner {
		require(block.number < _startBlock, "set_startBlock: startBlock invalid");
        uint256 bonusEndBlockOffset = bonusEndBlock.sub(startBlock);
        startBlock = _startBlock>0 ? _startBlock : block.number + 1;
        bonusEndBlock = startBlock.add(bonusEndBlockOffset);
        endBlock = bonusEndBlock.add(subBlockNumerPeriod.mul(allMinePeriodInfo.length));
	}
    function getMinePeriodCount() public view returns (uint256) {
        return allMinePeriodInfo.length;
    }
    function calcMineTenReward(uint256 _from,uint256 _to) public view returns (uint256) {
        if(_from < startBlock){
            _from = startBlock;
        }
        if(_from >= endBlock){
            return 0;
        }
        if(_from >= _to){
            return 0;
        }
        uint256 mineFrom = calcTotalMine(_from);
        uint256 mineTo= calcTotalMine(_to);
        return mineTo.sub(mineFrom);
    }
    function calcTotalMine(uint256 _to) public view returns (uint256 totalMine) {
        if(_to <= startBlock){
            totalMine = 0;
        }else if(_to <= bonusEndBlock){
            totalMine = _to.sub(startBlock).mul(bonusTenPerBlock).mul(bonus_multiplier);
        }else if(_to < endBlock){
            uint256 periodIndex = _to.sub(bonusEndBlock).div(subBlockNumerPeriod);
            uint256 periodBlock = _to.sub(bonusEndBlock).mod(subBlockNumerPeriod);
            MinePeriodInfo memory minePeriodInfo = allMinePeriodInfo[periodIndex];
            uint256 curMine = periodBlock.mul(minePeriodInfo.tenPerBlockPeriod);
            totalMine = curMine.add(minePeriodInfo.totalTenPeriod);
        }else{
            totalMine = totalSupply;
        }
    }    
    function getMultiplier(uint256 _from, uint256 _to,uint256 _end,uint256 _tokenBonusEndBlock,uint256 _tokenBonusMultipler) public pure returns (uint256) {
        if(_to > _end){
            _to = _end;
        }
        if(_from>_end){
            return 0;
        }else if (_to <= _tokenBonusEndBlock) {
            return _to.sub(_from).mul(_tokenBonusMultipler);
        } else if (_from >= _tokenBonusEndBlock) {
            return _to.sub(_from);
        } else {
            return _tokenBonusEndBlock.sub(_from).mul(_tokenBonusMultipler).add(_to.sub(_tokenBonusEndBlock));
        }
    }    
}

pragma solidity 0.6.12;


contract Tenet is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;             
        uint256 rewardTokenDebt;    
        uint256 rewardTenDebt;      
        uint256 lastBlockNumber;    
        uint256 freezeBlocks;      
        uint256 freezeTen;         
    }
    struct PoolSettingInfo{
        address lpToken;            
        address tokenAddr;          
        address projectAddr;        
        uint256 tokenAmount;       
        uint256 startBlock;        
        uint256 endBlock;          
        uint256 tokenPerBlock;      
        uint256 tokenBonusEndBlock; 
        uint256 tokenBonusMultipler;
    }
    struct PoolInfo {
        uint256 lastRewardBlock;  
        uint256 lpTokenTotalAmount;
        uint256 accTokenPerShare; 
        uint256 accTenPerShare; 
        uint256 userCount;
        uint256 amount;     
        uint256 rewardTenDebt; 
        uint256 mineTokenAmount;
    }

    struct TenPoolInfo {
        uint256 lastRewardBlock;
        uint256 accTenPerShare; 
        uint256 allocPoint;
        uint256 lpTokenTotalAmount;
    }

    TenetToken public ten;
    TenetMine public tenMineCalc;
    IERC20 public lpTokenTen;
    address public devaddr;
    uint256 public devaddrAmount;
    uint256 public modifyAllocPointPeriod;
    uint256 public lastModifyAllocPointBlock;
    uint256 public totalAllocPoint;
    uint256 public devWithdrawStartBlock;
    uint256 public addpoolfee;
    uint256 public bonusAllocPointBlock;
    uint256 public minProjectUserCount;

    uint256 public emergencyWithdraw;
    uint256 public constant MINLPTOKEN_AMOUNT = 10;
    uint256 public constant PERSHARERATE = 1000000000000;
    PoolInfo[] public poolInfo;
    PoolSettingInfo[] public poolSettingInfo;
    TenPoolInfo public tenProjectPool;
    TenPoolInfo public tenUserPool;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    mapping (address => UserInfo) public userInfoUserPool;
    mapping (address => bool) public tenMintRightAddr;

    address public bonusAddr;
    uint256 public bonusPoolFeeRate;

    event AddPool(address indexed user, uint256 indexed pid, uint256 tokenAmount,uint256 lpTenAmount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount,uint256 penddingToken,uint256 penddingTen,uint256 freezeTen,uint256 freezeBlocks);
    event DepositFrom(address indexed user, uint256 indexed pid, uint256 amount,address from,uint256 penddingToken,uint256 penddingTen,uint256 freezeTen,uint256 freezeBlocks);
    event MineLPToken(address indexed user, uint256 indexed pid, uint256 penddingToken,uint256 penddingTen,uint256 freezeTen,uint256 freezeBlocks);    
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount,uint256 penddingToken,uint256 penddingTen,uint256 freezeTen,uint256 freezeBlocks);

    event DepositLPTen(address indexed user, uint256 indexed pid, uint256 amount,uint256 penddingTen,uint256 freezeTen,uint256 freezeBlocks);
    event WithdrawLPTen(address indexed user, uint256 indexed pid, uint256 amount,uint256 penddingTen,uint256 freezeTen,uint256 freezeBlocks);    
    event MineLPTen(address indexed user, uint256 penddingTen,uint256 freezeTen,uint256 freezeBlocks);    
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event DevWithdraw(address indexed user, uint256 amount);

    constructor(
        TenetToken _ten,
        TenetMine _tenMineCalc,
        IERC20 _lpTen,        
        address _devaddr,
        uint256 _allocPointProject,
        uint256 _allocPointUser,
        uint256 _devWithdrawStartBlock,
        uint256 _modifyAllocPointPeriod,
        uint256 _bonusAllocPointBlock,
        uint256 _minProjectUserCount
    ) public {
        ten = _ten;
        tenMineCalc = _tenMineCalc;
        devaddr = _devaddr;
        lpTokenTen = _lpTen;
        tenProjectPool.allocPoint = _allocPointProject;
        tenUserPool.allocPoint = _allocPointUser;
        totalAllocPoint = _allocPointProject.add(_allocPointUser);
        devaddrAmount = 0;
        devWithdrawStartBlock = _devWithdrawStartBlock;
        addpoolfee = 0;
        emergencyWithdraw = 0;
        modifyAllocPointPeriod = _modifyAllocPointPeriod;
        lastModifyAllocPointBlock = tenMineCalc.startBlock();
        bonusAllocPointBlock = _bonusAllocPointBlock;
        minProjectUserCount = _minProjectUserCount;
        bonusAddr = msg.sender;
        bonusPoolFeeRate = 0;
    }
    modifier onlyMinter() {
        require(tenMintRightAddr[msg.sender] == true, "onlyMinter: caller is no right to mint");
        _;
    }
    modifier onlyNotEmergencyWithdraw() {
        require(emergencyWithdraw == 0, "onlyNotEmergencyWithdraw: emergencyWithdraw now");
        _;
    }    
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    function set_basicInfo(TenetToken _ten,IERC20 _lpTokenTen,TenetMine _tenMineCalc,uint256 _devWithdrawStartBlock,uint256 _bonusAllocPointBlock,uint256 _minProjectUserCount) public onlyOwner {
        ten = _ten;
        lpTokenTen = _lpTokenTen;
        tenMineCalc = _tenMineCalc;
        devWithdrawStartBlock = _devWithdrawStartBlock;
        bonusAllocPointBlock = _bonusAllocPointBlock;
        minProjectUserCount = _minProjectUserCount;
    }
    function set_bonusInfo(address _bonusAddr,uint256 _addpoolfee,uint256 _bonusPoolFeeRate) public onlyOwner {
        bonusAddr = _bonusAddr;
        addpoolfee = _addpoolfee;
        bonusPoolFeeRate = _bonusPoolFeeRate;
    }
    function set_tenMintRightAddr(address _addr,bool isHaveRight) public onlyOwner {
        tenMintRightAddr[_addr] = isHaveRight;
    }
    function tenMint(address _toAddr,uint256 _amount) public onlyMinter {
        if(_amount > 0){
            ten.mint(_toAddr,_amount);
            devaddrAmount = devaddrAmount.add(_amount.div(10));
        }
    }    
    function set_tenNewOwner(address _tenNewOwner) public onlyOwner {
        ten.transferOwnership(_tenNewOwner);
    }    
    function set_emergencyWithdraw(uint256 _emergencyWithdraw) public onlyOwner {
        emergencyWithdraw = _emergencyWithdraw;
    }
    function set_allocPoint(uint256 _allocPointProject,uint256 _allocPointUser,uint256 _modifyAllocPointPeriod) public onlyOwner {
        _minePoolTen(tenProjectPool);
        _minePoolTen(tenUserPool);
        tenProjectPool.allocPoint = _allocPointProject;
        tenUserPool.allocPoint = _allocPointUser;
        modifyAllocPointPeriod = _modifyAllocPointPeriod;
        totalAllocPoint = _allocPointProject.add(_allocPointUser);
        require(totalAllocPoint > 0, "set_allocPoint: Alloc Point invalid");
    }
    function add(address _lpToken,
            address _tokenAddr,
            uint256 _tokenAmount,
            uint256 _startBlock,
            uint256 _endBlockOffset,
            uint256 _tokenPerBlock,
            uint256 _tokenBonusEndBlockOffset,
            uint256 _tokenBonusMultipler,
            uint256 _lpTenAmount) public onlyNotEmergencyWithdraw {
        if(_startBlock == 0){
            _startBlock = block.number;
        }
        require(block.number <= _startBlock, "add: startBlock invalid");
        require(_endBlockOffset >= _tokenBonusEndBlockOffset, "add: bonusEndBlockOffset invalid");
        require(tenMineCalc.getMultiplier(_startBlock,_startBlock.add(_endBlockOffset),_startBlock.add(_endBlockOffset),_startBlock.add(_tokenBonusEndBlockOffset),_tokenBonusMultipler).mul(_tokenPerBlock) <= _tokenAmount, "add: token amount invalid");
        require(_tokenAmount > 0, "add: tokenAmount invalid");
        IERC20(_tokenAddr).safeTransferFrom(msg.sender,address(this), _tokenAmount);
        if(addpoolfee > 0){
            IERC20(address(ten)).safeTransferFrom(msg.sender,address(this), addpoolfee);
            if(bonusPoolFeeRate > 0){
                IERC20(address(ten)).safeTransfer(bonusAddr, addpoolfee.mul(bonusPoolFeeRate).div(10000));
                if(bonusPoolFeeRate < 10000){
                    ten.burn(address(this),addpoolfee.sub(addpoolfee.mul(bonusPoolFeeRate).div(10000)));
                }
            }else{
                ten.burn(address(this),addpoolfee);
            }
        }
        uint256 pid = poolInfo.length;
        poolSettingInfo.push(PoolSettingInfo({
                lpToken: _lpToken,
                tokenAddr: _tokenAddr,
                projectAddr: msg.sender,
                tokenAmount:_tokenAmount,
                startBlock: _startBlock,
                endBlock: _startBlock.add(_endBlockOffset),
                tokenPerBlock: _tokenPerBlock,
                tokenBonusEndBlock: _startBlock.add(_tokenBonusEndBlockOffset),
                tokenBonusMultipler: _tokenBonusMultipler
            }));
        poolInfo.push(PoolInfo({
            lastRewardBlock: block.number > _startBlock ? block.number : _startBlock,
            accTokenPerShare: 0,
            accTenPerShare: 0,
            lpTokenTotalAmount: 0,
            userCount: 0,
            amount: 0,
            rewardTenDebt: 0,
            mineTokenAmount: 0
        }));
        if(_lpTenAmount>=MINLPTOKEN_AMOUNT){
            depositTenByProject(pid,_lpTenAmount);
        }
        emit AddPool(msg.sender, pid, _tokenAmount,_lpTenAmount);
    }
    function updateAllocPoint() public {
        if(lastModifyAllocPointBlock.add(modifyAllocPointPeriod) <= block.number){
            uint256 totalLPTokenAmount = tenProjectPool.lpTokenTotalAmount.mul(bonusAllocPointBlock.add(1e4)).div(1e4).add(tenUserPool.lpTokenTotalAmount);
            if(totalLPTokenAmount > 0)
            {
                tenProjectPool.allocPoint = tenProjectPool.allocPoint.add(tenProjectPool.lpTokenTotalAmount.mul(1e4).mul(bonusAllocPointBlock.add(1e4)).div(1e4).div(totalLPTokenAmount)).div(2);
                tenUserPool.allocPoint = tenUserPool.allocPoint.add(tenUserPool.lpTokenTotalAmount.mul(1e4).div(totalLPTokenAmount)).div(2);
                totalAllocPoint = tenProjectPool.allocPoint.add(tenUserPool.allocPoint);
                lastModifyAllocPointBlock = block.number;
                require(totalAllocPoint > 0, "updateAllocPoint: Alloc Point invalid");
            }
        }     
    }
    function _minePoolTen(TenPoolInfo storage tenPool) internal {
        if (block.number <= tenPool.lastRewardBlock) {
            return;
        }
        if (tenPool.lpTokenTotalAmount < MINLPTOKEN_AMOUNT) {
            tenPool.lastRewardBlock = block.number;
            return;
        }
        if(emergencyWithdraw > 0){
            tenPool.lastRewardBlock = block.number;
            return;                
        }
        uint256 tenReward = tenMineCalc.calcMineTenReward(tenPool.lastRewardBlock, block.number);
        if(tenReward > 0){
            tenReward = tenReward.mul(tenPool.allocPoint).div(totalAllocPoint);
            devaddrAmount = devaddrAmount.add(tenReward.div(10));
            ten.mint(address(this), tenReward);
            tenPool.accTenPerShare = tenPool.accTenPerShare.add(tenReward.mul(PERSHARERATE).div(tenPool.lpTokenTotalAmount));
        }
        tenPool.lastRewardBlock = block.number;
        updateAllocPoint();
    }
    function _withdrawProjectTenPool(PoolInfo storage pool) internal returns (uint256 pending){
        if (pool.amount >= MINLPTOKEN_AMOUNT) {
            pending = pool.amount.mul(tenProjectPool.accTenPerShare).div(PERSHARERATE).sub(pool.rewardTenDebt);
            if(pending > 0){
                if(pool.userCount == 0){
                    ten.burn(address(this),pending);
                    pending = 0;
                }
                else{
                    if(pool.userCount<minProjectUserCount){
                        uint256 newPending = pending.mul(bonusAllocPointBlock.mul(pool.userCount).div(minProjectUserCount).add(1e4)).div(bonusAllocPointBlock.add(1e4));
                        if(pending.sub(newPending) > 0){
                            ten.burn(address(this),pending.sub(newPending));
                        }
                        pending = newPending;
                    }                    
                    pool.accTenPerShare = pool.accTenPerShare.add(pending.mul(PERSHARERATE).div(pool.lpTokenTotalAmount));
                }
            }
        }
    }
    function _updateProjectTenPoolAmount(PoolInfo storage pool,uint256 _amount,uint256 amountType) internal{
        if(amountType == 1){
            lpTokenTen.safeTransferFrom(msg.sender, address(this), _amount);
            tenProjectPool.lpTokenTotalAmount = tenProjectPool.lpTokenTotalAmount.add(_amount);
            pool.amount = pool.amount.add(_amount);
        }else if(amountType == 2){
            pool.amount = pool.amount.sub(_amount);
            lpTokenTen.safeTransfer(address(msg.sender), _amount);
            tenProjectPool.lpTokenTotalAmount = tenProjectPool.lpTokenTotalAmount.sub(_amount);
        }
        pool.rewardTenDebt = pool.amount.mul(tenProjectPool.accTenPerShare).div(PERSHARERATE);
    }
    function depositTenByProject(uint256 _pid,uint256 _amount) public onlyNotEmergencyWithdraw {
        require(_amount > 0, "depositTenByProject: lpamount not good");
        PoolInfo storage pool = poolInfo[_pid];
        PoolSettingInfo storage poolSetting = poolSettingInfo[_pid];
        require(poolSetting.projectAddr == msg.sender, "depositTenByProject: not good");
        _minePoolTen(tenProjectPool);
        _withdrawProjectTenPool(pool);
        _updateProjectTenPoolAmount(pool,_amount,1);
        emit DepositLPTen(msg.sender, 1, _amount,0,0,0);
    }

    function withdrawTenByProject(uint256 _pid,uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        PoolSettingInfo storage poolSetting = poolSettingInfo[_pid];
        require(poolSetting.projectAddr == msg.sender, "withdrawTenByProject: not good");
        require(pool.amount >= _amount, "withdrawTenByProject: not good");
        if(emergencyWithdraw == 0){
            _minePoolTen(tenProjectPool);
            _withdrawProjectTenPool(pool);
        }else{
            if(pool.lastRewardBlock < poolSetting.endBlock){
                if(poolSetting.tokenAmount.sub(pool.mineTokenAmount) > 0){
                    IERC20(poolSetting.tokenAddr).safeTransfer(poolSetting.projectAddr,poolSetting.tokenAmount.sub(pool.mineTokenAmount));
                }
            }
        }
        if(_amount > 0){
            _updateProjectTenPoolAmount(pool,_amount,2);
        }
        emit WithdrawLPTen(msg.sender, 1, _amount,0,0,0);
    }

    function _updatePoolUserInfo(uint256 accTenPerShare,UserInfo storage user,uint256 _freezeBlocks,uint256 _freezeTen,uint256 _amount,uint256 _amountType) internal {
        if(_amountType == 1){
            user.amount = user.amount.add(_amount);
        }else if(_amountType == 2){
            user.amount = user.amount.sub(_amount);      
        }
        user.rewardTenDebt = user.amount.mul(accTenPerShare).div(PERSHARERATE);
        user.lastBlockNumber = block.number;
        user.freezeBlocks = _freezeBlocks;
        user.freezeTen = _freezeTen;
    }
    function _calcFreezeTen(UserInfo storage user,uint256 accTenPerShare) internal view returns (uint256 pendingTen,uint256 freezeBlocks,uint256 freezeTen){
        pendingTen = user.amount.mul(accTenPerShare).div(PERSHARERATE).sub(user.rewardTenDebt);
        uint256 blockNow = 0;
        if(pendingTen>0){
            if(user.lastBlockNumber<tenMineCalc.startBlock()){
                blockNow = block.number.sub(tenMineCalc.startBlock());
            }else{
                blockNow = block.number.sub(user.lastBlockNumber);
            }
        }else{
            if(user.freezeTen > 0){
                blockNow = block.number.sub(user.lastBlockNumber);
            }
        }
        uint256 periodBlockNumer = tenMineCalc.subBlockNumerPeriod();
        freezeBlocks = blockNow.add(user.freezeBlocks);
        if(freezeBlocks <= periodBlockNumer){
            freezeTen = pendingTen.add(user.freezeTen);
            pendingTen = 0;
        }else{
            if(pendingTen == 0){
                freezeBlocks = 0;
                freezeTen = 0;
                pendingTen = user.freezeTen;
            }else{
                freezeTen = pendingTen.add(user.freezeTen).mul(periodBlockNumer).div(freezeBlocks);
                pendingTen = pendingTen.add(user.freezeTen).sub(freezeTen);
                freezeBlocks = periodBlockNumer;
            }            
        }        
    }
    function _withdrawUserTenPool(address userAddr,UserInfo storage user) internal returns (uint256 pendingTen,uint256 freezeBlocks,uint256 freezeTen){
        (pendingTen,freezeBlocks,freezeTen) = _calcFreezeTen(user,tenUserPool.accTenPerShare);
        safeTenTransfer(userAddr, pendingTen);
    }   
    function depositTenByUser(uint256 _amount) public onlyNotEmergencyWithdraw {
        require(_amount > 0, "depositTenByUser: lpamount not good");
        UserInfo storage user = userInfoUserPool[msg.sender];
        _minePoolTen(tenUserPool);
        (uint256 pending,uint256 freezeBlocks,uint256 freezeTen) = _withdrawUserTenPool(msg.sender,user);
        lpTokenTen.safeTransferFrom(address(msg.sender), address(this), _amount);
        _updatePoolUserInfo(tenUserPool.accTenPerShare,user,freezeBlocks,freezeTen,_amount,1);
        tenUserPool.lpTokenTotalAmount = tenUserPool.lpTokenTotalAmount.add(_amount);        
        emit DepositLPTen(msg.sender, 2, _amount,pending,freezeTen,freezeBlocks);
    }

    function withdrawTenByUser(uint256 _amount) public {
        require(_amount > 0, "withdrawTenByUser: lpamount not good");
        UserInfo storage user = userInfoUserPool[msg.sender];
        require(user.amount >= _amount, "withdrawTenByUser: not good");
        if(emergencyWithdraw == 0){
            _minePoolTen(tenUserPool);
            (uint256 pending,uint256 freezeBlocks,uint256 freezeTen) = _withdrawUserTenPool(msg.sender,user);
            _updatePoolUserInfo(tenUserPool.accTenPerShare,user,freezeBlocks,freezeTen,_amount,2);
            emit WithdrawLPTen(msg.sender, 2, _amount,pending,freezeTen,freezeBlocks);
        }else{
            _updatePoolUserInfo(tenUserPool.accTenPerShare,user,user.freezeBlocks,user.freezeTen,_amount,2);
            emit WithdrawLPTen(msg.sender, 2, _amount,0,user.freezeTen,user.freezeBlocks);
        }
        tenUserPool.lpTokenTotalAmount = tenUserPool.lpTokenTotalAmount.sub(_amount);          
        lpTokenTen.safeTransfer(address(msg.sender), _amount);
    }
    function mineLPTen() public onlyNotEmergencyWithdraw {
        _minePoolTen(tenUserPool);
        UserInfo storage user = userInfoUserPool[msg.sender];
        (uint256 pending,uint256 freezeBlocks,uint256 freezeTen) = _withdrawUserTenPool(msg.sender,user);
        _updatePoolUserInfo(tenUserPool.accTenPerShare,user,freezeBlocks,freezeTen,0,0);
        emit MineLPTen(msg.sender,pending,freezeTen,freezeBlocks);
    }
    function depositTenByUserFrom(address _from,uint256 _amount) public onlyNotEmergencyWithdraw {
        require(_amount > 0, "depositTenByUserFrom: lpamount not good");
        UserInfo storage user = userInfoUserPool[_from];
        _minePoolTen(tenUserPool);
        (uint256 pending,uint256 freezeBlocks,uint256 freezeTen) = _withdrawUserTenPool(_from,user);
        lpTokenTen.safeTransferFrom(address(msg.sender), address(this), _amount);
        _updatePoolUserInfo(tenUserPool.accTenPerShare,user,freezeBlocks,freezeTen,_amount,1);
        tenUserPool.lpTokenTotalAmount = tenUserPool.lpTokenTotalAmount.add(_amount);        
        emit DepositLPTen(_from, 2, _amount,pending,freezeTen,freezeBlocks);
    } 
    function _minePoolToken(PoolInfo storage pool,PoolSettingInfo storage poolSetting) internal {
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lpTokenTotalAmount >= MINLPTOKEN_AMOUNT) {
            uint256 multiplier = tenMineCalc.getMultiplier(pool.lastRewardBlock, block.number,poolSetting.endBlock,poolSetting.tokenBonusEndBlock,poolSetting.tokenBonusMultipler);
            if(multiplier > 0){
                uint256 tokenReward = multiplier.mul(poolSetting.tokenPerBlock);
                pool.mineTokenAmount = pool.mineTokenAmount.add(tokenReward);
                pool.accTokenPerShare = pool.accTokenPerShare.add(tokenReward.mul(PERSHARERATE).div(pool.lpTokenTotalAmount));
            }
        }
        if(pool.lastRewardBlock < poolSetting.endBlock){
            if(block.number >= poolSetting.endBlock){
                if(poolSetting.tokenAmount.sub(pool.mineTokenAmount) > 0){
                    IERC20(poolSetting.tokenAddr).safeTransfer(poolSetting.projectAddr,poolSetting.tokenAmount.sub(pool.mineTokenAmount));
                }
            }
        }
        pool.lastRewardBlock = block.number;
        _minePoolTen(tenProjectPool);
        _withdrawProjectTenPool(pool);
        _updateProjectTenPoolAmount(pool,0,0);
    }
    function _withdrawTokenPool(address userAddr,PoolInfo storage pool,UserInfo storage user,PoolSettingInfo storage poolSetting) 
            internal returns (uint256 pendingToken,uint256 pendingTen,uint256 freezeBlocks,uint256 freezeTen){
        if (user.amount >= MINLPTOKEN_AMOUNT) {
            pendingToken = user.amount.mul(pool.accTokenPerShare).div(PERSHARERATE).sub(user.rewardTokenDebt);
            if(pendingToken > 0){
                IERC20(poolSetting.tokenAddr).safeTransfer(userAddr, pendingToken);
            }
            (pendingTen,freezeBlocks,freezeTen) = _calcFreezeTen(user,pool.accTenPerShare);
            safeTenTransfer(userAddr, pendingTen);
        }
    }
    function _updateTokenPoolUser(uint256 accTokenPerShare,uint256 accTenPerShare,UserInfo storage user,uint256 _freezeBlocks,uint256 _freezeTen,uint256 _amount,uint256 _amountType) 
            internal {
        _updatePoolUserInfo(accTenPerShare,user,_freezeBlocks,_freezeTen,_amount,_amountType);
        user.rewardTokenDebt = user.amount.mul(accTokenPerShare).div(PERSHARERATE);
    }
    function depositLPToken(uint256 _pid, uint256 _amount) public onlyNotEmergencyWithdraw {
        require(_amount > 0, "depositLPToken: lpamount not good");
        PoolInfo storage pool = poolInfo[_pid];
        PoolSettingInfo storage poolSetting = poolSettingInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        _minePoolToken(pool,poolSetting);
        (uint256 pendingToken,uint256 pendingTen,uint256 freezeBlocks,uint256 freezeTen) = _withdrawTokenPool(msg.sender,pool,user,poolSetting);
        if (user.amount < MINLPTOKEN_AMOUNT) {
            pool.userCount = pool.userCount.add(1);
        }
        IERC20(poolSetting.lpToken).safeTransferFrom(address(msg.sender), address(this), _amount);
        pool.lpTokenTotalAmount = pool.lpTokenTotalAmount.add(_amount);
        _updateTokenPoolUser(pool.accTokenPerShare,pool.accTenPerShare,user,freezeBlocks,freezeTen,_amount,1);
        emit Deposit(msg.sender, _pid, _amount,pendingToken,pendingTen,freezeTen,freezeBlocks);
    }

    function withdrawLPToken(uint256 _pid, uint256 _amount) public {
        require(_amount > 0, "withdrawLPToken: lpamount not good");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolSettingInfo storage poolSetting = poolSettingInfo[_pid];
        require(user.amount >= _amount, "withdrawLPToken: not good");
        if(emergencyWithdraw == 0){
            _minePoolToken(pool,poolSetting);
            (uint256 pendingToken,uint256 pendingTen,uint256 freezeBlocks,uint256 freezeTen) = _withdrawTokenPool(msg.sender,pool,user,poolSetting);
            _updateTokenPoolUser(pool.accTokenPerShare,pool.accTenPerShare,user,freezeBlocks,freezeTen,_amount,2);
            emit Withdraw(msg.sender, _pid, _amount,pendingToken,pendingTen,freezeTen,freezeBlocks);
        }else{
            _updateTokenPoolUser(pool.accTokenPerShare,pool.accTenPerShare,user,user.freezeBlocks,user.freezeTen,_amount,2);
            emit Withdraw(msg.sender, _pid, _amount,0,0,user.freezeTen,user.freezeBlocks);
        }
        IERC20(poolSetting.lpToken).safeTransfer(address(msg.sender), _amount);
        pool.lpTokenTotalAmount = pool.lpTokenTotalAmount.sub(_amount);
        if(user.amount < MINLPTOKEN_AMOUNT){
            pool.userCount = pool.userCount.sub(1);
        }
    }

    function mineLPToken(uint256 _pid) public onlyNotEmergencyWithdraw {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolSettingInfo storage poolSetting = poolSettingInfo[_pid];
        _minePoolToken(pool,poolSetting);
        (uint256 pendingToken,uint256 pendingTen,uint256 freezeBlocks,uint256 freezeTen) = _withdrawTokenPool(msg.sender,pool,user,poolSetting);
        _updateTokenPoolUser(pool.accTokenPerShare,pool.accTenPerShare,user,freezeBlocks,freezeTen,0,0);
        emit MineLPToken(msg.sender, _pid, pendingToken,pendingTen,freezeTen,freezeBlocks);
    }

    function depositLPTokenFrom(address _from,uint256 _pid, uint256 _amount) public onlyNotEmergencyWithdraw {
        require(_amount > 0, "depositLPTokenFrom: lpamount not good");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_from];
        PoolSettingInfo storage poolSetting = poolSettingInfo[_pid];
        _minePoolToken(pool,poolSetting);
        (uint256 pendingToken,uint256 pendingTen,uint256 freezeBlocks,uint256 freezeTen) = _withdrawTokenPool(_from,pool,user,poolSetting);
        if (user.amount < MINLPTOKEN_AMOUNT) {
            pool.userCount = pool.userCount.add(1);
        }
        IERC20(poolSetting.lpToken).safeTransferFrom(msg.sender, address(this), _amount);
        pool.lpTokenTotalAmount = pool.lpTokenTotalAmount.add(_amount);
        _updateTokenPoolUser(pool.accTokenPerShare,pool.accTenPerShare,user,freezeBlocks,freezeTen,_amount,1);
        emit DepositFrom(_from, _pid, _amount,msg.sender,pendingToken,pendingTen,freezeTen,freezeBlocks);
    }
 
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function devWithdraw(uint256 _amount) public {
        require(block.number >= devWithdrawStartBlock, "devWithdraw: start Block invalid");
        require(msg.sender == devaddr, "devWithdraw: devaddr invalid");
        require(devaddrAmount >= _amount, "devWithdraw: amount invalid");        
        ten.mint(devaddr,_amount);
        devaddrAmount = devaddrAmount.sub(_amount);
        emit DevWithdraw(msg.sender, _amount);
    }    

    function safeTenTransfer(address _to, uint256 _amount) internal {
        if(_amount > 0){
            uint256 bal = ten.balanceOf(address(this));
            if (_amount > bal) {
                if(bal > 0){
                    IERC20(address(ten)).safeTransfer(_to, bal);
                }
            } else {
                IERC20(address(ten)).safeTransfer(_to, _amount);
            }
        }
    }        
}