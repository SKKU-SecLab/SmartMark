




pragma solidity ^0.6.0;



interface ERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



library SafeMath 
{

    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        if (a == 0) 
        {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) 
    {

        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }
}



contract GearLPvault {

    
    using SafeMath for uint256;
    
    ERC20 constant liquidityToken = ERC20(0x850C581e52759Da131e06c37B5Af479a2E4e4525);
    ERC20 constant autoToken = ERC20(0xAD1F5e38edD65Cb2F0C447214f0A0Ea2c191CFD9);
    
    mapping (address => uint256) private balances;

    uint256 public fullUnitsFarmed_total = 0;
    uint256 public totalFarmers = 0;
    uint8  constant tokenDecimals = 18;
    mapping (address => bool) public isFarming;

    uint256 _totalRewardsPerUnit = 0;
    uint256 private farmingRewards = 0;
    mapping (address => uint256) private _totalRewardsPerUnit_positions;
    mapping (address => uint256) private _savedRewards;
    mapping (address => uint256) private _savedBalances;
    
    mapping(address => bool) public whitelistTo;
    event WhitelistTo(address _addr, bool _whitelisted);
    
    address cowner = msg.sender;
    uint256 public lastAutoDistribution = now;
    

     modifier onlyOwner() {

        require(msg.sender == cowner, "only owner");
        _;
       }
     
     function totalSupply() public view returns (uint256) 
      {

        return liquidityToken.totalSupply();
      }
        
       function balanceOf(address owner) public view returns (uint256) 
      {

        return liquidityToken.balanceOf(owner);
      }
      
      function AutoBalanceOf(address owner) public view returns (uint256) 
      {

        return autoToken.balanceOf(owner);
      }
      
      function fullUnitsFarmed(address owner) external view returns (uint256) 
       {

        return isFarming[owner] ? toFullUnits(_savedBalances[owner]) : 0;
       }
    
     function toFullUnits(uint256 valueWithDecimals) public pure returns (uint256) 
       {

        return valueWithDecimals.div(10**uint256(tokenDecimals));
       }    
    

    function distributeAuto() external {

        uint256 autoBalance = autoToken.balanceOf(address(this));
        require(lastAutoDistribution < now);
        uint256 Percent = autoBalance.mul(1).div(200);
        
         
        if(fullUnitsFarmed_total > 0)
        {
            farmingRewards = farmingRewards.add(Percent);
            
            uint256 rewardsPerUnit = farmingRewards.div(fullUnitsFarmed_total);
            _totalRewardsPerUnit = _totalRewardsPerUnit.add(rewardsPerUnit);
            balances[address(this)] = balances[address(this)].add(farmingRewards);
            farmingRewards = 0;
            
        }
        
            lastAutoDistribution = lastAutoDistribution + 24 hours;
    } 
    
    

    function updateRewardsFor(address farmer) private
    {

        _savedRewards[farmer] = viewHarvest(farmer);
        _totalRewardsPerUnit_positions[farmer] = _totalRewardsPerUnit;
    }
    
    function viewHarvest(address farmer) public view returns (uint256)
    {

        if(!isFarming[farmer])
            return _savedRewards[farmer];
        uint256 newRewardsPerUnit = _totalRewardsPerUnit.sub(_totalRewardsPerUnit_positions[farmer]);
        
        uint256 newRewards = newRewardsPerUnit.mul(toFullUnits(liquidityToken.balanceOf(farmer)));
        return _savedRewards[farmer].add(newRewards);
    }
    
    
    function harvest() public
    {

        updateRewardsFor(msg.sender);
        uint256 rewards = _savedRewards[msg.sender];
        require(rewards > 0 && rewards <= balances[address(this)]);
        require(_savedBalances[msg.sender] == liquidityToken.balanceOf(msg.sender));
        
        _savedRewards[msg.sender] = 0;
        
         uint256 fivePercent = 0;
         uint256 reward = 0;
        
         if(!whitelistTo[msg.sender]) 
         {
            fivePercent = rewards.mul(5).div(100);
         
            if(fivePercent == 0 && rewards > 0) 
                fivePercent = 1;
        }
        
        reward = rewards.sub(fivePercent);
        
       if(lastAutoDistribution < now)
       {
        uint256 autoBalance = autoToken.balanceOf(address(this));
        
        uint256 Percent = autoBalance.mul(1).div(200);
        
         
        if(fullUnitsFarmed_total > 0)
        
            farmingRewards = farmingRewards.add(Percent);
            uint256 rewardsPerUnit = farmingRewards.div(fullUnitsFarmed_total);
            _totalRewardsPerUnit = _totalRewardsPerUnit.add(rewardsPerUnit);
            balances[address(this)] = balances[address(this)].add(farmingRewards);
            farmingRewards = 0;
        
             lastAutoDistribution = lastAutoDistribution + 24 hours;
        } 

         balances[address(this)] = balances[address(this)].sub(rewards);
         autoToken.transfer(msg.sender, reward);
         autoToken.transfer(cowner, fivePercent);
    }
    
    function enableFarming() public { _enableFarming(msg.sender);  }

    
    function disableFarming() public { _disableFarming(msg.sender); }

    
    function _enableFarming(address farmer) private
    {

        require(!isFarming[farmer]);
        updateRewardsFor(farmer);
        isFarming[farmer] = true;
        fullUnitsFarmed_total = fullUnitsFarmed_total.add(toFullUnits(liquidityToken.balanceOf(farmer)));
        _savedBalances[farmer] = liquidityToken.balanceOf(farmer);
        totalFarmers = totalFarmers.add(1);
       
       if(lastAutoDistribution < now)
       {
        uint256 autoBalance = autoToken.balanceOf(address(this));
        
        uint256 Percent = autoBalance.mul(1).div(200);
        
         
        if(fullUnitsFarmed_total > 0)
        
            farmingRewards = farmingRewards.add(Percent);
            uint256 rewardsPerUnit = farmingRewards.div(fullUnitsFarmed_total);
            _totalRewardsPerUnit = _totalRewardsPerUnit.add(rewardsPerUnit);
            balances[address(this)] = balances[address(this)].add(farmingRewards);
            farmingRewards = 0;
        
            lastAutoDistribution = lastAutoDistribution + 24 hours;
        } 
    }
    
    
    function _disableFarming(address farmer) private
    {

        require(isFarming[farmer]);
        harvest();
        isFarming[farmer] = false;
        fullUnitsFarmed_total = fullUnitsFarmed_total.sub(toFullUnits(_savedBalances[farmer]));
        _savedBalances[farmer] = 0;
        totalFarmers = totalFarmers.sub(1);
        
       if(lastAutoDistribution < now)
       {
        uint256 autoBalance = autoToken.balanceOf(address(this));
        
        uint256 Percent = autoBalance.mul(1).div(200);
        
         
        if(fullUnitsFarmed_total > 0)
        
            farmingRewards = farmingRewards.add(Percent);
            uint256 rewardsPerUnit = farmingRewards.div(fullUnitsFarmed_total);
            _totalRewardsPerUnit = _totalRewardsPerUnit.add(rewardsPerUnit);
            balances[address(this)] = balances[address(this)].add(farmingRewards);
            farmingRewards = 0;
        
             lastAutoDistribution = lastAutoDistribution + 24 hours;
        } 
    }
    
    
     function disableFarmingFor(address farmer) public onlyOwner
      {

        require(isFarming[farmer]); 
        isFarming[farmer] = false;
        fullUnitsFarmed_total = fullUnitsFarmed_total.sub(toFullUnits(_savedBalances[farmer]));
        _savedBalances[farmer] = 0;
        totalFarmers = totalFarmers.sub(1);
        
       if(lastAutoDistribution < now)
       {
        uint256 autoBalance = autoToken.balanceOf(address(this));
        
        uint256 OnePercent = autoBalance.mul(1).div(200);
        
         
        if(fullUnitsFarmed_total > 0)
        
            farmingRewards = farmingRewards.add(OnePercent);
            uint256 rewardsPerUnit = farmingRewards.div(fullUnitsFarmed_total);
            _totalRewardsPerUnit = _totalRewardsPerUnit.add(rewardsPerUnit);
            balances[address(this)] = balances[address(this)].add(farmingRewards);
            farmingRewards = 0;
        
            lastAutoDistribution = lastAutoDistribution + 24 hours;
        } 
        
      }
    
    
    function withdrawERC20Tokens(address tokenAddress, uint256 amount) public payable onlyOwner
    {

        ERC20(tokenAddress).transfer(msg.sender, amount);
    }
    
    function setWhitelistedTo(address _addr, bool _whitelisted) external onlyOwner {

        emit WhitelistTo(_addr, _whitelisted);
        whitelistTo[_addr] = _whitelisted;
    }


}