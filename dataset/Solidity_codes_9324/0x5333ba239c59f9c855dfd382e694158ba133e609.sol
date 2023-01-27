

pragma solidity ^0.4.24;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


pragma solidity ^0.4.24;


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


pragma solidity ^0.4.25;



contract TokenExpress is Ownable {

    event Deposit(bytes32 indexed escrowId, address indexed sender, uint256 amount);
    event Send(bytes32 indexed escrowId, address indexed recipient, uint256 amount);
    event Recovery(bytes32 indexed escrowId, address indexed sender, uint256 amount);

    using SafeMath for uint256;

    uint256 fee = 1000000;

    uint256 lockTime = 14 * 24;

    address administrator = 0x0;

    struct TransferInfo {
        address from;
        address to;
        uint256 amount;
        uint256 date;
        bool    sent;
    }

    mapping (bytes32 => TransferInfo) private _transferInfo;

    constructor () public {
        owner = msg.sender;
    }

    function etherDeposit(bytes32 id, uint256 amount) payable public {

        require(_transferInfo[id].from == 0x0, "ID is already exists.");

        require(amount + fee <= msg.value, "Value is too low.");

        _transferInfo[id].from   = msg.sender;
        _transferInfo[id].to     = 0x0;
        _transferInfo[id].amount = amount;
        _transferInfo[id].date   = block.timestamp;
        emit Deposit(id, msg.sender, amount);
    }

    function etherSend(bytes32 id, address to) public {

        require(_transferInfo[id].from != 0x0, "ID error.");

        require(_transferInfo[id].sent == false, "Already sent.");

        require(to != 0x0, "Address error.");

        require(msg.sender == owner || msg.sender == administrator || msg.sender == _transferInfo[id].from, "Invalid address.");

        to.transfer(_transferInfo[id].amount);
        _transferInfo[id].to = to;
        _transferInfo[id].sent = true;
        emit Send(id, to, _transferInfo[id].amount);
    }

    function etherRecovery(bytes32 id) public {

        require(_transferInfo[id].from != 0x0, "ID error.");

        require(_transferInfo[id].sent == false, "Already recoveried.");

        require(_transferInfo[id].date + lockTime * 60 * 60 <= block.timestamp, "Locked.");

        address to = _transferInfo[id].from;
        to.transfer(_transferInfo[id].amount);
        _transferInfo[id].sent = true;
        emit Recovery(id, _transferInfo[id].from, _transferInfo[id].amount);
    }

    function etherInfo(bytes32 id) public view returns (address, address, uint256, bool) {

        return (_transferInfo[id].from, _transferInfo[id].to, _transferInfo[id].amount, _transferInfo[id].sent);
    }

    function setAdmin(address _admin) onlyOwner public {

        administrator = _admin;
    }

    function getAdmin() public view returns (address) {

        return administrator;
    }

    function setFee(uint256 _fee) onlyOwner public {

        fee = _fee;
    }

    function getFee() public view returns (uint256) {

        return fee;
    }

    function setLockTime(uint256 _lockTime) onlyOwner public {

        lockTime = _lockTime;
    }

    function getLockTime() public view returns (uint256) {

        return lockTime;
    }

    function getBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function sendEtherToOwner(address to, uint256 amount) onlyOwner public {

        to.transfer(amount);
    }

}