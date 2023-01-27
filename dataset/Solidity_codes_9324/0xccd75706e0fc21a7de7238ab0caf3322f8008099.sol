
pragma solidity 0.8.7;


interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

  function tokenURINotRevealed(uint256 tokenId) external view returns (string memory);

  function tokenURITopTalents(uint8 topTalentNo, uint256 tokenId) external view returns (string memory);

}

interface IDrawSvg {

  function drawSvg(
    string memory svgBreedColor, string memory svgBreedHead, string memory svgOffhand, string memory svgArmor, string memory svgMainhand
  ) external view returns (string memory);

  function drawSvgNew(
    string memory svgBreedColor, string memory svgBreedHead, string memory svgOffhand, string memory svgArmor, string memory svgMainhand
  ) external view returns (string memory);

}

interface INameChange {

  function changeName(address owner, uint256 id, string memory newName) external;

}

interface IDogewood {

    struct Doge2 {
        uint8 head;
        uint8 breed;
        uint8 color;
        uint8 class;
        uint8 armor;
        uint8 offhand;
        uint8 mainhand;
        uint16 level;
        uint16 breedRerollCount;
        uint16 classRerollCount;
        uint8 artStyle; // 0: new, 1: old
    }

    function getTokenTraits(uint256 tokenId) external view returns (Doge2 memory);

    function getGenesisSupply() external view returns (uint256);

    function validateOwnerOfDoge(uint256 id, address who_) external view returns (bool);

    function unstakeForQuest(address[] memory owners, uint256[] memory ids) external;

    function updateQuestCooldown(uint256[] memory doges, uint88 timestamp) external;

    function pull(address owner, uint256[] calldata ids) external;

    function manuallyAdjustDoge(uint256 id, uint8 head, uint8 breed, uint8 color, uint8 class, uint8 armor, uint8 offhand, uint8 mainhand, uint16 level, uint16 breedRerollCount, uint16 classRerollCount, uint8 artStyle) external;

    function transfer(address to, uint256 tokenId) external;

}

interface IDogewoodForCommonerSale {

    function validateDogeOwnerForClaim(uint256 id, address who_) external view returns (bool);

}

interface ICastleForCommonerSale {

    function dogeOwner(uint256 id) external view returns (address);

}

interface PortalLike {

    function sendMessage(bytes calldata message_) external;

}

interface CastleLike {

    function pullCallback(address owner, uint256[] calldata ids) external;

}

interface ERC20Like {

    function balanceOf(address from) external view returns(uint256 balance);

    function burn(address from, uint256 amount) external;

    function mint(address from, uint256 amount) external;

    function transfer(address to, uint256 amount) external;

    function transferFrom(address from, address to, uint256 value) external;

}

interface ERC1155Like {

    function mint(address to, uint256 id, uint256 amount) external;

    function burn(address from, uint256 id, uint256 amount) external;

}

interface ERC721Like {

    function transferFrom(address from, address to, uint256 id) external;   

    function transfer(address to, uint256 id) external;

    function ownerOf(uint256 id) external returns (address owner);

    function mint(address to, uint256 tokenid) external;

}

interface QuestLike {

    struct GroupConfig {
        uint16 lvlFrom;
        uint16 lvlTo;
        uint256 entryFee; // additional entry $TREAT
        uint256 initPrize; // init prize pool $TREAT
    }
    struct Action {
        uint256 id; // unique id to distinguish activities
        uint88 timestamp;
        uint256 doge;
        address owner;
        uint256 score;
        uint256 finalScore;
    }

    function doQuestByAdmin(uint256 doge, address owner, uint256 score, uint8 groupIndex, uint256 combatId) external;

}

interface IOracle {

    function request() external returns (uint64 key);

    function getRandom(uint64 id) external view returns(uint256 rand);

}

interface IVRF {

    function getRandom(uint256 seed) external returns (uint256);

    function getRandom(string memory seed) external returns (uint256);

    function getRand(uint256 nonce) external view returns (uint256);

    function getRange(uint min, uint max,uint nonce) external view returns(uint);

}

interface ICommoner {

    struct Commoner {
        uint8 head;
        uint8 breed;
        uint8 palette;
        uint8 bodyType;
        uint8 clothes;
        uint8 accessory;
        uint8 background;
        uint8 smithing;
        uint8 alchemy;
        uint8 cooking;
    }

    function getTokenTraits(uint256 tokenId) external view returns (Commoner memory);

    function getGenesisSupply() external view returns (uint256);

    function validateOwner(uint256 id, address who_) external view returns (bool);

    function pull(address owner, uint256[] calldata ids) external;

    function adjust(uint256 id, uint8 head, uint8 breed, uint8 palette, uint8 bodyType, uint8 clothes, uint8 accessory, uint8 background, uint8 smithing, uint8 alchemy, uint8 cooking) external;

    function transfer(address to, uint256 tokenId) external;

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

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;
    address        implementation_;
    address public admin; //Lame requirement from opensea

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

    string internal _name;

    string internal _symbol;

    mapping(uint256 => TokenOwnership) internal _ownerships;

    mapping(address => AddressData) private _addressData;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;


    function _startTokenId() internal view virtual returns (uint256) {

        return 1;
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert("BalanceQueryForZeroAddress()");
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

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

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
        revert("OwnerQueryForNonexistentToken()");
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _ownershipOf(tokenId).addr;
    }

    function owner() external view returns (address) {

        return admin;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert("URIQueryForNonexistentToken()");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert("ApprovalToCurrentOwner()");

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert("ApprovalCallerNotOwnerNorApproved()");
        }

        _approve(to, tokenId, owner);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        if (!_exists(tokenId)) revert("ApprovalQueryForNonexistentToken()");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        if (operator == _msgSender()) revert("ApproveToCaller()");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transfer(address to, uint256 tokenId) external {

        require(msg.sender == ownerOf(tokenId), "NOT_OWNER");
        if (to == address(0)) revert("TransferToZeroAddress()");

        _transfer(msg.sender, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert("TransferCallerNotOwnerNorApproved()");
        if (to == address(0)) revert("TransferToZeroAddress()");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert("TransferCallerNotOwnerNorApproved()");
        if (to == address(0)) revert("TransferToZeroAddress()");

        _transfer(from, to, tokenId);
        if (to.isContract() && !_checkContractOnERC721Received(from, to, tokenId, _data)) {
            revert("TransferToNonERC721ReceiverImplementer()");
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _startTokenId() <= tokenId && tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, '');
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
        if (to == address(0)) revert("MintToZeroAddress()");
        if (quantity == 0) revert("MintZeroQuantity()");

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
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert("TransferToNonERC721ReceiverImplementer()");
                    }
                } while (updatedIndex != end);
                if (_currentIndex != startTokenId) revert("Reentrancy protection");
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
    ) internal {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert("TransferFromIncorrectOwner()");



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

            if (!isApprovedOrOwner) revert("TransferCallerNotOwnerNorApproved()");
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

        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("TransferToNonERC721ReceiverImplementer()");
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

contract Commoners is ERC721A {

    using ECDSA for bytes32;

    bool public initialized;
    mapping(address => bool) public auth;

    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public constant DOGE_SUPPLY = 5_001;
    uint256 public totalClaimed; // total claimed amount of genesis doge holders
    mapping(uint8 => TokenPartner) public tokenPartner;
    uint256 public initialSaleMinted; // minted amount of initial public sale

    IDogewood public dogewood;
    ERC20Like public treat;
    uint8 public saleStatus; // 0 : not in sale, 1: claim & WL & public, 2: public sale
    mapping(uint256 => bool) public dogeClaimed; // tokenId => isClaimed
    mapping(address => uint8) public whitelistMinted; // address => minted_amount

    mapping(uint256 => ICommoner.Commoner) internal commoners; // traits: tokenId => blockNumber
    mapping(uint256 => uint256) public coolBlocks; // cool blocks to lock metadata: tokenId => blockNumber
    ITraits public traits;
    IVRF public vrf; // random generator
    address public castle;

    uint8[][10] public rarities;
    uint8[][10] public aliases;
    mapping(uint256 => uint256) public existingCombinations;
    bool public revealed;
    mapping(uint256 => uint8) public topTalents; // commonerId => topTalentNo (1~4)



    struct TokenPartner {
        bool mintActive;
        uint8 maxMintPerTx;
        uint16 totalMinted;
        uint16 mintQuantity;
        uint256 mintPrice;
        ERC20Like token;
    }


    event AirdropTopTalent(uint8 talentId, uint256 commonerId);


    modifier noCheaters() {
        uint256 size = 0;
        address acc = msg.sender;
        assembly {
            size := extcodesize(acc)
        }

        require(
            auth[msg.sender] || (msg.sender == tx.origin && size == 0),
            "you're trying to cheat!"
        );
        _;
    }



    function initialize(address dogewood_, address treat_, address vrf_) public {
        require(msg.sender == admin, "not admin");
        require(initialized == false, "already initialized");
        initialized = true;

        _name = "Commoners";
        _symbol = "COMMONERS";
        _currentIndex = _startTokenId();

        auth[msg.sender] = true;
        dogewood = IDogewood(dogewood_);
        treat = ERC20Like(treat_);
        vrf = IVRF(vrf_);
        revealed = false;

        rarities[0] = [173, 155, 255, 206, 206, 206, 114, 114, 114];
        aliases[0] = [2, 2, 8, 0, 0, 0, 0, 1, 1];
        rarities[1] = [255, 255, 255, 255, 255, 255, 255, 255];
        aliases[1] = [7, 7, 7, 7, 7, 7, 7, 7];
        rarities[2] = [255, 188, 255, 229, 153, 76];
        aliases[2] = [2, 2, 5, 0, 0, 1];
        rarities[3] = [255, 255];
        aliases[3] = [1, 1];
        rarities[4] = [209, 96, 66, 153, 219, 107, 112, 198, 198, 66, 132, 132, 254];
        aliases[4] = [4, 5, 0, 6, 6, 6, 12, 1, 1, 1, 3, 3, 12];
        rarities[5] = [209, 96, 66, 153, 219, 107, 112, 198, 198, 66, 132, 132, 254];
        aliases[5] = [4, 5, 0, 6, 6, 6, 12, 1, 1, 1, 3, 3, 12];
        rarities[6] = [142, 254, 244, 183, 122, 61];
        aliases[6] = [1, 5, 0, 0, 0, 0];
        rarities[7] = [204, 255, 153, 51]; // [0.5, 0.3, 0.15, 0.05]
        aliases[7] = [1, 3, 0, 0];
        rarities[8] = [204, 255, 153, 51]; // [0.5, 0.3, 0.15, 0.05]
        aliases[8] = [1, 3, 0, 0];
        rarities[9] = [204, 255, 153, 51]; // [0.5, 0.3, 0.15, 0.05]
        aliases[9] = [1, 3, 0, 0];
    }

    function setRevealed() external {
        require(msg.sender == admin, "not admin");
        require(!revealed, "already revealed");
        revealed = true;
        _airdropTopTalents();
    }

    function setSaleStatus(uint8 status_) public {
        require(msg.sender == admin, "not admin");
        saleStatus = status_;
    }

    function withdraw() external payable {
        require(msg.sender == admin, "not admin");
        payable(0x8c8bbDB5C8D9c35FfB4493490172D2787648cAD8).transfer(address(this).balance);
    }

    function burnPartnerToken(uint8 tokenNo_) external {
        require(msg.sender == admin, "not admin");
        tokenPartner[tokenNo_].token.transfer(0x000000000000000000000000000000000000dEaD, tokenPartner[tokenNo_].token.balanceOf(address(this)));
    }

    function setTreat(address t_) external {
        require(msg.sender == admin);
        treat = ERC20Like(t_);
    }

    function setPartnerToken(uint8 tokenNo_, bool mintActive_, uint8 maxMintPerTx_, uint16 mintQuantity_,uint256 mintPrice_,  address token_) external {
        require(msg.sender == admin);
        tokenPartner[tokenNo_] = TokenPartner(mintActive_, maxMintPerTx_, 0, mintQuantity_, mintPrice_, ERC20Like(token_));
    }

    function setCastle(address c_) external {
        require(msg.sender == admin);
        castle = c_;
    }

    function setTraits(address t_) external {
        require(msg.sender == admin);
        traits = ITraits(t_);
    }

    function setAuth(address add, bool isAuth) external {
        require(msg.sender == admin);
        auth[add] = isAuth;
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == admin);
        admin = newOwner;
    }

    function mintReserve(uint16 quantity_, address to_) external {
        require(msg.sender == admin);
        require(totalSupply()+quantity_ <= MAX_SUPPLY-DOGE_SUPPLY, "sold out");
        _mintCommoners(to_, quantity_);
    }


    function claimMint(uint16[] memory doges_) external noCheaters {
        require(saleStatus == 1, "claim is not active");
        require(doges_.length > 0, "empty doges");
        for (uint16 i = 0; i < doges_.length; i++) {
            require(dogeClaimed[doges_[i]] == false, "already claimed");
            require(IDogewoodForCommonerSale(address(dogewood)).validateDogeOwnerForClaim(doges_[i], msg.sender), "invalid owner");
        }

        treat.burn(msg.sender, doges_.length * 40 ether);
        for (uint16 i = 0; i < doges_.length; i++) {
            require(dogeClaimed[doges_[i]] == false, "already claimed");
            dogeClaimed[doges_[i]] = true;
        }
        totalClaimed += doges_.length;
        _mintCommoners(msg.sender, uint16(doges_.length));
    }

    function whitelistMint(uint8 quantity_, bytes memory signature) external payable noCheaters {
        require(saleStatus == 1, "wl is not active");
        require(quantity_ > 0, "empty quantity");
        require(isValidSignature(msg.sender, signature), "invalid signature");
        require(whitelistMinted[msg.sender] + quantity_ <= 3, "exceeds wl quantity");
        require(totalSupply()+quantity_ <= MAX_SUPPLY-DOGE_SUPPLY+totalClaimed, "sold out");

        require(msg.value >= uint(quantity_) * 0.035 ether, "insufficient eth");
        whitelistMinted[msg.sender] = whitelistMinted[msg.sender] + quantity_;
        _mintCommoners(msg.sender, quantity_);
    }

    function isValidSignature(address user, bytes memory signature) internal view returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked("whitelist", user));
        address signer_ = hash.toEthSignedMessageHash().recover(signature);
        return auth[signer_];
    }

    function publicMintInitial(uint8 quantity_, uint8 tokenNo_) external payable noCheaters {
        require(saleStatus == 1, "status is not public sale");
        require(quantity_ <= 6, "exceed max quantity");
        require(initialSaleMinted+quantity_ <= 1000, "exceed initial sale amount");
        require(totalSupply()+quantity_ <= MAX_SUPPLY-DOGE_SUPPLY+totalClaimed, "sold out");

        if(tokenNo_ == 0) {
            require(msg.value >= uint(quantity_) * 0.035 ether, "insufficient eth");
        } else {
            require(tokenPartner[tokenNo_].mintActive == true, "invalid token");
            require(tokenPartner[tokenNo_].totalMinted + quantity_ <= tokenPartner[tokenNo_].mintQuantity, "minted out with this token");
            tokenPartner[tokenNo_].token.transferFrom(msg.sender, address(this), uint(quantity_) * tokenPartner[tokenNo_].mintPrice);
        }
        initialSaleMinted += quantity_;
        _mintCommoners(msg.sender, quantity_);
    }

    function publicMintFinal(uint8 quantity_, uint8 tokenNo_) external payable noCheaters {
        require(saleStatus == 2, "status is not public sale");
        require(quantity_ <= 6, "exceed max quantity");
        require(totalSupply()+quantity_ <= MAX_SUPPLY, "sold out");

        if(tokenNo_ == 0) {
            require(msg.value >= uint(quantity_) * 0.035 ether, "insufficient eth");
        } else {
            require(tokenPartner[tokenNo_].mintActive == true, "invalid token");
            require(tokenPartner[tokenNo_].totalMinted + quantity_ <= tokenPartner[tokenNo_].mintQuantity, "minted out with this token");
            tokenPartner[tokenNo_].token.transferFrom(msg.sender, address(this), uint(quantity_) * tokenPartner[tokenNo_].mintPrice);
        }
        _mintCommoners(msg.sender, quantity_);
    }


    function _airdropTopTalents() internal {
        uint256 airdropMax_ = _currentIndex > MAX_SUPPLY ? MAX_SUPPLY : (_currentIndex-1);
        for (uint8 i = 1; i <= 4; i++) {
            uint256 topCommoner_;
            do {
                topCommoner_ = (vrf.getRandom(i) % airdropMax_) + 1;
            } while (topTalents[topCommoner_] > 0);
            topTalents[topCommoner_] = i;

            if(i == 1) {
                commoners[topCommoner_].head = 0;
                commoners[topCommoner_].breed = 6;
                commoners[topCommoner_].palette = 0;
                commoners[topCommoner_].bodyType = 0;
                commoners[topCommoner_].clothes = 13;
                commoners[topCommoner_].accessory = 13;
                commoners[topCommoner_].background = 6;
                commoners[topCommoner_].smithing = 5;
                commoners[topCommoner_].alchemy = 1;
                commoners[topCommoner_].cooking = 1;
            } else if(i == 2) {
                commoners[topCommoner_].head = 9;
                commoners[topCommoner_].breed = 8;
                commoners[topCommoner_].palette = 0;
                commoners[topCommoner_].bodyType = 0;
                commoners[topCommoner_].clothes = 14;
                commoners[topCommoner_].accessory = 14;
                commoners[topCommoner_].background = 7;
                commoners[topCommoner_].smithing = 1;
                commoners[topCommoner_].alchemy = 5;
                commoners[topCommoner_].cooking = 1;
            } else if(i == 3) {
                commoners[topCommoner_].head = 10;
                commoners[topCommoner_].breed = 2;
                commoners[topCommoner_].palette = 0;
                commoners[topCommoner_].bodyType = 0;
                commoners[topCommoner_].clothes = 15;
                commoners[topCommoner_].accessory = 15;
                commoners[topCommoner_].background = 8;
                commoners[topCommoner_].smithing = 1;
                commoners[topCommoner_].alchemy = 1;
                commoners[topCommoner_].cooking = 5;
            } else if(i == 4) {
                commoners[topCommoner_].head = 11;
                commoners[topCommoner_].breed = 9;
                commoners[topCommoner_].palette = 0;
                commoners[topCommoner_].bodyType = 0;
                commoners[topCommoner_].clothes = 16;
                commoners[topCommoner_].accessory = 16;
                commoners[topCommoner_].background = 9;
                commoners[topCommoner_].smithing = 4;
                commoners[topCommoner_].alchemy = 4;
                commoners[topCommoner_].cooking = 4;
            }
            emit AirdropTopTalent(i, topCommoner_);
        }
    }

    function _mintCommoners(address to_, uint16 quantity_) internal {
        uint256 startTokenId = _currentIndex;
        for (uint256 id_ = startTokenId; id_ < startTokenId + quantity_; id_++) {
            uint256 seed = vrf.getRandom(id_);
            generate(id_, seed);
            coolBlocks[id_] = block.number;
        }
        uint numBatch = quantity_ / 10;
        for (uint256 i = 0; i < numBatch; i++) {
            _mint(to_, 10, '', false);
        }
        uint left_ = quantity_ - (numBatch*10);
        if(left_ > 0) _mint(to_, left_, '', false);
    }

    function generate(uint256 tokenId, uint256 seed) internal returns (ICommoner.Commoner memory t) {
        t = selectTraits(seed);
        commoners[tokenId] = t;
        return t;

    }

    function selectTrait(uint16 seed, uint8 traitType) internal view returns (uint8) {
        uint8 trait = uint8(seed) % uint8(rarities[traitType].length);
        if (seed >> 8 < rarities[traitType][trait]) return trait;
        return aliases[traitType][trait];
    }

    function selectTraits(uint256 seed) internal view returns (ICommoner.Commoner memory t) {    
        t.head = selectTrait(uint16(seed & 0xFFFF), 0);
        seed >>= 16;
        t.breed = selectTrait(uint16(seed & 0xFFFF), 1);
        seed >>= 16;
        t.palette = selectTrait(uint16(seed & 0xFFFF), 2);
        seed >>= 16;
        t.bodyType = selectTrait(uint16(seed & 0xFFFF), 3);
        seed >>= 16;
        t.clothes = selectTrait(uint16(seed & 0xFFFF), 4);
        seed >>= 16;
        t.accessory = selectTrait(uint16(seed & 0xFFFF), 5);
        seed >>= 16;
        t.background = selectTrait(uint16(seed & 0xFFFF), 6);
        seed >>= 16;
        t.smithing = selectTrait(uint16(seed & 0xFFFF), 7);
        seed >>= 16;
        t.alchemy = selectTrait(uint16(seed & 0xFFFF), 8);
        seed >>= 16;
        t.cooking = selectTrait(uint16(seed & 0xFFFF), 9);
        seed >>= 16;
    }

    function structToHash(ICommoner.Commoner memory s) internal pure returns (uint256) {
        return uint256(bytes32(
            abi.encodePacked(
                s.head,
                s.breed,
                s.palette,
                s.bodyType,
                s.clothes,
                s.accessory,
                s.background,
                s.smithing,
                s.alchemy,
                s.cooking
            )
        ));
    }




    function validateOwner(uint256 id, address who_) external view returns (bool) { 
        return (ownerOf(id) == who_);
    }

    function getTokenTraits(uint256 tokenId) external view returns (ICommoner.Commoner memory) {
        require(revealed, "not revealed yet");
        require(coolBlocks[tokenId] != block.number, "ERC721Metadata: URI query for cooldown token");
        return ICommoner.Commoner({
            head: commoners[tokenId].head,
            breed: commoners[tokenId].breed,
            palette: commoners[tokenId].palette,
            bodyType: commoners[tokenId].bodyType,
            clothes: commoners[tokenId].clothes,
            accessory: commoners[tokenId].accessory,
            background: commoners[tokenId].background,
            smithing: commoners[tokenId].smithing,
            alchemy: commoners[tokenId].alchemy,
            cooking: commoners[tokenId].cooking
        });
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if(!revealed) return traits.tokenURINotRevealed(tokenId);
        require(coolBlocks[tokenId] != block.number, "ERC721Metadata: URI query for nonexistent token");
        if(topTalents[tokenId] > 0) return traits.tokenURITopTalents(topTalents[tokenId], tokenId);
        return traits.tokenURI(tokenId);
    }


    function pull(address owner_, uint256[] calldata ids) external {
        require(revealed, "not revealed yet");
        require (msg.sender == castle, "not castle");
        for (uint256 index = 0; index < ids.length; index++) {
            _transfer(owner_, msg.sender, ids[index]);
        }
        CastleLike(msg.sender).pullCallback(owner_, ids);
    }

    function adjust(uint256 id, uint8 head, uint8 breed, uint8 palette, uint8 bodyType, uint8 clothes, uint8 accessory, uint8 background, uint8 smithing, uint8 alchemy, uint8 cooking) external {
        require(msg.sender == admin || auth[msg.sender], "not authorized");
        commoners[id].head = head;
        commoners[id].breed = breed;
        commoners[id].palette = palette;
        commoners[id].bodyType = bodyType;
        commoners[id].clothes = clothes;
        commoners[id].accessory = accessory;
        commoners[id].background = background;
        commoners[id].smithing = smithing;
        commoners[id].alchemy = alchemy;
        commoners[id].cooking = cooking;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public pure returns (bytes4) {
        return 0x150b7a02;
    }
}