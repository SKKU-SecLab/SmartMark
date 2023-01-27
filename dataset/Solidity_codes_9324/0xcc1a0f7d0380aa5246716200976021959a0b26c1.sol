
pragma solidity ^0.6.7;



 library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor() public {
    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

interface Token {

    function transfer(address, uint) external returns (bool);

}

contract DEFISocialPreSale is Ownable {

  using SafeMath for uint;

    address payable public constant token = payable(0x731A30897bF16597c0D5601205019C947BF15c6E);

  address payable public wallet;

  uint256 public weiRaised;
  

  uint256 public cap;
  uint256 public tokensLeft;
  uint256 public tokensBought;

  uint256 public minInvestment;

  uint256 public rate;

  bool public isFinalized ;



  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  event Finalized();




  function start(address payable _wallet, uint256 _minInvestment, uint256 _cap, uint256 _rate) public onlyOwner {

    
    require(_wallet != 0x0000000000000000000000000000000000000000);
    require(_minInvestment >= 0);
    require(_cap > 0);
 
    wallet = _wallet;
    rate = _rate;
    minInvestment = _minInvestment;  //minimum investment in wei  (=10 ether)
    cap = _cap * (10**18);  //cap in tokens base units (=295257 tokens)
    tokensBought = 0;
    tokensLeft = cap;
  }

     function tokBought() view public  returns (uint256) {

    return tokensBought;
  }
    function tokLeft() view public  returns (uint256) {

    return tokensLeft;
  }
  

  receive () external payable {
      if(msg.sender == owner){
          
      }else{
          buyTokens(msg.sender, msg.value);
      }
   
  }
  
    
  
  function buyTokens(address beneficiary, uint256 amount)  public payable {

    require(beneficiary != 0x0000000000000000000000000000000000000000, "Error");
    require(validPurchase(), "Not a valid purchase");
    require(!isFinalized, "Finalized");
    require(tokensLeft > 0, "No more tokens left");
    


    uint256 weiAmount = amount;
    
    uint256 tokens = weiAmount.mul(rate);

    require(Token(token).transfer(beneficiary, tokens), "Could not transfer tokens.");
    tokensBought = tokensBought.add(tokens);
    tokensLeft = tokensLeft.sub(tokens);
    weiRaised = weiRaised.add(weiAmount);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
    
  }

  function forwardFunds() internal {

    wallet.transfer(msg.value);
  }

  function validPurchase() internal  returns (bool) {


    uint256 weiAmount = weiRaised.add(msg.value);
    bool notSmallAmount = msg.value >= minInvestment;
    bool withinCap = weiAmount.mul(rate) <= tokensLeft;

    return (notSmallAmount && withinCap);
  }

  function end() private onlyOwner {

    require(!isFinalized);
    require(hasEnded());

    Finalized();

    isFinalized = true;
  }



   function hasEnded() view public  returns (bool) {

    bool capReached = (weiRaised.mul(rate) >= cap);
    return capReached;
  }
    


}