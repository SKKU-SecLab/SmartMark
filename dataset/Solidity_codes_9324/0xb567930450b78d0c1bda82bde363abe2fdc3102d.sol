
pragma solidity ^0.5.2;




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

        require(b > 0);
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



contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract Adminable is Initializable {


  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

  modifier ifAdmin() {

    require(msg.sender == _admin());
    _;
  }

  function admin() external view returns (address) {

    return _admin();
  }

  function implementation() external view returns (address impl) {

    bytes32 slot = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;
    assembly {
      impl := sload(slot)
    }
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }
}

contract Bridge is Adminable {

  using SafeMath for uint256;

  modifier onlyOperator() {

    require(msg.sender == operator, "Tried to call a only-operator function from non-operator");
    _;
  }

  event NewHeight(uint256 height, bytes32 indexed root);
  event NewOperator(address operator);

  struct Period {
    uint32 height;            // the height of last block in period
    uint32 timestamp;         // the block.timestamp at submission of period
    uint32 parentBlockNumber; // the block.number at submission of period
    bytes32 parentBlockHash;  // the blockhash(block.number -1) at submission of period
  }

  bytes32 constant GENESIS = 0x4920616d207665727920616e6772792c20627574206974207761732066756e21;

  bytes32 public tipHash; // hash of first period that has extended chain to some height
  uint256 public genesisBlockNumber;
  uint256 parentBlockInterval; // how often epochs can be submitted max
  uint256 public lastParentBlock; // last ethereum block when epoch was submitted
  address public operator; // the operator contract

  mapping(bytes32 => Period) public periods;

  function initialize(uint256 _parentBlockInterval) public initializer {

    Period memory genesisPeriod = Period({
      height: 1,
      timestamp: uint32(block.timestamp),
      parentBlockNumber: uint32(block.number),
      parentBlockHash: blockhash(block.number-1)
    });
    tipHash = GENESIS;
    periods[GENESIS] = genesisPeriod;
    genesisBlockNumber = block.number;
    parentBlockInterval = _parentBlockInterval;
    operator = msg.sender;
  }

  function setOperator(address _operator) public ifAdmin {

    operator = _operator;
    emit NewOperator(_operator);
  }

  function getParentBlockInterval() public view returns (uint256) {

    return parentBlockInterval;
  }

  function setParentBlockInterval(uint256 _parentBlockInterval) public ifAdmin {

    parentBlockInterval = _parentBlockInterval;
  }

  function submitPeriod(
    bytes32 _prevHash,
    bytes32 _root)
  public onlyOperator returns (uint256 newHeight) {


    require(periods[_prevHash].timestamp > 0, "Parent node should exist");
    require(periods[_root].timestamp == 0, "Trying to submit the same root twice");

    newHeight = periods[_prevHash].height + 1;
    if (newHeight > periods[tipHash].height) {
      require(
        block.number >= lastParentBlock + parentBlockInterval,
        "Tried to submit new period too soon"
      );
      tipHash = _root;
      lastParentBlock = block.number;
    }
    emit NewHeight(newHeight, _root);
    Period memory newPeriod = Period({
      height: uint32(newHeight),
      timestamp: uint32(block.timestamp),
      parentBlockNumber: uint32(block.number),
      parentBlockHash: blockhash(block.number-1)
    });
    periods[_root] = newPeriod;
  }
}