

pragma solidity 0.5.14;

contract AvastarTypes {


    enum Generation {
        ONE,
        TWO,
        THREE,
        FOUR,
        FIVE
    }

    enum Series {
        PROMO,
        ONE,
        TWO,
        THREE,
        FOUR,
        FIVE
    }

    enum Wave {
        PRIME,
        REPLICANT
    }

    enum Gene {
        SKIN_TONE,
        HAIR_COLOR,
        EYE_COLOR,
        BG_COLOR,
        BACKDROP,
        EARS,
        FACE,
        NOSE,
        MOUTH,
        FACIAL_FEATURE,
        EYES,
        HAIR_STYLE
    }

    enum Gender {
        ANY,
        MALE,
        FEMALE
    }

    enum Rarity {
        COMMON,
        UNCOMMON,
        RARE,
        EPIC,
        LEGENDARY
    }

    struct Trait {
        uint256 id;
        Generation generation;
        Gender gender;
        Gene gene;
        Rarity rarity;
        uint8 variation;
        Series[] series;
        string name;
        string svg;

    }

    struct Prime {
        uint256 id;
        uint256 serial;
        uint256 traits;
        bool[12] replicated;
        Generation generation;
        Series series;
        Gender gender;
        uint8 ranking;
    }

    struct Replicant {
        uint256 id;
        uint256 serial;
        uint256 traits;
        Generation generation;
        Gender gender;
        uint8 ranking;
    }

    struct Avastar {
        uint256 id;
        uint256 serial;
        uint256 traits;
        Generation generation;
        Wave wave;
    }

    struct Attribution {
        Generation generation;
        string artist;
        string infoURI;
    }

}


pragma solidity 0.5.14;

contract AvastarBase {


    function uintToStr(uint _i)
    internal pure
    returns (string memory result) {

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
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        result = string(bstr);
    }

    function strConcat(string memory _a, string memory _b)
    internal pure
    returns(string memory result) {

        result = string(abi.encodePacked(bytes(_a), bytes(_b)));
    }

}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
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


pragma solidity 0.5.14;



contract AccessControl {


    using SafeMath for uint256;
    using SafeMath for uint16;
    using Roles for Roles.Role;

    Roles.Role private admins;
    Roles.Role private minters;
    Roles.Role private owners;

    constructor() public {
        admins.add(msg.sender);
    }

    event ContractPaused();

    event ContractUnpaused();

    event ContractUpgrade(address newContract);


    bool public paused = true;
    bool public upgraded = false;
    address public newContractAddress;

    modifier onlyMinter() {

        require(minters.has(msg.sender));
        _;
    }

    modifier onlyOwner() {

        require(owners.has(msg.sender));
        _;
    }

    modifier onlySysAdmin() {

        require(admins.has(msg.sender));
        _;
    }

    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused() {

        require(paused);
        _;
    }

    modifier whenNotUpgraded() {

        require(!upgraded);
        _;
    }

    function upgradeContract(address _newAddress) external onlySysAdmin whenPaused whenNotUpgraded {

        require(_newAddress != address(0));
        upgraded = true;
        newContractAddress = _newAddress;
        emit ContractUpgrade(_newAddress);
    }

    function addMinter(address _minterAddress) external onlySysAdmin {

        minters.add(_minterAddress);
        require(minters.has(_minterAddress));
    }

    function addOwner(address _ownerAddress) external onlySysAdmin {

        owners.add(_ownerAddress);
        require(owners.has(_ownerAddress));
    }

    function addSysAdmin(address _sysAdminAddress) external onlySysAdmin {

        admins.add(_sysAdminAddress);
        require(admins.has(_sysAdminAddress));
    }

    function stripRoles(address _address) external onlyOwner {

        require(msg.sender != _address);
        bool stripped = false;
        if (admins.has(_address)) {
            admins.remove(_address);
            stripped = true;
        }
        if (minters.has(_address)) {
            minters.remove(_address);
            stripped = true;
        }
        if (owners.has(_address)) {
            owners.remove(_address);
            stripped = true;
        }
        require(stripped == true);
    }

    function pause() external onlySysAdmin whenNotPaused {

        paused = true;
        emit ContractPaused();
    }

    function unpause() external onlySysAdmin whenPaused whenNotUpgraded {

        paused = false;
        emit ContractUnpaused();
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


pragma solidity 0.5.14;





contract AvastarState is AvastarBase, AvastarTypes, AccessControl, ERC721Full {


    constructor() public ERC721Full(TOKEN_NAME, TOKEN_SYMBOL) {}

    string public constant TOKEN_NAME = "Avastar";
    string public constant TOKEN_SYMBOL = "AVASTAR";

    Avastar[] internal avastars;

    Trait[] internal traits;

    mapping(uint8 => Prime[]) internal primesByGeneration;

    mapping(uint8 => Replicant[]) internal replicantsByGeneration;

    mapping(uint8 => Attribution) public attributionByGeneration;

    mapping(uint256 => address) internal traitHandlerByPrimeTokenId;

    mapping(uint8 => mapping(uint256 => bool)) public isHashUsedByGeneration;

    mapping(uint8 => mapping(uint256 => uint256)) public tokenIdByGenerationAndHash;

    mapping(uint8 =>  mapping(uint8 => uint16)) public primeCountByGenAndSeries;

    mapping(uint8 => uint16) public replicantCountByGeneration;

    mapping(uint8 => mapping(uint8 => mapping(uint256 => uint256))) public tokenIdByGenerationWaveAndSerial;

    mapping(uint8 => mapping(uint8 => mapping(uint8 => uint256))) public traitIdByGenerationGeneAndVariation;

}


pragma solidity 0.5.14;


contract TraitFactory is AvastarState {


    event NewTrait(uint256 id, Generation generation, Gene gene, Rarity rarity, uint8 variation, string name);

    event AttributionSet(Generation generation, string artist, string infoURI);

    event TraitArtExtended(uint256 id);

    modifier onlyBeforeProd(Generation _generation) {

        require(primesByGeneration[uint8(_generation)].length == 0 && replicantsByGeneration[uint8(_generation)].length == 0);
        _;
    }

    function getTraitIdByGenerationGeneAndVariation(
        Generation _generation,
        Gene _gene,
        uint8 _variation
    )
    external view
    returns (uint256 traitId)
    {

        return traitIdByGenerationGeneAndVariation[uint8(_generation)][uint8(_gene)][_variation];
    }

    function getTraitInfoById(uint256 _traitId)
    external view
    returns (
        uint256 id,
        Generation generation,
        Series[] memory series,
        Gender gender,
        Gene gene,
        Rarity rarity,
        uint8 variation,
        string memory name
    ) {

        require(_traitId < traits.length);
        Trait memory trait = traits[_traitId];
        return (
            trait.id,
            trait.generation,
            trait.series,
            trait.gender,
            trait.gene,
            trait.rarity,
            trait.variation,
            trait.name
        );
    }

    function getTraitNameById(uint256 _traitId)
    external view
    returns (string memory name) {

        require(_traitId < traits.length);
        name = traits[_traitId].name;
    }

    function getTraitArtById(uint256 _traitId)
    external view onlySysAdmin
    returns (string memory art) {

        require(_traitId < traits.length);
        Trait memory trait = traits[_traitId];
        art = trait.svg;
    }

    function getAttributionByGeneration(Generation _generation)
    external view
    returns (
        string memory attribution
    ){

        Attribution memory attrib = attributionByGeneration[uint8(_generation)];
        require(bytes(attrib.artist).length > 0);
        attribution = strConcat(attribution, attrib.artist);
        attribution = strConcat(attribution, ' (');
        attribution = strConcat(attribution, attrib.infoURI);
        attribution = strConcat(attribution, ')');
    }

    function setAttribution(
        Generation _generation,
        string calldata _artist,
        string calldata _infoURI
    )
    external onlySysAdmin onlyBeforeProd(_generation)
    {

        require(bytes(_artist).length > 0 && bytes(_infoURI).length > 0);
        attributionByGeneration[uint8(_generation)] = Attribution(_generation, _artist, _infoURI);
        emit AttributionSet(_generation, _artist, _infoURI);
    }

    function createTrait(
        Generation _generation,
        Series[] calldata _series,
        Gender _gender,
        Gene _gene,
        Rarity _rarity,
        uint8 _variation,
        string calldata _name,
        string calldata _svg
    )
    external onlySysAdmin whenNotPaused onlyBeforeProd(_generation)
    returns (uint256 traitId)
    {

        require(_series.length > 0);
        require(bytes(_name).length > 0);
        require(bytes(_svg).length > 0);

        traitId = traits.length;

        traits.push(
            Trait(traitId, _generation, _gender, _gene, _rarity, _variation,  _series, _name, _svg)
        );

        traitIdByGenerationGeneAndVariation[uint8(_generation)][uint8(_gene)][uint8(_variation)] = traitId;

        emit NewTrait(traitId, _generation, _gene, _rarity, _variation, _name);

        return traitId;
    }

    function extendTraitArt(uint256 _traitId, string calldata _svg)
    external onlySysAdmin whenNotPaused onlyBeforeProd(traits[_traitId].generation)
    {

        require(_traitId < traits.length);
        string memory art = strConcat(traits[_traitId].svg, _svg);
        traits[_traitId].svg = art;
        emit TraitArtExtended(_traitId);
    }

    function assembleArtwork(Generation _generation, uint256 _traitHash)
    internal view
    returns (string memory svg)
    {

        require(_traitHash > 0);
        string memory accumulator = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" height="1000px" width="1000px" viewBox="0 0 1000 1000">';
        uint256 slotConst = 256;
        uint256 slotMask = 255;
        uint256 bitMask;
        uint256 slottedValue;
        uint256 slotMultiplier;
        uint256 variation;
        uint256 traitId;
        Trait memory trait;

        for (uint8 slot = 0; slot <= uint8(Gene.HAIR_STYLE); slot++){
            slotMultiplier = uint256(slotConst**slot);  // Create slot multiplier
            bitMask = slotMask * slotMultiplier;        // Create bit mask for slot
            slottedValue = _traitHash & bitMask;        // Extract slotted value from hash
            if (slottedValue > 0) {
                variation = (slot > 0)                  // Extract variation from slotted value
                    ? slottedValue / slotMultiplier
                    : slottedValue;
                if (variation > 0) {
                    traitId = traitIdByGenerationGeneAndVariation[uint8(_generation)][slot][uint8(variation)];
                    trait = traits[traitId];
                    accumulator = strConcat(accumulator, trait.svg);
                }
            }
        }

        return strConcat(accumulator, '</svg>');
    }

}


pragma solidity 0.5.14;


contract AvastarFactory is TraitFactory {


    function mintAvastar(
        address _owner,
        uint256 _serial,
        uint256 _traits,
        Generation _generation,
        Wave _wave
    )
    internal whenNotPaused
    returns (uint256 tokenId)
    {

        require(tokenIdByGenerationWaveAndSerial[uint8(_generation)][uint8(_wave)][_serial] == 0);

        if (_wave == Wave.PRIME){
            require(_serial == primesByGeneration[uint8(_generation)].length);
        } else {
            require(_serial == replicantsByGeneration[uint8(_generation)].length);
        }

        tokenId = avastars.length;

        Avastar memory avastar = Avastar(tokenId, _serial, _traits, _generation, _wave);

        avastars.push(avastar);

        isHashUsedByGeneration[uint8(avastar.generation)][avastar.traits] = true;

        tokenIdByGenerationAndHash[uint8(avastar.generation)][avastar.traits] = avastar.id;

        tokenIdByGenerationWaveAndSerial[uint8(avastar.generation)][uint8(avastar.wave)][avastar.serial] = avastar.id;

        super._mint(_owner, tokenId);
    }

    function getAvastarWaveByTokenId(uint256 _tokenId)
    external view
    returns (Wave wave)
    {

        require(_tokenId < avastars.length);
        wave = avastars[_tokenId].wave;
    }

    function renderAvastar(uint256 _tokenId)
    external view
    returns (string memory svg)
    {

        require(_tokenId < avastars.length);
        Avastar memory avastar = avastars[_tokenId];
        uint256 traits = (avastar.wave == Wave.PRIME)
        ? primesByGeneration[uint8(avastar.generation)][avastar.serial].traits
        : replicantsByGeneration[uint8(avastar.generation)][avastar.serial].traits;
        svg = assembleArtwork(avastar.generation, traits);
    }
}


pragma solidity 0.5.14;


contract PrimeFactory is AvastarFactory {


    uint16 public constant MAX_PRIMES_PER_SERIES = 5000;
    uint16 public constant MAX_PROMO_PRIMES_PER_GENERATION = 200;

    event NewPrime(uint256 id, uint256 serial, Generation generation, Series series, Gender gender, uint256 traits);

    function getPrimeByGenerationAndSerial(Generation _generation, uint256 _serial)
    external view
    returns (
        uint256 tokenId,
        uint256 serial,
        uint256 traits,
        Generation generation,
        Series series,
        Gender gender,
        uint8 ranking
    ) {

        require(_serial < primesByGeneration[uint8(_generation)].length);
        Prime memory prime = primesByGeneration[uint8(_generation)][_serial];
        return (
            prime.id,
            prime.serial,
            prime.traits,
            prime.generation,
            prime.series,
            prime.gender,
            prime.ranking
        );
    }

    function getPrimeByTokenId(uint256 _tokenId)
    external view
    returns (
        uint256 tokenId,
        uint256 serial,
        uint256 traits,
        Generation generation,
        Series series,
        Gender gender,
        uint8 ranking
    ) {

        require(_tokenId < avastars.length);
        Avastar memory avastar = avastars[_tokenId];
        require(avastar.wave ==  Wave.PRIME);
        Prime memory prime = primesByGeneration[uint8(avastar.generation)][avastar.serial];
        return (
            prime.id,
            prime.serial,
            prime.traits,
            prime.generation,
            prime.series,
            prime.gender,
            prime.ranking
        );
    }

    function getPrimeReplicationByTokenId(uint256 _tokenId)
    external view
    returns (
        uint256 tokenId,
        bool[12] memory replicated
    ) {

        require(_tokenId < avastars.length);
        Avastar memory avastar = avastars[_tokenId];
        require(avastar.wave ==  Wave.PRIME);
        Prime memory prime = primesByGeneration[uint8(avastar.generation)][avastar.serial];
        return (
            prime.id,
            prime.replicated
        );
    }

    function mintPrime(
        address _owner,
        uint256 _traits,
        Generation _generation,
        Series _series,
        Gender _gender,
        uint8 _ranking
    )
    external onlyMinter whenNotPaused
    returns (uint256 tokenId, uint256 serial)
    {

        require(_owner != address(0));
        require(_traits != 0);
        require(isHashUsedByGeneration[uint8(_generation)][_traits] == false);
        require(_ranking > 0 && _ranking <= 100);
        uint16 count = primeCountByGenAndSeries[uint8(_generation)][uint8(_series)];
        if (_series != Series.PROMO) {
            require(count < MAX_PRIMES_PER_SERIES);
        } else {
            require(count < MAX_PROMO_PRIMES_PER_GENERATION);
        }

        serial = primesByGeneration[uint8(_generation)].length;
        tokenId = mintAvastar(_owner, serial, _traits, _generation, Wave.PRIME);

        bool[12] memory replicated;
        primesByGeneration[uint8(_generation)].push(
            Prime(tokenId, serial, _traits, replicated, _generation, _series, _gender, _ranking)
        );

        primeCountByGenAndSeries[uint8(_generation)][uint8(_series)]++;

        emit NewPrime(tokenId, serial, _generation, _series, _gender, _traits);

        return (tokenId, serial);
    }

}


pragma solidity 0.5.14;


contract ReplicantFactory is PrimeFactory {


    uint16 public constant MAX_REPLICANTS_PER_GENERATION = 25200;

    event NewReplicant(uint256 id, uint256 serial, Generation generation, Gender gender, uint256 traits);

    function getReplicantByGenerationAndSerial(Generation _generation, uint256 _serial)
    external view
    returns (
        uint256 tokenId,
        uint256 serial,
        uint256 traits,
        Generation generation,
        Gender gender,
        uint8 ranking
    ) {

        require(_serial < replicantsByGeneration[uint8(_generation)].length);
        Replicant memory replicant = replicantsByGeneration[uint8(_generation)][_serial];
        return (
            replicant.id,
            replicant.serial,
            replicant.traits,
            replicant.generation,
            replicant.gender,
            replicant.ranking
        );
    }

    function getReplicantByTokenId(uint256 _tokenId)
    external view
    returns (
        uint256 tokenId,
        uint256 serial,
        uint256 traits,
        Generation generation,
        Gender gender,
        uint8 ranking
    ) {

        require(_tokenId < avastars.length);
        Avastar memory avastar = avastars[_tokenId];
        require(avastar.wave ==  Wave.REPLICANT);
        Replicant memory replicant = replicantsByGeneration[uint8(avastar.generation)][avastar.serial];
        return (
            replicant.id,
            replicant.serial,
            replicant.traits,
            replicant.generation,
            replicant.gender,
            replicant.ranking
        );
    }

    function mintReplicant(
        address _owner,
        uint256 _traits,
        Generation _generation,
        Gender _gender,
        uint8 _ranking
    )
    external onlyMinter whenNotPaused
    returns (uint256 tokenId, uint256 serial)
    {

        require(_traits != 0);
        require(isHashUsedByGeneration[uint8(_generation)][_traits] == false);
        require(_ranking > 0 && _ranking <= 100);
        require(replicantCountByGeneration[uint8(_generation)] < MAX_REPLICANTS_PER_GENERATION);

        serial = replicantsByGeneration[uint8(_generation)].length;
        tokenId = mintAvastar(_owner, serial, _traits, _generation, Wave.REPLICANT);

        replicantsByGeneration[uint8(_generation)].push(
            Replicant(tokenId, serial, _traits, _generation, _gender, _ranking)
        );

        replicantCountByGeneration[uint8(_generation)]++;

        emit NewReplicant(tokenId, serial, _generation, _gender, _traits);

        return (tokenId, serial);
    }

}


pragma solidity 0.5.14;

interface IAvastarMetadata {


    function isAvastarMetadata() external pure returns (bool);


    function tokenURI(uint _tokenId)
    external view
    returns (string memory uri);

}


pragma solidity 0.5.14;



contract AvastarTeleporter is ReplicantFactory {


    event TraitAccessApproved(address indexed handler, uint256[] primeIds);

    event TraitsUsed(address indexed handler, uint256 primeId, bool[12] used);

    event MetadataContractAddressSet(address contractAddress);

    address private metadataContractAddress;

    function isAvastarTeleporter() external pure returns (bool) {return true;}


    function setMetadataContractAddress(address _address)
    external onlySysAdmin whenPaused whenNotUpgraded
    {

        IAvastarMetadata candidateContract = IAvastarMetadata(_address);

        require(candidateContract.isAvastarMetadata());

        metadataContractAddress = _address;

        emit MetadataContractAddressSet(_address);
    }

    function getMetadataContractAddress()
    external view
    returns (address contractAddress) {

        return metadataContractAddress;
    }

    function tokenURI(uint _tokenId)
    external view
    returns (string memory uri)
    {

        require(_tokenId < avastars.length);
        return IAvastarMetadata(metadataContractAddress).tokenURI(_tokenId);
    }

    function approveTraitAccess(address _handler, uint256[] calldata _primeIds)
    external
    {

        require(_primeIds.length > 0 && _primeIds.length <= 256);
        uint256 primeId;
        bool approvedAtLeast1 = false;
        for (uint8 i = 0; i < _primeIds.length; i++) {
            primeId = _primeIds[i];
            require(primeId < avastars.length);
            require(msg.sender == super.ownerOf(primeId), "Must be token owner");
            if (traitHandlerByPrimeTokenId[primeId] != _handler) {
                traitHandlerByPrimeTokenId[primeId] = _handler;
                approvedAtLeast1 = true;
            }
        }
        require(approvedAtLeast1, "No unhandled primes specified");

        emit TraitAccessApproved(_handler, _primeIds);
    }

    function useTraits(uint256 _primeId, bool[12] calldata _traitFlags)
    external
    {

        require(_primeId < avastars.length);

        require(msg.sender == super.ownerOf(_primeId) || msg.sender == traitHandlerByPrimeTokenId[_primeId],
        "Must be token owner or approved handler" );

        Avastar memory avastar = avastars[_primeId];
        require(avastar.wave == Wave.PRIME);

        Prime storage prime = primesByGeneration[uint8(avastar.generation)][avastar.serial];

        bool usedAtLeast1;
        for (uint8 i = 0; i < 12; i++) {
            if (_traitFlags.length > i ) {
                if ( !prime.replicated[i] && _traitFlags[i] ) {
                    prime.replicated[i] = true;
                    usedAtLeast1 = true;
                }
            } else {
                break;
            }
        }

        require(usedAtLeast1, "No reusable traits specified");

        traitHandlerByPrimeTokenId[_primeId] = address(0);

        emit TraitsUsed(msg.sender, _primeId, prime.replicated);
    }

}