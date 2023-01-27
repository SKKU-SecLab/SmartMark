
pragma solidity ^0.5.0;


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

contract IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() public view returns (uint8);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract IERC20Mintable {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() public view returns (uint8);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address _to,uint256 _value) public;

    function burn(uint256 _value) public;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract TokenFarm {

    using SafeMath for uint256;
	modifier onlyOwner {

        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
	modifier onlyModerators {

        require(
            Admins[msg.sender]==true,
            "Only owner can call this function."
        );
        _;
    }

    address public owner;
    string public name = "Dapp Token Farm";
    IERC20Mintable public dappToken;

    
    struct staker {
        uint256 id;
        mapping(address=> uint256) balance;
        mapping(address=> uint256) timestamp;
        mapping(address=> uint256) timefeestartstamp; 

    }

    struct rate {
        uint256 rate;
        bool exists;
    }

    mapping(address => uint256) public totalStaked;
    address[] private tokenPools; 
    mapping(address => staker) stakers;
    mapping(address => rate) public RatePerCoin;
	mapping (address=>bool) Admins;
    uint256 public minimumDaysLockup=3;
    uint256 public penaltyFee=10;
    constructor(IERC20Mintable _dapptoken, address _spiritclashtoken)
        public
    {
        dappToken = _dapptoken;
        owner = msg.sender;
        Admins[msg.sender]=true;
		setCoinRate(_spiritclashtoken,80000);
    }

    function stakeTokens(uint256 _amount,IERC20 token) external { // remove payable

		require(RatePerCoin[address(token)].exists==true,"token doesnt have a rate");
        require(_amount > 0, "amount cannot be 0");
        if (stakers[msg.sender].balance[address(token)] > 0) {
            claimToken(address(token));
        }

        token.transferFrom(msg.sender, address(this), _amount);

        stakers[msg.sender].balance[address(token)] = stakers[msg.sender].balance[address(token)].add( _amount);
        totalStaked[address(token)] = totalStaked[address(token)].add( _amount);
        stakers[msg.sender].timestamp[address(token)] = block.timestamp;
        stakers[msg.sender].timefeestartstamp[address(token)] = block.timestamp;
    }


    function unstakeToken(IERC20 token) external {

        uint256 balance = stakers[msg.sender].balance[address(token)];

        require(balance > 0, "staking balance cannot be 0");
        if( (block.timestamp.sub(stakers[msg.sender].timefeestartstamp[address(token)])) < (minimumDaysLockup*24*60*60)){  
            uint256 fee = (balance.mul(100).div(penaltyFee)).div(100);
            token.transfer(owner, fee);
            balance = balance.sub(fee); 
        }
        claimTokens();

        stakers[msg.sender].balance[address(token)] = 0;
        totalStaked[address(token)] = totalStaked[address(token)].sub(balance);
        token.transfer(msg.sender, balance);
    }

    function unstakeTokens() external{ // this is fine

        
        claimTokens();
        for (uint i=0; i< tokenPools.length; i++){
            uint256 balance = stakers[msg.sender].balance[tokenPools[i]];
            if(balance > 0){
                totalStaked[tokenPools[i]] = totalStaked[tokenPools[i]].sub(balance);
                stakers[msg.sender].balance[tokenPools[i]] = 0;
                if((block.timestamp.sub(stakers[msg.sender].timefeestartstamp[tokenPools[i]])) < (minimumDaysLockup*24*60*60)){
                    uint256 fee = (balance.mul(100).div(penaltyFee)).div(100);
                    balance = balance.sub(fee);
                    IERC20(tokenPools[i]).transfer(owner, fee);
                }
                IERC20(tokenPools[i]).transfer(msg.sender, balance);
            }
        }
    }

	function earned(address token) public view returns(uint256){ // this is fine

        uint256 multiplier =100000000;
		return (stakers[msg.sender].balance[token]* 
            (RatePerCoin[token].rate) * //coin earn rate in percentage so should be divided by 100
                ( 
                    (stakers[msg.sender].balance[token]*multiplier)/(totalStaked[token]) //calculate token share percentage
                )/(365*24*60*60)// 31 536 000
            *(
                block.timestamp.sub(stakers[msg.sender].timestamp[token]) // get time
                
            )
        )/multiplier/10;
	}


    function claimTokens() public { // This function looks good to me.

        uint256 rewardbal=0;
		for (uint i=0; i< tokenPools.length; i++){
            address token = tokenPools[i];
            if(stakers[msg.sender].balance[token]>0){
                uint256 earnings = earned(token);
                stakers[msg.sender].timestamp[token]=block.timestamp;
                rewardbal= rewardbal.add(earnings);
            }
        }
        IERC20Mintable(dappToken).mint(msg.sender, rewardbal);
    }
    function claimToken(address token) public { // For sure an issue

        require(stakers[msg.sender].balance[token]>0,"you have no balance and cant claim");
        uint256 earnings = earned(token);
        stakers[msg.sender].timestamp[token]=block.timestamp;
        IERC20Mintable(dappToken).mint(msg.sender, earnings);
    }
    
    function setMinimumLockup(uint256 _days) external onlyModerators {

        minimumDaysLockup =_days;
    }
    
    function setPenaltyFee(uint256 _fee) external onlyModerators {

        penaltyFee =_fee;
    }

    function transferOwnership(address _newOwner) external onlyOwner{

        owner=_newOwner;
    }

    function setCoinRate(address coin,uint256 Rate) public onlyModerators {

        RatePerCoin[coin].rate =Rate;
        if(RatePerCoin[coin].exists == false){
            tokenPools.push(coin);
            RatePerCoin[coin].exists = true;
        }
    }

	function setAdmin(address addy,bool value) external onlyOwner{

		Admins[addy]= value;
	}
    function stakingBalance(address token) external view returns(uint256) {

        return stakers[msg.sender].balance[token];
    }
}

pragma solidity ^0.5.0;

contract ClashPay {

    using SafeMath for uint256;
    string  public name = "Clash Pay";
    string  public symbol = "SCP";
    uint256 public totalSupply = 10000000000000000000;
    uint8   public decimals = 18;
    address public owner;
    address public Tokenfarm;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Burn(
        address indexed burner,
        uint256 value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        owner= msg.sender;
    }
    function setContract(address _contract) external{

        require(msg.sender==owner,"must be owner");
        Tokenfarm=_contract;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {

        require(address(0)!= _to,"to burn tokens use the burn function");
        balanceOf[msg.sender] =balanceOf[msg.sender].sub( _value);
        balanceOf[_to] = balanceOf[_to].add( _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool success) {

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {

        require(address(0)!= _to,"to burn tokens use the burn function");
        balanceOf[_from] = balanceOf[_from].sub( _value); // msg.sender => _from
        balanceOf[_to] = balanceOf[_to].add( _value);
        allowance[_from][msg.sender] =allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function mint(address _to,uint256 _value) public {

        require(msg.sender==Tokenfarm,"only Tokenfarm contract can mint tokens");
        totalSupply= totalSupply.add( _value);
        balanceOf[_to]=balanceOf[_to].add(_value);
        emit Transfer(address(0),msg.sender,_value);
    }
    function burn(uint256 _value) public{

        balanceOf[msg.sender] =balanceOf[msg.sender].sub( _value);
        emit Burn(msg.sender,_value);
        emit Transfer(msg.sender,address(0),_value);
    }
    function transferOwnership(address _newOwner) external{

        require(msg.sender==owner,"only the owner an call this function");
        owner=_newOwner;

    }

}