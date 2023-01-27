
pragma solidity ^0.5.0;
interface IERC165 {

function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
library SafeMath {

function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
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

    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    return c;
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
contract IERC721Receiver {

function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
public returns (bytes4);

}
pragma solidity ^0.5.0;
contract ERC721 is ERC165, IERC721 {

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
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
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

    require(to != msg.sender, "ERC721: approve to caller");
    _operatorApprovals[msg.sender][to] = approved;
    emit ApprovalForAll(msg.sender, to, approved);
}
function isApprovedForAll(address owner, address operator) public view returns (bool) {

    return _operatorApprovals[owner][operator];
}
function transferFrom(address from, address to, uint256 tokenId) public {

    require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
    _transferFrom(from, to, tokenId);
}
function safeTransferFrom(address from, address to, uint256 tokenId) public {

    safeTransferFrom(from, to, tokenId, "");
}
function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

    transferFrom(from, to, tokenId);
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
contract CustomERC721Metadata is ERC165, ERC721, ERC721Enumerable {

string private _name;
string private _symbol;
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
}
pragma solidity ^0.5.0;
library Strings {

function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {

    return strConcat(_a, _b, "", "", "");
}
function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {

    return strConcat(_a, _b, _c, "", "");
}
function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory _concatenatedString) {

    return strConcat(_a, _b, _c, _d, "");
}
function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {

    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    uint i = 0;
    for (i = 0; i < _ba.length; i++) {
        babcde[k++] = _ba[i];
    }
    for (i = 0; i < _bb.length; i++) {
        babcde[k++] = _bb[i];
    }
    for (i = 0; i < _bc.length; i++) {
        babcde[k++] = _bc[i];
    }
    for (i = 0; i < _bd.length; i++) {
        babcde[k++] = _bd[i];
    }
    for (i = 0; i < _be.length; i++) {
        babcde[k++] = _be[i];
    }
    return string(babcde);
}
function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

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
    return string(bstr);
}
}

pragma solidity ^0.5.0;
interface mirageContracts {

function balanceOf(address owner, uint256 _id) external view returns (uint256);

}
contract mirageCurated is CustomERC721Metadata {

using SafeMath for uint256;
event Mint(
    address indexed _to,
    uint256 indexed _tokenId,
    uint256 indexed _projectId
);
struct Project {
    string name;
    string artist;
    string description;
    string website;
    string license;
    string projectBaseURI;
    uint256 artworks;
    uint256 maxArtworks;
    uint256 maxEarly;
    bool publicActive;
    bool locked;
    bool paused;
    bool earlyActive;
}
uint256 constant TEN_THOUSAND = 10_000;
mapping(uint256 => Project) projects;
mapping(uint256 => address) public projectIdToArtistAddress;
mapping(uint256 => string) public projectIdToCurrencySymbol;
mapping(uint256 => address) public projectIdToCurrencyAddress;
mapping(uint256 => uint256) public projectIdToPricePerTokenInWei;
mapping(uint256 => address) public projectIdToAdditionalPayee;
mapping(uint256 => uint256) public projectIdToAdditionalPayeePercentage;
address public mirageAddress;
mirageContracts public membershipContract;
uint256 public miragePercentage = 10;
mapping(uint256 => uint256) public tokenIdToProjectId;
mapping(uint256 => uint256[]) internal projectIdToTokenIds;
mapping(uint256 => bytes32) public tokenIdToHash;
mapping(bytes32 => uint256) public hashToTokenId;
address public admin;
mapping(address => bool) public isWhitelisted;
mapping(address => bool) public isMintWhitelisted;
uint256 public nextProjectId = 1;
modifier onlyValidTokenId(uint256 _tokenId) {

    require(_exists(_tokenId), "Token ID does not exist");
    _;
}
modifier onlyUnlocked(uint256 _projectId) {

    require(!projects[_projectId].locked, "Only if unlocked");
    _;
}
modifier onlyArtist(uint256 _projectId) {

    require(msg.sender == projectIdToArtistAddress[_projectId], "Only artist");
    _;
}
modifier onlyAdmin() {

    require(msg.sender == admin, "Only admin");
    _;
}
modifier onlyWhitelisted() {

    require(isWhitelisted[msg.sender], "Only whitelisted");
    _;
}
modifier onlyArtistOrWhitelisted(uint256 _projectId) {

    require(isWhitelisted[msg.sender] || msg.sender == projectIdToArtistAddress[_projectId], "Only artist or whitelisted");
    _;
}
constructor(string memory _tokenName, string memory _tokenSymbol, address membershipAddress) CustomERC721Metadata(_tokenName, _tokenSymbol) public {
    admin = msg.sender;
    isWhitelisted[msg.sender] = true;
    mirageAddress = msg.sender;
    membershipContract = mirageContracts(membershipAddress);
}
function mint(address _to, uint256 _projectId, address _by) external returns (uint256 _tokenId) {

    require(isMintWhitelisted[msg.sender], "Must mint from whitelisted minter contract.");
    require(projects[_projectId].artworks.add(51) <= projects[_projectId].maxArtworks, "Must not exceed max artworks");
    require(projects[_projectId].publicActive || _by == projectIdToArtistAddress[_projectId], "Project must exist and be active");
    require(!projects[_projectId].paused || _by == projectIdToArtistAddress[_projectId], "Purchases are paused.");
    uint256 tokenId = _mintToken(_to, _projectId);
    return tokenId;
}
 function earlyMint(address _to, uint256 _projectId, address _by) external returns (uint256 _tokenId) {

    require(isMintWhitelisted[msg.sender], "Must mint from whitelisted minter contract.");
    require(projects[_projectId].earlyActive || _by == projectIdToArtistAddress[_projectId], "Project not in early mint phase");
    require(!projects[_projectId].paused || _by == projectIdToArtistAddress[_projectId], "Purchases are paused.");
    require(projects[_projectId].artworks < projects[_projectId].maxEarly, "Must not exceed early mint allowance");
    uint256 tokenId = _mintToken(_to, _projectId);
    return tokenId;
}
function _mintToken(address _to, uint256 _projectId) internal returns (uint256 _tokenId) {

    uint256 tokenIdToBe = (_projectId * TEN_THOUSAND) + projects[_projectId].artworks + 50; //adding 50 in order to skip pieces claimable by sentient members
    projects[_projectId].artworks = projects[_projectId].artworks.add(1);
    _mint(_to, tokenIdToBe);
    tokenIdToProjectId[tokenIdToBe] = _projectId;
    projectIdToTokenIds[_projectId].push(tokenIdToBe);
    emit Mint(_to, tokenIdToBe, _projectId);
    return tokenIdToBe;
}
 function claimSentient(uint256 _projectId, uint256 membershipId) public {

    require(projects[_projectId].publicActive || projects[_projectId].earlyActive, "Project must exist, and be active or in early mint state");
    require(membershipId < 50, "Must be a Sentient Membership ID (0-49)");
    require(membershipContract.balanceOf(msg.sender, membershipId) == 1, "Wallet does not have this membership ID");
    sentientMint(msg.sender, _projectId, membershipId);
}
function sentientMint(address _to, uint256 _projectId, uint256 _membershipId) internal returns (uint256 _tokenId) {

    uint256 tokenIdToBe = (_projectId * TEN_THOUSAND) + _membershipId;
    _mint(_to, tokenIdToBe);
    tokenIdToProjectId[tokenIdToBe] = _projectId;
    projectIdToTokenIds[_projectId].push(tokenIdToBe);
    emit Mint(_to, tokenIdToBe, _projectId);
    return tokenIdToBe;
}
 function updateMembershipContract(address newAddress) public onlyAdmin {

    membershipContract = mirageContracts(newAddress);
}
 function updateMirageAddress(address _mirageAddress) public onlyAdmin {

    mirageAddress = _mirageAddress;
}
function updateMiragePercentage(uint256 _miragePercentage) public onlyAdmin {

    require(_miragePercentage <= 25, "Max of 25%");
    miragePercentage = _miragePercentage;
}
function addWhitelisted(address _address) public onlyAdmin {

    isWhitelisted[_address] = true;
}
function removeWhitelisted(address _address) public onlyAdmin {

    isWhitelisted[_address] = false;
}
function addMintWhitelisted(address _address) public onlyAdmin {

    isMintWhitelisted[_address] = true;
}
function removeMintWhitelisted(address _address) public onlyAdmin {

    isMintWhitelisted[_address] = false;
}
function toggleProjectIsLocked(uint256 _projectId) public onlyWhitelisted onlyUnlocked(_projectId) {

    projects[_projectId].locked = true;
}
function toggleProjectPublicMint(uint256 _projectId) public onlyWhitelisted {

    projects[_projectId].publicActive = !projects[_projectId].publicActive;
    projects[_projectId].earlyActive = false;
}
 function toggleEarlyMint(uint256 _projectId) public onlyWhitelisted {

    projects[_projectId].earlyActive = !projects[_projectId].earlyActive;
}
function updateProjectArtistAddress(uint256 _projectId, address _artistAddress) public onlyArtistOrWhitelisted(_projectId) {

    projectIdToArtistAddress[_projectId] = _artistAddress;
}
function toggleProjectIsPaused(uint256 _projectId) public onlyWhitelisted {

    projects[_projectId].paused = !projects[_projectId].paused;
}
function addProject(string memory _projectName, string memory tokenURI, string memory description, string memory artistName, string memory projectWebsite, string memory projectLicense, address _artistAddress, uint256 _pricePerTokenInWei, uint256 _maxArtworks, uint256 _maxEarly) public onlyWhitelisted {

    uint256 projectId = nextProjectId;
    projectIdToArtistAddress[projectId] = _artistAddress;
    projects[projectId].name = _projectName;
    projects[projectId].artist = artistName;
    projects[projectId].description = description;
    projects[projectId].website = projectWebsite;
    projects[projectId].license = projectLicense;
    projectIdToCurrencySymbol[projectId] = "ETH";
    projectIdToPricePerTokenInWei[projectId] = _pricePerTokenInWei;
    projects[projectId].paused=false;
    projects[projectId].earlyActive = false;
    projects[projectId].publicActive = false;
    projects[projectId].maxArtworks = _maxArtworks;
    projects[projectId].maxEarly = _maxEarly;
    projects[projectId].projectBaseURI = tokenURI;
    nextProjectId = nextProjectId.add(1);
}
function updateProjectCurrencyInfo(uint256 _projectId, string memory _currencySymbol, address _currencyAddress) onlyAdmin() public {

    projectIdToCurrencySymbol[_projectId] = _currencySymbol;
    projectIdToCurrencyAddress[_projectId] = _currencyAddress;
}
function updateProjectPricePerTokenInWei(uint256 _projectId, uint256 _pricePerTokenInWei) onlyWhitelisted public {

    projectIdToPricePerTokenInWei[_projectId] = _pricePerTokenInWei;
}
function updateProjectName(uint256 _projectId, string memory _projectName) onlyUnlocked(_projectId) onlyAdmin() public {

    projects[_projectId].name = _projectName;
}
function updateProjectArtistName(uint256 _projectId, string memory _projectArtistName) onlyUnlocked(_projectId) onlyArtistOrWhitelisted(_projectId) public {

    projects[_projectId].artist = _projectArtistName;
}
function updateProjectAdditionalPayeeInfo(uint256 _projectId, address _additionalPayee, uint256 _additionalPayeePercentage) onlyArtist(_projectId) public {

    require(_additionalPayeePercentage <= 100, "Max of 100%");
    projectIdToAdditionalPayee[_projectId] = _additionalPayee;
    projectIdToAdditionalPayeePercentage[_projectId] = _additionalPayeePercentage;
}
function updateProjectDescription(uint256 _projectId, string memory _projectDescription) onlyArtist(_projectId) public {

    projects[_projectId].description = _projectDescription;
}
function updateProjectWebsite(uint256 _projectId, string memory _projectWebsite) onlyArtist(_projectId) public {

    projects[_projectId].website = _projectWebsite;
}
function updateProjectLicense(uint256 _projectId, string memory _projectLicense) onlyUnlocked(_projectId) onlyArtistOrWhitelisted(_projectId) public {

    projects[_projectId].license = _projectLicense;
}
function updateProjectMaxArtworks(uint256 _projectId, uint256 _maxArtworks) onlyUnlocked(_projectId) onlyWhitelisted public {

    require(_maxArtworks > projects[_projectId].artworks.add(50), "You must set max artworks greater than current artworks");
    require(_maxArtworks <= 5000, "Cannot exceed 5000");
    projects[_projectId].maxArtworks = _maxArtworks;
}
 function updateProjectMaxEarly(uint256 _projectId, uint256 _maxEarly) onlyUnlocked(_projectId) onlyWhitelisted public {

    require(_maxEarly < projects[_projectId].maxArtworks, "Early mint amount must be less than total number of artworks");
    require(_maxEarly <= 2500, "Cannot exceed 2500");
    projects[_projectId].maxEarly = _maxEarly;
}
function updateProjectBaseURI(uint256 _projectId, string memory _newBaseURI) onlyWhitelisted public {

    projects[_projectId].projectBaseURI = _newBaseURI;
}
function projectDetails(uint256 _projectId) view public returns (string memory projectName, string memory artist, string memory description, string memory website, string memory license) {

    projectName = projects[_projectId].name;
    artist = projects[_projectId].artist;
    description = projects[_projectId].description;
    website = projects[_projectId].website;
    license = projects[_projectId].license;
}
function projectTokenInfo(uint256 _projectId) view public returns (address artistAddress, uint256 pricePerTokenInWei, uint256 artworks, uint256 maxArtworks, uint256 maxEarly, address additionalPayee, uint256 additionalPayeePercentage, bool publicActive, bool earlyActive, string memory currency) {

    artistAddress = projectIdToArtistAddress[_projectId];
    pricePerTokenInWei = projectIdToPricePerTokenInWei[_projectId];
    artworks = projects[_projectId].artworks.add(50); //add 50 to account for claimable pieces for sentient members
    maxArtworks = projects[_projectId].maxArtworks;
    maxEarly = projects[_projectId].maxEarly;
    publicActive = projects[_projectId].publicActive;
    earlyActive = projects[_projectId].earlyActive;
    additionalPayee = projectIdToAdditionalPayee[_projectId];
    additionalPayeePercentage = projectIdToAdditionalPayeePercentage[_projectId];
    currency = projectIdToCurrencySymbol[_projectId];
}
function projectURIInfo(uint256 _projectId) view public returns (string memory projectBaseURI) {

    projectBaseURI = projects[_projectId].projectBaseURI;
}
function projectShowAllTokens(uint _projectId) public view returns (uint256[] memory){

    return projectIdToTokenIds[_projectId];
}
function tokensOfOwner(address owner) external view returns (uint256[] memory) {

    return _tokensOfOwner(owner);
}
function getRoyaltyData(uint256 _tokenId) public view returns (address artistAddress, address additionalPayee, uint256 additionalPayeePercentage) {

    artistAddress = projectIdToArtistAddress[tokenIdToProjectId[_tokenId]];
    additionalPayee = projectIdToAdditionalPayee[tokenIdToProjectId[_tokenId]];
    additionalPayeePercentage = projectIdToAdditionalPayeePercentage[tokenIdToProjectId[_tokenId]];
}
function tokenURI(uint256 _tokenId) external view onlyValidTokenId(_tokenId) returns (string memory) {

    return Strings.strConcat(projects[tokenIdToProjectId[_tokenId]].projectBaseURI, Strings.uint2str(_tokenId));
}
}