pragma solidity >=0.8.0;

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }


    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;


library SafeTransferLib {

    event Debug(bool one, bool two, uint256 retsize);


    function safeTransferETH(address to, uint256 amount) internal {

        bool success;

        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
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
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);


    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }


    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }


    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

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
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }


    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }


    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

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

abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    function toHexString(address addr) internal pure returns (string memory) {

        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}//MIT
pragma solidity ^0.8.12;

library utils {

    string internal constant NULL = '';

    function setCssVar(string memory _key, string memory _val)
        internal
        pure
        returns (string memory)
    {

        return string.concat('--', _key, ':', _val, ';');
    }

    function getCssVar(string memory _key)
        internal
        pure
        returns (string memory)
    {

        return string.concat('var(--', _key, ')');
    }

    function getDefURL(string memory _id)
        internal
        pure
        returns (string memory)
    {

        return string.concat('url(#', _id, ')');
    }

    function white_a(uint256 _a) internal pure returns (string memory) {

        return rgba(255, 255, 255, _a);
    }

    function black_a(uint256 _a) internal pure returns (string memory) {

        return rgba(0, 0, 0, _a);
    }

    function rgba(
        uint256 _r,
        uint256 _g,
        uint256 _b,
        uint256 _a
    ) internal pure returns (string memory) {

        string memory formattedA = _a < 100
            ? string.concat('0.', utils.uint2str(_a))
            : '1';
        return
            string.concat(
                'rgba(',
                utils.uint2str(_r),
                ',',
                utils.uint2str(_g),
                ',',
                utils.uint2str(_b),
                ',',
                formattedA,
                ')'
            );
    }

    function stringsEqual(string memory _a, string memory _b)
        internal
        pure
        returns (bool)
    {

        return
            keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    function utfStringLength(string memory _str)
        internal
        pure
        returns (uint256 length)
    {

        uint256 i = 0;
        bytes memory string_rep = bytes(_str);

        while (i < string_rep.length) {
            if (string_rep[i] >> 7 == 0) i += 1;
            else if (string_rep[i] >> 5 == bytes1(uint8(0x6))) i += 2;
            else if (string_rep[i] >> 4 == bytes1(uint8(0xE))) i += 3;
            else if (string_rep[i] >> 3 == bytes1(uint8(0x1E)))
                i += 4;
            else i += 1;

            length++;
        }
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return '0';
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}//MIT
pragma solidity ^0.8.12;

library svg {

    function g(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('g', _props, _children);
    }

    function path(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('path', _props, _children);
    }

    function text(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('text', _props, _children);
    }

    function line(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('line', _props, _children);
    }

    function circle(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('circle', _props, _children);
    }

    function circle(string memory _props)
        internal
        pure
        returns (string memory)
    {

        return el('circle', _props);
    }

    function rect(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('rect', _props, _children);
    }

    function rect(string memory _props)
        internal
        pure
        returns (string memory)
    {

        return el('rect', _props);
    }

    function filter(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('filter', _props, _children);
    }

    function cdata(string memory _content)
        internal
        pure
        returns (string memory)
    {

        return string.concat('<![CDATA[', _content, ']]>');
    }

    function radialGradient(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('radialGradient', _props, _children);
    }

    function linearGradient(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {

        return el('linearGradient', _props, _children);
    }

    function gradientStop(
        uint256 offset,
        string memory stopColor,
        string memory _props
    ) internal pure returns (string memory) {

        return
            el(
                'stop',
                string.concat(
                    prop('stop-color', stopColor),
                    ' ',
                    prop('offset', string.concat(utils.uint2str(offset), '%')),
                    ' ',
                    _props
                )
            );
    }

    function animateTransform(string memory _props)
        internal
        pure
        returns (string memory)
    {

        return el('animateTransform', _props);
    }

    function image(string memory _href, string memory _props)
        internal
        pure
        returns (string memory)
    {

        return
            el(
                'image',
                string.concat(prop('href', _href), ' ', _props)
            );
    }

    function el(
        string memory _tag,
        string memory _props,
        string memory _children
    ) internal pure returns (string memory) {

        return
            string.concat(
                '<',
                _tag,
                ' ',
                _props,
                '>',
                _children,
                '</',
                _tag,
                '>'
            );
    }

    function el(
        string memory _tag,
        string memory _props
    ) internal pure returns (string memory) {

        return
            string.concat(
                '<',
                _tag,
                ' ',
                _props,
                '/>'
            );
    }

    function prop(string memory _key, string memory _val)
        internal
        pure
        returns (string memory)
    {

        return string.concat(_key, '=', '"', _val, '" ');
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
pragma solidity 0.8.13;


abstract contract CallyNft is ERC721("Cally", "CALL") {
    function _mint(address to, uint256 id) internal override {
        require(to != address(0), "INVALID_RECIPIENT");
        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal override {
        address owner = _ownerOf[id];

        delete _ownerOf[id];
        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    function balanceOf(address owner) public pure override returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");
        return type(uint256).max;
    }

    function _forceTransfer(address to, uint256 id) internal {
        require(to != address(0), "INVALID_RECIPIENT");

        address from = _ownerOf[id];
        _ownerOf[id] = to;
        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function renderJson(
        address token_,
        uint256 tokenIdOrAmount_,
        uint256 premium_,
        uint256 durationDays_,
        uint256 dutchAuctionStartingStrike_,
        uint256 currentExpiration_,
        uint256 currentStrike_,
        bool isExercised_,
        bool isVault_
    ) public pure returns (string memory) {
        string memory token = addressToString(token_);
        string memory tokenIdOrAmount = Strings.toString(tokenIdOrAmount_);
        string memory premium = Strings.toString(premium_);
        string memory durationDays = Strings.toString(durationDays_);
        string memory dutchAuctionStartingStrike = Strings.toString(dutchAuctionStartingStrike_);
        string memory currentExpiration = Strings.toString(currentExpiration_);
        string memory currentStrike = Strings.toString(currentStrike_);
        string memory isExercised = Strings.toString(isExercised_ ? 1 : 0);
        string memory nftType = isVault_ ? "Vault" : "Option";

        string memory svgStr = renderSvg(
            token,
            tokenIdOrAmount,
            premium,
            durationDays,
            dutchAuctionStartingStrike,
            currentExpiration,
            currentStrike,
            isExercised,
            nftType
        );

        string memory json = string.concat(
            '{"name":"',
            "Cally",
            '","description":"',
            "NFT and ERC20 covered call vaults",
            '","image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(svgStr)),
            '","attributes": [',
            '{ "trait_type": "token",',
            '"value": "',
            token,
            '"},',
            '{ "trait_type": "tokenIdOrAmount",',
            '"value": "',
            tokenIdOrAmount,
            '"},',
            '{ "trait_type": "premium",',
            '"value": "',
            premium,
            '"},',
            '{ "trait_type": "durationDays",',
            '"value": "',
            durationDays,
            '"},',
            '{ "trait_type": "dutchAuctionStartingStrike",',
            '"value": "',
            dutchAuctionStartingStrike,
            '"},',
            '{ "trait_type": "currentExpiration",',
            '"value": "',
            currentExpiration,
            '"},',
            '{ "trait_type": "currentStrike",',
            '"value": "',
            currentStrike,
            '"},',
            '{ "trait_type": "isExercised",',
            '"value": "',
            isExercised,
            '"},',
            '{ "trait_type": "nftType",',
            '"value": "',
            nftType,
            '"}',
            "]}"
        );

        return json;
    }

    function renderSvg(
        string memory token,
        string memory tokenIdOrAmount,
        string memory premium,
        string memory durationDays,
        string memory dutchAuctionStartingStrike,
        string memory currentExpiration,
        string memory currentStrike,
        string memory isExercised,
        string memory nftType
    ) public pure returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="350" height="350" style="background:#000">',
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "20"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Token: "), token)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "40"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Token ID or Amount: "), tokenIdOrAmount)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "60"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Premium (WEI): "), premium)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "80"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Duration (days): "), durationDays)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "100"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Starting strike (WEI): "), dutchAuctionStartingStrike)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "120"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Expiration (UNIX): "), currentExpiration)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "140"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Strike (WEI): "), currentStrike)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "160"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Exercised (y/n): "), isExercised)
                ),
                svg.text(
                    string.concat(
                        svg.prop("x", "10"),
                        svg.prop("y", "180"),
                        svg.prop("font-size", "12"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Type: "), nftType)
                ),
                "</svg>"
            );
    }

    function addressToString(address account) public pure returns (string memory) {
        bytes memory data = abi.encodePacked(account);

        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }

        return string(str);
    }
}// MIT
pragma solidity 0.8.13;




contract Cally is CallyNft, ReentrancyGuard, Ownable, ERC721TokenReceiver {

    using SafeTransferLib for ERC20;
    using SafeTransferLib for address payable;

    event NewVault(uint256 indexed vaultId, address indexed from, address indexed token);

    event BoughtOption(uint256 indexed optionId, address indexed from, address indexed token);

    event ExercisedOption(uint256 indexed optionId, address indexed from);

    event Harvested(address indexed from, uint256 amount);

    event InitiatedWithdrawal(uint256 indexed vaultId, address indexed from);

    event Withdrawal(uint256 indexed vaultId, address indexed from);

    event SetFee(uint256 indexed newFee);

    event SetVaultBeneficiary(uint256 indexed vaultId, address indexed from, address indexed to);

    enum TokenType {
        ERC721,
        ERC20
    }

    struct Vault {
        uint256 tokenIdOrAmount;
        address token;
        uint8 premiumIndex; // indexes into `premiumOptions`
        uint8 durationDays; // days
        uint8 dutchAuctionStartingStrikeIndex; // indexes into `strikeOptions`
        uint32 currentExpiration;
        bool isExercised;
        bool isWithdrawing;
        TokenType tokenType;
        uint16 feeRate;
        uint256 currentStrike;
        uint256 dutchAuctionReserveStrike;
    }

    uint32 public constant AUCTION_DURATION = 24 hours;

    uint256[17] public premiumOptions = [0.01 ether, 0.025 ether, 0.05 ether, 0.075 ether, 0.1 ether, 0.25 ether, 0.5 ether, 0.75 ether, 1.0 ether, 2.5 ether, 5.0 ether, 7.5 ether, 10 ether, 25 ether, 50 ether, 75 ether, 100 ether];
    uint256[19] public strikeOptions = [1 ether, 2 ether, 3 ether, 5 ether, 8 ether, 13 ether, 21 ether, 34 ether, 55 ether, 89 ether, 144 ether, 233 ether, 377 ether, 610 ether, 987 ether, 1597 ether, 2584 ether, 4181 ether, 6765 ether];

    uint16 public feeRate = 0;
    uint256 public protocolUnclaimedFees;

    uint256 public vaultIndex = 1;

    mapping(uint256 => Vault) private _vaults;

    mapping(uint256 => address) private _vaultBeneficiaries;

    mapping(address => uint256) public ethBalance;


    function setFee(uint16 feeRate_) external payable onlyOwner {

        require(feeRate_ <= 300, "Fee cannot be larger than 30%");

        feeRate = feeRate_;

        emit SetFee(feeRate_);
    }

    function withdrawProtocolFees() external payable onlyOwner returns (uint256 amount) {

        amount = protocolUnclaimedFees;
        protocolUnclaimedFees = 0;

        emit Harvested(msg.sender, amount);

        payable(msg.sender).safeTransferETH(amount);
    }

    function selfHarvest() external payable onlyOwner returns (uint256 amount) {

        amount = ethBalance[address(this)];
        ethBalance[address(this)] = 0;

        emit Harvested(address(this), amount);

        payable(msg.sender).safeTransferETH(amount);
    }


    function createVaults(
        uint256[] memory tokenIdOrAmounts,
        address[] memory tokens,
        uint8[] memory premiumIndexes,
        uint8[] memory durationDays,
        uint8[] memory dutchAuctionStartingStrikeIndexes,
        uint256[] memory dutchAuctionReserveStrikes,
        TokenType[] memory tokenTypes
    ) external returns (uint256[] memory vaultIds) {

        vaultIds = new uint256[](tokenIdOrAmounts.length);

        for (uint256 i = 0; i < tokenIdOrAmounts.length; i++) {
            uint256 vaultId = createVault(
                tokenIdOrAmounts[i],
                tokens[i],
                premiumIndexes[i],
                durationDays[i],
                dutchAuctionStartingStrikeIndexes[i],
                dutchAuctionReserveStrikes[i],
                tokenTypes[i]
            );

            vaultIds[i] = vaultId;
        }
    }


    function createVault(
        uint256 tokenIdOrAmount,
        address token,
        uint8 premiumIndex,
        uint8 durationDays,
        uint8 dutchAuctionStartingStrikeIndex,
        uint256 dutchAuctionReserveStrike,
        TokenType tokenType
    ) public returns (uint256 vaultId) {

        require(premiumIndex < premiumOptions.length, "Invalid premium index");
        require(dutchAuctionStartingStrikeIndex < strikeOptions.length, "Invalid strike index");
        require(dutchAuctionReserveStrike < strikeOptions[dutchAuctionStartingStrikeIndex], "Reserve strike too large");
        require(durationDays > 0, "durationDays too small");
        require(token.code.length > 0, "token is not contract");
        require(token != address(this), "token cannot be Cally contract");
        require(tokenType == TokenType.ERC721 || tokenIdOrAmount > 0, "tokenIdOrAmount is 0");

        unchecked {
            vaultIndex = vaultIndex + 2;
        }
        vaultId = vaultIndex;

        Vault storage vault = _vaults[vaultId];

        vault.token = token;
        vault.premiumIndex = premiumIndex;
        vault.durationDays = durationDays;
        vault.dutchAuctionStartingStrikeIndex = dutchAuctionStartingStrikeIndex;
        vault.currentExpiration = uint32(block.timestamp);
        vault.tokenType = tokenType;

        if (feeRate > 0) {
            vault.feeRate = feeRate;
        }

        if (dutchAuctionReserveStrike > 0) {
            vault.dutchAuctionReserveStrike = dutchAuctionReserveStrike;
        }

        _mint(msg.sender, vaultId);

        emit NewVault(vaultId, msg.sender, token);

        if (tokenType == TokenType.ERC721) {
            vault.tokenIdOrAmount = tokenIdOrAmount;
            ERC721(token).safeTransferFrom(msg.sender, address(this), tokenIdOrAmount);
        } else {
            uint256 balanceBefore = ERC20(token).balanceOf(address(this));
            ERC20(token).safeTransferFrom(msg.sender, address(this), tokenIdOrAmount);
            vault.tokenIdOrAmount = ERC20(token).balanceOf(address(this)) - balanceBefore;
        }
    }

    function buyOption(uint256 vaultId) external payable returns (uint256 optionId) {

        require(vaultId % 2 != 0, "Not vault type");

        require(ownerOf(vaultId) != address(0), "Vault does not exist");

        Vault storage vault = _vaults[vaultId];

        require(!vault.isExercised, "Vault already exercised");

        require(!vault.isWithdrawing, "Vault is being withdrawn");

        uint256 premium = premiumOptions[vault.premiumIndex];
        require(msg.value == premium, "Incorrect ETH amount sent");

        uint32 auctionStartTimestamp = vault.currentExpiration;
        require(block.timestamp >= auctionStartTimestamp, "Auction not started");

        vault.currentStrike = getDutchAuctionStrike(
            strikeOptions[vault.dutchAuctionStartingStrikeIndex],
            auctionStartTimestamp + AUCTION_DURATION,
            vault.dutchAuctionReserveStrike
        );

        vault.currentExpiration = uint32(block.timestamp) + uint32(vault.durationDays) * 1 days;

        optionId = vaultId + 1;
        _forceTransfer(msg.sender, optionId);

        address beneficiary = getVaultBeneficiary(vaultId);
        ethBalance[beneficiary] += msg.value;

        emit BoughtOption(optionId, msg.sender, vault.token);
    }

    function exercise(uint256 optionId) external payable {

        require(optionId % 2 == 0, "Not option type");

        require(msg.sender == ownerOf(optionId), "You are not the owner");

        uint256 vaultId = optionId - 1;
        Vault storage vault = _vaults[vaultId];

        require(block.timestamp < vault.currentExpiration, "Option has expired");

        require(msg.value == vault.currentStrike, "Incorrect ETH sent for strike");

        _burn(optionId);

        vault.isExercised = true;

        uint256 fee = 0;
        if (vault.feeRate > 0) {
            fee = (msg.value * vault.feeRate) / 1000;
            protocolUnclaimedFees += fee;
        }

        ethBalance[getVaultBeneficiary(vaultId)] += msg.value - fee;

        emit ExercisedOption(optionId, msg.sender);

        vault.tokenType == TokenType.ERC721
            ? ERC721(vault.token).safeTransferFrom(address(this), msg.sender, vault.tokenIdOrAmount)
            : ERC20(vault.token).safeTransfer(msg.sender, vault.tokenIdOrAmount);
    }

    function initiateWithdraw(uint256 vaultId) external {

        require(vaultId % 2 != 0, "Not vault type");

        require(msg.sender == ownerOf(vaultId), "You are not the owner");

        require(!_vaults[vaultId].isWithdrawing, "Vault is already withdrawing");

        _vaults[vaultId].isWithdrawing = true;

        emit InitiatedWithdrawal(vaultId, msg.sender);
    }

    function withdraw(uint256 vaultId) external nonReentrant {

        require(vaultId % 2 != 0, "Not vault type");

        require(msg.sender == ownerOf(vaultId), "You are not the owner");

        Vault storage vault = _vaults[vaultId];

        require(!vault.isExercised, "Vault already exercised");
        require(vault.isWithdrawing, "Vault not in withdrawable state");
        require(block.timestamp > vault.currentExpiration, "Option still active");

        uint256 optionId = vaultId + 1;
        _burn(optionId);
        _burn(vaultId);

        emit Withdrawal(vaultId, msg.sender);

        harvest();

        vault.tokenType == TokenType.ERC721
            ? ERC721(vault.token).safeTransferFrom(address(this), msg.sender, vault.tokenIdOrAmount)
            : ERC20(vault.token).safeTransfer(msg.sender, vault.tokenIdOrAmount);
    }

    function setVaultBeneficiary(uint256 vaultId, address beneficiary) external {

        require(vaultId % 2 != 0, "Not vault type");
        require(msg.sender == ownerOf(vaultId), "Not owner");

        _vaultBeneficiaries[vaultId] = beneficiary;

        emit SetVaultBeneficiary(vaultId, msg.sender, beneficiary);
    }

    function harvest() public returns (uint256 amount) {

        amount = ethBalance[msg.sender];
        ethBalance[msg.sender] = 0;

        emit Harvested(msg.sender, amount);

        payable(msg.sender).safeTransferETH(amount);
    }


    function getVaultBeneficiary(uint256 vaultId) public view returns (address beneficiary) {

        address currentBeneficiary = _vaultBeneficiaries[vaultId];

        beneficiary = currentBeneficiary == address(0) ? ownerOf(vaultId) : currentBeneficiary;
    }

    function vaults(uint256 vaultId) external view returns (Vault memory) {

        return _vaults[vaultId];
    }

    function getDutchAuctionStrike(
        uint256 startingStrike,
        uint32 auctionEndTimestamp,
        uint256 reserveStrike
    ) public view returns (uint256 strike) {

        uint256 delta = auctionEndTimestamp > block.timestamp ? auctionEndTimestamp - block.timestamp : 0;
        uint256 progress = (1e18 * delta) / AUCTION_DURATION;
        strike = (((progress * progress * (startingStrike - reserveStrike)) / 1e18) / 1e18) + reserveStrike;
    }


    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {

        require(from == _ownerOf[id], "WRONG_FROM");
        require(to != address(0), "INVALID_RECIPIENT");
        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        bool isVaultToken = id % 2 != 0;
        if (isVaultToken) {
            _vaultBeneficiaries[id] = address(0);
        }

        _ownerOf[id] = to;
        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_ownerOf[tokenId] != address(0), "URI query for NOT_MINTED token");

        bool isVaultToken = tokenId % 2 != 0;
        uint256 vaultId = isVaultToken ? tokenId : tokenId - 1;
        Vault memory vault = _vaults[vaultId];

        string memory jsonStr = renderJson(
            vault.token,
            vault.tokenIdOrAmount,
            premiumOptions[vault.premiumIndex],
            vault.durationDays,
            strikeOptions[vault.dutchAuctionStartingStrikeIndex],
            vault.currentExpiration,
            vault.currentStrike,
            vault.isExercised,
            isVaultToken
        );

        return string.concat("data:application/json;base64,", Base64.encode(bytes(jsonStr)));
    }
}