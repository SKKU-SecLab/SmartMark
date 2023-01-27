
pragma solidity 0.6.8;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity 0.6.8;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity 0.6.8;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage)
        internal
        pure
        returns (uint256)
    {

        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.6.8;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

pragma solidity 0.6.8;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal
        virtual
    {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount)
        internal
        virtual
    {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _changeName(string memory name_) internal {

        _name = name_;
    }

    function _changeSymbol(string memory symbol_) internal {

        _symbol = symbol_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
    {}

}

pragma solidity ^0.6.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity ^0.6.2;


interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

pragma solidity ^0.6.2;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

pragma solidity ^0.6.2;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

pragma solidity ^0.6.0;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity ^0.6.0;


contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

pragma solidity 0.6.8;

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


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint256(_at(set._inner, index)));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

pragma solidity ^0.6.0;

library EnumerableMap {

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}

pragma solidity ^0.6.0;

library Strings {
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

pragma solidity ^0.6.0;


contract ERC721 is
    Context,
    ERC165,
    IERC721,
    IERC721Metadata,
    IERC721Enumerable
{
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping(address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return
            _tokenOwners.get(
                tokenId,
                "ERC721: owner query for nonexistent token"
            );
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index)
        public
        view
        override
        returns (uint256)
    {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId)
        public
        virtual
        override
    {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId)
        public
        virtual
        override
    {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data)
        internal
        virtual
    {
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

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId)
        internal
        virtual
    {
        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(
            abi.encodeWithSelector(
                IERC721Receiver(to).onERC721Received.selector,
                _msgSender(),
                from,
                tokenId,
                _data
            ),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        virtual
    {}
}

pragma solidity 0.6.8;


contract TokenMultiCall {
    function getErc20Data(address addr)
        public
        view
        returns (string memory name, string memory symbol, uint256 totalSupply)
    {
        ERC20 erc20 = ERC20(addr);
        string memory _name = erc20.name();
        string memory _symbol = erc20.symbol();
        uint256 _totalSupply = erc20.totalSupply();

        return (_name, _symbol, _totalSupply);
    }

    function getErc721Data(address addr)
        public
        view
        returns (string memory name, string memory symbol)
    {
        ERC721 erc721 = ERC721(addr);
        string memory _name = erc721.name();
        string memory _symbol = erc721.symbol();

        return (_name, _symbol);
    }

    function getErc20And721Data(address erc20Addr, address erc721Addr)
        public
        view
        returns (
            string memory erc20Name,
            string memory erc20Symbol,
            uint256 erc20TotalSupply,
            string memory erc721name,
            string memory erc721symbol
        )
    {
        (string memory _erc20Name, string memory _erc20Symbol, uint256 _erc20TotalSupply) = getErc20Data(
            erc20Addr
        );
        (string memory _erc721Name, string memory _erc721Symbol) = getErc721Data(
            erc721Addr
        );

        return (
            _erc20Name,
            _erc20Symbol,
            _erc20TotalSupply,
            _erc721Name,
            _erc721Symbol
        );
    }

    function getDoubleErc20Data(address addr1, address addr2)
        public
        view
        returns (
            string memory name1,
            string memory symbol1,
            uint256 totalSupply1,
            string memory name2,
            string memory symbol2,
            uint256 totalSupply2
        )
    {
        (string memory _name1, string memory _symbol1, uint256 _totalSupply1) = getErc20Data(
            addr1
        );
        (string memory _name2, string memory _symbol2, uint256 _totalSupply2) = getErc20Data(
            addr2
        );

        return (
            _name1,
            _symbol1,
            _totalSupply1,
            _name2,
            _symbol2,
            _totalSupply2
        );
    }

}

pragma solidity >=0.4.24 <0.7.0;

contract Initializable {
    bool private initialized;

    bool private initializing;

    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

pragma solidity 0.6.8;


contract Ownable is Context, Initializable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function initOwnable() internal virtual initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.6.8;


contract Timelocked is Ownable {
    using SafeMath for uint256;

    uint256 public shortDelay;
    uint256 public mediumDelay;
    uint256 public longDelay;

    function setDelays(
        uint256 _shortDelay,
        uint256 _mediumDelay,
        uint256 _longDelay
    ) internal virtual {
        shortDelay = _shortDelay;
        mediumDelay = _mediumDelay;
        longDelay = _longDelay;
    }

    function timeInDays(uint256 num) internal pure returns (uint256) {
        return num * 60 * 60 * 24;
    }

    function getDelay(uint256 delayIndex) public view returns (uint256) {
        if (delayIndex == 0) {
            return shortDelay;
        } else if (delayIndex == 1) {
            return mediumDelay;
        } else if (delayIndex == 2) {
            return longDelay;
        }
    }

    function onlyIfPastDelay(uint256 delayIndex, uint256 startTime)
        internal
        view
    {
        require(1 >= startTime.add(getDelay(delayIndex)), "Delay not over");
    }
}

pragma solidity 0.6.8;


abstract contract ControllerBase is Timelocked {
    using SafeMath for uint256;

    address public leadDev;

    uint256 numFuncCalls;

    mapping(uint256 => uint256) public time;
    mapping(uint256 => uint256) public funcIndex;
    mapping(uint256 => address payable) public addressParam;
    mapping(uint256 => uint256[]) public uintArrayParam;

    function transferOwnership(address newOwner) public override virtual {
        uint256 fcId = numFuncCalls;
        numFuncCalls = numFuncCalls.add(1);
        time[fcId] = now;
        funcIndex[fcId] = 0;
        addressParam[fcId] = payable(newOwner);
    }

    function initialize() public initializer {
        initOwnable();
    }

    function setLeadDev(address newLeadDev) public virtual onlyOwner {
        leadDev = newLeadDev;
    }

    function stageFuncCall(
        uint256 _funcIndex,
        address payable _addressParam,
        uint256[] memory _uintArrayParam
    ) public virtual onlyOwner {
        uint256 fcId = numFuncCalls;
        numFuncCalls = numFuncCalls.add(1);
        time[fcId] = now;
        funcIndex[fcId] = _funcIndex;
        addressParam[fcId] = _addressParam;
        uintArrayParam[fcId] = _uintArrayParam;
    }

    function cancelFuncCall(uint256 fcId) public virtual onlyOwner {
        funcIndex[fcId] = 0;
    }

    function executeFuncCall(uint256 fcId) public virtual {
        if (funcIndex[fcId] == 0) {
            return;
        } else if (funcIndex[fcId] == 1) {
            require(
                    uintArrayParam[fcId][2] >= uintArrayParam[fcId][1] &&
                        uintArrayParam[fcId][1] >= uintArrayParam[fcId][0],
                    "Invalid delays"
                );
            if (uintArrayParam[fcId][2] != longDelay) {
                onlyIfPastDelay(2, time[fcId]);
            } else if (uintArrayParam[fcId][1] != mediumDelay) {
                onlyIfPastDelay(1, time[fcId]);
            } else {
                onlyIfPastDelay(0, time[fcId]);
            }
            setDelays(
                uintArrayParam[fcId][0],
                uintArrayParam[fcId][1],
                uintArrayParam[fcId][2]
            );
        } else if (funcIndex[fcId] == 2) {
            onlyIfPastDelay(1, time[fcId]);
            Ownable.transferOwnership(addressParam[fcId]);
        }
    }
}

pragma solidity 0.6.8;

contract Counter {
    uint256 internal number;

    function getNumber() public view returns (uint256) {
        return number;
    }

    function increaseNumberBy(uint256 amount) public {
        number += amount;
    }

}

pragma solidity 0.6.8;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
            amount,
            "ERC20: burn amount exceeds allowance"
        );

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

pragma solidity 0.6.8;


contract D2Token is Context, Ownable, ERC20Burnable {
    address private vaultAddress;

    constructor(string memory name, string memory symbol)
        public
        ERC20(name, symbol)
    {
        initOwnable();
        _mint(msg.sender, 0);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

pragma solidity ^0.6.0;


contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

pragma solidity 0.6.8;


contract ERC721Public is Context, ERC721 {
    uint256 public minTokenId;
    uint256 public maxTokenId;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _minTokenId,
        uint256 _maxTokenId
    ) public ERC721(name, symbol) {
        minTokenId = _minTokenId;
        maxTokenId = _maxTokenId;
    }

    function mint(uint256 tokenId, address recipient) public {
        require(tokenId >= minTokenId, "tokenId < minTokenId");
        require(tokenId <= maxTokenId, "tokenId > maxTokenId");
        _mint(recipient, tokenId);
    }

}

pragma solidity ^0.6.2;


interface IERC721Plus is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

pragma solidity 0.6.8;


contract Pausable is Ownable {
    mapping(uint256 => bool) isPaused;

    function onlyOwnerIfPaused(uint256 pauserId) public view virtual {
        require(!isPaused[pauserId] || msg.sender == owner(), "Paused");
    }

    function setPaused(uint256 pauserId, bool _isPaused)
        public
        virtual
        onlyOwner
    {
        isPaused[pauserId] = _isPaused;
    }
}

pragma solidity 0.6.8;


interface IXToken is IERC20 {
    function owner() external returns (address);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function mint(address to, uint256 amount) external;

    function changeName(string calldata name) external;

    function changeSymbol(string calldata symbol) external;

    function setVaultAddress(address vaultAddress) external;

    function transferOwnership(address newOwner) external;
}

pragma solidity 0.6.8;


contract ReentrancyGuard is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function initReentrancyGuard() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

pragma solidity 0.6.8;


interface INFTX {
    event NFTsDeposited(uint256 vaultId, uint256[] nftIds, address from);
    event NFTsRedeemed(uint256 vaultId, uint256[] nftIds, address to);
    event TokensMinted(uint256 vaultId, uint256 amount, address to);
    event TokensBurned(uint256 vaultId, uint256 amount, address from);

    event EligibilitySet(uint256 vaultId, uint256[] nftIds, bool _boolean);
    event ReservesIncreased(uint256 vaultId, uint256 nftId);
    event ReservesDecreased(uint256 vaultId, uint256 nftId);

    function store() external returns (address);

    function transferOwnership(address newOwner) external;

    function vaultSize(uint256 vaultId) external view returns (uint256);

    function isEligible(uint256 vaultId, uint256 nftId)
        external
        view
        returns (bool);

    function createVault(address _erc20Address, address _nftAddress)
        external
        returns (uint256);

    function depositETH(uint256 vaultId) external payable;

    function setIsEligible(
        uint256 vaultId,
        uint256[] calldata nftIds,
        bool _boolean
    ) external;

    function setNegateEligibility(uint256 vaultId, bool shouldNegate) external;

    function setShouldReserve(
        uint256 vaultId,
        uint256[] calldata nftIds,
        bool _boolean
    ) external;

    function setIsReserved(
        uint256 vaultId,
        uint256[] calldata nftIds,
        bool _boolean
    ) external;

    function setExtension(address contractAddress, bool _boolean) external;

    function directRedeem(uint256 vaultId, uint256[] calldata nftIds)
        external
        payable;

    function mint(uint256 vaultId, uint256[] calldata nftIds, uint256 d2Amount)
        external
        payable;

    function redeem(uint256 vaultId, uint256 numNFTs) external payable;

    function mintAndRedeem(uint256 vaultId, uint256[] calldata nftIds)
        external
        payable;

    function changeTokenName(uint256 vaultId, string calldata newName) external;

    function changeTokenSymbol(uint256 vaultId, string calldata newSymbol)
        external;

    function setManager(uint256 vaultId, address newManager) external;

    function finalizeVault(uint256 vaultId) external;

    function closeVault(uint256 vaultId) external;

    function setMintFees(uint256 vaultId, uint256 _ethBase, uint256 _ethStep)
        external;

    function setBurnFees(uint256 vaultId, uint256 _ethBase, uint256 _ethStep)
        external;

    function setDualFees(uint256 vaultId, uint256 _ethBase, uint256 _ethStep)
        external;

    function setSupplierBounty(uint256 vaultId, uint256 ethMax, uint256 length)
        external;
}

pragma solidity 0.6.8;

interface ITokenManager {
    function mint(address _receiver, uint256 _amount) external;
    function issue(uint256 _amount) external;
    function assign(address _receiver, uint256 _amount) external;
    function burn(address _holder, uint256 _amount) external;
    function assignVested(
        address _receiver,
        uint256 _amount,
        uint64 _start,
        uint64 _cliff,
        uint64 _vested,
        bool _revokable
    ) external returns (uint256);
    function revokeVesting(address _holder, uint256 _vestingId) external;
}

pragma solidity ^0.6.0;

interface ITransparentUpgradeableProxy {
    function admin() external returns (address);

    function implementation() external returns (address);

    function changeAdmin(address newAdmin) external;

    function upgradeTo(address newImplementation) external;

    function upgradeToAndCall(address newImplementation, bytes calldata data)
        external
        payable;
}

pragma solidity 0.6.8;


interface IXStore {
    struct FeeParams {
        uint256 ethBase;
        uint256 ethStep;
    }

    struct BountyParams {
        uint256 ethMax;
        uint256 length;
    }

    struct Vault {
        address xTokenAddress;
        address nftAddress;
        address manager;
        IXToken xToken;
        IERC721 nft;
        EnumerableSet.UintSet holdings;
        EnumerableSet.UintSet reserves;
        mapping(uint256 => address) requester;
        mapping(uint256 => bool) isEligible;
        mapping(uint256 => bool) shouldReserve;
        bool allowMintRequests;
        bool flipEligOnRedeem;
        bool negateEligibility;
        bool isFinalized;
        bool isClosed;
        FeeParams mintFees;
        FeeParams burnFees;
        FeeParams dualFees;
        BountyParams supplierBounty;
        uint256 ethBalance;
        uint256 tokenBalance;
        bool isD2Vault;
        address d2AssetAddress;
        IERC20 d2Asset;
        uint256 d2Holdings;
    }

    function isExtension(address addr) external view returns (bool);

    function randNonce() external view returns (uint256);

    function vaultsLength() external view returns (uint256);

    function xTokenAddress(uint256 vaultId) external view returns (address);

    function nftAddress(uint256 vaultId) external view returns (address);

    function manager(uint256 vaultId) external view returns (address);

    function xToken(uint256 vaultId) external view returns (IXToken);

    function nft(uint256 vaultId) external view returns (IERC721);

    function holdingsLength(uint256 vaultId) external view returns (uint256);

    function holdingsContains(uint256 vaultId, uint256 elem)
        external
        view
        returns (bool);

    function holdingsAt(uint256 vaultId, uint256 index)
        external
        view
        returns (uint256);

    function reservesLength(uint256 vaultId) external view returns (uint256);

    function reservesContains(uint256 vaultId, uint256 elem)
        external
        view
        returns (bool);

    function reservesAt(uint256 vaultId, uint256 index)
        external
        view
        returns (uint256);

    function requester(uint256 vaultId, uint256 id)
        external
        view
        returns (address);

    function isEligible(uint256 vaultId, uint256 id)
        external
        view
        returns (bool);

    function shouldReserve(uint256 vaultId, uint256 id)
        external
        view
        returns (bool);

    function allowMintRequests(uint256 vaultId) external view returns (bool);

    function flipEligOnRedeem(uint256 vaultId) external view returns (bool);

    function negateEligibility(uint256 vaultId) external view returns (bool);

    function isFinalized(uint256 vaultId) external view returns (bool);

    function isClosed(uint256 vaultId) external view returns (bool);

    function mintFees(uint256 vaultId) external view returns (uint256, uint256);

    function burnFees(uint256 vaultId) external view returns (uint256, uint256);

    function dualFees(uint256 vaultId) external view returns (uint256, uint256);

    function supplierBounty(uint256 vaultId)
        external
        view
        returns (uint256, uint256);

    function ethBalance(uint256 vaultId) external view returns (uint256);

    function tokenBalance(uint256 vaultId) external view returns (uint256);

    function isD2Vault(uint256 vaultId) external view returns (bool);

    function d2AssetAddress(uint256 vaultId) external view returns (address);

    function d2Asset(uint256 vaultId) external view returns (IERC20);

    function d2Holdings(uint256 vaultId) external view returns (uint256);

    function setXTokenAddress(uint256 vaultId, address _xTokenAddress) external;

    function setNftAddress(uint256 vaultId, address _assetAddress) external;

    function setManager(uint256 vaultId, address _manager) external;

    function setXToken(uint256 vaultId) external;

    function setNft(uint256 vaultId) external;

    function holdingsAdd(uint256 vaultId, uint256 elem) external;

    function holdingsRemove(uint256 vaultId, uint256 elem) external;

    function reservesAdd(uint256 vaultId, uint256 elem) external;

    function reservesRemove(uint256 vaultId, uint256 elem) external;

    function setRequester(uint256 vaultId, uint256 id, address _requester)
        external;

    function setIsEligible(uint256 vaultId, uint256 id, bool _bool) external;

    function setShouldReserve(uint256 vaultId, uint256 id, bool _shouldReserve)
        external;

    function setAllowMintRequests(uint256 vaultId, bool isAllowed) external;

    function setFlipEligOnRedeem(uint256 vaultId, bool flipElig) external;

    function setNegateEligibility(uint256 vaultId, bool negateElig) external;

    function setIsFinalized(uint256 vaultId, bool _isFinalized) external;

    function setIsClosed(uint256 vaultId, bool _isClosed) external;

    function setMintFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        external;

    function setBurnFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        external;

    function setDualFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        external;

    function setSupplierBounty(uint256 vaultId, uint256 ethMax, uint256 length)
        external;

    function setEthBalance(uint256 vaultId, uint256 _ethBalance) external;

    function setTokenBalance(uint256 vaultId, uint256 _tokenBalance) external;

    function setIsD2Vault(uint256 vaultId, bool _isD2Vault) external;

    function setD2AssetAddress(uint256 vaultId, address _assetAddress) external;

    function setD2Asset(uint256 vaultId) external;

    function setD2Holdings(uint256 vaultId, uint256 _d2Holdings) external;


    function setIsExtension(address addr, bool _isExtension) external;

    function setRandNonce(uint256 _randNonce) external;

    function addNewVault() external returns (uint256);
}

pragma solidity 0.6.8;


contract KittyTest is ERC721Holder {
    address public kittyCoreAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyCore kittyCore;
    IERC721 kittyNft;

    constructor() public {
        kittyCore = KittyCore(kittyCoreAddress);
        kittyNft = IERC721(kittyCoreAddress);
    }

    function testA1(uint256 tokenId, address toAddress) public {
        kittyNft.transferFrom(msg.sender, toAddress, tokenId);
    }

    function testA2(uint256 tokenId, address toAddress) public {
        kittyCore.transferFrom(msg.sender, toAddress, tokenId);
    }

    function testB1(uint256 tokenId, address toAddress) public {
        kittyNft.transferFrom(msg.sender, toAddress, tokenId);
    }

    function testB2(uint256 tokenId, address toAddress) public {
        kittyCore.transferFrom(msg.sender, toAddress, tokenId);
    }

    function depositA(uint256 tokenId) public {
        kittyNft.transferFrom(msg.sender, address(this), tokenId);
    }

    function depositB(uint256 tokenId) public {
        kittyCore.transferFrom(msg.sender, address(this), tokenId);
    }

    function withdrawA(uint256 tokenId) public {
        kittyNft.transferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawB(uint256 tokenId) public {
        kittyCore.transferFrom(address(this), msg.sender, tokenId);
    }
}

interface KittyCore {
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function transferFrom(address _from, address _to, uint256 _tokenId)
        external;
    function transfer(address _to, uint256 _tokenId) external;
    function getKitty(uint256 _id)
        external
        view
        returns (
            bool,
            bool,
            uint256 _cooldownIndex,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256 _generation,
            uint256
        );
    function kittyIndexToApproved(uint256 index)
        external
        view
        returns (address approved);
}

pragma solidity 0.6.8;


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(IERC20 token, address spender, uint256 value)
        internal
    {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value)
        internal
    {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value)
        internal
    {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

pragma solidity 0.6.8;


contract NFTX is Pausable, ReentrancyGuard, ERC721Holder {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event NewVault(uint256 indexed vaultId, address sender);
    event Mint(
        uint256 indexed vaultId,
        uint256[] nftIds,
        uint256 d2Amount,
        address sender
    );
    event Redeem(
        uint256 indexed vaultId,
        uint256[] nftIds,
        uint256 d2Amount,
        address sender
    );
    event MintRequested(
        uint256 indexed vaultId,
        uint256[] nftIds,
        address sender
    );

    IXStore public store;

    function initialize(address storeAddress) public initializer {
        initOwnable();
        initReentrancyGuard();
        store = IXStore(storeAddress);
    }


    function onlyPrivileged(uint256 vaultId) internal view {
        if (store.isFinalized(vaultId)) {
            require(msg.sender == owner(), "Not owner");
        } else {
            require(msg.sender == store.manager(vaultId), "Not manager");
        }
    }

    function isEligible(uint256 vaultId, uint256 nftId)
        public
        view
        virtual
        returns (bool)
    {
        return
            store.negateEligibility(vaultId)
                ? !store.isEligible(vaultId, nftId)
                : store.isEligible(vaultId, nftId);
    }

    function vaultSize(uint256 vaultId) public view virtual returns (uint256) {
        return
            store.isD2Vault(vaultId)
                ? store.d2Holdings(vaultId)
                : store.holdingsLength(vaultId).add(
                    store.reservesLength(vaultId)
                );
    }

    function _getPseudoRand(uint256 modulus)
        internal
        virtual
        returns (uint256)
    {
        store.setRandNonce(store.randNonce().add(1));
        return
            uint256(
                keccak256(abi.encodePacked(now, msg.sender, store.randNonce()))
            ) %
            modulus;
    }

    function _calcFee(
        uint256 amount,
        uint256 ethBase,
        uint256 ethStep,
        bool isD2
    ) internal pure virtual returns (uint256) {
        if (amount == 0) {
            return 0;
        } else if (isD2) {
            return ethBase.add(ethStep.mul(amount.sub(10**18)).div(10**18));
        } else {
            uint256 n = amount;
            uint256 nSub1 = amount >= 1 ? n.sub(1) : 0;
            return ethBase.add(ethStep.mul(nSub1));
        }
    }

    function _calcBounty(uint256 vaultId, uint256 numTokens, bool isBurn)
        public
        view
        virtual
        returns (uint256)
    {
        (, uint256 length) = store.supplierBounty(vaultId);
        if (length == 0) return 0;
        uint256 ethBounty = 0;
        for (uint256 i = 0; i < numTokens; i = i.add(1)) {
            uint256 _vaultSize = isBurn
                ? vaultSize(vaultId).sub(i.add(1))
                : vaultSize(vaultId).add(i);
            uint256 _ethBounty = _calcBountyHelper(vaultId, _vaultSize);
            ethBounty = ethBounty.add(_ethBounty);
        }
        return ethBounty;
    }

    function _calcBountyD2(uint256 vaultId, uint256 amount, bool isBurn)
        public
        view
        virtual
        returns (uint256)
    {
        (uint256 ethMax, uint256 length) = store.supplierBounty(vaultId);
        if (length == 0) return 0;
        uint256 prevSize = vaultSize(vaultId);
        uint256 prevDepth = prevSize > length ? 0 : length.sub(prevSize);
        uint256 prevReward = _calcBountyD2Helper(ethMax, length, prevSize);
        uint256 newSize = isBurn
            ? vaultSize(vaultId).sub(amount)
            : vaultSize(vaultId).add(amount);
        uint256 newDepth = newSize > length ? 0 : length.sub(newSize);
        uint256 newReward = _calcBountyD2Helper(ethMax, length, newSize);
        uint256 prevTriangle = prevDepth.mul(prevReward).div(2).div(10**18);
        uint256 newTriangle = newDepth.mul(newReward).div(2).div(10**18);
        return
            isBurn
                ? newTriangle.sub(prevTriangle)
                : prevTriangle.sub(newTriangle);
    }

    function _calcBountyD2Helper(uint256 ethMax, uint256 length, uint256 size)
        internal
        pure
        returns (uint256)
    {
        if (size >= length) return 0;
        return ethMax.sub(ethMax.mul(size).div(length));
    }

    function _calcBountyHelper(uint256 vaultId, uint256 _vaultSize)
        internal
        view
        virtual
        returns (uint256)
    {
        (uint256 ethMax, uint256 length) = store.supplierBounty(vaultId);
        if (_vaultSize >= length) return 0;
        uint256 depth = length.sub(_vaultSize);
        return ethMax.mul(depth).div(length);
    }

    function createVault(
        address _xTokenAddress,
        address _assetAddress,
        bool _isD2Vault
    ) public virtual nonReentrant returns (uint256) {
        onlyOwnerIfPaused(0);
        IXToken xToken = IXToken(_xTokenAddress);
        require(xToken.owner() == address(this), "Wrong owner");
        uint256 vaultId = store.addNewVault();
        store.setXTokenAddress(vaultId, _xTokenAddress);

        store.setXToken(vaultId);
        if (!_isD2Vault) {
            store.setNftAddress(vaultId, _assetAddress);
            store.setNft(vaultId);
            store.setNegateEligibility(vaultId, true);
        } else {
            store.setD2AssetAddress(vaultId, _assetAddress);
            store.setD2Asset(vaultId);
            store.setIsD2Vault(vaultId, true);
        }
        store.setManager(vaultId, msg.sender);
        emit NewVault(vaultId, msg.sender);
        return vaultId;
    }

    function depositETH(uint256 vaultId) public payable virtual {
        store.setEthBalance(vaultId, store.ethBalance(vaultId).add(msg.value));
    }

    function _payEthFromVault(
        uint256 vaultId,
        uint256 amount,
        address payable to
    ) internal virtual {
        uint256 ethBalance = store.ethBalance(vaultId);
        uint256 amountToSend = ethBalance < amount ? ethBalance : amount;
        if (amountToSend > 0) {
            store.setEthBalance(vaultId, ethBalance.sub(amountToSend));
            to.transfer(amountToSend);
        }
    }

    function _receiveEthToVault(
        uint256 vaultId,
        uint256 amountRequested,
        uint256 amountSent
    ) internal virtual {
        require(amountSent >= amountRequested, "Value too low");
        store.setEthBalance(
            vaultId,
            store.ethBalance(vaultId).add(amountRequested)
        );
        if (amountSent > amountRequested) {
            msg.sender.transfer(amountSent.sub(amountRequested));
        }
    }

    function requestMint(uint256 vaultId, uint256[] memory nftIds)
        public
        payable
        virtual
        nonReentrant
    {
        onlyOwnerIfPaused(1);
        require(store.allowMintRequests(vaultId), "Not allowed");
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            require(
                store.nft(vaultId).ownerOf(nftIds[i]) != address(this),
                "Already owner"
            );
            store.nft(vaultId).safeTransferFrom(
                msg.sender,
                address(this),
                nftIds[i]
            );
            require(
                store.nft(vaultId).ownerOf(nftIds[i]) == address(this),
                "Not received"
            );
            store.setRequester(vaultId, nftIds[i], msg.sender);
        }
        emit MintRequested(vaultId, nftIds, msg.sender);
    }

    function revokeMintRequests(uint256 vaultId, uint256[] memory nftIds)
        public
        virtual
        nonReentrant
    {
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            require(
                store.requester(vaultId, nftIds[i]) == msg.sender,
                "Not requester"
            );
            store.setRequester(vaultId, nftIds[i], address(0));
            store.nft(vaultId).safeTransferFrom(
                address(this),
                msg.sender,
                nftIds[i]
            );
        }
    }

    function approveMintRequest(uint256 vaultId, uint256[] memory nftIds)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            address requester = store.requester(vaultId, nftIds[i]);
            require(requester != address(0), "No request");
            require(
                store.nft(vaultId).ownerOf(nftIds[i]) == address(this),
                "Not owner"
            );
            store.setRequester(vaultId, nftIds[i], address(0));
            store.setIsEligible(vaultId, nftIds[i], true);
            if (store.shouldReserve(vaultId, nftIds[i])) {
                store.reservesAdd(vaultId, nftIds[i]);
            } else {
                store.holdingsAdd(vaultId, nftIds[i]);
            }
            store.xToken(vaultId).mint(requester, 10**18);
        }
    }

    function _mint(uint256 vaultId, uint256[] memory nftIds, bool isDualOp)
        internal
        virtual
    {
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            uint256 nftId = nftIds[i];
            require(isEligible(vaultId, nftId), "Not eligible");
            require(
                store.nft(vaultId).ownerOf(nftId) != address(this),
                "Already owner"
            );
            store.nft(vaultId).safeTransferFrom(
                msg.sender,
                address(this),
                nftId
            );
            require(
                store.nft(vaultId).ownerOf(nftId) == address(this),
                "Not received"
            );
            if (store.shouldReserve(vaultId, nftId)) {
                store.reservesAdd(vaultId, nftId);
            } else {
                store.holdingsAdd(vaultId, nftId);
            }
        }
        if (!isDualOp) {
            uint256 amount = nftIds.length.mul(10**18);
            store.xToken(vaultId).mint(msg.sender, amount);
        }
    }

    function _mintD2(uint256 vaultId, uint256 amount) internal virtual {
        store.d2Asset(vaultId).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        store.xToken(vaultId).mint(msg.sender, amount);
        store.setD2Holdings(vaultId, store.d2Holdings(vaultId).add(amount));
    }

    function _redeem(uint256 vaultId, uint256 numNFTs, bool isDualOp)
        internal
        virtual
    {
        for (uint256 i = 0; i < numNFTs; i = i.add(1)) {
            uint256[] memory nftIds = new uint256[](1);
            if (store.holdingsLength(vaultId) > 0) {
                uint256 rand = _getPseudoRand(store.holdingsLength(vaultId));
                nftIds[0] = store.holdingsAt(vaultId, rand);
            } else {
                uint256 rand = _getPseudoRand(store.reservesLength(vaultId));
                nftIds[0] = store.reservesAt(vaultId, rand);
            }
            _redeemHelper(vaultId, nftIds, isDualOp);
            emit Redeem(vaultId, nftIds, 0, msg.sender);
        }
    }

    function _redeemD2(uint256 vaultId, uint256 amount) internal virtual {
        store.xToken(vaultId).burnFrom(msg.sender, amount);
        store.d2Asset(vaultId).safeTransfer(msg.sender, amount);
        store.setD2Holdings(vaultId, store.d2Holdings(vaultId).sub(amount));
        uint256[] memory nftIds = new uint256[](0);
        emit Redeem(vaultId, nftIds, amount, msg.sender);
    }

    function _redeemHelper(
        uint256 vaultId,
        uint256[] memory nftIds,
        bool isDualOp
    ) internal virtual {
        if (!isDualOp) {
            store.xToken(vaultId).burnFrom(
                msg.sender,
                nftIds.length.mul(10**18)
            );
        }
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            uint256 nftId = nftIds[i];
            require(
                store.holdingsContains(vaultId, nftId) ||
                    store.reservesContains(vaultId, nftId),
                "NFT not in vault"
            );
            if (store.holdingsContains(vaultId, nftId)) {
                store.holdingsRemove(vaultId, nftId);
            } else {
                store.reservesRemove(vaultId, nftId);
            }
            if (store.flipEligOnRedeem(vaultId)) {
                bool isElig = store.isEligible(vaultId, nftId);
                store.setIsEligible(vaultId, nftId, !isElig);
            }
            store.nft(vaultId).safeTransferFrom(
                address(this),
                msg.sender,
                nftId
            );
        }
    }

    function mint(uint256 vaultId, uint256[] memory nftIds, uint256 d2Amount)
        public
        payable
        virtual
        nonReentrant
    {
        onlyOwnerIfPaused(1);
        uint256 amount = store.isD2Vault(vaultId) ? d2Amount : nftIds.length;
        uint256 ethBounty = store.isD2Vault(vaultId)
            ? _calcBountyD2(vaultId, d2Amount, false)
            : _calcBounty(vaultId, amount, false);
        (uint256 ethBase, uint256 ethStep) = store.mintFees(vaultId);
        uint256 ethFee = _calcFee(
            amount,
            ethBase,
            ethStep,
            store.isD2Vault(vaultId)
        );
        if (ethFee > ethBounty) {
            _receiveEthToVault(vaultId, ethFee.sub(ethBounty), msg.value);
        }
        if (store.isD2Vault(vaultId)) {
            _mintD2(vaultId, d2Amount);
        } else {
            _mint(vaultId, nftIds, false);
        }
        if (ethBounty > ethFee) {
            _payEthFromVault(vaultId, ethBounty.sub(ethFee), msg.sender);
        }
        emit Mint(vaultId, nftIds, d2Amount, msg.sender);
    }

    function redeem(uint256 vaultId, uint256 amount)
        public
        payable
        virtual
        nonReentrant
    {
        onlyOwnerIfPaused(2);
        if (!store.isClosed(vaultId)) {
            uint256 ethBounty = store.isD2Vault(vaultId)
                ? _calcBountyD2(vaultId, amount, true)
                : _calcBounty(vaultId, amount, true);
            (uint256 ethBase, uint256 ethStep) = store.burnFees(vaultId);
            uint256 ethFee = _calcFee(
                amount,
                ethBase,
                ethStep,
                store.isD2Vault(vaultId)
            );
            if (ethBounty.add(ethFee) > 0) {
                _receiveEthToVault(vaultId, ethBounty.add(ethFee), msg.value);
            }
        }
        if (!store.isD2Vault(vaultId)) {
            _redeem(vaultId, amount, false);
        } else {
            _redeemD2(vaultId, amount);
        }

    }


    function setIsEligible(
        uint256 vaultId,
        uint256[] memory nftIds,
        bool _boolean
    ) public virtual {
        onlyPrivileged(vaultId);
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            store.setIsEligible(vaultId, nftIds[i], _boolean);
        }
    }

    function setAllowMintRequests(uint256 vaultId, bool isAllowed)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setAllowMintRequests(vaultId, isAllowed);
    }

    function setFlipEligOnRedeem(uint256 vaultId, bool flipElig)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setFlipEligOnRedeem(vaultId, flipElig);
    }

    function setNegateEligibility(uint256 vaultId, bool shouldNegate)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        require(
            store
                .holdingsLength(vaultId)
                .add(store.reservesLength(vaultId))
                .add(store.d2Holdings(vaultId)) ==
                0,
            "Vault not empty"
        );
        store.setNegateEligibility(vaultId, shouldNegate);
    }



    function changeTokenName(uint256 vaultId, string memory newName)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.xToken(vaultId).changeName(newName);
    }

    function changeTokenSymbol(uint256 vaultId, string memory newSymbol)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.xToken(vaultId).changeSymbol(newSymbol);
    }

    function setManager(uint256 vaultId, address newManager) public virtual {
        onlyPrivileged(vaultId);
        store.setManager(vaultId, newManager);
    }

    function finalizeVault(uint256 vaultId) public virtual {
        onlyPrivileged(vaultId);
        if (!store.isFinalized(vaultId)) {
            store.setIsFinalized(vaultId, true);
        }
    }

    function closeVault(uint256 vaultId) public virtual {
        onlyPrivileged(vaultId);
        if (!store.isFinalized(vaultId)) {
            store.setIsFinalized(vaultId, true);
        }
        store.setIsClosed(vaultId, true);
    }

    function setMintFees(uint256 vaultId, uint256 _ethBase, uint256 _ethStep)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setMintFees(vaultId, _ethBase, _ethStep);
    }

    function setBurnFees(uint256 vaultId, uint256 _ethBase, uint256 _ethStep)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setBurnFees(vaultId, _ethBase, _ethStep);
    }


    function setSupplierBounty(uint256 vaultId, uint256 ethMax, uint256 length)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setSupplierBounty(vaultId, ethMax, length);
    }

}

pragma solidity 0.6.8;


contract NFTXv2 is NFTX {

    function _mint(uint256 vaultId, uint256[] memory nftIds, bool isDualOp)
        internal
        virtual
        override
    {
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            uint256 nftId = nftIds[i];
            require(isEligible(vaultId, nftId), "Not eligible");
            require(
                store.nft(vaultId).ownerOf(nftId) != address(this),
                "Already owner"
            );
            store.nft(vaultId).transferFrom(msg.sender, address(this), nftId);
            require(
                store.nft(vaultId).ownerOf(nftId) == address(this),
                "Not received"
            );
            if (store.shouldReserve(vaultId, nftId)) {
                store.reservesAdd(vaultId, nftId);
            } else {
                store.holdingsAdd(vaultId, nftId);
            }
        }
        if (!isDualOp) {
            uint256 amount = nftIds.length.mul(10**18);
            store.xToken(vaultId).mint(msg.sender, amount);
        }
    }
}

pragma solidity 0.6.8;


contract NFTXv3 is NFTXv2 {
    function requestMint(uint256 vaultId, uint256[] memory nftIds)
        public
        payable
        virtual
        override
        nonReentrant
    {
        onlyOwnerIfPaused(1);
        require(store.allowMintRequests(vaultId), "Not allowed");
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            require(
                store.nft(vaultId).ownerOf(nftIds[i]) != address(this),
                "Already owner"
            );
            store.nft(vaultId).transferFrom(
                msg.sender,
                address(this),
                nftIds[i]
            );
            require(
                store.nft(vaultId).ownerOf(nftIds[i]) == address(this),
                "Not received"
            );
            store.setRequester(vaultId, nftIds[i], msg.sender);
        }
        emit MintRequested(vaultId, nftIds, msg.sender);
    }
}

pragma solidity 0.6.8;


contract NFTXv4 is NFTXv3 {
    function _mintD2(uint256 vaultId, uint256 amount)
        internal
        virtual
        override
    {
        store.d2Asset(vaultId).safeTransferFrom(
            msg.sender,
            address(this),
            amount.mul(1000)
        );
        store.xToken(vaultId).mint(msg.sender, amount);
        store.setD2Holdings(
            vaultId,
            store.d2Holdings(vaultId).add(amount.mul(1000))
        );
    }

    function _redeemD2(uint256 vaultId, uint256 amount)
        internal
        virtual
        override
    {
        store.xToken(vaultId).burnFrom(msg.sender, amount);
        store.d2Asset(vaultId).safeTransfer(msg.sender, amount.mul(1000));
        store.setD2Holdings(
            vaultId,
            store.d2Holdings(vaultId).sub(amount.mul(1000))
        );
    }
}

pragma solidity 0.6.8;


contract ProxyController is Ownable {
    using SafeMath for uint256;

    ITransparentUpgradeableProxy private nftxProxy;
    address public implAddress;

    constructor(address nftx) public {
        initOwnable();
        nftxProxy = ITransparentUpgradeableProxy(nftx);
    }

    function getAdmin() public returns (address) {
        return nftxProxy.admin();
    }

    function fetchImplAddress() public {
        implAddress = nftxProxy.implementation();
    }

    function changeProxyAdmin(address newAdmin) public onlyOwner {
        nftxProxy.changeAdmin(newAdmin);
    }

    function upgradeProxyTo(address newImpl) public onlyOwner {
        nftxProxy.upgradeTo(newImpl);
    }
}

pragma solidity 0.6.8;


contract TimeDelay is Ownable {
    using SafeMath for uint256;

    uint256 public shortDelay;
    uint256 public mediumDelay;
    uint256 public longDelay;

    function setDelays(
        uint256 _shortDelay,
        uint256 _mediumDelay,
        uint256 _longDelay
    ) internal virtual {
        shortDelay = _shortDelay;
        mediumDelay = _mediumDelay;
        longDelay = _longDelay;
    }

    function timeInDays(uint256 num) internal pure returns (uint256) {
        return num * 60 * 60 * 24;
    }

    function getDelay(uint256 delayIndex) public view returns (uint256) {
        if (delayIndex == 0) {
            return shortDelay;
        } else if (delayIndex == 1) {
            return mediumDelay;
        } else if (delayIndex == 2) {
            return longDelay;
        }
    }

    function onlyIfPastDelay(uint256 delayIndex, uint256 startTime)
        internal
        view
    {
        require(1 >= startTime.add(getDelay(delayIndex)), "Delay not over");
    }
}

pragma solidity 0.6.8;


contract TokenAppController is Ownable {
    ITokenManager public tokenManager;
    address public tokenManagerAddr;

    function initTAC() internal {
        initOwnable();
    }

    function setTokenManager(address tokenManagerAddress) internal onlyOwner {
        tokenManagerAddr = tokenManagerAddress;
        tokenManager = ITokenManager(tokenManagerAddr);
    }

    function callMint(address _receiver, uint256 _amount) internal onlyOwner {
        tokenManager.mint(_receiver, _amount);
    }

    function callIssue(uint256 _amount) internal onlyOwner {
        tokenManager.issue(_amount);
    }

    function callAssign(address _receiver, uint256 _amount) internal onlyOwner {
        tokenManager.assign(_receiver, _amount);
    }

    function callBurn(address _holder, uint256 _amount) internal onlyOwner {
        tokenManager.burn(_holder, _amount);
    }

    function callAssignVested(
        address _receiver,
        uint256 _amount,
        uint64 _start,
        uint64 _cliff,
        uint64 _vested,
        bool _revokable
    ) internal returns (uint256) {
        return
            tokenManager.assignVested(
                _receiver,
                _amount,
                _start,
                _cliff,
                _vested,
                _revokable
            );
    }

    function callRevokeVesting(address _holder, uint256 _vestingId)
        internal
        onlyOwner
    {
        tokenManager.revokeVesting(_holder, _vestingId);
    }

}

pragma solidity 0.6.8;


contract UpgradeController is ControllerBase {
    using SafeMath for uint256;

    
    ITransparentUpgradeableProxy private nftxProxy;
    ITransparentUpgradeableProxy private xControllerProxy;

    constructor(address nftx, address xController) public {
        ControllerBase.initialize();
        nftxProxy = ITransparentUpgradeableProxy(nftx);
        xControllerProxy = ITransparentUpgradeableProxy(xController);
    }

    function executeFuncCall(uint256 fcId) public override onlyOwner {
        super.executeFuncCall(fcId);
        if (funcIndex[fcId] == 3) {
            nftxProxy.changeAdmin(addressParam[fcId]);
        } else if (funcIndex[fcId] == 4) {
            nftxProxy.upgradeTo(addressParam[fcId]);
        } else if (funcIndex[fcId] == 5) {
            xControllerProxy.changeAdmin(addressParam[fcId]);
        } else if (funcIndex[fcId] == 6) {
            xControllerProxy.upgradeTo(addressParam[fcId]);
        }
    }

}

pragma solidity 0.6.8;


contract XBounties is TokenAppController, ReentrancyGuard {
    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    uint256 public constant BASE = 10**18;
    uint256 public interval = 15 * 60; // 15 minutes
    uint256 public start = 1608580800; // Mon, Dec 21 2020, 12pm PST
    uint64 public vestedUntil = 1609876800; // Tue, Jan 5 2021, 12pm PST

    IERC20 public nftxToken;
    address payable public daoMultiSig;

    struct Bounty {
        address tokenContract;
        uint256 nftxPrice;
        uint256 paidOut;
        uint256 payoutCap;
    }

    event NewBountyAdded(uint256 bountyId);
    event BountyFilled(
        uint256 bountyId,
        uint256 nftxAmount,
        uint256 assetAmount,
        address sender,
        uint64 start,
        uint64 cliff,
        uint64 vested
    );
    event NftxPriceSet(uint256 bountyId, uint256 newNftxPrice);
    event PayoutCapSet(uint256 bountyId, uint256 newCap);
    event BountyClosed(uint256 bountyId);
    event EthWithdrawn(uint256 amount);
    event Erc20Withdrawn(address tokenContract, uint256 amount);
    event Erc721Withdrawn(address nftContract, uint256 tokenId);

    Bounty[] internal bounties;

    constructor(
        address _tokenManager,
        address payable _daoMultiSig,
        address _nftxToken,
        address _xStore
    ) public {
        initTAC();
        setTokenManager(_tokenManager);
        daoMultiSig = _daoMultiSig;
        nftxToken = IERC20(_nftxToken);

        IXStore xStore = IXStore(_xStore);

        createEthBounty(130 * BASE, 65000 * BASE);
        createEthBounty(65 * BASE, 65000 * BASE);
        createEthBounty(BASE.mul(130).div(3), 65000 * BASE);
        createBounty(
            xStore.xTokenAddress(0), // PUNK-BASIC
            390 * BASE,
            31200 * BASE
        );
        createBounty(
            xStore.xTokenAddress(1), // PUNK-ATTR-4
            585 * BASE,
            14625 * BASE
        );
        createBounty(
            xStore.xTokenAddress(2), // PUNK-ATTR-5
            1950 * BASE,
            15600 * BASE
        );
        createBounty(
            xStore.xTokenAddress(3), // PUNK-ZOMBIE
            8450 * BASE,
            16900 * BASE
        );
        createBounty(
            xStore.xTokenAddress(4), // AXIE-ORIGIN
            130 * BASE,
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(5), // AXIE-MYSTIC-1
            780 * BASE,
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(6), // AXIE-MYSTIC-2
            3900 * BASE,
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(7), // KITTY-GEN-0
            26 * BASE,
            5850 * BASE
        );
        createBounty(
            xStore.xTokenAddress(8), // KITTY-GEN-0-F
            39 * BASE,
            5850 * BASE
        );
        createBounty(
            xStore.xTokenAddress(9), // KITTY-FOUNDER
            6175 * BASE,
            6175 * BASE
        );
        createBounty(
            xStore.xTokenAddress(10), // AVASTR-BASIC
            20 * BASE,
            6175 * BASE
        );
        createBounty(
            xStore.xTokenAddress(11), // AVASTR-RANK-30
            26 * BASE,
            6175 * BASE
        );
        createBounty(
            xStore.xTokenAddress(12), // AVASTR-RANK-60
            195 * BASE,
            6175 * BASE
        );
        createBounty(
            xStore.xTokenAddress(13), // GLYPH
            1300 * BASE,
            26000 * BASE
        );
        createBounty(
            xStore.xTokenAddress(14), // JOY
            455 * BASE,
            10010 * BASE
        );
    }

    function setStart(uint256 newStart) public onlyOwner {
        start = newStart;
    }

    function setInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }

    function setVestedUntil(uint64 newTime) public onlyOwner {
        vestedUntil = newTime;
    }

    function getBountyInfo(uint256 bountyId)
        public
        view
        returns (address, uint256, uint256, uint256)
    {
        require(bountyId < bounties.length, "Invalid bountyId");
        return (
            bounties[bountyId].tokenContract,
            bounties[bountyId].nftxPrice,
            bounties[bountyId].paidOut,
            bounties[bountyId].payoutCap
        );
    }

    function getMaxPayout() public view returns (uint256) {
        uint256 tMinus4 = start.sub(interval.mul(4));
        uint256 tMinus3 = start.sub(interval.mul(3));
        uint256 tMinus2 = start.sub(interval.mul(2));
        uint256 tMinus1 = start.sub(interval.mul(1));
        uint256 tm4Max = 0;
        uint256 tm3Max = 50 * BASE;
        uint256 tm2Max = 500 * BASE;
        uint256 tm1Max = 5000 * BASE;
        uint256 tm0Max = 50000 * BASE;
        if (now < tMinus4) {
            return 0;
        } else if (now < tMinus3) {
            uint256 progressBigNum = now.sub(tMinus4).mul(BASE).div(interval);
            uint256 addedPayout = tm3Max.sub(tm4Max).mul(progressBigNum).div(
                BASE
            );
            return tm4Max.add(addedPayout);
        } else if (now < tMinus2) {
            uint256 progressBigNum = now.sub(tMinus3).mul(BASE).div(interval);
            uint256 addedPayout = tm2Max.sub(tm3Max).mul(progressBigNum).div(
                BASE
            );
            return tm3Max.add(addedPayout);
        } else if (now < tMinus1) {
            uint256 progressBigNum = now.sub(tMinus2).mul(BASE).div(interval);
            uint256 addedPayout = tm1Max.sub(tm2Max).mul(progressBigNum).div(
                BASE
            );
            return tm2Max.add(addedPayout);
        } else if (now < start) {
            uint256 progressBigNum = now.sub(tMinus1).mul(BASE).div(interval);
            uint256 addedPayout = tm0Max.sub(tm1Max).mul(progressBigNum).div(
                BASE
            );
            return tm1Max.add(addedPayout);
        } else {
            return tm0Max;
        }
    }

    function getBountiesLength() public view returns (uint256) {
        return bounties.length;
    }

    function getIsEth(uint256 bountyId) public view returns (bool) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].tokenContract == address(0);
    }

    function getTokenContract(uint256 bountyId) public view returns (address) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].tokenContract;
    }

    function getNftxPrice(uint256 bountyId) public view returns (uint256) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].nftxPrice;
    }

    function getPayoutCap(uint256 bountyId) public view returns (uint256) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].payoutCap;
    }

    function getPaidOut(uint256 bountyId) public view returns (uint256) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].paidOut;
    }

    function setNftxPrice(uint256 bountyId, uint256 newPrice) public onlyOwner {
        require(bountyId < bounties.length, "Invalid bountyId");
        bounties[bountyId].nftxPrice = newPrice;
        emit NftxPriceSet(bountyId, newPrice);
    }

    function setPayoutCap(uint256 bountyId, uint256 newCap) public onlyOwner {
        require(bountyId < bounties.length, "Invalid bountyId");
        bounties[bountyId].payoutCap = newCap;
        emit PayoutCapSet(bountyId, newCap);
    }

    function createEthBounty(uint256 nftxPricePerEth, uint256 amountOfEth)
        public
        onlyOwner
    {
        createBounty(address(0), nftxPricePerEth, amountOfEth);
    }

    function createBounty(address token, uint256 nftxPrice, uint256 payoutCap)
        public
        onlyOwner
    {
        Bounty memory newBounty;
        newBounty.tokenContract = token;
        newBounty.nftxPrice = nftxPrice;
        newBounty.payoutCap = payoutCap;
        bounties.push(newBounty);
        uint256 bountyId = bounties.length.sub(1);
        emit NewBountyAdded(bountyId);
    }

    function closeBounty(uint256 bountyId) public onlyOwner {
        require(bountyId < bounties.length, "Invalid bountyId");
        bounties[bountyId].payoutCap = bounties[bountyId].paidOut;
        emit BountyClosed(bountyId);
    }

    function fillBounty(uint256 bountyId, uint256 amountBeingSent)
        public
        payable
        nonReentrant
    {
        _fillBountyCustom(
            bountyId,
            amountBeingSent,
            vestedUntil - 2,
            vestedUntil - 1,
            vestedUntil
        );
    }


    function _fillBountyCustom(
        uint256 bountyId,
        uint256 donationSize,
        uint64 _start,
        uint64 cliff,
        uint64 vested
    ) internal {
        require(cliff >= vestedUntil - 1 && vested >= vestedUntil, "Not valid");
        require(bountyId < bounties.length, "Invalid bountyId");
        Bounty storage bounty = bounties[bountyId];
        uint256 rewardCap = getMaxPayout();
        require(rewardCap > 0, "Must wait for cap to be lifted");
        uint256 remainingNftx = bounty.payoutCap.sub(bounty.paidOut);
        require(remainingNftx > 0, "Bounty is already finished");
        uint256 requestedNftx = donationSize.mul(bounty.nftxPrice).div(BASE);
        uint256 willGive = remainingNftx < requestedNftx
            ? remainingNftx
            : rewardCap < requestedNftx
            ? rewardCap
            : requestedNftx;
        uint256 willTake = donationSize.mul(willGive).div(requestedNftx);
        if (getIsEth(bountyId)) {
            require(msg.value >= willTake, "Value sent is insufficient");
            if (msg.value > willTake) {
                address payable _sender = msg.sender;
                _sender.transfer(msg.value.sub(willTake));
            }
            daoMultiSig.transfer(willTake);
        } else {
            IERC20 fundToken = IERC20(bounty.tokenContract);
            fundToken.safeTransferFrom(msg.sender, daoMultiSig, willTake);
        }
        if (now > vested) {
            nftxToken.safeTransfer(msg.sender, willGive);
        } else {
            nftxToken.safeTransfer(tokenManagerAddr, willGive);
            callAssignVested(
                msg.sender,
                willGive,
                _start,
                cliff,
                vested,
                false
            );
        }
        bounty.paidOut = bounty.paidOut.add(willGive);
        emit BountyFilled(
            bountyId,
            willGive,
            willTake,
            msg.sender,
            _start,
            cliff,
            vested
        );
    }

    function withdrawEth(uint256 amount) public onlyOwner {
        address payable sender = msg.sender;
        sender.transfer(amount);
        emit EthWithdrawn(amount);
    }

    function withdrawErc20(address tokenContract, uint256 amount)
        public
        onlyOwner
    {
        IERC20 token = IERC20(tokenContract);
        token.safeTransfer(msg.sender, amount);
        emit Erc20Withdrawn(tokenContract, amount);
    }

    function withdrawErc721(address nftContract, uint256 tokenId)
        public
        onlyOwner
    {
        IERC721 nft = IERC721(nftContract);
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        emit Erc721Withdrawn(nftContract, tokenId);
    }
}

pragma solidity 0.6.8;


contract XController is ControllerBase {
    INFTX private nftx;
    IXStore store;

    mapping(uint256 => uint256) public uintParam;
    mapping(uint256 => string) public stringParam;
    mapping(uint256 => bool) public boolParam;

    mapping(uint256 => uint256) public pendingEligAdditions;

    function initXController(address nftxAddress) public initializer {
        initOwnable();
        nftx = INFTX(nftxAddress);
    }

    function onlyOwnerOrLeadDev(uint256 funcIndex) public view virtual {
        if (funcIndex > 3) {
            require(
                _msgSender() == leadDev || _msgSender() == owner(),
                "Not owner or leadDev"
            );
        } else {
            require(_msgSender() == owner(), "Not owner");
        }
    }

    function stageFuncCall(
        uint256 _funcIndex,
        address payable _addressParam,
        uint256 _uintParam,
        string memory _stringParam,
        uint256[] memory _uintArrayParam,
        bool _boolParam
    ) public virtual {
        onlyOwnerOrLeadDev(_funcIndex);
        uint256 fcId = numFuncCalls;
        numFuncCalls = numFuncCalls.add(1);
        time[fcId] = 1;
        funcIndex[fcId] = _funcIndex;
        addressParam[fcId] = _addressParam;
        uintParam[fcId] = _uintParam;
        stringParam[fcId] = _stringParam;
        uintArrayParam[fcId] = _uintArrayParam;
        boolParam[fcId] = _boolParam;
        if (
            funcIndex[fcId] == 4 &&
            store.negateEligibility(uintParam[fcId]) != !boolParam[fcId]
        ) {
            pendingEligAdditions[uintParam[fcId]] = pendingEligAdditions[uintParam[fcId]]
                .add(uintArrayParam[fcId].length);
        }
    }

    function cancelFuncCall(uint256 fcId) public override virtual {
        onlyOwnerOrLeadDev(funcIndex[fcId]);
        require(funcIndex[fcId] != 0, "Already cancelled");
        funcIndex[fcId] = 0;
        if (
            funcIndex[fcId] == 3 &&
            store.negateEligibility(uintParam[fcId]) != !boolParam[fcId]
        ) {
            pendingEligAdditions[uintParam[fcId]] = pendingEligAdditions[uintParam[fcId]]
                .sub(uintArrayParam[fcId].length);
        }
    }

    function executeFuncCall(uint256 fcId) public override virtual {
        super.executeFuncCall(fcId);
        if (funcIndex[fcId] == 3) {
            onlyIfPastDelay(2, time[fcId]);
            nftx.transferOwnership(addressParam[fcId]);
        } else if (funcIndex[fcId] == 4) {
            uint256 percentInc = pendingEligAdditions[uintParam[fcId]]
                .mul(100)
                .div(nftx.vaultSize(uintParam[fcId]));
            if (percentInc > 10) {
                onlyIfPastDelay(2, time[fcId]);
            } else if (percentInc > 1) {
                onlyIfPastDelay(1, time[fcId]);
            } else {
                onlyIfPastDelay(0, time[fcId]);
            }
            nftx.setIsEligible(
                uintParam[fcId],
                uintArrayParam[fcId],
                boolParam[fcId]
            );
            pendingEligAdditions[uintParam[fcId]] = pendingEligAdditions[uintParam[fcId]]
                .sub(uintArrayParam[fcId].length);
        } else if (funcIndex[fcId] == 5) {
            onlyIfPastDelay(0, time[fcId]); // vault must be empty
            nftx.setNegateEligibility(funcIndex[fcId], boolParam[fcId]);
        } else if (funcIndex[fcId] == 6) {
            onlyIfPastDelay(0, time[fcId]);
            nftx.setShouldReserve(
                uintParam[fcId],
                uintArrayParam[fcId],
                boolParam[fcId]
            );
        } else if (funcIndex[fcId] == 7) {
            onlyIfPastDelay(0, time[fcId]);
            nftx.setIsReserved(
                uintParam[fcId],
                uintArrayParam[fcId],
                boolParam[fcId]
            );
        } else if (funcIndex[fcId] == 8) {
            onlyIfPastDelay(1, time[fcId]);
            nftx.changeTokenName(uintParam[fcId], stringParam[fcId]);
        } else if (funcIndex[fcId] == 9) {
            onlyIfPastDelay(1, time[fcId]);
            nftx.changeTokenSymbol(uintParam[fcId], stringParam[fcId]);
        } else if (funcIndex[fcId] == 10) {
            onlyIfPastDelay(0, time[fcId]);
            nftx.closeVault(uintParam[fcId]);
        } else if (funcIndex[fcId] == 11) {
            onlyIfPastDelay(0, time[fcId]);
            nftx.setMintFees(
                uintArrayParam[fcId][0],
                uintArrayParam[fcId][1],
                uintArrayParam[fcId][2]
            );
        } else if (funcIndex[fcId] == 12) {
            (uint256 ethBase, uint256 ethStep) = store.burnFees(
                uintArrayParam[fcId][0]
            );
            uint256 ethBasePercentInc = uintArrayParam[fcId][1].mul(100).div(
                ethBase
            );
            uint256 ethStepPercentInc = uintArrayParam[fcId][2].mul(100).div(
                ethStep
            );
            if (ethBasePercentInc.add(ethStepPercentInc) > 15) {
                onlyIfPastDelay(2, time[fcId]);
            } else if (ethBasePercentInc.add(ethStepPercentInc) > 5) {
                onlyIfPastDelay(1, time[fcId]);
            } else {
                onlyIfPastDelay(0, time[fcId]);
            }
            nftx.setBurnFees(
                uintArrayParam[fcId][0],
                uintArrayParam[fcId][1],
                uintArrayParam[fcId][2]
            );
        } else if (funcIndex[fcId] == 13) {
            onlyIfPastDelay(0, time[fcId]);
            nftx.setDualFees(
                uintArrayParam[fcId][0],
                uintArrayParam[fcId][1],
                uintArrayParam[fcId][2]
            );
        } else if (funcIndex[fcId] == 14) {
            (uint256 ethMax, uint256 length) = store.supplierBounty(
                uintArrayParam[fcId][0]
            );
            uint256 ethMaxPercentInc = uintArrayParam[fcId][1].mul(100).div(
                ethMax
            );
            uint256 lengthPercentInc = uintArrayParam[fcId][2].mul(100).div(
                length
            );
            if (ethMaxPercentInc.add(lengthPercentInc) > 20) {
                onlyIfPastDelay(2, time[fcId]);
            } else if (ethMaxPercentInc.add(lengthPercentInc) > 5) {
                onlyIfPastDelay(1, time[fcId]);
            } else {
                onlyIfPastDelay(0, time[fcId]);
            }
            nftx.setSupplierBounty(
                uintArrayParam[fcId][0],
                uintArrayParam[fcId][1],
                uintArrayParam[fcId][2]
            );
        }
    }

}

pragma solidity 0.6.8;


contract XSale is Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    INFTX public nftx;
    IXStore public xStore;
    IERC20 public nftxToken;
    ITokenManager public tokenManager;

    uint64 public constant vestedUntil = 1610697600000; // Fri Jan 15 2021 00:00:00 GMT-0800

    mapping(uint256 => Bounty[]) public xBounties;

    struct Bounty {
        uint256 reward;
        uint256 request;
    }

    constructor(address _nftx, address _nftxToken, address _tokenManager)
        public
    {
        initOwnable();
        nftx = INFTX(_nftx);
        xStore = IXStore(nftx.store());
        nftxToken = IERC20(_nftxToken);
        tokenManager = ITokenManager(_tokenManager);
    }

    function addXBounty(uint256 vaultId, uint256 reward, uint256 request)
        public
        onlyOwner
    {
        Bounty memory newXBounty;
        newXBounty.reward = reward;
        newXBounty.request = request;
        xBounties[vaultId].push(newXBounty);
    }

    function setXBounty(
        uint256 vaultId,
        uint256 xBountyIndex,
        uint256 newReward,
        uint256 newRequest
    ) public onlyOwner {
        Bounty storage xBounty = xBounties[vaultId][xBountyIndex];
        xBounty.reward = newReward;
        xBounty.request = newRequest;
    }

    function withdrawNFTX(address to, uint256 amount) public onlyOwner {
        nftxToken.transfer(to, amount);
    }

    function withdrawXToken(uint256 vaultId, address to, uint256 amount)
        public
        onlyOwner
    {
        xStore.xToken(vaultId).transfer(to, amount);
    }

    function withdrawETH(address payable to, uint256 amount) public onlyOwner {
        to.transfer(amount);
    }

    function fillXBounty(uint256 vaultId, uint256 xBountyIndex, uint256 amount)
        public
        nonReentrant
    {
        Bounty storage xBounty = xBounties[vaultId][xBountyIndex];
        require(amount <= xBounty.request, "Amount > bounty");
        require(
            amount <= nftxToken.balanceOf(address(nftx)),
            "Amount > balance"
        );
        xStore.xToken(vaultId).transferFrom(
            _msgSender(),
            address(nftx),
            amount
        );
        uint256 reward = xBounty.reward.mul(amount).div(xBounty.request);
        xBounty.request = xBounty.request.sub(amount);
        xBounty.reward = xBounty.reward.sub(reward);
        nftxToken.transfer(address(tokenManager), reward);
        tokenManager.assignVested(
            _msgSender(),
            reward,
            vestedUntil,
            vestedUntil,
            vestedUntil,
            false
        );
    }
}

pragma solidity 0.6.8;


contract XStore is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    struct FeeParams {
        uint256 ethBase;
        uint256 ethStep;
    }

    struct BountyParams {
        uint256 ethMax;
        uint256 length;
    }

    struct Vault {
        address xTokenAddress;
        address nftAddress;
        address manager;
        IXToken xToken;
        IERC721 nft;
        EnumerableSet.UintSet holdings;
        EnumerableSet.UintSet reserves;
        mapping(uint256 => address) requester;
        mapping(uint256 => bool) isEligible;
        mapping(uint256 => bool) shouldReserve;
        bool allowMintRequests;
        bool flipEligOnRedeem;
        bool negateEligibility;
        bool isFinalized;
        bool isClosed;
        FeeParams mintFees;
        FeeParams burnFees;
        FeeParams dualFees;
        BountyParams supplierBounty;
        uint256 ethBalance;
        uint256 tokenBalance;
        bool isD2Vault;
        address d2AssetAddress;
        IERC20 d2Asset;
        uint256 d2Holdings;
    }

    event XTokenAddressSet(uint256 indexed vaultId, address token);
    event NftAddressSet(uint256 indexed vaultId, address asset);
    event ManagerSet(uint256 indexed vaultId, address manager);
    event XTokenSet(uint256 indexed vaultId);
    event NftSet(uint256 indexed vaultId);
    event HoldingsAdded(uint256 indexed vaultId, uint256 id);
    event HoldingsRemoved(uint256 indexed vaultId, uint256 id);
    event ReservesAdded(uint256 indexed vaultId, uint256 id);
    event ReservesRemoved(uint256 indexed vaultId, uint256 id);
    event RequesterSet(uint256 indexed vaultId, uint256 id, address requester);
    event IsEligibleSet(uint256 indexed vaultId, uint256 id, bool _bool);
    event ShouldReserveSet(uint256 indexed vaultId, uint256 id, bool _bool);
    event AllowMintRequestsSet(uint256 indexed vaultId, bool isAllowed);
    event FlipEligOnRedeemSet(uint256 indexed vaultId, bool _bool);
    event NegateEligibilitySet(uint256 indexed vaultId, bool _bool);
    event IsFinalizedSet(uint256 indexed vaultId, bool _isFinalized);
    event IsClosedSet(uint256 indexed vaultId, bool _isClosed);
    event MintFeesSet(
        uint256 indexed vaultId,
        uint256 ethBase,
        uint256 ethStep
    );
    event BurnFeesSet(
        uint256 indexed vaultId,
        uint256 ethBase,
        uint256 ethStep
    );
    event DualFeesSet(
        uint256 indexed vaultId,
        uint256 ethBase,
        uint256 ethStep
    );
    event SupplierBountySet(
        uint256 indexed vaultId,
        uint256 ethMax,
        uint256 length
    );
    event EthBalanceSet(uint256 indexed vaultId, uint256 _ethBalance);
    event TokenBalanceSet(uint256 indexed vaultId, uint256 _tokenBalance);
    event IsD2VaultSet(uint256 indexed vaultId, bool _isD2Vault);
    event D2AssetAddressSet(uint256 indexed vaultId, address _d2Asset);
    event D2AssetSet(uint256 indexed vaultId);
    event D2HoldingsSet(uint256 indexed vaultId, uint256 _d2Holdings);
    event NewVaultAdded(uint256 indexed vaultId);
    event IsExtensionSet(address addr, bool _isExtension);
    event RandNonceSet(uint256 _randNonce);

    Vault[] internal vaults;

    mapping(address => bool) public isExtension;
    uint256 public randNonce;

    constructor() public {
        initOwnable();
    }

    function _getVault(uint256 vaultId) internal view returns (Vault storage) {
        require(vaultId < vaults.length, "Invalid vaultId");
        return vaults[vaultId];
    }

    function vaultsLength() public view returns (uint256) {
        return vaults.length;
    }

    function xTokenAddress(uint256 vaultId) public view returns (address) {
        Vault storage vault = _getVault(vaultId);
        return vault.xTokenAddress;
    }

    function nftAddress(uint256 vaultId) public view returns (address) {
        Vault storage vault = _getVault(vaultId);
        return vault.nftAddress;
    }

    function manager(uint256 vaultId) public view returns (address) {
        Vault storage vault = _getVault(vaultId);
        return vault.manager;
    }

    function xToken(uint256 vaultId) public view returns (IXToken) {
        Vault storage vault = _getVault(vaultId);
        return vault.xToken;
    }

    function nft(uint256 vaultId) public view returns (IERC721) {
        Vault storage vault = _getVault(vaultId);
        return vault.nft;
    }

    function holdingsLength(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.length();
    }

    function holdingsContains(uint256 vaultId, uint256 elem)
        public
        view
        returns (bool)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.contains(elem);
    }

    function holdingsAt(uint256 vaultId, uint256 index)
        public
        view
        returns (uint256)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.at(index);
    }

    function reservesLength(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.length();
    }

    function reservesContains(uint256 vaultId, uint256 elem)
        public
        view
        returns (bool)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.contains(elem);
    }

    function reservesAt(uint256 vaultId, uint256 index)
        public
        view
        returns (uint256)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.at(index);
    }

    function requester(uint256 vaultId, uint256 id)
        public
        view
        returns (address)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.requester[id];
    }

    function isEligible(uint256 vaultId, uint256 id)
        public
        view
        returns (bool)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.isEligible[id];
    }

    function shouldReserve(uint256 vaultId, uint256 id)
        public
        view
        returns (bool)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.shouldReserve[id];
    }

    function allowMintRequests(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.allowMintRequests;
    }

    function flipEligOnRedeem(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.flipEligOnRedeem;
    }

    function negateEligibility(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.negateEligibility;
    }

    function isFinalized(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.isFinalized;
    }

    function isClosed(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.isClosed;
    }

    function mintFees(uint256 vaultId) public view returns (uint256, uint256) {
        Vault storage vault = _getVault(vaultId);
        return (vault.mintFees.ethBase, vault.mintFees.ethStep);
    }

    function burnFees(uint256 vaultId) public view returns (uint256, uint256) {
        Vault storage vault = _getVault(vaultId);
        return (vault.burnFees.ethBase, vault.burnFees.ethStep);
    }

    function dualFees(uint256 vaultId) public view returns (uint256, uint256) {
        Vault storage vault = _getVault(vaultId);
        return (vault.dualFees.ethBase, vault.dualFees.ethStep);
    }

    function supplierBounty(uint256 vaultId)
        public
        view
        returns (uint256, uint256)
    {
        Vault storage vault = _getVault(vaultId);
        return (vault.supplierBounty.ethMax, vault.supplierBounty.length);
    }

    function ethBalance(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.ethBalance;
    }

    function tokenBalance(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.tokenBalance;
    }

    function isD2Vault(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.isD2Vault;
    }

    function d2AssetAddress(uint256 vaultId) public view returns (address) {
        Vault storage vault = _getVault(vaultId);
        return vault.d2AssetAddress;
    }

    function d2Asset(uint256 vaultId) public view returns (IERC20) {
        Vault storage vault = _getVault(vaultId);
        return vault.d2Asset;
    }

    function d2Holdings(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.d2Holdings;
    }

    function setXTokenAddress(uint256 vaultId, address _xTokenAddress)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.xTokenAddress = _xTokenAddress;
        emit XTokenAddressSet(vaultId, _xTokenAddress);
    }

    function setNftAddress(uint256 vaultId, address _nft) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.nftAddress = _nft;
        emit NftAddressSet(vaultId, _nft);
    }

    function setManager(uint256 vaultId, address _manager) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.manager = _manager;
        emit ManagerSet(vaultId, _manager);
    }

    function setXToken(uint256 vaultId) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.xToken = IXToken(vault.xTokenAddress);
        emit XTokenSet(vaultId);
    }

    function setNft(uint256 vaultId) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.nft = IERC721(vault.nftAddress);
        emit NftSet(vaultId);
    }

    function holdingsAdd(uint256 vaultId, uint256 elem) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.holdings.add(elem);
        emit HoldingsAdded(vaultId, elem);
    }

    function holdingsRemove(uint256 vaultId, uint256 elem) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.holdings.remove(elem);
        emit HoldingsRemoved(vaultId, elem);
    }

    function reservesAdd(uint256 vaultId, uint256 elem) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.reserves.add(elem);
        emit ReservesAdded(vaultId, elem);
    }

    function reservesRemove(uint256 vaultId, uint256 elem) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.reserves.remove(elem);
        emit ReservesRemoved(vaultId, elem);
    }

    function setRequester(uint256 vaultId, uint256 id, address _requester)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.requester[id] = _requester;
        emit RequesterSet(vaultId, id, _requester);
    }

    function setIsEligible(uint256 vaultId, uint256 id, bool _bool)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.isEligible[id] = _bool;
        emit IsEligibleSet(vaultId, id, _bool);
    }

    function setShouldReserve(uint256 vaultId, uint256 id, bool _shouldReserve)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.shouldReserve[id] = _shouldReserve;
        emit ShouldReserveSet(vaultId, id, _shouldReserve);
    }

    function setAllowMintRequests(uint256 vaultId, bool isAllowed)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.allowMintRequests = isAllowed;
        emit AllowMintRequestsSet(vaultId, isAllowed);
    }

    function setFlipEligOnRedeem(uint256 vaultId, bool flipElig)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.flipEligOnRedeem = flipElig;
        emit FlipEligOnRedeemSet(vaultId, flipElig);
    }

    function setNegateEligibility(uint256 vaultId, bool negateElig)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.negateEligibility = negateElig;
        emit NegateEligibilitySet(vaultId, negateElig);
    }

    function setIsFinalized(uint256 vaultId, bool _isFinalized)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.isFinalized = _isFinalized;
        emit IsFinalizedSet(vaultId, _isFinalized);
    }

    function setIsClosed(uint256 vaultId, bool _isClosed) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.isClosed = _isClosed;
        emit IsClosedSet(vaultId, _isClosed);
    }

    function setMintFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.mintFees = FeeParams(ethBase, ethStep);
        emit MintFeesSet(vaultId, ethBase, ethStep);
    }

    function setBurnFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.burnFees = FeeParams(ethBase, ethStep);
        emit BurnFeesSet(vaultId, ethBase, ethStep);
    }

    function setDualFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.dualFees = FeeParams(ethBase, ethStep);
        emit DualFeesSet(vaultId, ethBase, ethStep);
    }

    function setSupplierBounty(uint256 vaultId, uint256 ethMax, uint256 length)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.supplierBounty = BountyParams(ethMax, length);
        emit SupplierBountySet(vaultId, ethMax, length);
    }

    function setEthBalance(uint256 vaultId, uint256 _ethBalance)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.ethBalance = _ethBalance;
        emit EthBalanceSet(vaultId, _ethBalance);
    }

    function setTokenBalance(uint256 vaultId, uint256 _tokenBalance)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.tokenBalance = _tokenBalance;
        emit TokenBalanceSet(vaultId, _tokenBalance);
    }

    function setIsD2Vault(uint256 vaultId, bool _isD2Vault) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.isD2Vault = _isD2Vault;
        emit IsD2VaultSet(vaultId, _isD2Vault);
    }

    function setD2AssetAddress(uint256 vaultId, address _d2Asset)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.d2AssetAddress = _d2Asset;
        emit D2AssetAddressSet(vaultId, _d2Asset);
    }

    function setD2Asset(uint256 vaultId) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.d2Asset = IERC20(vault.d2AssetAddress);
        emit D2AssetSet(vaultId);
    }

    function setD2Holdings(uint256 vaultId, uint256 _d2Holdings)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.d2Holdings = _d2Holdings;
        emit D2HoldingsSet(vaultId, _d2Holdings);
    }


    function addNewVault() public onlyOwner returns (uint256) {
        Vault memory newVault;
        vaults.push(newVault);
        uint256 vaultId = vaults.length.sub(1);
        emit NewVaultAdded(vaultId);
        return vaultId;
    }

    function setIsExtension(address addr, bool _isExtension) public onlyOwner {
        isExtension[addr] = _isExtension;
        emit IsExtensionSet(addr, _isExtension);
    }

    function setRandNonce(uint256 _randNonce) public onlyOwner {
        randNonce = _randNonce;
        emit RandNonceSet(_randNonce);
    }
}

pragma solidity 0.6.8;


contract XStoreMultiCall {
    IXStore public xStore;

    constructor() public {
        xStore = IXStore(0xBe54738723cea167a76ad5421b50cAa49692E7B7);
    }

    function getVaultDataA(uint256 vaultId)
        public
        view
        returns (
            address xTokenAddress,
            address nftAddress,
            address manager,
            bool isClosed,
            bool isD2Vault,
            address d2AssetAddress
        )
    {
        address _xTokenAddress = xStore.xTokenAddress(vaultId);
        address _nftAddress = xStore.nftAddress(vaultId);
        address _manager = xStore.manager(vaultId);
        bool _isClosed = xStore.isClosed(vaultId);
        bool _isD2Vault = xStore.isD2Vault(vaultId);
        address _d2AssetAddress = xStore.d2AssetAddress(vaultId);

        return (
            _xTokenAddress,
            _nftAddress,
            _manager,
            _isClosed,
            _isD2Vault,
            _d2AssetAddress
        );
    }

    function getVaultDataB(uint256 vaultId)
        public
        view
        returns (
            bool allowMintRequests,
            bool flipEligOnRedeem,
            bool negateEligibility,
            bool isFinalized
        )
    {
        bool _allowMintRequests = xStore.allowMintRequests(vaultId);
        bool _flipEligOnRedeem = xStore.flipEligOnRedeem(vaultId);
        bool _negateEligibility = xStore.negateEligibility(vaultId);
        bool _isFinalized = xStore.isFinalized(vaultId);

        return (
            _allowMintRequests,
            _flipEligOnRedeem,
            _negateEligibility,
            _isFinalized
        );
    }
}

pragma solidity 0.6.8;


contract XToken is Context, Ownable, ERC20Burnable {
    constructor(string memory name, string memory symbol, address _owner)
        public
        ERC20(name, symbol)
    {
        initOwnable();
        transferOwnership(_owner);
        _mint(msg.sender, 0);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function changeName(string memory name) public onlyOwner {
        _changeName(name);
    }

    function changeSymbol(string memory symbol) public onlyOwner {
        _changeSymbol(symbol);
    }
}
