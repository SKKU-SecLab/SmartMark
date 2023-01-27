

pragma solidity 0.5.17;


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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}

contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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

    constructor () internal {
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

contract ERC721 is Context, ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
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

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {

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

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

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

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

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

contract DloopAdmin {

    mapping(address => bool) private _adminMap;
    uint256 private _adminCount = 0;

    event AdminAdded(address indexed account);
    event AdminRenounced(address indexed account);

    constructor() public {
        _adminMap[msg.sender] = true;
        _adminCount = 1;
    }

    modifier onlyAdmin() {

        require(_adminMap[msg.sender], "caller does not have the admin role");
        _;
    }

    function numberOfAdmins() public view returns (uint256) {

        return _adminCount;
    }

    function isAdmin(address account) public view returns (bool) {

        return _adminMap[account];
    }

    function addAdmin(address account) public onlyAdmin {

        require(!_adminMap[account], "account already has admin role");
        require(account != address(0x0), "account must not be 0x0");
        _adminMap[account] = true;
        _adminCount = SafeMath.add(_adminCount, 1);
        emit AdminAdded(account);
    }

    function renounceAdmin() public onlyAdmin {

        _adminMap[msg.sender] = false;
        _adminCount = SafeMath.sub(_adminCount, 1);
        require(_adminCount > 0, "minimum one admin required");
        emit AdminRenounced(msg.sender);
    }
}

contract DloopGovernance is DloopAdmin {

    bool private _minterRoleEnabled = true;
    mapping(address => bool) private _minterMap;
    uint256 private _minterCount = 0;

    event AllMintersDisabled(address indexed sender);
    event AllMintersEnabled(address indexed sender);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    constructor() public {
        addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(_minterRoleEnabled, "all minters are disabled");
        require(isMinter(msg.sender), "caller does not have the minter role");
        _;
    }

    function disableAllMinters() public onlyMinter {

        _minterRoleEnabled = false;
        emit AllMintersDisabled(msg.sender);
    }

    function enableAllMinters() public onlyAdmin {

        require(!_minterRoleEnabled, "minters already enabled");
        _minterRoleEnabled = true;
        emit AllMintersEnabled(msg.sender);
    }

    function isMinter(address account) public view returns (bool) {

        require(_minterRoleEnabled, "all minters are disabled");
        return _minterMap[account];
    }

    function isMinterRoleActive() public view returns (bool) {

        return _minterRoleEnabled;
    }

    function addMinter(address account) public onlyAdmin {

        require(!_minterMap[account], "account already has minter role");
        _minterMap[account] = true;
        _minterCount = SafeMath.add(_minterCount, 1);
        emit MinterAdded(account);
    }

    function removeMinter(address account) public onlyAdmin {

        require(_minterMap[account], "account does not have minter role");
        _minterMap[account] = false;
        _minterCount = SafeMath.sub(_minterCount, 1);
        emit MinterRemoved(account);
    }

    function numberOfMinters() public view returns (uint256) {

        return _minterCount;
    }
}

contract DloopManagedToken is ERC721, DloopGovernance {

    mapping(uint256 => bool) private _managedMap;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {

        require(!isManaged(tokenId), "token is managed");
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(!isManaged(tokenId), "token is managed");
        super.transferFrom(from, to, tokenId);
    }

    function isManaged(uint256 tokenId) public view returns (bool) {

        require(super._exists(tokenId), "tokenId does not exist");
        return _managedMap[tokenId];
    }

    function _setManaged(uint256 tokenId, bool managed) internal {

        require(super._exists(tokenId), "tokenId does not exist");
        _managedMap[tokenId] = managed;
    }
}

contract DloopWithdraw is DloopManagedToken {

    uint256 private _lastWithdrawal = block.timestamp;
    uint256 private _withdrawalWaitTime = 300;

    event TokenWithdrawn(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event WithdrawalWaitTimeSet(uint256 withdrawalWaitTime);
    event ManagedTransfer(
        address by,
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function managedTransfer(address to, uint256 tokenId)
        public
        onlyMinter
        returns (bool)
    {

        require(
            isManaged(tokenId),
            "specified tokenId does not reference a managed token"
        );

        address from = ownerOf(tokenId);
        super._safeTransferFrom(from, to, tokenId, "");
        emit ManagedTransfer(msg.sender, from, to, tokenId);
        return true;
    }

    function withdraw(address to, uint256 tokenId)
        public
        onlyMinter
        returns (bool)
    {

        require(
            isManaged(tokenId),
            "specified tokenId does not reference a managed token"
        );
        require(canWithdrawNow(), "withdrawal is currently locked");

        _lastWithdrawal = block.timestamp;
        super._setManaged(tokenId, false);

        address from = ownerOf(tokenId);
        super._safeTransferFrom(from, to, tokenId, "");

        emit TokenWithdrawn(from, to, tokenId);
        return true;
    }

    function setWithdrawalWaitTime(uint256 withdrawalWaitTime)
        public
        onlyAdmin
        returns (uint256)
    {

        _withdrawalWaitTime = withdrawalWaitTime;
        emit WithdrawalWaitTimeSet(withdrawalWaitTime);
    }

    function getWithdrawalWaitTime() public view returns (uint256) {

        return _withdrawalWaitTime;
    }

    function canWithdrawNow() public view returns (bool) {

        if (_withdrawalWaitTime == 0) {
            return true;
        } else {
            uint256 nextWithdraw = SafeMath.add(
                _lastWithdrawal,
                _withdrawalWaitTime
            );
            return nextWithdraw <= block.timestamp;
        }
    }

    function getLastWithdrawal() public view returns (uint256) {

        return _lastWithdrawal;
    }

}

contract DloopUtil {

    uint256 internal constant MAX_DATA_LENGTH = 4096;
    uint256 internal constant MIN_DATA_LENGTH = 1;

    struct Data {
        bytes32 dataType;
        bytes data;
    }

    function createTokenId(
        uint64 artworkId,
        uint16 editionNumber,
        uint8 artistProofNumber
    ) public pure returns (uint256) {

        require(artworkId > 0, "artworkId must be positive");
        require(
            editionNumber > 0 || artistProofNumber > 0,
            "one of editionNumber or artistProofNumber must be positive"
        );
        require(
            !(editionNumber != 0 && artistProofNumber != 0),
            "one of editionNumber or artistProofNumber must be zero"
        );

        uint256 tokenId = artworkId;
        tokenId = tokenId << 16;
        tokenId = SafeMath.add(tokenId, editionNumber);
        tokenId = tokenId << 8;
        tokenId = SafeMath.add(tokenId, artistProofNumber);

        return tokenId;
    }

    function splitTokenId(uint256 tokenId)
        public
        pure
        returns (
            uint64 artworkId,
            uint16 editionNumber,
            uint8 artistProofNumber
        )
    {

        artworkId = uint64(tokenId >> 24);
        editionNumber = uint16(tokenId >> 8);
        artistProofNumber = uint8(tokenId);

        require(artworkId > 0, "artworkId must be positive");
        require(
            editionNumber > 0 || artistProofNumber > 0,
            "one of editionNumber or artistProofNumber must be positive"
        );
        require(
            !(editionNumber != 0 && artistProofNumber != 0),
            "one of editionNumber or artistProofNumber must be zero"
        );
    }
}

contract DloopArtwork is DloopGovernance, DloopUtil {

    uint16 private constant MAX_EDITION_SIZE = 10000;
    uint16 private constant MIN_EDITION_SIZE = 1;

    uint8 private constant MAX_ARTIST_PROOF_SIZE = 10;
    uint8 private constant MIN_ARTIST_PROOF_SIZE = 1;

    struct Artwork {
        uint16 editionSize;
        uint16 editionCounter;
        uint8 artistProofSize;
        uint8 artistProofCounter;
        bool hasEntry;
        Data[] dataArray;
    }

    mapping(uint64 => Artwork) private _artworkMap; //uint64 represents the artworkId

    event ArtworkCreated(uint64 indexed artworkId);
    event ArtworkDataAdded(uint64 indexed artworkId, bytes32 indexed dataType);

    function createArtwork(
        uint64 artworkId,
        uint16 editionSize,
        uint8 artistProofSize,
        bytes32 dataType,
        bytes memory data
    ) public onlyMinter returns (bool) {

        require(!_artworkMap[artworkId].hasEntry, "artworkId already exists");
        require(editionSize <= MAX_EDITION_SIZE, "editionSize exceeded");
        require(
            editionSize >= MIN_EDITION_SIZE,
            "editionSize must be positive"
        );
        require(
            artistProofSize <= MAX_ARTIST_PROOF_SIZE,
            "artistProofSize exceeded"
        );
        require(
            artistProofSize >= MIN_ARTIST_PROOF_SIZE,
            "artistProofSize must be positive"
        );

        _artworkMap[artworkId].hasEntry = true;
        _artworkMap[artworkId].editionSize = editionSize;
        _artworkMap[artworkId].artistProofSize = artistProofSize;

        emit ArtworkCreated(artworkId);
        addArtworkData(artworkId, dataType, data);

        return true;
    }

    function _updateArtwork(
        uint64 artworkId,
        uint16 editionNumber,
        uint8 artistProofNumber
    ) internal {

        Artwork storage aw = _artworkMap[artworkId];

        require(aw.hasEntry, "artworkId does not exist");

        if (editionNumber > 0) {
            require(
                editionNumber <= aw.editionSize,
                "editionNumber must not exceed editionSize"
            );
            aw.editionCounter = aw.editionCounter + 1;
        }

        if (artistProofNumber > 0) {
            require(
                artistProofNumber <= aw.artistProofSize,
                "artistProofNumber must not exceed artistProofSize"
            );
            aw.artistProofCounter = aw.artistProofCounter + 1;
        }
    }

    function addArtworkData(
        uint64 artworkId,
        bytes32 dataType,
        bytes memory data
    ) public onlyMinter returns (bool) {

        require(_artworkMap[artworkId].hasEntry, "artworkId does not exist");
        require(artworkId > 0, "artworkId must be greater than 0");
        require(dataType != 0x0, "dataType must not be 0x0");
        require(data.length >= MIN_DATA_LENGTH, "data required");
        require(data.length <= MAX_DATA_LENGTH, "data exceeds maximum length");

        _artworkMap[artworkId].dataArray.push(Data(dataType, data));

        emit ArtworkDataAdded(artworkId, dataType);
        return true;
    }

    function getArtworkDataLength(uint64 artworkId)
        public
        view
        returns (uint256)
    {

        require(_artworkMap[artworkId].hasEntry, "artworkId does not exist");
        return _artworkMap[artworkId].dataArray.length;
    }

    function getArtworkData(uint64 artworkId, uint256 index)
        public
        view
        returns (bytes32 dataType, bytes memory data)
    {

        Artwork memory aw = _artworkMap[artworkId];

        require(aw.hasEntry, "artworkId does not exist");
        require(
            index < aw.dataArray.length,
            "artwork data index is out of bounds"
        );

        dataType = aw.dataArray[index].dataType;
        data = aw.dataArray[index].data;
    }

    function getArtworkInfo(uint64 artworkId)
        public
        view
        returns (
            uint16 editionSize,
            uint16 editionCounter,
            uint8 artistProofSize,
            uint8 artistProofCounter
        )
    {

        Artwork memory aw = _artworkMap[artworkId];
        require(aw.hasEntry, "artworkId does not exist");

        editionSize = aw.editionSize;
        editionCounter = aw.editionCounter;
        artistProofSize = aw.artistProofSize;
        artistProofCounter = aw.artistProofCounter;
    }
}

contract DloopMintable is DloopWithdraw, DloopArtwork {

    mapping(uint256 => Data[]) private _dataMap; //uint256 represents the tokenId

    event EditionMinted(
        uint256 indexed tokenId,
        uint64 indexed artworkId,
        uint16 editionNumber,
        uint8 artistProofNumber
    );
    event EditionDataAdded(uint256 indexed tokenId, bytes32 indexed dataType);

    function mintEdition(
        address to,
        uint64 artworkId,
        uint16 editionNumber,
        uint8 artistProofNumber,
        bytes32 dataType,
        bytes memory data
    ) public onlyMinter returns (bool) {

        uint256 tokenId = super.createTokenId(
            artworkId,
            editionNumber,
            artistProofNumber
        );

        super._safeMint(to, tokenId);
        super._setManaged(tokenId, true);

        super._updateArtwork(artworkId, editionNumber, artistProofNumber);

        emit EditionMinted(
            tokenId,
            artworkId,
            editionNumber,
            artistProofNumber
        );

        if (dataType != 0x0) {
            addEditionData(tokenId, dataType, data);
        }

        return true;
    }

    function addEditionData(
        uint256 tokenId,
        bytes32 dataType,
        bytes memory data
    ) public onlyMinter returns (bool) {

        require(super._exists(tokenId), "tokenId does not exist");
        require(dataType != 0x0, "dataType must not be 0x0");
        require(data.length >= MIN_DATA_LENGTH, "data required");
        require(data.length <= MAX_DATA_LENGTH, "data exceeds maximum length");

        _dataMap[tokenId].push(Data(dataType, data));

        emit EditionDataAdded(tokenId, dataType);
        return true;
    }

    function getEditionDataLength(uint256 tokenId)
        public
        view
        returns (uint256)
    {

        require(_exists(tokenId), "tokenId does not exist");
        return _dataMap[tokenId].length;
    }

    function getEditionData(uint256 tokenId, uint256 index)
        public
        view
        returns (bytes32 dataType, bytes memory data)
    {

        require(_exists(tokenId), "tokenId does not exist");
        require(
            index < _dataMap[tokenId].length,
            "edition data index is out of bounds"
        );

        dataType = _dataMap[tokenId][index].dataType;
        data = _dataMap[tokenId][index].data;
    }
}

contract CustomERC721Metadata is ERC165, ERC721 {

    string private _name;
    string private _symbol;
    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    event BaseURISet(string baseURI);

    constructor(string memory name, string memory symbol, string memory baseURI)
        public
    {
        _name = name;
        _symbol = symbol;
        _baseURI = baseURI;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function _setBaseURI(string memory baseURI) internal {

        _baseURI = baseURI;
        emit BaseURISet(baseURI);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function getBaseURI() external view returns (string memory) {

        return _baseURI;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "tokenId does not exist");
        return string(abi.encodePacked(_baseURI, uint2str(tokenId)));
    }

    function uint2str(uint256 inp) internal pure returns (string memory) {

        if (inp == 0) return "0";
        uint256 i = inp;
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (i != 0) {
            bstr[k--] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }
        return string(bstr);
    }
}

contract DloopToken is CustomERC721Metadata, ERC721Enumerable, DloopMintable {

    constructor(string memory baseURI)
        public
        CustomERC721Metadata("dloop Art Registry", "DART", baseURI)
    {
    }

    function setBaseURI(string memory baseURI)
        public
        onlyMinter
        returns (bool)
    {

        super._setBaseURI(baseURI);
        return true;
    }
}