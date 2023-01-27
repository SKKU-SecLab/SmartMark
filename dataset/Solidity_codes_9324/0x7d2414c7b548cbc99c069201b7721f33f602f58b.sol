
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
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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
}// MIT

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
}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    function __ERC1155_init(string memory uri_) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal initializer {

        _setURI(uri_);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
    uint256[47] private __gap;
}// MIT pragma
pragma solidity 0.7.5;

library LibPart {

    bytes32 public constant TYPE_HASH =
        keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {

        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}// MIT
pragma solidity 0.7.5;

abstract contract AbstractRoyalties {
    mapping(uint256 => LibPart.Part) public royalties;

    function _saveRoyalties(uint256 _id, LibPart.Part memory _royalties)
        internal
    {
        require(
            _royalties.account != address(0x0),
            "Recipient should be present"
        );
        require(_royalties.value >= 0, "Royalty value should be positive");
        royalties[_id] = _royalties;
        _onRoyaltiesSet(_id, _royalties);
    }

    function _updateAccount(
        uint256 _id,
        address _from,
        address _to
    ) internal {
        if (royalties[_id].account == _from) {
            royalties[_id].account = payable(address(uint160(_to)));
        }
    }

    function _onRoyaltiesSet(uint256 _id, LibPart.Part memory _royalties)
        internal
        virtual;
}// MIT
pragma solidity 0.7.5;
pragma abicoder v2;


interface RoyaltiesV2 {

    event RoyaltiesSet(uint256 tokenId, LibPart.Part royalties);

    function getVindergoodV2Royalties(uint256 id)
        external
        view
        returns (LibPart.Part memory);

}// MIT
pragma solidity 0.7.5;


contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2 {

    function getVindergoodV2Royalties(uint256 id)
        public
        view
        override
        returns (LibPart.Part memory)
    {

        return royalties[id];
    }

    function _onRoyaltiesSet(uint256 _id, LibPart.Part memory _royalties)
        internal
        override
    {

        emit RoyaltiesSet(_id, _royalties);
    }
}// MIT
pragma solidity 0.7.5;




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
}


pragma solidity 0.7.5;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity 0.7.5;

interface IERC1155 is IERC165 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);


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

}


pragma solidity 0.7.5;

interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}


pragma solidity 0.7.5;

interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}


pragma solidity 0.7.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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


pragma solidity 0.7.5;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}


pragma solidity 0.7.5;

abstract contract Pausable is ContextUpgradeable {
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
}


pragma solidity 0.7.5;

abstract contract ContextMixin {
    function msgSender() internal view returns (address payable sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}


pragma solidity 0.7.5;

contract EIP712Base is Initializable {

    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 salt;
    }

    string public constant ERC712_VERSION = "1";

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            bytes(
                "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"
            )
        );
    bytes32 internal domainSeperator;

    function _initializeEIP712(string memory name) internal initializer {

        _setDomainSeperator(name);
    }

    function _setDomainSeperator(string memory name) internal {

        domainSeperator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(ERC712_VERSION)),
                address(this),
                bytes32(getChainId())
            )
        );
    }

    function getDomainSeperator() public view returns (bytes32) {

        return domainSeperator;
    }

    function getChainId() public view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function toTypedMessageHash(bytes32 messageHash)
        internal
        view
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19\x01", getDomainSeperator(), messageHash)
            );
    }
}


pragma solidity 0.7.5;

contract NativeMetaTransaction is EIP712Base {

    bytes32 private constant META_TRANSACTION_TYPEHASH =
        keccak256(
            bytes(
                "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
            )
        );
    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );
    mapping(address => uint256) nonces;

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external returns (bytes memory) {

        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        require(
            verify(userAddress, metaTx, sigR, sigS, sigV),
            "Signer and signature do not match"
        );

        nonces[userAddress] += 1;

        emit MetaTransactionExecuted(
            userAddress,
            payable(msg.sender),
            functionSignature
        );

        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call not successful");

        return returnData;
    }

    function hashMetaTransaction(MetaTransaction memory metaTx)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    META_TRANSACTION_TYPEHASH,
                    metaTx.nonce,
                    metaTx.from,
                    keccak256(metaTx.functionSignature)
                )
            );
    }

    function getNonce(address user) public view returns (uint256 nonce) {

        nonce = nonces[user];
    }

    function verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {

        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");
        return
            signer ==
            ecrecover(
                toTypedMessageHash(hashMetaTransaction(metaTx)),
                sigV,
                sigR,
                sigS
            );
    }
}


pragma solidity 0.7.5;

contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

contract ERC1155Tradable is
    ContextMixin,
    ERC1155Upgradeable,
    NativeMetaTransaction,
    OwnableUpgradeable,
    Pausable
{

    using Address for address;

    address public proxyRegistryAddress;
    string public name;
    string public symbol;

    mapping(uint256 => mapping(address => uint256)) private balances;

    mapping(uint256 => uint256) private _supply;

    function initializeERC1155Tradable(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) public initializer {

        require(_proxyRegistryAddress != address(0), "Invalid Address");

        __ERC1155_init("");
        __Ownable_init();

        name = _name;
        symbol = _symbol;
        proxyRegistryAddress = _proxyRegistryAddress;
        _initializeEIP712(name);
    }

    modifier onlyOwnerOrProxy() {

        require(
            _isOwnerOrProxy(_msgSender()),
            "ERC1155Tradable#onlyOwner: CALLER_IS_NOT_OWNER"
        );
        _;
    }

    modifier onlyApproved(address _from) {

        require(
            _from == _msgSender() || isApprovedForAll(_from, _msgSender()),
            "ERC1155Tradable#onlyApproved: CALLER_NOT_ALLOWED"
        );
        _;
    }

    function _isOwnerOrProxy(address _address) internal view returns (bool) {

        return owner() == _address || _isProxyForUser(owner(), _address);
    }

    function pause() external onlyOwnerOrProxy {

        _pause();
    }

    function unpause() external onlyOwnerOrProxy {

        _unpause();
    }

    function balanceOf(address account, uint256 id)
        public
        view
        virtual
        override
        returns (uint256)
    {

        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        return balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(
            accounts.length == ids.length,
            "ERC1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function totalSupply(uint256 _id) public view returns (uint256) {

        return _supply[_id];
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {

        if (_isProxyForUser(_owner, _operator)) {
            return true;
        }

        return super.isApprovedForAll(_owner, _operator);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override whenNotPaused onlyApproved(from) {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            from,
            to,
            asSingletonArray(id),
            asSingletonArray(amount),
            data
        );

        uint256 fromBalance = balances[id][from];
        require(
            fromBalance >= amount,
            "ERC1155: insufficient balance for transfer"
        );
        balances[id][from] = fromBalance - amount;
        balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override whenNotPaused onlyApproved(from) {

        require(
            ids.length == amounts.length,
            "ERC1155: IDS_AMOUNTS_LENGTH_MISMATCH"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = balances[id][from];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
            balances[id][from] = fromBalance - amount;
            balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    function _beforeMint(uint256 _id, uint256 _quantity) internal virtual {}


    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public virtual onlyOwnerOrProxy {

        _mint(_to, _id, _quantity, _data);
    }

    function batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _quantities,
        bytes memory _data
    ) public virtual onlyOwnerOrProxy {

        _batchMint(_to, _ids, _quantities, _data);
    }

    function burn(
        address _from,
        uint256 _id,
        uint256 _quantity
    ) public virtual onlyApproved(_from) {

        _burn(_from, _id, _quantity);
    }

    function batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _quantities
    ) public virtual onlyApproved(_from) {

        _burnBatch(_from, _ids, _quantities);
    }

    function exists(uint256 _id) public view returns (bool) {

        return _supply[_id] > 0;
    }

    function _mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal virtual override whenNotPaused {

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            _to,
            asSingletonArray(_id),
            asSingletonArray(_amount),
            _data
        );

        _beforeMint(_id, _amount);

        balances[_id][_to] += _amount;
        _supply[_id] += _amount;

        address origin = _origin(_id);

        emit TransferSingle(operator, origin, _to, _id, _amount);

        doSafeTransferAcceptanceCheck(
            operator,
            origin,
            _to,
            _id,
            _amount,
            _data
        );
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal virtual whenNotPaused {

        require(
            _ids.length == _amounts.length,
            "ERC1155Tradable#batchMint: INVALID_ARRAYS_LENGTH"
        );

        uint256 nMint = _ids.length;

        address origin = _origin(_ids[0]);

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), _to, _ids, _amounts, _data);

        for (uint256 i = 0; i < nMint; i++) {
            uint256 id = _ids[i];
            uint256 amount = _amounts[i];
            _beforeMint(id, amount);
            require(
                _origin(id) == origin,
                "ERC1155Tradable#batchMint: MULTIPLE_ORIGINS_NOT_ALLOWED"
            );
            balances[id][_to] += amount;
            _supply[id] += amount;
        }

        emit TransferBatch(operator, origin, _to, _ids, _amounts);

        doSafeBatchTransferAcceptanceCheck(
            operator,
            origin,
            _to,
            _ids,
            _amounts,
            _data
        );
    }

    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal override whenNotPaused {

        require(account != address(0), "ERC1155#_burn: BURN_FROM_ZERO_ADDRESS");
        require(amount > 0, "ERC1155#_burn: AMOUNT_LESS_THAN_ONE");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            account,
            address(0),
            asSingletonArray(id),
            asSingletonArray(amount),
            ""
        );

        uint256 accountBalance = balances[id][account];
        require(
            accountBalance >= amount,
            "ERC1155#_burn: AMOUNT_EXCEEDS_BALANCE"
        );
        balances[id][account] = accountBalance - amount;
        _supply[id] -= amount;

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal override whenNotPaused {

        require(account != address(0), "ERC1155: BURN_FROM_ZERO_ADDRESS");
        require(
            ids.length == amounts.length,
            "ERC1155: IDS_AMOUNTS_LENGTH_MISMATCH"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = balances[id][account];
            require(
                accountBalance >= amount,
                "ERC1155#_burnBatch: AMOUNT_EXCEEDS_BALANCE"
            );
            balances[id][account] = accountBalance - amount;
            _supply[id] -= amount;
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _origin(
        uint256 /* _id */
    ) internal view virtual returns (address) {

        return address(0);
    }


    function _isProxyForUser(address _user, address _address)
        internal
        view
        virtual
        returns (bool)
    {

        if (!proxyRegistryAddress.isContract()) {
            return false;
        }
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        return address(proxyRegistry.proxies(_user)) == _address;
    }

    function doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver(to).onERC1155Received.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {

        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response !=
                    IERC1155Receiver(to).onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    function _msgSender() internal view override returns (address payable) {

        return ContextMixin.msgSender();
    }
}


pragma solidity 0.7.5;

contract AssetContract is RoyaltiesV2Impl, ERC1155Tradable {

    event PermanentURI(string _value, uint256 indexed _id);

    uint256 constant TOKEN_SUPPLY_CAP = 1;

    string public templateURI;

    mapping(uint256 => string) private _tokenURI;

    mapping(uint256 => bool) private _isPermanentURI;

    modifier onlyTokenAmountOwned(
        address _from,
        uint256 _id,
        uint256 _quantity
    ) {

        require(
            _ownsTokenAmount(_from, _id, _quantity),
            "AssetContract#onlyTokenAmountOwned: ONLY_TOKEN_AMOUNT_OWNED_ALLOWED"
        );
        _;
    }

    modifier onlyImpermanentURI(uint256 id) {

        require(
            !isPermanentURI(id),
            "AssetContract#onlyImpermanentURI: URI_CANNOT_BE_CHANGED"
        );
        _;
    }

    function initializeAssetContract(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress,
        string memory _templateURI
    ) public {

        initializeERC1155Tradable(_name, _symbol, _proxyRegistryAddress);
        if (bytes(_templateURI).length > 0) {
            setTemplateURI(_templateURI);
        }
    }

    function _ownsTokenAmount(
        address _from,
        uint256 _id,
        uint256 _quantity
    ) internal view returns (bool) {

        return balanceOf(_from, _id) >= _quantity;
    }

    function supportsFactoryInterface() public pure returns (bool) {

        return true;
    }

    function setTemplateURI(string memory _uri) public onlyOwnerOrProxy {

        templateURI = _uri;
    }

    function setURI(uint256 _id, string memory _uri)
        public
        virtual
        onlyOwnerOrProxy
        onlyImpermanentURI(_id)
    {

        _setURI(_id, _uri);
    }

    function setPermanentURI(uint256 _id, string memory _uri)
        public
        virtual
        onlyOwnerOrProxy
        onlyImpermanentURI(_id)
    {

        _setPermanentURI(_id, _uri);
    }

    function isPermanentURI(uint256 _id) public view returns (bool) {

        return _isPermanentURI[_id];
    }

    function uri(uint256 _id) public view override returns (string memory) {

        string memory tokenUri = _tokenURI[_id];
        if (bytes(tokenUri).length != 0) {
            return tokenUri;
        }
        return templateURI;
    }

    function balanceOf(address _owner, uint256 _id)
        public
        view
        virtual
        override
        returns (uint256)
    {

        uint256 balance = super.balanceOf(_owner, _id);
        return
            _isCreatorOrProxy(_id, _owner)
                ? balance + _remainingSupply(_id)
                : balance;
    }

    function setRoyalties(uint256 _id, LibPart.Part memory _royalty)
        public
        returns (uint256)
    {

        LibPart.Part memory royalty = getVindergoodV2Royalties(_id);
        if (royalty.account == address(0)) {
            _saveRoyalties(_id, _royalty);
        }

        return _id;
    }

    function transfer(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public returns (uint256) {

        uint256 mintedBalance = super.balanceOf(_from, _id);
        if (mintedBalance < _amount) {
            mint(_to, _id, _amount - mintedBalance, _data);
            if (mintedBalance > 0) {
                super.safeTransferFrom(_from, _to, _id, mintedBalance, _data);
            }
        } else {
            super.safeTransferFrom(_from, _to, _id, _amount, _data);
        }
        return _id;
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) public override {

        require(
            _ids.length == _amounts.length,
            "AssetContract#safeBatchTransferFrom: INVALID_ARRAYS_LENGTH"
        );
        for (uint256 i = 0; i < _ids.length; i++) {
            safeTransferFrom(_from, _to, _ids[i], _amounts[i], _data);
        }
    }

    function _beforeMint(uint256 _id, uint256 _quantity)
        internal
        view
        override
    {

        require(
            _quantity <= _remainingSupply(_id),
            "AssetContract#_beforeMint: QUANTITY_EXCEEDS_TOKEN_SUPPLY_CAP"
        );
    }

    function burn(
        address _from,
        uint256 _id,
        uint256 _quantity
    ) public override onlyTokenAmountOwned(_from, _id, _quantity) {

        super.burn(_from, _id, _quantity);
    }

    function batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _quantities
    ) public override {

        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                _ownsTokenAmount(_from, _ids[i], _quantities[i]),
                "AssetContract#batchBurn: ONLY_TOKEN_AMOUNT_OWNED_ALLOWED"
            );
        }
        super.batchBurn(_from, _ids, _quantities);
    }

    function _mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) internal override {

        super._mint(_to, _id, _quantity, _data);
        if (_data.length > 1) {
            _setURI(_id, string(_data));
        }
    }

    function _isCreatorOrProxy(uint256, address _address)
        internal
        view
        virtual
        returns (bool)
    {

        return _isOwnerOrProxy(_address);
    }

    function _remainingSupply(uint256 _id)
        internal
        view
        virtual
        returns (uint256)
    {

        return TOKEN_SUPPLY_CAP - totalSupply(_id);
    }

    function _origin(
        uint256 /* _id */
    ) internal view virtual override returns (address) {

        return owner();
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _quantities,
        bytes memory _data
    ) internal virtual override {

        super._batchMint(_to, _ids, _quantities, _data);
        if (_data.length > 1) {
            for (uint256 i = 0; i < _ids.length; i++) {
                _setURI(_ids[i], string(_data));
            }
        }
    }

    function _setURI(uint256 _id, string memory _uri) internal {

        _tokenURI[_id] = _uri;
        emit URI(_uri, _id);
    }

    function _setPermanentURI(uint256 _id, string memory _uri)
        internal
        virtual
    {

        require(
            bytes(_uri).length > 0,
            "AssetContract#setPermanentURI: ONLY_VALID_URI"
        );
        _isPermanentURI[_id] = true;
        _setURI(_id, _uri);
        emit PermanentURI(_uri, _id);
    }
}


pragma solidity 0.7.5;

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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {

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


pragma solidity 0.7.5;

library TokenIdentifiers {

    uint8 constant ADDRESS_BITS = 160;
    uint8 constant INDEX_BITS = 56;
    uint8 constant SUPPLY_BITS = 40;

    uint256 constant SUPPLY_MASK = (uint256(1) << SUPPLY_BITS) - 1;
    uint256 constant INDEX_MASK =
        ((uint256(1) << INDEX_BITS) - 1) ^ SUPPLY_MASK;

    function tokenMaxSupply(uint256 _id) internal pure returns (uint256) {

        return _id & SUPPLY_MASK;
    }

    function tokenIndex(uint256 _id) internal pure returns (uint256) {

        return _id & INDEX_MASK;
    }

    function tokenCreator(uint256 _id) internal pure returns (address) {

        return address(uint160(_id >> (INDEX_BITS + SUPPLY_BITS)));
    }
}


pragma solidity 0.7.5;

contract VindergoodToken is AssetContract, ReentrancyGuard {

    VindergoodToken public migrationTarget;

    mapping(address => bool) public sharedProxyAddresses;

    struct Ownership {
        uint256 id;
        address owner;
    }

    using TokenIdentifiers for uint256;

    event CreatorChanged(uint256 indexed _id, address indexed _creator);

    mapping(uint256 => address) internal _creatorOverride;

    modifier creatorOnly(uint256 _id) {

        require(
            _isCreatorOrProxy(_id, _msgSender()),
            "VindergoodToken#creatorOnly: ONLY_CREATOR_ALLOWED"
        );
        _;
    }

    modifier onlyFullTokenOwner(uint256 _id) {

        require(
            _ownsTokenAmount(_msgSender(), _id, _id.tokenMaxSupply()),
            "VindergoodToken#onlyFullTokenOwner: ONLY_FULL_TOKEN_OWNER_ALLOWED"
        );
        _;
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress,
        string memory _templateURI,
        address _migrationAddress
    ) external initializer {

        initializeAssetContract(
            _name,
            _symbol,
            _proxyRegistryAddress,
            _templateURI
        );
        migrationTarget = VindergoodToken(_migrationAddress);
    }

    function setProxyRegistryAddress(address _address) public onlyOwnerOrProxy {

        proxyRegistryAddress = _address;
    }

    function contractURI() public view returns (string memory) {

        return templateURI;
    }

    function addSharedProxyAddress(address _address) public onlyOwnerOrProxy {

        sharedProxyAddresses[_address] = true;
    }

    function removeSharedProxyAddress(address _address)
        public
        onlyOwnerOrProxy
    {

        delete sharedProxyAddresses[_address];
    }

    function disableMigrate() public onlyOwnerOrProxy {

        migrationTarget = VindergoodToken(address(0));
    }

    function migrate(Ownership[] memory _ownerships) public onlyOwnerOrProxy {

        VindergoodToken _migrationTarget = migrationTarget;
        require(
            _migrationTarget != VindergoodToken(address(0)),
            "VindergoodToken#migrate: MIGRATE_DISABLED"
        );

        string memory _migrationTargetTemplateURI = _migrationTarget
            .templateURI();

        for (uint256 i = 0; i < _ownerships.length; ++i) {
            uint256 id = _ownerships[i].id;
            address owner = _ownerships[i].owner;

            require(
                owner != address(0),
                "VindergoodToken#migrate: ZERO_ADDRESS_NOT_ALLOWED"
            );

            uint256 previousAmount = _migrationTarget.balanceOf(owner, id);

            if (previousAmount == 0) {
                continue;
            }

            _mint(owner, id, previousAmount, "");

            if (
                keccak256(bytes(_migrationTarget.uri(id))) !=
                keccak256(bytes(_migrationTargetTemplateURI))
            ) {
                _setPermanentURI(id, _migrationTarget.uri(id));
            }
        }
    }

    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public override nonReentrant creatorOnly(_id) {

        _mint(_to, _id, _quantity, _data);
    }

    function batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _quantities,
        bytes memory _data
    ) public override nonReentrant {

        for (uint256 i = 0; i < _ids.length; i++) {
            require(
                _isCreatorOrProxy(_ids[i], _msgSender()),
                "VindergoodToken#_batchMint: ONLY_CREATOR_ALLOWED"
            );
        }
        _batchMint(_to, _ids, _quantities, _data);
    }


    function setURI(uint256 _id, string memory _uri)
        public
        override
        creatorOnly(_id)
        onlyImpermanentURI(_id)
        onlyFullTokenOwner(_id)
    {

        _setURI(_id, _uri);
    }

    function setPermanentURI(uint256 _id, string memory _uri)
        public
        override
        creatorOnly(_id)
        onlyImpermanentURI(_id)
        onlyFullTokenOwner(_id)
    {

        _setPermanentURI(_id, _uri);
    }

    function setCreator(uint256 _id, address _to) public creatorOnly(_id) {

        require(
            _to != address(0),
            "VindergoodToken#setCreator: INVALID_ADDRESS."
        );
        _creatorOverride[_id] = _to;
        emit CreatorChanged(_id, _to);
    }

    function creator(uint256 _id) public view returns (address) {

        if (_creatorOverride[_id] != address(0)) {
            return _creatorOverride[_id];
        } else {
            return _id.tokenCreator();
        }
    }

    function maxSupply(uint256 _id) public pure returns (uint256) {

        return _id.tokenMaxSupply();
    }

    function _origin(uint256 _id) internal pure override returns (address) {

        return _id.tokenCreator();
    }

    function _requireMintable(address _address, uint256 _id) internal view {

        require(
            _isCreatorOrProxy(_id, _address),
            "VindergoodToken#_requireMintable: ONLY_CREATOR_ALLOWED"
        );
    }

    function _remainingSupply(uint256 _id)
        internal
        view
        override
        returns (uint256)
    {

        return maxSupply(_id) - totalSupply(_id);
    }

    function _isCreatorOrProxy(uint256 _id, address _address)
        internal
        view
        override
        returns (bool)
    {

        address creator_ = creator(_id);
        return creator_ == _address || _isProxyForUser(creator_, _address);
    }

    function _isProxyForUser(address _user, address _address)
        internal
        view
        override
        returns (bool)
    {

        if (sharedProxyAddresses[_address]) {
            return true;
        }
        return super._isProxyForUser(_user, _address);
    }
}