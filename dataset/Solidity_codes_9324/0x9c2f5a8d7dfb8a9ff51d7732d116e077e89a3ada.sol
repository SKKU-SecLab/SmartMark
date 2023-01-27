
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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
}

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

}

pragma solidity >=0.6.0 <0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

pragma solidity >=0.6.2 <0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

pragma solidity >=0.6.0 <0.8.0;

library StringsUpgradeable {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}

pragma solidity 0.7.6;


contract ERC721UpgradeableMinimal is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    mapping(uint256 => bool) private _burnedTokens;

    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
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

    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721UpgradeableMinimal.ownerOf(tokenId);
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
        address owner = ERC721UpgradeableMinimal.ownerOf(tokenId);
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
        require(!_burnedTokens[tokenId], "token already burned");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        _emitMintEvent(to, tokenId);
    }

    function _emitMintEvent(address to, uint tokenId) internal virtual {

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721UpgradeableMinimal.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _clearMetadata(tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        _setBurned(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _setBurned(uint256 tokenId) internal {

        _burnedTokens[tokenId] = true;
    }

    function _clearMetadata(uint256 tokenId) internal virtual {

    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721UpgradeableMinimal.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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
        emit Approval(ERC721UpgradeableMinimal.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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

    uint256[43] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC721BurnableUpgradeableMinimal is Initializable, ContextUpgradeable, ERC721UpgradeableMinimal {
    function __ERC721Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Burnable_init_unchained();
    }

    function __ERC721Burnable_init_unchained() internal initializer {
    }
    function burn(uint256 tokenId) public virtual {
        if(!_exists(tokenId)) {
            address owner = address(tokenId >> 96);
            require(owner == _msgSender(), "ERC721Burnable: caller is not owner, not burn");
            _setBurned(tokenId);
        } else {
            require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
            _burn(tokenId);
        }
    }

    uint256[50] private __gap;
}// MIT

pragma solidity 0.7.6;


abstract contract ERC721DefaultApprovalMinimal is ERC721UpgradeableMinimal {
    mapping(address => bool) private defaultApprovals;

    event DefaultApproval(address indexed operator, bool hasApproval);

    function _setDefaultApproval(address operator, bool hasApproval) internal {
        defaultApprovals[operator] = hasApproval;
        emit DefaultApproval(operator, hasApproval);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal virtual override view returns (bool) {
        return defaultApprovals[spender] || super._isApprovedOrOwner(spender, tokenId);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return defaultApprovals[operator] || super.isApprovedForAll(owner, operator);
    }
    uint256[50] private __gap;
}

pragma solidity >=0.6.2 <0.8.0;

library LibPart {

    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {

        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

pragma solidity >=0.6.2 <0.8.0;


abstract contract AbstractRoyalties {
    mapping (uint256 => LibPart.Part[]) internal royalties;

    function _saveRoyalties(uint256 id, LibPart.Part[] memory _royalties) internal {
        uint256 totalValue;
        for (uint i = 0; i < _royalties.length; i++) {
            require(_royalties[i].account != address(0x0), "Recipient should be present");
            require(_royalties[i].value != 0, "Royalty value should be positive");
            totalValue += _royalties[i].value;
            royalties[id].push(_royalties[i]);
        }
        require(totalValue < 10000, "Royalty total value should be < 10000");
        _onRoyaltiesSet(id, _royalties);
    }

    function _updateAccount(uint256 _id, address _from, address _to) internal {
        uint length = royalties[_id].length;
        for(uint i = 0; i < length; i++) {
            if (royalties[_id][i].account == _from) {
                royalties[_id][i].account = address(uint160(_to));
            }
        }
    }

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties) virtual internal;
}

pragma solidity >=0.6.2 <0.8.0;
pragma abicoder v2;


interface RoyaltiesV2 {

    event RoyaltiesSet(uint256 tokenId, LibPart.Part[] royalties);

    function getWoonklyNFTV2Royalties(uint256 id) external view returns (LibPart.Part[] memory);

}

pragma solidity >=0.6.2 <0.8.0;


contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2 {


    function getWoonklyNFTV2Royalties(uint256 id) override external view returns (LibPart.Part[] memory) {

        return royalties[id];
    }

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties) override internal {

        emit RoyaltiesSet(id, _royalties);
    }
}

pragma solidity >=0.6.2 <0.8.0;

library LibRoyaltiesV2 {

    bytes4 constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
}

pragma solidity >=0.6.2 <0.8.0;


abstract contract RoyaltiesV2Upgradeable is ERC165Upgradeable, RoyaltiesV2 {
    function __RoyaltiesV2Upgradeable_init_unchained() internal initializer {
        _registerInterface(LibRoyaltiesV2._INTERFACE_ID_ROYALTIES);
    }
}

pragma solidity >=0.6.2 <0.8.0;


library LibERC721LazyMint {

    bytes4 constant public ERC721_LAZY_ASSET_CLASS = bytes4(keccak256("ERC721_LAZY"));
    bytes4 constant _INTERFACE_ID_MINT_AND_TRANSFER = 0x8486f69f;

    struct Mint721Data {
        uint tokenId;
        string tokenURI;
        LibPart.Part[] creators;
        LibPart.Part[] royalties;
        bytes[] signatures;
    }

    bytes32 public constant MINT_AND_TRANSFER_TYPEHASH = keccak256("Mint721(uint256 tokenId,string tokenURI,Part[] creators,Part[] royalties)Part(address account,uint96 value)");

    function hash(Mint721Data memory data) internal pure returns (bytes32) {

        bytes32[] memory royaltiesBytes = new bytes32[](data.royalties.length);
        for (uint i = 0; i < data.royalties.length; i++) {
            royaltiesBytes[i] = LibPart.hash(data.royalties[i]);
        }
        bytes32[] memory creatorsBytes = new bytes32[](data.creators.length);
        for (uint i = 0; i < data.creators.length; i++) {
            creatorsBytes[i] = LibPart.hash(data.creators[i]);
        }
        return keccak256(abi.encode(
                MINT_AND_TRANSFER_TYPEHASH,
                data.tokenId,
                keccak256(bytes(data.tokenURI)),
                keccak256(abi.encodePacked(creatorsBytes)),
                keccak256(abi.encodePacked(royaltiesBytes))
            ));
    }

}

pragma solidity >=0.6.2 <0.8.0;


interface IERC721LazyMint is IERC721Upgradeable {


    event Creators(
        uint256 tokenId,
        LibPart.Part[] creators
    );

    function mintAndTransfer(
        LibERC721LazyMint.Mint721Data memory data,
        address to
    ) external;


    function transferFromOrMint(
        LibERC721LazyMint.Mint721Data memory data,
        address from,
        address to
    ) external;

}

pragma solidity 0.7.6;

abstract contract ERC1271 {
    bytes4 constant public ERC1271_INTERFACE_ID = 0xfb855dc9; // this.isValidSignature.selector

    bytes4 constant public ERC1271_RETURN_VALID_SIGNATURE =   0x1626ba7e;
    bytes4 constant public ERC1271_RETURN_INVALID_SIGNATURE = 0x00000000;

    function isValidSignature(bytes32 _hash, bytes memory _signature) public virtual view returns (bytes4);

    function returnIsValidSignatureMagicNumber(bool isValid) internal pure returns (bytes4) {
        return isValid ? ERC1271_RETURN_VALID_SIGNATURE : ERC1271_RETURN_INVALID_SIGNATURE;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract EIP712Upgradeable is Initializable {
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }

    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
}

pragma solidity ^0.7.0;

library LibSignature {

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );

        address signer;
        if (v > 30) {
            require(
                v - 4 == 27 || v - 4 == 28,
                "ECDSA: invalid signature 'v' value"
            );
            signer = ecrecover(toEthSignedMessageHash(hash), v - 4, r, s);
        } else {
            require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");
            signer = ecrecover(hash, v, r, s);
        }

        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }
}

pragma solidity 0.7.6;


abstract contract ERC1271Validator is EIP712Upgradeable {
    using AddressUpgradeable for address;
    using LibSignature for bytes32;

    string constant SIGNATURE_ERROR = "signature verification error";
    bytes4 constant internal MAGICVALUE = 0x1626ba7e;

    function validate1271(address signer, bytes32 structHash, bytes memory signature) internal view {
        bytes32 hash = _hashTypedDataV4(structHash);

        address signerFromSig;
        if (signature.length == 65) {
            signerFromSig = hash.recover(signature);
        }
        if  (signerFromSig != signer) {
            if (signer.isContract()) {
                require(
                    ERC1271(signer).isValidSignature(hash, signature) == MAGICVALUE,
                    SIGNATURE_ERROR
                );
            } else {
                revert(SIGNATURE_ERROR);
            }
        }
    }
    uint256[50] private __gap;
}

pragma solidity 0.7.6;


contract Mint721Validator is ERC1271Validator {

    function __Mint721Validator_init_unchained() internal initializer {

        __EIP712_init_unchained("Mint721", "1");
    }

    function validate(address account, bytes32 hash, bytes memory signature) internal view {

        validate1271(account, hash, signature);
    }
    uint256[50] private __gap;
}

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.7.6;

library LibURI {

    function checkPrefix(string memory base, string memory _tokenURI)
        internal
        pure
        returns (string memory)
    {

        bytes memory whatBytes = bytes(base);
        bytes memory whereBytes = bytes(_tokenURI);

        if (whatBytes.length > whereBytes.length) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        for (uint256 j = 0; j < whatBytes.length; j++) {
            if (whereBytes[j] != whatBytes[j]) {
                return string(abi.encodePacked(base, _tokenURI));
            }
        }

        return _tokenURI;
    }
}

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC721URI is ContextUpgradeable, ERC721UpgradeableMinimal {
    using StringsUpgradeable for uint256;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    function _clearMetadata(uint256 tokenId) internal override virtual {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return LibURI.checkPrefix(base, _tokenURI);
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    uint256[50] private __gap;
}// MIT

pragma solidity 0.7.6;


abstract contract ERC721LazyMinimal is IERC721LazyMint, ERC721UpgradeableMinimal, Mint721Validator, RoyaltiesV2Upgradeable, RoyaltiesV2Impl, ERC721URI {
    using SafeMathUpgradeable for uint;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    mapping(uint256 => LibPart.Part[]) private creators;

    function __ERC721Lazy_init_unchained() internal initializer {

    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC165Upgradeable) returns (bool) {
        return interfaceId == LibERC721LazyMint._INTERFACE_ID_MINT_AND_TRANSFER
        || interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES
        || interfaceId == _INTERFACE_ID_ERC165
        || interfaceId == _INTERFACE_ID_ERC721
        || interfaceId == _INTERFACE_ID_ERC721_METADATA
        || interfaceId == _INTERFACE_ID_ERC721_ENUMERABLE;
    }

    function transferFromOrMint(
        LibERC721LazyMint.Mint721Data memory data,
        address from,
        address to
    ) override external {
        if (_exists(data.tokenId)) {
            safeTransferFrom(from, to, data.tokenId);
        } else {
            mintAndTransfer(data, to);
        }
    }

    function mintAndTransfer(LibERC721LazyMint.Mint721Data memory data, address to) public override virtual {
        address minter = address(data.tokenId >> 96);
        address sender = _msgSender();

        require(minter == data.creators[0].account, "tokenId incorrect");
        require(data.creators.length == data.signatures.length);
        require(minter == sender || isApprovedForAll(minter, sender), "ERC721: transfer caller is not owner nor approved");

        bytes32 hash = LibERC721LazyMint.hash(data);
        for (uint i = 0; i < data.creators.length; i++) {
            address creator = data.creators[i].account;
            if (creator != sender) {
                validate(creator, hash, data.signatures[i]);
            }
        }

        _safeMint(to, data.tokenId);
        _saveRoyalties(data.tokenId, data.royalties);
        _saveCreators(data.tokenId, data.creators);
        _setTokenURI(data.tokenId, data.tokenURI);
    }

    function _emitMintEvent(address to, uint tokenId) internal override virtual {
        address minter = address(tokenId >> 96);
        if (minter != to) {
            emit Transfer(address(0), minter, tokenId);
            emit Transfer(minter, to, tokenId);
        } else {
            emit Transfer(address(0), to, tokenId);
        }
    }

    function _saveCreators(uint tokenId, LibPart.Part[] memory _creators) internal {
        LibPart.Part[] storage creatorsOfToken = creators[tokenId];
        uint total = 0;
        for (uint i = 0; i < _creators.length; i++) {
            require(_creators[i].account != address(0x0), "Account should be present");
            require(_creators[i].value != 0, "Creator share should be positive");
            creatorsOfToken.push(_creators[i]);
            total = total.add(_creators[i].value);
        }
        require(total == 10000, "total amount of creators share should be 10000");
        emit Creators(tokenId, _creators);
    }

    function updateAccount(uint256 _id, address _from, address _to) external {
        require(_msgSender() == _from, "not allowed");
        super._updateAccount(_id, _from, _to);
    }

    function getCreators(uint256 _id) external view returns (LibPart.Part[] memory) {
        return creators[_id];
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721UpgradeableMinimal, ERC721URI) returns (string memory) {
        return ERC721URI.tokenURI(tokenId);
    }

    function _clearMetadata(uint256 tokenId) internal override(ERC721UpgradeableMinimal, ERC721URI) virtual {
        return ERC721URI._clearMetadata(tokenId);
    }

    uint256[50] private __gap;
}

pragma solidity 0.7.6;


abstract contract HasContractURI is ERC165Upgradeable {

    string public contractURI;

    bytes4 private constant _INTERFACE_ID_CONTRACT_URI = 0xe8a3d485;

    function __HasContractURI_init_unchained(string memory _contractURI) internal initializer {
        contractURI = _contractURI;
        _registerInterface(_INTERFACE_ID_CONTRACT_URI);
    }

    function _setContractURI(string memory _contractURI) internal {
        contractURI = _contractURI;
    }

    uint256[49] private __gap;
}

pragma solidity 0.7.6;


abstract contract ERC721BaseMinimal is OwnableUpgradeable, ERC721DefaultApprovalMinimal, ERC721BurnableUpgradeableMinimal, ERC721LazyMinimal, HasContractURI {

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal virtual override(ERC721UpgradeableMinimal, ERC721DefaultApprovalMinimal) view returns (bool) {
        return ERC721DefaultApprovalMinimal._isApprovedOrOwner(spender, tokenId);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override(ERC721DefaultApprovalMinimal, ERC721UpgradeableMinimal, IERC721Upgradeable) returns (bool) {
        return ERC721DefaultApprovalMinimal.isApprovedForAll(owner, operator);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, ERC721LazyMinimal) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721UpgradeableMinimal, ERC721LazyMinimal) returns (string memory) {
        return ERC721LazyMinimal.tokenURI(tokenId);
    }

    function _clearMetadata(uint256 tokenId) internal override(ERC721UpgradeableMinimal, ERC721LazyMinimal) virtual {
        return ERC721LazyMinimal._clearMetadata(tokenId);
    }

    function _emitMintEvent(address to, uint tokenId) internal override(ERC721UpgradeableMinimal, ERC721LazyMinimal) virtual {
        return ERC721LazyMinimal._emitMintEvent(to, tokenId);
    }

    uint256[50] private __gap;
}

pragma solidity 0.7.6;


contract ERC721WoonklyNFTMinimalRevealWave is ERC721BaseMinimal {

    using SafeMathUpgradeable for uint256;

 
    mapping(uint256 => uint256) public tokens; //tokenId to WaveId
    mapping(uint256 => RevealWave) public waves; //waveId -> RevealWave details

    struct RevealWave {
        bool isRevealed;
        string name;
        string hiddenBaseURI;
        bool addTokenURIToHiddenBaseURI;
        string revealBaseURI;
        uint revealDate;
    }
    bool isPrivate;

    event CreateERC721WoonklyNFT(address owner, string name, string symbol);
    event CreateERC721WoonklyNFTUser(address owner, string name, string symbol);

    function __ERC721WoonklyNFTUser_init(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI, address[] memory operators, address transferProxy, address lazyTransferProxy) external initializer {

        __ERC721WoonklyNFT_init_unchained(_name, _symbol, baseURI, contractURI, transferProxy, lazyTransferProxy);

        for(uint i = 0; i < operators.length; i++) {
            setApprovalForAll(operators[i], true);
        }

        isPrivate = true;
        emit CreateERC721WoonklyNFTUser(_msgSender(), _name, _symbol);
    }

    function __ERC721WoonklyNFT_init(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI, address transferProxy, address lazyTransferProxy) external initializer {

        __ERC721WoonklyNFT_init_unchained(_name, _symbol, baseURI, contractURI, transferProxy, lazyTransferProxy);

        isPrivate = false;
        emit CreateERC721WoonklyNFT(_msgSender(), _name, _symbol);
    }

     function __ERC721WoonklyNFT_init_unchained(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI, address transferProxy, address lazyTransferProxy) internal {

        _setBaseURI("");
        __ERC721Lazy_init_unchained();
        __RoyaltiesV2Upgradeable_init_unchained();
        __Context_init_unchained();
        __ERC165_init_unchained();
        __Ownable_init_unchained();
        __ERC721Burnable_init_unchained();
        __Mint721Validator_init_unchained();
        __HasContractURI_init_unchained(contractURI);
        __ERC721_init_unchained(_name, _symbol);

        _setDefaultApproval(transferProxy, true);
        _setDefaultApproval(lazyTransferProxy, true);
    }

    function getRevealWaveIdByTokenId(uint _tokenId) public view returns (uint)
    {

        uint revealWaveId=tokens[_tokenId];
        return revealWaveId;
    }

    function setRevealWave(
        uint _waveId,
        string memory _name,
        string memory _hiddenBaseURI,
        bool _addTokenURIToHiddenBaseURI,
        uint _revealDate 
    ) public onlyOwner {

        require(bytes(_name).length > 0 && bytes(_hiddenBaseURI).length > 0,"Error: Input parameters can not be empty (string) or equal to 0 (uint)");
        RevealWave storage revealWave = waves[_waveId];
        revealWave.name = _name;
        revealWave.hiddenBaseURI = _hiddenBaseURI;
        revealWave.addTokenURIToHiddenBaseURI = _addTokenURIToHiddenBaseURI;
        revealWave.revealDate = _revealDate;     
    }

    function changeHiddenBaseURI(
        uint _waveId,
        string memory _baseURI
    ) public onlyOwner {

        require(bytes(_baseURI).length > 0,"Error: Input parameters can not be empty (string)");
        RevealWave storage revealWave = waves[_waveId];
        revealWave.revealBaseURI = _baseURI;   
    }

    function changeAddTokenURIToHiddenBaseURI(
        uint _waveId,
        bool _addTokenURIToHiddenBaseURI
    ) public onlyOwner {

         RevealWave storage revealWave = waves[_waveId];
        revealWave.addTokenURIToHiddenBaseURI = _addTokenURIToHiddenBaseURI;   
    }

    function changeRevealBaseURI(
        uint _waveId,
        string memory _revealBaseURI
    ) public onlyOwner {

        require(bytes(_revealBaseURI).length > 0,"Error: Input parameters can not be empty (string)");
        RevealWave storage revealWave = waves[_waveId];
        revealWave.isRevealed = true;   
        revealWave.revealBaseURI = _revealBaseURI;
   
    }

    function changeRevealDate(
        uint _waveId,
        uint _revealDate
    ) public onlyOwner {

        RevealWave storage revealWave = waves[_waveId];
        revealWave.revealDate = _revealDate;   
    }

    function resetIsRevealedAndRevealURI(
        uint _waveId
    ) public onlyOwner {

         RevealWave storage revealWave = waves[_waveId];
        revealWave.revealBaseURI = "";
        revealWave.isRevealed = false;   
    }


     function changeName(
        uint _waveId,
        string memory _name
    ) public onlyOwner {

        require(bytes(_name).length > 0,"Error: Input parameters can not be empty (string)");
        RevealWave storage revealWave = waves[_waveId];
        revealWave.name = _name;   
    }

 
    function assignRevealWaveIdToTokenId(uint _tokenId, uint _waveId) public onlyOwner
    {

        tokens[_tokenId] = _waveId;
    }



    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {

        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
    
        uint waveId = getRevealWaveIdByTokenId(_tokenId);
        RevealWave memory revealWave = waves[waveId];

        string memory _tokenURI;
        string memory _baseURI;

        if(revealWave.isRevealed == true || revealWave.addTokenURIToHiddenBaseURI == true)
        {
            _tokenURI = super.tokenURI(_tokenId);
        }

        _baseURI = revealWave.isRevealed == false ? revealWave.hiddenBaseURI : revealWave.revealBaseURI;
 
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }

        return string(abi.encodePacked(_baseURI,_tokenURI));
         

    }


    function mintAndTransfer(
        LibERC721LazyMint.Mint721Data memory data,
        address to
    ) public virtual override {

        if (isPrivate) {
            require(
                owner() == data.creators[0].account,
                "minter is not the owner"
            );
        }

        super.mintAndTransfer(data, to);
    }



    function mintAndTransferReveal(
        LibERC721LazyMint.Mint721Data memory data,
        address to,
        uint _waveId
    ) public onlyOwner{


        assignRevealWaveIdToTokenId(data.tokenId,_waveId);
        
        mintAndTransfer(data, to);

    }

    uint256[49] private __gap; 
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}

pragma solidity >=0.6.2 <0.8.0;

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
}

pragma solidity >=0.6.0 <0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}

pragma solidity >=0.6.0 <0.8.0;


contract BeaconProxy is Proxy {

    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor(address beacon, bytes memory data) public payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon, data);
    }

    function _beacon() internal view virtual returns (address beacon) {

        bytes32 slot = _BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
    }

    function _implementation() internal view virtual override returns (address) {

        return IBeacon(_beacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).implementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
        }
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}

pragma solidity >=0.6.2 <0.8.0;



contract ERC721WoonklyNFTRevealWaveFactoryC2 is Ownable {

    address public beacon;
    address transferProxy;
    address lazyTransferProxy;

    event Create721WoonklyNFTProxy(address proxy);
    event Create721WoonklyNFTUserProxy(address proxy);

    constructor(address _beacon, address _transferProxy, address _lazyTransferProxy) {
        beacon = _beacon;
        transferProxy = _transferProxy;
        lazyTransferProxy = _lazyTransferProxy;
    }

    function createToken(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI, uint salt) external {

        address beaconProxy = deployProxy(getData(_name, _symbol, baseURI, contractURI), salt);
        
        ERC721WoonklyNFTMinimalRevealWave token = ERC721WoonklyNFTMinimalRevealWave(address(beaconProxy));
        token.transferOwnership(_msgSender());
        emit Create721WoonklyNFTProxy(beaconProxy);
    }

    function createToken(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI, address[] memory operators, uint salt) external {

        address beaconProxy = deployProxy(getData(_name, _symbol, baseURI, contractURI, operators), salt);
        
        ERC721WoonklyNFTMinimalRevealWave token = ERC721WoonklyNFTMinimalRevealWave(address(beaconProxy));
        token.transferOwnership(_msgSender());
        emit Create721WoonklyNFTUserProxy(beaconProxy);
    }

    function deployProxy(bytes memory data, uint salt) internal returns(address proxy){

        bytes memory bytecode = getCreationBytecode(data);
        assembly {
            proxy := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(proxy)) {
                revert(0, 0)
            }
        }
    }

    function getCreationBytecode(bytes memory _data) internal view returns (bytes memory) {

        return abi.encodePacked(type(BeaconProxy).creationCode, abi.encode(beacon, _data));
    }

    function getAddress(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI, uint _salt)
        public
        view
        returns (address)
    {   

        bytes memory bytecode = getCreationBytecode(getData(_name, _symbol, baseURI, contractURI));

        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );

        return address(uint160(uint(hash)));
    }

    function getData(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI) view internal returns(bytes memory){

        return abi.encodeWithSelector(ERC721WoonklyNFTMinimalRevealWave(0).__ERC721WoonklyNFT_init.selector, _name, _symbol, baseURI, contractURI, transferProxy, lazyTransferProxy);
    }

    function getAddress(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI, address[] memory operators, uint _salt)
        public
        view
        returns (address)
    {   

        bytes memory bytecode = getCreationBytecode(getData(_name, _symbol, baseURI, contractURI, operators));

        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );

        return address(uint160(uint(hash)));
    }

    function getData(string memory _name, string memory _symbol, string memory baseURI, string memory contractURI, address[] memory operators) view internal returns(bytes memory){

        return abi.encodeWithSelector(ERC721WoonklyNFTMinimalRevealWave(0).__ERC721WoonklyNFTUser_init.selector, _name, _symbol, baseURI, contractURI, operators, transferProxy, lazyTransferProxy);
    }
}
