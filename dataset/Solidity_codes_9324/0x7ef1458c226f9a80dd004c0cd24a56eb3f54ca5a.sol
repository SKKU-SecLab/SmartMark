
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
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

pragma solidity >=0.6.0;

library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

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

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
pragma solidity ^0.8.9;


interface IENS {

    function resolver(bytes32 node) external view returns (IResolver);

}

interface IResolver {

    function addr(bytes32 node) external view returns (address);

}

abstract contract Ownable is Context {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 private _releaseFee;

    bool private _releasesERC20;
    bool private _releasesERC721;

    address private _owner;

    bytes32 public _nameHash;

    constructor(uint256 releaseFee, bool releasesERC20, bool releasesERC721) {
        _owner = _msgSender();
        _releaseFee = releaseFee;
        _releasesERC20 = releasesERC20;
        _releasesERC721 = releasesERC721;
    }

    function owner() public view virtual returns (address) {
        if (_nameHash == "") return _owner;
        bytes32 node = _nameHash;
        IENS ens = IENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        IResolver resolver = ens.resolver(node);
        return resolver.addr(node);
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function setNameHash(bytes32 nameHash) external onlyOwner {
        _nameHash = nameHash;
    }

    function releaseERC20(IERC20 token, address to, uint256 amount) external onlyOwner {
        require(_releasesERC20, "Not allowed");
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");

        uint share = 100;
        if (_releaseFee > 0) token.safeTransfer(_msgSender(), amount.mul(_releaseFee).div(100));
        token.safeTransfer(to, amount.mul(share.sub(_releaseFee)).div(100));
    }

    function releaseERC721(IERC721 tokenAddress, address to, uint256 tokenId) external onlyOwner {
        require(_releasesERC721, "Not allowed");
        require(tokenAddress.ownerOf(tokenId) == address(this), "Invalid tokenId");

        tokenAddress.safeTransferFrom(address(this), to, tokenId);
    }

    function withdraw() external virtual onlyOwner {
        payable(_msgSender()).call{value: address(this).balance}("");
    }
}// MIT
pragma solidity ^0.8.9;


contract CryptData is Ownable(5, true, true) {

    using SafeMath for uint256;
    using Strings for uint256;

    struct Attribute {
        string label;
        string value;
        string svgPaths;
    }

    mapping(uint256 => uint256) public _seeds;

    string[20] public _svgPaths;

    string public _tokenUrl = "https://graveyardnft.com/#/crypts/";

    constructor() {
        for (uint256 i = 0;i <= 96;i++) {
            _seeds[i] = uint256(keccak256(abi.encodePacked(block.difficulty, blockhash(block.number -1), block.timestamp, i, msg.sender)));
        }
    }

    function uploadSvgPaths(uint256 index, string calldata paths) external onlyOwner {

        _svgPaths[index] = paths;
    }

    function setTokenUrl(string calldata tokenUrl) external onlyOwner {

        _tokenUrl = tokenUrl;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        Attribute[5] memory attributes = tokenAttributes(tokenId);
        return encode("application/json", abi.encodePacked('{',
            '"name": "CRYPT #', tokenId.toString(), '",',
            '"description": "The last resting place of failed NFT\'s.",',
            '"attributes": ', attributesToJson(tokenId, attributes),',',
            '"image": "', attributesToImageURI(tokenId, attributes), '",',
            '"external_link": "', _tokenUrl, tokenId.toString(), '",',
            '"external_url": "', _tokenUrl, tokenId.toString(), '"',
        '}'));
    }

    function getRewardRate(uint256 tokenId) external view returns (uint256) {

        return 10 * 1e18 + (getSpookiness(tokenId) * 1e18 / 10);
    }

    function tokenAttributes(uint256 tokenId) internal view returns (Attribute[5] memory attributes) {

        string[5] memory attributeLabels = ["Sky", "Crypt", "West", "East", "Item"];
        string[5][5] memory attributeValues = [
            ["Foggy", "Crescent Moon", "Full Moon", "Lightning", "Rainbow"],
            ["Mithraeum", "Roman", "Medieval", "Gothic", "Pyramid"],
            ["Headstone", "Tombstone", "Cross", "Skull Tombstone", "Tomb"],
            ["Headstone", "Tombstone", "Cross", "Skull Tombstone", "Tomb"],
            ["None", "Candle", "Lantern", "Skull", "Scythe"]
        ];

        tokenId--;
        uint256 seedIndex = tokenId / 70;
        uint256 seed = _seeds[seedIndex];
        uint256 offset = tokenId - (seedIndex * 70);
        uint8[19] memory weights = [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4];
        for (uint256 i = 0;i < attributes.length;i++) {
            uint256 weight = ((seed / 10 ** offset) % 10) + ((seed / 10 ** (offset + 1)) % 10);
            uint256 index = weights[weight];
            uint256 svgIndex = i > 2 ? (i * 5 + index) - 5 : i * 5 + index;
            string memory svgPath = string(abi.encodePacked('<g id="attribute-', i.toString(), '"', i == 2 ? ' transform="translate(1000, 0) scale(-1,1)"' : "", ">", _svgPaths[svgIndex], "</g>"));
            attributes[i] = Attribute(attributeLabels[i], attributeValues[i][index], svgPath);
            offset++;
        }

        return attributes;
    }

    function getSpookiness(uint256 tokenId) internal view returns (uint256) {

        uint256 id = tokenId - 1;
        uint256 seedIndex = id / 70;
        uint256 seed = _seeds[seedIndex];
        uint256 offset = id - (seedIndex * 70);
        uint256 spookiness = 0;
        for (uint256 i = 0;i < 5;i++) {
            spookiness += ((seed / 10 ** offset) % 10) + ((seed / 10 ** (offset + 1)) % 10) + 1;
            offset++;
        }
        return spookiness;
    }

    function encode(string memory mimeType, bytes memory source) internal pure returns (string memory) {

        return string(abi.encodePacked("data:", mimeType, ";base64,", Base64.encode(source)));
    }

    function attributesToJson(uint256 tokenId, Attribute[5] memory attributes) internal view returns (string memory) {

        bytes memory json;
        for (uint256 i = 0;i < attributes.length;i++) {
            json = bytes.concat(json, '{"trait_type": "', bytes(attributes[i].label), '", "value": "', bytes(attributes[i].value), '"},');
        }
        return string(bytes.concat("[", json, '{"trait_type": "Spookiness", "value": ', bytes(getSpookiness(tokenId).toString()), '}', "]"));
    }

    function attributesToImageURI(uint256 tokenId, Attribute[5] memory attributes) internal view returns (string memory) {

        uint256 spookiness = getSpookiness(tokenId);
        (bool success, uint256 hue) = SafeMath.trySub(spookiness, 5);
        hue = hue * 4;
        bytes memory paths = "";
        for (uint256 i = 0;i < attributes.length;i++) {
            paths = bytes.concat(paths, bytes(attributes[i].svgPaths));
            if (i == 0) { /// Add foreground after sky attribute
                paths = bytes.concat(paths, bytes('<g id="ground" style="filter: hue-rotate('), bytes(hue.toString()), bytes('deg)"><path fill="#0091d4" d="M9 472c-2 3-4 14-9 24v386h1000V526l-7-1 7-12-12 5-7-19 4 18-12-7 3 10-19-2a940 940 0 0 1-2 0h-2l4-18-6 18-5-1-14-9v-5l-22 9-14-25 12 26-9 3 5-8-7 5-23-11v6l-9-10 2 7-16 3 3-14-4 3 2-12-3 13-6 4-2-3-6-14 2 9-7-9 7 16-10-4 3 10-22 3 3-19-6 19-4 1-14-6v-6l-22 14-16-21 14 23-9 5 4-9-6 6-23-5v5l-20-7 8 12-7 3-4-2c1-8-2-20-2-20l-2 21-18-19 7 12-7 6-9-2c-3-3-4-8-5-9a11 11 0 0 0 2 9l-3-1 3 10-18 5a649 649 0 0 1-2 0l-2 1 3-20-5 21-4 1-7-2-2-8-4 5c-3-7-6-17-8-19l5 15v1l-7-12 6 12-5 5h-1l2-12-12 9-1-5-17 10-26-13 2 5-9 7-21 1v-10l-9 7-6-3 1-13-12 23 1 2-5-1 2-12-11 12-2-5-13 11-6-3 5 6-27-9 2 5-8 9-20 5v-10l-6 6 1-15-5 18-11-7 8 14-11 1-1-6-3 11-2-5-12 15h-2l1-6-6 9-3-17c0 3-3 4-2 13l-2 4-8-1 2-4-12 6v-4l-14 5-1 2-5-3 8-14-9 13h-1l3-16-5 15-10-6v4l-9 9-12 2 4-6-11 6 2-6h-6l1-14-3 13-16 2-1-1-4-7 10-13-11 11-1-1 14-28-16 25-11-19-2 7-14 2-3-2 1-23-3 22-18-10 5-10-11 1 9-17-12 17-4-7 9-13-23 19v-23l-1 22-4-2v3l-8-11 3-7-10 8 2-7-22 3-5-6 1 10-5-7a1277 1277 0 0 1-2-2l-15-19-2 7-14 4-4-1v-22l-2 22-1-1-5-19 3 19-16-5 6-11-10 3 10-17-9 9 5-9-10 15-2 2-8-9v15l-8-2 8-11-14 7 4-7-21 10 1-6-23 9-2-3 5-5-11 8-1-1Zm-15 12"/><path fill="#003a71" d="m211 636-46-5 6-56s3-23 26-21 21 26 21 26Zm789 10h-31v-59s0-24 25-24a31 31 0 0 1 6 0Zm-240 6-1-10-18 2-1-16-10 1 1 16-18 1 1 10 18-1 4 43 10-1-4-43 18-2z"/><path fill="#0d1856" d="m843 668-33 6-7-40s-3-16 13-19 20 13 20 13ZM120 564l-2-15-28 3-3-23-15 1 3 24-27 4 2 15 27-4 9 67 15-2-9-67 28-3zm799 22-2-10-18 3-2-16-9 1 2 16-18 2 1 10 18-2 5 43 10-1-5-44 18-2zM30 610l-12-1 2-10-7-1-1 10-12-1-1 6 12 2-3 28 6 1 4-29 11 2 1-7z"/><path fill="#005d9d" d="m15 635 4-18-7 19-12-5 7 12-7 1v356h1000V614l-17-18 16 27-11-7 5 5-2 3-23-9 1 6-21-10 4 7-13-7 8 11-9 2v-15l-8 9-2-2-10-15 5 9-9-9 10 17-9-3 5 11-16 5 3-19-5 19-1 1-2-22v22l-4 1-14-4-2-7-12 16-15-27 13 29-8 10 1-10-4 6-22-3 1 7-10-8 4 7-10-4 7 12-6 3v-3l-4 2-1-22v23l-5-27 3 26-21-18 9 13-4 7-12-17 9 17h-5l-10-8 7 7h-3l6 10-18 10-4-22 2 23-4 2-13-2-3-7-13 23-20-19 18 21-4 7-1 1-5-2h-10l-4-13 1 14h-6l2 6-11-6 4 6-12-2-8-9v-4l-14 7-8-13 7 14-5 3 3-5-4 3-14-5v4l-5-6 1 4-8-4 2 4h-3l2-8-3 8-4 1-6-8-1 8-7-2-12-16-2 5-9-15v11l-6-2 6-11-9 4-4-19v16l-5-6-1 10-20-5-7-9 1-5-27 9 5-6-5 3-14-11-1 5-11-12 1 12-5 1 2-3h-4l-9-22 1 13-6 3-9-7v9h-21l-8-7 1-5-26 13h-1l-16-10-1 5-5-8v6l-7-7 2 11-7-5-3 4-3-5-3 8-7 1-8-2-9-17 7 17-18-6 3-9-3 1 6-7c-2 0-5 4-9 7l-6 1 5-15c-2 1-5 9-8 16l-7-6 7-13-19 19-2-23 1 24-7-2 1 2-6-2 7-12-13 6 3-7-10 8v-5l-23 5-6-5 4 8-9-5 14-23-16 21h-1l7-27-9 25-19-12v6l-14 6-4-1c-2-7-4-17-6-19l3 19h-1l-10-16 8 15-19-2 3-10-10 4 7-16-7 9 3-9-7 14-2 3-6-4-2-13 1 12-4-3 4 14-10-1 6-11-13 9 2-7-9 10v-6l-25 12-9-1 13-26c-3 3-12 19-15 25l-1-1 5-28-8 27-18-7v5l-14 9-5 1-6-18 4 18h-1l-11-14 8 14-18 2 2-10Zm991-33"/></g>'));
            }
        }
        string memory invert = spookiness >= 85 ? "1" : "0";
        return encode("image/svg+xml", abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" version="1.1" viewBox="0 0 1000 1000" style="filter: invert(', invert, ')">',
            '<rect id="background" width="100%" height="100%" fill="#011628"/>',
            paths,
            '<g id="front"><path fill="#0e0543" d="m0 923 12-2 21-17h110l12 13 33 9 11 12 131 30 8 15 31 17H0v-77z"/><path fill="#001b55" d="m369 1000-32-17s-42 10-115 12l22 5Z"/><path fill="#00486d" d="M202 994s-7 11-72 2c0 0 32-17 72-2ZM157 977s-10 15-99 4c0 0 44-24 99-4Z"/><path fill="#001b55" d="m61 1000-37-5-4 5h41zM0 962v27l23 2 3-32-26 3z"/><path fill="#00486d" d="m219 970 111-2s-76-29-131-30l-39 16ZM153 954l-75 8-18-8-52-5s111-14 145 5ZM188 926l-24 3-19 9-82-3s74-4 92-18ZM143 904s-74 22-110 0c0 0 79-19 110 0ZM0 931l53 2s-43-4-41-12l-12 2Z"/><path fill="#0e0543" d="M1000 1000H873v-23l38-5 18-16h71v44z"/><path fill="#00486d" d="M1000 1000h-47l-46-4s53-7 93-4ZM1000 962c-22 4-52 6-71-6 0 0 40-9 71-7ZM947 982s-37-3-36-10l-38 5v9h23Z"/></g>',
            '</svg>'
        ));
    }
}