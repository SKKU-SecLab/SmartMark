

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
}

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
        return !Address.isContract(address(this));
    }
}

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
}

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
}

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
}

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

}

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

pragma solidity ^0.8.0;


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
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

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

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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

}

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
}

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
}
pragma solidity ^0.8.0;

contract Governance {

    address public _governance;

    constructor() {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance) public onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }

}
pragma solidity ^0.8.0;


contract RoleControl is Governance,Pausable,ReentrancyGuard{

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    mapping(bytes32 => mapping(address => bool)) private _roles; // rule name => address => flag

    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender) ,"account is missing role.");
        _;
    }
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    function grantRole(bytes32 role, address account) external onlyGovernance {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyGovernance {
        _revokeRole(role, account);
    }



    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyGovernance {
        _unpause();
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role][account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role][account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }


}

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

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
}

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
}

pragma solidity ^0.8.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}
pragma solidity ^0.8.0;


    

interface IThemisLendCompoundStorage{
    struct LendUserInfo {
        uint256 lastLendInterestShare;
        uint256 unRecvInterests;
        uint256 currTotalLend;
        uint256 userDli;
    }
    
    struct CompoundLendPool {
        address token;
        address spToken;
        uint256 curSupply;
        uint256 curBorrow;
        uint256 totalRecvInterests; //User receives interest
    }
}
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;



interface IThemisLendCompound is IThemisLendCompoundStorage{
    function tokenOfPid(address token) external view returns(uint256 pid);
    function lendPoolInfo(uint256 pid) external view returns(CompoundLendPool memory pool);
    function getPoolLength() external view returns(uint256 poolLength);
    function doAfterLpTransfer(address ctoken,address sender,address recipient, uint256 amount) external;

    function loanTransferToken(uint256 pid,address toUser,uint256 amount) external;
    function repayTransferToken(uint256 pid,uint256 amount) external;
    function lendUserInfos(address user,uint256 pid) external view returns(LendUserInfo memory lendUserInfo);
    function userLend(uint256 _pid, uint256 _amount) external;
    function userRedeem(uint256 pid, uint256 _amount) external returns(uint256);
    function pendingRedeemInterests(uint256 _pid, address _user) external view returns(uint256 _lendInterests,uint256 _platFormInterests);
    function settlementRepayTransferToken(uint256 pid,uint256 amount) external;
    function transferToAuctionUpBorrow(uint256 pid,uint256 amount) external;
}
pragma solidity ^0.8.0;




contract ThemisFinanceToken is ERC20,Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    
    uint8 private _decimals = 18;


	constructor(string memory _name, string memory _symbol, uint8 _decimalsTmp) ERC20(_name, _symbol)  {
		_decimals = _decimalsTmp;
	}
	
	function decimals() public view override returns (uint8) {
        return _decimals;
    }
	
    function mint(address _to, uint256 _amount) onlyOwner external {
        _mint(_to, _amount);
    }
    
    function burn(address _to, uint256 _amount) onlyOwner external {
        _burn(_to, _amount);
    }

    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        
        IThemisLendCompound(owner()).doAfterLpTransfer(address(this),msg.sender,recipient,amount);

        return super.transfer(recipient, amount);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        
        IThemisLendCompound(owner()).doAfterLpTransfer(address(this),sender,recipient,amount);
        
        return super.transferFrom(sender, recipient, amount);
    }
    

    
    
}
pragma solidity ^0.8.0;
interface IUniswapV3Oracle{
    function getNFTAmounts(uint256 _tokenId) external view returns(address _token0,address _token1,uint24 _fee,uint256 _amount0,uint256 _amount1);
    function getTWAPQuoteNft(uint256 _tokenId,address _quoteToken) external view returns(uint256 _quoteAmount,uint256 _gasEstimate);
    
}
pragma solidity ^0.8.0;

interface IThemisAuction{
    function toAuction(address erc721Addr,uint256 tokenId,uint256 bid,address auctionToken,uint256 startAuctionAmount,uint256 startAuctioInterests) external;
}
pragma solidity ^0.8.0;


    

interface IThemisBorrowCompoundStorage{
    struct BorrowUserInfo {
        uint256 currTotalBorrow;
    }
    
    struct UserApplyRate{
        address apply721Address;
        uint256 specialMaxRate;
        uint256 tokenId;
    }
    
    struct BorrowInfo {
        address user;
        uint256 pid;
        uint256 tokenId;
        uint256 borrowValue;
        uint256 auctionValue;
        uint256 amount;
        uint256 repaidAmount;
        uint256 startBowShare;
        uint256 startBlock;
        uint256 returnBlock;
        uint256 interests;
        uint256 state;      //0.init 1.borrowing 2.return 8.settlement 9.overdue
    }
    
    struct CompoundBorrowPool {
        address token;
        address ctoken;
        uint256 curBorrow;
        uint256 curBowRate;
        uint256 lastShareBlock;
        uint256 globalBowShare;
        uint256 globalLendInterestShare;
        uint256 totalMineInterests;
        uint256 overdueRate;
    }
    
    struct Special721Info{
        string name;
        uint256 rate;
    }
    
}
pragma solidity ^0.8.0;







contract ThemisBorrowCompound is IThemisBorrowCompoundStorage,IThemisLendCompoundStorage,RoleControl,Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    using EnumerableSet for EnumerableSet.UintSet;
    

    event UserBorrow(address indexed user, uint256 indexed tokenId, uint256 indexed pid, uint256 bid, uint256 value, uint256 amount,uint256 borrowRate,address apply721Address, uint256 startBlock);
    event UserReturn(address indexed user, uint256 indexed bid,uint256 pid, uint256 amount,uint256 interests,uint256 platFormInterests);
    event TransferToAuction(uint256 indexed bid, uint256 indexed tokenId,uint256 pid);
    event SettlementBorrowEvent(uint256 indexed bid,uint256 pid,uint256 amount,uint256 interests,uint256 platFormInterests);
    
    event AddNftV3WhiteListEvent(uint256 indexed position,address sender,address token0,address token1);
    event SetNftV3WhiteListEvent(uint256 indexed position,address sender,address beforeToken0,address beforeToken1,address afterToken0,address afterToken1);
    event SetBorrowPoolOverdueRateEvent(uint256 indexed pid,address sender,uint256 beforeOverdueRate,uint256 afterOverdueRate);
    
    event SetSpecial721BorrowRateEvent(address indexed special72,address sender,uint256 beforeRate,uint256 afterRate);
    
    event ApplyRateEvent(address indexed sender,address apply721Address,uint256 specialMaxRate,uint256 tokenId);
    event setSettlementBorrowAuthEvent(address indexed sender,address user,bool flag);
    event TransferInterestToLendEvent(address indexed sender,uint256 pid,address toUser,uint256 interests);
    event SetInterestPlatformRateEvent(address indexed sender,uint256 beforeValue,uint256 afterValue);
    event SetFunderEvent(address indexed sender,address beforeVal,address afterVal);
    event FunderClaimEvent(address indexed sender,uint256 pid,uint256 amount);
    event MinSettingCollateralEvent(address indexed sender,uint256 pid,uint256 beforeVal,uint256 afterVal);
    event PausePoolEvent(address indexed sender,uint256 pid,bool flag);
    event ChangeUniswapV3OracleEvent(address indexed sender,address beforeVal,address afterVal);
 
    mapping(address => mapping(uint256 => BorrowUserInfo)) public borrowUserInfos;
    mapping (address => mapping (uint256 => EnumerableSet.UintSet)) private _holderBorrowIds;
    
    mapping (address => EnumerableSet.UintSet) private _holderBorrowPoolIds;
    


    
    BorrowInfo[] public borrowInfo;

    IERC721 public uniswapV3;

    address public themisAuction ;
    
    IThemisLendCompound public lendCompound;
    CompoundBorrowPool[] public borrowPoolInfo;
    
    address[] public nftV3Token0WhiteList;
    address[] public nftV3Token1WhiteList;
    
    address[] public special721Arr;
    mapping(address => Special721Info) public special721Info;
    
    mapping(address => UserApplyRate) public userApplyRate;
    
    IUniswapV3Oracle public uniswapV3Oracle;
    
    uint256 public constant blockPerDay = 5760;
    
    uint256 public globalDefault = 650;

    mapping(address=>bool) public settlementBorrowAuth;

    mapping(uint256 => uint256) public badDebtPrincipal;
    mapping(uint256 => uint256) public badDebtInterest;

    address public funder;
    uint256 public interestPlatformRate;
    mapping(uint256 => uint256) public funderPoolInterest;  //pid => amount

    mapping(uint256 => uint256) public minSettingCollateral;// pid => min amount
    

    modifier onlyLendVistor {
        require(address(lendCompound) == msg.sender, "not lend vistor allow.");
        _;
    }

    modifier onlySettlementVistor {
        require(settlementBorrowAuth[msg.sender], "not settlement borrow vistor allow.");
        _;
    }

    modifier onlyFunderVistor {
        require(funder == msg.sender, "not funder vistor allow.");
        _;
    }

    modifier authContractAccessChecker {
        if(msg.sender.isContract() || tx.origin != msg.sender){
            require(hasRole(keccak256("CONTRACT_ACCESS_ROLE"),msg.sender), "not whitelist vistor allow.");
        }
        _;
    }
    
    function doInitialize(address _uniswapV3,address _uniswapV3Oracle, IThemisLendCompound _iThemisLendCompound,address _themisAuction,uint256 _globalDefault,uint256 _interestPlatformRate) public initializer{
        require(_globalDefault < 1_000,"The maximum ratio has been exceeded.");
        require(_interestPlatformRate < 10_000,"The maximum ratio has been exceeded.");
        _governance = msg.sender;
        _grantRole(PAUSER_ROLE, msg.sender);
        
        uniswapV3 = IERC721(_uniswapV3);
        uniswapV3Oracle  = IUniswapV3Oracle(_uniswapV3Oracle);
        lendCompound = _iThemisLendCompound;
        themisAuction = _themisAuction;
        globalDefault = _globalDefault;
        settlementBorrowAuth[themisAuction] = true;
        interestPlatformRate = _interestPlatformRate;
    }

    function changeUniswapV3Oracle(address _uniswapV3Oracle) external onlyGovernance{
        address _beforeVal = address(uniswapV3Oracle);
        uniswapV3Oracle  = IUniswapV3Oracle(_uniswapV3Oracle);
        emit ChangeUniswapV3OracleEvent(msg.sender,_beforeVal,_uniswapV3Oracle);
    }
    
    function setMinSettingCollateral(uint256 _pid,uint256 _minAmount) external onlyGovernance{
        uint256 _beforeVal = minSettingCollateral[_pid];
        minSettingCollateral[_pid] = _minAmount;
        emit MinSettingCollateralEvent(msg.sender,_pid,_beforeVal,_minAmount);
    }

    function setInterestPlatformRate(uint256 _interestPlatformRate)  external onlyGovernance{
        require(_interestPlatformRate < 10_000,"The maximum ratio has been exceeded.");
        uint256 _beforeValue = interestPlatformRate;
        interestPlatformRate = _interestPlatformRate;
        emit SetInterestPlatformRateEvent(msg.sender,_beforeValue,_interestPlatformRate);
    }

    function setSettlementBorrowAuth(address _user,bool _flag) external  onlyGovernance{
        settlementBorrowAuth[_user] = _flag;
        emit setSettlementBorrowAuthEvent(msg.sender,_user,_flag);
    }

    function pausePool(uint256 _pid) external onlyRole(PAUSER_ROLE){
        CompoundBorrowPool memory _borrowPool = borrowPoolInfo[_pid];
        _grantRole(keccak256("VAR_PAUSE_POOL_ACCESS_ROLE"), _borrowPool.token);
        emit PausePoolEvent(msg.sender,_pid,true);
    }

    function unpausePool(uint256 _pid) external onlyGovernance{
        CompoundBorrowPool memory _borrowPool = borrowPoolInfo[_pid];
        _revokeRole(keccak256("VAR_PAUSE_POOL_ACCESS_ROLE"), _borrowPool.token);
        emit PausePoolEvent(msg.sender,_pid,false);
    }


    function addBorrowPool(address borrowToken,address lendCToken) external onlyLendVistor{
        borrowPoolInfo.push(CompoundBorrowPool({
            token: borrowToken,
            ctoken: lendCToken,
            curBorrow: 0,
            curBowRate: 0,
            lastShareBlock: block.number,
            globalBowShare: 0,
            globalLendInterestShare: 0,
            totalMineInterests: 0,
            overdueRate: 800
        }));
        
    }
    
    function addNftV3WhiteList(address tokenA,address tokenB) external onlyGovernance{
        require( nftV3Token0WhiteList.length ==  nftV3Token1WhiteList.length,"error for nftV3Token0WhiteList size.");
        (address _token0, address _token1) = sortTokens(tokenA,tokenB);
        uint256 _position = nftV3Token0WhiteList.length;

        nftV3Token0WhiteList.push(_token0);
        nftV3Token1WhiteList.push(_token1);
        emit AddNftV3WhiteListEvent(_position,msg.sender,_token0,_token1);
    }
    
    function setNftV3WhiteList(uint256 position,address tokenA,address tokenB) external onlyGovernance{
        require( nftV3Token0WhiteList.length ==  nftV3Token1WhiteList.length,"error for nftV3Token0WhiteList size.");
        require( nftV3Token0WhiteList[position]!=address(0),"error for nftV3Token0WhiteList position.");
        (address _token0, address _token1) = sortTokens(tokenA,tokenB);
        address _beforeToken0 = nftV3Token0WhiteList[position];
        address _beforeToken1 = nftV3Token1WhiteList[position];
        nftV3Token0WhiteList[position] = _token0;
        nftV3Token1WhiteList[position] = _token1;
        
        emit SetNftV3WhiteListEvent(position,msg.sender,_beforeToken0,_beforeToken1,_token0,_token1);
    }
    
    function setSpecial721BorrowRate(address special721,uint256 rate,string memory name) external onlyGovernance{
        require(rate < 1000,"The maximum ratio has been exceeded.");
        uint256 beforeRate = special721Info[special721].rate;
        
        special721Info[special721].name = name;
        special721Info[special721].rate = rate;
        
        bool flag = true;
        for(uint i=0;i<special721Arr.length;i++){
            if(special721Arr[i] == special721){
                flag = false;
                break;
            }
        }
        if(flag){
            special721Arr[special721Arr.length] = special721;
        }

        emit SetSpecial721BorrowRateEvent(special721,msg.sender,beforeRate,rate);
    }
    
        
    function setBorrowPoolOverdueRate(uint256 pid,uint256 overdueRate) external onlyGovernance{
        CompoundBorrowPool storage _borrowPool = borrowPoolInfo[pid];
        uint256 beforeOverdueRate = _borrowPool.overdueRate;
        _borrowPool.overdueRate = overdueRate;
        emit SetBorrowPoolOverdueRateEvent(pid,msg.sender,beforeOverdueRate,overdueRate);
    }

    function setFunder(address _funder) external onlyGovernance{
        address _beforeVal = funder;
        funder = _funder;
        emit SetFunderEvent(msg.sender,_beforeVal,_funder);
    }

    
    function funderClaim(uint256 _pid,uint256 _amount) external onlyFunderVistor{

        uint256 _totalAmount = funderPoolInterest[_pid];
        require(_totalAmount >= _amount,"Wrong amount.");
        funderPoolInterest[_pid] = funderPoolInterest[_pid].sub(_amount);
        CompoundBorrowPool memory _borrowPool = borrowPoolInfo[_pid];
        checkPoolPause(_borrowPool.token);
        
        IERC20(_borrowPool.token).safeTransfer(funder,_amount);

        emit FunderClaimEvent(msg.sender,_pid,_amount);
    }
    

    function transferInterestToLend(uint256 pid,address toUser,uint256 interests) onlyLendVistor external{
        checkPoolPause(borrowPoolInfo[pid].token);

        IERC20(borrowPoolInfo[pid].token).safeTransfer(toUser,interests);
        emit TransferInterestToLendEvent(msg.sender,pid,toUser,interests);
    }
    
    function getUserMaxBorrowAmount(uint256 pid, uint256 tokenId, uint256 borrowAmount,address _user) public view returns(uint256 _maxBorrowAmount,bool _flag){
        require(checkNftV3WhiteList(tokenId),"Borrow error.Not uniswap V3 white list NFT.");
        CompoundBorrowPool memory _borrowPool = borrowPoolInfo[pid];

        (uint256 _value,) = uniswapV3Oracle.getTWAPQuoteNft(tokenId, _borrowPool.token);

        (,uint256 _borrowRate,,,,) = getUserApplyRate(_user);
  
        _maxBorrowAmount = _value.mul(_borrowRate).div(1000);
        _flag = _maxBorrowAmount >= borrowAmount;
    }
    
    function v3NFTBorrow(uint256 pid, uint256 tokenId, uint256 borrowAmount) public authContractAccessChecker nonReentrant whenNotPaused {
        require(checkNftV3WhiteList(tokenId),"Borrow error.Not uniswap V3 white list NFT.");
        BorrowUserInfo storage _user = borrowUserInfos[msg.sender][pid];
        CompoundBorrowPool memory _borrowPool = borrowPoolInfo[pid];
        checkPoolPause(_borrowPool.token);

        (uint256 _value,) = uniswapV3Oracle.getTWAPQuoteNft(tokenId, _borrowPool.token);

        require(_value > minSettingCollateral[pid],"The value of collateral is too low.");
        
        (,uint256 _borrowRate,,,,) = getUserApplyRate(msg.sender);

        
        uint256 _maxBorrowAmount = _value.mul(_borrowRate).div(1000);
        require(_maxBorrowAmount >= borrowAmount, 'Exceeds the maximum loanable amount');
        
        
        _upGobalBorrowInfo(pid,borrowAmount,1);
        
        borrowInfo.push(
            BorrowInfo({
                user: msg.sender,
                pid: pid,
                tokenId: tokenId,
                borrowValue: _value,
                auctionValue: 0,
                amount: borrowAmount,
                repaidAmount: 0,
                startBowShare: _borrowPool.globalBowShare,
                startBlock: block.number,
                returnBlock: 0,
                interests: 0,
                state: 1
            })
        );
        uint256 _bid = borrowInfo.length - 1;

        _user.currTotalBorrow = _user.currTotalBorrow.add(borrowAmount);


        if(_holderBorrowIds[msg.sender][pid].length() == 0){

            _holderBorrowPoolIds[msg.sender].add(pid);
        }
        _holderBorrowIds[msg.sender][pid].add(_bid);
        
        uniswapV3.transferFrom(msg.sender, address(this), tokenId);
        
        lendCompound.loanTransferToken(pid,msg.sender,borrowAmount);


        
        emit UserBorrow(msg.sender, tokenId, pid, _bid, _value, borrowAmount,_borrowRate,userApplyRate[msg.sender].apply721Address, block.number);
    }
    
    function userReturn(uint256 bid,uint256 repayAmount) public authContractAccessChecker nonReentrant whenNotPaused{
        BorrowInfo storage _borrowInfo = borrowInfo[bid];
        require(_borrowInfo.user == msg.sender, 'not owner');
        
        CompoundBorrowPool memory _borrowPool = borrowPoolInfo[_borrowInfo.pid];
        checkPoolPause(_borrowPool.token);
        
        BorrowUserInfo storage _user = borrowUserInfos[msg.sender][_borrowInfo.pid];
        
        uint256 _borrowInterests = _pendingReturnInterests(bid);
        require(repayAmount >= _borrowInterests,"Not enough to repay interest.");
        
        uint256 _repayAllAmount = _borrowInfo.amount.add(_borrowInterests);

        if(repayAmount > _repayAllAmount){
            repayAmount = _repayAllAmount;
        }

        uint256 _repayPrincipal = repayAmount.sub(_borrowInterests);
        
        uint256 _userBalance = IERC20(_borrowPool.token).balanceOf(msg.sender);
         require(_userBalance >= repayAmount, 'not enough amount.');

        _upGobalBorrowInfo(_borrowInfo.pid,_repayPrincipal,2);

        uint256 _platFormInterests = _borrowInterests.mul(interestPlatformRate).div(10_000);
        
        
        _updateRealReturnInterest(_borrowInfo.pid,_borrowInterests.sub(_platFormInterests));
        
        
        _user.currTotalBorrow = _user.currTotalBorrow.sub(_repayPrincipal);

        if(_repayPrincipal == _borrowInfo.amount){
            _holderBorrowIds[msg.sender][_borrowInfo.pid].remove(bid);
            if(_user.currTotalBorrow == 0){
                if(_holderBorrowIds[msg.sender][_borrowInfo.pid].length() == 0){
                    _holderBorrowPoolIds[msg.sender].remove(_borrowInfo.pid);
                }
            }
            _borrowInfo.returnBlock = block.number;
            _borrowInfo.state = 2;
            uniswapV3.transferFrom(address(this), msg.sender, _borrowInfo.tokenId);
        }else{
            _borrowInfo.amount = _borrowInfo.amount.sub(_repayPrincipal);
            _borrowInfo.startBowShare = _borrowPool.globalBowShare;
        }
        _borrowInfo.repaidAmount = _borrowInfo.repaidAmount.add(_repayPrincipal);
        _borrowInfo.interests = _borrowInfo.interests.add(_borrowInterests);

        
        IERC20(_borrowPool.token).safeTransferFrom(msg.sender, address(this), repayAmount);

        
        if(_platFormInterests > 0){
            funderPoolInterest[_borrowInfo.pid] = funderPoolInterest[_borrowInfo.pid].add(_platFormInterests);
        }

        IERC20(_borrowPool.token).safeApprove(address(lendCompound),0);
        IERC20(_borrowPool.token).safeApprove(address(lendCompound),_repayPrincipal);
        lendCompound.repayTransferToken(_borrowInfo.pid,_repayPrincipal);

        
        emit UserReturn(msg.sender, bid,_borrowInfo.pid, _repayPrincipal,_borrowInterests,_platFormInterests);
    }
    
    function applyRate(address special721,uint256 tokenId) external nonReentrant whenNotPaused{
        uint256 _confRate = special721Info[special721].rate;
        require(_confRate>0,"This 721 Contract not setting.");
        userApplyRate[msg.sender].apply721Address = special721;
        userApplyRate[msg.sender].specialMaxRate = _confRate;
        userApplyRate[msg.sender].tokenId = tokenId;
        emit ApplyRateEvent(msg.sender,special721,_confRate,tokenId);
    }

    
    
    
    function getUserApplyRate(address user) public view returns(string memory name,uint256 userMaxRate,uint256 defaultRate,uint256 tokenId,address apply721Address,bool signed){
        defaultRate = globalDefault;
        apply721Address = userApplyRate[user].apply721Address;
        signed = false;
        if(apply721Address!=address(0)){
            tokenId =  userApplyRate[user].tokenId;
            address tokenOwner = IERC721(apply721Address).ownerOf(tokenId);
            if(user == tokenOwner){
                userMaxRate = userApplyRate[user].specialMaxRate;
                signed = true;
                name = special721Info[apply721Address].name;
            }
        }
       
        if(userMaxRate == 0){
            userMaxRate = defaultRate;
        }
    }


    function transferToAuction(uint256 bid) external nonReentrant whenNotPaused{
        require(isBorrowOverdue(bid), 'can not auction now');

        BorrowInfo storage _borrowInfo = borrowInfo[bid];
        
        require(_borrowInfo.state == 1, 'borrow state error.');
        address _userAddr = _borrowInfo.user;

        CompoundBorrowPool storage _borrowPool = borrowPoolInfo[_borrowInfo.pid];
        checkPoolPause(_borrowPool.token);
        
        BorrowUserInfo storage _user = borrowUserInfos[_userAddr][_borrowInfo.pid];
        
        _borrowInfo.state = 9;

        _borrowInfo.interests = _pendingReturnInterests(bid);
        
        
        _user.currTotalBorrow = _user.currTotalBorrow.sub(_borrowInfo.amount);
        
        _holderBorrowIds[_userAddr][_borrowInfo.pid].remove(bid);
        if(_holderBorrowIds[_userAddr][_borrowInfo.pid].length() == 0){
            _holderBorrowPoolIds[_userAddr].remove(_borrowInfo.pid);
        }
        
        badDebtPrincipal[_borrowInfo.pid] = badDebtPrincipal[_borrowInfo.pid].add(_borrowInfo.amount);
        badDebtInterest[_borrowInfo.pid] = badDebtInterest[_borrowInfo.pid].add(_borrowInfo.interests);

        _upGobalBorrowInfo(_borrowInfo.pid,_borrowInfo.amount,2);
        lendCompound.transferToAuctionUpBorrow(_borrowInfo.pid,_borrowInfo.amount);
        
        
        (uint256 _value,) = uniswapV3Oracle.getTWAPQuoteNft(_borrowInfo.tokenId, _borrowPool.token);

        _borrowInfo.auctionValue = _value;
        
        IThemisAuction(themisAuction).toAuction(address(uniswapV3),_borrowInfo.tokenId,bid,_borrowPool.token,_borrowInfo.auctionValue,_borrowInfo.interests);
        
        uniswapV3.transferFrom(address(this), themisAuction, _borrowInfo.tokenId);
        
        emit TransferToAuction(bid, _borrowInfo.tokenId,_borrowInfo.pid);
    }
    
    function settlementBorrow(uint256 bid) public onlySettlementVistor nonReentrant whenNotPaused{
        BorrowInfo storage _borrowInfo = borrowInfo[bid];
        require(_borrowInfo.state == 9, 'error status');
        
    
        CompoundBorrowPool storage _borrowPool = borrowPoolInfo[_borrowInfo.pid];
        checkPoolPause(_borrowPool.token);

        _borrowInfo.state = 8;
        _borrowInfo.returnBlock = block.number;
        
        uint256 totalReturn = _borrowInfo.amount.add(_borrowInfo.interests);

        badDebtPrincipal[_borrowInfo.pid] = badDebtPrincipal[_borrowInfo.pid].sub(_borrowInfo.amount);
        badDebtInterest[_borrowInfo.pid] = badDebtInterest[_borrowInfo.pid].sub(_borrowInfo.interests);
        
        
        uint256 _platFormInterests = _borrowInfo.interests.mul(interestPlatformRate).div(10_000);
        
        
        _updateRealReturnInterest(_borrowInfo.pid,_borrowInfo.interests.sub(_platFormInterests));

        IERC20(_borrowPool.token).safeTransferFrom(msg.sender, address(this), totalReturn);

        if(_platFormInterests > 0){
            funderPoolInterest[_borrowInfo.pid] = funderPoolInterest[_borrowInfo.pid].add(_platFormInterests);
        }
        

        IERC20(_borrowPool.token).safeApprove(address(lendCompound),0);
        IERC20(_borrowPool.token).safeApprove(address(lendCompound),_borrowInfo.amount);
        lendCompound.settlementRepayTransferToken(_borrowInfo.pid,_borrowInfo.amount);
        
        emit SettlementBorrowEvent(bid, _borrowInfo.pid,_borrowInfo.amount,_borrowInfo.interests,_platFormInterests);
    }
    

    function checkNftV3WhiteList(uint256 tokenId) public view returns(bool flag) {
        (address _tokenA,address _tokenB,,,) = uniswapV3Oracle.getNFTAmounts(tokenId);
        (address _token0, address _token1) = sortTokens(_tokenA,_tokenB);
        flag = false;
        for (uint256 i = 0; i < nftV3Token0WhiteList.length; i++) {
            if(nftV3Token0WhiteList[i] == _token0 && nftV3Token1WhiteList[i] == _token1){
                flag = true;
                break;
            }
        }

    }
    
    function getSpecial721Length() external view returns(uint256){
        return special721Arr.length;
    }
    
    function pendingReturnInterests(uint256 bid) external view returns(uint256) {
        if (isBorrowOverdue(bid)) {
            return 0;
        }
       
        return _pendingReturnInterests(bid);
    }

    function checkPoolPause(address _token) public view {
        require(!hasRole(keccak256("VAR_PAUSE_POOL_ACCESS_ROLE"),_token),"This pool has been suspended.");
    }

    function _pendingReturnInterests(uint256 bid) private view returns(uint256) {

        BorrowInfo memory _borrowInfo = borrowInfo[bid];
        CompoundBorrowPool memory _borrowPool = borrowPoolInfo[_borrowInfo.pid];
        uint256 addBowShare = _calAddBowShare(_borrowPool.curBowRate,_borrowPool.lastShareBlock,block.number);
        return _borrowPool.globalBowShare.add(addBowShare).sub(_borrowInfo.startBowShare).mul(_borrowInfo.amount).div(1e12);
    }



    function getGlobalLendInterestShare(uint256 pid) external view returns(uint256 globalLendInterestShare){
        globalLendInterestShare = borrowPoolInfo[pid].globalLendInterestShare;
    }

    
    function isBorrowOverdue(uint256 bid) public view returns(bool) {
        BorrowInfo memory _borrowInfo = borrowInfo[bid];
    
        CompoundBorrowPool memory _borrowPool = borrowPoolInfo[_borrowInfo.pid];
        (uint256 _currValue,) = uniswapV3Oracle.getTWAPQuoteNft(_borrowInfo.tokenId, _borrowPool.token);
        
        uint256 auctionThreshold = _currValue.mul(_borrowPool.overdueRate).div(1000);

        
        uint256 interests = _pendingReturnInterests(bid);
        
        if (interests.add(_borrowInfo.amount) > auctionThreshold) {
            return true;
        }else{
            return false;
        }
        
    }
    
    function updateBorrowPool(uint256 pid ) external onlyLendVistor{
        _updateCompound(pid);
    }
    
    function getBorrowIdsOfOwnerAndPoolId(address owner,uint256 pid) external view returns (uint256[] memory) {
        uint256[] memory tokens = new uint256[](_holderBorrowIds[owner][pid].length());
        for (uint256 i = 0; i < _holderBorrowIds[owner][pid].length(); i++) {
            tokens[i] = _holderBorrowIds[owner][pid].at(i);
        }
        return tokens;
    }
    
    function getBorrowPoolIdsOfOwner(address owner) external view returns (uint256[] memory) {
        uint256[] memory tokens = new uint256[](_holderBorrowPoolIds[owner].length());
        for (uint256 i = 0; i < _holderBorrowPoolIds[owner].length(); i++) {
            tokens[i] = _holderBorrowPoolIds[owner].at(i);
        }
        return tokens;
    }
    
    function getFundUtilization(uint256 pid) public view returns(uint256) {
        CompoundLendPool memory _lendPool = lendCompound.lendPoolInfo(pid);
        
        if (_lendPool.curSupply.add(_lendPool.curBorrow) <= 0) {
            return 0;
        }
        return _lendPool.curBorrow.mul(1e12).div(_lendPool.curSupply.add(_lendPool.curBorrow));
    }
    
    function getBorrowingRate(uint256 pid) public view returns(uint256) {
        return getFundUtilization(pid).mul(200000000000).div(1e12).add(25000000000);
    }
    
    function getLendingRate(uint256 pid) public view returns(uint256) {
        return getFundUtilization(pid).mul(getBorrowingRate(pid)).div(1e12);
    }
    
    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'V3 NFT: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'V3 NFT: ZERO_ADDRESS');
    }
    
    
    function _upGobalBorrowInfo(uint256 pid,uint256 amount,uint optType) private{
        
        CompoundBorrowPool storage _borrowPool = borrowPoolInfo[pid];
        
        if(optType == 1){
             _borrowPool.curBorrow = _borrowPool.curBorrow.add(amount);
        }else{
             _borrowPool.curBorrow = _borrowPool.curBorrow.sub(amount);
        }
        _updateCompound(pid);
         
    }
    
    function _updateCompound(uint256 _pid) private {
        CompoundBorrowPool storage _borrowPool = borrowPoolInfo[_pid];
        if (_borrowPool.lastShareBlock >= block.number) {
            return;
        }
		uint256 addBowShare = _calAddBowShare(_borrowPool.curBowRate,_borrowPool.lastShareBlock,block.number);
 
        _borrowPool.lastShareBlock = block.number;
        _borrowPool.curBowRate = getBorrowingRate(_pid);
        _borrowPool.globalBowShare = _borrowPool.globalBowShare.add(addBowShare);

    }
    
    function _updateRealReturnInterest(uint256 _pid,uint256 _interests) private {
        if(_interests > 0){
            CompoundBorrowPool storage _borrowPool = borrowPoolInfo[_pid];
            uint256 lpSupply = ThemisFinanceToken(_borrowPool.ctoken).totalSupply();
            if (lpSupply > 0) {
                _borrowPool.globalLendInterestShare = _borrowPool.globalLendInterestShare.add(_interests.mul(1e12).div(lpSupply));
            }
        }

    }

    function _calAddBowShare(uint256 _curBowRate,uint256 _lastShareBlock,uint256 _blockNuber) pure internal returns(uint256 addBowShare){
        addBowShare = _curBowRate.mul(_blockNuber.sub(_lastShareBlock)).div(blockPerDay * 365);
    }


    
}