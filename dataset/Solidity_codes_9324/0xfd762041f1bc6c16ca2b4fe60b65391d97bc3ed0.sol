
pragma solidity ^0.8.0;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC777Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}// MIT

pragma solidity ^0.8.0;

interface IERC777RecipientUpgradeable {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC777SenderUpgradeable {

    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC1820RegistryUpgradeable {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;


    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}// MIT

pragma solidity ^0.8.0;


contract ERC777Upgradeable is Initializable, ContextUpgradeable, IERC777Upgradeable, IERC20Upgradeable {

    using AddressUpgradeable for address;

    IERC1820RegistryUpgradeable internal constant _ERC1820_REGISTRY = IERC1820RegistryUpgradeable(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    address[] private _defaultOperatorsArray;

    mapping(address => bool) private _defaultOperators;

    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    mapping(address => mapping(address => uint256)) private _allowances;

    function __ERC777_init(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) internal onlyInitializing {

        __Context_init_unchained();
        __ERC777_init_unchained(name_, symbol_, defaultOperators_);
    }

    function __ERC777_init_unchained(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;

        _defaultOperatorsArray = defaultOperators_;
        for (uint256 i = 0; i < defaultOperators_.length; i++) {
            _defaultOperators[defaultOperators_[i]] = true;
        }

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public pure virtual returns (uint8) {

        return 18;
    }

    function granularity() public view virtual override returns (uint256) {

        return 1;
    }

    function totalSupply() public view virtual override(IERC20Upgradeable, IERC777Upgradeable) returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address tokenHolder) public view virtual override(IERC20Upgradeable, IERC777Upgradeable) returns (uint256) {

        return _balances[tokenHolder];
    }

    function send(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        _send(_msgSender(), recipient, amount, data, "", true);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = _msgSender();

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    function burn(uint256 amount, bytes memory data) public virtual override {

        _burn(_msgSender(), amount, data, "");
    }

    function isOperatorFor(address operator, address tokenHolder) public view virtual override returns (bool) {

        return
            operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

    function authorizeOperator(address operator) public virtual override {

        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

    function revokeOperator(address operator) public virtual override {

        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

    function defaultOperators() public view virtual override returns (address[] memory) {

        return _defaultOperatorsArray;
    }

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {

        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(sender, recipient, amount, data, operatorData, true);
    }

    function operatorBurn(
        address account,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {

        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(account, amount, data, operatorData);
    }

    function allowance(address holder, address spender) public view virtual override returns (uint256) {

        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 value) public virtual override returns (bool) {

        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = _msgSender();

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");

        uint256 currentAllowance = _allowances[holder][spender];
        require(currentAllowance >= amount, "ERC777: transfer amount exceeds allowance");
        _approve(holder, spender, currentAllowance - amount);

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) internal virtual {

        _mint(account, amount, userData, operatorData, true);
    }

    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {

        require(account != address(0), "ERC777: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, requireReceptionAck);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {

        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    function _burn(
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal virtual {

        require(from != address(0), "ERC777: burn from the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        _beforeTokenTransfer(operator, from, address(0), amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC777: burn amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _totalSupply -= amount;

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {

        _beforeTokenTransfer(operator, from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC777: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _approve(
        address holder,
        address spender,
        uint256 value
    ) internal {

        require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {

        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777SenderUpgradeable(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) private {

        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777RecipientUpgradeable(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    uint256[41] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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

        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Upgradeable.ownerOf(tokenId);

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

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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

    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721URIStorage_init_unchained();
    }

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {
    }
    using StringsUpgradeable for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;

library SignedSafeMath {

    function mul(int256 a, int256 b) internal pure returns (int256) {

        return a * b;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        return a + b;
    }
}// contracts/Pool0.sol
pragma solidity ^0.8.4;


contract PropToken0 is Initializable, ERC721URIStorageUpgradeable {

    using SignedSafeMath for int256;
    using SafeMath for uint256;

    struct Lien{
        uint256 lienIndex;
        uint256 lienValue;
        uint256[] seniorLienValues;
        uint256 propValue;
        string propAddress;
        uint256 issuedAtTimestamp;
    }

    uint256 lienCount;
    address[] servicerAddresses;
    address[] poolAddresses;
    mapping(uint256 => Lien) lienData;



    function initialize(string memory name, string memory symbol, address _poolAddress, address approvedServicer) public initializer {

        servicerAddresses.push(approvedServicer);
        poolAddresses.push(_poolAddress);
        ERC721Upgradeable.__ERC721_init(name, symbol);

        lienCount = 0;
    }


    function isApprovedServicer(address _address) internal view returns (bool) {

        bool isApproved = false;
        
        for (uint i = 0; i < servicerAddresses.length; i++) {
            if(_address == servicerAddresses[i]) {
                isApproved = true;
            }
        }

        return isApproved;
    }

    function getLienValue(uint256 lienId) public view returns (uint256) {

        return lienData[lienId].lienValue;
    }

    function getPropTokenCount() public view returns (uint256) {

        return lienCount;
    }

    function getPoolAddresses() public view returns (address[] memory) {

        return poolAddresses;
    }

    function getPropTokenData(uint256 propTokenID) public view returns (address, uint256, uint256[] memory, uint256, string memory, uint256, string memory) {

        Lien memory propToken = lienData[propTokenID];
        return(
          ownerOf(propTokenID),
          propToken.lienValue,
          propToken.seniorLienValues,
          propToken.propValue,
          propToken.propAddress,
          propToken.issuedAtTimestamp,
          tokenURI(propTokenID)
        );
    }


    function mintPropToken(
        address to,
        uint256 lienValue,
        uint256[] memory seniorLienValues,
        uint256 propValue,
        string memory propAddress,
        string memory propPhotoURI
        ) public {

        require(isApprovedServicer(msg.sender));

        Lien memory newLien = Lien(lienCount, lienValue, seniorLienValues, propValue, propAddress, block.timestamp);

        _safeMint(to, lienCount);
        _setTokenURI(lienCount, propPhotoURI);

        lienData[lienCount] = newLien;
        lienCount = lienCount + 1;
    }

}// MIT
pragma solidity ^0.8.4;

contract LTVGuidelines {

    uint256 maxLoanToValue;

    constructor() {                  
        maxLoanToValue = 80;        
    } 
 
    function getMaxLTV() public view returns (uint256) {        

        return maxLoanToValue;        
    } 
}// contracts/Pool0.sol
pragma solidity ^0.8.4;


contract BaconCoin0 is Initializable, ERC777Upgradeable {

    using SignedSafeMath for int256;
    using SafeMath for uint256;

    address stakingContract;
    address airdropContract;

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => address) public delegates;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    mapping (address => uint) public nonces;

    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);


    function initialize(string memory name, string memory symbol, address _stakingContractAddress, address _airdropContractAddress) public initializer {

        stakingContract = _stakingContractAddress;
        airdropContract = _airdropContractAddress;
        address[] memory operators;
        ERC777Upgradeable.__ERC777_init(name, symbol, operators );
    }

    function transfer(address dst, uint amount) public override returns (bool) {

        require(super.transfer(dst, amount));
        _moveDelegates(delegates[msg.sender], delegates[dst], amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) public override returns (bool) {

        require(super.transferFrom(src, dst, amount));
        _moveDelegates(delegates[src], delegates[dst], amount);
        return true;
    }

    function mint(address account, uint256 amount) public {

        require(msg.sender == stakingContract || msg.sender == airdropContract, "Invalid mint sender");
        super._mint(account, amount, "", "");
        _moveDelegates(address(0), account, amount);
    }

    function version() public pure returns (uint) {

        return 0;
    }
    
    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint) {

        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }


    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "BaconCoin: invalid signature");
        require(nonce == nonces[signatory]++, "BaconCoin: invalid nonce");
        require(block.timestamp <= expiry, "BaconCoin: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber) public view returns (uint256) {

        require(blockNumber < block.number, "BaconCoin: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {

      uint32 blockNumber = safe32(block.number, "BaconCoin: block number exceeds 32 bits");

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.4;




contract PoolStaking0 is Initializable {

    using SignedSafeMath for int256;
    using SafeMath for uint256;

    uint256 constant PER_BLOCK_DECAY = 9999997757;
    uint256 constant PER_BLOCK_DECAY_18_DECIMALS = 999999775700000000;
    uint256 constant PER_BLOCK_DECAY_INVERSE = 10000002243;
    uint256 constant GUARDIAN_REWARD = 3900000000000000000;
    uint256 constant DAO_REWARD = 18000000000000000000;
    uint256 constant COMMUNITY_REWARD = 50000000000000000000;
    uint256 constant COMMUNITY_REWARD_BONUS = 100000000000000000000;

    uint256 stakeAfterBlock;
    address guardianAddress;
    address daoAddress;
    address baconCoinAddress;
    address[] poolAddresses;

    uint256[] updateEventBlockNumber;
    uint256[] updateEventNewAmountStaked;
    uint256 updateEventCount;
    uint256 currentStakedAmount;

    mapping(address => uint256) userStaked;
    mapping(address => uint256) userLastDistribution;

    uint256 oneYearBlock;


    function initialize(address _poolAddress, address _guardianAddress, uint256 startingBlock, uint _stakeAfterBlock, uint256 _oneYearBlock) public initializer {

        guardianAddress = _guardianAddress;
        poolAddresses.push(_poolAddress);

        updateEventCount = 0;
        currentStakedAmount = 0;

        userLastDistribution[guardianAddress] = startingBlock;
        userLastDistribution[daoAddress] = startingBlock;
        stakeAfterBlock = _stakeAfterBlock;
        oneYearBlock = _oneYearBlock;
    }

    function setOneYearBlock(uint256 _oneYearBlock) public {

        require(msg.sender == guardianAddress, "unapproved sender");
        oneYearBlock = _oneYearBlock;
    }

    function setstakeAfterBlock(uint256 _stakeAfterBlock) public {

        require(msg.sender == guardianAddress, "unapproved sender");
        stakeAfterBlock = _stakeAfterBlock;
    }

    function setBaconAddress(address _baconCoinAddress) public {

        require(msg.sender == guardianAddress, "unapproved sender");
        baconCoinAddress = _baconCoinAddress;
    }

    function setDAOAddress(address _DAOAddress) public {

        require(msg.sender == guardianAddress, "unapproved sender");
        daoAddress = _DAOAddress;
    }

    function version() public pure returns (uint) {

        return 0;
    }

    function getContractInfo() public view returns (uint256, uint256, address, address, address, address  [] memory, uint256, uint256) {

        return (
            stakeAfterBlock,
            oneYearBlock,
            guardianAddress,
            daoAddress,
            baconCoinAddress,
            poolAddresses,
            updateEventCount,
            currentStakedAmount
        );
    }

    function isApprovedPool(address _address) internal view returns (bool) {

        bool isApproved = false;
        
        for (uint i = 0; i < poolAddresses.length; i++) {
            if(_address == poolAddresses[i]) {
                isApproved = true;
            }
        }

        return isApproved;
    }


    function stake(address wallet, uint256 amount) public returns (bool) {

        require(isApprovedPool(msg.sender), "sender not Pool");

        return stakeInternal(wallet, amount);
    }

    
    function stakeInternal(address wallet, uint256 amount) internal returns (bool) {

        if(userStaked[wallet] != 0 || wallet == guardianAddress || wallet == daoAddress) {
            distribute(wallet);
        } else {
            userLastDistribution[wallet] = block.number;
        }

        userStaked[wallet] = userStaked[wallet].add(amount);
        currentStakedAmount = currentStakedAmount.add(amount);
        updateEventBlockNumber.push(block.number);
        updateEventNewAmountStaked.push(currentStakedAmount);
        updateEventCount = updateEventCount.add(1);

        return true;
    }

    function decayExponent(uint256 exponent) internal pure returns (uint256) {

        uint256 answer = PER_BLOCK_DECAY;
        for (uint256 i = 0; i < exponent; i++) {
            answer = answer.mul(10000000000).div(PER_BLOCK_DECAY_INVERSE);
        }

        return answer;
    }

    function calcBaconBetweenEvents(uint256 blockX, uint256 blockY) internal view returns (uint256) {



        blockX = blockX.sub(oneYearBlock);
        blockY = blockY.sub(oneYearBlock);

        uint256 SyNumer = decayExponent(blockY).mul(50);
        uint256 SxNumer = decayExponent(blockX).mul(50);
        uint256 denom = uint256(1000000000000000000).sub(PER_BLOCK_DECAY_18_DECIMALS);

        uint256 Sy = SyNumer.mul(1000000000000000000).div(denom);
        uint256 Sx = SxNumer.mul(1000000000000000000).div(denom);

        return Sy.sub(Sx);
    }


    function distribute(address wallet) public returns (uint256) {


        if (userStaked[wallet] == 0 && wallet != guardianAddress && wallet != daoAddress) {
            return 0;
        }

        uint256 accruedBacon = 0;
        uint256 countingBlock = userLastDistribution[wallet];

        uint256 blockDifference = 0;
        uint256 tempAccruedBacon = 0;

        if(wallet == daoAddress) {
            blockDifference = block.number - countingBlock;
            tempAccruedBacon = blockDifference.mul(DAO_REWARD);
            accruedBacon += tempAccruedBacon;
        } else if (wallet == guardianAddress) {
            blockDifference = block.number - countingBlock;
            accruedBacon = blockDifference.mul(GUARDIAN_REWARD);
            accruedBacon += tempAccruedBacon;
        } else if (countingBlock < stakeAfterBlock) {
            countingBlock = stakeAfterBlock;
        }

        if (userStaked[wallet] != 0) {
            for (uint256 i = 0; i < updateEventCount; i++) {
                if (updateEventBlockNumber[i] > countingBlock) {
                    blockDifference = updateEventBlockNumber[i] - countingBlock;
                    
                    if(updateEventBlockNumber[i] < oneYearBlock) {
                        tempAccruedBacon = blockDifference.mul(COMMUNITY_REWARD_BONUS).mul(userStaked[wallet]).div(updateEventNewAmountStaked[i-1]);
                    } else {
                        if(countingBlock < oneYearBlock) {
                            uint256 blocksLeftInFirstYear = oneYearBlock - countingBlock;
                            tempAccruedBacon = blocksLeftInFirstYear.mul(COMMUNITY_REWARD_BONUS).mul(userStaked[wallet]).div(updateEventNewAmountStaked[i-1]);

                            accruedBacon = accruedBacon.add(tempAccruedBacon);
                            countingBlock = oneYearBlock;
                        }
                        
                        uint256 baconBetweenBlocks = calcBaconBetweenEvents(countingBlock, updateEventBlockNumber[i]);
                        tempAccruedBacon = baconBetweenBlocks.mul(userStaked[wallet]).div(updateEventNewAmountStaked[i-1]);
                    }
                    
                    accruedBacon = accruedBacon.add(tempAccruedBacon);
                    countingBlock = updateEventBlockNumber[i];
                }

            }// end updateEvent for loop


            if(countingBlock != block.number && countingBlock < block.number) {
                if(countingBlock < oneYearBlock  && block.number < oneYearBlock) {
                    blockDifference = block.number - countingBlock;
                    tempAccruedBacon = blockDifference.mul(COMMUNITY_REWARD_BONUS).mul(userStaked[wallet]).div(currentStakedAmount);
                } else {
                    if (countingBlock < oneYearBlock  && block.number > oneYearBlock) {
                        uint256 blocksLeftInFirstYear = oneYearBlock - countingBlock;
                        tempAccruedBacon = blocksLeftInFirstYear.mul(COMMUNITY_REWARD_BONUS).mul(userStaked[wallet]).div(updateEventNewAmountStaked[updateEventCount-1]);

                        accruedBacon = accruedBacon.add(tempAccruedBacon);
                        countingBlock = oneYearBlock;
                    } 

                    uint256 baconBetweenBlocks = calcBaconBetweenEvents(countingBlock, block.number);
                    tempAccruedBacon = baconBetweenBlocks.mul(userStaked[wallet]).div(updateEventNewAmountStaked[updateEventCount-1]);
                }

                accruedBacon = accruedBacon.add(tempAccruedBacon);
            }
        }

        userLastDistribution[wallet] = block.number;
        BaconCoin0(baconCoinAddress).mint(wallet, accruedBacon);

        return accruedBacon;
    }


    function checkStaked(address wallet) public view returns (uint256) {

        return userStaked[wallet];
    }

    function withdraw(uint256 amount) public returns (uint256) {

        require(userStaked[msg.sender] >= amount, "not enough staked");

        uint256 distributed = distribute(msg.sender);

        uint256 stakedDiff = userStaked[msg.sender].sub(amount);
        currentStakedAmount = currentStakedAmount.sub(userStaked[msg.sender]);
        userStaked[msg.sender] = 0;

        if(stakedDiff > 0) {
            stakeInternal(msg.sender, stakedDiff);
        } else {
            updateEventBlockNumber.push(block.number);
            updateEventNewAmountStaked.push(currentStakedAmount);
            updateEventCount = updateEventCount.add(1);
        }

        IERC777Upgradeable(poolAddresses[0]).send(msg.sender, amount, "");

        return distributed;

    }

    function getEvents() public view returns (uint256  [] memory, uint256  [] memory) {

        return (updateEventBlockNumber, updateEventNewAmountStaked);
    }

}// contracts/Pool4.sol
pragma solidity ^0.8.4;



contract Pool4 is Initializable, ERC777Upgradeable, IERC721ReceiverUpgradeable {

    using SignedSafeMath for int256;
    using SafeMath for uint256;

    struct Loan{
        uint256 loanId;
        address borrower;
        uint256 interestRate;
        uint256 principal;
        uint256 interestAccrued;
        uint256 timeLastPayment;
    }

    address servicer;
    address ERCAddress;
    address[] servicerAddresses;

    uint256 poolLent;
    uint256 poolBorrowed;
    mapping(address => uint256[]) userLoans;
    Loan[] loans;
    uint256 loanCount;

    uint constant servicerFeePercentage = 1000000;
    uint constant baseInterestPercentage = 1000000;
    uint constant curveK = 120000000;

    string private _name;
    string private _symbol;
    mapping(uint256 => uint256) loanToPropToken;
    address propTokenContractAddress;

    address LTVOracleAddress;

    address poolUtilsAddress;
    address baconCoinAddress;
    address poolStakingAddress;



    function initializePoolFour(address _poolUtilsAddress, address _baconCoinAddress, address _poolStakingAddress) public {

        require(msg.sender == servicer);
        poolUtilsAddress = _poolUtilsAddress;
        baconCoinAddress = _baconCoinAddress;
        poolStakingAddress = _poolStakingAddress;
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns(string memory) {

        return _symbol;
    }

    function decimals() public pure override returns(uint8) {

        return 6;
    }
    
    function setApprovedAddresses(address[] memory _servicerAddresses) public {

        require(msg.sender == servicer);

        servicerAddresses = _servicerAddresses;
    }

    function isApprovedServicer(address _address) internal view returns (bool) {

        bool isApproved = false;
        
        for (uint i = 0; i < servicerAddresses.length; i++) {
            if(_address == servicerAddresses[i]) {
                isApproved = true;
            }
        }

        return isApproved;
    }

    function getContractData() public view returns (address, address, uint256, uint256, uint256, uint256) {

        return (servicer, ERCAddress, poolLent, (poolLent + PoolUtils0(poolUtilsAddress).getPoolInterestAccrued()), poolBorrowed, loanCount);
    }

    function getLoanCount() public view returns (uint256) {

        return loanCount;
    }

    function getSupplyableTokenAddress() public view returns (address) {

        return ERCAddress;
    }

    function getServicerAddress() public view returns (address) {

        return servicer;
    } 

    function getLoanDetails(uint256 loanId) public view returns (uint256, address, uint256, uint256, uint256, uint256, uint256) {

        Loan memory loan = loans[loanId];
        uint256 interestAccrued = getLoanAccruedInterest(loanId);
        uint256 propTokenID = loanToPropToken[loanId];
        return (loan.loanId, loan.borrower, loan.interestRate, loan.principal, interestAccrued, loan.timeLastPayment, propTokenID);
    }

    function getLoanAccruedInterest(uint256 loanId) public view returns (uint256) {

        Loan memory loan = loans[loanId];
        uint256 secondsSincePayment = block.timestamp.sub(loan.timeLastPayment);

        uint256 interestPerSecond = loan.principal.mul(loan.interestRate).div(31622400);
        uint256 interestAccrued = interestPerSecond.mul(secondsSincePayment).div(100000000);
        return interestAccrued.add(loan.interestAccrued);
    }   



    function mintProportionalPoolTokens(address recepient, uint256 amount) private returns (uint256) {

        if (poolLent == 0) {
            super._mint(recepient, amount, "", "");
            return amount;
        } else {
            uint256 new_hc_pool = amount.mul(super.totalSupply()).div(poolLent);
            super._mint(recepient, new_hc_pool, "", "");
            return new_hc_pool;
        }
    }

    function lend(
        uint256 amount
    ) public returns (uint256) {

        IERC20Upgradeable(ERCAddress).transferFrom(msg.sender, address(this), amount);
        uint256 newTokensMinted = mintProportionalPoolTokens(msg.sender, amount);
        poolLent = poolLent.add(amount);

        return newTokensMinted;
    }

    function redeem(
        uint256 amount
    ) public {

        require(balanceOf(msg.sender) >= amount);

        uint256 tokenPrice = poolLent.mul(1000000).div(super.totalSupply());
        uint256 erc20ValueOfTokens = amount.mul(tokenPrice).div(1000000);
        require(erc20ValueOfTokens <= (poolLent - poolBorrowed));

        super._burn(msg.sender, amount, "", "");
        poolLent = poolLent.sub(erc20ValueOfTokens);
        IERC20Upgradeable(ERCAddress).transfer(msg.sender, erc20ValueOfTokens);
    }

    function borrow(uint256 amount, uint256 maxRate, uint256 propTokenId) public {

        require(PropToken0(propTokenContractAddress).getApproved(propTokenId) == address(this), "pool not approved to move egg");
        require(PropToken0(propTokenContractAddress).ownerOf(propTokenId) == msg.sender, "msg.sender not egg owner");

        uint256 fixedInterestRate = uint256(PoolUtils0(poolUtilsAddress).getInterestRate(amount));
        require(fixedInterestRate <= maxRate, "interest rate no longer avail");

        uint256 lienAmount = PropToken0(propTokenContractAddress).getLienValue(propTokenId);
        require(lienAmount >= amount, "loan larger that egg value");

        uint256 LTVRequirement = LTVGuidelines(LTVOracleAddress).getMaxLTV();
        (, , uint256[] memory SeniorLiens, uint256 HomeValue, , ,) = PropToken0(propTokenContractAddress).getPropTokenData(propTokenId);
        for (uint i = 0; i < SeniorLiens.length; i++) {  
            lienAmount = lienAmount.add(SeniorLiens[i]);
        }
        require(lienAmount.mul(100).div(HomeValue) < LTVRequirement, "LTV too high");


        PropToken0(propTokenContractAddress).safeTransferFrom(msg.sender, address(this), propTokenId);

        Loan memory newLoan = Loan(loanCount, msg.sender, fixedInterestRate, amount, 0, block.timestamp);
        loans.push(newLoan);
        userLoans[msg.sender].push(loanCount);

        loanToPropToken[loanCount] = propTokenId;

        loanCount = loanCount.add(1);
        poolBorrowed = poolBorrowed.add(amount);

        IERC20Upgradeable(ERCAddress).transfer(msg.sender, amount);

        mintProportionalPoolTokens(servicer, amount.div(100));
    }
    

    function repay(uint256 loanId, uint256 amount) public {        

        uint256 interestAmountRepayed = amount;

        uint256 currentInterest = getLoanAccruedInterest(loanId);
        if(currentInterest > amount) {
            IERC20Upgradeable(ERCAddress).transferFrom(msg.sender, address(this), amount);
            loans[loanId].interestAccrued = currentInterest.sub(amount);
        } else {
            interestAmountRepayed = currentInterest;
            uint256 amountAfterInterest = amount.sub(currentInterest);
            
            if(loans[loanId].principal > amountAfterInterest) {
                IERC20Upgradeable(ERCAddress).transferFrom(msg.sender, address(this), amount);
                poolBorrowed = poolBorrowed.sub(amountAfterInterest);
                loans[loanId].principal = loans[loanId].principal.sub(amountAfterInterest);
            } else {
                uint256 totalLoanValue = loans[loanId].principal.add(currentInterest);
                IERC20Upgradeable(ERCAddress).transferFrom(msg.sender, address(this), totalLoanValue);
                poolBorrowed = poolBorrowed.sub(loans[loanId].principal);
                loans[loanId].principal = 0;
                PropToken0(propTokenContractAddress).safeTransferFrom(address(this), loans[loanId].borrower, loanToPropToken[loanId]);
            }

            loans[loanId].interestAccrued = 0;
        }

        loans[loanId].timeLastPayment = block.timestamp;

        poolLent = poolLent.add(interestAmountRepayed);

        uint256 servicerFeeInERC = servicerFeePercentage.mul(interestAmountRepayed).div(loans[loanId].interestRate);
        mintProportionalPoolTokens(servicer, servicerFeeInERC);
    }


    function stake(uint256 amount) public returns (bool) {

        require(balanceOf(msg.sender) >= amount, "not enough to stake");

        bool successfulStake = PoolStaking0(poolStakingAddress).stake(msg.sender, amount);
        if(successfulStake) {
            transfer(poolStakingAddress, amount);
        }

        return successfulStake;
    }

    function lendAndStake(uint256 amount) public returns (bool) {

        uint256 newPoolTokens = lend(amount);
        return stake(newPoolTokens);
    }

    function getVersion() public pure returns (uint) {

        return 4;
    }

    function onERC721Received(address, address, uint256, bytes memory ) public pure override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// contracts/PoolUtils0.sol
pragma solidity ^0.8.4;



contract PoolUtils0 is Initializable {

    using SignedSafeMath for int256;
    using SafeMath for uint256;

    uint constant servicerFeePercentage = 1000000;
    uint constant baseInterestPercentage = 0;
    uint constant curveK = 200000000;

    address poolCore;

    function initialize(address _poolCore) public initializer {

        poolCore = _poolCore;
    }




    function getAverageInterest() public view returns (uint256) {

        uint256 sumOfRates = 0;
        uint256 borrowedCounter = 0;
        
        uint256 interestRate = 0;
        uint256 principal = 0;
        uint256 loanCount = 0;

        (, , , , , loanCount) = Pool4(poolCore).getContractData();

        for (uint i = 0; i < loanCount; i++) {

            (, , interestRate, principal, , , ) = Pool4(poolCore).getLoanDetails(i);
            if(principal != 0){
                sumOfRates = sumOfRates.add(interestRate.mul(principal));
                borrowedCounter = borrowedCounter.add(principal);
            }
        }

       return sumOfRates.div(borrowedCounter);
    }

    function getActiveLoans() public view returns (bool[] memory) {

        uint256 principal = 0;
        uint256 loanCount = 0;

        (, , , , , loanCount) = Pool4(poolCore).getContractData();
        bool[] memory loanActive = new bool[](loanCount);

        for (uint i = 0; i < loanCount; i++) {
            (, , , principal, , , ) = Pool4(poolCore).getLoanDetails(i);

            if(principal != 0) {
                loanActive[i] = true;
            } else {
                loanActive[i] = false;
            }
        }

        return loanActive;
    }


    function getPoolInterestAccrued() public view returns (uint256) {

        uint256 totalInterest = 0;
        uint256 loanCount = Pool4(poolCore).getLoanCount();


        for (uint i=0; i<loanCount; i++) {
            uint256 accruedInterest = Pool4(poolCore).getLoanAccruedInterest(i);
            totalInterest = totalInterest.add(accruedInterest);
        }

        return totalInterest;
    }

    function getInterestRate(uint256 amount) public view returns (int256) {


        uint256 poolBorrowed = 0;
        uint256 poolLent = 0;
        (, , poolLent, , poolBorrowed, ) = Pool4(poolCore).getContractData();
        
        require(amount < (poolLent - poolBorrowed));

        int256 newUtilizationRatio = int256(poolBorrowed).add(int256(amount)).mul(100000000).div(int256(poolLent));

        int256 numerator = newUtilizationRatio.sub(int256(curveK));  
        int256 denominator = newUtilizationRatio.sub(100000000);
        int256 interest = numerator.mul(1000000).div(denominator);
        interest = interest.sub(int256(curveK).div(100)).add(int256(servicerFeePercentage)).add(int256(baseInterestPercentage)); 
        
        return interest;
    }

 
}// contracts/Pool.sol
pragma solidity ^0.8.4;



contract Pool8 is Initializable, ERC777Upgradeable, IERC721ReceiverUpgradeable {

    using SignedSafeMath for int256;
    using SafeMath for uint256;

    struct Loan{
        uint256 loanId;
        address borrower;
        uint256 interestRate;
        uint256 principal;
        uint256 interestAccrued;
        uint256 timeLastPayment;
    }

    address servicer;
    address ERCAddress;
    address[] servicerAddresses;

    uint256 poolLent;
    uint256 poolBorrowed;
    mapping(address => uint256[]) userLoans;
    Loan[] loans;
    uint256 loanCount;

    uint constant servicerFeePercentage = 1000000;
    uint constant baseInterestPercentage = 1000000;
    uint constant curveK = 120000000;

    string private _name;
    string private _symbol;
    mapping(uint256 => uint256) loanToPropToken;
    address propTokenContractAddress;

    address LTVOracleAddress;

    address poolUtilsAddress;
    address baconCoinAddress;
    address poolStakingAddress;

    address daoAddress;



    function initializePoolEight(address _daoAddress) public {

        require(msg.sender == servicer);
        daoAddress = _daoAddress;
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns(string memory) {

        return _symbol;
    }

    function decimals() public pure override returns(uint8) {

        return 6;
    }
    
    function setApprovedAddresses(address[] memory _servicerAddresses) public {

        require(msg.sender == servicer);

        servicerAddresses = _servicerAddresses;
    }

    function isApprovedServicer(address _address) internal view returns (bool) {

        bool isApproved = false;
        
        for (uint i = 0; i < servicerAddresses.length; i++) {
            if(_address == servicerAddresses[i]) {
                isApproved = true;
            }
        }

        return isApproved;
    }

    function getContractData() public view returns (address, address, uint256, uint256, uint256, uint256) {

        return (servicer, ERCAddress, poolLent, (poolLent + PoolUtils0(poolUtilsAddress).getPoolInterestAccrued()), poolBorrowed, loanCount);
    }

    function getLoanCount() public view returns (uint256) {

        return loanCount;
    }

    function getSupplyableTokenAddress() public view returns (address) {

        return ERCAddress;
    }

    function getServicerAddress() public view returns (address) {

        return servicer;
    } 

    function getLoanDetails(uint256 loanId) public view returns (uint256, address, uint256, uint256, uint256, uint256, uint256) {

        Loan memory loan = loans[loanId];
        uint256 interestAccrued = getLoanAccruedInterest(loanId);
        uint256 propTokenID = loanToPropToken[loanId];
        return (loan.loanId, loan.borrower, loan.interestRate, loan.principal, interestAccrued, loan.timeLastPayment, propTokenID);
    }

    function getLoanAccruedInterest(uint256 loanId) public view returns (uint256) {

        Loan memory loan = loans[loanId];
        uint256 secondsSincePayment = block.timestamp.sub(loan.timeLastPayment);

        uint256 interestPerSecond = loan.principal.mul(loan.interestRate).div(31622400);
        uint256 interestAccrued = interestPerSecond.mul(secondsSincePayment).div(100000000);
        return interestAccrued.add(loan.interestAccrued);
    }   



    function getProportionalPoolTokens(uint256 amount) private view returns (uint256) {

        if (poolLent == 0) {
            return amount;
        } else {
            uint256 new_hc_pool = amount.mul(super.totalSupply()).div(poolLent);
            return new_hc_pool;
        }
    }

    function lend(
        uint256 amount
    ) public returns (uint256) {

        IERC20Upgradeable(ERCAddress).transferFrom(msg.sender, address(this), amount);
        uint256 newTokensMinted = getProportionalPoolTokens(amount);
        poolLent = poolLent.add(amount);

        super._mint(msg.sender, newTokensMinted, "", "");

        return newTokensMinted;
    }

    function redeem(
        uint256 amount
    ) public {

        require(balanceOf(msg.sender) >= amount);

        uint256 tokenPrice = poolLent.mul(1000000).div(super.totalSupply());
        uint256 erc20ValueOfTokens = amount.mul(tokenPrice).div(1000000);
        require(erc20ValueOfTokens <= (poolLent - poolBorrowed));

        super._burn(msg.sender, amount, "", "");
        poolLent = poolLent.sub(erc20ValueOfTokens);
        IERC20Upgradeable(ERCAddress).transfer(msg.sender, erc20ValueOfTokens);
    }

    function borrow(uint256 amount, uint256 maxRate, uint256 propTokenId) public {

        require(PropToken0(propTokenContractAddress).getApproved(propTokenId) == address(this), "pool not approved to move egg");
        require(PropToken0(propTokenContractAddress).ownerOf(propTokenId) == msg.sender, "msg.sender not egg owner");

        uint256 fixedInterestRate = uint256(PoolUtils0(poolUtilsAddress).getInterestRate(amount));
        require(fixedInterestRate <= maxRate, "interest rate no longer avail");

        uint256 lienAmount = PropToken0(propTokenContractAddress).getLienValue(propTokenId);
        require(lienAmount >= amount, "loan larger that egg value");

        uint256 LTVRequirement = LTVGuidelines(LTVOracleAddress).getMaxLTV();
        (, , uint256[] memory SeniorLiens, uint256 HomeValue, , ,) = PropToken0(propTokenContractAddress).getPropTokenData(propTokenId);
        for (uint i = 0; i < SeniorLiens.length; i++) {  
            lienAmount = lienAmount.add(SeniorLiens[i]);
        }
        require(lienAmount.mul(100).div(HomeValue) < LTVRequirement, "LTV too high");


        PropToken0(propTokenContractAddress).safeTransferFrom(msg.sender, address(this), propTokenId);

        Loan memory newLoan = Loan(loanCount, msg.sender, fixedInterestRate, amount, 0, block.timestamp);
        loans.push(newLoan);
        userLoans[msg.sender].push(loanCount);

        loanToPropToken[loanCount] = propTokenId;

        loanCount = loanCount.add(1);
        poolBorrowed = poolBorrowed.add(amount);

        IERC20Upgradeable(ERCAddress).transfer(msg.sender, amount);

        uint256 newTokensMinted = getProportionalPoolTokens(amount.div(200));
        super._mint(servicer, newTokensMinted, "", "");
        super._mint(daoAddress, newTokensMinted, "", "");
    }
    

    function repay(uint256 loanId, uint256 amount) public {        

        uint256 interestAmountRepayed = amount;

        uint256 currentInterest = getLoanAccruedInterest(loanId);
        if(currentInterest > amount) {
            IERC20Upgradeable(ERCAddress).transferFrom(msg.sender, address(this), amount);
            loans[loanId].interestAccrued = currentInterest.sub(amount);
        } else {
            interestAmountRepayed = currentInterest;
            uint256 amountAfterInterest = amount.sub(currentInterest);
            
            if(loans[loanId].principal > amountAfterInterest) {
                IERC20Upgradeable(ERCAddress).transferFrom(msg.sender, address(this), amount);
                poolBorrowed = poolBorrowed.sub(amountAfterInterest);
                loans[loanId].principal = loans[loanId].principal.sub(amountAfterInterest);
            } else {
                uint256 totalLoanValue = loans[loanId].principal.add(currentInterest);
                IERC20Upgradeable(ERCAddress).transferFrom(msg.sender, address(this), totalLoanValue);
                poolBorrowed = poolBorrowed.sub(loans[loanId].principal);
                loans[loanId].principal = 0;
                PropToken0(propTokenContractAddress).safeTransferFrom(address(this), loans[loanId].borrower, loanToPropToken[loanId]);
            }

            loans[loanId].interestAccrued = 0;
        }

        loans[loanId].timeLastPayment = block.timestamp;

        poolLent = poolLent.add(interestAmountRepayed);

        uint256 servicerFeeInERC = servicerFeePercentage.mul(interestAmountRepayed).div(loans[loanId].interestRate);
        uint256 newTokensMinted = getProportionalPoolTokens(servicerFeeInERC).div(2);
        super._mint(servicer, newTokensMinted, "", "");
        super._mint(daoAddress, newTokensMinted, "", "");
    }


    function stake(uint256 amount) public returns (bool) {

        require(balanceOf(msg.sender) >= amount, "not enough to stake");

        bool successfulStake = PoolStaking0(poolStakingAddress).stake(msg.sender, amount);
        if(successfulStake) {
            transfer(poolStakingAddress, amount);
        }

        return successfulStake;
    }

    function lendAndStake(uint256 amount) public returns (bool) {

        uint256 newPoolTokens = lend(amount);
        return stake(newPoolTokens);
    }

    function getVersion() public pure returns (uint) {

        return 8;
    }

    function onERC721Received(address, address, uint256, bytes memory ) public pure override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// contracts/PoolUtils.sol
pragma solidity ^0.8.4;



contract PoolUtils2 is Initializable {

    using SignedSafeMath for int256;
    using SafeMath for uint256;

    uint constant servicerFeePercentage = 1e6;
    uint constant baseInterestPercentage = 1e6;
    uint constant curveK = 150e6;

    address poolCore;




    function getAverageInterest() public view returns (uint256) {

        uint256 sumOfRates = 0;
        uint256 borrowedCounter = 0;
        
        uint256 interestRate = 0;
        uint256 principal = 0;
        uint256 loanCount = 0;

        (, , , , , loanCount) = Pool4(poolCore).getContractData();

        for (uint i = 0; i < loanCount; i++) {

            (, , interestRate, principal, , , ) = Pool4(poolCore).getLoanDetails(i);
            if(principal != 0){
                sumOfRates = sumOfRates.add(interestRate.mul(principal));
                borrowedCounter = borrowedCounter.add(principal);
            }
        }

       return sumOfRates.div(borrowedCounter);
    }

    function getActiveLoans() public view returns (bool[] memory) {

        uint256 principal = 0;
        uint256 loanCount = 0;

        (, , , , , loanCount) = Pool4(poolCore).getContractData();
        bool[] memory loanActive = new bool[](loanCount);

        for (uint i = 0; i < loanCount; i++) {
            (, , , principal, , , ) = Pool4(poolCore).getLoanDetails(i);

            if(principal != 0) {
                loanActive[i] = true;
            } else {
                loanActive[i] = false;
            }
        }

        return loanActive;
    }


    function getPoolInterestAccrued() public view returns (uint256) {

        uint256 totalInterest = 0;
        uint256 loanCount = Pool4(poolCore).getLoanCount();


        for (uint i=0; i<loanCount; i++) {
            uint256 accruedInterest = Pool4(poolCore).getLoanAccruedInterest(i);
            totalInterest = totalInterest.add(accruedInterest);
        }

        return totalInterest;
    }

    function getInterestRate(uint256 amount) public view returns (int256) {


        uint256 poolBorrowed = 0;
        uint256 poolLent = 0;
        (, , poolLent, , poolBorrowed, ) = Pool4(poolCore).getContractData();
        
        require(amount < (poolLent - poolBorrowed));

        int256 newUtilizationRatio = int256(poolBorrowed).add(int256(amount)).mul(100000000).div(int256(poolLent));

        int256 numerator = newUtilizationRatio.sub(int256(curveK));  
        int256 denominator = newUtilizationRatio.sub(100000000);
        int256 interest = numerator.mul(1000000).div(denominator);
        interest = interest.sub(int256(curveK).div(100)).add(int256(servicerFeePercentage)).add(int256(baseInterestPercentage)); 
        
        return interest;
    }


    function getVersion() public pure returns (uint) {

        return 2;
    }
 
}