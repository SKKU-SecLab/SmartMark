

pragma solidity ^0.8.0;


abstract contract ReentrancyGuard {

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}



contract CHIZchefV2 is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. CHIZes to distribute per block.
        uint256 lastRewardBlock;  // Last block number that CHIZes distribution occurs.
        uint256 accChizPerShare;   // Accumulated CHIZes per share, times 1e36. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
	    uint256 lpSupply;
        bool isPoolPrivileged; 
    }

    IERC20 public chizToken;
    IERC721 public nftPrivilegeContractOne;
    IERC721 public nftPrivilegeContractTwo;
    address public devAddress;
    address public feeAddress;
    uint256 constant max_chiz_reward_amount = 30000000 ether;

    uint256 public chizPerBlock = 20 ether;
    uint256 public chizDistributedAmount = 0;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public endBlock;

    uint256 public constant MAXIMUM_EMISSION_RATE = 300 ether;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);
    event SetDevAddress(address indexed user, address indexed newAddress);
    event UpdateEmissionRate(address indexed user, uint256 chizPerBlock);
    event PoolAdd(address indexed user, IERC20 lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint16 depositFeeBP);
    event PoolSet(address indexed user, IERC20 lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint16 depositFeeBP);
    event UpdateStartBlock(address indexed user, uint256 startBlock);
    constructor(
        IERC721 _nftPrivilegeContractOne,
        IERC721 _nftPrivilegeContractTwo,
        IERC20 _chizToken,
        uint256 _startBlock,
        address _devAddress,
        address _feeAddress
        
    ) public {
        nftPrivilegeContractOne = _nftPrivilegeContractOne;
        nftPrivilegeContractTwo = _nftPrivilegeContractTwo;
        chizToken = _chizToken;
        startBlock = _startBlock;
        devAddress = _devAddress;
        feeAddress = _feeAddress;
        endBlock = _startBlock;
        
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    mapping(IERC20 => bool) public poolExistence;
    modifier nonDuplicated(IERC20 _lpToken) {

        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, uint16 _depositFeeBP, bool _isPoolPrivileged) external onlyOwner {

	    _lpToken.balanceOf(address(this));
        require(_depositFeeBP <= 500, "add: invalid deposit fee basis points");

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_lpToken] = true;
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accChizPerShare: 0,
            depositFeeBP: _depositFeeBP,
	        lpSupply: 0,
            isPoolPrivileged: _isPoolPrivileged
        }));
	    emit PoolAdd(msg.sender, _lpToken, _allocPoint,lastRewardBlock,_depositFeeBP);
    }

    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP) external onlyOwner {

        require(_depositFeeBP <= 500, "set: invalid deposit fee basis points");
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
	    emit PoolSet(msg.sender, poolInfo[_pid].lpToken, _allocPoint,poolInfo[_pid].lastRewardBlock,_depositFeeBP);
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        if (chizDistributedAmount >= max_chiz_reward_amount) return 0;
 
        return _to.sub(_from);
    }

    function pendingChiz(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accChizPerShare = pool.accChizPerShare;

        if (block.number > pool.lastRewardBlock && pool.lpSupply != 0 && totalAllocPoint > 0) {
            uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, lastBlock);
            uint256 chizReward = multiplier.mul(chizPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accChizPerShare = accChizPerShare.add(chizReward.mul(1e36).div(pool.lpSupply));
        }
        return user.amount.mul(accChizPerShare).div(1e36).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
        if (lastBlock <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = lastBlock;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, lastBlock);
        uint256 chizReward = multiplier.mul(chizPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        if(chizDistributedAmount.add(chizReward.mul(102).div(100)) <= max_chiz_reward_amount){
            chizToken.safeTransfer(devAddress, chizReward.div(50));
        }

        pool.accChizPerShare = pool.accChizPerShare.add(chizReward.mul(1e36).div(pool.lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) nonReentrant external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(pool.isPoolPrivileged){
            require(nftPrivilegeContractOne.balanceOf(msg.sender) > 0 && nftPrivilegeContractTwo.balanceOf(msg.sender) > 0, "NFTs are required for deposit");

        }
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accChizPerShare).div(1e36).sub(user.rewardDebt);
            if (pending > 0) {
                safeChizTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
	        uint256 balanceBefore = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            _amount = pool.lpToken.balanceOf(address(this)).sub(balanceBefore);
            require(_amount > 0, "we dont accept deposits of 0");
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
		        pool.lpSupply = pool.lpSupply.add(_amount).sub(depositFee);
            } else {
                user.amount = user.amount.add(_amount);
		        pool.lpSupply = pool.lpSupply.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accChizPerShare).div(1e36);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) nonReentrant external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accChizPerShare).div(1e36).sub(user.rewardDebt);
        if (pending > 0) {
            safeChizTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
	        pool.lpSupply = pool.lpSupply.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accChizPerShare).div(1e36);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) nonReentrant external{

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
	    pool.lpSupply = pool.lpSupply.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function safeChizTransfer(address _to, uint256 _amount) internal {

        uint256 chizBal = chizToken.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > chizBal) {
            transferSuccess = chizToken.transfer(_to, chizBal);
            chizDistributedAmount = chizDistributedAmount.add(chizBal);
        } else {
            transferSuccess = chizToken.transfer(_to, _amount);
            chizDistributedAmount = chizDistributedAmount.add(_amount);
        }
        require(transferSuccess, "safeChizTransfer: Transfer failed");
    }

    function setDevAddress(address _devAddress) external onlyOwner {

	require(_devAddress != address(0), "!nonzero");
        devAddress = _devAddress;
        emit SetDevAddress(msg.sender, _devAddress);
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {

	require(_feeAddress != address(0), "!nonzero");
        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }

    function updateEmissionRate(uint256 _chizPerBlock) external onlyOwner {

        require(_chizPerBlock <= MAXIMUM_EMISSION_RATE, "Too High");
        massUpdatePools();
        chizPerBlock = _chizPerBlock;
        emit UpdateEmissionRate(msg.sender, _chizPerBlock);
    }

    function updateStartBlock(uint256 _startBlock) onlyOwner external{

        require(startBlock > block.number, "Farm already started");
        uint256 length = poolInfo.length;
        for(uint256 pid = 0; pid < length; ++pid){
            PoolInfo storage pool = poolInfo[pid];
            pool.lastRewardBlock = _startBlock;
        }
            startBlock = _startBlock;
        emit UpdateStartBlock(msg.sender, _startBlock);
    }
    function fund(uint256 _amount) public onlyOwner {

        require(block.number < endBlock, "fund: too late, the farm is closed");

        chizToken.transferFrom(address(msg.sender), address(this), _amount);
        endBlock += _amount.div(chizPerBlock);
    }
}