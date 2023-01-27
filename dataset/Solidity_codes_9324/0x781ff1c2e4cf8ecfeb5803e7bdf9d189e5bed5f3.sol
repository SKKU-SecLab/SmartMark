

pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.16;


interface IERC165 {


    function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

}


pragma solidity ^0.5.16;


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


pragma solidity ^0.5.16;

interface IERC1155TokenReceiver {


  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4);


  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4);


  function supportsInterface(bytes4 interfaceID) external view returns (bool);

}


pragma solidity ^0.5.16;


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


pragma solidity ^0.5.16;


library Address {


  bytes32 constant internal ACCOUNT_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

  function isContract(address _address) internal view returns (bool) {

    bytes32 codehash;

    assembly { codehash := extcodehash(_address) }
    return (codehash != 0x0 && codehash != ACCOUNT_HASH);
  }
}


pragma solidity ^0.5.16;







contract ERC1155 is IERC165, IERC1155 {

  using SafeMath for uint256;
  using Address for address;


  bytes4 constant internal ERC1155_RECEIVED_VALUE = 0xf23a6e61;
  bytes4 constant internal ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

  mapping (address => mapping(uint256 => uint256)) internal balances;

  mapping (address => mapping(address => bool)) internal operators;



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
    public
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeTransferFrom: INVALID_OPERATOR");
    require(_to != address(0),"ERC1155#safeTransferFrom: INVALID_RECIPIENT");

    _safeTransferFrom(_from, _to, _id, _amount);
    _callonERC1155Received(_from, _to, _id, _amount, gasleft(), _data);
  }

  function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    public
  {

    require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR");
    require(_to != address(0), "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT");

    _safeBatchTransferFrom(_from, _to, _ids, _amounts);
    _callonERC1155BatchReceived(_from, _to, _ids, _amounts, gasleft(), _data);
  }



  function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount)
    internal
  {

    balances[_from][_id] = balances[_from][_id].sub(_amount); // Subtract amount
    balances[_to][_id] = balances[_to][_id].add(_amount);     // Add amount

    emit TransferSingle(msg.sender, _from, _to, _id, _amount);
  }

  function _callonERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, uint256 _gasLimit, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received.gas(_gasLimit)(msg.sender, _from, _id, _amount, _data);
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

  function _callonERC1155BatchReceived(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, uint256 _gasLimit, bytes memory _data)
    internal
  {

    if (_to.isContract()) {
      bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived.gas(_gasLimit)(msg.sender, _from, _ids, _amounts, _data);
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


pragma solidity ^0.5.16;



contract ERC1155MintBurn is ERC1155 {



  function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data)
    internal
  {

    balances[_to][_id] = balances[_to][_id].add(_amount);

    emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

    _callonERC1155Received(address(0x0), _to, _id, _amount, gasleft(), _data);
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

    _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, gasleft(), _data);
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

    uint256 nBurn = _ids.length;
    require(nBurn == _amounts.length, "ERC1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH");

    for (uint256 i = 0; i < nBurn; i++) {
      balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
    }

    emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
  }
}


pragma solidity ^0.5.2;



contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

contract ERC1155Tradable is ERC1155MintBurn, Ownable {

    address public proxyRegistryAddress;
    string public name;
    string public symbol;

    mapping(uint256 => uint256) private _supply;

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) public {
        name = _name;
        symbol = _symbol;
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    modifier onlyOwner() {

        require(
            _isOwner(_msgSender()),
            "ERC1155Tradable#onlyOwner: CALLER_IS_NOT_OWNER"
        );
        _;
    }

    function totalSupply(uint256 _id) public view returns (uint256) {

        return _supply[_id];
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool isOperator)
    {

        if (_isProxyForUser(_owner, _operator)) {
            return true;
        }

        return super.isApprovedForAll(_owner, _operator);
    }

    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public onlyOwner {

        _mint(_to, _id, _quantity, _data);
    }

    function batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _quantities,
        bytes memory _data
    ) public onlyOwner {

        _batchMint(_to, _ids, _quantities, _data);
    }

    function burn(
        address _from,
        uint256 _id,
        uint256 _quantity
    ) public {

        _supply[_id] = _supply[_id].sub(_quantity);
        _burn(_from, _id, _quantity);
    }

    function batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _quantities
    ) public {

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            _supply[id] = _supply[id].sub(_quantities[i]);
        }
        _batchBurn(_from, _ids, _quantities);
    }

    function exists(uint256 _id) public view returns (bool) {

        return _supply[_id] > 0;
    }

    function _isOwner(address _address) internal view returns (bool) {

        return owner() == _address || _isProxyForUser(owner(), _address);
    }

    function _mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal {

        balances[_to][_id] = balances[_to][_id].add(_amount);
        _supply[_id] = _supply[_id].add(_amount);

        address origin = _origin(_id);

        emit TransferSingle(msg.sender, origin, _to, _id, _amount);

        _callonERC1155Received(origin, _to, _id, _amount, gasleft(), _data);
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal {

        require(
            _ids.length == _amounts.length,
            "ERC1155Tradable#batchMint: INVALID_ARRAYS_LENGTH"
        );

        uint256 nMint = _ids.length;

        address origin = _origin(_ids[0]);

        for (uint256 i = 0; i < nMint; i++) {
            uint256 id = _ids[i];
            require(
                _origin(id) == origin,
                "ERC1155Tradable#batchMint: MULTIPLE_ORIGINS_NOT_ALLOWED"
            );
            balances[_to][id] = balances[_to][id].add(_amounts[i]);
            _supply[id] = _supply[id].add(_amounts[i]);
        }

        emit TransferBatch(msg.sender, origin, _to, _ids, _amounts);

        _callonERC1155BatchReceived(
            origin,
            _to,
            _ids,
            _amounts,
            gasleft(),
            _data
        );
    }

    function _origin(
        uint256 /* _id */
    ) internal view returns (address) {

        return address(0);
    }


    function _isProxyForUser(address _user, address _address)
        internal
        view
        returns (bool)
    {

        return _proxy(_user) == _address;
    }

    function _proxy(address _address) internal view returns (address) {

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        return address(proxyRegistry.proxies(_address));
    }
}


pragma solidity ^0.5.2;


contract AssetContract is ERC1155Tradable {

    event URI(string _value, uint256 indexed _id);
    event PermanentURI(string _value, uint256 indexed _id);

    uint256 constant TOKEN_SUPPLY_CAP = 1;

    string public templateURI;

    mapping(uint256 => string) private _tokenURI;

    mapping(uint256 => bool) private _isPermanentURI;

    modifier onlyTokenAmountOwned(address _from, uint256 _id, uint256 _quantity) {

        require(
            _ownsTokenAmount(_from, _id, _quantity),
            "AssetContract#onlyTokenAmountOwned: ONLY_TOKEN_AMOUNT_OWNED_ALLOWED"
        );
        _;
    }

    modifier onlyImpermanentURI(uint256 id) {

        require(!_isPermanentURI[id], "AssetContract#onlyImpermanentURI: URI_CANNOT_BE_CHANGED");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress,
        string memory _templateURI
    ) public ERC1155Tradable(_name, _symbol, _proxyRegistryAddress) {
        if (bytes(_templateURI).length > 0) {
            setTemplateURI(_templateURI);
        }
    }

    function openSeaVersion() public pure returns (string memory) {

        return "2.0.3";
    }

    function _ownsTokenAmount(address _from, uint256 _id, uint256 _quantity) internal view returns (bool) {

        return balanceOf(_from, _id) >= _quantity;
    }

    function supportsFactoryInterface() public pure returns (bool) {

        return true;
    }

    function setTemplateURI(string memory uri) public onlyOwner {

        templateURI = uri;
    }

    function setURI(uint256 _id, string memory _uri) public onlyOwner onlyImpermanentURI(_id) {

        _setURI(_id, _uri);
    }

    function setPermanentURI(uint256 _id, string memory _uri) public onlyOwner onlyImpermanentURI(_id) {

        _setPermanentURI(_id, _uri);
    }

    function uri(uint256 _id) public view returns (string memory) {

        string memory tokenUri = _tokenURI[_id];
        if (bytes(tokenUri).length != 0) {
            return tokenUri;
        }
        return templateURI;
    }

    function balanceOf(address _owner, uint256 _id)
        public
        view
        returns (uint256)
    {

        uint256 balance = super.balanceOf(_owner, _id);
        return
            _isCreatorOrProxy(_id, _owner)
                ? balance.add(_remainingSupply(_id))
                : balance;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public {

        uint256 mintedBalance = super.balanceOf(_from, _id);
        if (mintedBalance < _amount) {
            mint(_to, _id, _amount.sub(mintedBalance), _data);
            if (mintedBalance > 0) {
                super.safeTransferFrom(_from, _to, _id, mintedBalance, _data);
            }
        } else {
            super.safeTransferFrom(_from, _to, _id, _amount, _data);
        }
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) public {

        require(
            _ids.length == _amounts.length,
            "AssetContractShared#safeBatchTransferFrom: INVALID_ARRAYS_LENGTH"
        );
        for (uint256 i = 0; i < _ids.length; i++) {
            safeTransferFrom(_from, _to, _ids[i], _amounts[i], _data);
        }
    }

    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public onlyOwner {

        require(
            _quantity <= _remainingSupply(_id),
            "AssetContract#mint: QUANTITY_EXCEEDS_TOKEN_SUPPLY_CAP"
        );
        _mint(_to, _id, _quantity, _data);
    }

    function batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _quantities,
        bytes memory _data
    ) public onlyOwner {

        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                _quantities[i] <= _remainingSupply(_ids[i]),
                "AssetContract#batchMint: QUANTITY_EXCEEDS_TOKEN_SUPPLY_CAP"
            );
        }
        _batchMint(_to, _ids, _quantities, _data);
    }


    function burn(
        address _from,
        uint256 _id,
        uint256 _quantity
    ) public onlyTokenAmountOwned(_from, _id, _quantity) {

        super.burn(_from, _id, _quantity);
    }

    function batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _quantities
    ) public {

        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                _ownsTokenAmount(_from, _ids[i], _quantities[i]),
                "AssetContract#batchBurn: ONLY_TOKEN_AMOUNT_OWNED_ALLOWED"
            );
        }
        super.batchBurn(_from, _ids, _quantities);
    }

    function _mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) internal {

        super._mint(_to, _id, _quantity, _data);
        if (_data.length > 1) {
            _setURI(_id, string(_data));
        }
    }

    function _isCreatorOrProxy(uint256, address _address)
        internal
        view
        returns (bool)
    {

        return _isOwner(_address);
    }

    function _remainingSupply(uint256 _id) internal view returns (uint256) {

        return TOKEN_SUPPLY_CAP.sub(totalSupply(_id));
    }

    function _origin(
        uint256 /* _id */
    ) internal view returns (address) {

        return owner();
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _quantities,
        bytes memory _data
    ) internal {

        super._batchMint(_to, _ids, _quantities, _data);
        if (_data.length > 1) {
            for (uint256 i = 0; i < _ids.length; i++) {
                _setURI(_ids[i], string(_data));
            }
        }
    }

    function _setURI(uint256 _id, string memory _uri) internal {

        _tokenURI[_id] = _uri;
        emit URI(_uri, _id);
    }

    function _setPermanentURI(uint256 _id, string memory _uri) internal {

        _isPermanentURI[_id] = true;
        _setURI(_id, _uri);
        emit PermanentURI(_uri, _id);
    }
}


pragma solidity ^0.5.2;


library TokenIdentifiers {

    using SafeMath for uint256;

    uint8 constant ADDRESS_BITS = 160;
    uint8 constant INDEX_BITS = 56;
    uint8 constant SUPPLY_BITS = 40;

    uint256 constant SUPPLY_MASK = (uint256(1) << SUPPLY_BITS) - 1;
    uint256 constant INDEX_MASK = ((uint256(1) << INDEX_BITS) - 1) ^
        SUPPLY_MASK;

    function tokenMaxSupply(uint256 _id) internal pure returns (uint256) {

        return _id & SUPPLY_MASK;
    }

    function tokenIndex(uint256 _id) internal pure returns (uint256) {

        return _id & INDEX_MASK;
    }

    function tokenCreator(uint256 _id) internal pure returns (address) {

        return address(_id >> (INDEX_BITS + SUPPLY_BITS));
    }
}


pragma solidity ^0.5.2;




contract NiftyPlanet is AssetContract, ReentrancyGuard {

    mapping(address => bool) public sharedProxyAddresses;
    using SafeMath for uint256;
    using TokenIdentifiers for uint256;

    event CreatorChanged(uint256 indexed _id, address indexed _creator);

    mapping(uint256 => address) internal _creatorOverride;

    modifier creatorOnly(uint256 _id) {

        require(
            _isCreatorOrProxy(_id, _msgSender()),
            "AssetContractShared#creatorOnly: ONLY_CREATOR_ALLOWED"
        );
        _;
    }

    modifier onlyFullTokenOwner(uint256 _id) {

        require(
            _ownsTokenAmount(_msgSender(), _id, _id.tokenMaxSupply()),
            "AssetContractShared#onlyFullTokenOwner: ONLY_FULL_TOKEN_OWNER_ALLOWED"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress,
        string memory _templateURI
    )
        public
        AssetContract(_name, _symbol, _proxyRegistryAddress, _templateURI)
    {}

    function setProxyRegistryAddress(address _address) public onlyOwner {

        proxyRegistryAddress = _address;
    }

    function addSharedProxyAddress(address _address) public onlyOwner {

        sharedProxyAddresses[_address] = true;
    }

    function removeSharedProxyAddress(address _address) public onlyOwner {

        delete sharedProxyAddresses[_address];
    }

    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public nonReentrant() {

        _requireMintable(_msgSender(), _id, _quantity);
        _mint(_to, _id, _quantity, _data);
    }

    function batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _quantities,
        bytes memory _data
    ) public nonReentrant() {

        for (uint256 i = 0; i < _ids.length; i++) {
            _requireMintable(_msgSender(), _ids[i], _quantities[i]);
        }
        _batchMint(_to, _ids, _quantities, _data);
    }


    function setURI(uint256 _id, string memory _uri) public creatorOnly(_id) onlyImpermanentURI(_id) onlyFullTokenOwner(_id) {

        _setURI(_id, _uri);
    }

    function setPermanentURI(uint256 _id, string memory _uri)
        public
        creatorOnly(_id)
        onlyImpermanentURI(_id)
        onlyFullTokenOwner(_id) {

        _setPermanentURI(_id, _uri);
    }

    function setCreator(uint256 _id, address _to) public creatorOnly(_id) {

        require(
            _to != address(0),
            "AssetContractShared#setCreator: INVALID_ADDRESS."
        );
        _creatorOverride[_id] = _to;
        emit CreatorChanged(_id, _to);
    }

    function creator(uint256 _id) public view returns (address) {

        if (_creatorOverride[_id] != address(0)) {
            return _creatorOverride[_id];
        } else {
            return _id.tokenCreator();
        }
    }

    function maxSupply(uint256 _id) public pure returns (uint256) {

        return _id.tokenMaxSupply();
    }

    function _origin(uint256 _id) internal view returns (address) {

        return _id.tokenCreator();
    }

    function _requireMintable(
        address _address,
        uint256 _id,
        uint256 _amount
    ) internal view {

        require(
            _isCreatorOrProxy(_id, _address),
            "AssetContractShared#_requireMintable: ONLY_CREATOR_ALLOWED"
        );
        require(
            _remainingSupply(_id) >= _amount,
            "AssetContractShared#_requireMintable: SUPPLY_EXCEEDED"
        );
    }

    function _remainingSupply(uint256 _id) internal view returns (uint256) {

        return maxSupply(_id).sub(totalSupply(_id));
    }

    function _isCreatorOrProxy(uint256 _id, address _address)
        internal
        view
        returns (bool)
    {

        address creator_ = creator(_id);
        return creator_ == _address || _isProxyForUser(creator_, _address);
    }

    function _isProxyForUser(address _user, address _address)
        internal
        view
        returns (bool)
    {

        if (sharedProxyAddresses[_address]) {
            return true;
        }
        return super._isProxyForUser(_user, _address);
    }
}