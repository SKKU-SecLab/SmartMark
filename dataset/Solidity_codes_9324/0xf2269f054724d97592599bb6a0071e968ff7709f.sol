

pragma solidity ^0.5.0;

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






pragma solidity ^0.5.0;

contract IAKAP {

    enum ClaimCase {RECLAIM, NEW, TRANSFER}
    enum NodeAttribute {EXPIRY, SEE_ALSO, SEE_ADDRESS, NODE_BODY, TOKEN_URI}

    event Claim(address indexed sender, uint indexed nodeId, uint indexed parentId, bytes label, ClaimCase claimCase);
    event AttributeChanged(address indexed sender, uint indexed nodeId, NodeAttribute attribute);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function hashOf(uint parentId, bytes memory label) public pure returns (uint id);


    function claim(uint parentId, bytes calldata label) external returns (uint status);


    function exists(uint nodeId) external view returns (bool);


    function isApprovedOrOwner(uint nodeId) external view returns (bool);


    function ownerOf(uint256 tokenId) public view returns (address);


    function parentOf(uint nodeId) external view returns (uint);


    function expiryOf(uint nodeId) external view returns (uint);


    function seeAlso(uint nodeId) external view returns (uint);


    function seeAddress(uint nodeId) external view returns (address);


    function nodeBody(uint nodeId) external view returns (bytes memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);


    function expireNode(uint nodeId) external;


    function setSeeAlso(uint nodeId, uint value) external;


    function setSeeAddress(uint nodeId, address value) external;


    function setNodeBody(uint nodeId, bytes calldata value) external;


    function setTokenURI(uint nodeId, string calldata uri) external;


    function approve(address to, uint256 tokenId) public;


    function getApproved(uint256 tokenId) public view returns (address);


    function setApprovalForAll(address to, bool approved) public;


    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function transferFrom(address from, address to, uint256 tokenId) public;


    function safeTransferFrom(address from, address to, uint256 tokenId) public;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public;

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



contract IDomainManager {

    function akap() public view returns (IAKAP);


    function erc721() public view returns (IERC721);


    function domainParent() public view returns (uint);


    function domainLabel() public view returns (bytes memory);


    function domain() public view returns (uint);


    function setApprovalForAll(address to, bool approved) public;


    function claim(bytes memory label) public returns (uint status);


    function claim(uint parentId, bytes memory label) public returns (uint);


    function reclaim() public returns (uint);

}






pragma solidity ^0.5.0;

library Uint256Lib {

    function asBytes(uint256 x) internal pure returns (bytes memory b) {

        return abi.encodePacked(x);
    }
}






pragma solidity ^0.5.0;

library StringLib {

    function asBytes(string memory s) internal pure returns (bytes memory) {

        return bytes(s);
    }
}






pragma solidity ^0.5.0;

library AddressLib {

    function asBytes(address x) internal pure returns (bytes memory b) {

        return abi.encodePacked(x);
    }
}






pragma solidity ^0.5.0;

library BytesLib {

    function asAddress(bytes memory b) internal pure returns (address x) {

        if (b.length == 0) {
            x = address(0);
        } else {
            assembly {
                x := mload(add(b, 0x14))
            }
        }
    }

    function asBool(bytes memory b) internal pure returns (bool x) {

        if (asUint8(b) > 0) return true;

        return false;
    }

    function asString(bytes memory b) internal pure returns (string memory) {

        return string(b);
    }

    function asUint8(bytes memory b) internal pure returns (uint8 x) {

        if (b.length == 0) {
            x = 0;
        } else {
            assembly {
                x := mload(add(b, 0x1))
            }
        }
    }

    function asUint160(bytes memory b) internal pure returns (uint160 x) {

        if (b.length == 0) {
            x = 0;
        } else {
            assembly {
                x := mload(add(b, 0x14))
            }
        }
    }

    function asUint256(bytes memory b) internal pure returns (uint256 x) {

        if (b.length == 0) {
            x = 0;
        } else {
            assembly {
                x := mload(add(b, 0x20))
            }
        }
    }
}






pragma solidity ^0.5.0;

contract ISimpleMap {

    function get(bytes memory key) public view returns (bytes memory value);


    function put(bytes memory key, bytes memory newValue) public;


    function remove(bytes memory key) public;

}


pragma solidity ^0.5.0;


contract RTokenLike is IERC20 {

    function mint(uint256 mintAmount) external returns (bool);


    function mintWithSelectedHat(uint256 mintAmount, uint256 hatID) external returns (bool);


    function mintWithNewHat(
        uint256 mintAmount,
        address[] calldata recipients,
        uint32[] calldata proportions
    ) external returns (bool);


    function transferAll(address dst) external returns (bool);


    function transferAllFrom(address src, address dst) external returns (bool);


    function redeem(uint256 redeemTokens) external returns (bool);


    function redeemAll() external returns (bool);


    function redeemAndTransfer(address redeemTo, uint256 redeemTokens) external returns (bool);


    function redeemAndTransferAll(address redeemTo) external returns (bool);


    function createHat(
        address[] calldata recipients,
        uint32[] calldata proportions,
        bool doChangeHat
    ) external returns (uint256 hatID);


    function changeHat(uint256 hatID) external returns (bool);


    function payInterest(address owner) external returns (bool);


    function getMaximumHatID() external view returns (uint256 hatID);


    function getHatByAddress(address owner)
    external
    view
    returns (
        uint256 hatID,
        address[] memory recipients,
        uint32[] memory proportions
    );


    function getHatByID(uint256 hatID)
    external
    view
    returns (address[] memory recipients, uint32[] memory proportions);


    function receivedSavingsOf(address owner)
    external
    view
    returns (uint256 amount);


    function receivedLoanOf(address owner)
    external
    view
    returns (uint256 amount);


    function interestPayableOf(address owner)
    external
    view
    returns (uint256 amount);


    event LoansTransferred(
        address indexed owner,
        address indexed recipient,
        uint256 indexed hatId,
        bool isDistribution,
        uint256 redeemableAmount,
        uint256 internalSavingsAmount);

    event InterestPaid(address indexed recipient, uint256 amount);

    event HatCreated(uint256 indexed hatID);

    event HatChanged(address indexed account, uint256 indexed oldHatID, uint256 indexed newHatID);
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

    string private _baseURI;

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


pragma solidity ^0.5.0;




contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
    }
}






pragma solidity ^0.5.0;




contract DomainManager is IDomainManager {

    IAKAP private __akap;
    IERC721 private __erc721;

    uint private __domainParent;
    bytes private __domainLabel;

    uint private __domain;

    constructor(address _akapAddress, uint _domainParent, bytes memory _domainLabel) public {
        __akap = IAKAP(_akapAddress);
        __erc721 = IERC721(_akapAddress);

        __domainParent = _domainParent;
        __domainLabel = _domainLabel;

        require(__akap.claim(__domainParent, __domainLabel) > 0, "DomainManager: Unable to claim");

        __domain = __akap.hashOf(__domainParent, __domainLabel);

        __akap.setSeeAddress(__domain, address(this));

        __erc721.setApprovalForAll(msg.sender, true);
    }

    modifier onlyApproved() {

        require(__erc721.isApprovedForAll(address(this), msg.sender), "DomainManager: Not approved for all");

        _;
    }

    function akap() public view returns (IAKAP) {

        return __akap;
    }

    function erc721() public view returns (IERC721) {

        return __erc721;
    }

    function domainParent() public view returns (uint) {

        return __domainParent;
    }

    function domainLabel() public view returns (bytes memory) {

        return __domainLabel;
    }

    function domain() public view returns (uint) {

        return __domain;
    }

    function setApprovalForAll(address to, bool approved) public onlyApproved() {

        require(to != msg.sender, "DomainManager: Approve to caller");

        __erc721.setApprovalForAll(to, approved);
    }

    function claim(bytes memory label) public returns (uint status) {

        return claim(__domain, label);
    }

    function claim(uint parentId, bytes memory label) public onlyApproved() returns (uint) {

        uint status = __akap.claim(parentId, label);

        require(status > 0, "DomainManager: Unable to claim");

        return status;
    }

    function reclaim() public returns (uint) {

        uint status = __akap.claim(__domainParent, __domainLabel);

        require(status > 0, "DomainManager: Unable to reclaim");

        return status;
    }
}






pragma solidity ^0.5.0;





contract MillionDaiToken is ERC721Full {

    using StringLib for string;

    DomainManager public dm;
    IAKAP public akap;
    uint public rootPtr;

    constructor(address _dmAddress, uint _rootPtr) ERC721Full("Million DAI website", "MillionDAI") public {
        dm = DomainManager(_dmAddress);
        akap = dm.akap();
        rootPtr = _rootPtr;
    }

    function ptr(string memory k) internal view returns (uint) {

        return akap.hashOf(rootPtr, k.asBytes());
    }

    function tokenAccessPtr() public view returns (uint) {

        return ptr("token-access");
    }

    function tokenAccess() public view returns (address) {

        return akap.seeAddress(tokenAccessPtr());
    }

    function exists(uint tile) external view returns (bool) {

        return _exists(tile);
    }

    modifier withTokenAccess() {

        require(msg.sender == tokenAccess(), "No token access");
        _;
    }

    function mint(address owner, uint tile) external withTokenAccess() returns (bool) {

        _mint(owner, tile);
        return true;
    }

    function burn(address owner, uint tile) external withTokenAccess() returns (bool) {

        _burn(owner, tile);
        return true;
    }

    function ownerChange(address from, address to, uint tile) external withTokenAccess() returns (bool) {

        _safeTransferFrom(from, to, tile, "");
        return true;
    }

    function setTokenURI(uint tile, string calldata uri) external withTokenAccess() {

        _setTokenURI(tile, uri);
    }
}






pragma solidity ^0.5.0;











contract MillionDai {

    using StringLib for string;
    using AddressLib for address;
    using Uint256Lib for uint;
    using BytesLib for bytes;

    IDomainManager public dm;
    IAKAP public akap;
    uint public rootPtr;

    bool private lock;

    enum TileAction {ENTER, EXIT}
    event Tile(uint indexed tile, address indexed actor, TileAction indexed action, uint amount);
    event Value(uint indexed tile, address indexed actor, bytes value);
    event URI(uint indexed tile, address indexed actor, string uri);
    event Vote(uint indexed tile, address indexed actor);

    constructor() public {}

    function ptr(string memory k) internal view returns (uint) {

        return akap.hashOf(rootPtr, k.asBytes());
    }

    function erc721Ptr() public view returns (uint) {

        return ptr("erc-721");
    }

    function daiPtr() public view returns (uint) {

        return ptr("dai");
    }

    function rdaiPtr() public view returns (uint) {

        return ptr("rdai");
    }

    function dataMapPtr() public view returns (uint) {

        return ptr("data-map");
    }

    function daiMapPtr() public view returns (uint) {

        return ptr("dai-map");
    }

    function tileBlockMapPtr() public view returns (uint) {

        return ptr("tile-block-map");
    }

    function voteTileMapPtr() public view returns (uint) {

        return ptr("vote-tile-map");
    }

    function voteBlockMapPtr() public view returns (uint) {

        return ptr("vote-block-map");
    }

    function adminRootPtr() public view returns (uint) {

        return ptr("admin");
    }

    function adminPtr() public view returns (uint) {

        address a = msg.sender;
        return akap.hashOf(adminRootPtr(), a.asBytes());
    }

    function erc721() public view returns (MillionDaiToken) {

        return MillionDaiToken(akap.seeAddress(erc721Ptr()));
    }

    function dai() public view returns (IERC20) {

        return IERC20(akap.seeAddress(daiPtr()));
    }

    function rdai() public view returns (RTokenLike) {

        return RTokenLike(akap.seeAddress(rdaiPtr()));
    }

    function dataMap() public view returns (ISimpleMap) {

        return ISimpleMap(akap.seeAddress(dataMapPtr()));
    }

    function daiMap() public view returns (ISimpleMap) {

        return ISimpleMap(akap.seeAddress(daiMapPtr()));
    }

    function tileBlockMap() public view returns (ISimpleMap) {

        return ISimpleMap(akap.seeAddress(tileBlockMapPtr()));
    }

    function voteBlockMap() public view returns (ISimpleMap) {

        return ISimpleMap(akap.seeAddress(voteBlockMapPtr()));
    }

    function voteTileMap() public view returns (ISimpleMap) {

        return ISimpleMap(akap.seeAddress(voteTileMapPtr()));
    }

    function tilePrice(uint tile) public view returns (uint) {

        bytes memory value = daiMap().get(tile.asBytes());

        return value.asUint256();
    }

    function get(uint tile) external view returns (bytes memory value, string memory uri, uint price, uint minNewPrice, address owner, uint blockNumber) {

        value = dataMap().get(tile.asBytes());

        MillionDaiToken token = erc721();

        if (token.exists(tile)) {
            uri = token.tokenURI(tile);
            owner = erc721().ownerOf(tile);
        } else {
            uri = "";
            owner = address(0);
        }

        price = tilePrice(tile);

        uint minPrice = 100000000000000000000; // 100 DAI
        uint minIncrement = 1000000000000000000; // 1 DAI
        uint minAmount = price + minIncrement;

        if (minPrice > minAmount) {
            minNewPrice = minPrice;
        } else {
            minNewPrice = minAmount;
        }

        blockNumber = tileBlockMap().get(tile.asBytes()).asUint256();
    }

    modifier withValidTile(uint tile) {

        uint lower = uint(-1) / 2;
        uint higher = lower + 10000;
        require(tile >= lower && tile < higher, "Invalid tile");
        _;
    }

    function set(uint tile, bytes calldata value, string calldata uri) external withValidTile(tile) {

        require(value.length == 38, "Wrong value size");
        MillionDaiToken token = erc721();
        require(msg.sender == token.ownerOf(tile), "Not owner");
        token.setTokenURI(tile, uri);
        dataMap().put(tile.asBytes(), value);
        emit Value(tile, msg.sender, value);
        emit URI(tile, msg.sender, uri);
    }

    function setTileValue(uint tile, bytes calldata value) external withValidTile(tile) {

        require(value.length == 38, "Wrong value size");
        MillionDaiToken token = erc721();
        require(msg.sender == token.ownerOf(tile), "Not owner");
        dataMap().put(tile.asBytes(), value);
        emit Value(tile, msg.sender, value);
    }

    function setTileURI(uint tile, string calldata uri) external withValidTile(tile) {

        MillionDaiToken token = erc721();
        require(msg.sender == token.ownerOf(tile), "Not owner");
        token.setTokenURI(tile, uri);
        emit URI(tile, msg.sender, uri);
    }

    function enter(uint tile, uint amount) external withValidTile(tile) {

        require(!lock, "Lock failure");
        lock = true;

        uint minPrice = 100000000000000000000; // 100 DAI
        uint minIncrement = 1000000000000000000; // 1 DAI
        uint existingAmount = tilePrice(tile);
        uint minAmount = existingAmount + minIncrement;

        MillionDaiToken token = erc721();
        RTokenLike rtoken = rdai();

        require(amount >= minPrice && minAmount > existingAmount, "Insufficient price");

        bool tokenExists = token.exists(tile);

        if (tokenExists) {
            require(rtoken.redeemAndTransfer(token.ownerOf(tile), existingAmount), "RDai redeem failure");
        }

        if (tokenExists && token.ownerOf(tile) != msg.sender) {
            require(amount >= minAmount, "Insufficient increase in price");
            require(token.ownerChange(token.ownerOf(tile), msg.sender, tile), "Owner change failure");
        } else if (!tokenExists) {
            require(token.mint(msg.sender, tile), "Token mint failure");
        }

        require(dai().transferFrom(msg.sender, address(this), amount), "Transfer failure");
        require(rtoken.mint(amount), "RDai mint failure");

        tileBlockMap().put(tile.asBytes(), block.number.asBytes());
        daiMap().put(tile.asBytes(), amount.asBytes());

        emit Tile(tile, msg.sender, TileAction.ENTER, amount);

        require(lock, "Lock failure");
        lock = false;
    }

    function exit(uint tile) external withValidTile(tile) {

        require(!lock, "Lock failure");
        lock = true;

        bytes memory value = tileBlockMap().get(tile.asBytes());
        uint blockEnter = value.asUint256();

        require(block.number > blockEnter, "Mint too fresh");

        require(erc721().burn(msg.sender, tile), "Token burn failure");

        uint existingAmount = tilePrice(tile);
        daiMap().put(tile.asBytes(), "");

        require(rdai().redeemAndTransfer(msg.sender, existingAmount), "RDai redeem failure");

        emit Tile(tile, msg.sender, TileAction.EXIT, existingAmount);

        require(lock, "Lock failure");
        lock = false;
    }

    function vote(uint tile) external withValidTile(tile) {

        bytes memory value = dataMap().get(tile.asBytes());
        require(value.length > 0, "No tile");

        address a = msg.sender;
        voteTileMap().put(a.asBytes(), tile.asBytes());
        voteBlockMap().put(a.asBytes(), block.number.asBytes());

        emit Vote(tile, a);
    }

    function getVote(address actor) external view returns (uint tile, uint blockNumber) {

        tile = voteTileMap().get(actor.asBytes()).asUint256();
        blockNumber = voteBlockMap().get(actor.asBytes()).asUint256();
    }

    modifier onlyAdmin() {

        require(akap.seeAddress(adminPtr()) == msg.sender, "Not admin");
        _;
    }

    function withHat(address[] calldata recipients, uint32[] calldata proportions) external onlyAdmin() {

        RTokenLike rd = rdai();
        dai().approve(address(rd), uint(-1));
        rd.createHat(recipients, proportions, true);
    }
}