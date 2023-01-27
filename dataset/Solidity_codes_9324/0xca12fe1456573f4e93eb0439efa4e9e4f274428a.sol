



pragma solidity ^0.8.0;


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

contract Ownable {

    address public owner;
    address public proposedOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Has to be owner");
        _;
    }

    function transferOwnership(address _proposedOwner) public onlyOwner {

        require(msg.sender != _proposedOwner, "Has to be diff than current owner");
        proposedOwner = _proposedOwner;
    }

    function claimOwnership() public {

        require(msg.sender == proposedOwner, "Has to be the proposed owner");
        emit OwnershipTransferred(owner, proposedOwner);
        owner = proposedOwner;
        proposedOwner = address(0);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
abstract contract Context {
 

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}


contract TierSystem is Ownable, Context{

    using SafeMath for uint;
    bool public isAudit=false;
    address public HDAO;
    uint public rate;   // yield 
    uint[10] public dynamicRate;
    uint public period; // calm down period
    bool public isReferMode;
    uint public referMode; // two types of refer modes
    uint[4] public threshold;  
    
    enum Tier{None,Bronze,Silver,Gold,Platinum}
    
    uint public totalStake;  // total amount at stake
    uint public totalFrozen; // total amount at frozen status
    uint public withdrawn; // total amount of stake withdrawn
    
    uint public staticAccrued;
    uint public dynamicAccrued;
    
    uint public staticWithdrawn;
    uint public dynamicWithdrawn;
    
    mapping(Tier=>uint) public tierInfo; // members of each tier

    
    struct UserInfo{
        uint deposit_times;
        address invite;
        uint stake_amount;  // real time on stake 
        uint frozen_amount; // unstake amount at frozen status
        uint lastTime; // stake timestamp used for interest calculation, will update at each operation
        uint countdown; // timestamp at unstake, used for calculate frozen period
        
        uint intAccrued; // static interest rewards
        uint dynamicRewards; 
        Tier tier;
        uint num_invitor; // number of people this address invited
        
    }
    
    mapping(address=>UserInfo) public userInfo; 
    
    
    event ReferMode(bool status, uint mode);
    event Stake(address indexed user, uint amount, uint timestamp);
    event Unstake(address indexed user, uint amount, uint timestamp);
    event Withdraw(address indexed user, uint amount, uint timestamp);
    
    constructor(){

        owner = _msgSender();
        userInfo[address(this)].deposit_times = 1;
        period = 3 days;
        rate = 18;
        
        threshold[0] = 10000 * 1e18;
        threshold[1] = 100000 * 1e18;
        threshold[2] = 500000 * 1e18;
        threshold[3] = 1000000 * 1e18;
        
        
        dynamicRate[0] = 30;
        dynamicRate[1] = 20;
        dynamicRate[2] = 10;
        dynamicRate[3] = 5;
        dynamicRate[4] = 5;
        dynamicRate[5] = 3;
        dynamicRate[6] = 3;
        dynamicRate[7] = 2;
        dynamicRate[8] = 2;
        dynamicRate[9] = 2;
        
    }
    
    function setAudit()external onlyOwner{

        isAudit = true;
    }
    function getUserTier(address _user) external view returns(uint8){

        return uint8(userInfo[_user].tier);
    }
    
    function getUserStake(address _user)external view returns(uint){

        return userInfo[_user].stake_amount;
    }
    
    function setHDAO(address addr) external onlyOwner{

        HDAO = addr;
    }
    function setThreshold(uint[4] memory ts) external onlyOwner{

        for(uint i=0;i<4; i++){
            threshold[i] = ts[i];
        }
    }
    
    function setPeriod(uint p) external onlyOwner{

        period = p;
    }
    
    function setRate(uint r) external onlyOwner{

        rate = r;
    }
    
    function setReferMode(bool s, uint mode) external onlyOwner{

        require(mode==1 || mode==2,"only two mode options");
        isReferMode = s;
        referMode = mode;
        emit ReferMode(s, mode);
    }
   
    function stake(uint _amount, address _invite) external {

        require(userInfo[_invite].deposit_times > 0 && _invite != _msgSender(), "invalid invitor");
        
        
        require(_amount>0,"amount should be positive");
        IERC20(HDAO).transferFrom(_msgSender(),address(this),_amount);
        
        if(userInfo[_msgSender()].deposit_times==0){
            tierInfo[Tier.None] += 1;
            userInfo[_msgSender()].invite = _invite;
            userInfo[_invite].num_invitor += 1;
            require(userInfo[_invite].stake_amount >= 10000*1e18 || _invite == address(this),"invitor should have at least 10000 on stake");
        }
        
        calculateInterest(_msgSender());
        
        userInfo[_msgSender()].deposit_times += 1;
        userInfo[_msgSender()].stake_amount += _amount;
        
       
        
        Tier temp;  // new tier
        Tier tier_user = userInfo[_msgSender()].tier; // original tier
        
        if(uint8(userInfo[_msgSender()].tier) < uint8(4)){
            if(userInfo[_msgSender()].stake_amount >= threshold[3]){
                temp = Tier.Platinum;
                
            }
            else if(userInfo[_msgSender()].stake_amount >= threshold[2]){
                temp = Tier.Gold;
                
            }
            else if(userInfo[_msgSender()].stake_amount >= threshold[1]){
                temp = Tier.Silver;
                
            }
            else if(userInfo[_msgSender()].stake_amount >= threshold[0]){
                temp = Tier.Bronze;
            }
            
            if(tier_user != temp){
                userInfo[_msgSender()].tier = temp;
                tierInfo[tier_user] --;
                tierInfo[temp] ++;
            }
        }
        
        totalStake += _amount;
        emit Stake(_msgSender(), _amount, block.timestamp);
    }
    
    
    function unstake(uint _amount) external {

        require(userInfo[_msgSender()].stake_amount>= _amount,"insufficient ammout");
        
        calculateInterest(_msgSender());
        
        userInfo[_msgSender()].stake_amount -= _amount;
        userInfo[_msgSender()].frozen_amount += _amount;
        userInfo[_msgSender()].countdown = block.timestamp;
        
        Tier temp;  // new tier
        Tier tier_user = userInfo[_msgSender()].tier; // original tier
        
        if(uint8(userInfo[_msgSender()].tier) > uint8(0)){
            if(userInfo[_msgSender()].stake_amount >= threshold[3]){
                temp = Tier.Platinum;
                
            }
            else if(userInfo[_msgSender()].stake_amount >= threshold[2]){
                temp = Tier.Gold;
                
            }
            else if(userInfo[_msgSender()].stake_amount >= threshold[1]){
                temp = Tier.Silver;
                
            }
            else if(userInfo[_msgSender()].stake_amount >= threshold[0]){
                temp = Tier.Bronze;
            }
            
            if(tier_user != temp){
                userInfo[_msgSender()].tier = temp;
                tierInfo[tier_user] --;
                tierInfo[temp] ++;
            }
        }
        
        totalStake -= _amount;
        totalFrozen += _amount; 
        emit Unstake(_msgSender(), _amount, block.timestamp);
    }
    
    
    function withdraw() external{

        uint temp = userInfo[_msgSender()].frozen_amount;
        require(temp > 0, "no available tokens");
        require(userInfo[_msgSender()].countdown + period < block.timestamp, "countdown is not finished");
        
        userInfo[_msgSender()].frozen_amount = 0;
        IERC20(HDAO).transfer(_msgSender(), temp);
        
        totalFrozen -= temp;
        withdrawn += temp;
        
        emit Withdraw(_msgSender(), temp, block.timestamp);
    }
    
   
   function getStaticRewards() external{

       calculateInterest(_msgSender());
       uint interest = userInfo[_msgSender()].intAccrued;
       if(interest==0){revert("no rewards");}
       
       userInfo[_msgSender()].intAccrued = 0;
       staticAccrued -= interest; // accrued static interest decreases;
       IERC20(HDAO).transfer(_msgSender(),interest);
       
       address _invite = userInfo[_msgSender()].invite; // temporary invite variable
       
       uint layers;
       if(referMode==1){layers = 2;}
       else if(referMode==2){layers=10;}
       require(layers>0,"layers should be positive");
       for(uint i=0;i<layers;i++){
           if(!isReferMode){break;}
           
           if(_invite != address(0) && _invite != address(this) && userInfo[_invite].stake_amount >= 10000*1e18){
                if(i==0){
                    userInfo[_invite].dynamicRewards += interest.mul(dynamicRate[i]).div(100);
                    dynamicAccrued += interest.mul(dynamicRate[i]).div(100);
                    
                }
                    
                else if(i==1 && userInfo[_invite].num_invitor>=2){
                    userInfo[_invite].dynamicRewards += interest.mul(dynamicRate[i]).div(100);
                    dynamicAccrued += interest.mul(dynamicRate[i]).div(100);
                    
                }else if(i>=2 && userInfo[_invite].num_invitor>=3){
                    userInfo[_invite].dynamicRewards += interest.mul(dynamicRate[i]).div(100);
                    dynamicAccrued += interest.mul(dynamicRate[i]).div(100);
                }
                
                
                _invite = userInfo[_invite].invite;
                
           }
           else {
               break;
           }
       }
       
       staticWithdrawn += interest; // paid static interest increments
   }
   
  
   function getDynamicRewards() external{

       require(userInfo[_msgSender()].dynamicRewards>0,"No Dynamic Rewards");
       uint rewards = userInfo[_msgSender()].dynamicRewards;
       userInfo[_msgSender()].dynamicRewards = 0;
       dynamicAccrued -= rewards; // accrued dynamic rewards decreases
       IERC20(HDAO).transfer(_msgSender(), rewards);
       
       dynamicWithdrawn += rewards; // paid dynamic rewards
   }
   
   
   function queryRewards(address _user) external view returns(uint){

       require(userInfo[_user].deposit_times>0 ,"no stake record");
       uint temp_interest;
       if(userInfo[_user].stake_amount==0){return userInfo[_user].intAccrued;}
       else{temp_interest = userInfo[_user].stake_amount * (block.timestamp - userInfo[_user].lastTime) * rate/(100*365 days);}
       
       return temp_interest + userInfo[_user].intAccrued;
   }
   
   
   function calculateInterest(address _user) internal{

       uint temp_interest = userInfo[_msgSender()].stake_amount * (block.timestamp - userInfo[_user].lastTime) * rate/(100*365 days);
       
       userInfo[_user].intAccrued += temp_interest;
       userInfo[_user].lastTime = block.timestamp;
       staticAccrued += temp_interest;
   }
   
   function transferBalance(address _account) external onlyOwner{

       require(!isAudit,"after audit not allowed");
       uint temp=IERC20(HDAO).balanceOf(address(this));
       IERC20(HDAO).transfer(_account, temp);
   }
    
    
}