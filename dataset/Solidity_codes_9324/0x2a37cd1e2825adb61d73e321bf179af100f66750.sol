
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping (uint256 => address) private _owners;

    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
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

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextMixin {
    function msgSender()
        internal
        view
        returns (address payable sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}// MIT

pragma solidity ^0.8.0;

contract Initializable {
    bool inited = false;

    modifier initializer() {
        require(!inited, "already inited");
        _;
        inited = true;
    }
}// MIT

pragma solidity ^0.8.0;


contract EIP712Base is Initializable {
    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 salt;
    }

    string constant public ERC712_VERSION = "1";

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(
        bytes(
            "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"
        )
    );
    bytes32 internal domainSeperator;

    function _initializeEIP712(
        string memory name
    )
        internal
        initializer
    {
        _setDomainSeperator(name);
    }

    function _setDomainSeperator(string memory name) internal {
        domainSeperator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(ERC712_VERSION)),
                address(this),
                bytes32(getChainId())
            )
        );
    }

    function getDomainSeperator() public view returns (bytes32) {
        return domainSeperator;
    }

    function getChainId() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function toTypedMessageHash(bytes32 messageHash)
        internal
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", getDomainSeperator(), messageHash)
            );
    }
}// MIT

pragma solidity ^0.8.0;


contract NativeMetaTransaction is EIP712Base {
    using SafeMath for uint256;
    bytes32 private constant META_TRANSACTION_TYPEHASH = keccak256(
        bytes(
            "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
        )
    );
    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );
    mapping(address => uint256) nonces;

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public payable returns (bytes memory) {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        require(
            verify(userAddress, metaTx, sigR, sigS, sigV),
            "Signer and signature do not match"
        );

        nonces[userAddress] = nonces[userAddress].add(1);

        emit MetaTransactionExecuted(
            userAddress,
            payable(msg.sender),
            functionSignature
        );

        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call not successful");

        return returnData;
    }

    function hashMetaTransaction(MetaTransaction memory metaTx)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    META_TRANSACTION_TYPEHASH,
                    metaTx.nonce,
                    metaTx.from,
                    keccak256(metaTx.functionSignature)
                )
            );
    }

    function getNonce(address user) public view returns (uint256 nonce) {
        nonce = nonces[user];
    }

    function verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {
        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");
        return
            signer ==
            ecrecover(
                toTypedMessageHash(hashMetaTransaction(metaTx)),
                sigV,
                sigR,
                sigS
            );
    }
}// MIT

pragma solidity ^0.8.0;



contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

abstract contract ERC721Tradable is ContextMixin, ERC721Enumerable, NativeMetaTransaction, Ownable {
    using SafeMath for uint256;

    address proxyRegistryAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) ERC721(_name, _symbol) {
        proxyRegistryAddress = _proxyRegistryAddress;
        _initializeEIP712(_name);
    }

    function mintTo(address _to, uint256 _boxnum, uint256 _tokenId, uint256 _classId) virtual external {
        _mint(_to, _tokenId);
    }

    function baseTokenURI() virtual public view returns (string memory);

    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}// MIT

pragma solidity ^0.8.0;

interface FactoryERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function numOptions() external view returns (uint256);

    function canMint(uint256 _optionId, uint256 _amount) external view returns (bool);

    function tokenURI(uint256 _optionId) external view returns (string memory);

    function supportsFactoryInterface() external view returns (bool);

    function mint(uint256 _optionId, address _toAddress) external;
}// MIT

pragma solidity ^0.8.0;


contract LazyMe is ERC721Tradable, ReentrancyGuard {
    using Strings for uint256;

    uint256 private _currentTokenId = 0;

    mapping(uint256 => mapping(uint256 => address)) private _ownersMapWithBox;
    mapping(uint256 => uint256) private _jsonMap;
    mapping(uint256 => uint256) private _boxMap;
    mapping(uint256 => uint256) private _boxTotalsupply;
    mapping(uint256 => uint256) private _burnTotalsupply;
    mapping(uint256 => string) private _tokenURI;

    string public baseURI;
    string public storeDataURI;
    address public factoryNftAddress;

    constructor(
        address _proxyRegistryAddress,
        string memory _baseURI,
        string memory _storeDataURI
    ) ERC721Tradable("LazyMe NFT", "LAZY", _proxyRegistryAddress) {
        baseURI = _baseURI;
        storeDataURI = _storeDataURI;
    }

    function contractURI() public view returns (string memory) {
        return storeDataURI;
    }

    function baseTokenURI() public view override returns (string memory) {
        return baseURI;
    }

    function setFactoryAddress(address _factoryNftAddress) public onlyOwner {
        factoryNftAddress = _factoryNftAddress;
    }

    function getFactoryAddress() public view onlyOwner returns (address) {
        return factoryNftAddress;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory rarityString = _tokenURI[_tokenId];
        uint256 tokenNum = _jsonMap[_tokenId];
        return
            string(
                abi.encodePacked(
                    baseTokenURI(),
                    rarityString,
                    "/",
                    Strings.toString(tokenNum),
                    ".json"
                )
            );
    }

    function mintTo(
        address _to,
        uint256 _boxnum,
        uint256 _tokenId,
        uint256 _classId
    ) public override {
        require(_to != address(0), "ERC721: mint to the zero address");
        require(
            _msgSender() == factoryNftAddress || _msgSender() == owner(),
            "ERC721: need factory to mint item"
        );
        require(!_exists(_currentTokenId), "ERC721: token already minted");

        _jsonMap[_currentTokenId] = _tokenId;
        _boxMap[_currentTokenId] = _boxnum;
        _tokenURI[_currentTokenId] = string(
            abi.encodePacked(
                Strings.toString(_boxnum),
                "/",
                Strings.toString(_classId)
            )
        );
        _ownersMapWithBox[_boxnum][_currentTokenId] = _to;
        _mint(_to, _currentTokenId);
        _boxTotalsupply[_boxnum] += 1;
        _incrementTokenId();
    }

    function _incrementTokenId() private {
        _currentTokenId++;
    }

    function checkOwnerOf(uint256 _boxnum, uint256 _boxTokenId)
        public
        view
        returns (address)
    {
        address owner = _ownersMapWithBox[_boxnum][_boxTokenId];
        return owner;
    }

    function checkTotalSupply(uint256 _boxnum) public view returns (uint256) {
        return _boxTotalsupply[_boxnum];
    }

    function checkBurnSupply(uint256 _boxnum) public view returns (uint256) {
        return _burnTotalsupply[_boxnum];
    }

    function getAllOwner(uint256 _boxnum)
        public
        view
        onlyOwner
        returns (address[] memory)
    {
        address[] memory result = new address[](_boxTotalsupply[_boxnum]);
        for (uint256 i = 0; i < _boxTotalsupply[_boxnum]; i++) {
            result[i] = _ownersMapWithBox[_boxnum][i];
        }
        return result;
    }

    function _transfer(address from, address to, uint256 tokenId) internal override nonReentrant() {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        uint256 _boxnum = _boxMap[tokenId];
        _ownersMapWithBox[_boxnum][tokenId] = to;

        super._transfer(from, to, tokenId);
    }

    function _burnCreature(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function _burn(uint256 tokenId) internal override nonReentrant() {
        delete (_jsonMap[tokenId]);
        delete (_tokenURI[tokenId]);
        uint256 _boxnum = _boxMap[tokenId];
        _ownersMapWithBox[_boxnum][tokenId] = address(0);
        _burnTotalsupply[_boxnum] += 1;
        delete (_boxMap[tokenId]);
        super._burn(tokenId);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Factory {
    function balanceOf(uint256 _tokenId, uint256 _optionId)
        public
        view
        virtual
        returns (bool);
}

library LootBoxRandomness {
    using SafeMath for uint256;

    event LootBoxOpened(
        uint256 indexed optionId,
        address indexed buyer,
        uint256 boxesPurchased,
        uint256 itemsMinted
    );
    event Warning(string message, address account);

    uint256 constant INVERSE_BASIS_POINT = 10000;

    struct OptionSettings {
        uint256 maxQuantityPerOpen;
        uint256[] classProbabilities;
        bool hasGuaranteedClasses;
        uint256[] guarantees;
    }

    struct LootBoxRandomnessState {
        address factoryAddress;
        uint256 numOptions;
        uint256 numClasses;
        uint256 numBox;
        mapping(uint256 => OptionSettings) optionToSettings;
        mapping(uint256 => mapping(uint256 => uint256)) classToTokenIds;
        uint256 seed;
    }

    function initState(
        LootBoxRandomnessState storage _state,
        address _factoryAddress,
        uint256 _numOptions,
        uint256 _numClasses,
        uint256 _numBox,
        uint256 _seed
    ) public {
        _state.factoryAddress = _factoryAddress;
        _state.numOptions = _numOptions;
        _state.numClasses = _numClasses;
        _state.numBox = _numBox;
        _state.seed = _seed;
    }

    function setTokenIdsForClass(
        LootBoxRandomnessState storage _state,
        uint256 _boxId,
        uint256 _classId,
        uint256 _tokenIds
    ) public {
        require(_boxId < _state.numBox, "Box out of range");
        require(_classId < _state.numClasses, "_class out of range");
        _state.classToTokenIds[_boxId][_classId] = _tokenIds;
    }

    function getTokenIdsForClass(
        LootBoxRandomnessState storage _state,
        uint256 _boxId,
        uint256 _classId
    ) public view returns (uint256) {
        require(_boxId < _state.numBox, "Box out of range");
        require(_classId < _state.numClasses, "_class out of range");
        return _state.classToTokenIds[_boxId][_classId];
    }

    function setOptionSettings(
        LootBoxRandomnessState storage _state,
        uint256 _option,
        uint256 _maxQuantityPerOpen,
        uint256[] memory _classProbabilities,
        uint256[] memory _guarantees
    ) public {
        require(_option < _state.numOptions, "_option out of range");

        bool hasGuaranteedClasses = false;
        for (uint256 i = 0; i < _guarantees.length; i++) {
            if (_guarantees[i] > 0) {
                hasGuaranteedClasses = true;
            }
        }

        OptionSettings memory settings = OptionSettings({
            maxQuantityPerOpen: _maxQuantityPerOpen,
            classProbabilities: _classProbabilities,
            hasGuaranteedClasses: hasGuaranteedClasses,
            guarantees: _guarantees
        });

        _state.optionToSettings[uint256(_option)] = settings;
    }

    function getQuantityPerOpen(
        LootBoxRandomnessState storage _state,
        uint256 _option
    ) public view returns (uint256) {
        require(_option < _state.numOptions, "_option out of range");

        return _state.optionToSettings[uint256(_option)].maxQuantityPerOpen;
    }

    function getQuantityGarantee(
        LootBoxRandomnessState storage _state,
        uint256 _option,
        uint256 classId
    ) public view returns (uint256) {
        require(_option < _state.numOptions, "_option out of range");

        return _state.optionToSettings[uint256(_option)].guarantees[classId];
    }

    function setSeed(LootBoxRandomnessState storage _state, uint256 _newSeed)
        public
    {
        _state.seed = _newSeed;
    }

    function _normalMint(
        LootBoxRandomnessState storage _state,
        uint256 _optionId,
        uint256 _boxNum
    ) internal returns (uint256 _tokenId, uint256 _classId) {
        require(_optionId < _state.numOptions, "_option out of range");
        require(_boxNum < _state.numBox, "_boxNum out of range");
        OptionSettings memory settings = _state.optionToSettings[_optionId];

        require(
            settings.maxQuantityPerOpen > 0,
            "LootBoxRandomness#_mint: OPTION_NOT_ALLOWED"
        );

        _classId = (_pickRandomClass(_state, settings.classProbabilities));
        _tokenId = _sendTokenWithClass(_state, _boxNum, _classId);
        
        return (_tokenId, _classId);
    }

    function _mint(
        LootBoxRandomnessState storage _state,
        uint256 _optionId,
        uint256 _randClassId,
        bool hasGuaranteed,
        uint256 _boxNum
    ) internal returns (uint256 _tokenId, uint256 _classId) {
        require(_optionId < _state.numOptions, "_option out of range");
        require(_boxNum < _state.numBox, "_boxNum out of range");
        OptionSettings memory settings = _state.optionToSettings[_optionId];

        require(
            settings.maxQuantityPerOpen > 0,
            "LootBoxRandomness#_mint: OPTION_NOT_ALLOWED"
        );

        if (hasGuaranteed) {
            uint256 randClass = _pickRandomClass(_state, settings.classProbabilities);
            if (randClass > _randClassId) {
                _classId = (randClass);
            } else {
                _classId = (_randClassId);
            }
            _tokenId = _sendTokenWithClass(
                _state,
                _boxNum,
                _classId
            );
        } else {
            _classId = (_pickRandomClass(_state, settings.classProbabilities));
            _tokenId = _sendTokenWithClass(_state, _boxNum, _classId);
        }
        
        return (_tokenId, _classId);
    }

    function _sendTokenWithClass(
        LootBoxRandomnessState storage _state,
        uint256 _boxNum,
        uint256 _classId
    ) internal returns (uint256) {
        require(_classId < _state.numClasses, "_class out of range");
        uint256 tokenId = _pickRandomAvailableTokenIdForClass(
            _state,
            _boxNum,
            _classId
        );
        return tokenId;
    }

    function _pickRandomClass(
        LootBoxRandomnessState storage _state,
        uint256[] memory _classProbabilities
    ) public returns (uint256) {
        uint256 value = uint256(_random(_state).mod(INVERSE_BASIS_POINT));
        for (uint256 i = uint256(_classProbabilities.length) - 1; i > 0; i--) {
            uint256 probability = _classProbabilities[i];
            if (value < probability) {
                return i;
            } else {
                value = value - probability;
            }
        }
        return 0;
    }

    function _pickRandomAvailableTokenIdForClass(
        LootBoxRandomnessState storage _state,
        uint256 _boxNum,
        uint256 _classId
    ) internal returns (uint256) {
        require(_classId < _state.numClasses, "_class out of range");
        uint256 tokenIds = _state.classToTokenIds[_boxNum][_classId];
        require(tokenIds > 0, "No token ids for _classId");
        uint256 randIndex = _random(_state).mod(tokenIds);
        Factory factory = Factory(_state.factoryAddress);
        for (uint256 i = randIndex; i < randIndex + tokenIds; i++) {
            uint256 tokenId = i % tokenIds;
            if (factory.balanceOf(tokenId, _boxNum)) {
                return tokenId;
            }
        }
        revert(
            "LootBoxRandomness#_pickRandomAvailableTokenIdForClass: NOT_ENOUGH_TOKENS_FOR_CLASS"
        );
    }

    function _random(LootBoxRandomnessState storage _state)
        internal
        returns (uint256)
    {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    msg.sender,
                    _state.seed
                )
            )
        );
        _state.seed = randomNumber;
        return randomNumber;
    }
}// MIT

pragma solidity ^0.8.0;


contract LazyMeFactory is FactoryERC721, Ownable, Factory, ReentrancyGuard {
    using LootBoxRandomness for LootBoxRandomness.LootBoxRandomnessState;
    using Strings for string;

    LootBoxRandomness.LootBoxRandomnessState state;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    address public proxyRegistryAddress;
    address public nftAddress;
    address public creatureAddress;
    address private ramdomAddress;
    string public baseURI;

    mapping (uint256 => uint256) public _boxMap;
    mapping (uint256=> uint256) public _supplyMap;

    uint256 BOX_MAX_NUM = 1;
    uint256 NUM_OPTIONS = 4;

    mapping (uint256 => bool) public _pauseSale;

    constructor(address _proxyRegistryAddress, address _creatureAddress, address _ramdomAddress, string memory _baseURI) {
        proxyRegistryAddress = _proxyRegistryAddress;
        baseURI = _baseURI;
        creatureAddress = _creatureAddress;
        ramdomAddress = _ramdomAddress;

        fireTransferEvents(address(0), owner());
    }

    function name() external pure override returns (string memory) {
        return "LazyMe Lootbox";
    }

    function symbol() external pure override returns (string memory) {
        return "LAZY_FAC";
    }

    function supportsFactoryInterface() public pure override returns (bool) {
        return true;
    }

    function numOptions() public view override returns (uint256) {
        return NUM_OPTIONS;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        address _prevOwner = owner();
        super.transferOwnership(newOwner);
        fireTransferEvents(_prevOwner, newOwner);
    }

    function fireTransferEvents(address _from, address _to) private {
        for (uint256 i = 0; i < NUM_OPTIONS; i++) {
            emit Transfer(_from, _to, i);
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        mint(_tokenId, _to);
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setCreatureAddress(address _creatureAddress) public onlyOwner {
        creatureAddress = _creatureAddress;
    }

    function setBoxMaxNum(uint256 _boxNum) public onlyOwner {
        BOX_MAX_NUM = _boxNum;
    }

    function setPauseSale(uint256 _optionId, bool _isPause) public onlyOwner {
        _pauseSale[_optionId] = _isPause;
    }

    function getPauseSale(uint256 _optionId) public view onlyOwner returns (bool pauseSale){
        return _pauseSale[_optionId];
    }

    function setBoxNum(uint256 _optionId, uint256 _boxnum) public onlyOwner {
        _boxMap[_optionId] = _boxnum;
    }

    function getBoxNum(uint256 _optionId) public view onlyOwner returns (uint256 _boxnum){
        return _boxMap[_optionId];
    }

    function setSupplyLimit(uint256 _boxnum, uint256 amount) public onlyOwner {
        _supplyMap[_boxnum] = amount;
    }

    function getSupplyLimit(uint256 _boxnum) public view onlyOwner returns (uint256 amount){
        return _supplyMap[_boxnum];
    }

    function mint(uint256 _optionId, address _toAddress) public override nonReentrant(){
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        assert( address(proxyRegistry.proxies(owner())) == _msgSender() || owner() == _msgSender());

        uint256 _tokenId;
        uint256 _classId;
        uint256 _boxnum = _boxMap[_optionId];

        require(!_pauseSale[_optionId],"This optionID is Pause sale");
        
        if(_optionId == 0) {
            require(canMint(_boxnum, 1),"CreatureFactory#_mint: CANNOT_MINT_MORE");
            (_tokenId, _classId) = LootBoxRandomness._normalMint(state, _optionId , _boxnum);
            mintItem(_boxnum, _tokenId, _toAddress, _classId);
        } else {
            speacialMint(_optionId, _toAddress);
        }
    }

    function speacialMint(uint256 _optionId, address _toAddress) private {
        uint256 _tokenId;
        uint256 _classId;
        uint256 _boxnum = _boxMap[_optionId];

        LootBoxRandomness.OptionSettings memory settings = state.optionToSettings[_optionId];
        uint256 amount = state.optionToSettings[_optionId].maxQuantityPerOpen;
        require(
            canMint(_boxnum, amount),
            "CreatureFactory#_mint: CANNOT_MINT_MORE"
        );

        uint256 guaranteeAmount = 0;
        for (uint256 randClassId = 0; randClassId < settings.guarantees.length; randClassId++) {
            uint256 quantityOfGuaranteed = settings.guarantees[randClassId];
            if (quantityOfGuaranteed > 0) {
                for (uint256 j = 0; j < quantityOfGuaranteed; j++) {
                    if(guaranteeAmount < amount) {
                        (_tokenId, _classId) = LootBoxRandomness._mint(state, _optionId, randClassId, true, _boxnum);
                        mintItem(_boxnum, _tokenId, _toAddress, _classId);
                        guaranteeAmount += 1;
                    }
                }
            }
        }

        for (uint256 randAmount = 0 + guaranteeAmount; randAmount < amount; randAmount++) {
                (_tokenId, _classId) = LootBoxRandomness._mint(state, _optionId, 0, false , _boxnum);
                mintItem(_boxnum, _tokenId, _toAddress, _classId);
        }
    }
    
    function mintBox(uint256 _optionId, address _toAddress) public onlyOwner {
        emit Transfer(address(0), _toAddress, _optionId);
    }

    function mintItem(uint256 _boxnum, uint256 _tokenId, address _toAddress, uint256 _classId) private {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        assert( address(proxyRegistry.proxies(owner())) == _msgSender() || owner() == _msgSender());
        require(
            canMint(_boxnum, 1),
            "CreatureFactory#_mint: CANNOT_MINT_MORE"
        );

        LazyMe lazyMeCreature = LazyMe(
            creatureAddress
        );
        lazyMeCreature.mintTo(_toAddress, _boxnum, _tokenId, _classId);
    }

    function balanceOf(uint256 _boxTokenId, uint256 _boxnum)
        public
        view
        override
        returns (bool)
    {
        LazyMe lazyMeCreature = LazyMe(
            creatureAddress
        );
        address owner = lazyMeCreature.checkOwnerOf(_boxnum, _boxTokenId);
        if(owner != address(0)){
            return false;
        } else {
            return true;
        }
    }
    
    function tokenURI(uint256 _optionId)
        external
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, Strings.toString(_optionId)));
    }

    function setState(
        address _factoryAddress,
        uint256 _numOptions,
        uint256 _numClasses,
        uint256 _numBox,
        uint256 _seed
    ) public onlyOwner {
        LootBoxRandomness.initState(
            state,
            _factoryAddress,
            _numOptions,
            _numClasses,
            _numBox,
            _seed
        );
    }

    function setTokenIdsForClass(uint256 _optionId, uint256 _classId, uint256 _tokenIds)
        public
        onlyOwner
    {
        LootBoxRandomness.setTokenIdsForClass(state, _optionId, _classId, _tokenIds);
    }

    function getQuantityPerOpen(
        uint256 _option
    ) public onlyOwner returns (uint256){
        return LootBoxRandomness.getQuantityPerOpen(
            state,
            _option
        );
    }

    function getQuantityGarantee(
        uint256 _option,
        uint256 classId
    ) public onlyOwner returns (uint256){
        return LootBoxRandomness.getQuantityGarantee(
            state,
            _option,
            classId
        );
    }

    function setOptionSettings(
        uint256 _option,
        uint256 _maxQuantityPerOpen,
        uint256[] memory _classProbabilities,
        uint256[] memory _guarantees
    ) public onlyOwner {
        LootBoxRandomness.setOptionSettings(
            state,
            _option,
            _maxQuantityPerOpen,
            _classProbabilities,
            _guarantees
        );
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        if (owner() == _owner && _owner == _operator) {
            return true;
        }

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (
            owner() == _owner &&
            address(proxyRegistry.proxies(_owner)) == _operator
        ) {
            return true;
        }

        return false;
    }

    function canMint(uint256 _boxnum, uint256 _amount) public view override returns (bool) {
        if (_boxnum >= BOX_MAX_NUM) {
            return false;
        }

        uint256 _supplyMax = _supplyMap[_boxnum];

        LazyMe lazyMeCreature = LazyMe(
            creatureAddress
        );
        uint256 creatureSupply = lazyMeCreature.checkTotalSupply(_boxnum);

        return creatureSupply < ( _supplyMax - _amount);
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return owner();
    }
}