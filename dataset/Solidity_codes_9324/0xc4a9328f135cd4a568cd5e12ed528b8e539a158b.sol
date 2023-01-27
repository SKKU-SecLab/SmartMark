
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

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.4;


interface IERC721A is IERC721, IERC721Metadata {

    error ApprovalCallerNotOwnerNorApproved();

    error ApprovalQueryForNonexistentToken();

    error ApproveToCaller();

    error ApprovalToCurrentOwner();

    error BalanceQueryForZeroAddress();

    error MintToZeroAddress();

    error MintZeroQuantity();

    error OwnerQueryForNonexistentToken();

    error TransferCallerNotOwnerNorApproved();

    error TransferFromIncorrectOwner();

    error TransferToNonERC721ReceiverImplementer();

    error TransferToZeroAddress();

    error URIQueryForNonexistentToken();

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

    function totalSupply() external view returns (uint256);

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


contract ERC721AF is Context, ERC165, IERC721A {

    using Address for address;
    using Strings for uint256;

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

    function totalSupply() public view override returns (uint256) {

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

        return uint256(_addressData[owner].numberMinted);
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberBurned);
    }

    function _getAux(address owner) internal view returns (uint64) {

        return _addressData[owner].aux;
    }

    function _setAux(address owner, uint64 aux) internal {

        _addressData[owner].aux = aux;
    }

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr) if (curr < _currentIndex) {
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

        return _ownershipOf(tokenId).addr;
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

        address owner = ERC721AF.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner) if(!isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

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

        _transfer(from, to, tokenId, false);
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

        _transfer(from, to, tokenId, false);
        if (to.isContract()) if(!_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }


    function _safeTransferFromForced(
      address from,
      address to,
      uint256 tokenId,
      bytes memory _data
    ) internal {

      _transfer(from, to, tokenId, true);
      if (to.isContract()) if(!_checkContractOnERC721Received(from, to, tokenId, _data)) {
          revert TransferToNonERC721ReceiverImplementer();
      }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _startTokenId() <= tokenId && tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
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

            if (to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex < end);
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex < end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _mint(address to, uint256 quantity) internal {

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

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId,
        bool ignoreOwnership
    ) private {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        if (!ignoreOwnership) {
          bool isApprovedOrOwner = (_msgSender() == from ||
              isApprovedForAll(from, _msgSender()) ||
              getApproved(tokenId) == _msgSender());

          if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, from);

        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _burn(uint256 tokenId) internal virtual {

        _burn(tokenId, false);
    }

    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        _approve(address(0), tokenId, from);

        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

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
pragma solidity ^0.8.2;


interface IWNS_Passes is IERC1155 {
  function burnTypeBulk(uint256 _typeId, address[] calldata owners) external;
  function burnTypeForOwnerAddress(uint256 _typeId, uint256 _quantity, address _typeOwnerAddress) external returns (bool);
  function mintTypeToAddress(uint256 _typeId, uint256 _quantity, address _toAddress) external returns (bool);
  function bulkSafeTransfer(uint256 _typeId, uint256 _quantityPerRecipient, address[] calldata recipients) external;
}// MIT
pragma solidity ^0.8.4;


interface IWRLD_Name_Service_Bridge is IERC165 {
  function transfer(address from, address to, uint256 tokenId, string memory name) external;
  function extendRegistration(string[] calldata _names, uint16[] calldata _additionalYears) external;
  function setController(string calldata _name, address _controller) external;

  function setStringRecord(string calldata _name, string calldata _record, string calldata _value, string calldata _typeOf, uint256 _ttl) external;
  function setAddressRecord(string memory _name, string memory _record, address _value, uint256 _ttl) external;
  function setUintRecord(string calldata _name, string calldata _record, uint256 _value, uint256 _ttl) external;
  function setIntRecord(string calldata _name, string calldata _record, int256 _value, uint256 _ttl) external;

  function setStringEntry(address _setter, string calldata _name, string calldata _entry, string calldata _value) external;
  function setAddressEntry(address _setter, string calldata _name, string calldata _entry, address _value) external;
  function setUintEntry(address _setter, string calldata _name, string calldata _entry, uint256 _value) external;
  function setIntEntry(address _setter, string calldata _name, string calldata _entry, int256 _value) external;

  function migrate(string calldata _name, uint256 _networkFlags) external;
}// MIT
pragma solidity ^0.8.4;


interface IWRLD_Name_Service_Metadata is IERC165 {
  function getMetadata(string memory _name, uint256 _expiresAt) external view returns (string memory);
  function getImage(string memory _name, uint256 _expiresAt) external view returns (string memory);
}// MIT
pragma solidity ^0.8.4;

interface IWRLD_Records {
  struct StringRecord {
    string value;
    string typeOf;
    uint256 ttl;
  }

  struct AddressRecord {
    address value;
    uint256 ttl;
  }

  struct UintRecord {
    uint256 value;
    uint256 ttl;
  }

  struct IntRecord {
    int256 value;
    uint256 ttl;
  }
}// MIT
pragma solidity ^0.8.4;



interface IWRLD_Name_Service_Resolver is IERC165, IWRLD_Records {

  function setStringRecord(string calldata _name, string calldata _record, string calldata _value, string calldata _typeOf, uint256 _ttl) external;
  function getNameStringRecord(string calldata _name, string calldata _record) external view returns (StringRecord memory);
  function getNameStringRecordsList(string calldata _name) external view returns (string[] memory);

  function setAddressRecord(string memory _name, string memory _record, address _value, uint256 _ttl) external;
  function getNameAddressRecord(string calldata _name, string calldata _record) external view returns (AddressRecord memory);
  function getNameAddressRecordsList(string calldata _name) external view returns (string[] memory);

  function setUintRecord(string calldata _name, string calldata _record, uint256 _value, uint256 _ttl) external;
  function getNameUintRecord(string calldata _name, string calldata _record) external view returns (UintRecord memory);
  function getNameUintRecordsList(string calldata _name) external view returns (string[] memory);

  function setIntRecord(string calldata _name, string calldata _record, int256 _value, uint256 _ttl) external;
  function getNameIntRecord(string calldata _name, string calldata _record) external view returns (IntRecord memory);
  function getNameIntRecordsList(string calldata _name) external view returns (string[] memory);


  function setStringEntry(address _setter, string calldata _name, string calldata _entry, string calldata _value) external;
  function getStringEntry(address _setter, string calldata _name, string calldata _entry) external view returns (string memory);

  function setAddressEntry(address _setter, string calldata _name, string calldata _entry, address _value) external;
  function getAddressEntry(address _setter, string calldata _name, string calldata _entry) external view returns (address);

  function setUintEntry(address _setter, string calldata _name, string calldata _entry, uint256 _value) external;
  function getUintEntry(address _setter, string calldata _name, string calldata _entry) external view returns (uint256);

  function setIntEntry(address _setter, string calldata _name, string calldata _entry, int256 _value) external;
  function getIntEntry(address _setter, string calldata _name, string calldata _entry) external view returns (int256);


  event StringRecordUpdated(string indexed idxName, string name, string record, string value, string typeOf, uint256 ttl);
  event AddressRecordUpdated(string indexed idxName, string name, string record, address value, uint256 ttl);
  event UintRecordUpdated(string indexed idxName, string name, string record, uint256 value, uint256 ttl);
  event IntRecordUpdated(string indexed idxName, string name, string record, int256 value, uint256 ttl);

  event StringEntryUpdated(address indexed setter, string indexed idxName, string indexed idxEntry, string name, string entry, string value);
  event AddressEntryUpdated(address indexed setter, string indexed idxName, string indexed idxEntry, string name, string entry, address value);
  event UintEntryUpdated(address indexed setter, string indexed idxName, string indexed idxEntry, string name, string entry, uint256 value);
  event IntEntryUpdated(address indexed setter, string indexed idxName, string indexed idxEntry, string name, string entry, int256 value);
}// MIT
pragma solidity ^0.8.4;


interface IWRLD_Name_Service_Registry is IERC165 {
  function register(address _registerer, string[] calldata _names, uint16[] memory _registrationYears) external;
  function extendRegistration(string[] calldata _names, uint16[] calldata _additionalYears) external;

  function getNameTokenId(string calldata _name) external view returns (uint256);

  event NameRegistered(string indexed idxName, string name, uint16 registrationYears);
  event NameRegistrationExtended(string indexed idxName, string name, uint16 additionalYears);
  event NameControllerUpdated(string indexed idxName, string name, address controller);

  event ResolverStringRecordUpdated(string indexed idxName, string name, string record, string value, string typeOf, uint256 ttl, address resolver);
  event ResolverAddressRecordUpdated(string indexed idxName, string name, string record, address value, uint256 ttl, address resolver);
  event ResolverUintRecordUpdated(string indexed idxName, string name, string record, uint256 value, uint256 ttl, address resolver);
  event ResolverIntRecordUpdated(string indexed idxName, string name, string record, int256 value, uint256 ttl, address resolver);

  event ResolverStringEntryUpdated(address indexed setter, string indexed idxName, string indexed idxEntry, string name, string entry, string value);
  event ResolverAddressEntryUpdated(address indexed setter, string indexed idxName, string indexed idxEntry, string name, string entry, address value);
  event ResolverUintEntryUpdated(address indexed setter, string indexed idxName, string indexed idxEntry, string name, string entry, uint256 value);
  event ResolverIntEntryUpdated(address indexed setter, string indexed idxName, string indexed idxEntry, string name, string entry, int256 value);
}// MIT
pragma solidity >=0.8.4;

library StringUtils {
    function strlen(string memory s) internal pure returns (uint256) {
        uint len;
        uint i = 0;
        uint bytelength = bytes(s).length;
        for (len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if (b < 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return len;
    }

    function validateUriCharset(string memory s) internal pure returns (bool) {
        uint len;
        uint i = 0;
        uint bytelength = bytes(s).length;
        bytes1 b0 = bytes(s)[0];
        if (b0==0x2d||b0==0x5f||b0==0x7e) {  // not allowed: - _ ~
            return false;
        }
        for (len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if (b < 0x80) {
                i += 1;
                if (b<0x2d||b==0x2e||b==0x2f||(b>=0x3a&&b<=0x40)||b==0x5b||b==0x5c||b==0x5d||b==0x5e||b==0x60||b==0x7b||b==0x7c||b==0x7d||b==0x7f) {
                    return false;
                }
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return true;
    }

    function UTS46Normalize(string memory s) internal pure returns (string memory) {
        uint len;
        uint i = 0;
        uint bytelength = bytes(s).length;
        bytes1 b0 = bytes(s)[0];

        if (b0==0x2d||b0==0x5f||b0==0x7e) {  // not allowed: - _ ~
            revert("invalid charset");
        }
        for (len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if (b < 0x80) {
                i += 1;
                if (b<0x2d||b==0x2e||b==0x2f||(b>=0x3a&&b<=0x40)||b==0x5b||b==0x5c||b==0x5d||b==0x5e||b==0x60||b==0x7b||b==0x7c||b==0x7d||b==0x7f) {
                    revert("invalid charset");
                }
                if (b>=0x41&&b<=0x5a) {
                    bytes(s)[i] = bytes1(uint8(b) + 32);
                }
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return s;
    }
}// MIT
pragma solidity ^0.8.4;



contract WRLD_Name_Service_Registry is ERC721AF, IWRLD_Name_Service_Registry, IWRLD_Records, Ownable, ReentrancyGuard {
  using StringUtils for *;


  IWRLD_Name_Service_Metadata metadata;
  IWRLD_Name_Service_Resolver resolver;
  IWRLD_Name_Service_Bridge bridge;

  uint256 private constant YEAR_SECONDS = 31536000;

  mapping(uint256 => WRLDName) public wrldNames;
  mapping(string => uint256) private nameTokenId;

  address private approvedWithdrawer;
  mapping(address => bool) private approvedRegistrars;

  struct WRLDName {
    string name;
    address controller;
    uint256 expiresAt;
  }

  constructor() ERC721AF("WRLD Name Service", "WNS") {}


  function tokenURI(uint256 _tokenId) override public view returns (string memory) {
    require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
    return metadata.getMetadata(wrldNames[_tokenId].name, wrldNames[_tokenId].expiresAt);
  }


  function register(address _registerer, string[] calldata _names, uint16[] memory _registrationYears) external override isApprovedRegistrar {
    require(_names.length == _registrationYears.length, "Arg size mismatched");

    uint256 mintCount = 0;
    uint256 tokenStartId = _currentIndex;

    for (uint256 i = 0; i < _names.length; i++) {
      require(_registrationYears[i] > 0, "Years must be greater than 0");

      string memory name = _names[i].UTS46Normalize();
      uint256 expiresAt = block.timestamp + YEAR_SECONDS * _registrationYears[i];

      if (nameExists(name)) {
        require(getNameExpiration(name) < block.timestamp, "Unavailable name");

        uint256 existingTokenId = nameTokenId[name];

        wrldNames[existingTokenId].expiresAt = expiresAt;

        _safeTransferFromForced(getNameOwner(name), _registerer, existingTokenId, "");
      } else {
        uint256 newTokenId = tokenStartId + mintCount;

        wrldNames[newTokenId] = WRLDName({
          name: name,
          controller: _registerer,
          expiresAt: expiresAt
        });

        nameTokenId[name] = newTokenId;

        mintCount++;

        emit NameRegistered(name, name, _registrationYears[i]);
      }
    }

    if (mintCount > 0) {
      _safeMint(_registerer, mintCount);
    }
  }


  function extendRegistration(string[] calldata _names, uint16[] calldata _additionalYears) external override isApprovedRegistrar {
    require(_names.length == _additionalYears.length, "Arg size mismatched");

    for (uint256 i = 0; i < _names.length; i++) {
      require(_additionalYears[i] > 0, "Years must be greater than zero");

      WRLDName storage wrldName = wrldNames[nameTokenId[_names[i]]];
      wrldName.expiresAt = wrldName.expiresAt + YEAR_SECONDS * _additionalYears[i];

      emit NameRegistrationExtended(_names[i], _names[i], _additionalYears[i]);
    }

    if (hasBridge()) {
      bridge.extendRegistration(_names, _additionalYears);
    }
  }


  function nameAvailable(string memory _name) external view returns (bool) {
    return !nameExists(_name) || getNameExpiration(_name) < block.timestamp;
  }

  function nameExists(string memory _name) public view returns (bool) {
    return nameTokenId[_name] != 0;
  }

  function getNameTokenId(string calldata _name) external view override returns (uint256) {
    return nameTokenId[_name];
  }

  function getTokenName(uint256 _tokenId) external view returns (string memory) {
    return wrldNames[_tokenId].name;
  }

  function getName(string calldata _name) external view returns (WRLDName memory) {
    return wrldNames[nameTokenId[_name]];
  }

  function getNameOwner(string memory _name) public view returns (address) {
    return ownerOf(nameTokenId[_name]);
  }

  function getNameController(string memory _name) public view returns (address) {
    return wrldNames[nameTokenId[_name]].controller;
  }

  function getNameExpiration(string memory _name) public view returns (uint256) {
    return wrldNames[nameTokenId[_name]].expiresAt;
  }

  function getNameStringRecord(string calldata _name, string calldata _record) external view returns (StringRecord memory) {
    return resolver.getNameStringRecord(_name, _record);
  }

  function getNameStringRecordsList(string calldata _name) external view returns (string[] memory) {
    return resolver.getNameStringRecordsList(_name);
  }

  function getNameAddressRecord(string calldata _name, string calldata _record) external view returns (AddressRecord memory) {
    return resolver.getNameAddressRecord(_name, _record);
  }

  function getNameAddressRecordsList(string calldata _name) external view returns (string[] memory) {
    return resolver.getNameAddressRecordsList(_name);
  }

  function getNameUintRecord(string calldata _name, string calldata _record) external view returns (UintRecord memory) {
    return resolver.getNameUintRecord(_name, _record);
  }

  function getNameUintRecordsList(string calldata _name) external view returns (string[] memory) {
    return resolver.getNameUintRecordsList(_name);
  }

  function getNameIntRecord(string calldata _name, string calldata _record) external view returns (IntRecord memory) {
    return resolver.getNameIntRecord(_name, _record);
  }

  function getNameIntRecordsList(string calldata _name) external view returns (string[] memory) {
    return resolver.getNameIntRecordsList(_name);
  }

  function getStringEntry(address _setter, string calldata _name, string calldata _entry) external view returns (string memory) {
    return resolver.getStringEntry(_setter, _name, _entry);
  }

  function getAddressEntry(address _setter, string calldata _name, string calldata _entry) external view returns (address) {
    return resolver.getAddressEntry(_setter, _name, _entry);
  }

  function getUintEntry(address _setter, string calldata _name, string calldata _entry) external view returns (uint256) {
    return resolver.getUintEntry(_setter, _name, _entry);
  }

  function getIntEntry(address _setter, string calldata _name, string calldata _entry) external view returns (int256) {
    return resolver.getIntEntry(_setter, _name, _entry);
  }


  function migrate(string calldata _name, uint256 _networkFlags) external isOwnerOrController(_name) {
    require(hasBridge(), "Bridge not set");

    bridge.migrate(_name, _networkFlags);
  }

  function setController(string calldata _name, address _controller) external {
    require(getNameOwner(_name) == msg.sender, "Sender is not owner");

    wrldNames[nameTokenId[_name]].controller = _controller;

    emit NameControllerUpdated(_name, _name, _controller);

    if (hasBridge()) {
      bridge.setController(_name, _controller);
    }
  }

  function setStringRecord(string calldata _name, string calldata _record, string calldata _value, string calldata _typeOf, uint256 _ttl) external isOwnerOrController(_name) {
    resolver.setStringRecord(_name, _record, _value, _typeOf, _ttl);

    emit ResolverStringRecordUpdated(_name, _name, _record, _value, _typeOf, _ttl, address(resolver));

    if (hasBridge()) {
      bridge.setStringRecord(_name, _record, _value, _typeOf, _ttl);
    }
  }

  function setAddressRecord(string memory _name, string memory _record, address _value, uint256 _ttl) external isOwnerOrController(_name) {
    resolver.setAddressRecord(_name, _record, _value, _ttl);

    emit ResolverAddressRecordUpdated(_name, _name, _record, _value, _ttl, address(resolver));

    if (hasBridge()) {
      bridge.setAddressRecord(_name, _record, _value, _ttl);
    }
  }

  function setUintRecord(string calldata _name, string calldata _record, uint256 _value, uint256 _ttl) external isOwnerOrController(_name) {
    resolver.setUintRecord(_name, _record, _value, _ttl);

    emit ResolverUintRecordUpdated(_name, _name, _record, _value, _ttl, address(resolver));

    if (hasBridge()) {
      bridge.setUintRecord(_name, _record, _value, _ttl);
    }
  }

  function setIntRecord(string calldata _name, string calldata _record, int256 _value, uint256 _ttl) external isOwnerOrController(_name) {
    resolver.setIntRecord(_name, _record, _value, _ttl);

    emit ResolverIntRecordUpdated(_name, _name, _record, _value, _ttl, address(resolver));

    if (hasBridge()) {
      bridge.setIntRecord(_name, _record, _value, _ttl);
    }
  }


  function setStringEntry(string calldata _name, string calldata _entry, string calldata _value) external {
    resolver.setStringEntry(msg.sender, _name, _entry, _value);

    emit ResolverStringEntryUpdated(msg.sender, _name, _entry, _name, _entry, _value);

    if (hasBridge()) {
      bridge.setStringEntry(msg.sender, _name, _entry, _value);
    }
  }

  function setAddressEntry(string calldata _name, string calldata _entry, address _value) external {
    resolver.setAddressEntry(msg.sender, _name, _entry, _value);

    emit ResolverAddressEntryUpdated(msg.sender, _name, _entry, _name, _entry, _value);

    if (hasBridge()) {
      bridge.setAddressEntry(msg.sender, _name, _entry, _value);
    }
  }

  function setUintEntry(string calldata _name, string calldata _entry, uint256 _value) external {
    resolver.setUintEntry(msg.sender, _name, _entry, _value);

    emit ResolverUintEntryUpdated(msg.sender, _name, _entry, _name, _entry, _value);

    if (hasBridge()) {
      bridge.setUintEntry(msg.sender, _name, _entry, _value);
    }
  }

  function setIntEntry(string calldata _name, string calldata _entry, int256 _value) external {
    resolver.setIntEntry(msg.sender, _name, _entry, _value);

    emit ResolverIntEntryUpdated(msg.sender, _name, _entry, _name, _entry, _value);

    if (hasBridge()) {
      bridge.setIntEntry(msg.sender, _name, _entry, _value);
    }
  }


  function setApprovedWithdrawer(address _approvedWithdrawer) external onlyOwner {
    approvedWithdrawer = _approvedWithdrawer;
  }

  function setApprovedRegistrar(address _approvedRegistrar, bool _approved) external onlyOwner {
    approvedRegistrars[_approvedRegistrar] = _approved;
  }

  function setMetadataContract(address _metadata) external onlyOwner {
    IWRLD_Name_Service_Metadata metadataContract = IWRLD_Name_Service_Metadata(_metadata);

    require(metadataContract.supportsInterface(type(IWRLD_Name_Service_Metadata).interfaceId), "Invalid metadata contract");

    metadata = metadataContract;
  }

  function setResolverContract(address _resolver) external onlyOwner {
    IWRLD_Name_Service_Resolver resolverContract = IWRLD_Name_Service_Resolver(_resolver);

    require(resolverContract.supportsInterface(type(IWRLD_Name_Service_Resolver).interfaceId), "Invalid resolver contract");

    resolver = resolverContract;
  }

  function setBridgeContract(address _bridge) external onlyOwner {
    IWRLD_Name_Service_Bridge bridgeContract = IWRLD_Name_Service_Bridge(_bridge);

    require(bridgeContract.supportsInterface(type(IWRLD_Name_Service_Bridge).interfaceId), "Invalid bridge contract");

    bridge = bridgeContract;
  }


  function _startTokenId() internal pure override returns (uint256) {
    return 1; // must start at 1, id 0 is used as non-existant check.
  }

  function _afterTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal override {
    for (uint256 i = 0; i < quantity; i++) {
      uint256 tokenId = startTokenId + i;
      WRLDName storage wrldName = wrldNames[tokenId];

      wrldName.controller = to;

      resolver.setAddressRecord(wrldName.name, "evm_default", to, 3600);
      emit ResolverAddressRecordUpdated(wrldName.name, wrldName.name, "evm_default", to, 3600, address(resolver));

      if (hasBridge()) {
        bridge.transfer(from, to, tokenId, wrldName.name);
      }
    }

    super._afterTokenTransfers(from, to, startTokenId, quantity);
  }


  function hasBridge() private view returns (bool) {
    return address(bridge) != address(0);
  }


  modifier isApprovedRegistrar() {
    require(approvedRegistrars[msg.sender], "msg sender is not registrar");
    _;
  }

  modifier isOwnerOrController(string memory _name) {
    require((getNameOwner(_name) == msg.sender || getNameController(_name) == msg.sender), "Sender is not owner or controller");
    _;
  }
}