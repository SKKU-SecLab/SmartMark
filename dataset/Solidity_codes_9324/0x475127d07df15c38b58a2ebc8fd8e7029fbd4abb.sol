
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

pragma solidity ^0.8.9;

struct Color {
    string rgb;
    string name;
}// MIT

pragma solidity ^0.8.9;


abstract contract IColorProvider {
    function totalAmount() public pure virtual returns (uint96);
    function getColor(uint128 id) public pure virtual returns (Color memory);

    bytes16 private constant HEX_ALPHABET = "0123456789ABCDEF";

    function _getColor(
        bytes memory names,
        bytes memory rgbs,
        uint128 index
    ) internal pure returns (Color memory) {
        return Color({
            rgb: string(getColorRgb(rgbs, index)), 
            name: string(getColorName(names, index))
        });
    }

    function getColorName(bytes memory names, uint128 index) internal pure returns (bytes memory) {
        bytes memory result;
        uint256 startIndex = 0;
        uint256 endIndex = 0;

        for (; startIndex < names.length && index > 0; startIndex++) {
            if (names[startIndex] != "|") continue;

            index--;
        }

        for (endIndex = startIndex + 1; endIndex < names.length && names[endIndex] != "|"; endIndex++) {}

        for (; startIndex < endIndex; startIndex++) {
            result = abi.encodePacked(result, names[startIndex]);
        }

        return result;
    }

    function getColorRgb(bytes memory rgbs, uint128 index) internal pure returns (bytes memory) {
        uint256 startIndex = 3 * uint256(index);

        return abi.encodePacked(
            HEX_ALPHABET[(uint8(rgbs[startIndex + 0]) >> 4) & 0xF],
            HEX_ALPHABET[uint8(rgbs[startIndex + 0]) & 0xF],
            HEX_ALPHABET[(uint8(rgbs[startIndex + 1]) >> 4) & 0xF],
            HEX_ALPHABET[uint8(rgbs[startIndex + 1]) & 0xF],
            HEX_ALPHABET[(uint8(rgbs[startIndex + 2]) >> 4) & 0xF],
            HEX_ALPHABET[uint8(rgbs[startIndex + 2]) & 0xF]);
    }
}// MIT

pragma solidity ^0.8.9;

library Base64 {

    string constant private B64_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory _data) internal pure returns (string memory result) {

        if (_data.length == 0) return '';
        string memory _table = B64_ALPHABET;
        uint256 _encodedLen = 4 * ((_data.length + 2) / 3);
        result = new string(_encodedLen + 32);

        assembly {
            mstore(result, _encodedLen)
            let tablePtr := add(_table, 1)
            let dataPtr := _data
            let endPtr := add(dataPtr, mload(_data))
            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
                resultPtr := add(resultPtr, 1)
            }
            
            switch mod(mload(_data), 3)
            case 1 {mstore(sub(resultPtr, 2), shl(240, 0x3d3d))}
            case 2 {mstore(sub(resultPtr, 1), shl(248, 0x3d))}
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.9;


abstract contract ColorPalette {
    struct ColorDependency {
        IColorProvider provider;
        uint96 accumulateAmount;
    }

    ColorDependency[] public _colorProviders;

    function _setColorProviders(IColorProvider[] memory colorProviders) internal {
        delete _colorProviders;

        uint96 accAmount = 0;
        for (uint i = 0; i < colorProviders.length; i++) {
            IColorProvider p = colorProviders[i];

            accAmount += uint96(p.totalAmount());
            _colorProviders.push(ColorDependency(p, accAmount));
        }
    }

    function getColor(uint16 id) public view returns (Color memory) {
        uint256 providerCount = _colorProviders.length;
        uint96 lastAccAmount = 0;

        for (uint i = 0; i < providerCount; i++) {
            ColorDependency memory dep = _colorProviders[i];

            if (id < dep.accumulateAmount) return dep.provider.getColor(id - lastAccAmount);
            lastAccAmount = dep.accumulateAmount;
        }

        revert("ColorPalette: id of color cannot exceed 16,000");
    }
}// MIT

pragma solidity ^0.8.9;


interface IMetadataRenderer {

    function renderUnreveal(uint16 tokenId) external view returns (string memory);

    function render(uint16 tokenId, Color memory color) external view returns (string memory);

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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

pragma solidity ^0.8.9;


contract ERC721Slim is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    uint256 private _burntTokens = 0;
    address[] private _tokenOwners;
    mapping(uint256 => address) _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721Slim: balance query for the zero address");

        uint256 balance = 0;
        for (uint i = 0; i < _tokenOwners.length; i++) {
            if (_tokenOwners[i] == owner) {
                balance++;
            }
        }

        return balance;
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721Slim: owner query for nonexistent token");
        address owner = _tokenOwners[tokenId];
        require(owner != address(0), "ERC721Slim: owner query for nonexistent token");
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
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721Slim.ownerOf(tokenId);
        require(to != owner, "ERC721Slim: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721Slim: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721Slim: approved query for nonexistent token");

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

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Slim: transfer caller is not owner nor approved");

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

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Slim: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721Slim: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return tokenId < _tokenOwners.length && _tokenOwners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721Slim: operator query for nonexistent token");
        address owner = ERC721Slim.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeBatchMint(address to, uint256 amount) internal returns (uint256 startId) {

        require(to != address(0), "ERC721Slim: mint to the zero address");
        require(amount > 0, "ERC721Slim: mint nothing");
        startId = _tokenOwners.length;

        for (uint256 i = 0; i < amount; i++) {
            _tokenOwners.push(to);

            emit Transfer(address(0), to, _tokenOwners.length - 1);
        }

        require(
            _checkOnERC721Received(address(0), to, startId, ""),
            "ERC721Slim: transfer to non ERC721Receiver implementer"
        );
    }

    function _safeMint(address to) internal virtual {

        _safeMint(to, "");
    }

    function _safeMint(
        address to,
        bytes memory _data
    ) internal virtual {

        uint256 tokenId = _mint(to);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721Slim: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to) internal virtual returns (uint256) {

        require(to != address(0), "ERC721Slim: mint to the zero address");

        uint256 tokenId = _tokenOwners.length;
        _tokenOwners.push(to);

        emit Transfer(address(0), to, tokenId);

        return tokenId;
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Slim.ownerOf(tokenId);

        _tokenOwners[tokenId] = address(0);
        delete _tokenApprovals[tokenId];
        _burntTokens++;

        emit Approval(owner, address(0), tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721Slim.ownerOf(tokenId) == from, "ERC721Slim: transfer from incorrect owner");
        require(to != address(0), "ERC721Slim: transfer to the zero address");

        _tokenOwners[tokenId] = to;
        _tokenApprovals[tokenId] = address(0);

        emit Approval(from, address(0), tokenId);
        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(_tokenOwners[tokenId], to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721Slim: approve to caller");
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
                    revert("ERC721Slim: transfer to non ERC721Receiver implementer");
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


    function totalSupply() public override view returns (uint256) {

        return _tokenOwners.length - _burntTokens;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId) {

        uint256 _totalSupply = _tokenOwners.length;

        for (uint i = 0; i < _totalSupply; i++) {
            if (_tokenOwners[i] != owner) continue;

            if (index == 0) {
                return i;
            }

            index--;
        }

        revert("ERC721Slim: owner index out of bounds");
    }

    function tokenByIndex(uint256 index) external view returns (uint256) {

        require(index < _tokenOwners.length, "ERC721Slim: global index out of bounds");
        
        uint256 burntTokens = 0;
        for (uint256 i = 0; i < _tokenOwners.length; i++) {
            if (_tokenOwners[i] == address(0)) {
                burntTokens++;
            }

            if (i == index + burntTokens) return i;
        }
        
        revert("ERC721Slim: global index out of bounds");
    }


    function totalMinted() public view returns (uint256) {

        return _tokenOwners.length;
    }
}// MIT

pragma solidity ^0.8.9;

library Random {

    uint256 private constant A = 48271;
    uint256 private constant M = type(uint32).max;
    uint256 private constant C = 0;

    function getRandomizedId(
        uint16 id,
        uint16 idMax,
        uint256 randomSeed
    ) internal pure returns (uint16) {

        uint16[] memory newIdSeq = new uint16[](idMax);
        uint256 seed = randomSeed;

        for (uint16 i = 0; i < idMax; i++) newIdSeq[i] = i;

        for (uint16 i = 0; i < idMax; i++) {
            unchecked { seed = (A * seed + C) % M; }

            uint16 iToSwap = uint16(seed % idMax);
            uint16 temp = newIdSeq[i];
            newIdSeq[i] = newIdSeq[iToSwap];
            newIdSeq[iToSwap] = temp;
        }

        return newIdSeq[id];
    }
}// MIT

pragma solidity ^0.8.9;


contract Synesthesia is ERC721Slim, ColorPalette, Ownable {

    uint256 public constant MAX_MINT_PER_TX = 20;
    uint256 public constant UNIT_PRICE = 0.055 ether;

    uint8 private constant SALE_STATE_NOT_STARTED = 0;
    uint8 private constant SALE_STATE_STARTED = 1;
    uint8 private constant SALE_STATE_CLOSED = 2;

    address public constant OPENDAO_TREASURY = 0xd08d0e994EeEf4001C63C72991Cf05918aDF191b;

    struct Config {
        uint8 saleState;
        uint16 maxSupply;
        uint128 randomSeed;
        uint104 minterSeed;
    }

    bytes32 public immutable _saltHash;
    Config public _config;
    IMetadataRenderer _renderer;

    constructor(uint16 maxSupply, bytes32 saltHash, address renderer, IColorProvider[] memory colorProviders)
        ERC721Slim("Synesthesia", "SYNES")
    {
        require(renderer != address(0), "Synesthesia: renderer shouldn't be zero address");
        require(maxSupply > 0, "Synesthesia: max supply should be larger than zero");
        require(saltHash != 0, "Synesthesia: salt hash cannot be zero");

        _setColorProviders(colorProviders);

        _config = Config({
            saleState: SALE_STATE_NOT_STARTED,
            maxSupply: maxSupply,
            randomSeed: 0,
            minterSeed: 0
        });

        _renderer = IMetadataRenderer(renderer);
        _saltHash = saltHash;
    }

    function sqeezePigmentTube(uint256 amount) external payable {

        Config memory config = _config;

        require(tx.origin == msg.sender, "Synesthesia: are you botting?");
        require(config.saleState == SALE_STATE_STARTED, "Synesthesia: sale is not yet started");
        require(amount <= MAX_MINT_PER_TX, "Synesthesia: exceeds maximum amount per transaction");
        require(amount * UNIT_PRICE <= msg.value, "Synesthesia: insufficient fund");
        require(amount + totalMinted() <= config.maxSupply, "Synesthesia: exceeds total supply");

        _safeBatchMint(msg.sender, amount);

        config.minterSeed = uint104(uint256(keccak256(abi.encodePacked(config.minterSeed, msg.sender))));
        _config = config;
    }

    function setRenderer(address renderer) external onlyOwner {

        _renderer = IMetadataRenderer(renderer);
    }

    function setColorProvier(IColorProvider[] memory colorProviders) external onlyOwner {

        _setColorProviders(colorProviders);
    }

    function setSaleState(uint8 targetSaleState) external onlyOwner {

        _config.saleState = targetSaleState;
    }

    function revealColors(string memory salt) external onlyOwner {

        require(keccak256(bytes(salt)) == _saltHash, "Synesthesia: invalid salt");
        require(_config.randomSeed == 0, "Synesthesia: already revealed");

        uint256 lastBlock = block.number - 1;
        _config.randomSeed = uint128(uint256(keccak256(abi.encodePacked(
            salt,
            _config.minterSeed,
            uint256(blockhash(lastBlock)),
            uint256(block.timestamp)))));
    }

    function withdraw() external onlyOwner {

        uint256 balance = address(this).balance;
        uint256 feedbackToOpenDAO = balance * 10 / 100;

        Address.sendValue(payable(OPENDAO_TREASURY), feedbackToOpenDAO);
        Address.sendValue(payable(msg.sender), balance - feedbackToOpenDAO);
    }

    function functionCall(address target, bytes calldata data) external payable onlyOwner {

        Address.functionCallWithValue(target, data, msg.value);
    }


    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "Synesthesia: URI query for nonexistent token");
        Config memory config = _config;

        if (_config.randomSeed == 0) {
            return _renderer.renderUnreveal(uint16(tokenId));
        } else {
            uint16 randomizedId = Random.getRandomizedId(
                uint16(tokenId),
                uint16(config.maxSupply),
                config.randomSeed);
            Color memory color = getColor(randomizedId);

            return _renderer.render(uint16(tokenId), color);
        }
    }
}