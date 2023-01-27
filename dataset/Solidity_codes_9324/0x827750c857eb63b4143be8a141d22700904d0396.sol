
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

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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

}//Unlicense
pragma solidity ^0.8.6;

interface IMetaDataGenerator {
    struct MetaDataParams {
        uint256 tokenId;
        uint256 activeGene;
        uint256 balance;
        address owner;
    }

    struct Attribute {
        uint256 layer;
        uint256 scene;
    }

    struct EncodedData {
        uint8[576] composite;
        uint256[] colorPalette;
        string[] attributes;
    }

    function getSVG(uint256 activeGene, uint256 balance) external view returns (string memory);

    function tokenURI(MetaDataParams memory params) external view returns (string memory);

    function getEncodedData(uint256 activeGene) external view returns (EncodedData memory);

    function ossified() external view returns (bool);
}//Unlicense
pragma solidity ^0.8.6;


interface ICryptoPiggies is IERC721 {
    struct Piggy {
        uint256 gene;
        uint256 traitMask;
        uint256 balance;
        uint256 flipCost;
    }


    event ResetMask(uint256 tokenId);
    event TurnTraitOn(uint256 tokenId, uint256 position);
    event TurnTraitOff(uint256 tokenId, uint256 position);
    event Deposit(uint256 tokenId, uint256 amount);
    event Break(uint256 piggiesBroken, uint256 amount, address to);


    receive() external payable;

    function mintPiggies(uint256 piggiesToMint) external payable;

    function giftPiggies(uint256 piggiesToMint, address to) external payable;


    function breakPiggies(uint256[] memory tokenIds, address payable to) external;


    function resetTraitMask(uint256 tokenId) external;

    function turnTraitOn(uint256 tokenId, uint256 position) external payable;

    function turnTraitOff(uint256 tokenId, uint256 position) external payable;

    function updateMultipleTraits(
        uint256 tokenId,
        uint256[] memory position,
        bool[] memory onOff
    ) external payable;


    function deposit(uint256 tokenId) external payable;


    function getSVG(uint256 tokenId) external view returns (string memory);

    function piggyBalance(uint256 tokenId) external view returns (uint256);

    function geneOf(uint256 tokenId) external view returns (uint256);

    function traitMaskOf(uint256 tokenId) external view returns (uint256);

    function activeGeneOf(uint256 tokenId) external view returns (uint256);

    function getPiggy(uint256 tokenId) external view returns (Piggy memory);

    function flipCost(uint256 tokenId) external view returns (uint256);

    function broken() external view returns (uint256);

    function treasury() external view returns (address payable);

    function METADATAGENERATOR() external view returns (IMetaDataGenerator);
}//Unlicense
pragma solidity ^0.8.6;



contract CryptoPiggies is ERC721, ICryptoPiggies {
    address payable public override treasury;
    IMetaDataGenerator public immutable override METADATAGENERATOR;

    mapping(uint256 => Piggy) piggies;

    uint256 public constant MINT_MASK = 0xfffff;
    uint256 public constant MINT_PRICE = 0.1 ether;
    uint256 public constant MINT_VALUE = MINT_PRICE / 2;
    uint256 public constant FLIP_MIN_COST = 0.01 ether;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_MINT = 20;

    uint256 internal _supply = 0;
    uint256 internal _broken = 0;

    constructor(address payable treasury_, IMetaDataGenerator generator)
        ERC721('CryptoPiggies', 'CPig')
    {
        treasury = treasury_;
        METADATAGENERATOR = generator;
    }

    function setTreasury(address payable treasury_) public {
        require(treasury == msg.sender, 'caller not treasury');
        treasury = treasury_;
    }

    receive() external payable override {
        uint256 piggiesToMint = msg.value / MINT_PRICE;
        giftPiggies(piggiesToMint > MAX_MINT ? MAX_MINT : piggiesToMint, msg.sender);
    }

    function mintPiggies(uint256 piggiesToMint) public payable override {
        giftPiggies(piggiesToMint, msg.sender);
    }

    function giftPiggies(uint256 piggiesToMint, address to) public payable override {
        uint256 supply = _supply;
        require(piggiesToMint > 0, 'cannot mint 0 piggies');
        require(piggiesToMint <= MAX_MINT, 'exceeds max mint');
        require(supply + piggiesToMint <= MAX_SUPPLY, 'exceeds max supply');
        require(msg.value >= MINT_PRICE * piggiesToMint, 'insufficient eth');
        _supply = _supply + piggiesToMint;
        for (uint256 i = 0; i < piggiesToMint; i++) {
            _mintPiggie(to, supply + i);
        }
        treasury.transfer(MINT_VALUE * piggiesToMint);
        uint256 refundAmount = msg.value - piggiesToMint * MINT_PRICE;
        payable(msg.sender).transfer(refundAmount);
    }

    function breakPiggies(uint256[] memory tokenIds, address payable to) external override {
        uint256 fundsInBroken = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            fundsInBroken += _breakPiggie(tokenId);
        }
        _broken += tokenIds.length;
        to.transfer(fundsInBroken);

        emit Break(tokenIds.length, fundsInBroken, to);
    }

    function resetTraitMask(uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'caller is not approved nor owner');
        piggies[tokenId].traitMask = MINT_MASK;
        piggies[tokenId].flipCost = FLIP_MIN_COST;
        emit ResetMask(tokenId);
    }

    function updateMultipleTraits(
        uint256 tokenId,
        uint256[] memory positions,
        bool[] memory onOffs
    ) public payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'caller is not approved nor owner');
        require(positions.length == onOffs.length, 'length mismatch');
        uint256 costOfFlipping = 0;
        for (uint256 i = 0; i < positions.length; i++) {
            costOfFlipping += piggies[tokenId].flipCost * (2**i);
        }
        require(msg.value >= costOfFlipping, 'insufficient eth');

        Piggy memory piggie = piggies[tokenId];
        for (uint256 i = 0; i < positions.length; i++) {
            require(positions[i] > 4, 'cannot flip piggy or colors');
            if (onOffs[i]) {
                piggie.traitMask = newMask(piggie.traitMask, 15, positions[i]);
                emit TurnTraitOn(tokenId, positions[i]);
            } else {
                piggie.traitMask = newMask(piggie.traitMask, 0, positions[i]);
                emit TurnTraitOff(tokenId, positions[i]);
            }
        }

        piggie.flipCost = piggie.flipCost * (2 * (positions.length));
        piggie.balance += msg.value / 2;
        piggies[tokenId] = piggie;

        treasury.transfer(msg.value / 2);
    }

    function turnTraitOn(uint256 tokenId, uint256 position) public payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'caller is not approved nor owner');
        _updateTraitMask(tokenId, 15, position);
        emit TurnTraitOn(tokenId, position);
    }

    function turnTraitOff(uint256 tokenId, uint256 position) public payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), 'caller is not approved nor owner');
        _updateTraitMask(tokenId, 0, position);
        emit TurnTraitOff(tokenId, position);
    }


    function deposit(uint256 tokenId) public payable override {
        require(_exists(tokenId), 'cannot deposit to non-existing piggy');
        piggies[tokenId].balance += msg.value;
        emit Deposit(tokenId, msg.value);
    }

    function getSVG(uint256 tokenId) public view override returns (string memory) {
        return METADATAGENERATOR.getSVG(activeGeneOf(tokenId), piggyBalance(tokenId));
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        IMetaDataGenerator.MetaDataParams memory params = IMetaDataGenerator.MetaDataParams(
            tokenId,
            activeGeneOf(tokenId),
            piggyBalance(tokenId),
            ownerOf(tokenId)
        );
        return METADATAGENERATOR.tokenURI(params);
    }

    function totalSupply() external view returns (uint256) {
        return _supply;
    }

    function broken() external view override returns (uint256) {
        return _broken;
    }

    function geneOf(uint256 tokenId) external view override returns (uint256) {
        return piggies[tokenId].gene;
    }

    function traitMaskOf(uint256 tokenId) external view override returns (uint256) {
        return piggies[tokenId].traitMask;
    }

    function activeGeneOf(uint256 tokenId) public view override returns (uint256) {
        return piggies[tokenId].gene & piggies[tokenId].traitMask;
    }

    function piggyBalance(uint256 tokenId) public view override returns (uint256) {
        return piggies[tokenId].balance;
    }

    function flipCost(uint256 tokenId) external view override returns (uint256) {
        return piggies[tokenId].flipCost;
    }

    function getPiggy(uint256 tokenId) external view override returns (Piggy memory) {
        return piggies[tokenId];
    }


    function _mintPiggie(address to, uint256 tokenId) internal {
        uint256 gene = uint256(
            keccak256(
                abi.encode(
                    blockhash(block.number),
                    gasleft(),
                    msg.sender,
                    to,
                    tokenId,
                    _supply,
                    _broken
                )
            )
        );
        piggies[tokenId] = Piggy(gene, MINT_MASK, MINT_VALUE, FLIP_MIN_COST);
        _mint(to, tokenId);
    }

    function _breakPiggie(uint256 tokenId) internal returns (uint256 balance) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), 'caller is not approved nor owner');
        balance = piggies[tokenId].balance;
        delete piggies[tokenId];
        _burn(tokenId);
    }

    function _updateTraitMask(
        uint256 tokenId,
        uint256 replaceValue,
        uint256 position
    ) internal {
        require(position > 4, 'cannot flip piggy or colors');
        Piggy memory piggie = piggies[tokenId];
        require(msg.value >= piggie.flipCost, 'insufficient eth');
        piggie.traitMask = newMask(piggie.traitMask, replaceValue, position);
        piggie.flipCost += piggie.flipCost;
        piggie.balance += msg.value / 2;
        piggies[tokenId] = piggie;

        treasury.transfer(msg.value / 2);
    }

    function newMask(
        uint256 mask,
        uint256 replacement,
        uint256 position
    ) internal pure virtual returns (uint256) {
        uint256 rhs = position > 0 ? mask % 16**position : 0;
        uint256 lhs = (mask / (16**(position + 1))) * (16**(position + 1));
        uint256 insert = replacement * 16**position;
        return lhs + insert + rhs;
    }
}