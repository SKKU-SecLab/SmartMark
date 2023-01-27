
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

}// MIT

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


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

pragma solidity ^0.8.9;


contract ERC1155Contract is ERC1155, Ownable, PaymentSplitter, ReentrancyGuard {


    using Strings for uint256;

    struct InitialParameters {
        uint256 launchpassId;
        string name;
        string symbol;
        string uri;
        uint256 id;
        uint24 maxSupply;
        uint24 maxPerWallet;
        uint24 maxPerTransaction;
        uint72 preSalePrice;
        uint72 pubSalePrice;
    }

    struct TokenType {
        uint24 maxSupply;
        uint24 maxPerWallet;
        uint24 maxPerTransaction;
        uint72 preSalePrice;
        uint72 pubSalePrice;
        bool preSaleIsActive;
        bool saleIsActive;
        bool supplyLock;
        address creator;
        uint256 totalSupply;
        bytes32 merkleRoot;
    }

    mapping(uint256 => TokenType) public tokenTypes;
    mapping (uint256 => mapping(address => uint256)) public hasMinted;
    uint256 public launchpassId;
    string public name;
    string public symbol;
    string private baseURI;

    constructor(
        address[] memory _payees,
        uint256[] memory _shares,
        address _owner,
        InitialParameters memory initialParameters
    ) ERC1155(initialParameters.uri) PaymentSplitter(_payees, _shares) {
        name = initialParameters.name;
        symbol = initialParameters.symbol;
        baseURI = initialParameters.uri;
        launchpassId = initialParameters.launchpassId;
        uint256 _id = initialParameters.id;
        tokenTypes[_id].maxSupply = initialParameters.maxSupply;
        tokenTypes[_id].maxPerWallet = initialParameters.maxPerWallet;
        tokenTypes[_id].maxPerTransaction = initialParameters.maxPerTransaction;
        tokenTypes[_id].preSalePrice = initialParameters.preSalePrice;
        tokenTypes[_id].pubSalePrice = initialParameters.pubSalePrice;
        tokenTypes[_id].totalSupply = 0;
        tokenTypes[_id].saleIsActive = false;
        tokenTypes[_id].preSaleIsActive = false;
        tokenTypes[_id].supplyLock = false;
        tokenTypes[_id].creator = msg.sender;
        transferOwnership(_owner);
    }

    function uri(uint256 _id)
        public
        view                
        override
        returns (string memory)
    {

        require(tokenTypes[_id].creator != address(0), "Token does not exists");
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, _id.toString()))
                : baseURI;
    }

    function setURI(string memory _uri) external onlyOwner {

        baseURI = _uri;
    }

    function totalSupply(
        uint256 _id
    ) public view returns (uint256) {

        return tokenTypes[_id].totalSupply;
    }

    function maxSupply(
        uint256 _id
    ) public view returns (uint24) {

        return tokenTypes[_id].maxSupply;
    }

    function preSalePrice(
        uint256 _id
    ) public view returns (uint72) {

        return tokenTypes[_id].preSalePrice;
    }

    function pubSalePrice(
        uint256 _id
    ) public view returns (uint72) {

        return tokenTypes[_id].pubSalePrice;
    }

    function maxPerWallet(
        uint256 _id
    ) public view returns (uint24) {

        return tokenTypes[_id].maxPerWallet;
    }

    function maxPerTransaction(
        uint256 _id
    ) public view returns (uint24) {

        return tokenTypes[_id].maxPerTransaction;
    }

    function preSaleIsActive(
        uint256 _id
    ) public view returns (bool) {

        return tokenTypes[_id].preSaleIsActive;
    }

    function supplyLock(
        uint256 _id
    ) public view returns (bool) {

        return tokenTypes[_id].supplyLock;
    }

    function saleIsActive(
        uint256 _id
    ) public view returns (bool) {

        return tokenTypes[_id].saleIsActive;
    }

    function setMaxSupply(uint256 _id, uint24 _supply) public onlyOwner {

        require(!tokenTypes[_id].supplyLock, "Supply is locked.");
       tokenTypes[_id].maxSupply = _supply;
    }

    function lockSupply(uint256 _id) public onlyOwner {

        tokenTypes[_id].supplyLock = true;
    }

    function setPreSalePrice(uint256 _id, uint72 _price) public onlyOwner {

        tokenTypes[_id].preSalePrice = _price;
    }

    function setPublicSalePrice(uint256 _id, uint72 _price) public onlyOwner {

        tokenTypes[_id].pubSalePrice = _price;
    }

    function setMaxPerWallet(uint256 _id, uint24 _quantity) public onlyOwner {

        tokenTypes[_id].maxPerWallet = _quantity;
    }

    function setMaxPerTransaction(uint256 _id, uint24 _quantity) public onlyOwner {

        tokenTypes[_id].maxPerTransaction = _quantity;
    }

    function setRoot(uint256 _id, bytes32 _root) public onlyOwner {

        tokenTypes[_id].merkleRoot = _root;
    }

    function setSaleState(uint256 _id, bool _isActive) public onlyOwner {

        tokenTypes[_id].saleIsActive = _isActive;
    }

    function setPreSaleState(uint256 _id, bool _isActive) public onlyOwner {

        require(tokenTypes[_id].merkleRoot != "", "Merkle root is undefined.");
        tokenTypes[_id].preSaleIsActive = _isActive;
    }

    function verify(uint256 _id, bytes32 leaf, bytes32[] memory proof) public view returns (bool) {

        bytes32 computedHash = leaf;
        for (uint i = 0; i < proof.length; i++) {
          bytes32 proofElement = proof[i];
          if (computedHash <= proofElement) {
            computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
          } else {
            computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
          }
        }
        return computedHash == tokenTypes[_id].merkleRoot;
    }

    function createType(
        uint256 _id,
        uint24 _maxSupply,
        uint24 _maxPerWallet,
        uint24 _maxPerTransaction,
        uint72 _preSalePrice,
        uint72 _pubSalePrice
    ) public onlyOwner {

        require(tokenTypes[_id].creator == address(0), "token _id already exists");
        tokenTypes[_id].maxSupply = _maxSupply;
        tokenTypes[_id].maxPerWallet = _maxPerWallet;
        tokenTypes[_id].maxPerTransaction = _maxPerTransaction;
        tokenTypes[_id].preSalePrice = _preSalePrice;
        tokenTypes[_id].pubSalePrice = _pubSalePrice;
        tokenTypes[_id].totalSupply = 0;
        tokenTypes[_id].saleIsActive = false;
        tokenTypes[_id].preSaleIsActive = false;
        tokenTypes[_id].supplyLock = false;
        tokenTypes[_id].creator = msg.sender;
    }

    function mint(
        uint256 _id,
        bytes memory _data,
        uint256 _quantity,
        bytes32[] memory proof
    ) public payable nonReentrant {

        uint _maxPerWallet = tokenTypes[_id].maxPerWallet;
        uint256 _currentSupply = tokenTypes[_id].totalSupply;
        require(tokenTypes[_id].saleIsActive, "Sale is not active.");
        require(_currentSupply + _quantity <= tokenTypes[_id].maxSupply, "Requested quantity would exceed total supply.");
        if(tokenTypes[_id].preSaleIsActive) {
            require(tokenTypes[_id].preSalePrice * _quantity <= msg.value, "ETH sent is incorrect.");
            require(_quantity <= _maxPerWallet, "Exceeds wallet presale limit.");
            uint256 mintedAmount = hasMinted[_id][msg.sender] + _quantity;
            require(mintedAmount <= _maxPerWallet, "Exceeds per wallet presale limit.");
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _id));
            require(verify(_id, leaf, proof), "You are not whitelisted.");
            hasMinted[_id][msg.sender] = mintedAmount;
        } else {
            require(tokenTypes[_id].pubSalePrice * _quantity <= msg.value, "ETH sent is incorrect.");
            require(_quantity <= tokenTypes[_id].maxPerTransaction, "Exceeds per transaction limit for public sale.");
        }
        _mint(msg.sender, _id, _quantity, _data);
        tokenTypes[_id].totalSupply = _currentSupply + _quantity;
    }

    function reserve(uint256 _id, bytes memory _data, address _address, uint256 _quantity) public onlyOwner nonReentrant {

        uint256 _currentSupply = tokenTypes[_id].totalSupply;
        require(_currentSupply + _quantity <= tokenTypes[_id].maxSupply, "Requested quantity would exceed total supply.");
        tokenTypes[_id].totalSupply = _currentSupply + _quantity;
        _mint(_address, _id, _quantity, _data);
    }
}// MIT

pragma solidity ^0.8.9;


abstract contract LaunchPass {
    function balanceOf(address owner)
        public
        view
        virtual
        returns (uint256 balance);
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        returns (address);
}

contract ERC1155Factory is Ownable {


    struct Referrer {
        address payee;
        uint256 share;
    }

    mapping(uint256 => address) public deployments;
    mapping(uint256 => Referrer) public referrers;
    address payable public treasuryAddress;
    address public launchpassAddress;
    uint256 public treasuryShare;
    ERC1155Contract[] public nfts;
    address[] payees;
    uint256[] shares;

    constructor(address payable _treasuryAddress, address _launchpassAddress, uint256 _treasuryShare) {
        treasuryAddress = _treasuryAddress;
        launchpassAddress = _launchpassAddress;
        treasuryShare = _treasuryShare;
    }

    function addReferrer(uint256 _launchpassId, uint256 _share, address _address) public onlyOwner {

        require(referrers[_launchpassId].payee == address(0), "Referrer already exists.");
        referrers[_launchpassId].payee = _address;
        referrers[_launchpassId].share = _share;
    }

    function updateReferrer(uint256 _launchpassId, uint256 _share, address _address) public onlyOwner {

        require(referrers[_launchpassId].payee != address(0), "Referrer does not exist.");
        referrers[_launchpassId].payee = _address;
        referrers[_launchpassId].share = _share;
    }

    function removeReferrer(uint256 _launchpassId) public onlyOwner {

        require(referrers[_launchpassId].payee != address(0), "Referrer does not exist.");
        delete referrers[_launchpassId];
    }

    function setTreasuryShare(uint256 _treasuryShare) public onlyOwner {

        treasuryShare = _treasuryShare;
    }

    function setLaunchPassAddress(address _launchpassAddress) public onlyOwner {

        launchpassAddress = _launchpassAddress;
    }

    function setTreasuryAddress(address payable _treasuryAddress) public onlyOwner {

        treasuryAddress = _treasuryAddress;
    }

    function getDeployedNFTs() public view returns (ERC1155Contract[] memory) {

        return nfts;
    }

    function deploy(
        address[] memory _payees,
        uint256[] memory _shares,
        ERC1155Contract.InitialParameters memory initialParameters
    ) public {

        require(_payees.length == _shares.length,  "Shares and payees must have the same length.");
        payees = _payees;
        shares = _shares;
        if (referrers[initialParameters.launchpassId].payee != address(0)) {
            payees.push(referrers[initialParameters.launchpassId].payee);
            shares.push(referrers[initialParameters.launchpassId].share);
            payees.push(treasuryAddress);
            shares.push(treasuryShare - referrers[initialParameters.launchpassId].share);
        } else {
            payees.push(treasuryAddress);
            shares.push(treasuryShare);
        }
        uint256 totalShares = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            totalShares = totalShares + shares[i];
        }
        require(totalShares == 100,  "Sum of shares must equal 100.");
        LaunchPass launchpass = LaunchPass(launchpassAddress);
        require(launchpass.balanceOf(msg.sender) > 0,  "You do not have a LaunchPass.");
        require(launchpass.ownerOf(initialParameters.launchpassId) == msg.sender,  "You do not own this LaunchPass.");
        ERC1155Contract nft = new ERC1155Contract(payees, shares, msg.sender, initialParameters);
        deployments[initialParameters.launchpassId] = address(nft);
        nfts.push(nft);
        payees = new address[](0);
        shares = new uint256[](0);
    }

}