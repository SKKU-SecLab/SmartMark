pragma solidity ^0.8.8;

interface IOKPC {

  enum Phase {
    INIT,
    EARLY_BIRDS,
    FRIENDS,
    PUBLIC
  }
  struct Art {
    address artist;
    bytes16 title;
    uint256 data1;
    uint256 data2;
  }
  struct Commission {
    address artist;
    uint256 amount;
  }
  struct ClockSpeedXP {
    uint256 savedSpeed;
    uint256 lastSaveBlock;
    uint256 transferCount;
    uint256 artLastChanged;
  }

  function getPaintArt(uint256) external view returns (Art memory);


  function getGalleryArt(uint256) external view returns (Art memory);


  function activeArtForOKPC(uint256) external view returns (uint256);


  function useOffchainMetadata(uint256) external view returns (bool);


  function clockSpeed(uint256) external view returns (uint256);


  function artCountForOKPC(uint256) external view returns (uint256);

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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

pragma solidity ^0.8.4;


error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintedQueryForZeroAddress();
error BurnedQueryForZeroAddress();
error AuxQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerIndexOutOfBounds();
error OwnerQueryForNonexistentToken();
error TokenIndexOutOfBounds();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error URIQueryForNonexistentToken();

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
    }

    struct AddressData {
        uint64 balance;
        uint64 numberMinted;
        uint64 numberBurned;
        uint64 aux;
    }

    uint256 internal _currentIndex;

    uint256 internal _burnCounter;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) internal _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    function _startTokenId() internal view virtual returns (uint256) {

        return 0;
    }

    function totalSupply() public view returns (uint256) {

        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    function _totalMinted() internal view returns (uint256) {

        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        if (owner == address(0)) revert MintedQueryForZeroAddress();
        return uint256(_addressData[owner].numberMinted);
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        if (owner == address(0)) revert BurnedQueryForZeroAddress();
        return uint256(_addressData[owner].numberBurned);
    }

    function _getAux(address owner) internal view returns (uint64) {

        if (owner == address(0)) revert AuxQueryForZeroAddress();
        return _addressData[owner].aux;
    }

    function _setAux(address owner, uint64 aux) internal {

        if (owner == address(0)) revert AuxQueryForZeroAddress();
        _addressData[owner].aux = aux;
    }

    function ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr && curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return ownershipOf(tokenId).addr;
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

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {

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
        if (to.isContract() && !_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _startTokenId() <= tokenId && tokenId < _currentIndex &&
            !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        _mint(to, quantity, _data, true);
    }

    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {

        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (safe && to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex != end);
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex != end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
            isApprovedForAll(prevOwnership.addr, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            _ownerships[tokenId].addr = to;
            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);

            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                if (nextTokenId < _currentIndex) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _burn(uint256 tokenId) internal virtual {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        _beforeTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        unchecked {
            _addressData[prevOwnership.addr].balance -= 1;
            _addressData[prevOwnership.addr].numberBurned += 1;

            _ownerships[tokenId].addr = prevOwnership.addr;
            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);
            _ownerships[tokenId].burned = true;

            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                if (nextTokenId < _currentIndex) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(prevOwnership.addr, address(0), tokenId);
        _afterTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

        unchecked {
            _burnCounter++;
        }
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
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


library Bytecode {
  error InvalidCodeAtRange(uint256 _size, uint256 _start, uint256 _end);

  function creationCodeFor(bytes memory _code) internal pure returns (bytes memory) {

    return abi.encodePacked(
      hex"63",
      uint32(_code.length),
      hex"80_60_0E_60_00_39_60_00_F3",
      _code
    );
  }

  function codeSize(address _addr) internal view returns (uint256 size) {
    assembly { size := extcodesize(_addr) }
  }

  function codeAt(address _addr, uint256 _start, uint256 _end) internal view returns (bytes memory oCode) {
    uint256 csize = codeSize(_addr);
    if (csize == 0) return bytes("");

    if (_start > csize) return bytes("");
    if (_end < _start) revert InvalidCodeAtRange(csize, _start, _end); 

    unchecked {
      uint256 reqSize = _end - _start;
      uint256 maxSize = csize - _start;

      uint256 size = maxSize < reqSize ? maxSize : reqSize;

      assembly {
        oCode := mload(0x40)
        mstore(0x40, add(oCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
        mstore(oCode, size)
        extcodecopy(_addr, add(oCode, 0x20), _start, size)
      }
    }
  }
}// MIT
pragma solidity ^0.8.0;


library SSTORE2 {
  error WriteError();

  function write(bytes memory _data) internal returns (address pointer) {
    bytes memory code = Bytecode.creationCodeFor(
      abi.encodePacked(
        hex'00',
        _data
      )
    );

    assembly { pointer := create(0, add(code, 32), mload(code)) }

    if (pointer == address(0)) revert WriteError();
  }

  function read(address _pointer) internal view returns (bytes memory) {
    return Bytecode.codeAt(_pointer, 1, type(uint256).max);
  }

  function read(address _pointer, uint256 _start) internal view returns (bytes memory) {
    return Bytecode.codeAt(_pointer, _start + 1, type(uint256).max);
  }

  function read(address _pointer, uint256 _start, uint256 _end) internal view returns (bytes memory) {
    return Bytecode.codeAt(_pointer, _start + 1, _end + 1);
  }
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}//Unlicense
pragma solidity ^0.8.7;

interface IOKPCParts {
  error IndexOutOfBounds(uint256 index, uint256 maxIndex);

  struct Color {
    bytes6 light;
    bytes6 regular;
    bytes6 dark;
    string name;
  }

  struct Vector {
    string data;
    string name;
  }

  function getColor(uint256 index) external view returns (Color memory);

  function getHeadband(uint256 index) external view returns (Vector memory);

  function getSpeaker(uint256 index) external view returns (Vector memory);

  function getWord(uint256 index) external view returns (string memory);
}//Unlicense
pragma solidity ^0.8.8;


interface IOKPCMetadata {
  error InvalidTokenID();
  error NotEnoughPixelData();

  struct Parts {
    IOKPCParts.Vector headband;
    IOKPCParts.Vector rightSpeaker;
    IOKPCParts.Vector leftSpeaker;
    IOKPCParts.Color color;
    string word;
  }

  function tokenURI(uint256 tokenId) external view returns (string memory);

  function renderArt(bytes memory art, uint256 colorIndex)
    external
    view
    returns (string memory);

  function getParts(uint256 tokenId) external view returns (Parts memory);

  function drawArt(bytes memory artData) external pure returns (string memory);
}/*
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░██████████░░░░░██████████░░░███████████████░░██████████░░░░░██████████░░░░░
  ░░░░░███░░░░░██░░░░░███░░░░░██░░░░░███░░░░░██░░░░░███░░░░░██░░░░░███░░░░░██░░░░░
  ░░░░░█████░░░██████████░░░░░██████████░░░░░██████████░░░░░██████████░░█████░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ████████████████████████████████████████████████████████████████████████████████
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░█████░░                                                            ░░░░░███░░
  ░░░░░░░░░░          ██████████                    ██████████          ░░░█████░░
  ░░░░░███░░        ██          ███               ██          ███       ░░░██░░░░░
  ░░░░░░░░░░     ███               ██          ███               ██     ░░░░░░░░░░
  ░░░█████░░     ███     █████     ██          ███     █████     ██     ░░░░░███░░
  ░░░░░░░░░░     ███       ███     ██   █████  ███       ███     ██     ░░░█████░░
  ░░░░░███░░     ███     █████     ██          ███     █████     ██     ░░░██░░░░░
  ░░░░░░░░░░     ███     █████     ██   █████  ███     █████     ██     ░░░░░░░░░░
  ░░░█████░░        ██          ███               ██          ███       ░░░██░░░░░
  ░░░░░░░░░░          ██████████        █████       ██████████          ░░░█████░░
  ░░░░░███░░                                                            ░░░░░███░░
  ░░░░░░░░░░     █████                                        █████     ░░░░░░░░░░
  ░░░█████░░     █████   █████  █████   █████  █████   █████  █████     ░░░██░░░░░
  ░░░░░░░░░░             █████  █████   █████     ██   █████            ░░░█████░░
  ░░░░░███░░                                                            ░░░░░███░░
  ░░░░░░░░░░                                                            ░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ████████████████████████████████████████████████████████████████████████████████
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░████████░░███░░███░░████████░░████████░░░░░██░░░██░░░██░░░██░░░██░░░██░░░░░
  ░░░░░███░░███░░█████░░░░░████████░░███░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░░░░░████████░░███░░███░░███░░░░░░░████████░░░░░██░░░██░░░██░░░██░░░██░░░██░░░░░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░


                       scotato.eth, shahruz.eth, cjpais.eth

*/

pragma solidity ^0.8.8;


contract OKPC is IOKPC, ERC721A, IERC2981, Ownable, ReentrancyGuard {

  uint256 public immutable MAX_SUPPLY;
  uint16 private immutable ARTISTS_RESERVED;
  uint16 private immutable TEAM_RESERVED;
  uint16 private immutable MAX_PER_PHASE;
  uint256 public immutable MINT_COST;
  uint8 private constant MAX_ART_PER_ARTIST = 8;
  uint8 private constant MIN_GALLERY_ART = 128;
  uint16 public constant MAX_COLLECT_PER_ART = 512;
  uint256 public constant ART_COLLECT_COST = 0.02 ether;
  uint256 private constant ROYALTY = 640;
  uint256 public clockSpeedMaxMultiplier = 24;


  Phase public mintingPhase;
  mapping(address => bool) public earlyBirdsMintClaimed;
  mapping(address => bool) public friendsMintClaimed;
  bytes32 private _artistsMerkleRoot;
  bytes32 private _earlyBirdsMerkleRoot;
  bytes32 private _friendsMerkleRoot;
  bool public galleryOpen;
  uint256 public galleryArtCounter;
  uint256 private maxGalleryArt = 512;
  mapping(uint256 => uint256) public galleryArtCollectedCount;
  mapping(uint256 => address) private _galleryArtData;
  mapping(address => uint256) public galleryArtistArtCount;
  mapping(uint256 => uint256) public activeArtForOKPC;
  mapping(uint256 => mapping(uint256 => bool)) public artCollectedByOKPC;
  mapping(uint256 => uint256) public artCountForOKPC;
  mapping(bytes32 => bool) private _galleryArtHashes;
  bool public paintOpen;
  mapping(uint256 => Art) public paintArtForOKPC;
  mapping(uint256 => Commission) public openCommissionForOKPC;
  mapping(address => bool) public denyList;
  address public metadataAddress;
  mapping(uint256 => bool) public useOffchainMetadata;
  uint256 public paymentBalanceOwner;
  mapping(address => uint256) public paymentBalanceArtist;
  mapping(uint256 => ClockSpeedXP) public clockSpeedData;
  address public messagingAddress;
  address public communityAddress;
  address public marketplaceAddress;


  event hello();
  event MintingPhaseStarted(Phase phase);
  event ArtChanged(uint256 pcId, uint256 artId);
  event GalleryOpenUpdated(bool open);
  event GalleryArtCreated(uint256 indexed artId, address artist);
  event GalleryArtCollected(uint256 pcId, uint256 artId);
  event GalleryArtSwapped(uint256 pcId1, uint256 pcId2);
  event GalleryArtTransferred(
    uint256 fromOKPCId,
    uint256 toOKPCId,
    uint256 artId
  );
  event GalleryMaxArtUpdated(uint256 maxGalleryArt);
  event PaintOpenUpdated(bool open);
  event PaintArtCreated(uint256 indexed pcId, address artist);
  event CommissionCreated(uint256 pcId, address artist, uint256 amount);
  event CommissionCompleted(uint256 pcId, address artist, uint256 amount);
  event CommissionCancelled(uint256 pcId);
  event MetadataAddressUpdated(address addr);
  event PaymentWithdrawnOwner(uint256 amount);
  event PaymentWithdrawnArtist(address artist, uint256 amount);
  event PaymentReceivedArtist(address artist, uint256 amount);
  event PaymentReceivedOwner(uint256 amount);
  event ClockSpeedMaxMultiplierUpdated(uint256 maxMultiplier);
  event MessagingAddressUpdated(address messagingAddress);
  event CommunityAddressUpdated(address communityAddress);
  event MarketplaceAddressUpdated(address marketplaceAddress);


  error NotOKPCOwner();
  error OKPCNotFound();
  error MerkleProofInvalid();
  error InvalidAddress();
  error MintPhaseNotOpen();
  error MintTooManyOKPCs();
  error MintAlreadyClaimed();
  error MintMaxReached();
  error MintNotAuthorized();
  error GalleryNotOpen();
  error GalleryMinArtNotReached();
  error GalleryMaxArtReached();
  error GalleryArtNotFound();
  error GalleryArtAlreadyCollected();
  error GalleryArtNotCollected();
  error GalleryArtCollectedMaximumTimes();
  error GalleryArtCannotBeActive();
  error GalleryArtDuplicate();
  error GalleryArtLastCollected();
  error PaintArtDataInvalid();
  error PaintArtNotFound();
  error PaintNotOpen();
  error PaintDenyList();
  error PaintCommissionInvalid();
  error PaintNotCommissionedArtist();
  error PaymentAmountInvalid();
  error PaymentBalanceZero();
  error PaymentTransferFailed();
  error NotCommunityAddress();
  error NotMarketplaceAddress();
  error NotOwnerOrCommunity();


  modifier onlyOwnerOf(uint256 pcId) {
    if (msg.sender != ownerOf(pcId)) revert NotOKPCOwner();
    _;
  }
  modifier onlyIfSupplyMintable() {
    if (
      _currentIndex >
      ARTISTS_RESERVED + TEAM_RESERVED + (uint256(mintingPhase) * MAX_PER_PHASE)
    ) revert MintMaxReached();
    _;
  }
  modifier onlyIfMintingPhaseIsSetTo(Phase phase) {
    if (mintingPhase != phase) revert MintPhaseNotOpen();
    _;
  }
  modifier onlyIfMintingPhaseIsSetToOrAfter(Phase minimumPhase) {
    if (mintingPhase < minimumPhase) revert MintPhaseNotOpen();
    _;
  }
  modifier onlyIfValidMerkleProof(bytes32 root, bytes32[] calldata proof) {
    if (
      !MerkleProof.verify(proof, root, keccak256(abi.encodePacked(msg.sender)))
    ) revert MerkleProofInvalid();
    _;
  }
  modifier onlyIfNotAlreadyClaimedEarlyBirds() {
    if (earlyBirdsMintClaimed[msg.sender]) revert MintAlreadyClaimed();
    _;
  }
  modifier onlyIfNotAlreadyClaimedFriends() {
    if (friendsMintClaimed[msg.sender]) revert MintAlreadyClaimed();
    _;
  }
  modifier onlyIfGalleryOpen() {
    if (!galleryOpen) revert GalleryNotOpen();
    _;
  }
  modifier onlyIfGalleryArtExists(uint256 artId) {
    if (artId > galleryArtCounter || artId == 0) revert GalleryArtNotFound();
    _;
  }
  modifier onlyIfOKPCHasCollectedGalleryArt(uint256 pcId, uint256 artId) {
    if (!artCollectedByOKPC[pcId][artId]) revert GalleryArtNotCollected();
    _;
  }
  modifier onlyAfterMinimumGalleryArtUploaded() {
    if (galleryArtCounter < MIN_GALLERY_ART) revert GalleryMinArtNotReached();
    _;
  }
  modifier onlyIfPaintOpen() {
    if (!paintOpen) revert PaintNotOpen();
    _;
  }
  modifier onlyIfPaymentAmountValid(uint256 value) {
    if (msg.value != value) revert PaymentAmountInvalid();
    _;
  }
  modifier onlyOwnerOrCommunity() {
    if (msg.sender != communityAddress && msg.sender != owner())
      revert NotOwnerOrCommunity();
    _;
  }
  modifier onlyCommunity() {
    if (msg.sender != communityAddress) revert NotCommunityAddress();
    _;
  }
  modifier onlyMarketplace() {
    if (msg.sender != marketplaceAddress) revert NotMarketplaceAddress();
    _;
  }


  constructor(
    uint16 artistsReserved,
    uint16 teamReserved,
    uint16 maxPerPhase,
    uint256 mintCost
  ) ERC721A('OKPC', 'OKPC') {
    ARTISTS_RESERVED = artistsReserved;
    TEAM_RESERVED = teamReserved;
    MAX_PER_PHASE = maxPerPhase;
    MAX_SUPPLY = ARTISTS_RESERVED + TEAM_RESERVED + (MAX_PER_PHASE * 3);
    MINT_COST = mintCost;

    emit hello();
  }

  function setArtistsMerkleRoot(bytes32 newRoot) external onlyOwner {
    _artistsMerkleRoot = newRoot;
  }

  function setEarlyBirdsMerkleRoot(bytes32 newRoot) external onlyOwner {
    _earlyBirdsMerkleRoot = newRoot;
  }

  function setFriendsMerkleRoot(bytes32 newRoot) external onlyOwner {
    _friendsMerkleRoot = newRoot;
  }

  function addInitialGalleryArt(bytes calldata data) external onlyOwner {
    if (galleryArtCounter > 0) revert GalleryMaxArtReached();
    if (data.length != uint256(MIN_GALLERY_ART) * 128)
      revert PaintArtDataInvalid();

    for (uint256 i; i < MIN_GALLERY_ART; i++) {
      uint256 artId = i + 1;

      (address artist, uint256 data1, uint256 data2, bytes16 title) = abi
        .decode(
          data[i * MIN_GALLERY_ART:artId * MIN_GALLERY_ART],
          (address, uint256, uint256, bytes16)
        );

      if (title[0] == bytes1(0x0)) revert PaintArtDataInvalid();
      if (_galleryArtHashes[keccak256(abi.encodePacked(data1, data2))])
        revert GalleryArtDuplicate();
      if (galleryArtistArtCount[artist] == MAX_ART_PER_ARTIST)
        revert GalleryMaxArtReached();

      unchecked {
        galleryArtistArtCount[artist]++;
      }
      _galleryArtHashes[keccak256(abi.encodePacked(data1, data2))] = true;

      emit GalleryArtCreated(artId, artist);
    }

    _galleryArtData[0] = SSTORE2.write(data);
    galleryArtCounter = MIN_GALLERY_ART;
  }


  function mintArtists(address[64] calldata addr)
    external
    onlyOwner
    onlyAfterMinimumGalleryArtUploaded
    nonReentrant
  {
    if (_currentIndex > ARTISTS_RESERVED) revert MintMaxReached();
    for (uint16 i; i < 64; i++) {
      _collectIncludedGalleryArt(_currentIndex);
      _safeMint(addr[i], 1);
    }
  }

  function mintTeam(address[4] calldata addr)
    external
    onlyOwner
    onlyAfterMinimumGalleryArtUploaded
    nonReentrant
  {
    if (_currentIndex < ARTISTS_RESERVED) revert MintPhaseNotOpen();
    if (_currentIndex > ARTISTS_RESERVED + TEAM_RESERVED)
      revert MintMaxReached();
    for (uint16 i; i < 64; i++) {
      _collectIncludedGalleryArt(_currentIndex);
      _safeMint(addr[i % 4], 1);
    }
  }

  function startEarlyBirdsMint()
    external
    onlyOwner
    onlyAfterMinimumGalleryArtUploaded
    onlyIfMintingPhaseIsSetTo(Phase.INIT)
  {
    if (_currentIndex <= 512) revert MintPhaseNotOpen();
    mintingPhase = Phase.EARLY_BIRDS;
    emit MintingPhaseStarted(mintingPhase);
  }

  function mintEarlyBirds(bytes32[] calldata merkleProof)
    external
    payable
    onlyIfMintingPhaseIsSetToOrAfter(Phase.EARLY_BIRDS)
    onlyIfValidMerkleProof(_earlyBirdsMerkleRoot, merkleProof)
    onlyIfPaymentAmountValid(MINT_COST)
    onlyIfNotAlreadyClaimedEarlyBirds
    onlyIfSupplyMintable
    nonReentrant
  {
    earlyBirdsMintClaimed[msg.sender] = true;

    _collectIncludedGalleryArt(_currentIndex);

    addToOwnerBalance(MINT_COST - ART_COLLECT_COST);
    addToArtistBalance(
      getGalleryArt(_includedGalleryArtForOKPC(_currentIndex)).artist,
      ART_COLLECT_COST
    );

    _safeMint(msg.sender, 1);
  }

  function startFriendsMint()
    external
    onlyOwner
    onlyIfMintingPhaseIsSetTo(Phase.EARLY_BIRDS)
  {
    mintingPhase = Phase.FRIENDS;
    emit MintingPhaseStarted(mintingPhase);
  }

  function mintFriends(bytes32[] calldata merkleProof)
    external
    payable
    onlyIfMintingPhaseIsSetToOrAfter(Phase.FRIENDS)
    onlyIfValidMerkleProof(_friendsMerkleRoot, merkleProof)
    onlyIfPaymentAmountValid(MINT_COST)
    onlyIfSupplyMintable
    onlyIfNotAlreadyClaimedFriends
    nonReentrant
  {
    friendsMintClaimed[msg.sender] = true;

    _collectIncludedGalleryArt(_currentIndex);

    addToOwnerBalance(MINT_COST - ART_COLLECT_COST);
    addToArtistBalance(
      getGalleryArt(_includedGalleryArtForOKPC(_currentIndex)).artist,
      ART_COLLECT_COST
    );

    _safeMint(msg.sender, 1);
  }

  function startPublicMint()
    external
    onlyOwner
    onlyIfMintingPhaseIsSetTo(Phase.FRIENDS)
  {
    mintingPhase = Phase.PUBLIC;
    emit MintingPhaseStarted(mintingPhase);
  }

  function mint(uint256 amount)
    external
    payable
    onlyIfMintingPhaseIsSetTo(Phase.PUBLIC)
    onlyIfSupplyMintable
    onlyIfPaymentAmountValid(MINT_COST * amount)
    nonReentrant
  {
    if (amount > 8) revert MintTooManyOKPCs();
    if (tx.origin != msg.sender) revert MintNotAuthorized();

    addToOwnerBalance(amount * (MINT_COST - ART_COLLECT_COST));

    for (uint256 i; i < amount; i++) {
      _collectIncludedGalleryArt(_currentIndex + i);
      addToArtistBalance(
        getGalleryArt(_includedGalleryArtForOKPC(_currentIndex + i)).artist,
        ART_COLLECT_COST
      );
    }

    _safeMint(msg.sender, amount);
  }


  function getGalleryArt(uint256 artId)
    public
    view
    onlyIfGalleryArtExists(artId)
    returns (Art memory)
  {
    if (artId <= MIN_GALLERY_ART) {
      uint256 artBucket = (artId - 1) / MIN_GALLERY_ART;
      uint256 artBucketOffset = (artId - 1) % MIN_GALLERY_ART;
      (address addr, uint256 data1, uint256 data2, bytes16 title) = abi.decode(
        SSTORE2.read(
          _galleryArtData[artBucket],
          artBucketOffset * 128,
          (artBucketOffset + 1) * 128
        ),
        (address, uint256, uint256, bytes16)
      );
      return Art(addr, title, data1, data2);
    } else {
      (address addr, uint256 data1, uint256 data2, bytes16 title) = abi.decode(
        SSTORE2.read(_galleryArtData[artId]),
        (address, uint256, uint256, bytes16)
      );
      return Art(addr, title, data1, data2);
    }
  }

  function collectArt(
    uint256 pcId,
    uint256 artId,
    bool makeActive
  )
    external
    payable
    onlyIfGalleryOpen
    onlyOwnerOf(pcId)
    onlyIfGalleryArtExists(artId)
  {
    address artist = getGalleryArt(artId).artist;
    if (msg.sender != artist && msg.value != ART_COLLECT_COST)
      revert PaymentAmountInvalid();
    else if (msg.sender == artist && msg.value > 0)
      revert PaymentAmountInvalid();

    if (msg.value > 0) addToArtistBalance(artist, msg.value);

    _collectGalleryArt(pcId, artId);

    if (makeActive) setGalleryArt(pcId, artId);
  }

  function collectArt(uint256 pcId, uint256[] calldata artIds)
    external
    payable
    onlyIfGalleryOpen
    onlyOwnerOf(pcId)
  {
    if (msg.value != ART_COLLECT_COST * artIds.length)
      revert PaymentAmountInvalid();

    for (uint256 i; i < artIds.length; i++) {
      if (artIds[i] > galleryArtCounter || artIds[i] == 0)
        revert GalleryArtNotFound();

      addToArtistBalance(getGalleryArt(artIds[i]).artist, ART_COLLECT_COST);

      _collectGalleryArt(pcId, artIds[i]);
    }
  }

  function setGalleryArt(uint256 pcId, uint256 artId)
    public
    onlyOwnerOf(pcId)
    onlyIfOKPCHasCollectedGalleryArt(pcId, artId)
  {
    activeArtForOKPC[pcId] = artId;
    clockSpeedData[pcId].artLastChanged = block.timestamp;
    emit ArtChanged(pcId, artId);
  }

  function addGalleryArt(
    bytes16 title,
    uint256 data1,
    uint256 data2,
    bytes32[] calldata merkleProof
  ) external onlyIfValidMerkleProof(_artistsMerkleRoot, merkleProof) {
    if (denyList[msg.sender]) revert PaintDenyList();
    if (galleryArtCounter == maxGalleryArt) revert GalleryMaxArtReached();
    if (title[0] == bytes1(0x0)) revert PaintArtDataInvalid();
    if (_galleryArtHashes[keccak256(abi.encodePacked(data1, data2))])
      revert GalleryArtDuplicate();
    if (galleryArtistArtCount[msg.sender] == MAX_ART_PER_ARTIST)
      revert GalleryMaxArtReached();

    unchecked {
      galleryArtistArtCount[msg.sender]++;
      galleryArtCounter++;
    }
    _galleryArtHashes[keccak256(abi.encodePacked(data1, data2))] = true;

    _galleryArtData[galleryArtCounter] = SSTORE2.write(
      abi.encode(msg.sender, data1, data2, title)
    );

    emit GalleryArtCreated(galleryArtCounter, msg.sender);
  }

  function toggleGalleryOpen() external onlyOwner {
    galleryOpen = !galleryOpen;
    emit GalleryOpenUpdated(galleryOpen);
  }

  function increaseMaxGalleryArt(uint256 newMaxGalleryArt) external onlyOwner {
    if (maxGalleryArt >= newMaxGalleryArt) revert GalleryMaxArtReached();
    maxGalleryArt = newMaxGalleryArt;
    emit GalleryMaxArtUpdated(maxGalleryArt);
  }

  function moderateGalleryArt(
    uint256 artId,
    bytes16 title,
    uint256 data1,
    uint256 data2,
    address artist
  ) external onlyOwnerOrCommunity {
    if (artId <= 128) revert PaintArtDataInvalid();
    if (title[0] == bytes1(0x0)) revert PaintArtDataInvalid();

    Art memory art = getGalleryArt(artId);
    galleryArtistArtCount[art.artist]--;

    unchecked {
      galleryArtistArtCount[artist]++;
    }

    _galleryArtData[artId] = SSTORE2.write(
      abi.encode(artist, data1, data2, title)
    );

    emit GalleryArtCreated(galleryArtCounter, msg.sender);
  }

  function _collectGalleryArt(uint256 pcId, uint256 artId) internal {
    if (artCollectedByOKPC[pcId][artId]) revert GalleryArtAlreadyCollected();
    if (galleryArtCollectedCount[artId] == MAX_COLLECT_PER_ART)
      revert GalleryArtCollectedMaximumTimes();

    artCollectedByOKPC[pcId][artId] = true;

    unchecked {
      artCountForOKPC[pcId]++;
      galleryArtCollectedCount[artId]++;
    }

    emit GalleryArtCollected(pcId, artId);
  }

  function _includedGalleryArtForOKPC(uint256 pcId)
    internal
    view
    returns (uint256)
  {
    return
      pcId <= 128
        ? pcId
        : (uint256(
          keccak256(
            abi.encodePacked(
              'OKPC',
              pcId,
              blockhash(block.number - 1),
              block.coinbase,
              block.difficulty,
              msg.sender
            )
          )
        ) % galleryArtCounter) + 1;
  }

  function _collectIncludedGalleryArt(uint256 pcId) internal {
    uint256 artId = _includedGalleryArtForOKPC(pcId);

    artCountForOKPC[pcId] = 1;
    artCollectedByOKPC[pcId][artId] = true;
    emit GalleryArtCollected(pcId, artId);

    activeArtForOKPC[pcId] = artId;
    clockSpeedData[pcId].artLastChanged = block.timestamp;
    emit ArtChanged(pcId, artId);
  }


  function getPaintArt(uint256 pcId) public view returns (Art memory) {
    if (paintArtForOKPC[pcId].artist == address(0)) revert PaintArtNotFound();
    return paintArtForOKPC[pcId];
  }

  function setPaintArt(uint256 pcId) external onlyOwnerOf(pcId) {
    if (paintArtForOKPC[pcId].artist == address(0)) revert PaintArtNotFound();
    activeArtForOKPC[pcId] = 0;
    clockSpeedData[pcId].artLastChanged = block.timestamp;
    emit ArtChanged(pcId, 0);
  }

  function setPaintArt(
    uint256 pcId,
    bytes16 title,
    uint256 data1,
    uint256 data2
  ) external onlyIfPaintOpen onlyOwnerOf(pcId) {
    _setPaintArt(pcId, title, msg.sender, data1, data2);
  }

  function createCommission(uint256 pcId, address artist)
    external
    payable
    onlyOwnerOf(pcId)
    onlyIfPaintOpen
    nonReentrant
  {
    if (artist == address(0)) revert PaintCommissionInvalid();
    if (msg.sender == artist) revert PaintCommissionInvalid();

    if (openCommissionForOKPC[pcId].artist != address(0))
      cancelCommission(pcId);

    openCommissionForOKPC[pcId] = Commission(artist, msg.value);

    emit CommissionCreated(pcId, artist, msg.value);
  }

  function cancelCommission(uint256 pcId)
    public
    onlyOwnerOf(pcId)
    onlyIfPaintOpen
  {
    _cancelCommission(pcId);
  }

  function _cancelCommission(uint256 pcId) internal nonReentrant {
    if (openCommissionForOKPC[pcId].artist == address(0))
      revert PaintCommissionInvalid();

    uint256 amount = openCommissionForOKPC[pcId].amount;
    delete openCommissionForOKPC[pcId];

    if (amount > 0) {
      (bool success, ) = ownerOf(pcId).call{value: amount}('');
      if (!success) revert PaymentTransferFailed();
    }

    emit CommissionCancelled(pcId);
  }

  function completeCommission(
    uint256 pcId,
    bytes16 title,
    uint256 data1,
    uint256 data2
  ) external onlyIfPaintOpen nonReentrant {
    if (msg.sender != openCommissionForOKPC[pcId].artist)
      revert PaintNotCommissionedArtist();

    _setPaintArt(pcId, title, msg.sender, data1, data2);

    uint256 amount = openCommissionForOKPC[pcId].amount;
    delete openCommissionForOKPC[pcId];
    if (amount > 0) {
      (bool success, ) = msg.sender.call{value: amount}('');
      if (!success) revert PaymentTransferFailed();
    }

    emit CommissionCompleted(pcId, msg.sender, amount);
  }

  function togglePaintOpen() external onlyOwner {
    paintOpen = !paintOpen;
    emit PaintOpenUpdated(paintOpen);
  }

  function setDenyListStatus(address artist, bool deny) external onlyOwner {
    denyList[artist] = deny;
  }

  function moderatePaintArt(uint256 pcId, uint256 artId)
    external
    onlyOwnerOrCommunity
    onlyIfOKPCHasCollectedGalleryArt(pcId, artId)
  {
    if (getPaintArt(pcId).artist == address(0)) revert PaintArtNotFound();

    delete paintArtForOKPC[pcId];

    activeArtForOKPC[pcId] = artId;
    emit ArtChanged(pcId, artId);
  }

  function _setPaintArt(
    uint256 pcId,
    bytes16 title,
    address artist,
    uint256 data1,
    uint256 data2
  ) internal {
    if (denyList[artist]) revert PaintDenyList();
    if (title[0] == bytes1(0x0)) revert PaintArtDataInvalid();
    if (_galleryArtHashes[keccak256(abi.encodePacked(data1, data2))])
      revert GalleryArtDuplicate();

    paintArtForOKPC[pcId].artist = artist;
    paintArtForOKPC[pcId].title = title;
    paintArtForOKPC[pcId].data1 = data1;
    paintArtForOKPC[pcId].data2 = data2;
    emit PaintArtCreated(pcId, artist);

    activeArtForOKPC[pcId] = 0;
    clockSpeedData[pcId].artLastChanged = block.timestamp;
    emit ArtChanged(pcId, 0);
  }


  function switchOKPCRenderer(uint256 pcId) external onlyOwnerOf(pcId) {
    useOffchainMetadata[pcId] = !useOffchainMetadata[pcId];
  }

  function setMetadataAddress(address addr) external onlyOwner {
    if (addr == address(0)) revert InvalidAddress();
    metadataAddress = addr;
    emit MetadataAddressUpdated(addr);
  }


  function withdrawArtistBalance() external nonReentrant {
    uint256 balance = paymentBalanceArtist[msg.sender];
    if (balance == 0) revert PaymentBalanceZero();
    paymentBalanceArtist[msg.sender] = 0;

    (bool success, ) = msg.sender.call{value: balance}('');
    if (!success) revert PaymentBalanceZero();

    emit PaymentWithdrawnArtist(msg.sender, balance);
  }

  function withdrawOwnerBalance(address withdrawTo)
    external
    onlyOwner
    nonReentrant
  {
    if (paymentBalanceOwner == 0) revert PaymentBalanceZero();
    uint256 balance = paymentBalanceOwner;
    paymentBalanceOwner = 0;

    (bool success, ) = withdrawTo.call{value: balance}('');
    if (!success) revert PaymentBalanceZero();

    emit PaymentWithdrawnOwner(balance);
  }

  function addToArtistBalance(address artist, uint256 amount) internal {
    emit PaymentReceivedArtist(artist, amount);
    paymentBalanceArtist[artist] += amount;
  }

  function addToOwnerBalance(uint256 amount) internal {
    emit PaymentReceivedOwner(amount);
    paymentBalanceOwner += amount;
  }


  function royaltyInfo(uint256, uint256 salePrice)
    external
    view
    returns (address receiver, uint256 royaltyAmount)
  {
    return (address(this), (salePrice * ROYALTY) / 10000);
  }

  receive() external payable {
    addToOwnerBalance(msg.value);
  }


  function clockSpeed(uint256 pcId) public view returns (uint256) {
    uint256 lastBlock = clockSpeedData[pcId].lastSaveBlock;
    if (lastBlock == 0) {
      return 1;
    }
    uint256 delta = block.number - lastBlock;
    uint256 multiplier = delta / 200_000;
    if (multiplier > clockSpeedMaxMultiplier) {
      multiplier = clockSpeedMaxMultiplier;
    }
    uint256 total = clockSpeedData[pcId].savedSpeed +
      ((delta * (multiplier + 1)) / 10_000);
    if (total < 1) total = 1;
    return total;
  }

  function setClockSpeedMaxMultiplier(uint256 multiplier) external onlyOwner {
    clockSpeedMaxMultiplier = multiplier;
    emit ClockSpeedMaxMultiplierUpdated(multiplier);
  }

  function _saveClockSpeed(uint256 pcId) internal {
    clockSpeedData[pcId].savedSpeed = clockSpeed(pcId);
    clockSpeedData[pcId].lastSaveBlock = block.number;
    unchecked {
      clockSpeedData[pcId].transferCount++;
    }
  }


  function setMessagingAddress(address addr) external onlyOwner {
    if (addr == address(0)) revert InvalidAddress();
    messagingAddress = addr;
    emit MessagingAddressUpdated(addr);
  }

  function setCommunityAddress(address addr) external onlyOwner {
    if (addr == address(0)) revert InvalidAddress();
    communityAddress = addr;
    emit CommunityAddressUpdated(addr);
  }

  function setMarketplaceAddress(address addr) external onlyOwner {
    if (addr == address(0)) revert InvalidAddress();
    marketplaceAddress = addr;
    emit MarketplaceAddressUpdated(addr);
  }

  function transferArt(
    uint256 fromOKPCId,
    uint256 toOKPCId,
    uint256 artId
  ) external onlyMarketplace onlyIfGalleryArtExists(artId) {
    if (!artCollectedByOKPC[fromOKPCId][artId]) revert GalleryArtNotCollected();

    if (artCollectedByOKPC[toOKPCId][artId])
      revert GalleryArtAlreadyCollected();

    if (artCountForOKPC[fromOKPCId] == 1) revert GalleryArtLastCollected();

    if (activeArtForOKPC[fromOKPCId] == artId)
      revert GalleryArtCannotBeActive();

    artCollectedByOKPC[fromOKPCId][artId] = false;
    artCountForOKPC[fromOKPCId]--;

    artCollectedByOKPC[toOKPCId][artId] = true;
    unchecked {
      artCountForOKPC[toOKPCId]++;
    }
    emit GalleryArtTransferred(fromOKPCId, toOKPCId, artId);
  }

  function addToArtistBalanceFromMarketplace(address artist)
    external
    payable
    onlyMarketplace
  {
    addToArtistBalance(artist, msg.value);
  }

  function addToOwnerBalanceFromMarketplace() external payable onlyMarketplace {
    addToOwnerBalance(msg.value);
  }


  function tokenURI(uint256 pcId) public view override returns (string memory) {
    if (!_exists(pcId)) revert OKPCNotFound();
    return IOKPCMetadata(metadataAddress).tokenURI(pcId);
  }

  function _startTokenId() internal pure override returns (uint256) {
    return 1;
  }

  function _beforeTokenTransfers(
    address,
    address,
    uint256 startTokenId,
    uint256 quantity
  ) internal override {
    for (uint256 i; i < quantity; i++) {
      uint256 pcId = startTokenId + i;
      _saveClockSpeed(pcId);
      if (openCommissionForOKPC[pcId].artist != address(0))
        _cancelCommission(pcId);
    }
  }

}