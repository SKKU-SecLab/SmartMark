
            

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
}




            

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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

contract DivinityCellWhitelist is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet _whitelisted_users;

    function whitelist(address toWhitelist) external onlyOwner returns(bool) {

        require(!_whitelisted_users.contains(toWhitelist), "Address is already in whitelist");
        _whitelisted_users.add(toWhitelist);
        return true;
    }

    function getWhitelist() external view returns(address[] memory) {

        return _whitelisted_users.values();
    }

    function unwhitelist(address toUnWhitelist) external onlyOwner returns(bool) {

        require(_whitelisted_users.contains(toUnWhitelist), "Address is not in whitelist");
        _whitelisted_users.remove(toUnWhitelist);
        return true;
    }

    function whitelistMany(address[] memory toWhitelist) external onlyOwner returns(bool) {

        for (uint i = 0; i < toWhitelist.length; i++) {
            _whitelisted_users.add(toWhitelist[i]);
        }
        return true;
    }

    function unwhitelistMany(address[] memory toUnWhitelist) external onlyOwner returns(bool) {

        for (uint i = 0; i < toUnWhitelist.length; i++) {
            _whitelisted_users.remove(toUnWhitelist[i]);
        }
        return true;
    }

    function is_whitelisted(address account) public view returns(bool) {

        return _whitelisted_users.contains(account);
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

    event Premint(address indexed _to, uint256 indexed start_id, uint256 indexed count);
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

    function _mint_many(address to, uint256 first_tokenId, uint256 count) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(first_tokenId), "ERC721: token already minted");
        uint256 last_id = first_tokenId + count;

        for (uint256 i = first_tokenId; i <  last_id; i++) {
            _mint(to, i);
        }
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



contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract DivinityCellNFT is ERC721, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    string base_url;
    address burner;
    address _minter;
    address proxyRegistryAddress;
    Counters.Counter _nextTokenId;
    
    modifier onlyBurner {
        require(msg.sender == burner, "DivinityCellNFT: Sender must have burner role");
        _;
    }

    modifier onlyMinter {
        require(msg.sender == _minter, "DivinityCellNFT: Sender is not auction");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory token_url,
        address _proxyRegistryAddress
    ) ERC721(_name, _symbol) {
        base_url = token_url;
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function isTokenOwner(uint256 tokenId, address account) external view returns(bool) {
        return ERC721.ownerOf(tokenId) == account;
    }

    function mintTo(address recipient) external onlyMinter returns(uint256) {
        uint256 currentTokenId = _nextTokenId.current();
        _nextTokenId.increment();
        _safeMint(recipient, currentTokenId);
        return currentTokenId;
    }
     
    function premint(address account, uint256 count) external onlyMinter returns(bool) {
        uint256 currentTokenId = _nextTokenId.current();
        ERC721._mint_many(account, currentTokenId, count);
        _nextTokenId._value += count;
        return true;
    }
    
    function registerMinterContract(address minter) external onlyOwner returns(bool){
        _minter = minter;
        return true;
    }

    function totalSupply() external view returns (uint256) {
        return _nextTokenId.current();
    }

    function setURI(string memory baseUrl) external onlyOwner returns (bool) {
        base_url = baseUrl;

        return true;
    }

    function URI() public view returns (string memory) {
        return base_url;
    }

    function tokenURI(uint256 _tokenId) override public view returns (string memory) {
        return string(abi.encodePacked(URI(), Strings.toString(_tokenId)));
    }

    function setBurner(address newBurner) external onlyOwner returns(bool) {
        burner = newBurner;
        return true;
    }

    function burn(uint256 tokenId) external onlyBurner returns(bool) {
        _burn(tokenId);
        return true;
    } 
    
    function exists(uint256 tokenId) external view returns(bool) {
        return ERC721._exists(tokenId);
    }

    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}   




            

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
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

contract DivinityCellMinter is ReentrancyGuard, Ownable, Pausable, DivinityCellWhitelist {
    using SafeMath for uint256;

    uint256 public tokens_limit;
    
    uint256 public tokens_this_sale = 0;
    uint32 public buy_limit;
    uint32 current_sale_id = 0;
    uint256 public mint_price;

    uint256 public sale_end_timestamp = 0;
    uint256 public sale_start_timestamp = 0;

    bool public is_sell_private = true;

    mapping(uint => mapping(address => uint)) bought_current_sell;
    address nft_contract;
    address whitelist_contract;

    function boughtCurrentSale(address account) public view returns(uint) {
        return bought_current_sell[current_sale_id][account];
    }

    modifier minterAllowed {
        if (is_sell_private) {
            require(block.timestamp < sale_end_timestamp, "DivinityCellAuction: Sale ended");
            if (mint_price == 0) {
                require(DivinityCellWhitelist(whitelist_contract).is_whitelisted(msg.sender), "DivinityCellAuction: Account is not whitelisted");
            } else {
                require(is_whitelisted(msg.sender), "DivinityCellAuction: Account is not whitelisted");
            }
        }
        _;
    }

    modifier onlyIfNoSale {
        require(sale_start_timestamp < block.timestamp, "DivinityCellAuction: New sale is about to start");

        if (tokens_this_sale != 0) {
            require(sale_end_timestamp < block.timestamp, "DivinityCellAuction: Private sale still continues");
        }
        _;
    }

    constructor(address nft, address whitelist, uint32 tokens_count, uint256 initial_mint_price) {
        tokens_limit = tokens_count;
        nft_contract = nft;
        whitelist_contract = whitelist;
        mint_price = initial_mint_price;
    }

    function collectETH(address payable _to) external onlyOwner payable returns(bool) {
        (bool sent,) = _to.call{value: address(this).balance}("");
        require(sent, "DivinityCellAuction: Failed to send Ether");
        return true;
    }

    function setPrice(uint256 new_mint_price) external onlyOwner returns(bool) {
        mint_price = new_mint_price;
        return true;
    }

    function startPrivateSale(uint32 per_user_limitation, uint256 tokens_count, uint256 new_sale_start_timestamp, uint256 new_sale_end_timestamp) external onlyOwner onlyIfNoSale returns(bool) {
        require(tokens_limit >= tokens_count, "DivinityCellAuction: Cant sell that much tokens");
        require(new_sale_end_timestamp > block.timestamp, "DivinityCellAuction: Wrong timestamp passed");
        require(new_sale_start_timestamp < new_sale_end_timestamp, "DivinityCellAuction: Start date should be less than end date");
        require(per_user_limitation > 0, "DivinityCellAuction: Wrong limitation passed");
        require(tokens_count > 0, "DivinityCellAuction: Wrong token count passed");

        tokens_this_sale = tokens_count;
        buy_limit  = per_user_limitation;
        sale_end_timestamp = new_sale_end_timestamp;
        sale_start_timestamp = new_sale_start_timestamp;
        current_sale_id += 1;
        is_sell_private = true;
        
        return true;
    }
    
    function reschedulePrivateSale(uint256 new_sale_start_timestamp, uint256 new_sale_end_timestamp) external onlyOwner returns(bool) {
        require(new_sale_start_timestamp < new_sale_end_timestamp, "DivinityCellAuction: Start date should be less than end date");
        require(tokens_this_sale > 0, "DivinityCellAuction: No tokens left");

        sale_end_timestamp = new_sale_end_timestamp;
        sale_start_timestamp = new_sale_start_timestamp;

        return true;
    } 
    
    function startPublicSale(uint32 per_user_limitation, uint256 tokens_count, uint256 new_sale_start_timestamp) external onlyOwner onlyIfNoSale returns(bool) {
        require(tokens_limit >= tokens_count, "DivinityCellAuction: Cant sell that much tokens");
        require(tokens_limit > 0, "DivinityCellAuction: Cant sell that much tokens");
        require(per_user_limitation > 0, "DivinityCellAuction: Wrong limitation passed");
        
        tokens_this_sale = tokens_count;
        sale_start_timestamp = new_sale_start_timestamp;
        buy_limit  = per_user_limitation;
        current_sale_id += 1;
        is_sell_private = false;
        
        return true;
    }
    
    function reschedulePublicSale(uint256 new_sale_start_timestamp) external onlyOwner returns(bool) {
        require(sale_end_timestamp < block.timestamp, "DivinityCellAuction: Private sale continues");
        require(tokens_this_sale > 0, "DivinityCellAuction: No tokens left");

        sale_start_timestamp = new_sale_start_timestamp;

        return true;
    } 
    
    function pause() public onlyOwner {
        Pausable._pause();
    }

    function unpause() public onlyOwner {
        Pausable._unpause();
    }

    function mint(uint256 amount) public payable whenNotPaused minterAllowed nonReentrant returns(bool) {
        uint256 userLimit = getMintLimit();
        require(userLimit > 0, "DivinityCellAuction: This recipient cant buy more tokens this sale");
        require(amount > 0, "DivinityCellAuction: Invalid amount");
        require(block.timestamp >= sale_start_timestamp, "DivinityCellAuction: Sale hasn't started yet");

        uint256 count = Math.min(amount, userLimit);
        require(msg.value == mint_price * count, "DivinityCellAuction: Wrong amount of eth sent");
        require(tokens_this_sale >= count, "DivinityCellAuction: Nothing to sell");
        require(tokens_limit >= count, "DivinityCellAuction: Nothing to sell");

        bool isMinted = DivinityCellNFT(nft_contract).premint(msg.sender, count);
        require(isMinted, "DivinityCellAuction: mint failed");
        bought_current_sell[current_sale_id][msg.sender] += count;
        tokens_this_sale -= count;
        tokens_limit -= count;

        return isMinted;
    }
    
    function premint(address account, uint256 count) external onlyOwner nonReentrant returns(bool) {
        require(tokens_limit >= count, "DivinityCellAuction: can't mint that much tokens");
        bool is_premnt_successful = DivinityCellNFT(nft_contract).premint(account, count);
        require(is_premnt_successful, "DivinityCellAuction: premint was unsuccessful");
        tokens_limit -= count;
        return is_premnt_successful;
    }



    function getMintLimit() internal view returns(uint) {
        if (is_sell_private) {
            uint bought = boughtCurrentSale(msg.sender);
            if (mint_price == 0) {
                if (bought > 0) {
                    return 0;
                }
                uint256 holdings = DivinityCellNFT(nft_contract).balanceOf(msg.sender);
                if (holdings >= 5) {
                    return 2;
                } 
                if (holdings >= 3) {
                    return 1;
                } 
                return 0;
            }
            return buy_limit - bought;
        }

        return 5;
    }
}