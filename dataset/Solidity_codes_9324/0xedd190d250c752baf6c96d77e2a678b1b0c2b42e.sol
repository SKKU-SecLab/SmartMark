
pragma solidity 0.5.17;


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = msg.sender;
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

        return msg.sender == _owner;
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

library Roles {

    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage _role, address _account) internal {

        require(!has(_role, _account), "Roles: account already has role");
        _role.bearer[_account] = true;
    }

    function remove(Role storage _role, address _account) internal {

        require(has(_role, _account), "Roles: account does not have role");
        _role.bearer[_account] = false;
    }

    function has(Role storage _role, address _account) internal view returns (bool) {

        require(_account != address(0), "Roles: account is the zero address");
        return _role.bearer[_account];
    }
}

contract Operator is Ownable {

    using Roles for Roles.Role;

    Roles.Role private _operators;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    function isOperator(address _account) public view returns (bool) {

        return _operators.has(_account);
    }

    function addOperator(address _account) external onlyOwner {

        _addOperator(_account);
    }

    function removeOperator(address _account) external onlyOwner {

        _removeOperator(_account);
    }

    function renounceOperator() external {

        _removeOperator(msg.sender);
    }

    function _addOperator(address _account) internal {

        _operators.add(_account);
        emit OperatorAdded(_account);
    }

    function _removeOperator(address _account) internal {

        _operators.remove(_account);
        emit OperatorRemoved(_account);
    }
}

contract Pausable is Ownable {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() external onlyOwner whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;


    function approve(address to, uint256 tokenId) public;


    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;


    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public;

}

contract IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4);

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping(uint256 => address) private _tokenOwner;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => Counters.Counter) private _ownedTokensCount;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor() public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {

        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {

        if (!to.isContract()) {
            return true;
        }
        (bool success, bytes memory returndata) = to.call(
            abi.encodeWithSelector(IERC721Receiver(to).onERC721Received.selector, msg.sender, from, tokenId, _data)
        );
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

}

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor() public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}

contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    string private _baseURI;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_tokenURI).length == 0) {
            return "";
        } else {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI) internal {

        _baseURI = baseURI;
    }

    function baseURI() external view returns (string memory) {

        return _baseURI;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

contract ERC721Pausable is ERC721, Pausable {

    function approve(address to, uint256 tokenId) public whenNotPaused {

        super.approve(to, tokenId);
    }

    function setApprovalForAll(address to, bool approved) public whenNotPaused {

        super.setApprovalForAll(to, approved);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal whenNotPaused {

        super._transferFrom(from, to, tokenId);
    }
}

contract Whitelist is Ownable {

    using Roles for Roles.Role;

    Roles.Role private _whitelists;

    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);

    function isWhitelist(address _account) public view returns (bool) {

        return _whitelists.has(_account);
    }

    function addWhitelist(address _account) external onlyOwner {

        _addWhitelist(_account);
    }

    function removeWhitelist(address _account) external onlyOwner {

        _removeWhitelist(_account);
    }

    function renounceWhitelist() external {

        _removeWhitelist(msg.sender);
    }

    function _addWhitelist(address _account) internal {

        _whitelists.add(_account);
        emit WhitelistAdded(_account);
    }

    function _removeWhitelist(address _account) internal {

        _whitelists.remove(_account);
        emit WhitelistRemoved(_account);
    }
}

contract ERC721Whitelist is ERC721, Whitelist {

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {

        require(isWhitelist(from) || isWhitelist(to), "ERC721Whitelist: sender or recipient is not whitelist");
        super._transferFrom(from, to, tokenId);
    }
}

contract ERC721Full is ERC721Enumerable, ERC721Metadata, ERC721Pausable, ERC721Whitelist {

    constructor(string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {



        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract GenesisKingdomToken is Operator, ERC721Full {

    using SafeERC20 for IERC20;

    uint256 public constant SYSTEM_FEE_COEFF = 10000; // 10x percent, 10000 = 100%

    struct Order {
        uint128 id;
        uint128[] landIds;
        address maker;
        address taker;
        address[] offeredCurrencies;
        uint256[] offeredAmounts;
        address fulfilledCurrency;
        uint256 fulfilledAmount;
        OrderType otype;
        OrderSellingMethod sellingMethod;
        OrderStatus status;
    }

    struct SystemFee {
        uint128 id;
        uint256 genesisFee;
        uint256 inviterReward;
        uint256 buyerReward;
    }

    enum OrderType { OrderIndividual, OrderBundle }

    enum OrderSellingMethod { Acreage, Freely }

    enum OrderStatus { OPEN, HOLDING, FULFILLED, CANCELLED }

    mapping(uint128 => bytes32) private _nameOfLands;
    mapping(uint128 => uint128) private _bundleOfLands;
    mapping(uint128 => Order) private _orders;
    mapping(uint128 => uint128) private _goodIdOfOrders;
    mapping(uint128 => address) private _orderHolders;
    mapping(string => bool) private _processedTxids;
    mapping(uint128 => SystemFee) private _systemFees;
    mapping(uint128 => uint128) private _orderFees;

    event Received(address operator, address from, uint256 tokenId, bytes data, uint256 gas);
    event OrderCreate(address operator, uint128 indexed orderId);
    event OrderUpdate(address operator, uint128 indexed orderId);
    event OrderCancelled(address operator, uint128 indexed orderId);
    event OrderHolding(address holder, uint128 indexed orderId);
    event OrderFulfilled(address operator, uint128 indexed orderId);
    event SystemFeeCreate(address operator, uint128 feeId);
    event Withdrawal(address operator, address recepient, address currency, uint256 amount);
    event Refund(address receiver, uint128 orderId, address currency, uint256 amount);

    constructor(string memory _name, string memory _symbol) public ERC721Full(_name, _symbol) {
        _addWhitelist(address(this));
    }

    function getLandDetail(uint128 id)
        external
        view
        returns (
            uint128 landId,
            uint128 landBundleId,
            bytes32 lname,
            address owner
        )
    {

        landId = id;
        lname = _nameOfLands[landId];
        landBundleId = _bundleOfLands[landId];
        owner = ownerOf(landId);
    }

    function hasExistentToken(uint128 id) external view returns (bool) {

        return _exists(id);
    }

    function _issueNewLand(
        address _owner,
        uint128 _id,
        bytes32 _name,
        uint128 _bundleId
    ) internal {

        require(_bundleId != 0, "GK: invalid bundleId");
        require(_name.length != 0, "GK: invalid landName");

        _nameOfLands[_id] = _name;
        _bundleOfLands[_id] = _bundleId;

        _mint(_owner, _id);
    }

    function issueNewLandBundle(
        address _owner,
        uint128[] calldata _ids,
        bytes32[] calldata _names,
        uint128 _bundleId
    ) external onlyOwner whenNotPaused {

        require(_ids.length == _names.length, "GK: invalid array length");
        for (uint256 i = 0; i != _ids.length; i++) {
            _issueNewLand(_owner, _ids[i], _names[i], _bundleId);
        }
    }

    function getOrderDetails(uint128 _orderId)
        external
        view
        returns (
            uint128 id,
            uint128[] memory landIds,
            address maker,
            address taker,
            address[] memory offeredCurrencies,
            uint256[] memory offeredAmounts,
            address fulfilledCurrency,
            uint256 fulfilledAmount,
            OrderType otype,
            OrderSellingMethod sellingMethod,
            OrderStatus status
        )
    {

        Order memory order = _orders[_orderId];
        id = order.id;
        landIds = order.landIds;
        maker = order.maker;
        taker = order.taker;
        offeredCurrencies = order.offeredCurrencies;
        offeredAmounts = order.offeredAmounts;
        fulfilledCurrency = order.fulfilledCurrency;
        fulfilledAmount = order.fulfilledAmount;
        otype = order.otype;
        sellingMethod = order.sellingMethod;
        status = order.status;
    }

    function getOrderGoodId(uint128 _orderId) external view returns (uint128) {

        return _goodIdOfOrders[_orderId];
    }

    function getOrderGenesisFeeId(uint128 _orderId) external view returns (uint128 feeId) {

        return _orderFees[_orderId];
    }

    function hasExistentOrder(uint128 _orderId) external view returns (bool) {

        return _orders[_orderId].id != 0;
    }

    function _preValidateOrder(
        uint128 _orderId,
        uint128 _goodId,
        address[] memory _offeredCurrencies,
        uint256[] memory _offeredAmounts,
        uint128 _feeId
    ) internal view {

        require(_orderId != 0, "GK: invalid orderId");
        require(_orders[_orderId].id == 0, "GK: order has already exists");
        require(_goodId != 0, "GK: invalid goodId");
        require(_offeredCurrencies.length == _offeredAmounts.length, "GK: invalid array length");
        require(_systemFees[_feeId].id != 0, "GK: invalid system fee");
    }

    function _createOrder(
        uint128 _orderId,
        uint128 _goodId,
        uint128[] memory _landIds,
        address[] memory _offeredCurrencies,
        uint256[] memory _offeredAmounts,
        OrderType _type,
        OrderSellingMethod _sellingMethod,
        uint128 _feeId
    ) internal {

        _orders[_orderId] = Order(
            _orderId,
            _landIds,
            msg.sender,
            address(0),
            _offeredCurrencies,
            _offeredAmounts,
            address(0),
            0,
            _type,
            _sellingMethod,
            OrderStatus.OPEN
        );
        _orderFees[_orderId] = _feeId;
        _goodIdOfOrders[_orderId] = _goodId;

        emit OrderCreate(msg.sender, _orderId);
    }

    function issueAndCreateLandBundleOrder(
        uint128 _orderId,
        uint128 _bundleId,
        uint128[] calldata _ids,
        bytes32[] calldata _names,
        address[] calldata _offeredCurrencies,
        uint256[] calldata _offeredAmounts,
        OrderSellingMethod _sellingMethod,
        uint128 _feeId
    ) external onlyOwner whenNotPaused {

        for (uint256 i = 0; i != _ids.length; i++) {
            _issueNewLand(address(this), _ids[i], _names[i], _bundleId);
        }

        _preValidateOrder(_orderId, _bundleId, _offeredCurrencies, _offeredAmounts, _feeId);

        _createOrder(_orderId, _bundleId, _ids, _offeredCurrencies, _offeredAmounts, OrderType.OrderBundle, _sellingMethod, _feeId);
    }

    function createSingleLandOrder(
        uint128 _orderId,
        uint128 _landId,
        address[] calldata _offeredCurrencies,
        uint256[] calldata _offeredAmounts,
        OrderSellingMethod _sellingMethod,
        uint128 _feeId
    ) external whenNotPaused {

        uint128[] memory _landIds = new uint128[](1);
        _landIds[0] = _landId;

        _preValidateOrder(_orderId, _landId, _offeredCurrencies, _offeredAmounts, _feeId);

        transferFrom(msg.sender, address(this), _landId);

        _createOrder(_orderId, _landId, _landIds, _offeredCurrencies, _offeredAmounts, OrderType.OrderIndividual, _sellingMethod, _feeId);
    }

    function createLandBundleOrder(
        uint128 _orderId,
        uint128 _bundleId,
        uint128[] calldata _landIds,
        address[] calldata _offeredCurrencies,
        uint256[] calldata _offeredAmounts,
        OrderSellingMethod _sellingMethod,
        uint128 _feeId
    ) external whenNotPaused {

        _preValidateOrder(_orderId, _bundleId, _offeredCurrencies, _offeredAmounts, _feeId);

        _batchSafeTransferFrom(address(0), msg.sender, address(this), _landIds);

        _createOrder(_orderId, _bundleId, _landIds, _offeredCurrencies, _offeredAmounts, OrderType.OrderBundle, _sellingMethod, _feeId);
    }

    function updateOrder(
        uint128 _orderId,
        address[] calldata _offeredCurrencies,
        uint256[] calldata _offeredAmounts,
        OrderSellingMethod _sellingMethod,
        uint128 _feeId
    ) external whenNotPaused {

        Order storage order = _orders[_orderId];
        require(order.id != 0, "GK: caller query nonexistent order");
        require(msg.sender == order.maker, "GK: only maker can update order");
        require(order.status == OrderStatus.OPEN, "GK: order not allow to update");
        require(_systemFees[_feeId].id != 0, "GK: invalid system fee");
        require(_offeredCurrencies.length == _offeredAmounts.length, "GK: invalid array length");

        order.offeredCurrencies = _offeredCurrencies;
        order.offeredAmounts = _offeredAmounts;
        order.sellingMethod = _sellingMethod;
        _orderFees[_orderId] = _feeId;

        emit OrderUpdate(msg.sender, order.id);
    }

    function cancelOrder(uint128 _orderId) external whenNotPaused {

        Order storage order = _orders[_orderId];
        require(order.id != 0, "GK: caller query nonexistent order");
        require(msg.sender == order.maker, "GK: only maker can cancel order");
        require(order.status == OrderStatus.OPEN, "GK: order not allow to cancel");

        if (order.otype == OrderType.OrderIndividual) {
            IERC721(address(this)).safeTransferFrom(address(this), order.maker, order.landIds[0]);
        } else if (order.otype == OrderType.OrderBundle) {
            _batchSafeTransferFrom(address(this), address(this), order.maker, order.landIds);
        }
        order.status = OrderStatus.CANCELLED;

        emit OrderCancelled(msg.sender, order.id);
    }

    function takeOrderByEther(uint128 _orderId) external payable whenNotPaused {

        Order storage order = _orders[_orderId];
        require(order.id != 0, "GK: caller query nonexistent order");
        require(order.maker != msg.sender, "GK: you are owner");
        if (order.status == OrderStatus.OPEN) {
            uint256 _amount = 0;
            for (uint256 i = 0; i != order.offeredCurrencies.length; i++) {
                if (order.offeredCurrencies[i] == address(0)) {
                    _amount = order.offeredAmounts[i];
                    break;
                }
            }
            require(_amount != 0 && msg.value == _amount, "GK: invalid amount");

            order.status = OrderStatus.HOLDING;
            _orderHolders[_orderId] = msg.sender;

            emit OrderHolding(msg.sender, order.id);
        } else {
            msg.sender.transfer(msg.value);
            emit Refund(msg.sender, _orderId, address(0), msg.value);
        }
    }

    function completeOrder(
        uint128 _orderId,
        address _taker,
        address _currency,
        uint256 _amount,
        string calldata _txid
    ) external whenNotPaused {

        require(isOperator(msg.sender), "GK: caller is not operator");
        require(_taker != address(0), "GK: invalid address");
        if (_orderHolders[_orderId] != address(0)) {
            require(_taker == _orderHolders[_orderId], "GK: invalid taker");
        }
        Order storage order = _orders[_orderId];
        require(order.id != 0, "GK: caller query nonexistent order");
        require(order.maker != _taker, "GK: you are owner");
        require(order.status == OrderStatus.OPEN || order.status == OrderStatus.HOLDING, "GK: cannot complete this order");
        require(!_processedTxids[_txid], "GK: txid has processed");

        uint256 amount = 0;
        for (uint256 i = 0; i != order.offeredCurrencies.length; i++) {
            if (_currency == order.offeredCurrencies[i]) {
                amount = order.offeredAmounts[i];
                break;
            }
        }
        require(amount != 0 && amount == _amount, "GK: invalid amount");

        uint256 fee = 0;
        if (order.maker != owner()) {
            SystemFee memory sFee = _systemFees[_orderFees[_orderId]];
            fee = _amount.mul(sFee.genesisFee).div(SYSTEM_FEE_COEFF);
        }

        if (_currency == address(0)) {
            order.maker.toPayable().transfer(amount.sub(fee));
        } else {
            IERC20(_currency).safeTransfer(order.maker, amount.sub(fee));
        }

        if (order.otype == OrderType.OrderIndividual) {
            IERC721(address(this)).safeTransferFrom(address(this), _taker, order.landIds[0]);
        } else if (order.otype == OrderType.OrderBundle) {
            _batchSafeTransferFrom(address(this), address(this), _taker, order.landIds);
        }

        order.taker = _taker;
        order.fulfilledCurrency = _currency;
        order.fulfilledAmount = amount;
        order.status = OrderStatus.FULFILLED;

        _orderHolders[_orderId] = _taker;
        _processedTxids[_txid] = true;

        emit OrderFulfilled(msg.sender, order.id);
    }

    function getSystemFee(uint128 _feeId)
        external
        view
        returns (
            uint128 feeId,
            uint256 genesisFee,
            uint256 inviterReward,
            uint256 buyerReward
        )
    {

        feeId = _systemFees[_feeId].id;
        genesisFee = _systemFees[_feeId].genesisFee;
        inviterReward = _systemFees[_feeId].inviterReward;
        buyerReward = _systemFees[_feeId].buyerReward;
    }

    function setNewSystemFee(
        uint128 _feeId,
        uint256 _genesisFee,
        uint256 _inviterReward,
        uint256 _buyerReward
    ) external onlyOwner whenNotPaused {

        require(_feeId != 0, "GK: invalid feeId");
        require(_systemFees[_feeId].id == 0, "GK: fee has already exists");

        _systemFees[_feeId] = SystemFee(_feeId, _genesisFee, _inviterReward, _buyerReward);
        emit SystemFeeCreate(msg.sender, _feeId);
    }

    function _withdrawal(
        address _recepient,
        address _currency,
        uint256 _amount
    ) internal {

        require(_recepient != address(0), "GK: invalid address");
        require(_amount != 0, "GK: invalid amount");
        if (_currency == address(0)) {
            require(address(this).balance >= _amount, "GK: balance not enough");
            _recepient.toPayable().transfer(_amount);
        } else {
            uint256 balance = IERC20(_currency).balanceOf(address(this));
            require(balance >= _amount, "GK: balance not enough");
            IERC20(_currency).safeTransfer(_recepient, _amount);
        }
    }

    function withdrawal(
        address _recepient,
        address _currency,
        uint256 _amount
    ) external onlyOwner {

        _withdrawal(_recepient, _currency, _amount);
        emit Withdrawal(msg.sender, _recepient, _currency, _amount);
    }

    function refund(
        uint128 _orderId,
        address _recepient,
        address _currency,
        uint256 _amount
    ) external whenNotPaused {

        require(isOperator(msg.sender), "GK: caller is not operator");
        require(_orders[_orderId].id != 0, "GK: caller query nonexistent order");
        _withdrawal(_recepient, _currency, _amount);
        emit Refund(_recepient, _orderId, _currency, _amount);
    }

    function setTokenURI(uint256 tokenId, string calldata _tokenURI) external onlyOwner {

        super._setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {

        super._setBaseURI(baseURI);
    }

    function _batchSafeTransferFrom(
        address _token,
        address _from,
        address _recepient,
        uint128[] memory _tokenIds
    ) internal {

        for (uint256 i = 0; i != _tokenIds.length; i++) {
            if (_token != address(0)) {
                IERC721(_token).safeTransferFrom(_from, _recepient, _tokenIds[i]);
            } else {
                safeTransferFrom(_from, _recepient, _tokenIds[i]);
            }
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {

        emit Received(operator, from, tokenId, data, gasleft());
        return 0x150b7a02;
    }
}