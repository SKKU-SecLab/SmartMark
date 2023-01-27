

pragma solidity ^0.6.0;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


interface ZinFinance {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract zinStake {

     address burnWallet;
     constructor( ZinFinance _token,address _burnWallet) public {
      burnWallet=_burnWallet;
      token=_token;
      owner = msg.sender;
       }
     using SafeMath for uint256;
    uint256 public percentage=2;
    mapping(address=>uint256) public rewardsGiven;
    mapping(address=>uint256) public prevReward;
    address public contractAddress=address(this);
     address payable owner;
     address[] public stakeholders;

     mapping(address => uint256) public stakes;
     mapping(address => uint256) public deposit_time;

    
    ZinFinance public token;
event stakezin(
        uint256 timestamp,
        address _Staker,
        uint256 token,
        string nature
    );
    event unstakeEvent(
        uint256 timestamp,
        address _Staker,
        uint256 token,
        string nature
    );
    modifier onlyOwner(){

    require(msg.sender==owner);
    _;
    }
    modifier onlyBurnwalletowner(){

    require(msg.sender==burnWallet);
    _;
    }

    function stakeZin(uint256 _stake)
        public
    { 

        address _Staker=msg.sender;
        require(token.balanceOf(_Staker)>=_stake,"You don't have enough Zin tokens to Stake");
        token.transferFrom(_Staker,address(this),_stake);
        if(stakes[_Staker] == 0){
         deposit_time[_Staker]=now;
         addStakeholder(_Staker);
        }
        stakes[_Staker] +=_stake;
       emit stakezin(
            block.timestamp, 
            _Staker, 
            _stake, 
            "stake"
        );
    }
     function setBurnPercentage(uint256 _percentage)public onlyOwner{

        percentage=_percentage;
    }
    function addStakeholder(address _stakeholder)
        private
    {

        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {

        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }
    
    function totalStakes()
        public
        view
        returns(uint256)
    {

        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }
    function unStakeZin(uint256 _amount)
        public
    {   address _stakeholder=msg.sender;

        uint256 stakedZin=stakes[_stakeholder];
        require(stakedZin>=_amount,"You don't have enough Zin tokens to Unstake");
        uint256 stakingWallet=(_amount.div(100)).mul(percentage);
        uint256 unStakedZin=_amount.sub(stakingWallet);
        token.transfer(burnWallet,stakingWallet);
        token.transfer(_stakeholder,unStakedZin);
        stakes[_stakeholder]=stakedZin.sub(stakingWallet.add(unStakedZin));
        if(stakes[_stakeholder]==0){
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
        }
         emit unstakeEvent(
            block.timestamp, 
            msg.sender, 
            _amount, 
            "unstake"
        );
    }
    function sendGasFee(uint256 _amount) payable public{}

    function getGasFee(uint256 _amount)public onlyOwner{
        owner.transfer(_amount*1000000000000000000);
    }
    function getTokens(uint256 _amount)public
    onlyOwner{

        token.transfer(owner,_amount*1000000000000000000);
    }
    function destroy()
    public
    onlyOwner
    {

        require(token.transfer(owner,token.balanceOf(address(this))),"Balance is not transferring to the owner");
        selfdestruct(owner);
    }

}