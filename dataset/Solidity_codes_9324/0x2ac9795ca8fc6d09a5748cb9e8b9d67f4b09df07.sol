
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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


    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

pragma solidity ^0.8.1;

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
}

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

pragma solidity ^0.8.4;


error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerQueryForNonexistentToken();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error URIQueryForNonexistentToken();

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata {

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
        uint64 aux;
    }

    uint256 internal _currentIndex;

    uint256 internal _burnCounter;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) internal _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    function _startTokenId() internal view virtual returns (uint256) {

        return 0;
    }

    function totalSupply() public view returns (uint256) {

        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    function _totalMinted() internal view returns (uint256) {

        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberMinted);
    }

    function _numberBurned(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberBurned);
    }

    function _getAux(address owner) internal view returns (uint64) {

        return _addressData[owner].aux;
    }

    function _setAux(address owner, uint64 aux) internal {

        _addressData[owner].aux = aux;
    }

    function _ownershipOf(uint256 tokenId)
        internal
        view
        returns (TokenOwnership memory)
    {

        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr && curr < _currentIndex) {
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

        return _ownershipOf(tokenId).addr;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId)
        public
        view
        override
        returns (address)
    {

        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {

        if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {

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

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        _transfer(from, to, tokenId);
        if (
            to.isContract() &&
            !_checkContractOnERC721Received(from, to, tokenId, _data)
        ) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex &&
            !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, "");
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
            uint256 end = updatedIndex + quantity;

            if (safe && to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (
                        !_checkContractOnERC721Received(
                            address(0),
                            to,
                            updatedIndex++,
                            _data
                        )
                    ) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex != end);
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex != end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, from);

        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _burn(uint256 tokenId) internal virtual {

        _burn(tokenId, false);
    }

    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        _approve(address(0), tokenId, from);

        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

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

    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        try
            IERC721Receiver(to).onERC721Received(
                _msgSender(),
                from,
                tokenId,
                _data
            )
        returns (bytes4 retval) {
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

}

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
}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

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
pragma solidity ^0.8.12;

library utils {
    string internal constant NULL = "";

    function rgbaString(string memory _rgb, string memory _a)
        internal
        pure
        returns (string memory)
    {
        string memory formattedA = stringsEqual(_a, "100")
            ? "1"
            : string.concat("0.", _a);

        return string.concat("rgba(", _rgb, ",", formattedA, ")");
    }

    function rgba(
        uint256 _r,
        uint256 _g,
        uint256 _b,
        string memory _a
    ) internal pure returns (string memory) {
        string memory formattedA = stringsEqual(_a, "100")
            ? "1"
            : string.concat("0.", _a);

        return
            string.concat(
                "rgba(",
                utils.uint2str(_r),
                ",",
                utils.uint2str(_g),
                ",",
                utils.uint2str(_b),
                ",",
                formattedA,
                ")"
            );
    }

    function rgbaFromArray(uint256[3] memory _arr, string memory _a)
        internal
        pure
        returns (string memory)
    {
        return rgba(_arr[0], _arr[1], _arr[2], _a);
    }

    function stringsEqual(string memory _a, string memory _b)
        internal
        pure
        returns (bool)
    {
        return
            keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

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

    function getRandomInteger(
        string memory _name,
        uint256 _seed,
        uint256 _min,
        uint256 _max
    ) internal pure returns (uint256) {
        if (_max <= _min) return _min;
        return
            (uint256(keccak256(abi.encodePacked(_name, _seed))) %
                (_max - _min)) + _min;
    }

    function shuffle(uint256[3] memory _arr, uint256 _seed)
        internal
        view
        returns (uint256[3] memory)
    {
        for (uint256 i = 0; i < _arr.length; i++) {
            uint256 n = i +
                (uint256(keccak256(abi.encodePacked(block.timestamp, _seed))) %
                    (_arr.length - i));
            uint256 temp = _arr[n];
            _arr[n] = _arr[i];
            _arr[i] = temp;
        }

        return _arr;
    }
}
pragma solidity ^0.8.12;


interface SpectrumGeneratorInterface {
    function tokenURI(uint256 _tokenId, uint256 _seed)
        external
        view
        returns (string memory);
}
pragma solidity ^0.8.12;



contract KineticSpectrum is ERC721A, Ownable, ReentrancyGuard {
    uint256 public constant MAX_SPECTRUMS = 1111;
    uint256 public constant MAX_FOUNDER = 20;
    uint256 public constant PRICE = 0.03 ether;
    uint256 public constant FRIENDS_PRICE = 0.02 ether;

    bool public isFriendSale = false;
    bool public isPublicSale = false;

    bytes32 private root;

    mapping(uint256 => uint256) public seeds;
    mapping(address => uint256) public mintedAddress;
    mapping(address => bool) public founders;

    SpectrumGeneratorInterface public spectrumGenerator;

    constructor(SpectrumGeneratorInterface _spectrumGenerator)
        ERC721A("Kinetic Spectrum", "SPCTR")
    {
        spectrumGenerator = _spectrumGenerator;
    }

    function _createSeed(uint256 _tokenId, address _address)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _tokenId,
                        _address,
                        utils.getRandomInteger("spectrum", _tokenId, 0, 42069),
                        block.difficulty,
                        block.timestamp
                    )
                )
            );
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_tokenId < _totalMinted(), "TokenId not yet minted");
        return spectrumGenerator.tokenURI(_tokenId, seeds[_tokenId]);
    }

    function mint(uint256 _q) external payable nonReentrant {
        require(isPublicSale, "Sale has not started");
        require(_q > 0, "You should mint one");
        require(_currentIndex <= MAX_SPECTRUMS, "All metavatars minted");
        require(
            _currentIndex + _q <= MAX_SPECTRUMS,
            "Minting exceeds max supply"
        );
        require(PRICE * _q <= msg.value, "Min 0.03eth per Spectrum");
        uint256 currentTokenId = _currentIndex;

        _safeMint(msg.sender, _q);
        mintedAddress[msg.sender] += _q;

        for (uint8 i = 0; i < _q; i++) {
            seeds[currentTokenId] = _createSeed(currentTokenId, msg.sender);

            currentTokenId++;
        }
    }

    function friendMint(uint256 _q, bytes32[] calldata _merkleProof)
        external
        payable
        nonReentrant
    {
        require(isFriendSale, "Sale has not started or has finished");
        require(_q > 0, "You should mint one");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, root, leaf),
            "This address is not in friendlist"
        );
        require(_currentIndex <= MAX_SPECTRUMS, "All metavatars minted");
        require(
            _currentIndex + _q <= MAX_SPECTRUMS,
            "Minting exceeds max supply"
        );
        require(FRIENDS_PRICE * _q <= msg.value, "Min 0.02eth per Spectrum");

        uint256 currentTokenId = _currentIndex;

        _safeMint(msg.sender, _q);
        mintedAddress[msg.sender] += _q;

        for (uint8 i = 0; i < _q; i++) {
            seeds[currentTokenId] = _createSeed(currentTokenId, msg.sender);

            currentTokenId++;
        }
    }

    function foundersMint(uint256 _q) external payable nonReentrant {
        require(founders[msg.sender], "You are not a founder");
        require(_currentIndex <= MAX_SPECTRUMS, "All metavatars minted");
        require(
            _currentIndex + _q <= MAX_SPECTRUMS,
            "Minting exceeds max supply"
        );
        require(mintedAddress[msg.sender] + _q <= MAX_FOUNDER, "Max reached");
        uint256 currentTokenId = _currentIndex;

        _safeMint(msg.sender, _q);
        mintedAddress[msg.sender] += _q;

        for (uint8 i = 0; i < _q; i++) {
            seeds[currentTokenId] = _createSeed(currentTokenId, msg.sender);

            currentTokenId++;
        }
    }

    function airdrop(address _address) external onlyOwner {
        require(_currentIndex <= MAX_SPECTRUMS, "All metavatars minted");
        require(
            _currentIndex + 1 <= MAX_SPECTRUMS,
            "Minting exceeds max supply"
        );
        seeds[_currentIndex] = _createSeed(_currentIndex, msg.sender);
        mintedAddress[_address] += 1;
        _safeMint(_address, 1);
    }

    function addFounder(address _address) external onlyOwner {
        founders[_address] = true;
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function startFriendSale() external onlyOwner {
        isFriendSale = true;
    }

    function stopFriendSale() external onlyOwner {
        isFriendSale = false;
    }

    function startPublicSale() external onlyOwner {
        isPublicSale = true;
    }

    function stopPublicSale() external onlyOwner {
        isPublicSale = false;
    }

    function setRoot(bytes32 _root) external onlyOwner {
        root = _root;
    }

    function setGenerator(SpectrumGeneratorInterface _spectrumGenerator)
        external
        onlyOwner
    {
        spectrumGenerator = _spectrumGenerator;
    }
}
pragma solidity ^0.8.12;

library Base64 {
    string internal constant TABLE_ENCODE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    bytes internal constant TABLE_DECODE =
        hex"0000000000000000000000000000000000000000000000000000000000000000"
        hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
        hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
        hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        string memory table = TABLE_ENCODE;

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

                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(18, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(12, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(
                    resultPtr,
                    mload(add(tablePtr, and(shr(6, input), 0x3F)))
                )
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
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

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 4)
                let input := mload(dataPtr)

                let output := add(
                    add(
                        shl(
                            18,
                            and(
                                mload(add(tablePtr, and(shr(24, input), 0xFF))),
                                0xFF
                            )
                        ),
                        shl(
                            12,
                            and(
                                mload(add(tablePtr, and(shr(16, input), 0xFF))),
                                0xFF
                            )
                        )
                    ),
                    add(
                        shl(
                            6,
                            and(
                                mload(add(tablePtr, and(shr(8, input), 0xFF))),
                                0xFF
                            )
                        ),
                        and(mload(add(tablePtr, and(input, 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}
pragma solidity ^0.8.12;


interface SpectrumDetailsInterface {
    function getDetail(uint256 _detail)
        external
        view
        returns (string memory, string memory);
}
pragma solidity ^0.8.12;



contract SpectrumDetails is SpectrumDetailsInterface {
    string constant commonSingle =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M500 880C709.868 880 880 709.868 880 500C880 290.132 709.868 120 500 120C290.132 120 120 290.132 120 500C120 709.868 290.132 880 500 880ZM500 900C720.914 900 900 720.914 900 500C900 279.086 720.914 100 500 100C279.086 100 100 279.086 100 500C100 720.914 279.086 900 500 900Z" fill="white"/>';
    string constant commonDouble =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M880 500C880 709.868 709.868 880 500 880C290.132 880 120 709.868 120 500C120 290.132 290.132 120 500 120C709.868 120 880 290.132 880 500ZM900 500C900 720.914 720.914 900 500 900C279.086 900 100 720.914 100 500C100 279.086 279.086 100 500 100C720.914 100 900 279.086 900 500ZM760 500C760 643.594 643.594 760 500 760C356.406 760 240 643.594 240 500C240 356.406 356.406 240 500 240C643.594 240 760 356.406 760 500ZM780 500C780 654.64 654.64 780 500 780C345.36 780 220 654.64 220 500C220 345.36 345.36 220 500 220C654.64 220 780 345.36 780 500Z" fill="white"/>';
    string constant commonTriple =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M500 880C709.868 880 880 709.868 880 500C880 290.132 709.868 120 500 120C290.132 120 120 290.132 120 500C120 709.868 290.132 880 500 880ZM500 900C720.914 900 900 720.914 900 500C900 279.086 720.914 100 500 100C279.086 100 100 279.086 100 500C100 720.914 279.086 900 500 900ZM500 760C643.594 760 760 643.594 760 500C760 356.406 643.594 240 500 240C356.406 240 240 356.406 240 500C240 643.594 356.406 760 500 760ZM500 780C654.64 780 780 654.64 780 500C780 345.36 654.64 220 500 220C345.36 220 220 345.36 220 500C220 654.64 345.36 780 500 780ZM640 500C640 577.32 577.32 640 500 640C422.68 640 360 577.32 360 500C360 422.68 422.68 360 500 360C577.32 360 640 422.68 640 500ZM660 500C660 588.366 588.366 660 500 660C411.634 660 340 588.366 340 500C340 411.634 411.634 340 500 340C588.366 340 660 411.634 660 500Z" fill="white"/>';
    string constant rareSingle =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M500 960C754.051 960 960 754.051 960 500C960 245.949 754.051 40 500 40C245.949 40 40 245.949 40 500C40 754.051 245.949 960 500 960ZM500 980C765.097 980 980 765.097 980 500C980 234.903 765.097 20 500 20C234.903 20 20 234.903 20 500C20 765.097 234.903 980 500 980Z" fill="white"/>';
    string constant rareDouble =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M960 500C960 754.051 754.051 960 500 960C245.949 960 40 754.051 40 500C40 245.949 245.949 40 500 40C754.051 40 960 245.949 960 500ZM980 500C980 765.097 765.097 980 500 980C234.903 980 20 765.097 20 500C20 234.903 234.903 20 500 20C765.097 20 980 234.903 980 500ZM920 500C920 731.96 731.96 920 500 920C268.04 920 80 731.96 80 500C80 268.04 268.04 80 500 80C731.96 80 920 268.04 920 500ZM940 500C940 743.005 743.005 940 500 940C256.995 940 60 743.005 60 500C60 256.995 256.995 60 500 60C743.005 60 940 256.995 940 500Z" fill="white"/>';
    string constant rareTriple =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M500 960C754.051 960 960 754.051 960 500C960 245.949 754.051 40 500 40C245.949 40 40 245.949 40 500C40 754.051 245.949 960 500 960ZM500 980C765.097 980 980 765.097 980 500C980 234.903 765.097 20 500 20C234.903 20 20 234.903 20 500C20 765.097 234.903 980 500 980ZM500 920C731.96 920 920 731.96 920 500C920 268.04 731.96 80 500 80C268.04 80 80 268.04 80 500C80 731.96 268.04 920 500 920ZM500 940C743.005 940 940 743.005 940 500C940 256.995 743.005 60 500 60C256.995 60 60 256.995 60 500C60 743.005 256.995 940 500 940ZM880 500C880 709.868 709.868 880 500 880C290.132 880 120 709.868 120 500C120 290.132 290.132 120 500 120C709.868 120 880 290.132 880 500ZM900 500C900 720.914 720.914 900 500 900C279.086 900 100 720.914 100 500C100 279.086 279.086 100 500 100C720.914 100 900 279.086 900 500Z" fill="white"/>';
    string constant epicSingle =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M500 900C720.914 900 900 720.914 900 500C900 279.086 720.914 100 500 100C279.086 100 100 279.086 100 500C100 720.914 279.086 900 500 900ZM500 1000C776.142 1000 1000 776.142 1000 500C1000 223.858 776.142 0 500 0C223.858 0 0 223.858 0 500C0 776.142 223.858 1000 500 1000Z" fill="white"/>';
    string constant epicDouble =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M499 799C664.685 799 799 664.685 799 499C799 333.315 664.685 199 499 199C333.315 199 199 333.315 199 499C199 664.685 333.315 799 499 799ZM499 899C719.914 899 899 719.914 899 499C899 278.086 719.914 99 499 99C278.086 99 99 278.086 99 499C99 719.914 278.086 899 499 899Z" fill="white"/>';
    string constant epicTriple =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M800 500C800 665.685 665.685 800 500 800C334.315 800 200 665.685 200 500C200 334.315 334.315 200 500 200C665.685 200 800 334.315 800 500ZM900 500C900 720.914 720.914 900 500 900C279.086 900 100 720.914 100 500C100 279.086 279.086 100 500 100C720.914 100 900 279.086 900 500ZM601 501C601 556.228 556.228 601 501 601C445.772 601 401 556.228 401 501C401 445.772 445.772 401 501 401C556.228 401 601 445.772 601 501ZM701 501C701 611.457 611.457 701 501 701C390.543 701 301 611.457 301 501C301 390.543 390.543 301 501 301C611.457 301 701 390.543 701 501Z" fill="white"/>';
    string constant legendary =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M995 500C995 773.381 773.381 995 500 995C226.619 995 5 773.381 5 500C5 226.619 226.619 5 500 5C773.381 5 995 226.619 995 500ZM1000 500C1000 776.142 776.142 1000 500 1000C223.858 1000 0 776.142 0 500C0 223.858 223.858 0 500 0C776.142 0 1000 223.858 1000 500ZM500 975C762.335 975 975 762.335 975 500C975 237.665 762.335 25 500 25C237.665 25 25 237.665 25 500C25 762.335 237.665 975 500 975ZM500 980C765.097 980 980 765.097 980 500C980 234.903 765.097 20 500 20C234.903 20 20 234.903 20 500C20 765.097 234.903 980 500 980ZM500 790C660.163 790 790 660.163 790 500C790 339.837 660.163 210 500 210C339.837 210 210 339.837 210 500C210 660.163 339.837 790 500 790ZM500 840C687.777 840 840 687.777 840 500C840 312.223 687.777 160 500 160C312.223 160 160 312.223 160 500C160 687.777 312.223 840 500 840ZM500 955C751.29 955 955 751.29 955 500C955 248.71 751.29 45 500 45C248.71 45 45 248.71 45 500C45 751.29 248.71 955 500 955ZM500 960C754.051 960 960 754.051 960 500C960 245.949 754.051 40 500 40C245.949 40 40 245.949 40 500C40 754.051 245.949 960 500 960ZM935 500C935 740.244 740.244 935 500 935C259.756 935 65 740.244 65 500C65 259.756 259.756 65 500 65C740.244 65 935 259.756 935 500ZM940 500C940 743.005 743.005 940 500 940C256.995 940 60 743.005 60 500C60 256.995 256.995 60 500 60C743.005 60 940 256.995 940 500ZM500 915C729.198 915 915 729.198 915 500C915 270.802 729.198 85 500 85C270.802 85 85 270.802 85 500C85 729.198 270.802 915 500 915ZM500 920C731.96 920 920 731.96 920 500C920 268.04 731.96 80 500 80C268.04 80 80 268.04 80 500C80 731.96 268.04 920 500 920ZM895 500C895 718.152 718.152 895 500 895C281.848 895 105 718.152 105 500C105 281.848 281.848 105 500 105C718.152 105 895 281.848 895 500ZM900 500C900 720.914 720.914 900 500 900C279.086 900 100 720.914 100 500C100 279.086 279.086 100 500 100C720.914 100 900 279.086 900 500ZM500 875C707.107 875 875 707.107 875 500C875 292.893 707.107 125 500 125C292.893 125 125 292.893 125 500C125 707.107 292.893 875 500 875ZM500 880C709.868 880 880 709.868 880 500C880 290.132 709.868 120 500 120C290.132 120 120 290.132 120 500C120 709.868 290.132 880 500 880ZM855 500C855 696.061 696.061 855 500 855C303.939 855 145 696.061 145 500C145 303.939 303.939 145 500 145C696.061 145 855 303.939 855 500ZM860 500C860 698.823 698.823 860 500 860C301.177 860 140 698.823 140 500C140 301.177 301.177 140 500 140C698.823 140 860 301.177 860 500Z" fill="white"/>';
    string constant impossible =
        '<path fill-rule="evenodd" clip-rule="evenodd" d="M910 500C910 726.437 726.437 910 500 910C273.563 910 90 726.437 90 500C90 273.563 273.563 90 500 90C726.437 90 910 273.563 910 500ZM990 500C990 770.62 770.62 990 500 990C229.38 990 10 770.62 10 500C10 229.38 229.38 10 500 10C770.62 10 990 229.38 990 500ZM880 500C880 709.868 709.868 880 500 880C290.132 880 120 709.868 120 500C120 290.132 290.132 120 500 120C709.868 120 880 290.132 880 500ZM900 500C900 720.914 720.914 900 500 900C279.086 900 100 720.914 100 500C100 279.086 279.086 100 500 100C720.914 100 900 279.086 900 500ZM500 700C610.457 700 700 610.457 700 500C700 389.543 610.457 300 500 300C389.543 300 300 389.543 300 500C300 610.457 389.543 700 500 700ZM500 720C621.503 720 720 621.503 720 500C720 378.498 621.503 280 500 280C378.497 280 280 378.498 280 500C280 621.503 378.497 720 500 720ZM550 500C550 527.614 527.614 550 500 550C472.386 550 450 527.614 450 500C450 472.386 472.386 450 500 450C527.614 450 550 472.386 550 500ZM690 500C690 604.934 604.934 690 500 690C395.066 690 310 604.934 310 500C310 395.066 395.066 310 500 310C604.934 310 690 395.066 690 500ZM500 220C511.046 220 520 211.046 520 200C520 188.954 511.046 180 500 180C488.954 180 480 188.954 480 200C480 211.046 488.954 220 500 220ZM537.75 213.259C532.28 228.834 517.444 240 500 240C482.557 240 467.721 228.834 462.25 213.26C460.997 229.72 449.557 244.345 432.708 248.859C415.858 253.374 398.637 246.428 389.322 232.799C392.373 249.022 385.108 266.111 370 274.833C354.893 283.556 336.461 281.303 323.936 270.549C331.082 285.43 328.488 303.817 316.152 316.153C303.818 328.487 285.432 331.082 270.552 323.938C281.304 336.463 283.555 354.893 274.834 370C266.111 385.107 249.022 392.372 232.798 389.321C246.427 398.636 253.374 415.857 248.859 432.707C244.344 449.557 229.719 460.997 213.259 462.25C228.834 467.72 240 482.556 240 500C240 517.444 228.834 532.28 213.259 537.75C229.719 539.003 244.345 550.443 248.86 567.293C253.374 584.143 246.428 601.363 232.8 610.678C249.023 607.628 266.111 614.893 274.833 630C283.555 645.106 281.303 663.537 270.551 676.061C285.432 668.916 303.819 671.511 316.153 683.846C328.488 696.181 331.083 714.568 323.938 729.449C336.462 718.697 354.893 716.445 369.999 725.167C385.107 733.889 392.372 750.979 389.321 767.202C398.635 753.573 415.857 746.626 432.707 751.141C449.557 755.656 460.998 770.282 462.25 786.741C467.72 771.166 482.556 759.998 500.001 759.998C517.445 759.998 532.28 771.164 537.751 786.738C539.004 770.279 550.444 755.655 567.293 751.14C584.143 746.626 601.364 753.572 610.678 767.2C607.628 750.977 614.893 733.889 630 725.167C645.108 716.444 663.539 718.697 676.064 729.45C668.917 714.569 671.512 696.181 683.847 683.846C696.182 671.511 714.568 668.916 729.448 676.06C718.697 663.536 716.445 645.106 725.167 630C733.889 614.893 750.976 607.628 767.198 610.677C753.571 601.362 746.626 584.142 751.141 567.294C755.656 550.444 770.281 539.004 786.741 537.751C771.166 532.281 760 517.445 760 500.001C760 482.556 771.167 467.72 786.742 462.25C770.281 460.998 755.655 449.558 751.14 432.708C746.625 415.858 753.571 398.638 767.199 389.323C750.976 392.372 733.889 385.107 725.167 370.001C716.445 354.893 718.698 336.461 729.452 323.936C714.571 331.082 696.183 328.488 683.848 316.152C671.513 303.818 668.918 285.432 676.063 270.551C663.538 281.303 645.107 283.555 630 274.834C614.893 266.111 607.628 249.023 610.678 232.799C601.364 246.428 584.143 253.375 567.293 248.86C550.443 244.345 539.003 229.719 537.75 213.259ZM217.655 616.951C200.499 628.623 195.009 651.74 205.551 670C216.093 688.26 238.859 695.063 257.545 686.042C243.996 701.757 244.676 725.506 259.585 740.415C274.493 755.323 298.243 756.003 313.958 742.454C304.936 761.141 311.739 783.906 329.999 794.449C348.26 804.991 371.378 799.5 383.05 782.342C379.171 802.728 391.635 822.958 412.002 828.415C432.369 833.872 453.278 822.585 460.111 802.991C461.642 823.685 478.916 839.998 500.001 839.998C521.085 839.998 538.359 823.686 539.891 802.994C546.725 822.585 567.633 833.871 587.999 828.414C608.365 822.957 620.829 802.729 616.951 782.344C628.624 799.5 651.74 804.991 670 794.449C688.261 783.906 695.064 761.139 686.041 742.452C701.756 756.003 725.507 755.323 740.416 740.414C755.324 725.506 756.004 701.757 742.456 686.042C761.143 695.062 783.907 688.259 794.449 670C804.991 651.741 799.501 628.625 782.347 616.952C802.731 620.828 822.958 608.365 828.415 587.999C833.872 567.633 822.585 546.725 802.993 539.89C823.686 538.36 840 521.085 840 500.001C840 478.916 823.686 461.641 802.992 460.111C822.584 453.277 833.871 432.368 828.414 412.002C822.957 391.636 802.73 379.173 782.346 383.049C799.501 371.377 804.991 348.26 794.449 330.001C783.906 311.74 761.14 304.937 742.453 313.96C756.005 298.245 755.326 274.493 740.416 259.584C725.507 244.675 701.758 243.995 686.043 257.545C695.063 238.858 688.26 216.094 670 205.552C651.74 195.009 628.623 200.5 616.951 217.657C620.828 197.272 608.365 177.043 587.998 171.586C567.632 166.129 546.724 177.415 539.89 197.007C538.359 176.314 521.085 160 500 160C478.916 160 461.642 176.313 460.11 197.006C453.275 177.414 432.368 166.128 412.002 171.585C391.636 177.042 379.172 197.271 383.05 217.656C371.378 200.5 348.261 195.009 330 205.551C311.74 216.094 304.937 238.86 313.959 257.547C298.244 243.996 274.493 244.675 259.584 259.584C244.675 274.493 243.995 298.242 257.544 313.957C238.858 304.937 216.094 311.74 205.552 330C195.009 348.26 200.501 371.378 217.658 383.05C197.272 379.171 177.042 391.635 171.585 412.002C166.128 432.368 177.415 453.276 197.007 460.111C176.314 461.641 160 478.916 160 500C160 521.085 176.314 538.359 197.007 539.89C177.415 546.724 166.128 567.632 171.586 587.999C177.043 608.365 197.271 620.828 217.655 616.951ZM726.274 302.01C718.464 309.821 705.8 309.821 697.99 302.01C690.179 294.2 690.179 281.536 697.99 273.726C705.8 265.915 718.464 265.915 726.274 273.726C734.084 281.536 734.084 294.2 726.274 302.01ZM780 500.001C780 511.046 788.954 520.001 800 520.001C811.046 520.001 820 511.046 820 500.001C820 488.955 811.046 480.001 800 480.001C788.954 480.001 780 488.955 780 500.001ZM697.99 726.272C690.179 718.462 690.179 705.798 697.99 697.988C705.8 690.177 718.463 690.177 726.274 697.988C734.084 705.798 734.084 718.462 726.274 726.272C718.463 734.083 705.8 734.083 697.99 726.272ZM500.001 819.998C511.047 819.998 520.001 811.044 520.001 799.998C520.001 788.953 511.047 779.998 500.001 779.998C488.955 779.998 480.001 788.953 480.001 799.998C480.001 811.044 488.955 819.998 500.001 819.998ZM302.011 726.272C294.201 734.083 281.538 734.083 273.727 726.272C265.917 718.462 265.917 705.799 273.727 697.988C281.537 690.178 294.201 690.178 302.011 697.988C309.822 705.799 309.822 718.462 302.011 726.272ZM180 500C180 511.046 188.954 520 200 520C211.046 520 220 511.046 220 500C220 488.955 211.046 480 200 480C188.954 480 180 488.955 180 500ZM273.726 302.011C265.915 294.2 265.915 281.537 273.726 273.726C281.536 265.916 294.2 265.916 302.01 273.726C309.821 281.537 309.821 294.2 302.01 302.011C294.2 309.821 281.536 309.821 273.726 302.011ZM360 257.513C369.566 251.99 372.844 239.758 367.321 230.192C361.798 220.626 349.566 217.349 340 222.872C330.435 228.395 327.157 240.626 332.68 250.192C338.203 259.758 350.435 263.036 360 257.513ZM596.964 215.399C594.105 226.068 583.139 232.4 572.469 229.541C561.8 226.682 555.468 215.716 558.327 205.046C561.186 194.377 572.153 188.045 582.822 190.904C593.491 193.763 599.823 204.73 596.964 215.399ZM742.488 360.001C748.011 369.566 760.242 372.844 769.808 367.321C779.374 361.798 782.652 349.566 777.129 340.001C771.606 330.435 759.374 327.157 749.808 332.68C740.242 338.203 736.965 350.435 742.488 360.001ZM784.601 596.965C773.932 594.106 767.6 583.139 770.459 572.47C773.318 561.801 784.285 555.469 794.954 558.328C805.623 561.187 811.955 572.153 809.096 582.823C806.237 593.492 795.271 599.824 784.601 596.965ZM660 777.128C669.566 771.605 672.844 759.373 667.321 749.807C661.798 740.242 649.566 736.964 640 742.487C630.435 748.01 627.157 760.242 632.68 769.807C638.203 779.373 650.435 782.651 660 777.128ZM441.673 794.954C438.814 805.624 427.848 811.955 417.178 809.096C406.509 806.238 400.177 795.271 403.036 784.602C405.895 773.932 416.862 767.601 427.531 770.459C438.2 773.318 444.532 784.285 441.673 794.954ZM222.871 660C228.394 669.566 240.626 672.844 250.192 667.321C259.758 661.798 263.035 649.566 257.512 640C251.99 630.434 239.758 627.157 230.192 632.68C220.626 638.203 217.349 650.434 222.871 660ZM205.046 441.673C194.376 438.814 188.045 427.848 190.904 417.178C193.762 406.509 204.729 400.177 215.398 403.036C226.068 405.895 232.399 416.862 229.541 427.531C226.682 438.2 215.715 444.532 205.046 441.673ZM257.513 360C263.036 350.434 259.759 338.202 250.193 332.679C240.627 327.156 228.395 330.434 222.872 340C217.349 349.565 220.627 361.797 230.193 367.32C239.759 372.843 251.99 369.565 257.513 360ZM441.674 205.046C444.532 215.715 438.201 226.682 427.531 229.541C416.862 232.4 405.895 226.068 403.036 215.399C400.178 204.729 406.509 193.763 417.179 190.904C427.848 188.045 438.815 194.377 441.674 205.046ZM640 257.513C649.566 263.036 661.798 259.758 667.321 250.193C672.844 240.627 669.566 228.395 660 222.872C650.435 217.349 638.203 220.627 632.68 230.193C627.157 239.758 630.435 251.99 640 257.513ZM794.954 441.673C784.284 444.532 773.318 438.201 770.459 427.531C767.6 416.862 773.932 405.895 784.601 403.036C795.27 400.177 806.237 406.509 809.096 417.178C811.955 427.848 805.623 438.814 794.954 441.673ZM777.129 660C782.651 650.434 779.374 638.202 769.808 632.679C760.242 627.156 748.01 630.434 742.487 640C736.965 649.565 740.242 661.797 749.808 667.32C759.374 672.843 771.606 669.565 777.129 660ZM596.965 784.601C599.823 795.27 593.492 806.237 582.822 809.096C572.153 811.955 561.186 805.623 558.328 794.954C555.469 784.284 561.8 773.318 572.47 770.459C583.139 767.6 594.106 773.932 596.965 784.601ZM339.999 777.128C349.565 782.651 361.797 779.373 367.32 769.807C372.843 760.242 369.565 748.01 359.999 742.487C350.434 736.964 338.202 740.242 332.679 749.807C327.156 759.373 330.434 771.605 339.999 777.128ZM215.399 596.964C204.73 599.823 193.763 593.492 190.904 582.822C188.045 572.153 194.377 561.186 205.046 558.327C215.715 555.468 226.682 561.8 229.541 572.469C232.4 583.139 226.068 594.105 215.399 596.964Z" fill="white"/><animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 500 500" to="360 500 500" dur="60s" additive="sum" repeatCount="indefinite" />';
    string constant founder =
        '<path d="M1001 501H901C901 280.086 721.914 101 501 101C280.086 101 101 280.086 101 501H1C1 224.858 224.858 1 501 1C777.142 1 1001 224.858 1001 501Z" fill="white"/><path fill-rule="evenodd" clip-rule="evenodd" d="M396 501H296C296 614.218 387.782 706 501 706C614.218 706 706 614.218 706 501H606C606 443.01 558.99 396 501 396C443.01 396 396 443.01 396 501ZM396 501C396 558.99 443.01 606 501 606C558.99 606 606 558.99 606 501H396Z" fill="white"/><path fill-rule="evenodd" clip-rule="evenodd" d="M201 501H101C101 721.914 280.086 901 501 901C721.914 901 901 721.914 901 501H801C801 335.315 666.685 201 501 201C335.315 201 201 335.315 201 501ZM296 501H201C201 666.685 335.315 801 501 801C666.685 801 801 666.685 801 501H706C706 387.782 614.218 296 501 296C387.782 296 296 387.782 296 501Z" fill="white"/><animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 500 500" to="360 500 500" dur="120s" additive="sum" repeatCount="indefinite" />';

    function getDetail(uint256 _d)
        external
        pure
        returns (string memory, string memory)
    {
        string memory detail;
        string memory name;

        if (_d < 2) {
            detail = "";
            name = "Perfect";
        } else if (_d < 4) {
            detail = impossible;
            name = "Impossible";
        } else if (_d < 8) {
            detail = legendary;
            name = "Legendary";
        } else if (_d < 15) {
            detail = epicTriple;
            name = "Epic Triple";
        } else if (_d < 23) {
            detail = epicDouble;
            name = "Epic Double";
        } else if (_d < 29) {
            detail = epicSingle;
            name = "Epic Single";
        } else if (_d < 38) {
            detail = rareTriple;
            name = "Rare Triple";
        } else if (_d < 47) {
            detail = rareDouble;
            name = "Rare Double";
        } else if (_d < 56) {
            detail = rareSingle;
            name = "Rare Single";
        } else if (_d < 68) {
            detail = commonTriple;
            name = "Common Triple";
        } else if (_d < 80) {
            detail = commonDouble;
            name = "Common Double";
        } else if (_d < 92) {
            detail = commonSingle;
            name = "Common Single";
        } else if (_d == 92) {
            detail = founder;
            name = "Founder: himlate.eth";
        } else if (_d == 93) {
            detail = founder;
            name = "Founder: biron.eth";
        }

        return (
            string.concat(
                '<g style="mix-blend-mode:difference">',
                detail,
                "</g>"
            ),
            name
        );
    }
}
pragma solidity ^0.8.12;

library svg {
    function g(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {
        return el("g", _props, _children);
    }

    function defs(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {
        return el("defs", _props, _children);
    }

    function circle(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {
        return el("circle", _props, _children);
    }

    function radialGradient(string memory _props, string memory _children)
        internal
        pure
        returns (string memory)
    {
        return el("radialGradient", _props, _children);
    }

    function gradientStop(
        uint256 offset,
        string memory stopColor,
        string memory _props
    ) internal pure returns (string memory) {
        return
            el(
                "stop",
                string.concat(
                    prop("stop-color", stopColor),
                    " ",
                    prop("offset", string.concat(utils.uint2str(offset), "%")),
                    " ",
                    _props
                ),
                utils.NULL
            );
    }

    function animateTransform(string memory _props)
        internal
        pure
        returns (string memory)
    {
        return el("animateTransform", _props, utils.NULL);
    }

    function el(
        string memory _tag,
        string memory _props,
        string memory _children
    ) internal pure returns (string memory) {
        return
            string.concat(
                "<",
                _tag,
                " ",
                _props,
                ">",
                _children,
                "</",
                _tag,
                ">"
            );
    }

    function prop(string memory _key, string memory _val)
        internal
        pure
        returns (string memory)
    {
        return string.concat(_key, "=", '"', _val, '" ');
    }
}
pragma solidity ^0.8.12;



contract SpectrumGenerator is SpectrumGeneratorInterface {
    uint256 private MIN_LAYERS = 2;
    uint256 private MAX_LAYERS = 6;
    uint256 private MIN_DURATION = 10;
    uint256 private MAX_DURATION = 30;

    SpectrumDetailsInterface public spectrumDetails;

    mapping(uint256 => string) private _tokenURIs;

    uint256 public tokenCounter;

    constructor(SpectrumDetailsInterface _spectrumDetails) {
        spectrumDetails = _spectrumDetails;
    }

    function createLayer(
        string memory _name,
        string memory _duration,
        string memory _rgb
    ) internal pure returns (string memory) {
        return
            string.concat(
                svg.g(
                    string.concat(
                        svg.prop("style", "mix-blend-mode: multiply")
                    ),
                    string.concat(
                        svg.circle(
                            string.concat(
                                svg.prop("cx", "500"),
                                svg.prop("cy", "500"),
                                svg.prop("r", "500"),
                                svg.prop(
                                    "fill",
                                    string.concat("url(#", _name, ")")
                                )
                            ),
                            utils.NULL
                        ),
                        svg.animateTransform(
                            string.concat(
                                svg.prop("attributeType", "xml"),
                                svg.prop("attributeName", "transform"),
                                svg.prop("type", "rotate"),
                                svg.prop("from", "360 500 500"),
                                svg.prop("to", "0 500 500"),
                                svg.prop("dur", string.concat(_duration, "s")),
                                svg.prop("additive", "sum"),
                                svg.prop("repeatCount", "indefinite")
                            )
                        )
                    )
                ),
                svg.defs(
                    utils.NULL,
                    svg.radialGradient(
                        string.concat(
                            svg.prop("id", _name),
                            svg.prop("cx", "0"),
                            svg.prop("cy", "0"),
                            svg.prop("r", "1"),
                            svg.prop("gradientUnits", "userSpaceOnUse"),
                            svg.prop(
                                "gradientTransform",
                                "translate(500) rotate(90) scale(1000)"
                            )
                        ),
                        string.concat(
                            svg.gradientStop(0, _rgb, utils.NULL),
                            svg.gradientStop(
                                100,
                                _rgb,
                                string.concat(svg.prop("stop-opacity", "0"))
                            )
                        )
                    )
                )
            );
    }

    function _getLayers(uint256 seed, uint256 d)
        private
        view
        returns (string memory, string memory)
    {
        uint256 i;
        uint256 iterations = utils.getRandomInteger(
            "iterations",
            seed,
            MIN_LAYERS,
            MAX_LAYERS
        );
        string memory layers;
        string memory layersMeta;

        while (i < iterations) {
            string memory id = utils.uint2str(i);
            uint256 duration = utils.getRandomInteger(
                id,
                seed,
                MIN_DURATION,
                MAX_DURATION
            );
            uint256 r = utils.getRandomInteger(
                string.concat("r_", id),
                seed,
                0,
                255
            );
            uint256[3] memory arr = [r, 0, 255];
            uint256[3] memory shuffledArr = utils.shuffle(arr, i + d);

            layers = string.concat(
                layers,
                createLayer(
                    string.concat("layer_", id),
                    utils.uint2str(duration),
                    string.concat(
                        "rgb(",
                        utils.uint2str(shuffledArr[0]),
                        ",",
                        utils.uint2str(shuffledArr[1]),
                        ",",
                        utils.uint2str(shuffledArr[2]),
                        ")"
                    )
                )
            );

            layersMeta = string.concat(
                layersMeta,
                _createAttribute(
                    "Layer Color",
                    string.concat(
                        utils.uint2str(shuffledArr[0]),
                        ",",
                        utils.uint2str(shuffledArr[1]),
                        ",",
                        utils.uint2str(shuffledArr[2])
                    ),
                    true
                ),
                _createAttribute("Layer Speed", utils.uint2str(duration), true)
            );

            i++;
        }

        return (
            layers,
            string.concat(
                _createAttribute("Layers", utils.uint2str(iterations), true),
                layersMeta
            )
        );
    }

    function _createSvg(uint256 _seed, uint256 _tokenId)
        internal
        view
        returns (string memory, string memory)
    {
        uint256 d = _tokenId < 2
            ? 92 + _tokenId
            : utils.getRandomInteger("_detail", _seed, 1, 92);
        (string memory detail, string memory detailName) = spectrumDetails
            .getDetail(d);
        (string memory layers, string memory layersMeta) = _getLayers(_seed, d);

        string memory stringSvg = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1000 1000">',
            svg.circle(
                string.concat(
                    svg.prop("cx", "500"),
                    svg.prop("cy", "500"),
                    svg.prop("r", "500"),
                    svg.prop("fill", "#fff")
                ),
                utils.NULL
            ),
            layers,
            detail,
            "</svg>"
        );

        return (
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(stringSvg))
                )
            ),
            string.concat(
                '"attributes":[',
                _createAttribute("Detail", detailName, false),
                layersMeta,
                "]"
            )
        );
    }

    function _createAttribute(
        string memory _type,
        string memory _value,
        bool _leadingComma
    ) internal pure returns (string memory) {
        return
            string.concat(
                _leadingComma ? "," : "",
                '{"trait_type":"',
                _type,
                '","value":"',
                _value,
                '"}'
            );
    }

    function _prepareMetadata(
        uint256 tokenId,
        string memory image,
        string memory attributes
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Spectrum #',
                                utils.uint2str(tokenId),
                                '", "description":"Kinetic Spectrums is a collection of dynamic, ever changing artworks stored on the Ethereum Network. Each Spectrum is made by combining 2 to 5 layers of color. These layers multiply with each other and slowly rotate at a different speeds meaning your NFT is constantly changing color and evolving the longer you watch it.", ',
                                attributes,
                                ', "image":"',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(uint256 _tokenId, uint256 _seed)
        external
        view
        returns (string memory)
    {
        (string memory svg64, string memory attributes) = _createSvg(
            _seed,
            _tokenId
        );

        return _prepareMetadata(_tokenId, svg64, attributes);
    }
}
