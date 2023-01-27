






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






contract RocketDropV1 is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;             // Address of LP token contract.
        uint256 lastRewardBlock;    // Last block number that ERC20s distribution occurs.
        uint256 accERC20PerShare;   // Accumulated ERC20s per share, times 1e36.
        IERC20 rewardToken;         // pool specific reward token.
        uint256 startBlock;         // pool specific block number when rewards start
        uint256 endBlock;           // pool specific block number when rewards end
        uint256 rewardPerBlock;     // pool specific reward per block
        uint256 paidOut;            // total paid out by pool
        uint256 tokensStaked;       // allows the same token to be staked across different pools
        uint256 gasAmount;          // eth fee charged on deposits and withdrawals (per pool)
        uint256 minStake;           // minimum tokens allowed to be staked
        uint256 maxStake;           // max tokens allowed to be staked
        address payable partnerTreasury;    // allows eth fee to be split with a partner on transfer
        uint256 partnerPercent;     // eth fee percent of partner split, 2 decimals (ie 10000 = 100.00%, 1002 = 10.02%)
    }

    uint256 public gasAmount = 2000000000000000;
    address payable public treasury;
    IERC20 public accessToken;
    uint256 public accessTokenMin;
    bool public accessTokenRequired = false;

    IERC20 public rocketBunny;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(IERC20 rocketBunnyAddress) public {
        rocketBunny = rocketBunnyAddress;
        treasury = msg.sender;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function currentBlock() external view returns (uint256) {

        return block.number;
    }

    function initialFund(uint256 _pid, uint256 _amount, uint256 _startBlock) public {

        require(poolInfo[_pid].startBlock == 0, "initialFund: initial funding already complete");
        IERC20 erc20;
        erc20 = poolInfo[_pid].rewardToken;
        erc20.safeTransferFrom(address(msg.sender), address(this), _amount);
        poolInfo[_pid].lastRewardBlock = _startBlock;
        poolInfo[_pid].startBlock = _startBlock;
        poolInfo[_pid].endBlock = _startBlock.add(_amount.div(poolInfo[_pid].rewardPerBlock));
    }

    function fundMore(uint256 _pid, uint256 _amount) public {

        require(block.number < poolInfo[_pid].endBlock, "fundMore: pool closed or use initialFund() first");
        IERC20 erc20;
        erc20 = poolInfo[_pid].rewardToken;
        erc20.safeTransferFrom(address(msg.sender), address(this), _amount);
        poolInfo[_pid].endBlock += _amount.div(poolInfo[_pid].rewardPerBlock);
    }

    function add(IERC20 _lpToken, IERC20 _rewardToken, uint256 _rewardPerBlock, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            lastRewardBlock: 0,
            accERC20PerShare: 0,
            rewardToken: _rewardToken,
            startBlock: 0,
            endBlock: 0,
            rewardPerBlock: _rewardPerBlock,
            paidOut: 0,
            tokensStaked: 0,
            gasAmount: gasAmount,   // defaults to global gas/eth fee
            minStake: 0,
            maxStake: ~uint256(0),
            partnerTreasury: treasury,
            partnerPercent: 0
        }));
    }

    function set(uint256 _pid, uint256 _rewardPerBlock, bool _withUpdate) public onlyOwner {

        updatePool(_pid);   // prevents taking existing rewards from current stakers
        poolInfo[_pid].rewardPerBlock = _rewardPerBlock;
        if (_withUpdate) {
            updatePool(_pid);
        }
    }

    function minStake(uint256 _pid, uint256 _minStake) public onlyOwner {

        poolInfo[_pid].minStake = _minStake;
    }

    function maxStake(uint256 _pid, uint256 _maxStake) public onlyOwner {

        poolInfo[_pid].maxStake = _maxStake;
    }

    function deposited(uint256 _pid, address _user) external view returns (uint256) {

        UserInfo storage user = userInfo[_pid][_user];
        return user.amount;
    }

    function pending(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accERC20PerShare = pool.accERC20PerShare;
        
        uint256 lpSupply = pool.tokensStaked;

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 lastBlock = block.number < pool.endBlock ? block.number : pool.endBlock;
            uint256 nrOfBlocks = lastBlock.sub(pool.lastRewardBlock);
            uint256 erc20Reward = nrOfBlocks.mul(pool.rewardPerBlock);
            accERC20PerShare = accERC20PerShare.add(erc20Reward.mul(1e36).div(lpSupply));
        }

        return user.amount.mul(accERC20PerShare).div(1e36).sub(user.rewardDebt);
    }

    function totalPending(uint256 _pid) external view returns (uint256) {

        if (block.number <= poolInfo[_pid].startBlock) {
            return 0;
        }

        uint256 lastBlock = block.number < poolInfo[_pid].endBlock ? block.number : poolInfo[_pid].endBlock;
        return poolInfo[_pid].rewardPerBlock.mul(lastBlock - poolInfo[_pid].startBlock).sub(poolInfo[_pid].paidOut);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 lastBlock = block.number < pool.endBlock ? block.number : pool.endBlock;

        if (lastBlock <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.tokensStaked;
        if (lpSupply == 0) {
            pool.lastRewardBlock = lastBlock;
            return;
        }

        uint256 nrOfBlocks = lastBlock.sub(pool.lastRewardBlock);
        uint256 erc20Reward = nrOfBlocks.mul(pool.rewardPerBlock);

        pool.accERC20PerShare = pool.accERC20PerShare.add(erc20Reward.mul(1e36).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public payable {

        if(accessTokenRequired){
            require(accessToken.balanceOf(msg.sender) >= accessTokenMin, 'Must have minimum amount of access token!');
        }
        PoolInfo storage pool = poolInfo[_pid];
        uint256 poolGasAmount = pool.gasAmount;
        require(msg.value >= poolGasAmount, 'Correct gas amount must be sent!');
        require(_amount >= pool.minStake && _amount <= pool.maxStake, 'Min/Max stake required!');

        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = user.amount.mul(pool.accERC20PerShare).div(1e36).sub(user.rewardDebt);
            erc20Transfer(msg.sender, _pid, pendingAmount);
        }

        uint256 startTokenBalance = pool.lpToken.balanceOf(address(this));
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        uint256 endTokenBalance = pool.lpToken.balanceOf(address(this));
        uint256 trueDepositedTokens = endTokenBalance.sub(startTokenBalance);

        user.amount = user.amount.add(trueDepositedTokens);
        pool.tokensStaked = pool.tokensStaked.add(trueDepositedTokens);
        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
        
        if (pool.partnerPercent == 0) {
            treasury.transfer(msg.value);
        } else {
            uint256 totalAmount = msg.value;
            uint256 partnerAmount = totalAmount.mul(pool.partnerPercent).div(10000);
            uint256 treasuryAmount = totalAmount.sub(partnerAmount);
            treasury.transfer(treasuryAmount);
            pool.partnerTreasury.transfer(partnerAmount);
        }
        
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public payable {

        if(accessTokenRequired){
            require(accessToken.balanceOf(msg.sender) >= accessTokenMin, 'Must have minimum amount of access token!');
        }
        PoolInfo storage pool = poolInfo[_pid];
        uint256 poolGasAmount = pool.gasAmount;
        require(msg.value >= poolGasAmount, 'Correct gas amount must be sent!');

        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: can't withdraw more than deposit");
        updatePool(_pid);
        uint256 pendingAmount = user.amount.mul(pool.accERC20PerShare).div(1e36).sub(user.rewardDebt);
        erc20Transfer(msg.sender, _pid, pendingAmount);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
        
        if(_amount > 0){
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            pool.tokensStaked = pool.tokensStaked.sub(_amount);
        }

        if (pool.partnerPercent == 0) {
            treasury.transfer(msg.value);
        } else {
            uint256 totalAmount = msg.value;
            uint256 partnerAmount = totalAmount.mul(pool.partnerPercent).div(10000);
            uint256 treasuryAmount = totalAmount.sub(partnerAmount);
            treasury.transfer(treasuryAmount);
            pool.partnerTreasury.transfer(partnerAmount);
        }

        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        pool.tokensStaked = pool.tokensStaked.sub(user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function erc20Transfer(address _to, uint256 _pid, uint256 _amount) internal {

        IERC20 erc20;
        erc20 = poolInfo[_pid].rewardToken;
        erc20.transfer(_to, _amount);
        poolInfo[_pid].paidOut += _amount;
    }
    
    function adjustGasGlobal(uint256 newgas) public onlyOwner {

        gasAmount = newgas;
    }

    function changeAccessToken(IERC20 newToken) public onlyOwner {

        accessToken = newToken;
    }
    function changeAccessMin(uint256 newMin) public onlyOwner {

        accessTokenMin = newMin;
    }
    function changeAccessTknReq(bool setting) public onlyOwner {

        accessTokenRequired = setting;
    }

    function adjustPoolGas(uint256 _pid, uint256 newgas) public onlyOwner {

        poolInfo[_pid].gasAmount = newgas;
    }

    function transferExtraBunny(address _recipient) public onlyOwner {

        uint256 length = poolInfo.length;
        uint256 bunnyHeld;
        uint256 bunnyBalance = rocketBunny.balanceOf(address(this));
        for (uint256 pid = 0; pid < length; ++pid) {
            if(poolInfo[pid].lpToken == rocketBunny){
                bunnyHeld = bunnyHeld.add(poolInfo[pid].tokensStaked);
            }
        }
        uint256 bunnyYield = bunnyBalance.sub(bunnyHeld);
        rocketBunny.transfer(_recipient, bunnyYield);
    }

    function changeTreasury(address payable newTreasury) public onlyOwner {

        treasury = newTreasury;
    }

    function changePartnerTreasury(uint256 _pid, address payable newTreasury) public onlyOwner {

        poolInfo[_pid].partnerTreasury = newTreasury;
    }
    
    function changePartnerPercent(uint256 _pid, uint256 newPercent) public onlyOwner {

        poolInfo[_pid].partnerPercent = newPercent;
    }

    function transfer() public onlyOwner {

        treasury.transfer(address(this).balance);
    }
}