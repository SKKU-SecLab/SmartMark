
pragma solidity 0.7.5;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
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

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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


interface IERC721Metadata {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

        require(owner != address(0), 'ERC721: balance query for the zero address');
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), 'ERC721: owner query for nonexistent token');
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return '';
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, 'ERC721: approval to current owner');

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            'ERC721: approve caller is not owner nor approved for all'
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), 'ERC721: approved query for nonexistent token');

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), 'ERC721: approve to caller');

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, 'ERC721: transfer of token that is not own');
        require(to != address(0), 'ERC721: transfer to the zero address');

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), 'ERC721: transfer caller is not owner nor approved');

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

        require(_isApprovedOrOwner(_msgSender(), tokenId), 'ERC721: transfer caller is not owner nor approved');
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), 'ERC721: transfer to non ERC721Receiver implementer');
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), 'ERC721: operator query for nonexistent token');
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(
        address creator,
        address to,
        uint256 tokenId
    ) internal virtual {

        _safeMint(creator, to, tokenId, '');
    }

    function _safeMint(
        address creator,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            'ERC721: transfer to non ERC721Receiver implementer'
        );
    }

    function _mint(
        address to,
        uint256 tokenId
    ) internal virtual {

        require(to != address(0), 'ERC721: mint to the zero address');
        require(!_exists(tokenId), 'ERC721: token already minted');

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _bulkMint(
        address to,
        uint256 tokenIDS_start,
        uint256 quantity
    ) internal virtual {

        require(to != address(0), 'ERC721: mint to the zero address');

        for (uint i = 0; i < quantity; i++) {
          require(!_exists(tokenIDS_start + i), 'ERC721: token already minted');
          _owners[tokenIDS_start + i] = to;
          emit Transfer(address(0), to, tokenIDS_start + i);
        }

        _balances[to] += quantity;
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
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert('ERC721: transfer to non ERC721Receiver implementer');
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


abstract contract ERC721Opensea is ERC721, Ownable {
    string private _contractURI;
    string private _tokenBaseURI;
    address proxyRegistryAddress = 0xF57B2c51dED3A29e6891aba85459d600256Cf317;

    constructor() {}

    function setProxyRegistryAddress(address proxyAddress) external onlyOwner {
        proxyRegistryAddress = proxyAddress;
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function setContractURI(string calldata URI) external onlyOwner {
        _contractURI = URI;
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

}

contract YetiGymBruhs is Ownable, ERC721Opensea {


    using Strings for uint256;
    using SafeMath for uint256;

    bool public isMintingAllowed;

    uint256 private _currentTokenID; // most recent tokenID
    uint256 public maxSupply = 3333; // max supply
    uint256 public maxMinted = 5; // no more tokens can be minted by any given address (if not excluded)

    uint256 public price; // in ETH wei

    uint256[] public mintProceedsAllocations;
    address[] public mintProceedsRecipients;
    uint256[] public royaltiesAllocations;
    address[] public royaltiesRecipients;
    uint256 public mintProceeds;

    mapping(address => bool) public isExcludedFromOwnershipRestrictions; // indicates whether a given address can mint more than maxMinted tokens
    mapping(address => bool) public isClaimable; // indicates whether a given address can still claim a free token
    mapping(address => uint256) public mintedQuantity; // how many are minted per wallet

    string private baseURI;

    constructor( string memory _baseURI, uint256 _price, uint256[] memory _mintProceedsAllocations, address[] memory _mintProceedsRecipients, uint256[] memory _royaltiesAllocations, address[] memory _royaltiesRecipients ) ERC721("Yeti Gym Bruhs", "GYMBRUHS") {
        baseURI = _baseURI;
        price = _price;

        require(_mintProceedsRecipients.length == _mintProceedsAllocations.length);
        require(_royaltiesAllocations.length == _royaltiesRecipients.length);

        uint256 _totalMintAllocation;
        uint256 _totalRoyaltiesAllocation;

        mintProceedsAllocations = _mintProceedsAllocations;
        mintProceedsRecipients = _mintProceedsRecipients;
        royaltiesAllocations = _royaltiesAllocations;
        royaltiesRecipients = _royaltiesRecipients;

        for (uint i = 0; i < _mintProceedsAllocations.length; i++) {
          _totalMintAllocation = _totalMintAllocation + _mintProceedsAllocations[i];
        }

        for (uint i = 0; i < _royaltiesAllocations.length; i++) {
          _totalRoyaltiesAllocation = _totalRoyaltiesAllocation + _royaltiesAllocations[i];
        }

        require(_totalMintAllocation == 1000);
        require(_totalRoyaltiesAllocation == 1000);
    }

    receive() external payable {}

    function mint(uint256 quantity) external payable {

        require(isMintingAllowed, "Minting is disabled");
        require(msg.value >= (price.mul(quantity)), "Insufficient ETH");
        require(tx.origin == msg.sender, "Contracts not allowed");
        mintProceeds = mintProceeds.add(msg.value);
        _mintTo(msg.sender, quantity);
    }

    function claim() external {

        require(isClaimable[msg.sender], "Not whitelisted or claimed already");
        isClaimable[msg.sender] = false;
        _mintTo(msg.sender, 1);
    }

    function mintReserved(address[] memory _recipients, uint256[] memory _quantity) external onlyOwner() {

        require(_recipients.length == _quantity.length);
        for (uint i = 0; i < _recipients.length; i++) {
          isExcludedFromOwnershipRestrictions[_recipients[i]] = true;
          _mintTo(_recipients[i], _quantity[i]);
        }
    }

    function _baseURI() internal view override returns (string memory) {

        return baseURI;
    }

    function setPrice(uint256 _price) external onlyOwner() {

        price = _price;
    }

    function setMintingEnabled(bool _enabled) external onlyOwner() {

        isMintingAllowed = _enabled;
    }

    function setMaxMinted(uint256 _maxMinted) external onlyOwner() {

        maxMinted = _maxMinted;
    }

    function setMintProceedsRecipients(uint256[] memory _mintProceedsAllocations, address[] memory _mintProceedsRecipients) external onlyOwner() {

        uint256 _totalMintAllocation;
        mintProceedsAllocations = _mintProceedsAllocations;
        mintProceedsRecipients = _mintProceedsRecipients;

        for (uint i = 0; i < _mintProceedsAllocations.length; i++) {
          _totalMintAllocation = _totalMintAllocation + _mintProceedsAllocations[i];
        }

        require(_totalMintAllocation == 1000);
    }

    function setRoyaltiesRecipients(uint256[] memory _royaltiesAllocations, address[] memory _royaltiesRecipients) external onlyOwner() {

        uint256 _totalRoyaltiesAllocation;
        royaltiesAllocations = _royaltiesAllocations;
        royaltiesRecipients = _royaltiesRecipients;

        for (uint i = 0; i < _royaltiesAllocations.length; i++) {
          _totalRoyaltiesAllocation = _totalRoyaltiesAllocation + _royaltiesAllocations[i];
        }

        require(_totalRoyaltiesAllocation == 1000);
    }

    function whitelistMembers(address[] memory _members, bool _status) external onlyOwner() {

        for (uint i = 0; i < _members.length; i++) {
          isClaimable[_members[i]] = _status;
        }
    }

    function setExcludedFromOwnershipRestrictions(address _recipient, bool _excluded) external onlyOwner() {

        isExcludedFromOwnershipRestrictions[_recipient] = _excluded;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner() {

        baseURI = _baseURI;
    }

    function withdraw() external onlyOwner() {

        uint256 royaltiesBal = address(this).balance.sub(mintProceeds);

        for (uint i = 0; i < mintProceedsRecipients.length; i++) {
          uint256 amount = mintProceedsAllocations[i].mul(mintProceeds).div(1000);
          if (amount > 0 && amount <= address(this).balance) {
            payable(mintProceedsRecipients[i]).transfer(amount);
          }
        }

        for (uint i = 0; i < royaltiesRecipients.length; i++) {
          uint256 amount = royaltiesAllocations[i].mul(royaltiesBal).div(1000);
          if (amount > 0 && amount <= address(this).balance) {
            payable(royaltiesRecipients[i]).transfer(amount);
          }
        }

        mintProceeds = 0;
    }

    function withdrawFull() external onlyOwner() {

        payable(msg.sender).transfer(address(this).balance);
        mintProceeds = 0;
    }

    function totalSupply() public view returns (uint256) {

        return _currentTokenID;
    }

    function _mintTo(address to, uint256 quantity) internal {

        require((_currentTokenID + quantity) <= maxSupply, "Max supply reached");
        _bulkMint(to, _currentTokenID, quantity);
        _currentTokenID = _currentTokenID + quantity;
        mintedQuantity[to] = mintedQuantity[to].add(quantity);
        if (!isExcludedFromOwnershipRestrictions[to]) require(mintedQuantity[to] <= maxMinted, "Balance Limit Reached");
    }

    function tokenURI(uint256 tokenID) public view override returns (string memory) {

        require(_exists(tokenID), 'Yeti Gym Bruhs: URI query for nonexistent token');
        return string(abi.encodePacked(baseURI, '/', tokenID.toString(), ".json"));
    }

}