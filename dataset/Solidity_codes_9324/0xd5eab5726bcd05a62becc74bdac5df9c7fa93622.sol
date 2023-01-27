
pragma solidity 0.4.24;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}

library SafeERC20 {

    function safeTransfer(Token _token, address _to, uint256 _value) internal returns (bool) {

        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            return false;
        }

        address(_token).call(abi.encodeWithSignature("transfer(address,uint256)", _to, _value));

        return prevBalance - _value == _token.balanceOf(address(this));
    }
}

interface Token {

    function transfer(address _to, uint256 _value) external returns (bool success);

    function balanceOf(address who) external view returns (uint256 balance);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

}

contract Sellix {

    using SafeMath for uint256;
    
    address public owner;
    uint public tokenSendFee; // in wei
    uint public ethSendFee; // in wei
    
    constructor() public payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {

      require(msg.sender == owner);
      _;
    }
    
    function balance() public constant returns (uint value) {

        return address(this).balance;
    }
    
    function balanceToken(Token tokenAddr) public constant returns (uint value) {

        return tokenAddr.balanceOf(address(this));
    }
    
    function deposit() payable public returns (bool) {

        return true;
    }
    
    function withdrawEth(address addr, uint amount) public onlyOwner returns(bool success) {

        addr.transfer(amount * 1 wei);
        return true;
    }
    
    function withdrawToken(Token tokenAddr, address _to, uint _amount) public onlyOwner returns(bool success) {

        SafeERC20.safeTransfer(tokenAddr, _to, _amount);
        return true;
    }
    
    function multiPayoutToken(Token tokenAddr, address[] addresses, uint256[] amounts) public onlyOwner returns(bool success) {

        uint total = 0;

        for (uint8 i = 0; i < amounts.length; i++) {
            total = total.add(amounts[i]);
        }
        
        require(total <= tokenAddr.balanceOf(address(this)), "Not enough token balance");
        
        for (uint8 j = 0; j < addresses.length; j++) {
            SafeERC20.safeTransfer(tokenAddr, addresses[j], amounts[j]);
        }
        
        return true;
    }
    
    function multiPayoutEth(address[] addresses, uint256[] amounts) public onlyOwner returns(bool success) {

        uint total = 0;

        for (uint8 i = 0; i < amounts.length; i++){
            total = total.add(amounts[i]);
        }
        
        uint requiredAmount = total.add(ethSendFee * 1 wei);
        require(address(this).balance >= (requiredAmount * 1 wei), "Not enough balance");
        
        for (uint8 j = 0; j < addresses.length; j++) {
            addresses[j].transfer(amounts[j] * 1 wei);
        }

        return true;
    }
    
    function setTokenFee(uint _tokenSendFee) public onlyOwner returns(bool success) {

        tokenSendFee = _tokenSendFee;
        return true;
    }
    
    function setEthFee(uint _ethSendFee) public onlyOwner returns(bool success) {

        ethSendFee = _ethSendFee;
        return true;
    }
 
    function contractAddress() public onlyOwner constant returns (address) {

        return address(this);
    }

    function destroy (address _to) public onlyOwner {
        selfdestruct(_to);
    }
}