

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

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}

interface IMigratorChef {

    function migrate(IERC20 token) external returns (IERC20);

}


contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract TestaFarmV1Plus is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        mapping (uint256 => uint256) pendingTesta;
        mapping (uint256 => uint256) rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        IUniswapV2Pair uniswap;
        uint112 startLiquidity;
        uint256 allocPoint;       // How many allocation points assigned to this pool. Testa to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Testa distribution occurs.
        uint256 accTestaPerShare; // Accumulated Testa per share, times 1e18. See below.
        uint256 debtIndexKey;
        uint256 startBlock;
        uint256 initStartBlock;
    }

    address public testa;
    uint256 public testaPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 10;
    IMigratorChef public migrator;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public activeReward = 10;
    uint256 public fiveHundred = 40;
    uint256 public thousand = 50;
    int public progressive = 0;
    int public maxProgressive;
    int public minProgressive;
    uint256 public numberOfBlock;
    uint112 public startLiquidity;
    uint112 public currentLiquidity;
    AggregatorV3Interface public priceFeed;
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        address _testa,
        uint256 _testaPerBlock,
        int _maxProgressive,
        int _minProgressive,
        uint256 activateAtBlock,
        address _priceFeed
    ) public {
        testa = _testa;
        testaPerBlock = _testaPerBlock;
        maxProgressive = _maxProgressive;
        minProgressive = _minProgressive;
        numberOfBlock = activateAtBlock;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    modifier onlyEOA() {

        require(msg.sender == tx.origin, "Not EOA");
        _;
    }

    function setTestaPerBlock(uint256 _testaPerBlock) public onlyOwner{

        testaPerBlock = _testaPerBlock;
    }

    function setProgressive(int _maxProgressive, int _minProgressive) public onlyOwner{

        maxProgressive = _maxProgressive;
        minProgressive = _minProgressive;
    }

    function setNumberOfBlock(uint256 _numberOfBlock) public onlyOwner{

        numberOfBlock = _numberOfBlock;
    }

    function setActiveReward(uint256 _activeReward) public onlyOwner{

        activeReward = _activeReward;
    }

    function harvestAndWithdraw(uint256 _pid, uint256 _amount) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        require(getCountDown(_pid) <= numberOfBlock);
        require((progressive == maxProgressive) && (lpSupply != 0), "Must have lpSupply and reach maxProgressive to harvest");
        require(user.amount >= _amount, "No lpToken cannot withdraw");
        updatePool(_pid);
        
        uint256 testaAmount = pendingTesta( _pid, msg.sender);
        
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            user.rewardDebt[pool.debtIndexKey] = user.amount.mul(pool.accTestaPerShare).div(1e18);
            user.pendingTesta[pool.debtIndexKey] = 0;
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            safeTestaTransfer(msg.sender, testaAmount);
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function harvest(uint256 _pid) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        require(getCountDown(_pid) <= numberOfBlock);
        require((progressive == maxProgressive) && (lpSupply != 0), "Must have lpSupply and reach maxProgressive to harvest");
        require(user.amount > 0, "No lpToken cannot withdraw");
        updatePool(_pid);
        
        uint256 testaAmount = pendingTesta( _pid, msg.sender);
        user.rewardDebt[pool.debtIndexKey] = user.amount.mul(pool.accTestaPerShare).div(1e18);
        user.pendingTesta[pool.debtIndexKey] = 0;
        safeTestaTransfer(msg.sender, testaAmount);
    }
    
    function firstActivate(uint256 _pid) public onlyEOA nonReentrant {

        currentLiquidity = getLiquidity(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.initStartBlock == pool.startBlock);
        require(block.number >= pool.initStartBlock, "Cannot activate until the specific block time arrive");
        pool.startBlock = getLatestBlock();
        pool.startLiquidity = currentLiquidity;
        safeTestaTransfer(msg.sender, getTestaReward(_pid));
    }

    function activate(uint256 _pid) public onlyEOA nonReentrant {

        currentLiquidity = getLiquidity(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        
        require(pool.initStartBlock != pool.startBlock);
        require(getCountDown(_pid) >= numberOfBlock, "Cannot activate until specific amount of blocks pass");
        
        if(currentLiquidity > pool.startLiquidity){
            progressive++;
        }else{
            progressive--;
        }
            
        if(progressive <= minProgressive){
            progressive = minProgressive;
            clearPool(_pid);
        }else if(progressive >= maxProgressive){
            progressive = maxProgressive;
        }
        pool.startBlock = getLatestBlock();  
        pool.startLiquidity = currentLiquidity;
        safeTestaTransfer(msg.sender, getTestaReward(_pid));
    }

    function getTestaPoolBalance() public view returns (uint256){

        return IERC20(testa).balanceOf(address(this));
    }
    
    function getProgressive() public view returns (int){

        return progressive;
    }
    
    function getLatestBlock() public view returns (uint256) {

        return block.number;
    }
    
    function getCountDown(uint256 _pid) public view returns (uint256){

        require(getLatestBlock() > getStartedBlock(_pid));
        return getLatestBlock().sub(getStartedBlock(_pid));
    }

    function getStartedBlock(uint256 _pid) public view returns (uint256){

        PoolInfo storage pool = poolInfo[_pid];
        return pool.startBlock;
    }
    
    function getLiquidity(uint256 _pid) public view returns (uint112){

        PoolInfo storage pool = poolInfo[_pid];
        ( , uint112 _reserve1, ) = pool.uniswap.getReserves();
        return _reserve1;
    }

    function getLatestPrice() public view returns (int) {

        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        require(timeStamp > 0, "Round not complete");
        return price;
    }

    function getTestaReward(uint256 _pid) public view returns (uint256){

         PoolInfo storage pool = poolInfo[_pid];
        (uint112 _reserve0, uint112 _reserve1, ) = pool.uniswap.getReserves();
        uint256 reserve = uint256(_reserve0).mul(1e18).div(uint256(_reserve1));
        uint256 ethPerDollar = uint256(getLatestPrice()).mul(1e10); // 1e8
        uint256 testaPerDollar = ethPerDollar.mul(1e18).div(reserve);
        uint256 _activeReward = activeReward.mul(1e18);
        uint256 testaAmount = _activeReward.mul(1e18).div(testaPerDollar);
        return testaAmount;
    }
    
    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 startBlock, uint256 _allocPoint, address _lpToken, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        IUniswapV2Pair uniswap = IUniswapV2Pair(_lpToken);
        ( , uint112 _reserve1, ) = uniswap.getReserves(); 
        
        poolInfo.push(PoolInfo({
            lpToken: IERC20(_lpToken),
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accTestaPerShare: 0,
            debtIndexKey: 0,
            uniswap: uniswap,
            startLiquidity: _reserve1,
            startBlock: startBlock,
            initStartBlock: startBlock
        }));

        
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMigrator(IMigratorChef _migrator) public onlyOwner {

        migrator = _migrator;
    }

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        return _to.sub(_from);
    }
    
    function clearPool(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        pool.accTestaPerShare = 0;
        pool.lastRewardBlock = block.number;
        pool.debtIndexKey++;
    }

    function pendingTesta(uint256 _pid, address _user) public view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTestaPerShare = pool.accTestaPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 testaReward = multiplier.mul(testaPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTestaPerShare = accTestaPerShare.add(testaReward.mul(1e18).div(lpSupply));
        }
        uint256 rewardDebt = user.rewardDebt[pool.debtIndexKey];
        return user.amount.mul(accTestaPerShare).div(1e18).sub(rewardDebt).add(user.pendingTesta[pool.debtIndexKey]);
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
        uint256 testaReward = multiplier.mul(testaPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accTestaPerShare = pool.accTestaPerShare.add(testaReward.mul(1e18).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        if (user.amount > 0) {
          user.pendingTesta[pool.debtIndexKey] = pendingTesta(_pid, msg.sender);
        }
        
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        
        user.rewardDebt[pool.debtIndexKey] = user.amount.mul(pool.accTestaPerShare).div(1e18);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "No lpToken cannot withdraw");
        updatePool(_pid);
        
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt[pool.debtIndexKey] = user.amount.mul(pool.accTestaPerShare).div(1e18);
        user.pendingTesta[pool.debtIndexKey] = 0;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt[pool.debtIndexKey] = 0;
    }

    function safeTestaTransfer(address _to, uint256 _amount) internal {

        uint256 testaBal = IERC20(testa).balanceOf(address(this));
        if (_amount > testaBal) {
            testa.call(abi.encodeWithSignature("transfer(address,uint256)", _to, testaBal));
        } else {
            testa.call(abi.encodeWithSignature("transfer(address,uint256)", _to, _amount));
        }
    }
}