pragma solidity >=0.8.0;

abstract contract ERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);


    uint256 public totalSupply;

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
            msg.sender == from || msg.sender == getApproved[id] || isApprovedForAll[from][msg.sender],
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


    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }


    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(ownerOf[id] == address(0), "ALREADY_MINTED");

        unchecked {
            totalSupply++;

            balanceOf[to]++;
        }

        ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = ownerOf[id];

        require(ownerOf[id] != address(0), "NOT_MINTED");

        unchecked {
            totalSupply--;

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

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}

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
}
pragma solidity ^0.8.14;


error MintedOut();
error AuctionNotStarted();
error MintingTooMany();
error ValueTooLow();
error NotMintlisted();
error UnauthorizedEvolution();
error UnknownEvolution();


contract Pixelmon is ERC721, Ownable {

    using Strings for uint256;


    uint constant public provenanceHash = 0x9912e067bd3802c3b007ce40b6c125160d2ccb5352d199e20c092fdc17af8057;

    address constant gnosisSafeAddress = 0xF6BD9Fc094F7aB74a846E5d82a822540EE6c6971;

    uint constant auctionSupply = 7750 + 330;

    uint constant secondEvolutionOffset = 10005;
    uint constant thirdEvolutionOffset = secondEvolutionOffset + 4013;
    uint constant fourthEvolutionOffset = thirdEvolutionOffset + 1206;


    uint secondEvolutionSupply = 0;
    uint thirdEvolutionSupply = 0;
    uint fourthEvolutionSupply = 0;

    address public serumContract;

    mapping(address => bool) public mintlisted;


    uint256 constant public auctionStartPrice = 3 ether;

    uint256 constant public auctionStartTime = 1644256800;

    uint256 public mintlistPrice = 0.75 ether;


    string public baseURI;


    constructor(string memory _baseURI) ERC721("Pixelmon", "PXLMN") {
        baseURI = _baseURI;
        unchecked {
            balanceOf[gnosisSafeAddress] += 330;
            totalSupply += 330;
            for (uint256 i = 0; i < 330; i++) {
                ownerOf[i] = gnosisSafeAddress;
                emit Transfer(address(0), gnosisSafeAddress, i);
            }
        }
    }


    function setBaseURI(string memory _baseURI) public onlyOwner {

        baseURI = _baseURI;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {

        return string(abi.encodePacked(baseURI, id.toString()));
    }


    function validCalculatedTokenPrice() private view returns (uint) {

        uint priceReduction = ((block.timestamp - auctionStartTime) / 10 minutes) * 0.1 ether;
        return auctionStartPrice >= priceReduction ? (auctionStartPrice - priceReduction) : 0;
    }

    function getCurrentTokenPrice() public view returns (uint256) {

        return max(validCalculatedTokenPrice(), 0.2 ether);
    }

    function auction(bool mintingTwo) public payable {

        if(block.timestamp < auctionStartTime || block.timestamp > auctionStartTime + 1 days) revert AuctionNotStarted();

        uint count = mintingTwo ? 2 : 1;
        uint price = getCurrentTokenPrice();

        if(totalSupply + count > auctionSupply) revert MintedOut();
        if(balanceOf[msg.sender] + count > 2) revert MintingTooMany();
        if(msg.value < price * count) revert ValueTooLow();

        mintingTwo ? _mintTwo(msg.sender) : _mint(msg.sender, totalSupply);
    }
    
    function _mintTwo(address to) internal {

        require(to != address(0), "INVALID_RECIPIENT");
        require(ownerOf[totalSupply] == address(0), "ALREADY_MINTED");
        uint currentId = totalSupply;

        unchecked {
            totalSupply += 2;
            balanceOf[to] += 2;
            ownerOf[currentId] = to;
            ownerOf[currentId + 1] = to;
            emit Transfer(address(0), to, currentId);
            emit Transfer(address(0), to, currentId + 1);
        }
    }



    function setMintlistPrice(uint256 price) public onlyOwner {

        mintlistPrice = price;
    }

    function mintlistUser(address user) public onlyOwner {

        mintlisted[user] = true;
    }

    function mintlistUsers(address[] calldata users) public onlyOwner {

        for (uint256 i = 0; i < users.length; i++) {
           mintlisted[users[i]] = true; 
        }
    }

    function mintlistMint() public payable {

        if(totalSupply >= secondEvolutionOffset) revert MintedOut();
        if(!mintlisted[msg.sender]) revert NotMintlisted();
        if(msg.value < mintlistPrice) revert ValueTooLow();

        mintlisted[msg.sender] = false;
        _mint(msg.sender, totalSupply);
    }

    function withdraw() public onlyOwner {

        (bool success, ) = gnosisSafeAddress.call{value: address(this).balance}("");
        require(success);
    }


    function rollOverPixelmons(address[] calldata addresses) public onlyOwner {

        if(totalSupply + addresses.length > secondEvolutionOffset) revert MintedOut();

        for (uint256 i = 0; i < addresses.length; i++) {
            _mint(msg.sender, totalSupply);
        }
    }


    function setSerumContract(address _serumContract) public onlyOwner {

        serumContract = _serumContract; 
    }

    function mintEvolvedPixelmon(address receiver, uint evolutionStage) public payable {

        if(msg.sender != serumContract) revert UnauthorizedEvolution();

        if (evolutionStage == 2) {
            if(secondEvolutionSupply >= 4013) revert MintedOut();
            _mint(receiver, secondEvolutionOffset + secondEvolutionSupply);
            unchecked {
                secondEvolutionSupply++;
            }
        } else if (evolutionStage == 3) {
            if(thirdEvolutionSupply >= 1206) revert MintedOut();
            _mint(receiver, thirdEvolutionOffset + thirdEvolutionSupply);
            unchecked {
                thirdEvolutionSupply++;
            }
        } else if (evolutionStage == 4) {
            if(fourthEvolutionSupply >= 33) revert MintedOut();
            _mint(receiver, fourthEvolutionOffset + fourthEvolutionSupply);
            unchecked {
                fourthEvolutionSupply++;
            }
        } else  {
            revert UnknownEvolution();
        }
    }



    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

}
pragma solidity >=0.8.0;

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

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
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

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

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
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
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


    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
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
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
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
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
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
pragma solidity ^0.8.14;


error InvalidNonce();
error InvalidOwner();
error InvalidEvolution();
error InvalidVoucher();
error NotEnoughEther();

contract EvolutionSerum is ERC1155, Ownable, ERC1155TokenReceiver {

    using Strings for uint256;


    event Evolution(uint indexed tokenId, uint evolutionStage);

    
    address constant public evolutionSigner = 0x00000001DEA29D000f2e99100C503bf1544Da95d;
    address constant public gnosisSafeAddress = 0x813F10aBA9624D2f4b3130a1EcD26da2BB2d09D4;

    string constant public name = "Evolution Serum";
    string constant public symbol = "ES";


    Pixelmon creatures;

    mapping(uint => uint) public serumPrices;
    mapping(address => uint) public nonces;
    mapping(bytes32 => bool) public usedVouchers;

    string baseURI;


    constructor(address creatureAddress, string memory _baseURI) {
        creatures = Pixelmon(creatureAddress);
        baseURI = _baseURI;
    }


    modifier correctNonce(uint nonce) {

        if(nonce != nonces[msg.sender]) revert InvalidNonce();
        nonces[msg.sender]++;
        _;
    }


    function setBaseURI(string memory _baseURI) public onlyOwner {

        baseURI = _baseURI;
    }

    function setSerumPrice(uint serumId, uint price) public onlyOwner {

        serumPrices[serumId] = price;
    }

    function uri(uint256 id) public view override returns (string memory) {

        return string(abi.encodePacked(baseURI, id.toString()));
    }


    function claim(uint serumId, uint count, bytes memory signature) public payable {

        if(msg.value < count * serumPrices[serumId]) revert NotEnoughEther();
        if(!validMint(msg.sender, serumId, count, signature)) revert InvalidVoucher();
        _mint(msg.sender, serumId, count, "");
    }

    function airdrop(uint serumId, address[] calldata users) public onlyOwner {

        for (uint256 i = 0; i < users.length; i++) {
           _mint(users[i], serumId, 1, ""); 
        }
    }

    function ownerMint(uint id, uint amount, address receiver) public onlyOwner {

        _mint(receiver, id, amount, "");
    }


    function evolve(uint tokenId, uint serumId, uint nonce, uint evolutionStage, bytes memory signature) public correctNonce(nonce) {

        if(creatures.ownerOf(tokenId) != msg.sender) revert InvalidOwner();
        if(!validEvolution(msg.sender, serumId, tokenId, evolutionStage, nonce, signature)) revert InvalidEvolution();
        _burn(msg.sender, serumId, 1);
        creatures.mintEvolvedPixelmon(msg.sender, evolutionStage);
        emit Evolution(tokenId, evolutionStage);
    }


    function validMint(address user, uint serumId, uint count, bytes memory signature) public returns (bool) {

        bytes32 messageHash = keccak256(abi.encodePacked(user, serumId, count));
        if(usedVouchers[messageHash]) return false;

        usedVouchers[messageHash] = true;
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == evolutionSigner;
    }

    function validEvolution(address user, uint serumId, uint creatureId, uint evolutionStage, uint nonce, bytes memory signature)
        public
        pure
        returns (bool)
    {

        bytes32 messageHash = keccak256(abi.encodePacked(user, serumId, creatureId, evolutionStage, nonce));
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == evolutionSigner;
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        private
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) private pure returns (address) {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        require(sig.length == 65, "sig invalid");

        assembly {

            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }

    function withdraw() public onlyOwner {

        (bool success, ) = gnosisSafeAddress.call{value: address(this).balance}("");
        require(success);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4) {

        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external returns (bytes4) {

        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}
