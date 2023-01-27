
pragma solidity ^0.8.0;

interface IERC165 {

  function supportsInterface(bytes4 _interfaceId) external view returns (bool);

}

interface IERC1155 {


  event TransferSingle(
    address indexed _operator,
    address indexed _from,
    address indexed _to,
    uint256 _id,
    uint256 _amount
  );

  event TransferBatch(
    address indexed _operator,
    address indexed _from,
    address indexed _to,
    uint256[] _ids,
    uint256[] _amounts
  );

  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _id,
    uint256 _amount,
    bytes calldata _data
  ) external;


  function safeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] calldata _ids,
    uint256[] calldata _amounts,
    bytes calldata _data
  ) external;


  function balanceOf(address _owner, uint256 _id)
    external
    view
    returns (uint256);


  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
    external
    view
    returns (uint256[] memory);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator)
    external
    view
    returns (bool isOperator);

}

interface IERC1155TokenReceiver {

  function onERC1155Received(
    address _operator,
    address _from,
    uint256 _id,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bytes4);


  function onERC1155BatchReceived(
    address _operator,
    address _from,
    uint256[] calldata _ids,
    uint256[] calldata _amounts,
    bytes calldata _data
  ) external returns (bytes4);

}

library Address {

  function isContract(address account) internal view returns (bool) {


    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}

abstract contract Ownable {
  address private _owner;

  string private constant ERR = "Ownable";

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    _transferOwnership(msg.sender);
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == msg.sender, ERR);
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), ERR);
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

contract ERC1155Metadata {

  string private baseMetadataURI;


  function uri(uint256 _id) public view returns (string memory) {

    bytes memory bytesURI = bytes(baseMetadataURI);
    if (bytesURI.length == 0 || bytesURI[bytesURI.length - 1] == '/')
      return string(abi.encodePacked(baseMetadataURI, _uint2str(_id), ".json"));
    else return baseMetadataURI;
  }

  function _setBaseMetadataURI(string memory _newBaseMetadataURI) internal {

    baseMetadataURI = _newBaseMetadataURI;
  }


  function _uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {

    if (_i == 0) {
      return "0";
    }

    uint256 j = _i;
    uint256 ii = _i;
    uint256 len;

    while (j != 0) {
      len++;
      j /= 10;
    }

    bytes memory bstr = new bytes(len);

    while (ii != 0) {
      bstr[--len] = bytes1(uint8(48 + ii % 10));
      ii /= 10;
    }

    return string(bstr);
  }
}

abstract contract ReentrancyGuard {

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  string private constant ERR = "Reentrancy";

  uint256 private _status;

  constructor() {
    _status = _NOT_ENTERED;
  }

  modifier nonReentrant() {
    require(_status != _ENTERED, ERR);

    _status = _ENTERED;

    _;

    _status = _NOT_ENTERED;
  }
}

contract ProxyRegistry {

  mapping(address => address) public proxies;
}

contract ERC1155Base is IERC1155, IERC165, ERC1155Metadata, Ownable, ReentrancyGuard {

  using Address for address;


  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  address constant internal NULL_ADDR = address(0);

  string private constant ERR = "ERC1155Base";

  string public name;

  string public symbol;

  address private immutable _proxyRegistry;

  address private immutable _initializer;

  mapping (address => mapping(uint256 => uint256)) internal balances;

  mapping (address => mapping(address => bool)) internal operators;

  uint256 private _maxTxMint;

  uint256 private _cap;

  uint256 private _tokenPrice;

  uint256 private _currentTokenId;

  uint256 mintAllowed;

  event Distributed(address indexed receiver, uint256 amount);


  constructor(address initializer_, address proxyRegistry) {
    _proxyRegistry = proxyRegistry;
    _initializer = initializer_;
  }

  function initialize(
    address owner_,
    string memory name_,
    string memory symbol_
   ) external
  {

    require(msg.sender == _initializer, ERR);

    _transferOwnership(owner_);
    name = name_;
    symbol = symbol_;

    balances[owner_][0] = 1;
    emit TransferSingle(msg.sender, NULL_ADDR, owner(), 0, 1);
  }

  function initialize(
    address owner_,
    string memory name_,
    string memory symbol_,
    uint256 cap_,
    uint256 maxPerTx_,
    uint256 price_) external
  {

    require(msg.sender == _initializer, ERR);

    _transferOwnership(owner_);

    name = name_;
    symbol = symbol_;
    _cap = cap_;
    _maxTxMint = maxPerTx_;
    _tokenPrice = price_;
    balances[owner_][0] = 1;
    _currentTokenId = 1;
    mintAllowed = 1;
    emit TransferSingle(msg.sender, NULL_ADDR, owner_, 0, 1);
  }


  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
    external override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), ERR);
    require(_to != address(0), ERR);
 
    _safeTransferFrom(_from, _to, _id, _amount);
    _callonERC1155Received(_from, _to, _id, _amount, _data);
  }

  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    external override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), ERR);
    require(_to != address(0), ERR);

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);
    _callonERC1155BatchReceived(_from, _to, _ids, _amounts, _data);
  }

  function unsafeBatchMint(address[] calldata _tos, uint256[] calldata _counts, uint256[] calldata _ids) external onlyOwner {

    uint256 idOffset = 0;
    for (uint256 i = 0; i < _tos.length; ++i) {
      uint256 idOffsetEnd = idOffset + _counts[i];
      require (idOffsetEnd <= _ids.length, ERR);
      {
        uint256 curE = _ids[idOffset] >> 8;
        uint256 mask = 0;
        for (; idOffset < idOffsetEnd; ++idOffset) {
          uint256 elem = _ids[idOffset] >> 8;
          uint256 id = uint256(1) << (_ids[idOffset] & 0xFF);
          if (elem != curE) {
            balances[_tos[i]][curE] |= mask;
            curE = elem;
            mask = 0;
          }
          mask |= id;
        }
        balances[_tos[i]][curE] |= mask;
        emit TransferSingle(msg.sender, NULL_ADDR, _tos[i], _ids[idOffset], 1);
      }

      uint256[] memory amounts = new uint256[](_counts[i]);
      for (uint pos = 0; pos < _counts[i]; ++pos)
        amounts[pos] = 1;
      _callonERC1155BatchReceived(address(0), _tos[i], _ids[idOffsetEnd - _counts[i]:idOffsetEnd], amounts, '');
    }
  }

  function unsafeBatchMessage(address[] calldata _tos, uint256[] calldata _counts, uint256[] calldata _ids) external onlyOwner {

    uint256 idOffset = 0;
    for (uint256 i = 0; i < _tos.length; ++i) {
      uint256 idOffsetEnd = idOffset + _counts[i];
      require (idOffsetEnd <= _ids.length, ERR);
      for (; idOffset < idOffsetEnd; ++idOffset) {
        emit TransferSingle(msg.sender, NULL_ADDR, _tos[i], _ids[idOffset], 1);
      }
    }
  }

  function mint(address to, uint256 numMint) external payable nonReentrant {

    uint256 tid = _currentTokenId;
    uint256 tidEnd = _currentTokenId + numMint;

    require(mintAllowed != 0 &&
      numMint > 0 &&
      numMint <= _maxTxMint &&
      tidEnd <= _cap &&
      msg.value >= numMint * _tokenPrice, ERR
    );
    
    {
      uint256 mask = 0;
      uint256 curE = tid >> 8;
      for (; tid < tidEnd; ++tid) {
        uint256 elem = tid >> 8;
        uint256 id = uint256(1) << (tid & 0xFF);
        if (elem != curE) {
          balances[to][curE] |= mask;
          curE = elem;
          mask = 0;
        }
        mask |= id;
        emit TransferSingle(msg.sender, NULL_ADDR, to, tid, 1);
      }
      balances[to][curE] |= mask;
      _currentTokenId += numMint;
    }

    {
      uint256 dust = msg.value - (numMint * _tokenPrice);
      if (dust > 0) payable(msg.sender).transfer(dust);
    }

    { 
      uint256[] memory ids = new uint256[](numMint);
      uint256[] memory amounts = new uint256[](numMint);
      for (uint256 i = 0; i < numMint; ++i) {
        ids[i] = tid - numMint--;
        amounts[i] = 1;
      }
      _callonERC1155BatchReceived(address(0), to, ids, amounts, '');
    }
  }

  function distribute(
    address[] calldata accounts,
    uint256[] calldata refunds,
    uint256[] calldata percents
  ) external onlyOwner {

    require(
      (refunds.length == 0 || refunds.length == accounts.length) &&
        (percents.length == 0 || percents.length == accounts.length),
      ERR
    );

    uint256 availableAmount = address(this).balance;
    uint256[] memory amounts = new uint256[](accounts.length);

    for (uint256 i = 0; i < refunds.length; ++i) {
      require(refunds[i] <= availableAmount, ERR);
      amounts[i] = refunds[i];
      availableAmount -= refunds[i];
    }

    uint256 amountToShare = availableAmount;
    for (uint256 i = 0; i < percents.length; ++i) {
      uint256 amount = (amountToShare * percents[i]) / 100;
      amounts[i] += (amount <= availableAmount) ? amount : availableAmount;
      availableAmount -= amount;
    }

    for (uint256 i = 0; i < accounts.length; ++i) {
      if (amounts[i] > 0) {
        payable(accounts[i]).transfer(amounts[i]);
        emit Distributed(accounts[i], amounts[i]);
      }
    }
  }

  function setBaseMetadataURI(string memory _newBaseMetadataURI) external onlyOwner {

    _setBaseMetadataURI(_newBaseMetadataURI);
  }


  function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
    internal
  {

    require(_amount == 1, ERR);

    _transferOwner(_from, _to, _id);

    emit TransferSingle(msg.sender, _from, _to, _id, _amount);
  }

  function _callonERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _id, _amount, _data);
      require(retval == ERC1155_RECEIVED_VALUE, ERR);
    }
  }

  function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts)
    internal
  {

    uint256 len = _ids.length;

    require(len == _amounts.length, ERR);

    for (uint256 i = 0; i < len; ++i) {
      require(_amounts[i] == 1, ERR);
      _transferOwner(_from, _to, _ids[i]);
    }

    emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
  }

  function _callonERC1155BatchReceived(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _ids, _amounts, _data);
      require(retval == ERC1155_BATCH_RECEIVED_VALUE, ERR);
    }
  }



  function setApprovalForAll(address _operator, bool _approved)
    external override
  {

    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function isApprovedForAll(address _owner, address _operator)
    public view override returns (bool isOperator)
  {

    ProxyRegistry proxyRegistry = ProxyRegistry(_proxyRegistry);
    if (address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return operators[_owner][_operator];
  }



  function balanceOf(address _owner, uint256 _id)
    public view override returns (uint256)
  {

    return _isOwner(_owner, _id) ? 1 : 0;
  }

  function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
    public view override returns (uint256[] memory)
  {

    require(_owners.length == _ids.length, ERR);

    uint256[] memory batchBalances = new uint256[](_owners.length);

    for (uint256 i = 0; i < _owners.length; i++) {
      batchBalances[i] = _isOwner(_owners[i], _ids[i]) ? 1 : 0;
    }

    return batchBalances;
  }



  bytes4 constant private INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;

  bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

  function supportsInterface(bytes4 _interfaceID) external pure override returns (bool) {

    if (_interfaceID == INTERFACE_SIGNATURE_ERC165 ||
        _interfaceID == INTERFACE_SIGNATURE_ERC1155) {
      return true;
    }
    return false;
  }


  function _isOwner(address _from, uint256 _id) internal view returns (bool) {

    return (balances[_from][_id >> 8] & (uint256(1) << (_id & 0xFF))) != 0;
  }

  function _transferOwner(address _from, address _to, uint256 _id) internal {

    uint256 elem = _id >> 8;
    uint256 id = uint256(1) << (_id & 0xFF);

    if (_from != NULL_ADDR) {
      require((balances[_from][elem] & id) != 0, ERR);
      balances[_from][elem] &=~id;
    }
    
    if (_to != NULL_ADDR) {
      balances[_to][elem] |= id;
    }
  }
}