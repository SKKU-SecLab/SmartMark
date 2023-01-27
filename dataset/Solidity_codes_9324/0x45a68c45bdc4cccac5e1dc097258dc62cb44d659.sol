
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT
pragma solidity 0.6.12;


interface IRewardsSchedule {

  event EarlyEndBlockSet(uint256 earlyEndBlock);

  function startBlock() external view returns (uint256);

  function endBlock() external view returns (uint256);

  function getRewardsForBlockRange(uint256 from, uint256 to) external view returns (uint256);

  function setEarlyEndBlock(uint256 earlyEndBlock) external;

}// MIT
pragma solidity 0.6.12;



contract CNJRewardsSchedule is Ownable, IRewardsSchedule {

  uint256 public immutable override startBlock;
  uint256 public override endBlock;

  constructor(uint256 startBlock_) public Ownable() {
  startBlock = startBlock_;
  endBlock = startBlock_ + 1194545;
}

function setEarlyEndBlock(uint256 earlyEndBlock) external override onlyOwner {

  uint256 endBlock_ = endBlock;
  require(endBlock_ == startBlock + 1194545, "Early end block already set");
  require(earlyEndBlock > block.number && earlyEndBlock > startBlock, "End block too early");
  require(earlyEndBlock < endBlock_, "End block too late");
  endBlock = earlyEndBlock;
  emit EarlyEndBlockSet(earlyEndBlock);
}

function getRewardsForBlockRange(uint256 from, uint256 to) external view override returns (uint256) {

  require(to >= from, "Bad block range");
  uint256 endBlock_ = endBlock;
  if (from >= endBlock_ || to <= startBlock) return 0;

  if (to > endBlock_) to = endBlock_;
  if (from < startBlock) from = startBlock;

  uint256 x = from - startBlock;
  uint256 y = to - startBlock;


  return (583417178500 * x**2)
  + (2789765141e9 * (y - x))
  - (583417178500 * y**2);
  }
}