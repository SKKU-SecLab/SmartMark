
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
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

        require(operator != _msgSender(), "ERC721: approve to caller");

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
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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

}// Unlicense

pragma solidity ^0.8.6;

abstract contract Random {
    uint256 private s_Previous = 0;

    function _random() internal returns (uint256) {

        unchecked {
            uint256 bitfield;

            for (uint ii = 1; ii < 257; ii++) {
                uint256 bits = uint256(blockhash(block.number - ii));
                bitfield |= bits & (1 << (ii - 1));
            }

            uint256 value = uint256(keccak256(abi.encodePacked(bytes32(bitfield))));
            s_Previous ^= value;

            return uint256(keccak256(abi.encodePacked(s_Previous)));
        }
    }
}// MIT

library Base64 {
    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';
        
        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)
            
            let tablePtr := add(table, 1)
            
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            
            let resultPtr := add(result, 32)
            
            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 3)
               
               let input := mload(dataPtr)
               
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
            
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }
        
        return result;
    }
}// GPL-3.0-or-later

pragma solidity ^0.8.6;


library LootRoomErrors {
    string constant internal OUT_OF_RANGE = "out of range";
    string constant internal NO_LOOT = "no loot bag";
}

contract LootRoom {

    function biomeName(uint8 val) private pure returns (string memory) {
        if (184 >= val) { return "Room"; }
        if (200 >= val) { return "Pit"; }
        if (216 >= val) { return "Lair"; }
        if (232 >= val) { return "Refuge"; }
        if (243 >= val) { return "Shop"; }
        if (254 >= val) { return "Shrine"; }
        return "Treasury";
    }

    function roomType(uint256 tokenId) private pure returns (string memory) {
        uint8 val = uint8(bytes32(tokenId)[0]);
        return biomeName(val);
    }

    function roomMaterial(uint256 tokenId) public pure returns (string memory) {
        uint8 val = uint8(bytes32(tokenId)[1]);

        if (128 >= val) { return "Stone"; }
        if (200 >= val) { return "Wooden"; }
        if (216 >= val) { return "Mud"; }
        if (232 >= val) { return "Brick"; }
        if (243 >= val) { return "Granite"; }
        if (254 >= val) { return "Bone"; }
        return "Marble";
    }

    function roomContainer(
        uint256 tokenId,
        uint256 idx
    ) public pure returns (string memory) {
        require(4 > idx, LootRoomErrors.OUT_OF_RANGE);
        uint8 val = uint8(bytes32(tokenId)[2 + idx]);

        if (229 >= val) { return ""; }
        if (233 >= val) { return "Barrel"; }
        if (237 >= val) { return "Basket"; }
        if (240 >= val) { return "Bucket"; }
        if (243 >= val) { return "Chest"; }
        if (245 >= val) { return "Coffer"; }
        if (247 >= val) { return "Pouch"; }
        if (249 >= val) { return "Sack"; }
        if (251 >= val) { return "Crate"; }
        if (253 >= val) { return "Shelf"; }
        if (255 >= val) { return "Box"; }
        return "Strongbox";
    }

    function roomOpinion(uint256 tokenId) public pure returns (string memory) {
        uint8 val = uint8(bytes32(tokenId)[6]);

        if (229 >= val) { return "Unremarkable"; }
        if (233 >= val) { return "Unusual"; }
        if (237 >= val) { return "Interesting"; }
        if (240 >= val) { return "Strange"; }
        if (243 >= val) { return "Bizarre"; }
        if (245 >= val) { return "Curious"; }
        if (247 >= val) { return "Memorable"; }
        if (249 >= val) { return "Remarkable"; }
        if (251 >= val) { return "Notable"; }
        if (253 >= val) { return "Peculiar"; }
        if (255 >= val) { return "Puzzling"; }
        return "Weird";
    }

    function roomSize(uint256 tokenId) public pure returns (string memory) {
        uint8 val = uint8(bytes32(tokenId)[7]);

        if (  0 == val) { return "Infinitesimal"; }
        if (  2 >= val) { return "Microscopic"; }
        if (  4 >= val) { return "Lilliputian"; }
        if (  7 >= val) { return "Minute"; }
        if ( 10 >= val) { return "Minuscule"; }
        if ( 14 >= val) { return "Miniature"; }
        if ( 18 >= val) { return "Teensy"; }
        if ( 23 >= val) { return "Cramped"; }
        if ( 28 >= val) { return "Measly"; }
        if ( 34 >= val) { return "Puny"; }
        if ( 40 >= val) { return "Wee"; }
        if ( 47 >= val) { return "Tiny"; }
        if ( 54 >= val) { return "Baby"; }
        if ( 62 >= val) { return "Confined"; }
        if ( 70 >= val) { return "Undersized"; }
        if ( 79 >= val) { return "Petite"; }
        if ( 88 >= val) { return "Little"; }
        if ( 98 >= val) { return "Cozy"; }
        if (108 >= val) { return "Small"; }

        if (146 >= val) { return "Average-Sized"; }

        if (156 >= val) { return "Good-Sized"; }
        if (166 >= val) { return "Large"; }
        if (175 >= val) { return "Sizable"; }
        if (184 >= val) { return "Big"; }
        if (192 >= val) { return "Oversized"; }
        if (200 >= val) { return "Huge"; }
        if (207 >= val) { return "Extensive"; }
        if (214 >= val) { return "Giant"; }
        if (220 >= val) { return "Enormous"; }
        if (226 >= val) { return "Gigantic"; }
        if (231 >= val) { return "Massive"; }
        if (236 >= val) { return "Immense"; }
        if (240 >= val) { return "Vast"; }
        if (244 >= val) { return "Colossal"; }
        if (247 >= val) { return "Titanic"; }
        if (250 >= val) { return "Humongous"; }
        if (252 >= val) { return "Gargantuan"; }
        if (254 >= val) { return "Monumental"; }

        return "Immeasurable";
    }

    function roomModifier(uint256 tokenId) public pure returns (string memory) {
        uint8 val = uint8(bytes32(tokenId)[8]);

        if ( 15 >= val) { return "Sweltering"; }
        if ( 31 >= val) { return "Freezing"; }
        if ( 47 >= val) { return "Dim"; }
        if ( 63 >= val) { return "Bright"; }
        if ( 79 >= val) { return "Barren"; }
        if ( 95 >= val) { return "Plush"; }
        if (111 >= val) { return "Filthy"; }
        if (127 >= val) { return "Dingy"; }
        if (143 >= val) { return "Airy"; }
        if (159 >= val) { return "Stuffy"; }
        if (175 >= val) { return "Rough"; }
        if (191 >= val) { return "Untidy"; }
        if (207 >= val) { return "Dank"; }
        if (223 >= val) { return "Moist"; }
        if (239 >= val) { return "Soulless"; }
        return "Exotic";
    }

    function exitType(
        uint256 tokenId,
        uint256 direction
    ) public pure returns (string memory) {
        require(4 > direction, LootRoomErrors.OUT_OF_RANGE);
        uint8 val = uint8(bytes32(tokenId)[9 + direction]);
        return biomeName(val);
    }

    function exitPassable(
        uint256 tokenId,
        uint256 direction
    ) public pure returns (bool) {
        require(4 > direction, LootRoomErrors.OUT_OF_RANGE);
        uint8 val = uint8(bytes32(tokenId)[13 + direction]);
        return 128 > val;
    }

    function lootId(uint256 tokenId) public pure returns (uint256) {
        uint256 lootTokenId = tokenId & 0xFFFF;
        require(0 < lootTokenId && 8001 > lootTokenId, LootRoomErrors.NO_LOOT);
        return lootTokenId;
    }

    function _svgNorth(uint256 tokenId) private pure returns (string memory) {
        return string(abi.encodePacked(
            "<text x='250' y='65' font-size='20px'><tspan>",
            exitType(tokenId, 0),
            "</tspan></text>",
            (exitPassable(tokenId, 0) ?
                "<path d='m250 15 15 26h-30z'/>"
                    : "<rect x='75' y='75' width='350' height='15'/>")

        ));
    }

    function _svgEast(uint256 tokenId) private pure returns (string memory) {
        return string(abi.encodePacked(
            "<text transform='rotate(90)' x='250' y='-435'><tspan>",
            exitType(tokenId, 1),
            "</tspan></text>",
            (exitPassable(tokenId, 1) ?
                "<path d='m483 248-26 15v-30z'/>"
                : "<rect x='410' y='75' width='15' height='350'/>")

        ));
    }

    function _svgSouth(uint256 tokenId) private pure returns (string memory) {
        return string(abi.encodePacked(
            "<text transform='scale(-1)' x='-250' y='-435'><tspan>",
            exitType(tokenId, 2),
            "</tspan></text>",
            (exitPassable(tokenId, 2) ?
                "<path d='m250 481 15-26h-30z'/>"
                : "<rect x='75' y='410' width='350' height='15'/>")
        ));
    }

    function _svgWest(uint256 tokenId) private pure returns (string memory) {
        return string(abi.encodePacked(
            "<text transform='rotate(-90)' x='-250' y='65'><tspan>",
            exitType(tokenId, 3),
            "</tspan></text>",
            (exitPassable(tokenId, 3) ?
                "<path d='m17 248 26 15v-30z'/>"
                : "<rect x='75' y='75' width='15' height='350'/>")
        ));
    }

    function _svgRoom(uint256 tokenId) private pure returns (string memory) {
        return string(abi.encodePacked(
            "<text x='125' y='130' text-align='left' text-anchor='start'><tspan>",
            article(tokenId),
            "</tspan><tspan x='125' dy='25'>",
            roomOpinion(tokenId), "</tspan><tspan x='125' dy='25'>",
            roomSize(tokenId), "</tspan><tspan x='125' dy='25'>",
            roomModifier(tokenId), "</tspan><tspan x='125' dy='25'>",
            roomMaterial(tokenId), "</tspan><tspan x='125' dy='25'>",
            roomType(tokenId), ".</tspan><tspan x='125' dy='25'>&#160;</tspan>"
        ));
    }

    function _svgContainer(
        uint256 tokenId,
        uint256 idx
    ) private pure returns (string memory) {
        string memory container = roomContainer(tokenId, idx);
        if (bytes(container).length == 0) {
            return "";
        } else {
            return string(abi.encodePacked(
                "<tspan x='125' dy='25'>", container, "</tspan>\n"
            ));
        }
    }

    function _svgEdges(uint256 tokenId) private pure returns (string memory) {
        return string(abi.encodePacked(
            _svgNorth(tokenId),
            _svgEast(tokenId),
            _svgSouth(tokenId),
            _svgWest(tokenId)
        ));
    }

    function article(uint256 tokenId) public pure returns (string memory) {
        uint8 val = uint8(bytes32(tokenId)[6]);
        if (237 >= val) { return "An"; }
        return "A";
    }

    function image(uint256 tokenId) public pure returns (string memory) {
        bytes memory start = abi.encodePacked(
            "<?xml version='1.0' encoding='UTF-8'?>"
            "<svg version='1.1' viewBox='0 0 500 500' xmlns='http://www.w3.org/2000/svg' style='background:#000'>"
            "<g fill='#fff' font-size='20px' font-family='serif' text-align='center' text-anchor='middle'>",

            _svgEdges(tokenId)
        );

        bytes memory end = abi.encodePacked(
            _svgRoom(tokenId),

            _svgContainer(tokenId, 0),
            _svgContainer(tokenId, 1),
            _svgContainer(tokenId, 2),
            _svgContainer(tokenId, 3),

            "</text>"
            "</g>"
            "</svg>"
        );

        return string(abi.encodePacked(start, end));
    }

    function tokenName(uint256 tokenId) public pure returns (string memory) {
        uint256 num = uint256(keccak256(abi.encodePacked(tokenId))) & 0xFFFFFF;

        return string(abi.encodePacked(
            roomOpinion(tokenId),
            " ",
            roomType(tokenId),
            " #",
            Strings.toString(num)
        ));
    }

    function tokenDescription(
        uint256 tokenId
    ) public pure returns (string memory) {
        uint256 c;
        c  = bytes(roomContainer(tokenId, 0)).length == 0 ? 0 : 1;
        c += bytes(roomContainer(tokenId, 1)).length == 0 ? 0 : 1;
        c += bytes(roomContainer(tokenId, 2)).length == 0 ? 0 : 1;
        c += bytes(roomContainer(tokenId, 3)).length == 0 ? 0 : 1;

        string memory containers;
        if (0 == c) {
            containers = "";
        } else if (1 == c) {
            containers = "You find one container.";
        } else {
            containers = string(abi.encodePacked(
                "You find ",
                Strings.toString(c),
                " containers."
            ));
        }

        bytes memory exits = abi.encodePacked(
            exitPassable(tokenId, 0) ? string(abi.encodePacked(" To the North, there is a ", exitType(tokenId, 0), ".")) : "",
            exitPassable(tokenId, 1) ? string(abi.encodePacked(" To the East, there is a ", exitType(tokenId, 1), ".")) : "",
            exitPassable(tokenId, 2) ? string(abi.encodePacked(" To the South, there is a ", exitType(tokenId, 2), ".")) : "",
            exitPassable(tokenId, 3) ? string(abi.encodePacked(" To the West, there is a ", exitType(tokenId, 3), ".")) : ""
        );

        return string(abi.encodePacked(
            article(tokenId),
            " ",
            roomOpinion(tokenId),
            " ",
            roomType(tokenId),
            " with a mostly ",
            roomMaterial(tokenId),
            " construction. Compared to other rooms it is ",
            roomSize(tokenId),
            ", and feels ",
            roomModifier(tokenId),
            ". ",
            containers,
            exits
        ));
    }

    function tokenURI(uint256 tokenId) external pure returns (string memory) {
        bytes memory json = abi.encodePacked(
            "{\"description\":\"", tokenDescription(tokenId),"\",\"name\":\"",
            tokenName(tokenId),
            "\",\"attributes\":[{\"trait_type\":\"Opinion\",\"value\":\"",
            roomOpinion(tokenId),
            "\"},{\"trait_type\":\"Size\",\"value\":\"",
            roomSize(tokenId)
        );

        bytes memory json2 = abi.encodePacked(
            "\"},{\"trait_type\":\"Description\",\"value\":\"",
            roomModifier(tokenId),
            "\"},{\"trait_type\":\"Material\",\"value\":\"",
            roomMaterial(tokenId),
            "\"},{\"trait_type\":\"Biome\",\"value\":\"",
            roomType(tokenId),
            "\"}],\"image\":\"data:image/svg+xml;base64,",
            Base64.encode(bytes(image(tokenId))),
            "\"}"
        );

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(abi.encodePacked(json, json2))
        ));
    }
}// GPL-3.0-or-later

pragma solidity ^0.8.6;


library Errors {
    string constant internal OUT_OF_RANGE = "range";
    string constant internal NOT_OWNER = "owner";
    string constant internal ALREADY_CLAIMED = "claimed";
    string constant internal SOLD_OUT = "sold out";
    string constant internal INSUFFICIENT_VALUE = "low ether";
}

contract LootRoomToken is Ownable, Random, ERC721 {
    uint256 constant public AUCTION_BLOCKS = 6650;
    uint256 constant public AUCTION_MINIMUM_START = 1 ether;

    IERC721 immutable private LOOT;
    LootRoom immutable private RENDER;

    mapping (uint256 => bool) private s_ClaimedBags;

    uint256 private s_StartBlock;
    uint256 private s_StartPrice;
    uint256 private s_Lot;

    constructor(LootRoom render, IERC721 loot) ERC721("Loot Room", "ROOM") {
        RENDER = render;
        LOOT = loot;
        _startAuction(0);
    }

    function _generateTokenId() private returns (uint256) {
        return _random() & ~uint256(0xFFFF);
    }

    function _startAuction(uint256 lastPrice) private {
        uint256 oldLot = s_Lot;
        uint256 newLot = oldLot;
        while (newLot == oldLot) {
            newLot = _generateTokenId();
        }

        s_Lot = newLot;
        s_StartBlock = block.number;
        lastPrice *= 4;
        if (lastPrice < AUCTION_MINIMUM_START) {
            s_StartPrice = AUCTION_MINIMUM_START;
        } else {
            s_StartPrice = lastPrice;
        }
    }

    function getForSale() public view returns (uint256) {
        return s_Lot;
    }

    function getPrice() public view returns (uint256) {
        uint256 currentBlock = block.number - s_StartBlock;
        if (currentBlock >= AUCTION_BLOCKS) {
            return 0;
        } else {
            uint256 startPrice = s_StartPrice;
            uint256 sub = (startPrice * currentBlock) / AUCTION_BLOCKS;
            return startPrice - sub;
        }
    }

    function _buy(uint256 tokenId) private returns (uint256) {
        uint256 lot = s_Lot;
        require(0 == tokenId || tokenId == lot, Errors.SOLD_OUT);

        uint256 price = getPrice();
        require(msg.value >= price, Errors.INSUFFICIENT_VALUE);

        _startAuction(msg.value);

        return lot;
    }

    function safeBuy(uint256 tokenId) external payable returns (uint256) {
        tokenId = _buy(tokenId);
        _safeMint(msg.sender, tokenId);
        return tokenId;
    }

    function buy(uint256 tokenId) external payable returns (uint256) {
        tokenId = _buy(tokenId);
        _mint(msg.sender, tokenId);
        return tokenId;
    }

    function _claim(uint256 lootTokenId) private returns (uint256) {
        require(0 < lootTokenId && 8001 > lootTokenId, Errors.OUT_OF_RANGE);

        require(!s_ClaimedBags[lootTokenId], Errors.ALREADY_CLAIMED);
        s_ClaimedBags[lootTokenId] = true; // Claim before making any calls out.

        require(LOOT.ownerOf(lootTokenId) == msg.sender, Errors.NOT_OWNER);
        return _generateTokenId() | lootTokenId;
    }

    function safeClaim(uint256 lootTokenId) external returns (uint256) {
        uint256 tokenId = _claim(lootTokenId);
        _safeMint(msg.sender, tokenId);
        return tokenId;
    }

    function claim(uint256 lootTokenId) external returns (uint256) {
        uint256 tokenId = _claim(lootTokenId);
        _mint(msg.sender, tokenId);
        return tokenId;
    }

    function withdraw(address payable to) external onlyOwner {
        (bool success,) = to.call{value:address(this).balance}("");
        require(success, "failed");
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return RENDER.tokenURI(tokenId);
    }
}