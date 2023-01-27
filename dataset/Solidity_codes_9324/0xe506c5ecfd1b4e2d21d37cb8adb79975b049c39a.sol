
pragma solidity 0.6.2;



contract Ownable
{


  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor()
    public
  {
    owner = msg.sender;
  }

  modifier onlyOwner()
  {

    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }

  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {

    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}



library SafeMath
{

  string constant OVERFLOW = "008001";
  string constant SUBTRAHEND_GREATER_THEN_MINUEND = "008002";
  string constant DIVISION_BY_ZERO = "008003";

  function mul(
    uint256 _factor1,
    uint256 _factor2
  )
    internal
    pure
    returns (uint256 product)
  {

    if (_factor1 == 0)
    {
      return 0;
    }

    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2, OVERFLOW);
  }

  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {

    require(_divisor > 0, DIVISION_BY_ZERO);
    quotient = _dividend / _divisor;
  }

  function sub(
    uint256 _minuend,
    uint256 _subtrahend
  )
    internal
    pure
    returns (uint256 difference)
  {

    require(_subtrahend <= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);
    difference = _minuend - _subtrahend;
  }

  function add(
    uint256 _addend1,
    uint256 _addend2
  )
    internal
    pure
    returns (uint256 sum)
  {

    sum = _addend1 + _addend2;
    require(sum >= _addend1, OVERFLOW);
  }

  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder)
  {

    require(_divisor != 0, DIVISION_BY_ZERO);
    remainder = _dividend % _divisor;
  }

}


contract ERC20Token {

 
    function totalSupply() external view returns (uint256){}

    function balanceOf(address account) external view returns (uint256){}
    function allowance(address owner, address spender) external view returns (uint256){}

    function transfer(address recipient, uint256 amount) external returns (bool){}
    function approve(address spender, uint256 amount) external returns (bool){}

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function decimals()  external view returns (uint8){}

  
}



contract MEX is
  Ownable
{

    using SafeMath for uint256;
   
    modifier onlyPriceManager() {

      require(
          msg.sender == price_manager,
          "only price manager can call this function"
          );
          _;
    }
  
   
   
    ERC20Token token;
    
   
    address ERC20Contract = 0x0000000000000000000000000000000000000000;
    address price_manager = 0x0000000000000000000000000000000000000000;
    
    uint256 adj_constant = 1000000000000000000; 
    
    uint256  sell_price = 2000000000000000; 
    
    uint256  buyout_price = 1000000000000000; 
    
    event Bought(uint256 amount, address wallet);
    event Sold(uint256 amount, address wallet);
    event TokensDeposited(uint256 amount, address wallet);
    event FinneyDeposited(uint256 amount, address wallet);
    event Withdrawn(uint256 amount, address wallet);
    event TokensWithdrawn(uint256 amount, address wallet);
   
    constructor() public {
        price_manager = owner;
    }
    
    
    function setPriceManagerRight(address newPriceManager) external onlyOwner{

          price_manager = newPriceManager;
    }
      
      
    function getPriceManager() public view returns(address){

        return price_manager;
    }
    
    
    function setERC20(address newERC20Contract) external onlyOwner returns(bool){

        
        ERC20Contract = newERC20Contract;
        token = ERC20Token(ERC20Contract); 
    }
    
    
    function getERC20() external view returns(address){

        return ERC20Contract;
    }

    function setAdjConstant(uint256 new_adj_constant) external onlyOwner{

        adj_constant = new_adj_constant;
    }
    
    function getAdjConstant() external view returns(uint256){  

        return adj_constant;
    }
 
    function setSellPrice(uint256 new_sell_price) external onlyPriceManager{

        sell_price = new_sell_price;
    }
    
    function setBuyOutPrice(uint256 new_buyout_price) external onlyPriceManager{

        buyout_price = new_buyout_price;
    }
    
    function getSellPrice() external view returns(uint256){  

        return sell_price;
    }
    
    function getBuyOutPrice() external view returns(uint256){  

        return buyout_price;
    }
    
    
    
    function calcCanBuy(uint256 forWeiAmount) external view returns(uint256){

        require(forWeiAmount > 0,"forWeiAmount should be > 0");
        uint256 amountTobuy = forWeiAmount.div(sell_price);
       
        return amountTobuy; 
    }
    
     
    function calcCanGet(uint256 tokensNum) external view returns(uint256){

        require(tokensNum > 0,"tokensNum should be > 0"); //it is "frontend" tokens
        uint256 amountToGet = tokensNum.mul(buyout_price);
        return amountToGet; //wei
    }
    
    
    function buy() payable external notContract returns (bool) {

        uint256 amountSent = msg.value; //in wei..
        require(amountSent > 0, "You need to send some Ether");
         uint256 dexBalance = token.balanceOf(address(this));
        uint256 amountTobuy = amountSent.div(sell_price); //tokens as user see them
       
        uint256 realAmountTobuy = amountTobuy.mul(adj_constant); //tokens adjusted to real ones
        
       
        
        require(realAmountTobuy > 0, "not enough ether to buy any feasible amount of tokens");
        require(realAmountTobuy <= dexBalance, "Not enough tokens in the reserve");
        
        try token.transfer(msg.sender, realAmountTobuy) { //ensure we revert in case of failure
            emit Bought(amountTobuy, msg.sender);
            return true;
        } catch {
            require(false,"transfer failed");
        }
        
        return false;
    }
    
    
    function sell(uint256 amount_tokens) external notContract returns(bool) {

        uint256 amount_wei = 0;
        require(amount_tokens > 0, "You need to sell at least some tokens");
        uint256 realAmountTokens = amount_tokens.mul(adj_constant);
        
        uint256 token_bal = token.balanceOf(msg.sender);
        require(token_bal >= realAmountTokens, "Check the token balance on your wallet");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= realAmountTokens, "Check the token allowance");
       
        amount_wei = amount_tokens.mul(buyout_price); //convert to wei
        
        
        require(address(this).balance > amount_wei, "unsufficient funds");
        bool success = false;
       
        try token.transferFrom(msg.sender, address(this), realAmountTokens) { 
        } catch {
            require(false,"tokens transfer failed");
            return false;
        }
        
        
       
        (success, ) = msg.sender.call.value(amount_wei)("");
        require(success, "Transfer failed.");
        
      
        emit Sold(amount_tokens, msg.sender);
        return true; //normal completion
       
    }


    
    function getContractBalance() external view returns (uint256) {

        return address(this).balance;
    }
    
    function getContractTokensBalance() external view returns (uint256) {

        return token.balanceOf(address(this));
    }
    
   
    
    function withdraw(address payable sendTo, uint256 amount) external onlyOwner {

        require(address(this).balance >= amount, "unsufficient funds");
        bool success = false;
        (success, ) = sendTo.call.value(amount)("");
        require(success, "Transfer failed.");
        emit Withdrawn(amount, sendTo); //wei
    }
  
    
    function deposit(uint256 amount) payable external onlyOwner { //amount in finney

        require(amount*(1 finney) == msg.value,"please provide value in finney");
        emit FinneyDeposited(amount, owner); //in finney
    }

    function depositTokens(uint256 amount) external onlyOwner {

        require(amount > 0, "You need to deposit at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        
        emit TokensDeposited(amount.div(adj_constant), owner);
    }
    
  
    function withdrawTokens(address to_wallet, uint256 amount_tokens) external onlyOwner{

        require(amount_tokens > 0, "You need to withdraw at least some tokens");
        uint256 realAmountTokens = amount_tokens.mul(adj_constant);
        uint256 contractTokenBalance = token.balanceOf(address(this));
        
        require(contractTokenBalance > realAmountTokens, "unsufficient funds");
      
       
        
        try token.transfer(to_wallet, realAmountTokens) { 
        } catch {
            require(false,"tokens transfer failed");
           
        }
        
    
        emit TokensWithdrawn(amount_tokens, to_wallet);
    }
    
    
    function walletTokenBalance(address wallet) external view returns(uint256){

        return token.balanceOf(wallet);
    }
    
    function walletTokenAllowance(address wallet) external view returns (uint256){

        return  token.allowance(wallet, address(this)); 
    }
    
    
    function isContract(address _addr) internal view returns (bool){

      uint32 size;
      assembly {
          size := extcodesize(_addr)
      }
      
      return (size > 0);
    }
    
    modifier notContract(){

      require(
          (!isContract(msg.sender)),
          "external contracts are not allowed"
          );
          _;
    }
}