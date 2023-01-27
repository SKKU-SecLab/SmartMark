
pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.4;


interface IERC721A is IERC721, IERC721Metadata {

    error ApprovalCallerNotOwnerNorApproved();

    error ApprovalQueryForNonexistentToken();

    error ApproveToCaller();

    error ApprovalToCurrentOwner();

    error BalanceQueryForZeroAddress();

    error MintToZeroAddress();

    error MintZeroQuantity();

    error OwnerQueryForNonexistentToken();

    error TransferCallerNotOwnerNorApproved();

    error TransferFromIncorrectOwner();

    error TransferToNonERC721ReceiverImplementer();

    error TransferToZeroAddress();

    error URIQueryForNonexistentToken();

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
    }

    struct AddressData {
        uint64 balance;
        uint64 numberMinted;
        uint64 numberBurned;
        uint64 aux;
    }

    function totalSupply() external view returns (uint256);

}//Unlicense
pragma solidity ^0.8.4;

interface IMembershipNFT {

    event Mint(
        address indexed operator,
        address indexed to,
        uint256 quantity,
        uint256 tierIndex
    );
    event Burn(address indexed operator, uint256 tokenID);
    event UpdateMetadataImage(string[]);
    event UpdateMetadataExternalUrl(string[]);
    event UpdateMetadataAnimationUrl(string[]);
    event SetupPool(address indexed operator, address pool);
    event Locked(address indexed operator, bool locked);
    event MintToPool(address indexed operator);

    function tierSupply(uint8) external view returns (uint256);


    function tierName(uint8) external view returns (string memory);


    function tierCount(uint8) external view returns (uint256);


    function tierStartId(uint8) external view returns (uint256);


    function tierEndId(uint8) external view returns (uint256);


    function numberTiers() external view returns (uint256);


    function getTierIndex(uint256 _tokenId) external view returns (uint8);


    function getTierTokenId(uint256 _tokenId) external view returns (uint256);


    function getTokenId(uint8 _tier, uint256 _tierTokenId)
        external
        view
        returns (uint256);

}//Unlicense
pragma solidity ^0.8.4;

interface IGiftContract {

    event UpdateGiftLimit(
        address indexed operator,
        uint8 tierIndex,
        uint256 limit
    );
    event UpdateGiftReserves(address operator, uint16[] reserves);

    event Gift(address indexed, uint8, uint256);
    event GiftEx(address indexed, uint256[]);
    event GiftToAll(address[] indexed, uint256[]);
	
    event Submit(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint8 tierIndex,
        uint256 tokenId,
        bytes data
    );
    event SubmitAndConfirm(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint8 tierIndex,
        uint256 tokenId,
        bytes data
    );
    event Confirm(address indexed owner, uint256 indexed txIndex);
    event ConfirmAndExecute(address indexed owner, uint256 indexed txIndex);

    event Revoke(address indexed owner, uint256 indexed txIndex);
    event Execute(address indexed owner, uint256 indexed txIndex);

    function totalSupply(uint8 tierIndex) external view returns (uint256);


    function getNftToken() external view returns (address);


    function getTokenPool() external view returns (address);


    function isTokenSubmitted(uint256 tokenId) external view returns (bool);


    function getGiftedList() external view returns (uint256[] memory);


    function getTransactionCount() external view returns (uint256);


    function getTransaction(uint256 _txIndex)
        external
        view
        returns (
            address to,
            uint256 tokenId,
            bytes memory data,
            bool executed,
            bool reverted,
            uint256 numConfirmations
        );


    function getActiveTxnCount() external view returns (uint256);

    function getActiveTokenIds() external view returns (uint256[] memory);


    function balanceOf(address user, uint8 tierIndex)
        external
        view
        returns (uint256);

}//Unlicense
pragma solidity ^0.8.4;

contract GiftContractV2 is IGiftContract, AccessControl {

    uint256 public confirmsRequired;
    uint8 private constant ID_MOG = 0;
    uint8 private constant ID_INV = 1;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    mapping(uint8 => uint16) public giftLimit;
    mapping(uint8 => uint16) public giftReserves;

    mapping(uint8 => uint256) internal _giftSupply;
    mapping(address => mapping(uint8 => uint256)) public giftList;
    mapping(uint8 => uint256) internal _giftSubmitSupply;
    mapping(address => mapping(uint8 => uint256)) public giftSubmitList;

    mapping(uint256 => bool) internal _isTokenSubmitted;
    uint256[] internal _giftedTokenList;

    bool private _initialized;

    address public nftToken;
    address public tokenPool;

    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    struct Txn {
        address to;
        uint256 tokenId;
        bytes data;
        bool executed;
        bool reverted;
        uint256 confirms;
    }

    Txn[] public txns;
    modifier onlyOwner() {

        address account = msg.sender;
        require(
            hasRole(DEFAULT_ADMIN_ROLE, account) ||
                hasRole(MINTER_ROLE, account) ||
                hasRole(OWNER_ROLE, account),
            "Not admin"
        );
        _;
    }

    modifier txExists(uint256 _txIndex) {

        require(_txIndex < txns.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {

        require(!txns[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {

        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }
    modifier notReverted(uint256 _txIndex) {

        require(!txns[_txIndex].reverted, "tx already reverted");
        _;
    }
    modifier initializer() {

        require(!_initialized, "GIFT_ALREADY_INITIALIZED");
        _initialized = true;
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
    }

    function initialize(address token, address pool)
        external
        initializer
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(
            token != address(0) && pool != address(0),
            "GIFT_INIT_ZERO_ADDRESS"
        );
        nftToken = token;
        tokenPool = pool;
        setGiftLimit(ID_MOG, 1);
        setGiftLimit(ID_INV, 1);
        giftReserves[ID_MOG] = 74;
        giftReserves[ID_INV] = 425;
        confirmsRequired = 2;
    }

    function setGiftLimit(uint8 tierIndex, uint8 limit) public onlyOwner {

        unchecked {
            giftLimit[tierIndex] = limit;
        }
        emit UpdateGiftLimit(msg.sender, tierIndex, limit);
    }

    function setGiftReserve(uint16[] memory reserves) public onlyOwner {

        unchecked {
            for (uint8 i = 0; i < reserves.length; i++) {
                giftReserves[i] = reserves[i];
            }
        }
        emit UpdateGiftReserves(msg.sender, reserves);
    }

    function setNumConfirms(uint256 number) public onlyOwner {

        unchecked {
            confirmsRequired = number;
        }
    }

    function getTransactionCount() public view override returns (uint256) {

        return txns.length;
    }

    function getTransaction(uint256 _txIndex)
        public
        view
        override
        returns (
            address to,
            uint256 tokenId,
            bytes memory data,
            bool executed,
            bool reverted,
            uint256 numConfirmations
        )
    {

        Txn storage transaction = txns[_txIndex];

        return (
            transaction.to,
            transaction.tokenId,
            transaction.data,
            transaction.executed,
            transaction.reverted,
            transaction.confirms
        );
    }

    function getActiveTxnCount() public view override returns (uint256) {

        Txn[] memory _txns = txns;
        uint256 txActiveCount = 0;
        for (uint256 i = 0; i < _txns.length; i++) {
            if (!_txns[i].reverted) txActiveCount++;
        }
        return txActiveCount;
    }

    function getActiveTokenIds()
        public
        view
        override
        returns (uint256[] memory)
    {

        Txn[] memory _txns = txns;
        uint256 txActiveCount = getActiveTxnCount();
        uint256 j = 0;
        uint256[] memory _activeTxnIds = new uint256[](txActiveCount);
        for (uint256 i = 0; i < _txns.length; i++) {
            if (!_txns[i].reverted) {
                _activeTxnIds[j] = _txns[i].tokenId;
                j++;
            }
        }
        return _activeTxnIds;
    }

    function _submit(
        address _to,
        uint8 _tierIndex,
        uint256 _tokenId,
        bytes memory _data
    ) internal returns (uint256) {

        require(_tierIndex == getTierIndex(_tokenId), "GIFT_INVALID_TIER");

        IERC721 nftContract = IERC721(nftToken);
        require(nftContract.ownerOf(_tokenId) == tokenPool, "GIFT_NOT_EXIST");

        require(!_isTokenSubmitted[_tokenId], "GIFT_SUBMITTED_ALREADY");
        _isTokenSubmitted[_tokenId] = true;

        uint256 txIndex = txns.length;
        uint256 giftTierSupply = _giftSubmitSupply[_tierIndex];
        uint256 giftReserve = giftReserves[_tierIndex];

        require(giftTierSupply < giftReserve, "GIFT_RESERVE_LIMITED");
        require(
            giftSubmitList[_to][_tierIndex] < giftLimit[_tierIndex],
            "GIFT_EXCEED_ALLOC"
        );
        txns.push(
            Txn({
                to: _to,
                tokenId: _tokenId,
                data: _data,
                executed: false,
                reverted: false,
                confirms: 0
            })
        );
        _giftSubmitSupply[_tierIndex]++;
        giftSubmitList[_to][_tierIndex]++;
        return txIndex;
    }

    function _confirm(uint256 _txIndex) internal {

        Txn storage transaction = txns[_txIndex];
        transaction.confirms += 1;
        isConfirmed[_txIndex][msg.sender] = true;
    }

    function _execute(uint256 _txIndex) internal {

        Txn storage transaction = txns[_txIndex];
        uint8 tierIndex = getTierIndex(transaction.tokenId);

        require(transaction.confirms >= confirmsRequired, "GIFT_NOT_CONFIRMED");

        transaction.executed = true;

        (bool success, ) = address(nftToken).call(
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                tokenPool,
                transaction.to,
                transaction.tokenId
            )
        );
        require(success, "GIFT_FAILED_TRANSFER");
        _giftedTokenList.push(transaction.tokenId);
        _giftSupply[tierIndex]++;
        giftList[transaction.to][tierIndex]++;
    }

    function _revoke(uint256 _txIndex) internal {

        Txn storage transaction = txns[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
        unchecked {
            transaction.confirms -= 1;
            isConfirmed[_txIndex][msg.sender] = false;
            if (transaction.confirms == 0) {
                transaction.reverted = true;
                _isTokenSubmitted[transaction.tokenId] = false;
                uint8 tierIndex = getTierIndex(transaction.tokenId);
                _giftSubmitSupply[tierIndex]--;
                giftSubmitList[transaction.to][tierIndex]--;
            }
        }
    }

    function submit(
        address _to,
        uint8 _tierIndex,
        uint256 _tokenId,
        bytes memory _data
    ) public onlyOwner {

        uint256 txIndex = txns.length;
        _submit(_to, _tierIndex, _tokenId, _data);
        emit Submit(msg.sender, txIndex, _to, _tierIndex, _tokenId, _data);
    }

    function confirm(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
        notReverted(_txIndex)
    {

        _confirm(_txIndex);
        emit Confirm(msg.sender, _txIndex);
    }

    function execute(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notReverted(_txIndex)
    {

        _execute(_txIndex);
        emit Execute(msg.sender, _txIndex);
    }

    function revoke(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notReverted(_txIndex)
    {

        _revoke(_txIndex);
        emit Revoke(msg.sender, _txIndex);
    }

    function submitAndConfirm(
        address _to,
        uint8 _tierIndex,
        uint256 _tokenId,
        bytes memory _data
    ) public onlyOwner {

        uint256 txIndex = _submit(_to, _tierIndex, _tokenId, _data);
        _confirm(txIndex);
        emit SubmitAndConfirm(
            msg.sender,
            txIndex,
            _to,
            _tierIndex,
            _tokenId,
            _data
        );
    }

    function confirmAndExecute(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notConfirmed(_txIndex)
        notExecuted(_txIndex)
        notReverted(_txIndex)
    {

        _confirm(_txIndex);
        Txn storage transaction = txns[_txIndex];
        if (transaction.confirms >= confirmsRequired) {
            _execute(_txIndex);
            emit ConfirmAndExecute(msg.sender, _txIndex);
        } else {
            emit Confirm(msg.sender, _txIndex);
        }
    }

    function totalSupply(uint8 tierIndex)
        public
        view
        override
        returns (uint256)
    {

        return _giftSupply[tierIndex];
    }

    function getNftToken() public view override returns (address) {

        require(nftToken != address(0), "TOKEN_ZERO_ADDRESS");
        return nftToken;
    }

    function getTokenPool() public view override returns (address) {

        require(tokenPool != address(0), "ACCOUNT_ZERO_ADDRESS");
        return tokenPool;
    }

    function getGiftedList() public view override returns (uint256[] memory) {

        return _giftedTokenList;
    }

    function isTokenSubmitted(uint256 tokenId)
        public
        view
        override
        returns (bool)
    {

        return _isTokenSubmitted[tokenId];
    }

    function getTierStartId(uint8 tier) public view returns (uint256) {

        IMembershipNFT nftContract = IMembershipNFT(nftToken);
        return nftContract.tierStartId(tier);
    }

    function getTierEndId(uint8 tier) public view returns (uint256) {

        IMembershipNFT nftContract = IMembershipNFT(nftToken);
        return nftContract.tierEndId(tier);
    }

    function getTierIndex(uint256 tokenId) public view returns (uint8) {

        IMembershipNFT nftContract = IMembershipNFT(nftToken);
        return nftContract.getTierIndex(tokenId);
    }
    function getTierTokenId(uint256 _tokenId) public view returns(uint) {

        IMembershipNFT nftContract = IMembershipNFT(nftToken);
        return nftContract.getTierTokenId(_tokenId);
    }
    function getTokenId(uint8 _tier, uint _tierTokenId) public view returns(uint) {

        IMembershipNFT nftContract = IMembershipNFT(nftToken);
        return nftContract.getTokenId(_tier, _tierTokenId);
    }
    function balanceOf(address owner, uint8 tierIndex)
        public
        view
        override
        returns (uint256)
    {

        require(owner != address(0), "OWNER_ZERO_ADDRESS");
        return giftList[owner][tierIndex];
    }
}