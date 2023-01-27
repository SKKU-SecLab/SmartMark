

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    
    function decimals() external view returns (uint8);


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

    function transferOwnership(address newOwner) internal virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.6.0;

interface StabilizeToken is IERC20 {


    function mint(address _to, uint256 _amount) external returns (bool);


    function initiateBurn(uint256 rate) external returns (bool);

    
    function owner() external view returns (address);


}

interface StabilizePriceOracle {

    function getPrice(address _address) external returns (uint256);

}


pragma solidity ^0.6.0;

contract Operator is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for StabilizeToken;
    using Address for address;
    
    uint256 constant duration = 604800; // Each reward period lasts for one week
    uint256 private _periodFinished; // The UTC time that the current reward period ends
    uint256 public protocolStart; // UTC time that the protocol begins to reward tokens
    uint256 public lastOracleTime; // UTC time that oracle was last ran
    uint256 constant minOracleRefresh = 21600; // The minimum amount of time we need to wait before refreshing the oracle prices
    uint256 private targetPrice = 1000000000000000000; // The target price for the stablecoins in USD
    StabilizeToken private StabilizeT; // A reference to the StabilizeToken
    StabilizePriceOracle private oracleContract; // A reference to the price oracle contract
    
    uint256 private _currentWeek = 0; // Week 1 to 52 are bootstrap weeks that have emissions, after week 52, token burns
    uint256 private _weekStart = 0; // This is the time that the current week starts, must be at least duration before starting a new week
    uint256[] private _mintSchedule; // The pre-programmed schedule for minting tokens from contract
    uint256 private weeklyReward; // The reward for the current week, this determines the reward rate
    
    uint256 private _maxSupplyFirstYear = 1000000000000000000000000; // Max emission during the first year, max 1,000,000 Stablize Token
    uint256 private _rewardPercentLP = 50000; // This is the percent of rewards reserved for LP pools. Represents 50% of all Stabilize Token rewards 
    uint256 constant _rewardPercentDev = 1000; // This percent of rewards going to development team during first year, 1%
    uint256 private _emissionRateLong = 1000; // This is the minting rate after the first year, currently 1% per year
    uint256 private _burnRateLong = 0; // This is the burn per transaction after the first year
    uint256 private _earlyBurnRate = 0; // Optionally, the contract may burn tokens if extra not needed
    uint256 constant divisionFactor = 100000;
    

    struct UserInfo {
        uint256 amount; // How many LP/Stablecoin tokens the user has provided.
        uint256 rewardDebt; // Reward debt. The amount of rewards already given to depositer
        uint256 unclaimedReward; // Total reward potential
    }

    struct PoolInfo {
        IERC20 sToken; // Address of LP/Stablecoin token contract.
        uint256 rewardRate; // The rate at which Stabilize Token is earned per second
        uint256 rewardPerTokenStored; // Reward per token stored which should gradually increase with time
        uint256 lastUpdateTime; // Time the pool was last updated
        uint256 totalSupply; // The total amount of LP/Stablecoin in the pool
        bool active; // If active, the pool is earning rewards, otherwise its not
        uint256 poolID; // ID for the pool
        bool lpPool; // LP pools are calculated separate from stablecoin pools
        uint256 price; // Oracle price of token in pool
        uint256 poolWeight; // Weight of pool compared to the total
    }

    PoolInfo[] private totalPools;
    mapping(uint256 => mapping(address => UserInfo)) private userInfo;
    uint256[] private activePools;

    event RewardAdded(uint256 pid, uint256 reward);
    event Deposited(uint256 pid, address indexed user, uint256 amount);
    event Withdrawn(uint256 pid, address indexed user, uint256 amount);
    event RewardPaid(uint256 pid, address indexed user, uint256 reward);
    event RewardDenied(uint256 pid, address indexed user, uint256 reward);
    event NewWeek(uint256 weekNum, uint256 rewardAmount);

    constructor(
        StabilizeToken _stabilize,
        StabilizePriceOracle _oracle,
        uint256 startTime
    ) public {
        StabilizeT = _stabilize;
        oracleContract = _oracle;
        protocolStart = startTime;
        setupEmissionSchedule(); // Publicize mint schedule
    }
    
    
    modifier updateRewardEarned(uint256 _pid, address account) {

        totalPools[_pid].rewardPerTokenStored = rewardPerToken(_pid);
        totalPools[_pid].lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            userInfo[_pid][account].unclaimedReward = rewardEarned(_pid,account);
            userInfo[_pid][account].rewardDebt = totalPools[_pid].rewardPerTokenStored;
        }
        _;
    }
    
    
    function setupEmissionSchedule() internal {

        _mintSchedule.push(76000000000000000000000); // Week 1 emission
        _mintSchedule.push(57000000000000000000000); // Week 2 emission
        _mintSchedule.push(38000000000000000000000); // Week 3 emission
        _mintSchedule.push(19000000000000000000000); // Week 4 emission
        for(uint i = 4; i < 52; i++){
            _mintSchedule.push(16875000000000000000000); // Week 5-52 emissions, can be adjusted
        }
    }
    
    function mintNewWeek() external {

        require(now >= protocolStart,"Too soon to start this protocol");
        if(_currentWeek > 0){
            require(now >= _periodFinished,"Too early to start next week");
        }
        require(StabilizeT.owner() == address(this),"The Operator does not have permission to mint tokens");
        _currentWeek = _currentWeek.add(1);
        uint256 rewardAmount = 0;
        if(_currentWeek < 53){
            uint256 devShare = 0;
            if(_currentWeek > 1){
                devShare = _mintSchedule[_currentWeek-1].mul(_rewardPercentDev).div(divisionFactor);
                _mintSchedule[_currentWeek-1] = _mintSchedule[_currentWeek-1].sub(devShare);
                StabilizeT.mint(owner(),devShare); // The Operator will mint tokens to the developer
            }else{
                for(uint256 i = 0; i < totalPools.length; i++){
                    activePools.push(totalPools[i].poolID);
                    totalPools[i].active = true;
                }             
            }
            rewardAmount = _mintSchedule[_currentWeek-1];
            if(_earlyBurnRate > 0){
                rewardAmount = rewardAmount.sub(rewardAmount.mul(_earlyBurnRate).div(divisionFactor));
            }
        }else{
            if(_currentWeek == 53){
                StabilizeT.initiateBurn(_burnRateLong);
                _maxSupplyFirstYear = StabilizeT.totalSupply();
            }
            rewardAmount = _maxSupplyFirstYear.mul(_emissionRateLong).div(divisionFactor).div(52);
        }
        StabilizeT.mint(address(this),rewardAmount); // Mint at a set rate
        for(uint256 i = 0; i < activePools.length; i++){
            forceUpdateRewardEarned(activePools[i],address(0));
            totalPools[activePools[i]].rewardRate = 0; // Set the reward rate to 0 until pools rebalanced
        }
        _periodFinished = now + duration;
        weeklyReward = rewardAmount; // This is this week's distribution
        lastOracleTime = now - minOracleRefresh; // Force oracle price to update
        rebalancePoolRewards(); // The pools will determine their reward rates based on the price
        emit NewWeek(_currentWeek,weeklyReward);
    }
    
    function currentWeek() external view returns (uint256){

        return _currentWeek;
    }
    
    function emissionRate() external view returns (uint256){

        return _emissionRateLong;
    }
    
    function periodFinished() external view returns (uint256){

        return _periodFinished;
    }

    function poolLength() public view returns (uint256) {

        return totalPools.length;
    }
    
    function rebalancePoolRewards() public {

        require(now >= lastOracleTime + minOracleRefresh, "Cannot update the oracle prices now");
        require(_currentWeek > 0, "Protocol has not started yet");
        require(oracleContract != StabilizePriceOracle(address(0)),"No price oracle contract has been selected yet");
        lastOracleTime = now;
        uint256 rewardPerSecond = weeklyReward.div(duration);
        uint256 rewardLeft = 0;
        uint256 timeLeft = 0;
        if(now < _periodFinished){
            timeLeft = _periodFinished.sub(now);
            rewardLeft = timeLeft.mul(rewardPerSecond); // The amount of rewards left in this week
        }
        uint256 lpRewardLeft = rewardLeft.mul(_rewardPercentLP).div(divisionFactor);
        uint256 sbRewardLeft = rewardLeft.sub(lpRewardLeft);
        
        uint256 length = activePools.length;
        require(length > 0,"No active pools exist on the protocol");
        uint256 totalWeight = 0;
        uint256 i = 0;
        for(i = 0; i < length; i++){
            if(totalPools[activePools[i]].lpPool == true){
                totalPools[activePools[i]].poolWeight = 1;
                totalWeight++;
            }else{
                uint256 price = oracleContract.getPrice(address(totalPools[activePools[i]].sToken));
                if(price > 0){
                    totalPools[activePools[i]].price = price;
                }
            }
        }
        for(i = 0; i < length; i++){
            if(totalPools[activePools[i]].lpPool == true){
                uint256 rewardPercent = totalPools[activePools[i]].poolWeight.mul(divisionFactor).div(totalWeight);
                uint256 poolReward = lpRewardLeft.mul(rewardPercent).div(divisionFactor);
                forceUpdateRewardEarned(activePools[i],address(0)); // Update the stored rewards for this pool before changing the rates
                if(timeLeft > 0){
                    totalPools[activePools[i]].rewardRate = poolReward.div(timeLeft); // The rate of return per second for this pool
                }else{
                    totalPools[activePools[i]].rewardRate = 0;
                }               
            }
        }
        
        totalWeight = 0;
        uint256 i2 = 0;
        for(i = 0; i < length; i++){
            if(totalPools[activePools[i]].lpPool == false){
                uint256 amountBelow = 0;
                for(i2 = 0; i2 < length; i2++){
                    if(totalPools[activePools[i2]].lpPool == false){
                        if(i != i2){ // Do not want to check itself
                            if(totalPools[activePools[i]].price <= totalPools[activePools[i2]].price){
                                amountBelow++;
                            }
                        }
                    }
                }
                uint256 weight = (1 + amountBelow) * 100000;
                uint256 diff = 0;
                if(totalPools[activePools[i]].price > targetPrice){
                    diff = totalPools[activePools[i]].price - targetPrice;
                    diff = diff.div(1e14); // Normalize the difference
                    uint256 weightReduction = diff.mul(50); // Weight is reduced for each $0.0001 above target price
                    if(weightReduction >= weight){
                        weight = 1;
                    }else{
                        weight = weight.sub(weightReduction);
                    }
                }else if(totalPools[activePools[i]].price < targetPrice){
                    diff = targetPrice - totalPools[activePools[i]].price;
                    diff = diff.div(1e14); // Normalize the difference
                    uint256 weightGain = diff.mul(50); // Weight is added for each $0.0001 below target price
                    weight = weight.add(weightGain);      
                }
                totalPools[activePools[i]].poolWeight = weight;
                totalWeight = totalWeight.add(weight);
            }
        }
        for(i = 0; i < length; i++){
            if(totalPools[activePools[i]].lpPool == false){
                uint256 rewardPercent = totalPools[activePools[i]].poolWeight.mul(divisionFactor).div(totalWeight);
                uint256 poolReward = sbRewardLeft.mul(rewardPercent).div(divisionFactor);
                forceUpdateRewardEarned(activePools[i],address(0)); // Update the stored rewards for this pool before changing the rates
                if(timeLeft > 0){
                    totalPools[activePools[i]].rewardRate = poolReward.div(timeLeft); // The rate of return per second for this pool
                }else{
                    totalPools[activePools[i]].rewardRate = 0;
                }               
            }
        }
    }
    
    function forceUpdateRewardEarned(uint256 _pid, address _address) internal updateRewardEarned(_pid, _address) {

        
    }
    
    function lastTimeRewardApplicable() public view returns (uint256) {

        return block.timestamp < _periodFinished ? block.timestamp : _periodFinished;
    }
    
    function rewardRate(uint256 _pid) external view returns (uint256) {

        return totalPools[_pid].rewardRate;
    }
    
    function poolSize(uint256 _pid) external view returns (uint256) {

        return totalPools[_pid].totalSupply;
    }
    
    function poolBalance(uint256 _pid, address _address) external view returns (uint256) {

        return userInfo[_pid][_address].amount;
    }
    
    function poolTokenAddress(uint256 _pid) external view returns (address) {

        return address(totalPools[_pid].sToken);
    }

    function rewardPerToken(uint256 _pid) public view returns (uint256) {

        if (totalPools[_pid].totalSupply == 0) {
            return totalPools[_pid].rewardPerTokenStored;
        }
        return
            totalPools[_pid].rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(totalPools[_pid].lastUpdateTime)
                    .mul(totalPools[_pid].rewardRate)
                    .mul(1e18)
                    .div(totalPools[_pid].totalSupply)
            );
    }

    function rewardEarned(uint256 _pid, address account) public view returns (uint256) {

        return
            userInfo[_pid][account].amount
                .mul(rewardPerToken(_pid).sub(userInfo[_pid][account].rewardDebt))
                .div(1e18)
                .add(userInfo[_pid][account].unclaimedReward);
    }

    function deposit(uint256 _pid, uint256 amount) public updateRewardEarned(_pid, _msgSender()) {

        require(amount > 0, "Cannot deposit 0");
        if(_currentWeek > 0){
            require(totalPools[_pid].active == true, "This pool is no longer active");
        }      
        totalPools[_pid].totalSupply = totalPools[_pid].totalSupply.add(amount);
        userInfo[_pid][_msgSender()].amount = userInfo[_pid][_msgSender()].amount.add(amount);
        totalPools[_pid].sToken.safeTransferFrom(_msgSender(), address(this), amount);
        emit Deposited(_pid, _msgSender(), amount);
    }

    function withdraw(uint256 _pid, uint256 amount) public updateRewardEarned(_pid, _msgSender()) {

        require(amount > 0, "Cannot withdraw 0");
        totalPools[_pid].totalSupply = totalPools[_pid].totalSupply.sub(amount);
        userInfo[_pid][_msgSender()].amount = userInfo[_pid][_msgSender()].amount.sub(amount);
        totalPools[_pid].sToken.safeTransfer(_msgSender(), amount);
        emit Withdrawn(_pid, _msgSender(), amount);
    }

    function exit(uint256 _pid, uint256 _amount) external {

        withdraw(_pid, _amount);
        getReward(_pid);
    }

    function pushReward(uint256 _pid, address recipient) external updateRewardEarned(_pid, recipient) onlyOwner {

        uint256 reward = rewardEarned(_pid,recipient);
        if (reward > 0) {
            userInfo[_pid][recipient].unclaimedReward = 0;
            if (!recipient.isContract()) {
                uint256 contractBalance = StabilizeT.balanceOf(address(this));
                if(contractBalance < reward){ // This prevents a contract with zero balance locking up
                    reward = contractBalance;
                }
                StabilizeT.safeTransfer(recipient, reward);
                emit RewardPaid(_pid, recipient, reward);
            } else {
                emit RewardDenied(_pid, recipient, reward);
            }
        }
    }

    function getReward(uint256 _pid) public updateRewardEarned(_pid, _msgSender()) {

        uint256 reward = rewardEarned(_pid,_msgSender());
        if (reward > 0) {
            userInfo[_pid][_msgSender()].unclaimedReward = 0;
            if (tx.origin == _msgSender()) {
                uint256 contractBalance = StabilizeT.balanceOf(address(this));
                if(contractBalance < reward){ // This prevents a contract with zero balance locking up
                    reward = contractBalance;
                }
                StabilizeT.safeTransfer(_msgSender(), reward);
                emit RewardPaid(_pid, _msgSender(), reward);
            } else {
                emit RewardDenied(_pid, _msgSender(), reward);
            }
        }
    }
    
    
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant _timelockDuration = 86400; // Timelock is 24 hours
    
    uint256 private _timelock_data_1;
    address private _timelock_address_1;
    bool private _timelock_bool_1;
    
    modifier timelockConditionsMet(uint256 _type) {

        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(_currentWeek > 0){
            require(now >= _timelockStart + _timelockDuration, "Timelock time not met");
        }
        _;
    }
    
    function bootstrapLiquidty() external onlyOwner {

        require(StabilizeT.totalSupply() == 0, "This token has already been bootstrapped");
        require(StabilizeT.owner() == address(this),"The Operator does not have permission to mint tokens");
        uint256 devAmount = _mintSchedule[0].mul(_rewardPercentDev).div(divisionFactor);
        _mintSchedule[0] = _mintSchedule[0].sub(devAmount); // The first week doesn't give dev team any extra tokens
        StabilizeT.mint(owner(),devAmount); // The Operator will mint tokens to the developer
    }
    
    function startOwnerChange(address _address) external onlyOwner {

        _timelockStart = now;
        _timelockType = 1;
        _timelock_address_1 = _address;       
    }
    
    function finishOwnerChange() external onlyOwner timelockConditionsMet(1) {

        transferOwnership(_timelock_address_1);
    }

    function startChangeEarlyBurnRate(uint256 _percent) external onlyOwner {

        _timelockStart = now;
        _timelockType = 2;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeEarlyBurnRate() external onlyOwner timelockConditionsMet(2) {

        _earlyBurnRate = _timelock_data_1;
    }
    
    function startChangeBurnRateLong(uint256 _percent) external onlyOwner {

        _timelockStart = now;
        _timelockType = 3;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeBurnRateLong() external onlyOwner timelockConditionsMet(3) {

       _burnRateLong  = _timelock_data_1;
       if(_currentWeek >= 53){
           StabilizeT.initiateBurn(_burnRateLong);
       }
    }
    
    function startChangeEmissionRateLong(uint256 _percent) external onlyOwner {

        _timelockStart = now;
        _timelockType = 4;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeEmissionRateLong() external onlyOwner timelockConditionsMet(4) {

        _emissionRateLong =_timelock_data_1;
    }

    function startChangeRewardPercentLP(uint256 _percent) external onlyOwner {

        _timelockStart = now;
        _timelockType = 5;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeRewardPercentLP() external onlyOwner timelockConditionsMet(5) {

        _rewardPercentLP = _timelock_data_1;
    }

    function startChangeTargetPrice(uint256 _price) external onlyOwner {

        _timelockStart = now;
        _timelockType = 6;
        _timelock_data_1 = _price;
    }
    
    function finishChangeTargetPrice() external onlyOwner timelockConditionsMet(6) {

        targetPrice = _timelock_data_1;
    }
    
    function startChangePriceOracle(address _address) external onlyOwner {

        _timelockStart = now;
        _timelockType = 7;
        _timelock_address_1 = _address;
    }
    
    function finishChangePriceOracle() external onlyOwner timelockConditionsMet(7) {

        oracleContract = StabilizePriceOracle(_timelock_address_1);
    }
   
    function startAddNewPool(address _address, bool _lpPool) external onlyOwner {

        _timelockStart = now;
        _timelockType = 8;
        _timelock_address_1 = _address;
        _timelock_bool_1 = _lpPool;
        if(_currentWeek == 0){
            finishAddNewPool(); // Automatically add the pool if protocol hasn't started yet
        }
    }
    
    function finishAddNewPool() public onlyOwner timelockConditionsMet(8) {

        totalPools.push(
            PoolInfo({
                sToken: IERC20(_timelock_address_1),
                poolID: poolLength(),
                lpPool: _timelock_bool_1,
                rewardRate: 0,
                poolWeight: 0,
                price: 0,
                rewardPerTokenStored: 0,
                lastUpdateTime: 0,
                totalSupply: 0,
                active: false
            })
        );
    }
    
    function startAddActivePool(uint256 _pid) external onlyOwner {

        _timelockStart = now;
        _timelockType = 9;
        _timelock_data_1 = _pid;
    }
    
    function finishAddActivePool() external onlyOwner timelockConditionsMet(9) {

        require(totalPools[_timelock_data_1].active == false, "This pool is already active");
        activePools.push(_timelock_data_1);
        totalPools[_timelock_data_1].active = true;
        if(_currentWeek > 0){
            lastOracleTime = now - minOracleRefresh; // Force oracle price to update
            rebalancePoolRewards();
        }
    }
    
    function startRemoveActivePool(uint256 _pid) external onlyOwner {

        _timelockStart = now;
        _timelockType = 10;
        _timelock_data_1 = _pid;
    }
    
    function finishRemoveActivePool() external onlyOwner timelockConditionsMet(10) updateRewardEarned(_timelock_data_1, address(0)) {

        uint256 length = activePools.length;
        for(uint256 i = 0; i < length; i++){
            if(totalPools[activePools[i]].poolID == _timelock_data_1){
                totalPools[activePools[i]].active = false;
                totalPools[activePools[i]].rewardRate = 0; // Deactivate rewards but first make sure to store current rewards
                for(uint256 i2 = i; i2 < length-1; i2++){
                    activePools[i2] = activePools[i2 + 1]; // Shift the data down one
                }
                activePools.pop(); //Remove last element
                break;
            }
        }
        if(_currentWeek > 0){
            lastOracleTime = now - minOracleRefresh; // Force oracle price to update
            rebalancePoolRewards();
        }
    }
}