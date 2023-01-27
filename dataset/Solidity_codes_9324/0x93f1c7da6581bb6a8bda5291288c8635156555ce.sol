


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

pragma solidity >=0.5.0;

interface IWETH {

    function balanceOf(address) view external returns(uint256);

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

    function approve(address guy, uint wad) external returns (bool);

}


pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}


pragma solidity >=0.5.0;

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


pragma solidity 0.6.6;
interface IRecycleToken {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function mint(address _to, uint256 _amount) external;

    function transferWithoutFee(address recipient, uint256 amount) external returns (bool);

}


interface IRecycleStation {


}

contract MasterChef is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct BountyUser{
        address referrer; // Referrer. Will get a part of bounty
        uint256 bountyAmount;// Reward from invitation
        uint256 referrLevel1;
        uint256 referrLevel2;
    }
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint lastDepositTime; // Deposit time, used to judge unlock time. It will be updated every time you deposit.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. Recycles to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Recycles distribution occurs.
        uint256 accRecyclePerShare; // Accumulated Recycles per share, times 1e12. See below.

        uint256 totalLPAmount; // save the number of user deposit amount.
        uint256 lastBurnTime; // every 12 hours will burn
        uint8 burnAmountOfK; // will burn this / 1000
    }

    IRecycleToken public recycle;
    address public devaddr;
    uint256 public bonusEndBlock;
    uint256 public RecyclePerBlock;
    uint256 public constant BONUS_MULTIPLIER = 2;

    uint256 public remainBountyAmount;
    uint256 public remainBugBountyAmount;
    uint256 public remainPoolRewardAmount;

    uint public minLockTime;

    IRecycleStation public recycleStation;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    mapping (address => BountyUser) public bountyInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;


    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IRecycleToken _recycle,
        address _devaddr,
        uint256 _recyclePerBlock,//need multi the decimals
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) public {
        recycle = _recycle;
        devaddr = _devaddr;
        RecyclePerBlock = _recyclePerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        remainBountyAmount = 30000 * 10 ** uint256(_recycle.decimals());// default is 30k
        remainBugBountyAmount = 70000 * 10 ** uint256(_recycle.decimals());// default is 70k
        remainPoolRewardAmount = 900000 * 10 ** uint256(_recycle.decimals()); // default is 900k
        minLockTime = 0;
    }

    function setBounty(uint256 _amount) public onlyOwner{

        remainBountyAmount = _amount;
    }

    function setBugBounty(uint256 _amount) public onlyOwner{

        remainBugBountyAmount = _amount;
    }

    function setPoolReward(uint256 _amount) public onlyOwner{

        remainPoolRewardAmount = _amount;
    }

    function setMinLockTime(uint _time) public onlyOwner {

        minLockTime = _time;
    }

    function setRecycleStation(IRecycleStation _station) public onlyOwner{

        recycleStation = _station;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function initRecyclePair(uint256 _perETHCanSwapAmount,address _factory,IWETH _WETH) public onlyOwner payable{

        if (IUniswapV2Factory(_factory).getPair(address (recycle), address (_WETH)) == address(0)) {
            IUniswapV2Factory(_factory).createPair(address (recycle), address (_WETH));
        }
        address pair = IUniswapV2Factory(_factory).getPair(address (recycle), address (_WETH));
        IWETH(_WETH).deposit{value: 1 ether}();
        assert(IWETH(_WETH).transfer(pair, 1 ether));
        recycle.mint(address (pair),_perETHCanSwapAmount * 10 ** uint256(recycle.decimals()));
        IUniswapV2Pair(pair).mint(address (0));
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner{

        add(_allocPoint,_lpToken,_withUpdate,50);
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate,uint8 _burnOfK) public onlyOwner {

        require(_burnOfK >= 0 && _burnOfK < 1000, "set: invalid burnOfK");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accRecyclePerShare: 0,
            totalLPAmount:0,
            lastBurnTime:block.timestamp,
            burnAmountOfK:_burnOfK
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        set(_pid,_allocPoint,_withUpdate,50);
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate,uint8 _burnOfK) public onlyOwner {

        require(_burnOfK >= 0 && _burnOfK < 1000, "set: invalid burnOfK");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].burnAmountOfK = _burnOfK;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    function pendingRecycle(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRecyclePerShare = pool.accRecyclePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 RecycleReward = multiplier.mul(RecyclePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accRecyclePerShare = accRecyclePerShare.add(RecycleReward.mul(1e12).div(pool.totalLPAmount));
        }
        return user.amount.mul(accRecyclePerShare).div(1e12).sub(user.rewardDebt);
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
        uint256 lpSupply = pool.totalLPAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 RecycleReward = multiplier.mul(RecyclePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        if (remainBugBountyAmount > 0){
            uint256 mintBuyBounty = RecycleReward.div(10);
            if(remainBugBountyAmount < mintBuyBounty){
                recycle.mint(devaddr,remainBugBountyAmount);
                remainBugBountyAmount = 0;
            }else{
                remainBugBountyAmount = remainBugBountyAmount.sub(mintBuyBounty);
                recycle.mint(devaddr,mintBuyBounty);
            }
        }

        if (remainPoolRewardAmount == 0){
            return;
        }
        if(remainPoolRewardAmount > RecycleReward){
            remainPoolRewardAmount = remainPoolRewardAmount.sub(RecycleReward);
        }else{
            RecycleReward = remainPoolRewardAmount;
            remainPoolRewardAmount = 0;
        }

        if(pool.burnAmountOfK > 0 && pool.lastBurnTime + 12 hours < block.timestamp && address(recycleStation) != address(0)){
            uint256 offset = uint256(block.timestamp).sub(pool.lastBurnTime).div(12 hours);
            uint256 currencyLp = pool.lpToken.balanceOf(address(this));
            pool.lastBurnTime = pool.lastBurnTime.add(offset.mul(12 hours));
            uint256 amount = 0;
            uint256 futureLpSupply = currencyLp;
            for(uint i = 0;i<offset;i++){
                uint256 subAmount = futureLpSupply.mul(pool.burnAmountOfK).div(1000);
                amount = amount.add(subAmount);
                futureLpSupply = futureLpSupply.sub(subAmount);
            }
            pool.lpToken.safeTransfer(address(recycleStation),amount);// every 12 hours burn 5%
        }

        recycle.mint(address(this), RecycleReward);
        pool.accRecyclePerShare = pool.accRecyclePerShare.add(RecycleReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount,address referrer) public {

        require(referrer != msg.sender,"deposit:wut?");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        BountyUser storage bountyUser = bountyInfo[msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accRecyclePerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeRecycleTransfer(msg.sender, pending);
                sendTheBounty(pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }

        if(bountyUser.referrer == address(0) && referrer != address(0)){
            bountyUser.referrer = referrer;
            BountyUser storage referrer1 = bountyInfo[bountyUser.referrer];
            referrer1.referrLevel1 ++;
            BountyUser storage referrer2 = bountyInfo[referrer1.referrer];
            referrer2.referrLevel2 ++;
        }
        user.lastDepositTime = block.timestamp;
        user.rewardDebt = user.amount.mul(pool.accRecyclePerShare).div(1e12);
        pool.totalLPAmount = pool.totalLPAmount.add(_amount);

        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRecyclePerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeRecycleTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            require(user.lastDepositTime + minLockTime < block.timestamp,"withdraw: not the time");

            uint256 lpSupply = pool.lpToken.balanceOf(address(this));
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount.mul(lpSupply).div(pool.totalLPAmount));
            pool.totalLPAmount = pool.totalLPAmount.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRecyclePerShare).div(1e12);
        sendTheBounty(pending);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function sendTheBounty(uint256 pending) private{

        if (pending == 0){
            return;
        }
        if(remainBountyAmount > 0){
            BountyUser storage bountyCurrency = bountyInfo[msg.sender];
            address upper = bountyCurrency.referrer;
            uint256 toUpper = pending.mul(3).div(100);

            uint256 toUserTmp = 0;

            if (upper != address(0) && toUpper > 0){
                if(remainBountyAmount > toUpper){
                    remainBountyAmount = remainBountyAmount.sub(toUpper);
                    recycle.mint(upper,toUpper);
                    toUserTmp = toUpper;
                }else{
                    toUserTmp = remainBountyAmount;
                    recycle.mint(upper,remainBountyAmount);
                    remainBountyAmount = 0;
                }

                bountyCurrency.bountyAmount = bountyCurrency.bountyAmount.add(toUserTmp);
            }

            if(upper == address(0)){
                return;
            }

            address upperUpper = bountyInfo[upper].referrer;
            uint256 toUpperUpper = pending.div(100);

            if (remainBountyAmount > 0 && upperUpper != address(0) && toUpperUpper > 0){
                if(remainBountyAmount > toUpperUpper){
                    remainBountyAmount = remainBountyAmount.sub(toUpperUpper);
                    recycle.mint(upperUpper,toUpperUpper);
                    toUserTmp = toUpperUpper;
                }else{
                    toUserTmp = remainBountyAmount;
                    recycle.mint(upperUpper,remainBountyAmount);
                    remainBountyAmount = 0;
                }

                bountyInfo[upper].bountyAmount = bountyInfo[upper].bountyAmount.add(toUserTmp);
            }
        }
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 finalAmount = user.amount.mul(lpSupply).div(pool.totalLPAmount);
        pool.lpToken.safeTransfer(address(msg.sender), finalAmount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        pool.totalLPAmount = pool.totalLPAmount.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeRecycleTransfer(address _to, uint256 _amount) internal {

        uint256 RecycleBal = recycle.balanceOf(address(this));
        if (_amount > RecycleBal) {
            recycle.transferWithoutFee(_to, RecycleBal);
        } else {
            recycle.transferWithoutFee(_to, _amount);
        }
    }

    function dev(address _devaddr) public {

        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}