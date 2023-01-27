


pragma solidity 0.6.12;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
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



interface StandardToken {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

}

interface IController {

    function withdrawETH(uint256 amount) external;

    function depositForStrategy(uint256 amount, address addr) external;

    function buyForStrategy(
        uint256 amount,
        address rewardToken,
        address recipient
    ) external;


    function sendExitToken(
        address user,
        uint256 amount
    ) external;


    function getStrategy(address vault) external view returns (address);

}

interface IStrategy {

    function getNextEpochTime() external view returns(uint256);

}

interface StakeAndYieldV1 {

    function users(address user) external view returns (
        uint256 balance,
        uint256 stakeType,
        uint256 paidReward,
        uint256 yieldPaidReward,
        uint256 paidRewardPerToken,
        uint256 yieldPaidRewardPerToken,
        uint256 withdrawable,
        uint256 withdrawableExit,
        uint256 withdrawTime,
        bool exit,
        uint256 exitStartTime,
        uint256 exitAmountTillNow,
        uint256 lastClaimTime
    );


    function userInfo(address account) external view returns(
        uint256[15] memory numbers,

        address rewardTokenAddress,
        address stakedTokenAddress,
        address controllerAddress,
        address strategyAddress,
        bool exit
    );

}

contract StakeAndYieldV2 is Ownable {

    uint256 constant STAKE = 1;
    uint256 constant YIELD = 2;
    uint256 constant BOTH = 3;

    uint256 public PERIOD = 7 days;

    uint256 public EPOCH_PERIOD = 24 hours;

    uint256 public EXIT_PERIOD = 75 days;

    uint256 public lastUpdateTime;
    uint256 public rewardRate;
    uint256 public rewardRateYield;

    uint256 public rewardTillNowPerToken = 0;
    uint256 public yieldRewardTillNowPerToken = 522980160138;

    uint256 public _totalSupply = 487606203595522605888605 ;
    uint256 public _totalSupplyYield = 475335208376198031867650 ;

    uint256 public _totalYieldWithdrawed = 14715976256875355924591 ;
    uint256 public _totalExit = 0;

    bool public allowEmergencyWithdraw = false;

    uint256 public exitRewardDenominator = 2;

    IController public controller;

    address public operator;

    struct User {
        uint256 balance;
        uint256 stakeType;

        uint256 paidReward;
        uint256 yieldPaidReward;

        uint256 paidRewardPerToken;
        uint256 yieldPaidRewardPerToken;

        uint256 withdrawable;
        uint256 withdrawableExit;
        uint256 withdrawTime;

        bool exit;

        uint256 exitStartTime;
        uint256 exitAmountTillNow;

        uint256 lastClaimTime;
    }

    mapping (address => uint256) pendingEarneds;
    mapping (address => uint256) pendingEarnedYields;

    using SafeMath for uint256;

    mapping (address => User) public users;

    uint256 public lastUpdatedBlock;

    uint256 public periodFinish;

    uint256 public birthDate;

    uint256 public daoShare;
    address public daoWallet;

    bool public exitable;

    StandardToken public stakedToken;
    StandardToken public rewardToken;
    StandardToken public yieldRewardToken;

    address public oldContract;

    uint256 public totalExitRewards;
    uint256 public totalExitRewardsYield;

    event Deposit(address user, uint256 amount, uint256 stakeType);
    event Withdraw(address user, uint256 amount, uint256 stakeType);
    event Exit(address user, uint256 amount, uint256 stakeType);
    event Unfreeze(address user, uint256 amount, uint256 stakeType);
    event EmergencyWithdraw(address user, uint256 amount);
    event RewardClaimed(address user, uint256 amount, uint256 yieldAmount);


    constructor (
		address _stakedToken,
		address _rewardToken,
        address _yieldRewardToken,
		uint256 _daoShare,
		address _daoWallet,
        address _controller,
        bool _exitable,
        address _oldContract
    ) public {
        stakedToken = StandardToken(_stakedToken);
        rewardToken = StandardToken(_rewardToken);
        yieldRewardToken = StandardToken(_yieldRewardToken);
        controller = IController(_controller);
        daoShare = _daoShare;
        daoWallet = _daoWallet;
        exitable = _exitable;

        operator = msg.sender;
        oldContract = _oldContract;
        birthDate = now;
    }

    modifier onlyOwnerOrController(){

        require(msg.sender == owner() ||
            msg.sender == address(controller) ||
            msg.sender == operator,
            "!ownerOrController"
        );
        _;
    }

    modifier importUser(address account){

        if(oldContract != address(0)){
            if(users[account].stakeType==0){
                uint256 oldStakeType;
                bool oldExit;
                uint256[] memory ints = new uint256[](3);
                (
                    ,
                    oldStakeType,
                    ,,,,,,ints[2],oldExit,ints[0],,ints[1]
                ) = StakeAndYieldV1(oldContract).users(account);
                if(oldStakeType > 0){
                    require(ints[1] <= birthDate, "lastClaimTime > birthDate");
                    users[account].exit = oldExit;
                    users[account].exitStartTime = ints[0];
                    users[account].lastClaimTime = ints[1];
                    users[account].withdrawTime = ints[2];
                    loadOldUser(account);
                }
            }
        }
        _;
    }

    modifier updateReward(address account, uint256 stakeType) {

        
        if(users[account].balance > 0 || users[account].withdrawable > 0
            || users[account].withdrawableExit > 0
        ){
            stakeType = users[account].stakeType;
        }
        
        if (account != address(0)) {
            uint256 stakeEarned;
            uint256 stakeSubtract;

            (stakeEarned, stakeSubtract) = earned(account, STAKE);

            uint256 yieldEarned;
            uint256 yieldSubtract;

            (yieldEarned, yieldSubtract) = earned(account, YIELD);


            if(yieldEarned > 0){
                pendingEarnedYields[account] = yieldEarned;
                totalExitRewardsYield += yieldSubtract;
            }
            if(stakeEarned > 0){
                pendingEarneds[account] = stakeEarned;
                totalExitRewards += stakeSubtract;
            }
        }
        
        rewardTillNowPerToken = rewardPerToken(STAKE);
        yieldRewardTillNowPerToken = rewardPerToken(YIELD);
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            users[account].paidRewardPerToken = rewardTillNowPerToken;
            users[account].yieldPaidRewardPerToken = yieldRewardTillNowPerToken;
        }
        _;
    }

    function loadOldUser(address account) private{

            (
                users[account].balance,
                users[account].stakeType,
                , //paidReward,
                users[account].yieldPaidReward,
                ,//paidRewardPerToken,
                users[account].yieldPaidRewardPerToken,
                users[account].withdrawable,
                ,//withdrawableExit,
                ,//withdrawTime,
                ,//exit,
                ,//exitStartTime,
                ,//exitAmountTillNow,
            ) = StakeAndYieldV1(oldContract).users(account);
    }

    function setDaoWallet(address _daoWallet) public onlyOwner {

        daoWallet = _daoWallet;
    }

    function setDaoShare(uint256 _daoShare) public onlyOwner {

        daoShare = _daoShare;
    }

    function setExitPeriod(uint256 period) public onlyOwner {

        EXIT_PERIOD = period;
    }

    function setOperator(address _addr) public onlyOwner{

        operator = _addr;
    }

    function setPeriods(uint256 period, uint256 epochPeriod, uint256 _birthDate) public onlyOwner{

        PERIOD = period;
        EPOCH_PERIOD = epochPeriod;
        birthDate = _birthDate;
    }

    function setRewardInfo(
        uint256 _lastUpdateTime,
        uint256 _rewardRate,
        uint256 _rewardRateYield,

        uint256 _rewardTillNowPerToken,
        uint256 _yieldRewardTillNowPerToken
    ) public onlyOwner{

        lastUpdateTime = _lastUpdateTime;
        rewardRate = _rewardRate;
        rewardRateYield = _rewardRateYield;

        rewardTillNowPerToken = _rewardTillNowPerToken;
        yieldRewardTillNowPerToken = _yieldRewardTillNowPerToken;
    }

    function withdrawToBurn() public onlyOwner{

        stakedToken.transfer(
            msg.sender,
            _totalExit
        );
        _totalExit = 0;
    }

    function earned(address account, uint256 stakeType) public view returns(uint256, uint256) {

        User storage user = users[account];

        uint256 paidPerToken = stakeType == STAKE ? 
            user.paidRewardPerToken : user.yieldPaidRewardPerToken;

        uint256 amount = balanceOf(account, stakeType).mul(
            rewardPerToken(stakeType).
            sub(paidPerToken)
        ).div(1e18);

        uint256 substract = 0;
        if(user.exit){
            uint256 startDate = user.exitStartTime;
            if(user.lastClaimTime > startDate){
                startDate = user.lastClaimTime;
            }
            uint256 daysIn = (block.timestamp - startDate) / 1 days;
            uint256 exitPeriodDays = EXIT_PERIOD/1 days;
            if(daysIn > exitPeriodDays){
                daysIn = exitPeriodDays;
            }
            substract = daysIn.mul(amount).div(exitPeriodDays).div(
                exitRewardDenominator
            );
        }
        uint256 pending = stakeType == STAKE ? 
            pendingEarneds[account] : pendingEarnedYields[account];
        return (amount.sub(substract) + pending, substract);
    }

    function earned(address account) public view returns(uint256){

        uint256 stakeEarned;
        uint256 yieldEarned;
        uint256 tmp;
        (stakeEarned, tmp) = earned(account, STAKE);
        (yieldEarned, tmp) = earned(account, YIELD);

        return stakeEarned + yieldEarned;
    }

	function deposit(uint256 amount, uint256 stakeType, bool _exit) public {

		depositFor(msg.sender, amount, stakeType, _exit);
    }

    function depositFor(address _user, uint256 amount, uint256 stakeType, bool _exit)
        

        updateReward(_user, stakeType)
        public {

        
        require(stakeType==STAKE || stakeType ==YIELD || stakeType==BOTH, "Invalid stakeType");
 
        User storage user = users[_user];
        require((user.balance == 0 && user.withdrawable==0 && user.withdrawableExit == 0)|| user.stakeType==stakeType, "Invalid Stake Type");

        if(user.exit || (user.balance == 0 && _exit)){
            updateExit(_user);
        }else if(user.balance == 0 && !_exit){
            user.exit = false;
        }

        stakedToken.transferFrom(address(msg.sender), address(this), amount);

        user.stakeType = stakeType;
        user.balance = user.balance.add(amount);

        if(stakeType == STAKE){
            _totalSupply = _totalSupply.add(amount);
        }else if(stakeType == YIELD){
            _totalSupplyYield = _totalSupplyYield.add(amount);
        }else{
            _totalSupplyYield = _totalSupplyYield.add(amount);
            _totalSupply = _totalSupply.add(amount);
        }
        
        emit Deposit(_user, amount, stakeType);
    }

    function updateExit(address _user) private{

        require(exitable, "Not exitable");
        User storage user = users[_user];
        user.exit = true;
        user.exitAmountTillNow = exitBalance(_user);
        user.exitStartTime = block.timestamp;
    }

	function sendReward(address userAddress, 
        uint256 stakeEarned, uint256 stakeSubtract, 
        uint256 yieldEarned, uint256 yieldSubtract
    ) private {

        User storage user = users[userAddress];
		uint256 _daoShare = stakeEarned.mul(daoShare).div(1 ether);
        uint256 _yieldDaoShare = yieldEarned.mul(daoShare).div(1 ether);

        if(stakeEarned > 0){
            rewardToken.transfer(userAddress, stakeEarned.sub(_daoShare));
            if(_daoShare > 0)
                rewardToken.transfer(daoWallet, _daoShare);
            user.paidReward = user.paidReward.add(
                stakeEarned
            );
        }

        if(yieldEarned > 0){
            yieldRewardToken.transfer(userAddress, yieldEarned.sub(_yieldDaoShare));
            
            if(_yieldDaoShare > 0)
                yieldRewardToken.transfer(daoWallet, _yieldDaoShare);   
            
            user.yieldPaidReward = user.yieldPaidReward.add(
                yieldEarned
            );
        }
        
        if(yieldEarned > 0 || stakeEarned > 0){
            emit RewardClaimed(userAddress, stakeEarned, yieldEarned);
        }

        if(stakeSubtract > 0){
            totalExitRewards += stakeSubtract;
        }
        if(yieldSubtract > 0){
            totalExitRewardsYield += yieldSubtract;
        }
        user.lastClaimTime = block.timestamp;
        pendingEarneds[userAddress] = 0;
        pendingEarnedYields[userAddress] = 0;
	}

    function sendExitToken(address _user, uint256 amount) private {

        controller.sendExitToken(
            _user,
            amount
        );
    }

    function claim() 
        updateReward(msg.sender, 0) public {

        
        claimInternal();
    }

    function claimInternal() private{

        uint256 stakeEarned;
        uint256 stakeSubtract;

        (stakeEarned, stakeSubtract) = earned(msg.sender, STAKE);

        uint256 yieldEarned;
        uint256 yieldSubtract;

        (yieldEarned, yieldSubtract) = earned(msg.sender, YIELD);

        sendReward(
            msg.sender,
            stakeEarned, stakeSubtract,
            yieldEarned, yieldSubtract
        );
    }

    function setExit(bool _val) 
        updateReward(msg.sender, 0) public{

        
        User storage user = users[msg.sender];
        require(user.exit != _val, "same exit status");
        require(user.balance > 0, "0 balance");

        user.exit = _val;
        user.exitStartTime = now;
        user.exitAmountTillNow = 0;
    }

    function unfreezeAllAndClaim() public{

        unfreeze(users[msg.sender].balance);
        claimInternal();
    }

    function unfreeze(uint256 amount) 
        updateReward(msg.sender, 0) public {

        User storage user = users[msg.sender];
        uint256 stakeType = user.stakeType;

        require(
            user.balance >= amount,
            "withdraw > deposit");

        if (amount > 0) {
            uint256 exitAmount = exitBalance(msg.sender);
            uint256 remainingExit = 0;
            if(exitAmount > amount){
                remainingExit = exitAmount.sub(amount);
                exitAmount = amount;
            }

            if(user.exit){
                user.exitAmountTillNow = remainingExit;
                user.exitStartTime = now;
            }

            uint256 tokenAmount = amount.sub(exitAmount);
            user.balance = user.balance.sub(amount);
            if(stakeType == STAKE){
                _totalSupply = _totalSupply.sub(amount);
            }else if (stakeType == YIELD){
                _totalSupplyYield = _totalSupplyYield.sub(amount);
            }else{
                _totalSupply = _totalSupply.sub(amount);
                _totalSupplyYield = _totalSupplyYield.sub(amount);
            }

            if(allowEmergencyWithdraw || stakeType==STAKE){
                if(tokenAmount > 0){
                    stakedToken.transfer(address(msg.sender), tokenAmount);
                    emit Withdraw(msg.sender, tokenAmount, stakeType);
                }
                if(exitAmount > 0){
                    sendExitToken(msg.sender, exitAmount);
                    emit Exit(msg.sender, exitAmount, stakeType);
                }
            }else{
                user.withdrawable += tokenAmount;
                user.withdrawableExit += exitAmount;

                user.withdrawTime = now;

                _totalYieldWithdrawed += amount;
                emit Unfreeze(msg.sender, amount, stakeType);
            }
            _totalExit += exitAmount;
        }
    }

    function withdrawUnfreezed() 
        public{

        User storage user = users[msg.sender];
        require(user.withdrawable > 0 || user.withdrawableExit > 0, 
            "amount is 0");
        
        uint256 nextEpochTime = IStrategy(
            controller.getStrategy(address(this))
        ).getNextEpochTime();

        require(nextEpochTime.sub(PERIOD).sub(EPOCH_PERIOD) >=  user.withdrawTime ||
            allowEmergencyWithdraw, "not withdrawable yet");

        if(user.withdrawable > 0){
            stakedToken.transfer(address(msg.sender), user.withdrawable);
            emit Withdraw(msg.sender, user.withdrawable, YIELD);
            user.withdrawable = 0;
        }

        if(user.withdrawableExit > 0){
            sendExitToken(msg.sender, user.withdrawableExit);
            emit Exit(msg.sender, user.withdrawableExit, YIELD);
            user.withdrawableExit = 0;    
        }
    }

    function notifyRewardAmount(uint256 reward, uint256 stakeType) public onlyOwnerOrController{

        notifyRewardAmountInternal(reward, stakeType);
    }

    function notifyRewardAmountInternal(uint256 reward, uint256 stakeType) private  updateReward(address(0), stakeType){

        if (block.timestamp >= periodFinish) {
            if(stakeType == STAKE){
                rewardRate = reward.div(PERIOD);    
            }else{
                rewardRateYield = reward.div(PERIOD);
            }
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            if(stakeType == STAKE){
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(PERIOD);    
            }else{
                uint256 leftover = remaining.mul(rewardRateYield);
                rewardRateYield = reward.add(leftover).div(PERIOD);
            }
            
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(PERIOD);
    }

    function balanceOf(address account, uint256 stakeType) public view returns(uint256) {

        User storage user = users[account];
        if(user.stakeType == BOTH || user.stakeType==stakeType)
            return user.balance;
        return 0;
    }

    function exitBalance(address account) public view returns(uint256){

        User storage user = users[account];
        if(!user.exit || user.balance==0){
            return 0;
        }
        uint256 portion = (block.timestamp - user.exitStartTime).mul(1 ether).div(EXIT_PERIOD);
        portion = portion >= 1 ether ? 1 ether : portion;

        uint256 notExitedBalance = user.balance.sub(user.exitAmountTillNow);
        
        uint256 balance = user.exitAmountTillNow.add(notExitedBalance.mul(portion).div(1 ether));
        return balance > user.balance ? user.balance : balance;
    }

    function totalYieldWithdrawed() public view returns(uint256) {

        return _totalYieldWithdrawed;
    }

    function totalExit() public view returns(uint256) {

        return _totalExit;
    }

    function totalSupply(uint256 stakeType) public view returns(uint256) {

        return stakeType == STAKE ? _totalSupply : _totalSupplyYield;
    }

    function lastTimeRewardApplicable() public view returns(uint256) {

        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken(uint256 stakeType) public view returns(uint256) {

        uint256 supply = stakeType == STAKE ? _totalSupply : _totalSupplyYield;        
        if (supply == 0) {
            return stakeType == STAKE ? rewardTillNowPerToken : yieldRewardTillNowPerToken;
        }
        if(stakeType == STAKE){
            return rewardTillNowPerToken.add(
                lastTimeRewardApplicable().sub(lastUpdateTime)
                .mul(rewardRate).mul(1e18).div(_totalSupply)
            );
        }else{
            return yieldRewardTillNowPerToken.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).
                mul(rewardRateYield).mul(1e18).div(_totalSupplyYield)
            );
        }
    }

    function getRewardToken() public view returns(address){

        return address(rewardToken);
    }

    function userInfo(address account) public view returns(
        uint256[15] memory numbers,

        address rewardTokenAddress,
        address stakedTokenAddress,
        address controllerAddress,
        address strategyAddress,
        bool exit
    ){

        User storage user = users[account];
        numbers[0] = user.balance;
        numbers[1] = user.stakeType;
        numbers[2] = user.withdrawTime;
        numbers[3] = user.withdrawable;
        numbers[4] = _totalSupply;
        numbers[5] = _totalSupplyYield;
        numbers[6] = stakedToken.balanceOf(address(this));
        
        numbers[7] = rewardPerToken(STAKE);
        numbers[8] = rewardPerToken(YIELD);
        
        numbers[9] = earned(account);

        numbers[10] = user.exitStartTime;
        numbers[11] = exitBalance(account);

        numbers[12] = user.withdrawable;
        numbers[13] = user.withdrawableExit;

        rewardTokenAddress = address(rewardToken);
        stakedTokenAddress = address(stakedToken);
        controllerAddress = address(controller);

        exit = user.exit;

        strategyAddress = controller.getStrategy(address(this));
        numbers[14] = IStrategy(
            controller.getStrategy(address(this))
        ).getNextEpochTime();
    }

    function setController(address _controller) public onlyOwner{

        if(_controller != address(0)){
            controller = IController(_controller);
        }
    }

	function emergencyWithdrawFor(address _user) public onlyOwner{

        User storage user = users[_user];

        uint256 amount = user.balance;

        stakedToken.transfer(_user, amount);

        emit EmergencyWithdraw(_user, amount);

        user.balance = 0;
        user.paidReward = 0;
        user.yieldPaidReward = 0;
    }

    function setAllowEmergencyWithdraw(bool _val) public onlyOwner{

        allowEmergencyWithdraw = _val;
    }

    function setExitable(bool _val) public onlyOwner{

        exitable = _val;
    }

    function setExitRewardDenominator(uint256 _val) public onlyOwner{

        exitRewardDenominator = _val;
    }

    function emergencyWithdrawETH(uint256 amount, address addr) public onlyOwner{

        require(addr != address(0));
        payable(addr).transfer(amount);
    }

    function emergencyWithdrawERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {

        StandardToken(_tokenAddr).transfer(_to, _amount);
    }
}


