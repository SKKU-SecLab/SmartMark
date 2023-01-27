pragma solidity 0.8.3;

interface IERC1155TokenReceiver {


  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4);


  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4);

}// Apache-2.0
pragma solidity 0.8.3;


interface IERC1155 {



  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;


  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;


  function balanceOf(address _owner, uint256 _id) external view returns (uint256);


  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

}// UNLICENSED
pragma solidity 0.8.3;


library Address {


  bytes32 constant internal ACCOUNT_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

  function isContract(address _address) internal view returns (bool) {

    bytes32 codehash;

    assembly { codehash := extcodehash(_address) }
    return (codehash != 0x0 && codehash != ACCOUNT_HASH);
  }
}// UNLICENSED
pragma solidity 0.8.3;

abstract contract ERC165 {
  function supportsInterface(bytes4 _interfaceID) virtual public pure returns (bool) {
    return _interfaceID == this.supportsInterface.selector;
  }
}// Apache-2.0
pragma solidity 0.8.3;



contract ERC1155PackedBalance is IERC1155, ERC165 {

  using Address for address;


  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  uint256 internal constant IDS_BITS_SIZE   = 32;                  // Max balance amount in bits per token ID
  uint256 internal constant IDS_PER_UINT256 = 256 / IDS_BITS_SIZE; // Number of ids per uint256

  enum Operations { Add, Sub }

  mapping (address => mapping(uint256 => uint256)) internal balances;

  mapping (address => mapping(address => bool)) internal operators;



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
    public override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155PackedBalance#safeTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155PackedBalance#safeTransferFrom: INVALID_RECIPIENT");

    _safeTransferFrom(_from, _to, _id, _amount);
    _callonERC1155Received(_from, _to, _id, _amount, gasleft(), _data);
  }

  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    public override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155PackedBalance#safeBatchTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155PackedBalance#safeBatchTransferFrom: INVALID_RECIPIENT");

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);
    _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasleft(), _data);
  }



  function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
    internal
  {

    _updateIDBalance(_from, _id, _amount, Operations.Sub); // Subtract amount from sender
    _updateIDBalance(_to,   _id, _amount, Operations.Add); // Add amount to recipient

    emit TransferSingle(msg.sender, _from, _to, _id, _amount);
  }

  function _callonERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, uint256 _gasLimit, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received{gas:_gasLimit}(msg.sender, _from, _id, _amount, _data);
      require(retval == ERC1155_RECEIVED_VALUE, "ERC1155PackedBalance#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts)
    internal
  {

    uint256 nTransfer = _ids.length; // Number of transfer to execute
    require(nTransfer == _amounts.length, "ERC1155PackedBalance#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH");

    if (_from != _to && nTransfer > 0) {
      (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);

      uint256 balFrom = _viewUpdateBinValue(balances[_from][bin], index, _amounts[0], Operations.Sub);
      uint256 balTo = _viewUpdateBinValue(balances[_to][bin], index, _amounts[0], Operations.Add);

      uint256 lastBin = bin;

      for (uint256 i = 1; i < nTransfer; i++) {
        (bin, index) = getIDBinIndex(_ids[i]);

        if (bin != lastBin) {
          balances[_from][lastBin] = balFrom;
          balances[_to][lastBin] = balTo;

          balFrom = balances[_from][bin];
          balTo = balances[_to][bin];

          lastBin = bin;
        }

        balFrom = _viewUpdateBinValue(balFrom, index, _amounts[i], Operations.Sub);
        balTo = _viewUpdateBinValue(balTo, index, _amounts[i], Operations.Add);
      }

      balances[_from][bin] = balFrom;
      balances[_to][bin] = balTo;

    } else {
      for (uint256 i = 0; i < nTransfer; i++) {
        require(balanceOf(_from, _ids[i]) >= _amounts[i], "ERC1155PackedBalance#_safeBatchTransferFrom: UNDERFLOW");
      }
    }

    emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
  }

  function _callonERC1155BatchReceived(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, uint256 _gasLimit, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived{gas: _gasLimit}(msg.sender, _from, _ids, _amounts, _data);
      require(retval == ERC1155_BATCH_RECEIVED_VALUE, "ERC1155PackedBalance#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE");
    }
  }



  function setApprovalForAll(address _operator, bool _approved)
    external override
  {

    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function isApprovedForAll(address _owner, address _operator)
    public override view returns (bool isOperator)
  {

    return operators[_owner][_operator];
  }



  function balanceOf(address _owner, uint256 _id)
    public override view returns (uint256)
  {

    uint256 bin;
    uint256 index;

    (bin, index) = getIDBinIndex(_id);
    return getValueInBin(balances[_owner][bin], index);
  }

  function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
    public override view returns (uint256[] memory)
  {

    uint256 n_owners = _owners.length;
    require(n_owners == _ids.length, "ERC1155PackedBalance#balanceOfBatch: INVALID_ARRAY_LENGTH");

    (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);
    uint256 balance_bin = balances[_owners[0]][bin];
    uint256 last_bin = bin;

    uint256[] memory batchBalances = new uint256[](n_owners);
    batchBalances[0] = getValueInBin(balance_bin, index);

    for (uint256 i = 1; i < n_owners; i++) {
      (bin, index) = getIDBinIndex(_ids[i]);

      if (bin != last_bin || _owners[i-1] != _owners[i]) {
        balance_bin = balances[_owners[i]][bin];
        last_bin = bin;
      }

      batchBalances[i] = getValueInBin(balance_bin, index);
    }

    return batchBalances;
  }



  function _updateIDBalance(address _address, uint256 _id, uint256 _amount, Operations _operation)
    internal
  {

    uint256 bin;
    uint256 index;

    (bin, index) = getIDBinIndex(_id);

    balances[_address][bin] = _viewUpdateBinValue(balances[_address][bin], index, _amount, _operation);
  }

  function _viewUpdateBinValue(uint256 _binValues, uint256 _index, uint256 _amount, Operations _operation)
    internal pure returns (uint256 newBinValues)
  {

    uint256 shift = IDS_BITS_SIZE * _index;
    uint256 mask = (uint256(1) << IDS_BITS_SIZE) - 1;

    if (_operation == Operations.Add) {
      newBinValues = _binValues + (_amount << shift);
      require(newBinValues >= _binValues, "ERC1155PackedBalance#_viewUpdateBinValue: OVERFLOW");
      require(
        ((_binValues >> shift) & mask) + _amount < 2**IDS_BITS_SIZE, // Checks that no other id changed
        "ERC1155PackedBalance#_viewUpdateBinValue: OVERFLOW"
      );

    } else if (_operation == Operations.Sub) {
      newBinValues = _binValues - (_amount << shift);
      require(newBinValues <= _binValues, "ERC1155PackedBalance#_viewUpdateBinValue: UNDERFLOW");
      require(
        ((_binValues >> shift) & mask) >= _amount, // Checks that no other id changed
        "ERC1155PackedBalance#_viewUpdateBinValue: UNDERFLOW"
      );

    } else {
      revert("ERC1155PackedBalance#_viewUpdateBinValue: INVALID_BIN_WRITE_OPERATION"); // Bad operation
    }

    return newBinValues;
  }

  function getIDBinIndex(uint256 _id)
    public pure returns (uint256 bin, uint256 index)
  {

    bin = _id / IDS_PER_UINT256;
    index = _id % IDS_PER_UINT256;
    return (bin, index);
  }

  function getValueInBin(uint256 _binValues, uint256 _index)
    public pure returns (uint256)
  {


    uint256 mask = (uint256(1) << IDS_BITS_SIZE) - 1;

    uint256 rightShift = IDS_BITS_SIZE * _index;
    return (_binValues >> rightShift) & mask;
  }



  function supportsInterface(bytes4 _interfaceID) public override virtual pure returns (bool) {

    if (_interfaceID == type(IERC1155).interfaceId) {
      return true;
    }
    return super.supportsInterface(_interfaceID);
  }
}// Apache-2.0
pragma solidity 0.8.3;



contract ERC1155MintBurnPackedBalance is ERC1155PackedBalance {



  function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data)
    internal
  {

    _updateIDBalance(_to,   _id, _amount, Operations.Add); // Add amount to recipient

    emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

    _callonERC1155Received(address(0x0), _to, _id, _amount, gasleft(), _data);
  }

  function _batchMint(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    internal
  {

    require(_ids.length == _amounts.length, "ERC1155MintBurnPackedBalance#_batchMint: INVALID_ARRAYS_LENGTH");

    if (_ids.length > 0) {
      (uint256 bin, uint256 index) = getIDBinIndex(_ids[0]);

      uint256 balTo = _viewUpdateBinValue(balances[_to][bin], index, _amounts[0], Operations.Add);

      uint256 nTransfer = _ids.length;

      uint256 lastBin = bin;

      for (uint256 i = 1; i < nTransfer; i++) {
        (bin, index) = getIDBinIndex(_ids[i]);

        if (bin != lastBin) {
          balances[_to][lastBin] = balTo;
          balTo = balances[_to][bin];

          lastBin = bin;
        }

        balTo = _viewUpdateBinValue(balTo, index, _amounts[i], Operations.Add);
      }

      balances[_to][bin] = balTo;
    }

    emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

    _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, gasleft(), _data);
  }



  function _burn(address _from, uint256 _id, uint256 _amount)
    internal
  {

    _updateIDBalance(_from, _id, _amount, Operations.Sub);

    emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
  }

  function _batchBurn(address _from, uint256[] memory _ids, uint256[] memory _amounts)
    internal
  {

    uint256 nBurn = _ids.length;
    require(nBurn == _amounts.length, "ERC1155MintBurnPackedBalance#batchBurn: INVALID_ARRAYS_LENGTH");

    for (uint256 i = 0; i < nBurn; i++) {
      _updateIDBalance(_from,   _ids[i], _amounts[i], Operations.Sub); // Add amount to recipient
    }

    emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
  }
}// Apache-2.0
pragma solidity 0.8.3;


interface IERC1155Metadata {


  event URI(string _uri, uint256 indexed _id);


  function uri(uint256 _id) external view returns (string memory);

}// Apache-2.0
pragma solidity 0.8.3;


contract NFT is ERC1155MintBurnPackedBalance, IERC1155Metadata {


    address public owner;
    string public baseURI;

    constructor(string memory _baseURI) {
        owner = msg.sender;
        baseURI = _baseURI;
    }

    modifier onlyOwner {

        require(msg.sender == owner, "not allowed");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {

        owner = _newOwner;
    }

    function changeBaseURI(string memory _newBaseURI) public onlyOwner {

        baseURI = _newBaseURI;
    }

    function mint(address _to, uint256 _id, uint256 _amount) public onlyOwner {

        _mint(_to, _id, _amount, "");
    }

    function batchMint(address _to, uint256[] memory _ids, uint256[] memory _amounts) public onlyOwner {

        _batchMint(_to, _ids, _amounts, "");
    }

    function burn(address _from, uint256 _id, uint256 _amount) public onlyOwner {

        _burn(_from, _id, _amount);
    }

    function batchBurn(address _from, uint256[] memory _ids, uint256[] memory _amounts) public onlyOwner {

        _batchBurn(_from, _ids, _amounts);
    }

    function supportsInterface(bytes4 _interfaceID) public override pure returns (bool) {

        if (_interfaceID == type(IERC1155).interfaceId || _interfaceID == type(IERC1155Metadata).interfaceId) {
            return true;
        }
        return super.supportsInterface(_interfaceID);
    }

    function uri(uint256 _id) external view override returns (string memory) {

        return string(abi.encodePacked(baseURI, uint2str(_id)));
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
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}