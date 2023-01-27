
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


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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

contract VRFRequestIDBase {
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.8.0;



abstract contract VRFConsumerBase is VRFRequestIDBase {
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract PaymentSplitter is Context {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    function totalReleased(IERC20 token) public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    function released(IERC20 token, address account) public view returns (uint256) {
        return _erc20Released[token][account];
    }

    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function release(IERC20 token, address account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        uint256 payment = _pendingPayment(account, totalReceived, released(token, account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _erc20Released[token][account] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }
}// MIT



pragma solidity ^0.8.0;

contract CommitRevealSeeder {
   bytes8[] public blockhashData;

   struct TokenMap {
      uint16 startingTokenId;
      uint16 blockhashIndex;
   }

   TokenMap[] public tokenMap;

   function _commitTokens(uint256 _startingTokenId) internal {
      _commitBlockHash();
      _commitTokenMap(_startingTokenId);
   }

   function _commitBlockHash() private {
      if (blockhashData.length == 0 || blockhashData[blockhashData.length - 1] != bytes8(blockhash(block.number - 1))) {
         blockhashData.push(bytes8(blockhash(block.number - 1)));
      }
   }

   function _commitTokenMap(uint256 _startingTokenId) private {
      require(
         tokenMap.length == 0 || uint16(_startingTokenId) > tokenMap[tokenMap.length - 1].startingTokenId,
         "tokenIds must be comitted in ascending order"
      );
      tokenMap.push(TokenMap({startingTokenId: uint16(_startingTokenId), blockhashIndex: uint16(blockhashData.length)}));
   }

   function _tokenIdToBlockhashIndex(uint256 tokenId) internal view returns (uint16) {
      if (tokenMap.length == 1) return 1;

      for (uint256 i; i <= tokenMap.length - 2; i++) {
         if (tokenId >= tokenMap[i].startingTokenId && tokenId < tokenMap[i + 1].startingTokenId) return tokenMap[i].blockhashIndex;
      }
      return tokenMap[tokenMap.length - 1].blockhashIndex;
   }

   function _rawSeedForTokenId(uint256 tokenId) internal view returns (uint256) {
      uint256 blockhashIndex = _tokenIdToBlockhashIndex(tokenId); //Grab the location of the blockhashData to be used for this token
      if ((blockhashData.length - 1) >= blockhashIndex) {
         return uint256(keccak256(abi.encodePacked(address(this), tokenId, blockhashData[blockhashIndex])));
      } else {
         return 0;
      }
   }

   function _commitFinalBlockHash() internal {
      require(blockhashData[blockhashData.length - 1] != bytes8(blockhash(block.number - 1)), "Wait one block");
      _commitBlockHash();
   }
}// MIT


pragma solidity ^0.8.0;

interface GenesisDescriptor {
   function generateTokenURI(uint256 tokenId) external view returns (string memory);

   function getSvg(uint256 tokenId) external view returns (string memory);
}

interface V2Descriptor {
   function generateTokenURI(
      uint256 tokenId,
      uint256 rawSeed,
      uint256 tokenType
   ) external view returns (string memory);

   function processRawSeed(uint256 rawseed) external view returns (uint8[10] memory);

   function getSvgCustomToken(uint256 tokenId) external view returns (string memory);

   function getSvgFromSeed(uint8[10] memory seed) external view returns (string memory);
}

interface ENS_Registrar {
   function setName(string calldata name) external returns (bytes32);
}

contract EthTerrestrials is ERC721A, CommitRevealSeeder, Ownable, ReentrancyGuard, VRFConsumerBase, PaymentSplitter {
   enum TOKENTYPE {
      GENESIS,
      V2ONEOFONE,
      V2COMMON
   }

   address public address_genesis_descriptor;
   address public address_v2_descriptor;
   address public address_opensea_token;
   address public authorizedMinter;

   GenesisDescriptor genesis_descriptor;
   V2Descriptor v2_descriptor;
   IERC1155 OS_token;

   uint256 public constant genesisSupply = 100;
   uint256 public constant v2supplyMax = 4169;
   uint256 public constant v2oneOfOneCount = 11;
   uint256 public constant maxMintsPerTransaction = 10;

   uint256 private constant oneOfOneStart = genesisSupply + 1; //101
   uint256 private constant oneOfOneEnd = oneOfOneStart + v2oneOfOneCount - 1; //111
   uint256 private constant publicTokenStart = oneOfOneEnd + 1; //112

   uint256 public constant maxTokens = genesisSupply + v2supplyMax; //4269
   uint256 public v2price = 0.14 ether;

   bool public _UFOhasArrived; //toggles the public mint
   bool public _mothershipHasArrived; //toggles the ability to upgrade genesis tokens
   bool public _contractsealed; //seals contract from changes

   mapping(uint256 => uint256) public genesisTokenOSSStoNewTokenId;

   bytes32 internal keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
   uint256 public VRF_randomness;
   uint256 private fee = 2 ether;
   address public VRF_coordinator_address = 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952;
   address public LINK_address = 0x514910771AF9Ca656af840dff83E8264EcF986CA;

   modifier onlyOwnerWhileUnsealed() {
      require(!_contractsealed && msg.sender == owner(), "Not owner or locked");
      _;
   }

   constructor(address[] memory _payees, uint256[] memory _shares)
      public
      ERC721A("ETHTerrestrials", "ETHT")
      PaymentSplitter(_payees, _shares)
      VRFConsumerBase(VRF_coordinator_address, LINK_address)
   {

   }


   function onERC1155Received(
      address operator,
      address from,
      uint256 tokenId,
      uint256 value,
      bytes calldata data
   ) public nonReentrant returns (bytes4) {
      require(_mothershipHasArrived, "Mothership has not arrived, too early to beam up!");
      require(msg.sender == address_opensea_token, "Not the correct token contract");
      require(value == 1, "Quantity error");
      beamUp(tokenId);
      if (totalSupply() < maxTokens) {
         mintInternal(tx.origin, 1);
      }
      return this.onERC1155Received.selector;
   }

   function beamUp(uint256 tokenId) internal {
      uint256 newTokenId = genesisTokenOSSStoNewTokenId[tokenId];
      require(newTokenId != 0, "Not a valid tokenId");
      genesisTokenOSSStoNewTokenId[tokenId] = 0;

      IERC721(address(this)).safeTransferFrom(address(this), tx.origin, newTokenId);
   }

   function abduct(uint256 quantity) external payable nonReentrant {
      require(totalSupply() + quantity <= maxTokens, "Exceeds Supply");
      require(tx.origin == msg.sender, "No contract minters");
      require(_UFOhasArrived, "UFO hasn't arrived, abductions haven't started yet!");
      require(quantity <= maxMintsPerTransaction);
      require(msg.value == v2price * quantity, "Incorrect ETH sent");
      mintInternal(msg.sender, quantity);
   }

   function mintAdmin(address to, uint256 quantity) external nonReentrant {
      require(totalSupply() + quantity <= maxTokens, "Exceeds Supply");
      require(msg.sender == authorizedMinter, "Unauthorized");
      mintInternal(to, quantity);
   }

   function mintInternal(address to, uint256 quantity) private {
      _commitTokens(_currentIndex); //commit the tokens for a pseudorandom seed
      _safeMint(to, quantity);
   }


   function tokenURI(uint256 tokenId) public view override returns (string memory) {
      require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
      TOKENTYPE tokenType = checkType(tokenId);

      if (tokenType == TOKENTYPE.GENESIS) return genesis_descriptor.generateTokenURI(tokenId);

      uint256 rawSeed = tokenType == TOKENTYPE.V2ONEOFONE ? 0 : _rawSeedForTokenId(tokenId);

      return v2_descriptor.generateTokenURI(tokenId, rawSeed, uint256(tokenType));
   }

   function getTokenSeed(uint256 tokenId) public view returns (uint8[10] memory) {
      TOKENTYPE tokenType = checkType(tokenId);
      require(tokenType == TOKENTYPE.V2COMMON, "This type of token does not have a pseudorandom seed");

      uint256 rawSeed = _rawSeedForTokenId(tokenId);
      require(rawSeed != 0, "Seed not yet established");
      return v2_descriptor.processRawSeed(rawSeed);
   }

   function tokenSVG(uint256 tokenId, bool background) external view returns (string memory) {
      require(_exists(tokenId), "query for nonexistent token");
      TOKENTYPE tokenType = checkType(tokenId);

      if (tokenType == TOKENTYPE.GENESIS) return genesis_descriptor.getSvg(tokenId);
      else if (tokenType == TOKENTYPE.V2ONEOFONE) return v2_descriptor.getSvgCustomToken(tokenId);

      uint8[10] memory seed = getTokenSeed(tokenId);
      if (!background) seed[0] = 0;
      return v2_descriptor.getSvgFromSeed(seed);
   }

   function checkType(uint256 tokenId) public pure returns (TOKENTYPE) {
      if (tokenId <= genesisSupply) return TOKENTYPE.GENESIS;
      else if (tokenId <= oneOfOneEnd) return TOKENTYPE.V2ONEOFONE;
      else return TOKENTYPE.V2COMMON;
   }

   function tokenIdToBlockhashIndex(uint256 tokenId) external view returns (uint16) {
      require(_exists(tokenId), "query for nonexistent token");
      TOKENTYPE tokenType = checkType(tokenId);
      require(tokenType == TOKENTYPE.V2COMMON, "This type of token does not have a pseudorandom seed");
      return _tokenIdToBlockhashIndex(tokenId);
   }

   function rawSeedForTokenId(uint256 tokenId) external view returns (uint256) {
      require(_exists(tokenId), "query for nonexistent token");
      TOKENTYPE tokenType = checkType(tokenId);
      require(tokenType == TOKENTYPE.V2COMMON, "This type of token does not have a pseudorandom seed");
      return _rawSeedForTokenId(tokenId);
   }

   function _startTokenId() internal view override returns (uint256) {
      return 1;
   }



   function getRandomNumber() public onlyOwner returns (bytes32 requestId) {
      LINK.transferFrom(owner(), address(this), fee);
      require(VRF_randomness == 0, "Cannot request a random number once it has been set");
      require(totalSupply() == maxTokens, "Not sold out");
      return requestRandomness(keyHash, fee);
   }

   function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
      VRF_randomness = randomness;

      _commitFinalBlockHash();
   }

   function distributeOneOfOnes() external onlyOwner {
      require(VRF_randomness != 0, "Random seed not established");
      for (uint256 i; i < v2oneOfOneCount; i++) {
         uint256 recipientToken = (uint256(keccak256(abi.encode(VRF_randomness, i))) % (v2supplyMax - v2oneOfOneCount)) + publicTokenStart;

         address recipient = ownerOf(recipientToken);

         IERC721(address(this)).transferFrom(address(this), recipient, i + oneOfOneStart); //uses transferFrom instead of safeTransferFrom so that a contract recipient doesn't break the function
      }
   }

   function changeLinkFee(
      uint256 _fee,
      address _VRF_coordinator_address,
      bytes32 _keyhash
   ) external onlyOwner {
      fee = _fee;
      VRF_coordinator_address = _VRF_coordinator_address;
      keyHash = _keyhash;
   }


   function mintToContract() external onlyOwner {
      require(totalSupply() == 0);
      _mint(address(this), oneOfOneEnd, "", false);
   }

   function setAddresses(
      address _genesis_descriptor,
      address _v2_descriptor,
      address _os_address,
      address _authorizedMinter
   ) external onlyOwnerWhileUnsealed {
      address_genesis_descriptor = _genesis_descriptor;
      address_v2_descriptor = _v2_descriptor;
      genesis_descriptor = GenesisDescriptor(address_genesis_descriptor);
      v2_descriptor = V2Descriptor(address_v2_descriptor);
      address_opensea_token = _os_address;
      OS_token = IERC1155(address_opensea_token);
      authorizedMinter = _authorizedMinter;
   }

   function setGenesisTokenIds(uint256[] memory _OSSS_id, uint256[] memory _newTokenId) external onlyOwnerWhileUnsealed {
      require(_OSSS_id.length == _newTokenId.length, "Length mismatch");
      for (uint256 i; i < _OSSS_id.length; i++) {
         uint256 genesisId = _OSSS_id[i];
         uint256 newId = _newTokenId[i];
         genesisTokenOSSStoNewTokenId[genesisId] = newId;
      }
   }

   function togglePublicMint() external onlyOwner {
      _UFOhasArrived = !_UFOhasArrived;
   }

   function toggleUpgrade() external onlyOwner {
      _mothershipHasArrived = !_mothershipHasArrived;
   }

   function setv2Price(uint256 _price) external onlyOwner {
      v2price = _price;
   }

   function seal() external onlyOwnerWhileUnsealed {
      _contractsealed = true;
   }

   function emergencyWithdraw(uint256 tokenId) external onlyOwner {
      IERC721(address(this)).transferFrom(address(this), owner(), tokenId);
   }

   function setReverseRecord(string calldata _name, address registrar_address) external onlyOwner {
      ENS_Registrar(registrar_address).setName(_name);
   }
}