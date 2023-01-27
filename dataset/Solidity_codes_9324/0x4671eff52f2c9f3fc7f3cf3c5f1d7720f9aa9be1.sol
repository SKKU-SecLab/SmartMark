
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
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

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);


  function approve(address spender, uint256 value) external returns (bool success);


  function balanceOf(address owner) external view returns (uint256 balance);


  function decimals() external view returns (uint8 decimalPlaces);


  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);


  function increaseApproval(address spender, uint256 subtractedValue) external;


  function name() external view returns (string memory tokenName);


  function symbol() external view returns (string memory tokenSymbol);


  function totalSupply() external view returns (uint256 totalTokensIssued);


  function transfer(address to, uint256 value) external returns (bool success);


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);


  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);

}// MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {

  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );


  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);


  function createSubscription() external returns (uint64 subId);


  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );


  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;


  function acceptSubscriptionOwnerTransfer(uint64 subId) external;


  function addConsumer(uint64 subId, address consumer) external;


  function removeConsumer(uint64 subId, address consumer) external;


  function cancelSubscription(uint64 subId, address to) external;

}// MIT
pragma solidity ^0.8.0;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}//MIT
pragma solidity 0.8.9;

contract EIP712Base {
    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 salt;
    }

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            bytes(
                "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"
            )
        );

    bytes32 internal domainSeparator;

    constructor(string memory name, string memory version) {
        domainSeparator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                address(this),
                bytes32(getChainID())
            )
        );
    }

    function getChainID() internal view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    function getDomainSeparator() private view returns (bytes32) {
        return domainSeparator;
    }

    function toTypedMessageHash(bytes32 messageHash)
        internal
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", getDomainSeparator(), messageHash)
            );
    }
}//MIT
pragma solidity 0.8.9;


contract EIP712MetaTransaction is EIP712Base {
    using SafeMath for uint256;
    bytes32 private constant META_TRANSACTION_TYPEHASH =
        keccak256(
            bytes(
                "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
            )
        );

    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );
    mapping(address => uint256) private nonces;

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    constructor(string memory name, string memory version)
        EIP712Base(name, version)
    {}

    function convertBytesToBytes4(bytes memory inBytes)
        internal
        pure
        returns (bytes4 outBytes4)
    {
        if (inBytes.length == 0) {
            return 0x0;
        }

        assembly {
            outBytes4 := mload(add(inBytes, 32))
        }
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public payable returns (bytes memory) {
        bytes4 destinationFunctionSig = convertBytesToBytes4(functionSignature);
        require(
            destinationFunctionSig != msg.sig,
            "functionSignature can not be of executeMetaTransaction method"
        );
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
        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );

        require(success, string(returnData));
        emit MetaTransactionExecuted(
            userAddress,
            payable(msg.sender),
            functionSignature
        );
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

    function getNonce(address user) external view returns (uint256 nonce) {
        nonce = nonces[user];
    }

    function verify(
        address user,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {
        address signer = ecrecover(
            toTypedMessageHash(hashMetaTransaction(metaTx)),
            sigV,
            sigR,
            sigS
        );
        require(signer != address(0), "Invalid signature");
        return signer == user;
    }

    function msgSender() internal view returns (address sender) {
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
            sender = msg.sender;
        }
        return sender;
    }
}//UNLICENSED
pragma solidity 0.8.9;


contract DGFamilyCollection is
    ERC721URIStorage,
    Ownable,
    EIP712MetaTransaction
{
    using Strings for uint256;
    using SafeMath for uint256;

    string private baseURI;
    uint256 public constant MAX_PUBLIC_SUPPLY = 5000;
    uint256 public totalSupply;
    uint256 public royaltyPercentage;
    address public glassBoxContract;
    address public privateSaleContract;
    mapping(uint256 => bool) public privateSaleTokenIds;

    event RoyaltyPercentageChanged(uint256 indexed newPercentage);
    event BaseUriUpdated(string indexed uri);


    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        string memory _baseUri,
        uint256 _royaltyPercentage,
        uint256[] memory _privateSaleTokenIds
    )
        ERC721(tokenName, tokenSymbol)
        EIP712MetaTransaction("NftCollectionBatch", "1")
    {
        baseURI = _baseUri;
        royaltyPercentage = _royaltyPercentage;
        for (uint256 i = 0; i < _privateSaleTokenIds.length; i = i.add(1)) {
            privateSaleTokenIds[_privateSaleTokenIds[i]] = true;
        }
    }

    modifier onlyGlassBoxOrOwnerOrPrivateSale() {
        require(
            glassBoxContract == msgSender() || owner() == msgSender() || privateSaleContract == msgSender(),
            "UNAUTHORIZED_ACCESS"
        );
        _;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
        emit BaseUriUpdated(baseURI);
    }

    function setRoyaltyPercentage(uint256 _percentage) external onlyOwner {
        royaltyPercentage = _percentage;

        emit RoyaltyPercentageChanged(royaltyPercentage);
    }

    function generate(address destination, uint256 tokenIndex)
        external
        onlyGlassBoxOrOwnerOrPrivateSale
        returns (uint256)
    {
        require(destination != address(0), "ADDRESS_CAN_NOT_BE_ZERO");
        require(
            totalSupply < MAX_PUBLIC_SUPPLY,
            "MAX_PUBLIC_SUPPLY_REACHED"
        );
        if ((privateSaleContract == msgSender()) || (owner() == msgSender())) {
            require(
                privateSaleTokenIds[tokenIndex],
                "PRIVATE_SALE_PERMISSION_DENIED"
            );
        }
        totalSupply = totalSupply.add(1);
        _safeMint(destination, tokenIndex);
        return tokenIndex;
    }

    function getRoyaltyInfo(uint256 _price)
        external
        view
        returns (uint256 royaltyAmount, address royaltyReceiver)
    {
        require(_price > 0, "PRICE_CAN_NOT_BE_ZERO");
        uint256 royalty = (_price.mul(royaltyPercentage)).div(100);

        return (royalty, owner());
    }

    function setGlassBoxContract(address _address) external onlyOwner {
        glassBoxContract = _address;
    }

    function setPrivateSaleContract(address _address) external onlyOwner {
        privateSaleContract = _address;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721URIStorage)
        returns (string memory)
    {
        if (totalSupply == 0) {
            return _baseURI();
        }
        require(_exists(_tokenId), "TOKEN_DOES_NOT_EXIST");

        return string(abi.encodePacked(_baseURI(), _tokenId.toString()));
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(msgSender(), tokenId),
            "CALLER_NOT_APPROVED"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(msgSender(), tokenId),
            "CALLER_NOT_APPROVED"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function renounceOwnership() public view override onlyOwner {
        revert("CAN_NOT_RENOUNCE_OWNERSHIP");
    }


    function approve(address to, uint256 tokenId) public virtual override {
        address tokenOwner = ERC721.ownerOf(tokenId);
        require(to != tokenOwner, "ERC721:APPROVAL_TO_CURRENT_OWNER");

        require(
            msgSender() == tokenOwner ||
                isApprovedForAll(tokenOwner, msgSender()),
            "ERC721:APPROVE_CALLER_NOT_OWNER_OR_APPROVED_FOR_ALL"
        );

        _approve(to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}//UNLICENSED
pragma solidity 0.8.9;



contract DGFamilyGlassBox is
    ERC721URIStorage,
    Ownable,
    EIP712MetaTransaction,
    VRFConsumerBaseV2,
    ReentrancyGuard
{
    using Strings for uint256;
    using SafeMath for uint256;

    uint16[] public seed = [1982,739,329,2506,4524,4704,4814,3891,2602,2490,3157,4885,2933,4976,1081,581,3689,3884,3543,3842,4142,459,1318,1127,1461,4650,1351,1108,777,4114,4411,1530,1244,4376,2414,4075,2286,2380,3972,2420,4314,3824,3430,4308,491,3452,440,1532,2000,2004,856,1812,3967,3533,2045,1203,3260,1770,1873,277,1314,2502,634,3953,2465,2471,3635,4003,1768,3657,4713,2464,3994,2835,1181,3387,4515,1022,723,2144,2669,4329,611,4226,1551,3300,4959,3105,325,3568,3650,4792,3400,1672,4293,4387,4591,3943,1922,2632,2383,1212,4196,2336,137,1284,2972,2294,2926,419,900,3490,2702,2213,4550,4210,4184,1695,3028,1913,3909,4219,1055,2351,1923,3512,3252,961,4581,802,2338,3145,3863,2682,3679,1225,1280,2649,1330,2064,2910,4415,4577,3916,4034,3336,1698,4574,3547,2656,3254,3000,4449,4397,4047,1851,484,2511,1715,1370,1419,4123,960,1712,2493,3869,2214,1586,1125,3807,1092,4276,2115,2781,2335,3797,3627,165,2979,1533,4110,3858,4364,2805,4652,4145,4883,4863,959,4815,2151,2517,4115,3843,1360,3988,4944,463,3036,1619,4060,626,2252,2706,2855,4183,2551,1363,3287,3762,2154,1078,4816,3160,4005,4306,1664,679,2954,2242,4008,725,2008,3444,307,2598,2999,174,3043,4750,4942,804,2267,2293,83,3589,1501,1412,1058,3605,1068,3816,3859,3900,2634,534,4663,762,1261,3131,4084,2067,4995,2296,878,3272,2364,4583,1792,2514,898,81,3309,881,1806,1131,1909,3277,138,1771,521,3022,203,4957,4731,1494,1159,4407,3381,391,327,939,1392,2853,4136,1731,134,1333,710,248,3436,4349,4181,3698,1520,2412,3258,1458,3425,563,542,1285,1478,1408,3806,3787,2526,4447,3721,4560,3991,1624,3067,1841,2928,1298,360,1060,615,3371,975,48,924,4831,1590,3643,4682,3322,4910,4953,3801,3873,3729,866,973,582,1282,4602,1544,3694,2863,2750,941,1579,1847,585,1825,1192,1155,4057,1391,3504,2794,362,4365,2995,4541,1647,1437,2413,1785,3138,1576,2530,3491,240,2422,2840,3155,2310,4690,483,1186,4997,1820,1434,3745,510,1308,1206,97,1445,2223,2023,4645,987,2857,1657,2181,4379,4138,4277,431,4505,3486,2816,2749,3421,3435,630,1705,3071,1299,4066,981,2468,2977,1254,1228,4199,1233,2695,4511,2836,4729,3132,4299,547,3507,3077,197,2406,382,3324,253,4435,2913,2982,1523,1042,98,1279,4620,4232,1278,3788,2041,3699,4171,4632,105,4952,2106,4044,1149,1492,1365,2087,3455,4268,2730,2873,2694,1562,4634,3583,2731,1780,4822,1782,4758,1334,296,103,4772,208,189,2691,449,2878,2219,995,1652,2035,114,696,291,1453,4283,2469,4091,3646,2714,2581,194,4941,1502,1482,3493,3935,758,2117,2301,1987,2801,3754,2432,3274,1767,4636,2271,4400,2316,3166,2898,82,948,2342,4987,4784,3087,2368,2520,3195,4147,1634,4383,3103,3813,374,3135,3626,3914,4933,3722,436,4968,476,202,2437,4346,1510,1324,2195,71,418,2893,1410,3056,1905,2636,4585,1917,848,3571,4187,4290,544,2220,2906,4639,4730,953,321,4593,4594,241,2049,1100,1522,1152,2932,1584,2556,3714,807,2344,1725,3771,3123,937,62,4683,2567,3753,4320,785,2537,3828,3339,3063,513,790,3883,3919,1143,952,870,3550,4370,2016,2311,4889,2480,4605,3271,257,3737,4829,4036,3017,1822,683,1934,2202,3625,1033,4681,1660,1387,928,2235,2429,2653,825,4113,4961,3775,2994,1145,1489,4966,1327,1539,4448,4791,3704,968,2618,4835,2947,3211,3544,4394,2819,1843,1994,2326,2668,4733,2444,2174,1459,603,849,753,3382,2279,3564,2789,3031,1114,73,3233,3594,4434,254,3081,2676,3276,2329,3178,3481,3107,4766,2849,4898,3165,3534,141,59,330,3705,4143,2531,4556,543,2975,1388,2047,2780,4589,1650,2983,3340,283,2862,2216,3094,3848,2450,3653,761,3227,1176,4700,199,1691,1118,1582,922,3767,1856,811,1182,4543,2442,4744,4990,4923,1999,4190,2454,308,2425,4444,4770,4310,1739,1080,245,624,4646,2478,4569,1472,2472,3222,4530,2964,2631,2763,3251,389,2260,4102,2489,2762,3289,1427,4201,4539,2321,3035,4390,3514,4954,4261,914,2619,3538,4342,1306,2738,485,3569,693,3232,3680,984,4271,3137,4369,1372,343,2384,285,2597,1439,3197,4432,359,781,1375,172,1749,4549,3736,3203,185,4629,3204,1267,1928,1493,3118,4212,1593,2667,1699,445,602,810,1985,4104,755,3755,4464,4980,3257,926,1648,3551,3062,2052,4446,3262,2914,1608,2470,2175,4691,4068,1303,3263,473,537,3759,1386,2247,4146,3027,2937,398,4782,1973,2146,4211,4536,3315,1726,3793,962,1264,1071,4059,2698,1260,4736,4317,954,2569,242,1018,4203,3172,3572,4072,2014,3199,226,1636,1550,2160,2881,1497,686,1742,181,4103,2130,357,1897,3110,947,4827,4288,1732,3372,2011,2317,3658,1556,1052,3996,4894,460,2739,272,413,2377,1028,4624,4258,1718,3691,3428,1171,3112,3268,2399,2859,4847,2681,2692,1621,3255,1823,4479,631,4897,4476,2449,4790,376,2095,3218,2962,4238,1561,1703,4506,2145,4130,3665,1754,2395,2509,239,1347,605,2021,1304,1602,2949,3932,3465,1026,3323,3440,2098,4374,2733,3634,403,3116,3990,2729,3928,839,2249,907,2270,2677,2261,3766,815,3226,1775,1357,2020,353,4930,2589,2657,3866,1701,1626,1027,4077,2800,3299,1491,4494,3416,4779,3337,2108,4015,2770,1744,421,1349,1241,1123,1090,681,3221,2843,3184,735,2375,1290,3423,3237,4958,3836,3005,1547,2093,4689,2813,3096,3390,976,3862,1727,3969,1571,4762,4338,4126,4315,2229,3407,3414,2183,985,4220,3212,1148,4603,1289,1563,122,2611,2563,344,2693,3789,3537,2679,872,4875,379,2769,2904,2939,882,1620,1629,1878,3069,247,2829,3683,409,4586,2911,1471,4046,3642,3383,3007,1988,1216,3106,1037,1972,2903,3662,1700,1021,1266,2080,2790,1888,2663,86,2582,3822,859,4865,1135,996,3453,1061,4107,4208,3117,3530,861,3854,3182,3068,2578,3908,899,1777,978,578,4886,4433,4592,429,3325,2723,935,4544,2486,3835,444,2193,3867,1237,148,1816,1361,2573,2178,3159,2157,2328,368,2234,712,4793,3450,2415,664,1756,273,4019,4765,3021,507,1681,2211,3220,2027,4485,3844,271,428,4820,472,120,1047,3685,1094,4915,3366,2541,1631,3707,1312,3174,910,408,1311,1069,4975,3670,4493,4635,3716,149,1464,4956,1323,4783,235,4481,1671,4207,1371,4611,4527,2806,4676,4879,367,4571,3238,850,3298,4726,2461,1991,95,2612,2887,2231,1665,4841,1188,3621,3820,1044,1964,852,2104,1043,1804,1173,969,2428,2852,2613,349,1603,3697,3638,1442,1366,2699,498,4426,3427,4913,1339,3219,2285,4122,891,531,4561,1142,3104,160,2284,2837,385,223,583,1947,4422,465,668,3037,1622,4245,3113,3556,348,2244,1019,1029,4105,3224,4509,1835,3827,2834,2096,4798,1505,4257,4474,2900,4401,1861,3817,3558,4600,1645,4182,687,3541,3193,2462,136,3633,1736,4093,3095,1846,1219,663,1553,2799,897,854,1567,1554,1384,2605,1531,4513,3080,4027,2291,3185,2167,3825,355,738,1301,4131,970,559,3821,3351,4922,2929,1779,1008,3168,2680,3904,4710,92,4388,4672,2268,1961,1638,2272,131,3812,4007,4333,519,3051,4339,4760,4868,4162,613,4937,126,3622,791,1892,3437,4562,108,3772,774,452,1908,4035,3295,2617,4609,3865,4425,1197,4157,4969,354,4393,4794,2783,2720,358,934,4525,4234,4484,1256,229,2674,1085,3102,3109,2028,4846,1331,1024,1251,1642,728,4854,2128,4160,220,523,4614,1309,2273,1185,2350,4533,1802,2498,3266,1697,2484,1297,4359,3933,765,2243,3294,1015,3948,4647,2269,2105,4278,3246,2212,299,3945,4297,1591,2851,3180,3877,564,1355,1710,797,3923,812,2076,378,688,1803,2441,180,3023,1676,3949,1190,4193,3576,2917,597,276,3244,4752,1463,4654,680,2547,575,4498,1223,1852,1980,2038,2924,844,745,3957,4086,1979,3401,3595,3004,1077,352,474,971,4361,350,4021,90,411,731,256,4860,2481,4535,3673,2934,3242,1772,4492,826,3874,783,4064,3020,430,2078,3415,1097,3259,1234,4295,3147,614,3353,2330,4243,3173,3075,4112,2970,4964,3925,1500,76,4523,857,586,3024,2628,911,1977,1300,3645,4418,4517,682,4141,1268,480,1187,468,265,2879,2057,1653,3579,1545,1837,2719,1307,2060,991,4522,113,4095,3942,2403,2149,2705,1870,4231,1036,3879,4597,1242,3678,426,3800,4716,309,2974,3032,1430,3256,3040,604,4356,4127,2670,361,2387,4304,218,3397,2488,4380,1543,2124,4725,963,1659,1766,3446,1855,1864,892,3962,3809,2847,2362,2205,3388,3922,3319,4451,860,1824,116,1054,2624,4692,2411,567,1692,4595,3659,4247,675,1938,1574,167,4623,2518,1295,1320,1679,268,3194,3146,2473,4172,2640,654,1422,4625,3142,4089,1658,3808,2177,3954,2239,3718,4668,2308,591,315,3603,4849,1273,2046,1103,1128,4368,2081,2830,540,3739,4626,3559,4578,2576,3764,943,267,1787,3030,871,2094,2485,3847,3245,771,3347,2512,2978,3768,217,3887,3845,3190,4722,767,988,4098,1329,3369,1941,1031,2356,2540,3210,1446,1259,3492,372,3700,2854,396,3307,282,339,2072,596,3555,4176,1121,2409,3770,4951,4244,2894,684,685,3496,4140,3982,1088,4548,4316,2192,264,628,2088,3676,1321,2734,1073,3536,2654,894,384,1737,4657,1483,79,3488,3839,1828,1178,4463,1238,3125,4092,4256,1328,2500,2897,4706,904,2895,3757,2861,732,2599,923,1095,1084,972,642,1833,1200,4416,599,2194,1685,1046,338,186,1838,1070,865,1163,3053,3655,1460,4839,486,4168,2793,800,2074,2560,1517,2665,499,1112,4164,806,4006,1939,2561,475,4708,632,1305,3432,1168,3868,1253,3318,716,100,571,1906,2985,2361,4996,4437,1907,3346,244,144,1689,4266,1287,2355,2245,392,4431,2110,2884,2572,1845,3644,863,3208,3419,893,4512,2539,1476,3320,3153,4640,4009,3979,2522,3223,594,1874,2155,478,1064,1157,2447,2885,4621,1839,2007,3581,1034,2998,1853,1911,3418,2950,346,1723,224,2546,1881,3019,656,1221,4773,2760,3973,4398,620,913,4331,1496,3384,4325,3511,135,2768,1557,673,3395,4781,780,1195,2759,292,3368,2419,4367,4938,2376,715,3396,1326,1383,184,587,3682,4087,3931,1891,263,1252,1479,2960,3777,347,1294,1826,3499,757,2297,3273,1120,1429,2024,2061,3710,3885,1104,1751,3393,4842,4495,4327,1945,269,951,4714,4653,3615,2352,3964,908,2165,4807,4267,1438,1503,4502,1729,2942,737,3915,4606,1537,3344,219,3701,188,4737,1546,3610,2554,492,3647,3506,4026,4921,3086,335,3712,4534,2276,877,2388,4935,659,727,3695,4471,530,3191,4094,2838,3380,539,1840,3016,1343,4178,422,1106,3516,290,2848,2992,2869,2864,3703,3934,4477,4677,3341,4916,565,130,4661,4074,2558,2779,2029,4575,858,3413,1560,4312,512,4223,2944,2622,4490,2527,3164,3128,1183,590,4303,1010,332,3314,4462,697,2655,2186,3886,1848,4040,3161,3897,2525,2651,2044,2264,3779,1643,4873,3668,2224,4851,1540,786,4926,1875,1342,433,4909,4810,2391,4472,4125,1616,3464,2263,1504,1776,3472,3881,751,1717,1513,375,2238,4225,577,3002,1919,3375,2445,316,3365,669,3740,1598,2776,297,2557,2082,1208,820,788,702,1124,318,3151,3607,658,443,1836,4011,2955,3763,4358,4892,1374,4340,4215,2164,266,2389,2034,4555,1518,1470,1524,2253,1205,145,1377,417,4504,3774,2332,2877,3838,903,966,526,4684,4988,4042,2168,3279,1255,230,4081,1398,1609,412,1249,1635,3612,1797,481,4108,3815,3187,2233,399,1585,1111,4828,639,1527,3872,404,3590,4545,4853,3520,1741,919,2716,221,901,4866,2936,3518,2986,1338,4742,3726,2018,1368,637,2135,4192,3189,312,225,2726,4582,420,1210,4389,1451,4109,4823,1041,393,1432,4200,3826,171,3296,3150,1487,3304,831,3426,1759,3539,916,2583,1201,156,3206,885,822,4440,2747,2876,4250,1269,3756,4630,4570,2398,2688,2591,4801,2961,3898,1526,3014,3420,2492,4384,4870,1706,3941,1435,4950,2114,1788,1396,4465,2984,4588,4755,2017,2315,4806,1086,552,423,4205,1337,3529,3089,3479,3769,4642,1915,1783,4055,1162,2182,4496,1115,1101,1716,1456,3154,1172,4206,864,795,2139,1910,1179,1745,2844,3938,4510,1072,4135,4012,1552,1669,380,1981,3029,4764,2491,3527,3352,1485,340,2077,336,3687,4185,4745,2025,1793,3213,2322,3692,2754,2940,2129,4204,2150,1644,1270,2808,1743,207,4984,538,1013,3663,1651,2807,3144,4177,3983,1730,4862,2068,3906,1413,1414,2871,4023,2666,3391,3064,1293,1757,456,1367,1000,1789,4302,4151,895,4579,2373,302,1568,4242,4443,1462,3798,3278,1807,2659,535,3306,4649,3732,3378,4900,5000,946,4323,3373,711,3574,177,3654,4170,4457,518,875,979,1379,4285,139,2804,667,3025,2169,1226,4608,4929,4821,2185,1154,1623,2112,3409,2153,3761,958,3328,2907,4743,3297,2086,259,2644,734,4939,1498,660,1475,4031,1817,3671,94,4641,3335,2030,2295,2070,3292,1380,1395,1240,1421,3870,2604,1693,2309,2246,1808,549,289,4321,3084,2516,3580,4693,3308,929,1296,880,994,2922,4727,3467,1473,1929,4763,2543,1713,2784,4079,592,4615,3119,2457,187,72,2171,2621,1818,68,2559,1005,3785,588,569,1409,566,950,448,1344,204,2773,4450,3350,809,4396,1275,3652,3234,832,706,3261,4227,2479,1769,2319,1575,2307,390,938,3513,2858,736,1440,4313,3100,2938,2372,2303,2378,1765,666,827,4420,3837,4809,665,1735,1827,580,3083,677,4106,3410,1017,740,1102,2248,4382,1755,4254,4063,4466,4826,1904,1606,3731,2382,4275,4132,3291,1746,2802,4292,3079,1748,3917,1549,295,2191,3624,763,3469,1834,4402,2991,3567,2767,2393,2013,1230,3475,838,1170,2091,4882,2102,4062,3834,2727,1733,4259,3546,191,281,999,782,1193,3358,742,2645,2981,608,1704,3065,942,4856,2856,3059,215,2324,2188,3681,1958,3892,2113,1974,381,4728,4454,3796,692,179,4097,1661,4209,3792,4757,334,4328,3735,4761,1962,609,1983,3902,1656,1231,4442,884,3773,4843,2386,3101,3709,1863,550,1633,2431,1778,2590,4998,127,3880,2392,2638,4850,2390,3896,2965,4381,2700,1687,4631,1358,371,2718,3519,2593,2586,3598,3963,2339,4024,1402,1415,2577,3713,709,2402,3048,4282,1096,889,4662,3743,514,1014,2340,4048,4749,323,3478,4372,4085,4139,3563,3050,405,1426,2262,3152,2288,600,3377,2513,1040,3629,4797,2189,834,4439,2161,3742,4924,1196,2782,370,1469,3602,4638,2348,3045,2968,1079,1535,2460,560,3628,500,2571,4054,3057,1248,1302,2615,4161,4326,3672,678,3802,1137,2084,4073,4311,2133,701,2056,814,2635,515,3531,4724,3462,1113,324,3631,3376,2127,4152,1310,1566,821,1666,3570,4335,3198,2320,3981,4453,3445,2658,1992,1117,4217,2476,63,1800,3039,2051,4409,3250,4274,4022,3810,3134,1618,182,1588,3814,2883,4030,4590,3566,930,617,2032,70,874,3441,940,1158,4001,4812,4038,1418,4799,3554,3505,1680,3750,3577,805,1857,2764,833,462,1087,801,4000,3143,2545,104,2083,293,2085,2006,4202,2236,4404,246,3176,789,1565,3247,1403,1936,2417,1516,482,249,4832,3549,2265,328,2803,4118,2043,3760,4627,4658,1406,4216,4872,3525,3677,4165,1336,570,4927,3281,4616,1995,1728,1003,3431,4753,4845,2923,2121,503,211,2504,1862,1417,2230,3910,4679,1684,867,124,4788,896,3348,579,2987,1686,1214,446,3360,4838,3829,1016,4878,977,2289,447,3186,2880,998,1405,4601,2459,4039,956,1605,754,1023,4405,4262,853,2400,3449,3724,3738,517,965,1604,2534,1511,2510,3412,1933,4117,2550,434,2905,1564,3140,1397,4065,2079,4553,4584,1536,2822,2710,2902,1452,107,3690,337,2792,4651,2435,4236,4598,3748,4613,1394,2012,2633,388,2170,4972,2111,4903,2980,4345,4777,3952,4248,140,3875,2818,4090,4891,730,4399,3085,1525,4531,4041,1011,3744,4778,2349,1335,1969,986,1955,2927,982,2163,589,2463,439,4241,3501,845,1682,1762,3330,4912,2179,3357,1617,1714,4497,2796,3433,3985,622,3121,3907,1573,2912,1831,3399,4412,3955,1641,3980,1989,3893,2222,2280,1871,154,2515,4711,4013,1133,2650,1488,3974,1045,1667,4385,1696,572,2701,505,497,3855,3976,2712,855,1615,3664,2722,4644,529,1194,1721,2809,123,4818,722,3267,3231,3747,647,4322,2203,3442,1257,2687,4343,1578,2675,2254,4840,1577,2711,3727,905,3447,4643,2916,2100,2609,689,4970,983,3216,3317,2870,3540,495,2812,1529,425,132,2627,671,1896,616,2092,159,2548,3575,1007,3127,3749,489,2497,4803,584,3477,1447,2908,989,4529,2777,1997,4558,170,3044,3460,1105,4436,2595,1688,4337,1009,4269,2538,2066,3588,2298,2626,3283,1799,1819,1872,2026,2724,3636,4813,4305,4235,766,4230,2901,2503,2367,142,2131,4373,3124,1512,129,1752,636,4622,4718,493,4659,1424,4967,4887,1628,4925,3901,2033,441,3930,2325,4540,4516,4428,3402,3927,1613,435,2292,3149,190,2728,902,3355,2090,1935,3649,2416,835,322,3434,4739,1747,3136,2440,106,250,1986,2042,4707,3818,2405,4709,3169,373,3009,2436,876,152,1180,326,2620,2467,3587,1724,1946,3288,3282,4076,2865,3585,4100,927,2875,4948,3911,676,3711,3523,4352,1654,2359,3230,2208,2772,3214,2240,80,4618,4445,2574,4088,4195,1286,1139,401,561,4377,4985,4307,4702,1153,4945,1416,3548,88,3899,65,576,1316,1960,2446,4675,726,1811,3999,3741,1354,3329,4552,3385,655,4392,4071,650,4901,2642,1786,2827,3090,4741,3944,2751,4301,4263,1345,4148,4688,402,4685,784,4294,4888,1382,4438,1890,3162,3379,4869,3010,1930,1359,3674,3648,1509,231,4334,2715,2031,4417,2890,2662,1006,3331,2673,3066,4286,288,2505,1083,2766,4194,3619,490,2448,96,1854,4363,4551,1595,1877,3179,1109,183,364,477,593,4768,1570,4175,2736,1407,2162,2109,2652,2660,4747,209,2116,119,1976,1271,619,3466,1191,1655,4715,2443,3986,2166,1592,1352,4908,3454,1998,4129,3993,453,2158,1420,2956,646,1053,1805,3895,4936,3013,548,3666,1056,2241,1720,993,4229,212,651,2053,1499,1601,3229,3463,3565,3217,2394,3667,3482,944,4918,4353,4824,1001,2811,3209,1246,2069,1927,2643,4289,4965,2896,2401,3042,4080,4069,787,365,1199,4940,1075,274,703,4355,3156,2421,3474,2482,2282,1559,2283,3617,3639,4134,2685,4962,4911,4811,3936,2788,4296,717,3823,817,1953,1263,2495,3929,3864,3181,168,568,3456,2299,1607,4017,3097,110,4043,3139,4429,1449,4251,4705,310,4051,2381,3239,2533,2785,162,1627,1639,427,279,4805,1441,3470,2791,733,918,1646,3099,2614,1683,4991,886,1506,3992,3126,836,2690,2989,4855,3122,1288,4010,997,741,4478,284,317,4932,2973,2775,3170,4410,1004,3001,1901,3058,1521,1957,3386,2996,213,2521,2001,3398,3856,1903,1177,2226,3937,4723,494,555,1222,4270,1719,4830,3008,4458,3088,3522,4150,2228,4360,2197,3215,2126,3356,4233,2346,1912,414,2741,4413,828,4703,4992,238,4696,4351,2507,4617,3561,2159,2584,3995,2187,3965,1098,4789,1858,2397,146,3111,743,601,1332,4198,525,4880,2637,2278,4537,2499,1116,3498,4249,621,1224,341,1217,1385,3725,1709,4983,3280,3183,3429,4971,1378,2771,2966,1810,2990,1971,957,3924,1815,2353,4721,1039,1722,3461,125,3417,4214,1239,457,532,2608,1763,2697,2639,1794,3141,2062,1951,206,2594,1599,454,1151,3243,3303,520,4720,3448,2019,3424,4222,2725,4687,2120,3946,1859,1450,4332,2696,980,369,3012,1632,4599,2580,471,2250,4756,627,4596,3133,2872,2815,3958,4666,173,2585,4974,3819,278,1126,3596,1136,4330,4319,1089,4375,2737,2347,2713,1528,1428,1784,176,2795,3706,56,3786,2404,4371,2587,3241,3484,2275,3959,4169,1668,2010,1990,4189,690,3591,3830,1814,4083,2758,255,2073,261,1373,4280,1161,2433,4566,3656,4284,633,2237,1952,4124,111,3411,2536,2005,4049,3497,2918,461,818,4699,2360,3326,4717,1996,74,163,1600,4480,2314,1538,3114,3606,2899,1144,4133,837,1860,1949,541,1832,1984,3846,1189,2039,4128,3364,3987,2152,2036,4701,3966,3033,2274,275,4943,4771,4067,4610,4166,1663,3438,1707,1813,458,4395,4671,4336,2055,1876,4546,1166,3799,3553,3200,4354,232,4928,2455,2752,356,1886,4045,4748,3526,4163,3977,1076,4475,1868,2089,2592,724,4858,2786,4612,1258,1548,3302,3363,1581,662,1740,210,4774,3049,2920,4240,606,2743,1882,1051,3489,1791,4680,4052,2125,228,3311,1274,792,3235,101,4607,3790,2173,2071,4500,3515,2438,2266,3599,3578,3804,2564,4526,205,2756,4697,1236,705,1012,2101,4503,4033,1809,1448,2418,4902,3641,3108,1542,4920,653,721,3078,2817,4014,2976,3240,2142,2184,4817,4344,699,3781,3120,3361,2304,1346,1879,2232,4563,2930,2508,395,816,3970,931,2206,4348,450,3961,2757,2218,2277,161,1211,3532,3301,1141,504,3269,4775,796,4264,4559,1924,2683,3060,3072,1773,2732,2040,1966,1829,4501,672,3524,768,4004,3502,1091,3675,2641,2704,2686,598,1884,3851,2141,2458,258,1245,1587,227,3614,1959,3660,2337,1926,1948,301,1443,1062,1940,1431,2826,2369,574,3018,2054,3861,4993,1213,1790,830,652,3521,1381,2892,2198,2661,432,3780,2221,846,3394,4734,2562,640,294,3784,4487,2603,1690,3630,4486,2742,2745,3073,3495,3582,4669,1844,2354,527,3327,3354,1589,237,1235,2137,4116,4572,1534,2707,1277,1132,4137,3971,879,649,3850,2037,3960,3876,4673,4459,2846,424,2941,386,3006,3026,2370,260,2201,4456,2345,4144,1612,3651,2496,2625,1507,1468,3803,2022,4896,2379,2426,4859,1350,3054,3926,128,1898,3831,3584,4028,674,4386,793,4557,704,2385,4834,3734,4488,3483,3349,3684,4796,407,314,2287,2671,912,2343,516,4667,1893,1894,1319,4468,4825,3794,3316,342,3192,1281,2868,3860,2523,251,2943,1059,3158,4877,2501,4769,4473,829,467,3163,4637,2607,4053,2787,2969,4159,3510,3618,2575,612,157,2579,1348,2823,1390,4580,4499,2255,3717,3471,470,3248,2957,3888,794,4255,4947,4224,1678,4300,3765,1369,4167,2407,84,2544,1950,1262,2842,2156,3778,915,4050,2553,1030,2227,488,2860,657,4576,4508,2357,1750,1849,2630,3076,554,558,3443,3833,4016,773,1796,3321,117,4554,1866,3857,3609,868,4906,2180,1393,888,2629,2945,1490,3715,4408,3912,2549,3290,2841,1243,3367,1760,175,1942,1937,4955,3557,4173,2251,1597,3457,1140,2993,4751,3552,1583,1207,3669,4279,1411,2601,1484,2915,3129,3408,1032,4155,1276,2519,3878,4686,3148,3093,3310,3719,1150,303,720,3728,3975,3509,752,1272,1610,4120,2951,4291,4518,4695,506,511,890,2453,1340,1364,270,2410,2334,2050,1895,2257,1887,4648,2209,3130,3611,351,648,756,397,4180,147,3795,3091,2331,1674,1283,1202,1821,2570,4977,3811,3950,2798,1480,4406,2610,524,4260,2281,1147,661,2058,2215,4213,4532,3720,4904,2176,4470,2606,1555,2946,4366,2147,4154,2333,4881,3920,1467,4341,2866,234,3038,4002,1389,3623,193,3997,3751,2721,4664,719,2555,1466,4018,1465,3968,437,4780,4149,2225,2988,4934,3293,3708,3508,1925,3207,2689,3503,2959,2761,1572,3225,3913,776,3600,3723,4919,99,3494,1798,1594,469,3175,2833,4800,4298,3196,2744,3947,3951,2009,2207,1156,556,2341,3034,4547,2753,936,1764,394,4158,3205,4221,4808,4318,502,1404,625,1956,3047,4324,3422,2065,1900,2596,233,3473,2327,2318,2483,4857,4419,3545,1400,508,2494,3752,1353,1250,4452,707,1356,4712,1675,4735,4978,333,4099,1734,1662,2487,61,2423,4787,851,2210,2256,2456,2451,546,2200,3055,2717,3989,496,618,3003,1425,4061,1247,1067,4430,2143,3597,1889,3480,3265,4287,643,645,3270,847,1795,764,3805,3333,2874,1850,4121,2952,670,479,3468,2882,1515,1093,3921,4981,416,2199,4469,320,2703,2302,216,166,89,383,1965,1673,4587,2258,3535,4191,4568,3459,4403,1541,3517,4427,1914,3733,1322,1781,133,1902,1063,3688,718,1918,4179,2568,778,841,2196,1082,1175,4252,2474,3249,1677,4678,2839,311,4802,3608,1020,2919,487,1830,2204,1455,3236,3359,3343,1943,4391,4656,887,698,1963,2845,1220,695,1580,4874,4907,1921,2306,1637,1160,1184,595,2797,3404,2963,1066,222,1880,1931,2312,4357,1774,1057,842,4836,2313,4848,3620,109,3782,178,3601,2909,4489,1708,2103,1869,4025,3956,2259,2190,3889,2953,1865,4272,4101,3905,883,4871,150,4899,3313,196,3082,4963,3061,1209,2935,2600,2408,1753,2566,729,1167,3284,4759,700,2831,4694,1640,2825,3918,1433,115,4078,3542,1313,2363,4483,4804,1630,4058,3882,3696,3758,3984,1325,3592,4890,4989,1134,3593,3345,4424,4960,2434,3894,1265,3528,1883,2684,121,3202,4564,533,3852,4633,2063,819,3228,1694,779,623,1920,1916,769,2565,2891,236,2623,4670,1495,2524,3776,112,1146,3451,1025,2118,262,1074,843,3586,551,3305,3560,4660,2967,3011,2921,2099,2535,2140,1315,2889,964,1099,3940,1970,4655,2850,1174,1569,3177,1486,4740,4507,1481,4754,3403,2925,1899,2122,3661,1198,2290,4767,3285,305,4514,4738,691,2828,2746,1229,2466,102,4467,313,3312,992,522,644,1291,744,91,921,3439,298,3998,195,3783,2814,4538,2002,1932,4819,2958,1711,4565,557,3693,4999,4917,4893,87,4876,1362,3853,1227,949,4521,713,2740,2672,2616,345,2003,1625,3275,1519,201,4895,4455,304,442,2678,3286,4931,1975,3052,2424,2532,509,1035,3849,932,1204,4378,1107,1457,1119,2374,3389,4665,4949,1614,2217,4237,77,1341,2075,803,3613,3485,1129,1758,4197,4174,3046,3746,2748,2132,1978,708,118,4795,169,192,78,3115,1399,2396,387,3342,1169,2552,2886,3890,2452,4461,4441,4982,545,143,3978,306,4265,2542,1477,1065,2439,4861,629,2648,4619,366,823,1611,151,3562,2810,3702,4362,2888,3405,4423,3167,2778,4491,455,4421,4867,4020,1944,2015,4119,772,3939,3791,4350,4156,158,2300,917,4567,1317,990,300,869,4253,610,694,3092,4884,775,4082,813,536,3458,57,3616,1423,3332,1049,4979,280,2172,319,3871,2867,3171,363,3201,4414,1110,3632,808,862,2588,331,2708,4520,3188,3392,955,438,3015,4786,641,3500,909,2646,2477,4719,4032,3832,4698,1122,2323,1968,873,4347,4604,3264,3604,3903,1885,164,3374,2774,4153,3730,1292,4281,4746,3074,1508,798,286,974,1558,2430,3070,638,4905,4096,4188,1596,4542,2048,501,2997,1738,553,4986,2647,4070,1867,287,1436,4273,4239,2709,4111,4973,760,1454,2097,1954,410,3840,85,1474,464,2824,945,4460,4837,2366,2119,2427,200,1050,4186,1165,198,153,377,920,3362,1702,2735,3637,1444,1232,2148,635,1842,3098,2123,2371,243,4732,2820,925,451,4519,1993,3253,4628,2305,2931,1048,2755,3334,759,64,1002,1761,406,3686,1038,4994,93,3041,933,4218,906,2134,607,2136,4037,770,155,2664,1215,1801,415,3573,1376,3640,1514,2358,2821,1670,1401,4844,4309,4482,4785,4914,840,3370,4833,4852,714,2365,967,799,214,3338,2059,2107,4864,4228,3476,1218,1130,2971,4946,400,4776,4246,4573,562,466,1967,528,824,252,2832,2765,2475,4056,2948,1138,4029,4674,4528,3406,2529,3487,1164,1649,573,3841,2528,2138];


    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    uint64 public subscriptionId;

    address public vrfCoordinator;

    address public link;

    bytes32 private keyHash;
    uint32 private callbackGasLimit = 200000;
    uint16 private requestConfirmations = 30;
    uint32 private numWords = 1;

    uint256 private chainlinkRandomNumber;

    uint256 private primeNumber;

    uint256 private requestId;


    string private baseURI;

    uint256 private tokenIndex;

    uint256 public totalSupply;

    uint256 public royaltyPercentage;

    uint256 public constant MAX_PUBLIC_SUPPLY = 4935;

    bool public revealPhaseStarted = false;

    address public dgFamilyContractAddress;

    enum BoxType {
        BLACK,
        GOLD,
        PLATINUM
    }

    mapping(address => bool) public systems;

    mapping(uint256 => bool) public revealedTokens;

    mapping(uint256 => BoxType) public revealedResults;

    mapping(uint8 => BoxType) public boxTypeMapping;

    event RoyaltyPercentageChanged(uint256 indexed newPercentage);

    event BaseUriUpdated(string indexed uri);

    event SystemAddressUpdated(address someAddress, bool enabled);

    event Revealed(uint256 glassBoxTokenId, uint256 dgTokenId, BoxType boxType);

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _baseURI1,
        uint256 _royaltyPercentage,
        address _dgFamilyContractAddress,
        uint64 _subscriptionId,
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash
    )
        ERC721(_tokenName, _tokenSymbol)
        EIP712MetaTransaction("DGFamilyGlassBox", "1")
        VRFConsumerBaseV2(_vrfCoordinator)
    {
        baseURI = _baseURI1;
        royaltyPercentage = _royaltyPercentage;
        dgFamilyContractAddress = _dgFamilyContractAddress;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        subscriptionId = _subscriptionId;
        vrfCoordinator = _vrfCoordinator;
        link = _link;
        keyHash = _keyHash;
        boxTypeMapping[1] = BoxType.BLACK;
        boxTypeMapping[2] = BoxType.GOLD;
        boxTypeMapping[3] = BoxType.PLATINUM;
    }

    modifier onlySystem() {
        require(systems[msgSender()], "SYSTEM_UNAUTHORIZED_ACCESS");
        _;
    }

    modifier onlySystemOrOwner() {
        require(
            systems[msgSender()] || owner() == msgSender(),
            "UNAUTHORIZED_ACCESS"
        );
        _;
    }

    function setSystem(address someAddress, bool enabled) external onlyOwner {
        require(someAddress != address(0), "INVALID_ADDRESS");
        systems[someAddress] = enabled;
        emit SystemAddressUpdated(someAddress, enabled);
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
        emit BaseUriUpdated(baseURI);
    }

    function setRoyaltyPercentage(uint256 _percentage) external onlyOwner {
        royaltyPercentage = _percentage;
        emit RoyaltyPercentageChanged(royaltyPercentage);
    }

    function generate(uint256 numberOfTokens, address destination)
        external
        onlySystemOrOwner
        nonReentrant
    {
        require(destination != address(0), "ADDRESS_CAN_NOT_BE_ZERO");
        require(
            (!revealPhaseStarted),
            "PERMISSION_DENIED_REVEAL_PHASE_STARTED"
        );
        require(
            (totalSupply.add(numberOfTokens)) <= MAX_PUBLIC_SUPPLY,
            "MAX_PUBLIC_SUPPLY_REACHED"
        );

        for (uint256 i = 0; i < numberOfTokens; i = i.add(1)) {
            tokenIndex = totalSupply.add(1);
            totalSupply = totalSupply.add(1);
            _safeMint(destination, tokenIndex);
        }
    }

    function getRoyaltyInfo(uint256 _price)
        external
        view
        returns (uint256 royaltyAmount, address royaltyReceiver)
    {
        require(_price > 0, "PRICE_CAN_NOT_BE_ZERO");
        uint256 royalty = (_price.mul(royaltyPercentage)).div(100);
        return (royalty, owner());
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721URIStorage)
        returns (string memory)
    {
        if (totalSupply == 0) {
            return _baseURI();
        }
        require(_exists(_tokenId), "TOKEN_DOES_NOT_EXIST");

        return string(abi.encodePacked(_baseURI(), _tokenId.toString()));
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(msgSender(), tokenId),
            "CALLER_NOT_APPROVED"
        );
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(msgSender(), tokenId),
            "CALLER_NOT_APPROVED"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function renounceOwnership() public view override onlyOwner {
        revert("CAN_NOT_RENOUNCE_OWNERSHIP");
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address tokenOwner = ERC721.ownerOf(tokenId);
        require(to != tokenOwner, "ERC721:APPROVAL_TO_CURRENT_OWNER");
        require(
            msgSender() == tokenOwner ||
                isApprovedForAll(tokenOwner, msgSender()),
            "ERC721:APPROVE_CALLER_NOT_OWNER_OR_APPROVED_FOR_ALL"
        );
        _approve(to, tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function checkIfRevealed(uint256 _tokenId) public view returns (bool) {
        return revealedTokens[_tokenId];
    }

    function startRevealPhase(uint16 _primeNumber) public onlyOwner {
        require(!revealPhaseStarted, "REVEAL_PHASE_ALREADY_INITIATED");

        primeNumber = _primeNumber;

        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        chainlinkRandomNumber = (randomWords[0].mod(999999999999999));
        revealPhaseStarted = true;
    }

    function revealBox(uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msgSender(), tokenId),
            "CALLER_NOT_APPROVED"
        );
        require(revealPhaseStarted, "REVEAL_PHASE_NOT_INITIATED");
        require(!revealedTokens[tokenId], "BOX_ALREADY_REVEALED");

        revealedTokens[tokenId] = true;
        _burn(tokenId);

        uint256 randomIndex = (((primeNumber * tokenId) + chainlinkRandomNumber) % seed.length);
        uint16 revealedBoxTokenId = seed[randomIndex];
        BoxType boxType = BoxType.BLACK;

        if (revealedBoxTokenId >=1 && revealedBoxTokenId <=75) {
            boxType = BoxType.PLATINUM;
        } else if (revealedBoxTokenId >=76 && revealedBoxTokenId <= 750) {
            boxType = BoxType.GOLD;
        }

        DGFamilyCollection dgFamilyContract = DGFamilyCollection(
            dgFamilyContractAddress
        );
        uint256 dgFamilyTokenId = dgFamilyContract.generate(msgSender(), revealedBoxTokenId);
        emit Revealed(tokenId, dgFamilyTokenId, boxType);
    }


}//UNLICENSED
pragma solidity 0.8.9;


contract DGFamilyReveal is
	Ownable,
	VRFConsumerBaseV2,
	ReentrancyGuard
{

	uint16[] public seed = [1982,739,329,2506,4524,4704,4814,3891,2602,2490,3157,4885,2933,4976,1081,581,3689,3884,3543,3842,4142,459,1318,1127,1461,4650,1351,1108,777,4114,4411,1530,1244,4376,2414,4075,2286,2380,3972,2420,4314,3824,3430,4308,491,3452,440,1532,2000,2004,856,1812,3967,3533,2045,1203,3260,1770,1873,277,1314,2502,634,3953,2465,2471,3635,4003,1768,3657,4713,2464,3994,2835,1181,3387,4515,1022,723,2144,2669,4329,611,4226,1551,3300,4959,3105,325,3568,3650,4792,3400,1672,4293,4387,4591,3943,1922,2632,2383,1212,4196,2336,137,1284,2972,2294,2926,419,900,3490,2702,2213,4550,4210,4184,1695,3028,1913,3909,4219,1055,2351,1923,3512,3252,961,4581,802,2338,3145,3863,2682,3679,1225,1280,2649,1330,2064,2910,4415,4577,3916,4034,3336,1698,4574,3547,2656,3254,3000,4449,4397,4047,1851,484,2511,1715,1370,1419,4123,960,1712,2493,3869,2214,1586,1125,3807,1092,4276,2115,2781,2335,3797,3627,165,2979,1533,4110,3858,4364,2805,4652,4145,4883,4863,959,4815,2151,2517,4115,3843,1360,3988,4944,463,3036,1619,4060,626,2252,2706,2855,4183,2551,1363,3287,3762,2154,1078,4816,3160,4005,4306,1664,679,2954,2242,4008,725,2008,3444,307,2598,2999,174,3043,4750,4942,804,2267,2293,83,3589,1501,1412,1058,3605,1068,3816,3859,3900,2634,534,4663,762,1261,3131,4084,2067,4995,2296,878,3272,2364,4583,1792,2514,898,81,3309,881,1806,1131,1909,3277,138,1771,521,3022,203,4957,4731,1494,1159,4407,3381,391,327,939,1392,2853,4136,1731,134,1333,710,248,3436,4349,4181,3698,1520,2412,3258,1458,3425,563,542,1285,1478,1408,3806,3787,2526,4447,3721,4560,3991,1624,3067,1841,2928,1298,360,1060,615,3371,975,48,924,4831,1590,3643,4682,3322,4910,4953,3801,3873,3729,866,973,582,1282,4602,1544,3694,2863,2750,941,1579,1847,585,1825,1192,1155,4057,1391,3504,2794,362,4365,2995,4541,1647,1437,2413,1785,3138,1576,2530,3491,240,2422,2840,3155,2310,4690,483,1186,4997,1820,1434,3745,510,1308,1206,97,1445,2223,2023,4645,987,2857,1657,2181,4379,4138,4277,431,4505,3486,2816,2749,3421,3435,630,1705,3071,1299,4066,981,2468,2977,1254,1228,4199,1233,2695,4511,2836,4729,3132,4299,547,3507,3077,197,2406,382,3324,253,4435,2913,2982,1523,1042,98,1279,4620,4232,1278,3788,2041,3699,4171,4632,105,4952,2106,4044,1149,1492,1365,2087,3455,4268,2730,2873,2694,1562,4634,3583,2731,1780,4822,1782,4758,1334,296,103,4772,208,189,2691,449,2878,2219,995,1652,2035,114,696,291,1453,4283,2469,4091,3646,2714,2581,194,4941,1502,1482,3493,3935,758,2117,2301,1987,2801,3754,2432,3274,1767,4636,2271,4400,2316,3166,2898,82,948,2342,4987,4784,3087,2368,2520,3195,4147,1634,4383,3103,3813,374,3135,3626,3914,4933,3722,436,4968,476,202,2437,4346,1510,1324,2195,71,418,2893,1410,3056,1905,2636,4585,1917,848,3571,4187,4290,544,2220,2906,4639,4730,953,321,4593,4594,241,2049,1100,1522,1152,2932,1584,2556,3714,807,2344,1725,3771,3123,937,62,4683,2567,3753,4320,785,2537,3828,3339,3063,513,790,3883,3919,1143,952,870,3550,4370,2016,2311,4889,2480,4605,3271,257,3737,4829,4036,3017,1822,683,1934,2202,3625,1033,4681,1660,1387,928,2235,2429,2653,825,4113,4961,3775,2994,1145,1489,4966,1327,1539,4448,4791,3704,968,2618,4835,2947,3211,3544,4394,2819,1843,1994,2326,2668,4733,2444,2174,1459,603,849,753,3382,2279,3564,2789,3031,1114,73,3233,3594,4434,254,3081,2676,3276,2329,3178,3481,3107,4766,2849,4898,3165,3534,141,59,330,3705,4143,2531,4556,543,2975,1388,2047,2780,4589,1650,2983,3340,283,2862,2216,3094,3848,2450,3653,761,3227,1176,4700,199,1691,1118,1582,922,3767,1856,811,1182,4543,2442,4744,4990,4923,1999,4190,2454,308,2425,4444,4770,4310,1739,1080,245,624,4646,2478,4569,1472,2472,3222,4530,2964,2631,2763,3251,389,2260,4102,2489,2762,3289,1427,4201,4539,2321,3035,4390,3514,4954,4261,914,2619,3538,4342,1306,2738,485,3569,693,3232,3680,984,4271,3137,4369,1372,343,2384,285,2597,1439,3197,4432,359,781,1375,172,1749,4549,3736,3203,185,4629,3204,1267,1928,1493,3118,4212,1593,2667,1699,445,602,810,1985,4104,755,3755,4464,4980,3257,926,1648,3551,3062,2052,4446,3262,2914,1608,2470,2175,4691,4068,1303,3263,473,537,3759,1386,2247,4146,3027,2937,398,4782,1973,2146,4211,4536,3315,1726,3793,962,1264,1071,4059,2698,1260,4736,4317,954,2569,242,1018,4203,3172,3572,4072,2014,3199,226,1636,1550,2160,2881,1497,686,1742,181,4103,2130,357,1897,3110,947,4827,4288,1732,3372,2011,2317,3658,1556,1052,3996,4894,460,2739,272,413,2377,1028,4624,4258,1718,3691,3428,1171,3112,3268,2399,2859,4847,2681,2692,1621,3255,1823,4479,631,4897,4476,2449,4790,376,2095,3218,2962,4238,1561,1703,4506,2145,4130,3665,1754,2395,2509,239,1347,605,2021,1304,1602,2949,3932,3465,1026,3323,3440,2098,4374,2733,3634,403,3116,3990,2729,3928,839,2249,907,2270,2677,2261,3766,815,3226,1775,1357,2020,353,4930,2589,2657,3866,1701,1626,1027,4077,2800,3299,1491,4494,3416,4779,3337,2108,4015,2770,1744,421,1349,1241,1123,1090,681,3221,2843,3184,735,2375,1290,3423,3237,4958,3836,3005,1547,2093,4689,2813,3096,3390,976,3862,1727,3969,1571,4762,4338,4126,4315,2229,3407,3414,2183,985,4220,3212,1148,4603,1289,1563,122,2611,2563,344,2693,3789,3537,2679,872,4875,379,2769,2904,2939,882,1620,1629,1878,3069,247,2829,3683,409,4586,2911,1471,4046,3642,3383,3007,1988,1216,3106,1037,1972,2903,3662,1700,1021,1266,2080,2790,1888,2663,86,2582,3822,859,4865,1135,996,3453,1061,4107,4208,3117,3530,861,3854,3182,3068,2578,3908,899,1777,978,578,4886,4433,4592,429,3325,2723,935,4544,2486,3835,444,2193,3867,1237,148,1816,1361,2573,2178,3159,2157,2328,368,2234,712,4793,3450,2415,664,1756,273,4019,4765,3021,507,1681,2211,3220,2027,4485,3844,271,428,4820,472,120,1047,3685,1094,4915,3366,2541,1631,3707,1312,3174,910,408,1311,1069,4975,3670,4493,4635,3716,149,1464,4956,1323,4783,235,4481,1671,4207,1371,4611,4527,2806,4676,4879,367,4571,3238,850,3298,4726,2461,1991,95,2612,2887,2231,1665,4841,1188,3621,3820,1044,1964,852,2104,1043,1804,1173,969,2428,2852,2613,349,1603,3697,3638,1442,1366,2699,498,4426,3427,4913,1339,3219,2285,4122,891,531,4561,1142,3104,160,2284,2837,385,223,583,1947,4422,465,668,3037,1622,4245,3113,3556,348,2244,1019,1029,4105,3224,4509,1835,3827,2834,2096,4798,1505,4257,4474,2900,4401,1861,3817,3558,4600,1645,4182,687,3541,3193,2462,136,3633,1736,4093,3095,1846,1219,663,1553,2799,897,854,1567,1554,1384,2605,1531,4513,3080,4027,2291,3185,2167,3825,355,738,1301,4131,970,559,3821,3351,4922,2929,1779,1008,3168,2680,3904,4710,92,4388,4672,2268,1961,1638,2272,131,3812,4007,4333,519,3051,4339,4760,4868,4162,613,4937,126,3622,791,1892,3437,4562,108,3772,774,452,1908,4035,3295,2617,4609,3865,4425,1197,4157,4969,354,4393,4794,2783,2720,358,934,4525,4234,4484,1256,229,2674,1085,3102,3109,2028,4846,1331,1024,1251,1642,728,4854,2128,4160,220,523,4614,1309,2273,1185,2350,4533,1802,2498,3266,1697,2484,1297,4359,3933,765,2243,3294,1015,3948,4647,2269,2105,4278,3246,2212,299,3945,4297,1591,2851,3180,3877,564,1355,1710,797,3923,812,2076,378,688,1803,2441,180,3023,1676,3949,1190,4193,3576,2917,597,276,3244,4752,1463,4654,680,2547,575,4498,1223,1852,1980,2038,2924,844,745,3957,4086,1979,3401,3595,3004,1077,352,474,971,4361,350,4021,90,411,731,256,4860,2481,4535,3673,2934,3242,1772,4492,826,3874,783,4064,3020,430,2078,3415,1097,3259,1234,4295,3147,614,3353,2330,4243,3173,3075,4112,2970,4964,3925,1500,76,4523,857,586,3024,2628,911,1977,1300,3645,4418,4517,682,4141,1268,480,1187,468,265,2879,2057,1653,3579,1545,1837,2719,1307,2060,991,4522,113,4095,3942,2403,2149,2705,1870,4231,1036,3879,4597,1242,3678,426,3800,4716,309,2974,3032,1430,3256,3040,604,4356,4127,2670,361,2387,4304,218,3397,2488,4380,1543,2124,4725,963,1659,1766,3446,1855,1864,892,3962,3809,2847,2362,2205,3388,3922,3319,4451,860,1824,116,1054,2624,4692,2411,567,1692,4595,3659,4247,675,1938,1574,167,4623,2518,1295,1320,1679,268,3194,3146,2473,4172,2640,654,1422,4625,3142,4089,1658,3808,2177,3954,2239,3718,4668,2308,591,315,3603,4849,1273,2046,1103,1128,4368,2081,2830,540,3739,4626,3559,4578,2576,3764,943,267,1787,3030,871,2094,2485,3847,3245,771,3347,2512,2978,3768,217,3887,3845,3190,4722,767,988,4098,1329,3369,1941,1031,2356,2540,3210,1446,1259,3492,372,3700,2854,396,3307,282,339,2072,596,3555,4176,1121,2409,3770,4951,4244,2894,684,685,3496,4140,3982,1088,4548,4316,2192,264,628,2088,3676,1321,2734,1073,3536,2654,894,384,1737,4657,1483,79,3488,3839,1828,1178,4463,1238,3125,4092,4256,1328,2500,2897,4706,904,2895,3757,2861,732,2599,923,1095,1084,972,642,1833,1200,4416,599,2194,1685,1046,338,186,1838,1070,865,1163,3053,3655,1460,4839,486,4168,2793,800,2074,2560,1517,2665,499,1112,4164,806,4006,1939,2561,475,4708,632,1305,3432,1168,3868,1253,3318,716,100,571,1906,2985,2361,4996,4437,1907,3346,244,144,1689,4266,1287,2355,2245,392,4431,2110,2884,2572,1845,3644,863,3208,3419,893,4512,2539,1476,3320,3153,4640,4009,3979,2522,3223,594,1874,2155,478,1064,1157,2447,2885,4621,1839,2007,3581,1034,2998,1853,1911,3418,2950,346,1723,224,2546,1881,3019,656,1221,4773,2760,3973,4398,620,913,4331,1496,3384,4325,3511,135,2768,1557,673,3395,4781,780,1195,2759,292,3368,2419,4367,4938,2376,715,3396,1326,1383,184,587,3682,4087,3931,1891,263,1252,1479,2960,3777,347,1294,1826,3499,757,2297,3273,1120,1429,2024,2061,3710,3885,1104,1751,3393,4842,4495,4327,1945,269,951,4714,4653,3615,2352,3964,908,2165,4807,4267,1438,1503,4502,1729,2942,737,3915,4606,1537,3344,219,3701,188,4737,1546,3610,2554,492,3647,3506,4026,4921,3086,335,3712,4534,2276,877,2388,4935,659,727,3695,4471,530,3191,4094,2838,3380,539,1840,3016,1343,4178,422,1106,3516,290,2848,2992,2869,2864,3703,3934,4477,4677,3341,4916,565,130,4661,4074,2558,2779,2029,4575,858,3413,1560,4312,512,4223,2944,2622,4490,2527,3164,3128,1183,590,4303,1010,332,3314,4462,697,2655,2186,3886,1848,4040,3161,3897,2525,2651,2044,2264,3779,1643,4873,3668,2224,4851,1540,786,4926,1875,1342,433,4909,4810,2391,4472,4125,1616,3464,2263,1504,1776,3472,3881,751,1717,1513,375,2238,4225,577,3002,1919,3375,2445,316,3365,669,3740,1598,2776,297,2557,2082,1208,820,788,702,1124,318,3151,3607,658,443,1836,4011,2955,3763,4358,4892,1374,4340,4215,2164,266,2389,2034,4555,1518,1470,1524,2253,1205,145,1377,417,4504,3774,2332,2877,3838,903,966,526,4684,4988,4042,2168,3279,1255,230,4081,1398,1609,412,1249,1635,3612,1797,481,4108,3815,3187,2233,399,1585,1111,4828,639,1527,3872,404,3590,4545,4853,3520,1741,919,2716,221,901,4866,2936,3518,2986,1338,4742,3726,2018,1368,637,2135,4192,3189,312,225,2726,4582,420,1210,4389,1451,4109,4823,1041,393,1432,4200,3826,171,3296,3150,1487,3304,831,3426,1759,3539,916,2583,1201,156,3206,885,822,4440,2747,2876,4250,1269,3756,4630,4570,2398,2688,2591,4801,2961,3898,1526,3014,3420,2492,4384,4870,1706,3941,1435,4950,2114,1788,1396,4465,2984,4588,4755,2017,2315,4806,1086,552,423,4205,1337,3529,3089,3479,3769,4642,1915,1783,4055,1162,2182,4496,1115,1101,1716,1456,3154,1172,4206,864,795,2139,1910,1179,1745,2844,3938,4510,1072,4135,4012,1552,1669,380,1981,3029,4764,2491,3527,3352,1485,340,2077,336,3687,4185,4745,2025,1793,3213,2322,3692,2754,2940,2129,4204,2150,1644,1270,2808,1743,207,4984,538,1013,3663,1651,2807,3144,4177,3983,1730,4862,2068,3906,1413,1414,2871,4023,2666,3391,3064,1293,1757,456,1367,1000,1789,4302,4151,895,4579,2373,302,1568,4242,4443,1462,3798,3278,1807,2659,535,3306,4649,3732,3378,4900,5000,946,4323,3373,711,3574,177,3654,4170,4457,518,875,979,1379,4285,139,2804,667,3025,2169,1226,4608,4929,4821,2185,1154,1623,2112,3409,2153,3761,958,3328,2907,4743,3297,2086,259,2644,734,4939,1498,660,1475,4031,1817,3671,94,4641,3335,2030,2295,2070,3292,1380,1395,1240,1421,3870,2604,1693,2309,2246,1808,549,289,4321,3084,2516,3580,4693,3308,929,1296,880,994,2922,4727,3467,1473,1929,4763,2543,1713,2784,4079,592,4615,3119,2457,187,72,2171,2621,1818,68,2559,1005,3785,588,569,1409,566,950,448,1344,204,2773,4450,3350,809,4396,1275,3652,3234,832,706,3261,4227,2479,1769,2319,1575,2307,390,938,3513,2858,736,1440,4313,3100,2938,2372,2303,2378,1765,666,827,4420,3837,4809,665,1735,1827,580,3083,677,4106,3410,1017,740,1102,2248,4382,1755,4254,4063,4466,4826,1904,1606,3731,2382,4275,4132,3291,1746,2802,4292,3079,1748,3917,1549,295,2191,3624,763,3469,1834,4402,2991,3567,2767,2393,2013,1230,3475,838,1170,2091,4882,2102,4062,3834,2727,1733,4259,3546,191,281,999,782,1193,3358,742,2645,2981,608,1704,3065,942,4856,2856,3059,215,2324,2188,3681,1958,3892,2113,1974,381,4728,4454,3796,692,179,4097,1661,4209,3792,4757,334,4328,3735,4761,1962,609,1983,3902,1656,1231,4442,884,3773,4843,2386,3101,3709,1863,550,1633,2431,1778,2590,4998,127,3880,2392,2638,4850,2390,3896,2965,4381,2700,1687,4631,1358,371,2718,3519,2593,2586,3598,3963,2339,4024,1402,1415,2577,3713,709,2402,3048,4282,1096,889,4662,3743,514,1014,2340,4048,4749,323,3478,4372,4085,4139,3563,3050,405,1426,2262,3152,2288,600,3377,2513,1040,3629,4797,2189,834,4439,2161,3742,4924,1196,2782,370,1469,3602,4638,2348,3045,2968,1079,1535,2460,560,3628,500,2571,4054,3057,1248,1302,2615,4161,4326,3672,678,3802,1137,2084,4073,4311,2133,701,2056,814,2635,515,3531,4724,3462,1113,324,3631,3376,2127,4152,1310,1566,821,1666,3570,4335,3198,2320,3981,4453,3445,2658,1992,1117,4217,2476,63,1800,3039,2051,4409,3250,4274,4022,3810,3134,1618,182,1588,3814,2883,4030,4590,3566,930,617,2032,70,874,3441,940,1158,4001,4812,4038,1418,4799,3554,3505,1680,3750,3577,805,1857,2764,833,462,1087,801,4000,3143,2545,104,2083,293,2085,2006,4202,2236,4404,246,3176,789,1565,3247,1403,1936,2417,1516,482,249,4832,3549,2265,328,2803,4118,2043,3760,4627,4658,1406,4216,4872,3525,3677,4165,1336,570,4927,3281,4616,1995,1728,1003,3431,4753,4845,2923,2121,503,211,2504,1862,1417,2230,3910,4679,1684,867,124,4788,896,3348,579,2987,1686,1214,446,3360,4838,3829,1016,4878,977,2289,447,3186,2880,998,1405,4601,2459,4039,956,1605,754,1023,4405,4262,853,2400,3449,3724,3738,517,965,1604,2534,1511,2510,3412,1933,4117,2550,434,2905,1564,3140,1397,4065,2079,4553,4584,1536,2822,2710,2902,1452,107,3690,337,2792,4651,2435,4236,4598,3748,4613,1394,2012,2633,388,2170,4972,2111,4903,2980,4345,4777,3952,4248,140,3875,2818,4090,4891,730,4399,3085,1525,4531,4041,1011,3744,4778,2349,1335,1969,986,1955,2927,982,2163,589,2463,439,4241,3501,845,1682,1762,3330,4912,2179,3357,1617,1714,4497,2796,3433,3985,622,3121,3907,1573,2912,1831,3399,4412,3955,1641,3980,1989,3893,2222,2280,1871,154,2515,4711,4013,1133,2650,1488,3974,1045,1667,4385,1696,572,2701,505,497,3855,3976,2712,855,1615,3664,2722,4644,529,1194,1721,2809,123,4818,722,3267,3231,3747,647,4322,2203,3442,1257,2687,4343,1578,2675,2254,4840,1577,2711,3727,905,3447,4643,2916,2100,2609,689,4970,983,3216,3317,2870,3540,495,2812,1529,425,132,2627,671,1896,616,2092,159,2548,3575,1007,3127,3749,489,2497,4803,584,3477,1447,2908,989,4529,2777,1997,4558,170,3044,3460,1105,4436,2595,1688,4337,1009,4269,2538,2066,3588,2298,2626,3283,1799,1819,1872,2026,2724,3636,4813,4305,4235,766,4230,2901,2503,2367,142,2131,4373,3124,1512,129,1752,636,4622,4718,493,4659,1424,4967,4887,1628,4925,3901,2033,441,3930,2325,4540,4516,4428,3402,3927,1613,435,2292,3149,190,2728,902,3355,2090,1935,3649,2416,835,322,3434,4739,1747,3136,2440,106,250,1986,2042,4707,3818,2405,4709,3169,373,3009,2436,876,152,1180,326,2620,2467,3587,1724,1946,3288,3282,4076,2865,3585,4100,927,2875,4948,3911,676,3711,3523,4352,1654,2359,3230,2208,2772,3214,2240,80,4618,4445,2574,4088,4195,1286,1139,401,561,4377,4985,4307,4702,1153,4945,1416,3548,88,3899,65,576,1316,1960,2446,4675,726,1811,3999,3741,1354,3329,4552,3385,655,4392,4071,650,4901,2642,1786,2827,3090,4741,3944,2751,4301,4263,1345,4148,4688,402,4685,784,4294,4888,1382,4438,1890,3162,3379,4869,3010,1930,1359,3674,3648,1509,231,4334,2715,2031,4417,2890,2662,1006,3331,2673,3066,4286,288,2505,1083,2766,4194,3619,490,2448,96,1854,4363,4551,1595,1877,3179,1109,183,364,477,593,4768,1570,4175,2736,1407,2162,2109,2652,2660,4747,209,2116,119,1976,1271,619,3466,1191,1655,4715,2443,3986,2166,1592,1352,4908,3454,1998,4129,3993,453,2158,1420,2956,646,1053,1805,3895,4936,3013,548,3666,1056,2241,1720,993,4229,212,651,2053,1499,1601,3229,3463,3565,3217,2394,3667,3482,944,4918,4353,4824,1001,2811,3209,1246,2069,1927,2643,4289,4965,2896,2401,3042,4080,4069,787,365,1199,4940,1075,274,703,4355,3156,2421,3474,2482,2282,1559,2283,3617,3639,4134,2685,4962,4911,4811,3936,2788,4296,717,3823,817,1953,1263,2495,3929,3864,3181,168,568,3456,2299,1607,4017,3097,110,4043,3139,4429,1449,4251,4705,310,4051,2381,3239,2533,2785,162,1627,1639,427,279,4805,1441,3470,2791,733,918,1646,3099,2614,1683,4991,886,1506,3992,3126,836,2690,2989,4855,3122,1288,4010,997,741,4478,284,317,4932,2973,2775,3170,4410,1004,3001,1901,3058,1521,1957,3386,2996,213,2521,2001,3398,3856,1903,1177,2226,3937,4723,494,555,1222,4270,1719,4830,3008,4458,3088,3522,4150,2228,4360,2197,3215,2126,3356,4233,2346,1912,414,2741,4413,828,4703,4992,238,4696,4351,2507,4617,3561,2159,2584,3995,2187,3965,1098,4789,1858,2397,146,3111,743,601,1332,4198,525,4880,2637,2278,4537,2499,1116,3498,4249,621,1224,341,1217,1385,3725,1709,4983,3280,3183,3429,4971,1378,2771,2966,1810,2990,1971,957,3924,1815,2353,4721,1039,1722,3461,125,3417,4214,1239,457,532,2608,1763,2697,2639,1794,3141,2062,1951,206,2594,1599,454,1151,3243,3303,520,4720,3448,2019,3424,4222,2725,4687,2120,3946,1859,1450,4332,2696,980,369,3012,1632,4599,2580,471,2250,4756,627,4596,3133,2872,2815,3958,4666,173,2585,4974,3819,278,1126,3596,1136,4330,4319,1089,4375,2737,2347,2713,1528,1428,1784,176,2795,3706,56,3786,2404,4371,2587,3241,3484,2275,3959,4169,1668,2010,1990,4189,690,3591,3830,1814,4083,2758,255,2073,261,1373,4280,1161,2433,4566,3656,4284,633,2237,1952,4124,111,3411,2536,2005,4049,3497,2918,461,818,4699,2360,3326,4717,1996,74,163,1600,4480,2314,1538,3114,3606,2899,1144,4133,837,1860,1949,541,1832,1984,3846,1189,2039,4128,3364,3987,2152,2036,4701,3966,3033,2274,275,4943,4771,4067,4610,4166,1663,3438,1707,1813,458,4395,4671,4336,2055,1876,4546,1166,3799,3553,3200,4354,232,4928,2455,2752,356,1886,4045,4748,3526,4163,3977,1076,4475,1868,2089,2592,724,4858,2786,4612,1258,1548,3302,3363,1581,662,1740,210,4774,3049,2920,4240,606,2743,1882,1051,3489,1791,4680,4052,2125,228,3311,1274,792,3235,101,4607,3790,2173,2071,4500,3515,2438,2266,3599,3578,3804,2564,4526,205,2756,4697,1236,705,1012,2101,4503,4033,1809,1448,2418,4902,3641,3108,1542,4920,653,721,3078,2817,4014,2976,3240,2142,2184,4817,4344,699,3781,3120,3361,2304,1346,1879,2232,4563,2930,2508,395,816,3970,931,2206,4348,450,3961,2757,2218,2277,161,1211,3532,3301,1141,504,3269,4775,796,4264,4559,1924,2683,3060,3072,1773,2732,2040,1966,1829,4501,672,3524,768,4004,3502,1091,3675,2641,2704,2686,598,1884,3851,2141,2458,258,1245,1587,227,3614,1959,3660,2337,1926,1948,301,1443,1062,1940,1431,2826,2369,574,3018,2054,3861,4993,1213,1790,830,652,3521,1381,2892,2198,2661,432,3780,2221,846,3394,4734,2562,640,294,3784,4487,2603,1690,3630,4486,2742,2745,3073,3495,3582,4669,1844,2354,527,3327,3354,1589,237,1235,2137,4116,4572,1534,2707,1277,1132,4137,3971,879,649,3850,2037,3960,3876,4673,4459,2846,424,2941,386,3006,3026,2370,260,2201,4456,2345,4144,1612,3651,2496,2625,1507,1468,3803,2022,4896,2379,2426,4859,1350,3054,3926,128,1898,3831,3584,4028,674,4386,793,4557,704,2385,4834,3734,4488,3483,3349,3684,4796,407,314,2287,2671,912,2343,516,4667,1893,1894,1319,4468,4825,3794,3316,342,3192,1281,2868,3860,2523,251,2943,1059,3158,4877,2501,4769,4473,829,467,3163,4637,2607,4053,2787,2969,4159,3510,3618,2575,612,157,2579,1348,2823,1390,4580,4499,2255,3717,3471,470,3248,2957,3888,794,4255,4947,4224,1678,4300,3765,1369,4167,2407,84,2544,1950,1262,2842,2156,3778,915,4050,2553,1030,2227,488,2860,657,4576,4508,2357,1750,1849,2630,3076,554,558,3443,3833,4016,773,1796,3321,117,4554,1866,3857,3609,868,4906,2180,1393,888,2629,2945,1490,3715,4408,3912,2549,3290,2841,1243,3367,1760,175,1942,1937,4955,3557,4173,2251,1597,3457,1140,2993,4751,3552,1583,1207,3669,4279,1411,2601,1484,2915,3129,3408,1032,4155,1276,2519,3878,4686,3148,3093,3310,3719,1150,303,720,3728,3975,3509,752,1272,1610,4120,2951,4291,4518,4695,506,511,890,2453,1340,1364,270,2410,2334,2050,1895,2257,1887,4648,2209,3130,3611,351,648,756,397,4180,147,3795,3091,2331,1674,1283,1202,1821,2570,4977,3811,3950,2798,1480,4406,2610,524,4260,2281,1147,661,2058,2215,4213,4532,3720,4904,2176,4470,2606,1555,2946,4366,2147,4154,2333,4881,3920,1467,4341,2866,234,3038,4002,1389,3623,193,3997,3751,2721,4664,719,2555,1466,4018,1465,3968,437,4780,4149,2225,2988,4934,3293,3708,3508,1925,3207,2689,3503,2959,2761,1572,3225,3913,776,3600,3723,4919,99,3494,1798,1594,469,3175,2833,4800,4298,3196,2744,3947,3951,2009,2207,1156,556,2341,3034,4547,2753,936,1764,394,4158,3205,4221,4808,4318,502,1404,625,1956,3047,4324,3422,2065,1900,2596,233,3473,2327,2318,2483,4857,4419,3545,1400,508,2494,3752,1353,1250,4452,707,1356,4712,1675,4735,4978,333,4099,1734,1662,2487,61,2423,4787,851,2210,2256,2456,2451,546,2200,3055,2717,3989,496,618,3003,1425,4061,1247,1067,4430,2143,3597,1889,3480,3265,4287,643,645,3270,847,1795,764,3805,3333,2874,1850,4121,2952,670,479,3468,2882,1515,1093,3921,4981,416,2199,4469,320,2703,2302,216,166,89,383,1965,1673,4587,2258,3535,4191,4568,3459,4403,1541,3517,4427,1914,3733,1322,1781,133,1902,1063,3688,718,1918,4179,2568,778,841,2196,1082,1175,4252,2474,3249,1677,4678,2839,311,4802,3608,1020,2919,487,1830,2204,1455,3236,3359,3343,1943,4391,4656,887,698,1963,2845,1220,695,1580,4874,4907,1921,2306,1637,1160,1184,595,2797,3404,2963,1066,222,1880,1931,2312,4357,1774,1057,842,4836,2313,4848,3620,109,3782,178,3601,2909,4489,1708,2103,1869,4025,3956,2259,2190,3889,2953,1865,4272,4101,3905,883,4871,150,4899,3313,196,3082,4963,3061,1209,2935,2600,2408,1753,2566,729,1167,3284,4759,700,2831,4694,1640,2825,3918,1433,115,4078,3542,1313,2363,4483,4804,1630,4058,3882,3696,3758,3984,1325,3592,4890,4989,1134,3593,3345,4424,4960,2434,3894,1265,3528,1883,2684,121,3202,4564,533,3852,4633,2063,819,3228,1694,779,623,1920,1916,769,2565,2891,236,2623,4670,1495,2524,3776,112,1146,3451,1025,2118,262,1074,843,3586,551,3305,3560,4660,2967,3011,2921,2099,2535,2140,1315,2889,964,1099,3940,1970,4655,2850,1174,1569,3177,1486,4740,4507,1481,4754,3403,2925,1899,2122,3661,1198,2290,4767,3285,305,4514,4738,691,2828,2746,1229,2466,102,4467,313,3312,992,522,644,1291,744,91,921,3439,298,3998,195,3783,2814,4538,2002,1932,4819,2958,1711,4565,557,3693,4999,4917,4893,87,4876,1362,3853,1227,949,4521,713,2740,2672,2616,345,2003,1625,3275,1519,201,4895,4455,304,442,2678,3286,4931,1975,3052,2424,2532,509,1035,3849,932,1204,4378,1107,1457,1119,2374,3389,4665,4949,1614,2217,4237,77,1341,2075,803,3613,3485,1129,1758,4197,4174,3046,3746,2748,2132,1978,708,118,4795,169,192,78,3115,1399,2396,387,3342,1169,2552,2886,3890,2452,4461,4441,4982,545,143,3978,306,4265,2542,1477,1065,2439,4861,629,2648,4619,366,823,1611,151,3562,2810,3702,4362,2888,3405,4423,3167,2778,4491,455,4421,4867,4020,1944,2015,4119,772,3939,3791,4350,4156,158,2300,917,4567,1317,990,300,869,4253,610,694,3092,4884,775,4082,813,536,3458,57,3616,1423,3332,1049,4979,280,2172,319,3871,2867,3171,363,3201,4414,1110,3632,808,862,2588,331,2708,4520,3188,3392,955,438,3015,4786,641,3500,909,2646,2477,4719,4032,3832,4698,1122,2323,1968,873,4347,4604,3264,3604,3903,1885,164,3374,2774,4153,3730,1292,4281,4746,3074,1508,798,286,974,1558,2430,3070,638,4905,4096,4188,1596,4542,2048,501,2997,1738,553,4986,2647,4070,1867,287,1436,4273,4239,2709,4111,4973,760,1454,2097,1954,410,3840,85,1474,464,2824,945,4460,4837,2366,2119,2427,200,1050,4186,1165,198,153,377,920,3362,1702,2735,3637,1444,1232,2148,635,1842,3098,2123,2371,243,4732,2820,925,451,4519,1993,3253,4628,2305,2931,1048,2755,3334,759,64,1002,1761,406,3686,1038,4994,93,3041,933,4218,906,2134,607,2136,4037,770,155,2664,1215,1801,415,3573,1376,3640,1514,2358,2821,1670,1401,4844,4309,4482,4785,4914,840,3370,4833,4852,714,2365,967,799,214,3338,2059,2107,4864,4228,3476,1218,1130,2971,4946,400,4776,4246,4573,562,466,1967,528,824,252,2832,2765,2475,4056,2948,1138,4029,4674,4528,3406,2529,3487,1164,1649,573,3841,2528,2138];


	VRFCoordinatorV2Interface COORDINATOR;
	LinkTokenInterface LINKTOKEN;

	uint64 public subscriptionId;

	address public vrfCoordinator;

	address public link;

	bytes32 private keyHash;
	uint32 private callbackGasLimit = 2500000;
	uint16 private requestConfirmations = 3;

	mapping(uint256 => address) public requestIdToSender;

	mapping(uint256 => uint256[]) public requestIdToTokenIds;


	bool public revealPhaseStarted = false;

	address public dgFamilyContractAddress;

	address public glassBoxContractAddress;

	enum BoxType {
		BLACK,
		GOLD,
		PLATINUM
	}

	uint8 private constant BATCH_SIZE = 10;

	uint8 public randomNumberRequestsLimit = 1;

	address private platformWallet;

	uint256 public revealFees;

	mapping(uint256 => uint8) public randomNumberRequests;

	mapping(uint256 => bool) public revealedTokens;

	mapping(uint256 => uint256) public revealedResults;

	mapping(uint8 => BoxType) public boxTypeMapping;

	event RandomNumberRequested(uint256[] tokenIds, uint256 requestId);

	event RandomNumberGenerated(uint256 requestId, uint256[] randomNumbers);

	event Revealed(uint256 glassBoxTokenId, uint256 dgTokenId, BoxType boxType);

	constructor(
		address _dgFamilyContractAddress,
		address _glassBoxContractAddress,
		address _platformWallet,
		uint256 _revealFees,
		uint64 _subscriptionId,
		address _vrfCoordinator,
		address _link,
		bytes32 _keyHash
	)
		VRFConsumerBaseV2(_vrfCoordinator)
	{
		dgFamilyContractAddress = _dgFamilyContractAddress;
		glassBoxContractAddress = _glassBoxContractAddress;
		platformWallet = _platformWallet;
		revealFees = _revealFees;
		COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
		LINKTOKEN = LinkTokenInterface(link);
		subscriptionId = _subscriptionId;
		vrfCoordinator = _vrfCoordinator;
		link = _link;
		keyHash = _keyHash;
		boxTypeMapping[1] = BoxType.BLACK;
		boxTypeMapping[2] = BoxType.GOLD;
		boxTypeMapping[3] = BoxType.PLATINUM;
	}

	modifier basicChecks(
		uint256 tokenId
	) {
		require(revealPhaseStarted, "REVEAL_PHASE_NOT_INITIATED");

		DGFamilyGlassBox glassBoxContract = DGFamilyGlassBox(
			glassBoxContractAddress
		);

		address ownerAddress = glassBoxContract.ownerOf(tokenId);
		require(ownerAddress == msg.sender, "ONLY_OWNER_CAN_CALL_THIS_METHOD");

		bool isApprovedForAll = glassBoxContract.isApprovedForAll(ownerAddress, address(this));
		require(isApprovedForAll, "APPROVAL_NOT_GIVEN");

		_;
	}

	function setPlatformWallet(
		address _platformWallet
	)
		external
		onlyOwner
	{
		require(_platformWallet != address(0), "ADDRESS_CAN_NOT_BE_ZERO");
		platformWallet = _platformWallet;
	}

	function setRevealFees(
		uint256 _revealFees
	)
		external
		onlyOwner
	{
		revealFees = _revealFees;
	}

	function setChainlinkKeyHash(
		bytes32 _keyHash
	)
		external
		onlyOwner
	{
		keyHash = _keyHash;
	}


	function renounceOwnership()
		public
		view
		override
		onlyOwner
	{
		revert("CAN_NOT_RENOUNCE_OWNERSHIP");
	}


	function toggleRevealPhase()
		public
		onlyOwner
	{
		revealPhaseStarted = !revealPhaseStarted;
	}


	function setRandomNumberRequestsLimit(
		uint8 newLimit
	)
		external
		onlyOwner
	{
		randomNumberRequestsLimit = newLimit;
	}

	function resetRandomNumbersRequested(
		uint256 tokenId
	)
		external
		onlyOwner
	{
		randomNumberRequests[tokenId] = 0;
	}


	function checkIfRevealed(
		uint256 tokenId
	)
		public
		view
		returns (bool)
	{
		return revealedTokens[tokenId];
	}

	function requestRandomNumber(
		uint256[] memory tokenIds
	)
		external
		payable
		nonReentrant
	{
		DGFamilyGlassBox glassBoxContract = DGFamilyGlassBox(
			glassBoxContractAddress
		);
		bool isApprovedForAll = glassBoxContract.isApprovedForAll(msg.sender, address(this));

		require(revealPhaseStarted, "REVEAL_PHASE_NOT_INITIATED");
		require(isApprovedForAll, "APPROVAL_NOT_GIVEN");
		require((tokenIds.length > 0) && (tokenIds.length <= BATCH_SIZE), "BATCH_SIZE_INVALID");

		for(uint256 i = 0; i < tokenIds.length; i = i + 1) {
			uint256 tokenId = tokenIds[i];
			address ownerAddress = glassBoxContract.ownerOf(tokenId);

			require(ownerAddress == msg.sender, "ONLY_OWNER_CAN_CALL_THIS_METHOD");
			require(!revealedTokens[tokenId], "BOX_ALREADY_CLAIMED");
			require(randomNumberRequests[tokenId] < randomNumberRequestsLimit, "RANDOM_NUMBER_LIMIT_REACHED");

			randomNumberRequests[tokenId] = randomNumberRequests[tokenId] + 1;
		}

		if (revealFees > 0) {
			uint256 totalFees = revealFees * tokenIds.length;
			require(msg.value == totalFees, "INVALID_REVEAL_FEES_AMOUNT");
			(bool sent, ) = platformWallet.call{value: msg.value}("");
			require(sent, "FAILED_TO_SEND_REVEAL_FEES");
		}

		uint32 numbers = uint32(tokenIds.length);
		uint256 requestId = COORDINATOR.requestRandomWords(
			keyHash,
			subscriptionId,
			requestConfirmations,
			callbackGasLimit,
			numbers
		);
		requestIdToTokenIds[requestId] = tokenIds;
		requestIdToSender[requestId] = msg.sender;
		emit RandomNumberRequested(tokenIds, requestId);
	}

	function fulfillRandomWords(
		uint256 requestId,
		uint256[] memory randomWords
	)
		internal
		virtual
		override
	{
		DGFamilyGlassBox glassBoxContract = DGFamilyGlassBox(
			glassBoxContractAddress
		);
		DGFamilyCollection dgFamilyContract = DGFamilyCollection(
			dgFamilyContractAddress
		);
		address sender = requestIdToSender[requestId];
		uint256[] memory tokenIds = requestIdToTokenIds[requestId];
		emit RandomNumberGenerated(requestId, randomWords);

		for(uint8 i = 0; i < tokenIds.length; i = i + 1) {
			uint256 tokenId = tokenIds[i];
			uint256 randomNumber = randomWords[i];
			uint256 randomIndex = randomNumber % seed.length; // get random number between 0 to seed length.

			if (revealedTokens[tokenId]) {
				continue;
			}

			revealedTokens[tokenId] = true;

			glassBoxContract.transferFrom(sender, 0x000000000000000000000000000000000000dEaD, tokenId);

			uint16 revealedBoxTokenId = seed[randomIndex];
			BoxType boxType = BoxType.BLACK;
			if (revealedBoxTokenId >=1 && revealedBoxTokenId <=75) {
				boxType = BoxType.PLATINUM;
			} else if (revealedBoxTokenId >=76 && revealedBoxTokenId <= 750) {
				boxType = BoxType.GOLD;
			}

			seed[randomIndex] = seed[seed.length - 1];
			seed.pop();

			revealedResults[tokenId] = revealedBoxTokenId;

			dgFamilyContract.generate(sender, revealedBoxTokenId);
			emit Revealed(tokenId, revealedBoxTokenId, boxType);
		}

	}

}