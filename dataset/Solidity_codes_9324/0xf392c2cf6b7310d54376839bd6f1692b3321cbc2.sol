

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
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

interface IUniswapV2Router02 {

  function addLiquidityETH(
  address token,
  uint amountTokenDesired,
  uint amountTokenMin,
  uint amountETHMin,
  address to,
  uint deadline
) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}






 contract uniLock {

    using Address for address;
    using SafeMath for uint;
    address factory;
    uint public locked = 0;
    uint  burnt = 0;
    uint public unlock_date = 0;
    address public owner;
    address public token;
    uint public softCap;
    uint public hardCap;
    uint public start_date;
    uint public end_date;
    uint public rate; // coin sale rate 1 ETH = 1 XYZ (rate = 1e18) <=> 1 ETH = 10 XYZ (rate = 1e19) 
    uint public min_allowed;
    uint public max_allowed; // Max ETH 
    uint public collected; // collected ETH
    uint public pool_rate; // uniswap liquidity pool rate  1 ETH = 1 XYZ (rate = 1e18) <=> 1 ETH = 10 XYZ (rate = 1e19)
    uint public lock_duration; // duration wished to keep the LP tokens locked


    constructor() public{
        factory = msg.sender;
        
    }
   

    
    
    
    mapping(address => uint) participant;
    
    function initilaize(uint _softCap,uint _hardCap,uint _start_date,uint _end_date,uint _rate,uint _min_allowed,uint _max_allowed,address _token,address _owner_Address,uint _pool_rate,uint _lock_duration) external returns (uint){

      require(msg.sender == factory,'You are not allowed to initialize a new Campaign');
      owner = _owner_Address; 
      softCap = _softCap;
      hardCap = _hardCap;
      start_date = _start_date;
      end_date = _end_date;
      rate = _rate; 
      min_allowed = _min_allowed;
      max_allowed = _max_allowed;
      token = _token;
      pool_rate = _pool_rate;
      lock_duration = _lock_duration;
    }
    
    function buyTokens() public payable returns (uint){

        require(isLive(),'campaign is not live');
        require((msg.value>= min_allowed)&& (msg.value<= max_allowed) && (msg.value <= getRemaining()),'The contract has insufficent funds or you are not allowed');
        require(IERC20(address(token)).transfer(msg.sender,calculateAmount(msg.value)),"can't transfer");
        participant[msg.sender] = participant[msg.sender].add(msg.value);
        collected = (collected).add(msg.value);
        return 1;
    }
    function unlock(address _LPT,uint _amount) public returns (bool){

        require(locked == 1 || failed(),'liquidity is not yet locked');
        require(block.timestamp >= unlock_date ,"can't receive LP tokens");
        require(msg.sender == owner,'You are not the owner');
        IERC20(address(_LPT)).transfer(msg.sender,_amount);
    }
    
    
    function uniLOCK() public returns(uint){

        require(locked ==0,'Liquidity is already locked');
        require(!isLive(),'Presale is still live');
        require(!failed(),"Presale failed , can't lock liquidity");
        require(softCap <= collected,"didn't reach soft cap");
        require(addLiquidity(),'error adding liquidity to uniswap');
        locked = 1;
        IERC20(address(token)).transfer(address(0x000000000000000000000000000000000000dEaD),IERC20(address(token)).balanceOf(address(this)));
        unlock_date = (block.timestamp).add(lock_duration);

        return 1;
    }
    
    function addLiquidity() internal returns(bool){

        uint liqidityAmount = collected.mul(uint(uniLockFactory(factory).fee())).div(1000);
        IERC20(address(token)).approve(address(uniLockFactory(factory).uni_router()),(hardCap.mul(rate)).div(1e18));
        IUniswapV2Router02(address(uniLockFactory(factory).uni_router())).addLiquidityETH.value(liqidityAmount)(address(token),(liqidityAmount.mul(pool_rate)).div(1e18),0,0,address(this),block.timestamp + 100000000);
        payable(uniLockFactory(factory).toFee()).transfer(collected.sub(liqidityAmount));
        return true;
          
    }
    
    
    function failed() public view returns(bool){

        if((block.timestamp >= end_date) && (softCap > collected)){
            return true;
            
        }
        return false;
    }
    
    function withdrawFunds() public returns(uint){

        require(failed(),"campaign didn't fail");
        require(participant[msg.sender] >0 ,"You didn't participate in the campaign");
        uint withdrawAmount = participant[msg.sender].mul(uint(uniLockFactory(factory).fee())).div(1000);
        (msg.sender).transfer(withdrawAmount);
        payable(uniLockFactory(factory).toFee()).transfer(participant[msg.sender].sub(withdrawAmount));
        participant[msg.sender] = 0;

    }
    
    function isLive() public view returns(bool){

       if((block.timestamp < start_date)) return false;
       if((block.timestamp >= end_date)) return false;
       if((collected >= hardCap)) return false;
       return true;
    }
    function calculateAmount(uint _amount) public view returns(uint){

        return (_amount.mul(rate)).div(1e18);
        
    }
    
    function getRemaining() public view returns (uint){

        return (hardCap).sub(collected);
    }
    function getGivenAmount(address _address) public view returns (uint){

        return participant[_address];
    }
    
  
    


    
}/**
 *Submitted for verification at Etherscan.io on 2020-10-10
*/


pragma solidity 0.6.12;









contract uniLockFactory is uniLock {

    address[] public campaigns;
    address public toFee;
    uint public fee;
    address factory_owner;
    address public unl_address;
    address public uni_router;
    uint balance_required;
    uint active = 1;
    
    constructor(address _UNL,uint min_balance,uint _fee,address _uniRouter) public {
        factory_owner = msg.sender;
        toFee = msg.sender;
        unl_address = _UNL;
        balance_required = min_balance;
        fee = _fee;
        uni_router = _uniRouter;
    }
    modifier only_factory_Owner(){

        require(factory_owner == msg.sender,'You are not the owner');
        _;
    }
    function createCampaign(uint _softCap,uint _hardCap,uint _start_date,uint _end_date,uint _rate,uint _min_allowed,uint _max_allowed,address _token,uint _pool_rate,uint _lock_duration) public returns (address campaign_address){

     require(IERC20(address(unl_address)).balanceOf(msg.sender) >= uint(balance_required),"You don't have the minimum UNL tokens required to launch a campaign");
     require(active==1,'Factory is not active');
     require(_softCap < _hardCap,"Error :  soft cap can't be higher than hard cap" );
     require(_start_date < _end_date ,"Error :  start date can't be higher than end date " );
     require(block.timestamp < _end_date ,"Error :  end date can't be higher than current date ");
     require(_min_allowed < _hardCap,"Error :  minimum allowed can't be higher than hard cap " );
     require(_rate != 0,"rate can't be null");
     bytes memory bytecode = type(uniLock).creationCode;
     bytes32 salt = keccak256(abi.encodePacked(_token, msg.sender));
     assembly {
            campaign_address := create2(0, add(bytecode, 32), mload(bytecode), salt)
     }
     uniLock(campaign_address).initilaize(_softCap,_hardCap,_start_date,_end_date,_rate,_min_allowed,_max_allowed,_token,msg.sender,_pool_rate,_lock_duration);
     campaigns.push(campaign_address);
     require(transferToCampaign(_hardCap,_rate,_pool_rate,_token,campaign_address),"unable to transfer funds");
    }
    function transferToCampaign(uint _hardCap,uint _rate, uint _pool_rate,address _token,address _campaign_address) internal returns(bool){


     require(IERC20(address(_token)).transferFrom(msg.sender,address(_campaign_address),(_hardCap.mul(_rate).div(1e18)).add(_hardCap.mul(_pool_rate).div(1e18))),"unable to transfer token amount to the campaign");
     return true;
    }
   function changeConfig(uint _fee,address _to,uint _balance_required,address _uni_router,address _unl_address) public only_factory_Owner returns(uint){

        fee = _fee;
        toFee = _to;
        balance_required = _balance_required;
        uni_router = _uni_router;
        unl_address = _unl_address;
    }

   function trigger() public only_factory_Owner returns(uint){

        active = active == 1 ? 0 : 1;
    } 

 
    
 


    
}