

pragma solidity ^0.8.0;

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {

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

    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}



contract UsershipManager {

    using EnumerableSet for EnumerableSet.AddressSet;
    struct Usership {
        bool isOpen2All; // indicates if all NFT contracts are allowed
        address user; // usership account address
        EnumerableSet.AddressSet whitelist; // NFT contract addresses allowed for usership
    }

    mapping(address => Usership) private _userships; // an owner can has only one usership address (that can be modified if owner decides)
    mapping(address => address) public getOwnershipAddress; // a user can be assigned for the only one owner

    function setUsership(
        bool _allowFullTokenPermissions,
        address _newUsershipAddress,
        address[] calldata _tokenAddressesPermitted
    ) external {

        require(
            getOwnershipAddress[_newUsershipAddress] == address(0),
            "already_in_use"
        );
        Usership storage u = _userships[msg.sender];

        u.isOpen2All = _allowFullTokenPermissions;
        u.user = _newUsershipAddress;
        for (uint256 i = 0; i < _tokenAddressesPermitted.length; i++) {
            u.whitelist.add(_tokenAddressesPermitted[i]);
        }

        getOwnershipAddress[_newUsershipAddress] = msg.sender;
    }

    function getUsershipAddress(address _owner)
        public
        view
        returns (
            bool fullPermission,
            address usershipAddress,
            address[] memory tokensPermitted
        )
    {

        Usership storage u = _userships[_owner];

        tokensPermitted = new address[](u.whitelist.length());
        for (uint256 i = 0; i < u.whitelist.length(); i++) {
            tokensPermitted[i] = u.whitelist.at(i);
        }

        fullPermission = u.isOpen2All;
        usershipAddress = u.user;
    }

    function getUsershipPermissionForOwnerToken(
        address _usershipAddress,
        address _ownershipAddress,
        address _tokenAddress
    ) external view returns (bool tokenPermission) {

        Usership storage u = _userships[_ownershipAddress];

        if (u.user != _usershipAddress) {
            return false;
        }

        return u.isOpen2All || u.whitelist.contains(_tokenAddress);
    }

    function getUsershipPermissions(address _user)
        external
        view
        returns (
            bool fullPermission,
            address ownershipAddress,
            address[] memory tokensPermitted
        )
    {

        ownershipAddress = getOwnershipAddress[_user];
        (fullPermission, , tokensPermitted) = getUsershipAddress(
            ownershipAddress
        );
    }

    function getUsershipPermissionForToken(
        address _usershipAddress,
        address _tokenAddress
    ) external view returns (bool tokenPermission) {

        address ownershipAddress = getOwnershipAddress[_usershipAddress];
        if (ownershipAddress == address(0)) {
            return false;
        }

        Usership storage u = _userships[ownershipAddress];
        return u.isOpen2All || u.whitelist.contains(_tokenAddress);
    }

    function updateTokenPermission(address _tokenAddress, bool _isAdd)
        external
    {

        Usership storage u = _userships[msg.sender];

        if (_isAdd) {
            u.whitelist.add(_tokenAddress);
        } else {
            u.whitelist.remove(_tokenAddress);
        }
    }

    function updateFullPermission(bool _fullPermission) external {

        Usership storage u = _userships[msg.sender];
        u.isOpen2All = _fullPermission;
    }
}