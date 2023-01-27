
pragma solidity 0.5.2;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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

  function registerToken(address _token, bool _isERC721) public ifAdmin {

    require(_token != address(0), "Tried to register 0x0 address");
    require(!tokenColors[_token], "Token already registered");
    uint16 color;
    if (_isERC721) {
      require(nftTokenCount < 0x4000);
      require(TransferrableToken(_token).supportsInterface(0x80ac58cd) == true, "Not an ERC721 token");
      color = NFT_FIRST_COLOR + nftTokenCount; // NFT color namespace starts from 2^15 + 1
      nftTokenCount += 1;
    } else {
      require(ERC20(_token).totalSupply() >= 0, "Not an ERC20 token");
      color = erc20TokenCount;
      erc20TokenCount += 1;
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

  function registerNST(address _token) public ifAdmin {

    require(_token != address(0), "Tried to register 0x0 address");
    require(!tokenColors[_token], "Token already registered");
    require(nstTokenCount < 0x3ffe);
    require(TransferrableToken(_token).supportsInterface(0x80ac58cd) == true, "Not an ERC721 token");

    uint16 color = NST_FIRST_COLOR + nstTokenCount; // NST color namespace starts from 2^15 + 2^14 + 1
    nstTokenCount += 1;

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








contract DepositHandler is Vault {


  event NewDeposit(
    uint32 indexed depositId,
    address indexed depositor,
    uint256 indexed color,
    uint256 amount
  );
  event MinGasPrice(uint256 minGasPrice);
  event NewDepositV2(
    uint32 indexed depositId,
    address indexed depositor,
    uint256 indexed color,
    uint256 amount,
    bytes32 data
  );

  struct Deposit {
    uint64 time;
    uint16 color;
    address owner;
    uint256 amount;
  }

  uint32 public depositCount;
  uint256 public minGasPrice;

  mapping(uint32 => Deposit) public deposits;
  mapping(uint32 => bytes32) public tokenData;

  function setMinGasPrice(uint256 _minGasPrice) public ifAdmin {

    minGasPrice = _minGasPrice;
    emit MinGasPrice(minGasPrice);
  }

  function deposit(address _owner, uint256 _amountOrTokenId, uint16 _color) public {

    require(_owner == msg.sender, "owner different from msg.sender");
    _deposit(_amountOrTokenId, _color);
  }

  function depositBySender(uint256 _amountOrTokenId, uint16 _color) public {

    _deposit(_amountOrTokenId, _color);
  }

  function _deposit(uint256 _amountOrTokenId, uint16 _color) internal {

    TransferrableToken token = tokens[_color].addr;
    require(address(token) != address(0), "Token color already registered");
    require(_amountOrTokenId > 0 || _color > 32769, "no 0 deposits for fungible tokens");

    bytes32 _tokenData;

    if (_color >= NST_FIRST_COLOR) {
      IERC1948 nst = IERC1948(address(token));
      _tokenData = nst.readData(_amountOrTokenId);
    }

    token.transferFrom(msg.sender, address(this), _amountOrTokenId);

    bytes32 tipHash = bridge.tipHash();
    uint256 timestamp;
    (, timestamp,,) = bridge.periods(tipHash);

    depositCount++;
    deposits[depositCount] = Deposit({
      time: uint32(timestamp),
      owner: msg.sender,
      color: _color,
      amount: _amountOrTokenId
    });

    if (_color >= NST_FIRST_COLOR) {
      tokenData[depositCount] = _tokenData;

      emit NewDepositV2(
        depositCount,
        msg.sender,
        _color,
        _amountOrTokenId,
        _tokenData
      );
    } else {
      emit NewDeposit(
        depositCount,
        msg.sender,
        _color,
        _amountOrTokenId
      );
    }
  }

  uint256[49] private ______gap;
}





contract IExitHandler {


  function startExit(bytes32[] memory, bytes32[] memory, uint8, uint8) public payable;


}




library TxLib {


  uint constant internal WORD_SIZE = 32;
  uint constant internal ONES = ~uint(0);
  enum TxType { None0, None1, Deposit, Transfer, None4, None5,
  None6, None7, None8, None9, None10, None11, None12, SpendCond }

  struct Outpoint {
    bytes32 hash;
    uint8 pos;
  }

  struct Input {
    Outpoint outpoint;
    bytes32 r;
    bytes32 s;
    uint8 v;
    bytes script;
    bytes msgData;
  }

  struct Output {
    uint256 value;
    uint16 color;
    address owner;
    bytes32 stateRoot;
  }

  struct Tx {
    TxType txType;
    Input[] ins;
    Output[] outs;
  }

  function parseInput(
    TxType _type, bytes memory _txData, uint256 _pos, uint256 offset, Input[] memory _ins
  ) internal pure returns (uint256 newOffset) {

    bytes32 inputData;
    uint8 index;
    if (_type == TxType.Deposit) {
      assembly {
        inputData := mload(add(add(offset, 4), _txData))
      }
      inputData = bytes32(uint256(uint32(uint256(inputData))));
      index = 0;
      newOffset = offset + 4;
    } else {
      assembly {
        inputData := mload(add(add(offset, 32), _txData))
        index := mload(add(add(offset, 33), _txData))
      }
      newOffset = offset + 33;
    }
    Outpoint memory outpoint = Outpoint(inputData, index);
    bytes memory data = new bytes(0);
    Input memory input = Input(outpoint, 0, 0, 0, data, data); // solium-disable-line arg-overflow
    if (_type == TxType.SpendCond) {
      uint16 len;
      assembly {
        len := mload(add(add(offset, 35), _txData)) 
      }
      data = new bytes(len);  
      uint src;
      uint dest;
      assembly {  
        src := add(add(add(offset, 35), 0x20), _txData) 
        dest := add(data, 0x20) 
      }
      memcopy(src, dest, len);  
      input.msgData = data;  
      newOffset = offset + 37 + len;

      assembly {
        len := mload(add(newOffset, _txData)) 
      }

      data = new bytes(len);
      assembly {  
        src := add(add(add(newOffset, 0), 0x20), _txData) 
        dest := add(data, 0x20) 
      }
      memcopy(src, dest, len);  
      input.script = data;
      newOffset = newOffset + len;
    }
    if (_type == TxType.Transfer) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      assembly {
        r := mload(add(add(offset, 65), _txData))
        s := mload(add(add(offset, 97), _txData))
        v := mload(add(add(offset, 98), _txData))
      }
      input.r = r;
      input.s = s;
      input.v = v;
      newOffset = offset + 33 + 65;
    }
    _ins[_pos] = input;
  }

  function memcopy(uint srcPtr, uint destPtr, uint len) internal pure {

    uint offset = 0;
    uint size = len / WORD_SIZE;
    for (uint i = 0; i < size; i++) {
      offset = i * WORD_SIZE;
      assembly {
        mstore(add(destPtr, offset), mload(add(srcPtr, offset)))
      }
    }
    offset = size*WORD_SIZE;
    uint mask = ONES << 8*(32 - len % WORD_SIZE);
    assembly {
      let nSrc := add(srcPtr, offset)
      let nDest := add(destPtr, offset)
      mstore(nDest, or(and(mload(nSrc), mask), and(mload(nDest), not(mask))))
    }
  }

  function parseOutput(
    bytes memory _txData, uint256 _pos, uint256 offset, Output[] memory _outs
  ) internal pure returns (uint256) {

    uint256 value;
    uint16 color;
    address owner;
    bytes32 data;

    assembly {
      offset := add(offset, 32)
      value := mload(add(offset, _txData))

      offset := add(offset, 2)
      color := and(mload(add(offset, _txData)), 0xffff)

      offset := add(offset, 20)
      owner := mload(add(offset, _txData))

      if gt(color, 49152) {
        offset := add(offset, 32)
        data := mload(add(offset, _txData))
      }
    }

    Output memory output = Output(value, color, owner, data);  // solium-disable-line arg-overflow
    _outs[_pos] = output;

    return offset;
  }

  function parseTx(bytes memory _txData) internal pure returns (Tx memory txn) {

    TxType txType;
    uint256 a;
    assembly {
      a := mload(add(0x20, _txData))
    }
    a = a >> 248; // get first byte
    if (a == 2) {
      txType = TxType.Deposit;
    } else if (a == 3) {
      txType = TxType.Transfer;
    } else if (a == 13) {
      txType = TxType.SpendCond;
    } else {
      revert("unknown tx type");
    }
    assembly {
        a := mload(add(0x21, _txData))
    }
    a = a >> 252; // get ins-length nibble
    Input[] memory ins = new Input[](a);
    uint256 offset = 2;
    for (uint i = 0; i < ins.length; i++) {
      offset = parseInput(txType, _txData, i, offset, ins); // solium-disable-line arg-overflow
    }
    assembly {
        a := mload(add(0x21, _txData))
    }
    a = (a >> 248) & 0x0f; // get outs-length nibble
    Output[] memory outs = new Output[](a);
    for (uint256 i = 0; i < outs.length; i++) {
      offset = parseOutput(_txData, i, offset, outs); // solium-disable-line arg-overflow
    }
    txn = Tx(txType, ins, outs);
  }

  function getSigHash(bytes memory _txData) internal pure returns (bytes32 sigHash) {

    uint256 a;
    assembly {
      a := mload(add(0x20, _txData))
    }
    a = a >> 248;
    require(a == 3);
    assembly {
        a := mload(add(0x21, _txData))
    }
    a = a >> 252; // get ins-length nibble
    bytes memory sigData = new bytes(_txData.length);
    assembly {
      mstore8(add(sigData, 32), byte(0, mload(add(_txData, 32))))
      mstore8(add(sigData, 33), byte(1, mload(add(_txData, 32))))
      let offset := 0
      for
        { let i := 0 }
        lt(i, a)
        { i := add(i, 1) }
        {
          mstore(add(sigData, add(34, offset)), mload(add(_txData, add(34, offset))))
          mstore8(add(sigData, add(66, offset)), byte(0, mload(add(_txData, add(66, offset)))))
          offset := add(offset, add(33, 65))
        }
      for
        { let i := add(34, offset) }
        lt(i, add(64, mload(_txData)))
        { i := add(i, 0x20) }
        {
          mstore(add(sigData, i), mload(add(_txData, i)))
        }
    }

    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", uint2str(_txData.length), sigData));
  }

  function getMerkleRoot(
    bytes32 _leaf, uint256 _index, uint256 _offset, bytes32[] memory _proof
  ) internal pure returns (bytes32) {

    bytes32 temp;
    for (uint256 i = _offset; i < _proof.length; i++) {
      temp = _proof[i];
      if (_index % 2 == 0) {
        assembly {
          mstore(0, _leaf)
          mstore(0x20, temp)
          _leaf := keccak256(0, 0x40)
        }
      } else {
        assembly {
          mstore(0, temp)
          mstore(0x20, _leaf)
          _leaf := keccak256(0, 0x40)
        }
      }
      _index = _index / 2;
    }
    return _leaf;
  }

  function validateProof(
    uint256 _cdOffset, bytes32[] memory _proof
  ) internal pure returns (uint64 txPos, bytes32 txHash, bytes memory txData) {

    uint256 offset = uint8(uint256(_proof[1] >> 248));
    uint256 txLength = uint16(uint256(_proof[1] >> 224));

    txData = new bytes(txLength);
    assembly {
      calldatacopy(add(txData, 0x20), add(68, add(offset, _cdOffset)), txLength)
    }
    txHash = keccak256(txData);
    txPos = uint64(uint256(_proof[1] >> 160));
    bytes32 root = getMerkleRoot(
      txHash, 
      txPos, 
      uint8(uint256(_proof[1] >> 240)),
      _proof
    ); 
    require(root == _proof[0]);
  }

  function recoverTxSigner(uint256 offset, bytes32[] memory _proof) internal pure returns (address dest) {

    uint16 txLength = uint16(uint256(_proof[1] >> 224));
    bytes memory txData = new bytes(txLength);
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      calldatacopy(add(txData, 32), add(114, offset), 43)
      r := calldataload(add(157, offset))
      s := calldataload(add(189, offset))
      v := calldataload(add(190, offset))
      calldatacopy(add(txData, 140), add(222, offset), 28) // 32 + 43 + 65
    }
    dest = ecrecover(getSigHash(txData), v, r, s); // solium-disable-line arg-overflow
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }
}













contract ExitHandler is IExitHandler, DepositHandler {


  using PriorityQueue for PriorityQueue.Token;

  event ExitStarted(
    bytes32 indexed txHash,
    uint8 indexed outIndex,
    uint256 indexed color,
    address exitor,
    uint256 amount
  );

  struct Exit {
    uint256 amount;
    uint16 color;
    address owner;
    bool finalized;
    uint32 priorityTimestamp;
    uint256 stake;
    bytes32 tokenData;
  }

  uint256 public exitDuration;
  uint256 public exitStake;
  uint256 public nftExitCounter;
  uint256 public nstExitCounter;

  mapping(bytes32 => Exit) public exits;

  function initializeWithExit(
    Bridge _bridge,
    uint256 _exitDuration,
    uint256 _exitStake) public initializer {

    initialize(_bridge);
    exitDuration = _exitDuration;
    exitStake = _exitStake;
    emit MinGasPrice(0);
  }

  function setExitStake(uint256 _exitStake) public ifAdmin {

    exitStake = _exitStake;
  }

  function setExitDuration(uint256 _exitDuration) public ifAdmin {

    exitDuration = _exitDuration;
  }

  function startExit(
    bytes32[] memory _youngestInputProof, bytes32[] memory _proof,
    uint8 _outputIndex, uint8 _inputIndex
  ) public payable {

    require(msg.value >= exitStake, "Not enough ether sent to pay for exit stake");
    uint32 timestamp;
    (, timestamp,,) = bridge.periods(_proof[0]);
    require(timestamp > 0, "The referenced period was not submitted to bridge");

    if (_youngestInputProof.length > 0) {
      (, timestamp,,) = bridge.periods(_youngestInputProof[0]);
      require(timestamp > 0, "The referenced period was not submitted to bridge");
    }

    bytes32 txHash;
    bytes memory txData;
    uint64 txPos;
    (txPos, txHash, txData) = TxLib.validateProof(32 * (_youngestInputProof.length + 2) + 64, _proof);

    TxLib.Tx memory exitingTx = TxLib.parseTx(txData);
    TxLib.Output memory out = exitingTx.outs[_outputIndex];

    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash)));
    uint256 priority;
    if (msg.sender != out.owner) {
      address a = msg.sender;
      assembly {
        priority := extcodehash(a) // abusing priority for hashBytes here, to save stack
      }
      require(priority != 0, "caller not contract");
      require(bytes20(out.owner) == ripemd160(abi.encode(priority)), "Only UTXO owner or contract can start exit");
      out.owner = msg.sender;
    }
    require(out.value > 0, "UTXO has no value");
    require(exits[utxoId].amount == 0, "The exit for UTXO has already been started");
    require(!exits[utxoId].finalized, "The exit for UTXO has already been finalized");

    
    if (_youngestInputProof.length > 0) {
      bytes32 inputTxHash;
      (txPos, inputTxHash,) = TxLib.validateProof(96, _youngestInputProof);
      require(
        inputTxHash == exitingTx.ins[_inputIndex].outpoint.hash,
        "Input from the proof is not referenced in exiting tx"
      );
      
      if (isNft(out.color)) {
        priority = (nftExitCounter << 128) | uint128(uint256(utxoId));
        nftExitCounter++;
      } else if (isNST(out.color)) {
        priority = (nstExitCounter << 128) | uint128(uint256(utxoId));
        nstExitCounter++;
      } else {      
        priority = getERC20ExitPriority(timestamp, utxoId, txPos);
      }
    } else {
      require(exitingTx.txType == TxLib.TxType.Deposit, "Expected deposit tx");
      if (isNft(out.color)) {
        priority = (nftExitCounter << 128) | uint128(uint256(utxoId));
        nftExitCounter++;
      } else if (isNST(out.color)) {
        priority = (nstExitCounter << 128) | uint128(uint256(utxoId));
        nstExitCounter++;
      } else {
        priority = getERC20ExitPriority(timestamp, utxoId, txPos);
      }
    }

    tokens[out.color].insert(priority);

    exits[utxoId] = Exit({
      owner: out.owner,
      color: out.color,
      amount: out.value,
      finalized: false,
      stake: exitStake,
      priorityTimestamp: timestamp,
      tokenData: out.stateRoot
    });

    emit ExitStarted(
      txHash,
      _outputIndex,
      out.color,
      out.owner,
      out.value
    );
  }

  function startDepositExit(uint256 _depositId) public payable {

    require(msg.value >= exitStake, "Not enough ether sent to pay for exit stake");
    Deposit memory deposit = deposits[uint32(_depositId)];
    require(deposit.owner == msg.sender, "Only deposit owner can start exit");
    require(deposit.amount > 0, "deposit has no value");
    require(exits[bytes32(_depositId)].amount == 0, "The exit of deposit has already been started");
    require(!exits[bytes32(_depositId)].finalized, "The exit for deposit has already been finalized");

    uint256 priority;
    if (isNft(deposit.color)) {
      priority = (nftExitCounter << 128) | uint128(_depositId);
      nftExitCounter++;
    } else if (isNST(deposit.color)) {
      priority = (nstExitCounter << 128) | uint128(_depositId);
      nstExitCounter++;
    } else {
      priority = getERC20ExitPriority(uint32(deposit.time), bytes32(_depositId), 0);
    }

    tokens[deposit.color].insert(priority);

    exits[bytes32(_depositId)] = Exit({
      owner: deposit.owner,
      color: deposit.color,
      amount: deposit.amount,
      finalized: false,
      stake: exitStake,
      priorityTimestamp: uint32(now),
      tokenData: "0x"
    });

    emit ExitStarted(
      bytes32(_depositId),
      0,
      deposit.color,
      deposit.owner,
      deposit.amount
    );
  }

  function finalizeExits(uint16 _color) public {

    bytes32 utxoId;
    uint256 exitableAt;
    Exit memory currentExit;

    (utxoId, exitableAt) = getNextExit(_color);

    require(tokens[_color].currentSize > 0, "Queue empty for color.");

    for (uint i = 0; i<20; i++) {
      if (exitableAt > block.timestamp) {
        return;
      }

      currentExit = exits[utxoId];

      if (currentExit.owner != address(0) || currentExit.amount != 0) { // exit was not removed
        if (isNft(currentExit.color)) {
          tokens[currentExit.color].addr.transferFrom(address(this), currentExit.owner, currentExit.amount);
        } else if (isNST(currentExit.color)) {
          bytes32 tokenData = currentExit.tokenData;
          address tokenAddr = address(tokens[currentExit.color].addr);

          bool success;
          (success, ) = tokenAddr.call(abi.encodeWithSignature("writeData(uint256,bytes32)", currentExit.amount, tokenData));
          if (!success) {
            tokenAddr.call(
              abi.encodeWithSignature(
                "breed(uint256,address,bytes32)",
                currentExit.amount, currentExit.owner, tokenData
              )
            );
          } else {
            tokens[currentExit.color].addr.transferFrom(address(this), currentExit.owner, currentExit.amount);
          }
        } else {
          tokens[currentExit.color].addr.approve(address(this), currentExit.amount);
          tokens[currentExit.color].addr.transferFrom(address(this), currentExit.owner, currentExit.amount);
        }
        address(uint160(currentExit.owner)).send(currentExit.stake);
      }

      tokens[currentExit.color].delMin();
      exits[utxoId].finalized = true;

      if (tokens[currentExit.color].currentSize > 0) {
        (utxoId, exitableAt) = getNextExit(_color);
      } else {
        return;
      }
    }
  }

  function finalizeTopExit(uint16 _color) public {

    finalizeExits(_color);
  }

  function challengeExit(
    bytes32[] memory _proof,
    bytes32[] memory _prevProof,
    uint8 _outputIndex,
    uint8 _inputIndex
  ) public {

    uint256 offset = 32 * (_proof.length + 2);
    bytes32 txHash1;
    bytes memory txData;
    (, txHash1, txData) = TxLib.validateProof(offset + 64, _prevProof);
    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash1)));

    TxLib.Tx memory txn;
    if (_proof.length > 0) {
      bytes32 txHash;
      (, txHash, txData) = TxLib.validateProof(96, _proof);
      txn = TxLib.parseTx(txData);

      require(txHash1 == txn.ins[_inputIndex].outpoint.hash);
      require(_outputIndex == txn.ins[_inputIndex].outpoint.pos);

      if (txn.txType == TxLib.TxType.Transfer) {
        bytes32 sigHash = TxLib.getSigHash(txData);
        address signer = ecrecover(
          sigHash,
          txn.ins[_inputIndex].v,
          txn.ins[_inputIndex].r,
          txn.ins[_inputIndex].s
        );
        require(exits[utxoId].owner == signer);
      } else {
        revert("unknown tx type");
      }
    } else {
      txn = TxLib.parseTx(txData);
      utxoId = txn.ins[_inputIndex].outpoint.hash;
      if (txn.txType == TxLib.TxType.Deposit) {
        Deposit memory deposit = deposits[uint32(uint256(utxoId))];
        require(deposit.amount == txn.outs[0].value, "value mismatch");
        require(deposit.owner == txn.outs[0].owner, "owner mismatch");
        require(deposit.color == txn.outs[0].color, "color mismatch");
        if (isNST(deposit.color)) {
          require(tokenData[uint32(uint256(utxoId))] == txn.outs[0].stateRoot, "data mismatch");
        }
      } else {
        revert("unexpected tx type");
      }
    }

    require(exits[utxoId].amount > 0, "exit not found");
    require(!exits[utxoId].finalized, "The exit has already been finalized");

    msg.sender.transfer(exits[utxoId].stake);
    delete exits[utxoId];
  }

  function challengeYoungestInput(
    bytes32[] memory _youngerInputProof,
    bytes32[] memory _exitingTxProof,
    uint8 _outputIndex,
    uint8 _inputIndex
  ) public {

    bytes32 txHash;
    bytes memory txData;
    (, txHash, txData) = TxLib.validateProof(32 * (_youngerInputProof.length + 2) + 64, _exitingTxProof);
    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash)));

    require(exits[utxoId].amount > 0, "There is no exit for this UTXO");

    TxLib.Tx memory exitingTx = TxLib.parseTx(txData);

    (,txHash,) = TxLib.validateProof(96, _youngerInputProof);

    require(txHash == exitingTx.ins[_inputIndex].outpoint.hash, "Given output is not referenced in exiting tx");

    uint32 youngerInputTimestamp;
    (,youngerInputTimestamp,,) = bridge.periods(_youngerInputProof[0]);
    require(youngerInputTimestamp > 0, "The referenced period was not submitted to bridge");

    require(exits[utxoId].priorityTimestamp < youngerInputTimestamp, "Challenged input should be older");

    msg.sender.transfer(exits[utxoId].stake);
    delete exits[utxoId];
  }

  function getNextExit(uint16 _color) internal view returns (bytes32 utxoId, uint256 exitableAt) {

    uint256 priority = tokens[_color].getMin();
    utxoId = bytes32(uint256(uint128(priority)));
    exitableAt = priority >> 192;
  }

  function isNft(uint16 _color) internal pure returns (bool) {

    return (_color >= NFT_FIRST_COLOR) && (_color < NST_FIRST_COLOR);
  }

  function isNST(uint16 _color) internal pure returns (bool) {

    return _color >= NST_FIRST_COLOR;
  }

  function getERC20ExitPriority(
    uint32 timestamp, bytes32 utxoId, uint64 txPos
  ) internal view returns (uint256 priority) {

    uint256 exitableAt = Math.max(timestamp + (2 * exitDuration), block.timestamp + exitDuration);
    return (exitableAt << 192) | uint256(txPos) << 128 | uint128(uint256(utxoId));
  }

  uint256[49] private ______gap;
}








contract FastExitHandler is ExitHandler {


  struct Data {
    uint32 timestamp;
    bytes32 txHash;
    uint64 txPos;
    bytes32 utxoId;
  }

  function startBoughtExit(
    bytes32[] memory _youngestInputProof, bytes32[] memory _proof,
    uint8 _outputIndex, uint8 _inputIndex, bytes32[] memory signedData
  ) public payable {

    require(msg.value >= exitStake, "Not enough ether sent to pay for exit stake");
    Data memory data;

    (,data.timestamp,,) = bridge.periods(_proof[0]);
    require(data.timestamp > 0, "The referenced period was not submitted to bridge");

    (, data.timestamp,,) = bridge.periods(_youngestInputProof[0]);
    require(data.timestamp > 0, "The referenced period was not submitted to bridge");

    bytes memory txData;
    (data.txPos, data.txHash, txData) = TxLib.validateProof(32 * (_youngestInputProof.length + 2) + 96, _proof);

    TxLib.Tx memory exitingTx = TxLib.parseTx(txData);
    TxLib.Output memory out = exitingTx.outs[_outputIndex];
    data.utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(data.txHash)));

    (uint256 buyPrice, bytes32 utxoIdSigned, address signer) = unpackSignedData(signedData);

    require(!isNft(out.color), "Can not fast exit NFTs");
    require(out.owner == address(this), "Funds were not sent to this contract");
    require(
      ecrecover(
        TxLib.getSigHash(txData),
        exitingTx.ins[0].v, exitingTx.ins[0].r, exitingTx.ins[0].s
      ) == signer,
      "Signer was not the previous owner of UTXO"
    );
    require(
      data.utxoId == utxoIdSigned,
      "The signed utxoid does not match the one in the proof"
    );

    require(out.value > 0, "UTXO has no value");
    require(exits[data.utxoId].amount == 0, "The exit for UTXO has already been started");
    require(!exits[data.utxoId].finalized, "The exit for UTXO has already been finalized");
    require(exitingTx.txType == TxLib.TxType.Transfer, "Can only fast exit transfer tx");

    uint256 priority;
    bytes32 inputTxHash;
    (data.txPos, inputTxHash,) = TxLib.validateProof(128, _youngestInputProof);
    require(
      inputTxHash == exitingTx.ins[_inputIndex].outpoint.hash,
      "Input from the proof is not referenced in exiting tx"
    );

    if (isNft(out.color)) {
      priority = (nftExitCounter << 128) | uint128(uint256(data.utxoId));
      nftExitCounter++;
    } else {
      priority = getERC20ExitPriority(data.timestamp, data.utxoId, data.txPos);
    }

    tokens[out.color].addr.transferFrom(msg.sender, signer, buyPrice);

    tokens[out.color].insert(priority);

    exits[data.utxoId] = Exit({
      owner: msg.sender,
      color: out.color,
      amount: out.value,
      finalized: false,
      stake: exitStake,
      priorityTimestamp: data.timestamp,
      tokenData: out.stateRoot
    });
    emit ExitStarted(
      data.txHash,
      _outputIndex,
      out.color,
      out.owner,
      out.value
    );
  }

  function unpackSignedData(
    bytes32[] memory signedData
  ) internal pure returns (
    uint256 buyPrice, bytes32 utxoId, address signer
  ) {

    utxoId = signedData[0];
    buyPrice = uint256(signedData[1]);
    bytes32 r = signedData[2];
    bytes32 s = signedData[3];
    uint8 v = uint8(uint256(signedData[4]));
    bytes32 sigHash = keccak256(abi.encodePacked(
      "\x19Ethereum Signed Message:\n",
      uint2str(64),
      utxoId,
      buyPrice
    ));
    signer = ecrecover(sigHash, v, r, s); // solium-disable-line arg-overflow
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }
}