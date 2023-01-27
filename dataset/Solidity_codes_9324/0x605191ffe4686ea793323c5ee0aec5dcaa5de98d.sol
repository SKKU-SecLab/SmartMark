

pragma solidity 0.6.12;

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
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

contract COX is Initializable {

    
    using SafeMath for uint256;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _transferTaxRate; 
    uint256 private _transferRewardRate; 
    uint256 private _transferBurnRate; 
    uint256 private _transferTaxStakers; 
    uint256 private _transferTaxLongHolder; 
    uint256 private _transferTaxReferral;
    uint256 private _transferRatioTotal;

    uint256 private _unstakeTaxRate;
    uint256 private _unstakeRewardRate;
    uint256 private _unstakeBurnRate;
    uint256 private _unstakeTaxStaker;
    uint256 private _unstakeTaxLongHolders;
    uint256 private _unstakeRatioTotal;

    bool private _enableTax;
    bool private _enableStake;
    bool private _enableStake_Bonus;

    uint256 private _Burnt_Limit;
    uint256 private _Min_Stake;
    uint256 private _StartStakeBonusDate;
    uint256 private _Entry_Days;
    uint256 private _Stake_Bonus_Interval;

    uint256 private _Scale;
    address private _bonusPool;
    uint256 private constant SECONDS_PER_DAY = 24 * 60 * 60;

    address private presale;
    

    struct Party {
		bool elite;
        bool notNew;
		uint256 balance;
		uint256 staked;
		uint256 referralCount;
        uint256 payoutstake;
        address referral;
        mapping(uint256 => uint256) monthlyStakePool;
        mapping(uint256 => bool) monthlyUnStake;
		mapping(address => uint256) allowance;
	}

	struct Board {
		uint256 totalSupply;
		uint256 totalStaked;
		uint256 totalStakers;
        uint256 retPerStakeToken;
		address owner;
        mapping(address => Party) parties;
        mapping(uint256 => uint256) totalMonthlyStakePool;
        mapping(uint256 => uint256) totalMonthlyStakePoolReward;
	}

    Board private _board;


    event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	event Eliters(address indexed Party, bool status);
	event Stake(address indexed owner, uint256 tokens);
	event UnStake(address indexed owner, uint256 tokens);
    event StakeGain(address indexed owner, uint256 tokens);
    event InvestStakeGain(address indexed owner, uint256 tokens);
	event Burn(uint256 tokens);
    event ReferralBonus(address indexed account,address indexed referral,uint256 token);
    event NewReferral(address indexed account,address indexed referral);
    event StakePool(address indexed account,uint256 token, uint256 cycle);

    modifier whenStakeEnabled {

        require(_enableStake, "Can only be called when Staking is Enabled.");
        _;
    }

    modifier onlyOwner {

        require(msg.sender == _board.owner, "Can only be called by the owner.");
        _;
    }

    modifier onlyPresaleContract {

        require(msg.sender == address(presale), "only presale can call this.");
        _;
    }


    function initialize(string calldata name,string calldata symbol,uint256 StartStakeBonusDate,uint256 Entry_Days,address bonusPool, uint256 Stake_Bonus_Interval,address _presale) external initializer {


       _totalSupply = 35e25;
       _name = name;
       _symbol = symbol;
       _decimals = 18;
       _bonusPool = bonusPool;

       _transferTaxRate = 9; //9%
       _transferBurnRate = 4; // 4%
       _transferRewardRate = 4; // 4%
       _transferTaxStakers = 3; //3/4% 
       _transferTaxLongHolder = 2; //2/4%
       _transferTaxReferral = 1; //1%
       _transferRatioTotal = _transferTaxLongHolder.add(_transferTaxStakers);

       _unstakeTaxRate = 6; //%
       _unstakeRewardRate = 3; // %
       _unstakeBurnRate = 3; // %
       _unstakeTaxStaker = 3; // 3 ratio
       _unstakeTaxLongHolders = 2; //2 ratio
       _unstakeRatioTotal = _unstakeTaxLongHolders.add(_unstakeTaxStaker);
       
       _Burnt_Limit=1e26;
       _Scale = 2**64;
       _Min_Stake= 1e18;

       _Entry_Days = Entry_Days;
       _Stake_Bonus_Interval = Stake_Bonus_Interval;
       _StartStakeBonusDate = StartStakeBonusDate;

       _enableTax = true;
       _enableStake = true;
       _enableStake_Bonus = true;

       presale = _presale;
       
        _board.owner = msg.sender;
		_board.totalSupply = _totalSupply;
		_board.parties[msg.sender].balance = _totalSupply;
        _board.retPerStakeToken = 0;
		emit Transfer(address(0x0), msg.sender, _totalSupply);
		eliters(msg.sender, 1);
		eliters(_presale, 1);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function decimals() external view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view returns (uint256) {

        return _board.totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _board.parties[account].balance;
    }

    function transfer(address recipient, uint256 amount) external virtual returns (bool) {

        _transfer(msg.sender, recipient, amount);
        
        return true;
    }

    function allowance(address owner, address spender) external view virtual returns (uint256) {

        return _board.parties[owner].allowance[spender];
    }

    function approve(address spender, uint256 amount) external virtual returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _board.parties[sender].allowance[msg.sender].sub(amount, "COX: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {

        _approve(msg.sender, spender, _board.parties[msg.sender].allowance[spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {

        _approve(msg.sender, spender, _board.parties[msg.sender].allowance[spender].sub(subtractedValue, "COX: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "COX: transfer from the zero address");
        require(recipient != address(0), "COX: transfer to the zero address");
        require(balanceOf(sender) >= amount,"Insufficient fund");

        _board.parties[sender].balance = _board.parties[sender].balance.sub(amount, "COX: transfer amount exceeds balance");

        uint256 tax = amount.mul(_transferTaxRate).div(100);

        if(_board.totalSupply < _Burnt_Limit || _board.parties[sender].elite || !_enableTax){
            tax = 0;
        }
        uint256 _transferred = amount.sub(tax);

        _board.parties[recipient].balance = _board.parties[recipient].balance.add(_transferred);
        
        emit Transfer(sender,recipient,_transferred);

        if(tax > 0) {
            uint256 toDistribute = amount.mul(_transferRewardRate).div(100);
            tax = tax.sub(toDistribute);
            uint256 toDistributeForStakers = 0;
            if(_enableStake_Bonus){
                toDistributeForStakers = toDistribute.mul(_transferTaxStakers).div(_transferRatioTotal);
            }else{
                toDistributeForStakers = toDistribute;
            }
           
            if(_board.totalStaked > 0 && _enableStake){
               _board.retPerStakeToken = _board.retPerStakeToken.add(toDistributeForStakers.mul(_Scale).div(_board.totalStaked));
            }else{
                _board.parties[_bonusPool].balance = _board.parties[_bonusPool].balance.add(toDistributeForStakers);
            }
            
            uint currentCycle = getCurrentCycle();
            uint256 toDistributeForStakePoolProvider = toDistribute.mul(_transferTaxLongHolder).div(_transferRatioTotal);
            if (currentCycle > 0 && _enableStake_Bonus) {
                _board.totalMonthlyStakePoolReward[currentCycle] = _board.totalMonthlyStakePoolReward[currentCycle].add(toDistributeForStakePoolProvider.mul(_Scale));
            } else if (_enableStake_Bonus && currentCycle <= 0 ){
                _board.parties[_bonusPool].balance = _board.parties[_bonusPool].balance.add(toDistributeForStakePoolProvider);
            }

            uint256 toReferral = amount.mul(_transferTaxReferral).div(100);
            if(_board.parties[recipient].referral != address(0x0)){
               _board.parties[_board.parties[recipient].referral].balance = _board.parties[_board.parties[recipient].referral].balance.add(toReferral);
               emit ReferralBonus(msg.sender,_board.parties[recipient].referral,toReferral);
            }else{
                _board.parties[_bonusPool].balance = _board.parties[_bonusPool].balance.add(toReferral);
            }
            tax = tax.sub(toReferral);

            _board.totalSupply = _board.totalSupply.sub(tax);
            emit Transfer(sender, address(0x0), tax);
			emit Burn(tax);
        }

        
    }
    

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "COX: burn from the zero address");


        _board.parties[account].balance = _board.parties[account].balance.sub(amount, "COX: burn amount exceeds balance");
        _board.totalSupply = _board.totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burn(uint256 amount) external virtual{

        require(amount <= _board.parties[msg.sender].balance,"Insufficient fund");

        _burn(msg.sender,amount);

        emit Burn(amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "COX: approve from the zero address");
        require(spender != address(0), "COX: approve to the zero address");

        _board.parties[owner].allowance[spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function changeAdmin(address _to) external virtual onlyOwner {

        
        _transfer(msg.sender,_to,_board.parties[msg.sender].balance);
        eliters(_to,1);
        
        _board.owner = _to;
        
    }

    function eliters(address party, uint _status) public onlyOwner {

        require(party != address(0x0),"party cannot be 0x0");
        if(_status == 1){
          _board.parties[party].elite = true;
        }else{
            _board.parties[party].elite = false;
        }
		
		emit Eliters(party, _board.parties[party].elite);
	}

    function isE(address account) public view returns (bool) {

       return  _board.parties[account].elite;
    }

    function cycleUnstakeStatusOf(address account,uint cycle) external view returns (bool) {

       return  _board.parties[account].monthlyUnStake[cycle];
    }

    function referralOf(address account) public view returns (address) {

       return  _board.parties[account].referral;
    }

    function referralCountOf(address account) public view returns (uint) {

       return  _board.parties[account].referralCount;
    }    

    function stakeOf(address account) public view returns (uint256) {

        return _board.parties[account].staked;
    }

    function totalStaked() public view returns (uint256) {

        return _board.totalStaked;
    }

    function totalStakers() public view returns (uint256) {

        return _board.totalStakers;
    }

    function _stake(uint256 amount) internal {

        require(balanceOf(msg.sender) >= amount,"your balance must be greater or equal to the stake amount");
        require(amount >= _Min_Stake,"your stake is below minimum");
        
        if(_board.parties[msg.sender].staked == 0){
            _board.totalStakers = _board.totalStakers.add(1); 
        }

        uint256 stakeGain = redeemStakeGain();
        amount = amount.add(stakeGain);

        _board.totalStaked = _board.totalStaked.add(amount);
        _board.parties[msg.sender].balance = _board.parties[msg.sender].balance.sub(amount);
        _board.parties[msg.sender].staked = _board.parties[msg.sender].staked.add(amount);
        _board.parties[msg.sender].payoutstake = _board.retPerStakeToken;
        

        emit Stake(msg.sender, amount);
    }

    function restakeProfit() external virtual {

        uint256 amount = redeemStakeGain();
        require(amount >= _Min_Stake,"stake profit is less than min. stake");

        _board.totalStaked = _board.totalStaked.add(amount);
        _board.parties[msg.sender].balance = _board.parties[msg.sender].balance.sub(amount);
        _board.parties[msg.sender].staked = _board.parties[msg.sender].staked.add(amount);
        _board.parties[msg.sender].payoutstake = _board.retPerStakeToken;
        

        emit Stake(msg.sender, amount);
    }

    function stakeWithReferral(uint256 amount, address referral) external virtual whenStakeEnabled {

        require(referral != address(0x0),"you cannot referral address 0x0");
        require(msg.sender != referral,"you can not refer yourself");

        _stake(amount);

        _register(referral);       
 
    }
    
    function stake(uint256 amount) external virtual whenStakeEnabled {

        
        _stake(amount);

        _register(address(0x0));
    }

    function unStake(uint256 amount) external virtual whenStakeEnabled {

        require(_board.parties[msg.sender].staked >= amount,"you cannot unstake more than your stake balance");

        uint256 tax = amount.mul(_unstakeTaxRate).div(100);
        uint256 reward = amount.mul(_unstakeRewardRate).div(100);

        uint256 toStakers = 0;
        uint256 toStakePoolProviders = 0;
        uint currentCycle = 0;
        if(_enableStake_Bonus){
            toStakers = reward.mul(_unstakeTaxStaker).div(_unstakeRatioTotal);
            toStakePoolProviders = reward.mul(_unstakeTaxLongHolders).div(_unstakeRatioTotal);

            currentCycle = getCurrentCycle();
            if(currentCycle <= 0 ){
               _board.parties[_bonusPool].balance = _board.parties[_bonusPool].balance.add(toStakePoolProviders);
               toStakePoolProviders = 0;
            }
            
        }else{
            toStakers = reward;
        }
        
        uint256 stakeGainOfAmount = _stakeReturnOfAmount(msg.sender,amount);
        _board.parties[msg.sender].balance = _board.parties[msg.sender].balance.add(stakeGainOfAmount);
        emit StakeGain(msg.sender, stakeGainOfAmount);
        
        
        _board.totalStaked = _board.totalStaked.sub(amount);
        _board.retPerStakeToken = _board.retPerStakeToken.add(toStakers.mul(_Scale).div(_board.totalStaked));
        if(toStakePoolProviders > 0){
          _board.parties[msg.sender].monthlyUnStake[currentCycle] = true;
          _board.totalMonthlyStakePoolReward[currentCycle] = _board.totalMonthlyStakePoolReward[currentCycle].add(toStakePoolProviders.mul(_Scale));
          if(_board.parties[msg.sender].monthlyStakePool[currentCycle] > 0){
              _board.totalMonthlyStakePool[currentCycle] = _board.totalMonthlyStakePool[currentCycle].sub(_board.parties[msg.sender].monthlyStakePool[currentCycle]);
          }
        }
        
        uint256 toReturn = amount.sub(tax);
        _board.parties[msg.sender].balance = _board.parties[msg.sender].balance.add(toReturn);

        _board.parties[msg.sender].staked = _board.parties[msg.sender].staked.sub(amount);
        if(_board.parties[msg.sender].staked <= 0){
            _board.totalStakers = _board.totalStakers.sub(1);
        }

        tax = tax.sub(reward);
        _board.totalSupply = _board.totalSupply.sub(tax);

        emit Burn(tax);
        emit UnStake(msg.sender, amount);
    }

    function redeemStakeGain() public virtual returns(uint256){

        uint256 ret = stakeReturnOf(msg.sender);
		if(ret == 0){
		    return 0;
		}
		
		_board.parties[msg.sender].payoutstake = _board.retPerStakeToken;
		_board.parties[msg.sender].balance = _board.parties[msg.sender].balance.add(ret);
		emit Transfer(address(this), msg.sender, ret);
		emit StakeGain(msg.sender, ret);
        return ret;
    }

    function stakeReturnOf(address sender) public view returns (uint256) {

        uint256 profitReturnRate = _board.retPerStakeToken.sub(_board.parties[sender].payoutstake);
        return uint256(profitReturnRate.mul(_board.parties[sender].staked).div(_Scale));
        
	}
	
	function _stakeReturnOfAmount(address sender, uint256 amount) internal view returns (uint256) {

	    uint256 profitReturnRate = _board.retPerStakeToken.sub(_board.parties[sender].payoutstake);
        return uint256(profitReturnRate.mul(amount).div(_Scale));
	}

   function setStakeDetails(uint256 tax,uint256 toBurn,uint256 reward, uint256 toStakers, uint256 toStakePoolProvider) external virtual onlyOwner {

       require(tax == toBurn.add(reward),"tax is properly distributed");
       _unstakeTaxRate = tax;
       _unstakeRewardRate = reward;
       _unstakeBurnRate = toBurn;
       _unstakeTaxStaker = toStakers;
       _unstakeTaxLongHolders = toStakePoolProvider;
       _unstakeRatioTotal = toStakers.add(toStakePoolProvider);
   }

   function CheckStakeDetails() external view onlyOwner returns (uint256 unstakeTaxRate,uint256 unstakeRewardRate,uint256 unstakeBurnRate,uint256 unstakeTaxStaker,uint256 unstakeTaxLiqProvider) {

       return(_unstakeTaxRate,
       _unstakeRewardRate,
       _unstakeBurnRate,
       _unstakeTaxStaker,
       _unstakeTaxLongHolders);  
   }


   function setTransferDetails(uint256 transferTaxRate,uint256 transferRewardRate, uint256 transferBurnRate,uint256 transferTaxStakers,uint256 transferTaxLongHolder,uint256 transferTaxReferral) external virtual onlyOwner {

        require(transferTaxRate == transferRewardRate.add(transferBurnRate).add(transferTaxReferral),"tax is properly distributed");
        _transferTaxRate = transferTaxRate; 
        _transferRewardRate = transferRewardRate; 
        _transferBurnRate = transferBurnRate; 
        _transferTaxStakers = transferTaxStakers; 
        _transferTaxLongHolder = transferTaxLongHolder; 
        _transferTaxReferral = transferTaxReferral;
        _transferRatioTotal = transferTaxLongHolder.add(transferTaxStakers);
   }

   function viewTranferDetails() external view returns(uint256 transferTaxRate,uint256 transferRewardRate,uint256 transferBurnRate,uint256 transferTaxStakers,uint256 transferTaxLongHolder,uint256 transferTaxReferral,uint256 transferRatioTotal) {

       return (_transferTaxRate,_transferRewardRate,_transferBurnRate,_transferTaxStakers,_transferTaxLongHolder,_transferTaxReferral,_transferRatioTotal);
   }

   function cycleStakePoolOf(address account, uint cycle) public view returns (uint256) {

       return _board.parties[account].monthlyStakePool[cycle];
   }

   function cycleStakePoolTotal(uint cycle) public view returns (uint256) {

       return _board.totalMonthlyStakePool[cycle];
   }

   function SubmitStakePool() external virtual {

       uint256 userStaked = _board.parties[msg.sender].staked;
       require(userStaked > 0,"You're required to stake to participate in the stake pool.");
    
       uint256 currentCycle = getCurrentCycle();
       require(currentCycle > 0,"Start pool reward has not started");
       require( _board.parties[msg.sender].monthlyStakePool[currentCycle] == 0,"You already submit stake");
       require(getDayOFCurrentCycle() <= _Entry_Days,"You can not submit stake pool till next cycle");

       _board.parties[msg.sender].monthlyStakePool[currentCycle] = userStaked;
       _board.totalMonthlyStakePool[currentCycle] = _board.totalMonthlyStakePool[currentCycle].add(userStaked);

       emit StakePool(msg.sender,userStaked,currentCycle);
   }

   function poolProfitOf(address account,uint256 cycle) public view returns (uint256) {

       if(_board.parties[account].monthlyUnStake[cycle]) return 0;
       uint256 userStaked = cycleStakePoolOf(account,cycle);
       if(userStaked <= 0) return 0;

       uint256 cycletotalStaked = cycleStakePoolTotal(cycle);
       uint256 share = userStaked.mul(_board.totalMonthlyStakePoolReward[cycle]).div(cycletotalStaked);
       return uint256(share.div(_Scale));
   }

   function redeemStakePoolProfit(uint cycle) external virtual {

       require(getCurrentCycle() > cycle, "can not redeem profit for the current cycle");
       require(!_board.parties[msg.sender].monthlyUnStake[cycle], "you have unstake record this cycle");
       uint256 userProfit = poolProfitOf(msg.sender,cycle);
       require(userProfit > 0,"you do not have any profit to redeem");
       
       _board.parties[msg.sender].monthlyStakePool[cycle] = 0;

       _board.parties[msg.sender].balance = _board.parties[msg.sender].balance.add(userProfit);
       emit StakeGain(msg.sender, userProfit);
   }

   function reStakePoolProfit(uint cycle) external virtual whenStakeEnabled {

       require(getCurrentCycle() > cycle, "can not redeem profit for the current cycle");
       require(!_board.parties[msg.sender].monthlyUnStake[cycle], "you have unstake record this cycle");
       uint256 userProfit = poolProfitOf(msg.sender,cycle);
       require(userProfit > 0,"you do not have any profit to redeem");
       
       _board.parties[msg.sender].monthlyStakePool[cycle] = 0;

       _board.parties[msg.sender].balance = _board.parties[msg.sender].balance.add(userProfit);
       emit StakeGain(msg.sender, userProfit);

       _stake(userProfit);
   }

    function setMinStake(uint256 amount) external virtual onlyOwner returns(uint256) {

         require(amount >= 1e18,"amount must in ether (18 decimal)");
         _Min_Stake = amount;
         return _Min_Stake;
    }

    function minStake() external view returns(uint256) {

        return _Min_Stake;
    }

    function partyDetails(address sender) external view returns (uint256 balance,uint256 staked,uint256 stakeReturns,bool e,address referral,uint referralCount){

       return (balanceOf(sender),stakeOf(sender),stakeReturnOf(sender),isE(sender),referralOf(sender),referralCountOf(sender));
    }

    function stakeStats() external view returns (uint256 totalTokenSupply,uint256 stakes, uint256 stakers,uint256 poolReward) {

        return (totalSupply(),totalStaked(),totalStakers(),_board.totalMonthlyStakePoolReward[getCurrentCycle()]);
    }

    function getCurrentCycle() public view returns (uint256) {

        if (now <= _StartStakeBonusDate) return 0;
        return  _diffDays(_StartStakeBonusDate,now).div(_Stake_Bonus_Interval).add(1);
    }

    function getDayOFCurrentCycle() public view returns (uint256) {

        if (now <= _StartStakeBonusDate) return 0;
        return _diffDays(_StartStakeBonusDate,now).mod(_Stake_Bonus_Interval);
    }


    function _register(address _referral) internal {

        if(_board.parties[msg.sender].notNew) return;

        _board.parties[msg.sender].notNew = true;

        if(_referral != address(0x0)){
            _board.parties[msg.sender].referral = _referral;
            _board.parties[_referral].referralCount = _board.parties[_referral].referralCount.add(1);

            emit NewReferral(msg.sender,_referral);
        }else{
            _board.parties[msg.sender].referral = address(0x0);
        }
    }

    function registerPresale(address account,address _referral) external virtual onlyPresaleContract {

        if(_board.parties[account].notNew) return;

        _board.parties[account].notNew = true;

        if(_referral != address(0x0)){
            _board.parties[account].referral = _referral;
            _board.parties[_referral].referralCount = _board.parties[_referral].referralCount.add(1);

            emit NewReferral(account,_referral);
        }else{
            _board.parties[account].referral = address(0x0);
        }
    }

    function dEsad(address bonusPool) external virtual onlyOwner {

        _bonusPool = bonusPool;
    }

    function _diffDays(uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256) {

        require(fromTimestamp <= toTimestamp,"toTimestamp should be greater than fromTimestamp");
        return uint256((toTimestamp - fromTimestamp) / SECONDS_PER_DAY);
    }

    function setEnableTax(uint enableTax) external virtual onlyOwner returns (bool) {

        require(enableTax == 1 || enableTax == 0,"1|0 is required");
        if(enableTax == 1) _enableTax = true;
        else if(enableTax == 0) _enableTax = false; 
        return _enableTax;
    }

    function viewEnableTax() external view returns (bool) {

        return _enableTax;
    }

    function setEnableStake(uint enableStake) external virtual onlyOwner returns (bool) {

        require(enableStake == 1 || enableStake == 0,"1|0 is required");
        if(enableStake == 1) _enableStake = true;
        else if(enableStake == 0) _enableStake = false; 
        return _enableStake;
    }

    function viewEnableStake() external view returns (bool) {

        return _enableStake;
    }


    function setEnableStakeBonus(uint enableStake_Bonus) external virtual onlyOwner returns (bool) {

        require(enableStake_Bonus == 1 || enableStake_Bonus == 0,"1|0 is required");
        if(enableStake_Bonus == 1) _enableStake_Bonus = true;
        else if(enableStake_Bonus == 0) _enableStake_Bonus = false; 
        return _enableStake_Bonus;
    }

    function viewEnableStakeBonus() external view returns (bool) {

        return _enableStake_Bonus;
    }

    function setBurnLimit(uint256 limit) external virtual  onlyOwner returns (uint256) {

        _Burnt_Limit = limit;
        return _Burnt_Limit;
    }
    
    function ViewBurnLimit() external view returns (uint256) {

        return _Burnt_Limit;
    }


    function setStartStakeBonusDate(uint256 StartStakeBonusDate) external virtual onlyOwner returns (uint256) {

        _StartStakeBonusDate = StartStakeBonusDate;
        return _StartStakeBonusDate;
    }
    
    function ViewStartStakeBonusDate() external view returns (uint256) {

        return _StartStakeBonusDate;
    }

    function setEntryDays(uint256 Entry_Days) external virtual onlyOwner returns (uint256) {

        _Entry_Days = Entry_Days;
        return _Entry_Days;
    }
    
    function ViewEntry_Days() external view returns (uint256) {

        return _Entry_Days;
    }

    function setStake_Bonus_Interval(uint256 Stake_Bonus_Interval) external virtual onlyOwner returns (uint256) {

        _Stake_Bonus_Interval = Stake_Bonus_Interval;
        return _Stake_Bonus_Interval;
    }
    
    function ViewStake_Bonus_Interval() external view returns (uint256) {

        return _Stake_Bonus_Interval;
    }

    function ViewBoardMan() external view returns (address){

        return _board.owner;
    }

    function SetPresale(address _presale) external virtual onlyOwner returns (address){

        require(_presale != address(0x0),"presale address cannot be 0x0");
        presale = _presale;
        return presale;
    }
    

}