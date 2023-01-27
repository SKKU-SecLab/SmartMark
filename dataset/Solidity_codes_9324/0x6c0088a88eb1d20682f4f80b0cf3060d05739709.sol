
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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
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


contract MekaApesERC721 is ERC721Upgradeable, OwnableUpgradeable {


    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);

    address public gameContract;

    string public baseURI;

    string public _contractURI;

    function initialize(
        string memory name_, 
        string memory symbol_, 
        string memory baseURI_,
        string memory contractURI_
    ) public initializer {


        __ERC721_init(name_, symbol_);
        __Ownable_init();

       
        baseURI = baseURI_;
        _contractURI = contractURI_;
    }

    function setGameContract(address gameContract_) external onlyOwner {

         gameContract = gameContract_;
    }   

    function contractURI() public view returns (string memory) {

        return _contractURI;
    }

    function setContractURI(string memory contractURI_) external onlyOwner {

        _contractURI = contractURI_;
    }

    function mint(address account, uint256 tokenId) external {

        require(msg.sender == gameContract, "E1");
        _mint(account, tokenId);
    }

    function mintMultiple(address account, uint256 startFromTokenId, uint256 amount) external {

        require(msg.sender == gameContract, "E1");
        for(uint256 i=0; i<amount; i++) {
            _mint(account, startFromTokenId + i);
        }
    }

    function burn(uint256 tokenId) external {

        require(msg.sender == gameContract, "E2");
        _burn(tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {

        return baseURI;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "E3");

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, uintToStr(tokenId), ".json")) : "";
    }

    function changeBaseURI(string memory baseURI_) external onlyOwner {

        baseURI = baseURI_;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual override returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender) || spender == gameContract);
    }

    function uintToStr(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT
pragma solidity ^0.8.0;



contract OogearERC20 is ERC20, Ownable {

    address public gameContract;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable() {

    }

    function setGameContract(address gameContract_) external onlyOwner {
         gameContract = gameContract_;
    }   

    function mint(address account, uint256 amount) external {
        require(msg.sender == gameContract, "E1");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(msg.sender == gameContract, "E2");
        _burn(account, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount || msg.sender == gameContract, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        _transfer(sender, recipient, amount);

        return true;
    }

}// MIT
pragma solidity ^0.8.0;

interface IDMT_ERC20 {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
}// MIT
pragma solidity ^0.8.0;



enum OogaType { ROBOOOGA, MEKAAPE }

struct OogaAttributes {
    OogaType oogaType;
    uint8 level;

    bool staked;
    address stakedOwner;

    uint256 lastClaimTimestamp;
    uint256 savedReward;

    uint256 lastRewardPerPoint;
    uint256 stakedMegaIndex;
}

struct Prices {
    uint256 mintPrice;
    uint256 mintStakePrice;
    uint256[] mintOGprice;
    uint256[] mintOGstakePrice;
    uint256 mintDMTstakePrice;
    uint256[] roboLevelupPrice;
    uint256 mekaMergePrice;
}

struct PricesGetter {
    uint256 mintPrice;
    uint256 mintStakePrice;
    uint256 mintOGprice;
    uint256 mintOGstakePrice;
    uint256 mintDMTstakePrice;
    uint256[] roboLevelupPrice;
    uint256 mekaMergePrice;
    uint256[] roboLevelupPriceOG;
}

struct RandomsGas {
    uint256 mintBase;
    uint256 mintPerToken;
    uint256 mintPerTokenStaked;
    uint256 unstakeBase;
    uint256 unstakePerToken;
    uint256 mergeBase;
}

struct InitParams {
    MekaApesERC721 erc721Contract_;
    OogearERC20 ogToken_;
    IDMT_ERC20 dmtToken_;
    IERC721 oogaVerse_;
    address mintSigWallet_;
    address randomProvider_;
    Prices prices_;
    RandomsGas randomsGas_;
    uint256[] mintOGpriceSteps_;
    uint256[] roboOogaRewardPerSec_;
    uint256[] roboOogaMinimalRewardToUnstake_;
    uint256[] roboOogaRewardAttackProbabilities_;
    uint256[] megaLevelProbabilities_;
    uint256[] mekaLevelSharePoints_;
    uint256[] megaTributePoints_;
    uint256 claimTax_;
    uint256 maxMintWithDMT_;
    uint256 mintSaleAmount_;
    uint256 maxTokenSupply_;
    uint256 maxOgSupply_;
    uint256 addedOgForRewardsAtEnd_;
    uint256 ethMintAttackChance_;
    uint256 dmtMintAttackChance_;
    uint256 ogMintAttackChance_;
    uint256 randomMekaProbability_;
    uint256 publicMintAllowance_;
    uint256 maxMintedRewardTokens_;
    address[] mintETHWithdrawers_;
    uint256[] mintETHWithdrawersPercents_;
}

struct MintSignature {
    uint256 mintAllowance;
    uint8 _v;
    bytes32 _r; 
    bytes32 _s;
}

struct LeaderboardRewardSignature {
    uint256 reward;
    uint8 _v;
    bytes32 _r;
    bytes32 _s;
}

enum RandomRequestType { MINT, UNSTAKE, MERGE }

struct RandomRequest {
    RandomRequestType requestType;
    address user;
    bool active;
}

struct ClaimRequest {
    uint256 totalMekaReward;
    uint256[] roboOogas;
    uint256[] roboOogasAmounts;
}

struct MintRequest {
    uint32 startFromId;
    uint8 amount;
    uint8 attackChance;
    bool toStake;
}

struct Crew {
    address owner;
    uint256[] oogas;
    uint256 lastClaimTimestamp;
    uint256 totalRewardPerSec;
    uint256 savedReward;
    uint256 oogaCount;
}

contract MekaApesGame_2 is OwnableUpgradeable {

    MekaApesERC721 public erc721Contract;
    OogearERC20 public ogToken;
    IDMT_ERC20 public dmtToken;
    IERC721 public oogaVerse;

    address public mintSigWallet;
    address public randomProvider;

    Prices public prices;
    RandomsGas public randomsGas;

    uint256[] public mintOGpriceSteps;
    uint256 public currentOgPriceStep;

    uint256[] public roboOogaRewardPerSec;
    uint256[] public roboOogaMinimalRewardToUnstake;
    uint256[] public roboOogaRewardAttackProbabilities;

    uint256 public claimTax;

    uint256 public nextTokenId;

    uint256 public tokensMintedWithDMT;
    uint256 public maxMintWithDMT;

    uint256 public ethMintAttackChance;
    uint256 public dmtMintAttackChance;
    uint256 public ogMintAttackChance;
    uint256 public ATTACK_CHANCE_DENOM;

    uint256 public randomMekaProbability;

    uint256[] public megaLevelProbabilities;

    uint256[] public mekaLevelSharePoints;
    uint256[] public megaTributePoints;

    uint256 public mekaTotalRewardPerPoint;
    uint256 public mekaTotalPointsStaked;

    uint256[][4] public megaStaked;

    mapping(uint256 => OogaAttributes) public oogaAttributes;

    mapping(uint256 => bool) public oogaEvolved;

    uint256 public publicMintAllowance;
    bool public publicMintStarted;
    mapping(address => uint256) public numberOfMintedOogas;

    uint256 public mintSaleAmount;
    bool public mintSale;
    bool public gameActive;

    uint256 public ogMinted;
    uint256 public maxOgSupply;
    uint256 public addedOgForRewardsAtEnd;

    uint256 public maxTokenSupply;

    uint256 public totalMintedRewardTokens;
    uint256 public maxMintedRewardTokens;

    uint256 public totalRandomTxFee;
    uint256 public totalRandomTxFeeWithdrawn;

    uint256 public totalMintETH;
    mapping(address => uint256) public withdrawerPercent;
    mapping(address => uint256) public withdrawerLastTotalMintETH;

    uint256 public nextRandomRequestId;
    mapping(uint256 => RandomRequest) public randomRequests;
    mapping(uint256 => MintRequest) public mintRequests;
    mapping(uint256 => ClaimRequest) public claimRequests;
    mapping(uint256 => uint256) public mergeRequests;
    uint256 public nextClaimWithoutRandomId;

    event MintMultipleRobo(address indexed account, uint256 indexed startFromTokenId, uint256 indexed amount);
    event MekaConvert(uint256 indexed tokenId);
    event OogaAttacked(uint256 indexed oogaId, address indexed tributeAccount, uint256 indexed tributeOogaId);
    event BabyOogaEvolve(address indexed account, uint256 indexed oogaId, uint256 indexed newTokenId);
    event StakeOoga(uint256 indexed oogaId, address indexed account);
    event UnstakeOoga(uint256 indexed oogaId, address indexed account);
    event ClaimReward(uint256 indexed claimId, address indexed account, uint256 indexed tokenId, uint256 amount);
    event TaxReward(uint256 indexed claimId, uint256 totalTax);
    event AttackReward(uint256 indexed claimId, uint256 indexed tokenId, uint256 amount);
    event LevelUpRoboOoga(address indexed account, uint256 indexed oogaId, uint256 indexed newLevel);
    event MergeMekaApes(address indexed account, uint256 indexed oogaIdSave, uint256 indexed oogaIdBurn);
    event MegaMerged(uint256 indexed tokenId, uint256 indexed megaLevel);

    event RequestRandoms(uint256 indexed requestId, uint256 requestSeed);
    event ReceiveRandoms(uint256 indexed requestId, uint256 entropy);


    uint256 public previousBaseFee;
    uint256 public currentBaseFee;
    uint256 public baseFeeRefreshTime;
    uint256 public baseFeeUpdatedAt;

    event RoboMint(address indexed account, uint256 indexed tokenId);

    bool public initV2;


    bool public allTokensMinted;
    uint256 public allMintedTimestamp;

    bool public ogRewardMinted;

    bool public initV3;


    uint256[] public roboOogaRewardPerSec_midStage;

    bool public initV4;


    event MakeCrew(address indexed account, uint256 indexed crewId);
    event RemoveCrew(uint256 indexed crewId);
    event ClaimCrewReward(address indexed account, uint256 indexed crewId, uint256 amount);

    uint256 public nextCrewId;
    mapping(uint256 => Crew) public crews;
    mapping(uint256 => uint256) public inCrew;

    uint256[] public roboLevelupPriceOG;
    uint256[] public roboOogaRewardPerSecInCrew;
    uint256[] public maxCrewForMekaLevel;
    uint256[] public mekaCrewRewardMultiplier;

    uint256 public crewClaimPercent;

    bool public initV5;

    event AddToCrew(uint256 indexed crewId, uint256 indexed tokenIds);
    event RemoveFromCrew(uint256 indexed crewId, uint256 indexed tokenIds);

    uint256 public unstakeCreditsStart;
    mapping(address => uint256) public unstakeCredits;
    mapping(address => uint256) public usedUnstakeCredits;
    uint256[] public unstakeCreditsForRoboLevel;

    uint256 public roboOogaRewardStart;

    mapping(address => uint256) public leaderboardRewardClaimed;

    event AddUnstakeCredits(address indexed user, uint256 indexed burnOogaId, uint256 addedCredits);
    event LeaderbordRewardClaim(address indexed user, uint256 reward);

    address public gameContract2;

    uint256 public midStageOverTimestamp;
    uint256 public roboOogaRewardEnd;
    uint256 public roboOogaRewardIncreaseDuration;

    event ChangeStaker(uint256 indexed tokenId, address indexed account);


    mapping(address => uint256) public recoverOGClaimed;
    address public recoverSigWallet;


    bool public initV6;
    uint256 public stopOGproductionTimestamp;


    function verifyMintSig(bytes memory message, uint8 _v, bytes32 _r, bytes32 _s, address sigWalletCheck) private pure returns (bool) {
        bytes32 messageHash = keccak256(message);
        bytes32 signedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        address signer = ecrecover(signedMessageHash, _v, _r, _s);
        return signer == sigWalletCheck;
    }

    function _ogMint(address toAddress, uint256 amount) private {
        uint256 toMint = amount;

        ogToken.mint(toAddress, toMint);
    }

    function claimAvailableAmount(uint256 tokenId) private view returns(uint256) {
        OogaAttributes memory ooga = oogaAttributes[tokenId];

        if (ooga.oogaType == OogaType.ROBOOOGA) {

            uint256 roboReward = ooga.savedReward;

            uint256 lastClaim = oogaAttributes[tokenId].lastClaimTimestamp;

            if (lastClaim < allMintedTimestamp) {
                roboReward += (allMintedTimestamp - lastClaim) * roboOogaRewardPerSec[ooga.level];
                lastClaim = allMintedTimestamp;
            }

            if (lastClaim < midStageOverTimestamp) {
                roboReward += (midStageOverTimestamp - lastClaim) * roboOogaRewardPerSec_midStage[ooga.level];
                lastClaim = midStageOverTimestamp;
            }

            uint256 lastTimestamp = (block.timestamp < stopOGproductionTimestamp) ? block.timestamp : stopOGproductionTimestamp;

            if (lastClaim < lastTimestamp) {
                uint256 passedTime = lastTimestamp - lastClaim;
                uint256 roboOogaRewardIncreasePerSecond = (roboOogaRewardEnd - roboOogaRewardStart) / roboOogaRewardIncreaseDuration;

                if (passedTime > roboOogaRewardIncreaseDuration) {

                    roboReward += (roboOogaRewardIncreaseDuration * roboOogaRewardIncreaseDuration * roboOogaRewardIncreasePerSecond) / 2;
                    roboReward += roboOogaRewardIncreaseDuration * roboOogaRewardStart;

                    roboReward += (passedTime - roboOogaRewardIncreaseDuration) * roboOogaRewardEnd;

                } else {
                    roboReward += (passedTime * passedTime * roboOogaRewardIncreasePerSecond) / 2;
                    roboReward += passedTime * roboOogaRewardStart;
                }

            }

            return roboReward;
        } else {
            
            return (mekaTotalRewardPerPoint - ooga.lastRewardPerPoint) * mekaLevelSharePoints[ooga.level];
        }
    }

    function _addMekaToStakingRewards(uint256 tokenId) private {
        OogaAttributes storage ooga = oogaAttributes[tokenId];

        mekaTotalPointsStaked += mekaLevelSharePoints[ooga.level];
        ooga.lastRewardPerPoint = mekaTotalRewardPerPoint;

        if (ooga.level > 0) {
            ooga.stakedMegaIndex = megaStaked[ooga.level].length;
            megaStaked[ooga.level].push(tokenId);
        }
    }

    function _removeMekaFromStakingRewards(uint256 tokenId) private {
        OogaAttributes storage ooga = oogaAttributes[tokenId];

        mekaTotalPointsStaked -= mekaLevelSharePoints[ooga.level];

        if (ooga.level > 0) {
            uint256 lastOogaId = megaStaked[ooga.level][ megaStaked[ooga.level].length - 1 ];
            megaStaked[ooga.level][ooga.stakedMegaIndex] = lastOogaId;
            megaStaked[ooga.level].pop();
            oogaAttributes[lastOogaId].stakedMegaIndex = ooga.stakedMegaIndex;
        }

        ooga.stakedMegaIndex = 0;
    }

    function createCrew(uint256[] calldata tokenIds) external {
        require(gameActive, "E01");

        uint256 len = tokenIds.length;
        require(len > 0, "E120");

        uint256 crewId = nextCrewId;
        nextCrewId++;

        emit MakeCrew(msg.sender, crewId);

        Crew storage crew = crews[crewId];

        crew.owner = msg.sender;

        OogaAttributes storage mekaLeader = oogaAttributes[tokenIds[0]];

        require(mekaLeader.oogaType == OogaType.MEKAAPE, "E121");
        require(mekaLeader.staked == true && mekaLeader.stakedOwner == msg.sender, "E125");
        require(inCrew[tokenIds[0]] == 0, "E123");

        require(len-1 <= maxCrewForMekaLevel[mekaLeader.level], "E122");
       
        crew.oogas.push(tokenIds[0]);
        inCrew[tokenIds[0]] = crewId;
        emit AddToCrew(crewId, tokenIds[0]);

        uint256 mekaReward = claimAvailableAmount(tokenIds[0]);
        mekaLeader.lastRewardPerPoint = mekaTotalRewardPerPoint;

        _removeMekaFromStakingRewards(tokenIds[0]);

        _addToCrew(crewId, tokenIds, 1);

        crew.lastClaimTimestamp = block.timestamp;
        crew.savedReward = mekaReward;
    }

    function _removeCrew(uint256 crewId) private {
        Crew storage crew = crews[crewId];

        require(crew.owner == msg.sender, "E132");

        _claimCrewReward(crewId);

        for(uint256 i=1; i<crew.oogas.length; i++) {
            if (inCrew[crew.oogas[i]] == crewId) {
                _removeFromCrewOneToken(crewId, crew.oogas[i]);
            }
        }

        _addMekaToStakingRewards(crew.oogas[0]);
        inCrew[crew.oogas[0]] = 0;

        emit RemoveCrew(crewId);
    }

    function removeCrew(uint256[] calldata crewIds) external {
        require(gameActive, "E01");

        for(uint256 i=0; i<crewIds.length; i++) {
            _removeCrew(crewIds[i]);
        }
    }

    function _addToCrew(uint256 crewId, uint256[] calldata addTokenIds, uint256 startFrom) private {
        Crew storage crew = crews[crewId];

        for(uint256 i=startFrom; i<addTokenIds.length; i++) {
            OogaAttributes storage ooga = oogaAttributes[addTokenIds[i]];
            require(ooga.staked == true && ooga.stakedOwner == msg.sender, "E135");
            require(ooga.oogaType == OogaType.ROBOOOGA, "E133");
            require(inCrew[addTokenIds[i]] == 0, "E134");

            ooga.savedReward = claimAvailableAmount(addTokenIds[i]);
            ooga.lastClaimTimestamp = block.timestamp;

            crew.oogas.push(addTokenIds[i]);
            crew.totalRewardPerSec += roboOogaRewardPerSecInCrew[ooga.level];

            crew.oogaCount += 1;

            inCrew[addTokenIds[i]] = crewId;
            emit AddToCrew(crewId, addTokenIds[i]);
        }
    }

    function _removeFromCrewOneToken(uint256 crewId, uint256 tokenId) private {
        crews[crewId].totalRewardPerSec -= roboOogaRewardPerSecInCrew[oogaAttributes[tokenId].level];
        inCrew[tokenId] = 0;

        oogaAttributes[tokenId].lastClaimTimestamp = block.timestamp;

        crews[crewId].oogaCount -= 1;

        emit RemoveFromCrew(crewId, tokenId);
    }

    function _removeFromCrew(uint256 crewId, uint256[] calldata removeTokenIds) private {
         for(uint256 i=0; i<removeTokenIds.length; i++) {
            OogaAttributes storage ooga = oogaAttributes[removeTokenIds[i]];
            require(ooga.oogaType == OogaType.ROBOOOGA, "E143");
            require(inCrew[removeTokenIds[i]] == crewId, "E144");

            _removeFromCrewOneToken(crewId, removeTokenIds[i]);
         }
    }

    function changeCrew(uint256 crewId, uint256[] calldata addTokenIds, uint256[] calldata removeTokenIds) external {
        require(gameActive, "E01");

        Crew storage crew = crews[crewId];

        require(crew.owner == msg.sender, "E111");

        _updateCrewReward(crewId);

        uint256 maxCrewTokens = maxCrewForMekaLevel[oogaAttributes[crew.oogas[0]].level];
        require(crew.oogaCount + addTokenIds.length - removeTokenIds.length <= maxCrewTokens, "E112");

        _addToCrew(crewId, addTokenIds, 0);
        _removeFromCrew(crewId, removeTokenIds);
    }

function claimAvailableAmountCrew(uint256 crewId) public view returns(uint256) {
        Crew storage crew = crews[crewId];

        OogaAttributes storage mekaLeader = oogaAttributes[crew.oogas[0]];

        uint256 rewardPerSec = (crew.totalRewardPerSec * mekaCrewRewardMultiplier[mekaLeader.level]) / 100;

        uint256 crewReward = crew.savedReward;

        uint256 lastTimestamp = (block.timestamp < stopOGproductionTimestamp) ? block.timestamp : stopOGproductionTimestamp;

        if (crew.lastClaimTimestamp < lastTimestamp) {
            crewReward += (lastTimestamp - crew.lastClaimTimestamp) * rewardPerSec;
        }

        return crewReward;
    }

    function claimAvailableAmountMultipleCrews(uint256[] calldata crewIds) public view returns(uint256[] memory result) {
        result = new uint256[](crewIds.length);
        for(uint256 i=0; i<crewIds.length; i++) {
            result[i] = claimAvailableAmountCrew(crewIds[i]);
        }

        return result;
    }

    function _updateCrewReward(uint256 crewId) private {
        crews[crewId].savedReward = claimAvailableAmountCrew(crewId);
        crews[crewId].lastClaimTimestamp = block.timestamp;
    }

    function _claimCrewReward(uint256 crewId) private {

        Crew storage crew = crews[crewId];

        require(crew.owner == msg.sender, "E131");

        uint256 reward = claimAvailableAmountCrew(crewId);

        crew.lastClaimTimestamp = block.timestamp;
        crew.savedReward = 0;

        _ogMint(msg.sender, reward);

        emit ClaimCrewReward(msg.sender, crewId, reward);
    }

    function claimCrewReward(uint256[] calldata crewIds) external {
        require(gameActive, "E01");

        for(uint256 i=0; i<crewIds.length; i++) {
            _claimCrewReward(crewIds[i]);
        }
    }

    function claimLeaderbordReward(LeaderboardRewardSignature calldata rewardSig) external {
        require(gameActive, "E01");

        require(verifyMintSig(
                abi.encode(msg.sender, rewardSig.reward),
                rewardSig._v,
                rewardSig._r,
                rewardSig._s,
                mintSigWallet
            ), "E181");

        require(leaderboardRewardClaimed[msg.sender] == 0, "E182");

        leaderboardRewardClaimed[msg.sender] = rewardSig.reward;

        _ogMint(msg.sender, rewardSig.reward);

        emit LeaderbordRewardClaim(msg.sender, rewardSig.reward);
    }

    function recoverLostTokens(uint256[] calldata tokenIds, address oldOwner, address newOwner) external onlyOwner {
        for(uint256 i=0; i<tokenIds.length; i++) {
            OogaAttributes storage ooga = oogaAttributes[tokenIds[i]];
            require(ooga.staked == true && ooga.stakedOwner == oldOwner, "E510");
            if (inCrew[tokenIds[i]] != 0) {
                _removeFromCrewOneToken(inCrew[tokenIds[i]], tokenIds[i]);
            }
            ooga.stakedOwner = newOwner;
            emit ChangeStaker(tokenIds[i], newOwner);
        }
    }

    function changeRecoverSigWallet(address newRecoveryWallet_) external onlyOwner {
        recoverSigWallet = newRecoveryWallet_;
    }

    function recoverLostOG(LeaderboardRewardSignature calldata rewardSig) external {
        require(gameActive, "E01");

        require(verifyMintSig(
                abi.encode(msg.sender, rewardSig.reward),
                rewardSig._v,
                rewardSig._r,
                rewardSig._s,
                recoverSigWallet
            ), "E281");

        require(recoverOGClaimed[msg.sender] == 0, "E282");

        recoverOGClaimed[msg.sender] = rewardSig.reward;

        _ogMint(msg.sender, rewardSig.reward);

        emit ClaimReward(0, msg.sender, 0, rewardSig.reward);
    }

    function withdrawERC20(IERC20 token, address toAddress, uint256 amount) external onlyOwner {
        token.transfer(toAddress, amount);
    }

    function withdrawERC721(IERC721 token, address toAddress, uint256 tokenId) external onlyOwner {
        token.transferFrom(address(this), toAddress, tokenId);
    }
}