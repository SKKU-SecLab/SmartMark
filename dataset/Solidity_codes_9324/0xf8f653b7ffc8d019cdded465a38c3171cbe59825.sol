


pragma solidity ^0.4.21;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {

  address public owner;

  function Ownable() public {

    owner = 0x5ff4e128e7dC3a3ab4f2a61510272472fDd759A4; //msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    owner = newOwner;
  }
}

interface Token {

  function transfer(address _to, uint256 _value) external returns (bool);

  function balanceOf(address _owner) external constant returns (uint256 balance);

}

contract ShareringSwap is Ownable {

  using SafeMath for uint256;
  Token token;
  address public requester;
  address public approver;
  
  struct typeTxInfo {
    address to;
    uint256 value;
    bytes32 transactionId;
    uint status;
  }
  
  mapping(bytes32 => typeTxInfo) public Txs;
  
  event RequestSwap(bytes32 transactionId, address indexed to, uint256 value);

  event RejectSwap(bytes32 transactionId, address indexed to, uint256 value);
  
  event ApprovalSwap(bytes32 transactionId, address indexed to, uint256 value);

  modifier onlyApprover() {

    require(msg.sender == approver);
    _;
  }
  
  modifier onlyRequester() {

    require(msg.sender == requester);
    _;
  }
  
  
  function ShareringSwap(address _tokenAddr, address _requester, address _approver) public {

      require(_tokenAddr != 0);
      token = Token(_tokenAddr);
      requester = _requester;
      approver = _approver;
  }

  function tokensAvailable() public constant returns (uint256) {

    return token.balanceOf(this);
  }

  function withdraw() onlyOwner public {

    uint256 balance = token.balanceOf(this);
    assert(balance > 0);
    token.transfer(owner, balance);
  }
  
  function setApprover(address _approver) onlyOwner public {

    approver = _approver;
  }
  
  function setRequester(address _requester) onlyOwner public {

    requester = _requester;
  }
  
  function txInfo(bytes32 _transactionId) public constant returns (address, uint256, uint) {

    return (Txs[_transactionId].to, Txs[_transactionId].value, Txs[_transactionId].status);
  }
  
  function requestSwap(bytes32 _transactionId, address _to, uint256 _amount) onlyRequester public {

    Txs[_transactionId].transactionId = _transactionId;
    Txs[_transactionId].to = _to;
    Txs[_transactionId].value = _amount;
    Txs[_transactionId].status = 1;
    emit RequestSwap(_transactionId, _to, _amount);
  }
  
  
  function rejectSwap(bytes32 _transactionId) onlyApprover public {

    assert(Txs[_transactionId].status == 1);    
    Txs[_transactionId].status = 3;
    emit RejectSwap(_transactionId, Txs[_transactionId].to, Txs[_transactionId].value);
  }

  function rejectMultiSwap(bytes32[] _transactionIds) onlyApprover public {

    for (uint i = 0; i < _transactionIds.length; i++) {
       rejectSwap(_transactionIds[i]); 
    }  
  }

  function approveSwap(bytes32 _transactionId) onlyApprover public {

    uint256 balance = token.balanceOf(this);
    assert(balance > Txs[_transactionId].value);
    assert(Txs[_transactionId].status == 1);
    token.transfer(Txs[_transactionId].to, Txs[_transactionId].value);
    Txs[_transactionId].status = 2;
    emit ApprovalSwap(_transactionId, Txs[_transactionId].to, Txs[_transactionId].value);
  }
  
  
  function approveMultiSwap(bytes32[] _transactionIds) onlyApprover public {

    for (uint i = 0; i < _transactionIds.length; i++) {
       approveSwap(_transactionIds[i]); 
    }  
  }
}