
pragma solidity ^0.4.16;


contract ERC20 {

    

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);


  function totalSupply() public constant returns (uint);

  function balanceOf(address _owner) public constant returns (uint balance);

  function transfer(address _to, uint _value) public returns (bool success);

  function transferFrom(address _from, address _to, uint _value) public returns (bool success);

  function approve(address _spender, uint _value) public returns (bool success);

  function allowance(address _owner, address _spender) public constant returns (uint remaining);


}

contract Owned {

    address public owner;
    address public newOwner;
    
     event OwnershipTransferProposed(address indexed _from, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {

        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    modifier checkpermission{

       require(msg.sender == owner && HODLwin2Eth(msg.sender).owner() == owner);
        _;
    }

       function transferOwnership(address _newOwner) public onlyOwner {

    require( _newOwner != owner );
    require( _newOwner != address(0x0) );
    OwnershipTransferProposed(owner, _newOwner);
    newOwner = _newOwner;
  }

  function acceptOwnership() public {

    require(msg.sender == newOwner);
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract HODLwin2Eth is Owned {


    address public HODLaddress;       // address of token
    uint256 public mktValue;    // contract buys lots of token at this price
    uint256 public units;       // lot size (token-wei)
    uint256 public origMktValue; //the original crowdsale price
    event HODLrSoldWin(address indexed seller, uint256 amountOfTokensToSell,
        uint256 tokensSold, uint256 etherValueOfTokensSold);
    event mktValueupdated(uint _mktValue);
    
    function HODLwin2Eth (
        address _HODLaddress,
        uint256 _mktValue,
        uint256 _units,
        uint256 _origMktValue
                ) public {
        HODLaddress       = _HODLaddress;
        mktValue    = _mktValue;
         units       = _units;
         origMktValue = _origMktValue;
           }

    
    function HODLrSellWin(uint256 amountOfTokensToSell) public {

            uint256 can_buy = this.balance / mktValue;
            uint256 order = amountOfTokensToSell / units;
            if(order > can_buy) order = can_buy;
           if(order > 0){
           
             require (ERC20(HODLaddress).transferFrom(msg.sender, address(this), order * units));
             require (msg.sender.send(order * mktValue));
           }
           
            HODLrSoldWin(msg.sender, amountOfTokensToSell, order * units, order * mktValue);
        
    }

function updatemktValue(uint _mktValue) public onlyOwner {

	
    require(_mktValue >= origMktValue);
	mktValue = _mktValue;
   mktValueupdated(_mktValue);
  }
  
   function () public payable {
      
    }
}

contract HODLwin2EthExchanger is Owned {


    event TradeListing(address indexed ownerAddress, address indexed HODLwin2EthAddress,
        address indexed HODLaddress, uint256 mktValue, uint256 units, uint256 origMktValue);
 

    mapping(address => bool) _verify;

    function verify(address tradeContract) public  constant returns (
        bool    valid,
        address owner,
        address HODLaddress,
        uint256 mktValue,
        uint256 units,
        uint256 origMktValue
      
    ) {

        valid = _verify[tradeContract];
      require (valid);
            HODLwin2Eth t = HODLwin2Eth(tradeContract);
            owner         = t.owner();
            HODLaddress    = t.HODLaddress();
            mktValue      = t.mktValue();
            units         = t.units();
            origMktValue = t.origMktValue();
 }

    function createTradeContract(
        address HODLaddress,
        uint256 mktValue,
        uint256 units,
        uint256 origMktValue
    ) public returns (address trader) {

        require (HODLaddress != 0x0);
        uint256 allowance = ERC20(HODLaddress).allowance(msg.sender, this);
        allowance= allowance;
        require(mktValue > 0);
        require(units > 0);

        trader = new HODLwin2Eth(
            HODLaddress,
            mktValue,
            units,
            origMktValue
            );
        _verify[trader] = true;
        HODLwin2Eth(trader).transferOwnership(msg.sender);
        TradeListing(msg.sender, trader, HODLaddress, mktValue, units, origMktValue);
    }

   
   function () public payable {
    
  }
   
}