
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity ^0.8.10;


contract YokaiRaffle is Ownable {

  using SafeMath for uint256;

  address public yohContract = 0x88a07dE49B1E97FdfeaCF76b42463453d48C17cD;
  uint public ticketPrice = 420 * (10 ** 18);

  uint public startTime;
  uint public endTime;

  address public creator;
  address[] public participants;
  address[] public winners;

  event JoinEvent(uint _length, uint _qty);
  event DrawEvent(address _winner, uint _prize);

  constructor(address _yoh, uint _price) {
    yohContract = _yoh;
    ticketPrice = _price;
  }

  function setTicketPrice(uint _price) external onlyOwner {

    ticketPrice = _price;
  }

  function createDrawEvent(uint _startTime, uint _endTime) external onlyOwner {

    startTime = _startTime;
    endTime = _endTime;
    delete participants;
  }

  function withdrawBalance() external onlyOwner {

    uint currentBalance = IYohToken(yohContract).balanceOf(address(this));
    IYohToken(yohContract).transfer(msg.sender, currentBalance);
  }

  function joinraffle(uint _qty) public returns(bool) {

    require(block.timestamp > startTime, "YokaiRaffle::JoinRaffle: has not started");
    require(block.timestamp < endTime, "YokaiRaffle::JoinRaffle: has already ended");

    uint payAmount = ticketPrice * _qty;
    require(IYohToken(yohContract).transferFrom(msg.sender, address(this), payAmount), "YokaiRaffle::JoinRaffle: no funds?");


    for (uint i = 0; i < _qty; i++) {
      participants.push(msg.sender);
    }

    emit JoinEvent (participants.length, _qty);

    return true;
  }

  function draw() external returns (bool) {

    require(block.timestamp > startTime, "YokaiRaffle::Draw: has not started");
    require(block.timestamp > endTime, "YokaiRaffle::Draw: has not ended");

    uint seed = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    uint random = seed % participants.length;

    winners.push(participants[random]);
    uint pot = IYohToken(yohContract).balanceOf(address(this));
    emit DrawEvent (address(participants[random]), pot);

    return true;
  }
}

interface IYohToken {

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function balanceOf(address account) external returns (uint256);

}