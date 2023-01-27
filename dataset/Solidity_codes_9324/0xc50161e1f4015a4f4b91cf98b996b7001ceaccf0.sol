pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}
pragma solidity ^0.5.0;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);


    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}
pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}
pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}
pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
pragma solidity ^0.5.0;


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

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}
pragma solidity ^0.5.0;


contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => uint256) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner] = _ownedTokensCount[owner].sub(1);
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}
pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}
pragma solidity ^0.5.0;


contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply());
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
pragma solidity ^0.5.0;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}
pragma solidity ^0.5.0;


contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
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

        require(_exists(tokenId));
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId));
        _tokenURIs[tokenId] = uri;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
pragma solidity ^0.5.0;


contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
    }
}
pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
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

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}

pragma solidity ^0.5.0;

library strings {

    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function toSlice(string memory self) internal pure returns (slice memory) {

        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function concat(slice memory self, slice memory other) internal pure returns (string memory) {

        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly {
            retptr := add(ret, 32)
        }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }
}
pragma solidity ^0.5.0;


contract Metadata {

    using strings for *;

    function tokenURI(uint _tokenId) public pure returns (string memory _infoUrl) {

        string memory base = "https://folia.app/v1/metadata/";
        string memory id = uint2str(_tokenId);
        return base.toSlice().concat(id.toSlice());
    }
    function uint2str(uint i) internal pure returns (string memory) {

        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0) {
            uint _uint = 48 + i % 10;
            bstr[k--] = toBytes(_uint)[31];
            i /= 10;
        }
        return string(bstr);
    }
    function toBytes(uint256 x) public pure returns (bytes memory b) {

        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }
}
pragma solidity ^0.5.0;



contract Folia is ERC721Full, Ownable {

    using Roles for Roles.Role;
    Roles.Role private _admins;
    uint8 admins;

    address public metadata;
    address public controller;

    modifier onlyAdminOrController() {

        require((_admins.has(msg.sender) || msg.sender == controller), "DOES_NOT_HAVE_ADMIN_OR_CONTROLLER_ROLE");
        _;
    }

    constructor(string memory name, string memory symbol, address _metadata) public ERC721Full(name, symbol) {
        metadata = _metadata;
        _admins.add(msg.sender);
        admins += 1;
    }

    function mint(address recepient, uint256 tokenId) public onlyAdminOrController {

        _mint(recepient, tokenId);
    }
    function burn(uint256 tokenId) public onlyAdminOrController {

        _burn(ownerOf(tokenId), tokenId);
    }
    function updateMetadata(address _metadata) public onlyAdminOrController {

        metadata = _metadata;
    }
    function updateController(address _controller) public onlyAdminOrController {

        controller = _controller;
    }

    function addAdmin(address _admin) public onlyOwner {

        _admins.add(_admin);
        admins += 1;
    }
    function removeAdmin(address _admin) public onlyOwner {

        require(admins > 1, "CANT_REMOVE_LAST_ADMIN");
        _admins.remove(_admin);
        admins -= 1;
    }

    function tokenURI(uint _tokenId) external view returns (string memory _infoUrl) {

        return Metadata(metadata).tokenURI(_tokenId);
    }

    function moveEth(address payable _to, uint256 _amount) public onlyAdminOrController {

        require(_amount <= address(this).balance);
        _to.transfer(_amount);
    }
    function moveToken(address _to, uint256 _amount, address _token) public onlyAdminOrController returns (bool) {

        require(_amount <= IERC20(_token).balanceOf(address(this)));
        return IERC20(_token).transfer(_to, _amount);
    }

}
pragma solidity ^0.5.0;


contract Decomposer is Folia {

    constructor(address _metadata) public Folia("Decomposer", "DCMP", _metadata){}
}
pragma solidity ^0.5.0;

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}
pragma solidity ^0.5.0;


interface Punk {

      function punkIndexToAddress(uint256 tokenId) external view returns (address owner);

}

contract DecomposerController is Ownable, ReentrancyGuard {


    using SafeMath for uint256;

    event newContract(address contractAddress, uint256 maxEditions, cT contractType);
    event deletedContract(address contractAddress);
    event editionBought(address contractAddress, uint256 tokenId, uint256 newTokenId);
    uint256 public price = 8 * (10**16); // 0.08 Eth
    uint256 public totalMax = 888;
    mapping(address => uint256) public editionsLeft;

    Decomposer public decomposer;

    uint256 public adminSplit = 20;
    address payable public adminWallet;
    address payable public artistWallet;
    bool public paused;

    modifier notPaused() {

        require(!paused, "Must not be paused");
        _;
    }

    constructor(
        Decomposer _decomposer,
        address payable _adminWallet
    ) public {
        decomposer = _decomposer;
        adminWallet = _adminWallet;
        uint256 _maxEditions = 88;

        addContract(0xB77F0b25aF126FCE0ea41e5696F1E5e9102E1D77, _maxEditions, uint8(cT.ERC721)); // 3Words
        addContract(0x123b30E25973FeCd8354dd5f41Cc45A3065eF88C, _maxEditions, uint8(cT.ERC721)); // Alien Frens
        addContract(0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270, _maxEditions, uint8(cT.ERC721)); // Apparitions by Aaron Penne
        addContract(0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270, _maxEditions, uint8(cT.ERC721)); // Archetype by Kjetil Golid
        addContract(0x842D8B7B08C154ADc36A4f1186A0f401a10518EA, _maxEditions, uint8(cT.ERC721)); // Autobreeder (lite) by Harm van den Dorpel 
        addContract(0xDFAcD840f462C27b0127FC76b63e7925bEd0F9D5, _maxEditions, uint8(cT.ERC721)); // Avid Lines
        addContract(0xED5AF388653567Af2F388E6224dC7C4b3241C544, _maxEditions, uint8(cT.ERC721)); // Azuki
        addContract(0x8d04a8c79cEB0889Bdd12acdF3Fa9D207eD3Ff63, _maxEditions, uint8(cT.ERC721)); // Blitmap
        addContract(0xba30E5F9Bb24caa003E9f2f0497Ad287FDF95623, _maxEditions, uint8(cT.ERC721)); // Bored Ape Kennel Club
        addContract(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D, _maxEditions, uint8(cT.ERC721)); // Bored Ape Yacht Club
        addContract(0xfcB1315C4273954F74Cb16D5b663DBF479EEC62e, _maxEditions, uint8(cT.ERC721)); // Capsule House
        addContract(0x059EDD72Cd353dF5106D2B9cC5ab83a52287aC3a, _maxEditions, uint8(cT.ERC721)); // Chromie Squiggle by Snowfro
        addContract(0x91Fba69Ce5071Cf9e828999a0F6006A7F7E2a959, _maxEditions, uint8(cT.ERC721)); // CLASSIFIED | Holly Herndon
        addContract(0x49cF6f5d44E70224e2E23fDcdd2C053F30aDA28B, _maxEditions, uint8(cT.ERC721)); // CLONE X - X TAKASHI MURAKAMI
        addContract(0x1A92f7381B9F03921564a437210bB9396471050C, _maxEditions, uint8(cT.ERC721)); // Cool Cats NFT
        addContract(0xc92cedDfb8dd984A89fb494c376f9A48b999aAFc, _maxEditions, uint8(cT.ERC721)); // Creature World
        addContract(0x1CB1A5e65610AEFF2551A50f76a87a7d3fB649C6, _maxEditions, uint8(cT.ERC721)); // CrypToadz by GREMPLIN
        addContract(0xBACe7E22f06554339911A03B8e0aE28203Da9598, _maxEditions, uint8(cT.ERC721exception)); // CryptoArte
        addContract(0xF7a6E15dfD5cdD9ef12711Bd757a9b6021ABf643, _maxEditions, uint8(cT.ERC721exception)); // CryptoBots
        addContract(0x1981CC36b59cffdd24B01CC5d698daa75e367e04, _maxEditions, uint8(cT.ERC721)); // Crypto.Chicks
        addContract(0x5180db8F5c931aaE63c74266b211F580155ecac8, _maxEditions, uint8(cT.ERC721)); // Crypto Coven
        addContract(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d, _maxEditions, uint8(cT.ERC721exception)); // CryptoKitties
        addContract(0x57a204AA1042f6E66DD7730813f4024114d74f37, _maxEditions, uint8(cT.ERC721)); // CyberKongz
        addContract(0xc1Caf0C19A8AC28c41Fe59bA6c754e4b9bd54dE9, _maxEditions, uint8(cT.ERC721)); // CryptoSkulls
        addContract(0xF87E31492Faf9A91B02Ee0dEAAd50d51d56D5d4d, _maxEditions, uint8(cT.ERC721)); // Decentraland
        addContract(0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e, _maxEditions, uint8(cT.ERC721)); // Doodles
        addContract(0x6CA044FB1cD505c1dB4eF7332e73a236aD6cb71C, _maxEditions, uint8(cT.ERC721)); // DotCom Seance
        addContract(0x4721D66937B16274faC603509E9D61C5372Ff220, _maxEditions, uint8(cT.ERC721)); // Fast Food Frens Collection
        addContract(0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270, _maxEditions, uint8(cT.ERC721)); // Fidenza by Tyler Hobbs
        addContract(0x90cfCE78f5ED32f9490fd265D16c77a8b5320Bd4, _maxEditions, uint8(cT.ERC721)); // FOMO Dog Club
        addContract(0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270, _maxEditions, uint8(cT.ERC721)); // Fragments of an Infinite Field by Monica Rizzolli
        addContract(0xC2C747E0F7004F9E8817Db2ca4997657a7746928, _maxEditions, uint8(cT.ERC721)); // Hashmasks
        addContract(0x0c2E57EFddbA8c768147D1fdF9176a0A6EBd5d83, _maxEditions, uint8(cT.ERC721)); // Kaiju Kingz
        addContract(0x9d413B9434c20C73f509505F7fbC6FC591bbf04A, _maxEditions, uint8(cT.ERC721)); // Kudzu
        addContract(0x8943C7bAC1914C9A7ABa750Bf2B6B09Fd21037E0, _maxEditions, uint8(cT.ERC721)); // Lazy Lions
        addContract(0x026224A2940bFE258D0dbE947919B62fE321F042, _maxEditions, uint8(cT.ERC721)); // lobsterdao
        addContract(0x4b3406a41399c7FD2BA65cbC93697Ad9E7eA61e5, _maxEditions, uint8(cT.ERC721)); // LOSTPOETS
        addContract(0x7Bd29408f11D2bFC23c34f18275bBf23bB716Bc7, _maxEditions, uint8(cT.ERC721)); // Meebits
        addContract(0xF7143Ba42d40EAeB49b88DaC0067e54Af042E963, _maxEditions, uint8(cT.ERC721)); // Metasaurs by Dr. DMT
        addContract(0xc3f733ca98E0daD0386979Eb96fb1722A1A05E69, _maxEditions, uint8(cT.ERC721)); // MoonCats
        addContract(0x60E4d786628Fea6478F785A6d7e704777c86a7c6, _maxEditions, uint8(cT.ERC721)); // Mutant Ape Yacht Club
        addContract(0x9C8fF314C9Bc7F6e59A9d9225Fb22946427eDC03, _maxEditions, uint8(cT.ERC721)); // Nouns
        addContract(0x4f89Cd0CAE1e54D98db6a80150a824a533502EEa, _maxEditions, uint8(cT.ERC721)); // PEACEFUL GROUPIES
        addContract(0x67D9417C9C3c250f61A83C7e8658daC487B56B09, _maxEditions, uint8(cT.ERC721)); // PhantaBear
        addContract(0x050dc61dFB867E0fE3Cf2948362b6c0F3fAF790b, _maxEditions, uint8(cT.ERC721)); // PixelMap
        addContract(0xBd3531dA5CF5857e7CfAA92426877b022e612cf8, _maxEditions, uint8(cT.ERC721)); // Pudgy Penguins
        addContract(0x51Ae5e2533854495f6c587865Af64119db8F59b4, _maxEditions, uint8(cT.ERC721)); // PunkScapes
        addContract(0x29b7315fc83172CFcb45c2Fb415E91A265fb73f2, _maxEditions, uint8(cT.ERC721)); // Realiti
        addContract(0x8CD3cEA52a45f30Ed7c93a63FB2b5C13B453d5A1, _maxEditions, uint8(cT.ERC721)); // Rebel Society
        addContract(0x3Fe1a4c1481c8351E91B64D5c398b159dE07cbc5, _maxEditions, uint8(cT.ERC721)); // SupDucks
        addContract(0xF4ee95274741437636e748DdAc70818B4ED7d043, _maxEditions, uint8(cT.ERC721)); // The Doge Pound
        addContract(0x5CC5B05a8A13E3fBDB0BB9FcCd98D38e50F90c38, _maxEditions, uint8(cT.ERC721)); // The Sandbox
        addContract(0x11450058d796B02EB53e65374be59cFf65d3FE7f, _maxEditions, uint8(cT.ERC721)); // THE SHIBOSHIS
        addContract(0x7f7685b4CC34BD19E2B712D8a89f34D219E76c35, _maxEditions, uint8(cT.ERC721)); // WomenRise
        addContract(0xe785E82358879F061BC3dcAC6f0444462D4b5330, _maxEditions, uint8(cT.ERC721)); // World of Women
        addContract(0xB67812ce508b9fC190740871032237C24b6896A0, _maxEditions, uint8(cT.ERC721)); // WoW Pixies Official
        addContract(0xd0e7Bc3F1EFc5f098534Bce73589835b8273b9a0, _maxEditions, uint8(cT.ERC721)); // Wrapped CryptoCats Official
        addContract(0x6f9d53BA6c16fcBE66695E860e72a92581b58Aed, _maxEditions, uint8(cT.ERC721)); // Wrapped Pixereum
        

        addContract(0xDCe09254dD3592381b6A5b7a848B29890b656e01, _maxEditions, uint8(cT.Folia)); // Emoji Script by Travess Smalley (work 2)

        addContract(0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB, _maxEditions, uint8(cT.Punk)); // CryptoPunks
    }

    enum cT {ERC721, Punk, Folia, ERC721exception}
    struct ContractInfo {
      cT _cT;
      uint256 editionsLeft;
    }
    mapping(address => ContractInfo) public aC;

    function addContract(address contractAddress, uint256 maxEditions, uint8 _cT ) public onlyOwner {

      
      if (_cT == uint8(cT.ERC721)) {
        require(IERC165(contractAddress).supportsInterface(0x80ac58cd), "Not an ERC721");
      } else {
        require(_cT == uint8(cT.Punk) || _cT == uint8(cT.Folia) || _cT == uint8(cT.ERC721exception), "Unknown contractType");
      }

      aC[contractAddress]._cT = cT(_cT);
      aC[contractAddress].editionsLeft = maxEditions;
      emit newContract(contractAddress, maxEditions, cT(_cT));
    }
    
    function removeContract(address contractAddress) public onlyOwner {

      delete aC[contractAddress];
      emit deletedContract(contractAddress);
    }

    function updateArtworkPrice(uint256 _price) public onlyOwner {

      price = _price;
    }

    function updateArtistWallet(address payable _artistWallet) public onlyOwner {

      artistWallet = _artistWallet;
    }

    function updateTotalMax(uint256 _totalMax) public onlyOwner {

      totalMax = _totalMax;
    }

    function buy(address recipient, address contractAddress, uint256 tokenId) public payable notPaused nonReentrant returns(bool) {

        require(aC[contractAddress].editionsLeft != 0, "Wrong Contract or No Editions Left");
        aC[contractAddress].editionsLeft -= 1;

        require(msg.value == price, "Wrong price paid");

        if (aC[contractAddress]._cT == cT.Punk) {
          require(Punk(contractAddress).punkIndexToAddress(tokenId) == msg.sender, "Can't mint a token you don't own");
        } else if (aC[contractAddress]._cT == cT.ERC721 || aC[contractAddress]._cT == cT.ERC721exception) {
          require(IERC721(contractAddress).ownerOf(tokenId) == msg.sender, "Can't mint a token you don't own");
        } else if (aC[contractAddress]._cT == cT.Folia) {
          require(tokenId >= 2000000 && tokenId <= 2000500, "Can't mint this Folia token");

          require(IERC721(contractAddress).ownerOf(tokenId) == msg.sender, "Can't mint a token you don't own");
        }

        uint256 newTokenId = uint256(keccak256(abi.encodePacked(contractAddress, tokenId)));
        decomposer.mint(recipient, newTokenId);

        uint256 adminReceives = msg.value.mul(adminSplit).div(100);
        uint256 artistReceives = msg.value.sub(adminReceives);

        (bool success, ) = adminWallet.call.value(adminReceives)("");
        require(success, "admin failed to receive");

        (success, ) = artistWallet.call.value(artistReceives)("");
        require(success, "artist failed to receive");

        emit editionBought(contractAddress, tokenId, newTokenId);
    }

    function updateAdminSplit(uint256 _adminSplit) public onlyOwner {

        require(_adminSplit <= 100, "SPLIT_MUST_BE_LTE_100");
        adminSplit = _adminSplit;
    }

    function updateAdminWallet(address payable _adminWallet) public onlyOwner {

        adminWallet = _adminWallet;
    }

    function updatePaused(bool _paused) public onlyOwner {

        paused = _paused;
    }
}
pragma solidity ^0.5.0;


contract DecomposerMetadata is Metadata {

    function tokenURI(uint _tokenId) public pure returns (string memory _infoUrl) {

        string memory base = "https://decomposer.folia.app/v1/metadata/";
        string memory id = uint2str(_tokenId);
        return base.toSlice().concat(id.toSlice());
    }
}
