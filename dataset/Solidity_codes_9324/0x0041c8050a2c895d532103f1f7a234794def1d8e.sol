



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

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




pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}




pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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




pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

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

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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












contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

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

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}




pragma solidity ^0.6.0;




abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



pragma solidity ^0.6.0;




contract NftImageDataStorage is Ownable {
    using SafeMath for uint256;
    uint256 constant FILL_DATA_GAS_RESERVE = 46000;

    struct ArtWorkImageData {
        uint256[] colorIndex;
        uint256[] individualPixels;
        uint256[] pixelGroups;
        uint256[] pixelGroupIndexes;
        uint256[] transparentPixelGroups;
        uint256[] transparentPixelGroupIndexes;
    }
    mapping(bytes32 => ArtWorkImageData) private artworkImageDatas;

    modifier onlyFilledArtwork(bytes32 dataHash) {
        require(isArtworkFilled(dataHash), "Artwork is not filled");
        _;
    }

    event Filled(
        bytes32 dataHash,
        uint256 colorIndexLength,
        uint256 individualPixelsLength,
        uint256 pixelGroupsLength,
        uint256 pixelGroupIndexesLength,
        uint256 transparentPixelGroupsLength,
        uint256 transparentPixelGroupIndexesLength
    );

    function fillData(
        uint256[] memory colorIndex,
        uint256[] memory individualPixels,
        uint256[] memory pixelGroups,
        uint256[] memory pixelGroupIndexes,
        uint256[] memory transparentPixelGroups,
        uint256[] memory transparentPixelGroupIndexes
    ) public onlyOwner returns (bool) {
        bytes32 dataHash = keccak256(
            abi.encodePacked(
                colorIndex,
                individualPixels,
                pixelGroups,
                pixelGroupIndexes,
                transparentPixelGroups,
                transparentPixelGroupIndexes
            )
        );
        require(!isArtworkFilled(dataHash), "Artwork is already filled");

        ArtWorkImageData storage _artworkImageData = artworkImageDatas[dataHash];

        uint256 len;
        uint256 index;

        if (gasleft() > FILL_DATA_GAS_RESERVE && colorIndex.length > 0) {
            index = _artworkImageData.colorIndex.length == 0 ? 0 : _artworkImageData.colorIndex.length + 1;

            len = colorIndex.length;

            while ((gasleft() > FILL_DATA_GAS_RESERVE) && index < len) {
                _artworkImageData.colorIndex.push(colorIndex[index]);
                index++;
            }
        }

        if (gasleft() > FILL_DATA_GAS_RESERVE && individualPixels.length > 0) {
            index = _artworkImageData.individualPixels.length == 0 ? 0 : _artworkImageData.individualPixels.length + 1;

            len = individualPixels.length;

            while ((gasleft() > FILL_DATA_GAS_RESERVE) && index < len) {
                _artworkImageData.individualPixels.push(individualPixels[index]);
                index++;
            }
        }

        if (gasleft() > FILL_DATA_GAS_RESERVE && pixelGroups.length > 0) {
            index = _artworkImageData.pixelGroups.length == 0 ? 0 : _artworkImageData.pixelGroups.length + 1;

            len = pixelGroups.length;

            while ((gasleft() > FILL_DATA_GAS_RESERVE) && index < len) {
                _artworkImageData.pixelGroups.push(pixelGroups[index]);
                index++;
            }
        }

        if (gasleft() > FILL_DATA_GAS_RESERVE && pixelGroupIndexes.length > 0) {
            index = _artworkImageData.pixelGroupIndexes.length == 0
                ? 0
                : _artworkImageData.pixelGroupIndexes.length + 1;

            len = pixelGroupIndexes.length;

            while ((gasleft() > FILL_DATA_GAS_RESERVE) && index < len) {
                _artworkImageData.pixelGroupIndexes.push(pixelGroupIndexes[index]);
                index++;
            }
        }

        if (gasleft() > FILL_DATA_GAS_RESERVE && transparentPixelGroups.length > 0) {
            index = _artworkImageData.transparentPixelGroups.length == 0
                ? 0
                : _artworkImageData.transparentPixelGroups.length + 1;

            len = transparentPixelGroups.length;

            while ((gasleft() > FILL_DATA_GAS_RESERVE) && index < len) {
                _artworkImageData.transparentPixelGroups.push(transparentPixelGroups[index]);
                index++;
            }
        }

        if (gasleft() > FILL_DATA_GAS_RESERVE && transparentPixelGroupIndexes.length > 0) {
            index = _artworkImageData.transparentPixelGroupIndexes.length == 0
                ? 0
                : _artworkImageData.transparentPixelGroupIndexes.length + 1;

            len = transparentPixelGroupIndexes.length;

            while ((gasleft() > FILL_DATA_GAS_RESERVE) && index < len) {
                _artworkImageData.transparentPixelGroupIndexes.push(transparentPixelGroupIndexes[index]);
                index++;
            }
        }

        emit Filled(
            dataHash,
            _artworkImageData.colorIndex.length,
            _artworkImageData.individualPixels.length,
            _artworkImageData.pixelGroups.length,
            _artworkImageData.pixelGroupIndexes.length,
            _artworkImageData.transparentPixelGroups.length,
            _artworkImageData.transparentPixelGroupIndexes.length
        );
        return
            (colorIndex.length == _artworkImageData.colorIndex.length) &&
            (individualPixels.length == _artworkImageData.individualPixels.length) &&
            (pixelGroups.length == _artworkImageData.pixelGroups.length) &&
            (pixelGroupIndexes.length == _artworkImageData.pixelGroupIndexes.length) &&
            (transparentPixelGroups.length == _artworkImageData.transparentPixelGroups.length) &&
            (transparentPixelGroupIndexes.length == _artworkImageData.transparentPixelGroupIndexes.length);
    }

    function isArtworkFilled(bytes32 dataHash) public view returns (bool) {
        ArtWorkImageData memory _artworkImageData = artworkImageDatas[dataHash];
        return
            dataHash ==
            keccak256(
                abi.encodePacked(
                    _artworkImageData.colorIndex,
                    _artworkImageData.individualPixels,
                    _artworkImageData.pixelGroups,
                    _artworkImageData.pixelGroupIndexes,
                    _artworkImageData.transparentPixelGroups,
                    _artworkImageData.transparentPixelGroupIndexes
                )
            );
    }

    function getArtworkFillCompletionStatus(bytes32 dataHash)
        public
        view
        returns (
            uint256 colorIndexLength,
            uint256 individualPixelsLength,
            uint256 pixelGroupsLength,
            uint256 pixelGroupIndexesLength,
            uint256 transparentPixelGroupsLength,
            uint256 transparentPixelGroupIndexesLength
        )
    {
        ArtWorkImageData memory _artworkImageData = artworkImageDatas[dataHash];

        return (
            _artworkImageData.colorIndex.length,
            _artworkImageData.individualPixels.length,
            _artworkImageData.pixelGroups.length,
            _artworkImageData.pixelGroupIndexes.length,
            _artworkImageData.transparentPixelGroups.length,
            _artworkImageData.transparentPixelGroupIndexes.length
        );
    }

    function getArtworkForDataHash(bytes32 dataHash)
        public
        view
        onlyFilledArtwork(dataHash)
        returns (
            uint256[] memory colorIndex,
            uint256[] memory individualPixels,
            uint256[] memory pixelGroups,
            uint256[] memory pixelGroupIndexes,
            uint256[] memory transparentPixelGroups,
            uint256[] memory transparentPixelGroupIndexes
        )
    {
        ArtWorkImageData memory _artworkImageData = artworkImageDatas[dataHash];
        return (
            _artworkImageData.colorIndex,
            _artworkImageData.individualPixels,
            _artworkImageData.pixelGroups,
            _artworkImageData.pixelGroupIndexes,
            _artworkImageData.transparentPixelGroups,
            _artworkImageData.transparentPixelGroupIndexes
        );
    }

    function getColorIndexForDataHash(bytes32 dataHash)
        public
        view
        onlyFilledArtwork(dataHash)
        returns (uint256[] memory colorIndex)
    {
        return artworkImageDatas[dataHash].colorIndex;
    }
}



pragma solidity ^0.6.0;






contract MurAllNFT is ERC721, Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    using Strings for uint256;

    string public constant INVALID_TOKEN_ID = "Invalid Token ID";

    uint256 constant FIRST_3_BYTES_MASK = 115792082335569848633007197573932045576244532214531591869071028845388905840640;
    uint256 constant METADATA_HAS_ALPHA_CHANNEL_BYTES_MASK = 15;
    uint256 constant CONVERSION_SHIFT_BYTES = 232;
    uint256 constant CONVERSION_SHIFT_BYTES_RGB565 = 240;

    struct ArtWork {
        bytes32 dataHash;
        address artist;
        uint256 name;
        uint256 metadata;
    }

    NftImageDataStorage nftImageDataStorage;
    ArtWork[] artworks;

    string private mediaUriBase;

    string private viewUriBase;

    modifier onlyExistingTokens(uint256 _tokenId) {
        require(_tokenId < totalSupply(), INVALID_TOKEN_ID);
        _;
    }

    modifier onlyFilledTokens(uint256 _tokenId) {
        require(isArtworkFilled(_tokenId), "Artwork is not filled");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Does not have admin role");
        _;
    }

    event ArtworkFilled(uint256 indexed id, bool finished);

    constructor(address[] memory admins, NftImageDataStorage _nftImageDataStorageAddr)
        public
        ERC721("MurAll", "MURALL")
    {
        for (uint256 i = 0; i < admins.length; ++i) {
            _setupRole(ADMIN_ROLE, admins[i]);
        }
        nftImageDataStorage = _nftImageDataStorageAddr;
    }

    function mint(
        address origin,
        uint256[] memory colorIndex,
        uint256[] memory individualPixels,
        uint256[] memory pixelGroups,
        uint256[] memory pixelGroupIndexes,
        uint256[] memory transparentPixelGroups,
        uint256[] memory transparentPixelGroupIndexes,
        uint256[2] memory metadata
    ) public onlyOwner returns (uint256) {
        bytes32 dataHash = keccak256(
            abi.encodePacked(
                colorIndex,
                individualPixels,
                pixelGroups,
                pixelGroupIndexes,
                transparentPixelGroups,
                transparentPixelGroupIndexes
            )
        );

        ArtWork memory _artwork = ArtWork(dataHash, origin, metadata[0], metadata[1]);

        artworks.push(_artwork);
        uint256 _id = artworks.length - 1;

        _mint(origin, _id);

        return _id;
    }

    function fillData(
        uint256 id,
        uint256[] memory colorIndex,
        uint256[] memory individualPixels,
        uint256[] memory pixelGroups,
        uint256[] memory pixelGroupIndexes,
        uint256[] memory transparentPixelGroups,
        uint256[] memory transparentPixelGroupIndexes
    ) public onlyExistingTokens(id) {
        require(_isApprovedOrOwner(msg.sender, id), "Not approved or not owner of token");
        bytes32 dataHash = keccak256(
            abi.encodePacked(
                colorIndex,
                individualPixels,
                pixelGroups,
                pixelGroupIndexes,
                transparentPixelGroups,
                transparentPixelGroupIndexes
            )
        );
        require(artworks[id].dataHash == dataHash, "Incorrect data");

        bool filled = nftImageDataStorage.fillData(
            colorIndex,
            individualPixels,
            pixelGroups,
            pixelGroupIndexes,
            transparentPixelGroups,
            transparentPixelGroupIndexes
        );
        emit ArtworkFilled(id, filled);
    }

    function getFullDataForId(uint256 id)
        public
        view
        onlyExistingTokens(id)
        onlyFilledTokens(id)
        returns (
            address artist,
            uint256[] memory colorIndex,
            uint256[] memory individualPixels,
            uint256[] memory pixelGroups,
            uint256[] memory pixelGroupIndexes,
            uint256[] memory transparentPixelGroups,
            uint256[] memory transparentPixelGroupIndexes,
            uint256[2] memory metadata
        )
    {
        ArtWork memory _artwork = artworks[id];
        (
            colorIndex,
            individualPixels,
            pixelGroups,
            pixelGroupIndexes,
            transparentPixelGroups,
            transparentPixelGroupIndexes
        ) = getArtworkForId(id);
        artist = _artwork.artist;
        metadata = [_artwork.name, _artwork.metadata];
    }

    function getArtworkForId(uint256 id)
        public
        view
        onlyExistingTokens(id)
        onlyFilledTokens(id)
        returns (
            uint256[] memory colorIndex,
            uint256[] memory individualPixels,
            uint256[] memory pixelGroups,
            uint256[] memory pixelGroupIndexes,
            uint256[] memory transparentPixelGroups,
            uint256[] memory transparentPixelGroupIndexes
        )
    {
        return nftImageDataStorage.getArtworkForDataHash(artworks[id].dataHash);
    }

    function getArtworkDataHashForId(uint256 id) public view onlyExistingTokens(id) returns (bytes32) {
        return artworks[id].dataHash;
    }

    function getName(uint256 id) public view onlyExistingTokens(id) returns (string memory) {
        return bytes32ToString(bytes32(artworks[id].name));
    }

    function getNumber(uint256 id) public view onlyExistingTokens(id) returns (uint256) {
        return (FIRST_3_BYTES_MASK & artworks[id].metadata) >> CONVERSION_SHIFT_BYTES;
    }

    function getSeriesId(uint256 id) public view onlyExistingTokens(id) returns (uint256) {
        return (FIRST_3_BYTES_MASK & (artworks[id].metadata << 24)) >> CONVERSION_SHIFT_BYTES;
    }

    function hasAlphaChannel(uint256 id) public view onlyExistingTokens(id) returns (bool) {
        return (METADATA_HAS_ALPHA_CHANNEL_BYTES_MASK & artworks[id].metadata) != 0;
    }

    function getAlphaChannel(uint256 id) public view onlyExistingTokens(id) onlyFilledTokens(id) returns (uint256) {
        require(hasAlphaChannel(id), "Artwork has no alpha");
        return
            nftImageDataStorage.getColorIndexForDataHash(artworks[id].dataHash)[0] >> CONVERSION_SHIFT_BYTES_RGB565;
    }

    function getArtworkFillCompletionStatus(uint256 id)
        public
        view
        onlyExistingTokens(id)
        returns (
            uint256 colorIndexLength,
            uint256 individualPixelsLength,
            uint256 pixelGroupsLength,
            uint256 pixelGroupIndexesLength,
            uint256 transparentPixelGroupsLength,
            uint256 transparentPixelGroupIndexesLength
        )
    {
        return nftImageDataStorage.getArtworkFillCompletionStatus(artworks[id].dataHash);
    }

    function isArtworkFilled(uint256 id) public view onlyExistingTokens(id) returns (bool) {
        return nftImageDataStorage.isArtworkFilled(artworks[id].dataHash);
    }

    function getArtist(uint256 id) public view onlyExistingTokens(id) returns (address) {
        return artworks[id].artist;
    }

    function setTokenUriBase(string calldata _tokenUriBase) external onlyAdmin {
        _setBaseURI(_tokenUriBase);
    }

    function setMediaUriBase(string calldata _mediaUriBase) external onlyAdmin {
        mediaUriBase = _mediaUriBase;
    }

    function setViewUriBase(string calldata _viewUriBase) external onlyAdmin {
        viewUriBase = _viewUriBase;
    }

    function viewURI(uint256 _tokenId) public view returns (string memory uri) {
        require(_tokenId < totalSupply(), INVALID_TOKEN_ID);
        uri = string(abi.encodePacked(viewUriBase, _tokenId.toString()));
    }

    function mediaURI(uint256 _tokenId) public view returns (string memory uri) {
        require(_tokenId < totalSupply(), INVALID_TOKEN_ID);
        uri = string(abi.encodePacked(mediaUriBase, _tokenId.toString()));
    }

    function bytes32ToString(bytes32 x) internal pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint256 charCount = 0;
        uint256 j;
        for (j = 0; j < 32; j++) {
            bytes1 char = bytes1(bytes32(uint256(x) * 2**(8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}



pragma solidity ^0.6.0;

interface INftMetadata {
    function getNftMetadata(uint256 _tokenId) external view returns (string memory metadata);
}



pragma solidity ^0.6.0;





contract NftMetadata is Ownable, INftMetadata {
    using Strings for uint256;
    string public constant INVALID_TOKEN_ID = "Invalid Token ID";

    MurAllNFT public murAllNFT;

    constructor(MurAllNFT _murAllNFTAddr) public {
        murAllNFT = _murAllNFTAddr;
    }

    function getNftMetadata(uint256 _tokenId) external override view returns (string memory metadata) {
        require(_tokenId < murAllNFT.totalSupply(), INVALID_TOKEN_ID);

        string memory name = murAllNFT.getName(_tokenId);
        metadata = strConcat('{\n  "name": "', name);
        metadata = strConcat(metadata, '",\n');

        string memory artist = toAsciiString(murAllNFT.getArtist(_tokenId));
        metadata = strConcat(metadata, '  "description": "By Artist ');
        metadata = strConcat(metadata, artist);

        metadata = strConcat(metadata, ", Number ");
        metadata = strConcat(metadata, murAllNFT.getNumber(_tokenId).toString());

        metadata = strConcat(metadata, " from Series ");
        metadata = strConcat(metadata, murAllNFT.getSeriesId(_tokenId).toString());
        metadata = strConcat(metadata, '",\n');

        metadata = strConcat(metadata, '  "external_url": "');
        metadata = strConcat(metadata, murAllNFT.viewURI(_tokenId));
        metadata = strConcat(metadata, '",\n');

        metadata = strConcat(metadata, '  "image": "');
        metadata = strConcat(metadata, murAllNFT.mediaURI(_tokenId));
        metadata = strConcat(metadata, '",\n');

        metadata = strConcat(metadata, '  "attributes": [\n');

        metadata = strConcat(metadata, "    {\n");
        metadata = strConcat(metadata, '      "trait_type": "Name",\n');
        metadata = strConcat(metadata, '      "value": "');
        metadata = strConcat(metadata, name);
        metadata = strConcat(metadata, '"\n    },\n');

        metadata = strConcat(metadata, "    {\n");
        metadata = strConcat(metadata, '      "trait_type": "Artist",\n');
        metadata = strConcat(metadata, '      "value": "');
        metadata = strConcat(metadata, artist);
        metadata = strConcat(metadata, '"\n    },\n');

        metadata = strConcat(metadata, "    {\n");
        metadata = strConcat(metadata, '      "trait_type": "Filled",\n');
        metadata = strConcat(metadata, '      "value": "');
        if (murAllNFT.isArtworkFilled(_tokenId)) {
            metadata = strConcat(metadata, "Filled");
        } else {
            metadata = strConcat(metadata, "Not filled");
        }
        metadata = strConcat(metadata, '"\n    },\n');

        metadata = strConcat(metadata, "    {\n");
        metadata = strConcat(metadata, '      "display_type": "number",\n');
        metadata = strConcat(metadata, '      "trait_type": "Number",\n');
        metadata = strConcat(metadata, '      "value": ');
        metadata = strConcat(metadata, murAllNFT.getNumber(_tokenId).toString());
        metadata = strConcat(metadata, "\n    },\n");

        metadata = strConcat(metadata, "    {\n");
        metadata = strConcat(metadata, '      "display_type": "number",\n');
        metadata = strConcat(metadata, '      "trait_type": "Series Id",\n');
        metadata = strConcat(metadata, '      "value": ');
        metadata = strConcat(metadata, murAllNFT.getSeriesId(_tokenId).toString());
        metadata = strConcat(metadata, "\n    }\n");

        metadata = strConcat(metadata, "  ]\n}");

        return metadata;
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory result) {
        result = string(abi.encodePacked(bytes(_a), bytes(_b)));
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(x) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}