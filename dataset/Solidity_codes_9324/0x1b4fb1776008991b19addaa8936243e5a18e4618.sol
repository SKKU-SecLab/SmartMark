pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}pragma solidity ^0.6.0;


abstract contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view virtual returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view virtual returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual;
    function transferFrom(address from, address to, uint256 tokenId) public virtual;
    function approve(address to, uint256 tokenId) public virtual;
    function getApproved(uint256 tokenId) public view virtual returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public virtual;
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual;
}
pragma solidity ^0.6.0;


abstract contract IERC721Enumerable is IERC721 {
    function totalSupply() public view virtual returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view virtual returns (uint256);
}
pragma solidity ^0.6.0;

abstract contract IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public virtual returns (bytes4);
}
pragma solidity ^0.6.0;

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
pragma solidity ^0.6.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
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
pragma solidity ^0.6.0;


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
pragma solidity ^0.6.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
pragma solidity ^0.6.0;


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

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

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

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal virtual returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
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

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}
pragma solidity ^0.6.0;


contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {
    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToOwnerEnumeration(to, tokenId);
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (to == address(0)) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
            _ownedTokensIndex[tokenId] = 0;

            _removeTokenFromAllTokensEnumeration(tokenId);
        } else {
            _removeTokenFromOwnerEnumeration(from, tokenId);
            _addTokenToOwnerEnumeration(to, tokenId);
        }
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

        _ownedTokens[from].pop();

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.pop();

        _allTokensIndex[tokenId] = 0;
    }
}
pragma solidity ^0.6.0;


abstract contract IERC721Metadata is IERC721 {
    function name() external view virtual returns (string memory);
    function symbol() external view virtual returns (string memory);
    function tokenURI(uint256 tokenId) external view virtual returns (string memory);
}
pragma solidity ^0.6.0;


contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {
    string private _name;

    string private _symbol;

    string private _baseURI;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_tokenURI).length == 0) {
            return "";
        } else {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI) internal virtual {
        _baseURI = baseURI;
    }

    function baseURI() external view returns (string memory) {
        return _baseURI;
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (to == address(0)) { // When burning tokens
            if (bytes(_tokenURIs[tokenId]).length != 0) {
                delete _tokenURIs[tokenId];
            }
        }
    }
}
pragma solidity ^0.6.0;


contract ERC721Full is ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) { }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        virtual
        override(ERC721Enumerable, ERC721Metadata)
        internal
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
pragma solidity ^0.6.0;

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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.6.0;

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
pragma solidity ^0.6.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
pragma solidity ^0.6.0;



contract RegencyNFTs is ERC721Full("RegencyNFT", "RNFT"), Ownable {
using SafeMath for uint256;
using Roles for Roles.Role;
Roles.Role moderators;
address payable ownerRegency = 0x00a2Ddfa736214563CEa9AEf5100f2e90c402918;
address payable ownerRegent1 = 0x7beAd6F7dB10Ae70090aee1742F5f9Af83D76784;
address payable ownerRegent2 = 0xb799e0b02Cc6738f704cF15dcBE0934eC73A2707;
address payable ownerRegent3 = 0xAD5bA38e921bDE497C18Be44977A255C57A55F18;
address payable ownerRegent4 = 0x9FcCea1dCa74b110f265ac5f86F7Acf0B3709aC0;
address payable ownerRegent5 = 0x5219c80f8179f3361a605fbB5DDb7528308A1DC0;

struct RegencyNFT {
uint256 priceFinney;
uint256 numClonesAllowed;
uint256 numClonesInWild;
uint256 clonedFromId;
}

RegencyNFT[] public regencyNFTs;
uint256 public cloneFeePercentage = 10;
bool public isMintable = true;

modifier mintable {
require(
isMintable == true,
"New regencyNFTs are no longer mintable on this contract."
);
_;
}

constructor () public {
if(regencyNFTs.length == 0) {
RegencyNFT memory _dummyRegencyNFT = RegencyNFT({priceFinney: 0,numClonesAllowed: 0, numClonesInWild: 0,
clonedFromId: 0
});
regencyNFTs.push(_dummyRegencyNFT);
}
}

function addModRoles(address [] memory _moderators) public onlyOwner {
for(uint i=0; i< _moderators.length; i++)
{
moderators.add(_moderators[i]);
}
}

function addOneModRole(address _moderator) public onlyOwner {
moderators.add(_moderator);
}

function removeOneModRole(address _moderator) public onlyOwner {
moderators.remove(_moderator);
}

function isMod() public view returns (bool){
return moderators.has(msg.sender);
}

function mint(address _to, uint256 _priceFinney, uint256 _numClonesAllowed, string memory _tokenURI) public mintable returns (uint256 tokenId) {
require(moderators.has(msg.sender) || Ownable.isOwner(), "DOES NOT HAVE Moderator ROLE or not Owner");

RegencyNFT memory _regencyNFT = RegencyNFT({priceFinney: _priceFinney, numClonesAllowed: _numClonesAllowed,
numClonesInWild: 0, clonedFromId: 0
});

regencyNFTs.push(_regencyNFT);
tokenId = regencyNFTs.length - 1;
regencyNFTs[tokenId].clonedFromId = tokenId;

_mint(_to, tokenId);
_setTokenURI(tokenId, _tokenURI);

}

function clone(address _to, uint256 _tokenId, uint256 _numClonesRequested) public payable mintable {

RegencyNFT memory _regencyNFT = regencyNFTs[_tokenId];
uint256 cloningCost = _regencyNFT.priceFinney * 10**15 * _numClonesRequested;
require(
_regencyNFT.numClonesInWild + _numClonesRequested <= _regencyNFT.numClonesAllowed,
"The number of RegencyNFTs clones requested exceeds the number of clones allowed.");
require(
msg.value >= cloningCost,
"Not enough Wei to pay for the RegencyNFTs clones.");


uint256 ownerRegencyCut = (cloningCost.mul(50)).div(100);
ownerRegency.transfer(ownerRegencyCut);

uint256 ownerRegent1Cut = (cloningCost.mul(10)).div(100);
ownerRegent1.transfer(ownerRegent1Cut);

uint256 ownerRegent2Cut = (cloningCost.mul(10)).div(100);
ownerRegent1.transfer(ownerRegent2Cut);

uint256 ownerRegent3Cut = (cloningCost.mul(10)).div(100);
ownerRegent1.transfer(ownerRegent3Cut);

uint256 ownerRegent4Cut = (cloningCost.mul(10)).div(100);
ownerRegent1.transfer(ownerRegent4Cut);

uint256 ownerRegent5Cut = (cloningCost.mul(10)).div(100);
ownerRegent1.transfer(ownerRegent5Cut);

_regencyNFT.numClonesInWild += _numClonesRequested;
regencyNFTs[_tokenId] = _regencyNFT;

for (uint i = 0; i < _numClonesRequested; i++) {
RegencyNFT memory _newRegencyNFT;
_newRegencyNFT.priceFinney = _regencyNFT.priceFinney;
_newRegencyNFT.numClonesAllowed = 0;
_newRegencyNFT.numClonesInWild = 0;
_newRegencyNFT.clonedFromId = _tokenId;

regencyNFTs.push(_newRegencyNFT);
uint256 newTokenId = regencyNFTs.length-1;

_mint(_to, newTokenId);

string memory _tokenURI = this.tokenURI(_tokenId);
_setTokenURI(newTokenId, _tokenURI);
}
msg.sender.transfer( msg.value - cloningCost );
}


function burn(address _owner, uint256 _tokenId) public {

require(moderators.has(msg.sender) || Ownable.isOwner(), "DOES NOT HAVE Moderator ROLE or not Owner");

RegencyNFT memory _regencyNFT = regencyNFTs[_tokenId];
uint256 gen0Id = _regencyNFT.clonedFromId;
if (_tokenId != gen0Id) {
RegencyNFT memory _gen0RegencyNFT = regencyNFTs[gen0Id];
_gen0RegencyNFT.numClonesInWild -= 1;
regencyNFTs[gen0Id] = _gen0RegencyNFT;
}
delete regencyNFTs[_tokenId];
_burn(_owner, _tokenId);
}

function setCloneFeePercentage(uint256 _cloneFeePercentage) public {
require(moderators.has(msg.sender) || Ownable.isOwner(), "DOES NOT HAVE Moderator ROLE or not Owner");
require(
_cloneFeePercentage >= 0 && _cloneFeePercentage <= 100,
"Invalid range for cloneFeePercentage. Must be between 0 and 100.");
cloneFeePercentage = _cloneFeePercentage;
}

function setMintable(bool _isMintable) public {
require(moderators.has(msg.sender) || Ownable.isOwner(), "DOES NOT HAVE Moderator ROLE or not Owner");
isMintable = _isMintable;
}

function setPrice(uint256 _tokenId, uint256 _newPriceFinney) public {
require(moderators.has(msg.sender) || Ownable.isOwner(), "DOES NOT HAVE Moderator ROLE or not Owner");
RegencyNFT memory _regencyNFT = regencyNFTs[_tokenId];

_regencyNFT.priceFinney = _newPriceFinney;
regencyNFTs[_tokenId] = _regencyNFT;
}

function setTokenURI(uint256 _tokenId, string memory _tokenURI) public {
require(moderators.has(msg.sender) || Ownable.isOwner(), "DOES NOT HAVE Moderator ROLE or not Owner");
_setTokenURI(_tokenId, _tokenURI);
}

function getRegencyNFTsById(uint256 _tokenId) view public returns (uint256 priceFinney,
uint256 numClonesAllowed,
uint256 numClonesInWild,
uint256 clonedFromId
)
{
RegencyNFT memory _regencyNFT = regencyNFTs[_tokenId];

priceFinney = _regencyNFT.priceFinney;
numClonesAllowed = _regencyNFT.numClonesAllowed;
numClonesInWild = _regencyNFT.numClonesInWild;
clonedFromId = _regencyNFT.clonedFromId;
}

function getNumClonesInWild(uint256 _tokenId) view public returns (uint256 numClonesInWild)
{
RegencyNFT memory _regencyNFT = regencyNFTs[_tokenId];

numClonesInWild = _regencyNFT.numClonesInWild;
}

function getLatestId() view public returns (uint256 tokenId)
{
if (regencyNFTs.length == 0) {
tokenId = 0;
} else {
tokenId = regencyNFTs.length - 1;
}
}
}