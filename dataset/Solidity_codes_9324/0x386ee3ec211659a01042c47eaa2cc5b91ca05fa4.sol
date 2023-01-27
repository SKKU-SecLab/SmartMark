

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



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

}



pragma solidity >=0.6.2 <0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}




pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}




pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}




pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}




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
}




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
}




pragma solidity >=0.6.0 <0.8.0;

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

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
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

        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
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
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}




pragma solidity >=0.6.0 <0.8.0;

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
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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




pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
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




pragma solidity >=0.6.0 <0.8.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}




pragma solidity >=0.6.0 <0.8.0;






contract RtistiqBase is Ownable, Pausable {


    using SafeMath for uint256;
    using Address for address;


    address private tokenContract;

    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    struct art {
        address owner;
        string ipfsMetadataHash;
    }

    mapping(uint256 => art) private arts;

    mapping(bytes32 => bool) private rfids;
 
    mapping (uint256 => address) private tokenApprovals;

    bool public isRtistiqBase = true;
   
    modifier onlyTokenContract() {

        require(msg.sender == tokenContract, "Sender not allowed to call this function");
        _;
    }

    function setTokenContract(address _currentTokenContract) public onlyOwner {

        tokenContract = _currentTokenContract;
    }

    function getTokenContract() public view returns (address) {

        return tokenContract;
    }
    
    function rfidExists(bytes32 _rfid) public view returns (bool) {

       return rfids[_rfid];
    }

    function tokenExists(uint256 _tokenId) public view returns (bool) {

        if (arts[_tokenId].owner!=address(0)) {
            return true;
        }
        else {
            return false;
        }
    }

    function getTokenOwnerOf(uint256 _tokenId) public view returns (address) {

        return arts[_tokenId].owner;
    }

    function getTokenURI(uint256 _tokenId) public view returns (string memory) {

        return arts[_tokenId].ipfsMetadataHash;
    }

    function mintToken(address _to, 
        bytes32 _rfid, 
        string memory _tokenURI
    ) public onlyTokenContract whenNotPaused returns (uint256) {

        tokenIds.increment(); 
        uint256 tokenId =  tokenIds.current();     
        arts[tokenId].ipfsMetadataHash = _tokenURI;
        arts[tokenId].owner = _to;
        rfids[_rfid] = true;
        return tokenId;
    } 

    function burnToken(uint256 _tokenId) public onlyTokenContract whenNotPaused {

        setTokenApprovals(address(0), _tokenId);
        arts[_tokenId].ipfsMetadataHash = '';
        arts[_tokenId].owner = address(0);
    }
    
    function transferToken(address _to, uint256 _tokenId) public onlyTokenContract whenNotPaused {

        setTokenApprovals(address(0), _tokenId);
        arts[_tokenId].owner = _to;
    }

    function updateTokenMetadata(uint256 _tokenId, string memory _tokenURI) public onlyTokenContract whenNotPaused {

        arts[_tokenId].ipfsMetadataHash = _tokenURI;
    }

    function setTokenApprovals(address _to, uint256 _tokenId) public onlyTokenContract whenNotPaused returns (address) {

        return tokenApprovals[_tokenId] = _to;
    }

    function getTokenApprovals(uint256 _tokenId) public view returns (address) {

        require(tokenExists(_tokenId), "Token does not exists");
        return tokenApprovals[_tokenId];
    }

    function pause() onlyOwner whenNotPaused public {

        _pause();
    }

    function unpause() onlyOwner whenPaused public {

        _unpause();
    }

}




pragma solidity >=0.6.0 <0.8.0;













contract RtistiqToken is Context, ERC165, IERC721, IERC721Metadata, Ownable, Pausable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    RtistiqBase internal rtistiqBase;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    string private _name;

    string private _symbol;

    string private _baseURI;

    address private baseContractAddress;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;


    constructor (string memory name_, string memory symbol_, string memory baseUri_) public {
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseUri_;
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function setRtistiqBaseAddress(address _address) public onlyOwner {

        RtistiqBase candidateContract = RtistiqBase(_address);
        baseContractAddress = _address;
        require(candidateContract.isRtistiqBase());
        rtistiqBase = candidateContract;
    }

    function getBaseContract() public view returns (address) {

        return baseContractAddress;
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {

        return 0;
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        return rtistiqBase.getTokenOwnerOf(tokenId);
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(rtistiqBase.tokenExists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = rtistiqBase.getTokenURI(tokenId);
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function baseURI() public view virtual returns (string memory) {

        return _baseURI;
    }

    function setBaseURI(string memory baseUri_) public {

        _baseURI = baseUri_;
    }

    function _mint(address to, bytes32 rfid, string memory metadata) internal returns (uint256) {

        uint256 tokenId = rtistiqBase.mintToken(to,rfid,metadata);
        emit Transfer(address(0), to, tokenId);
        return tokenId;
    }

    function _updateMetadata(uint256 _tokenId, string memory _tokenURI) internal {

        rtistiqBase.updateTokenMetadata(_tokenId, _tokenURI);
    }
    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: transfer to the zero address");
        address previousOwner = RtistiqToken.ownerOf(tokenId);
        rtistiqBase.transferToken(to, tokenId);

        emit Transfer(previousOwner, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = RtistiqToken.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        
        _canOperate(_msgSender(), owner);
        _approve(to, tokenId);
    }

    function _canOperate(address spender, address owner) internal view virtual returns (bool) {


        require(spender == owner || RtistiqToken.isApprovedForAll(owner, spender),
                "ERC721: approve caller is not owner nor approved for all"
            );
    }

    function _approve(address to, uint256 tokenId) internal {

        rtistiqBase.setTokenApprovals(to, tokenId);
        emit Approval(RtistiqToken.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function clearApproval(uint256 tokenId) internal {

        rtistiqBase.setTokenApprovals(address(0), tokenId);
        emit Approval(RtistiqToken.ownerOf(tokenId), address(0), tokenId); // internal owner
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

       return rtistiqBase.getTokenApprovals(tokenId);
    }

    function setApprovalForAll(address operator, bool _approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return false;
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(rtistiqBase.tokenExists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = RtistiqToken.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || RtistiqToken.isApprovedForAll(owner, spender));
    }

    function _burn(uint256 tokenId) internal virtual whenNotPaused {

        address owner = rtistiqBase.getTokenOwnerOf(tokenId);
        rtistiqBase.burnToken(tokenId);

        emit Transfer(owner, address(0), tokenId);
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

    function pause() onlyOwner whenNotPaused public {

        _pause();
    }

    function unpause() onlyOwner whenPaused public {

        _unpause();
    }
}




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
}




pragma solidity >=0.6.0 <0.8.0;




contract RtistiqCore is RtistiqToken {


  constructor() public RtistiqToken("Rtistiq", "RQT", "https://gateway.pinata.cloud/ipfs/") {}

  using ECDSA for bytes32;

  function verifySignature(
      bool isWeb3Signature,
      address _signer,
      bytes24 _message,
      bytes memory _signature
  ) private pure returns (bool) {

      bytes32 hash = '';
      
      if (!isWeb3Signature) {
        hash = keccak256(abi.encodePacked(_message));
      }
      else {
        hash = toEthSignedMessageHash(_message);
      }
      
      address sigOwner = hash.recover(_signature);
      return _signer == sigOwner;
  }

  function toEthSignedMessageHash(bytes24 _message)  internal pure returns (bytes32) {

    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n24", _message)
    );
  }

  function createArtworkToken(bytes24 _artId,
    bool _isWeb3Signature,
    bytes32 _rfid, 
    address _recipient, 
    address _signer,
    string memory _metadata, 
    bytes memory _signature
  ) public onlyOwner whenNotPaused returns (uint256)  {

    
    require(rtistiqBase.rfidExists(_rfid) != true, "The given RFID already exists!");
    require(verifySignature(_isWeb3Signature,_signer,_artId, _signature), "Signature Verification failed");

    uint256 tokenId = _mint(_recipient,_rfid,_metadata);
    return tokenId;
  }

  function transferArtworkOwnership(uint256 _tokenId, 
    bytes32 _rfid, 
    address _from, 
    address _to,
    bool _isWeb3Signature, 
    bytes memory _signature
  ) public onlyOwner whenNotPaused {

    bytes32 _hash = '';
      
      if (!_isWeb3Signature) {
        _hash = keccak256(abi.encodePacked(_rfid, _to));
      }
      else {
        _hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_rfid));
      }

    address sigOwner = _hash.recover(_signature);
    require(_from == sigOwner, "Signature verification Failed");
    require(_isApprovedOrOwner(_from, _tokenId), "Transfer caller is not the owner nor approved");
    _transfer(_from, _to, _tokenId);   
  }

  function artworkApprove(bytes24 _artId,
    uint256 _tokenId, 
    address _from, 
    address _to, 
    bytes memory _signature
  ) public onlyOwner whenNotPaused {

      
    address owner = RtistiqToken.ownerOf(_tokenId);
    require(_to != owner, "Approval to the current owner");
    require(verifySignature(true,_from,_artId, _signature), "Signature Verification failed");
    _canOperate(_from, owner);
    _approve(_to, _tokenId);
  }

  function artworkClearApproval(bytes24 _artId,
    uint256 _tokenId, 
    address _from, 
    bytes memory _signature
  ) public onlyOwner whenNotPaused {

    require(verifySignature(true,_from,_artId, _signature), "Signature Verification failed");
          
    address owner = RtistiqToken.ownerOf(_tokenId);
    _canOperate(_from, owner);
    clearApproval(_tokenId);
  }
  
  function burnArtworkToken(bytes24 _artId, 
    uint256 _tokenId, 
    address _from, 
    bytes memory _signature
  ) public onlyOwner whenNotPaused {

    require(verifySignature(true,_from,_artId, _signature), "Signature Verification failed");
    require(_isApprovedOrOwner(_from, _tokenId), "Transfer caller is not the owner nor approved");
    _burn(_tokenId);
  }

  function updateArtworkMetadata(bytes24 _artId, 
    uint256 _tokenId,
    address _from, 
    string memory _metadata, 
    bytes memory _signature
  ) public onlyOwner whenNotPaused {

    require(verifySignature(true,_from,_artId, _signature), "Signature Verification failed");
    require(_isApprovedOrOwner(_from, _tokenId), "Transfer caller is not the owner nor approved");
    _updateMetadata(_tokenId, _metadata);
  }

}