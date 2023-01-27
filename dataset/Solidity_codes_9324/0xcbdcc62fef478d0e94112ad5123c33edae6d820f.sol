

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64) {

        uint64 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {

        require(b <= a, errorMessage);
        uint64 c = a - b;

        return c;
    }

    function mul(uint64 a, uint64 b) internal pure returns (uint64) {

        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}



pragma solidity 0.5.7;




contract Staking {

    
    using SafeMath for uint256;

    struct InterestData {
        uint256 globalTotalStaked;
        uint256 globalYieldPerToken; 
        uint256 lastUpdated;
        mapping(address => Staker) stakers;  
    }

    struct Staker {
        uint256 totalStaked;
        uint256 withdrawnToDate;
        uint256 stakeBuyinRate;  
    }


    ERC20 private stakeToken;

    ERC20 private rewardToken;

    InterestData public interestData;

    uint public stakingStartTime;

    uint public totalReward;

    address public vaultAddress; 

    uint256 private constant DECIMAL1e18 = 10**18;

    uint256 public stakingPeriod;

    event Staked(address indexed staker, uint256 value, uint256 _globalYieldPerToken);

    event StakeWithdrawn(address indexed staker, uint256 value, uint256 _globalYieldPerToken);


    event InterestCollected(
        address indexed staker,
        uint256 _value,
        uint256 _globalYieldPerToken
    );

    constructor(
        address _stakeToken,
        address _rewardToken,
        uint256 _stakingPeriod,
        uint256 _totalRewardToBeDistributed,
        uint256 _stakingStart,
        address _vaultAdd
    ) public {
        require(_stakingPeriod > 0, "Should be positive");
        require(_totalRewardToBeDistributed > 0, "Total reward can not be 0");
        require(_stakingStart >= now, "Can not be past time");
        require(_stakeToken != address(0), "Can not be null address");
        require(_rewardToken != address(0), "Can not be null address");
        require(_vaultAdd != address(0), "Can not be null address");
        stakeToken = ERC20(_stakeToken);
        rewardToken = ERC20(_rewardToken);
        stakingStartTime = _stakingStart;
        interestData.lastUpdated = _stakingStart;
        stakingPeriod = _stakingPeriod;
        totalReward = _totalRewardToBeDistributed;
        vaultAddress = _vaultAdd;
    }

    function stake(uint256 _amount) external {

        require(_amount > 0, "You need to stake a positive token amount");
        require(
            stakeToken.transferFrom(msg.sender, address(this), _amount),
            "TransferFrom failed, make sure you approved token transfer"
        );
        require(now.sub(stakingStartTime) <= stakingPeriod, "Can not stake after staking period passed");
        uint newlyInterestGenerated = now.sub(interestData.lastUpdated).mul(totalReward).div(stakingPeriod);
        interestData.lastUpdated = now;
        updateGlobalYieldPerToken(newlyInterestGenerated);
        updateStakeData(msg.sender, _amount);
        emit Staked(msg.sender, _amount, interestData.globalYieldPerToken);
    }

    function updateStakeData(
        address _staker,
        uint256 _stake
    ) internal {

        Staker storage _stakerData = interestData.stakers[_staker];

        _stakerData.totalStaked = _stakerData.totalStaked.add(_stake);

        updateStakeBuyinRate(
            _stakerData,
            interestData.globalYieldPerToken,
            _stake
        );

        interestData.globalTotalStaked = interestData.globalTotalStaked.add(_stake);
    }

    function updateStakeBuyinRate(
        Staker storage _stakerData,
        uint256 _globalYieldPerToken,
        uint256 _stake
    ) internal {


        _stakerData.stakeBuyinRate = _stakerData.stakeBuyinRate.add(
            _globalYieldPerToken.mul(_stake).div(DECIMAL1e18)
        );
    }

    function withdrawStakeAndInterest(uint256 _amount) external {

        Staker storage staker = interestData.stakers[msg.sender];
        require(_amount > 0, "Should withdraw positive amount");
        require(staker.totalStaked >= _amount, "Not enough token staked");
        withdrawInterest();
        updateStakeAndInterestData(msg.sender, _amount);
        require(stakeToken.transfer(msg.sender, _amount), "withdraw transfer failed");
        emit StakeWithdrawn(msg.sender, _amount, interestData.globalYieldPerToken);
    }
    
    function updateStakeAndInterestData(
        address _staker,
        uint256 _amount
    ) internal {

        Staker storage _stakerData = interestData.stakers[_staker];

        _stakerData.totalStaked = _stakerData.totalStaked.sub(_amount);

        interestData.globalTotalStaked = interestData.globalTotalStaked.sub(_amount);

        _stakerData.stakeBuyinRate = 0;
        _stakerData.withdrawnToDate = 0;
        updateStakeBuyinRate(
            _stakerData,
            interestData.globalYieldPerToken,
            _stakerData.totalStaked
        );
    }

    function withdrawInterest() public {

        uint timeSinceLastUpdate = _timeSinceLastUpdate();
        uint newlyInterestGenerated = timeSinceLastUpdate.mul(totalReward).div(stakingPeriod);
        
        updateGlobalYieldPerToken(newlyInterestGenerated);
        uint256 interest = calculateInterest(msg.sender);
        Staker storage stakerData = interestData.stakers[msg.sender];
        stakerData.withdrawnToDate = stakerData.withdrawnToDate.add(interest);
        require(rewardToken.transfer(msg.sender, interest), "Withdraw interest transfer failed");
        emit InterestCollected(msg.sender, interest, interestData.globalYieldPerToken);
    }

    function updateGlobalYield() public {

        uint timeSinceLastUpdate = _timeSinceLastUpdate();
        uint newlyInterestGenerated = timeSinceLastUpdate.mul(totalReward).div(stakingPeriod);
        updateGlobalYieldPerToken(newlyInterestGenerated);
    }

    function getYieldData(address _staker) public view returns(uint256, uint256)
    {


      return (interestData.globalYieldPerToken, interestData.stakers[_staker].stakeBuyinRate);
    }

    function _timeSinceLastUpdate() internal returns(uint256) {

        uint timeSinceLastUpdate;
        if(now.sub(stakingStartTime) > stakingPeriod)
        {
            timeSinceLastUpdate = stakingStartTime.add(stakingPeriod).sub(interestData.lastUpdated);
            interestData.lastUpdated = stakingStartTime.add(stakingPeriod);
        } else {
            timeSinceLastUpdate = now.sub(interestData.lastUpdated);
            interestData.lastUpdated = now;
        }
        return timeSinceLastUpdate;
    }

    function calculateInterest(address _staker)
        public
        view
        returns (uint256)
    {

        Staker storage stakerData = interestData.stakers[_staker];

        
        uint256 _withdrawnToDate = stakerData.withdrawnToDate;

        uint256 intermediateInterest = stakerData
            .totalStaked
            .mul(interestData.globalYieldPerToken).div(DECIMAL1e18);

        uint256 intermediateVal = _withdrawnToDate.add(
            stakerData.stakeBuyinRate
        );

        if (intermediateVal > intermediateInterest) {
            return 0;
        }

        uint _earnedInterest = (intermediateInterest.sub(intermediateVal));

        return _earnedInterest;
    }

    function updateGlobalYieldPerToken(
        uint256 _interestGenerated
    ) internal {

        if (interestData.globalTotalStaked == 0) {
            require(rewardToken.transfer(vaultAddress, _interestGenerated), "Transfer failed while trasfering to vault");
            return;
        }
        interestData.globalYieldPerToken = interestData.globalYieldPerToken.add(
            _interestGenerated
                .mul(DECIMAL1e18) 
                .div(interestData.globalTotalStaked) 
        );
    }


    function getStakerData(address _staker) public view returns(uint256, uint256)
    {


      return (interestData.stakers[_staker].totalStaked, interestData.stakers[_staker].withdrawnToDate);
    }

    function getStatsData(address _staker) external view returns(uint, uint, uint, uint, uint)
    {


        Staker storage stakerData = interestData.stakers[_staker];
        uint estimatedReward = 0;
        uint unlockedReward = 0;
        uint accruedReward = 0;
        uint timeElapsed = now.sub(stakingStartTime);

        if(timeElapsed > stakingPeriod)
        {
            timeElapsed = stakingPeriod;
        }

        unlockedReward = timeElapsed.mul(totalReward).div(stakingPeriod);

        uint timeSinceLastUpdate;
        if(timeElapsed == stakingPeriod)
        {
            timeSinceLastUpdate = stakingStartTime.add(stakingPeriod).sub(interestData.lastUpdated);
        } else {
            timeSinceLastUpdate = now.sub(interestData.lastUpdated);
        }
        uint newlyInterestGenerated = timeSinceLastUpdate.mul(totalReward).div(stakingPeriod);
        uint updatedGlobalYield;
        uint stakingTimeLeft = 0;
        if(now < stakingStartTime.add(stakingPeriod)){
         stakingTimeLeft = stakingStartTime.add(stakingPeriod).sub(now);
        }
        uint interestGeneratedEnd = stakingTimeLeft.mul(totalReward).div(stakingPeriod);
        uint globalYieldEnd;
        if (interestData.globalTotalStaked != 0) {
            updatedGlobalYield = interestData.globalYieldPerToken.add(
            newlyInterestGenerated
                .mul(DECIMAL1e18)
                .div(interestData.globalTotalStaked));

            globalYieldEnd = updatedGlobalYield.add(interestGeneratedEnd.mul(DECIMAL1e18).div(interestData.globalTotalStaked));
        }
        
        accruedReward = stakerData
            .totalStaked
            .mul(updatedGlobalYield).div(DECIMAL1e18);

        if (stakerData.withdrawnToDate.add(stakerData.stakeBuyinRate) > accruedReward)
        {
            accruedReward = 0;
        } else {

            accruedReward = accruedReward.sub(stakerData.withdrawnToDate.add(stakerData.stakeBuyinRate));
        }

        estimatedReward = stakerData
            .totalStaked
            .mul(globalYieldEnd).div(DECIMAL1e18);
        if (stakerData.withdrawnToDate.add(stakerData.stakeBuyinRate) > estimatedReward) {
            estimatedReward = 0;
        } else {

            estimatedReward = estimatedReward.sub(stakerData.withdrawnToDate.add(stakerData.stakeBuyinRate));
        }

        return (interestData.globalTotalStaked, totalReward, estimatedReward, unlockedReward, accruedReward);

    }

    function getStakeToken() external view returns (ERC20) {

        return stakeToken;
    }

    function getRewardToken() external view returns (ERC20) {

        return rewardToken;
    }
}