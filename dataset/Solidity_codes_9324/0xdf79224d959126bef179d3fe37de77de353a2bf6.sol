
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.4;


error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintedQueryForZeroAddress();
error BurnedQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerIndexOutOfBounds();
error OwnerQueryForNonexistentToken();
error TokenIndexOutOfBounds();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error URIQueryForNonexistentToken();

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
    }

    struct AddressData {
        uint64 balance;
        uint64 numberMinted;
        uint64 numberBurned;
    }

    
    uint128 internal _currentIndex;

    uint128 internal _burnCounter;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) internal _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function totalSupply() public view override returns (uint256) {

        unchecked {
            return _currentIndex - _burnCounter;    
        }
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        uint256 numMintedSoFar = _currentIndex;
        uint256 tokenIdsIdx;

        unchecked {
            for (uint256 i; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = _ownerships[i];
                if (!ownership.burned) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }
        revert TokenIndexOutOfBounds();
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        if (index >= balanceOf(owner)) revert OwnerIndexOutOfBounds();
        uint256 numMintedSoFar = _currentIndex;
        uint256 tokenIdsIdx;
        address currOwnershipAddr;

        unchecked {
            for (uint256 i; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = _ownerships[i];
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }

        revert();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        if (owner == address(0)) revert MintedQueryForZeroAddress();
        return uint256(_addressData[owner].numberMinted);
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        if (owner == address(0)) revert BurnedQueryForZeroAddress();
        return uint256(_addressData[owner].numberBurned);
    }

    function ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        uint256 curr = tokenId;

        unchecked {
            if (curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {

        if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {

        _mint(to, quantity, _data, true);
    }

    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {

        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;

            for (uint256 i; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex);
                if (safe && !_checkOnERC721Received(address(0), to, updatedIndex, _data)) {
                    revert TransferToNonERC721ReceiverImplementer();
                }
                updatedIndex++;
            }

            _currentIndex = uint128(updatedIndex);
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
            isApprovedForAll(prevOwnership.addr, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            _ownerships[tokenId].addr = to;
            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);

            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                if (nextTokenId < _currentIndex) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _burn(uint256 tokenId) internal virtual {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        _beforeTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        unchecked {
            _addressData[prevOwnership.addr].balance -= 1;
            _addressData[prevOwnership.addr].numberBurned += 1;

            _ownerships[tokenId].addr = prevOwnership.addr;
            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);
            _ownerships[tokenId].burned = true;

            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                if (nextTokenId < _currentIndex) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(prevOwnership.addr, address(0), tokenId);
        _afterTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

        unchecked { 
            _burnCounter++;
        }
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert TransferToNonERC721ReceiverImplementer();
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

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}


    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

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


contract Pausable is Ownable {

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }


    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    modifier whenPaused() {
        require(_paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        _paused = true;
    }

    function unpause() onlyOwner whenPaused public {
        _paused = false;
    }
}// MIT
pragma solidity ^0.8.0;

contract ScumbugsValues {

    mapping(uint8 => bytes32) public handMap;
    mapping(uint8 => bytes32) public bodyMap;
    mapping(uint8 => bytes32) public eyesMap;
    mapping(uint8 => bytes32) public headMap;
    mapping(uint8 => bytes32) public mouthMap;
    mapping(uint8 => bytes32) public backgroundMap;
    mapping(uint8 => bytes32) public bugTypeMap;


    constructor() {
        handMap[0] = bytes32("No traits");
        handMap[1] = bytes32("Bug You");
        handMap[2] = bytes32("Smoke");
        handMap[3] = bytes32("Money Talk");
        handMap[4] = bytes32("Bug Spray");
        handMap[5] = bytes32("Camcorder");
        handMap[6] = bytes32("Golf Club");
        handMap[7] = bytes32("Spicey");
        handMap[8] = bytes32("Genius");
        handMap[9] = bytes32("All In");
        handMap[10] = bytes32("Fishing Rod");
        handMap[11] = bytes32("Lactose Intolerant");
        handMap[12] = bytes32("Pizza");
        handMap[13] = bytes32("Scum Drink");
        handMap[14] = bytes32("Selfie Stick");
        handMap[15] = bytes32("Fake Watch");
        handMap[16] = bytes32("Rings");
        handMap[17] = bytes32("Boujee");
        handMap[18] = bytes32("Scissorhands");
        handMap[19] = bytes32("Artist");
        handMap[20] = bytes32("Graffiti");
        handMap[21] = bytes32("Lasso");
        handMap[22] = bytes32("Mic");
        handMap[23] = bytes32("Wood");
        handMap[24] = bytes32("Spy");
        handMap[25] = bytes32("Lettuce Finger");
        handMap[26] = bytes32("Baller");
        handMap[27] = bytes32("Katana");
        handMap[28] = bytes32("Scary Puppet");
        handMap[29] = bytes32("Sippin");
        handMap[30] = bytes32("Shroom");
        handMap[31] = bytes32("Banana Gun");
        handMap[32] = bytes32("Flask");
        handMap[33] = bytes32("Boombox");
        handMap[34] = bytes32("Larry SB");
        handMap[35] = bytes32("Wonderful gm");
        handMap[36] = bytes32("Slingshot");
        handMap[37] = bytes32("Skateboard");
        handMap[38] = bytes32("Glow Stick");
        handMap[39] = bytes32("Sadomaso");
        handMap[40] = bytes32("Demi God");
        handMap[41] = bytes32("I Can Point This");

        bodyMap[0] = bytes32("No traits");
        bodyMap[1] = bytes32("Logo T");
        bodyMap[2] = bytes32("System B");
        bodyMap[3] = bytes32("Daddy's Rich");
        bodyMap[4] = bytes32("McScumin");
        bodyMap[5] = bytes32("Stunt Bug");
        bodyMap[6] = bytes32("Bug Squad");
        bodyMap[7] = bytes32("Track Jacket");
        bodyMap[8] = bytes32("Polo");
        bodyMap[9] = bytes32("Boomer");
        bodyMap[10] = bytes32("Turtleneck");
        bodyMap[11] = bytes32("Coconut Bra");
        bodyMap[12] = bytes32("Tie-dye");
        bodyMap[13] = bytes32("Life Jacket");
        bodyMap[14] = bytes32("Down Jacket");
        bodyMap[15] = bytes32("Perfecto");
        bodyMap[16] = bytes32("Thunder Fleece");
        bodyMap[17] = bytes32("Spandex");
        bodyMap[18] = bytes32("Bugs Racing");
        bodyMap[19] = bytes32("Scum Bag");
        bodyMap[20] = bytes32("Trailer Park Bugs");
        bodyMap[21] = bytes32("Disco Shirt");
        bodyMap[22] = bytes32("Knit");
        bodyMap[23] = bytes32("Gloves Jacket");
        bodyMap[24] = bytes32("Sherpa Fleece");
        bodyMap[25] = bytes32("Velvet Hoodie");
        bodyMap[26] = bytes32("Hoodie Up");
        bodyMap[27] = bytes32("Denim Jacket");
        bodyMap[28] = bytes32("Biker Vest");
        bodyMap[29] = bytes32("Sherling Jacket");
        bodyMap[30] = bytes32("V God");
        bodyMap[31] = bytes32("Trench Coat");
        bodyMap[32] = bytes32("Tuxedo");
        bodyMap[33] = bytes32("Dragon Shirt");
        bodyMap[34] = bytes32("Scammer");
        bodyMap[35] = bytes32("B.W.A.");
        bodyMap[36] = bytes32("Punk Jacket");
        bodyMap[37] = bytes32("Loose Knit");
        bodyMap[38] = bytes32("Red Puffer");
        bodyMap[39] = bytes32("Wolf");
        bodyMap[40] = bytes32("King Robe");
        bodyMap[41] = bytes32("Notorious B.U.G.");
        bodyMap[42] = bytes32("Scum God Jacket");
        bodyMap[43] = bytes32("Fast Lane");
        bodyMap[44] = bytes32("Iced Out Chain");
        bodyMap[45] = bytes32("Flower Costume");
        bodyMap[46] = bytes32("Cold Chain");
        bodyMap[47] = bytes32("Straight Jacket");
        bodyMap[48] = bytes32("Predator Costume");
        bodyMap[49] = bytes32("White & Gold Dress");
        bodyMap[50] = bytes32("Spike Jacket");
        bodyMap[51] = bytes32("Invisibility Cloak");
        bodyMap[52] = bytes32("GOAT Jacket");
        bodyMap[53] = bytes32("Black & Blue Dress");

        eyesMap[0] = bytes32("No traits");
        eyesMap[1] = bytes32("Clear Eyes");
        eyesMap[2] = bytes32("Sus");
        eyesMap[3] = bytes32("Scum");
        eyesMap[4] = bytes32("Shroomed");
        eyesMap[5] = bytes32("Shark");
        eyesMap[6] = bytes32("Cleo");
        eyesMap[7] = bytes32("Soft Glam");
        eyesMap[8] = bytes32("Goat");
        eyesMap[9] = bytes32("Cat");
        eyesMap[10] = bytes32("Clown");
        eyesMap[11] = bytes32("Tearful");
        eyesMap[12] = bytes32("Mesmerized");
        eyesMap[13] = bytes32("Scum Clown");
        eyesMap[14] = bytes32("Blind");
        eyesMap[15] = bytes32("Black Eye");
        eyesMap[16] = bytes32("Black Eye Scum");

        headMap[0] = bytes32("No traits");
        headMap[1] = bytes32("Logo Cap");
        headMap[2] = bytes32("Beanie");
        headMap[3] = bytes32("Mullet");
        headMap[4] = bytes32("Dreadlocks");
        headMap[5] = bytes32("V-cut");
        headMap[6] = bytes32("Sleek");
        headMap[7] = bytes32("Trucker Hat");
        headMap[8] = bytes32("Preppy");
        headMap[9] = bytes32("Bun");
        headMap[10] = bytes32("Black Bucket Hat");
        headMap[11] = bytes32("Fade");
        headMap[12] = bytes32("Ushanka");
        headMap[13] = bytes32("Red Spikes");
        headMap[14] = bytes32("Beach");
        headMap[15] = bytes32("Afro");
        headMap[16] = bytes32("Lover Bug");
        headMap[17] = bytes32("New Jack City");
        headMap[18] = bytes32("Blume");
        headMap[19] = bytes32("Mohawk");
        headMap[20] = bytes32("Fitted Cap");
        headMap[21] = bytes32("Karen");
        headMap[22] = bytes32("Blond Bowlcut");
        headMap[23] = bytes32("The King");
        headMap[24] = bytes32("Durag");
        headMap[25] = bytes32("Bucket Hat");
        headMap[26] = bytes32("Bus Driver");
        headMap[27] = bytes32("Black Bowlcut");
        headMap[28] = bytes32("Rawr xd");
        headMap[29] = bytes32("Cowboy");
        headMap[30] = bytes32("Aerobics");
        headMap[31] = bytes32("Rattail");
        headMap[32] = bytes32("Clown");
        headMap[33] = bytes32("Hair Metal");
        headMap[34] = bytes32("Unibruh");
        headMap[35] = bytes32("Biker");
        headMap[36] = bytes32("Piercing");
        headMap[37] = bytes32("/");
        headMap[38] = bytes32("Knot Head");
        headMap[39] = bytes32("Say No More");
        headMap[40] = bytes32("Mixologist");
        headMap[41] = bytes32("Sahara Cap");
        headMap[42] = bytes32("Cheetah Fur Hat");
        headMap[43] = bytes32("Pharaoh");
        headMap[44] = bytes32("Giga Brain");
        headMap[45] = bytes32("Flower Costume");
        headMap[46] = bytes32("Rockstar");
        headMap[47] = bytes32("Dryden");
        headMap[48] = bytes32("Trash's King");
        headMap[49] = bytes32("Tin Foil Hat");
        headMap[50] = bytes32("Umbrella");
        headMap[51] = bytes32("Archive Cap");
        headMap[52] = bytes32("Rug Legend");
        headMap[53] = bytes32("Compost God");
        headMap[54] = bytes32("Balaclava");
        headMap[55] = bytes32("Predator Costume");

        mouthMap[0] = bytes32("Smiley");
        mouthMap[1] = bytes32("Duck Face");
        mouthMap[2] = bytes32("Vortex");
        mouthMap[3] = bytes32("Pornstache");
        mouthMap[4] = bytes32("Ron");
        mouthMap[5] = bytes32("Bandana");
        mouthMap[6] = bytes32("Kiss");
        mouthMap[7] = bytes32("Glossy Lips");
        mouthMap[8] = bytes32("Hogan");
        mouthMap[9] = bytes32("Buckteeth");
        mouthMap[10] = bytes32("Lumbersexual");
        mouthMap[11] = bytes32("Grrr");
        mouthMap[12] = bytes32("Toothbrush");
        mouthMap[13] = bytes32("Rotten");
        mouthMap[14] = bytes32("Zoidbug");
        mouthMap[15] = bytes32("Reptilian");
        mouthMap[16] = bytes32("Goth");
        mouthMap[17] = bytes32("Tooth Cap");
        mouthMap[18] = bytes32("Lemmy");
        mouthMap[19] = bytes32("Gold Grillz");
        mouthMap[20] = bytes32("Overjet");
        mouthMap[21] = bytes32("Duke In Vegas");
        mouthMap[22] = bytes32("Hannibal");
        mouthMap[23] = bytes32("Iced Out");
        mouthMap[24] = bytes32("Braces");

        backgroundMap[0] = bytes32("blue");
        backgroundMap[1] = bytes32("green");
        backgroundMap[2] = bytes32("orange");
        backgroundMap[3] = bytes32("pink");
        backgroundMap[4] = bytes32("red");
        backgroundMap[5] = bytes32("yellow");

        bugTypeMap[0] = bytes32("mantis");
        bugTypeMap[1] = bytes32("caterpillar");
        bugTypeMap[2] = bytes32("fly");
        bugTypeMap[3] = bytes32("mosquito");
        bugTypeMap[4] = bytes32("moth");
        bugTypeMap[5] = bytes32("snail");

    }

}// MIT
pragma solidity ^0.8.0;

contract DateTime {
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
        }

        uint private constant DAY_IN_SECONDS = 86400;
        uint private constant YEAR_IN_SECONDS = 31536000;
        uint private constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint private constant HOUR_IN_SECONDS = 3600;
        uint private constant MINUTE_IN_SECONDS = 60;

        uint16 private constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) internal pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) internal pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }
        }

        function getYear(uint timestamp) internal pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) internal pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) internal pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }
}// MIT
pragma solidity ^0.8.0;


contract ScumbugsMetadata is DateTime {

    struct Attributes {
        uint8 hand;
        uint8 body;
        uint8 eyes;
        uint8 head;
        uint8 mouth;
        uint8 background_color;
        uint8 bug_type;
        uint32 birthday;
    }

    struct MetadataInput {
        uint256 tokenId;
        bytes32 txHash;
        bytes32 mediaId1;
        bytes32 mediaId2;
        bytes32 mediaBdayId1;
        bytes32 mediaBdayId2;
        uint8 hand;
        uint8 body;
        uint8 eyes;
        uint8 head;
        uint8 mouth;
        uint8 background_color;
        uint8 bug_type;
        uint32 birthday;
    }

    mapping (uint256 => Attributes) internal attributesMap;
    mapping (uint256 => bytes32) public txhashes;
    mapping (uint256 => bytes32) internal mediaIds1;
    mapping (uint256 => bytes32) internal mediaIds2;
    mapping (uint256 => bytes32) internal mediaBdayIds1;
    mapping (uint256 => bytes32) internal mediaBdayIds2;
    bytes32 private defaultImagePart1 = bytes32("U95dUPeExh0CVYAH0ga8jOuifsPD6FsF");
    bytes32 private defaultImagePart2 = bytes32("6aGK2oGauo8");
    
    bytes32 internal siteUrl;
    address public ScumbugsValuesAddress;
    


    constructor(bytes32 _siteUrl, address _ScumbugsValuesAddress) {
        siteUrl = _siteUrl;
        ScumbugsValuesAddress = _ScumbugsValuesAddress;
    }

    function _render(uint256 tokenId) internal view virtual returns (string memory) {
        bool isBirthday = false;
        uint8 nowDay = getDay(block.timestamp);
        uint8 nowMonth = getMonth(block.timestamp);
        uint8 bdDay = getDay(attributesMap[tokenId].birthday);
        uint8 bdMonth = getMonth(attributesMap[tokenId].birthday);
        if (nowDay == bdDay && nowMonth == bdMonth) {
            isBirthday = true;
        }
        delete nowDay;
        delete nowMonth;
        delete bdDay;
        delete bdMonth;
        bool generated = isGenerated(tokenId);
        bytes memory tokenIdBytes = uintToStrBytes(tokenId);
        bytes memory buffer = bytes.concat(bytes28("data:application/json;utf8,{"), bytes8('"name":"'));
        buffer = bytes.concat(buffer, bytes9("Scumbug #"), tokenIdBytes, bytes2('",'));
        if (!generated) {
            buffer = bytes.concat(buffer, bytes9('"image":"'), bytes5("ar://"), defaultImagePart1);
            buffer = bytes.concat(buffer, defaultImagePart2, bytes2('",'));
        } else if (isBirthday) {
            buffer = bytes.concat(buffer, bytes9('"image":"'), bytes5("ar://"), mediaBdayIds1[tokenId]);
            buffer = bytes.concat(buffer, mediaBdayIds2[tokenId], bytes2('",'));
        } else {
            buffer = bytes.concat(buffer, bytes9('"image":"'), bytes5("ar://"), mediaIds1[tokenId]);
            buffer = bytes.concat(buffer, mediaIds2[tokenId], bytes2('",'));
        }
        buffer = bytes.concat(buffer, bytes10('"tokenId":'), tokenIdBytes, bytes1(","));
        if (generated) {
            buffer = bytes.concat(buffer, bytes16('"external_url":"'), siteUrl, tokenIdBytes, bytes2('",'));
            delete tokenIdBytes;
            Attributes memory attributes = attributesMap[tokenId];
            ScumbugsValues scumbugsValuesInstance = ScumbugsValues(ScumbugsValuesAddress);
            buffer = bytes.concat(buffer, bytes14('"attributes":['));
            if (attributes.hand != 0) {
                bytes32 data = scumbugsValuesInstance.handMap(attributes.hand);
                buffer = bytes.concat(buffer, bytes30('{"trait_type":"hand","value":"'), data, bytes3('"},'));
            }
            if (attributes.body != 0) {
                bytes32 data = scumbugsValuesInstance.bodyMap(attributes.body);
                buffer = bytes.concat(buffer, bytes30('{"trait_type":"body","value":"'), data, bytes3('"},'));
            }
            if (attributes.eyes != 0) {
                bytes32 data = scumbugsValuesInstance.eyesMap(attributes.eyes);
                buffer = bytes.concat(buffer, bytes30('{"trait_type":"eyes","value":"'), data, bytes3('"},'));
            }
            if (attributes.head != 0) {
                bytes32 data = scumbugsValuesInstance.headMap(attributes.head);
                buffer = bytes.concat(buffer, bytes30('{"trait_type":"head","value":"'), data, bytes3('"},'));
            }
            if (attributes.mouth != 0) {
                bytes32 data = scumbugsValuesInstance.mouthMap(attributes.mouth);
                buffer = bytes.concat(buffer, bytes31('{"trait_type":"mouth","value":"'), data, bytes3('"},'));
            }
            if (isBirthday) {
                buffer = bytes.concat(buffer, bytes32('{"trait_type":"background_color"'), bytes22(',"value":"Birthday!"},'));
            } else {
                bytes32 backgroundData = scumbugsValuesInstance.backgroundMap(attributes.background_color);
                buffer = bytes.concat(buffer, bytes32('{"trait_type":"background_color"'), bytes10(',"value":"'), backgroundData, bytes3('"},'));
                delete backgroundData;
            }
            bytes32 bugTypeData = scumbugsValuesInstance.bugTypeMap(attributes.bug_type);
            buffer = bytes.concat(buffer, bytes24('{"trait_type":"bug_type"'), bytes10(',"value":"'), bugTypeData, bytes3('"},'));
            delete bugTypeData;
            delete scumbugsValuesInstance;
            buffer = bytes.concat(buffer, bytes25('{"trait_type":"birthday",'), bytes22('"display_type":"date",'), bytes8('"value":'), 
                uintToStrBytes(attributes.birthday), bytes1('}'));
            delete attributes;
            buffer = bytes.concat(buffer, bytes1("]"));
        } else {
            buffer = bytes.concat(buffer, bytes15('"attributes":[]'));
        }
        buffer = bytes.concat(buffer, bytes1("}"));
        return string(buffer);
    }

    function isGenerated(uint256 tokenId) public view returns (bool) {
        return mediaIds1[tokenId] != 0;
    }

    function uintToStrBytes(uint256 value) pure private returns (bytes memory) {
        if (value == 0) {
            return bytes("0");
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
        return buffer;
    }

}// MIT
pragma solidity ^0.8.0;

interface OwnableDelegateProxy {

}

interface ProxyRegistry {
    function proxies(address) external view returns (OwnableDelegateProxy);
}// MIT
pragma solidity ^0.8.0;


contract ScumbugsNFT is ERC721A, Pausable, ScumbugsMetadata {

    address private proxyRegistryAddress;
    uint256 public unitPrice = 0.069 ether;
    uint32 public constant supply = 15341;
    uint16 public constant maxAmount = 20;
    bool private isOpenSeaProxyActive = true;

    

    constructor(bytes32 _siteUrl, address _ScumbugsValues, address _proxyRegistryAddress) 
    ERC721A("Scumbugs", "SCUMBUGS")
    ScumbugsMetadata(_siteUrl, _ScumbugsValues)
    {
        proxyRegistryAddress = _proxyRegistryAddress;
        _safeMint(msg.sender, 341);
    }

    function currentTokenId() view external returns (uint256) {
        return _currentIndex - 1;
    }

    function mintNFT(uint16 amount) external payable whenNotPaused {
        require(amount <= maxAmount, "Can't mint more than max amount");
        require(msg.value >= (unitPrice * amount), "Value should be equal or greater than unit price * amount");
        require((_currentIndex + amount - 1) < supply, "Can't mint that amount of NFTs");
        _safeMint(msg.sender, amount);
    }

    function withdraw() external {
        payable(owner()).transfer(address(this).balance);
    }

    function generateMetadata_w1o(MetadataInput memory metadataInput) external onlyOwner {
        uint256 tokenId = metadataInput.tokenId;
        bool generated = isGenerated(tokenId);
        require(!generated, "Metadata already generated for tokenId");
        require(_currentIndex > tokenId, "NFT with tokenId does not exist");
        delete generated;
        attributesMap[tokenId] = Attributes({
            hand: metadataInput.hand,
            body: metadataInput.body,
            eyes: metadataInput.eyes,
            head: metadataInput.head,
            mouth: metadataInput.mouth,
            background_color: metadataInput.background_color,
            bug_type: metadataInput.bug_type,
            birthday: metadataInput.birthday
        });
        txhashes[tokenId] = metadataInput.txHash;
        mediaIds1[tokenId] = metadataInput.mediaId1;
        mediaIds2[tokenId] = metadataInput.mediaId2;
        mediaBdayIds1[tokenId] = metadataInput.mediaBdayId1;
        mediaBdayIds2[tokenId] = metadataInput.mediaBdayId2;
    }

    function setSiteUrl(bytes32 _siteUrl) external onlyOwner {
        siteUrl = _siteUrl;
    }

    function setUnitPrice(uint256 _unitPrice) external onlyOwner whenPaused {
        unitPrice = _unitPrice;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');
        return _render(tokenId);
    }

    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive) public onlyOwner {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);

        if (isOpenSeaProxyActive && address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
 
}