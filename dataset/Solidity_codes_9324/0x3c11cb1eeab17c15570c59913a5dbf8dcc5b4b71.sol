
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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

}// MIT


pragma solidity 0.8.9;


contract Component is ERC721, ReentrancyGuard, Ownable {
    using Strings for uint256;

    using Counters for Counters.Counter;

    Counters.Counter private _supply;

    address public projectAddress;

    address public openSeaProxyContractAddress = 0xa5409ec958C83C3f309868babACA7c86DCB077c1;

    string public baseURI;

    string public baseExtension = "";

    string public provenanceHash;

    mapping(uint256 => uint256) private _tokenIdCache;
    uint256 public remainingTokenCount = 10000;

    uint256 public tokenStartId = 0;

    constructor (
        string memory _name,
        string memory _symbol,
        uint256 _tokenStartId
    ) ERC721(_name, _symbol) {
        tokenStartId = _tokenStartId;
    }

    modifier onlyProject () {
        require(_msgSender() == projectAddress, "Only the parent Project contract can call this method");
        _;
    }

    function _baseURI () internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setProjectAddress (address _newAddr) external onlyOwner {
        projectAddress = _newAddr;
    }

    function setBaseURI (string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension (string memory _newBaseExtension) external onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setTokenStartId (uint256 _newId) external onlyOwner {
        tokenStartId = _newId;
    }

    function setProvenanceHash (string memory _newHash) external onlyOwner {
        provenanceHash = _newHash;
    }

    function setOpenSeaProxyAddress (address _newAddress) external onlyOwner {
        openSeaProxyContractAddress = _newAddress;
    }

    function tokenURI (uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "Query for non-existent token");

        string memory currentBaseURI = _baseURI();

        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), baseExtension))
            : "";
    }

    function totalSupply () public view returns (uint256) {
        return _supply.current();
    }

    function mint (address _to, uint256 _numToMint) public nonReentrant onlyProject {
        _mintLoop(_to, _numToMint);
    }

    function _mintLoop (address _to, uint256 _numToMint) private {
        for (uint256 i = 0; i < _numToMint; i++) {
            uint256 tokenId = drawTokenId();

            _safeMint(_to, tokenId);

            _supply.increment();
        }
    }

    function drawTokenId () private returns (uint256) {
        uint256 num = uint256(
            keccak256(
                abi.encode(
                    _msgSender(),
                    name(),
                    symbol(),
                    blockhash(block.number - 1),
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    tx.gasprice,
                    remainingTokenCount,
                    projectAddress
                )
            )
        );

        uint256 index = num % remainingTokenCount;

        uint256 tokenId = _tokenIdCache[index] == 0
            ? index
            : _tokenIdCache[index];

        _tokenIdCache[index] = _tokenIdCache[remainingTokenCount - 1] == 0
            ? remainingTokenCount - 1
            : _tokenIdCache[remainingTokenCount - 1];

        remainingTokenCount = remainingTokenCount - 1;

        return tokenId + tokenStartId;
    }

    function exists (uint256 _tokenId) public view returns (bool) {
        return _exists(_tokenId);
    }

    function isApprovedForAll (address _owner, address _operator) public override view returns (bool) {
        if (openSeaProxyContractAddress != address(0)) {
            ProxyRegistry proxyRegistry = ProxyRegistry(openSeaProxyContractAddress);

            if (address(proxyRegistry.proxies(_owner)) == _operator) {
                return true;
            }
        }

        return super.isApprovedForAll(_owner, _operator);
    }
}

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}// MIT



pragma solidity 0.8.9;


contract Bodies is Component {
    constructor (
        string memory _name,
        string memory _symbol,
        uint256 _tokenStartId
    ) Component(_name, _symbol, _tokenStartId) {}
}// MIT



pragma solidity 0.8.9;


contract Legs is Component {
    constructor (
        string memory _name,
        string memory _symbol,
        uint256 _tokenStartId
    ) Component(_name, _symbol, _tokenStartId) {}
}// GPL-3.0




pragma solidity 0.8.9;



contract Project is ReentrancyGuard, Ownable, PaymentSplitter {
    event StatusChange(Status _newStatus);

    enum Status {
        Paused,
        Whitelist,
        Mintpass,
        Public
    }

    Status public status;

    Bodies public bodies;

    Legs public legs;

    uint256 public whitelistPrice = 0.02 ether;
    uint256 public mintpassPrice = 0.02 ether;
    uint256 public publicPrice = 0.04 ether;

    uint256 public whitelistMintLimit = 4;
    uint256 public mintpassMintLimit = 20;
    uint256 public publicMintLimit = 40;

    uint256 public maxFreeSupply = 250;

    uint256 public maxSupply = 10000;

    address[] public mintpassedContracts;

    bytes32 public merkleRoot = 0x05ba199ba71527baf0f85acf24728a2e559447f3228c1ff56d0d90f8bb269f7d;

    constructor (
        string memory _name,
        string memory _symbol,
        uint256 _tokenStartId,
        address[] memory _payees,
        uint256[] memory _shares,
        bool _deployComponents
    ) PaymentSplitter(_payees, _shares) {
        if (_deployComponents) {
            bodies = new Bodies(
                string(abi.encodePacked(_name, ": Bodies")), // Extend name.
                string(abi.encodePacked(_symbol, "B")), // Extend symbol.
                _tokenStartId
            );

            bodies.setProjectAddress(address(this));

            bodies.transferOwnership(_msgSender());

            legs = new Legs(
                string(abi.encodePacked(_name, ": Legs")), // Extend name.
                string(abi.encodePacked(_symbol, "L")), // Extend symbol.
                _tokenStartId
            );

            legs.setProjectAddress(address(this));

            legs.transferOwnership(_msgSender());
        }
    }

    modifier mintCheck (address _to, uint256 _numToMint, uint256 _mintpassTokenId) {
        require(status != Status.Paused, "Minting is paused");

        require(_to == _msgSender(), "Can only mint for self");

        require(!Address.isContract(_msgSender()), "Cannot mint from contract");

        require(_numToMint > 0, "Cannot mint zero tokens");

        require(totalSupply() + _numToMint <= maxSupply, "Max supply exceeded");

        require(_numToMint <= mintLimit(), "Cannot mint this many tokens");

        require(msg.value == _numToMint * mintPrice(_to, _mintpassTokenId), "Incorrect payment amount sent");

        _;
    }

    function setPrice (Status _status, uint256 _newPrice) external onlyOwner {
        if (_status == Status.Whitelist) {
            whitelistPrice = _newPrice;
        }

        if (_status == Status.Mintpass) {
            mintpassPrice = _newPrice;
        }

        if (_status == Status.Public) {
            publicPrice = _newPrice;
        }
    }

    function setMintLimit (Status _status, uint256 _newLimit) external onlyOwner {
        if (_status == Status.Whitelist) {
            whitelistMintLimit = _newLimit;
        }

        if (_status == Status.Mintpass) {
            mintpassMintLimit = _newLimit;
        }

        if (_status == Status.Public) {
            publicMintLimit = _newLimit;
        }
    }

    function setFreeMintMaxSupply (uint256 _newSupply) external onlyOwner {
        maxFreeSupply = _newSupply;
    }

    function setBodies (address _newAddr) external onlyOwner {
        bodies = Bodies(_newAddr);
    }

    function setLegs (address _newAddr) external onlyOwner {
        legs = Legs(_newAddr);
    }

    function setMerkleRoot (bytes32 _newRoot) external onlyOwner {
        merkleRoot = _newRoot;
    }

    function setStatus (Status _newStatus) external onlyOwner {
        status = _newStatus;

        emit StatusChange(_newStatus);
    }

    function setMintpassedContracts (address[] calldata _newAddrs) external onlyOwner {
        delete mintpassedContracts;
        mintpassedContracts = _newAddrs;
    }

    function addMintpassedContract (address _addr) external onlyOwner {
        mintpassedContracts.push(_addr);
    }

    function isWhitelistedAddress (address _addr, bytes32[] calldata _merkleProof) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_addr));
        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }

    function isMintpassedAddress (address _addr, uint256 _mintpassTokenId) public view returns (bool) {
        uint256 len = mintpassedContracts.length;

        for (uint256 i = 0; i < len; i++) {
            address _contractAddr = mintpassedContracts[i];

            MintpassedContract mintpassedContract = MintpassedContract(_contractAddr);

            if (
                _contractAddr == 0x0144B7e66993C6BfaB85581e8601f96BFE50c9Df
                ||
                _contractAddr == 0xdeA38D5252Fd794CcE5d21BB131b78f287E686B3
            ) {
                if (mintpassedContract.ownerOf(_mintpassTokenId) == _addr) {
                    return true;
                }
            } else {
                if (mintpassedContract.balanceOf(_addr) > 0) {
                    return true;
                }
            }
        }

        return false;
    }

    function totalSupply () public view returns (uint256) {
        return bodies.totalSupply();
    }

    function balanceOf (address _owner) public view returns (uint256) {
        return bodies.balanceOf(_owner);
    }

    function mintPrice (address _to, uint256 _mintpassTokenId) public view returns (uint256) {
        if (status == Status.Paused) {
            return 1000000 ether;
        }

        if (totalSupply() < maxFreeSupply) {
            return 0;
        }

        if (status == Status.Whitelist) {
            return whitelistPrice;
        }

        if (status == Status.Mintpass) {
            return mintpassPrice;
        }

        return isMintpassedAddress(_to, _mintpassTokenId) ? mintpassPrice : publicPrice;
    }

    function mintLimit () public view returns (uint256) {
        if (status == Status.Paused) {
            return 0;
        }

        if (status == Status.Whitelist) {
            return whitelistMintLimit;
        }

        if (status == Status.Mintpass) {
            return mintpassMintLimit;
        }

        return publicMintLimit;
    }

    function mint (address _to, uint256 _numToMint, uint256 _mintpassTokenId) external payable nonReentrant mintCheck(_to, _numToMint, _mintpassTokenId) {
        require(status != Status.Whitelist, "Whitelist mints must provide proof via mintWhitelist()");

        if (status == Status.Mintpass) {
            require((balanceOf(_to) + _numToMint) <= mintLimit(), "Mintpass mint limit exceeded");

            require(totalSupply() + _numToMint <= maxFreeSupply, "Max free supply exceeded");

            require(isMintpassedAddress(_to, _mintpassTokenId), "Address is not mintpassed");
        }

        _mint(_to, _numToMint);
    }

    function mintWhitelist (address _to, uint256 _numToMint, bytes32[] calldata _merkleProof, uint256 _mintpassTokenId) external payable nonReentrant mintCheck(_to, _numToMint, _mintpassTokenId) {
        require(status == Status.Whitelist, "Whitelist mints only");

        require((balanceOf(_to) + _numToMint) <= mintLimit(), "Whitelist mint limit exceeded");

        require(isWhitelistedAddress(_to, _merkleProof), "Address is not whitelisted");

        _mint(_to, _numToMint);
    }

    function _mint (address _to, uint256 _numToMint) private {
        bodies.mint(_to, _numToMint);
        legs.mint(_to, _numToMint);
    }
}

interface MintpassedContract {
    function balanceOf(address _account) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}