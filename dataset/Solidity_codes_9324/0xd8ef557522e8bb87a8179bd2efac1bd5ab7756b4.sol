

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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

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


pragma solidity ^0.5.0;


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

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.5.0;








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


pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


pragma solidity ^0.5.0;





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


pragma solidity ^0.5.0;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.5.0;





contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {

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

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
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


pragma solidity ^0.5.15;

contract IENSRegistry {

    function setOwner(bytes32 node, address owner) public;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public;

    function setResolver(bytes32 node, address resolver) public;

    function owner(bytes32 node) public view returns (address);

    function resolver(bytes32 node) public view returns (address);

}


pragma solidity ^0.5.15;

contract IENSResolver {

    function setAddr(bytes32 node, address addr) public;


    function addr(bytes32 node) public view returns (address);

}


pragma solidity ^0.5.15;

contract IBaseRegistrar {

    function register(uint256 id, address owner, uint duration) external returns(uint);


    function renew(uint256 id, uint duration) external returns(uint);


    function reclaim(uint256 id, address owner) external;


    function transferFrom(address from, address to, uint256 id) public;


}


pragma solidity ^0.5.2;

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


pragma solidity ^0.5.15;


contract IERC20Token is IERC20{

    function balanceOf(address from) public view returns (uint256);

    function transferFrom(address from, address to, uint tokens) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function burn(uint256 amount) public;

}


pragma solidity ^0.5.15;









contract DCLRegistrar is ERC721Full, Ownable {

    using Address for address;
    bytes4 public constant ERC721_RECEIVED = 0x150b7a02;

    IENSRegistry public registry;
    IBaseRegistrar public base;

    mapping(address => bool) public controllers;

    bytes32 emptyNamehash = 0x00;
    string public topdomain;
    string public domain;
    bytes32 public topdomainNameHash;
    bytes32 public domainNameHash;
    string public baseURI;

    bool public migrated;

    mapping (bytes32 => string) public subdomains;

    event NameRegistered(
        address indexed _caller,
        address indexed _beneficiary,
        bytes32 indexed _labelHash,
        string _subdomain,
        uint256 _createdDate
    );
    event Reclaimed(address indexed _caller, address indexed _owner, uint256 indexed  _tokenId);
    event DomainReclaimed(uint256 indexed _tokenId);
    event DomainTransferred(address indexed _newOwner, uint256 indexed _tokenId);

    event RegistryUpdated(IENSRegistry indexed _previousRegistry, IENSRegistry indexed _newRegistry);
    event BaseUpdated(IBaseRegistrar indexed _previousBase, IBaseRegistrar indexed _newBase);

    event ControllerAdded(address indexed _controller);
    event ControllerRemoved(address indexed _controller);

    event MigrationFinished();

    event BaseURI(string _oldBaseURI, string _newBaseURI);


    modifier onlyController() {

        require(controllers[msg.sender], "Only a controller can call this method");
        _;
    }

    modifier isNotMigrated() {

        require(!migrated, "The migration has finished");
        _;
    }

    modifier isMigrated() {

        require(migrated, "The migration has not finished");
        _;
    }

    constructor(
        IENSRegistry _registry,
        IBaseRegistrar _base,
        string memory _topdomain,
        string memory _domain,
        string memory _baseURI
    ) public ERC721Full("DCL Registrar", "DCLENS") {
        updateRegistry(_registry);
        updateBase(_base);

        require(bytes(_topdomain).length > 0, "Top domain can not be empty");
        topdomain = _topdomain;

        require(bytes(_domain).length > 0, "Domain can not be empty");
        domain = _domain;

        topdomainNameHash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(topdomain))));
        domainNameHash = keccak256(abi.encodePacked(topdomainNameHash, keccak256(abi.encodePacked(domain))));

        updateBaseURI(_baseURI);
    }

    function migrateNames(
        bytes32[] calldata _names,
        address[] calldata _beneficiaries,
        uint256[] calldata _createdDates
    ) external onlyOwner isNotMigrated {

        for (uint256 i = 0; i < _names.length; i++) {
            string memory name = _bytes32ToString(_names[i]);
            _register(
                name,
                keccak256(abi.encodePacked(_toLowerCase(name))),
                _beneficiaries[i],
                _createdDates[i]
            );
        }
    }

    function register(
        string calldata _subdomain,
        address _beneficiary
    ) external onlyController isMigrated {

        require(registry.owner(domainNameHash) == address(this), "The contract does not own the domain");
        bytes32 subdomainLabelHash = keccak256(abi.encodePacked(_toLowerCase(_subdomain)));
        require(_available(subdomainLabelHash), "Subdomain already owned");
        _register(_subdomain, subdomainLabelHash, _beneficiary, now);
    }

    function _register(
        string memory _subdomain,
        bytes32 subdomainLabelHash,
        address _beneficiary,
        uint256 _createdDate
    ) internal {

        registry.setSubnodeOwner(domainNameHash, subdomainLabelHash, _beneficiary);
        _mint(_beneficiary, uint256(subdomainLabelHash));
        subdomains[subdomainLabelHash] = _subdomain;
        emit NameRegistered(msg.sender, _beneficiary, subdomainLabelHash, _subdomain, _createdDate);
    }

    function reclaim(uint256 _tokenId, address _owner) public {

        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "Only an authorized account can change the subdomain settings"
        );

        registry.setSubnodeOwner(domainNameHash, bytes32(_tokenId), _owner);

        emit Reclaimed(msg.sender, _owner, _tokenId);
    }

    function onERC721Received(
        address /* _operator */,
        address /* _from */,
        uint256 _tokenId,
        bytes memory /* _data */
    )
        public
        returns (bytes4)
    {

        require(msg.sender == address(base), "Only base can send NFTs to this contract");

        base.reclaim(_tokenId, address(this));
        return ERC721_RECEIVED;
    }

    function available(string memory _subdomain) public view returns (bool) {

        bytes32 subdomainLabelHash = keccak256(abi.encodePacked(_toLowerCase(_subdomain)));
        return _available(subdomainLabelHash);
    }


    function _available(bytes32 _subdomainLabelHash) internal view returns (bool) {

        bytes32 subdomainNameHash = keccak256(abi.encodePacked(domainNameHash, _subdomainLabelHash));
        return registry.owner(subdomainNameHash) == address(0) && !_exists(uint256(_subdomainLabelHash));
    }

    function getTokenId(string memory _subdomain) public view returns (uint256) {

        string memory subdomain = _toLowerCase(_subdomain);
        bytes32 subdomainLabelHash = keccak256(abi.encodePacked(subdomain));
        uint256 tokenId = uint256(subdomainLabelHash);

        require(
            _exists(tokenId),
            "The subdomain is not registered"
        );

        return tokenId;
    }

    function getOwnerOf(string memory _subdomain) public view returns (address) {

        return ownerOf(getTokenId(_subdomain));
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {

        if (bytes(baseURI).length == 0) {
            return "";
        }

        require(_exists(_tokenId), "ERC721Metadata: received a URI query for a nonexistent token");
        return string(abi.encodePacked(baseURI, _toLowerCase(subdomains[bytes32(_tokenId)])));
    }

    function reclaimDomain(uint256 _tokenId) public onlyOwner {

        base.reclaim(_tokenId, address(this));

        emit DomainReclaimed(_tokenId);
    }

    function transferDomainOwnership(address _owner, uint256 _tokenId) public onlyOwner {

        base.transferFrom(address(this), _owner, _tokenId);
        emit DomainTransferred(_owner, _tokenId);
    }

    function addController(address controller) external onlyOwner {

        require(!controllers[controller], "The controller was already added");
        controllers[controller] = true;
        emit ControllerAdded(controller);
    }

    function removeController(address controller) external onlyOwner {

        require(controllers[controller], "The controller is already disabled");
        controllers[controller] = false;
        emit ControllerRemoved(controller);
    }

    function updateRegistry(IENSRegistry _registry) public onlyOwner {

        require(registry != _registry, "New registry should be different from old");
        require(address(_registry).isContract(), "New registry should be a contract");

        emit RegistryUpdated(registry, _registry);

        registry = _registry;
    }

    function updateBase(IBaseRegistrar _base) public onlyOwner {

        require(base != _base, "New base should be different from old");
        require(address(_base).isContract(), "New base should be a contract");

        emit BaseUpdated(base, _base);

        base = _base;
    }

    function updateBaseURI(string memory _baseURI) public onlyOwner {

        require(
            keccak256(abi.encodePacked((baseURI))) != keccak256(abi.encodePacked((_baseURI))),
            "Base URI should be different from old"
        );
        emit BaseURI(baseURI, _baseURI);
        baseURI = _baseURI;
    }

    function migrationFinished() external onlyOwner isNotMigrated {

        migrated = true;
        emit MigrationFinished();
    }

    function _bytes32ToString(bytes32 _x) internal pure returns (string memory) {

        uint256 charCount = 0;
        for (uint256 j = 0; j <= 256; j += 8) {
            byte char = byte(_x << j);
            if (char == 0) {
                break;
            }
            charCount++;
        }

        string memory out = new string(charCount);

        assembly {
            mstore(add(0x20, out), _x)
        }

        return out;
    }

    function _toLowerCase(string memory _str) internal pure returns (string memory) {

        bytes memory bStr = bytes(_str);
        bytes memory bLower = new bytes(bStr.length);

        for (uint i = 0; i < bStr.length; i++) {
            if ((bStr[i] >= 0x41) && (bStr[i] <= 0x5A)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 0x20);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}