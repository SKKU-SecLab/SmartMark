



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





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
}





pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





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

}





pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}





pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}





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
}





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
}





pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}





pragma solidity ^0.8.4;







error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintToZeroAddress();
error MintToDeadAddress();
error MintZeroQuantity();
error OwnerIndexOutOfBounds();
error OwnerQueryForNonexistentToken();
error TokenIndexOutOfBounds();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error TransferToDeadAddress();
error UnableGetTokenOwnerByIndex();
error URIQueryForNonexistentToken();

contract ERC721Opt is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    uint256 internal _nextTokenId = 1;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) internal _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    address constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function totalSupply() public view virtual returns (uint256) {

        unchecked {
            return (_nextTokenId - 1) - balanceOf(DEAD_ADDR);    
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address owner) {

        if (!_exists(tokenId)) revert OwnerQueryForNonexistentToken();

        unchecked {
            for (uint256 curr = tokenId;; curr--) {
                owner = _owners[curr];
                if (owner != address(0)) {
                    return owner;
                }
            }
        }
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) revert ApprovalCallerNotOwnerNorApproved();

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        if (operator == _msgSender()) revert ApproveToCaller();

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

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, _data)) revert TransferToNonERC721ReceiverImplementer();
    }

    function _isApprovedOrOwner(address sender, uint256 tokenId) internal view virtual returns (bool) {

        address owner = ownerOf(tokenId);

        return (sender == owner ||
            getApproved(tokenId) == sender ||
            isApprovedForAll(owner, sender));
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return tokenId > 0 && tokenId < _nextTokenId && _owners[tokenId] != DEAD_ADDR;
    }
    
    function _mint(address to, uint256 quantity) internal virtual {

        _mint(to, quantity, '', false);
    }

    function _safeMint(address to, uint256 quantity) internal virtual {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal virtual {

        _mint(to, quantity, _data, true);
    }

    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal virtual {

        uint256 startTokenId = _nextTokenId;
        if (to == address(0)) revert MintToZeroAddress();
        if (to == DEAD_ADDR) revert MintToDeadAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _balances[to] += quantity;

            _owners[startTokenId] = to;

            uint256 updatedIndex = startTokenId;

            for (uint256 i; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex);
                if (safe) {
                    if (!_checkOnERC721Received(address(0), to, updatedIndex, _data)) revert TransferToNonERC721ReceiverImplementer();
                }

                updatedIndex++;
            }

            _nextTokenId = updatedIndex;
        }

        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        address owner = ownerOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == owner ||
            isApprovedForAll(owner, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (owner != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert TransferToZeroAddress();
        if (to == DEAD_ADDR) revert TransferToDeadAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, owner);

        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;

            _owners[tokenId] = to;

            
            uint256 nextTokenId = tokenId + 1;
            if (_owners[nextTokenId] == address(0)) {
                if (nextTokenId < _nextTokenId) {
                    _owners[nextTokenId] = owner;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ownerOf(tokenId);

        _beforeTokenTransfers(owner, address(0), tokenId, 1);

        _approve(address(0), tokenId, owner);

        unchecked {
            _balances[owner] -= 1;
            _balances[DEAD_ADDR] += 1;

            _owners[tokenId] = DEAD_ADDR;

            
            uint256 nextTokenId = tokenId + 1;
            if (_owners[nextTokenId] == address(0)) {
                if (nextTokenId < _nextTokenId) { 
                    _owners[nextTokenId] = owner;
                }
            }
        }

        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfers(owner, address(0), tokenId, 1);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) revert TransferToNonERC721ReceiverImplementer();
                else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

}





pragma solidity ^0.8.4;

error AllOwnersHaveBeenSet();
error QuantityMustBeNonZero();
error NoTokensMintedYet();

abstract contract ERC721OptOwnersExplicit is ERC721Opt {
    uint256 public nextOwnerToExplicitlySet = 1;

    function _setOwnersExplicit(uint256 quantity) internal {
        if (quantity == 0) revert QuantityMustBeNonZero();
        if (_nextTokenId == 1) revert NoTokensMintedYet();
        uint256 _nextOwnerToExplicitlySet = nextOwnerToExplicitlySet;
        if (_nextOwnerToExplicitlySet >= _nextTokenId) revert AllOwnersHaveBeenSet();

        unchecked {
            uint256 endIndex = _nextOwnerToExplicitlySet + quantity - 1;

            if (endIndex + 1 > _nextTokenId) {
                endIndex = _nextTokenId - 1;
            }

            for (uint256 i = _nextOwnerToExplicitlySet; i <= endIndex; i++) {
                if (_owners[i] == address(0) && _owners[i] != DEAD_ADDR) {
                    address ownership = ownerOf(i);
                    _owners[i] = ownership;
                }
            }

            nextOwnerToExplicitlySet = endIndex + 1;
        }
    }
}





pragma solidity ^0.8.4;

error BurnCallerNotOwnerNorApproved();

abstract contract ERC721OptBurnable is ERC721Opt {

    function burn(uint256 tokenId) public virtual {
        if (!_isApprovedOrOwner(_msgSender(), tokenId)) revert BurnCallerNotOwnerNorApproved();
        _burn(tokenId);
    }
}





pragma solidity ^0.8.4;

abstract contract ERC721OptBatchBurnable is ERC721OptBurnable {
    function batchBurn(uint16[] memory tokenIds) public virtual {
        for (uint16 i = 0; i < tokenIds.length; ++i) {
            if (!_isApprovedOrOwner(_msgSender(), tokenIds[i])) revert BurnCallerNotOwnerNorApproved();
            _burn(tokenIds[i]);
        }
    }
}





pragma solidity ^0.8.4;

abstract contract ERC721OptBatchTransferable is ERC721Opt {
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint16[] tokenIds
    );

    function batchTransferFrom(
        address from,
        address to,
        uint16[] memory tokenIds
    ) public virtual {
        for (uint16 i = 0; i < tokenIds.length; ++i) {
            if (!_isApprovedOrOwner(_msgSender(), tokenIds[i])) revert TransferCallerNotOwnerNorApproved();
            transferFrom(from, to, tokenIds[i]);
        }

        emit TransferBatch(_msgSender(), from, to, tokenIds);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint16[] memory tokenIds
    ) public virtual {
        safeBatchTransferFrom(from, to, tokenIds, '');
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint16[] memory tokenIds,
        bytes memory _data
    ) public virtual {
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            if (!_isApprovedOrOwner(_msgSender(), tokenIds[i])) revert TransferCallerNotOwnerNorApproved();
            safeTransferFrom(from, to, tokenIds[i], _data);
        }

        emit TransferBatch(_msgSender(), from, to, tokenIds);
    }
}





pragma solidity ^0.8.4;




contract OpenSeaOwnableDelegateProxy {}

contract OpenSeaProxyRegistry {
    mapping(address => OpenSeaOwnableDelegateProxy) public proxies;
}

interface IToken {
    function updateRewards(address _user) external;
}

error CardTypeQueryForNonexistentToken();
error OnlyMintersCanMint();
error NoMintAmountProvided();
error AllSilverCardsMinted();
error AllBlackCardsMinted();

contract DAOBnBNFT is Ownable, ERC721Opt, ERC721OptOwnersExplicit, ERC721OptBatchBurnable, ERC721OptBatchTransferable {
     using Strings for uint16;

    string public baseURI;

    address public openSeaProxyRegistryAddress;

    IToken public token;

    uint16 silverCardsMax = 6400;
    uint16 blackCardsMax = 2700;

    uint16 blackCardsMinted;

    mapping(address => uint16) public walletBlackCards;
    
    mapping(address => bool) public minters;

    mapping(uint16 => bool) _blackCardTokenIds;
    
    constructor(string memory name_, string memory symbol_, string memory _initialBaseURI, address _openSeaProxyRegistryAddress, address[] memory _minters) ERC721Opt(name_, symbol_) {
        baseURI = _initialBaseURI;
        openSeaProxyRegistryAddress = _openSeaProxyRegistryAddress;
        
        for (uint256 i = 0; i < _minters.length; i++) {
            minters[_minters[i]] = true;
        }
    }

    function silverCardsLeft() public view returns (uint256) {
        return silverCardsMax - (_nextTokenId - 1 - blackCardsMinted);
    }

    function blackCardsLeft() public view returns (uint256) {
        return blackCardsMax - blackCardsMinted;
    }

    function tokenCardType(uint16 tokenId) public view returns (string memory) {
        if (!_exists(tokenId)) revert CardTypeQueryForNonexistentToken();

        if (_blackCardTokenIds[tokenId]) {
            return "black";
        }

        return "silver";
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        OpenSeaProxyRegistry openSeaProxyRegistry = OpenSeaProxyRegistry(
            openSeaProxyRegistryAddress
        );
        if (address(openSeaProxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return ERC721Opt.isApprovedForAll(owner, operator);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(_baseURI(), tokenCardType(uint16(tokenId)), '.json'))
                : '';
    }

    function mint(uint16 silverCardsAmount, uint16 blackCardsAmount, address to) public {
        if(!minters[msg.sender]) revert OnlyMintersCanMint();
        if(silverCardsAmount + blackCardsAmount == 0) revert NoMintAmountProvided();
        if(_nextTokenId - 1 - blackCardsMinted + silverCardsAmount > silverCardsMax) revert AllSilverCardsMinted();
        if(blackCardsMinted + blackCardsAmount > blackCardsMax) revert AllBlackCardsMinted();

        if (blackCardsAmount > 0) {
            blackCardsMinted += blackCardsAmount;

            uint16 tokenId = uint16(_nextTokenId) + silverCardsAmount;

            for (uint16 i; i < blackCardsAmount; i++) {
                _blackCardTokenIds[tokenId++] = true;
            }
        }
        
        _safeMint(to, silverCardsAmount + blackCardsAmount, '');
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        if (address(token) != address(0)) {
            token.updateRewards(from);
            token.updateRewards(to);
        }

        uint16 blackCards;

        for(uint16 i = uint16(startTokenId); i < startTokenId + quantity; i++) {
            if (_blackCardTokenIds[i]) {
                blackCards += 1;
            }
        }

        if (from != address(0)) {
            walletBlackCards[from] -= blackCards;
        }
        if (to != address(0)) {
            walletBlackCards[to] += blackCards;
        }

        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setMinters(address[] calldata addresses, bool allowed) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++) {
            minters[addresses[i]] = allowed;
        }
    }

    function updateAvailableCards(uint16 silverCards, uint16 blackCards) external onlyOwner {
        silverCardsMax = silverCards;
        blackCardsMax = blackCards;
    }

    function setToken(IToken _token) external onlyOwner {
        token = _token;
    }

    function updateOwners(uint256 quantity) external onlyOwner {
        _setOwnersExplicit(quantity);
    }
}





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

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




pragma solidity ^0.8.0;



contract DAOBnBMinter is Ownable {
    using Strings for uint16;
    using ECDSA for bytes32;

    DAOBnBNFT nftContract;

    bool public preSaleIsActive;
    bool public saleIsActive;
    
    uint16 public maxPreSaleSilverCardsPerAddress = 2;
    uint16 public maxPreSaleBlackCardsPerAddress = 1;

    uint16 public maxPreSaleSilverCardsPerTransaction = 2;
    uint16 public maxPreSaleBlackCardsPerTransaction = 1;
    
    uint16 public maxSilverCardsPerTransaction = 16;
    uint16 public maxBlackCardsPerTransaction = 4;

    uint16 public reservedSilverCards = 640;
    uint16 public reservedBlackCards = 270;

    uint256 public preSaleSilverCardPrice = 0.175 ether;
    uint256 public preSaleBlackCardPrice = 0.7 ether;

    uint256 public silverCardPrice = 0.175 ether;
    uint256 public blackCardPrice = 0.7 ether;
    
    mapping(address => bool) public preSaleListSignatureAddresses;
    mapping(uint16 => address) public preSaleListSignatureUsedNounces;
    
    mapping(address => bool) public preSaleListedAddresses;

    mapping(address => uint16) public preSaleSilverCardPurchases;
    mapping(address => uint16) public preSaleBlackCardPurchases;

    constructor(
        DAOBnBNFT _nftContract,
        address[] memory _preSaleListSignatureAddresses
    ) {
        nftContract = _nftContract;

        for (uint256 i = 0; i < _preSaleListSignatureAddresses.length; i++) {
            preSaleListSignatureAddresses[_preSaleListSignatureAddresses[i]] = true;
        }
    }

    function getPreSaleListMessage(uint16 nounce, address sender)
        public
        pure
        returns (bytes32)
    {
        if (nounce > 0) {
            return keccak256(abi.encodePacked('ProjectId: 621285d3e200cdf5b5ef5704, Nounce: ', nounce));
        }
        
        return keccak256(abi.encodePacked('ProjectId: 621285d3e200cdf5b5ef5704, Address: ', sender));
    }
    
    function mintPreSale(uint16 silverCardsAmount, uint16 blackCardsAmount, uint16 nounce, bytes calldata signature) external payable {
        require(preSaleIsActive, 'Pre sale must be active to mint pre sale');
        require(!saleIsActive, 'Regular sale is already active');
        require(
            silverCardsAmount + blackCardsAmount > 0,
            'No amounts provided'
        );
        require(
            silverCardsAmount <= maxPreSaleSilverCardsPerTransaction,
            'Can not mint that many silver tokens in a single transaction during the pre sale'
        );
        require(
            blackCardsAmount <= maxPreSaleBlackCardsPerTransaction,
            'Can not mint that many black tokens in a single transaction during the pre sale'
        );
        require(
            silverCardsAmount <= nftContract.silverCardsLeft() - reservedSilverCards,
            'Sold Out'
        );
        require(
            blackCardsAmount <= nftContract.blackCardsLeft() - reservedBlackCards,
            'Sold Out'
        );
        require(
            preSaleSilverCardPurchases[msg.sender] + silverCardsAmount <= maxPreSaleSilverCardsPerAddress,
            'Can only mint so many silver cards during the presale'
        );
        require(
            preSaleBlackCardPurchases[msg.sender] + blackCardsAmount <= maxPreSaleBlackCardsPerAddress,
            'Can only mint so many black cards during the presale'
        );
        require(
            msg.value >= (preSaleSilverCardPrice * silverCardsAmount) + (preSaleBlackCardPrice * blackCardsAmount),
            'Ether value sent is not correct'
        );
        require(preSaleListedAddresses[_msgSender()] || signature.length > 0, 'Signature required for pre sale');
        require(nounce == 0 || preSaleListSignatureUsedNounces[nounce] == address(0) || preSaleListSignatureUsedNounces[nounce] == _msgSender(), 'Invalid or used nounce');

        if (!preSaleListedAddresses[_msgSender()] && preSaleListSignatureUsedNounces[nounce] != _msgSender()) {
            bytes32 message = getPreSaleListMessage(nounce, _msgSender());
            bytes32 messageHash = message.toEthSignedMessageHash();
            address signer = messageHash.recover(signature);

            require(preSaleListSignatureAddresses[signer], 'Signature invalid');

            if (nounce > 0) {
                preSaleListSignatureUsedNounces[nounce] = _msgSender();
            }
        }

        preSaleSilverCardPurchases[msg.sender] += silverCardsAmount;
        preSaleBlackCardPurchases[msg.sender] += blackCardsAmount;

        nftContract.mint(silverCardsAmount, blackCardsAmount, msg.sender);
    }
    
    function mint(uint16 silverCardsAmount, uint16 blackCardsAmount) external payable {
        require(saleIsActive, 'Regular sale is not active');
        require(
            silverCardsAmount + blackCardsAmount > 0,
            'No amounts provided'
        );
        require(
            silverCardsAmount <= maxSilverCardsPerTransaction,
            'Can not mint that many silver cards in a single transaction during the sale'
        );
        require(
            blackCardsAmount <= maxBlackCardsPerTransaction,
            'Can not mint that many black cards in a single transaction during the sale'
        );
        require(
            silverCardsAmount <= nftContract.silverCardsLeft() - reservedSilverCards,
            'Sold Out'
        );
        require(
            blackCardsAmount <= nftContract.blackCardsLeft() - reservedBlackCards,
            'Sold Out'
        );
        require(
            msg.value >= (silverCardPrice * silverCardsAmount) + (blackCardPrice * blackCardsAmount),
            'Ether value sent is not correct'
        );

        nftContract.mint(silverCardsAmount, blackCardsAmount, _msgSender());
    }
    
    function updatePreSaleListSignatureAddresses(address[] memory _preSaleListSignatureAddresses, bool allowed)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _preSaleListSignatureAddresses.length; i++) {
            preSaleListSignatureAddresses[_preSaleListSignatureAddresses[i]] = allowed;
        }
    }
    
    function updatePreSaleListedAddresses(address[] memory _preSaleListedAddresses, bool allowed)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _preSaleListedAddresses.length; i++) {
            preSaleListedAddresses[_preSaleListedAddresses[i]] = allowed;
        }
    }

    function flipPreSaleState() external onlyOwner {
        preSaleIsActive = !preSaleIsActive;
    }

    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function setMaxPreSaleCardsPerAddress(uint16 _silverCardsAmount, uint16 _blackCardsAmount) external onlyOwner {
        maxPreSaleSilverCardsPerAddress = _silverCardsAmount;
        maxPreSaleBlackCardsPerAddress = _blackCardsAmount;
    }

    function setMaxPreSaleCardsPerTransaction(uint16 _silverCardsAmount, uint16 _blackCardsAmount) external onlyOwner {
        maxPreSaleSilverCardsPerTransaction = _silverCardsAmount;
        maxPreSaleBlackCardsPerTransaction = _blackCardsAmount;
    }

    function setMaxCardsPerTransaction(uint16 _silverCardsAmount, uint16 _blackCardsAmount, bool updatePreSaleAlso) external onlyOwner {
        maxSilverCardsPerTransaction = _silverCardsAmount;
        maxBlackCardsPerTransaction = _blackCardsAmount;

        if (updatePreSaleAlso) {
            maxPreSaleSilverCardsPerTransaction = _silverCardsAmount;
            maxPreSaleBlackCardsPerTransaction = _blackCardsAmount;
        }
    }

    function setReservedCards(uint16 _silverCardsAmount, uint16 _blackCardsAmount) external onlyOwner {
        reservedSilverCards = _silverCardsAmount;
        reservedBlackCards = _blackCardsAmount;
    }

    function setPreSalePrice(uint256 _silverCardPrice, uint256 _blackCardPrice) external onlyOwner {
        preSaleSilverCardPrice = _silverCardPrice;
        preSaleBlackCardPrice = _blackCardPrice;
    }

    function setPrice(uint256 _silverCardPrice, uint256 _blackCardPrice, bool updatePreSaleAlso) external onlyOwner {
        silverCardPrice = _silverCardPrice;
        blackCardPrice = _blackCardPrice;

        if (updatePreSaleAlso) {
            preSaleSilverCardPrice = _silverCardPrice;
            preSaleBlackCardPrice = _blackCardPrice;
        }
    }

    function reserveMint(uint16 silverCardsAmount, uint16 blackCardsAmount, address[] calldata to) external onlyOwner {
        require(
            (silverCardsAmount * to.length) <= reservedSilverCards,
            'Not enough reserve left for team'
        );
        require(
            (blackCardsAmount * to.length) <= reservedBlackCards,
            'Not enough reserve left for team'
        );
        require(
            silverCardsAmount + blackCardsAmount > 0,
            'No amounts provided'
        );

        for (uint16 i = 0; i < to.length; i++) {
            nftContract.mint(silverCardsAmount, blackCardsAmount, to[i]);
        }

        reservedSilverCards = uint16(reservedSilverCards - (silverCardsAmount * to.length));
        reservedBlackCards = uint16(reservedBlackCards - (blackCardsAmount * to.length));
    }
    
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}