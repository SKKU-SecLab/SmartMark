




library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}






library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}





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





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}






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





interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}






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





interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}






interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}





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
}





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






abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}






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

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
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


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}






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
}






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






interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}






contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
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
        _setApprovalForAll(_msgSender(), operator, approved);
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
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
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
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
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
}











interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}



pragma solidity >=0.7.5 <0.9.0;


contract StarNFTMarketRoyalty is Ownable, ReentrancyGuard {
	bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
	bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
	bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
	
	using SafeMath for uint256;
	using Address for address;
	using Counters for Counters.Counter;
	Counters.Counter private _itemIds;
	Counters.Counter private _itemsClosed;
	
	address public marketOwner;
	address public feeAddress; // = 0xDa209d5B20CE12e6E37AED4374290668FDc68C85
	uint256 public feePercentage; // = 75; // default fee percentage : 0.75%, can move setting the value to constructor

	enum TokenType { ERC721, ERC1155 }
	enum MarketStatus { OPEN, CLOSED }

	struct MarketItem {
		uint256 itemId;
		address nftContract;
		uint256 tokenId;
		address seller;
		address owner;
		uint256 price;
		uint256 quantity;
		TokenType tokenType;
		MarketStatus status;
	}
	
	mapping(uint256 => MarketItem) private idToMarketItem;

	event MarketItemCreated(
		uint256 indexed itemId,
		address indexed nftContract,
		uint256 indexed tokenId,
		address seller,
		address owner,
		uint256 price,
		uint256 quantity,
		TokenType tokenType
	);

	event PriceChanged(uint256 indexed itemId, uint256 newPrice);
	event MarketNFTSold(uint256 indexed itemId, address indexed sender, uint256 amount);
	event MarketItemClosed(uint256 indexed itemId);

	constructor(address feeAddress_, uint256 feePercentage_) {
		require(feeAddress_ != address(0), "Invalid Address");
		require(feePercentage_ <= 10000, "Fee percentage can't be more than 100%");
		feeAddress = feeAddress_;
		feePercentage = feePercentage_;
		marketOwner = msg.sender;
	}

	function setFeeAddress(address _feeAddress) public onlyOwner {
		require(_feeAddress != address(0), "Invalid Address");
		feeAddress = _feeAddress;
	}

	function setFeePercentage(uint256 _feePercentage) public onlyOwner {
		require(_feePercentage <= 10000, "Fee percentage can't be more than 100%");
		feePercentage = _feePercentage;
	}

	function calculateFee(uint256 price) private view returns (uint256) {
		return price.mul(feePercentage).div(10000);
	}

	function getMarketItem(uint256 marketItemId) public view returns (MarketItem memory) {
		return idToMarketItem[marketItemId];
	}

	function createMarketItem721(
		address nftContract,
		uint256 tokenId,
		uint256 price
	) public nonReentrant {
		require(price >= 0.00000000001 ether, "Price must be at least 0.00000000001 ether");
		require(nftContract.isContract(), "Not a contract");
		require(IERC721(nftContract).supportsInterface(_INTERFACE_ID_ERC721), "Contract doesn't support IERC721");
		require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not an owner of nft");

		if (_supportsRoyalties(nftContract)) {
			( , uint256 royaltyAmount) = IERC2981(nftContract).royaltyInfo(tokenId, price);
			require(royaltyAmount <= price.mul(5000).div(10000), "Too high royalty percentage");
		}
		
		IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);
	
		_itemIds.increment();
		uint256 itemId = _itemIds.current();
		idToMarketItem[itemId] = MarketItem(
			itemId, 
			nftContract, 
			tokenId, 
			msg.sender,
			address(this), 
			price, 
			1, 
			TokenType.ERC721, 
			MarketStatus.OPEN
		);

		emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(this), price, 1, TokenType.ERC721);
	}
	
	function createMarketItem1155(
		address nftContract,
		uint256 tokenId,
		uint256 price,
		uint256 quantity
	) public nonReentrant {
		require(price >= 0.00000000001 ether, "Price must be at least 0.00000000001 ether");
		require(quantity > 0, "Can't put on market zero copies");
		require(nftContract.isContract(), "Not a contract");
		require(IERC1155(nftContract).supportsInterface(_INTERFACE_ID_ERC1155), "Contract doesn't support IERC1155");
		require(IERC1155(nftContract).balanceOf(msg.sender, tokenId) >= quantity, "Don't have enough copies to sell");
		
		if (_supportsRoyalties(nftContract)) {
			( , uint256 royaltyAmount) = IERC2981(nftContract).royaltyInfo(tokenId, price);
			require(royaltyAmount <= price.mul(5000).div(10000), "Too high royalty percentage");
		}
		
		IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, quantity, "");

		_itemIds.increment();
		uint256 itemId = _itemIds.current();
		idToMarketItem[itemId] = MarketItem(
			itemId, 
			nftContract, 
			tokenId, 
			msg.sender,
			address(this),
			price, 
			quantity, 
			TokenType.ERC1155, 
			MarketStatus.OPEN
		);

		emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(this), price, quantity, TokenType.ERC1155);
	}

	function buyMarketItem721(uint256 itemId) public payable nonReentrant {
		MarketStatus status = idToMarketItem[itemId].status;
		require(status == MarketStatus.OPEN, "Can't buy sold item");
		uint256 price = idToMarketItem[itemId].price;
		uint256 tokenId = idToMarketItem[itemId].tokenId;
		address nftContract = idToMarketItem[itemId].nftContract;
		uint256 fee = calculateFee(price);
		require(msg.value == price, "Incorrect amount of wei was sent");
		address seller = idToMarketItem[itemId].seller;
		require(seller != msg.sender, "Can't buy your own item");

		if (_supportsRoyalties(nftContract)) {
			(address royaltyReceiver, uint256 royaltyAmount) = IERC2981(nftContract).royaltyInfo(tokenId, price);
			(bool statusRoyalty, ) = payable(royaltyReceiver).call{value: royaltyAmount}("");
			require(statusRoyalty, "Failed to send Ether to royaltyReceiver");
			price -= royaltyAmount;
		}
		
		(bool statusPrice, ) = payable(seller).call{value: price.sub(fee)}("");
		(bool statusFee, ) = payable(feeAddress).call{value: fee}("");
		require(statusPrice && statusFee, "Failed to send Ether");
		
		IERC721(nftContract).safeTransferFrom(address(this), msg.sender, tokenId);
		_itemsClosed.increment();
		idToMarketItem[itemId].status = MarketStatus.CLOSED;
		
		emit MarketItemClosed(itemId);
	}
	
	function buyMarketItem1155(uint256 itemId, uint256 quantityToBuy) public payable nonReentrant {
		uint256 quantity = idToMarketItem[itemId].quantity;
		MarketStatus status = idToMarketItem[itemId].status;
		require(status == MarketStatus.OPEN, "Can't buy sold item");
		require(quantityToBuy > 0, "Invalid quantity value");
		require(quantity >= quantityToBuy, "Unable to buy more nfts than seller has");
		uint256 price = idToMarketItem[itemId].price.mul(quantityToBuy);
		uint256 tokenId = idToMarketItem[itemId].tokenId;
		address nftContract = idToMarketItem[itemId].nftContract;
		uint256 fee = calculateFee(price);
		require(msg.value == price, "Incorrect amount of wei was sent");
		address seller = idToMarketItem[itemId].seller;
		require(seller != msg.sender, "Can't buy your own item");
		
		if (_supportsRoyalties(nftContract)) {
			(address royaltyReceiver, uint256 royaltyAmount) = IERC2981(nftContract).royaltyInfo(tokenId, price);
			(bool statusRoyalty, ) = payable(royaltyReceiver).call{value: royaltyAmount}("");
			require(statusRoyalty, "Failed to send Ether to royaltyReceiver");
			price -= royaltyAmount;
		}
		
		(bool statusPrice, ) = payable(seller).call{value: price.sub(fee)}("");
		(bool statusFee, ) = payable(feeAddress).call{value: fee}("");
		require(statusPrice && statusFee, "Failed to send Ether");
		
		IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, tokenId, quantityToBuy, "");
		if (quantity > quantityToBuy) {
			idToMarketItem[itemId].quantity -= quantityToBuy;
			emit MarketNFTSold(itemId, msg.sender, quantityToBuy);
		}
		else {
			_itemsClosed.increment();
			idToMarketItem[itemId].status = MarketStatus.CLOSED;
			emit MarketNFTSold(itemId, msg.sender, quantityToBuy);
			emit MarketItemClosed(itemId);
		}
	}

	function closeMarketItem(uint256 itemId) public nonReentrant {
		address seller = idToMarketItem[itemId].seller;
		MarketStatus status = idToMarketItem[itemId].status;
		require(status == MarketStatus.OPEN, "MarketItem is already closed");
		require(msg.sender == seller || msg.sender == marketOwner, "Only seller of MarketItem and marketOwner can close item");
		uint256 tokenId = idToMarketItem[itemId].tokenId;
		address nftContract = idToMarketItem[itemId].nftContract;
		uint256 quantity = idToMarketItem[itemId].quantity;
		TokenType tokenType = idToMarketItem[itemId].tokenType;
		
		if (tokenType == TokenType.ERC721) {
			IERC721(nftContract).safeTransferFrom(address(this), seller, tokenId);
		} else {
			IERC1155(nftContract).safeTransferFrom(address(this), seller, tokenId, quantity, "");
		}
		
		idToMarketItem[itemId].status = MarketStatus.CLOSED;
		_itemsClosed.increment();
		
		emit MarketItemClosed(itemId);
	}

	function editMarketItem(uint256 itemId, uint256 newPrice) public {
		address seller = idToMarketItem[itemId].seller;
		MarketStatus status = idToMarketItem[itemId].status;
		uint256 price = idToMarketItem[itemId].price;
		require(status == MarketStatus.OPEN, "MarketItem is closed");
		require(msg.sender == seller, "Only seller of MarketItem can change price");
		require(newPrice >= 0.00000000001 ether, "Price must be at least 0.00000000001 ether");
		require(newPrice != price, "New price can't be equal to the current price");
		idToMarketItem[itemId].price = newPrice;
		
		emit PriceChanged(itemId, newPrice);
	}

	function getMarketItems() public view returns (MarketItem[] memory) {
		uint256 itemCount = _itemIds.current();
		uint256 unsoldItemCount = _itemIds.current() - _itemsClosed.current();
		uint256 currentIndex = 0;

		MarketItem[] memory items = new MarketItem[](unsoldItemCount);
		for (uint256 i = 0; i < itemCount; i++) {
			if ((idToMarketItem[i + 1].owner == address(this)) && (idToMarketItem[i + 1].status == MarketStatus.OPEN)) {
				MarketItem storage currentItem = idToMarketItem[i + 1];
				items[currentIndex] = currentItem;
				currentIndex += 1;
			}
		}

		return items;
	}

	function getUserItems(address walletAddress) public view returns (MarketItem[] memory) {
		uint256 totalItemCount = _itemIds.current();
		uint256 itemCount = 0;
		uint256 currentIndex = 0;

		for (uint256 i = 0; i < totalItemCount; i++) {
			if ((idToMarketItem[i + 1].seller == walletAddress) && (idToMarketItem[i + 1].status == MarketStatus.OPEN)) {				
				itemCount += 1;
			}
		}

		MarketItem[] memory items = new MarketItem[](itemCount);
		for (uint256 i = 0; i < totalItemCount; i++) {
			if ((idToMarketItem[i + 1].seller == walletAddress) && (idToMarketItem[i + 1].status == MarketStatus.OPEN)) {
				MarketItem storage currentItem = idToMarketItem[i + 1];
				items[currentIndex] = currentItem;
				currentIndex += 1;
			}
		}
		
		return items;
	}

	function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
		return this.onERC721Received.selector;
	}

	function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
		return this.onERC1155Received.selector;
	}

	
	function _supportsRoyalties(address nftContract) internal view returns (bool) {
		return IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC2981);
	}
}