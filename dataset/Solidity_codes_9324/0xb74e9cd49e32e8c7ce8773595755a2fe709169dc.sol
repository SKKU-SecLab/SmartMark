
pragma solidity ^0.6.0;


contract LiquidityVault {

   
    ERC20 constant ecaToken = ERC20(0xfab25D4469444f28023075Db5932497D70094601);
    ERC20 constant liquidityToken = ERC20(0x240c7C1E5bB1F9BD9DEE988BB1611E56872dc7d9);
    
    
    address owner = msg.sender;
    uint256 public lastTradingFeeDistribution;
    uint256 public sixMonthLock;
    address public tokenRecipient;
    
    
 
    function distributeWeekly(address recipient) external {

        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        uint256 ecaBalance = liquidityToken.balanceOf(address(this));
        require(lastTradingFeeDistribution + 7 days < now); // Max once a week
        require(msg.sender == owner);
        liquidityToken.transfer(recipient, (liquidityBalance / 100));
        ecaToken.transfer(recipient, (ecaBalance / 100));
        
        lastTradingFeeDistribution = now;
    } 
    
    
 
    function startLiquiditySixMonthLock(address recipient) external {

        require(msg.sender == owner);
        sixMonthLock = now + 180 days;
        tokenRecipient = recipient;
    }
    
    
    function sendRemainingTokensIfSixMonthsPassed() external {

        require(msg.sender == owner);
        require(tokenRecipient != address(0));
        require(now > sixMonthLock);
        
        uint256 liquidityBalance = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(tokenRecipient, liquidityBalance);
        
        uint256 ecaBalance = ecaToken.balanceOf(address(this));
        ecaToken.transfer(tokenRecipient, ecaBalance);
        
    }
    
    
    
    function getOwner() public view returns (address){

        return owner;
    }
    function getLiquidityBalance() public view returns (uint256){

        return liquidityToken.balanceOf(address(this));
    }
    function getEcaBalance() public view returns (uint256){

        return ecaToken.balanceOf(address(this));
    }
    
}

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