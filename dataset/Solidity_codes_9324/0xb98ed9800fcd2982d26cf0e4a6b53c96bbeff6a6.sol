


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


contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
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
}



pragma solidity ^0.6.0;

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
pragma experimental ABIEncoderV2;
interface INsure {

    function burn(uint256 amount)  external ;
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external  returns (bool);
    function mint(address _to, uint256 _amount) external  returns (bool);
    function balanceOf(address account) external view returns (uint256);
}



pragma solidity ^0.6.0;















contract CapitalStake is Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public signer;
    string public constant name = "CapitalStake";
    string public constant version = "1";
    struct UserInfo {
        uint256 amount;     // How many  tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 reward;

        uint256 pendingWithdrawal;  // payments available for withdrawal by an investor
        uint256 pendingAt;
    }

    struct PoolInfo {
        uint256 amount;             //Total Deposit of token
        IERC20 lpToken;             // Address of token contract.
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accNsurePerShare;
        uint256 pending;
    }
 
    INsure public nsure;
    uint256 public nsurePerBlock    = 18 * 1e17;

    uint256 public pendingDuration  = 14 days;

    mapping(uint256 => uint256) public capacityMax;

    bool public canDeposit = true;
    address public operator;

    mapping(uint256 => uint256) public userCapacityMax;

    PoolInfo[] public poolInfo;

    mapping(address => uint256) public nonces;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint = 0;

    uint256 public startBlock;


    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 public constant Capital_Unstake_TYPEHASH =
        keccak256(
            "CapitalUnstake(uint256 pid,address account,uint256 amount,uint256 nonce,uint256 deadline)"
    );

    bytes32 public constant Capital_Deposit_TYPEHASH =
        keccak256(
            "Deposit(uint256 pid,address account,uint256 amount,uint256 nonce,uint256 deadline)"
    );



    constructor(address _signer, address _nsure, uint256 _startBlock) public {
        nsure       = INsure(_nsure);
        startBlock  = _startBlock;
        userCapacityMax[0] = 10000e18;
        signer = _signer;
    }
    
      function setOperator(address _operator) external onlyOwner {   
        require(_operator != address(0),"_operator is zero");
        operator = _operator;
        emit eSetOperator(_operator);
    }

    function setSigner(address _signer) external onlyOwner {
        require(_signer != address(0), "_signer is zero");
        signer = _signer;
        emit eSetSigner(_signer);
    }

    modifier onlyOperator() {
        require(msg.sender == operator,"not operator");
        _;
    }

    function switchDeposit() external onlyOwner {
        canDeposit = !canDeposit;
        emit SwitchDeposit(canDeposit);
    }

    function setUserCapacityMax(uint256 _pid,uint256 _max) external onlyOwner {
        userCapacityMax[_pid] = _max;
        emit SetUserCapacityMax(_pid,_max);
    }

    function setCapacityMax(uint256 _pid,uint256 _max) external onlyOwner {
        capacityMax[_pid] = _max;
        emit SetCapacityMax(_pid,_max);
    }
   
   
   
    function updateBlockReward(uint256 _newReward) external onlyOwner {
        nsurePerBlock   = _newReward;
        emit UpdateBlockReward(_newReward);
    }

    function updateWithdrawPending(uint256 _seconds) external onlyOwner {
        pendingDuration = _seconds;
        emit UpdateWithdrawPending(_seconds);
    }

    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate,uint256 maxCapacity) onlyOwner external {
        require(address(_lpToken) != address(0),"_lpToken is zero");
        for(uint256 i=0; i<poolLength(); i++) {
            require(address(_lpToken) != address(poolInfo[i].lpToken), "Duplicate Token!");
        }

        if (_withUpdate) {
            massUpdatePools();
        }

        capacityMax[poolInfo.length] = maxCapacity;
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            amount:0,
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accNsurePerShare: 0,
            pending: 0
        }));

        
        emit Add(_allocPoint,_lpToken,_withUpdate);
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate)  onlyOwner external {
        require(_pid < poolInfo.length , "invalid _pid");
        if (_withUpdate) {
            massUpdatePools();
        }

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        emit Set(_pid,_allocPoint,_withUpdate);
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    function pendingNsure(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accNsurePerShare = pool.accNsurePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 nsureReward = multiplier.mul(nsurePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accNsurePerShare = accNsurePerShare.add(nsureReward.mul(1e12).div(lpSupply));
        }

        return user.amount.mul(accNsurePerShare).div(1e12).sub(user.rewardDebt);
    }


    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        require(_pid < poolInfo.length, "invalid _pid");
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 nsureReward = multiplier.mul(nsurePerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        bool mintRet = nsure.mint(address(this), nsureReward);
        if(mintRet) {
            pool.accNsurePerShare = pool.accNsurePerShare.add(nsureReward.mul(1e12).div(lpSupply));
            pool.lastRewardBlock = block.number;
        }
    }


    function deposit(uint256 _pid, uint256 _amount) external whenNotPaused {
        require(canDeposit, "can not");
        require(_pid < poolInfo.length, "invalid _pid");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount.add(_amount) <= userCapacityMax[_pid],"exceed user limit");
        require(pool.amount.add(_amount) <= capacityMax[_pid],"exceed the total limit");
        updatePool(_pid);

      
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        uint256 pending = user.amount.mul(pool.accNsurePerShare).div(1e12).sub(user.rewardDebt);
        
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accNsurePerShare).div(1e12);
        
        pool.amount = pool.amount.add(_amount);

        if(pending > 0){
            safeNsureTransfer(msg.sender,pending);
        }

        emit Deposit(msg.sender, _pid, _amount);
    }

    


    function unstake(
            uint256 _pid,
            uint256 _amount,
            uint8 v,
            bytes32 r,
            bytes32 s,
            uint256 deadline) external nonReentrant whenNotPaused {

   
        bytes32 domainSeparator =
            keccak256(
                abi.encode(
                    DOMAIN_TYPEHASH,
                    keccak256(bytes(name)),
                    keccak256(bytes(version)),
                    getChainId(),
                    address(this)
                )
            );
        bytes32 structHash =
            keccak256(
                abi.encode(
                    Capital_Unstake_TYPEHASH,
                    _pid,
                    address(msg.sender),
                    _amount,
                    nonces[msg.sender]++,
                    deadline
                )
            );
        bytes32 digest =
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
            
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "invalid signature");
        require(signatory == signer, "unauthorized");
        

        require(_pid < poolInfo.length , "invalid _pid");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "unstake: insufficient assets");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accNsurePerShare).div(1e12).sub(user.rewardDebt);
       
        user.amount     = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accNsurePerShare).div(1e12);

        user.pendingAt  = block.timestamp;
        user.pendingWithdrawal = user.pendingWithdrawal.add(_amount);

        pool.pending = pool.pending.add(_amount);

        safeNsureTransfer(msg.sender, pending);

        emit Unstake(msg.sender,_pid,_amount,nonces[msg.sender]-1);
    }


    function deposit(
            uint256 _pid,
            uint256 _amount,
            uint8 v,
            bytes32 r,
            bytes32 s,
            uint256 deadline) external nonReentrant whenNotPaused {

   
        bytes32 domainSeparator =
            keccak256(
                abi.encode(
                    DOMAIN_TYPEHASH,
                    keccak256(bytes(name)),
                    keccak256(bytes(version)),
                    getChainId(),
                    address(this)
                )
            );
        bytes32 structHash =
            keccak256(
                abi.encode(
                    Capital_Deposit_TYPEHASH,
                    _pid,
                    address(msg.sender),
                    _amount,
                    nonces[msg.sender]++,
                    deadline
                )
            );
        bytes32 digest =
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
            
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "invalid signature");
        require(signatory == signer, "unauthorized");
        

        require(_pid < poolInfo.length , "invalid _pid");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount.add(_amount) <= userCapacityMax[_pid],"exceed user's limit");
        require(pool.amount.add(_amount) <= capacityMax[_pid],"exceed the total limit");
        updatePool(_pid);

      
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        uint256 pending = user.amount.mul(pool.accNsurePerShare).div(1e12).sub(user.rewardDebt);
        
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accNsurePerShare).div(1e12);
        
        pool.amount = pool.amount.add(_amount);

        if(pending > 0){
            safeNsureTransfer(msg.sender,pending);
        }

        emit DepositSign(msg.sender, _pid, _amount,nonces[msg.sender] - 1);
    }




    function isPending(uint256 _pid) external view returns (bool,uint256) {
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(block.timestamp >= user.pendingAt.add(pendingDuration)) {
            return (false,0);
        }

        return (true,user.pendingAt.add(pendingDuration).sub(block.timestamp));
    }
    
    function withdraw(uint256 _pid) external nonReentrant whenNotPaused {
        require(_pid < poolInfo.length , "invalid _pid");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(block.timestamp >= user.pendingAt.add(pendingDuration), "still pending");

        uint256 amount          = user.pendingWithdrawal;
        pool.amount             = pool.amount.sub(amount);
        pool.pending            = pool.pending.sub(amount);

        user.pendingWithdrawal  = 0;

        pool.lpToken.safeTransfer(address(msg.sender), amount);

     
        
        emit Withdraw(msg.sender, _pid, amount);
    }

    function claim(uint256 _pid) external nonReentrant whenNotPaused {
        require(_pid < poolInfo.length , "invalid _pid");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accNsurePerShare).div(1e12).sub(user.rewardDebt);
        safeNsureTransfer(msg.sender, pending);

        user.rewardDebt = user.amount.mul(pool.accNsurePerShare).div(1e12);

        emit Claim(msg.sender, _pid, pending);
    }




    function safeNsureTransfer(address _to, uint256 _amount) internal {
        require(_to != address(0),"_to is zero");
        uint256 nsureBal = nsure.balanceOf(address(this));
        if (_amount > nsureBal) {
            nsure.transfer(_to,nsureBal);
        } else {
            nsure.transfer(_to,_amount);
        }
    }
    
     function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
    

    event Claim(address indexed user,uint256 pid,uint256 amount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event DepositSign(address indexed user, uint256 indexed pid, uint256 amount, uint256 nonce);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Unstake(address indexed user,uint256 pid, uint256 amount,uint256 nonce);
    event UpdateBlockReward(uint256 reward);
    event UpdateWithdrawPending(uint256 duration);
    event Add(uint256 point, IERC20 token, bool update);
    event Set(uint256 pid, uint256 point, bool update);
    event SwitchDeposit(bool swi);
    event SetUserCapacityMax(uint256 pid,uint256 max);
    event SetCapacityMax(uint256 pid, uint256 max);
    event eSetOperator(address indexed operator);
    event eSetSigner(address indexed signer);
}