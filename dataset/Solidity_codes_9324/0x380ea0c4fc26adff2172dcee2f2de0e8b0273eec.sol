pragma solidity 0.8.11;

struct Freak {
  uint8 species;
  uint8 body;
  uint8 armor;
  uint8 mainHand;
  uint8 offHand;
  uint8 power;
  uint8 health;
  uint8 criticalStrikeMod;

}
struct Celestial {
  uint8 healthMod;
  uint8 powMod;
  uint8 cPP;
  uint8 cLevel;
}

struct Layer {
  string name;
  string data;
}

struct LayerInput {
  string name;
  string data;
  uint8 layerIndex;
  uint8 itemIndex;
}// Unlicense
pragma solidity 0.8.11;


interface MetadataHandlerLike {

  function getCelestialTokenURI(uint256 id, Celestial memory character) external view returns (string memory);


  function getFreakTokenURI(uint256 id, Freak memory character) external view returns (string memory);

}

interface InventoryCelestialsLike {

  function getAttributes(Celestial memory character, uint256 id) external pure returns (bytes memory);


  function getImage(uint256 id) external view returns (bytes memory);

}

interface InventoryFreaksLike {

  function getAttributes(Freak memory character, uint256 id) external view returns (bytes memory);


  function getImage(Freak memory character) external view returns (bytes memory);

}

interface IFnG {

  function transferFrom(
    address from,
    address to,
    uint256 id
  ) external;


  function ownerOf(uint256 id) external returns (address owner);


  function isFreak(uint256 tokenId) external view returns (bool);


  function getSpecies(uint256 tokenId) external view returns (uint8);


  function getFreakAttributes(uint256 tokenId) external view returns (Freak memory);


  function setFreakAttributes(uint256 tokenId, Freak memory attributes) external;


  function getCelestialAttributes(uint256 tokenId) external view returns (Celestial memory);


  function setCelestialAttributes(uint256 tokenId, Celestial memory attributes) external;

}

interface IFBX {

  function mint(address to, uint256 amount) external;


  function burn(address from, uint256 amount) external;

}

interface ICKEY {

  function ownerOf(uint256 tokenId) external returns (address);

}

interface IVAULT {

  function depositsOf(address account) external view returns (uint256[] memory);

  function _depositedBlocks(address account, uint256 tokenId) external returns(uint256);

}

interface ERC20Like {

  function balanceOf(address from) external view returns (uint256 balance);


  function burn(address from, uint256 amount) external;


  function mint(address from, uint256 amount) external;


  function transfer(address to, uint256 amount) external;

}

interface ERC1155Like {

  function mint(
    address to,
    uint256 id,
    uint256 amount
  ) external;


  function burn(
    address from,
    uint256 id,
    uint256 amount
  ) external;

}

interface ERC721Like {

  function transferFrom(
    address from,
    address to,
    uint256 id
  ) external;


  function transfer(address to, uint256 id) external;


  function ownerOf(uint256 id) external returns (address owner);


  function mint(address to, uint256 tokenid) external;

}

interface PortalLike {

  function sendMessage(bytes calldata) external;

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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
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
pragma solidity 0.8.11;

abstract contract Controllable {
  mapping(address => bool) private _isController;
  modifier onlyController() {
    require(_isController[msg.sender], "Controllable: Caller is not a controller");
    _;
  }

  function isController(address addr) public view returns (bool) {
    return _isController[addr];
  }

  function _setController(address addr, bool status) internal {
    _isController[addr] = status;
  }
}// MIT
pragma solidity 0.8.11;


contract FreaksNGuilds is Controllable, Pausable, Ownable, ERC721A("Freaks N Guilds", "FnG") {
  using MerkleProof for bytes32[];


  bytes32 internal entropySauce;
  bytes32 public whitelistRoot;

  uint256 public constant FNG_PRICE_ETH_PUBLIC = 0.099 ether;
  uint256 public constant FNG_PRICE_ETH_WHITELIST = 0.09 ether;
  uint256 public constant FNG_PRICE_ETH_HOLDERS = 0.07 ether;
  uint256 public constant FNG_PRICE_FBX = 1000 ether;

  IFBX public fbx;
  ICKEY public ckey;
  IVAULT public vault;

  uint256 public maxSupply;
  uint256 public maxCelestialSupply;
  uint256 public celestialSupply;
  uint256 public freakSupply;
  uint256 public saleState;
  uint256 public maxWlMints;
  uint256 public maxPubMints;

  uint8 internal cBody = 1;
  uint8 internal cLevel = 1;
  uint8 internal cPP = 1;
  uint8 internal offHand = 0;

  mapping(uint256 => Freak) public freaks;
  mapping(uint256 => Celestial) public celestials;

  mapping(uint256 => bool) public redeemedCKEYs;
  mapping(address => uint256) public whitelistMinted;
  mapping(address => uint256) public publicMinted;

  MetadataHandlerLike public metadaHandler;


  modifier noCheaters() {
    uint256 size = 0;
    address acc = msg.sender;
    assembly {
      size := extcodesize(acc)
    }

    require(msg.sender == tx.origin, "you're trying to cheat!");
    require(size == 0, "you're trying to cheat!");
    _;

    entropySauce = keccak256(abi.encodePacked(acc, block.coinbase));
  }



  constructor(
    uint256 _maxSupply,
    uint256 _maxCelestialSupply,
    address _fbx,
    address _ckey,
    address _metadataHandler,
    address _vault,
    bytes32 _whitelistRoot
  ) {
    maxSupply = _maxSupply;
    maxCelestialSupply = _maxCelestialSupply;
    fbx = IFBX(_fbx);
    ckey = ICKEY(_ckey);
    vault = IVAULT(_vault);
    metadaHandler = MetadataHandlerLike(_metadataHandler);
    whitelistRoot = _whitelistRoot;
    maxWlMints = 2;
    maxPubMints = 4;
    _pause();
  }


  function tokenURI(uint256 id) public view override returns (string memory) {
    require(_exists(id), "token does not exist");
    if (!isFreak(id)) {
      Celestial memory celestial = celestials[id];
      return metadaHandler.getCelestialTokenURI(id, celestial);
    } else if (isFreak(id)) {
      Freak memory freak = freaks[id];
      return metadaHandler.getFreakTokenURI(id, freak);
    } else {
      return ""; // placeholder for compile
    }
  }


  function mintWithETH(uint256 amount) external payable noCheaters whenNotPaused {
    uint256 supply = _currentIndex;
    require(supply + amount <= maxSupply + 1, "maximum supply reached");
    if (msg.sender != owner()) {
      require(amount > 0 && amount + publicMinted[msg.sender] <= maxPubMints, "Invalid quantity");
      require(saleState == 2, "Mint stage not live");
      require(msg.value >= amount * FNG_PRICE_ETH_PUBLIC, "invalid ether amount");
    }
    uint256 rand = _rand();
    for (uint256 i = 0; i < amount; i++) {
      uint256 rNum = rand % 100;
      if (rNum < 15 && celestialSupply < 1500) {
        _revealCelestial(rNum, supply);
        rand = _randomize(rand, supply);
      } else {
        _revealFreak(rNum, supply);
        rand = _randomize(rand, supply);
      }
      supply += 1;
    }
    _mint(msg.sender, amount, "", false);
    publicMinted[msg.sender] += amount;
  }

  function mintWithETHHoldersOnly(uint256[] memory ckeyIds) external payable noCheaters whenNotPaused {
    require(saleState != 2, "Mint stage not live");
    uint256 supply = _currentIndex;
    uint256 amount = ckeyIds.length;
    require(amount > 0, "invalid token ID");
    require(supply + amount <= maxSupply + 1, "maximum supply reached");
    if (msg.sender != owner()) {
      require(msg.value >= amount * FNG_PRICE_ETH_HOLDERS, "invalid ether amount");
    }
    uint256 rand = _rand();
    for (uint256 i = 0; i < amount; i++) {
      require(msg.sender == ckey.ownerOf(ckeyIds[i]) || vault._depositedBlocks(msg.sender, ckeyIds[i]) != 0, "invalid token ID");
      require(!redeemedCKEYs[ckeyIds[i]], "token already used to mint");
      redeemedCKEYs[ckeyIds[i]] = true;
      uint256 rNum = rand % 100;
      if (rNum < 15 && celestialSupply < 1500) {
        _revealCelestial(rNum, supply);
        rand = _randomize(rand, supply);
      } else {
        _revealFreak(rNum, supply);
        rand = _randomize(rand, supply);
      }
      supply += 1;
    }
    _mint(msg.sender, amount, "", false);
  }

  function mintWithETHWhitelist(uint256 amount, bytes32[] memory proof) external payable whenNotPaused {
    require(saleState == 1, "Mint stage not live");
    uint256 supply = _currentIndex;
    require(supply + amount <= maxSupply + 1, "maximum supply reached");
    require(amount > 0 && amount + whitelistMinted[msg.sender] <= maxWlMints, "Invalid quantity for whitelist mint");
    require(msg.value >= amount * FNG_PRICE_ETH_WHITELIST, "invalid ether amount");
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
    require(proof.verify(whitelistRoot, leaf), "Invalid proof");
    uint256 rand = _rand();
    for (uint256 i = 0; i < amount; i++) {
      uint256 rNum = rand % 100;
      if (rNum < 15 && celestialSupply < 1500) {
        _revealCelestial(rNum, supply);
        rand = _randomize(rand, supply);
      } else {
        _revealFreak(rNum, supply);
        rand = _randomize(rand, supply);
      }
      supply += 1;
    }
    _mint(msg.sender, amount, "", false);
    whitelistMinted[msg.sender] += amount;
  }

  function mintWithFBX(uint256 amount) external noCheaters whenNotPaused {
    require(saleState != 2, "Mint stage not live");
    uint256 supply = _currentIndex;
    require(supply + amount <= maxSupply + 1, "maximum supply reached");
    uint256 rand = _rand();
    for (uint256 i = 0; i < amount; i++) {
      uint256 rNum = rand % 100;
      if (rNum < 15 && celestialSupply < 1500) {
        _revealCelestial(rNum, supply);
        rand = _randomize(rand, supply);
      } else {
        _revealFreak(rNum, supply);
        rand = _randomize(rand, supply);
      }
      supply++;
    }
    fbx.burn(msg.sender, FNG_PRICE_FBX * amount);
    _mint(msg.sender, amount, "", false);
  }

  function burn(uint256 tokenId) external onlyOwner {
    if(isFreak(tokenId)){
      delete freaks[tokenId];
      freakSupply -= 1;
    }else{
      delete celestials[tokenId];
      celestialSupply -= 1;
    }
    _burn(tokenId);
  }

  function _revealCelestial(uint256 rNum, uint256 id) internal {
    uint256 _rNum = _randomize(rNum, id);
    uint8 healthMod = _calcMod(_rNum);
    _rNum = _randomize(_rNum, id);
    uint8 powMod = _calcMod(_rNum);
    Celestial memory celestial = Celestial(healthMod, powMod, cPP, cLevel);
    celestials[id] = celestial;
    celestialSupply += 1;
  }

  function _revealFreak(uint256 rNum, uint256 id) internal {
    uint256 _rNum = _randomize(rNum, id);
    uint8 species = uint8((_rNum % 3) + 1);
    _rNum = _randomize(_rNum, id);
    uint8 mainHand = uint8((_rNum % 3) + 1);
    _rNum = _randomize(_rNum, id);
    uint8 body = uint8((_rNum % 3) + 1);
    _rNum = _randomize(_rNum, id);
    uint8 power = _calcPow(species, _rNum);
    _rNum = _randomize(_rNum, id);
    uint8 health = _calcHealth(species, _rNum);
    _rNum = _randomize(_rNum, id);
    uint8 armor = uint8((_rNum % 3) + 1); 
    uint8 criticalStrikeMod = 0;
    Freak memory freak = Freak(species, body, armor, mainHand, offHand, power, health, criticalStrikeMod);
    freaks[id] = freak;
    freakSupply += 1;
  }


  function getFreakAttributes(uint256 tokenId) external view returns (Freak memory) {
    require(_exists(tokenId), "token does not exist");
    return (freaks[tokenId]);
  }

  function getCelestialAttributes(uint256 tokenId) external view returns (Celestial memory) {
    require(_exists(tokenId), "token does not exist");
    return (celestials[tokenId]);
  }

  function isFreak(uint256 tokenId) public view returns (bool) {
    require(_exists(tokenId), "token does not exist");
    return freaks[tokenId].species != 0 ? true : false;
  }

  function getSpecies(uint256 tokenId) external view returns (uint8) {
    require(isFreak(tokenId) == true);
    return freaks[tokenId].species;
  }

  function getTokens(address addr) external view returns (uint256[] memory tokens) {
    uint256 balanceLength = balanceOf(addr);
    tokens = new uint256[](balanceLength);
    uint256 index = 0;
    for (uint256 j =  1; j < _currentIndex; j++) {
      if (ownerOf(j) == addr) {
        tokens[index] = j;
        index += 1;
      }
    }
    return tokens;
  }


  function _startTokenId() internal pure override returns (uint256) {
    return 1;
  }

  function _randomize(uint256 rand, uint256 spicy) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(rand, spicy)));
  }

  function _rand() internal view returns (uint256) {
    return
      uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.basefee, block.timestamp, entropySauce)));
  }

  function _calcMod(uint256 rNum) internal pure returns (uint8) {
    return uint8((rNum % 4) + 5);
  }

  function _calcHealth(uint8 species, uint256 rNum) internal pure returns (uint8) {
    uint8 baseHealth = 90; // ogre
    if (species == 1) {
      baseHealth = 50; // troll
    } else if (species == 2) {
      baseHealth = 70; // fairy
    }
    return uint8((rNum % 21) + baseHealth);
  }

  function _calcPow(uint8 species, uint256 rNum) internal pure returns (uint8) {
    uint8 basePow = 90; //ogre
    if (species == 1) {
      basePow = 115; // troll
    } else if (species == 2) {
      basePow = 65; //fairy
    }
    return uint8((rNum % 21) + basePow);
  }


  function setSaleState(uint256 newSaleState) external onlyOwner {
    saleState = newSaleState;
  }

  function isApprovedForAll(address owner, address operator) public view override returns (bool) {
    return
      isController(operator) ||
      super.isApprovedForAll(owner, operator);
  }

  function setMaxMints(uint256 _maxWlMints, uint256 _maxPubMints) external onlyOwner {
    maxWlMints = _maxWlMints;
    maxPubMints = _maxPubMints;
  }

  function setPause(bool _pauseToggle) external onlyOwner {
    if (_pauseToggle == true) {
      _pause();
    } else {
      _unpause();
    }
  }

  function setWhitelistRoot(bytes32 root) external onlyOwner {
    whitelistRoot = root;
  }

  function setContracts(address _fbx, address _ckey, address _vault, address _metadataHandler) external onlyOwner {
    fbx = IFBX(_fbx);
    ckey = ICKEY(_ckey);
    vault = IVAULT(_vault);
    metadaHandler = MetadataHandlerLike(_metadataHandler);
  }

  function withdraw(uint256 amount) external onlyOwner {
    payable(msg.sender).transfer(amount);
  }

  function withdrawERC20(IERC20 token, uint256 amount) external onlyOwner {
    token.transfer(msg.sender, amount);
  }

  function withdrawERC721(IERC721 token, uint256 tokenId) external onlyOwner {
    token.safeTransferFrom(address(this), msg.sender, tokenId);
  }

  function withdrawERC1155(
    IERC1155 token,
    uint256 tokenId,
    uint256 value
  ) external onlyOwner {
    token.safeTransferFrom(address(this), msg.sender, tokenId, value, "");
  }

  function setControllers(address[] calldata addrs, bool state) external onlyOwner {
    for (uint256 i = 0; i < addrs.length; i++) super._setController(addrs[i], state);
  }
}