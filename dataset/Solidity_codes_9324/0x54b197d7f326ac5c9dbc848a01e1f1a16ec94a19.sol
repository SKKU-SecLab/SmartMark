pragma solidity ^0.6.0;

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// MIT
pragma solidity ^0.6.0;


contract SwissVault {

    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 21000000 * 10 ** 18;
    string public name = "SwissVault";
    string public symbol = "SVLT";
    uint public decimals = 18;
    uint public lastBTCPrice = 0;
    uint public burnRatePerc = 0;
    bool public isBurn = true;
    address private owner;
    
    AggregatorV3Interface internal priceFeed;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() public {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C);
    }
    
    modifier onlyOwner() {

        require(owner == msg.sender);
            _;
    }
    
    function getBTCPrice() public view returns (int) {

        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    } 
    
    function setLastBTCPrice(uint value) onlyOwner public {

      lastBTCPrice = value;    
    }
    
    function setIsBurn(bool value) onlyOwner public {

      isBurn = value;    
    }    
    
    function calculateBurnRate(uint value) private returns (uint)  {

        if (isBurn == false){
          lastBTCPrice = 0;    
        }else if (lastBTCPrice == 0) {
          lastBTCPrice = uint(getBTCPrice());   
        }
        
        uint currentBTCPrice = uint(getBTCPrice());
        
        burnRatePerc = (lastBTCPrice * 1000) / currentBTCPrice;
        lastBTCPrice = currentBTCPrice;
        
        return (value * burnRatePerc) / 100000;
      }    
    
    
    function balanceOf(address owners) public view returns(uint){

        return balances[owners];
    }
    
    function transfer(address to, uint value) public returns(bool){

        require(balanceOf(msg.sender) >= value, 'balance too low');
        
        uint tokensToBurn = calculateBurnRate(value);
        uint tokensToTransfer = value - tokensToBurn;        

        balances[msg.sender] = balances[msg.sender] - value;
        balances[to] = balances[to] + tokensToTransfer;  
        
        totalSupply = totalSupply - tokensToBurn;

        emit Transfer(msg.sender, to, tokensToTransfer);
        emit Transfer(msg.sender, address(0), tokensToBurn);

        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool){

        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        
        uint tokensToBurn = calculateBurnRate(value);
        uint tokensToTransfer = value - tokensToBurn;          
        
        balances[from] = balances[from] - value;
        balances[to] = balances[to] + tokensToTransfer;  
        
        totalSupply = totalSupply - tokensToBurn;

        emit Transfer(from, to, tokensToTransfer);
        emit Transfer(from, address(0), tokensToBurn);
        
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool){

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}