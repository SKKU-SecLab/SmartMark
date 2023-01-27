
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}//MIT
pragma solidity 0.6.8;


interface IRegistry {
    function getAddress(bytes32 name) external view returns (address);

    function requireAndGetAddress(bytes32 name) external view returns (address);
}// MIT
pragma solidity ^0.6.8;


interface IStakingBank is IERC20 {
  function receiveApproval(address _from) external returns (bool success);

  function withdraw(uint256 _value) external returns (bool success);

  function create(address _id, string calldata _location) external;

  function update(address _id, string calldata _location) external;

  function addresses(uint256 _ix) external view returns (address);

  function validators(address _id) external view returns (address id, string memory location);

  function getNumberOfValidators() external view returns (uint256);
}//MIT
pragma solidity 0.6.8;


abstract contract Registrable {
  IRegistry public contractRegistry;


  constructor(address _contractRegistry) internal {
    require(_contractRegistry != address(0x0), "_registry is empty");
    contractRegistry = IRegistry(_contractRegistry);
  }


  modifier onlyFromContract(address _msgSender, bytes32 _contractName) {
    require(
      contractRegistry.getAddress(_contractName) == _msgSender,
        string(abi.encodePacked("caller is not ", _contractName))
    );
    _;
  }

  modifier withRegistrySetUp() {
    require(address(contractRegistry) != address(0x0), "_registry is empty");
    _;
  }


  function register() virtual external {
  }

  function unregister() virtual external {
  }


  function getName() virtual external pure returns (bytes32);

  function stakingBankContract() public view returns (IStakingBank) {
    return IStakingBank(contractRegistry.requireAndGetAddress("StakingBank"));
  }

  function tokenContract() public view withRegistrySetUp returns (ERC20) {
    return ERC20(contractRegistry.requireAndGetAddress("UMB"));
  }
}//MIT
pragma solidity 0.6.8;



contract Registry is Ownable {
  mapping(bytes32 => address) public registry;


  event LogRegistered(address indexed destination, bytes32 name);


  function importAddresses(bytes32[] calldata _names, address[] calldata _destinations) external onlyOwner {
    require(_names.length == _destinations.length, "Input lengths must match");

    for (uint i = 0; i < _names.length; i++) {
      registry[_names[i]] = _destinations[i];
      emit LogRegistered(_destinations[i], _names[i]);
    }
  }

  function importContracts(address[] calldata _destinations) external onlyOwner {
    for (uint i = 0; i < _destinations.length; i++) {
      bytes32 name = Registrable(_destinations[i]).getName();
      registry[name] = _destinations[i];
      emit LogRegistered(_destinations[i], name);
    }
  }

  function atomicUpdate(address _newContract) external onlyOwner {
    Registrable(_newContract).register();

    bytes32 name = Registrable(_newContract).getName();
    address oldContract = registry[name];
    registry[name] = _newContract;

    Registrable(oldContract).unregister();

    emit LogRegistered(_newContract, name);
  }


  function requireAndGetAddress(bytes32 name) external view returns (address) {
    address _foundAddress = registry[name];
    require(_foundAddress != address(0), string(abi.encodePacked("Name not registered: ", name)));
    return _foundAddress;
  }

  function getAddress(bytes32 _bytes) external view returns (address) {
    return registry[_bytes];
  }

  function getAddressByString(string memory _name) public view returns (address) {
    return registry[stringToBytes32(_name)];
  }

  function stringToBytes32(string memory _string) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(_string);

    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
      result := mload(add(_string, 32))
    }
  }
}// MIT
pragma solidity ^0.6.8;

library MerkleProof {
  uint256 constant public ROOT_MASK = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000;
  uint256 constant public TIMESTAMP_MASK = 0xffffffff;

  function extractSquashedData(bytes32 _rootTimestamp) internal pure returns (bytes32 root, uint32 dataTimestamp) {
    assembly {
      root := and(_rootTimestamp, ROOT_MASK)
      dataTimestamp := and(_rootTimestamp, TIMESTAMP_MASK)
    }
  }

  function extractRoot(bytes32 _rootTimestamp) internal pure returns (bytes32 root) {
    assembly {
      root := and(_rootTimestamp, ROOT_MASK)
    }
  }

  function extractTimestamp(bytes32 _rootTimestamp) internal pure returns (uint32 dataTimestamp) {
    assembly {
      dataTimestamp := and(_rootTimestamp, TIMESTAMP_MASK)
    }
  }

  function makeSquashedRoot(bytes32 _root, uint32 _timestamp) internal pure returns (bytes32 rootTimestamp) {
    assembly {
      rootTimestamp := or(and(_root, ROOT_MASK), _timestamp)
    }
  }

  function verifySquashedRoot(bytes32 squashedRoot, bytes32[] memory proof, bytes32 leaf) internal pure returns (bool) {
    return extractRoot(computeRoot(proof, leaf)) == extractRoot(squashedRoot);
  }

  function verify(bytes32 root, bytes32[] memory proof, bytes32 leaf) internal pure returns (bool) {
    return computeRoot(proof, leaf) == root;
  }

  function computeRoot(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash <= proofElement) {
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }

    return computedHash;
  }
}//Unlicensed
pragma solidity >=0.6.8;

library ValueDecoder {
  function toUint(bytes memory _bytes) internal pure returns (uint256 value) {
    assembly {
      value := mload(add(_bytes, 32))
    }
  }

  function toUint(bytes32 _bytes) internal pure returns (uint256 value) {
    assembly {
      value := _bytes
    }
  }
}// MIT
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;




abstract contract BaseChain is Registrable, Ownable {
  using ValueDecoder for bytes;
  using MerkleProof for bytes32;


  bytes constant public ETH_PREFIX = "\x19Ethereum Signed Message:\n32";

  struct Block {
    bytes32 root;
    uint32 dataTimestamp;
  }

  struct FirstClassData {
    uint224 value;
    uint32 dataTimestamp;
  }

  mapping(uint256 => bytes32) public squashedRoots;
  mapping(bytes32 => FirstClassData) public fcds;

  uint32 public blocksCount;
  uint32 public immutable blocksCountOffset;
  uint16 public padding;
  uint16 public immutable requiredSignatures;


  constructor(
    address _contractRegistry,
    uint16 _padding,
    uint16 _requiredSignatures // we have a plan to use signatures also in foreign Chains so lets keep it in base
  ) public Registrable(_contractRegistry) {
    padding = _padding;
    requiredSignatures = _requiredSignatures;
    BaseChain oldChain = BaseChain(Registry(_contractRegistry).getAddress("Chain"));

    blocksCountOffset = address(oldChain) != address(0x0)
      ? oldChain.blocksCount() + oldChain.blocksCountOffset() + 1
      : 0;
  }


  function setPadding(uint16 _padding) external onlyOwner {
    padding = _padding;
    emit LogPadding(msg.sender, _padding);
  }


  function isForeign() virtual external pure returns (bool);

  function recoverSigner(bytes32 _affidavit, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
    bytes32 hash = keccak256(abi.encodePacked(ETH_PREFIX, _affidavit));
    return ecrecover(hash, _v, _r, _s);
  }

  function blocks(uint256 _blockId) external view returns (Block memory) {
    bytes32 root = squashedRoots[_blockId];
    return Block(root, root.extractTimestamp());
  }

  function getBlockId() public view returns (uint32) {
    return getBlockIdAtTimestamp(block.timestamp);
  }

  function getBlockIdAtTimestamp(uint256 _timestamp) virtual public view returns (uint32) {
    uint32 _blocksCount = blocksCount + blocksCountOffset;

    if (_blocksCount == 0) {
      return 0;
    }

    if (squashedRoots[_blocksCount - 1].extractTimestamp() + padding < _timestamp) {
      return _blocksCount;
    }

    return _blocksCount - 1;
  }

  function getLatestBlockId() virtual public view returns (uint32) {
    return blocksCount + blocksCountOffset - 1;
  }

  function verifyProof(bytes32[] memory _proof, bytes32 _root, bytes32 _leaf) public pure returns (bool) {
    if (_root == bytes32(0)) {
      return false;
    }

    return _root.verify(_proof, _leaf);
  }

  function hashLeaf(bytes memory _key, bytes memory _value) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(_key, _value));
  }

  function verifyProofForBlock(
    uint256 _blockId,
    bytes32[] memory _proof,
    bytes memory _key,
    bytes memory _value
  ) public view returns (bool) {
    return squashedRoots[_blockId].verifySquashedRoot(_proof, keccak256(abi.encodePacked(_key, _value)));
  }

  function bytesToBytes32Array(
    bytes memory _data,
    uint256 _offset,
    uint256 _items
  ) public pure returns (bytes32[] memory) {
    bytes32[] memory dataList = new bytes32[](_items);

    for (uint256 i = 0; i < _items; i++) {
      bytes32 temp;
      uint256 idx = (i + 1 + _offset) * 32;

      assembly {
        temp := mload(add(_data, idx))
      }

      dataList[i] = temp;
    }

    return (dataList);
  }

  function verifyProofs(
    uint32[] memory _blockIds,
    bytes memory _proofs,
    uint256[] memory _proofItemsCounter,
    bytes32[] memory _leaves
  ) public view returns (bool[] memory results) {
    results = new bool[](_leaves.length);
    uint256 offset = 0;

    for (uint256 i = 0; i < _leaves.length; i++) {
      results[i] = squashedRoots[_blockIds[i]].verifySquashedRoot(
        bytesToBytes32Array(_proofs, offset, _proofItemsCounter[i]), _leaves[i]
      );

      offset += _proofItemsCounter[i];
    }
  }

  function getBlockRoot(uint32 _blockId) external view returns (bytes32) {
    return squashedRoots[_blockId].extractRoot();
  }

  function getBlockTimestamp(uint32 _blockId) external view returns (uint32) {
    return squashedRoots[_blockId].extractTimestamp();
  }

  function getCurrentValues(bytes32[] calldata _keys)
  external view returns (uint256[] memory values, uint32[] memory timestamps) {
    timestamps = new uint32[](_keys.length);
    values = new uint256[](_keys.length);

    for (uint i=0; i<_keys.length; i++) {
      FirstClassData storage numericFCD = fcds[_keys[i]];
      values[i] = uint256(numericFCD.value);
      timestamps[i] = numericFCD.dataTimestamp;
    }
  }

  function getCurrentValue(bytes32 _key) external view returns (uint256 value, uint256 timestamp) {
    FirstClassData storage numericFCD = fcds[_key];
    return (uint256(numericFCD.value), numericFCD.dataTimestamp);
  }


  event LogPadding(address indexed executor, uint16 timePadding);
}// MIT
pragma solidity ^0.6.8;


contract ForeignChain is BaseChain {
  address public immutable replicator;
  uint32 public lastBlockId;
  bool public deprecated;


  event LogBlockReplication(address indexed minter, uint32 blockId);
  event LogDeprecation(address indexed deprecator);


  constructor(
    address _contractRegistry,
    uint16 _padding,
    uint16 _requiredSignatures,
    address _replicator
  ) public BaseChain(_contractRegistry, _padding, _requiredSignatures) {
    replicator = _replicator;
  }

  modifier onlyReplicator() {
    require(msg.sender == replicator, "onlyReplicator");
    _;
  }


  function register() override external {
    require(msg.sender == address(contractRegistry), "only contractRegistry can register");

    ForeignChain oldChain = ForeignChain(contractRegistry.getAddress("Chain"));
    require(address(oldChain) != address(this), "registration must be done before address in registry is replaced");

    if (address(oldChain) != address(0x0)) {
      lastBlockId = oldChain.lastBlockId();

      uint32 lastBlockTime = oldChain.blocks(lastBlockId).dataTimestamp;
      bytes32 lastRootTime;
      assembly {
        lastRootTime := or(0x0, lastBlockTime)
      }
      squashedRoots[lastBlockId] = lastRootTime;

    }
  }

  function unregister() override external {
    require(msg.sender == address(contractRegistry), "only contractRegistry can unregister");
    require(!deprecated, "contract is already deprecated");

    ForeignChain newChain = ForeignChain(contractRegistry.getAddress("Chain"));
    require(address(newChain) != address(this), "unregistering must be done after address in registry is replaced");
    require(newChain.isForeign(), "can not be replaced with chain of different type");

    deprecated = true;
    emit LogDeprecation(msg.sender);
  }

  function submit(
    uint32 _dataTimestamp,
    bytes32 _root,
    bytes32[] calldata _keys,
    uint256[] calldata _values,
    uint32 _blockId
  ) external onlyReplicator {
    require(!deprecated, "contract is deprecated");
    uint lastDataTimestamp = squashedRoots[lastBlockId].extractTimestamp();

    require(squashedRoots[_blockId].extractTimestamp() == 0, "blockId already taken");
    require(lastDataTimestamp < _dataTimestamp, "can NOT submit older data");
    require(lastDataTimestamp + padding < block.timestamp, "do not spam");
    require(_keys.length == _values.length, "numbers of keys and values not the same");

    for (uint256 i = 0; i < _keys.length; i++) {
      require(uint224(_values[i]) == _values[i], "FCD overflow");
      fcds[_keys[i]] = FirstClassData(uint224(_values[i]), _dataTimestamp);
    }

    squashedRoots[_blockId] = MerkleProof.makeSquashedRoot(_root, _dataTimestamp);
    lastBlockId = _blockId;

    emit LogBlockReplication(msg.sender, _blockId);
  }


  function isForeign() override external pure returns (bool) {
    return true;
  }

  function getName() override external pure returns (bytes32) {
    return "Chain";
  }

  function getStatus() external view returns(
    uint256 blockNumber,
    uint16 timePadding,
    uint32 lastDataTimestamp,
    uint32 lastId,
    uint32 nextBlockId
  ) {
    blockNumber = block.number;
    timePadding = padding;
    lastId = lastBlockId;
    lastDataTimestamp = squashedRoots[lastId].extractTimestamp();
    nextBlockId = getBlockIdAtTimestamp(block.timestamp + 1);
  }

  function getBlockIdAtTimestamp(uint256 _timestamp) override public view  returns (uint32) {
    uint32 lastId = lastBlockId;
    uint32 dataTimestamp = squashedRoots[lastId].extractTimestamp();

    if (dataTimestamp == 0) {
      return 0;
    }

    if (dataTimestamp + padding < _timestamp) {
      return lastId + 1;
    }

    return lastId;
  }

  function getLatestBlockId() override public view returns (uint32) {
    return lastBlockId;
  }
}