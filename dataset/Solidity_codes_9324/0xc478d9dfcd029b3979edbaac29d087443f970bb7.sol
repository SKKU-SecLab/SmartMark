
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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

}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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


interface IMintMeFactory
{
    function feeWei() view external returns(uint256);
    function fundsReceiver() view external returns(address payable);
    function baseURI() view external returns(string memory);
    function onTransfer(address sender, address receiver, uint256 tokenId) external;
    function onCollectionUpdated(string memory contentCID) external;
    function onCollectionTransfer(address newOwner) external;
    function onTokenUpdated(uint256 tokenId, string memory contentCID) external;
}

pragma solidity ^0.8.0;



contract MintMe is ERC721, Ownable, ReentrancyGuard
{
    using Address for address payable;

    event ContentChanged(string contCID);
    event ContentChanged(uint256 indexed tokenId, string contCID);

    uint256                    private _counter;
    string                     private _base;
    IMintMeFactory             private _factory;
    string                     private _contentCID;
    string                     private _licenseCID;
    mapping(uint256 => string) private _contentCIDs;

    constructor(
            address       factory,
            string memory name,
            string memory symbol,
            string memory contCID,
            string memory licCID) ERC721(name, symbol)
    {
        _factory = IMintMeFactory(factory);
        _contentCID = contCID;
        _licenseCID = licCID;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId), "MintMe: URI query for nonexistent token");

        string memory baseURI = _factory.baseURI();
        string memory contCID = _contentCIDs[tokenId];
        return bytes(baseURI).length > 0 && bytes(contCID).length > 0 ?
            string(abi.encodePacked(baseURI, contCID)) : "";
    }

    function setContent(string memory contCID) public onlyOwner
    {
        _contentCID = contCID;
        _factory.onCollectionUpdated(contCID);
        emit ContentChanged(contCID);
    }

    function license() public view returns(string memory)
    {
        return _licenseCID;
    }

    function content() public view returns(string memory)
    {
        return _contentCID;
    }

    function setContent(uint256 tokenId, string memory contCID) public
    {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "MintMe: caller is not owner nor approved");
        _contentCIDs[tokenId] = contCID;
        _factory.onTokenUpdated(tokenId, contCID);
        emit ContentChanged(tokenId, contCID);
    }

    function content(uint256 tokenId) public view returns(string memory)
    {
        return _contentCIDs[tokenId];
    }

    function mint(address to, string memory contCID) public payable onlyOwner nonReentrant returns(uint256)
    {
        require(msg.value == _factory.feeWei(), "MintMe: insufficient funds");
        if (_factory.feeWei() != 0)
        {
            _factory.fundsReceiver().sendValue(_factory.feeWei());
        }
        _counter += 1;
        _mint(to, _counter);
        if (bytes(contCID).length != 0)
        {
            setContent(_counter, contCID);
        }
        return _counter;
    }

    function safeMint(address to, string memory contCID) public payable nonReentrant onlyOwner returns(uint256)
    {
        require(msg.value == _factory.feeWei(), "MintMe: insufficient funds");
        if (_factory.feeWei() != 0)
        {
            _factory.fundsReceiver().sendValue(_factory.feeWei());
        }
        _counter += 1;
        _safeMint(to, _counter);
        if (bytes(contCID).length != 0)
        {
            setContent(_counter, contCID);
        }
        return _counter;
    }

    function burn(uint256 tokenId) public
    {
        _burn(tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal override
    {
        super._transfer(from, to, tokenId);
        _factory.onTransfer(from, to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal override
    {
        super._mint(to, tokenId);
        _factory.onTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal override
    {
        address owner = ERC721.ownerOf(tokenId);
        super._burn(tokenId);
        _factory.onTransfer(owner, address(0), tokenId);
    }

    function transferOwnership(address newOwner) public override onlyOwner
    {
        super.transferOwnership(newOwner);
        _factory.onCollectionTransfer(newOwner);
    }
}

pragma solidity ^0.8.0;


contract MintMeFactory is Ownable, IMintMeFactory
{
    using Address for address payable;

    event FeeChanged(uint256 feeWei);
    event CollectionCreated(address indexed collection, address indexed creator, string contentCID, string licenseCID, string name, string symbol);
    event CollectionUpdated(address indexed collection, string contentCID);
    event CollectionTransfer(address indexed collection, address indexed newOwner);
    event TokenUpdated(address indexed collection, uint256 indexed tokenId, string contentCID);
    event Transfer(address collection, address indexed sender, address indexed receiver, uint256 indexed tokenId);

    uint256 private                      _feeWei;
    address payable private              _fundsReceiver;
    string  private                      _base;
    mapping (address => address) private _collections;

    constructor ()
    {
        setFee(1 ether / 10);
        _fundsReceiver = payable(_msgSender());
        setBaseURI("https://ipfs.io/ipfs/");
    }

    function setFee(uint256 newFeeWei) public onlyOwner
    {
        _feeWei = newFeeWei;
        emit FeeChanged(_feeWei);
    }

    function feeWei() view external override returns(uint256)
    {
        return _feeWei;
    }

    function setFundsReceiver(address newFundsReceiver) public onlyOwner
    {
        require(newFundsReceiver != address(0), "MintMe: zero address");
        _fundsReceiver = payable(newFundsReceiver);
    }

    function fundsReceiver() view external override returns(address payable)
    {
        return _fundsReceiver;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner
    {
        _base = newBaseURI;
    }

    function baseURI() view external override returns(string memory)
    {
        return _base;
    }

    function createCollection(
        string memory name,
        string memory symbol,
        string memory contentCID,
        string memory licenseCID) public payable
    {
        require(msg.value == _feeWei, "MintMeFactory: insufficient funds");
        if (_feeWei != 0)
        {
            _fundsReceiver.sendValue(_feeWei);
        }
        MintMe collection = new MintMe(address(this), name, symbol, contentCID, licenseCID);
        _collections[address(collection)] = _msgSender();
        emit CollectionCreated(address(collection), _msgSender(), contentCID, licenseCID, name, symbol);
        collection.transferOwnership(_msgSender());
    }

    function onTransfer(address sender, address receiver, uint256 tokenId) public override
    {
        validateCollection();
        emit Transfer(_msgSender(), sender, receiver, tokenId);
    }

    function onCollectionUpdated(string memory contentCID) public override
    {
        validateCollection();
        emit CollectionUpdated(_msgSender(), contentCID);
    }

    function onCollectionTransfer(address newOwner) public override
    {
        validateCollection();
        emit CollectionTransfer(_msgSender(), newOwner);
    }

    function onTokenUpdated(uint256 tokenId, string memory contentCID) public override
    {
        validateCollection();
        emit TokenUpdated(_msgSender(), tokenId, contentCID);
    }

    function validateCollection() internal view
    {
        require(_collections[_msgSender()] != address(0), "MintMeFactory: unknown collection");
    }
}
