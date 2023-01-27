


pragma solidity ^0.6.7;

contract ProtocolTokenAuthority {

  address public root;
  address public owner;

  modifier isRootCalling { require(msg.sender == root); _; }

  modifier isRootOrOwnerCalling { require(msg.sender == root || owner == msg.sender); _; }


  event SetRoot(address indexed newRoot);
  event SetOwner(address indexed newOwner);

  function setRoot(address usr) public isRootCalling {

    root = usr;
    emit SetRoot(usr);
  }
  function setOwner(address usr) public isRootOrOwnerCalling {

    owner = usr;
    emit SetOwner(usr);
  }

  mapping (address => uint) public authorizedAccounts;

  event AddAuthorization(address indexed usr);
  function addAuthorization(address usr) public isRootOrOwnerCalling { authorizedAccounts[usr] = 1; emit AddAuthorization(usr); }

  event RemoveAuthorization(address indexed usr);
  function removeAuthorization(address usr) public isRootOrOwnerCalling { authorizedAccounts[usr] = 0; emit RemoveAuthorization(usr); }


  constructor() public {
    root = msg.sender;
    emit SetRoot(msg.sender);
  }

  bytes4 constant burn = bytes4(0x42966c68);
  bytes4 constant burnFrom = bytes4(0x9dc29fac);
  bytes4 constant mint = bytes4(0x40c10f19);

  function canCall(address src, address, bytes4 sig)
      public view returns (bool)
  {

    if (sig == burn || sig == burnFrom || src == root || src == owner) {
      return true;
    } else if (sig == mint) {
      return (authorizedAccounts[src] == 1);
    } else {
      return false;
    }
  }
}