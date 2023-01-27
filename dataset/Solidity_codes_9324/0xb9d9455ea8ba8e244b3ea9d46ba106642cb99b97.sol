
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

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
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
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// UNLICENSED

pragma solidity ^0.8.0;


interface IBlockverse is IERC721Enumerable {
    function mint(uint256 amount, bool autoStake) external payable;
    function whitelistMint(uint256 amount, bytes32[] memory proof, bool autoStake) external payable;
    function walletOfUser(address user) external view returns (uint256[] memory);
    function getTokenFaction(uint256 tokenId) external view returns (BlockverseFaction);

    enum BlockverseFaction {
        UNASSIGNED,
        APES,
        KONGS,
        DOODLERS,
        CATS,
        KAIJUS,
        ALIENS
    }
}// UNLICENSED

pragma solidity ^0.8.0;

interface IBlockverseStaking {
    function stake(address from, uint256 tokenId) external;
    function claim(uint256 tokenId, bool unstake, uint256 nonce, uint256 amountV, bytes32 r, bytes32 s) external;
    function stakedByUser(address user) external view returns (uint256);

    event Claim(uint256 indexed _tokenId, uint256 indexed _amount, bool indexed _unstake);
}// UNLICENSED

pragma solidity ^0.8.0;


interface IBlockverseMetadata {
    function tokenURI(uint256 tokenId, IBlockverse.BlockverseFaction faction) external view returns (string memory);
}// UNLICENSED

pragma solidity ^0.8.0;


contract Blockverse is IBlockverse, ERC721Enumerable, Ownable, ReentrancyGuard {
    using MerkleProof for bytes32[];

    IBlockverseStaking staking;
    IBlockverseMetadata metadata;

    uint256 public constant price = 0.05 ether;
    uint256 constant mintLimit = 4;
    uint256 constant presaleMintLimit = 3;
    uint256 constant supplyLimit = 10000;
    bytes32 whitelistMerkelRoot;

    uint8 public saleStage = 0;

    mapping(address => uint256) public minted;
    mapping(address => BlockverseFaction) public walletAssignedMintFaction;
    mapping(BlockverseFaction => uint256) public mintedByFaction;
    mapping(uint256 => BlockverseFaction) public tokenFaction;

    constructor() ERC721("Blockverse", "BLCK")  {}

    function remainingMint(address user) public view returns (uint256) {
        return (saleStage == 1 ? presaleMintLimit : mintLimit) - minted[user];
    }

    function mint(uint256 num, bool autoStake) external override payable nonReentrant requireContractsSet {
        uint256 supply = totalSupply();
        require(tx.origin == _msgSender(), "Only EOA");
        require(saleStage == 2 || _msgSender() == owner(), "Sale not started");
        require(remainingMint(_msgSender()) >= num || _msgSender() == owner(), "Hit mint limit");
        require(supply + num < supplyLimit, "Exceeds maximum supply");
        require(msg.value >= price * num || _msgSender() == owner(), "Ether sent is not correct");
        require(num > 0, "Can't mint 0");

        if (walletAssignedMintFaction[_msgSender()] == BlockverseFaction.UNASSIGNED) {
            BlockverseFaction minFaction = BlockverseFaction.APES;
            uint256 minCount = mintedByFaction[minFaction];

            for (uint256 i = 1; i <= uint256(BlockverseFaction.ALIENS); i++) {
                uint256 iCount = mintedByFaction[BlockverseFaction(i)];
                if (iCount < minCount) {
                    minFaction = BlockverseFaction(i);
                    minCount = iCount;
                }
            }

            walletAssignedMintFaction[_msgSender()] = minFaction;
        }

        minted[_msgSender()] += num;
        mintedByFaction[walletAssignedMintFaction[_msgSender()]] += num;

        for (uint256 i; i < num; i++) {
            address recipient = autoStake && i == 0 ? address(staking) : _msgSender();
            _safeMint(recipient, supply + i + 1);
            tokenFaction[supply + i + 1] = walletAssignedMintFaction[_msgSender()];
        }

        if (autoStake && staking.stakedByUser(_msgSender()) == 0) {
            staking.stake(_msgSender(), supply + 1);
        }
    }

    function whitelistMint(uint256 num, bytes32[] memory proof, bool autoStake) external override payable nonReentrant requireContractsSet {
        uint256 supply = totalSupply();
        require(tx.origin == _msgSender(), "Only EOA");
        require(saleStage == 1 || _msgSender() == owner(), "Pre-sale not started or has ended");
        require(remainingMint(_msgSender()) >= num, "Hit mint limit");
        require(supply + num < supplyLimit, "Exceeds maximum supply");
        require(msg.value >= num * price, "Ether sent is not correct");
        require(whitelistMerkelRoot != 0, "Whitelist not set");
        require(
            proof.verify(whitelistMerkelRoot, keccak256(abi.encodePacked(_msgSender()))),
            "You aren't whitelisted"
        );
        require(num > 0, "Can't mint 0");

        minted[_msgSender()] += num;

        for (uint256 i; i < num; i++) {
            address recipient = autoStake ? address(staking) : _msgSender();
            _safeMint(recipient, supply + i + 1);
            tokenFaction[supply + i + 1] = walletAssignedMintFaction[_msgSender()];
        }

        if (autoStake) {
            staking.stake(_msgSender(), supply + 1);
        }
    }

    function walletOfUser(address user) public view override returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(user);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(user, i);
        }
        return tokensId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return metadata.tokenURI(tokenId, tokenFaction[tokenId]);
    }

    function getTokenFaction(uint256 tokenId) external view override returns (BlockverseFaction) {
        return tokenFaction[tokenId];
    }

    function setSaleStage(uint8 val) public onlyOwner {
        saleStage = val;
    }

    function setWhitelistRoot(bytes32 val) public onlyOwner {
        whitelistMerkelRoot = val;
    }

    function withdrawAll(address payable a) public onlyOwner {
        a.transfer(address(this).balance);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        if(_msgSender() != address(staking) && _msgSender() != owner()) {
            require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        }
        _transfer(from, to, tokenId);
    }

    modifier requireContractsSet() {
        require(address(staking) != address(0) && address(metadata) != address(0)
        , "Contracts not set");
        _;
    }

    function setContracts(address _staking, address _metadata) external onlyOwner {
        staking = IBlockverseStaking(_staking);
        metadata = IBlockverseMetadata(_metadata);
    }
}// UNLICENSED

pragma solidity ^0.8.0;


struct BlockverseToken {
    IBlockverse.BlockverseFaction faction;
    uint8 bottom;
    uint8 eye;
    uint8 mouth;
    uint8 top;
}

contract BlockverseMetadata is IBlockverseMetadata, Ownable {
    using Strings for uint256;
    using Strings for uint8;

    string public cdnUrl;
    uint256[] public tidBreakpoints;
    uint256[] public seedBreakpoints;
    mapping(uint256 => uint8[]) public traitProbabilities;
    mapping(uint256 => uint8[]) public traitAliases;
    mapping(uint256 => mapping(uint8 => string)) public traitNames;

    function tokenURI(uint256 tokenId, IBlockverse.BlockverseFaction faction) external view override returns (string memory) {
        BlockverseToken memory tokenStruct = getTokenMetadata(tokenId, faction);

        string memory metadata;
        if (tokenStruct.faction == IBlockverse.BlockverseFaction.UNASSIGNED) {
            metadata = string(abi.encodePacked(
                '{',
                    '"name":"Blockverse #???",',
                    '"description":"",',
                    '"image":"', cdnUrl, '/unknown",',
                    '"attributes":[',
                        attributeForTypeAndValue("Faction", "???"),',',
                        attributeForTypeAndValue("Bottom", "???"),',',
                        attributeForTypeAndValue("Eye", "???"),',',
                        attributeForTypeAndValue("Mouth", "???"),',',
                        attributeForTypeAndValue("Top", "???"),
                    ']',
                "}"
            ));
        } else {
            string memory queryParams = string(abi.encodePacked(
                    "?base=",uint256(faction).toString(),
                    "&bottoms=",tokenStruct.bottom.toString(),
                    "&eyes=",tokenStruct.eye.toString(),
                    "&mouths=",tokenStruct.mouth.toString(),
                    "&tops=",tokenStruct.top.toString()
                ));
            metadata = string(abi.encodePacked(
                '{',
                    '"name":"Blockverse #',tokenId.toString(),'",',
                    '"description":"",',
                    '"image":"', cdnUrl, '/token',queryParams,'",',
                    '"skinImage":"', cdnUrl, '/skin',queryParams,'",',
                    '"attributes":[',
                        attributeForTypeAndValue("Faction", factionToString(faction)),',',
                        attributeForTypeAndValue("Bottom", traitNames[0][tokenStruct.bottom]),',',
                        attributeForTypeAndValue("Eye", traitNames[1][tokenStruct.eye]),',',
                        attributeForTypeAndValue("Mouth", traitNames[2][tokenStruct.mouth]),',',
                        attributeForTypeAndValue("Top", traitNames[3][tokenStruct.top]),
                    ']',
                "}"
            ));
        }

        return string(abi.encodePacked(
            "data:application/json;base64,",
            base64(bytes(metadata))
        ));
    }

    function getTokenMetadata(uint256 tid, IBlockverse.BlockverseFaction faction) internal view returns (BlockverseToken memory tokenMetadata) {
        uint256 seed = getTokenSeed(tid);

        if (seed == 0) {
            tokenMetadata.faction = IBlockverse.BlockverseFaction.UNASSIGNED;
        } else {
            tokenMetadata.faction = faction;
            tokenMetadata.bottom = getTraitValue(seed, 0);
            tokenMetadata.eye = getTraitValue(seed, 1);
            tokenMetadata.mouth = getTraitValue(seed, 2);
            tokenMetadata.top = getTraitValue(seed, 3);
        }
    }

    function getTraitValue(uint256 seed, uint256 trait) public view returns (uint8 traitValue) {
        uint8 n = uint8(traitProbabilities[trait].length);

        uint16 traitSeed = uint16(seed >> trait * 16);
        traitValue = uint8(traitSeed) % n;
        uint8 rand = uint8(traitSeed >> 8);

        if (traitProbabilities[trait][traitValue] < rand) {
            traitValue = traitAliases[trait][traitValue];
        }
    }

    function getTokenSeed(uint256 tid) public view returns (uint256 seed) {
        require(tidBreakpoints.length == seedBreakpoints.length, "Invalid state");

        uint256 rangeSeed = 0;
        for (uint256 i; i < tidBreakpoints.length; i++) {
            if (tidBreakpoints[i] > tid) {
                rangeSeed = seedBreakpoints[i];
            }
        }

        seed = rangeSeed == 0 ? 0 : uint256(keccak256(abi.encodePacked(tid, rangeSeed)));
    }

    function addBreakpoint(uint256 seed, uint256 tid) external onlyOwner {
        require(seed != 0, "Seed can't be 0");
        require(tid != 0, "Token ID can't be 0");

        seedBreakpoints.push(seed);
        tidBreakpoints.push(tid);
    }

    function uploadTraitNames(uint8 traitType, uint8[] calldata traitIds, string[] calldata newTraitNames) external onlyOwner {
        require(traitIds.length == newTraitNames.length, "Mismatched inputs");
        for (uint i = 0; i < traitIds.length; i++) {
            traitNames[traitType][traitIds[i]] = newTraitNames[i];
        }
    }

    function uploadTraitProbabilities(uint8 traitType, uint8[] calldata newTraitProbabilities) external onlyOwner {
        delete traitProbabilities[traitType];
        for (uint i = 0; i < newTraitProbabilities.length; i++) {
            traitProbabilities[traitType].push(newTraitProbabilities[i]);
        }
    }

    function uploadTraitAliases(uint8 traitType, uint8[] calldata newTraitAliases) external onlyOwner {
        delete traitAliases[traitType];
        for (uint i = 0; i < newTraitAliases.length; i++) {
            traitAliases[traitType].push(newTraitAliases[i]);
        }
    }

    function setCdnUri(string memory newCdnUri) external onlyOwner {
        cdnUrl = newCdnUri;
    }

    function factionToString(IBlockverse.BlockverseFaction faction) internal pure returns (string memory factionString) {
        factionString = "???";
        if (faction == IBlockverse.BlockverseFaction.APES) {
            factionString = "Apes";
        } else if (faction == IBlockverse.BlockverseFaction.KONGS) {
            factionString = "Kongs";
        } else if (faction == IBlockverse.BlockverseFaction.DOODLERS) {
            factionString = "Doodlers";
        } else if (faction == IBlockverse.BlockverseFaction.CATS) {
            factionString = "Cats";
        } else if (faction == IBlockverse.BlockverseFaction.KAIJUS) {
            factionString = "Kaijus";
        } else if (faction == IBlockverse.BlockverseFaction.ALIENS) {
            factionString = "Aliens";
        }
    }

    function attributeForTypeAndValue(string memory traitType, string memory value) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '{"trait_type":"',
            traitType,
            '","value":"',
            value,
            '"}'
        ));
    }

    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function base64(bytes memory data) internal pure returns (string memory) {
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

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)

                let input := mload(dataPtr)

                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
                resultPtr := add(resultPtr, 1)
                mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }
}// UNLICENSED

pragma solidity ^0.8.0;

interface IBlockverseDiamonds {
    function mint(address to, uint256 amount) external;
}// UNLICENSED

pragma solidity ^0.8.0;


contract BlockverseStaking is IBlockverseStaking, IERC721Receiver, Ownable, ReentrancyGuard {
    IBlockverse blockverse;
    IBlockverseDiamonds diamonds;
    address signer;

    mapping(address => uint256) public userStake;
    mapping(address => uint256) public userUnstakeTime;
    mapping(address => IBlockverse.BlockverseFaction) public userUnstakeFaction;
    mapping(uint256 => address) public tokenStakedBy;
    mapping(uint256 => bool) public nonceUsed;

    uint256 unstakeFactionChangeTime = 3 days;

    function stake(address from, uint256 tokenId) external override requireContractsSet nonReentrant {
        require(tx.origin == _msgSender() || _msgSender() == address(blockverse), "Only EOA");
        require(userStake[from] == 0, "Must not be staking already");
        require(userUnstakeFaction[from] == blockverse.getTokenFaction(tokenId) || block.timestamp - userUnstakeTime[from] > unstakeFactionChangeTime, "Can't switch faction yet");
        if (_msgSender() != address(blockverse)) {
            require(blockverse.ownerOf(tokenId) == _msgSender(), "Must own this token");
            require(_msgSender() == from, "Must stake from yourself");
            blockverse.transferFrom(_msgSender(), address(this), tokenId);
        }

        userStake[from] = tokenId;
        tokenStakedBy[tokenId] = from;
    }

    bytes32 constant public MINT_CALL_HASH_TYPE = keccak256("mint(address to,uint256 amount)");

    function claim(uint256 tokenId, bool unstake, uint256 nonce, uint256 amountV, bytes32 r, bytes32 s) external override requireContractsSet nonReentrant {
        require(tx.origin == _msgSender(), "Only EOA");
        require(userStake[_msgSender()] == tokenId, "Must own this token");
        require(tokenStakedBy[tokenId] == _msgSender(), "Must own this token");
        require(!nonceUsed[nonce], "Claim already used");

        nonceUsed[nonce] = true;
        uint256 amount = uint248(amountV >> 8);
        uint8 v = uint8(amountV);

        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",
            keccak256(abi.encode(MINT_CALL_HASH_TYPE, nonce, _msgSender(), amount))
        ));

        address signedBy = ecrecover(digest, v, r, s);
        require(signedBy == signer, "Invalid signer");

        if (unstake) {
            userStake[_msgSender()] = 0;
            tokenStakedBy[tokenId] = address(0);
            userUnstakeFaction[_msgSender()] = blockverse.getTokenFaction(tokenId);
            userUnstakeTime[_msgSender()] = block.timestamp;

            blockverse.safeTransferFrom(address(this), _msgSender(), tokenId, "");
        }

        diamonds.mint(_msgSender(), amount);

        emit Claim(tokenId, amount, unstake);
    }

    function stakedByUser(address user) external view override returns (uint256) {
        return userStake[user];
    }

    modifier requireContractsSet() {
        require(address(blockverse) != address(0) && address(diamonds) != address(0) &&
            address(signer) != address(0),
            "Contracts not set");
        _;
    }

    function setContracts(address _blockverse, address _diamonds, address _signer) external onlyOwner {
        blockverse = IBlockverse(_blockverse);
        diamonds = IBlockverseDiamonds(_diamonds);
        signer = _signer;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
      require(from == address(0x0), "Cannot send to BlockverseStaking directly");
      return IERC721Receiver.onERC721Received.selector;
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


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}// UNLICENSED

pragma solidity ^0.8.0;


contract BlockverseDiamonds is ERC20, IBlockverseDiamonds, Ownable, ReentrancyGuard {
    IBlockverseStaking staking;

    constructor() ERC20("Blockverse Diamonds", "DIAMOND") {}

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function mint(address to, uint256 amount) external override nonReentrant requireContractsSet {
        require(_msgSender() == address(staking) || _msgSender() == owner(), "Not authorized");

        _mint(to, amount);
    }

    modifier requireContractsSet() {
        require(address(staking) != address(0), "Contracts not set");
        _;
    }

    function setContracts(address _staking) external onlyOwner {
        staking = IBlockverseStaking(_staking);
    }
}