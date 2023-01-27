pragma solidity >=0.7.4 <0.9.0;


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

}// Apache-2.0
pragma solidity >=0.7.4 <0.9.0;


interface IERC165 {


    function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

}// Apache-2.0
pragma solidity >=0.7.4 <0.9.0;

interface IERC1155TokenReceiver {


  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4);


  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4);

}// MIT

pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// Apache-2.0
pragma solidity >=0.7.4 <0.9.0;



contract ERC1155 is IERC165, IERC1155 {

  using Address for address;



  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  mapping (address => mapping(uint256 => uint256)) internal balances;

  mapping (address => mapping(address => bool)) internal operators;



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
  public virtual override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155#safeTransferFrom: INVALID_RECIPIENT");

    _safeTransferFrom(_from, _to, _id, _amount);
    _callonERC1155Received(_from, _to, _id, _amount, _data);
  }

  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
  public virtual override
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR");
    require(_to != address(0), "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT");

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);
    _callonERC1155BatchReceived(_from, _to, _ids, _amounts, _data);
  }



  function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
  internal
  {

    balances[_from][_id] = balances[_from][_id] - _amount; // Subtract amount
    balances[_to][_id] = balances[_to][_id] + _amount;     // Add amount

    emit TransferSingle(msg.sender, _from, _to, _id, _amount);
  }

  function _callonERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
  internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _id, _amount, _data);
      require(retval == ERC1155_RECEIVED_VALUE, "ERC1155#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE");
    }
  }

  function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts)
  internal
  {

    require(_ids.length == _amounts.length, "ERC1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH");

    uint256 nTransfer = _ids.length;

    for (uint256 i = 0; i < nTransfer; i++) {
      balances[_from][_ids[i]] = balances[_from][_ids[i]] - _amounts[i];
      balances[_to][_ids[i]] = balances[_to][_ids[i]] + _amounts[i];
    }

    emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
  }

  function _callonERC1155BatchReceived(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
  internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _ids, _amounts, _data);
      require(retval == ERC1155_BATCH_RECEIVED_VALUE, "ERC1155#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE");
    }
  }



  function setApprovalForAll(address _operator, bool _approved)
  external virtual override
  {

    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function isApprovedForAll(address _owner, address _operator)
  public view virtual override returns (bool isOperator)
  {

    return operators[_owner][_operator];
  }



  function balanceOf(address _owner, uint256 _id)
  public view virtual override returns (uint256)
  {

    return balances[_owner][_id];
  }

  function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
  public view virtual override returns (uint256[] memory)
  {

    require(_owners.length == _ids.length, "ERC1155#balanceOfBatch: INVALID_ARRAY_LENGTH");

    uint256[] memory batchBalances = new uint256[](_owners.length);

    for (uint256 i = 0; i < _owners.length; i++) {
      batchBalances[i] = balances[_owners[i]][_ids[i]];
    }

    return batchBalances;
  }



  bytes4 constant private INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;

  bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

  function supportsInterface(bytes4 _interfaceID) public view virtual override returns (bool) {

    if (_interfaceID == INTERFACE_SIGNATURE_ERC165 ||
      _interfaceID == INTERFACE_SIGNATURE_ERC1155) {
      return true;
    }
    return false;
  }

}// Apache-2.0
pragma solidity >=0.7.4 <0.9.0;

contract ERC1155MintBurn is ERC1155 {




  function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data)
  internal
  {

    balances[_to][_id] = balances[_to][_id] + _amount;

    emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

    _callonERC1155Received(address(0x0), _to, _id, _amount, _data);
  }

  function _batchMint(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
  internal
  {

    require(_ids.length == _amounts.length, "ERC1155MintBurn#batchMint: INVALID_ARRAYS_LENGTH");

    uint256 nMint = _ids.length;

    for (uint256 i = 0; i < nMint; i++) {
      balances[_to][_ids[i]] = balances[_to][_ids[i]] + _amounts[i];
    }

    emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

    _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, _data);
  }



  function _burn(address _from, uint256 _id, uint256 _amount)
  internal
  {

    balances[_from][_id] = balances[_from][_id] - _amount;

    emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
  }

  function _batchBurn(address _from, uint256[] memory _ids, uint256[] memory _amounts)
  internal
  {

    require(_ids.length == _amounts.length, "ERC1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH");

    uint256 nBurn = _ids.length;

    for (uint256 i = 0; i < nBurn; i++) {
      balances[_from][_ids[i]] = balances[_from][_ids[i]] - _amounts[i];
    }

    emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
  }

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// Apache-2.0
pragma solidity >=0.5.11 <0.9.0;

library Strings {

  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {

      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      bytes memory _bc = bytes(_c);
      bytes memory _bd = bytes(_d);
      bytes memory _be = bytes(_e);
      string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
      for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
      for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
      for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
      for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
      return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {

        return strConcat(_a, _b, "", "", "");
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
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}// Apache-2.0
pragma solidity >=0.7.4 <0.9.0;


interface IERC1155Metadata {


  event URI(string _uri, uint256 indexed _id);


  function uri(uint256 _id) external view returns (string memory);

}// Apache-2.0
pragma solidity >=0.5.12 <0.9.0;


contract OwnableDelegateProxy { }


contract ProxyRegistry {

  mapping(address => OwnableDelegateProxy) public proxies;
}

contract ERC1155Tradable is ERC1155, ERC1155MintBurn, IERC1155Metadata, Ownable {

  event CreatorChanged(uint256 id, address newCreator, address oldCreator);
  using Strings for string;

  address[] _proxyRegistries;
  uint256 private _currentTokenID = 0;
  mapping (uint256 => address) public creators;
  mapping (uint256 => uint256) public tokenSupply;
  mapping (uint256 => string) public uris;

  string public name;
  string public symbol;

  modifier creatorOnly(uint256 _id) {

    require(creators[_id] == msg.sender, "ERC1155Tradable#creatorOnly: ONLY_CREATOR_ALLOWED");
    _;
  }

  modifier ownersOnly(uint256 _id) {

    require(balances[msg.sender][_id] > 0, "ERC1155Tradable#ownersOnly: ONLY_OWNERS_ALLOWED");
    _;
  }

  constructor(
    string memory _name,
    string memory _symbol,
    address[] memory proxyRegistries_
  ) {
    name = _name;
    symbol = _symbol;
    for(uint8 i = 0; i < proxyRegistries_.length; i++) {
      _proxyRegistries.push(proxyRegistries_[i]);
    }
  }

  function totalSupply(
    uint256 _id
  ) public view returns (uint256) {

    return tokenSupply[_id];
  }

  function uri(uint256 id_) public view override returns (string memory) {

    return uris[id_];
  }

  function addProxyRegistry(
    address _proxyRegistry
  ) external onlyOwner {

    require(_proxyRegistries.length < 256, "ERC1155Tradable#addProxyRegistry: MAX_NUMBER_OF_PROXIES_REACHED");
    _proxyRegistries.push(_proxyRegistry);
  }

  function removeProxyRegistry(
    address _proxyRegistry
  ) external onlyOwner {

    for(uint8 i=0; i< _proxyRegistries.length; i++) {
      if(_proxyRegistries[i] == _proxyRegistry) {
        delete _proxyRegistries[i];
        _proxyRegistries[i] = _proxyRegistries[_proxyRegistries.length - 1];
        delete _proxyRegistries[_proxyRegistries.length - 1];
      }
    }
  }

  function swapProxyRegistry(
    address _proxyRegistry,
    uint8 _index
  ) external onlyOwner {

    _proxyRegistries[_index] = _proxyRegistry;
  }

  function proxyRegistries() public view returns(address[] memory) {

    return _proxyRegistries;
  }

  function create(
    address _initialOwner,
    uint256 _initialSupply,
    string calldata _uri,
    bytes calldata _data
  ) external returns (uint256) {


    uint256 _id = _getNextTokenID();
    _incrementTokenTypeId();

    uris[_id] = _uri;
    creators[_id] = msg.sender;

    _mint(_initialOwner, _id, _initialSupply, _data);

    tokenSupply[_id] = _initialSupply;

    return _id;
  }

  function mint(
    address _to,
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
  ) public creatorOnly(_id) {

    _mint(_to, _id, _quantity, _data);
    tokenSupply[_id] = tokenSupply[_id] + _quantity;
  }

  function batchMint(
    address _to,
    uint256[] memory _ids,
    uint256[] memory _quantities,
    bytes memory _data
  ) public {

    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 _id = _ids[i];
      require(creators[_id] == msg.sender, "ERC1155Tradable#batchMint: ONLY_CREATOR_ALLOWED");
      uint256 quantity = _quantities[i];
      tokenSupply[_id] = tokenSupply[_id] + quantity;
    }
    _batchMint(_to, _ids, _quantities, _data);
  }

  function setCreator(
    address _to,
    uint256[] memory _ids
  ) public {

    require(_to != address(0), "ERC1155Tradable#setCreator: INVALID_ADDRESS.");
    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];
      _setCreator(_to, id);
    }
  }

  function isApprovedForAll(
    address _owner,
    address _operator
  ) public view virtual override returns (bool isOperator) {

    for(uint8 i=0; i< _proxyRegistries.length; i++) {
      ProxyRegistry proxyRegistry = ProxyRegistry(_proxyRegistries[i]);
      if (address(proxyRegistry.proxies(_owner)) == _operator) {
        return true;
      }
    }

    return super.isApprovedForAll(_owner, _operator);
  }

  function creator(uint256 id_) public view returns(address){

    return creators[id_];
  }

  function _setCreator(address _to, uint256 _id) internal creatorOnly(_id)
  {

    emit CreatorChanged(_id, _to, creators[_id]);
    creators[_id] = _to;
  }

  function _exists(
    uint256 _id
  ) internal view returns (bool) {

    return creators[_id] != address(0);
  }

  function _getNextTokenID() private view returns (uint256) {

    return _currentTokenID + 1;
  }

  function _incrementTokenTypeId() private  {

    _currentTokenID++;
  }
}// MIT
pragma solidity >=0.5.11 <0.9.0;


contract JevelsERC1155 is ERC1155Tradable {

  string private _contractURI = "https://jevels.com/contract-uri";

  constructor(address[] memory _proxyRegistries)
  ERC1155Tradable(
    "Jevels",
    "JVL",
      _proxyRegistries
  ) {}

  function contractURI() public view returns (string memory) {

    return _contractURI;
  }

  function setContractURI(string calldata contractURI_) public returns (bool) {

    _contractURI = contractURI_;
    return true;
  }
}