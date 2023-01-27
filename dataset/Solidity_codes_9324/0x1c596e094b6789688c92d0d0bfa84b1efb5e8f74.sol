
pragma solidity ^0.4.24;


interface ERC165 {


  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

}


contract ERC721Basic is ERC165 {


  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;

  bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;

  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;

  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;

  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function balanceOf(address _owner) public view returns (uint256 _balance);

  function ownerOf(uint256 _tokenId) public view returns (address _owner);

  function exists(uint256 _tokenId) public view returns (bool _exists);


  function approve(address _to, uint256 _tokenId) public;

  function getApproved(uint256 _tokenId)
    public view returns (address _operator);


  function setApprovalForAll(address _operator, bool _approved) public;

  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);


  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;

}


contract ERC721Enumerable is ERC721Basic {

  function totalSupply() public view returns (uint256);

  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256 _tokenId);


  function tokenByIndex(uint256 _index) public view returns (uint256);

}


contract ERC721Metadata is ERC721Basic {

  function name() external view returns (string _name);

  function symbol() external view returns (string _symbol);

  function tokenURI(uint256 _tokenId) public view returns (string);

}


contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {

}


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


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


contract ERC20Receiver {

  bytes4 constant ERC20_RECEIVED = 0xbc04f0af;

  function onERC20Received(address _from, uint256 amount) public returns(bytes4);

}


contract ERC721Receiver {

  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  function onERC721Received(
    address _from,
    uint256 _tokenId,
    bytes _data
  )
    public
    returns(bytes4);

}


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


library ECVerify {


  enum SignatureMode {
    EIP712,
    GETH,
    TREZOR
  }

  function recover(bytes32 hash, bytes signature) internal pure returns (address) {

    require(signature.length == 66);
    SignatureMode mode = SignatureMode(uint8(signature[0]));

    uint8 v;
    bytes32 r;
    bytes32 s;
    assembly {
      r := mload(add(signature, 33))
      s := mload(add(signature, 65))
      v := and(mload(add(signature, 66)), 255)
    }

    if (mode == SignatureMode.GETH) {
      hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    } else if (mode == SignatureMode.TREZOR) {
      hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n\x20", hash));
    }

    return ecrecover(hash, v, r, s);
  }

  function ecverify(bytes32 hash, bytes sig, address signer) internal pure returns (bool) {

    return signer == recover(hash, sig);
  }
}


contract ValidatorManagerContract is Ownable {

  using ECVerify for bytes32;

  mapping (address => bool) public allowedTokens;
  mapping (address => uint256) public nonces;
  mapping (address => bool) validators;

  uint8 threshold_num;
  uint8 threshold_denom;
  uint256 public numValidators;
  uint256 public nonce; // used for replay protection when adding/removing validators

  event AddedValidator(address validator);
  event RemovedValidator(address validator);

  modifier onlyValidator() { require(checkValidator(msg.sender)); _; }


  constructor (address[] _validators, uint8 _threshold_num, uint8 _threshold_denom) public {
    uint256 length = _validators.length;
    require(length > 0);

    threshold_num = _threshold_num;
    threshold_denom = _threshold_denom;
    for (uint256 i = 0; i < length ; i++) {
      require(_validators[i] != address(0));
      validators[_validators[i]] = true;
      emit AddedValidator(_validators[i]);
    }
    numValidators = _validators.length;
  }

  modifier isVerifiedByValidator(uint256 num, address contractAddress, bytes sig) {

    bytes32 hash = keccak256(abi.encodePacked(msg.sender, contractAddress, nonces[msg.sender], num));
    address sender = hash.recover(sig);
    require(validators[sender], "Message not signed by a validator");
    _;
    nonces[msg.sender]++; // increment nonce after execution
  }

  function checkValidator(address _address) public view returns (bool) {

    if (_address == owner) {
      return true;
    }
    return validators[_address];
  }

  function addValidator(address validator, uint8[] v, bytes32[] r, bytes32[] s)
    external
  {

    require(!validators[validator], "Already a validator");

    bytes32 message = keccak256(abi.encodePacked("add", validator, nonce));
    checkThreshold(message, v, r, s);

    validators[validator] = true;
    numValidators++;
    nonce++;
    emit AddedValidator(validator);
  }

  function removeValidator(address validator, uint8[] v, bytes32[] r, bytes32[] s)
    external
  {

    require(validators[validator], "Not a validator");
    require(numValidators > 1);

    bytes32 message = keccak256(abi.encodePacked("remove", validator, nonce));
    checkThreshold(message, v, r, s);

    delete validators[validator];
    numValidators--;
    nonce++;
    emit RemovedValidator(validator);
  }

  function checkThreshold(bytes32 message, uint8[] v, bytes32[] r, bytes32[] s) private view {

    require(v.length > 0 && v.length == r.length && r.length == s.length,
      "Incorrect number of params");
    require(v.length >= (threshold_num * numValidators / threshold_denom ),
      "Not enough votes");

    bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
    uint256 sig_length = v.length;

    address lastAdd = address(0);
    for (uint256 i = 0; i < sig_length; i++) {
      address signer = ecrecover(hash, v[i], r[i], s[i]);
      require(signer > lastAdd && validators[signer], "Not signed by a validator");
      lastAdd = signer;
    }
  }

  function toggleToken(address _token) public onlyValidator {

    allowedTokens[_token] = !allowedTokens[_token];
  }
}


contract Gateway is ERC20Receiver, ERC721Receiver, ValidatorManagerContract {


  using SafeMath for uint256;

  struct Balance {
    uint256 eth;
    mapping(address => uint256) erc20;
    mapping(address => mapping(uint256 => bool)) erc721;
  }

  mapping (address => Balance) balances;

  event ETHReceived(address from, uint256 amount);
  event ERC20Received(address from, uint256 amount, address contractAddress);
  event ERC721Received(address from, uint256 uid, address contractAddress);

  enum TokenKind {
    ETH,
    ERC20,
    ERC721
  }

  event TokenWithdrawn(address indexed owner, TokenKind kind, address contractAddress, uint256 value);

  constructor (address[] _validators, uint8 _threshold_num, uint8 _threshold_denom)
    public ValidatorManagerContract(_validators, _threshold_num, _threshold_denom) {
  }

  function depositETH() private {

    balances[msg.sender].eth = balances[msg.sender].eth.add(msg.value);
  }

  function depositERC721(address from, uint256 uid) private {

    balances[from].erc721[msg.sender][uid] = true;
  }

  function depositERC20(address from, uint256 amount) private {

    balances[from].erc20[msg.sender] = balances[from].erc20[msg.sender].add(amount);
  }

  function withdrawERC20(uint256 amount, bytes sig, address contractAddress)
    external
    isVerifiedByValidator(amount, contractAddress, sig)
  {

    balances[msg.sender].erc20[contractAddress] = balances[msg.sender].erc20[contractAddress].sub(amount);
    ERC20(contractAddress).transfer(msg.sender, amount);
    emit TokenWithdrawn(msg.sender, TokenKind.ERC20, contractAddress, amount);
  }

  function withdrawERC721(uint256 uid, bytes sig, address contractAddress)
    external
    isVerifiedByValidator(uid, contractAddress, sig)
  {

    require(balances[msg.sender].erc721[contractAddress][uid], "Does not own token");
    ERC721(contractAddress).safeTransferFrom(address(this),  msg.sender, uid);
    delete balances[msg.sender].erc721[contractAddress][uid];
    emit TokenWithdrawn(msg.sender, TokenKind.ERC721, contractAddress, uid);
  }

  function withdrawETH(uint256 amount, bytes sig)
    external
    isVerifiedByValidator(amount, address(this), sig)
  {

    balances[msg.sender].eth = balances[msg.sender].eth.sub(amount);
    msg.sender.transfer(amount); // ensure it's not reentrant
    emit TokenWithdrawn(msg.sender, TokenKind.ETH, address(0), amount);
  }

  function depositERC20(uint256 amount, address contractAddress) external {

    ERC20(contractAddress).transferFrom(msg.sender, address(this), amount);
    balances[msg.sender].erc20[contractAddress] = balances[msg.sender].erc20[contractAddress].add(amount);
    emit ERC20Received(msg.sender, amount, contractAddress);
  }


  function onERC20Received(address _from, uint256 amount)
    public
    returns (bytes4)
  {

    require(allowedTokens[msg.sender], "Not a valid token");
    depositERC20(_from, amount);
    emit ERC20Received(_from, amount, msg.sender);
    return ERC20_RECEIVED;
  }

  function onERC721Received(address _from, uint256 _uid, bytes)
    public
    returns (bytes4)
  {

    require(allowedTokens[msg.sender], "Not a valid token");
    depositERC721(_from, _uid);
    emit ERC721Received(_from, _uid, msg.sender);
    return ERC721_RECEIVED;
  }

  function () external payable {
    depositETH();
    emit ETHReceived(msg.sender, msg.value);
  }

  function getETH(address owner) external view returns (uint256) {

    return balances[owner].eth;
  }

  function getERC20(address owner, address contractAddress) external view returns (uint256) {

    return balances[owner].erc20[contractAddress];
  }

  function getNFT(address owner, uint256 uid, address contractAddress) external view returns (bool) {

    return balances[owner].erc721[contractAddress][uid];
  }
}