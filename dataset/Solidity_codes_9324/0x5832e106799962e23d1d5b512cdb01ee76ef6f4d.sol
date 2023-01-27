

pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.6.2 <0.8.0;

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


pragma solidity >=0.6.0 <0.8.0;




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



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity >=0.6.0 <0.8.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


pragma solidity 0.7.6;




contract ENERGY is ERC20Burnable {
  using SafeMath for uint256;

  uint256 public constant initialSupply = 89099136 * 10 ** 3;
  uint256 public lastWeekTime;
  uint256 public weekCount;
  uint256 public constant totalWeeks = 100;
  address public stakingContrAddr;
  address public liquidityContrAddr;
  uint256 public constant timeStep = 1 weeks;
  
  modifier onlyStaking() {
    require(_msgSender() == stakingContrAddr, "Not staking contract");
    _;
  }

  constructor (address _liquidityContrAddr) ERC20("ENERGY", "NRGY") {
    _setupDecimals(6);
    lastWeekTime = block.timestamp;
    liquidityContrAddr = _liquidityContrAddr;
    _mint(_msgSender(), initialSupply.mul(4).div(10)); //40%
    _mint(liquidityContrAddr, initialSupply.mul(6).div(10)); //60%
  }

  function mintNewCoins(uint256[3] memory lastWeekRewards) public onlyStaking returns(bool) {
    if(weekCount >= 1) {
        uint256 newMint = lastWeekRewards[0].add(lastWeekRewards[1]).add(lastWeekRewards[2]);
        uint256 liquidityMint = (newMint.mul(20)).div(100);
        _mint(liquidityContrAddr, liquidityMint);
        _mint(stakingContrAddr, newMint);
    } else {
        _mint(liquidityContrAddr, initialSupply);
    }
    return true;
  }

  function updateWeek() public onlyStaking {
    weekCount++;
    lastWeekTime = block.timestamp;
  }

  function updateStakingContract(address _stakingContrAddr) public {
    require(stakingContrAddr == address(0), "Staking contract is already set");
    stakingContrAddr = _stakingContrAddr;
  }

  function burnOnUnstake(address account, uint256 amount) public onlyStaking {
      _burn(account, amount);
  }

  function getLastWeekUpdateTime() public view returns(uint256) {
    return lastWeekTime;
  }

  function isMintingCompleted() public view returns(bool) {
    if(weekCount > totalWeeks) {
      return true;
    } else {
      return false;
    }
  }

  function isGreaterThanAWeek() public view returns(bool) {
    if(block.timestamp > getLastWeekUpdateTime().add(timeStep)) {
      return true;
    } else {
      return false;
    }
  }
}


pragma solidity 0.7.6;



contract NRGYMarketMaker  {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    struct UserData {
        address user;
        bool isActive;
        uint256 rewards;
        uint256 feeRewards;
        uint256 depositTime;
        uint256 share;
        uint256 startedWeek;
        uint256 endedWeek;
        mapping(uint256 => uint256) shareByWeekNo;
    }
    
    struct FeeRewardData {
        uint256 value;
        uint256 timeStamp;
        uint256 totalStakersAtThatTime;
        uint256 weekGiven;
        mapping(address => bool) isClaimed;
    }

    ENERGY public energy;
    IERC20 public lpToken;
    uint256 public totalShares;
    uint256[] public stakingLimit;
    uint256 public constant minStakeForFeeRewards = 25 * 10 ** 6;
    uint256 public totalRewards;
    uint256 public totalFeeRewards;
    uint256 public rewardsAvailableInContract;
    uint256 public feeRewardsAvailableInContract;
    uint256 public feeRewardsCount;
    uint256 public totalStakeUsers;
    uint256 public constant percentageDivider = 100;
    uint256[3] private rewardPercentages = [10, 30, 60];
    uint256 public constant unstakeFees = 75;
    uint256 public totalWeeks;
    
    mapping(uint256 => address) public userList;
    mapping(address => UserData) public userInfo;
    mapping (address => bool) public smartContractStakers;
    
    mapping(uint256 => uint256) private stakePerWeek;
    mapping(uint256 => uint256) private totalSharesByWeek;
    mapping(uint256 => uint256[3]) private rewardByWeek;
    mapping(uint256 => FeeRewardData) private feeRewardData;

    event Staked(address indexed _user, uint256 _amountStaked, uint256 _balanceOf);
    event Withdrawn(address indexed _user,
                    uint256 _amountTransferred,
                    uint256 _amountUnstaked,
                    uint256 _shareDeducted,
                    uint256 _rewardsDeducted,
                    uint256 _feeRewardsDeducted);
    event RewardDistributed(uint256 _weekNo, uint256[3] _lastWeekRewards);
    event FeeRewardDistributed(uint256 _amount, uint256 _totalFeeRewards);

    constructor(address _energy) {
        energy = ENERGY(_energy);
        lpToken = IERC20(_energy);
        totalWeeks = energy.totalWeeks();
        stakingLimit.push(27000 * 10 ** 6);
    }

    function stake(uint256 amount) public {
        _stake(amount, tx.origin);
    }
    
    function stakeOnBehalf(uint256 amount, address _who) public {
        _stake(amount, _who);
    }

    function _stake(uint256 _amount, address _who) internal {
        uint256 _weekCount = energy.weekCount();
        bool isWeekOver = energy.isGreaterThanAWeek();

        if((_weekCount >= 1 && !isWeekOver) || _weekCount == 0) {
            require(!isStakingLimitReached(_amount, _weekCount), "Stake limit has been reached");
        }

        if(!isWeekOver || _weekCount == 0) {
            stakePerWeek[_weekCount] = getStakeByWeekNo(_weekCount).add(_amount);
            totalSharesByWeek[_weekCount] = totalShares.add(_amount);
            userInfo[_who].shareByWeekNo[_weekCount] = getUserShareByWeekNo(_who, _weekCount).add(_amount);

            if(_weekCount == 0) {
                if(stakingLimit[0] == totalShares.add(_amount)) {
                    setStakingLimit(_weekCount, stakingLimit[0]);
                    energy.mintNewCoins(getRewardsByWeekNo(0));
                    energy.updateWeek();
                }
            }
        } else/*is week is greater than 1 and is over */ {
            userInfo[_who].shareByWeekNo[_weekCount.add(1)] = getUserShareByWeekNo(_who, _weekCount).add(_amount);
            stakePerWeek[_weekCount.add(1)] = getStakeByWeekNo(_weekCount.add(1)).add(_amount);
            totalSharesByWeek[_weekCount.add(1)] = totalShares.add(_amount);
            setStakingLimit(_weekCount, totalShares);
            energy.updateWeek();
            if(_weekCount <= totalWeeks.add(3)) {
                setRewards(_weekCount);
                uint256 rewardDistributed = (rewardByWeek[_weekCount][0])
                                .add(rewardByWeek[_weekCount][1])
                                .add(rewardByWeek[_weekCount][2]);
                totalRewards = totalRewards.add(rewardDistributed);
                energy.mintNewCoins(getRewardsByWeekNo(_weekCount));
                rewardsAvailableInContract = rewardsAvailableInContract.add(rewardDistributed);
                emit RewardDistributed(_weekCount, getRewardsByWeekNo(_weekCount));
            }
        }
        
        if(!getUserStatus(_who)) {
            userInfo[_who].isActive = true;
            if(getUserShare(_who) < minStakeForFeeRewards) {
                userInfo[_who].startedWeek = _weekCount;
                userInfo[_who].depositTime = block.timestamp;
            }
        }
        
        if(!isUserPreviouslyStaked(_who)) {
            userList[totalStakeUsers] = _who;
            totalStakeUsers++;
            smartContractStakers[_who] = true;
            userInfo[_who].user = _who;
        }
        
        userInfo[_who].share = userInfo[_who].share.add(_amount);
        totalShares = totalShares.add(_amount);
        
        if(msg.sender == tx.origin) {
            lpToken.safeTransferFrom(_who, address(this), _amount);
        } else /*through liquity contract */ {
            lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        }
        emit Staked(_who, _amount, claimedBalanceOf(_who));
    }
    
    function setStakingLimit(uint256 _weekCount, uint256 _share) internal {
        uint256 lastWeekStakingLeft = stakingLimit[_weekCount].sub(getStakeByWeekNo(_weekCount));
        if(_weekCount <= 3) {
            stakingLimit.push((_share.mul(32)).div(percentageDivider));
        }
        if(_weekCount > 3) {
            stakingLimit.push((_share.mul(4)).div(percentageDivider));
        }
        stakingLimit[_weekCount.add(1)] = stakingLimit[_weekCount.add(1)].add(lastWeekStakingLeft);
    }
    
    function setRewards(uint256 _weekCount) internal {
        (rewardByWeek[_weekCount][0],
        rewardByWeek[_weekCount][1],
        rewardByWeek[_weekCount][2]) = calculateRewardsByWeekCount(_weekCount);
    }
    
    function calculateRewards() public view returns(uint256 _lastWeekReward, uint256 _secondLastWeekReward, uint256 _thirdLastWeekReward) {
        return calculateRewardsByWeekCount(energy.weekCount());
    }
    
    function calculateRewardsByWeekCount(uint256 _weekCount) public view returns(uint256 _lastWeekReward, uint256 _secondLastWeekReward, uint256 _thirdLastWeekReward) {
        bool isLastWeek = (_weekCount >= totalWeeks);
        if(isLastWeek) {
            if(_weekCount.sub(totalWeeks) == 0) {
                _lastWeekReward = (getStakeByWeekNo(_weekCount).mul(rewardPercentages[0])).div(percentageDivider);
                _secondLastWeekReward = (getStakeByWeekNo(_weekCount.sub(1)).mul(rewardPercentages[1])).div(percentageDivider);
                _thirdLastWeekReward = (getStakeByWeekNo(_weekCount.sub(2)).mul(rewardPercentages[2])).div(percentageDivider);
            } else if(_weekCount.sub(totalWeeks) == 1) {
                _secondLastWeekReward = (getStakeByWeekNo(_weekCount.sub(1)).mul(rewardPercentages[1])).div(percentageDivider);
                _thirdLastWeekReward = (getStakeByWeekNo(_weekCount.sub(2)).mul(rewardPercentages[2])).div(percentageDivider);
            } else if(_weekCount.sub(totalWeeks) == 2) {
                _thirdLastWeekReward = (getStakeByWeekNo(_weekCount.sub(2)).mul(rewardPercentages[2])).div(percentageDivider);
            }
        } else {
            if(_weekCount == 1) {
                _lastWeekReward = (getStakeByWeekNo(_weekCount).mul(rewardPercentages[0])).div(percentageDivider);
            } else if(_weekCount == 2) {
                _lastWeekReward = (getStakeByWeekNo(_weekCount).mul(rewardPercentages[0])).div(percentageDivider);
                _secondLastWeekReward = (getStakeByWeekNo(_weekCount.sub(1)).mul(rewardPercentages[1])).div(percentageDivider);
            } else if(_weekCount >= 3) {
                _lastWeekReward = (getStakeByWeekNo(_weekCount).mul(rewardPercentages[0])).div(percentageDivider);
                _secondLastWeekReward = (getStakeByWeekNo(_weekCount.sub(1)).mul(rewardPercentages[1])).div(percentageDivider);
                _thirdLastWeekReward = (getStakeByWeekNo(_weekCount.sub(2)).mul(rewardPercentages[2])).div(percentageDivider);
            }
        }
    }
    function isStakingLimitReached(uint256 _amount, uint256 _weekCount) public view returns(bool) {
        return (getStakeByWeekNo(_weekCount).add(_amount) > stakingLimit[_weekCount]);
    }

    function remainingStakingLimit(uint256 _weekCount) public view returns(uint256) {
        return (stakingLimit[_weekCount].sub(getStakeByWeekNo(_weekCount)));
    }

    function distributeFees(uint256 _amount) public {
        uint256 _weekCount = energy.weekCount();
        FeeRewardData storage _feeRewardData = feeRewardData[feeRewardsCount];
        _feeRewardData.value = _amount;
        _feeRewardData.timeStamp = block.timestamp;
        _feeRewardData.totalStakersAtThatTime = totalStakeUsers;
        _feeRewardData.weekGiven = _weekCount;
        feeRewardsCount++;
        totalFeeRewards = totalFeeRewards.add(_amount);
        feeRewardsAvailableInContract = feeRewardsAvailableInContract.add(_amount);
        lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit FeeRewardDistributed(_amount, totalFeeRewards);
    }

    function unstake(uint256 _amount) public {
        UserData storage _user = userInfo[msg.sender];
        uint256 _weekCount = energy.weekCount();
        userInfo[msg.sender].rewards = _user.rewards
                                        .add(getUserRewardsByWeekNo(msg.sender, _weekCount));
        userInfo[msg.sender].feeRewards = _user.feeRewards.add(_calculateFeeRewards(msg.sender));
        require(_amount <= claimedBalanceOf(msg.sender), "Unstake amount is greater than user balance");
        uint256 _fees = (_amount.mul(unstakeFees)).div(1000);
        uint256 _toTransfer = _amount.sub(_fees);
        energy.burnOnUnstake(address(this), _fees);
        lpToken.safeTransfer(msg.sender, _toTransfer);
        if(_amount <= getUserTotalRewards(msg.sender)) {
            if(_user.rewards >= _amount) {
                _user.rewards = _user.rewards.sub(_amount);
                rewardsAvailableInContract = rewardsAvailableInContract.sub(_amount);
                emit Withdrawn(msg.sender, _toTransfer, _amount, 0, _amount, 0);
            } else/*else take sum of fee rewards and rewards */ {
                uint256 remAmount = _amount.sub(_user.rewards);
                rewardsAvailableInContract = rewardsAvailableInContract.sub(_user.rewards);
                feeRewardsAvailableInContract = feeRewardsAvailableInContract.sub(remAmount);
                emit Withdrawn(msg.sender, _toTransfer, _amount, 0, _user.rewards, remAmount);
                _user.rewards = 0;
                _user.feeRewards = _user.feeRewards.sub(remAmount);
            }
        } else/* take from total shares*/ {
            uint256 remAmount = _amount.sub(getUserTotalRewards(msg.sender));
            rewardsAvailableInContract = rewardsAvailableInContract.sub(_user.rewards);
            feeRewardsAvailableInContract = feeRewardsAvailableInContract.sub(_user.feeRewards);
            emit Withdrawn(msg.sender, _toTransfer, _amount, remAmount, _user.rewards, _user.feeRewards);
            _user.rewards = 0;
            _user.feeRewards = 0;
            _user.share = _user.share.sub(remAmount);
            totalShares = totalShares.sub(remAmount);
            totalSharesByWeek[_weekCount] = totalSharesByWeek[_weekCount].sub(remAmount);
        }
        lpToken.safeApprove(address(this), 0);
        _user.isActive = false;
        _user.endedWeek = _weekCount == 0 ? _weekCount : _weekCount.sub(1);
    }
    
    function _calculateFeeRewards(address _who) internal returns(uint256) {
        uint256 _accumulatedRewards;
        if(getUserShare(_who) >= minStakeForFeeRewards) {
            for(uint256 i = 0; i < feeRewardsCount; i++) {
                if(getUserStartedWeek(_who) <= feeRewardData[i].weekGiven
                    && getUserLastDepositTime(_who) < feeRewardData[i].timeStamp 
                    && !feeRewardData[i].isClaimed[_who]) {
                    _accumulatedRewards = _accumulatedRewards.add(feeRewardData[i].value.div(feeRewardData[i].totalStakersAtThatTime));
                    feeRewardData[i].isClaimed[_who] = true;
                }
            }
        }
        return _accumulatedRewards;
    }

    
    function getUserUnclaimedFeesRewards(address _who) public view returns(uint256) {
        uint256 _accumulatedRewards;
        if(getUserShare(_who) >= minStakeForFeeRewards) {
            for(uint256 i = 0; i < feeRewardsCount; i++) {
                if(getUserStartedWeek(_who) <= feeRewardData[i].weekGiven
                    && getUserLastDepositTime(_who) < feeRewardData[i].timeStamp 
                    && !feeRewardData[i].isClaimed[_who]) {
                    _accumulatedRewards = _accumulatedRewards.add(feeRewardData[i].value.div(feeRewardData[i].totalStakersAtThatTime));
                }
            }
        }
        return _accumulatedRewards;
    }
    
    function getUserCurrentRewards(address _who) public view returns(uint256) {
        uint256 _weekCount = energy.weekCount();
        uint256[3] memory thisWeekReward;
        (thisWeekReward[0],
        thisWeekReward[1],
        thisWeekReward[2]) = calculateRewardsByWeekCount(_weekCount);
        uint256 userShareAtThatWeek = getUserPercentageShareByWeekNo(_who, _weekCount);
        return getUserRewardsByWeekNo(_who, _weekCount)
                .add(_calculateRewardByUserShare(thisWeekReward, userShareAtThatWeek))
                .add(getUserRewards(_who));
    }
    
    function getUserRewardsByWeekNo(address _who, uint256 _weekCount) public view returns(uint256) {
        uint256 rewardsAccumulated;
        uint256 userEndWeek = getUserEndedWeek(_who);
        if(getUserStatus(_who) || (getUserShare(_who) > 0)) {
            for(uint256 i = userEndWeek.add(1); i < _weekCount; i++) {
                uint256 userShareAtThatWeek = getUserPercentageShareByWeekNo(_who, i);
                rewardsAccumulated = rewardsAccumulated.add(_calculateRewardByUserShare(getRewardsByWeekNo(i), userShareAtThatWeek));
            }
        }
        return rewardsAccumulated;
    }
    
    function _calculateRewardByUserShare(uint256[3] memory rewardAtThatWeek, uint256 userShareAtThatWeek) internal pure returns(uint256) {
        return (((rewardAtThatWeek[0]
                    .add(rewardAtThatWeek[1])
                    .add(rewardAtThatWeek[2]))
                    .mul(userShareAtThatWeek))
                    .div(percentageDivider.mul(percentageDivider)));
    }

    function getUserPercentageShareByWeekNo(address _who, uint256 _weekCount) public view returns(uint256) {
        return _getUserPercentageShareByValue(getSharesByWeekNo(_weekCount), getUserShareByWeekNo(_who, _weekCount));
    }

    function _getUserPercentageShareByValue(uint256 _totalShares, uint256 _userShare) internal pure returns(uint256) {
        if(_totalShares == 0 || _userShare == 0) {
            return 0;
        } else {
            return (_userShare.mul(percentageDivider.mul(percentageDivider))).div(_totalShares);
        }
    }

    function claimedBalanceOf(address _who) public view returns(uint256) {
        return getUserShare(_who).add(getUserRewards(_who)).add(getUserFeeRewards(_who));
    }
    
    function getUserRewards(address _who) public view returns(uint256) {
        return userInfo[_who].rewards;
    }

    function getUserFeeRewards(address _who) public view returns(uint256) {
        return userInfo[_who].feeRewards;
    }
    
    function getUserTotalRewards(address _who) public view returns(uint256) {
        return userInfo[_who].feeRewards.add(userInfo[_who].rewards);
    }

    function getUserShare(address _who) public view returns(uint256) {
        return userInfo[_who].share;
    }
    
    function getUserShareByWeekNo(address _who, uint256 _weekCount) public view returns(uint256) {
        if(getUserStatus(_who)) {
            return (_userShareByWeekNo(_who, _weekCount) > 0 || _weekCount == 0)
                    ? _userShareByWeekNo(_who, _weekCount)
                    : getUserShareByWeekNo(_who, _weekCount.sub(1));
        } else if(getUserShare(_who) > 0) {
            return getUserShare(_who);            
        }
        return 0;
    }
    
    function _userShareByWeekNo(address _who, uint256 _weekCount) internal view returns(uint256) {
        return userInfo[_who].shareByWeekNo[_weekCount];
    }

    function getUserStatus(address _who) public view returns(bool) {
        return userInfo[_who].isActive;
    }
    
    function getUserStartedWeek(address _who) public view returns(uint256) {
        return userInfo[_who].startedWeek;
    }
    
    function getUserEndedWeek(address _who) public view returns(uint256) {
        return userInfo[_who].endedWeek;
    }
    
    function getUserLastDepositTime(address _who) public view returns(uint256) {
        return userInfo[_who].depositTime;
    }

    function isUserPreviouslyStaked(address _who) public view returns(bool) {
        return smartContractStakers[_who];
    }
    
    function getUserFeeRewardClaimStatus(address _who, uint256 _index) public view returns(bool) {
        return feeRewardData[_index].isClaimed[_who];
    }
    
    
    function getRewardsByWeekNo(uint256 _weekCount) public view returns(uint256[3] memory) {
        return rewardByWeek[_weekCount];
    }
    
    function getFeeRewardsByIndex(uint256 _index) public view returns(uint256, uint256, uint256, uint256) {
        return (feeRewardData[_index].value,
                feeRewardData[_index].timeStamp,
                feeRewardData[_index].totalStakersAtThatTime,
                feeRewardData[_index].weekGiven);
    }
    
    function getRewardPercentages() public view returns(uint256[3] memory) {
        return rewardPercentages;
    }
    
    function getStakeByWeekNo(uint256 _weekCount) public view returns(uint256) {
        return stakePerWeek[_weekCount];
    }
    
    function getSharesByWeekNo(uint256 _weekCount) public view returns(uint256) {
        return totalSharesByWeek[_weekCount];
    }
}