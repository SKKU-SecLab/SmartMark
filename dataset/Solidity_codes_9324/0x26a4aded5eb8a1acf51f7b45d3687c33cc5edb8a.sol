
pragma solidity ^0.5.0;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

contract TFTTokenWrapper {

    using SafeMath for uint256;
    IERC20 public tft;

    constructor(IERC20 _tftAddress) public {
        tft = IERC20(_tftAddress);
    }

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function stake(uint256 amount) public {

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        tft.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        tft.transfer(msg.sender, amount);
    }
}

interface IERC165 {

    function supportsInterface(bytes4 _interfaceId)
        external
        view
        returns (bool);

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


    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

contract ERC1155 is IERC165 {

    using SafeMath for uint256;
    using Address for address;


    bytes4 internal constant ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 internal constant ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    mapping(address => mapping(uint256 => uint256)) internal balances;

    mapping(address => mapping(address => bool)) internal operators;

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
    event URI(string _uri, uint256 indexed _id);


    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public {

        require(
            (msg.sender == _from) || isApprovedForAll(_from, msg.sender),
            "ERC1155#safeTransferFrom: INVALID_OPERATOR"
        );
        require(
            _to != address(0),
            "ERC1155#safeTransferFrom: INVALID_RECIPIENT"
        );

        _safeTransferFrom(_from, _to, _id, _amount);
        _callonERC1155Received(_from, _to, _id, _amount, _data);
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) public {

        require(
            (msg.sender == _from) || isApprovedForAll(_from, msg.sender),
            "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR"
        );
        require(
            _to != address(0),
            "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT"
        );

        _safeBatchTransferFrom(_from, _to, _ids, _amounts);
        _callonERC1155BatchReceived(_from, _to, _ids, _amounts, _data);
    }


    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal {

        balances[_from][_id] = balances[_from][_id].sub(_amount); // Subtract amount
        balances[_to][_id] = balances[_to][_id].add(_amount); // Add amount

        emit TransferSingle(msg.sender, _from, _to, _id, _amount);
    }

    function _callonERC1155Received(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal {

        if (_to.isContract()) {
            bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received(
                msg.sender,
                _from,
                _id,
                _amount,
                _data
            );
            require(
                retval == ERC1155_RECEIVED_VALUE,
                "ERC1155#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE"
            );
        }
    }

    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) internal {

        require(
            _ids.length == _amounts.length,
            "ERC1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH"
        );

        uint256 nTransfer = _ids.length;

        for (uint256 i = 0; i < nTransfer; i++) {
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(
                _amounts[i]
            );
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
    }

    function _callonERC1155BatchReceived(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal {

        if (_to.isContract()) {
            bytes4 retval = IERC1155TokenReceiver(_to).onERC1155BatchReceived(
                msg.sender,
                _from,
                _ids,
                _amounts,
                _data
            );
            require(
                retval == ERC1155_BATCH_RECEIVED_VALUE,
                "ERC1155#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE"
            );
        }
    }


    function setApprovalForAll(address _operator, bool _approved) external {

        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool isOperator)
    {

        return operators[_owner][_operator];
    }


    function balanceOf(address _owner, uint256 _id)
        public
        view
        returns (uint256)
    {

        return balances[_owner][_id];
    }

    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
        public
        view
        returns (uint256[] memory)
    {

        require(
            _owners.length == _ids.length,
            "ERC1155#balanceOfBatch: INVALID_ARRAY_LENGTH"
        );

        uint256[] memory batchBalances = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; i++) {
            batchBalances[i] = balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }


    bytes4 private constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;

    bytes4 private constant INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

    function supportsInterface(bytes4 _interfaceID)
        external
        view
        returns (bool)
    {

        if (
            _interfaceID == INTERFACE_SIGNATURE_ERC165 ||
            _interfaceID == INTERFACE_SIGNATURE_ERC1155
        ) {
            return true;
        }
        return false;
    }
}

contract ERC1155MintBurn is ERC1155 {


    function _mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal {

        balances[_to][_id] = balances[_to][_id].add(_amount);

        emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

        _callonERC1155Received(address(0x0), _to, _id, _amount, _data);
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal {

        require(
            _ids.length == _amounts.length,
            "ERC1155MintBurn#batchMint: INVALID_ARRAYS_LENGTH"
        );

        uint256 nMint = _ids.length;

        for (uint256 i = 0; i < nMint; i++) {
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
        }

        emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

        _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, _data);
    }


    function _burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) internal {

        balances[_from][_id] = balances[_from][_id].sub(_amount);

        emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
    }

    function _batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) internal {

        require(
            _ids.length == _amounts.length,
            "ERC1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH"
        );

        uint256 nBurn = _ids.length;

        for (uint256 i = 0; i < nBurn; i++) {
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(
                _amounts[i]
            );
        }

        emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
    }
}

contract ERC1155Metadata {

    string internal baseMetadataURI;
    event URI(string _uri, uint256 indexed _id);


    function uri(uint256 _id) public view returns (string memory) {

        return
            string(abi.encodePacked(baseMetadataURI, _uint2str(_id), ".json"));
    }


    function _logURIs(uint256[] memory _tokenIDs) internal {

        string memory baseURL = baseMetadataURI;
        string memory tokenURI;

        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            tokenURI = string(
                abi.encodePacked(baseURL, _uint2str(_tokenIDs[i]), ".json")
            );
            emit URI(tokenURI, _tokenIDs[i]);
        }
    }

    function _logURIs(uint256[] memory _tokenIDs, string[] memory _URIs)
        internal
    {

        require(
            _tokenIDs.length == _URIs.length,
            "ERC1155Metadata#_logURIs: INVALID_ARRAYS_LENGTH"
        );
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            emit URI(_URIs[i], _tokenIDs[i]);
        }
    }

    function _setBaseMetadataURI(string memory _newBaseMetadataURI) internal {

        baseMetadataURI = _newBaseMetadataURI;
    }


    function _uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

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
            bstr[k--] = bytes1(uint8(48 + (ii % 10)));
            ii /= 10;
        }

        return string(bstr);
    }
}

contract Context {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

    function strConcat(string memory _a, string memory _b)
        internal
        pure
        returns (string memory)
    {

        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

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

library Roles {

    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor() internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {

        require(
            isMinter(_msgSender()),
            "MinterRole: caller does not have the Minter role"
        );
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract WhitelistAdminRole is Context {

    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor() internal {
        _addWhitelistAdmin(_msgSender());
    }

    modifier onlyWhitelistAdmin() {

        require(
            isWhitelistAdmin(_msgSender()),
            "WhitelistAdminRole: caller does not have the WhitelistAdmin role"
        );
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

contract ERC1155Tradable is
    ERC1155,
    ERC1155MintBurn,
    ERC1155Metadata,
    Ownable,
    MinterRole,
    WhitelistAdminRole
{

    using Strings for string;

    address proxyRegistryAddress;
    uint256 private _currentTokenID = 0;
    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => uint256) public tokenMaxSupply;
    string public name;
    string public symbol;

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) public {
        name = _name;
        symbol = _symbol;
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function removeWhitelistAdmin(address account) public onlyOwner {

        _removeWhitelistAdmin(account);
    }

    function removeMinter(address account) public onlyOwner {

        _removeMinter(account);
    }

    function uri(uint256 _id) public view returns (string memory) {

        require(_exists(_id), "ERC721Tradable#uri: NONEXISTENT_TOKEN");
        return Strings.strConcat(baseMetadataURI, Strings.uint2str(_id));
    }

    function totalSupply(uint256 _id) public view returns (uint256) {

        return tokenSupply[_id];
    }

    function maxSupply(uint256 _id) public view returns (uint256) {

        return tokenMaxSupply[_id];
    }

    function setBaseMetadataURI(string memory _newBaseMetadataURI)
        public
        onlyWhitelistAdmin
    {

        _setBaseMetadataURI(_newBaseMetadataURI);
    }

    function create(
        uint256 _maxSupply,
        uint256 _initialSupply,
        string calldata _uri,
        bytes calldata _data
    ) external onlyWhitelistAdmin returns (uint256 tokenId) {

        require(
            _initialSupply <= _maxSupply,
            "Initial supply cannot be more than max supply"
        );
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = msg.sender;

        if (bytes(_uri).length > 0) {
            emit URI(_uri, _id);
        }

        if (_initialSupply != 0) _mint(msg.sender, _id, _initialSupply, _data);
        tokenSupply[_id] = _initialSupply;
        tokenMaxSupply[_id] = _maxSupply;
        return _id;
    }

    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public onlyMinter {

        uint256 tokenId = _id;
        require(
            tokenSupply[tokenId] < tokenMaxSupply[tokenId],
            "Max supply reached"
        );
        _mint(_to, _id, _quantity, _data);
        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
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

        return creators[_id] != address(0);
    }

    function _getNextTokenID() private view returns (uint256) {

        return _currentTokenID.add(1);
    }

    function _incrementTokenTypeId() private {

        _currentTokenID++;
    }
}

contract GenesisPool is TFTTokenWrapper, Ownable {

    ERC1155Tradable public tfts;

    mapping(address => uint256) public lastUpdateTime;
    mapping(address => uint256) public points;
    mapping(uint256 => uint256) public cards;

    event CardAdded(uint256 card, uint256 points);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Redeemed(address indexed user, uint256 amount);

    modifier updateReward(address account) {

        if (account != address(0)) {
            points[account] = earned(account);
            lastUpdateTime[account] = block.timestamp;
        }
        _;
    }

    constructor(ERC1155Tradable _tftsAddress, IERC20 _tftAddress)
        public
        TFTTokenWrapper(_tftAddress)
    {
        tfts = _tftsAddress;
    }

    function addCard(uint256 cardId, uint256 amount) public onlyOwner {

        cards[cardId] = amount;
        emit CardAdded(cardId, amount);
    }

    function earned(address account) public view returns (uint256) {

        uint256 blockTime = block.timestamp;
        return
            points[account].add(
                blockTime
                    .sub(lastUpdateTime[account])
                    .mul(1e6)
                    .div(86400)
                    .mul(balanceOf(account).div(1e13))
                    .div(1e4)
            );
    }

    function stake(uint256 amount) public updateReward(msg.sender) {

        require(
            amount.add(balanceOf(msg.sender)) <= 1e15,
            "Cannot stake more than 1e15 LP"
        );

        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");

        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
    }

    function redeem(uint256 card) public updateReward(msg.sender) {

        require(cards[card] != 0, "Card not found");
        require(
            points[msg.sender] >= cards[card],
            "Not enough points to redeem for card"
        );
        require(
            tfts.totalSupply(card) < tfts.maxSupply(card),
            "Max cards minted"
        );

        points[msg.sender] = points[msg.sender].sub(cards[card]);
        tfts.mint(msg.sender, card, 1, "");
        emit Redeemed(msg.sender, cards[card]);
    }
}