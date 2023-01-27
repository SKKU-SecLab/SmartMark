
pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

interface IERC2981Royalties {

    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);

}// MIT
pragma solidity ^0.8.9;

interface IRaribleSecondarySales {

    function getFeeRecipients(uint256 tokenId)
        external
        view
        returns (address payable[] memory);


    function getFeeBps(uint256 tokenId)
        external
        view
        returns (uint256[] memory);

}// MIT
pragma solidity ^0.8.9;

interface IFoundationSecondarySales {

    function getFees(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);

}// MIT
pragma solidity ^0.8.9;


interface IERC721WithRoyalties is
    IERC2981Royalties,
    IRaribleSecondarySales,
    IFoundationSecondarySales
{


}//MIT
pragma solidity ^0.8.9;


interface IERC721Slim is IERC721Upgradeable, IERC721WithRoyalties {

    function baseURI() external view returns (string memory);


    function contractURI() external view returns (string memory);



    function withdraw(
        address token,
        uint256 amount,
        uint256 tokenId
    ) external;


    function canEdit(address account) external view returns (bool);


    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external;


    function setBaseURI(string memory baseURI_) external;


    function setDefaultRoyaltiesRecipient(address recipient) external;


    function setContractURI(string memory contractURI_) external;

}//MIT
pragma solidity ^0.8.9;


interface INiftyForge721Slim is IERC721Slim {

    function initialize(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory baseURI_,
        address owner_,
        address minter_,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue
    ) external;


    function version() external view returns (bytes3);


    function minter() external view returns (address);


    function totalSupply() external view returns (uint256);


    function minted() external view returns (uint256);


    function maxSupply() external view returns (uint256);


    function mint(address to) external returns (uint256 tokenId);


    function mint(address to, address transferTo)
        external
        returns (uint256 tokenId);


    function mintBatch(address to, uint256 count)
        external
        returns (uint256 startId, uint256 endId);

}//MIT
pragma solidity ^0.8.9;

interface INFModuleTokenURI {

    function tokenURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);

}//MIT
pragma solidity ^0.8.9;

interface INFModuleWithRoyalties {

    function royaltyInfo(address registry, uint256 tokenId)
        external
        view
        returns (address recipient, uint256 basisPoint);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}//MIT
pragma solidity ^0.8.9;


contract NFBaseModuleSlim is ERC165 {

    event NewContractURI(string contractURI);

    string private _contractURI;

    constructor(string memory contractURI_) {
        _setContractURI(contractURI_);
    }

    function contractURI() external view virtual returns (string memory) {

        return _contractURI;
    }

    function _setContractURI(string memory contractURI_) internal {

        _contractURI = contractURI_;
        emit NewContractURI(contractURI_);
    }
}// MIT
pragma solidity ^0.8.0;


library Bytecode {

  error InvalidCodeAtRange(uint256 _size, uint256 _start, uint256 _end);

  function creationCodeFor(bytes memory _code) internal pure returns (bytes memory) {


    return abi.encodePacked(
      hex"63",
      uint32(_code.length),
      hex"80_60_0E_60_00_39_60_00_F3",
      _code
    );
  }

  function codeSize(address _addr) internal view returns (uint256 size) {

    assembly { size := extcodesize(_addr) }
  }

  function codeAt(address _addr, uint256 _start, uint256 _end) internal view returns (bytes memory oCode) {

    uint256 csize = codeSize(_addr);
    if (csize == 0) return bytes("");

    if (_start > csize) return bytes("");
    if (_end < _start) revert InvalidCodeAtRange(csize, _start, _end); 

    unchecked {
      uint256 reqSize = _end - _start;
      uint256 maxSize = csize - _start;

      uint256 size = maxSize < reqSize ? maxSize : reqSize;

      assembly {
        oCode := mload(0x40)
        mstore(0x40, add(oCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))
        mstore(oCode, size)
        extcodecopy(_addr, add(oCode, 0x20), _start, size)
      }
    }
  }
}// MIT
pragma solidity ^0.8.0;


library SSTORE2 {

  error WriteError();

  function write(bytes memory _data) internal returns (address pointer) {

    bytes memory code = Bytecode.creationCodeFor(
      abi.encodePacked(
        hex'00',
        _data
      )
    );

    assembly { pointer := create(0, add(code, 32), mload(code)) }

    if (pointer == address(0)) revert WriteError();
  }

  function read(address _pointer) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, 1, type(uint256).max);
  }

  function read(address _pointer, uint256 _start) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, _start + 1, type(uint256).max);
  }

  function read(address _pointer, uint256 _start, uint256 _end) internal view returns (bytes memory) {

    return Bytecode.codeAt(_pointer, _start + 1, _end + 1);
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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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
}pragma solidity ^0.8.0;



library Base64 {

    string internal constant TABLE =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

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

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                let input := mload(dataPtr)

                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }

    function toB64JSON(bytes memory toEncode)
        internal
        pure
        returns (string memory)
    {

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    encode(toEncode)
                )
            );
    }

    function toB64JSON(string memory toEncode)
        internal
        pure
        returns (string memory)
    {

        return toB64JSON(bytes(toEncode));
    }

    function toB64SVG(bytes memory toEncode)
        internal
        pure
        returns (string memory)
    {

        return
            string(
                abi.encodePacked('data:image/svg+xml;base64,', encode(toEncode))
            );
    }

    function toB64SVG(string memory toEncode)
        internal
        pure
        returns (string memory)
    {

        return toB64SVG(bytes(toEncode));
    }
}//MIT
pragma solidity ^0.8.0;


library SmartbagsUtils {

    using Strings for uint256;

    struct Color {
        string name;
        string color;
    }

    function getColor(address contractAddress)
        internal
        pure
        returns (Color memory)
    {

        uint256 colorSeed = uint256(uint160(contractAddress));

        return
            [
                Color({color: '#fc6f03', name: 'orange'}),
                Color({color: '#ff0000', name: 'red'}),
                Color({color: '#ffb700', name: 'gold'}),
                Color({color: '#ffe600', name: 'yellow'}),
                Color({color: '#fbff00', name: 'light green'}),
                Color({color: '#a6ff00', name: 'green'}),
                Color({color: '#dee060', name: 'pastel green'}),
                Color({color: '#f28b85', name: 'salmon'}),
                Color({color: '#48b007', name: 'forest green'}),
                Color({color: '#00ff55', name: 'turquoise green'}),
                Color({color: '#b4ff05', name: 'flashy Green'}),
                Color({color: '#61c984', name: 'alguae'}),
                Color({color: '#00ff99', name: 'turquoise'}),
                Color({color: '#00ffc3', name: 'flashy blue'}),
                Color({color: '#00fff2', name: 'light blue'}),
                Color({color: '#009c94', name: 'aqua blue'}),
                Color({color: '#0363ff', name: 'deep blue'}),
                Color({color: '#3636c2', name: 'blurple'}),
                Color({color: '#5d00ff', name: 'purple'}),
                Color({color: '#ff4ff9', name: 'pink'}),
                Color({color: '#fc0065', name: 'redPink'}),
                Color({color: '#ffffff', name: 'white'}),
                Color({color: '#c95136', name: 'copper'}),
                Color({color: '#c5c8c9', name: 'silver'})
            ][colorSeed % 24];
    }

    function getName(address contractAddress)
        internal
        view
        returns (string memory)
    {

        try IERC721Metadata(contractAddress).name() returns (
            string memory name
        ) {
            bytes memory strBytes = bytes(name);
            bytes memory sanitized = new bytes(strBytes.length);
            uint8 charCode;
            bytes1 char;
            for (uint256 i; i < strBytes.length; i++) {
                char = strBytes[i];
                charCode = uint8(char);

                if (
                    (charCode >= 33 && charCode <= 37) ||
                    (charCode >= 39 && charCode <= 47) ||
                    (charCode >= 48 && charCode <= 57) ||
                    (charCode >= 65 && charCode <= 90)
                ) {
                    sanitized[i] = char;
                } else if (charCode >= 97 && charCode <= 122) {
                    sanitized[i] = bytes1(charCode - 32);
                } else {
                    sanitized[i] = 0x32;
                }
            }

            if (sanitized.length > 0) {
                return string(sanitized);
            }
        } catch Error(string memory) {} catch (bytes memory) {}
        return uint256(uint160(contractAddress)).toHexString(20);
    }

    function tokenNumber(uint256 tokenId)
        internal
        pure
        returns (string memory)
    {
        bytes memory tokenStr = bytes(tokenId.toString());
        bytes memory fixedTokenStr = new bytes(4);
        fixedTokenStr[0] = 0x30;
        fixedTokenStr[1] = 0x30;
        fixedTokenStr[2] = 0x30;
        fixedTokenStr[3] = 0x30;

        uint256 it;
        for (uint256 i = tokenStr.length; i > 0; i--) {
            fixedTokenStr[3 - it] = tokenStr[i - 1];
            it++;
        }

        return string(fixedTokenStr);
    }

    function renderContract(address _addr, uint256 length)
        internal
        view
        returns (bytes memory)
    {
        uint256 maxSize;
        assembly {
            maxSize := extcodesize(_addr)
        }

        uint256 offset = maxSize > length
            ? (maxSize - length) % uint256(uint160(_addr))
            : 0;

        bytes memory code = getContractBytecode(
            _addr,
            offset,
            maxSize < length ? maxSize : length
        );

        if (maxSize < length) {
            uint256 toFill = length - maxSize;
            uint256 length = toFill / 2;

            bytes memory filler = new bytes(length);
            for (uint256 i; i < length; i++) {
                filler[i] = 0xff;
            }

            return abi.encodePacked(filler, code, filler);
        }

        return code;
    }

    function getContractBytecode(
        address _addr,
        uint256 start,
        uint256 length
    ) internal view returns (bytes memory o_code) {
        assembly {
            o_code := mload(0x40)
            mstore(
                0x40,
                add(o_code, and(add(add(length, 0x20), 0x1f), not(0x1f)))
            )
            mstore(o_code, length)
            extcodecopy(_addr, add(o_code, 0x20), start, length)
        }
    }
}//MIT
pragma solidity ^0.8.0;







interface IRenderer {

    function render(
        address contractAddress,
        string memory tokenNumber,
        string memory name,
        SmartbagsUtils.Color memory color,
        bytes memory texture,
        bytes memory fonts
    ) external pure returns (string memory);

}

interface IBagOpener {

    function open(
        uint256 tokenId,
        address owner,
        address operator,
        address contractAddress
    ) external;


    function render(uint256 tokenId, address contractAddress)
        external
        view
        returns (string memory);

}

contract Smartbags is
    Ownable,
    NFBaseModuleSlim,
    INFModuleTokenURI,
    INFModuleWithRoyalties,
    ReentrancyGuard
{

    using Strings for uint256;
    using SafeERC20 for IERC20;

    event BagsOpened(address operator, uint256[] tokenIds);

    error ShopIsClosed();
    error NoCanDo();
    error AlreadyMinted();
    error OutOfJpegs();

    error TooEarly();
    error AlreadyOpened();

    error ContractLocked();
    error NotAuthorized();

    error NotMinted();
    error OnlyContracts();

    error OnlyAsh();

    error WrongValue(uint256 expected, uint256 received);

    struct Payment {
        address token;
        uint96 unitPrice;
    }

    address public bagOpener;

    bool public collectActive;

    mapping(uint256 => address) public files;

    bool public locked;

    address public nftContract;

    mapping(uint256 => bool) public openedBags;

    Payment public payment;

    address public renderer;

    mapping(uint256 => address) public tokenToContract;

    mapping(address => uint256) public contractToToken;

    constructor(
        address renderer_,
        string memory moduleURI,
        Payment memory payment_,
        bool activateCollect,
        address owner_
    ) NFBaseModuleSlim(moduleURI) {
        renderer = renderer_;

        payment = payment_;

        collectActive = activateCollect;

        if (owner_ != address(0)) {
            transferOwnership(owner_);
        }
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {

        return
            interfaceId == type(INFModuleTokenURI).interfaceId ||
            interfaceId == type(INFModuleWithRoyalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokenURI(address, uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {

        address contractAddress = tokenToContract[tokenId];
        if (address(0) == contractAddress) revert NotMinted();

        return
            openedBags[tokenId]
                ? IBagOpener(bagOpener).render(tokenId, contractAddress)
                : _render(tokenId, contractAddress);
    }

    function royaltyInfo(address, uint256)
        public
        view
        override
        returns (address receiver, uint256 basisPoint)
    {

        return (owner(), 420);
    }


    function renderWithData(address contractAddress, string memory tokenNumber)
        public
        view
        returns (
            string memory uri,
            string memory name,
            SmartbagsUtils.Color memory color,
            bool minted
        )
    {

        minted = isMinted(contractAddress);

        color = SmartbagsUtils.getColor(contractAddress);

        name = SmartbagsUtils.getName(contractAddress);

        uri = IRenderer(renderer).render(
            contractAddress,
            tokenNumber,
            name,
            color,
            abi.encodePacked(SSTORE2.read(files[0]), SSTORE2.read(files[1])),
            SSTORE2.read(files[2])
        );
    }

    function isMinted(address contractAddress) public view returns (bool) {

        if (
            contractAddress ==
            address(0x21BEf5412E69cDcDA1B258c0E7C0b9db589083C3)
        ) {
            return true;
        }

        uint256 tokenId = contractToToken[contractAddress];
        address tokenContract = tokenToContract[tokenId];

        return tokenContract == contractAddress;
    }


    function collect(address contractAddress) public nonReentrant {

        if (!collectActive) {
            revert ShopIsClosed();
        }

        _proceedPayment(1);
        _collect(contractAddress);
    }

    function collectBatch(address[] calldata contractAddresses)
        public
        nonReentrant
    {

        if (!collectActive) {
            revert ShopIsClosed();
        }

        uint256 length = contractAddresses.length;
        _proceedPayment(length);
        for (uint256 i; i < length; i++) {
            _collect(contractAddresses[i]);
        }
    }

    function openBags(uint256[] calldata tokenIds) external {

        address bagOpener_ = bagOpener;

        if (address(0) == bagOpener_) {
            revert TooEarly();
        }

        uint256 tokenId;
        address ownerOf;
        uint256 length = tokenIds.length;
        address nftContract_ = nftContract;
        for (uint256 i; i < length; i++) {
            tokenId = tokenIds[i];

            if (openedBags[tokenId]) {
                revert AlreadyOpened();
            }

            ownerOf = IERC721(nftContract_).ownerOf(tokenId);
            if (
                msg.sender != ownerOf &&
                !IERC721(nftContract_).isApprovedForAll(ownerOf, msg.sender)
            ) {
                revert NotAuthorized();
            }

            openedBags[tokenId] = true;

            IBagOpener(bagOpener_).open(
                tokenId,
                ownerOf,
                msg.sender,
                tokenToContract[tokenId]
            );
        }

        emit BagsOpened(msg.sender, tokenIds);
    }


    function withdraw(address token) external onlyOwner {

        IERC20(token).safeTransfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }

    function lock() external onlyOwner {

        locked = true;
    }

    function setContractURI(string memory newURI) external onlyOwner {

        if (locked) revert ContractLocked();
        _setContractURI(newURI);
    }

    function setRenderer(address newRenderer) external onlyOwner {

        if (locked) revert ContractLocked();
        renderer = newRenderer;
    }

    function setNFTContract(address newNFTContract) external onlyOwner {

        if (locked) revert ContractLocked();
        nftContract = newNFTContract;
    }

    function setPayment(Payment calldata newPayment) external onlyOwner {

        if (locked) revert ContractLocked();
        payment = newPayment;
    }

    function allowOpening(address bagOpener_) external onlyOwner {

        if (locked) revert ContractLocked();
        bagOpener = bagOpener_;
    }

    function setCollectActive(bool activateCollect) external onlyOwner {

        collectActive = activateCollect;
    }

    function saveFile(uint256 index, string calldata fileContent)
        external
        onlyOwner
    {

        files[index] = SSTORE2.write(bytes(fileContent));
    }


    function _render(uint256 tokenId, address contractAddress)
        internal
        view
        returns (string memory uri)
    {

        (uri, , , ) = renderWithData(
            contractAddress,
            SmartbagsUtils.tokenNumber(tokenId)
        );
    }

    function _proceedPayment(uint256 pieces) internal {

        Payment memory _payment = payment;
        if (address(0) == _payment.token) {
            if (msg.value != uint256(_payment.unitPrice) * pieces) {
                revert WrongValue({
                    expected: _payment.unitPrice,
                    received: msg.value
                });
            }
        } else {
            if (msg.value != 0) revert OnlyAsh();
            IERC20(_payment.token).safeTransferFrom(
                msg.sender,
                owner(),
                uint256(_payment.unitPrice) * pieces
            );
        }
    }

    function _collect(address contractAddress) internal {

        if (
            contractAddress ==
            address(0x21BEf5412E69cDcDA1B258c0E7C0b9db589083C3)
        ) {
            revert NoCanDo();
        }
        if (!Address.isContract(contractAddress)) revert OnlyContracts();
        if (isMinted(contractAddress)) revert AlreadyMinted();

        _mint(contractAddress);
    }

    function _mint(address contractAddress) internal {

        uint256 tokenId = INiftyForge721Slim(nftContract).mint(msg.sender);
        tokenToContract[tokenId] = contractAddress;
        contractToToken[contractAddress] = tokenId;
    }
}