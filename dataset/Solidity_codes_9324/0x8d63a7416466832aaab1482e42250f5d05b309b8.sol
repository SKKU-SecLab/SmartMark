
pragma solidity 0.6.12;

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



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




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



contract MyToken is ERC20("IDMOToken", "IDMO"), Ownable {
    
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}




pragma experimental ABIEncoderV2;

contract IDMO is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     
        uint256 rewardDebt; 
		uint256 lock_expire; 
		uint256 lock_amount; 
    }

    struct PoolInfo {
        IERC20 lpToken;           
		uint256 amount;           
        uint256 allocPoint;       
        uint256 lastRewardBlock;  
        uint256 accPerShare; 
    }
	
	struct TokenParam{
		address myTokenAddr;   	
		address devAddr; 	   	
		uint amount1st;  		
		uint blkNum1st;  		
		uint amount2nd;  		
		uint blkNum2nd;  		
		uint amount3rd;  		
		uint blkNum3rd;  		
		uint feeRate;    		
		uint blkNumPriMine; 
	}	
	 
	mapping (uint256 => mapping(uint256 => PoolInfo)) public poolInfo;
	
	mapping (uint256 => mapping(uint256 => mapping (address => UserInfo))) public userInfo; 
	
	 
	mapping(uint256=>uint256) public totalAllocPoint;
	
	 
	mapping(uint256=>uint256) public startBlock; 
	
	uint256 public tokenIndex; 
	
	 
	mapping(uint256=>TokenParam) public tokenInfo; 
	
	mapping(uint256=>uint256) public poolNum;   

	address public delegateContract;  
	
	mapping(address=>uint256) public mapTokenExist;
	
	event Deposit(address indexed user, uint256 indexed tokenid, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed tokenid, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed tokenid, uint256 indexed pid, uint256 amount);
	
	modifier onlyControl(){ 
		address contractOwner = owner();
		require((msg.sender == contractOwner || msg.sender == delegateContract), "Caller error.");
		_;
	}
	modifier onlyDelegate(){ 
		require(msg.sender == delegateContract, "caller error");
		_;
	}
	
	
	function setDelegateContract(address _addr) public onlyOwner{
		
		delegateContract = _addr;
	}
	
	function isTokenExist(address tokenAddr) public  view{
		require(mapTokenExist[tokenAddr] == 0, "token exists");
	}
	
	
	
	function checkTokenParam(TokenParam memory tokenParam) public  view{
		require(tokenParam.myTokenAddr != address(0), "myTokenAddr error");
		isTokenExist(tokenParam.myTokenAddr);
		require(tokenParam.devAddr != address(0), "devAddr error");
		require(((tokenParam.amount1st>0 && tokenParam.blkNum1st>=10000) || (tokenParam.amount1st==0 && tokenParam.blkNum1st==0)), "amount1st blkNum1st error");
		require(((tokenParam.amount2nd>0 && tokenParam.blkNum2nd>=10000) || (tokenParam.amount2nd==0 && tokenParam.blkNum2nd==0)), "amount2nd blkNum2nd error");
		require(((tokenParam.amount3rd>0 && tokenParam.blkNum3rd>=10000) || (tokenParam.amount3rd==0 && tokenParam.blkNum3rd==0)), "amount3rd blkNum3rd error");
		require((tokenParam.feeRate>0 && tokenParam.feeRate<=20), "feeRate error");
		require(tokenParam.blkNumPriMine >= 10000, "blkNumPriMine error");
	}
	
	
	constructor(TokenParam memory tokenParam) public {
        checkTokenParam(tokenParam);
		tokenInfo[tokenIndex] = tokenParam;
		tokenIndex = tokenIndex + 1;
		mapTokenExist[tokenParam.myTokenAddr] = 1;
    }

	function addToken(TokenParam memory tokenParam) public onlyControl returns(uint256){
		checkTokenParam(tokenParam);
		tokenInfo[tokenIndex] = tokenParam;
		uint tokenId = tokenIndex;
		tokenIndex = tokenIndex + 1;
		mapTokenExist[tokenParam.myTokenAddr] = 1;
		return tokenId;
	}
	

	function setStartBlock(uint tokenId, uint _startBlk) public onlyControl{
		require(tokenId < tokenIndex);
		require(startBlock[tokenId] == 0);
		require(_startBlk > block.number);
		startBlock[tokenId] = _startBlk;

		uint256 length = poolNum[tokenId];
        for (uint256 pid = 0; pid < length; ++pid) {
            poolInfo[tokenId][pid].lastRewardBlock = _startBlk;
        }
	}
	

	function poolLength(uint tokenId) external view returns (uint256) {
        return poolNum[tokenId];
    }


	function addPool(uint tokenId, uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyControl {
        if (_withUpdate) {
            massUpdatePools(tokenId);
        }
        uint256 lastRewardBlock = block.number > startBlock[tokenId] ? block.number : startBlock[tokenId];
        totalAllocPoint[tokenId] = totalAllocPoint[tokenId].add(_allocPoint);
        poolInfo[tokenId][poolNum[tokenId]] = PoolInfo({
            lpToken: _lpToken,
			amount: 0,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accPerShare: 0
        });
		poolNum[tokenId] = poolNum[tokenId].add(1);
    }
	

	function setPool(uint tokenId, uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyControl {
        if (_withUpdate) {
            massUpdatePools(tokenId);
        }
        totalAllocPoint[tokenId] = totalAllocPoint[tokenId].sub(poolInfo[tokenId][_pid].allocPoint).add(_allocPoint);
        poolInfo[tokenId][_pid].allocPoint = _allocPoint;
    }
	

	function pendingToken(uint tokenId, uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[tokenId][_pid];
        UserInfo storage user = userInfo[tokenId][_pid][_user];
        uint256 accPerShare = pool.accPerShare;
		if(startBlock[tokenId] == 0){
			return 0;
		}

		uint256 lpSupply = pool.amount;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(tokenId, pool.lastRewardBlock, block.number);
            uint256 tokenReward = multiplier.mul(pool.allocPoint).div(totalAllocPoint[tokenId]);
            accPerShare = accPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accPerShare).div(1e12).sub(user.rewardDebt);
    }
	

	function massUpdatePools(uint tokenId) public {
        uint256 length = poolNum[tokenId];
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(tokenId, pid);
        }
    }


	function updatePool(uint tokenId, uint256 _pid) public {
		require(tokenId < tokenIndex);
        PoolInfo storage pool = poolInfo[tokenId][_pid];
		TokenParam storage pram = tokenInfo[tokenId];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
		if(startBlock[tokenId] == 0){
			return;
		}

		uint256 lpSupply = pool.amount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(tokenId, pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(pool.allocPoint).div(totalAllocPoint[tokenId]);
        MyToken(pram.myTokenAddr).mint(pram.devAddr, tokenReward.mul(pram.feeRate).div(100));
        MyToken(pram.myTokenAddr).mint(address(this), tokenReward);
        pool.accPerShare = pool.accPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }



	function deposit(uint tokenId, uint256 _pid, uint256 _amount) public {
		if(tokenId != 0){
			require(startBlock[tokenId] != 0);
			require(tokenInfo[tokenId].blkNumPriMine + startBlock[tokenId] <= block.number, "priority period");
		}
        PoolInfo storage pool = poolInfo[tokenId][_pid];
        UserInfo storage user = userInfo[tokenId][_pid][msg.sender];
        updatePool(tokenId, _pid);
		
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accPerShare).div(1e12).sub(user.rewardDebt);
            safeTokenTransfer(tokenId, msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
		pool.amount = pool.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e12);
        emit Deposit(msg.sender,tokenId, _pid, _amount);
    }
	

	function delegateDeposit(address _user, uint tokenId, uint256 _pid, uint256 _amount, uint256 _lock_expire)  public onlyDelegate{
		PoolInfo storage pool = poolInfo[tokenId][_pid];
		UserInfo storage user = userInfo[tokenId][_pid][_user];
		updatePool(tokenId, _pid);
		if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accPerShare).div(1e12).sub(user.rewardDebt);
            safeTokenTransfer(tokenId, _user, pending);
        }
		pool.lpToken.safeTransferFrom(delegateContract, address(this), _amount);
        user.amount = user.amount.add(_amount);
		user.lock_amount = user.lock_amount.add(_amount);
		user.lock_expire = _lock_expire;
		pool.amount = pool.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e12);
        emit Deposit(_user,tokenId, _pid, _amount);
	}
	

    function withdraw(uint tokenId, uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[tokenId][_pid];
        UserInfo storage user = userInfo[tokenId][_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
		if(user.lock_expire != 0){
			if(user.lock_expire > now){ 
				require(user.amount.sub(user.lock_amount) >= _amount,"lock amount");
			}
			else{ 
				user.lock_expire = 0;
				user.lock_amount = 0;
			}
		}
        updatePool(tokenId, _pid);
        uint256 pending = user.amount.mul(pool.accPerShare).div(1e12).sub(user.rewardDebt);
        safeTokenTransfer(tokenId, msg.sender, pending);
        user.amount = user.amount.sub(_amount);
		pool.amount = pool.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender,tokenId, _pid, _amount);
    }

	function safeTokenTransfer(uint tokenId, address _to, uint256 _amount) internal {
		TokenParam storage pram = tokenInfo[tokenId];
		uint256 Bal = ERC20(pram.myTokenAddr).balanceOf(address(this));
        if (_amount > Bal) {
            ERC20(pram.myTokenAddr).transfer(_to, Bal);
        } else {
            ERC20(pram.myTokenAddr).transfer(_to, _amount);
        }
    }

	function getMultiplier(uint tokenId, uint256 _from, uint256 _to) public view returns (uint256) {
		TokenParam storage pram = tokenInfo[tokenId];
		uint start = startBlock[tokenId];
		uint bonusEndBlock = start.add(pram.blkNum1st);
		
		if(_to <= bonusEndBlock.add(pram.blkNum2nd)){
			if(_to <= bonusEndBlock){
				if(pram.blkNum1st == 0){
					return 0;
				}
				else{
					return _to.sub(_from).mul(pram.amount1st).div(pram.blkNum1st).mul(100).div(pram.feeRate.add(100));
				}
			}
			else if(_from >= bonusEndBlock){
				if(pram.blkNum2nd == 0){
					return 0;
				}
				else{
					return _to.sub(_from).mul(pram.amount2nd).div(pram.blkNum2nd).mul(100).div(pram.feeRate.add(100));
				}
			}
			else{
				uint first;
				uint sec;
				if(pram.blkNum1st == 0){
					first = 0;
				}
				else{
					first =  bonusEndBlock.sub(_from).mul(pram.amount1st).div(pram.blkNum1st);
				}
				if(pram.blkNum2nd == 0){
					sec = 0;
				}
				else{
					sec = _to.sub(bonusEndBlock).mul(pram.amount2nd).div(pram.blkNum2nd);
				}
			    return first.add(sec).mul(100).div(pram.feeRate.add(100));
			}
		}
		else{
			if(pram.blkNum3rd == 0){
				return 0;
			}
			uint blockHalfstart = bonusEndBlock.add(pram.blkNum2nd);
			uint num = _to.sub(blockHalfstart).div(pram.blkNum3rd).add(1);
			uint perBlock = pram.amount3rd.div(2 ** num).div(pram.blkNum3rd);
			return _to.sub(_from).mul(perBlock).mul(100).div(pram.feeRate.add(100));
		}
    }

	function dev(uint tokenId, address _devAddr) public {
        require(msg.sender == tokenInfo[tokenId].devAddr, "dev: wut?");
        tokenInfo[tokenId].devAddr = _devAddr;
    }
	

	function viewPoolInfo(uint tokenId) public view returns (PoolInfo[] memory){
		uint256 length = poolNum[tokenId];
		PoolInfo[] memory ret = new PoolInfo[](length);
		for (uint256 pid = 0; pid < length; ++pid) {
            ret[pid] = poolInfo[tokenId][pid];
        }
		return ret;
	}
	

	function viewTokenInfo() public view returns (TokenParam[] memory){
		TokenParam [] memory ret = new TokenParam[](tokenIndex);
		for(uint256 index = 0; index < tokenIndex; ++index){
			ret[index]=tokenInfo[index];
		}
		return ret;
	}
}