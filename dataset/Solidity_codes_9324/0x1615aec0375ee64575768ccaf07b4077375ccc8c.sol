


pragma solidity >=0.7.0 <0.9.0;

library KWWUtils{


  uint constant DAY_IN_SECONDS = 86400;
  uint constant HOUR_IN_SECONDS = 3600;
  uint constant WEEK_IN_SECONDS = DAY_IN_SECONDS * 7;

  function pack(uint32 a, uint32 b) external pure returns(uint64) {

        return (uint64(a) << 32) | uint64(b);
  }

  function unpack(uint64 c) external pure returns(uint32 a, uint32 b) {

        a = uint32(c >> 32);
        b = uint32(c);
  }

  function random(uint256 seed) external view returns (uint256) {

    return uint256(keccak256(abi.encodePacked(
        tx.origin,
        blockhash(block.number - 1),
        block.difficulty,
        block.timestamp,
        seed
    )));
  }


  function getWeekday(uint256 timestamp) public pure returns (uint8) {

      return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
  }
}


pragma solidity ^0.8.4;

interface IKWWData { 

    struct KangarooDetails{
        uint64 birthTime;
        uint32 dadId;
        uint32 momId;
        uint32 coupleId;
        uint16 boatId;
	    uint16 landId;
		uint8 gen;
		uint8 status;
        uint8 bornState;
    }

    struct CoupleDetails{
        uint64 pregnancyStarted;
        uint8 babiesCounter;
        bool paidHospital;
        bool activePregnant;
    }

    function initKangaroo(uint32 tokenId, uint32 dadId, uint32 momId) external;

}



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

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

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

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}




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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




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

}




pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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









contract ERC721AK is
    Context,
    ERC165,
    IERC721,
    IERC721Metadata,
    IERC721Enumerable
{

    using Address for address;
    using Strings for uint256;

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
    }

    struct AddressData {
        uint128 balance;
        uint128 numberMinted;
    }

    uint256 private currentIndex = 1;

    uint256 internal immutable maxBatchSize;

    string private _name;

    string private _symbol;

    mapping(uint256 => TokenOwnership) private _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxBatchSize_
    ) {
        require(maxBatchSize_ > 0, "ERC721A: max batch size must be nonzero");
        _name = name_;
        _symbol = symbol_;
        maxBatchSize = maxBatchSize_;
    }

    function totalSupply() public view override returns (uint256) {

        return currentIndex;
    }

    function tokenByIndex(uint256 index)
        public
        view
        override
        returns (uint256)
    {

        require(index < totalSupply(), "ERC721A: global index out of bounds");
        return index;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        override
        returns (uint256)
    {

        require(index < balanceOf(owner), "ERC721A: owner index out of bounds");
        uint256 numMintedSoFar = totalSupply();
        uint256 tokenIdsIdx = 0;
        address currOwnershipAddr = address(0);
        for (uint256 i = 0; i < numMintedSoFar; i++) {
            TokenOwnership memory ownership = _ownerships[i];
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
        revert("ERC721A: unable to get token of owner by index");
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
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(
            owner != address(0),
            "ERC721A: balance query for the zero address"
        );
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {

        require(
            owner != address(0),
            "ERC721A: number minted query for the zero address"
        );
        return uint256(_addressData[owner].numberMinted);
    }

    function ownershipOf(uint256 tokenId)
        internal
        view
        returns (TokenOwnership memory)
    {

        require(_exists(tokenId), "ERC721A: owner query for nonexistent token");

        uint256 lowestTokenToCheck;
        if (tokenId >= maxBatchSize) {
            lowestTokenToCheck = tokenId - maxBatchSize + 1;
        }

        for (uint256 curr = tokenId; curr >= lowestTokenToCheck; curr--) {
            TokenOwnership memory ownership = _ownerships[curr];
            if (ownership.addr != address(0)) {
                return ownership;
            }
        }

        revert("ERC721A: unable to determine the owner of token");
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

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {

        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721AK.ownerOf(tokenId);
        require(to != owner, "ERC721A: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721A: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId)
        public
        view
        override
        returns (address)
    {

        require(
            _exists(tokenId),
            "ERC721A: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override
    {

        require(operator != _msgSender(), "ERC721A: approve to caller");

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
    ) public override {

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {

        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721A: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return tokenId < currentIndex;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, "", 0, 0);
    }

    function _safeMint(address to, uint256 quantity, uint32 dadId, uint32 momId) internal {

        _safeMint(to, quantity, "", dadId, momId);
    }

    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data,
        uint32 dadId,
        uint32 momId
    ) internal {

        uint256 startTokenId = currentIndex;
        require(to != address(0), "ERC721A: mint to the zero address");
        require(!_exists(startTokenId), "ERC721A: token already minted");
        require(quantity <= maxBatchSize, "ERC721A: quantity to mint too high");

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        AddressData memory addressData = _addressData[to];
        _addressData[to] = AddressData(
            addressData.balance + uint128(quantity),
            addressData.numberMinted + uint128(quantity)
        );
        _ownerships[startTokenId] = TokenOwnership(to, uint64(block.timestamp));

        uint256 updatedIndex = startTokenId;

        for (uint256 i = 0; i < quantity; i++) {
            emit Transfer(address(0), to, updatedIndex);
            require(
                _checkOnERC721Received(address(0), to, updatedIndex, _data),
                "ERC721A: transfer to non ERC721Receiver implementer"
            );
            updatedIndex++;
        }

        currentIndex = updatedIndex;
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
        _afterMinting(startTokenId, quantity, dadId, momId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
            getApproved(tokenId) == _msgSender() ||
            isApprovedForAll(prevOwnership.addr, _msgSender()));

        require(
            isApprovedOrOwner,
            "ERC721A: transfer caller is not owner nor approved"
        );

        require(
            prevOwnership.addr == from,
            "ERC721A: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721A: transfer to the zero address");

        _beforeTokenTransfers(from, to, tokenId, 1);

        _approve(address(0), tokenId, prevOwnership.addr);

        _addressData[from].balance -= 1;
        _addressData[to].balance += 1;
        _ownerships[tokenId] = TokenOwnership(to, uint64(block.timestamp));

        uint256 nextTokenId = tokenId + 1;
        if (_ownerships[nextTokenId].addr == address(0)) {
            if (_exists(nextTokenId)) {
                _ownerships[nextTokenId] = TokenOwnership(
                    prevOwnership.addr,
                    prevOwnership.startTimestamp
                );
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    uint256 public nextOwnerToExplicitlySet = 0;

    function _setOwnersExplicit(uint256 quantity) internal {

        uint256 oldNextOwnerToSet = nextOwnerToExplicitlySet;
        require(quantity > 0, "quantity must be nonzero");
        uint256 endIndex = oldNextOwnerToSet + quantity - 1;
        if (endIndex > currentIndex - 1) {
            endIndex = currentIndex - 1;
        }
        require(_exists(endIndex), "not enough minted yet for this cleanup");
        for (uint256 i = oldNextOwnerToSet; i <= endIndex; i++) {
            if (_ownerships[i].addr == address(0)) {
                TokenOwnership memory ownership = ownershipOf(i);
                _ownerships[i] = TokenOwnership(
                    ownership.addr,
                    ownership.startTimestamp
                );
            }
        }
        nextOwnerToExplicitlySet = endIndex + 1;
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
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
                    revert(
                        "ERC721A: transfer to non ERC721Receiver implementer"
                    );
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


    function _afterMinting(
        uint256 startTokenId,
        uint256 quantity,
        uint32 momId,
        uint32 dadId
    ) internal virtual {}

}




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
        _setApprovalForAll(_msgSender(), operator, approved);
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

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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



pragma solidity ^0.8.4;









contract KWWKangaroo is ERC721AK, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    uint256 public price = 0.18 ether;
    uint256 public coupleEachPrice = 0.15 ether;
    uint256 public genesisSupply = 2004;
    
    string public baseUri = "";
    string public notRevealedUri = "";
    string public extension = ".json";

    bytes32 public whitelistMT;

    address withdrawAddress;
    
    uint8 public whitelistMaxAmount = 4;
    uint8 public publicMaxAmount = 4;

    bool public whitelistLive;
    bool public publicLive;
    bool public revealed;

    IKWWData dataContract;

    constructor()
        ERC721AK(
            "Kangaroos Wild World - Kangaroos",
            "KangaroosKWW",
            genesisSupply
        )
    {}

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: Nonexistent token");
        string memory currentBaseURI = revealed ? baseUri : notRevealedUri;
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        extension
                    )
                )
                : "";
    }

    function getPriceForAmount(uint8 amount) public view returns(uint256){
        return uint256(amount).div(2).mul(coupleEachPrice.mul(2)) + uint256(amount).mod(2).mul(price);
    }

    function whitelistMint(uint8 amount, bytes32[] calldata proof)
        public
        payable
        isMintValid(amount)
    {
        require(address(dataContract) != address(0), "Data Contract not set");
        require(whitelistLive, "Whitelist sale is not live");
        require(amount > 0, "Amount not valid");
        uint256 currentPrice = getPriceForAmount(amount);
        require(msg.value >= currentPrice, "price is invalid");
        require(
            checkWhitelist(proof),
            "Your wallet is not whitelisted."
        );
        require(
            _numberMinted(msg.sender) + amount <= whitelistMaxAmount,
            "You've minted the maximum amount of kangaroos that you can"
        );
        _safeMint(msg.sender, amount);
    }

    function publicMint(uint8 amount) public payable isMintValid(amount) {
        require(address(dataContract) != address(0), "Data Contract not set");
        require(publicLive, "Public sale is not live");
        require(amount > 0, "Amount not valid");
        uint256 currentPrice = getPriceForAmount(amount);
        require(msg.value >= currentPrice, "price is invalid");
        require(
            _numberMinted(msg.sender) + amount <= publicMaxAmount,
            "You've minted the maximum amount of kangaroos that you can"
        );
        _safeMint(msg.sender, amount);
    }

    function birth(uint32 dadId, uint32 momId, address to, uint8 numBabies) public {
        require(address(dataContract) != address(0), "Data contract not initialized" );
        require(owner() == msg.sender || address(dataContract) == msg.sender, "permission denied");

        _safeMint(to, numBabies, dadId, momId);
    }

    function _afterMinting(uint256 startTokenId, uint256 quantity, uint32 dadId, uint32 momId) override internal {
        for(uint256 i = startTokenId; i < startTokenId + quantity; i++){
            dataContract.initKangaroo(uint32(i), dadId, momId);
        }
    }


    function checkWhitelist(bytes32[] memory proof)
        public
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                proof,
                whitelistMT,
                keccak256(abi.encodePacked(msg.sender))
            );
    }


    function checkNumMinted(address user) public view returns (uint256) {
        return _numberMinted(user);
    }

    modifier isMintValid(uint256 amount) {
        require(
            totalSupply() + amount < genesisSupply + 1,
            "Not enough remaining for mint amount requested"
        );
        require(amount > 0, "Quantity needs to be more than 0");
        _;
    }

    function founderMint(uint256 count, address to)
        public
        onlyOwner
        isMintValid(count)
    {
        require(address(dataContract) != address(0), "Data Contract not set");
        _safeMint(to, count);
    }

    function setMaxAmount(uint8 _whitelist, uint8 _public) public onlyOwner {
        whitelistMaxAmount = _whitelist;
        publicMaxAmount = _public;
    }

    function setDataContract(address _contract) public onlyOwner{
        dataContract = IKWWData(_contract);
    }

    function setWithdrawAddress(address _addr) public onlyOwner {
        withdrawAddress = _addr;
    }

    function setGenesisSupply(uint256 _supply) public onlyOwner {
        genesisSupply = _supply;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setCoupleEachPrice(uint256 _price) public onlyOwner {
        coupleEachPrice = _price;
    }

    function setBaseUri(string calldata _baseUri) public onlyOwner {
        baseUri = _baseUri;
    }

    function setNotRevealedUri(string calldata _uri) public onlyOwner {
        notRevealedUri = _uri;
    }

    function setExtention(string calldata _ext) public onlyOwner {
        extension = _ext;
    }

    function setWhitelistMerkleTree(bytes32 _whitelist) external onlyOwner {
        whitelistMT = _whitelist;
    }

    function setMintStages(bool _wl, bool _public) public onlyOwner {
        whitelistLive = _wl;
        publicLive = _public;
    }

    function toggleReveal() public onlyOwner {
        revealed = !revealed;
    }

    function withdraw() public onlyOwner{
        (bool os, ) = payable(withdrawAddress).call{value: address(this).balance}("");
        require(os);
    }
}



pragma solidity ^0.8.4;






contract KWWData is Ownable, IKWWData { 
    address gameManager;

    uint8 public pregnancyPeriod = 7;
    uint8 public babyPeriod = 7;

    KWWKangaroo kangarooContract;
    mapping(uint32 => KangarooDetails) public kangarooData;
    mapping(uint64 => CoupleDetails) public couplesData;
    uint8[] public mintPossibleStates = [1];


    function initKangaroo(uint32 tokenId, uint32 dadId, uint32 momId) override public onlyKangarooContract{
        uint8 gen = dadId == 0 ? 0 : kangarooData[dadId].gen + 1;
        uint8 genMom = momId == 0 ? 0 : kangarooData[momId].gen + 1;
        require(gen == genMom, "Parent have different generations");
        require(gen == 0 || getBornState(dadId) == getBornState(momId), "Parent have different bornState");
        uint8 bornState = gen == 0 ? randomState() : getBornState(dadId);

        kangarooData[tokenId] = KangarooDetails(uint64(block.timestamp), dadId, momId, 0, 0, 0, gen, gen == 0 ? 0 : 2, bornState);
    }

    function setCouple(uint32 male, uint32 female) public onlyGameManager {
        kangarooData[male].coupleId = female;
        kangarooData[female].coupleId = male;
    }

    function kangarooMoveLand(uint32 tokenId, uint16 landId) public onlyGameManager {
        kangarooData[tokenId].landId = landId;
    }

    function kangarooTookBoat(uint32 tokenId, uint16 boatId) public onlyGameManager {
        kangarooData[tokenId].status = 1;
        kangarooData[tokenId].boatId = boatId;
    }

    function kangarooReachedIsland(uint32 tokenId) public onlyGameManager {
      kangarooData[tokenId].status = 2;
      kangarooData[tokenId].boatId = 0;
    }

    function kangarooStartPregnancy(uint32 dadId, uint32 momId, bool hospital) public onlyGameManager {
      require(kangarooIsMale(dadId) && !kangarooIsMale(momId), "Genders not match");

      uint64 coupleEncoded = getCoupleEncoded(dadId, momId);
      uint8 baseMaxBabies = baseMaxBabiesAllowed(dadId);
      require(couplesData[coupleEncoded].babiesCounter < baseMaxBabies, "Max babies already born");
      kangarooData[dadId].status = 3;
      kangarooData[momId].status = 3;

      couplesData[coupleEncoded].pregnancyStarted = uint64(block.timestamp);
      couplesData[coupleEncoded].paidHospital = hospital;
      couplesData[coupleEncoded].activePregnant = true;
    }

    function birthKangaroos(uint32 dadId, uint32 momId) public onlyGameManager {
      require(kangarooContract.ownerOf(dadId) == msg.sender && kangarooContract.ownerOf(momId) == msg.sender, "You need to be the owner of the parents");
      require(kangarooIsMale(dadId) && !kangarooIsMale(momId), "Genders not match"); // Male is divided by 2 (2,4,6,8,10...)
      require(getKangarooGen(dadId) == getKangarooGen(momId), "Both parents needs to be from the same generation");
      require(kangarooData[dadId].status == 3 && kangarooData[momId].status == 3, "status of parents not eligible to do birth"); // After Pregnancy
      require(couplesData[getCoupleEncoded(dadId, momId)].activePregnant == true, "Pregnancy not active");
      require(dadId != 0 && momId != 0, "at least one of the parents don't exist");

      uint8 numBabies = getNumBabies(dadId, momId);
      kangarooContract.birth(dadId, momId, msg.sender, numBabies);

      kangarooData[dadId].status = 2;
      kangarooData[momId].status = 2;

      updateCouplesDataAfterBirth(dadId, momId, numBabies);
    }

    function updateCouplesDataAfterBirth(uint32 dadId, uint32 momId, uint8 numBabies) internal {
      uint64 coupleEncoded = getCoupleEncoded(dadId, momId);

      couplesData[coupleEncoded].pregnancyStarted = 0;
      couplesData[coupleEncoded].babiesCounter += numBabies;
      couplesData[coupleEncoded].paidHospital = false;
      couplesData[coupleEncoded].activePregnant = false;
    }
    
    function updateBirthTime(uint32 tokenId, uint64 _time) public onlyGameManager{
        kangarooData[tokenId].birthTime = _time;
    }
    
    function updateDadId(uint32 tokenId, uint32 dadId) public onlyGameManager{
        kangarooData[tokenId].dadId = dadId;
    }
    
    function updateMomId(uint32 tokenId, uint32 momId) public onlyGameManager{
        kangarooData[tokenId].momId = momId;
    }

    function updateCoupleId(uint32 tokenId, uint32 coupleId) public onlyGameManager{
        kangarooData[tokenId].coupleId = coupleId;
    }

    function updateBoatId(uint32 tokenId, uint16 boatId) public onlyGameManager{
        kangarooData[tokenId].boatId = boatId;
    }
    function updateLandId(uint32 tokenId, uint16 landId) public onlyGameManager{
        kangarooData[tokenId].landId = landId;
    }

    function updateStatus(uint32 tokenId, uint8 status) public onlyOwner{
        kangarooData[tokenId].status = status;
    }

    function updateBornState(uint32 tokenId, uint8 bornState) public onlyGameManager{
      kangarooData[tokenId].bornState = bornState;
    }

    function updateGen(uint32 tokenId, uint8 gen) public onlyGameManager{
      kangarooData[tokenId].gen = gen;
    }


    function getKangaroo(uint32 tokenId) public view returns(KangarooDetails memory){
        return kangarooData[tokenId];
    }

    function getPregnancyPeriod() public view returns(uint8){
        return pregnancyPeriod;
    }
    function getBabyPeriod() public view returns(uint8){
        return babyPeriod;
    }


    function isCouples(uint32 male, uint32 female) public view returns(bool){
      return kangarooData[male].coupleId == female && kangarooData[female].coupleId == male;
    }

    function getCouple(uint32 tokenId) public view returns(uint32){
      return kangarooData[tokenId].coupleId;
    }

    function getKangarooGender(uint32 tokenId) public pure returns(string memory){
      return kangarooIsMale(tokenId) ? "Male" : "Female";
    }

    function kangarooIsMale(uint32 tokenId) public pure returns(bool){
      return tokenId % 2 == 0;
    }

    function getKangarooGen(uint32 tokenId) public view returns(uint8){
      require(kangarooData[tokenId].birthTime != 0, "Token not exists");
      return kangarooData[tokenId].gen;
    }

    function isGen0(uint32 tokenId) public view returns(bool){
      require(kangarooData[tokenId].birthTime != 0, "Token not exists");
      return kangarooData[tokenId].gen == 0;
    }

    function baseMaxBabiesAllowed(uint32 token) public view returns(uint8){
      return isGen0(token) ? 2 : 1;
    }

    function getBabyPeriod(uint32 tokenId) public view returns(uint64) {
      require(kangarooData[tokenId].birthTime != 0, "Token not exists");
      return kangarooData[tokenId].birthTime + (babyPeriod * 1 days);
    }

    function getStatus(uint32 tokenId) public view returns(uint8){
      require(kangarooData[tokenId].birthTime != 0, "Token not exists");
      return kangarooData[tokenId].status;
    }

    function isBaby(uint32 tokenId) public view returns(bool){
      require(kangarooData[tokenId].birthTime != 0, "Token not exists");
      return getBabyPeriod(tokenId) > block.timestamp;
    }

    function getBornState(uint32 tokenId) public view returns(uint8){
      require(kangarooData[tokenId].birthTime != 0, "Token not exists");
      return kangarooData[tokenId].bornState;
    }


    function getNumBabies(uint32 dadId, uint32 momId) public view returns(uint8){
      require(getKangarooGen(dadId) == getKangarooGen(momId), "Parents are not from the same generation");
      require(kangarooData[dadId].status == 3 && kangarooData[momId].status == 3, "Parents are not at the right status");

      uint64 coupleEncoded = getCoupleEncoded(dadId, momId);
      require(couplesData[coupleEncoded].activePregnant == true, "Pregnancy is not active");
      require(pregnancyEndTimestamp(coupleEncoded) < block.timestamp, "Mom still in pregnancy period");
      uint8 baseMaxBabies = baseMaxBabiesAllowed(dadId);
      require(couplesData[coupleEncoded].babiesCounter < baseMaxBabies, "Max babies already born");

      uint8 babiesAmount = 0;
      if(couplesData[coupleEncoded].paidHospital == true){
        babiesAmount = baseMaxBabies;
      }
      else{
        uint256 rand = KWWUtils.random(random()) % 10000;
        if(isGen0(dadId)){
          babiesAmount =  rand > 6000 ? 0 : (rand <= 3500 ? 1 : 2);
        }
        else{
          babiesAmount =  rand > 6500 ? 0 : 1;
        }
      }

      uint8 maxBabiesLeft = baseMaxBabies - couplesData[coupleEncoded].babiesCounter;

      return maxBabiesLeft < babiesAmount ? maxBabiesLeft : babiesAmount;
    }

    function pregnancyEndTimestamp(uint64 coupleEncoded) public view returns(uint64){
      require(couplesData[coupleEncoded].activePregnant == true, "Pregnancy is not active");
      return couplesData[coupleEncoded].pregnancyStarted + (pregnancyPeriod * 1 days);
    }


    function random() internal view returns(uint256){
      return KWWUtils.random(kangarooContract.totalSupply());
    }

    function randomState() internal view returns(uint8){
      require(mintPossibleStates.length > 0, "There is no mint possible states");
      uint256 randomNum =  KWWUtils.random(kangarooContract.totalSupply());
      return mintPossibleStates[randomNum % mintPossibleStates.length];
    }


    function getCoupleEncoded(uint32 male, uint32 female) public pure returns(uint64){
      return KWWUtils.pack(male, female);
    }

    modifier onlyGameManager() {
        require(gameManager != address(0), "Game manager not exists");
        require(msg.sender == owner() || msg.sender == gameManager, "caller is not the game manager");
        _;
    }

    modifier onlyKangarooContract() {
        require(address(kangarooContract) != address(0), "kangaroo contract not exists");
        require(msg.sender == owner() || msg.sender == address(kangarooContract), "caller is not the Kangaroo contract");
        _;
    }  


    function setPregnancyPeriod(uint8 _pregnancyPeriod) public onlyOwner{
      pregnancyPeriod = _pregnancyPeriod;
    }

    function setDaysBabyPeriod(uint8 _daysBabyPeriod) public onlyOwner{
      babyPeriod = _daysBabyPeriod;
    }

    function setPossibleMintStates(uint8[] calldata _states) public onlyOwner{
      mintPossibleStates = _states;
    }

    function setKangarooContract(address _addr) public onlyOwner{
      kangarooContract = KWWKangaroo(_addr);
    }

    function setGameManager(address _addr) public onlyOwner{
      gameManager = _addr;
    }
}