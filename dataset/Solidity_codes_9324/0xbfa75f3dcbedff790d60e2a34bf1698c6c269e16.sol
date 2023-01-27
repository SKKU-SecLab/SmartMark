
pragma solidity >=0.8.12;

abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
} /// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

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


    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
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

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

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
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_SIGNER"
            );

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
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
} // OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {

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
} /// @title Interface for verifying contract-based account signatures

interface IERC1271 {

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        returns (bytes4 magicValue);

}


library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
}

library Signature {

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ODYSSEY: INVALID_SIGNATURE_S_VALUE"
        );
        require(v == 27 || v == 28, "ODYSSEY: INVALID_SIGNATURE_V_VALUE");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ODYSSEY: INVALID_SIGNATURE");

        return signer;
    }

    function verify(
        bytes32 hash,
        address signer,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 domainSeparator
    ) internal view {

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, hash)
        );
        if (Address.isContract(signer)) {
            require(
                IERC1271(signer).isValidSignature(
                    digest,
                    abi.encodePacked(r, s, v)
                ) == 0x1626ba7e,
                "ODYSSEY: UNAUTHORIZED"
            );
        } else {
            require(
                recover(digest, v, r, s) == signer,
                "ODYSSEY: UNAUTHORIZED"
            );
        }
    }
} // OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/MerkleProof.sol)

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf)
        internal
        pure
        returns (bytes32)
    {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b)
        private
        pure
        returns (bytes32 value)
    {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

library MerkleWhiteList {

    function verify(
        address sender,
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot
    ) internal pure {

        require(address(0) != sender);
        bytes32 leaf = keccak256(abi.encodePacked(sender));
        require(
            MerkleProof.verify(merkleProof, merkleRoot, leaf),
            "Not whitelisted"
        );
    }
} /// @notice Modern, minimalist, and gas efficient ERC-721 implementation.

abstract contract ERC721 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );


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

        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "NOT_AUTHORIZED"
        );

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
            msg.sender == from ||
                msg.sender == getApproved[id] ||
                isApprovedForAll[from][msg.sender],
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
                ERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    ""
                ) ==
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
                ERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    data
                ) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }


    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        returns (bool)
    {
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

        require(ownerOf[id] != address(0), "NOT_MINTED");

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
                ERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    address(0),
                    id,
                    ""
                ) ==
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
                ERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    address(0),
                    id,
                    data
                ) ==
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

library UInt2Str {

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return "0";
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
}

contract OdysseyERC721 is ERC721("", "") {

    using UInt2Str for uint256;

    error OdysseyERC721_AlreadyInit();
    error OdysseyERC721_Unauthorized();
    error OdysseyERC721_BadAddress();

    address launcher;
    address public owner;
    bool initialized;
    string public baseURI;
    uint256 public royaltyFeeInBips; // 1% = 100
    address public royaltyReceiver;
    string public contractURI;


    function tokenURI(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {

        return string(abi.encodePacked(baseURI, id.uint2str()));
    }


    function initialize(
        address _launcher,
        address _owner,
        string calldata _name,
        string calldata _symbol,
        string calldata _baseURI
    ) external {

        if (initialized) {
            revert OdysseyERC721_AlreadyInit();
        }
        initialized = true;
        launcher = _launcher;
        owner = _owner;
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
    }


    function transferOwnership(address newOwner) public virtual {

        if (newOwner == address(0)) {
            revert OdysseyERC721_BadAddress();
        }
        if (msg.sender != owner) {
            revert OdysseyERC721_Unauthorized();
        }
        owner = newOwner;
    }

    function mint(address user, uint256 id) external {

        if (msg.sender != launcher) {
            revert OdysseyERC721_Unauthorized();
        }
        _mint(user, id);
    }


    function royaltyInfo(uint256, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {

        return (royaltyReceiver, (_salePrice / 10000) * royaltyFeeInBips);
    }

    function setRoyaltyInfo(address _royaltyReceiver, uint256 _royaltyFeeInBips)
        external
    {

        if (_royaltyReceiver == address(0)) {
            revert OdysseyERC721_BadAddress();
        }
        if (msg.sender != owner) {
            revert OdysseyERC721_Unauthorized();
        }
        royaltyReceiver = _royaltyReceiver;
        royaltyFeeInBips = _royaltyFeeInBips;
    }

    function setContractURI(string memory _uri) public {

        if (msg.sender != owner) {
            revert OdysseyERC721_Unauthorized();
        }
        contractURI = _uri;
    }


    function supportsInterface(bytes4 interfaceID)
        public
        pure
        override(ERC721)
        returns (bool)
    {

        return
            bytes4(keccak256("royaltyInfo(uint256,uint256)")) == interfaceID ||
            super.supportsInterface(interfaceID);
    }
} /// @notice Minimalist and gas efficient standard ERC1155 implementation.

abstract contract ERC1155 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);


    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;


    function uri(uint256 id) public view virtual returns (string memory);


    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(
            msg.sender == from || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(
                    msg.sender,
                    from,
                    id,
                    amount,
                    data
                ) == ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        for (uint256 i = 0; i < idsLength; ) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(
                    msg.sender,
                    from,
                    ids,
                    amounts,
                    data
                ) == ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] memory owners, uint256[] memory ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        uint256 ownersLength = owners.length; // Saves MLOADs.

        require(ownersLength == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        unchecked {
            for (uint256 i = 0; i < ownersLength; i++) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }


    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }


    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(
                    msg.sender,
                    address(0),
                    id,
                    amount,
                    data
                ) == ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(
                    msg.sender,
                    address(0),
                    ids,
                    amounts,
                    data
                ) == ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

interface ERC1155TokenReceiver {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external returns (bytes4);

}

contract OdysseyERC1155 is ERC1155 {

    using UInt2Str for uint256;

    error OdysseyERC1155_AlreadyInit();
    error OdysseyERC1155_Unauthorized();
    error OdysseyERC1155_BadAddress();

    address launcher;
    address public owner;
    string public name;
    string public symbol;
    string public baseURI;
    bool initialized;
    uint256 public royaltyFeeInBips; // 1% = 100
    address public royaltyReceiver;
    string public contractURI;


    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {

        return string(abi.encodePacked(baseURI, id.uint2str()));
    }


    function initialize(
        address _launcher,
        address _owner,
        string calldata _name,
        string calldata _symbol,
        string calldata _baseURI
    ) external {

        if (isInit()) {
            revert OdysseyERC1155_AlreadyInit();
        }
        initialized = true;
        launcher = _launcher;
        owner = _owner;
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
    }

    function isInit() internal view returns (bool) {

        return initialized;
    }


    function transferOwnership(address newOwner) public virtual {

        if (newOwner == address(0)) {
            revert OdysseyERC1155_BadAddress();
        }
        if (msg.sender != owner) {
            revert OdysseyERC1155_Unauthorized();
        }
        owner = newOwner;
    }

    function mint(address user, uint256 id) external {

        if (msg.sender != launcher) {
            revert OdysseyERC1155_Unauthorized();
        }
        _mint(user, id, 1, "");
    }

    function mintBatch(
        address user,
        uint256 id,
        uint256 amount
    ) external {

        if (msg.sender != launcher) {
            revert OdysseyERC1155_Unauthorized();
        }
        _mint(user, id, amount, "");
    }


    function royaltyInfo(uint256, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {

        return (royaltyReceiver, (_salePrice / 10000) * royaltyFeeInBips);
    }

    function setRoyaltyInfo(address _royaltyReceiver, uint256 _royaltyFeeInBips)
        external
    {

        if (_royaltyReceiver == address(0)) {
            revert OdysseyERC1155_BadAddress();
        }
        if (msg.sender != owner) {
            revert OdysseyERC1155_Unauthorized();
        }
        royaltyReceiver = _royaltyReceiver;
        royaltyFeeInBips = _royaltyFeeInBips;
    }

    function setContractURI(string memory _uri) public {

        if (msg.sender != owner) {
            revert OdysseyERC1155_Unauthorized();
        }
        contractURI = _uri;
    }


    function supportsInterface(bytes4 interfaceID)
        public
        pure
        override(ERC1155)
        returns (bool)
    {

        return
            bytes4(keccak256("royaltyInfo(uint256,uint256)")) == interfaceID ||
            super.supportsInterface(interfaceID);
    }
}

contract OdysseyTokenFactory {

    error OdysseyTokenFactory_TokenAlreadyExists();

    event TokenCreated(
        string indexed name,
        string indexed symbol,
        address addr,
        bool isERC721,
        uint256 length
    );


    mapping(string => mapping(string => address)) public getToken;
    mapping(address => uint256) public tokenExists;
    address[] public allTokens;


    function allTokensLength() external view returns (uint256) {

        return allTokens.length;
    }

    function create1155(
        address owner,
        string calldata name,
        string calldata symbol,
        string calldata baseURI
    ) external returns (address token) {

        if (getToken[name][symbol] != address(0)) {
            revert OdysseyTokenFactory_TokenAlreadyExists();
        }
        bytes memory bytecode = type(OdysseyERC1155).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(name, symbol));
        assembly {
            token := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        getToken[name][symbol] = token;
        tokenExists[token] = 1;
        OdysseyERC1155(token).initialize(
            msg.sender,
            owner,
            name,
            symbol,
            string(
                abi.encodePacked(
                    baseURI,
                    Strings.toString(block.chainid),
                    "/",
                    Strings.toHexString(uint160(token)),
                    "/"
                )
            )
        );
        emit TokenCreated(name, symbol, token, false, allTokens.length);
        return token;
    }

    function create721(
        address owner,
        string calldata name,
        string calldata symbol,
        string calldata baseURI
    ) external returns (address token) {

        if (getToken[name][symbol] != address(0)) {
            revert OdysseyTokenFactory_TokenAlreadyExists();
        }
        bytes memory bytecode = type(OdysseyERC721).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(name, symbol));
        assembly {
            token := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        getToken[name][symbol] = token;
        tokenExists[token] = 1;
        OdysseyERC721(token).initialize(
            msg.sender,
            owner,
            name,
            symbol,
            string(
                abi.encodePacked(
                    baseURI,
                    Strings.toString(block.chainid),
                    "/",
                    Strings.toHexString(uint160(token)),
                    "/"
                )
            )
        );
        emit TokenCreated(name, symbol, token, true, allTokens.length);
    }
}

library OdysseyLib {

    struct Odyssey1155Info {
        uint256[] maxSupply;
        uint256[] tokenIds;
        uint256[] reserveAmounts;
    }

    struct BatchMint {
        bytes32[][] merkleProof;
        bytes32[] merkleRoot;
        uint256[] minPrice;
        uint256[] mintsPerUser;
        uint256[] tokenId;
        address[] tokenAddress;
        address[] currency;
        uint8[] v;
        bytes32[] r;
        bytes32[] s;
    }

    struct Percentage {
        uint256 numerator;
        uint256 denominator;
    }

    function compareDefaultPercentage(OdysseyLib.Percentage calldata percent)
        internal
        pure
        returns (bool result)
    {

        if (percent.numerator > percent.denominator) {
            return false;
        }

        if (percent.numerator == 0 || percent.denominator == 0) {
            return false;
        }

        uint256 crossMultiple1 = percent.numerator * 100;
        uint256 crossMultiple2 = percent.denominator * 3;
        if (crossMultiple1 < crossMultiple2) {
            return false;
        }
        return true;
    }
}

abstract contract OdysseyDatabase {
    error OdysseyLaunchPlatform_TokenDoesNotExist();
    error OdysseyLaunchPlatform_AlreadyClaimed();
    error OdysseyLaunchPlatform_MaxSupplyCap();
    error OdysseyLaunchPlatform_InsufficientFunds();
    error OdysseyLaunchPlatform_TreasuryPayFailure();
    error OdysseyLaunchPlatform_FailedToPayEther();
    error OdysseyLaunchPlatform_FailedToPayERC20();
    error OdysseyLaunchPlatform_ReservedOrClaimedMax();

    bytes32 public constant MERKLE_TREE_ROOT_ERC721_TYPEHASH =
        0xf0f6f256599682b9387f45fc268ed696625f835d98d64b8967134239e103fc6c;
    bytes32 public constant MERKLE_TREE_ROOT_ERC1155_TYPEHASH =
        0x0a52f6e0133eadd055cc5703844e676242c3b461d85fb7ce7f74becd7e40edd1;

    address launchPlatform; // slot 0
    address factory; // slot 1
    address treasury; // slot 2
    address admin; //slot 3
    address xp; //slot 4

    mapping(address => bytes32) public domainSeparator;
    mapping(address => uint256) public whitelistActive;
    mapping(address => address) public ownerOf;
    mapping(address => address) public royaltyRecipient;
    mapping(address => OdysseyLib.Percentage) public treasuryCommission;
    mapping(address => uint256) public ohmFamilyCurrencies;
    mapping(address => mapping(address => uint256)) public whitelistClaimed721;
    mapping(address => mapping(address => uint256)) public isReserved721;
    mapping(address => uint256) public cumulativeSupply721;
    mapping(address => uint256) public mintedSupply721;
    mapping(address => uint256) public maxSupply721;
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public whitelistClaimed1155;
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public isReserved1155;
    mapping(address => mapping(uint256 => uint256)) public cumulativeSupply1155;
    mapping(address => mapping(uint256 => uint256)) public maxSupply1155;

    function readSlotAsAddress(uint256 slot)
        public
        view
        returns (address data)
    {
        assembly {
            data := sload(slot)
        }
    }
} /// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.

library SafeTransferLib {


    function safeTransferETH(address to, uint256 amount) internal {

        bool callStatus;

        assembly {
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(from, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "from" argument.
            mstore(
                add(freeMemoryPointer, 36),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(
            didLastOptionalReturnCallSucceed(callStatus),
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(
            didLastOptionalReturnCallSucceed(callStatus),
            "TRANSFER_FAILED"
        );
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            ) // Begin with the function selector.
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }


    function didLastOptionalReturnCallSucceed(bool callStatus)
        private
        pure
        returns (bool success)
    {

        assembly {
            let returnDataSize := returndatasize()

            if iszero(callStatus) {
                returndatacopy(0, 0, returnDataSize)

                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                returndatacopy(0, 0, returnDataSize)

                success := iszero(iszero(mload(0)))
            }
            case 0 {
                success := 1
            }
            default {
                success := 0
            }
        }
    }
} /// @notice Arithmetic library with operations for fixed-point numbers.

library FixedPointMathLib {


    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }


    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {

        assembly {
            z := mul(x, y)

            if iszero(
                and(
                    iszero(iszero(denominator)),
                    or(iszero(x), eq(div(z, x), y))
                )
            ) {
                revert(0, 0)
            }

            z := div(z, denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {

        assembly {
            z := mul(x, y)

            if iszero(
                and(
                    iszero(iszero(denominator)),
                    or(iszero(x), eq(div(z, x), y))
                )
            ) {
                revert(0, 0)
            }

            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {

        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := scalar
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := scalar
                }
                default {
                    z := x
                }

                let half := shr(1, scalar)

                for {
                    n := shr(1, n)
                } n {
                    n := shr(1, n)
                } {
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    let xx := mul(x, x)

                    let xxRound := add(xx, half)

                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    x := div(xxRound, scalar)

                    if mod(n, 2) {
                        let zx := mul(z, x)

                        if iszero(eq(div(zx, x), z)) {
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        let zxRound := add(zx, half)

                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }


    function sqrt(uint256 x) internal pure returns (uint256 z) {

        assembly {
            z := 1

            let y := x

            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z) // Like multiplying by 2 ** 64.
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z) // Like multiplying by 2 ** 32.
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z) // Like multiplying by 2 ** 16.
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z) // Like multiplying by 2 ** 8.
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z) // Like multiplying by 2 ** 4.
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z) // Like multiplying by 2 ** 2.
            }
            if iszero(lt(y, 0x8)) {
                z := shl(1, z)
            }

            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            let zRoundDown := div(x, z)

            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }
} // OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId)
        internal
        view
        returns (bool)
    {

        return
            supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(
        address account,
        bytes4[] memory interfaceIds
    ) internal view returns (bool[] memory) {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(
                    account,
                    interfaceIds[i]
                );
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(
        address account,
        bytes4[] memory interfaceIds
    ) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId)
        private
        view
        returns (bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(
            IERC165.supportsInterface.selector,
            interfaceId
        );
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(
            encodedParams
        );
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}
struct Rewards {
    uint256 sale;
    uint256 purchase;
    uint256 mint;
    uint256 ohmPurchase;
    uint256 ohmMint;
    uint256 multiplier;
}

struct NFT {
    address contractAddress;
    uint256 id;
}

enum NftType {
    ERC721,
    ERC1155
}

error OdysseyXpDirectory_Unauthorized();

contract OdysseyXpDirectory {

    using ERC165Checker for address;

    Rewards public defaultRewards;
    mapping(address => Rewards) public erc721rewards;
    mapping(address => mapping(uint256 => Rewards)) public erc1155rewards;
    NFT[] public customRewardTokens;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function notOwner() internal view returns (bool) {

        return msg.sender != owner;
    }

    function transferOwnership(address newOwner) external {

        if (notOwner()) revert OdysseyXpDirectory_Unauthorized();
        owner = newOwner;
    }


    function setDefaultRewards(
        uint256 sale,
        uint256 purchase,
        uint256 mint,
        uint256 ohmPurchase,
        uint256 ohmMint,
        uint256 multiplier
    ) public {

        if (notOwner()) revert OdysseyXpDirectory_Unauthorized();
        defaultRewards = Rewards(
            sale,
            purchase,
            mint,
            ohmPurchase,
            ohmMint,
            multiplier
        );
    }

    function setErc721CustomRewards(
        address tokenAddress,
        uint256 sale,
        uint256 purchase,
        uint256 mint,
        uint256 ohmPurchase,
        uint256 ohmMint,
        uint256 multiplier
    ) public {

        if (notOwner()) revert OdysseyXpDirectory_Unauthorized();
        customRewardTokens.push(NFT(tokenAddress, 0));
        erc721rewards[tokenAddress] = Rewards(
            sale,
            purchase,
            mint,
            ohmPurchase,
            ohmMint,
            multiplier
        );
    }

    function setErc1155CustomRewards(
        address tokenAddress,
        uint256 tokenId,
        uint256 sale,
        uint256 purchase,
        uint256 mint,
        uint256 ohmPurchase,
        uint256 ohmMint,
        uint256 multiplier
    ) public {

        if (notOwner()) revert OdysseyXpDirectory_Unauthorized();
        customRewardTokens.push(NFT(tokenAddress, tokenId));
        erc1155rewards[tokenAddress][tokenId] = Rewards(
            sale,
            purchase,
            mint,
            ohmPurchase,
            ohmMint,
            multiplier
        );
    }


    function getSaleReward(
        address seller,
        address contractAddress,
        uint256 tokenId
    ) public view returns (uint256) {

        (
            bool isCustomErc721,
            bool isCustomErc1155,
            uint256 multiplier
        ) = _getRewardDetails(seller, contractAddress, tokenId);
        if (isCustomErc721) {
            return erc721rewards[contractAddress].sale * multiplier;
        } else if (isCustomErc1155) {
            return erc1155rewards[contractAddress][tokenId].sale * multiplier;
        } else {
            return defaultRewards.sale * multiplier;
        }
    }

    function getPurchaseReward(
        address buyer,
        address contractAddress,
        uint256 tokenId
    ) public view returns (uint256) {

        (
            bool isCustomErc721,
            bool isCustomErc1155,
            uint256 multiplier
        ) = _getRewardDetails(buyer, contractAddress, tokenId);
        if (isCustomErc721) {
            return erc721rewards[contractAddress].purchase * multiplier;
        } else if (isCustomErc1155) {
            return
                erc1155rewards[contractAddress][tokenId].purchase * multiplier;
        } else {
            return defaultRewards.purchase * multiplier;
        }
    }

    function getMintReward(
        address buyer,
        address contractAddress,
        uint256 tokenId
    ) public view returns (uint256) {

        (
            bool isCustomErc721,
            bool isCustomErc1155,
            uint256 multiplier
        ) = _getRewardDetails(buyer, contractAddress, tokenId);
        if (isCustomErc721) {
            return erc721rewards[contractAddress].mint * multiplier;
        } else if (isCustomErc1155) {
            return erc1155rewards[contractAddress][tokenId].mint * multiplier;
        } else {
            return defaultRewards.mint * multiplier;
        }
    }

    function getOhmPurchaseReward(
        address buyer,
        address contractAddress,
        uint256 tokenId
    ) public view returns (uint256) {

        (
            bool isCustomErc721,
            bool isCustomErc1155,
            uint256 multiplier
        ) = _getRewardDetails(buyer, contractAddress, tokenId);
        if (isCustomErc721) {
            return erc721rewards[contractAddress].ohmPurchase * multiplier;
        } else if (isCustomErc1155) {
            return
                erc1155rewards[contractAddress][tokenId].ohmPurchase *
                multiplier;
        } else {
            return defaultRewards.ohmPurchase * multiplier;
        }
    }

    function getOhmMintReward(
        address buyer,
        address contractAddress,
        uint256 tokenId
    ) public view returns (uint256) {

        (
            bool isCustomErc721,
            bool isCustomErc1155,
            uint256 multiplier
        ) = _getRewardDetails(buyer, contractAddress, tokenId);
        if (isCustomErc721) {
            return erc721rewards[contractAddress].ohmMint * multiplier;
        } else if (isCustomErc1155) {
            return
                erc1155rewards[contractAddress][tokenId].ohmMint * multiplier;
        } else {
            return defaultRewards.ohmMint * multiplier;
        }
    }

    function _getRewardDetails(
        address user,
        address contractAddress,
        uint256 tokenId
    )
        internal
        view
        returns (
            bool isCustomErc721,
            bool isCustomErc1155,
            uint256 multiplier
        )
    {

        NFT[] memory _customRewardTokens = customRewardTokens; // save an SLOAD from length reading
        for (uint256 i = 0; i < _customRewardTokens.length; i++) {
            NFT memory token = _customRewardTokens[i];
            if (token.contractAddress.supportsInterface(0x80ac58cd)) {
                if (OdysseyERC721(token.contractAddress).balanceOf(user) > 0) {
                    uint256 reward = erc721rewards[token.contractAddress]
                        .multiplier;
                    multiplier = reward > 1 ? multiplier + reward : multiplier; // only increment if multiplier is non-one
                }
                if (contractAddress == token.contractAddress) {
                    isCustomErc721 = true;
                }
            } else if (token.contractAddress.supportsInterface(0xd9b67a26)) {
                if (
                    OdysseyERC1155(token.contractAddress).balanceOf(
                        user,
                        token.id
                    ) > 0
                ) {
                    uint256 reward = erc1155rewards[token.contractAddress][
                        token.id
                    ].multiplier;
                    multiplier = reward > 1 ? multiplier + reward : multiplier; // only increment if multiplier is non-one
                    if (
                        contractAddress == token.contractAddress &&
                        tokenId == token.id
                    ) {
                        isCustomErc1155 = true;
                    }
                }
            }
        }
        multiplier = multiplier == 0 ? defaultRewards.multiplier : multiplier; // if no custom multiplier, use default
        multiplier = multiplier > 4 ? 4 : multiplier; // multiplier caps at 4
    }
}
error OdysseyXp_Unauthorized();
error OdysseyXp_NonTransferable();
error OdysseyXp_ZeroAssets();

contract OdysseyXp is ERC20 {

    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    struct UserHistory {
        uint256 balanceAtLastRedeem;
        uint256 globallyWithdrawnAtLastRedeem;
    }


    event Mint(address indexed owner, uint256 assets, uint256 xp);

    event Redeem(address indexed owner, uint256 assets, uint256 xp);


    address public router;
    address public exchange;
    address public owner;
    uint256 public globallyWithdrawn;
    ERC20 public immutable asset;
    OdysseyXpDirectory public directory;
    mapping(address => UserHistory) public userHistories;

    constructor(
        ERC20 _asset,
        OdysseyXpDirectory _directory,
        address _router,
        address _exchange,
        address _owner
    ) ERC20("Odyssey XP", "XP", 0) {
        asset = _asset;
        directory = _directory;
        router = _router;
        exchange = _exchange;
        owner = _owner;
    }


    function notOwner() internal view returns (bool) {

        return msg.sender != owner;
    }

    function notRouter() internal view returns (bool) {

        return msg.sender != router;
    }

    function notExchange() internal view returns (bool) {

        return msg.sender != exchange;
    }


    function setExchange(address _exchange) external {

        if (notOwner()) revert OdysseyXp_Unauthorized();
        exchange = _exchange;
    }

    function setRouter(address _router) external {

        if (notOwner()) revert OdysseyXp_Unauthorized();
        router = _router;
    }

    function setDirectory(address _directory) external {

        if (notOwner()) revert OdysseyXp_Unauthorized();
        directory = OdysseyXpDirectory(_directory);
    }

    function transferOwnership(address _newOwner) external {

        if (notOwner()) revert OdysseyXp_Unauthorized();
        owner = _newOwner;
    }


    function saleReward(
        address seller,
        address contractAddress,
        uint256 tokenId
    ) external {

        if (notExchange()) revert OdysseyXp_Unauthorized();
        _grantXP(
            seller,
            directory.getSaleReward(seller, contractAddress, tokenId)
        );
    }

    function purchaseReward(
        address buyer,
        address contractAddress,
        uint256 tokenId
    ) external {

        if (notExchange()) revert OdysseyXp_Unauthorized();
        _grantXP(
            buyer,
            directory.getPurchaseReward(buyer, contractAddress, tokenId)
        );
    }

    function mintReward(
        address buyer,
        address contractAddress,
        uint256 tokenId
    ) external {

        if (notRouter()) revert OdysseyXp_Unauthorized();
        _grantXP(
            buyer,
            directory.getMintReward(buyer, contractAddress, tokenId)
        );
    }

    function ohmPurchaseReward(
        address buyer,
        address contractAddress,
        uint256 tokenId
    ) external {

        if (notExchange()) revert OdysseyXp_Unauthorized();
        _grantXP(
            buyer,
            directory.getOhmPurchaseReward(buyer, contractAddress, tokenId)
        );
    }

    function ohmMintReward(
        address buyer,
        address contractAddress,
        uint256 tokenId
    ) external {

        if (notRouter()) revert OdysseyXp_Unauthorized();
        _grantXP(
            buyer,
            directory.getOhmMintReward(buyer, contractAddress, tokenId)
        );
    }


    function _grantXP(address receiver, uint256 xp)
        internal
        returns (uint256 assets)
    {

        uint256 currentXp = balanceOf[receiver];
        if ((assets = previewRedeem(receiver, currentXp)) > 0)
            _redeem(receiver, assets, currentXp); // force redeeming to keep portions in line
        else if (currentXp == 0)
            userHistories[receiver]
                .globallyWithdrawnAtLastRedeem = globallyWithdrawn; // if a new user, adjust their history to calculate withdrawn at their first redeem
        _mint(receiver, xp);

        emit Mint(msg.sender, assets, xp);

        afterMint(assets, xp);
    }


    function redeem() public returns (uint256 assets) {

        uint256 xp = balanceOf[msg.sender];
        if ((assets = previewRedeem(msg.sender, xp)) == 0)
            revert OdysseyXp_ZeroAssets();
        _redeem(msg.sender, assets, xp);
    }

    function _redeem(
        address receiver,
        uint256 assets,
        uint256 xp
    ) internal virtual {

        beforeRedeem(assets, xp);

        userHistories[receiver].balanceAtLastRedeem =
            asset.balanceOf(address(this)) -
            assets;
        userHistories[receiver].globallyWithdrawnAtLastRedeem =
            globallyWithdrawn +
            assets;
        globallyWithdrawn += assets;

        asset.safeTransfer(receiver, assets);

        emit Redeem(receiver, assets, xp);
    }


    function previewRedeem(address recipient, uint256 xp)
        public
        view
        virtual
        returns (uint256)
    {

        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return
            supply == 0 || xp == 0
                ? 0
                : xp.mulDivDown(totalAssets(recipient), supply);
    }

    function totalAssets(address user) internal view returns (uint256) {

        uint256 balance = asset.balanceOf(address(this)); // Saves an extra SLOAD if balance is non-zero.
        return
            balance +
            (globallyWithdrawn -
                userHistories[user].globallyWithdrawnAtLastRedeem) -
            userHistories[user].balanceAtLastRedeem;
    }


    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {

        revert OdysseyXp_NonTransferable();
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {

        revert OdysseyXp_NonTransferable();
    }


    function beforeRedeem(uint256 assets, uint256 xp) internal virtual {}


    function afterMint(uint256 assets, uint256 xp) internal virtual {}

}

contract OdysseyLaunchPlatform is OdysseyDatabase, ReentrancyGuard {
    function mintERC721(
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot,
        uint256 minPrice,
        uint256 mintsPerUser,
        address tokenAddress,
        address currency,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant {
        if (OdysseyTokenFactory(factory).tokenExists(tokenAddress) == 0) {
            revert OdysseyLaunchPlatform_TokenDoesNotExist();
        }
        if (whitelistClaimed721[tokenAddress][msg.sender] >= mintsPerUser) {
            revert OdysseyLaunchPlatform_AlreadyClaimed();
        }
        if (isReserved721[tokenAddress][msg.sender] == 0) {
            if (
                cumulativeSupply721[tokenAddress] >= maxSupply721[tokenAddress]
            ) {
                revert OdysseyLaunchPlatform_MaxSupplyCap();
            }
            {
                bytes32 hash = keccak256(
                    abi.encode(
                        MERKLE_TREE_ROOT_ERC721_TYPEHASH,
                        merkleRoot,
                        minPrice,
                        mintsPerUser,
                        tokenAddress,
                        currency
                    )
                );
                Signature.verify(
                    hash,
                    ownerOf[tokenAddress],
                    v,
                    r,
                    s,
                    domainSeparator[tokenAddress]
                );
            }
            if (whitelistActive[tokenAddress] == 1) {
                MerkleWhiteList.verify(msg.sender, merkleProof, merkleRoot);
            }
            cumulativeSupply721[tokenAddress]++;

            OdysseyLib.Percentage storage percent = treasuryCommission[
                tokenAddress
            ];
            uint256 commission = (minPrice * percent.numerator) /
                percent.denominator;

            if (currency == address(0)) {
                if (msg.value < minPrice) {
                    revert OdysseyLaunchPlatform_InsufficientFunds();
                }
                (bool treasurySuccess, ) = treasury.call{value: commission}("");
                if (!treasurySuccess) {
                    revert OdysseyLaunchPlatform_TreasuryPayFailure();
                }
                (bool success, ) = royaltyRecipient[tokenAddress].call{
                    value: minPrice - commission
                }("");
                if (!success) {
                    revert OdysseyLaunchPlatform_FailedToPayEther();
                }
            } else {
                if (
                    ERC20(currency).allowance(msg.sender, address(this)) <
                    minPrice
                ) {
                    revert OdysseyLaunchPlatform_InsufficientFunds();
                }
                bool result = ERC20(currency).transferFrom(
                    msg.sender,
                    treasury,
                    commission
                );
                if (!result) {
                    revert OdysseyLaunchPlatform_TreasuryPayFailure();
                }
                result = ERC20(currency).transferFrom(
                    msg.sender,
                    royaltyRecipient[tokenAddress],
                    minPrice - commission
                );
                if (!result) {
                    revert OdysseyLaunchPlatform_FailedToPayERC20();
                }
                if (ohmFamilyCurrencies[currency] == 1) {
                    OdysseyXp(xp).ohmMintReward(msg.sender, tokenAddress, 0);
                }
            }
        } else {
            isReserved721[tokenAddress][msg.sender]--;
        }
        whitelistClaimed721[tokenAddress][msg.sender]++;
        OdysseyERC721(tokenAddress).mint(
            msg.sender,
            mintedSupply721[tokenAddress]++
        );
    }

    function reserveERC721(
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot,
        uint256 minPrice,
        uint256 mintsPerUser,
        address tokenAddress,
        address currency,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant {
        if (OdysseyTokenFactory(factory).tokenExists(tokenAddress) == 0) {
            revert OdysseyLaunchPlatform_TokenDoesNotExist();
        }
        if (cumulativeSupply721[tokenAddress] >= maxSupply721[tokenAddress]) {
            revert OdysseyLaunchPlatform_MaxSupplyCap();
        }
        if (
            isReserved721[tokenAddress][msg.sender] +
                whitelistClaimed721[tokenAddress][msg.sender] >=
            mintsPerUser
        ) {
            revert OdysseyLaunchPlatform_ReservedOrClaimedMax();
        }
        {
            bytes32 hash = keccak256(
                abi.encode(
                    MERKLE_TREE_ROOT_ERC721_TYPEHASH,
                    merkleRoot,
                    minPrice,
                    mintsPerUser,
                    tokenAddress,
                    currency
                )
            );
            Signature.verify(
                hash,
                ownerOf[tokenAddress],
                v,
                r,
                s,
                domainSeparator[tokenAddress]
            );
        }
        if (whitelistActive[tokenAddress] == 1) {
            MerkleWhiteList.verify(msg.sender, merkleProof, merkleRoot);
        }

        isReserved721[tokenAddress][msg.sender]++;
        cumulativeSupply721[tokenAddress]++;

        OdysseyLib.Percentage storage percent = treasuryCommission[
            tokenAddress
        ];
        uint256 commission = (minPrice * percent.numerator) /
            percent.denominator;

        if (currency == address(0)) {
            if (msg.value < minPrice) {
                revert OdysseyLaunchPlatform_InsufficientFunds();
            }
            (bool treasurySuccess, ) = treasury.call{value: commission}("");
            if (!treasurySuccess) {
                revert OdysseyLaunchPlatform_TreasuryPayFailure();
            }
            (bool success, ) = royaltyRecipient[tokenAddress].call{
                value: minPrice - commission
            }("");
            if (!success) {
                revert OdysseyLaunchPlatform_FailedToPayEther();
            }
        } else {
            if (
                ERC20(currency).allowance(msg.sender, address(this)) < minPrice
            ) {
                revert OdysseyLaunchPlatform_InsufficientFunds();
            }
            bool result = ERC20(currency).transferFrom(
                msg.sender,
                treasury,
                commission
            );
            if (!result) {
                revert OdysseyLaunchPlatform_TreasuryPayFailure();
            }
            result = ERC20(currency).transferFrom(
                msg.sender,
                royaltyRecipient[tokenAddress],
                minPrice - commission
            );
            if (!result) {
                revert OdysseyLaunchPlatform_FailedToPayERC20();
            }
            if (ohmFamilyCurrencies[currency] == 1) {
                OdysseyXp(xp).ohmMintReward(msg.sender, tokenAddress, 0);
            }
        }
    }

    function mintERC1155(
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot,
        uint256 minPrice,
        uint256 mintsPerUser,
        uint256 tokenId,
        address tokenAddress,
        address currency,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant {
        if (OdysseyTokenFactory(factory).tokenExists(tokenAddress) == 0) {
            revert OdysseyLaunchPlatform_TokenDoesNotExist();
        }
        if (
            whitelistClaimed1155[tokenAddress][msg.sender][tokenId] >=
            mintsPerUser
        ) {
            revert OdysseyLaunchPlatform_AlreadyClaimed();
        }
        if (isReserved1155[tokenAddress][msg.sender][tokenId] == 0) {
            if (
                cumulativeSupply1155[tokenAddress][tokenId] >=
                maxSupply1155[tokenAddress][tokenId]
            ) {
                revert OdysseyLaunchPlatform_MaxSupplyCap();
            }
            {
                bytes32 hash = keccak256(
                    abi.encode(
                        MERKLE_TREE_ROOT_ERC1155_TYPEHASH,
                        merkleRoot,
                        minPrice,
                        mintsPerUser,
                        tokenId,
                        tokenAddress,
                        currency
                    )
                );
                Signature.verify(
                    hash,
                    ownerOf[tokenAddress],
                    v,
                    r,
                    s,
                    domainSeparator[tokenAddress]
                );
            }

            if (whitelistActive[tokenAddress] == 1) {
                MerkleWhiteList.verify(msg.sender, merkleProof, merkleRoot);
            }
            cumulativeSupply1155[tokenAddress][tokenId]++;

            OdysseyLib.Percentage storage percent = treasuryCommission[
                tokenAddress
            ];
            uint256 commission = (minPrice * percent.numerator) /
                percent.denominator;

            if (currency == address(0)) {
                if (msg.value < minPrice) {
                    revert OdysseyLaunchPlatform_InsufficientFunds();
                }
                (bool treasurySuccess, ) = treasury.call{value: commission}("");
                if (!treasurySuccess) {
                    revert OdysseyLaunchPlatform_TreasuryPayFailure();
                }
                (bool success, ) = royaltyRecipient[tokenAddress].call{
                    value: minPrice - commission
                }("");
                if (!success) {
                    revert OdysseyLaunchPlatform_FailedToPayEther();
                }
            } else {
                if (
                    ERC20(currency).allowance(msg.sender, address(this)) <
                    minPrice
                ) {
                    revert OdysseyLaunchPlatform_InsufficientFunds();
                }
                bool result = ERC20(currency).transferFrom(
                    msg.sender,
                    treasury,
                    commission
                );
                if (!result) {
                    revert OdysseyLaunchPlatform_TreasuryPayFailure();
                }
                result = ERC20(currency).transferFrom(
                    msg.sender,
                    royaltyRecipient[tokenAddress],
                    minPrice - commission
                );
                if (!result) {
                    revert OdysseyLaunchPlatform_FailedToPayERC20();
                }
                if (ohmFamilyCurrencies[currency] == 1) {
                    OdysseyXp(xp).ohmMintReward(
                        msg.sender,
                        tokenAddress,
                        tokenId
                    );
                }
            }
        } else {
            isReserved1155[tokenAddress][msg.sender][tokenId]--;
        }
        whitelistClaimed1155[tokenAddress][msg.sender][tokenId]++;

        OdysseyERC1155(tokenAddress).mint(msg.sender, tokenId);
    }

    function reserveERC1155(
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot,
        uint256 minPrice,
        uint256 mintsPerUser,
        uint256 tokenId,
        address tokenAddress,
        address currency,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant {
        if (OdysseyTokenFactory(factory).tokenExists(tokenAddress) == 0) {
            revert OdysseyLaunchPlatform_TokenDoesNotExist();
        }
        if (
            cumulativeSupply1155[tokenAddress][tokenId] >=
            maxSupply1155[tokenAddress][tokenId]
        ) {
            revert OdysseyLaunchPlatform_MaxSupplyCap();
        }
        if (
            isReserved1155[tokenAddress][msg.sender][tokenId] +
                whitelistClaimed1155[tokenAddress][msg.sender][tokenId] >=
            mintsPerUser
        ) {
            revert OdysseyLaunchPlatform_ReservedOrClaimedMax();
        }
        {
            bytes32 hash = keccak256(
                abi.encode(
                    MERKLE_TREE_ROOT_ERC1155_TYPEHASH,
                    merkleRoot,
                    minPrice,
                    mintsPerUser,
                    tokenId,
                    tokenAddress,
                    currency
                )
            );
            Signature.verify(
                hash,
                ownerOf[tokenAddress],
                v,
                r,
                s,
                domainSeparator[tokenAddress]
            );
        }

        if (whitelistActive[tokenAddress] == 1) {
            MerkleWhiteList.verify(msg.sender, merkleProof, merkleRoot);
        }

        isReserved1155[tokenAddress][msg.sender][tokenId]++;
        cumulativeSupply1155[tokenAddress][tokenId]++;

        OdysseyLib.Percentage storage percent = treasuryCommission[
            tokenAddress
        ];
        uint256 commission = (minPrice * percent.numerator) /
            percent.denominator;

        if (currency == address(0)) {
            if (msg.value < minPrice) {
                revert OdysseyLaunchPlatform_InsufficientFunds();
            }
            (bool treasurySuccess, ) = treasury.call{value: commission}("");
            if (!treasurySuccess) {
                revert OdysseyLaunchPlatform_TreasuryPayFailure();
            }
            (bool success, ) = royaltyRecipient[tokenAddress].call{
                value: minPrice - commission
            }("");
            if (!success) {
                revert OdysseyLaunchPlatform_FailedToPayEther();
            }
        } else {
            if (
                ERC20(currency).allowance(msg.sender, address(this)) < minPrice
            ) {
                revert OdysseyLaunchPlatform_InsufficientFunds();
            }
            bool result = ERC20(currency).transferFrom(
                msg.sender,
                treasury,
                commission
            );
            if (!result) {
                revert OdysseyLaunchPlatform_TreasuryPayFailure();
            }
            result = ERC20(currency).transferFrom(
                msg.sender,
                royaltyRecipient[tokenAddress],
                minPrice - commission
            );
            if (!result) {
                revert OdysseyLaunchPlatform_FailedToPayERC20();
            }
            if (ohmFamilyCurrencies[currency] == 1) {
                OdysseyXp(xp).ohmMintReward(msg.sender, tokenAddress, tokenId);
            }
        }
    }

    function setWhitelistStatus(address addr, bool active)
        external
        nonReentrant
    {
        if (OdysseyTokenFactory(factory).tokenExists(addr) == 0) {
            revert OdysseyLaunchPlatform_TokenDoesNotExist();
        }
        whitelistActive[addr] = active ? 1 : 0;
    }

    function mint721OnCreate(uint256 amount, address token)
        external
        nonReentrant
    {
        cumulativeSupply721[token] = amount;
        mintedSupply721[token] = amount;
        uint256 i;
        for (; i < amount; ++i) {
            OdysseyERC721(token).mint(msg.sender, i);
        }
    }

    function mint1155OnCreate(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        address token
    ) external nonReentrant {
        uint256 i;
        for (; i < tokenIds.length; ++i) {
            cumulativeSupply1155[token][tokenIds[i]] = amounts[i];
            OdysseyERC1155(token).mintBatch(
                msg.sender,
                tokenIds[i],
                amounts[i]
            );
        }
    }

    function ownerMint721(address token, address to) external nonReentrant {
        if (cumulativeSupply721[token] >= maxSupply721[token]) {
            revert OdysseyLaunchPlatform_MaxSupplyCap();
        }
        cumulativeSupply721[token]++;
        OdysseyERC721(token).mint(to, mintedSupply721[token]++);
    }

    function ownerMint1155(
        uint256 id,
        uint256 amount,
        address token,
        address to
    ) external nonReentrant {
        if (
            cumulativeSupply1155[token][id] + amount > maxSupply1155[token][id]
        ) {
            revert OdysseyLaunchPlatform_MaxSupplyCap();
        }
        cumulativeSupply1155[token][id] += amount;
        OdysseyERC1155(token).mintBatch(to, id, amount);
    }
}

contract OdysseyRouter is OdysseyDatabase, ReentrancyGuard {
    error OdysseyRouter_TokenIDSupplyMismatch();
    error OdysseyRouter_WhitelistUpdateFail();
    error OdysseyRouter_Unauthorized();
    error OdysseyRouter_OwnerMintFailure();
    error OdysseyRouter_BadTokenAddress();
    error OdysseyRouter_BadOwnerAddress();
    error OdysseyRouter_BadSenderAddress();
    error OdysseyRouter_BadRecipientAddress();
    error OdysseyRouter_BadTreasuryAddress();
    error OdysseyRouter_BadAdminAddress();

    constructor(
        address treasury_,
        address xpDirectory_,
        address xp_,
        address[] memory ohmCurrencies_
    ) {
        launchPlatform = address(new OdysseyLaunchPlatform());
        factory = address(new OdysseyTokenFactory());
        treasury = treasury_;
        admin = msg.sender;
        uint256 i;
        for (; i < ohmCurrencies_.length; i++) {
            ohmFamilyCurrencies[ohmCurrencies_[i]] = 1;
        }
        if (xp_ == address(0)) {
            if (xpDirectory_ == address(0)) {
                xpDirectory_ = address(new OdysseyXpDirectory());
                OdysseyXpDirectory(xpDirectory_).setDefaultRewards(
                    1,
                    1,
                    1,
                    3,
                    3,
                    1
                );
                OdysseyXpDirectory(xpDirectory_).transferOwnership(admin);
            }
            xp_ = address(
                new OdysseyXp(
                    ERC20(ohmCurrencies_[0]),
                    OdysseyXpDirectory(xpDirectory_),
                    address(this),
                    address(this),
                    admin
                )
            );
        }
        xp = xp_;
    }

    function Factory() public view returns (OdysseyTokenFactory) {
        return OdysseyTokenFactory(readSlotAsAddress(1));
    }

    function create1155(
        string calldata name,
        string calldata symbol,
        string calldata baseURI,
        OdysseyLib.Odyssey1155Info calldata info,
        OdysseyLib.Percentage calldata treasuryPercentage,
        address royaltyReceiver,
        bool whitelist
    ) external returns (address token) {
        if (info.maxSupply.length != info.tokenIds.length) {
            revert OdysseyRouter_TokenIDSupplyMismatch();
        }
        token = Factory().create1155(msg.sender, name, symbol, baseURI);
        ownerOf[token] = msg.sender;
        whitelistActive[token] = whitelist ? 1 : 0;
        royaltyRecipient[token] = royaltyReceiver;
        uint256 i;
        for (; i < info.tokenIds.length; ++i) {
            maxSupply1155[token][info.tokenIds[i]] = (info.maxSupply[i] == 0)
                ? type(uint256).max
                : info.maxSupply[i];
        }

        domainSeparator[token] = keccak256(
            abi.encode(
                0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                keccak256(bytes(Strings.toHexString(uint160(token)))),
                0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6, // keccak256(bytes("1"))
                block.chainid,
                token
            )
        );

        if (OdysseyLib.compareDefaultPercentage(treasuryPercentage)) {
            treasuryCommission[token] = treasuryPercentage;
        } else {
            treasuryCommission[token] = OdysseyLib.Percentage(3, 100);
        }

        if (info.reserveAmounts.length > 0) {
            (bool success, bytes memory data) = launchPlatform.delegatecall(
                abi.encodeWithSignature(
                    "mint1155OnCreate(uint256[],uint256[],address)",
                    info.tokenIds,
                    info.reserveAmounts,
                    token
                )
            );
            if (!success) {
                if (data.length == 0) revert();
                assembly {
                    revert(add(32, data), mload(data))
                }
            }
        }
        return token;
    }

    function create721(
        string calldata name,
        string calldata symbol,
        string calldata baseURI,
        uint256 maxSupply,
        uint256 reserveAmount,
        OdysseyLib.Percentage calldata treasuryPercentage,
        address royaltyReceiver,
        bool whitelist
    ) external returns (address token) {
        token = Factory().create721(msg.sender, name, symbol, baseURI);
        ownerOf[token] = msg.sender;
        maxSupply721[token] = (maxSupply == 0) ? type(uint256).max : maxSupply;
        whitelistActive[token] = whitelist ? 1 : 0;
        royaltyRecipient[token] = royaltyReceiver;
        domainSeparator[token] = keccak256(
            abi.encode(
                0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                keccak256(bytes(Strings.toHexString(uint160(token)))),
                0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6, // keccak256(bytes("1"))
                block.chainid,
                token
            )
        );

        if (OdysseyLib.compareDefaultPercentage(treasuryPercentage)) {
            treasuryCommission[token] = treasuryPercentage;
        } else {
            treasuryCommission[token] = OdysseyLib.Percentage(3, 100);
        }

        if (reserveAmount > 0) {
            (bool success, bytes memory data) = launchPlatform.delegatecall(
                abi.encodeWithSignature(
                    "mint721OnCreate(uint256,address)",
                    reserveAmount,
                    token
                )
            );
            if (!success) {
                if (data.length == 0) revert();
                assembly {
                    revert(add(32, data), mload(data))
                }
            }
        }

        return token;
    }

    function mintERC721(
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot,
        uint256 minPrice,
        uint256 mintsPerUser,
        address tokenAddress,
        address currency,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        (bool success, bytes memory data) = launchPlatform.delegatecall(
            abi.encodeWithSignature(
                "mintERC721(bytes32[],bytes32,uint256,uint256,address,address,uint8,bytes32,bytes32)",
                merkleProof,
                merkleRoot,
                minPrice,
                mintsPerUser,
                tokenAddress,
                currency,
                v,
                r,
                s
            )
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
    }

    function batchMintERC721(OdysseyLib.BatchMint calldata batch)
        public
        payable
    {
        for (uint256 i = 0; i < batch.tokenAddress.length; i++) {
            (bool success, bytes memory data) = launchPlatform.delegatecall(
                abi.encodeWithSignature(
                    "mintERC721(bytes32[],bytes32,uint256,uint256,address,address,uint8,bytes32,bytes32)",
                    batch.merkleProof[i],
                    batch.merkleRoot[i],
                    batch.minPrice[i],
                    batch.mintsPerUser[i],
                    batch.tokenAddress[i],
                    batch.currency[i],
                    batch.v[i],
                    batch.r[i],
                    batch.s[i]
                )
            );
            if (!success) {
                if (data.length == 0) revert();
                assembly {
                    revert(add(32, data), mload(data))
                }
            }
        }
    }

    function reserveERC721(
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot,
        uint256 minPrice,
        uint256 mintsPerUser,
        address tokenAddress,
        address currency,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        (bool success, bytes memory data) = launchPlatform.delegatecall(
            abi.encodeWithSignature(
                "reserveERC721(bytes32[],bytes32,uint256,uint256,address,address,uint8,bytes32,bytes32)",
                merkleProof,
                merkleRoot,
                minPrice,
                mintsPerUser,
                tokenAddress,
                currency,
                v,
                r,
                s
            )
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
    }

    function batchReserveERC721(OdysseyLib.BatchMint calldata batch)
        public
        payable
    {
        for (uint256 i = 0; i < batch.tokenAddress.length; i++) {
            (bool success, bytes memory data) = launchPlatform.delegatecall(
                abi.encodeWithSignature(
                    "reserveERC721(bytes32[],bytes32,uint256,uint256,address,address,uint8,bytes32,bytes32)",
                    batch.merkleProof[i],
                    batch.merkleRoot[i],
                    batch.minPrice[i],
                    batch.mintsPerUser[i],
                    batch.tokenAddress[i],
                    batch.currency[i],
                    batch.v[i],
                    batch.r[i],
                    batch.s[i]
                )
            );
            if (!success) {
                if (data.length == 0) revert();
                assembly {
                    revert(add(32, data), mload(data))
                }
            }
        }
    }

    function mintERC1155(
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot,
        uint256 minPrice,
        uint256 mintsPerUser,
        uint256 tokenId,
        address tokenAddress,
        address currency,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        (bool success, bytes memory data) = launchPlatform.delegatecall(
            abi.encodeWithSignature(
                "mintERC1155(bytes32[],bytes32,uint256,uint256,uint256,address,address,uint8,bytes32,bytes32)",
                merkleProof,
                merkleRoot,
                minPrice,
                mintsPerUser,
                tokenId,
                tokenAddress,
                currency,
                v,
                r,
                s
            )
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
    }

    function batchMintERC1155(OdysseyLib.BatchMint calldata batch)
        public
        payable
    {
        for (uint256 i = 0; i < batch.tokenAddress.length; i++) {
            (bool success, bytes memory data) = launchPlatform.delegatecall(
                abi.encodeWithSignature(
                    "mintERC1155(bytes32[],bytes32,uint256,uint256,uint256,address,address,uint8,bytes32,bytes32)",
                    batch.merkleProof[i],
                    batch.merkleRoot[i],
                    batch.minPrice[i],
                    batch.mintsPerUser[i],
                    batch.tokenId[i],
                    batch.tokenAddress[i],
                    batch.currency[i],
                    batch.v[i],
                    batch.r[i],
                    batch.s[i]
                )
            );
            if (!success) {
                if (data.length == 0) revert();
                assembly {
                    revert(add(32, data), mload(data))
                }
            }
        }
    }

    function reserveERC1155(
        bytes32[] calldata merkleProof,
        bytes32 merkleRoot,
        uint256 minPrice,
        uint256 mintsPerUser,
        uint256 tokenId,
        address tokenAddress,
        address currency,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        (bool success, bytes memory data) = launchPlatform.delegatecall(
            abi.encodeWithSignature(
                "reserveERC1155(bytes32[],bytes32,uint256,uint256,uint256,address,address,uint8,bytes32,bytes32)",
                merkleProof,
                merkleRoot,
                minPrice,
                mintsPerUser,
                tokenId,
                tokenAddress,
                currency,
                v,
                r,
                s
            )
        );
        if (!success) {
            if (data.length == 0) revert();
            assembly {
                revert(add(32, data), mload(data))
            }
        }
    }

    function batchReserveERC1155(OdysseyLib.BatchMint calldata batch)
        public
        payable
    {
        for (uint256 i = 0; i < batch.tokenAddress.length; i++) {
            (bool success, bytes memory data) = launchPlatform.delegatecall(
                abi.encodeWithSignature(
                    "reserveERC1155(bytes32[],bytes32,uint256,uint256,uint256,address,address,uint8,bytes32,bytes32)",
                    batch.merkleProof[i],
                    batch.merkleRoot[i],
                    batch.minPrice[i],
                    batch.mintsPerUser[i],
                    batch.tokenId[i],
                    batch.tokenAddress[i],
                    batch.currency[i],
                    batch.v[i],
                    batch.r[i],
                    batch.s[i]
                )
            );
            if (!success) {
                if (data.length == 0) revert();
                assembly {
                    revert(add(32, data), mload(data))
                }
            }
        }
    }

    function setWhitelistStatus(address addr, bool active) public {
        if (msg.sender != ownerOf[addr]) {
            revert OdysseyRouter_Unauthorized();
        }
        (bool success, ) = launchPlatform.delegatecall(
            abi.encodeWithSignature(
                "setWhitelistStatus(address,bool)",
                addr,
                active
            )
        );
        if (!success) {
            revert OdysseyRouter_WhitelistUpdateFail();
        }
    }

    function ownerMint721(address token, address to) public {
        if (ownerOf[token] != msg.sender) {
            revert OdysseyRouter_Unauthorized();
        }
        (bool success, ) = launchPlatform.delegatecall(
            abi.encodeWithSignature("ownerMint721(address,address)", token, to)
        );
        if (!success) {
            revert OdysseyRouter_OwnerMintFailure();
        }
    }

    function ownerMint1155(
        uint256 id,
        uint256 amount,
        address token,
        address to
    ) public {
        if (ownerOf[token] != msg.sender) {
            revert OdysseyRouter_Unauthorized();
        }
        (bool success, ) = launchPlatform.delegatecall(
            abi.encodeWithSignature(
                "ownerMint1155(uint256,uint256,address,address)",
                id,
                amount,
                token,
                to
            )
        );
        if (!success) {
            revert OdysseyRouter_OwnerMintFailure();
        }
    }

    function setOwnerShip(address token, address newOwner) public {
        if (token == address(0)) {
            revert OdysseyRouter_BadTokenAddress();
        }
        if (newOwner == address(0)) {
            revert OdysseyRouter_BadOwnerAddress();
        }
        if (msg.sender == address(0)) {
            revert OdysseyRouter_BadSenderAddress();
        }
        if (ownerOf[token] != msg.sender) {
            revert OdysseyRouter_Unauthorized();
        }
        ownerOf[token] = newOwner;
    }

    function setRoyaltyRecipient(address token, address recipient) public {
        if (token == address(0)) {
            revert OdysseyRouter_BadTokenAddress();
        }
        if (recipient == address(0)) {
            revert OdysseyRouter_BadRecipientAddress();
        }
        if (msg.sender == address(0)) {
            revert OdysseyRouter_BadSenderAddress();
        }
        if (ownerOf[token] != msg.sender) {
            revert OdysseyRouter_Unauthorized();
        }
        royaltyRecipient[token] = recipient;
    }

    function setTreasury(address newTreasury) public {
        if (msg.sender != admin) {
            revert OdysseyRouter_Unauthorized();
        }
        if (msg.sender == address(0)) {
            revert OdysseyRouter_BadSenderAddress();
        }
        if (newTreasury == address(0)) {
            revert OdysseyRouter_BadTreasuryAddress();
        }
        treasury = newTreasury;
    }

    function setXP(address newXp) public {
        if (msg.sender != admin) {
            revert OdysseyRouter_Unauthorized();
        }
        if (msg.sender == address(0)) {
            revert OdysseyRouter_BadSenderAddress();
        }
        if (newXp == address(0)) {
            revert OdysseyRouter_BadTokenAddress();
        }
        xp = newXp;
    }

    function setAdmin(address newAdmin) public {
        if (msg.sender != admin) {
            revert OdysseyRouter_Unauthorized();
        }
        if (msg.sender == address(0)) {
            revert OdysseyRouter_BadSenderAddress();
        }
        if (newAdmin == address(0)) {
            revert OdysseyRouter_BadAdminAddress();
        }
        admin = newAdmin;
    }

    function setMaxSupply721(address token, uint256 amount) public {
        if (ownerOf[token] != msg.sender) {
            revert OdysseyRouter_Unauthorized();
        }
        maxSupply721[token] = amount;
    }

    function setMaxSupply1155(
        address token,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) public {
        if (ownerOf[token] != msg.sender) {
            revert OdysseyRouter_Unauthorized();
        }
        uint256 i;
        for (; i < tokenIds.length; ++i) {
            maxSupply1155[token][tokenIds[i]] = amounts[i];
        }
    }
}