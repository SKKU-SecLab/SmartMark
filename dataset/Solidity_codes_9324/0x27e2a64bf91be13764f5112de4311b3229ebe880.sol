
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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
}// MIT

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



contract SupdoodleducksStaking is Ownable, IERC721Receiver, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;
    address public stakingDestinationAddress = 0x23988C2130b2D8A8334e85de4053C68A1e1F1639;
    mapping(address => EnumerableSet.UintSet) private deposits;
    mapping(uint256 => address) private tokenofaddr;
    mapping(uint256 => uint) private staketokentimestamp;
    struct WinnerResult {
        address winneraddress;
        uint256 winnertokenid;
    }
    WinnerResult[] public WinnerResults;

    function querywinnerbytokens(uint256[] calldata _tokenIds, uint256 ethprice) public view returns (uint256, address) {

        uint256 wintokenid;
        address winneraddress;
        uint256 seedinput;
        for (uint256 i; i < _tokenIds.length; i++) {
            seedinput = seedinput + _tokenIds[i] + ethprice;
        }
        seedinput = seedinput + block.timestamp;
        uint256 rand = random(string(abi.encodePacked(seedinput.toString())));
        uint256 index = rand % _tokenIds.length;
        wintokenid = _tokenIds[index];
        winneraddress = queryownerbytoken(_tokenIds[index]);
        return (wintokenid, winneraddress);
    }


    function querystaketokenbytimestamp(uint time, uint256[] calldata staketokenIds) public view returns (uint256[] memory) {

        uint[] memory stakestamp;
        uint256[] memory staketokenqualifiedIds = new uint256[] (staketokenIds.length);
        stakestamp = querystaketimebytokens(staketokenIds);
        for (uint256 i; i < stakestamp.length; i++) {
            if (stakestamp[i] >= time) {
                staketokenqualifiedIds[i] = staketokenIds[i];
            } else {
                staketokenqualifiedIds[i] = 0;
            }
        }
        return staketokenqualifiedIds;
    }


    function querystaketokenbyaddress(address _account) public view returns (uint256[] memory) {

        EnumerableSet.UintSet storage depositSet = deposits[_account];
        uint256[] memory tokenIds = new uint256[] (depositSet.length());
        for (uint256 i; i < depositSet.length(); i++) {
            tokenIds[i] = depositSet.at(i);
        }
        return tokenIds;
    }

    function querystaketimebytokens(uint256[] calldata _tokenIds) public view returns (uint[] memory) {

        uint[] memory tokenstaketime = new uint[] (_tokenIds.length);
        for (uint256 i; i < _tokenIds.length; i++) {
            tokenstaketime[i] = block.timestamp - staketokentimestamp[_tokenIds[i]];
        }
        return tokenstaketime;
    }

    function queryownerbytoken(uint256 _tokenId) public view returns (address) {

        return tokenofaddr[_tokenId];
    }

    function random(string memory input) internal pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked(input)));
    }

    function deposit(uint256[] calldata _tokenIds) external {

        require(msg.sender != stakingDestinationAddress, "Invalid address");
        require(tx.origin == msg.sender, "Only EOA");
        for (uint256 i; i < _tokenIds.length; i++) {
            require(IERC721(stakingDestinationAddress).ownerOf(_tokenIds[i]) == _msgSender(), "You don't own this token");
            deposits[msg.sender].add(_tokenIds[i]);
            staketokentimestamp[_tokenIds[i]] = block.timestamp;
            tokenofaddr[_tokenIds[i]] = msg.sender;
            IERC721(stakingDestinationAddress).safeTransferFrom(msg.sender, address(this), _tokenIds[i], "");
        }
    }

    function withdraw(uint256[] calldata _tokenIds) external nonReentrant() {

        for (uint256 i; i < _tokenIds.length; i++) {
            require(deposits[msg.sender].contains(_tokenIds[i]), "Staking: token not deposited");
            deposits[msg.sender].remove(_tokenIds[i]);
            staketokentimestamp[_tokenIds[i]] = 0;
            tokenofaddr[_tokenIds[i]] = address(0);
            IERC721(stakingDestinationAddress).safeTransferFrom(address(this), msg.sender, _tokenIds[i], "");
        }
    }

    function openLottery(uint time, uint256[] calldata staketokenIds, uint256 ethprice) public onlyOwner {

        uint256[] memory lotterytokenids;
        uint256 seedinput;
        uint256 winnerindex;
        address winneraddr;
        lotterytokenids = querystaketokenbytimestamp(time, staketokenIds);
        seedinput = (block.timestamp + ethprice) * lotterytokenids.length ;
        winnerindex = random(string(abi.encodePacked(seedinput.toString()))) % lotterytokenids.length;
        winneraddr = queryownerbytoken(lotterytokenids[winnerindex]);
        WinnerResults.push(WinnerResult({
        winneraddress : winneraddr,
        winnertokenid : lotterytokenids[winnerindex]
        }));
    }


    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {

        return IERC721Receiver.onERC721Received.selector;
    }

}