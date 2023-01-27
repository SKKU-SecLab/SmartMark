
pragma solidity ^0.5.2;


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





interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}



interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}


contract TransferrableToken is ERC165 {

  function transferFrom(address _from, address _to, uint256 _valueOrTokenId) public;

  function approve(address _to, uint256 _value) public;

}


library PriorityQueue {

  using SafeMath for uint256;

  struct Token {
    TransferrableToken addr;
    uint256[] heapList;
    uint256 currentSize;
  }

  function insert(Token storage self, uint256 k) internal {

    self.heapList.push(k);
    self.currentSize = self.currentSize.add(1);
    percUp(self, self.currentSize);
  }

  function minChild(Token storage self, uint256 i) internal view returns (uint256) {

    if (i.mul(2).add(1) > self.currentSize) {
      return i.mul(2);
    } else {
      if (self.heapList[i.mul(2)] < self.heapList[i.mul(2).add(1)]) {
        return i.mul(2);
      } else {
        return i.mul(2).add(1);
      }
    }
  }

  function getMin(Token storage self) internal view returns (uint256) {

    return self.heapList[1];
  }

  function delMin(Token storage self) internal returns (uint256) {

    uint256 retVal = self.heapList[1];
    self.heapList[1] = self.heapList[self.currentSize];
    delete self.heapList[self.currentSize];
    self.currentSize = self.currentSize.sub(1);
    percDown(self, 1);
    self.heapList.length = self.heapList.length.sub(1);
    return retVal;
  }

  function percUp(Token storage self, uint256 i) private {

    uint256 j = i;
    uint256 newVal = self.heapList[i];
    while (newVal < self.heapList[i.div(2)]) {
      self.heapList[i] = self.heapList[i.div(2)];
      i = i.div(2);
    }
    if (i != j) self.heapList[i] = newVal;
  }

  function percDown(Token storage self, uint256 i) private {

    uint256 j = i;
    uint256 newVal = self.heapList[i];
    uint256 mc = minChild(self, i);
    while (mc <= self.currentSize && newVal > self.heapList[mc]) {
      self.heapList[i] = self.heapList[mc];
      i = mc;
      mc = minChild(self, i);
    }
    if (i != j) self.heapList[i] = newVal;
  }

}



interface IERC1948 {


  event DataUpdated(uint256 indexed tokenId, bytes32 oldData, bytes32 newData);

  function readData(uint256 tokenId) external view returns (bytes32);


  function writeData(uint256 tokenId, bytes32 newData) external;


}

contract Vault is Adminable {

  using PriorityQueue for PriorityQueue.Token;

  uint16 constant NFT_FIRST_COLOR = 32769;
  uint16 constant NST_FIRST_COLOR = 49153;

  event NewToken(address indexed tokenAddr, uint16 color);

  Bridge public bridge;

  uint16 public erc20TokenCount;
  uint16 public nftTokenCount;
  uint16 public nstTokenCount;

  mapping(uint16 => PriorityQueue.Token) public tokens;
  mapping(address => bool) public tokenColors;

  function initialize(Bridge _bridge) public initializer {

    bridge = _bridge;
  } 

  function getTokenAddr(uint16 _color) public view returns (address) {

    return address(tokens[_color].addr);
  }

  function registerToken(address _token, uint256 _type) public ifAdmin {

    require(_token != address(0), "Tried to register 0x0 address");
    require(!tokenColors[_token], "Token already registered");
    uint16 color;
    if (_type == 0) {
      require(ERC20(_token).totalSupply() >= 0, "Not an ERC20 token");
      color = erc20TokenCount;
      erc20TokenCount += 1;
    } else if (_type == 1) {
      require(nftTokenCount < 0x4000);
      require(TransferrableToken(_token).supportsInterface(0x80ac58cd) == true, "Not an ERC721 token");
      color = NFT_FIRST_COLOR + nftTokenCount; // NFT color namespace starts from 2^15 + 1
      nftTokenCount += 1;
    } else {
      require(nstTokenCount < 0x3ffe);
      require(TransferrableToken(_token).supportsInterface(0x80ac58cd) == true, "Not an ERC721 token");
      color = NST_FIRST_COLOR + nstTokenCount; // NST color namespace starts from 2^15 + 2^14 + 1
      nstTokenCount += 1;
    }
    uint256[] memory arr = new uint256[](1);
    tokenColors[_token] = true;
    tokens[color] = PriorityQueue.Token({
      addr: TransferrableToken(_token),
      heapList: arr,
      currentSize: 0
    });
    emit NewToken(_token, color);
  }

  uint256[49] private ______gap;

}


contract PoaOperator is Adminable {


  event Epoch(uint256 epoch);
  event EpochLength(uint256 epochLength);

  event ValidatorJoin(
    address indexed signerAddr,
    uint256 indexed slotId,
    bytes32 indexed tenderAddr,
    uint256 eventCounter,
    uint256 epoch
  );

  event ValidatorLogout(
    address indexed signerAddr,
    uint256 indexed slotId,
    bytes32 indexed tenderAddr,
    address newSigner,
    uint256 eventCounter,
    uint256 epoch
  );

  event ValidatorLeave(
    address indexed signerAddr,
    uint256 indexed slotId,
    bytes32 indexed tenderAddr,
    uint256 epoch
  );

  event ValidatorUpdate(
    address indexed signerAddr,
    uint256 indexed slotId,
    bytes32 indexed tenderAddr,
    uint256 eventCounter
  );

  struct Slot {
    uint32 eventCounter;
    address owner;
    uint64 stake;
    address signer;
    bytes32 tendermint;
    uint32 activationEpoch;
    address newOwner;
    uint64 newStake;
    address newSigner;
    bytes32 newTendermint;
  }

  Vault public vault;
  Bridge public bridge;

  uint256 public epochLength; // length of epoch in periods (32 blocks)
  uint256 public lastCompleteEpoch; // height at which last epoch was completed
  uint256 public lastEpochBlockHeight;

  mapping(uint256 => Slot) public slots;


  function initialize(Bridge _bridge, Vault _vault, uint256 _epochLength) public initializer {

    vault = _vault;
    bridge = _bridge;
    epochLength = _epochLength;
    emit EpochLength(epochLength);
  }

  function setEpochLength(uint256 _epochLength) public ifAdmin {

    epochLength = _epochLength;
    emit EpochLength(epochLength);
  }

  function setSlot(uint256 _slotId, address _signerAddr, bytes32 _tenderAddr) public ifAdmin {

    require(_slotId < epochLength, "out of range slotId");
    Slot storage slot = slots[_slotId];

    if (slot.signer == address(0)) {
      slot.owner = _signerAddr;
      slot.signer = _signerAddr;
      slot.tendermint = _tenderAddr;
      slot.activationEpoch = 0;
      slot.eventCounter++;
      emit ValidatorJoin(
        slot.signer,
        _slotId,
        _tenderAddr,
        slot.eventCounter,
        lastCompleteEpoch + 1
      );
      return;
    }
    if (_signerAddr == address(0) && _tenderAddr == 0) {
      slot.activationEpoch = uint32(lastCompleteEpoch + 3);
      slot.eventCounter++;
      emit ValidatorLogout(
        slot.signer,
        _slotId,
        _tenderAddr,
        address(0),
        slot.eventCounter,
        lastCompleteEpoch + 3
      );
      return;
    }
  }

  function activate(uint256 _slotId) public {

    require(_slotId < epochLength, "out of range slotId");
    Slot storage slot = slots[_slotId];
    require(lastCompleteEpoch + 1 >= slot.activationEpoch, "activation epoch not reached yet");
    if (slot.signer != address(0)) {
      emit ValidatorLeave(
        slot.signer,
        _slotId,
        slot.tendermint,
        lastCompleteEpoch + 1
      );
    }
    slot.owner = slot.newOwner;
    slot.signer = slot.newSigner;
    slot.tendermint = slot.newTendermint;
    slot.activationEpoch = 0;
    slot.newSigner = address(0);
    slot.newTendermint = 0x0;
    slot.eventCounter++;
    if (slot.signer != address(0)) {
      emit ValidatorJoin(
        slot.signer,
        _slotId,
        slot.tendermint,
        slot.eventCounter,
        lastCompleteEpoch + 1
      );
    }
  }

  event Submission(
    bytes32 indexed blocksRoot,
    uint256 indexed slotId,
    address indexed owner,
    bytes32 casRoot,
    bytes32 periodRoot
  );

  function countSigs(uint256 _sigs, uint256 _epochLength) internal pure returns (uint256 count) {

    for (uint i = 256; i >= 256 - _epochLength; i--) {
      count += uint8(_sigs >> i) & 0x01;
    }
  }

  function neededSigs(uint256 _epochLength) internal pure returns (uint256 needed) {

    return (_epochLength * 2 / 3) + ((_epochLength * 2 % 3) == 0 ? 0 : 1);
  }

  function _submitPeriod(uint256 _slotId, bytes32 _prevHash, bytes32 _blocksRoot, bytes32 _cas) internal {

    require(_slotId < epochLength, "Incorrect slotId");
    Slot storage slot = slots[_slotId];
    require(slot.signer == msg.sender, "not submitted by signerAddr");
    if (slot.activationEpoch > 0) {
      require(lastCompleteEpoch + 2 < slot.activationEpoch, "slot not active");
    }

    bytes32 hashRoot = bytes32(_slotId << 160 | uint160(slot.owner));
    assembly {
      mstore(0, hashRoot)
      mstore(0x20, 0x0000000000000000000000000000000000000000)
      hashRoot := keccak256(0, 0x40)
    }
    assembly {
      mstore(0, _cas)
      mstore(0x20, hashRoot)
      hashRoot := keccak256(0, 0x40)
    }

    bytes32 consensusRoot;
    assembly {
      mstore(0, _blocksRoot)
      mstore(0x20, 0x0000000000000000000000000000000000000000)
      consensusRoot := keccak256(0, 0x40)
    }

    assembly {
      mstore(0, consensusRoot)
      mstore(0x20, hashRoot)
      hashRoot := keccak256(0, 0x40)
    }

    uint256 newHeight = bridge.submitPeriod(_prevHash, hashRoot);
    if (newHeight >= lastEpochBlockHeight + epochLength) {
      lastCompleteEpoch++;
      lastEpochBlockHeight = newHeight;
      emit Epoch(lastCompleteEpoch);
    }
    emit Submission(
      _blocksRoot,
      _slotId,
      slot.owner,
      _cas,
      hashRoot
    );
  }

  function submitPeriodWithCas(uint256 _slotId, bytes32 _prevHash, bytes32 _blocksRoot, bytes32 _cas) public {

    require(countSigs(uint256(_cas), epochLength) == neededSigs(epochLength), "incorrect number of sigs");
    _submitPeriod(_slotId, _prevHash, _blocksRoot, _cas);
  }

  function submitPeriod(uint256 _slotId, bytes32 _prevHash, bytes32 _blocksRoot) public {

    _submitPeriod(_slotId, _prevHash, _blocksRoot, 0);
  }
}