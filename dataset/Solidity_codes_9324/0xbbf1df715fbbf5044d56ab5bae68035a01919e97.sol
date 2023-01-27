
pragma solidity ^0.4.15;




contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract SlammerTime is Ownable{


  string public constant purpose = "ETHDenver";
  string public constant contact = "https://cryptogs.io";
  string public constant author = "Austin Thomas Griffith | [email protected]";

  address public cryptogs;

  function SlammerTime(address _cryptogs) public {

    cryptogs=_cryptogs;
  }

  function startSlammerTime(address _player1,uint256[5] _id1,address _player2,uint256[5] _id2) public returns (bool) {

    require(msg.sender==cryptogs);

    Cryptogs cryptogsContract = Cryptogs(cryptogs);

    for(uint8 i=0;i<5;i++){
      require(cryptogsContract.tokenIndexToOwner(_id1[i])==_player1);
      cryptogsContract.transferFrom(_player1,address(this),_id1[i]);
      require(cryptogsContract.tokenIndexToOwner(_id1[i])==address(this));
    }


    for(uint8 j=0;j<5;j++){
      require(cryptogsContract.tokenIndexToOwner(_id2[j])==_player2);
      cryptogsContract.transferFrom(_player2,address(this),_id2[j]);
      require(cryptogsContract.tokenIndexToOwner(_id2[j])==address(this));
    }


    return true;
  }

  function transferBack(address _toWhom, uint256 _id) public returns (bool) {

    require(msg.sender==cryptogs);

    Cryptogs cryptogsContract = Cryptogs(cryptogs);

    require(cryptogsContract.tokenIndexToOwner(_id)==address(this));
    cryptogsContract.transfer(_toWhom,_id);
    require(cryptogsContract.tokenIndexToOwner(_id)==_toWhom);
    return true;
  }

  function withdraw(uint256 _amount) public onlyOwner returns (bool) {

    require(this.balance >= _amount);
    assert(owner.send(_amount));
    return true;
  }

  function withdrawToken(address _token,uint256 _amount) public onlyOwner returns (bool) {

    StandardToken token = StandardToken(_token);
    token.transfer(msg.sender,_amount);
    return true;
  }
}

contract StandardToken {

  function transfer(address _to, uint256 _value) public returns (bool) { }

}


contract Cryptogs {
  mapping (uint256 => address) public tokenIndexToOwner;
  function transfer(address _to,uint256 _tokenId) external { }
  function transferFrom(address _from,address _to,uint256 _tokenId) external { }
}