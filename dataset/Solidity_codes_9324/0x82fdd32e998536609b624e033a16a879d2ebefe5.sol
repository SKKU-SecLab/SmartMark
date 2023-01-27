

pragma solidity ^0.5.12;


interface IERC165 {


    function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

}


pragma solidity ^0.5.12;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath#mul: OVERFLOW");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath#sub: UNDERFLOW");
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath#add: OVERFLOW");

    return c; 
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
    return a % b;
  }

}


pragma solidity ^0.5.12;

interface IERC1155TokenReceiver {


  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4);


  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4);


  function supportsInterface(bytes4 interfaceID) external view returns (bool);


}


pragma solidity ^0.5.12;


interface IERC1155 {


  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  event URI(string _amount, uint256 indexed _id);

  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;


  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;

  
  function balanceOf(address _owner, uint256 _id) external view returns (uint256);


  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);


}



pragma solidity ^0.5.12;


library Address {


  function isContract(address account) internal view returns (bool) {

    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    assembly { codehash := extcodehash(account) }
    return (codehash != 0x0 && codehash != accountHash);
  }

}


pragma solidity ^0.5.12;







contract ERC1155 is IERC165 {

  using SafeMath for uint256;
  using Address for address;



  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  mapping (address => mapping(uint256 => uint256)) internal balances;

  mapping (address => mapping(address => bool)) internal operators;

  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);
  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
  event URI(string _uri, uint256 indexed _id);



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
    public
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155#safeTransferFrom: INVALID_RECIPIENT");

    _safeTransferFrom(_from, _to, _id, _amount);
    _callonERC1155Received(_from, _to, _id, _amount, _data);
  }

  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    public
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR");
    require(_to != address(0), "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT");

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);
    _callonERC1155BatchReceived(_from, _to, _ids, _amounts, _data);
  }



  function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
    internal
  {

    balances[_from][_id] = balances[_from][_id].sub(_amount); // Subtract amount
    balances[_to][_id] = balances[_to][_id].add(_amount);     // Add amount

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
      balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
      balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
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
    external
  {

    operators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool isOperator)
  {

    return operators[_owner][_operator];
  }



  function balanceOf(address _owner, uint256 _id)
    public view returns (uint256)
  {

    return balances[_owner][_id];
  }

  function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
    public view returns (uint256[] memory)
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

  function supportsInterface(bytes4 _interfaceID) external view returns (bool) {

    if (_interfaceID == INTERFACE_SIGNATURE_ERC165 ||
        _interfaceID == INTERFACE_SIGNATURE_ERC1155) {
      return true;
    }
    return false;
  }

}


pragma solidity ^0.5.11;



contract ERC1155Metadata {


  string internal baseMetadataURI;
  event URI(string _uri, uint256 indexed _id);



  function uri(uint256 _id) public view returns (string memory) {

    return string(abi.encodePacked(baseMetadataURI, _uint2str(_id), ".json"));
  }



  function _logURIs(uint256[] memory _tokenIDs) internal {

    string memory baseURL = baseMetadataURI;
    string memory tokenURI;

    for (uint256 i = 0; i < _tokenIDs.length; i++) {
      tokenURI = string(abi.encodePacked(baseURL, _uint2str(_tokenIDs[i]), ".json"));
      emit URI(tokenURI, _tokenIDs[i]);
    }
  }

  function _logURIs(uint256[] memory _tokenIDs, string[] memory _URIs) internal {

    require(_tokenIDs.length == _URIs.length, "ERC1155Metadata#_logURIs: INVALID_ARRAYS_LENGTH");
    for (uint256 i = 0; i < _tokenIDs.length; i++) {
      emit URI(_URIs[i], _tokenIDs[i]);
    }
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
    uint256 k = len - 1;

    while (ii != 0) {
      bstr[k--] = byte(uint8(48 + ii % 10));
      ii /= 10;
    }

    return string(bstr);
  }

}


pragma solidity ^0.5.12;



contract ERC1155MintBurn is ERC1155 {




  function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data)
    internal
  {

    balances[_to][_id] = balances[_to][_id].add(_amount);

    emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

    _callonERC1155Received(address(0x0), _to, _id, _amount, _data);
  }

  function _batchMint(address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    internal
  {

    require(_ids.length == _amounts.length, "ERC1155MintBurn#batchMint: INVALID_ARRAYS_LENGTH");

    uint256 nMint = _ids.length;

    for (uint256 i = 0; i < nMint; i++) {
      balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
    }

    emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

    _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, _data);
  }



  function _burn(address _from, uint256 _id, uint256 _amount)
    internal
  {

    balances[_from][_id] = balances[_from][_id].sub(_amount);

    emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
  }

  function _batchBurn(address _from, uint256[] memory _ids, uint256[] memory _amounts)
    internal
  {

    require(_ids.length == _amounts.length, "ERC1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH");

    uint256 nBurn = _ids.length;

    for (uint256 i = 0; i < nBurn; i++) {
      balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
    }

    emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
  }

}



pragma solidity ^0.5.12;

library Strings {

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d,
        string memory _e
    ) internal pure returns (string memory) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(
            _ba.length + _bb.length + _bc.length + _bd.length + _be.length
        );
        bytes memory babcde = bytes(abcde);
        uint256 k = 0;
        for (uint256 i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint256 i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint256 i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint256 i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint256 i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d
    ) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c
    ) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {

        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.12;

contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address => bool) internal operators;
    address[] internal operatorsGroup;
    uint256 internal constant MAX_GROUP_SIZE = 50;

    constructor(address _admin) public {
        require(_admin != address(0), "Admin 0");
        admin = _admin;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyOperator() {

        require(operators[msg.sender], "Only operator");
        _;
    }

    function getOperators() external view returns (address[] memory) {

        return operatorsGroup;
    }

    event TransferAdminPending(address pendingAdmin);

    function transferAdmin(address newAdmin) public onlyAdmin {

        require(newAdmin != address(0), "New admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    function transferAdminQuickly(address newAdmin) public onlyAdmin {

        require(newAdmin != address(0), "Admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed(address newAdmin, address previousAdmin);

    function claimAdmin() public {

        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {

        require(!operators[newOperator], "Operator exists"); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE, "Max operators");

        emit OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator(address operator) public onlyAdmin {

        require(operators[operator], "Not operator");
        operators[operator] = false;

        for (uint256 i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.pop();
                emit OperatorAdded(operator, false);
                break;
            }
        }
    }
}



pragma solidity ^0.5.12;



contract Withdrawable is PermissionGroups {

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    mapping(address => bool) internal blacklist;

    event TokenWithdraw(address token, uint256 amount, address sendTo);

    event EtherWithdraw(uint256 amount, address sendTo);

    constructor(address _admin) public PermissionGroups(_admin) {}

    function withdrawToken(
        address token,
        uint256 amount,
        address sendTo
    ) external onlyAdmin {

        require(!blacklist[address(token)], "forbid to withdraw that token");
        _safeTransfer(token, sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }

    function withdrawEther(uint256 amount, address payable sendTo) external onlyAdmin {

        (bool success, ) = sendTo.call.value(amount)("");
        require(success);
        emit EtherWithdraw(amount, sendTo);
    }

    function setBlackList(address token) internal {

        blacklist[token] = true;
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {

        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }
}



pragma solidity ^0.5.12;






contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

contract Goddess is ERC1155, ERC1155MintBurn, ERC1155Metadata, Withdrawable {

    using Strings for string;

    address proxyRegistryAddress;
    uint256 private _currentTokenID = 0;
    mapping(uint256 => uint256) private tokenSupply;
    mapping(uint256 => uint256) private tokenMaxSupply;
    mapping(uint256 => uint256) public nextLevel;
    string public name;
    string public symbol;

    modifier ownersOnly(uint256 _id) {

        require(balances[msg.sender][_id] > 0, "ERC1155Tradable#ownersOnly: ONLY_OWNERS_ALLOWED");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) public Withdrawable(msg.sender) {
        name = _name;
        symbol = _symbol;
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function uri(uint256 _id) public view returns (string memory) {

        require(_exists(_id), "ERC721Tradable#uri: NONEXISTENT_TOKEN");
        return Strings.strConcat(baseMetadataURI, Strings.uint2str(_id));
    }

    function totalSupply(uint256 _id) public view returns (uint256) {

        return tokenSupply[_id];
    }

    function setBaseMetadataURI(string memory _newBaseMetadataURI) public onlyAdmin {

        _setBaseMetadataURI(_newBaseMetadataURI);
    }

    function setProxyRegistryAddress(address _proxyRegistryAddress) external onlyAdmin {

        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function create(uint256 _maxSupply) external onlyOperator returns (uint256) {

        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        tokenMaxSupply[_id] = _maxSupply;
        return _id;
    }

    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public onlyOperator {

        require(tokenSupply[_id] < tokenMaxSupply[_id], "Max supply reached");
        _mint(_to, _id, _quantity, _data);
        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    }

    function batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _quantities,
        bytes memory _data
    ) public onlyOperator {

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 _id = _ids[i];
            uint256 quantity = _quantities[i];
            tokenSupply[_id] = tokenSupply[_id].add(quantity);
        }
        _batchMint(_to, _ids, _quantities, _data);
    }

    function burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) public onlyOperator {

        _burn(_from, _id, _amount);
        tokenMaxSupply[_id] = tokenMaxSupply[_id].sub(_amount);
        tokenSupply[_id] = tokenSupply[_id].sub(_amount);
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool isOperator)
    {

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        return ERC1155.isApprovedForAll(_owner, _operator);
    }

    function _exists(uint256 _id) internal view returns (bool) {

        return _id <= _currentTokenID;
    }

    function _getNextTokenID() private view returns (uint256) {

        return _currentTokenID.add(1);
    }

    function _incrementTokenTypeId() private {

        _currentTokenID++;
    }

    function maxSupply(uint256 _id) public view returns (uint256) {

        return tokenMaxSupply[_id];
    }
}