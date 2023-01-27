pragma solidity 0.8.10;

abstract contract ERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);


    mapping(address => uint256) public balanceOf;

    mapping(uint256 => address) public ownerOf;

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }


    function approve(address spender, uint256 id) public virtual {
        address owner = ownerOf[id];

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
        require(from == ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        unchecked {
            balanceOf[from]--;

            balanceOf[to]++;
        }

        ownerOf[id] = to;

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
        bytes memory data
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

        require(ownerOf[id] == address(0), "ALREADY_MINTED");

        unchecked {
            balanceOf[to]++;
        }

        ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        unchecked {
            balanceOf[owner]--;
        }

        delete ownerOf[id];

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

interface ERC721TokenReceiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4);

}
abstract contract ERC2981 {

    uint256 internal _royaltyFee;
    address internal _royaltyRecipient;

    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual returns (
        address receiver,
        uint256 royaltyAmount
    ) {
        receiver = _royaltyRecipient;
        royaltyAmount = (salePrice * _royaltyFee) / 10000;
    }

    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x2a55205a; // ERC165 Interface ID for ERC2981
    }

}
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
}

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
}



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



library Base64 {

    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return "";

        string memory table = _TABLE;

        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            let tablePtr := add(table, 1)

            let resultPtr := add(result, 32)

            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)


                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}


interface IFrank {

    function ownerOf(uint256 tokenId) external view returns (address owner);

}


contract FrankLoot is ERC721, ERC2981 {

    using Strings for uint256;

    uint256 public pricePerFrank = 0.042069 ether;
    address public owner;

    IFrank public immutable frank = IFrank(0x91680cF5F9071cafAE21B90ebf2c9CC9e480fB93);

    uint256 public SEED;

    string[] private franks = [
        "frank",
        "frank",
        "frank",
        "FRANK",
        "frank ", 
        "FRANK ",
        "frank",
        "frank",
        "frank",
        "FRANK",
        "frank ", 
        "FRANK ",
        "frank",
        "frank",
        "frank",
        "FRANK",
        "frank ", 
        "FRANK ",
        "frank",
        "frank",
        "frank",
        "FRANK",
        "frank ", 
        "FRANK ",
        unicode"f̶̝̊̒r̶̙̄͠a̵͍̺̖̾͊͝ǹ̸̘̖̄̀k̶̬̙̲͊͋",
        unicode"F̴̥̬̃͋̆R̵͋̿͒ͅÄ̴̡͈͜͠Ṇ̶͕͈̀K̵̹͚̏̂",
        unicode"F̶͕̾R̸̬͐A̶͇̒N̷̢̆K̶̮͗",
        unicode"f̵͎̦̠̻̮͍̝̍́́̎̐͋͊̂̾̈̀͊̑̚ŗ̸̱̺̹͖̱̫͉̺͎̆̏̅̕͜ą̴̡̡̫̞̻͎̲͚̯̗̭̬̺̼̒͂̓̊͝n̸̢̼̖̦̗̐̈́̂͌̽̆́̋̂͑͝ͅk̴̛̛̥̻͖͉͚͔̊̉̾̆̈̏̈́̈͜ ",
        unicode"F̵̰͎̣̩̮̰̗͈̥͍͔͖͕͆̆́̏̚͜͝Ȓ̷̞͔͚̦̽̂̂̒̚͝A̴̱̺͚͙͖̹̞̲̘͒͊͑̄͒̓͒̓̀͂̋̐͂̔͘N̵͈̟̺̼̮̯̟̩͗̆̇̾͐̈̓̾̔͋̑̈͆Ḱ̷̡̢͉̜̟͖̣̝̥̗̰̙̬̥̻̈̿̀̉̆̈̇͂̓́͠ "
    ];

    string[] private shakes = [
        '<animateTransform attributeName="transform" attributeType="XML" type="scale" from="1 1" to="0 1" dur="1s" repeatCount="indefinite"/>',
        '<animateTransform attributeName="transform" attributeType="XML" type="scale" from="1 1" to="2 2" dur="1s" repeatCount="indefinite"/>',
        '<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0" to="-2" dur="0.1s" repeatCount="indefinite"/>',
        '<animateTransform attributeName="transform" attributeType="XML" type="translate" from="0 0" to="-5 4" dur="0.1s" repeatCount="indefinite"/>',
        '<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 0 0" to="45 45 500" dur="2s" repeatCount="indefinite" />',
        '<animate attributeName="opacity" dur="0.25s" keyTimes="0;0.1;0.5;0.6;1" values="0;1;1;0;0" repeatCount="indefinite" />'
    ];



    constructor()
    ERC721("frankLoot", "FRANKLOOT") {
        _royaltyFee = 700;
        _royaltyRecipient = msg.sender;
        SEED = random(block.timestamp.toString());
        owner = msg.sender;
    }


    modifier requiresAuth() {

        require(owner == msg.sender, "FRANKLY_NOT_ALLOWED");
        _;
    }

    function setPrice(uint256 newPrice) requiresAuth public {

        pricePerFrank = newPrice;
    }

    function setRoyaltyRecipient(address recipient) requiresAuth public {

        _royaltyRecipient = recipient;
    }

    function setRoyaltyFee(uint256 fee) requiresAuth public {

        _royaltyFee = fee;
    }


    function random(string memory input) internal view returns (uint256) {

        return uint256(keccak256(abi.encodePacked(SEED, input)));
    }

    function franksPerLine(uint256 _tokenId, uint256 _line) internal view returns (uint256) {

        uint256 rand = random(string(abi.encodePacked(SEED, _tokenId.toString())));
        uint256 greatness = rand % 21;

        if (greatness > 12) {
            return random(string(abi.encodePacked(_line.toString(), _tokenId.toString()))) % 7 + 1;
        } else {
            return 1;
        }

    }

    function getLine(uint256 tokenId, uint256 line) internal view returns (string memory) {

        uint256 franksThisLine = franksPerLine(tokenId, line);
        uint256 greatness = random(string(abi.encodePacked(SEED, tokenId.toString()))) % 21;

        string memory output;

        for(uint256 i = 0; i < franksThisLine; i++) {
            uint256 rand = random(string(abi.encodePacked(SEED, i, line, tokenId.toString())));
            if (greatness > 14) {
                output = string(abi.encodePacked(output, franks[rand % franks.length]));
            } else {
                output = string(abi.encodePacked(output, franks[rand % 24]));
            }
            
        }

        uint256 shakeRand = random(string(abi.encodePacked(SEED, line, tokenId.toString())));
        uint256 shakeGreatness = shakeRand % 21;
        if(shakeGreatness > 17) {
            output = string(abi.encodePacked(output, shakes[shakeRand % shakes.length]));
        }

        return output;
    }


    function mintWithFrank(uint256 frankId) public {

        require(frankId >= 0 && frankId < 2000, "FRANKLY_INVALID");
        require(frank.ownerOf(frankId) == msg.sender, "FRANKLY_NOT_YOURS");
        _safeMint(msg.sender, frankId);
    }

    function mintWithFrank(uint256[] memory frankId) public {

        uint256 frankfranks = frankId.length;
        for (uint256 i = 0; i < frankfranks; i++) {
            require(frankId[i] >= 0 && frankId[i] < 2000, "FRANKLY_INVALID");
            require(frank.ownerOf(frankId[i]) == msg.sender, "FRANKLY_NOT_YOURS");
           _safeMint(msg.sender, frankId[i]);
        }
    }

    function franklessMint(uint256 frankId) public payable {

        require(msg.value >= pricePerFrank, "FRANKLY_TOO_CHEAP");
        require(frankId >= 2000 && frankId < 4000, "FRANKLY_INVALID");
        _safeMint(msg.sender, frankId);
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        string[25] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = getLine(tokenId, 1);

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = getLine(tokenId, 2);

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = getLine(tokenId, 3);

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = getLine(tokenId, 4);

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = getLine(tokenId, 5);

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = getLine(tokenId, 6);

        parts[12] = '</text><text x="10" y="140" class="base">';

        parts[13] = getLine(tokenId, 7);

        parts[14] = '</text><text x="10" y="160" class="base">';

        parts[15] = getLine(tokenId, 8);

        parts[16] = '</text><text x="10" y="180" class="base">';

        parts[17] = getLine(tokenId, 9);

        parts[18] = '</text><text x="10" y="200" class="base">';

        parts[19] = getLine(tokenId, 10);

        parts[20] = '</text><text x="10" y="220" class="base">';

        parts[21] = getLine(tokenId, 11);

        parts[22] = '</text><text x="10" y="240" class="base">';

        parts[23] = getLine(tokenId, 12);

        parts[24] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8])
        );
        output = string(
            abi.encodePacked(
                output,
                parts[9],
                parts[10],
                parts[11],
                parts[12],
                parts[13],
                parts[14],
                parts[15],
                parts[16]
            )
        );

                output = string(
            abi.encodePacked(
                output,
                parts[17], 
                parts[18],
                parts[19],
                parts[20],
                parts[21],
                parts[22],
                parts[23],
                parts[24]
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "frankfrank #',
                        tokenId.toString(),
                        '", "description": "frankfrankFRANKFRANKFRANK FRANKfrankFRANK frankfrankFRANKfrank frankFRANKfrank frankFRANK FRANKfrank FRANKfrankFRANK frankfrankfrank frankFRANKfrankFRANKfrankFRANK frankFRANK FRANKfrankfrank frankfrankfrankFRANK frank FRANKfrank FRANK frankfrankFRANK frankFRANKfrank frank FRANK FRANKFRANKFRANK FRANKFRANKfrank frank FRANK frankfrankfrankfrank frank frankFRANKfrank", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(abi.encodePacked("data:application/json;base64,", json));

        return output;
    }

    function supportsInterface(bytes4 interfaceId) public pure override(ERC721, ERC2981) returns (bool) {

        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC721Metadata
            ERC2981.supportsInterface(interfaceId);
    }
}