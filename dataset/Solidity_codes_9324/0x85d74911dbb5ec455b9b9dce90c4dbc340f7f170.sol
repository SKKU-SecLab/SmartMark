


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}




pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;




interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}




pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}




pragma solidity ^0.8.0;



interface IAccessControlEnumerable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}




pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}




pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}




pragma solidity ^0.8.0;

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



pragma solidity ^0.8.0;

interface IMarketSale {

    function getTokenOnSale(uint256 tokenId) external view returns (address payable seller, uint256 price, uint64 startedAt);


    function createSale(uint256 tokenId, uint256 price) external returns (uint256);


    function cancelSale(uint256 tokenId) external;


    function buySale(uint256 tokenId) external payable;


    function withdrawBalance(address payable to, uint256 amount) external;

}



pragma solidity ^0.8.0;

interface IMarketSaleEnum {

    function sellerSalesCount(address seller) external view returns (uint256);

    
    function saleTokenOfSellerByIndex(address seller, uint256 index) external view returns (uint256);


    function totalSaleTokens() external view returns (uint256);


    function saleTokenByIndex(uint256 index) external view returns (uint256);

}



pragma solidity ^0.8.0;








contract MarketSale is IMarketSale, IMarketSaleEnum, Pausable, AccessControlEnumerable, ERC721Holder {


    struct Sale {
        address payable seller;
        uint256 price;
        uint64 startedAt;
    }

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ACCOUNTANCY_ROLE = keccak256("ACCOUNTANCY");

    address private _nftContract;

    uint256 private _PRICE_LIMIT;
    uint256 private _minPrice;
    uint256 private _minFee;
    uint8 private _tradeFee;
    uint256 private _totalFeeAmount;

    mapping(uint256 => Sale) private tokenIdToSale;

    mapping(address => uint256) private _sellerSalesCount;
    mapping(address => mapping(uint256 => uint256)) private _sellerSaleTokens;
    mapping(uint256 => uint256) private _sellerSaleTokensIndex;

    uint256[] private _allSaleTokens;
    mapping(uint256 => uint256) private _allSaleTokensIndex;

    event SaleCreated(uint256 tokenId, uint256 price, address payable seller);
    event SaleSucceed(uint256 tokenId, uint256 price, address payable seller, address buyer);
    event SaleCancelled(uint256 tokenId, address seller);

    constructor() {
        _initRoles();
        _init();
    }

    function _init() internal {

        _PRICE_LIMIT = 0.01 ether;
        _minPrice = 0.01 ether;
        _minFee = 0.001 ether;
        _tradeFee = 1;
        _totalFeeAmount = 0;
    }

    function _initRoles() internal {

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(ACCOUNTANCY_ROLE, msg.sender);
    }

    modifier isInitialed() {

        require(_nftContract != address(0), "NFTContract not ready");
        _;
    }

    modifier isAccountancyRole() {

        bool isAdmin = hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
        bool isAccountancy = hasRole(ACCOUNTANCY_ROLE, msg.sender);
        require(isAdmin || isAccountancy, "Not Accountancy Role");
        _;
    }

    modifier onlyAdmin() {

        _checkRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    function pause() public {

        require(hasRole(PAUSER_ROLE, msg.sender));
        _pause();
    }

    function unpause() public {

        require(hasRole(PAUSER_ROLE, msg.sender));
        _unpause();
    }

    function setNFTContract(address to) public onlyAdmin() {

        require(to != address(0));
        _nftContract = to;
    }

    function getNFTContract() public view returns (address) {

        return _nftContract;
    }

    function setMinPrice(uint256 to) public isAccountancyRole {

        require(to > _PRICE_LIMIT);
        _minPrice = to;
    }

    function getMinPrice() public view returns (uint256) {

        return _minPrice;
    }

    function setMinFee(uint256 to) public isAccountancyRole {

        require(to > _PRICE_LIMIT);
        _minFee = to;
    }

    function getMinFee() public view returns (uint256) {

        return _minFee;
    }

    function setTradeFee(uint8 to) public isAccountancyRole {

        require(to >= 1 && to < 100 );
        _tradeFee = to;
    }

    function getTradeFee() public view returns (uint256) {

        return _tradeFee;
    }

    function getTotalFeeAmount() public view returns (uint256) {

        return _totalFeeAmount;
    }

    function sellerSalesCount(address seller) public view override returns (uint256) {

        return _sellerSalesCount[seller];
    }

    function saleTokenOfSellerByIndex(address seller, uint256 index) public view override returns (uint256) {

        require(index < _sellerSalesCount[seller], "seller index out of bounds");
        return _sellerSaleTokens[seller][index];
    }

    function totalSaleTokens() public view override returns (uint256) {

        return _allSaleTokens.length;
    }

    function saleTokenByIndex(uint256 index) public view override returns (uint256) {

        require(index < _allSaleTokens.length, "global index out of bounds");
        return _allSaleTokens[index];
    }

    function _isOnSale(Sale storage sale) internal view returns (bool) {

        return (sale.startedAt > 0);
    }

    function _safeTransferToken(address from, address to, uint256 tokenId) internal {

        IERC721(_nftContract).safeTransferFrom(from, to, tokenId);
    }

    function _escrow(address _owner, uint256 tokenId) internal {

        if (_owner != address(this)) {
            _safeTransferToken(_owner, address(this), tokenId);
        }
    }

    function _addSaleTokenToSellerEnumeration(address to, uint256 tokenId) private {

        uint256 length = _sellerSalesCount[to];
        _sellerSaleTokens[to][length] = tokenId;
        _sellerSaleTokensIndex[tokenId] = length;
        _sellerSalesCount[to] += 1;
    }

    function _addSaleTokenToAllEnumeration(uint256 tokenId) private {

        _allSaleTokensIndex[tokenId] = _allSaleTokens.length;
        _allSaleTokens.push(tokenId);
    }

    function _removeSaleTokenFromSellerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = _sellerSalesCount[from] - 1;
        uint256 tokenIndex = _sellerSaleTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _sellerSaleTokens[from][lastTokenIndex];
            _sellerSaleTokens[from][tokenIndex] = lastTokenId;
            _sellerSaleTokensIndex[lastTokenId] = tokenIndex;
        }

        _sellerSalesCount[from] -= 1;
        delete _sellerSaleTokensIndex[tokenId];
        delete _sellerSaleTokens[from][lastTokenIndex];
    }

    function _removeSaleTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allSaleTokens.length - 1;
        uint256 tokenIndex = _allSaleTokensIndex[tokenId];

        uint256 lastTokenId = _allSaleTokens[lastTokenIndex];

        _allSaleTokens[tokenIndex] = lastTokenId;
        _allSaleTokensIndex[lastTokenId] = tokenIndex;

        delete _allSaleTokensIndex[tokenId];
        _allSaleTokens.pop();
    }

    function _addSale(uint256 tokenId, Sale memory sale) internal {

        tokenIdToSale[tokenId] = sale;
        _addSaleTokenToSellerEnumeration(sale.seller, tokenId);
        _addSaleTokenToAllEnumeration(tokenId);
        emit SaleCreated(
            uint256(tokenId),
            uint256(sale.price),
            sale.seller
        );
    }
    
    function _removeSale(uint256 tokenId) internal {

        Sale storage s = tokenIdToSale[tokenId];
        address seller = s.seller;
        _removeSaleTokenFromSellerEnumeration(seller, tokenId);
        _removeSaleTokenFromAllTokensEnumeration(tokenId);
        delete tokenIdToSale[tokenId];
    }

    function _checkMsgSenderMatchOwner(uint256 tokenId) internal view returns (bool) {

        address owner = IERC721(_nftContract).ownerOf(tokenId);
        return (owner == msg.sender);
    }

    function createSale(uint256 tokenId, uint256 price) public whenNotPaused isInitialed override returns (uint256) {

        require(_checkMsgSenderMatchOwner(tokenId), "Not unit owner");
        require(price >= _minPrice, "Unit price too low");
        address payable seller = payable(msg.sender);
        _escrow(seller, tokenId);
        Sale memory sale = Sale(
            seller,
            price,
            uint64(block.timestamp)
        );
        _addSale(tokenId, sale);
        return _allSaleTokens.length - 1;
    }

    function getTokenOnSale(uint256 tokenId) public view isInitialed override returns (
        address payable seller,
        uint256 price,
        uint64 startedAt
    ) {

        (seller, price, startedAt) = _getTokenOnSale(tokenId);
    }

    function _getTokenOnSale(uint256 tokenId) internal view returns (
        address payable seller,
        uint256 price,
        uint64 startedAt
    ) {

        Sale storage s = tokenIdToSale[tokenId];
        require(_isOnSale(s), "Token is not on sale");
        seller = s.seller;
        price = s.price;
        startedAt = s.startedAt;
    }

    function _cancelOnSale(uint256 tokenId, address seller) internal {

        _removeSale(tokenId);
        _safeTransferToken(address(this), seller, tokenId);
        emit SaleCancelled(tokenId, seller);
    }

    function _cancelSale(uint256 tokenId) internal {

        Sale storage s = tokenIdToSale[tokenId];
        require(_isOnSale(s), "Token is not on sale");
        address seller = s.seller;
        require(msg.sender == seller);
        _cancelOnSale(tokenId, seller);
    }

    function _forceCancelSale(uint256 tokenId) internal onlyAdmin {

        Sale storage s = tokenIdToSale[tokenId];
        require(_isOnSale(s), "Token is not on sale");
        address seller = s.seller;
        _cancelOnSale(tokenId, seller);
    }

    function calculateTradeFee(uint256 payment) public view returns (uint256) {

        uint256 fee = payment * _tradeFee / 100;
        if (fee < _minFee) {
            fee = _minFee;
        }
        return fee;
    }

    function _buySale(uint256 tokenId) internal whenNotPaused {

        require(msg.sender != address(0), "Invalid buyer");
        require(msg.value >= _minPrice, "Invalid payment");
        address payable seller;
        uint256 price;
        uint64 startedAt;
        (seller, price, startedAt) = _getTokenOnSale(tokenId);
        require(msg.sender != seller, "Could not buy your own item");
        require(msg.value >= price, "Payment not match sale price");
        _removeSale(tokenId);
        _safeTransferToken(address(this), msg.sender, tokenId);
        uint256 tradeFee = calculateTradeFee(msg.value);
        if (msg.value > tradeFee) {
            _totalFeeAmount += tradeFee;
            uint256 leastAmount = msg.value - tradeFee;
            seller.transfer(leastAmount);
        } else {
            _totalFeeAmount += msg.value;
        }
        emit SaleSucceed(tokenId, price, seller, msg.sender);
    }

    function cancelSale(uint256 tokenId) external override {

        _cancelSale(tokenId);
    }

    function buySale(uint256 tokenId) external payable whenNotPaused isInitialed override {

        _buySale(tokenId);
    }

    function withdrawBalance(address payable to, uint256 amount) external override isAccountancyRole {

        _transferBalance(to, amount);
    }

    function _transferBalance(address payable to, uint256 amount) internal {

        to.transfer(amount);
    }

    function withdrawERC20Token(address token, address to, uint256 amount) external isAccountancyRole {

        IERC20(token).transfer(to, amount);
    }

    function cancelLastSale(uint256 count) public whenPaused onlyAdmin {

        uint256 totalCount = totalSaleTokens();
        require(count <= totalCount);
        for (uint i=0; i<count; i++) {
            uint256 currentTotal = totalSaleTokens();
            uint256 lastTokenId = saleTokenByIndex(currentTotal - 1);
            _forceCancelSale(lastTokenId);
        }
    }
}