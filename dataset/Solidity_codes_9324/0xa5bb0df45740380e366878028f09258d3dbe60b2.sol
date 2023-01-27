
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT
pragma solidity ^0.8.0;


abstract contract ProtectedMint is Ownable {
    address[] public minterAddresses;

    modifier onlyMinter() {
        bool isAllowed;

        for (uint256 i; i < minterAddresses.length; i++) {
            if (minterAddresses[i] == msg.sender) {
                isAllowed = true;

                break;
            }
        }

        require(isAllowed, "Minter: caller is not an allowed minter");

        _;
    }

    function addMinterAddress(address _minterAddress) external onlyOwner {
        minterAddresses.push(_minterAddress);
    }

    function removeMinterAddress(address _minterAddress) external onlyOwner {
        for (uint256 i; i < minterAddresses.length; i++) {
            if (minterAddresses[i] != _minterAddress) {
                continue;
            }

            minterAddresses[i] = minterAddresses[minterAddresses.length - 1];

            minterAddresses.pop();
        }
    }
}// MIT
pragma solidity ^0.8.0;

contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, ProtectedMint {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) internal _owners;

    mapping(address => uint16) internal _balances;

    mapping(uint16 => address) internal _tokenApprovals;

    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    address proxyRegistryAddress;

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

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, uint16(tokenId));
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[uint16(tokenId)];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        if (proxyRegistryAddress != address(0)) {
            ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
            if (address(proxyRegistry.proxies(owner)) == operator) {
                return true;
            }
        }

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

    function setProxyRegistryAddress(address _proxyRegistryAddress) external onlyOwner {

        proxyRegistryAddress = _proxyRegistryAddress;
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
        address owner = ownerOf(tokenId);
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

    function _burn(uint16 tokenId) internal virtual {

        address owner = ownerOf(tokenId);

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

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), uint16(tokenId));

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint16 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
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


interface ITrait is IERC721 {
    function onTraitAddedToAvatar(uint16 _tokenId, uint16 _avatarId) external;

    function onAvatarTransfer(
        address _from,
        address _to,
        uint16 _tokenId
    ) external;

    function onTraitRemovedFromAvatar(uint16 _tokenId, address _owner) external;

    function traitToAvatar(uint16) external returns (uint16);

    function mint(uint256 _tokenId, address _to) external;

    function burn(uint16 _tokenId) external;
}// MIT
pragma solidity ^0.8.0;


contract QueensAndKingsAvatars is ERC721 {
    using Strings for uint256;

    modifier onlyAvatarOwner(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "Caller is not the owner of the avatar");

        _;
    }

    address public signerAddress;

    string public baseURI = "ipfs://HASH/";
    uint16 public totalTokens = 6900;
    uint16 public totalSupply = 0;
    uint256 public latestExternalTokenId = totalTokens + 1;

    address[] public traitTypeToAddress;

    mapping(uint16 => mapping(uint8 => uint16)) public avatarTraits;
    mapping(uint16 => bool) public hasMintedTraits;
    mapping(uint256 => uint16) public externalToInternalMapping;
    mapping(uint16 => uint256) public internalToExternalMapping;
    mapping(uint16 => bool) public frozenAvatars;

    bool isFreezeAllowed;

    constructor() ERC721("Queens+KingsAvatars", "Q+KA") {}


    function setSignerAddress(address _signerAddress) external onlyOwner {
        signerAddress = _signerAddress;
    }

    function setBaseTokenURI(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }

    function addTraitType(address _traitAddress) external onlyOwner {
        traitTypeToAddress.push(_traitAddress);
    }

    function resetTraitTypes() external onlyOwner {
        delete traitTypeToAddress;
    }

    function setFreezedAllowed(bool _isFreezeAllowed) external onlyOwner {
        isFreezeAllowed = _isFreezeAllowed;
    }



    function mint(uint16 _tokenId, address _to) external onlyMinter {
        require(_tokenId > 0 && _tokenId <= totalTokens, "Token ID cannot be 0");
        require(totalSupply < totalTokens, "Cannot mint more avatars");

        externalToInternalMapping[_tokenId] = _tokenId;
        internalToExternalMapping[_tokenId] = _tokenId;

        totalSupply++;

        _mint(_to, _tokenId);
    }



    function setTraitsToAvatar(uint256 _tokenId, uint16[] memory _traits) external onlyAvatarOwner(_tokenId) {
        require(traitTypeToAddress.length == _traits.length, "Invalid amount of traits");
        uint16 _iTokenId = getInternalMapping(_tokenId);
        require(hasMintedTraits[_iTokenId], "Can not modify avatar until original traits are minted");

        require(!frozenAvatars[_iTokenId], "Can not change the traits of a frozen avatar");

        bool regenerate;
        uint256[] memory traitsPreviousAvatar = new uint256[](_traits.length);
        uint256 regeneratePreviousAvatarCounter;

        for (uint8 i; i < _traits.length; i++) {
            if (_traits[i] == avatarTraits[_iTokenId][i]) {
                continue;
            }

            ITrait trait = ITrait(traitTypeToAddress[i]);

            require(_traits[i] == 0 || trait.ownerOf(_traits[i]) == msg.sender, "Caller is not the owner of the trait");

            uint16 newTraitCurrentAvatarId = trait.traitToAvatar(_traits[i]);

            if (newTraitCurrentAvatarId != 0 && newTraitCurrentAvatarId != _iTokenId) {
                avatarTraits[newTraitCurrentAvatarId][i] = 0;

                traitsPreviousAvatar[regeneratePreviousAvatarCounter] = getExternalMapping(newTraitCurrentAvatarId);

                regeneratePreviousAvatarCounter++;
            }

            if (avatarTraits[_iTokenId][i] != 0) {
                regenerate = true;
                trait.onTraitRemovedFromAvatar(avatarTraits[_iTokenId][i], ownerOf(_tokenId));
            }

            avatarTraits[_iTokenId][i] = _traits[i];

            if (_traits[i] != 0) {
                trait.onTraitAddedToAvatar(_traits[i], _iTokenId);
            }
        }

        for (uint256 i; i < regeneratePreviousAvatarCounter; i++) {
            if (_exists(traitsPreviousAvatar[i])) {
                regenerateAvatar(traitsPreviousAvatar[i]);
            }
        }

        if (regenerate) {
            regenerateAvatar(_tokenId);
        }
    }

    function mintTraits(
        uint16 _tokenId,
        uint16[] memory _traits,
        bytes calldata _signature
    ) external {
        require(ownerOf(_tokenId) == msg.sender, "Caller is not the owner of the avatar");
        require(_tokenId <= totalTokens, "Invalid token Id");
        require(!hasMintedTraits[_tokenId], "Traits already minted");

        bytes32 messageHash = generateMessageHash(_tokenId, _traits);
        address recoveredWallet = ECDSA.recover(messageHash, _signature);
        require(recoveredWallet == signerAddress, "Invalid signature for the caller");

        hasMintedTraits[_tokenId] = true;

        for (uint8 i; i < _traits.length; i++) {
            if (_traits[i] == 0) {
                continue;
            }

            ITrait trait = ITrait(traitTypeToAddress[i]);
            trait.mint(_traits[i], msg.sender);

            avatarTraits[_tokenId][i] = _traits[i];

            trait.onTraitAddedToAvatar(_traits[i], _tokenId);
        }
    }

    function freeze(uint256 _tokenId) external {
        require(isFreezeAllowed, "Cannot freeze at this stage");
        uint16 _iTokenId = getInternalMapping(_tokenId);

        require(ownerOf(_tokenId) == msg.sender, "Caller is not the owner of the avatar");
        require(hasMintedTraits[_iTokenId], "Traits have not been minted");
        require(!frozenAvatars[_iTokenId], "Avatar is already frozen");

        frozenAvatars[_iTokenId] = true;

        for (uint8 i; i < traitTypeToAddress.length; i++) {
            if (avatarTraits[_iTokenId][i] == 0) {
                continue;
            }

            ITrait trait = ITrait(traitTypeToAddress[i]);
            trait.burn(avatarTraits[_iTokenId][i]);
        }
    }



    function removeTrait(uint16 _iTokenId) external {
        require(!frozenAvatars[_iTokenId], "Avatar is already frozen");
        bool found;

        uint256 _tokenId = getExternalMapping(_iTokenId);

        for (uint8 i; i < traitTypeToAddress.length; i++) {
            if (traitTypeToAddress[i] == msg.sender) {
                avatarTraits[getInternalMapping(_tokenId)][i] = 0;
                found = true;

                break;
            }
        }

        require(found, "Caller is not allowed");

        regenerateAvatar(_tokenId);
    }



    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        uint16 _iTokenId = getInternalMapping(tokenId);

        _approve(address(0), uint16(tokenId));

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[_iTokenId] = to;

        emit Transfer(from, to, tokenId);

        for (uint8 i; i < traitTypeToAddress.length; i++) {
            if (avatarTraits[_iTokenId][i] == 0) {
                continue;
            }

            ITrait traitContract = ITrait(traitTypeToAddress[i]);
            traitContract.onAvatarTransfer(from, to, avatarTraits[_iTokenId][i]);
        }
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        uint16 _iTokenId;
        if (tokenId > totalTokens) {
            _iTokenId = getInternalMapping(tokenId);
        } else {
            _iTokenId = uint16(tokenId);
        }

        address owner = _owners[_iTokenId];
        require(owner != address(0), "ERC721 Avatar: owner query for nonexistent token");

        return owner;
    }

    function _exists(uint256 tokenId) internal view override returns (bool) {
        uint16 _iTokenId = externalToInternalMapping[tokenId];

        return _owners[_iTokenId] != address(0);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[getInternalMapping(tokenId)];
    }

    function _approve(address to, uint16 tokenId) internal virtual override {
        _tokenApprovals[getInternalMapping(tokenId)] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }


    function getAvatarTraits(uint256 _tokenId) external view returns (uint16[] memory) {
        require(_exists(_tokenId), "ERC721: operator query for nonexistent token");

        uint16 _iTokenId = getInternalMapping(_tokenId);

        uint16[] memory traits = new uint16[](traitTypeToAddress.length);
        for (uint8 i; i < traitTypeToAddress.length; i++) {
            traits[i] = avatarTraits[_iTokenId][i];
        }

        return traits;
    }


    function regenerateAvatar(uint256 _tokenId) internal returns (uint256) {
        address _owner = ownerOf(_tokenId);

        emit Transfer(_owner, address(0), _tokenId);
        emit Transfer(address(0), _owner, latestExternalTokenId);

        uint16 _iTokenId = getInternalMapping(_tokenId);

        externalToInternalMapping[latestExternalTokenId] = _iTokenId;
        internalToExternalMapping[_iTokenId] = latestExternalTokenId;

        delete externalToInternalMapping[_tokenId];

        latestExternalTokenId++;

        return latestExternalTokenId - 1;
    }

    function getInternalMapping(uint256 _tokenId) internal view returns (uint16) {
        require(externalToInternalMapping[_tokenId] != 0, "getInternalMapping: Invalid mapping");

        return externalToInternalMapping[_tokenId];
    }

    function getExternalMapping(uint16 _iTokenId) internal view returns (uint256) {
        require(internalToExternalMapping[_iTokenId] != 0, "getExternalMapping: Invalid mapping");

        return internalToExternalMapping[_iTokenId];
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function generateMessageHash(uint256 _avatarId, uint16[] memory _traitIds) internal pure returns (bytes32) {
        uint256 signatureBytes = 32 + _traitIds.length * 32;

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n", signatureBytes.toString(), _avatarId, _traitIds)
            );
    }
}// MIT
pragma solidity ^0.8.0;


contract FirstDrop is Ownable {
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    address public avatarContractAddress;
    address public signerAddress;
    address public sAddress;

    uint16 public sMintLimit = 300;
    uint16 public sMintedTokens = 0;

    uint16 public totalAvatars = 2000;
    uint256 public mintPrice = 0.423 ether;

    string public ipfsAvatars;

    mapping(uint16 => uint16) private tokenMatrix;
    mapping(address => uint8) public mintsPerUser;

    function setTotalAvatars(uint16 _totalAvatars) external onlyOwner {
        totalAvatars = _totalAvatars;
    }


    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function setAvatarContractAddress(address _address) external onlyOwner {
        avatarContractAddress = _address;
    }

    function setSignerAddress(address _signerAddress) external onlyOwner {
        signerAddress = _signerAddress;
    }

    function setSAddress(address _sAddress) external onlyOwner {
        sAddress = _sAddress;
    }

    function setSMintLimit(uint16 _sMintLimit) external onlyOwner {
        sMintLimit = _sMintLimit;
    }

    function setIPFSAvatars(string memory _ipfsAvatars) external onlyOwner {
        ipfsAvatars = _ipfsAvatars;
    }


    function mint(
        uint8 _quantity,
        uint256 _fromTimestamp,
        uint256 _toTimestamp,
        uint8 _maxQuantity,
        bytes calldata _signature
    ) external payable callerIsUser {
        bytes32 messageHash = generateMessageHash(msg.sender, _fromTimestamp, _toTimestamp, _maxQuantity);
        address recoveredWallet = ECDSA.recover(messageHash, _signature);

        require(recoveredWallet == signerAddress, "Invalid signature for the caller");
        require(block.timestamp >= _fromTimestamp, "Too early to mint");
        require(block.timestamp <= _toTimestamp, "The signature has expired");

        QueensAndKingsAvatars qakContract = QueensAndKingsAvatars(avatarContractAddress);
        uint16 tmpTotalSupply = qakContract.totalSupply();

        uint256 tokensLeft = totalAvatars - tmpTotalSupply;
        require(tokensLeft > 0, "No tokens left to be minted");

        if (_quantity + mintsPerUser[msg.sender] > _maxQuantity) {
            _quantity = _maxQuantity - mintsPerUser[msg.sender];
        }

        if (_quantity > tokensLeft) {
            _quantity = uint8(tokensLeft);
        }

        uint256 totalMintPrice = mintPrice * _quantity;
        require(msg.value >= totalMintPrice, "Not enough Ether provided to mint");

        if (msg.value > totalMintPrice) {
            payable(msg.sender).transfer(msg.value - totalMintPrice);
        }

        require(_quantity != 0, "Address mint limit reached");

        mintsPerUser[msg.sender] += _quantity;

        for (uint16 i; i < _quantity; i++) {
            uint16 _tokenId = _getTokenToBeMinted(tmpTotalSupply);
            qakContract.mint(_tokenId, msg.sender);
            tmpTotalSupply++;
        }
    }

    function mintTo(address[] memory _addresses) external {
        require(msg.sender == sAddress, "Caller is not allowed to mint");
        require(_addresses.length > 0, "At least one token should be minted");
        require(sMintedTokens + _addresses.length <= sMintLimit, "Mint limit reached");

        QueensAndKingsAvatars qakContract = QueensAndKingsAvatars(avatarContractAddress);
        uint16 tmpTotalSupply = qakContract.totalSupply();

        sMintedTokens += uint16(_addresses.length);
        for (uint256 i; i < _addresses.length; i++) {
            qakContract.mint(_getTokenToBeMinted(tmpTotalSupply), _addresses[i]);
            tmpTotalSupply++;
        }
    }

    function mintToDev(address[] memory _addresses) external onlyOwner {
        require(_addresses.length > 0, "At least one token should be minted");

        QueensAndKingsAvatars qakContract = QueensAndKingsAvatars(avatarContractAddress);
        uint16 tmpTotalSupply = qakContract.totalSupply();

        uint256 tokensLeft = totalAvatars - tmpTotalSupply;
        require(tokensLeft > 0, "No tokens left to be minted");

        for (uint256 i; i < _addresses.length; i++) {
            qakContract.mint(_getTokenToBeMinted(tmpTotalSupply), _addresses[i]);
            tmpTotalSupply++;
        }
    }

    function getAvailableTokens() external view returns (uint16) {
        QueensAndKingsAvatars qakContract = QueensAndKingsAvatars(avatarContractAddress);

        return totalAvatars - qakContract.totalSupply();
    }

    function generateMessageHash(
        address _address,
        uint256 _fromTimestamp,
        uint256 _toTimestamp,
        uint8 _maxQuantity
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n85",
                    _address,
                    _fromTimestamp,
                    _toTimestamp,
                    _maxQuantity
                )
            );
    }

    function _getTokenToBeMinted(uint16 _totalMintedTokens) private returns (uint16) {
        uint16 maxIndex = totalAvatars + sMintLimit - _totalMintedTokens;
        uint16 random = _getRandomNumber(maxIndex, _totalMintedTokens);

        uint16 tokenId = tokenMatrix[random];
        if (tokenMatrix[random] == 0) {
            tokenId = random;
        }

        tokenMatrix[maxIndex - 1] == 0 ? tokenMatrix[random] = maxIndex - 1 : tokenMatrix[random] = tokenMatrix[
            maxIndex - 1
        ];

        return tokenId + 1;
    }

    function _getRandomNumber(uint16 _upper, uint16 _totalMintedTokens) private view returns (uint16) {
        uint16 random = uint16(
            uint256(
                keccak256(
                    abi.encodePacked(
                        _totalMintedTokens,
                        blockhash(block.number - 1),
                        block.coinbase,
                        block.difficulty,
                        msg.sender
                    )
                )
            )
        );

        return (random % _upper);
    }
}