
pragma solidity ^0.8.0;


interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}// https://eips.ethereum.org/EIPS/eip-721, http://erc721.org/ 
pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);


    function ownerOf(uint256 _tokenId) external view returns (address);


    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external;


    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;


    function transferFrom(address _from, address _to, uint256 _tokenId) external;


    function approve(address _approved, uint256 _tokenId) external;


    function setApprovalForAll(address _operator, bool _approved) external;


    function getApproved(uint256 _tokenId) external view returns (address);


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableInitializable is Initializable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT


pragma solidity ^0.8.0;


library Strings {


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
}// MIT

pragma solidity ^0.8.0;



abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is ERC165, IERC721, IERC721Metadata, Initializable, OwnableInitializable {

    using Address for address;
    using Strings for uint256;

    uint16 public totalSupply;

    address public proxyRegistryAddress;

    string private _name;

    mapping(uint256 => address) internal _owners;

    mapping(address => uint256) internal _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => string) private _tokenURI;


    function __ERC721_init(address _openseaProxyRegistry, string memory name_) internal onlyInitializing {

        proxyRegistryAddress = _openseaProxyRegistry;
        _name = name_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) external view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() external view override returns (string memory) {

        return _name;
    }

    function symbol() external pure override returns (string memory) {

        return "MONA";
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return _tokenURI[tokenId];
    }

    function approve(address to, uint256 tokenId) external override {

        address owner = _owners[tokenId];
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external override {

        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return _operatorApprovals[owner][operator];
    }

    function setOpenseaProxyRegistry(address addr) external onlyOwner {

        proxyRegistryAddress = addr;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
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
        address owner = _owners[tokenId];
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, string memory uri) internal {

        uint tokenId = totalSupply;

        _balances[to]++;
        tokenId++;
        _owners[tokenId] = to;
        _tokenURI[tokenId] = uri;
        emit Transfer(address(0), to, tokenId);
        
        totalSupply++;
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

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

        require(_owners[tokenId] == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), tokenId);

        _balances[from]--;
        _balances[to]++;
        
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
    ) internal returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
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

}

contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}// MIT

pragma solidity ^0.8.0;


interface IERC2981 is IERC165 {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}// MIT
pragma solidity ^0.8.0;


contract MonaArtistContract is Initializable, IERC2981, ERC721 {


    uint private EIP2981RoyaltyPercent;

    address private EIP2981RoyaltyAddress;

    address public monaGalleryAddress;

    address public newContract;

    function initialize(
        uint royalty, 
        address royaltyAddress,
        address _monaGalleryAddress,
        address _openseaProxyRegistry,
        string memory name_
    ) external initializer {

        __Ownable_init();
        __ERC721_init(_openseaProxyRegistry, name_);
        __MonaArtistContract_init(royalty, royaltyAddress, _monaGalleryAddress);
    }

    function __MonaArtistContract_init(
        uint royalty,
        address royaltyAddress,
        address _monaGalleryAddress
    ) internal onlyInitializing {

        require(royalty <= 1000, "Can't go over 10 percent royalty!");
        require(royaltyAddress != address(0), "Royalty address cannot be null!");
        require(_monaGalleryAddress != address(0), "Mona exchange address cannot be null!");

        EIP2981RoyaltyAddress = royaltyAddress;
        EIP2981RoyaltyPercent = royalty;
        monaGalleryAddress = _monaGalleryAddress;
    }

    function mint(string memory uri) external onlyOwner {

        _mint(monaGalleryAddress, uri);
    }

    function _burnToMigrate(uint tokenId) external {

        require(msg.sender == newContract);
        _burn(tokenId);
    }

    function setMonaGalleryAddress(address addr) external onlyOwner {

        monaGalleryAddress = addr;
    }

    function setNewContractAddress(address addr) external onlyOwner {

        newContract = addr;
    }

    function royaltyInfo(uint tokenId, uint salePrice) external view override returns(address receiver, uint256 royaltyAmount) {

        require(_exists(tokenId), "Royality querry for non-existant token!");
        return(owner(), salePrice * EIP2981RoyaltyPercent / 10000);
    }

    function setRoyaltyPercent(uint256 amount) external onlyOwner {

        require(amount <= 1000, "Can't go over 10 percent!");
        EIP2981RoyaltyPercent = amount; 
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {

        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokensOfOwner(address owner) external view returns(uint[] memory) {

        uint[] memory tokens = new uint[](_balances[owner]);
        uint y = totalSupply + 1;
        uint x;

        for (uint i = 1; i < y; i++) {
            if (ownerOf(i) == owner) {
                tokens[x] = i;
                x++;
            }
        }

        return tokens;
    }
}