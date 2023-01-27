
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

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
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity 0.8.11;


contract PrideIcons is ERC721, Ownable {
    using ECDSA for bytes32;

    uint8 public maxMintsPerTx;

    uint256 public silverPrice;
    uint256 public goldPrice;

    uint16 public silverSupply;
    uint16 public goldSupply;
    uint16 public platinumSupply;

    uint16 internal mintedGold;
    uint16 internal mintedSilver;
    uint16 internal mintedPlatinum;

    mapping(uint16 => bool) public hasMintedPlatinum;

    string private baseTokenURI;

    string private nftContractURI;

    mapping(address => bool) public earlyBirdSaleList;

    mapping(address => uint256) public earlyBirdSalePurchasesSilver;
    mapping(address => uint256) public earlyBirdSalePurchasesGold;

    mapping(address => bool) public presaleList;

    mapping(address => uint256) public presalePurchasesSilver;
    mapping(address => uint256) public presalePurchasesGold;

    mapping(address => uint256) public presaleReservedSilver;
    mapping(address => uint256) public presaleReservedGold;

    mapping(bytes32 => bool) private nonces;

    string public proof;

    bool public earlyBirdSaleLive;
    bool public presaleLive;
    bool public publicSaleLive;

    bool public metadataLocked;
    bool public auctionLocked;

    uint16 public mintedSilverGifts;
    uint16 public mintedGoldGifts;

    uint256 public revealTimestamp;
    uint256 public startingIndexBlock;
    uint256 public startingIndex;

    address internal auctionAddress;
    address internal vaultAddress;
    address internal signerAddress;

    mapping(address => bool) private paperWallets;

    constructor(
        address _vaultAddress,
        address _signerAddress,
        string memory _baseTokenURI,
        string memory _nftContractURI,
        uint8 _maxMintsPerTx,
        uint256 _silverPrice,
        uint256 _goldPrice,
        uint16 _silverSupply,
        uint16 _goldSupply,
        uint16 _platinumSupply,
        address[] memory _paperWallets
    ) ERC721("PrideIcons", "PI") {
        require(_vaultAddress != address(0), "NULL_ADDRESS");
        require(_signerAddress != address(0), "NULL_ADDRESS");
        vaultAddress = _vaultAddress;
        signerAddress = _signerAddress;
        baseTokenURI = _baseTokenURI;
        nftContractURI = _nftContractURI;
        maxMintsPerTx = _maxMintsPerTx;
        silverPrice = _silverPrice;
        goldPrice = _goldPrice;
        silverSupply = _silverSupply;
        goldSupply = _goldSupply;
        platinumSupply = _platinumSupply;
        initializePaperWallets(_paperWallets);
    }

    modifier metadataNotLocked() {
        require(!metadataLocked, "CONTRACT_METADATA_METHODS_ARE_LOCKED");
        _;
    }

    modifier auctionNotLocked() {
        require(!auctionLocked, "CONTRACT_LOCKED_DOWN");
        _;
    }

    modifier onlyPaperOrOwner() {
        require(
            paperWallets[msg.sender] || owner() == msg.sender,
            "ONLY_PAPER_WALLETS_OR_OWNER_ALLOWED"
        );
        _;
    }

    function mint(
        bytes32 hash,
        bytes calldata signature,
        bytes32 nonce,
        uint16 silverQuantityToMint,
        uint16 goldQuantityToMint
    ) external payable {
        require(
            publicSaleLive && !presaleLive && !earlyBirdSaleLive,
            "SALE_CLOSED"
        );
        require(
            mintedSilver + silverQuantityToMint <= silverSupply,
            "OUT_OF_STOCK_SILVER"
        );
        require(
            mintedGold + goldQuantityToMint <= goldSupply,
            "OUT_OF_STOCK_GOLD"
        );
        require(
            silverQuantityToMint + goldQuantityToMint <= maxMintsPerTx,
            "EXCEED_QUANTITY_LIMIT"
        );
        require(
            msg.value >=
                (silverPrice *
                    silverQuantityToMint +
                    goldPrice *
                    goldQuantityToMint),
            "INSUFFICIENT_ETH"
        );
        require(matchAddresSigner(hash, signature), "UNAUTHORIZED_MINT");
        require(!nonces[nonce], "HASH_USED");
        require(
            hashTransaction(
                msg.sender,
                silverQuantityToMint + goldQuantityToMint,
                nonce
            ) == hash,
            "HASH_FAIL"
        );

        if (silverQuantityToMint > 0) {
            mintSilverQuantity(msg.sender, silverQuantityToMint);
        }
        if (goldQuantityToMint > 0) {
            mintGoldQuantity(msg.sender, goldQuantityToMint);
        }

        nonces[nonce] = true;

        trySetStartingIndex();
    }

    function mintEarlyBird(
        uint16 silverQuantityToMint,
        uint16 goldQuantityToMint
    ) external payable {
        require(
            earlyBirdSaleLive && !publicSaleLive && !presaleLive,
            "EARLY_BIRD_SALE_CLOSED"
        );
        require(earlyBirdSaleList[msg.sender], "UNAUTHORIZED");
        require(
            mintedSilver + silverQuantityToMint <= silverSupply,
            "OUT_OF_STOCK_SILVER"
        );
        require(
            mintedGold + goldQuantityToMint <= goldSupply,
            "OUT_OF_STOCK_GOLD"
        );
        require(
            earlyBirdSalePurchasesSilver[msg.sender] +
                silverQuantityToMint +
                earlyBirdSalePurchasesGold[msg.sender] +
                goldQuantityToMint <=
                maxMintsPerTx,
            "EXCEED_EARLY_BIRD_SALE_PERSONAL_LIMIT"
        );
        require(
            msg.value >=
                (silverPrice *
                    silverQuantityToMint +
                    goldPrice *
                    goldQuantityToMint),
            "INSUFFICIENT_ETH"
        );

        earlyBirdSalePurchasesSilver[msg.sender] += silverQuantityToMint;
        earlyBirdSalePurchasesGold[msg.sender] += goldQuantityToMint;

        if (silverQuantityToMint > 0) {
            mintSilverQuantity(msg.sender, silverQuantityToMint);
        }
        if (goldQuantityToMint > 0) {
            mintGoldQuantity(msg.sender, goldQuantityToMint);
        }

        trySetStartingIndex();
    }

    function mintPresale(uint16 silverQuantityToMint, uint16 goldQuantityToMint)
        external
        payable
    {
        require(
            presaleLive && !publicSaleLive && !earlyBirdSaleLive,
            "PRESALE_CLOSED"
        );
        require(presaleList[msg.sender], "UNAUTHORIZED");
        require(
            mintedSilver + silverQuantityToMint <= silverSupply,
            "OUT_OF_STOCK_SILVER"
        );
        require(
            mintedGold + goldQuantityToMint <= goldSupply,
            "OUT_OF_STOCK_GOLD"
        );
        require(
            presaleReservedSilver[msg.sender] == silverQuantityToMint &&
                presaleReservedGold[msg.sender] == goldQuantityToMint,
            "QUANTITY_MUST_BE_EQUAL_TO_RESERVED"
        );
        require(
            presalePurchasesSilver[msg.sender] +
                silverQuantityToMint +
                presalePurchasesGold[msg.sender] +
                goldQuantityToMint <=
                maxMintsPerTx,
            "EXCEED_PRESALE_PERSONAL_LIMIT"
        );
        require(
            msg.value >=
                (silverPrice *
                    silverQuantityToMint +
                    goldPrice *
                    goldQuantityToMint),
            "INSUFFICIENT_ETH"
        );

        presalePurchasesSilver[msg.sender] += silverQuantityToMint;
        presalePurchasesGold[msg.sender] += goldQuantityToMint;

        if (silverQuantityToMint > 0) {
            mintSilverQuantity(msg.sender, silverQuantityToMint);
        }
        if (goldQuantityToMint > 0) {
            mintGoldQuantity(msg.sender, goldQuantityToMint);
        }

        trySetStartingIndex();
    }

    function mintPlatinum(uint8 tokenId, address buyer)
        external
        auctionNotLocked
    {
        require(auctionAddress != address(0), "AUCTION_CONTRACT_UNINITIALIZED");
        require(buyer != address(0), "NULL_ADDRESS");
        require(msg.sender == auctionAddress, "UNAUTHORIZED");
        require(mintedPlatinum + 1 <= platinumSupply, "OUT_OF_STOCK");
        require(tokenId <= platinumSupply, "TOKEN_ID_OUT_OF_PLATINUM_RANGE");

        _safeMint(buyer, tokenId);
        mintedPlatinum++;
        hasMintedPlatinum[tokenId] = true;
    }

    function giftSilver(address[] calldata receivers) external onlyOwner {
        require(
            mintedSilver + receivers.length <= silverSupply,
            "OUT_OF_STOCK_SILVER"
        );

        mintedSilverGifts += uint16(receivers.length);
        for (uint16 i = 0; i < receivers.length; i++) {
            _safeMint(receivers[i], getNextSilverTokenId() + i);
        }
        mintedSilver += uint16(receivers.length);
    }

    function giftGold(address[] calldata receivers) external onlyOwner {
        require(
            mintedGold + receivers.length <= goldSupply,
            "OUT_OF_STOCK_GOLD"
        );

        mintedGoldGifts += uint16(receivers.length);
        for (uint16 i = 0; i < receivers.length; i++) {
            _safeMint(receivers[i], getNextGoldTokenId() + i);
        }
        mintedGold += uint16(receivers.length);
    }


    function paperMintSilver(address userWallet, uint8 quantity)
        public
        payable
        onlyPaperOrOwner
    {
        string memory ineligibilityReason = getClaimIneligibilityReasonSilver(
            userWallet,
            quantity
        );
        require(
            keccak256(abi.encodePacked(ineligibilityReason)) ==
                keccak256(abi.encodePacked("")),
            ineligibilityReason
        );

        if (presaleLive) {
            presalePurchasesSilver[userWallet] += quantity;
        } else if (earlyBirdSaleLive) {
            earlyBirdSalePurchasesSilver[userWallet] += quantity;
        }

        mintSilverQuantity(userWallet, quantity);

        trySetStartingIndex();
    }

    function paperMintGold(address userWallet, uint8 quantity)
        public
        payable
        onlyPaperOrOwner
    {
        string memory ineligibilityReason = getClaimIneligibilityReasonGold(
            userWallet,
            quantity
        );
        require(
            keccak256(abi.encodePacked(ineligibilityReason)) ==
                keccak256(abi.encodePacked("")),
            ineligibilityReason
        );

        if (presaleLive) {
            presalePurchasesGold[userWallet] += quantity;
        } else if (earlyBirdSaleLive) {
            earlyBirdSalePurchasesGold[userWallet] += quantity;
        }

        mintGoldQuantity(userWallet, quantity);

        trySetStartingIndex();
    }

    function getClaimIneligibilityReasonSilver(
        address userWallet,
        uint8 quantity
    ) public view returns (string memory) {
        if (presaleLive) {
            return
                getClaimIneligibilityReason(
                    userWallet,
                    quantity,
                    silverPrice,
                    mintedSilver,
                    silverSupply,
                    presaleReservedSilver[userWallet],
                    presalePurchasesSilver[userWallet],
                    presalePurchasesGold[userWallet]
                );
        }

        if (earlyBirdSaleLive) {
            return
                getClaimIneligibilityReason(
                    userWallet,
                    quantity,
                    silverPrice,
                    mintedSilver,
                    silverSupply,
                    0,
                    earlyBirdSalePurchasesSilver[userWallet],
                    earlyBirdSalePurchasesGold[userWallet]
                );
        }

        return
            getClaimIneligibilityReason(
                userWallet,
                quantity,
                silverPrice,
                mintedSilver,
                silverSupply,
                0,
                0,
                0
            );
    }

    function getClaimIneligibilityReasonGold(address userWallet, uint8 quantity)
        public
        view
        returns (string memory)
    {
        if (presaleLive) {
            return
                getClaimIneligibilityReason(
                    userWallet,
                    quantity,
                    goldPrice,
                    mintedGold,
                    goldSupply,
                    presaleReservedGold[userWallet],
                    presalePurchasesSilver[userWallet],
                    presalePurchasesGold[userWallet]
                );
        }

        if (earlyBirdSaleLive) {
            return
                getClaimIneligibilityReason(
                    userWallet,
                    quantity,
                    goldPrice,
                    mintedGold,
                    goldSupply,
                    0,
                    earlyBirdSalePurchasesSilver[userWallet],
                    earlyBirdSalePurchasesGold[userWallet]
                );
        }

        return
            getClaimIneligibilityReason(
                userWallet,
                quantity,
                goldPrice,
                mintedGold,
                goldSupply,
                0,
                0,
                0
            );
    }

    function getClaimIneligibilityReason(
        address userWallet,
        uint8 quantity,
        uint256 price,
        uint16 purchased,
        uint16 supply,
        uint256 reserved,
        uint256 purchasedSilver,
        uint256 purchasedGold
    ) private view returns (string memory) {
        if (quantity == 0) {
            return "NO_QUANTITY";
        }

        if (msg.value < (quantity * price)) {
            return "INSUFFICIENT_ETH";
        }

        if (purchased + quantity > supply) {
            return "NOT_ENOUGH_SUPPLY";
        }

        if (purchasedSilver + purchasedGold + quantity > maxMintsPerTx) {
            return "EXCEED_LIMIT";
        }

        if (earlyBirdSaleLive) {
            if (!earlyBirdSaleList[userWallet]) {
                return "NOT_ON_ALLOWLIST";
            }
        } else if (presaleLive) {
            if (!presaleList[userWallet]) {
                return "NOT_ON_ALLOWLIST";
            }

            if (reserved != quantity) {
                return "QUANTITY_MUST_BE_EQUAL_TO_RESERVED";
            }
        } else if (!publicSaleLive) {
            return "NOT_LIVE";
        }

        return "";
    }


    function mintSilverQuantity(address wallet, uint16 quantityToMint) private {
        for (uint16 i = 0; i < quantityToMint; i++) {
            _safeMint(wallet, getNextSilverTokenId() + i);
        }
        mintedSilver += quantityToMint;
    }

    function mintGoldQuantity(address wallet, uint16 quantityToMint) private {
        for (uint16 i = 0; i < quantityToMint; i++) {
            _safeMint(wallet, getNextGoldTokenId() + i);
        }
        mintedGold += quantityToMint;
    }

    function getNextSilverTokenId() internal view returns (uint16) {
        return mintedSilver + goldSupply + platinumSupply + 1;
    }

    function getNextGoldTokenId() internal view returns (uint16) {
        return mintedGold + platinumSupply + 1;
    }

    function setStartingIndex() public {
        require(startingIndex == 0, "ALREADY_SET");
        require(startingIndexBlock != 0, "MISSING_SEED");
        setStartingIndexInternal();
    }

    function trySetStartingIndex() private {
        if (
            startingIndexBlock == 0 &&
            ((mintedSilver + mintedGold == silverSupply + goldSupply) ||
                block.timestamp >= revealTimestamp)
        ) {
            startingIndexBlock = block.number;
            setStartingIndexInternal();
        }
    }

    function setStartingIndexInternal() private {
        if (block.number - startingIndexBlock > 255) {
            startingIndex =
                uint256(
                    keccak256(
                        abi.encodePacked(
                            blockhash(block.number - 1),
                            block.coinbase,
                            block.timestamp
                        )
                    )
                ) %
                goldSupply;
        } else {
            startingIndex =
                uint256(
                    keccak256(
                        abi.encodePacked(
                            blockhash(startingIndexBlock),
                            block.coinbase,
                            block.timestamp
                        )
                    )
                ) %
                goldSupply;
        }

        if (startingIndex == 0) {
            startingIndex = (block.number + 1) % goldSupply;
        }
    }

    function hashTransaction(
        address sender,
        uint256 quantity,
        bytes32 nonce
    ) internal pure returns (bytes32) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(sender, quantity, nonce))
            )
        );

        return hash;
    }

    function matchAddresSigner(bytes32 hash, bytes calldata signature)
        internal
        view
        returns (bool)
    {
        return signerAddress == hash.recover(signature);
    }

    function _baseURI() internal view override(ERC721) returns (string memory) {
        return baseTokenURI;
    }

    function contractURI() public view returns (string memory) {
        return nftContractURI;
    }

    function addToEarlyBirdSale(address[] calldata entries) external onlyOwner {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");
            require(!earlyBirdSaleList[entry], "DUPLICATE_ENTRY");

            earlyBirdSaleList[entry] = true;
        }
    }

    function addToPresale(
        address[] calldata entries,
        uint256[] calldata reservedPresaleSilver,
        uint256[] calldata reservedPresaleGold
    ) external onlyOwner {
        require(
            entries.length == reservedPresaleSilver.length &&
                reservedPresaleSilver.length == reservedPresaleGold.length,
            "UNEQUAL_LENGTH"
        );
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            uint256 silverQuantityToReserve = reservedPresaleSilver[i];
            uint256 goldQuantityToReserve = reservedPresaleGold[i];
            require(
                silverQuantityToReserve > 0 || goldQuantityToReserve > 0,
                "RESERVE_MUST_BE_GREATER_THAN_ZERO"
            );
            require(
                silverQuantityToReserve + goldQuantityToReserve <=
                    maxMintsPerTx,
                "RESERVE_OVER_LIMIT"
            );
            require(entry != address(0), "NULL_ADDRESS");
            require(!presaleList[entry], "DUPLICATE_ENTRY");

            presaleList[entry] = true;
            if (silverQuantityToReserve > 0) {
                presaleReservedSilver[entry] = silverQuantityToReserve;
            }
            if (goldQuantityToReserve > 0) {
                presaleReservedGold[entry] = goldQuantityToReserve;
            }
        }
    }

    function removeFromEarlyBirdSaleList(address[] calldata entries)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");

            earlyBirdSaleList[entry] = false;
        }
    }

    function removeFromPresaleList(address[] calldata entries)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");

            presaleList[entry] = false;
            presaleReservedSilver[entry] = 0;
            presaleReservedGold[entry] = 0;
        }
    }

    function modifyTokenPrices(uint256 newSilverPrice, uint256 newGoldPrice)
        external
        onlyOwner
    {
        silverPrice = newSilverPrice;
        goldPrice = newGoldPrice;
    }

    function setVaultAddress(address newVault) external onlyOwner {
        require(newVault != address(0), "NULL_ADDRESS");
        vaultAddress = newVault;
    }

    function lockMetadata() external onlyOwner {
        metadataLocked = true;
    }

    function lockAuction() external onlyOwner {
        auctionAddress = address(0);
        auctionLocked = true;
    }

    function unlockAuction(address newAuctionAddress) external onlyOwner {
        auctionLocked = false;
        auctionAddress = newAuctionAddress;
    }

    function toggleEarlyBirdStatus() external onlyOwner {
        earlyBirdSaleLive = !earlyBirdSaleLive;
        if (earlyBirdSaleLive) {
            presaleLive = false;
            publicSaleLive = false;
        }
    }

    function togglePresaleStatus() external onlyOwner {
        presaleLive = !presaleLive;
        if (presaleLive) {
            earlyBirdSaleLive = false;
            publicSaleLive = false;
        }
    }

    function togglePublicSaleStatus() external onlyOwner {
        publicSaleLive = !publicSaleLive;
        if (publicSaleLive) {
            earlyBirdSaleLive = false;
            presaleLive = false;
        }
    }

    function setRevealTimestamp(uint256 timestamp) public onlyOwner {
        revealTimestamp = timestamp;
    }

    function setSignerAddress(address addressToSet) external onlyOwner {
        require(addressToSet != address(0), "NULL_ADDRESS");
        signerAddress = addressToSet;
    }

    function withdrawAll() external onlyOwner {
        payable(vaultAddress).transfer(address(this).balance);
    }

    function setContractURI(string calldata uri) external onlyOwner {
        nftContractURI = uri;
    }

    function assignAuctionContractAddress(address _auctionAddress)
        external
        onlyOwner
    {
        require(_auctionAddress != address(0), "NULL_ADDRESS");
        auctionAddress = _auctionAddress;
    }

    function adjustMaxMintsPerTx(uint8 _maxMintsPerTx) external onlyOwner {
        maxMintsPerTx = _maxMintsPerTx;
    }

    function initializePaperWallets(address[] memory wallets)
        public
        virtual
        onlyOwner
    {
        for (uint8 i = 0; i < wallets.length; i++) {
            paperWallets[wallets[i]] = true;
        }
    }

    function adjustSupply(
        uint16 newSilverSupply,
        uint16 newGoldSupply,
        uint16 newPlatinumSupply
    ) external onlyOwner {
        require(
            newPlatinumSupply == platinumSupply ||
                (mintedPlatinum <= newPlatinumSupply &&
                    mintedSilver == 0 &&
                    mintedGold == 0),
            "SUPPLY_CANNOT_CHANGE_AFTER_MINT"
        );
        require(
            newGoldSupply == goldSupply ||
                (mintedGold <= newGoldSupply && mintedSilver == 0),
            "SUPPLY_CANNOT_CHANGE_AFTER_MINT"
        );
        require(
            mintedSilver <= newSilverSupply,
            "SUPPLY_CANNOT_CHANGE_AFTER_MINT"
        );

        silverSupply = newSilverSupply;
        goldSupply = newGoldSupply;
        platinumSupply = newPlatinumSupply;
    }

    function setBaseTokenURI(string calldata uri)
        external
        onlyOwner
        metadataNotLocked
    {
        baseTokenURI = uri;
    }

    function setProvenanceHash(string calldata hash)
        external
        onlyOwner
        metadataNotLocked
    {
        proof = hash;
    }

    function emergencySetStartingIndexBlock()
        external
        onlyOwner
        metadataNotLocked
    {
        require(startingIndex == 0, "STARTING_INDEX_ALREADY_SET");
        startingIndexBlock = block.number;
    }
}// MIT
pragma solidity 0.8.11;


contract PrideIconsAuction is Ownable {
    uint16 internal constant SECONDS_IN_HOUR = 3600;
    uint8 internal constant DEFAULT_INTERVAL_HOURS = 24;
    uint8 internal constant DEFAULT_BIDS_IN_PARALLEL = 3;

    uint256 public minimumBid;

    struct BidOpenTimes {
        uint256 biddingOpen;
        uint256 biddingClosed;
    }
    mapping(uint8 => BidOpenTimes) public bidTimestamps;

    struct Bid {
        address walletBidder;
        address walletRecipient;
        uint256 bidAmount;
    }
    mapping(uint8 => Bid[]) public bidHistory;

    mapping(uint8 => bool) public cancelledAuctions;

    mapping(address => bool) private paperWallets;

    bool public locked;

    PrideIcons public prideIcons;

    address internal vaultAddress;

    event BidPlaced(
        uint8 indexed tokenId,
        address bidder,
        address recipient,
        uint256 amount
    );
    event AuctionEnded(
        uint8 indexed tokenId,
        address bidder,
        address recipient,
        uint256 amount
    );
    event AuctionCancelled(uint8 indexed tokenId, address bidder);

    constructor(
        address _vaultAddress,
        uint256 _minimumBid,
        address _prideIconsAddress,
        uint256 _timestamp,
        address[] memory _paperWallets
    ) {
        require(_vaultAddress != address(0), "NULL_ADDRESS");
        vaultAddress = _vaultAddress;
        minimumBid = _minimumBid;
        prideIcons = PrideIcons(_prideIconsAddress);
        initializeTimestamps(
            _timestamp,
            DEFAULT_INTERVAL_HOURS,
            DEFAULT_BIDS_IN_PARALLEL
        );
        initializePaperWallets(_paperWallets);
    }

    modifier notLocked() {
        require(!locked, "CONTRACT_METADATA_METHODS_ARE_LOCKED");
        _;
    }

    modifier onlyPaperOrOwner() {
        require(
            paperWallets[msg.sender] || owner() == msg.sender,
            "ONLY_PAPER_WALLETS_OR_OWNER_ALLOWED"
        );
        _;
    }

    function placeBid(uint8 tokenId, address recipient)
        external
        payable
        onlyPaperOrOwner
    {
        _placeBid(tokenId, recipient);
    }

    function placeBid(uint8 tokenId) external payable {
        _placeBid(tokenId, msg.sender);
    }

    function _placeBid(uint8 tokenId, address recipient) private notLocked {
        Bid memory currentTopBid = getTopBid(tokenId);
        require(
            block.timestamp >= bidTimestamps[tokenId].biddingOpen &&
                block.timestamp <= bidTimestamps[tokenId].biddingClosed,
            "BIDDING_FOR_TOKEN_CLOSED"
        );
        require(!cancelledAuctions[tokenId], "AUCTION_CANCELLED");

        Bid memory latestBid = Bid(msg.sender, recipient, msg.value);
        if (currentTopBid.bidAmount == 0) {
            require(latestBid.bidAmount >= minimumBid, "BID_UNDER_MINIMUM");
        } else {
            require(
                latestBid.bidAmount > currentTopBid.bidAmount,
                "BID_TOO_LOW"
            );
            payable(currentTopBid.walletBidder).transfer(
                currentTopBid.bidAmount
            );
        }
        bidHistory[tokenId].push(latestBid);
        emit BidPlaced(
            tokenId,
            latestBid.walletBidder,
            latestBid.walletRecipient,
            latestBid.bidAmount
        );
    }

    function endAuction(uint8 tokenId) external notLocked {
        Bid memory currentTopBid = getTopBid(tokenId);
        require(!cancelledAuctions[tokenId], "AUCTION_CANCELLED");
        require(
            msg.sender == currentTopBid.walletBidder ||
                paperWallets[msg.sender] ||
                msg.sender == owner(),
            "ONLY_BIDDER_OR_PAPER_OR_OWNER_ALLOWED"
        );
        require(
            block.timestamp >= bidTimestamps[tokenId].biddingClosed,
            "BIDDING_NOT_OVER"
        );
        require(address(prideIcons) != address(0), "NULL_CONTRACT_ADDRESS");
        require(currentTopBid.walletRecipient != address(0), "NO_WINNERS");
        prideIcons.mintPlatinum(tokenId, currentTopBid.walletRecipient);

        emit AuctionEnded(
            tokenId,
            currentTopBid.walletBidder,
            currentTopBid.walletRecipient,
            currentTopBid.bidAmount
        );
    }

    function cancelAuction(uint8 tokenId) external onlyPaperOrOwner notLocked {
        Bid memory currentTopBid = getTopBid(tokenId);
        require(!cancelledAuctions[tokenId], "ALREADY_CANCELLED");
        require(currentTopBid.bidAmount != 0, "MUST_HAVE_BID");
        require(currentTopBid.walletBidder != address(0), "MUST_HAVE_BIDDER");
        require(
            paperWallets[currentTopBid.walletBidder] || msg.sender == owner(),
            "ONLY_PAPER_BIDDER_OR_OWNER_ALLOWED"
        );
        require(address(prideIcons) != address(0), "NULL_CONTRACT_ADDRESS");
        require(
            !prideIcons.hasMintedPlatinum(tokenId),
            "AUCTION_ALREADY_ENDED"
        );

        payable(currentTopBid.walletBidder).transfer(currentTopBid.bidAmount);

        cancelledAuctions[tokenId] = true;

        emit AuctionCancelled(tokenId, currentTopBid.walletBidder);
    }

    function getBidHistory(uint8 tokenId) external view returns (Bid[] memory) {
        return bidHistory[tokenId];
    }

    function initializeTimestamps(
        uint256 firstBidStartTime,
        uint256 intervalDurationHours,
        uint8 bidsInParallel
    ) public onlyOwner {
        require(address(prideIcons) != address(0), "NULL_CONTRACT_ADDRESS");
        uint16 platinumSupply = prideIcons.platinumSupply();

        for (uint8 i = 1; i <= platinumSupply; i++) {
            for (uint8 j = 0; j < bidsInParallel; j++) {
                uint8 index = i + j + (bidsInParallel - 1) * (i - 1);
                if (index > platinumSupply) return;
                bidTimestamps[index] = BidOpenTimes(
                    firstBidStartTime +
                        ((i - 1) * intervalDurationHours * SECONDS_IN_HOUR),
                    firstBidStartTime +
                        (i * intervalDurationHours * SECONDS_IN_HOUR)
                );
            }
        }
    }

    function getTopBid(uint8 tokenId) public view returns (Bid memory) {
        Bid[] memory bids = bidHistory[tokenId];
        return
            bids.length == 0
                ? Bid(address(0), address(0), 0)
                : bids[bids.length - 1];
    }

    function initializePaperWallets(address[] memory wallets)
        public
        virtual
        onlyOwner
    {
        for (uint8 i = 0; i < wallets.length; i++) {
            paperWallets[wallets[i]] = true;
        }
    }

    function withdrawAll() external onlyOwner {
        payable(vaultAddress).transfer(address(this).balance);
    }

    function modifyTimeStampForTokens(
        uint8[] calldata tokenIds,
        BidOpenTimes[] calldata biddingTimes
    ) external onlyOwner {
        require(tokenIds.length == biddingTimes.length, "UNEQUAL_LENGTH");
        for (uint8 i = 0; i < tokenIds.length; i++) {
            bidTimestamps[tokenIds[i]] = biddingTimes[i];
        }
    }

    function setVaultAddress(address newVault) external onlyOwner {
        require(newVault != address(0), "NULL_ADDRESS");
        vaultAddress = newVault;
    }

    function setMinimumBid(uint256 _minimumBid) external onlyOwner {
        minimumBid = _minimumBid;
    }

    function assignNftContractAddress(address contractAddress)
        external
        onlyOwner
    {
        require(contractAddress != address(0), "NULL_ADDRESS");
        prideIcons = PrideIcons(contractAddress);
    }

    function lockAuction() external onlyOwner {
        locked = true;
    }

    function unlockAuction() external onlyOwner {
        locked = false;
    }

    struct CancelledAuctionMap {
        uint8 tokenId;
        bool cancelled;
    }
    struct BidHistoryMap {
        uint8 tokenId;
        Bid[] bids;
    }

    function migrate(
        CancelledAuctionMap[] calldata _cancelledAuctions,
        BidHistoryMap[] calldata _bidHistory
    ) external onlyOwner {
        for (uint8 i = 0; i < _bidHistory.length; i++) {
            uint8 tokenId = _bidHistory[i].tokenId;
            for (uint256 j = 0; j < _bidHistory[i].bids.length; j++) {
                bidHistory[tokenId].push(
                    Bid(
                        _bidHistory[i].bids[j].walletBidder,
                        _bidHistory[i].bids[j].walletRecipient,
                        _bidHistory[i].bids[j].bidAmount
                    )
                );
            }
        }

        for (uint8 i = 0; i < _cancelledAuctions.length; i++) {
            uint8 tokenId = _cancelledAuctions[i].tokenId;
            cancelledAuctions[tokenId] = _cancelledAuctions[i].cancelled;
        }
    }
}