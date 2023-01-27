
pragma solidity >=0.6.0 <0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


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

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;

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
}// AGPL-1.0
pragma solidity 0.7.6;


abstract contract ERC721Base is IERC165, IERC721 {
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;
    bytes4 internal constant ERC165ID = 0x01ffc9a7;

    uint256 internal constant OPERATOR_FLAG = (2**255);

    mapping(uint256 => uint256) internal _owners;
    mapping(address => EnumerableSet.UintSet) internal _holderTokens;
    mapping(address => mapping(address => bool)) internal _operatorsForAll;
    mapping(uint256 => address) internal _operators;

    function totalSupply() external pure returns (uint256) {
        return 2**160 - 1; // do not count token with id zero whose owner would otherwise be the zero address
    }

    function tokenByIndex(uint256 index) external pure returns (uint256) {
        require(index < 2**160 - 1, "NONEXISTENT_TOKEN");
        return index + 1; // skip zero as we do not count token with id zero whose owner would otherwise be the zero address
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS_OWNER");
        (, bool registered) = _ownerOfAndRegistered(uint256(owner));
        if (!registered) {
            if (index == 0) {
                return uint256(owner);
            }
            index--;
        }
        return _holderTokens[owner].at(index);
    }

    function approve(address operator, uint256 id) external override {
        (address owner, bool registered) = _ownerOfAndRegistered(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(owner == msg.sender || _operatorsForAll[owner][msg.sender], "UNAUTHORIZED_APPROVAL");
        _approveFor(owner, operator, id, registered);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) external override {
        (address owner, bool operatorEnabled, bool registered) = _ownerRegisteredAndOperatorEnabledOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(owner == from, "NOT_OWNER");
        require(to != address(0), "NOT_TO_ZEROADDRESS");
        require(to != address(this), "NOT_TO_THIS");
        if (msg.sender != from) {
            require(
                _operatorsForAll[from][msg.sender] || (operatorEnabled && _operators[id] == msg.sender),
                "UNAUTHORIZED_TRANSFER"
            );
        }
        _transferFrom(from, to, id, registered);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external override {
        safeTransferFrom(from, to, id, "");
    }

    function setApprovalForAll(address operator, bool approved) external override {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function balanceOf(address owner) external view override returns (uint256 balance) {
        require(owner != address(0), "ZERO_ADDRESS_OWNER");
        balance = _holderTokens[owner].length();
        (, bool registered) = _ownerOfAndRegistered(uint256(owner));
        if (!registered) {
            balance++;
        }
    }

    function ownerOf(uint256 id) external view override returns (address owner) {
        owner = _ownerOf(id);
        require(owner != address(0), "NONEXISTANT_TOKEN");
    }

    function getApproved(uint256 id) external view override returns (address) {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        if (operatorEnabled) {
            return _operators[id];
        } else {
            return address(0);
        }
    }

    function isApprovedForAll(address owner, address operator) external view override returns (bool isOperator) {
        return _operatorsForAll[owner][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public override {
        (address owner, bool operatorEnabled, bool registered) = _ownerRegisteredAndOperatorEnabledOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(owner == from, "NOT_OWNER");
        require(to != address(0), "NOT_TO_ZEROADDRESS");
        require(to != address(this), "NOT_TO_THIS");
        if (msg.sender != from) {
            require(
                _operatorsForAll[from][msg.sender] || (operatorEnabled && _operators[id] == msg.sender),
                "UNAUTHORIZED_TRANSFER"
            );
        }
        _safeTransferFrom(from, to, id, registered, data);
    }

    function supportsInterface(bytes4 id) public pure virtual override returns (bool) {
        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x5b5e139f || id == 0x780e9d63;
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bool alreadyRegistered,
        bytes memory data
    ) internal {
        _transferFrom(from, to, id, alreadyRegistered);
        if (to.isContract()) {
            require(_checkOnERC721Received(msg.sender, from, to, id, data), "ERC721_TRANSFER_REJECTED");
        }
    }

    function _transferFrom(
        address from,
        address to,
        uint256 id,
        bool alreadyRegistered
    ) internal {
        if (alreadyRegistered) {
            _holderTokens[from].remove(id);
        }
        _holderTokens[to].add(id);
        _owners[id] = uint256(to);
        emit Transfer(from, to, id);
    }

    function _approveFor(
        address owner,
        address operator,
        uint256 id,
        bool alreadyRegistered
    ) internal {
        if (operator == address(0)) {
            _owners[id] = alreadyRegistered ? uint256(owner) : 0;
        } else {
            _owners[id] = OPERATOR_FLAG | (alreadyRegistered ? uint256(owner) : 0);
            _operators[id] = operator;
        }
        emit Approval(owner, operator, id);
    }

    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal {
        _operatorsForAll[sender][operator] = approved;

        emit ApprovalForAll(sender, operator, approved);
    }

    function _checkOnERC721Received(
        address operator,
        address from,
        address to,
        uint256 id,
        bytes memory _data
    ) internal returns (bool) {
        bytes4 retval = IERC721Receiver(to).onERC721Received(operator, from, id, _data);
        return (retval == ERC721_RECEIVED);
    }

    function _ownerOf(uint256 id) internal view returns (address owner) {
        owner = address(_owners[id]);
        if (owner == address(0) && id < 2**160) {
            owner = address(id);
        }
    }

    function _ownerOfAndRegistered(uint256 id) internal view returns (address owner, bool registered) {
        owner = address(_owners[id]);
        if (owner == address(0) && id < 2**160) {
            owner = address(id);
        } else {
            registered = true;
        }
    }

    function _ownerAndOperatorEnabledOf(uint256 id) internal view returns (address owner, bool operatorEnabled) {
        uint256 data = _owners[id];
        owner = address(data);
        if (owner == address(0) && id < 2**160) {
            owner = address(id);
        }
        operatorEnabled = (data & OPERATOR_FLAG) == OPERATOR_FLAG;
    }

    function _ownerRegisteredAndOperatorEnabledOf(uint256 id)
        internal
        view
        returns (
            address owner,
            bool operatorEnabled,
            bool registered
        )
    {
        uint256 data = _owners[id];
        owner = address(data);
        if (owner == address(0) && id < 2**160) {
            owner = address(id);
        } else {
            registered = true;
        }
        operatorEnabled = (data & OPERATOR_FLAG) == OPERATOR_FLAG;
    }
}// Unlicense
pragma solidity 0.7.6;

interface ISyntheticLoot {


    function weaponComponents(address walletAddress) external view returns (uint256[5] memory);


    function chestComponents(address walletAddress) external view returns (uint256[5] memory);


    function headComponents(address walletAddress) external view returns (uint256[5] memory);


    function waistComponents(address walletAddress) external view returns (uint256[5] memory);


    function footComponents(address walletAddress) external view returns (uint256[5] memory);


    function handComponents(address walletAddress) external view returns (uint256[5] memory);


    function neckComponents(address walletAddress) external view returns (uint256[5] memory);


    function ringComponents(address walletAddress) external view returns (uint256[5] memory);


    function getWeapon(address walletAddress) external view returns (string memory);


    function getChest(address walletAddress) external view returns (string memory);


    function getHead(address walletAddress) external view returns (string memory);


    function getWaist(address walletAddress) external view returns (string memory);


    function getFoot(address walletAddress) external view returns (string memory);


    function getHand(address walletAddress) external view returns (string memory);


    function getNeck(address walletAddress) external view returns (string memory);


    function getRing(address walletAddress) external view returns (string memory);


    function tokenURI(address walletAddress) external view returns (string memory);


}// Unlicense
pragma solidity 0.7.6;


interface ILoot is IERC721Metadata{


}// AGPL-1.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


contract LootForEveryone is ERC721Base {

    using EnumerableSet for EnumerableSet.UintSet;
    using ECDSA for bytes32;

    struct TokenData {
        uint256 id;
        string tokenURI;
        bool claimed;
    }

    ILoot private immutable _loot;
    ISyntheticLoot private immutable _syntheticLoot;

    constructor(ILoot loot, ISyntheticLoot syntheticLoot) {
        _loot = loot;
        _syntheticLoot = syntheticLoot;
    }

    function name() external pure returns (string memory) {

        return "Loot For Everyone";
    }

    function symbol() external pure returns (string memory) {

        return "LOOT";
    }

    function tokenURI(uint256 id) external view returns (string memory) {

        return _tokenURI(id);
    }

    function getTokenDataOfOwner(
        address owner,
        uint256 start,
        uint256 num
    ) external view returns (TokenData[] memory tokens) {

        require(start < 2**160 && num < 2**160, "INVALID_RANGE");
        EnumerableSet.UintSet storage allTokens = _holderTokens[owner];
        uint256 balance = allTokens.length();
        (, bool registered) = _ownerOfAndRegistered(uint256(owner));
        if (!registered) {
            balance++;
        }
        require(balance >= start + num, "TOO_MANY_TOKEN_REQUESTED");
        tokens = new TokenData[](num);
        uint256 i = 0;
        uint256 offset = 0;
        if (start == 0 && !registered) {
            tokens[0] = TokenData(uint256(owner), _tokenURI(uint256(owner)), false);
            offset = 1;
            i = 1;
        }
        while (i < num) {
            uint256 id = allTokens.at(start + i - offset);
            tokens[i] = TokenData(id, _tokenURI(id), true);
            i++;
        }
    }

    function getTokenDataForIds(uint256[] memory ids) external view returns (TokenData[] memory tokens) {

        tokens = new TokenData[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            (, bool registered) = _ownerOfAndRegistered(id);
            tokens[i] = TokenData(id, _tokenURI(id), registered);
        }
    }

    function pickLoot(address to, bytes memory signature) external {

        require(to != address(0), "NOT_TO_ZEROADDRESS");
        require(to != address(this), "NOT_TO_THIS");
        bytes32 hashedData = keccak256(abi.encodePacked("LootForEveryone", to));
        address signer = hashedData.toEthSignedMessageHash().recover(signature);
        (, bool registered) = _ownerOfAndRegistered(uint256(signer));
        require(!registered, "ALREADY_CALIMED");
        _safeTransferFrom(signer, to, uint256(signer), false, "");
    }

    function isLootPicked(uint256 id) external view returns(bool) {

        (address owner, bool registered) = _ownerOfAndRegistered(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        return registered;
    }

    function transmute(uint256 id, address to) external {

        require(to != address(0), "NOT_TO_ZEROADDRESS");
        require(to != address(this), "NOT_TO_THIS");
        _loot.transferFrom(msg.sender, address(this), id);
        (address owner, bool registered) = _ownerOfAndRegistered(id);
        if (registered) {
            require(owner == address(this), "ALREADY_CLAIMED"); // unlikely to happen, would need to find the private key for its adresss (< 8001)
            _safeTransferFrom(address(this), to, id, false, "");
        } else {
            _safeTransferFrom(address(id), to, id, false, "");
        }
    }

    function transmuteBack(uint256 id, address to) external {

        require(to != address(0), "NOT_TO_ZEROADDRESS");
        require(to != address(this), "NOT_TO_THIS");
        (address owner, bool registered) = _ownerOfAndRegistered(id);
        require(msg.sender == owner, "NOT_OWNER");
        _transferFrom(owner, address(this), id, registered);
        _loot.transferFrom(address(this), to, id);
    }


    function _tokenURI(uint256 id) internal view returns (string memory) {

        require(id > 0 && id < 2**160, "NONEXISTENT_TOKEN");
        if (id < 8001) {
            return _loot.tokenURI(id);
        }
        return _syntheticLoot.tokenURI(address(id));
    }
}