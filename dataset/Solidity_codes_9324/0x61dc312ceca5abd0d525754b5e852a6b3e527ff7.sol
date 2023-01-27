
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


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// UNLICENSED
pragma solidity ^0.8.10;


contract HDY721 is ERC721URIStorage, Ownable {

    mapping(uint256 => string) public collectionsName;
    mapping (uint256 => uint256) priceNFT;
    address public marketAddress;

    address public platformAddress;
    event Minted(
        address owner,
        uint256 tokenId,
        string CollectionName,
        string tokenURI
    );
    event PlatformUpdated(
        address newPlatformAddress,
        uint256 timestamp
    );
    struct Sig {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    constructor() ERC721("Hiroshima Dragonfly", "HDY") {}

    function mint(
        address callerAddress,
        uint256 tokenId,
        string memory _collectionName,
        string memory tokenURI,
        Sig memory MintRSV
    ) public {
        require(!(_exists(tokenId)), "Token ID already minted!");
        require(_msgSender() == marketAddress, "The caller must be marketplace contract!");
        require(
            verifySigner(
                platformAddress,
                messageHash(abi.encodePacked(callerAddress, tokenId)),
                MintRSV
            ),
            "Mint Signature Invalid"
        );
        _mint(callerAddress, tokenId);
        _setTokenURI(tokenId, tokenURI);
        collectionsName[tokenId] = _collectionName;

        emit Minted(callerAddress, tokenId, _collectionName, tokenURI);
    }
    
    function setPriceNFT(address callerAdress, uint256 tokenID, uint256 price) public {
        require(_exists(tokenID), "Token ID Doesn't exist!");
        require(_msgSender() == marketAddress, "The caller must be marketplace contract!");
        require(callerAdress == ownerOf(tokenID), "You're not the owner of this nft.");
        priceNFT[tokenID] = price;
    }
    
    function getPriceNFT(uint256 tokenID) public view returns (uint256) {
        return priceNFT[tokenID];
    }

    function setMarketAddress(address _marketAddress) public onlyOwner {
        require(_marketAddress != address(0), "Address must not be zero!");
        marketAddress = _marketAddress;
    }

    function updatePlatform(address newAddress) public onlyOwner {
        require(newAddress != address(0), "Address must not be zero!");
        platformAddress = newAddress;
        emit PlatformUpdated(newAddress, block.timestamp);
    }

    function messageHash(bytes memory abiEncode)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(abiEncode)
                )
            );
    }

    function verifySigner(
        address signer,
        bytes32 ethSignedMessageHash,
        Sig memory rsv
    ) internal pure returns (bool) {
        return
            ECDSA.recover(ethSignedMessageHash, rsv.v, rsv.r, rsv.s) == signer;
    }
}// UNLICENSED
pragma solidity ^0.8.10;


contract Marketplace is Ownable, ReentrancyGuard{
    uint256 public royaltyFee;
    address public platformAddress;
    address public NFTAddress;

    uint256 denominator = 10000;

    mapping (address => bool) public statusAdmin;
    mapping (uint256 => bool) public statusNFT;

    struct Sig{bytes32 r; bytes32 s; uint8 v;}

    event SellEvent(address Caller, uint256 TokenID, uint256 Price, string transactionID, uint256 TimeStamp);
    event BuyEvent(address Caller, uint256 TokenID, uint256 Price, string transactionID, uint256 TimeStamp, bytes transferData);
    event CancelSellEvent(address Caller, uint256 TokenID, string transactionID, uint256 TimeStamp);
    event LowingPriceEvent(address Caller, uint256 TokenID, uint256 NewPrice, string transactionID, uint256 TimeStamp);
    event BuyPackEvent(address buyerAddress, uint256 packID, uint256 amountPack, uint256 transferredAmount, string transactionID, uint256 TimeStamp, bytes transferData);

    bool public Initialized;

    function init(address _platformAddress, address _NFTAddress) public onlyOwner {
        require(!Initialized, "Contract already initialized!");
        platformAddress = _platformAddress;
        NFTAddress = _NFTAddress;
        Initialized = true;
        statusAdmin[_platformAddress] = true;
        statusAdmin[msg.sender] = true;
        setRoyaltyFee(250);
    }

    function buyPack(uint256 packID, uint256 amount, uint256 pricePack, string memory transactionID, Sig memory buyPackRSV) external payable initializer {
        require(verifySigner(platformAddress, messageHash(abi.encodePacked(msg.sender, packID, amount, pricePack, transactionID)), buyPackRSV), "BuyPack rsv invalid");
        require(msg.sender != address(0), "Address Invalid!");
        require(pricePack == msg.value, "Transferred amount is not match with price pack!");
        (bool sent, bytes memory data) = payable(platformAddress).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        emit BuyPackEvent(msg.sender, packID, amount, msg.value, transactionID, block.timestamp, data);
    }

    function sell(uint256 tokenID, uint256 price, string memory transactionID, Sig memory sellRSV) public initializer onlyNFTOwner(tokenID) {
        require(statusNFT[tokenID] != true, "NFT Already selled!");
        require(verifySigner(platformAddress, messageHash(abi.encodePacked(msg.sender, tokenID, price, transactionID)), sellRSV), "Sell rsv invalid");
        statusNFT[tokenID] = true;
        HDY721(NFTAddress).setPriceNFT(msg.sender, tokenID, price);
        emit SellEvent(msg.sender, tokenID, price, transactionID, block.timestamp);
    }

    function sellWithMint(uint256 tokenID, string memory collectionName, string memory tokenURI, uint256 price, string memory transactionID, HDY721.Sig memory MintRSV, Sig memory sellRSV) public initializer{
        require(verifySigner(platformAddress, messageHash(abi.encodePacked(msg.sender, tokenID, price, transactionID)), sellRSV), "Sell rsv invalid");
        HDY721(NFTAddress).mint(msg.sender, tokenID, collectionName, tokenURI, MintRSV);
        statusNFT[tokenID] = true;
        HDY721(NFTAddress).setPriceNFT(msg.sender, tokenID, price);
        emit SellEvent(msg.sender, tokenID, price, transactionID, block.timestamp);
    }

    function buy(address seller, uint256 tokenID,uint256 price, string memory transactionID, Sig memory buyRSV) public payable initializer {
        require(statusNFT[tokenID], "NFT is not listed!");
        require(verifySigner(platformAddress, messageHash(abi.encodePacked(msg.sender, tokenID, price, transactionID)), buyRSV), "Buy rsv invalid");
        require(HDY721(NFTAddress).getPriceNFT(tokenID) == price, "The amount is not match with listing price!");
        require(msg.value == price, "msg.value is not matched with price!");
        require(HDY721(NFTAddress).ownerOf(tokenID) != msg.sender, "You can't buy your own NFT!");
        statusNFT[tokenID] = false;
        uint256 fee = (msg.value * royaltyFee) / denominator;
        (bool sent, bytes memory data) = payable(seller).call{value: msg.value - fee}("");
        require(sent, "Failed to send Ether");
        (bool feeSent, bytes memory feeData) = payable(platformAddress).call{value: fee}("");
        require(feeSent, "Failed to send fee!");
        HDY721(NFTAddress).safeTransferFrom(seller, msg.sender, tokenID);
        emit BuyEvent(msg.sender, tokenID, price, transactionID, block.timestamp, data);
    }

    function cancelSell(uint256 tokenID, string memory transactionID, Sig memory cancelRSV) public initializer onlyNFTOwner(tokenID) {
        require(verifySigner(platformAddress, messageHash(abi.encodePacked(msg.sender, tokenID)), cancelRSV), "Cancel rsv invalid");
        require(statusNFT[tokenID], "You can't cancel sell NFT that not selled!");
        statusNFT[tokenID] = false;
        emit CancelSellEvent(msg.sender, tokenID, transactionID, block.timestamp);
    }
    
    function lowingPrice(uint256 tokenID, uint256 newPrice, string memory transactionID, Sig memory lowingPriceRSV) public initializer onlyNFTOwner(tokenID) {
        require(verifySigner(platformAddress, messageHash(abi.encodePacked(msg.sender, tokenID, newPrice)), lowingPriceRSV), "LowingPrice rsv invalid");
        require(newPrice < HDY721(NFTAddress).getPriceNFT(tokenID), "Your submitted new price is higher than initialized price.");
        HDY721(NFTAddress).setPriceNFT(msg.sender, tokenID, newPrice);
        emit LowingPriceEvent(msg.sender, tokenID, newPrice, transactionID, block.timestamp);
    }

    function addAdmin(address addressAdmin) external onlyOwner initializer{
        require(addressAdmin != address(0), "Address invalid");
        statusAdmin[addressAdmin] = true;
    }

    function updatePlatform(address newPlatform) external onlyAdmin initializer {
        require(newPlatform != address(0), "Address invalid");
        platformAddress = newPlatform;
    }

    function updateNFTAddress(address nftAddress) external onlyAdmin initializer{
        require(nftAddress != address(0), "Address invalid");
        NFTAddress = nftAddress;
    }

    function revokeAdmin(address addressAdmin) external onlyOwner {
        require(addressAdmin != address(0), "Address invalid");
        statusAdmin[addressAdmin] = false;
    }

    function setRoyaltyFee(uint256 newFee) public onlyAdmin initializer{
        require((newFee >= 100) && (newFee <= 10000) , "The Denominator is 10000");
        royaltyFee = newFee;
    }

    function getRoyaltyFee() public view returns (uint256){
        return royaltyFee;
    }

    function verifySigner(address signer, bytes32 ethSignedMessageHash, Sig memory rsv) internal pure returns (bool)
    {
        return ECDSA.recover(ethSignedMessageHash, rsv.v, rsv.r, rsv.s) == signer;
    }

    function messageHash(bytes memory abiEncode)internal pure returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abiEncode)));
    }

    modifier initializer() {
        require(Initialized, "The contract is not initialized yet!");
        _;
    }

    modifier onlyAdmin() {
        require(statusAdmin[msg.sender], "The caller is not an admin.");
        _;
    }

    modifier onlyNFTOwner(uint256 tokenID) {
        require(HDY721(NFTAddress).ownerOf(tokenID) == msg.sender, "You're not an owner of this NFT");
        _;
    }
}