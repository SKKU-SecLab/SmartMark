
pragma solidity ^0.8.0;

interface IERC998ERC721BottomUp {

    event TransferToParent(
        address indexed _toContract,
        uint256 indexed _toTokenId,
        uint256 _tokenId
    );
    event TransferFromParent(
        address indexed _fromContract,
        uint256 indexed _fromTokenId,
        uint256 _tokenId
    );

    function rootOwnerOf(uint256 _tokenId)
        external
        view
        returns (bytes32 rootOwner);


    function tokenOwnerOf(uint256 _tokenId)
        external
        view
        returns (
            bytes32 tokenOwner,
            uint256 parentTokenId,
            bool isParent
        );


    function transferToParent(
        address _from,
        address _toContract,
        uint256 _toTokenId,
        uint256 _tokenId,
        bytes memory _data
    ) external;


    function transferFromParent(
        address _fromContract,
        uint256 _fromTokenId,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external;


    function transferAsChild(
        address _fromContract,
        uint256 _fromTokenId,
        address _toContract,
        uint256 _toTokenId,
        uint256 _tokenId,
        bytes memory _data
    ) external;

}

pragma solidity ^0.8.0;

interface IERC998ERC721TopDown {

    event ReceivedChild(
        address indexed _from,
        uint256 indexed _tokenId,
        address indexed _childContract,
        uint256 _childTokenId
    );
    event TransferChild(
        uint256 indexed tokenId,
        address indexed _to,
        address indexed _childContract,
        uint256 _childTokenId
    );

    function rootOwnerOf(uint256 _tokenId)
        external
        view
        returns (bytes32 rootOwner);


    function rootOwnerOfChild(address _childContract, uint256 _childTokenId)
        external
        view
        returns (bytes32 rootOwner);


    function ownerOfChild(address _childContract, uint256 _childTokenId)
        external
        view
        returns (bytes32 parentTokenOwner, uint256 parentTokenId);


    function onERC721Received(
        address _operator,
        address _from,
        uint256 _childTokenId,
        bytes calldata _data
    ) external returns (bytes4);


    function transferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) external;


    function safeTransferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) external;


    function safeTransferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId,
        bytes memory _data
    ) external;


    function transferChildToParent(
        uint256 _fromTokenId,
        address _toContract,
        uint256 _toTokenId,
        address _childContract,
        uint256 _childTokenId,
        bytes memory _data
    ) external;


    function getChild(
        address _from,
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) external;

}

pragma solidity ^0.8.0;

interface IERC998ERC721TopDownEnumerable {

    function totalChildContracts(uint256 _tokenId)
        external
        view
        returns (uint256);


    function childContractByIndex(uint256 _tokenId, uint256 _index)
        external
        view
        returns (address childContract);


    function totalChildTokens(uint256 _tokenId, address _childContract)
        external
        view
        returns (uint256);


    function childTokenByIndex(
        uint256 _tokenId,
        address _childContract,
        uint256 _index
    ) external view returns (uint256 childTokenId);

}

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

pragma solidity ^0.8.0;


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

        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {

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

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

pragma solidity ^0.8.0;


contract ComposableTopDown is
    ERC165,
    IERC721,
    IERC998ERC721TopDown,
    IERC998ERC721TopDownEnumerable,
    IERC721Metadata
{

    using Address for address;
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    bytes4 constant ERC998_MAGIC_VALUE = 0xcd740db5;
    bytes32 constant ERC998_MAGIC_VALUE_32 =
        0xcd740db500000000000000000000000000000000000000000000000000000000;

    uint256 tokenCount = 0;

    mapping(uint256 => address) private tokenIdToTokenOwner;

    mapping(address => EnumerableSet.UintSet) private _holderTokens;

    mapping(uint256 => uint256) private tokenIdToStateHash;

    mapping(address => mapping(uint256 => address))
        private rootOwnerAndTokenIdToApprovedAddress;

    mapping(address => uint256) private tokenOwnerToTokenCount;

    mapping(address => mapping(address => bool)) private tokenOwnerToOperators;

    string private _name;

    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function _safeMint(address _to) internal virtual returns (uint256) {

        require(_to != address(0), "CTD: _to zero addr");
        tokenCount++;
        uint256 tokenCount_ = tokenCount;
        tokenIdToTokenOwner[tokenCount_] = _to;
        _holderTokens[_to].add(tokenCount_);
        tokenOwnerToTokenCount[_to]++;
        tokenIdToStateHash[tokenCount] = uint256(
            keccak256(
                abi.encodePacked(uint256(uint160(address(this))), tokenCount)
            )
        );

        require(
            _checkOnERC721Received(address(0), _to, tokenCount_, ""),
            "CTD: transfer to non ERC721Receiver"
        );
        emit Transfer(address(0), _to, tokenCount_);
        return tokenCount_;
    }

    bytes4 constant ERC721_RECEIVED_OLD = 0xf0b9e5ba;
    bytes4 constant ERC721_RECEIVED_NEW = 0x150b7a02;

    bytes4 constant ALLOWANCE = bytes4(keccak256("allowance(address,address)"));
    bytes4 constant APPROVE = bytes4(keccak256("approve(address,uint256)"));
    bytes4 constant ROOT_OWNER_OF_CHILD =
        bytes4(keccak256("rootOwnerOfChild(address,uint256)"));

    function rootOwnerOf(uint256 _tokenId)
        public
        view
        override
        returns (bytes32 rootOwner)
    {

        return rootOwnerOfChild(address(0), _tokenId);
    }

    function rootOwnerOfChild(address _childContract, uint256 _childTokenId)
        public
        view
        override
        returns (bytes32 rootOwner)
    {

        address rootOwnerAddress;
        if (_childContract != address(0)) {
            (rootOwnerAddress, _childTokenId) = _ownerOfChild(
                _childContract,
                _childTokenId
            );
        } else {
            rootOwnerAddress = tokenIdToTokenOwner[_childTokenId];
            require(
                rootOwnerAddress != address(0),
                "CTD: ownerOf _tokenId zero addr"
            );
        }
        while (rootOwnerAddress == address(this)) {
            (rootOwnerAddress, _childTokenId) = _ownerOfChild(
                rootOwnerAddress,
                _childTokenId
            );
        }
        bytes memory callData = abi.encodeWithSelector(
            ROOT_OWNER_OF_CHILD,
            address(this),
            _childTokenId
        );
        (bool callSuccess, bytes memory data) = rootOwnerAddress.staticcall(
            callData
        );
        if (callSuccess) {
            assembly {
                rootOwner := mload(add(data, 0x20))
            }
        }

        if (
            callSuccess == true &&
            rootOwner &
                0xffffffff00000000000000000000000000000000000000000000000000000000 ==
            ERC998_MAGIC_VALUE_32
        ) {
            return rootOwner;
        } else {
            assembly {
                rootOwner := or(ERC998_MAGIC_VALUE_32, rootOwnerAddress)
            }
        }
    }


    function ownerOf(uint256 _tokenId)
        public
        view
        override
        returns (address tokenOwner)
    {

        tokenOwner = tokenIdToTokenOwner[_tokenId];
        require(tokenOwner != address(0), "CTD: ownerOf _tokenId zero addr");
        return tokenOwner;
    }

    function balanceOf(address _tokenOwner)
        public
        view
        override
        returns (uint256)
    {

        require(
            _tokenOwner != address(0),
            "CTD: balanceOf _tokenOwner zero addr"
        );
        return tokenOwnerToTokenCount[_tokenOwner];
    }

    function approve(address _approved, uint256 _tokenId) external override {

        address rootOwner = address(uint160(uint256(rootOwnerOf(_tokenId))));
        require(
            rootOwner == msg.sender ||
                tokenOwnerToOperators[rootOwner][msg.sender],
            "CTD: approve msg.sender not owner"
        );
        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId] = _approved;
        emit Approval(rootOwner, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId)
        public
        view
        override
        returns (address)
    {

        address rootOwner = address(uint160(uint256(rootOwnerOf(_tokenId))));
        return rootOwnerAndTokenIdToApprovedAddress[rootOwner][_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved)
        external
        override
    {

        require(_operator != address(0), "CTD: _operator zero addr");
        tokenOwnerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        override
        returns (bool)
    {

        require(_owner != address(0), "CTD: _owner zero addr");
        require(_operator != address(0), "CTD: _operator zero addr");
        return tokenOwnerToOperators[_owner][_operator];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {

        _transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {

        _transferFrom(_from, _to, _tokenId);
        if (_to.isContract()) {
            bytes4 retval = IERC721Receiver(_to).onERC721Received(
                msg.sender,
                _from,
                _tokenId,
                ""
            );
            require(
                retval == ERC721_RECEIVED_OLD || retval == ERC721_RECEIVED_NEW,
                "CTD: safeTransferFrom(3) onERC721Received invalid return value"
            );
        }
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public override {

        _transferFrom(_from, _to, _tokenId);
        if (_to.isContract()) {
            bytes4 retval = IERC721Receiver(_to).onERC721Received(
                msg.sender,
                _from,
                _tokenId,
                _data
            );
            require(
                retval == ERC721_RECEIVED_OLD || retval == ERC721_RECEIVED_NEW,
                "CTD: safeTransferFrom(4) onERC721Received invalid return value"
            );
            rootOwnerOf(_tokenId);
        }
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) private {

        require(_from != address(0), "CTD: _from zero addr");
        require(tokenIdToTokenOwner[_tokenId] == _from, "CTD: _from not owner");
        require(_to != address(0), "CTD: _to zero address");

        if (msg.sender != _from) {
            bytes memory callData = abi.encodeWithSelector(
                ROOT_OWNER_OF_CHILD,
                address(this),
                _tokenId
            );
            (bool callSuccess, bytes memory data) = _from.staticcall(callData);
            if (callSuccess == true) {
                bytes32 rootOwner;
                assembly {
                    rootOwner := mload(add(data, 0x20))
                }
                require(
                    rootOwner &
                        0xffffffff00000000000000000000000000000000000000000000000000000000 !=
                        ERC998_MAGIC_VALUE_32,
                    "CTD: token is child of other top down composable"
                );
            }

            require(
                tokenOwnerToOperators[_from][msg.sender] ||
                    rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId] ==
                    msg.sender,
                "CTD: msg.sender not approved"
            );
        }

        if (
            rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId] != address(0)
        ) {
            delete rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];
            emit Approval(_from, address(0), _tokenId);
        }

        if (_from != _to) {
            assert(tokenOwnerToTokenCount[_from] > 0);
            tokenOwnerToTokenCount[_from]--;
            tokenIdToTokenOwner[_tokenId] = _to;
            _holderTokens[_from].remove(_tokenId);
            _holderTokens[_to].add(_tokenId);
            tokenOwnerToTokenCount[_to]++;
        }
        emit Transfer(_from, _to, _tokenId);
    }


    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return tokenIdToTokenOwner[tokenId] != address(0);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {

        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        returns (uint256)
    {

        return _holderTokens[owner].at(index);
    }

    function getTokenCount() public view returns (uint256) {

        return tokenCount;
    }


    mapping(uint256 => EnumerableSet.AddressSet) private childContracts;

    mapping(uint256 => mapping(address => EnumerableSet.UintSet))
        private childTokens;

    mapping(address => mapping(uint256 => uint256)) private childTokenOwner;

    function safeTransferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) external override {

        _transferChild(_fromTokenId, _to, _childContract, _childTokenId);
        IERC721(_childContract).safeTransferFrom(
            address(this),
            _to,
            _childTokenId
        );
        emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
    }

    function safeTransferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId,
        bytes memory _data
    ) external override {

        _transferChild(_fromTokenId, _to, _childContract, _childTokenId);
        IERC721(_childContract).safeTransferFrom(
            address(this),
            _to,
            _childTokenId,
            _data
        );
        emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
    }

    function transferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) external override {

        _transferChild(_fromTokenId, _to, _childContract, _childTokenId);
        bytes memory callData = abi.encodeWithSelector(
            APPROVE,
            this,
            _childTokenId
        );
        _childContract.call(callData);

        IERC721(_childContract).transferFrom(address(this), _to, _childTokenId);
        emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
    }

    function transferChildToParent(
        uint256 _fromTokenId,
        address _toContract,
        uint256 _toTokenId,
        address _childContract,
        uint256 _childTokenId,
        bytes memory _data
    ) external override {

        _transferChild(
            _fromTokenId,
            _toContract,
            _childContract,
            _childTokenId
        );
        IERC998ERC721BottomUp(_childContract).transferToParent(
            address(this),
            _toContract,
            _toTokenId,
            _childTokenId,
            _data
        );
        emit TransferChild(
            _fromTokenId,
            _toContract,
            _childContract,
            _childTokenId
        );
    }

    function getChild(
        address _from,
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) external override {

        receiveChild(_from, _tokenId, _childContract, _childTokenId);
        require(
            _from == msg.sender ||
                IERC721(_childContract).isApprovedForAll(_from, msg.sender) ||
                IERC721(_childContract).getApproved(_childTokenId) ==
                msg.sender,
            "CTD: msg.sender not approved"
        );
        IERC721(_childContract).transferFrom(
            _from,
            address(this),
            _childTokenId
        );
        rootOwnerOf(_tokenId);
    }

    function onERC721Received(
        address _from,
        uint256 _childTokenId,
        bytes calldata _data
    ) external returns (bytes4) {

        require(
            _data.length > 0,
            "CTD: onERC721Received(3) _data must contain the uint256 tokenId to transfer the child token to"
        );
        uint256 tokenId = _parseTokenId(_data);
        receiveChild(_from, tokenId, msg.sender, _childTokenId);
        require(
            IERC721(msg.sender).ownerOf(_childTokenId) != address(0),
            "CTD: onERC721Received(3) child token not owned"
        );
        rootOwnerOf(tokenId);
        return ERC721_RECEIVED_OLD;
    }

    function onERC721Received(
        address,
        address _from,
        uint256 _childTokenId,
        bytes calldata _data
    ) external override returns (bytes4) {

        require(
            _data.length > 0,
            "CTD: onERC721Received(4) _data must contain the uint256 tokenId to transfer the child token to"
        );
        uint256 tokenId = _parseTokenId(_data);
        receiveChild(_from, tokenId, msg.sender, _childTokenId);
        require(
            IERC721(msg.sender).ownerOf(_childTokenId) != address(0),
            "CTD: onERC721Received(4) child token not owned"
        );
        rootOwnerOf(tokenId);
        return ERC721_RECEIVED_NEW;
    }

    function childExists(address _childContract, uint256 _childTokenId)
        external
        view
        returns (bool)
    {

        uint256 tokenId = childTokenOwner[_childContract][_childTokenId];
        return tokenId != 0;
    }

    function totalChildContracts(uint256 _tokenId)
        public
        view
        override
        returns (uint256)
    {

        return childContracts[_tokenId].length();
    }

    function childContractByIndex(uint256 _tokenId, uint256 _index)
        public
        view
        override
        returns (address childContract)
    {

        return childContracts[_tokenId].at(_index);
    }

    function totalChildTokens(uint256 _tokenId, address _childContract)
        public
        view
        override
        returns (uint256)
    {

        return childTokens[_tokenId][_childContract].length();
    }

    function childTokenByIndex(
        uint256 _tokenId,
        address _childContract,
        uint256 _index
    ) public view override returns (uint256 childTokenId) {

        return childTokens[_tokenId][_childContract].at(_index);
    }

    function ownerOfChild(address _childContract, uint256 _childTokenId)
        external
        view
        override
        returns (bytes32 parentTokenOwner, uint256 parentTokenId)
    {

        parentTokenId = childTokenOwner[_childContract][_childTokenId];
        require(parentTokenId != 0, "CTD: not found");
        address parentTokenOwnerAddress = tokenIdToTokenOwner[parentTokenId];
        assembly {
            parentTokenOwner := or(
                ERC998_MAGIC_VALUE_32,
                parentTokenOwnerAddress
            )
        }
    }

    function _transferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) private {

        uint256 tokenId = childTokenOwner[_childContract][_childTokenId];
        require(tokenId != 0, "CTD: _childContract _childTokenId not found");
        require(tokenId == _fromTokenId, "CTD: wrong tokenId found");
        require(_to != address(0), "CTD: _to zero addr");
        address rootOwner = address(uint160(uint256(rootOwnerOf(tokenId))));
        require(
            rootOwner == msg.sender ||
                tokenOwnerToOperators[rootOwner][msg.sender] ||
                rootOwnerAndTokenIdToApprovedAddress[rootOwner][tokenId] ==
                msg.sender,
            "CTD: msg.sender not eligible"
        );
        removeChild(tokenId, _childContract, _childTokenId);
    }

    function _ownerOfChild(address _childContract, uint256 _childTokenId)
        private
        view
        returns (address parentTokenOwner, uint256 parentTokenId)
    {

        parentTokenId = childTokenOwner[_childContract][_childTokenId];
        require(parentTokenId != 0, "CTD: not found");
        return (tokenIdToTokenOwner[parentTokenId], parentTokenId);
    }

    function _parseTokenId(bytes memory _data)
        private
        pure
        returns (uint256 tokenId)
    {

        assembly {
            tokenId := mload(add(_data, 0x20))
        }
        if (_data.length < 32) {
            tokenId = tokenId >> (256 - _data.length * 8);
        }
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
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

    function removeChild(
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) private {

        uint256 lastTokenIndex = childTokens[_tokenId][_childContract]
            .length() - 1;
        childTokens[_tokenId][_childContract].remove(_childTokenId);
        delete childTokenOwner[_childContract][_childTokenId];

        if (lastTokenIndex == 0) {
            childContracts[_tokenId].remove(_childContract);
        }
        if (_childContract == address(this)) {
            _updateStateHash(
                _tokenId,
                uint256(uint160(_childContract)),
                tokenIdToStateHash[_childTokenId]
            );
        } else {
            _updateStateHash(
                _tokenId,
                uint256(uint160(_childContract)),
                _childTokenId
            );
        }
    }

    function receiveChild(
        address _from,
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) private {

        require(
            tokenIdToTokenOwner[_tokenId] != address(0),
            "CTD: _tokenId does not exist."
        );
        require(
            childTokenOwner[_childContract][_childTokenId] != _tokenId,
            "CTD: _childTokenId already received"
        );
        uint256 childTokensLength = childTokens[_tokenId][_childContract]
            .length();
        if (childTokensLength == 0) {
            childContracts[_tokenId].add(_childContract);
        }
        childTokens[_tokenId][_childContract].add(_childTokenId);
        childTokenOwner[_childContract][_childTokenId] = _tokenId;
        if (_childContract == address(this)) {
            _updateStateHash(
                _tokenId,
                uint256(uint160(_childContract)),
                tokenIdToStateHash[_childTokenId]
            );
        } else {
            _updateStateHash(
                _tokenId,
                uint256(uint160(_childContract)),
                _childTokenId
            );
        }
        emit ReceivedChild(_from, _tokenId, _childContract, _childTokenId);
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, ERC165)
        returns (bool)
    {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC998ERC721TopDown).interfaceId ||
            interfaceId == type(IERC998ERC721TopDownEnumerable).interfaceId ||
            interfaceId == 0x1bc995e4 ||
            super.supportsInterface(interfaceId);
    }


    function _updateStateHash(
        uint256 tokenId,
        uint256 childReference,
        uint256 value
    ) private {

        uint256 _newStateHash = uint256(
            keccak256(
                abi.encodePacked(
                    tokenIdToStateHash[tokenId],
                    childReference,
                    value
                )
            )
        );
        tokenIdToStateHash[tokenId] = _newStateHash;
        while (tokenIdToTokenOwner[tokenId] == address(this)) {
            tokenId = childTokenOwner[address(this)][tokenId];
            _newStateHash = uint256(
                keccak256(
                    abi.encodePacked(
                        tokenIdToStateHash[tokenId],
                        uint256(uint160(address(this))),
                        _newStateHash
                    )
                )
            );
            tokenIdToStateHash[tokenId] = _newStateHash;
        }
    }

    function stateHash(uint256 tokenId) public view returns (uint256) {

        uint256 _stateHash = tokenIdToStateHash[tokenId];
        require(_stateHash > 0, "CTD: stateHash of _tokenId is zero");
        return _stateHash;
    }

    function safeCheckedTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 expectedStateHash
    ) external {

        require(
            expectedStateHash == tokenIdToStateHash[tokenId],
            "CTD: stateHash mismatch (1)"
        );
        safeTransferFrom(from, to, tokenId);
    }

    function checkedTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 expectedStateHash
    ) external {

        require(
            expectedStateHash == tokenIdToStateHash[tokenId],
            "CTD: stateHash mismatch (2)"
        );
        transferFrom(from, to, tokenId);
    }

    function safeCheckedTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 expectedStateHash,
        bytes calldata data
    ) external {

        require(
            expectedStateHash == tokenIdToStateHash[tokenId],
            "CTD: stateHash mismatch (3)"
        );
        safeTransferFrom(from, to, tokenId, data);
    }
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
pragma solidity ^0.8.0;


contract MetaBoom is ComposableTopDown, Ownable {

    using Address for address;
    using Strings for uint256;

    uint256 public constant maxSupply = 5000;
    uint256 public constant price = 0.05 ether;
    uint256 public constant airDropMaxSupply = 300;
    uint256 public totalSupply = 0;
    uint256 public totalAirDrop = 0;
    string public baseTokenURI;
    string public subTokenURI;
    bool public paused = false;

    uint256 public preSaleTime = 1636682400;
    uint256 public publicSaleTime = 1637028000;

    mapping(address => bool) public airDropList;
    mapping(address => bool) public whiteList;
    mapping(address => uint8) public prePaidNumAry;
    mapping(address => uint8) public holdedNumAry;
    mapping(address => uint8) public claimed;
    mapping(uint256 => string) private _tokenURIs;

    event MetaBoomPop(uint256 indexed tokenId, address indexed tokenOwner);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        string memory _subUri
    ) ComposableTopDown(_name, _symbol) {
        baseTokenURI = _uri;
        subTokenURI = _subUri;
    }

    function preSale(uint8 _purchaseNum) external payable onlyWhiteList {

        require(!paused, "MetaBoom: currently paused");
        require(
            block.timestamp >= preSaleTime,
            "MetaBoom: preSale is not open"
        );
        require(
            (totalSupply + _purchaseNum) <= (maxSupply - airDropMaxSupply),
            "MetaBoom: reached max supply"
        );
        require(
            (holdedNumAry[_msgSender()] + _purchaseNum) <= 5,
            "MetaBoom: can not hold more than 5"
        );
        require(
            msg.value >= (price * _purchaseNum),
            "MetaBoom: price is incorrect"
        );

        holdedNumAry[_msgSender()] = holdedNumAry[_msgSender()] + _purchaseNum;
        prePaidNumAry[_msgSender()] =
            prePaidNumAry[_msgSender()] +
            _purchaseNum;
        totalSupply = totalSupply + _purchaseNum;
    }

    function publicSale(uint8 _purchaseNum) external payable {

        require(!paused, "MetaBoom: currently paused");
        require(
            block.timestamp >= publicSaleTime,
            "MetaBoom: publicSale is not open"
        );
        require(
            (totalSupply + _purchaseNum) <= (maxSupply - airDropMaxSupply),
            "MetaBoom: reached max supply"
        );
        require(
            (holdedNumAry[_msgSender()] + _purchaseNum) <= 5,
            "MetaBoom: can not hold more than 5"
        );
        require(
            msg.value >= (price * _purchaseNum),
            "MetaBoom: price is incorrect"
        );

        holdedNumAry[_msgSender()] = holdedNumAry[_msgSender()] + _purchaseNum;
        prePaidNumAry[_msgSender()] =
            prePaidNumAry[_msgSender()] +
            _purchaseNum;
        totalSupply = totalSupply + _purchaseNum;
    }

    function ownerMInt(address _addr)
        external
        onlyOwner
        returns (uint256 tokenId_)
    {

        require(
            totalSupply < (maxSupply - airDropMaxSupply),
            "MetaBoom: reached max supply"
        );
        require(holdedNumAry[_addr] < 5, "MetaBoom: can not hold more than 5");

        tokenId_ = _safeMint(_addr);
        holdedNumAry[_addr]++;
        claimed[_addr]++;
        totalSupply++;
        emit MetaBoomPop(tokenId_, _addr);
        return tokenId_;
    }

    function claimAirdrop() external onlyAirDrop {

        require(
            block.timestamp >= preSaleTime,
            "MetaBoom: Not able to claim yet."
        );
        uint256 tokenId_ = _safeMint(_msgSender());
        airDropList[_msgSender()] = false;
        emit MetaBoomPop(tokenId_, _msgSender());
        holdedNumAry[_msgSender()]++;
        claimed[_msgSender()]++;
    }

    function claimAll() external {

        require(
            block.timestamp >= preSaleTime,
            "MetaBoom: Not able to claim yet"
        );

        require(
            prePaidNumAry[_msgSender()] > 0,
            "MetaBoom: already claimed all"
        );

        for (uint8 i = 0; i < prePaidNumAry[_msgSender()]; i++) {
            uint256 tokenId_ = _safeMint(_msgSender());
            emit MetaBoomPop(tokenId_, _msgSender());
        }

        claimed[_msgSender()] += prePaidNumAry[_msgSender()];
        prePaidNumAry[_msgSender()] = 0;
    }

    modifier onlyWhiteList() {

        require(whiteList[_msgSender()], "MetaBoom: caller not in WhiteList");
        _;
    }

    modifier onlyAirDrop() {

        require(
            airDropList[_msgSender()],
            "MetaBoom: caller not in AirdropList"
        );
        _;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {

        baseTokenURI = _baseURI;
    }

    function setSubURI(string memory _subURI) external onlyOwner {

        subTokenURI = _subURI;
    }

    function setTokenURI(uint256 _tokenId, string memory _tokenURI)
        external
        onlyOwner
    {

        _tokenURIs[_tokenId] = _tokenURI;
    }

    function setPreSaleTime(uint256 _time) external onlyOwner {

        preSaleTime = _time;
    }

    function setPublicSaleTime(uint256 _time) external onlyOwner {

        publicSaleTime = _time;
    }

    function pauseSale() external onlyOwner {

        paused = !paused;
    }

    function addBatchWhiteList(address[] memory _accounts) external onlyOwner {

        for (uint256 i = 0; i < _accounts.length; i++) {
            whiteList[_accounts[i]] = true;
        }
    }

    function addBatchAirDropList(address[] memory _accounts)
        external
        onlyOwner
    {

        require(
            totalAirDrop + _accounts.length <= airDropMaxSupply,
            "reached max airDropSupply"
        );

        for (uint256 i = 0; i < _accounts.length; i++) {
            require(holdedNumAry[_accounts[i]] < 5, "can not hold more than 5");
            airDropList[_accounts[i]] = true;
        }

        totalAirDrop = totalAirDrop + _accounts.length;
    }

    function withdraw() external onlyOwner {

        payable(owner()).transfer(address(this).balance);
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {

        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }

    function childContractOfToken(uint256 _tokenId)
        external
        view
        returns (address[] memory)
    {

        uint256 childCount = totalChildContracts(_tokenId);
        if (childCount == 0) {
            return new address[](0);
        } else {
            address[] memory result = new address[](childCount);
            uint256 index;
            for (index = 0; index < childCount; index++) {
                result[index] = childContractByIndex(_tokenId, index);
            }
            return result;
        }
    }

    function childTokensOfChildContract(uint256 _tokenId, address _childAddr)
        external
        view
        returns (uint256[] memory)
    {

        uint256 tokenCount = totalChildTokens(_tokenId, _childAddr);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = childTokenByIndex(_tokenId, _childAddr, index);
            }
            return result;
        }
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {

        return
            bytes(_tokenURIs[_tokenId]).length > 0
                ? string(abi.encodePacked(subTokenURI, _tokenURIs[_tokenId]))
                : string(
                    abi.encodePacked(baseTokenURI, Strings.toString(_tokenId))
                );
    }
}

pragma solidity ^0.8.0;

interface IERC721ReceiverOld {

    function onERC721Received(address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

pragma solidity ^0.8.0;

interface IERC998ERC721BottomUpEnumerable {

    function totalChildTokens(address _parentContract, uint256 _parentTokenId)
        external
        view
        returns (uint256);


    function childTokenByIndex(
        address _parentContract,
        uint256 _parentTokenId,
        uint256 _index
    ) external view returns (uint256);

}
