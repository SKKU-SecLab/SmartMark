
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
}// MIT
pragma solidity ^0.7.0;

abstract contract Proxied {
    modifier proxied() {
        address ownerAddress = _owner();
        if (ownerAddress == address(0)) {
            assembly {
                sstore(
                    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                )
            }
        } else {
            require(msg.sender == ownerAddress);
        }
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner(), "NOT_AUTHORIZED");
        _;
    }

    function _owner() internal view returns (address ownerAddress) {
        assembly {
            ownerAddress := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
        }
    }
}// MIT
pragma solidity 0.7.1;


abstract contract ERC721Base is IERC165, IERC721 {
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;
    bytes4 internal constant ERC165ID = 0x01ffc9a7;

    uint256 internal constant OPERATOR_FLAG = (2**255);
    uint256 internal constant BURN_FLAG = (2**254);

    uint256 internal _supply;
    mapping (uint256 => uint256) internal _owners;
    mapping (address => EnumerableSet.UintSet) internal _holderTokens;
    mapping(address => mapping(address => bool)) internal _operatorsForAll;
    mapping(uint256 => address) internal _operators;


    function approve(address operator, uint256 id) external override {
        address owner = _ownerOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(owner == msg.sender || _operatorsForAll[owner][msg.sender], "UNAUTHORIZED_APPROVAL");
        _approveFor(owner, operator, id);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) external override {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(owner == from, "NOT_OWNER");
        require(to != address(0), "NOT_TO_ZEROADDRESS");
        if (msg.sender != from) {
            require(
                _operatorsForAll[from][msg.sender] || (operatorEnabled && _operators[id] == msg.sender),
                "UNAUTHORIZED_TRANSFER"
            );
        }
        _transferFrom(from, to, id);
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
    }

    function ownerOf(uint256 id) external view override returns (address owner) {
        owner = _ownerOf(id);
        require(owner != address(0), "NONEXISTANT_TOKEN");
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    function totalSupply() external view returns (uint256) {
        return _supply;
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
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(owner == from, "NOT_OWNER");
        require(to != address(0), "NOT_TO_ZEROADDRESS");
        if (msg.sender != from) {
            require(
                _operatorsForAll[from][msg.sender] || (operatorEnabled && _operators[id] == msg.sender),
                "UNAUTHORIZED_TRANSFER"
            );
        }
        _transferFrom(from, to, id);
        if (to.isContract()) {
            require(_checkOnERC721Received(msg.sender, from, to, id, data), "ERC721_TRANSFER_REJECTED");
        }
    }

    function supportsInterface(bytes4 id) public pure virtual override returns (bool) {
        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x780e9d63;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 id
    ) internal {
        _holderTokens[from].remove(id);
        _holderTokens[to].add(id);
        _owners[id] = uint256(to);
        emit Transfer(from, to, id);
    }

    function _approveFor(
        address owner,
        address operator,
        uint256 id
    ) internal {
        if (operator == address(0)) {
            _owners[id] =  uint256(owner);
        } else {
            _owners[id] = OPERATOR_FLAG | uint256(owner);
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
        bytes memory data
    ) internal returns (bool) {
        bytes4 retval = IERC721Receiver(to).onERC721Received(operator, from, id, data);
        return (retval == ERC721_RECEIVED);
    }

    function _ownerOf(uint256 id) internal view returns (address owner) {
        owner = address(_owners[id]);
        require(owner != address(0), "NOT_EXIST");
    }

    function _ownerAndOperatorEnabledOf(uint256 id) internal view returns (address owner, bool operatorEnabled) {
        uint256 data = _owners[id];
        owner = address(data);
        operatorEnabled = (data & OPERATOR_FLAG) == OPERATOR_FLAG;
    }

    function _mint(uint256 id, address to) internal {
        require(to != address(0), "NOT_TO_ZEROADDRESS");
        uint256 data = _owners[id];
        require(data == 0, "ALREADY_MINTED");
        _holderTokens[to].add(id);
        _owners[id] = uint256(to);
        _supply ++;
        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal {
        uint256 data = _owners[id];
        require(data != 0, "NOT_EXIST");
        require(data & BURN_FLAG == 0, "ALREADY_BURNT");
        address owner = address(data);
        require(msg.sender == owner, "NOT_OWNER");
        _holderTokens[owner].remove(id);
        _owners[id] = BURN_FLAG;
        _supply --;
        emit Transfer(msg.sender, address(0), id);
    }
}// MIT
pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;



contract MandalaToken is ERC721Base, IERC721Metadata, Proxied {

    using EnumerableSet for EnumerableSet.UintSet;
    using ECDSA for bytes32;


    bytes internal constant TEMPLATE = 'data:text/plain,{"name":"Mandala 0x0000000000000000000000000000000000000000","description":"A Unique Mandala","image":"data:image/svg+xml,<svg xmlns=\'http://www.w3.org/2000/svg\' shape-rendering=\'crispEdges\' width=\'512\' height=\'512\'><g transform=\'scale(64)\'><image width=\'8\' height=\'8\' style=\'image-rendering: pixelated;\' href=\'data:image/gif;base64,R0lGODdhEwATAMQAAAAAAPb+Y/7EJfN3NNARQUUKLG0bMsR1SujKqW7wQwe/dQBcmQeEqjDR0UgXo4A0vrlq2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkKAAAALAAAAAATABMAAAdNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA6gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGBADs=\'/></g></svg>"}';
    uint256 internal constant IMAGE_DATA_POS = 521;
    uint256 internal constant ADDRESS_NAME_POS = 74;

    uint256 internal constant WIDTH = 19;
    uint256 internal constant HEIGHT = 19;
    uint256 internal constant ROW_PER_BLOCK = 4;
    bytes32 constant internal xs = 0x8934893467893456789456789567896789789899000000000000000000000000;
    bytes32 constant internal ys = 0x0011112222223333333444444555556666777889000000000000000000000000;

    event Minted(uint256 indexed id, uint256 indexed pricePaid);
    event Burned(uint256 indexed id, uint256 indexed priceReceived);
    event CreatorshipTransferred(address indexed previousCreator, address indexed newCreator);

    uint256 public immutable linearCoefficient;
    uint256 public immutable initialPrice;
    uint256 public immutable creatorCutPer10000th;
    address payable public creator;

    constructor(address payable _creator, uint256 _initialPrice, uint256 _creatorCutPer10000th, uint256 _linearCoefficient) {
        require(_creatorCutPer10000th < 2000, "CREATOR_CUT_ROO_HIGHT");
        initialPrice = _initialPrice;
        creatorCutPer10000th = _creatorCutPer10000th;
        linearCoefficient = _linearCoefficient;
        postUpgrade(_creator, _initialPrice, _creatorCutPer10000th, _linearCoefficient);
    }

    function postUpgrade(address payable _creator, uint256 _initialPrice, uint256 _creatorCutPer10000th, uint256 _linearCoefficient) public proxied {

        creator = _creator;
        emit CreatorshipTransferred(address(0), creator);
    }


    function transferCreatorship(address payable newCreatorAddress) external {

        address oldCreator = creator;
        require(oldCreator == msg.sender, "NOT_AUTHORIZED");
        creator = newCreatorAddress;
        emit CreatorshipTransferred(oldCreator, newCreatorAddress);
    }

    function name() external pure override returns (string memory) {

        return "Mandala Tokens";
    }

    function symbol() external pure override returns (string memory) {

        return "MANDALA";
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {

        address owner = _ownerOf(id);
        require(owner != address(0), "NOT_EXISTS");
        return _tokenURI(id);
    }

    function supportsInterface(bytes4 id) public pure virtual override(ERC721Base, IERC165) returns (bool) {

        return ERC721Base.supportsInterface(id) || id == 0x5b5e139f;
    }

    struct TokenData {
        uint256 id;
        string tokenURI;
    }

    function getTokenDataOfOwner(
        address owner,
        uint256 start,
        uint256 num
    ) external view returns (TokenData[] memory tokens) {

        EnumerableSet.UintSet storage allTokens = _holderTokens[owner];
        uint256 balance = allTokens.length();
        require(balance >= start + num, "TOO_MANY_TOKEN_REQUESTED");
        tokens = new TokenData[](num);
        uint256 i = 0;
        while (i < num) {
            uint256 id = allTokens.at(start + i);
            tokens[i] = TokenData(id, _tokenURI(id));
            i++;
        }
    }

    function mint(address to, bytes memory signature) external payable returns (uint256) {

        uint256 mintPrice = _curve(_supply);
        require(msg.value >= mintPrice, "NOT_ENOUGH_ETH");


        bytes32 hashedData = keccak256(abi.encodePacked("Mandala", to));
        address signer = hashedData.toEthSignedMessageHash().recover(signature);
        _mint(uint256(signer), to);

        uint256 forCreator = mintPrice - _forReserve(mintPrice);

        bool success = true;
        if (forCreator > 0) {
            success = creator.send(forCreator);
        }

        if(!success || msg.value > mintPrice) {
            msg.sender.transfer(msg.value - mintPrice + (!success ? forCreator : 0));
        }

        emit Minted(uint256(signer), mintPrice);
        return uint256(signer);
    }


    function burn(uint256 id) external {

        uint256 burnPrice = _forReserve(_curve(_supply - 1));

        _burn(id);

        msg.sender.transfer(burnPrice);
        emit Burned(id, burnPrice);
    }

    function currentPrice() external view returns (uint256) {

        return _curve(_supply);
    }

    function _curve(uint256 supply) internal view returns (uint256) {

        return initialPrice + supply * linearCoefficient;
    }

    function _forReserve(uint256 mintPrice) internal view returns (uint256) {

        return mintPrice * (10000-creatorCutPer10000th) / 10000;
    }


    function _tokenURI(uint256 id) internal pure returns (string memory) {

        bytes memory metadata = TEMPLATE;
        writeUintAsHex(metadata, ADDRESS_NAME_POS, id);

        for (uint256 i = 0; i < 40; i++) {
            uint8 value = uint8((id >> (40-(i+1))*4) % 16);
            if (value == 0) {
                value = 16; // use black as oposed to transparent
            }
            uint256 x = extract(xs, i);
            uint256 y = extract(ys, i);
            setCharacter(metadata, IMAGE_DATA_POS, y*WIDTH + x + (y /ROW_PER_BLOCK) * 2 + 1, value);

            if (x != y) {
                setCharacter(metadata, IMAGE_DATA_POS, x*WIDTH + y + (x /ROW_PER_BLOCK) * 2 + 1, value);
                if (y != HEIGHT / 2) {
                    setCharacter(metadata, IMAGE_DATA_POS, x*WIDTH + (WIDTH -y -1) + (x /ROW_PER_BLOCK) * 2 + 1, value); // x mirror
                }

                if (x != WIDTH / 2) {
                    setCharacter(metadata, IMAGE_DATA_POS, (HEIGHT-x-1)*WIDTH + y + ((HEIGHT-x-1) /ROW_PER_BLOCK) * 2 + 1, value); // y mirror
                }

                if (x != WIDTH / 2 && y != HEIGHT / 2) {
                    setCharacter(metadata, IMAGE_DATA_POS, (HEIGHT-x-1)*WIDTH + (WIDTH-y-1) + ((HEIGHT-x-1) /ROW_PER_BLOCK) * 2 + 1, value); // x,y mirror
                }
            }

            if (x != WIDTH / 2) {
                setCharacter(metadata, IMAGE_DATA_POS, y*WIDTH + (WIDTH -x -1) + (y /ROW_PER_BLOCK) * 2 + 1, value); // x mirror
            }
            if (y != HEIGHT / 2) {
                setCharacter(metadata, IMAGE_DATA_POS, (HEIGHT-y-1)*WIDTH + x + ((HEIGHT-y-1) /ROW_PER_BLOCK) * 2 + 1, value); // y mirror
            }

            if (x != WIDTH / 2 && y != HEIGHT / 2) {
                setCharacter(metadata, IMAGE_DATA_POS, (HEIGHT-y-1)*WIDTH + (WIDTH-x-1) + ((HEIGHT-y-1) /ROW_PER_BLOCK) * 2 + 1, value); // x,y mirror
            }
        }
        return string(metadata);
    }


    function setCharacter(bytes memory metadata, uint256 base, uint256 pos, uint8 value) internal pure {

        uint256 base64Slot = base + (pos * 8) / 6;
        uint8 bit = uint8((pos * 8) % 6);
        uint8 existingValue = base64ToUint8(metadata[base64Slot]);
        if (bit == 0) {
            metadata[base64Slot] = uint8ToBase64(value >> 2);
            uint8 extraValue = base64ToUint8(metadata[base64Slot + 1]);
            metadata[base64Slot + 1] = uint8ToBase64(((value % 4) << 4) | (0x0F & extraValue));
        } else if (bit == 2) {
            metadata[base64Slot] = uint8ToBase64((value >> 4) | (0x30 & existingValue));
            uint8 extraValue = base64ToUint8(metadata[base64Slot + 1]);
            metadata[base64Slot + 1] = uint8ToBase64(((value % 16) << 2) | (0x03 & extraValue));
        } else { // bit == 4)
            metadata[base64Slot + 1] = uint8ToBase64(value % 64);
        }
    }

    function extract(bytes32 arr, uint256 i) internal pure returns (uint256) {

        return (uint256(arr) >> (256 - (i+1) * 4)) % 16;
    }

    bytes32 constant internal base64Alphabet_1 = 0x4142434445464748494A4B4C4D4E4F505152535455565758595A616263646566;
    bytes32 constant internal base64Alphabet_2 = 0x6768696A6B6C6D6E6F707172737475767778797A303132333435363738392B2F;

    function base64ToUint8(bytes1 s) internal pure returns (uint8 v) {

        if (uint8(s) == 0x2B) {
            return 62;
        }
        if (uint8(s) == 0x2F) {
            return 63;
        }
        if (uint8(s) >= 0x30 && uint8(s) <= 0x39) {
            return uint8(s) - 0x30 + 52;
        }
        if (uint8(s) >= 0x41 && uint8(s) <= 0x5A) {
            return uint8(s) - 0x41;
        }
        if (uint8(s) >= 0x5A && uint8(s) <= 0x7A) {
            return uint8(s) - 0x5A + 26;
        }
        return 0;
    }

    function uint8ToBase64(uint24 v) internal pure returns (bytes1 s) {

        if (v >= 32) {
            return base64Alphabet_2[v - 32];
        }
        return base64Alphabet_1[v];
    }

    bytes constant internal hexAlphabet = "0123456789abcdef";

    function writeUintAsHex(bytes memory data, uint256 endPos, uint256 num) internal pure {

        while (num != 0) {
            data[endPos--] = bytes1(hexAlphabet[num % 16]);
            num /= 16;
        }
    }

}