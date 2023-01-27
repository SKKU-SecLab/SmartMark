
pragma solidity 0.6.4;


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



contract SWAPCONTRACT{

    
   using SafeMath for uint256;
    
   address public V1;
   address public V2;
   bool swapEnabled;
   address administrator;
   
   constructor() public {
       
	    administrator = msg.sender;
		swapEnabled = false;
		
	}
	

	modifier onlyCreator() {

        require(msg.sender == administrator, "Ownable: caller is not the administrator");
        _;
    }
   
   function tokenConfig(address _v1Address, address _v2Address) public onlyCreator returns(bool){

       require(_v1Address != address(0) && _v2Address != address(0), "Invalid address has been set");
       V1 = _v1Address;
       V2 = _v2Address;
       return true;
       
   }
   
   
   function swapStatus(bool _status) public onlyCreator returns(bool){

       require(V1 != address(0) && V2 != address(0), "V1 and V2 addresses are not set up yet");
       swapEnabled = _status;
   }
   
   
   
   
   function swap(uint256 _amount) external returns(bool){

       
       require(swapEnabled, "Swap not yet initialized");
       require(_amount > 0, "Invalid amount to swap");
       require(IERC20(V1).balanceOf(msg.sender) >= _amount, "You cannot swap more than what you hold");
       require(IERC20(V2).balanceOf(address(this)) >= _amount, "Insufficient amount of tokens to be swapped for");
       require(IERC20(V1).allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance given to contract");
       
       require(IERC20(V1).transferFrom(msg.sender, address(this), _amount), "Transaction failed on root");
       require(IERC20(V2).transfer(msg.sender, _amount), "Transaction failed from base");
       
       return true;
       
   }
   
   function swapAll() external returns(bool){

       
       require(swapEnabled, "Swap not yet initialized");
       uint v1userbalance = IERC20(V1).balanceOf(msg.sender);
       uint v2contractbalance = IERC20(V2).balanceOf(address(this));
       
       require(v1userbalance > 0, "You cannot swap on zero balance");
       require(v2contractbalance >= v1userbalance, "Insufficient amount of tokens to be swapped for");
       require(IERC20(V1).allowance(msg.sender, address(this)) >= v1userbalance, "Insufficient allowance given to contract");
       
       require(IERC20(V1).transferFrom(msg.sender, address(this), v1userbalance), "Transaction failed on root");
       require(IERC20(V2).transfer(msg.sender, v1userbalance), "Transaction failed from base");
       
       return true;
       
   }
   
   
   function GetLeftOverV1() public onlyCreator returns(bool){

      
      require(administrator != address(0));
      require(administrator != address(this));
      require(V1 != address(0) && V2 != address(0), "V1 address not set up yet");
      uint bal = IERC20(V1).balanceOf(address(this));
      require(IERC20(V1).transfer(administrator, bal), "Transaction failed");
      
  }
  
  function GetLeftOverV2() public onlyCreator returns(bool){

      
      require(administrator != address(0));
      require(administrator != address(this));
      require(V1 != address(0) && V2 != address(0), "V1 address not set up yet");
      uint bal = IERC20(V2).balanceOf(address(this));
      require(IERC20(V2).transfer(administrator, bal), "Transaction failed");
      
  }
   
    
}