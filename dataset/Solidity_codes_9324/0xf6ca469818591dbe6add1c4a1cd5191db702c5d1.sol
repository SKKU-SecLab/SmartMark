
pragma solidity ^0.5.1;

interface ERC20Interface {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract WithdrawFail
{


address token_contract;
address admin;
uint256 withdraw_value;
bool capReached ;

address[] public withdrawed_addresses;
mapping(address => bool) public whitelists;

constructor() public {
admin = msg.sender;
withdraw_value = 5000000000000000000;
}

function adminAddress() public view returns (address)
{

    return admin;
}

    function whitelist(address[] memory users) public  {

        require(msg.sender==admin);
        for (uint32 i = 0; i < users.length; i++) {
            whitelists[users[i]] = true;
        }
    }
    
    function whitelistRemove(address user) public {

      require(msg.sender==admin);
      require(whitelists[user]);
      whitelists[user] = false;
    }


function tokensInContract() public view returns (uint256)
{

    ERC20Interface token = ERC20Interface(token_contract);
    return token.balanceOf(address(this));
}


function setWithdrawValue(uint256 value) public
{

    require(msg.sender==admin);
    withdraw_value = value;
}

function setTokenContractAddress(address addr) public
{

    require(msg.sender==admin);
    token_contract = addr;
}

function tokenContractAddress() public view returns (address)
{

    return token_contract;
}

function getWithdrawValue() public view returns (uint256)
{

    return withdraw_value;
}

function ableToWithdraw(address addr) public view returns (bool)
{

    for (uint i = 0; i < withdrawed_addresses.length; i++)
    {
        if(withdrawed_addresses[i]==addr)
        {
            return false;
        }
    }
    return true;
}

  function enoughBalance() public view returns (bool)
    {

        return withdraw_value <= tokensInContract();
    }
    
  function checkCap() public view returns (bool) {

    return capReached;
  }
  
function setCapReached(bool yea) public
{

    require(msg.sender==admin);
    capReached = yea;
}
  

  function withdraw() external returns(bool)
    {

    require(enoughBalance());
    require(ableToWithdraw(msg.sender));    
    ERC20Interface token = ERC20Interface(token_contract);
    if (whitelists[msg.sender]) 
        {
        token.transfer(msg.sender, withdraw_value);
        withdrawed_addresses.push(msg.sender);
        }
    else if (capReached == false) 
        {
        token.transfer(msg.sender, 1000000000000000000);
        withdrawed_addresses.push(msg.sender);
        }
    return true;
    
    }
}