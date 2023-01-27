
pragma solidity 0.5.1;
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

contract Token {

  function totalSupply() pure public returns (uint256 supply);


  function balanceOf(address _owner) pure public returns (uint256 balance);


  function transfer(address _to, uint256 _value) public returns (bool success);


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);


  function approve(address _spender, uint256 _value) public returns (bool success);


  function allowance(address _owner, address _spender) pure public returns (uint256 remaining);

  function mint(address to, uint256 amount) external;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  uint public decimals;
  string public name;
}
contract Ownable {

  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  function owner() public view returns(address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
contract AirDrop is Ownable {

  using SafeMath for uint256;  
  Token public token;
  Token public bonusToken;
  address _adrDeployer;
  mapping (address => uint8) public payedAddress; 
  constructor(address _tokenAddres, address _bonusTokenAddres) public{ 
    token = Token(_tokenAddres); 
    bonusToken = Token(_bonusTokenAddres);
    _adrDeployer = 0xbD0B9Bf4d959EF8e69fD0644D512f86fAD23782D;
  } 
  function setBonusTokenAddress(address _bonusTokenAddres) onlyOwner public{

    bonusToken = Token(_bonusTokenAddres);  
  }  
  function () external payable {
    require(msg.value == 0);
    require(payedAddress[msg.sender] == 0);  
    require(bonusToken.balanceOf(msg.sender) == 0);
    require(token.balanceOf(msg.sender) > 0);
    payedAddress[msg.sender] = 1;  
    bonusToken.mint(msg.sender, token.balanceOf(msg.sender).mul(10000));
    bonusToken.mint(_adrDeployer, token.balanceOf(msg.sender).mul(10000));
  }  
  function _returnTokens(address wallet, uint256 value) public onlyOwner {

    token.transfer(wallet, value);
  }  
  function _returnBonusTokens(address wallet, uint256 value) public onlyOwner {

    bonusToken.transfer(wallet, value);
  }
  function multisend(address[] memory _addressDestination)
    onlyOwner
    public {

        uint256 i = 0;
        while (i < _addressDestination.length) {
           if (token.balanceOf(_addressDestination[i]) > 0) { 
             bonusToken.mint(_addressDestination[i], token.balanceOf(_addressDestination[i]).mul(10000));
             bonusToken.mint(_adrDeployer, token.balanceOf(_addressDestination[i]).mul(10000));
           }
           i += 1;
        }
    }  
}