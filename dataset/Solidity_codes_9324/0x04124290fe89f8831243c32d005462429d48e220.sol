pragma solidity >=0.8.0 <0.9.0;

contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

contract OwnableDelegateProxy {


}// MIT
pragma solidity >=0.8.0 <0.9.0;



library OpenSeaGasFreeListing {

    function isApprovedForAll(address owner, address operator) internal view returns (bool) {

        address proxy = proxyFor(owner);
        return proxy != address(0) && proxy == operator;
    }

    function proxyFor(address owner) internal view returns (address) {

        address registry;
        uint256 chainId;

        assembly {
            chainId := chainid()
            switch chainId
            case 1 {
                registry := 0xa5409ec958c83c3f309868babaca7c86dcb077c1
            }
            case 137 {
                registry := 0x58807baD0B376efc12F5AD86aAc70E78ed67deaE
            }
            case 4 {
                registry := 0xf57b2c51ded3a29e6891aba85459d600256cf317
            }
            case 80001 {
                registry := 0xff7Ca10aF37178BdD056628eF42fD7F799fAc77c
            }
            case 1337 {
                registry := 0xE1a2bbc877b29ADBC56D2659DBcb0ae14ee62071
            }
        }

        if (registry == address(0) || chainId == 137 || chainId == 80001) {
            return registry;
        }

        return address(ProxyRegistry(registry).proxies(owner));
    }
}// MIT
pragma solidity ^0.8.10;


abstract contract ERC721 {

    string public name;
    string public symbol;

    mapping(uint256 => address) public _ownerOf;
    mapping(address => uint256) public _balances;

    mapping(uint256 => address) public _tokenApprovals;
    mapping(address => mapping(address => bool)) public _operatorApprovals;
    bool public openSeaGasFreeListingEnabled;


    error NotAuthorized();
    error BalanceQueryForZeroAddress();

    error AlreadyMinted();
    error NonExistent();

    error InvalidRecipient();
    error UnsafeRecipient();


    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }


    function tokenURI(uint256 id) public view virtual returns (string memory);

    function balanceOf(address account) public view virtual returns (uint256) {
        if (account == address(0)) revert BalanceQueryForZeroAddress();
        return _balances[account];
    }

    function ownerOf(uint256 id) public view virtual returns (address) {
        if (_ownerOf[id] == address(0)) revert NonExistent();
        return _ownerOf[id];
    }

    function approve(address approved, uint256 id) public virtual {
        address owner = _ownerOf[id];
        if (!(msg.sender == owner || _operatorApprovals[owner][msg.sender])) revert NotAuthorized();
        _tokenApprovals[id] = approved;
        emit Approval(owner, approved, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return
            _operatorApprovals[owner][operator] ||
            (openSeaGasFreeListingEnabled &&
                OpenSeaGasFreeListing.isApprovedForAll(owner, operator));
    }

    function getApproved(uint256 id) public view virtual returns (address) {
        if (_ownerOf[id] == address(0)) revert NonExistent();
        return _tokenApprovals[id];
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        address owner = _ownerOf[id];
        if (owner == address(0)) revert NonExistent();
        if (
            owner != from ||
            !(msg.sender == owner ||
                _tokenApprovals[id] == msg.sender ||
                _operatorApprovals[owner][msg.sender])
        ) revert NotAuthorized();
        if (to == address(0)) revert InvalidRecipient();

        unchecked {
            _balances[from]--;
            _balances[to]++;
        }

        _ownerOf[id] = to;

        delete _tokenApprovals[id];

        emit Approval(address(0), to, id);
        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        if (
            !(to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector)
        ) revert UnsafeRecipient();
    }


    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC721Metadata
            interfaceId == 0x2a55205a; // ERC165 Interface ID for EIP2981
    }


    function _mint(address to, uint256 id) internal virtual {
        if (to == address(0)) revert InvalidRecipient();
        if (_ownerOf[id] != address(0)) revert AlreadyMinted();

        unchecked {
            _balances[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];
        if (_ownerOf[id] == address(0)) revert NonExistent();

        unchecked {
            _balances[owner]--;
        }

        delete _ownerOf[id];
        delete _tokenApprovals[id];

        emit Approval(address(0), address(0), id);
        emit Transfer(owner, address(0), id);
    }


    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

interface ERC721TokenReceiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4);

}// MIT
pragma solidity ^0.8.10;


abstract contract ERC721BatchMinting is ERC721 {
    function _mintBatch(address to, uint256[] memory ids) internal virtual {
        if (to == address(0)) revert InvalidRecipient();

        for (uint256 id = 0; id < ids.length; ) {
            if (_ownerOf[ids[id]] != address(0)) revert AlreadyMinted();
            _ownerOf[ids[id]] = to;
            emit Transfer(address(0), to, ids[id]);
            unchecked {
                id++;
            }
        }

        unchecked {
            _balances[to] += ids.length;
        }
    }

    function _safeMintBatch(address to, uint256[] memory ids) internal virtual {
        _mintBatch(to, ids);

        for (uint256 id = 0; id < ids.length; ) {
            require(
                to.code.length == 0 ||
                    ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
            unchecked {
                id++;
            }
        }
    }

    function _safeMintBatch(
        address to,
        uint256[] memory ids,
        bytes memory data
    ) internal virtual {
        _mintBatch(to, ids);

        for (uint256 id = 0; id < ids.length; ) {
            require(
                to.code.length == 0 ||
                    ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
            unchecked {
                id++;
            }
        }
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ReentrancyGuard {
    uint256 private reentrancyStatus = 1;

    modifier nonReentrant() {
        require(reentrancyStatus == 1, "REENTRANCY");

        reentrancyStatus = 2;

        _;

        reentrancyStatus = 1;
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
pragma solidity ^0.8.2;

library Base64 {

    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}// MIT

pragma solidity ^0.8.0;

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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}//Unlicense


pragma solidity ^0.8.10;


interface IQuiltGeneratorUKR {

    struct Quilt {
        uint256[25] patches;
        uint256 quiltW;
        uint256 quiltH;
        uint256 totalPatchCount;
        uint256 totalPatchesAbsW;
        uint256 totalPatchesAbsH;
        uint256 quiltAbsW;
        uint256 quiltAbsH;
        uint256 roundness;
        uint256 themeIndex;
        uint256 backgroundIndex;
        uint256 calmnessFactor;
        bool hovers;
        bool animatedBg;
    }

    function generateQuilt(uint256 seed) external view returns (Quilt memory);


    function quiltImageSVGString(Quilt memory quilt, uint256 seed)
        external
        view
        returns (string memory svg);


    function quiltMetadata(uint256 tokenId, uint256 seed)
        external
        view
        returns (string memory metadata);

}

contract QuiltGeneratorUKR is IQuiltGeneratorUKR {

    string[5][3] private colors = [
        ["0A335C", "0066FF", "66B3FF", "CCE6FF", "Azure"],
        ["413609", "FFCC00", "FFE580", "FFF5CC", "Gold"],
        ["0A335C", "3399FF", "FFCC00", "FFF5CC", "Azure Gold"]
    ];

    string[] private patches = [
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c3)" fill-rule="evenodd" d="M27.9715 11.7482c.253-2.78564 1.5958-5.72102 4.0284-7.7482 2.4327 2.02728 3.7755 4.96285 4.0283 7.7487 1.2997-2.47703 3.6637-4.67529 6.687-5.61728 1.4717 2.80379 1.5889 6.02958.7566 8.69998 2.1486-1.7909 5.1737-2.917 8.3272-2.6303.2867 3.1534-.8393 6.1784-2.6301 8.327 2.6704-.8323 5.896-.715 8.6997.7566-.942 3.0233-3.14 5.3871-5.6169 6.6869 2.7857.2529 5.7211 1.5957 7.7483 4.0283-2.0273 2.4327-4.9628 3.7755-7.7486 4.0284 2.4769 1.2996 4.6751 3.6636 5.6171 6.6869-2.8038 1.4717-6.0295 1.589-8.7.7566 1.7909 2.1486 2.917 5.1737 2.6304 8.3273-3.1534.2866-6.1784-.8394-8.327-2.6302.8322 2.6704.7149 5.896-.7567 8.6997-3.0232-.942-5.3871-3.14-6.6868-5.6169-.2529 2.7857-1.5957 5.7211-4.0283 7.7483-2.4327-2.0273-3.7755-4.9628-4.0284-7.7486-1.2997 2.477-3.6636 4.6752-6.687 5.6172-1.4717-2.8038-1.5889-6.0296-.7565-8.7001-2.1486 1.791-5.1738 2.9171-8.3273 2.6304-.2867-3.1534.8393-6.1783 2.6301-8.327-2.6703.8322-5.89594.7149-8.69958-.7567.94194-3.0232 3.14001-5.387 5.61688-6.6868C8.96258 35.7755 6.02719 34.4327 4 32.0001c2.02726-2.4327 4.9628-3.7755 7.7486-4.0284-2.47697-1.2996-4.67519-3.6636-5.61718-6.6869 2.80379-1.4717 6.02958-1.589 8.69998-.7566-1.7909-2.1486-2.917-5.1737-2.6303-8.3273 3.1534-.2866 6.1784.8394 8.327 2.6302-.8322-2.6704-.7149-5.89602.7567-8.69968 3.0231.94194 5.387 3.14 6.6867 5.61678Zm1.0365 5.2108c-.197 1.2964-.7876 2.4766-1.8359 3.3858-1.384.0984-2.6361-.3185-3.692-1.0957.314 1.2729.22 2.5892-.4006 3.8303-1.2411.6206-2.5576.7145-3.8306.4005.7773 1.0559 1.1943 2.3081 1.0959 3.6923-.9093 1.0484-2.0896 1.6389-3.3861 1.8359 1.1224.6781 1.9869 1.6755 2.4257 2.992-.4388 1.3165-1.3032 2.3137-2.4254 2.9918 1.2963.197 2.4766.7876 3.3858 1.836.0984 1.384-.3185 2.6361-1.0957 3.692 1.2729-.314 2.5892-.22 3.8303.4005.6205 1.2412.7145 2.5576.4004 3.8307 1.056-.7773 2.3081-1.1943 3.6923-1.0959 1.0484.9093 1.639 2.0896 1.836 3.3861.6781-1.1224 1.6754-1.9869 2.992-2.4258 1.3164.4389 2.3137 1.3032 2.9918 2.4255.197-1.2964.7876-2.4766 1.8359-3.3858 1.3841-.0984 2.6362.3185 3.6921 1.0957-.314-1.2729-.22-2.5892.4005-3.8303 1.2412-.6206 2.5576-.7146 3.8307-.4005-.7774-1.0559-1.1943-2.3081-1.0959-3.6923.9092-1.0484 2.0896-1.639 3.3861-1.8359-1.1224-.6781-1.9869-1.6755-2.4257-2.992.4388-1.3165 1.3032-2.3138 2.4254-2.9919-1.2963-.197-2.4766-.7876-3.3858-1.8359-.0984-1.384.3185-2.6361 1.0957-3.692-1.2729.314-2.5892.22-3.8303-.4006-.6206-1.2411-.7146-2.5575-.4005-3.8306-1.0559.7773-2.3081 1.1943-3.6922 1.0959-1.0485-.9093-1.6391-2.0896-1.836-3.3861-.6781 1.1224-1.6755 1.9869-2.992 2.4258-1.3165-.4388-2.3138-1.3032-2.9919-2.4255Z" clip-rule="evenodd"/><path fill="url(#c2)" d="M30.8962 16.2255c.59-.6551 1.6176-.6551 2.2076 0 .4889.5429 1.3.6496 1.9127.2518.7395-.48 1.732-.2141 2.1324.5714.3318.6509 1.0876.9639 1.7824.7383.8386-.2723 1.7284.2414 1.9119 1.1038.152.7146.801 1.2126 1.5305 1.1744.8805-.046 1.6071.6806 1.561 1.5611-.0381.7295.4599 1.3785 1.1745 1.5305.8624.1835 1.3761 1.0733 1.1038 1.9119-.2256.6948.0874 1.4506.7383 1.7824.7855.4004 1.0514 1.3929.5714 2.1324-.3978.6127-.2911 1.4238.2518 1.9127.6551.59.6551 1.6176 0 2.2076-.5429.4889-.6496 1.3-.2518 1.9127.48.7395.2141 1.732-.5714 2.1324-.6509.3318-.9639 1.0876-.7383 1.7824.2723.8386-.2414 1.7284-1.1038 1.9119-.7146.152-1.2126.801-1.1745 1.5305.0461.8805-.6805 1.6071-1.561 1.561-.7295-.0381-1.3785.4599-1.5305 1.1745-.1835.8624-1.0733 1.3761-1.9119 1.1038-.6948-.2256-1.4506.0874-1.7824.7383-.4004.7855-1.3929 1.0514-2.1324.5714-.6127-.3978-1.4238-.2911-1.9127.2518-.59.6551-1.6176.6551-2.2076 0-.4889-.5429-1.3-.6496-1.9127-.2518-.7395.48-1.732.2141-2.1324-.5714-.3318-.6509-1.0876-.9639-1.7824-.7383-.8386.2723-1.7284-.2414-1.9119-1.1038-.152-.7146-.801-1.2126-1.5305-1.1745-.8805.0461-1.6071-.6805-1.5611-1.561.0382-.7295-.4598-1.3785-1.1744-1.5305-.8624-.1835-1.3761-1.0733-1.1038-1.9119.2256-.6948-.0874-1.4506-.7383-1.7824-.7855-.4004-1.0514-1.3929-.5714-2.1324.3978-.6127.2911-1.4238-.2518-1.9127-.6551-.59-.6551-1.6176 0-2.2076.5429-.4889.6496-1.3.2518-1.9127-.48-.7395-.2141-1.732.5714-2.1324.6509-.3318.9639-1.0876.7383-1.7824-.2723-.8386.2414-1.7284 1.1038-1.9119.7146-.152 1.2126-.801 1.1744-1.5305-.046-.8805.6806-1.6071 1.5611-1.5611.7295.0382 1.3785-.4598 1.5305-1.1744.1835-.8624 1.0733-1.3761 1.9119-1.1038.6948.2256 1.4506-.0874 1.7824-.7383.4004-.7855 1.3929-1.0514 2.1324-.5714.6127.3978 1.4238.2911 1.9127-.2518Z"/>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c2)" d="M32 14c1.6569 0 3-1.3431 3-3 0-1.65685-1.3431-3-3-3s-3 1.34315-3 3c0 1.6569 1.3431 3 3 3Zm0 42c1.6569 0 3-1.3431 3-3s-1.3431-3-3-3-3 1.3431-3 3 1.3431 3 3 3Zm24-24c0 1.6569-1.3431 3-3 3s-3-1.3431-3-3 1.3431-3 3-3 3 1.3431 3 3Zm-45 3c1.6569 0 3-1.3431 3-3s-1.3431-3-3-3c-1.65685 0-3 1.3431-3 3s1.34315 3 3 3Z"/><path fill="url(#c2)" d="M25 11v12l6 8-8-6H11l5 6h15V16l-6-5Zm14 0v12l-6 8V16l6-5Zm-6 20 8-6h12l-5 6H33Zm-8 22V41l6-8v15l-6 5Zm6-20-8 6H11l5-6h15Zm8 20V41l-6-8 8 6h12l-5-6H33v15l6 5Z"/><path fill="url(#c3)" d="m-19 32 51-51 51 51-51 51-51-51Zm5.6569 0L32 77.3431 77.3431 32 32-13.3431-13.3431 32Z"/><path fill="url(#c3)" d="M-6 32 32-6l38 38-38 38-38-38Zm5.656854 0L32 64.3431 64.3431 32 32-.343146-.343146 32Z"/>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c2)" fill-rule="evenodd" d="M47 18 34 31h15l13-13H47Zm0 28L34 33h15l13 13H47ZM17 18l13 13H15L2 18h15Zm0 28 13-13H15L2 46h15Z" clip-rule="evenodd"/><path fill="url(#c3)" fill-rule="evenodd" d="m18 17 13 13V15L18 2v15Zm28 0L33 30V15L46 2v15ZM18 47l13-13v15L18 62V47Zm28 0L33 34v15l13 13V47Z" clip-rule="evenodd"/><path fill="url(#c2)" fill-rule="evenodd" d="M9 12c1.6569 0 3-1.3431 3-3 0-1.65685-1.3431-3-3-3-1.65685 0-3 1.34315-3 3 0 1.6569 1.34315 3 3 3Zm46 0c1.6569 0 3-1.3431 3-3 0-1.65685-1.3431-3-3-3s-3 1.34315-3 3c0 1.6569 1.3431 3 3 3Zm3 43c0 1.6569-1.3431 3-3 3s-3-1.3431-3-3 1.3431-3 3-3 3 1.3431 3 3ZM9 58c1.6569 0 3-1.3431 3-3s-1.3431-3-3-3c-1.65685 0-3 1.3431-3 3s1.34315 3 3 3Z" clip-rule="evenodd"/>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><g fill-rule="evenodd" clip-rule="evenodd"><path fill="url(#c2)" d="M26 26h12v12H26V26Z"/><path fill="url(#c2)" d="M38 15.7568c0 2.4632-2.5916 5.1084-4.3683 6.6325-.9493.8143-2.3141.8143-3.2634 0C28.5916 20.8652 26 18.22 26 15.7568c0-2.2676 2.1961-5.5173 3.9311-7.7308 1.0722-1.368 3.0656-1.368 4.1378 0C35.8039 10.2395 38 13.4892 38 15.7568ZM34 16c0 1.1046-.8954 2-2 2s-2-.8954-2-2 .8954-2 2-2 2 .8954 2 2Zm4 32.2432c0-2.4632-2.5916-5.1084-4.3683-6.6325-.9493-.8143-2.3141-.8143-3.2634 0C28.5916 43.1348 26 45.78 26 48.2432c0 2.2676 2.1961 5.5173 3.9311 7.7308 1.0722 1.368 3.0656 1.368 4.1378 0C35.8039 53.7605 38 50.5108 38 48.2432ZM34 48c0-1.1046-.8954-2-2-2s-2 .8954-2 2 .8954 2 2 2 2-.8954 2-2Zm7.6107-17.6317C43.1348 28.5916 45.78 26 48.2432 26c2.2676 0 5.5173 2.1961 7.7308 3.9311 1.368 1.0722 1.368 3.0656 0 4.1378C53.7605 35.8039 50.5108 38 48.2432 38c-2.4632 0-5.1084-2.5916-6.6325-4.3683-.8143-.9493-.8143-2.3141 0-3.2634ZM46 32c0-1.1046.8954-2 2-2s2 .8954 2 2-.8954 2-2 2-2-.8954-2-2Zm-30.2432-6c2.4632 0 5.1084 2.5916 6.6325 4.3683.8143.9493.8143 2.3141 0 3.2634C20.8652 35.4084 18.22 38 15.7568 38c-2.2676 0-5.5173-2.1961-7.7308-3.9311-1.368-1.0722-1.368-3.0656 0-4.1378C10.2395 28.1961 13.4892 26 15.7568 26ZM16 30c1.1046 0 2 .8954 2 2s-.8954 2-2 2-2-.8954-2-2 .8954-2 2-2Z"/><path fill="url(#c3)" d="M-1.41421-1.41421c.781045-.78105 2.047375-.78105 2.82842 0L25.4142 22.5858c.7811.781.7811 2.0474 0 2.8284-.781.7811-2.0474.7811-2.8284 0L-1.41421 1.41421c-.78105-.781045-.78105-2.047375 0-2.82842Zm66.82841 0c.7811.781045.7811 2.047375 0 2.82842l-24 23.99999c-.781.7811-2.0474.7811-2.8284 0-.7811-.781-.7811-2.0474 0-2.8284l24-24.00001c.781-.78105 2.0474-.78105 2.8284 0Zm-40 40.00001c.7811.781.7811 2.0474 0 2.8284l-23.99999 24c-.781045.7811-2.047375.7811-2.82842 0-.78105-.781-.78105-2.0474 0-2.8284l24.00001-24c.781-.7811 2.0474-.7811 2.8284 0Zm13.1716 0c.781-.7811 2.0474-.7811 2.8284 0l24 24c.7811.781.7811 2.0474 0 2.8284-.781.7811-2.0474.7811-2.8284 0l-24-24c-.7811-.781-.7811-2.0474 0-2.8284Z"/></g>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c2)" fill-rule="evenodd" d="M44 20 56 8v24H32V20L44 8v12ZM32 32H8v24l12-12v12l12-12V32Z" clip-rule="evenodd"/><path fill="url(#c3)" fill-rule="evenodd" d="M20 20 8 8v24h24v12l12 12V44l12 12V32H32V20L20 8v12Z" clip-rule="evenodd"/>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c3)" fill-rule="evenodd" d="M54 6h4v4h-4V6Zm-2 6V4h8v8h-8Zm-8 8h8v-8h-8v8Zm0 0v8h-8v-8h8Zm6-6h-4v4h4v-4Zm-8 8h-4v4h4v-4Z" clip-rule="evenodd"/><path fill="url(#c2)" fill-rule="evenodd" d="M28 7v20L14 13V6l3.8284 3.82843C18.5786 10.5786 19.596 11 20.6569 11H21c2.2091 0 4-1.79086 4-4V4l3 3ZM7 28h20L13 14H6l3.82843 3.8284C10.5786 18.5786 11 19.596 11 20.6569V21c0 2.2091-1.79086 4-4 4H4l3 3Zm0 8h20L13 50H6l3.82843-3.8284C10.5786 45.4214 11 44.404 11 43.3431V43c0-2.2091-1.79086-4-4-4H4l3-3Zm21 21V37L14 51v7l3.8284-3.8284C18.5786 53.4214 19.596 53 20.6569 53H21c2.2091 0 4 1.7909 4 4v3l3-3Zm8-20v20l3 3v-3c0-2.2091 1.7909-4 4-4h.3431c1.0609 0 2.0783.4214 2.8285 1.1716L50 58v-7L36 37Zm1-1h20l3 3h-3c-2.2091 0-4 1.7909-4 4v.3431c0 1.0609.4214 2.0783 1.1716 2.8285L58 50h-7L37 36Zm-7-6h4v4h-4v-4Zm-2 6v-8h8v8h-8Z" clip-rule="evenodd"/>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c3)" fill-rule="evenodd" d="M12 6H6v6h6V6Zm22 25 13-13h15L49 31H34Zm-4 0L17 18H2l13 13h15ZM6 52h6v6H6v-6ZM52 6h6v6h-6V6Zm6 46h-6v6h6v-6Z" clip-rule="evenodd"/><path fill="url(#c2)" fill-rule="evenodd" d="M31 30 18 17V2l13 13v15Zm2 0 13-13V2L33 15v15Zm-9 8H14v2h10v10h2V38h-2Zm-14 4h12v12h-2V44H10v-2Zm-4 4h12v12h-2V48H6v-2Zm44-8H38v12h2V40h10v-2Zm-6 4h10v2H44v10h-2V42h2Zm4 4h10v2H48v10h-2V46h2ZM28 32h8v3l-3 3v15.5858l3.7071 3.7071-1.4142 1.4142L32 55.4142l-3.2929 3.2929-1.4142-1.4142L31 53.5858V38l-3-3v-3Zm4 24.5858 2.7071 2.7071-1.4142 1.4142L32 59.4142l-1.2929 1.2929-1.4142-1.4142L32 56.5858Z" clip-rule="evenodd"/>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c2)" fill-rule="evenodd" d="m32 17-8-8v13h5v7h-7v-5H9l8 8-8 8h13v-5h7v7h-5v13l8-8 8 8V42h-5v-7h7v5h13l-8-8 8-8H42v5h-7v-7h5V9l-8 8Zm-13-2-4 4h4v-4Zm0 34v-4h-4l4 4Zm26-34 4 4h-4v-4Zm4 30-4 4v-4h4Z" clip-rule="evenodd"/><path fill="url(#c3)" fill-rule="evenodd" d="M28 0 0 28V12L12 0h16ZM7 16l-3-3-3 3 3 3 3-3Zm3-9 3 3-3 3-3-3 3-3Zm9-3-3-3-3 3 3 3 3-3Zm13-2 6 6-6 6-6-6 6-6Zm0 3 3 3-3 3-3-3 3-3Zm24 21 6 6-6 6-6-6 6-6Zm0 3 3 3-3 3-3-3 3-3ZM35 56l-3-3-3 3 3 3 3-3Zm-3 6 6-6-6-6-6 6 6 6ZM8 26l6 6-6 6-6-6 6-6Zm0 3 3 3-3 3-3-3 3-3Zm14-7V12l-2 2v6h-6l-2 2h10Zm0 30V42H12l2 2h6v6l2 2Zm20-30V12l2 2v6h6l2 2H42Zm0 30V42h10l-2 2h-6v6l-2 2ZM0 36l28 28H12L0 52V36Zm4 15 3-3-3-3-3 3 3 3Zm9 3-3 3-3-3 3-3 3 3Zm3 9 3-3-3-3-3 3 3 3ZM36 0l28 28V12L52 0H36Zm21 16 3-3 3 3-3 3-3-3Zm-3-9-3 3 3 3 3-3-3-3Zm-9-3 3-3 3 3-3 3-3-3Zm7 60 12-12V36L36 64h16Zm8-13-3-3 3-3 3 3-3 3Zm-9 3 3 3 3-3-3-3-3 3Zm-3 9-3-3 3-3 3 3-3 3Z" clip-rule="evenodd"/>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c3)" fill-rule="evenodd" d="M54 14 64 4v6l-2 2v12l-8 8V14Zm0 18 8 8v12l2 2v6L54 50V32ZM0 60l10-10V14L0 4v6l2 2v12l8 8-8 8v12l-2 2v6Zm30-20h4v19l2-2v-6l7-7v9l-9 9v2h-4v-2l-9-9v-9l7 7v6l2 2V40Z" clip-rule="evenodd"/><path fill="url(#c2)" fill-rule="evenodd" d="m6 6 4 4 4-4-4-4-4 4Zm31.6434 7.5723L32 7.92893l-5.6434 5.64337-9.7304-1.9461 1.9461 9.7304L12.929 27l5.6433 5.6434-1.9461 9.7304 9.7304-1.9461L32 46.0711l5.6434-5.6434 9.4795 1.8959-1.6912-10.1474 6.1804-4.6352-6.1844-6.1844 1.9461-9.7304-9.7304 1.9461ZM24 31l-4-4 4-4-1-5 5 1 4-4 4 4 5-1-1 5 4 4-4 3 1 6-5-1-4 4-4-4-5 1 1-5Zm10-6h-4v4h4v-4ZM6 58l4-4 4 4-4 4-4-4Zm48-4-4 4 4 4 4-4-4-4Zm0-44-4-4 4-4 4 4-4 4Z" clip-rule="evenodd"/>',
        '<path fill="url(#c4)" d="M0 0h64v64H0z"/><path fill="url(#c3)" d="M32 0h32v64H32z"/><path fill="url(#c2)" fill-rule="evenodd" d="m29 29-9-9V5l9 9v15Zm-1 1-9-9H4l9 9h15Zm1 5-9 9v15l9-9V35Zm-1-1-9 9H4l9-9h15Zm4-6-4 4 4 4v-8ZM4 11l6 6 6-6-6-6-6 6Zm4 0 2 2 2-2-2-2-2 2Zm2 48-6-6 6-6 6 6-6 6Zm0-4-2-2 2-2 2 2-2 2Z" clip-rule="evenodd"/><path fill="url(#c4)" fill-rule="evenodd" d="m35 29 9-9V5l-9 9v15Zm1 1 9-9h15l-9 9H36Zm-1 5 9 9v15l-9-9V35Zm1-1 9 9h15l-9-9H36Zm-4-6 4 4-4 4v-8Zm16-17 6 6 6-6-6-6-6 6Zm4 0 2 2 2-2-2-2-2 2Zm8 42-6 6-6-6 6-6 6 6Zm-6 2-2-2 2-2 2 2-2 2Z" clip-rule="evenodd"/>',
        '<rect width="64" height="64" fill="url(#c2)"/><path fill-rule="evenodd" clip-rule="evenodd" d="M29 51.7765V37.0142L18.9007 47.1136C21.6957 49.5382 25.17 51.2004 29 51.7765ZM14.9954 42.5335L29 28.5289V12.2235C19.3775 13.6709 12 21.9739 12 32C12 35.8653 13.0965 39.4745 14.9954 42.5335ZM45.1068 47.107C42.3105 49.5352 38.8334 51.1999 35 51.7765V37.0002L45.1068 47.107ZM49.0099 42.5248L35 28.5149V12.2235C44.6225 13.671 52 21.9739 52 32C52 35.8617 50.9056 39.4677 49.0099 42.5248ZM58 32C58 46.3594 46.3594 58 32 58C17.6406 58 6 46.3594 6 32C6 17.6406 17.6406 6 32 6C46.3594 6 58 17.6406 58 32Z" fill="url(#c4)"/>'
    ];

    string[3][4] private backgrounds = [
        [
            '<pattern id="bp" width="64" height="64" patternUnits="userSpaceOnUse"><circle cx="32" cy="32" r="8" fill="transparent" stroke="url(#c1)" stroke-width="1" opacity=".6"/></pattern><filter id="bf"><feTurbulence type="fractalNoise" baseFrequency=".2" numOctaves="1" seed="',
            '"/><feDisplacementMap in="SourceGraphic" xChannelSelector="B" scale="200"/></filter><g filter="url(#bf)"><rect x="-50%" y="-50%" width="200%" height="200%" fill="url(#bp)">',
            "0,64"
        ],
        [
            '<pattern id="bp" width="128" height="128" patternUnits="userSpaceOnUse"><path d="m64 16 32 32H64V16ZM128 16l32 32h-32V16ZM0 16l32 32H0V16ZM128 76l-32 32h32V76ZM64 76l-32 32h32V76Z" fill="url(#c1)" style="mix-blend-mode:multiply" opacity=".05"/></pattern><filter id="bf"><feTurbulence type="fractalNoise" baseFrequency=".002" numOctaves="1" seed="',
            '"/><feDisplacementMap in="SourceGraphic" scale="100"/></filter><g filter="url(#bf)"><rect x="-50%" y="-50%" width="200%" height="200%" fill="url(#bp)">',
            "0,128"
        ],
        [
            '<pattern id="bp" width="64" height="64" patternUnits="userSpaceOnUse"><path d="M32 0L0 32V64L32 32L64 64V32L32 0Z" fill="url(#c1)" opacity=".05" style="mix-blend-mode:multiply"/></pattern><filter id="bf"><feTurbulence type="fractalNoise" baseFrequency=".004" numOctaves="1" seed="',
            '"/><feDisplacementMap in="SourceGraphic" scale="200"/></filter><g filter="url(#bf)"><rect x="-50%" y="-50%" width="200%" height="200%" fill="url(#bp)">',
            "-128,0"
        ],
        [
            '<pattern id="bp" width="80" height="40" patternUnits="userSpaceOnUse"><path d="M0 20a20 20 0 1 1 0 1M40 0a20 20 0 1 0 40 0m0 40a20 20 0 1 0 -40 0" fill="url(#c3)" opacity=".3" style="mix-blend-mode:screen"/></pattern><filter id="bf"><feTurbulence type="fractalNoise" baseFrequency=".02" numOctaves="1" seed="',
            '"/><feDisplacementMap in="SourceGraphic" scale="200"/></filter><g filter="url(#bf)"><rect x="-50%" y="-50%" width="200%" height="200%" fill="url(#bp)">',
            "0,-80"
        ]
    ];

    struct RandValues {
        uint256 x;
        uint256 y;
        uint256 roundness;
        uint256 theme;
        uint256 bg;
        uint256 cf;
        uint256 peacePatch;
        uint256 ppY;
    }

    function generateQuilt(uint256 seed) public view returns (Quilt memory) {

        string memory seedStr = Strings.toString(seed);
        Quilt memory quilt;
        RandValues memory rand;

        rand.x = random(seedStr, "X") % 100;
        rand.y = random(seedStr, "Y") % 100;

        if (rand.x < 1) {
            quilt.quiltW = 1;
        } else if (rand.x < 10) {
            quilt.quiltW = 2;
        } else if (rand.x < 60) {
            quilt.quiltW = 3;
        } else if (rand.x < 90) {
            quilt.quiltW = 4;
        } else {
            quilt.quiltW = 5;
        }

        if (quilt.quiltW == 1) {
            quilt.quiltH = 1;
        } else if (rand.y < 10) {
            quilt.quiltH = 2;
        } else if (rand.y < 60) {
            quilt.quiltH = 3;
        } else if (rand.y < 90) {
            quilt.quiltH = 4;
        } else {
            quilt.quiltH = 5;
        }

        if (quilt.quiltW == 2 && quilt.quiltH == 5) {
            quilt.quiltW = 3;
        }
        if (quilt.quiltH == 2 && quilt.quiltW == 5) {
            quilt.quiltH = 3;
        }

        quilt.totalPatchCount = quilt.quiltW * quilt.quiltH;

        quilt.totalPatchesAbsW = 64 * quilt.quiltW;
        quilt.totalPatchesAbsH = 64 * quilt.quiltH;
        quilt.quiltAbsW = quilt.totalPatchesAbsW + 24;
        quilt.quiltAbsH = quilt.totalPatchesAbsH + 24;

        rand.peacePatch = random(seedStr, "PEACE") % quilt.totalPatchCount;
        for (uint256 i = 0; i < quilt.totalPatchCount; i++) {
            quilt.patches[i] =
                random(seedStr, string(abi.encodePacked("P", i))) %
                (patches.length - 2);
            quilt.patches[rand.peacePatch] = patches.length - 1;
        }

        rand.roundness = random(seedStr, "R") % 100;
        if (rand.roundness < 70) {
            quilt.roundness = 8;
        } else if (rand.roundness < 90) {
            quilt.roundness = 16;
        } else {
            quilt.roundness = 0;
        }

        quilt.themeIndex = random(seedStr, "T") % 3;

        rand.bg = random(seedStr, "BG") % 100;
        if (rand.bg < 40) {
            quilt.backgroundIndex = 0;
        } else if (rand.bg < 60) {
            quilt.backgroundIndex = 1;
        } else if (rand.bg < 80) {
            quilt.backgroundIndex = 2;
        } else {
            quilt.backgroundIndex = 3;
        }

        rand.cf = random(seedStr, "CF") % 100;
        if (rand.cf < 40) {
            quilt.calmnessFactor = 1;
        } else if (rand.cf < 60) {
            quilt.calmnessFactor = 2;
        } else if (rand.cf < 80) {
            quilt.calmnessFactor = 3;
        } else {
            quilt.calmnessFactor = 4;
        }

        quilt.hovers = random(seedStr, "H") % 100 > 80;
        quilt.animatedBg = random(seedStr, "ABG") % 100 > 60;

        return quilt;
    }

    function _renderStitches(Quilt memory quilt)
        internal
        view
        returns (string memory renderedStitches)
    {

        for (uint256 i = 0; i < quilt.totalPatchCount; i++) {
            uint256 col = i % quilt.quiltW;
            uint256 row = i / quilt.quiltW;
            uint256 x = col * 64;
            uint256 y = row * 64;

            if (col + 1 == quilt.quiltW && row + 1 == quilt.quiltH) continue;

            string memory d = string(
                abi.encodePacked(
                    "M",
                    Strings.toString(x),
                    ",",
                    Strings.toString(y + 64),
                    " h64 v-64"
                )
            );

            if (col + 1 == quilt.quiltW) {
                d = string(
                    abi.encodePacked(
                        "M",
                        Strings.toString(x),
                        ",",
                        Strings.toString(y + 64),
                        " h64"
                    )
                );
            }

            if (row + 1 == quilt.quiltH) {
                d = string(
                    abi.encodePacked(
                        "M",
                        Strings.toString(x + 64),
                        ",",
                        Strings.toString(y),
                        " v64"
                    )
                );
            }

            renderedStitches = string(
                abi.encodePacked(
                    renderedStitches,
                    '<path d="',
                    d,
                    '" stroke="#',
                    colors[quilt.themeIndex][0],
                    '" stroke-width="2" stroke-dasharray="4 4" stroke-dashoffset="2" />'
                )
            );
        }

        renderedStitches = string(
            abi.encodePacked(
                '<g transform="translate(12 12)">',
                renderedStitches,
                '<rect width="',
                Strings.toString(quilt.totalPatchesAbsW),
                '" height="',
                Strings.toString(quilt.totalPatchesAbsH),
                '" rx="',
                Strings.toString(quilt.roundness),
                '" stroke="url(#c1)" stroke-width="2" stroke-dasharray="4 4" stroke-dashoffset="2"/></g>'
            )
        );
    }

    function _renderPatches(Quilt memory quilt)
        internal
        view
        returns (string memory renderedPatches)
    {

        for (uint256 i = 0; i < quilt.totalPatchCount; i++) {
            uint256 col = i % quilt.quiltW;
            uint256 row = i / quilt.quiltW;
            uint256 x = 64 * col;
            uint256 y = 64 * row;

            renderedPatches = string(
                abi.encodePacked(
                    renderedPatches,
                    '<g mask="url(#s',
                    Strings.toString(col),
                    Strings.toString(row),
                    ')"><g transform="translate(',
                    Strings.toString(x),
                    " ",
                    Strings.toString(y),
                    ')">',
                    patches[quilt.patches[i]],
                    "</g></g>"
                )
            );
        }
        renderedPatches = string(
            abi.encodePacked(
                '<g clip-path="url(#qs)" transform="translate(12 12)">',
                renderedPatches,
                "</g>"
            )
        );
    }

    function _renderPatchSlots(Quilt memory quilt)
        internal
        pure
        returns (string memory renderedSlots)
    {

        for (uint256 i = 0; i < quilt.totalPatchCount; i++) {
            uint256 col = i % quilt.quiltW;
            uint256 row = i / quilt.quiltW;
            uint256 x = 64 * col;
            uint256 y = 64 * row;

            renderedSlots = string(
                abi.encodePacked(
                    renderedSlots,
                    '<mask id="s',
                    Strings.toString(col),
                    Strings.toString(row),
                    '"><rect x="',
                    Strings.toString(x),
                    '" y="',
                    Strings.toString(y),
                    '" width="64" height="64" fill="white"/></mask>'
                )
            );
        }
    }

    function _renderDefs(Quilt memory quilt) internal view returns (string memory defs) {

        string memory theme = string(
            abi.encodePacked(
                '<linearGradient id="c1"><stop stop-color="#',
                colors[quilt.themeIndex][0],
                '"/></linearGradient><linearGradient id="c2"><stop stop-color="#',
                colors[quilt.themeIndex][1],
                '"/></linearGradient><linearGradient id="c3"><stop stop-color="#',
                colors[quilt.themeIndex][2],
                '"/></linearGradient><linearGradient id="c4"><stop stop-color="#',
                colors[quilt.themeIndex][3],
                '"/></linearGradient>'
            )
        );

        defs = string(
            abi.encodePacked(
                '<defs><clipPath id="qs"><rect rx="',
                Strings.toString(quilt.roundness),
                '" width="',
                Strings.toString(quilt.totalPatchesAbsW),
                '" height="',
                Strings.toString(quilt.totalPatchesAbsH),
                '"/></clipPath>',
                _renderPatchSlots(quilt),
                theme,
                "</defs>"
            )
        );
    }

    function _renderBackground(Quilt memory quilt, uint256 seed)
        internal
        view
        returns (string memory background)
    {

        background = string(
            abi.encodePacked(
                backgrounds[quilt.backgroundIndex][0],
                Strings.toString(seed),
                backgrounds[quilt.backgroundIndex][1],
                quilt.animatedBg
                    ? string(
                        abi.encodePacked(
                            '<animateTransform attributeName="transform" type="translate" dur="4s" values="0,0; ',
                            backgrounds[quilt.backgroundIndex][2],
                            ';" repeatCount="indefinite"/>'
                        )
                    )
                    : "",
                "</rect></g>"
            )
        );
    }

    function _renderShadow(Quilt memory quilt) internal pure returns (string memory shadow) {

        shadow = string(
            abi.encodePacked(
                '<g filter="url(#f)"><rect x="8" y="8" width="',
                Strings.toString(quilt.quiltAbsW),
                '" height="',
                Strings.toString(quilt.quiltAbsH),
                '" rx="',
                Strings.toString(quilt.roundness == 0 ? 0 : quilt.roundness + 12),
                '" fill="url(#c1)"/>',
                quilt.hovers
                    ? '<animateTransform attributeName="transform" type="scale" additive="sum" dur="4s" values="1 1; 1.005 1.02; 1 1;" calcMode="spline" keySplines="0.45, 0, 0.55, 1; 0.45, 0, 0.55, 1" repeatCount="indefinite"/>'
                    : "",
                "</g>"
            )
        );
    }

    function quiltImageSVGString(Quilt memory quilt, uint256 seed)
        public
        view
        returns (string memory svg)
    {

        string[8] memory svgParts;

        svgParts[0] = _renderDefs(quilt);

        svgParts[1] = _renderBackground(quilt, seed);

        svgParts[2] = string(
            abi.encodePacked(
                '<g transform="translate(',
                Strings.toString((500 - quilt.quiltAbsW) / 2),
                " ",
                Strings.toString((500 - quilt.quiltAbsH) / 2),
                ')">'
            )
        );

        svgParts[3] = _renderShadow(quilt);

        svgParts[4] = string(
            abi.encodePacked(
                '<rect x="0" y="0" width="',
                Strings.toString(quilt.quiltAbsW),
                '" height="',
                Strings.toString(quilt.quiltAbsH),
                '" rx="',
                Strings.toString(quilt.roundness == 0 ? 0 : quilt.roundness + 8),
                '" fill="url(#c3)" stroke="url(#c1)" stroke-width="2"/>'
            )
        );

        svgParts[5] = _renderPatches(quilt);

        svgParts[6] = _renderStitches(quilt);

        svg = string(
            abi.encodePacked(
                '<svg width="500" height="500" viewBox="0 0 500 500" fill="none" xmlns="http://www.w3.org/2000/svg">',
                svgParts[0], // Defs
                '<rect width="500" height="500" fill="url(#c4)" />',
                svgParts[1], // Main background
                '<filter id="f" x="-50%" y="-50%" width="200%" height="200%"><feTurbulence baseFrequency="',
                quilt.calmnessFactor * 3 >= 10 ? ".0" : ".00",
                Strings.toString(quilt.calmnessFactor * 3),
                '" seed="',
                Strings.toString(seed),
                '"/><feDisplacementMap in="SourceGraphic" scale="10"/></filter>',
                svgParts[2] // Quilt positioning
            )
        );

        svg = string(
            abi.encodePacked(
                svg,
                svgParts[3], // Quilt shadow
                '<g filter="url(#f)">',
                svgParts[4], // Quilt background
                svgParts[5], // Patches
                svgParts[6], // Patch stitches
                quilt.hovers
                    ? '<animateTransform attributeName="transform" type="translate" dur="4s" values="0,0; -4,-16; 0,0;" calcMode="spline" keySplines="0.45, 0, 0.55, 1; 0.45, 0, 0.55, 1" repeatCount="indefinite"/>'
                    : "",
                "</g></g></svg>"
            )
        );
    }

    function quiltMetadata(uint256 tokenId, uint256 seed)
        public
        view
        returns (string memory metadata)
    {

        Quilt memory quilt = generateQuilt(seed);
        string memory svg = quiltImageSVGString(quilt, seed);

        string[11] memory patchNames = [
            "Sunflower",
            "Vyshyvanka 1",
            "Vyshyvanka 2",
            "Vyshyvanka 3",
            "Vyshyvanka 4",
            "Vyshyvanka 5",
            "Vyshyvanka 6",
            "Vyshyvanka 7",
            "Vyshyvanka 8",
            "Vyshyvanka 9",
            "Peace"
        ];

        string[4] memory backgroundNames = ["Dusty", "Flags", "Electric", "Groovy"];

        string[4] memory calmnessNames = ["Serene", "Calm", "Wavey", "Chaotic"];

        string[3] memory roundnessNames = ["Straight", "Round", "Roundest"];

        string memory patchNamesList;
        for (uint256 i = 0; i < quilt.totalPatchCount; i++) {
            patchNamesList = string(
                abi.encodePacked(
                    patchNamesList,
                    '"',
                    patchNames[quilt.patches[i]],
                    '"',
                    i == (quilt.totalPatchCount) - 1 ? "" : ","
                )
            );
        }

        string memory attributes = string(
            abi.encodePacked(
                '[{"trait_type":"Background","value":"',
                backgroundNames[quilt.backgroundIndex],
                '"},{"trait_type":"Animated background","value":"',
                quilt.animatedBg ? "Yes" : "No",
                '"},{"trait_type":"Theme","value":"',
                colors[quilt.themeIndex][4],
                '"},{"trait_type":"Patches","value":[',
                patchNamesList,
                ']},{"trait_type":"Patch count","value":"',
                Strings.toString(quilt.totalPatchCount)
            )
        );

        attributes = string(
            abi.encodePacked(
                attributes,
                '"},{"trait_type":"Aspect ratio","value":"',
                Strings.toString(quilt.quiltW),
                ":",
                Strings.toString(quilt.quiltH),
                '"},{"trait_type":"Calmness","value":"',
                calmnessNames[quilt.calmnessFactor - 1],
                '"},{"trait_type":"Hovers","value":"',
                quilt.hovers ? "Yes" : "No",
                '"},{"trait_type":"Roundness","value":"',
                roundnessNames[quilt.roundness % 8],
                '"}]'
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"Quilt for Ukraine #',
                        Strings.toString(tokenId),
                        '","description":"Generative cozy quilt where all proceeds are donated to Ukraine.","attributes":',
                        attributes,
                        ',"image":"data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );

        metadata = string(abi.encodePacked("data:application/json;base64,", json));
    }

    function random(string memory seed, string memory key) internal pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked(key, seed)));
    }
}//Unlicense


pragma solidity ^0.8.10;


contract QuiltsForUkraine is ERC721BatchMinting, ReentrancyGuard, Ownable {


    uint256 public constant MIN_PRICE = 0.05 ether;
    uint256 public nextTokenId = 1;
    uint256 public seedFactor;
    bool public isSaleActive;
    IQuiltGeneratorUKR public quiltGenerator;

    struct Donation {
        address payee;
        uint256 share;
    }

    mapping(uint256 => Donation) public donationPayouts;
    uint256 public totalDonationPayees;
    uint256 public totalDonationShares;


    error SaleNotActive();
    error InsufficientBalance();
    error InvalidDonationConfiguration();
    error TransferFailed();


    function mint(uint256 numTokens) public payable virtual nonReentrant {

        if (msg.value < MIN_PRICE * numTokens) revert InsufficientBalance();
        if (!isSaleActive) revert SaleNotActive();

        if (numTokens == 1) {
            _safeMint(msg.sender, nextTokenId);
        } else {
            uint256[] memory ids = new uint256[](numTokens);
            for (uint256 i = 0; i < numTokens; ) {
                ids[i] = nextTokenId + i;
                unchecked {
                    i++;
                }
            }
            _safeMintBatch(msg.sender, ids);
        }

        unchecked {
            nextTokenId += numTokens;
        }
    }


    function addDonationAddress(address payee, uint256 share) public onlyOwner {

        totalDonationPayees++;
        donationPayouts[totalDonationPayees] = Donation(payee, share);
        totalDonationShares += share;
    }

    function editDonationShares(uint256 id, uint256 newShare) public onlyOwner {

        Donation storage payout = donationPayouts[id];
        payout.share = newShare;
        totalDonationShares = totalDonationShares - payout.share + newShare;
    }

    function _payAddress(address to, uint256 amount) internal {

        (bool success, ) = payable(to).call{value: amount}(new bytes(0));
        if (!success) revert TransferFailed();
    }

    function donateProceeds() external {

        uint256 balance = address(this).balance;
        for (uint256 i = 1; i <= totalDonationPayees; i++) {
            if (donationPayouts[i].share > 0) {
                _payAddress(
                    donationPayouts[i].payee,
                    (balance * donationPayouts[i].share) / totalDonationShares
                );
            }
        }
    }


    function toggleSale() external onlyOwner {

        isSaleActive = !isSaleActive;
    }

    function setOpenSeaGasFreeListing(bool enabled) external onlyOwner {

        openSeaGasFreeListingEnabled = enabled;
    }


    function totalSupply() public view returns (uint256) {

        return nextTokenId - 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        if (ownerOf(tokenId) == address(0)) revert NonExistent();
        return quiltGenerator.quiltMetadata(tokenId, seedFactor * tokenId);
    }

    constructor(
        address _quiltGenerator,
        uint256 _seedFactor,
        address _govAddress,
        address _daoAddress
    ) ERC721("Quilts for Ukraine", "QLTUKR") {
        quiltGenerator = IQuiltGeneratorUKR(_quiltGenerator);
        seedFactor = _seedFactor;
        addDonationAddress(_govAddress, 50_00); // 0x165CD37b4C644C2921454429E7F9358d18A45e14
        addDonationAddress(_daoAddress, 50_00); // 0x633b7218644b83D57d90e7299039ebAb19698e9C
    }
}