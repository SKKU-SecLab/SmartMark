


pragma solidity 0.5.16;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity 0.5.16;

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


pragma solidity 0.5.16;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity 0.5.16;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.16;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.5.16;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity 0.5.16;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity 0.5.16;

contract IRewardDistributionRecipient is Ownable {

    address rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;


    modifier onlyRewardDistribution() {

        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {

        rewardDistribution = _rewardDistribution;
    }
}

pragma solidity 0.5.16;

contract StakeTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public stakeToken = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); 

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function stake(uint256 amount) public {

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakeToken.safeTransfer(msg.sender, amount);
    }
}

pragma solidity 0.5.16;

contract WethPool is StakeTokenWrapper, IRewardDistributionRecipient {

    IERC20 public defi = IERC20(0x705befA72495cD32a801fAd8020BeFd3428C55ff);
    
    address payable public projectAddress;
    uint256 public constant DURATION = 7 days;
    uint256 public constant RewardDuration = 1 days;
    uint256 public constant startTime = 1609246800;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime; 
    uint256 public rewardPerTokenStored = 0;
    uint256 public totalBurnReward = 0;
    uint256[] public stakePool = new uint256[](1); 
    uint256[] public burnPool = new uint256[](1);
    bool private open = true;
    uint256 private constant _gunit = 1e18;
    
    struct Deposit {
      uint256 amount;
      uint256 stakeTime;
      uint256 stakeRewardPerTokenStored;
      uint256 round;
   }
   
   struct User {
      Deposit[] deposits;
   }
    
    mapping(address => uint256) public userRewardPerTokenPaid; 
    mapping(address => uint256) public rewards; // Unclaimed rewards
    mapping (address => User) internal users;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event SetOpen(bool _open);

    constructor(address payable projectAddr) public {
        projectAddress = projectAddr;
    }
    
    function _autoExendArray(uint256[] storage arr, uint256 index) internal{

        if(index >= arr.length){
            arr.length = index.add(1);
        }
    }
    
    function getRound(uint256 beginTime) public view returns (uint256) {

        if(block.timestamp <= beginTime) return 0;
        return block.timestamp.sub(beginTime).div(RewardDuration);
    }
    
    function getUser(address adrr,uint256 index) public view returns (uint256,uint256,uint256,uint256) {

        return (users[adrr].deposits[index].amount,users[adrr].deposits[index].stakeTime,users[adrr].deposits[index].stakeRewardPerTokenStored,users[adrr].deposits[index].round);
    }
    
    function getBurnPoolReward(uint256 index) public view returns (uint256) {

        if(index >= burnPool.length) return 0;
        return burnPool[index];
    }

    function getTotalBurnPoolReward() public view returns (uint256) {

        uint256 totalBurnPoolReward = 0;
        for(uint256 i = 0; i < burnPool.length; i++){
            totalBurnPoolReward = totalBurnPoolReward.add(burnPool[i]);
        }
        return totalBurnPoolReward;
    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(_gunit)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(_gunit)
                .add(rewards[account]);
    }

    function stake(uint256 amount) public checkOpen checkStart updateReward(msg.sender){ 

        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        uint256 round = getRound(startTime);
        _autoExendArray(stakePool,round);
        _autoExendArray(burnPool,round);
        stakePool[round] = stakePool[round].add(amount);
        uint256 updateTime = lastTimeRewardApplicable();
        users[msg.sender].deposits.push(Deposit(amount, updateTime, rewardPerTokenStored,round));
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public checkStart updateReward(msg.sender){

        require(amount > 0, "Cannot withdraw 0");
        getReward();
        super.withdraw(amount);
        uint256 totalAmount = amount;
        for (uint256 i = 0; i < users[msg.sender].deposits.length; i++) {
            uint256 userAmount = users[msg.sender].deposits[i].amount;
            uint256 userRound = users[msg.sender].deposits[i].round;
            if(totalAmount == 0 ) break;
            if(userAmount >= totalAmount){
                users[msg.sender].deposits[i].amount = users[msg.sender].deposits[i].amount.sub(totalAmount);
                stakePool[userRound] = stakePool[userRound].sub(totalAmount);
                totalAmount = 0;
            }else{
                stakePool[userRound] = stakePool[userRound].sub(users[msg.sender].deposits[i].amount);
                users[msg.sender].deposits[i].amount = 0;
                totalAmount = totalAmount.sub(userAmount);
            }
        }
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public checkStart updateReward(msg.sender){

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            uint256 taxAmount = tax(msg.sender);
            uint256 burnReward = _updateBurnReward(msg.sender);
            uint256 round = getRound(startTime);
            _autoExendArray(burnPool,round);
            _autoExendArray(stakePool,round.add(1));
            totalBurnReward = totalBurnReward.add(taxAmount);
            burnPool[round] = burnPool[round].add(taxAmount);
            defi.safeTransfer(projectAddress, reward.div(10));
            defi.safeTransfer(msg.sender, reward.mul(9).div(10).sub(taxAmount).add(burnReward));
            uint256 updateTime = lastTimeRewardApplicable();
            for (uint256 i = 0; i < users[msg.sender].deposits.length; i++) {
                if(users[msg.sender].deposits[i].amount != 0){
                    uint256 userRound = users[msg.sender].deposits[i].round;
                    stakePool[userRound] = stakePool[userRound].sub(users[msg.sender].deposits[i].amount);
                    users[msg.sender].deposits[i].stakeTime = updateTime;
                    users[msg.sender].deposits[i].stakeRewardPerTokenStored = userRewardPerTokenPaid[msg.sender];
                    users[msg.sender].deposits[i].round = round.add(1);
                    stakePool[round.add(1)] = stakePool[round.add(1)].add(users[msg.sender].deposits[i].amount);
                }
            }
            emit RewardPaid(msg.sender, reward);
        }
    }
    
    function getTaxRate(uint256 stakeTime) public view returns(uint256) {

        uint256 taxRate = lastTimeRewardApplicable()
                                .sub(stakeTime)
                                .mul(100)
                                .div(RewardDuration)
                                .div(2);
        return taxRate;
    }

    function tax(address account) public view returns(uint256) {

        uint256 taxAmount = 0;
        uint256 taxRewardPerToken = rewardPerToken();
        for(uint256 i = 0; i < users[account].deposits.length; i++) {
            if(users[account].deposits[i].amount != 0){
                uint256 taxRate = getTaxRate(users[account].deposits[i].stakeTime);
                if(taxRate < 100) {
                    taxRate = uint256(100).sub(taxRate);
                    uint256 userRewardPerToken = taxRewardPerToken.sub(users[account].deposits[i].stakeRewardPerTokenStored);
                    uint256 amount =  users[account].deposits[i].amount;
                    taxAmount = taxAmount.add(
                        amount
                            .mul(userRewardPerToken)
                            .mul(9)
                            .div(10)
                            .mul(36)
                            .div(100)
                            .mul(taxRate)
                        );
                }
            }
        }
        return taxAmount.div(_gunit).div(100);
    }
    
     function getBurnReward(address account) public view returns(uint256) {

        uint256 endIndex =  getRound(startTime);
        if(endIndex < 2 || users[account].deposits.length == 0 || burnPool.length < 2){
            return 0;
        }
        uint256 burnRewardAmount = 0;
        uint256[] memory tempBurnPool = burnPool;
        
        for (uint256 i = 0; i < users[account].deposits.length; i++) {
            if(users[account].deposits[i].amount != 0){
                if(users[account].deposits[i].round == 0){
                    uint256 reward = 0;
                    for(uint256 j = 0; j < 2; j++){
                        reward = reward.add(tempBurnPool[j]);
                    }
                    burnRewardAmount = burnRewardAmount.add(
                                            reward.mul(users[account].deposits[i].amount)
                                            .div(stakePool[0])
                                        );
                }
                uint256 userRound = users[account].deposits[i].round == 0 ? 1 : users[account].deposits[i].round;
                if(endIndex >= userRound.add(2)){
                    uint256 stakeRealAmount = 0;
                    for(uint256 j = 0; j < userRound; j++){
                        stakeRealAmount = stakeRealAmount.add(stakePool[j]);
                    }
                    for(uint256 j = userRound; j < tempBurnPool.length - 2; j++ ){
                        stakeRealAmount = stakeRealAmount.add(stakePool[j]);
                        uint reward = tempBurnPool[j.add(1)].mul(users[account].deposits[i].amount).div(stakeRealAmount);
                        burnRewardAmount = burnRewardAmount.add(reward); 
                    }
                }
            }
        }
        
        return burnRewardAmount;
    }
    
    function _updateBurnReward(address account) internal returns(uint256) {

        uint256 endIndex =  getRound(startTime);
        if(endIndex < 2 || users[account].deposits.length == 0 || burnPool.length < 2){
            return 0;
        }
        uint256 burnRewardAmount = 0;
        uint256[] memory tempBurnPool = burnPool;
        
        for (uint256 i = 0; i < users[account].deposits.length; i++) {
            if(users[account].deposits[i].amount != 0){
                if(users[account].deposits[i].round == 0){
                    uint256 reward = 0;
                    for(uint256 j = 0; j < 2; j++){
                        reward = reward.add(tempBurnPool[j]);
                    }
                    burnRewardAmount = burnRewardAmount.add(reward.mul(users[account].deposits[i].amount).div(stakePool[0]));
                    uint256 totalBurnRewardAmount = burnRewardAmount;
                    for (uint256 j = 0; j < 2; j++) {
                        if(totalBurnRewardAmount == 0 ) break;
                        if(burnPool[j] >= totalBurnRewardAmount){
                            burnPool[j] = burnPool[j].sub(totalBurnRewardAmount);
                            totalBurnRewardAmount = 0;
                        }else{
                            totalBurnRewardAmount = totalBurnRewardAmount.sub(burnPool[j]);
                            burnPool[j] = 0;
                        }
                    }
                }
                uint256 userRound = users[account].deposits[i].round == 0 ? 1 : users[account].deposits[i].round;
                if(endIndex >= userRound.add(2)){
                    uint256 stakeRealAmount = 0;
                    for(uint256 j = 0; j < userRound; j++){
                        stakeRealAmount = stakeRealAmount.add(stakePool[j]);
                    }
                    for(uint256 j = userRound; j < tempBurnPool.length - 2; j++ ){
                        stakeRealAmount = stakeRealAmount.add(stakePool[j]);
                        uint reward = tempBurnPool[j.add(1)].mul(users[account].deposits[i].amount).div(stakeRealAmount);
                        burnRewardAmount = burnRewardAmount.add(reward);
                        burnPool[j.add(1)] = burnPool[j.add(1)].add(reward);
                    }
                }
            }
        }
        
        return burnRewardAmount;
    }

    modifier checkStart(){

        require(block.timestamp > startTime,"Not start");
        _;
    }

    modifier checkOpen() {

        require(open, "Pool is closed");
        _;
    }

    function checkStartReturn() public view returns(bool){

        if(block.timestamp > startTime) return true;
        return false;
    }

    function getPeriodFinish() external view returns (uint256) {

        return periodFinish;
    }

    function isOpen() external view returns (bool) {

        return open;
    }

    function setOpen(bool _open) external onlyOwner {

        open = _open;
        emit SetOpen(_open);
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        checkOpen
        updateReward(address(0)){

        if (block.timestamp > startTime){
            if (block.timestamp >= periodFinish) {
                uint256 period = block.timestamp.sub(startTime).div(DURATION).add(1);
                periodFinish = startTime.add(period.mul(DURATION));
                rewardRate = reward.div(periodFinish.sub(block.timestamp));
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(remaining);
            }
            lastUpdateTime = block.timestamp;
        }else {
          rewardRate = reward.div(DURATION);
          periodFinish = startTime.add(DURATION);
          lastUpdateTime = startTime;
        }

        defi.mint(address(this),reward);
        emit RewardAdded(reward);

        _checkRewardRate();
    }
    
    function _checkRewardRate() internal view returns (uint256) {

        return DURATION.mul(rewardRate).mul(_gunit);
    }
}