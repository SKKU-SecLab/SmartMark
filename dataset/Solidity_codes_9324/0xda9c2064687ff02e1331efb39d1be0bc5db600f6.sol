pragma solidity 0.6.12;

library BoringMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function to128(uint256 a) internal pure returns (uint128 c) {

        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}

library BoringMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}// MIT
pragma solidity 0.6.12;

library SignedSafeMath {

  int256 constant private _INT256_MIN = -2**255;

  function mul(int256 a, int256 b) internal pure returns (int256) {

    if (a == 0) {
      return 0;
    }

    require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

    int256 c = a * b;
    require(c / a == b, "SignedSafeMath: multiplication overflow");

    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {

    require(b != 0, "SignedSafeMath: division by zero");
    require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

    int256 c = a / b;

    return c;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

    return c;
  }

  function toUInt256(int256 a) internal pure returns (uint256) {

    require(a >= 0, "Integer < 0");
    return uint256(a);
  }
}// MIT
pragma solidity 0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// MIT
pragma solidity 0.6.12;


library BoringERC20 {

    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    function returnDataToString(bytes memory data) internal pure returns (string memory) {

        if (data.length >= 64) {
            return abi.decode(data, (string));
        } else if (data.length == 32) {
            uint8 i = 0;
            while(i < 32 && data[i] != 0) {
                i++;
            }
            bytes memory bytesArray = new bytes(i);
            for (i = 0; i < 32 && data[i] != 0; i++) {
                bytesArray[i] = data[i];
            }
            return string(bytesArray);
        } else {
            return "???";
        }
    }

    function safeSymbol(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_SYMBOL));
        return success ? returnDataToString(data) : "???";
    }

    function safeName(IERC20 token) internal view returns (string memory) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_NAME));
        return success ? returnDataToString(data) : "???";
    }

    function safeDecimals(IERC20 token) internal view returns (uint8) {

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_DECIMALS));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
    }
}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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
}// MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




contract SDAOTokenStaking is Ownable {

  using BoringMath for uint256;
  using BoringMath128 for uint128;
  using BoringERC20 for IERC20;
  using SignedSafeMath for int256;

  
  struct UserInfo {
    uint256 amount;
    int256 rewardDebt;
  }


  struct PoolInfo {
    uint256 tokenPerBlock;
    uint256 lpSupply;
    uint128 accRewardsPerShare;
    uint64 lastRewardBlock;
    uint endOfEpochBlock;
  }


  uint256 private constant ACC_REWARDS_PRECISION = 1e18;

  IERC20 public immutable rewardsToken;


  
  PoolInfo[] public poolInfo;
  
  mapping(uint256 => IERC20) public lpToken;
  
  mapping(uint256 => mapping(address => UserInfo)) public userInfo;

  address public pointsAllocator;

  uint256 public totalRewardsReceived;


  event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
  event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
  event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
  event LogPoolAddition(uint256 indexed pid, IERC20 indexed lpToken);
  event LogUpdatePool(uint256 indexed pid, uint64 lastRewardBlock, uint256 lpSupply, uint256 accRewardsPerShare);
  event RewardsAdded(uint256 amount);
  event PointsAllocatorSet(address pointsAllocator);


  modifier onlyPointsAllocatorOrOwner {

    require(
      msg.sender == pointsAllocator || msg.sender == owner(),
      "MultiTokenStaking: not authorized to allocate points"
    );
    _;
  }


  constructor(address _rewardsToken) public {
    rewardsToken = IERC20(_rewardsToken);
  }


  function setPointsAllocator(address _pointsAllocator) external onlyOwner {

    require(_pointsAllocator != address(0), "Invalid points allocator address.");
    pointsAllocator = _pointsAllocator;
    emit PointsAllocatorSet(_pointsAllocator);
  }

  function addRewards(uint256 amount) external onlyPointsAllocatorOrOwner {

    
    require(rewardsToken.balanceOf(msg.sender) > 0, "ERC20: not enough tokens to transfer");

    totalRewardsReceived = totalRewardsReceived.add(amount);
    rewardsToken.safeTransferFrom(msg.sender, address(this), amount);
    
    emit RewardsAdded(amount);
  }



  
  function add(IERC20 _lpToken, uint256 _sdaoPerBlock, uint64 _endofepochblock) public onlyPointsAllocatorOrOwner {


    
    require(_endofepochblock > block.number, "Cannot create the pool for past time.");

    uint256 pid = poolInfo.length;

    lpToken[pid] = _lpToken;

    poolInfo.push(PoolInfo({
      tokenPerBlock: _sdaoPerBlock,
      endOfEpochBlock:_endofepochblock,
      lastRewardBlock: block.number.to64(),
      lpSupply:0,
      accRewardsPerShare: 0
    }));


    emit LogPoolAddition(pid, _lpToken);
  }


  function sdaoPerBlock(uint256 _pid) public view returns (uint256 amount) {

      PoolInfo memory pool = poolInfo[_pid];
      amount = pool.tokenPerBlock;
  }

  function massUpdatePools(uint256[] calldata pids) external onlyOwner {

    uint256 len = pids.length;
    for (uint256 i = 0; i < len; ++i) {
      updatePool(pids[i]);
    }
  }


 function updatePool(uint256 _pid) private returns (PoolInfo memory pool) {


    pool = poolInfo[_pid];
    uint256 lpSupply = pool.lpSupply;

    if (block.number > pool.lastRewardBlock && pool.lastRewardBlock < pool.endOfEpochBlock) {

       if(lpSupply > 0){
         
           uint256 blocks;
           if(block.number < pool.endOfEpochBlock) {
             blocks = block.number.sub(pool.lastRewardBlock);
           } else {
             blocks = pool.endOfEpochBlock.sub(pool.lastRewardBlock);
          }

          uint256 sdaoReward = blocks.mul(sdaoPerBlock(_pid));
          pool.accRewardsPerShare = pool.accRewardsPerShare.add((sdaoReward.mul(ACC_REWARDS_PRECISION) / lpSupply).to128());

       }

       pool.lastRewardBlock = block.number.to64();
       poolInfo[_pid] = pool;
       emit LogUpdatePool(_pid, pool.lastRewardBlock, lpSupply, pool.accRewardsPerShare);

    }

  }




  function pendingRewards(uint256 _pid, address _user) external view returns (uint256 pending) {


    PoolInfo memory pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_user];

    uint256 accRewardsPerShare = pool.accRewardsPerShare;
    uint256 lpSupply = pool.lpSupply;

    if (block.number > pool.lastRewardBlock && pool.lastRewardBlock < pool.endOfEpochBlock) {

      if(lpSupply > 0){

        uint256 blocks;

        if(block.number < pool.endOfEpochBlock) {
            blocks = block.number.sub(pool.lastRewardBlock);
        } else {
          blocks = pool.endOfEpochBlock.sub(pool.lastRewardBlock);
        }
        
        uint256 sdaoReward = blocks.mul(sdaoPerBlock(_pid));
        accRewardsPerShare = accRewardsPerShare.add(sdaoReward.mul(ACC_REWARDS_PRECISION) / lpSupply);

      }

    }

    pending = int256(user.amount.mul(accRewardsPerShare) / ACC_REWARDS_PRECISION).sub(user.rewardDebt).toUInt256();
  }


  function deposit(uint256 _pid, uint256 _amount, address _to) public {


    require(_amount > 0 && _to != address(0), "Invalid inputs for deposit.");

    PoolInfo memory pool = updatePool(_pid);
    UserInfo storage user = userInfo[_pid][_to];

    require (pool.endOfEpochBlock > block.number,"This pool epoch has ended. Please join staking new session.");
    
    user.amount = user.amount.add(_amount);
    user.rewardDebt = user.rewardDebt.add(int256(_amount.mul(pool.accRewardsPerShare) / ACC_REWARDS_PRECISION));

    pool.lpSupply = pool.lpSupply.add(_amount);
    poolInfo[_pid] = pool;

    lpToken[_pid].safeTransferFrom(msg.sender, address(this), _amount);

    emit Deposit(msg.sender, _pid, _amount, _to);
  }

  function withdraw(uint256 _pid, uint256 _amount, address _to) public {


    require(_to != address(0), "ERC20: transfer to the zero address");

    PoolInfo memory pool = updatePool(_pid);
    UserInfo storage user = userInfo[_pid][msg.sender];

    require(user.amount >= _amount && _amount > 0, "Invalid amount to withdraw.");

    user.rewardDebt = user.rewardDebt.sub(int256(_amount.mul(pool.accRewardsPerShare) / ACC_REWARDS_PRECISION));
    user.amount = user.amount.sub(_amount);

    pool.lpSupply = pool.lpSupply.sub(_amount);
    poolInfo[_pid] = pool;

    lpToken[_pid].safeTransfer(_to, _amount);

    emit Withdraw(msg.sender, _pid, _amount, _to);
  }


   function harvest(uint256 _pid, address _to) public {

    
    require(_to != address(0), "ERC20: transfer to the zero address");

    PoolInfo memory pool = updatePool(_pid);
    UserInfo storage user = userInfo[_pid][msg.sender];

    int256 accumulatedRewards = int256(user.amount.mul(pool.accRewardsPerShare) / ACC_REWARDS_PRECISION);
    uint256 _pendingRewards = accumulatedRewards.sub(user.rewardDebt).toUInt256();

    user.rewardDebt = accumulatedRewards;

    if(_pendingRewards > 0 ) {
      rewardsToken.safeTransfer(_to, _pendingRewards);
    }
    
    emit Harvest(msg.sender, _pid, _pendingRewards);
  }

  function withdrawAndHarvest(uint256 _pid, uint256 _amount, address _to) public {


    require(_to != address(0), "ERC20: transfer to the zero address");

    PoolInfo memory pool = updatePool(_pid);
    UserInfo storage user = userInfo[_pid][msg.sender];

    require(user.amount >= _amount && _amount > 0, "Cannot withdraw more than staked.");

    int256 accumulatedRewards = int256(user.amount.mul(pool.accRewardsPerShare) / ACC_REWARDS_PRECISION);
    uint256 _pendingRewards = accumulatedRewards.sub(user.rewardDebt).toUInt256();

    user.rewardDebt = accumulatedRewards.sub(int256(_amount.mul(pool.accRewardsPerShare) / ACC_REWARDS_PRECISION));
    user.amount = user.amount.sub(_amount);

    pool.lpSupply = pool.lpSupply.sub(_amount);
    poolInfo[_pid] = pool;

    if(_pendingRewards > 0) {
      rewardsToken.safeTransfer(_to, _pendingRewards);
    }
    lpToken[_pid].safeTransfer(_to, _amount);

    emit Harvest(msg.sender, _pid, _pendingRewards);
    emit Withdraw(msg.sender, _pid, _amount, _to);
  }


  function emergencyWithdraw(uint256 _pid, address _to) public {


    require(_to != address(0), "ERC20: transfer to the zero address");

    UserInfo storage user = userInfo[_pid][msg.sender];
    uint256 amount = user.amount;
    user.amount = 0;
    user.rewardDebt = 0;

    PoolInfo memory pool = updatePool(_pid);
    pool.lpSupply = pool.lpSupply.sub(amount);
    poolInfo[_pid] = pool;

    lpToken[_pid].safeTransfer(_to, amount);

    emit EmergencyWithdraw(msg.sender, _pid, amount, _to);
  }

  function withdrawETHAndAnyTokens(address token) external onlyOwner {

    msg.sender.send(address(this).balance);
    IERC20 Token = IERC20(token);
    uint256 currentTokenBalance = Token.balanceOf(address(this));
    Token.safeTransfer(msg.sender, currentTokenBalance); 
  }


  function poolLength() external view returns (uint256) {

    return poolInfo.length;
  }


}