

pragma solidity ^0.6.0;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    
    
    function mint(address account, uint256 amount) external ;


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


contract ErneMaster is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 time;
     
    }
    
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. Erne to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Erne distribution occurs.
        uint256 accErnePerShare; // Accumulated Erne per share, times 1e12. See below.
    }

    address public Erne;
    
    uint256 public ErnePerBlock;
    
    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    mapping (address=>bool)public lpTokenStatus;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public checkBlock = 200000;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    
    modifier validatePool (uint256 _pid ) {

        require( _pid < poolInfo.length, "pool exists ? " ) ;
        _;
    }
    
    constructor(
        address _Erne,
        uint256 _ErnePerBlock
    ) public {
        Erne = _Erne;
        ErnePerBlock = _ErnePerBlock;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {

        require(!lpTokenStatus[address(_lpToken)], "LP token exists");
        
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        lpTokenStatus[address(_lpToken)] = true;
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accErnePerShare: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }
    
    function setStartBlock(uint256 _startBlock ) public onlyOwner {

        startBlock = _startBlock;
    }

    function getMultiplier( uint256 _from,uint256  _to)public view returns(uint256) {

        
        uint256 endBlock = 10512000;// (1 day) 5760*365  => (1 year )2102400*l5 => 10512000
        require(_from < (startBlock.add(endBlock)) && _to <= (endBlock.add(startBlock)), "Expired");
   
        uint256 year = (_to.sub(startBlock)).div(2102400);
        uint256 erneperBlock = ErnePerBlock;
        uint256 totalrewards = 0;
   
        if(_from < startBlock.add(checkBlock) && _to <= startBlock.add(checkBlock)) {             
            totalrewards = (_to.sub(_from)).mul(380e18);
            return totalrewards;
        }
        else {      
            uint256 count = 1;
            uint256 _fromBlock = _from;
            uint256 _toBlock = _to;
            uint256 _strBlk; uint256 _endBlk;
            
            for(uint256 i = 0; i <= year;i++){
                _strBlk = startBlock.add(uint256(2102400)).mul(i);
                _endBlk = startBlock.add(uint256(2102400)).mul(count);
                
                if(i == 0){
                    if(_fromBlock < startBlock.add(checkBlock) && _toBlock > checkBlock) {             
                        totalrewards = totalrewards.add(((startBlock.add(checkBlock)).sub(_fromBlock)).mul(380e18)); //add ether
                        _fromBlock = startBlock.add(checkBlock);
                      }
                    if(_fromBlock >= startBlock.add(checkBlock) && _toBlock <= _endBlk) {  
                        totalrewards = totalrewards.add((_toBlock.sub(_fromBlock)).mul(76e18));//add ether
                    } 
                    if(_fromBlock >= startBlock.add(checkBlock) &&_fromBlock < startBlock.add(_endBlk) && _toBlock > _endBlk ){
                        totalrewards = totalrewards.add((_endBlk.sub(_fromBlock)).mul(76e18));//add ether
                        _fromBlock = _endBlk;
                    }
                }
                
                if(i > 0){
                    if(_strBlk >= startBlock.add(8409600) && _fromBlock >= _strBlk && _toBlock <= startBlock.add(endBlock)){
                        totalrewards = totalrewards.add((_toBlock.sub(_fromBlock).mul(595e16)));
                    }   
                    else if (_fromBlock >= _strBlk && _toBlock <= _endBlk)    {
                        totalrewards = totalrewards.add( (_toBlock.sub( _fromBlock)).mul(erneperBlock) );
                    }
                     else if(_fromBlock < _endBlk && _toBlock > _endBlk){
                        totalrewards = totalrewards.add((_endBlk.sub(_fromBlock).mul(erneperBlock)));
                        _fromBlock=_endBlk;
                    }
                }
                erneperBlock = erneperBlock.div(2); 
                count = count.add(1);
            }
            return totalrewards;
        }  
    }
    
    function pendingErne(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accErnePerShare = pool.accErnePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 ErneReward = multiplier.mul(ErnePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accErnePerShare = accErnePerShare.add(ErneReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accErnePerShare).div(1e12).sub(user.rewardDebt);
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
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 ErneReward = multiplier.mul(pool.allocPoint).div(totalAllocPoint);
        IERC20(Erne).mint(address(this), ErneReward);
        pool.accErnePerShare = pool.accErnePerShare.add(ErneReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function xreward(uint256 _userTime,uint256 _reward)public view returns(uint256) {

        uint256 totalDays = (now.sub(_userTime)).div(86400);
        uint256 tomint;
        if(totalDays >= 7 && totalDays <= 29){
            tomint= (_reward.mul(11e17)).div(100e18);
            return tomint;
        }
        else if(totalDays >= 30 && totalDays <= 89){
            tomint= (_reward.mul(125e16)).div(100e18);
            return tomint;
        }
        else if(totalDays >= 90 ){
            tomint= (_reward.mul(2e18)).div(100e18);
            return tomint;
        }
    }
    
    function deposit(uint256 _pid, uint256 _amount) public validatePool(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accErnePerShare).div(1e12).sub(user.rewardDebt);
            if(block.number > startBlock.add(checkBlock)) {
                uint256 token = xreward(user.time,pending);
                if(token > 0){
                    IERC20(Erne).mint(address(this),token);
                    pending = pending.add(token);
                }
           }
            safeErneTransfer(msg.sender, pending);
        }
        if(_amount > 0){
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accErnePerShare).div(1e12);
        user.time = now;
        
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public validatePool(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accErnePerShare).div(1e12).sub(user.rewardDebt);
        if(block.number > startBlock.add(checkBlock)) {
            uint256 token = xreward(user.time, pending);
            if(token > 0){
                IERC20(Erne).mint(address(this), token);
                pending = pending.add(token);
            }
         }

        if(pending > 0) {        
            safeErneTransfer(msg.sender, pending);
        }
        
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accErnePerShare).div(1e12);
        user.time = now;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public validatePool(_pid) {

        uint256 _amount;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        _amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    function safeErneTransfer(address _to, uint256 _amount) internal {

        uint256 ErneBal = IERC20(Erne).balanceOf(address(this));
        if (_amount > ErneBal) {
           IERC20(Erne).transfer(_to, ErneBal);
        } else {
            IERC20(Erne).transfer(_to, _amount);
        }
    }

}