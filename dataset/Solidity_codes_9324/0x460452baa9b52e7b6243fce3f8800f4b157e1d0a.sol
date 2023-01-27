
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
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ERC1155U {

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


    uint256[10001] private _attrs;

    mapping(address => mapping(address => bool)) private _isApprovedForAll;


    function uri(uint256 id) public view virtual returns (string memory);


    function ownerOf(uint256 id) public view returns (address) {
        return address(uint160(_attrs[id] & 0x00ffffffffffffffffffffffffffffffffffffffff));
    }


    function _setOwner(uint256 id, address to) private {
        _attrs[id] = (_attrs[id] & (0xffffffffffffffffffffffff << 160)) | uint160(to);
    }


    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _isApprovedForAll[owner][operator];
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        _isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll(from, msg.sender), 'NOT_AUTHORIZED');
        require(amount == 1, 'Can only transfer one');
        require(ownerOf(id) == from, 'Not owner');

        _setOwner(id, to);

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            'UNSAFE_RECIPIENT'
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

        require(idsLength == amounts.length, 'LENGTH_MISMATCH');

        require(msg.sender == from || isApprovedForAll(from, msg.sender), 'NOT_AUTHORIZED');

        for (uint256 i = 0; i < idsLength; ) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            
            require(amount == 1, 'Can only transfer one');
            require(ownerOf(id) == from, 'Not owner');

            _setOwner(id, to);

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
            'UNSAFE_RECIPIENT'
        );
    }

    function balanceOf(address owner, uint256 id) public view virtual returns (uint256 balance) {
        if (ownerOf(id) == owner) {
            balance = 1;
        }
    }

    function balanceOfBatch(address[] memory owners, uint256[] memory ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        uint256 ownersLength = owners.length; // Saves MLOADs.

        require(ownersLength == ids.length, 'LENGTH_MISMATCH');

        balances = new uint256[](owners.length);

        unchecked {
            for (uint256 i = 0; i < ownersLength; i++) {
                balances[i] = balanceOf(owners[i], ids[i]);
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
        bytes memory data
    ) internal {
        _setOwner(id, to);
        emit TransferSingle(msg.sender, address(0), to, id, 1);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, 1, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            'UNSAFE_RECIPIENT'
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        bytes memory data
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.
        uint256[] memory amounts = new uint256[](idsLength);

        for (uint256 i = 0; i < idsLength; ) {
            amounts[i] = 1;
            _setOwner(ids[i], to);

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
            'UNSAFE_RECIPIENT'
        );
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

}// MIT

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
}//Unlicense
pragma solidity ^0.8.9;




interface ProxyRegistry {

    function proxies(address) external view returns (address);

}

interface IERC2981 {

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}

contract COS is ERC1155U, IERC2981, Ownable {

    using SafeMath for uint256;
    using Strings for uint256;

    uint256 _currentTokenId = 1;

    uint256 public constant MAX_TOKENS = 4999;
    uint256 constant TOKENS_GIFT = 80;
    uint256 public PRICE = 0.25 ether;
    
    uint256 public giftedAmount;
    uint256 public presalePurchaseLimit = 3;
    bool public presaleLive;
    bool public saleLive;
    bool public locked;
    bool public revealed = false; 


    string private _tokenBaseURI = 'ipfs://QmQaZBeLfvrpfwuGCE7Q4iHrjzzngrminW8rgEdJUSoJgr/';

    bool private _gaslessTrading = true;
    uint256 private _royaltyPartsPerMillion = 50_000;

    string public constant name = 'Clash of Shiba';
    string public constant symbol = 'COS';

    mapping(address => bool) public presalerList;
    uint256 public currentWave;
    mapping(uint256 => mapping(address => uint256)) public presalerListPurchases;

    modifier notLocked {

        require(!locked, "Contract metadata methods are locked");
        _;
    }

    function send(address to) external onlyOwner {

        require(_currentTokenId <= MAX_TOKENS, 'Sold out');
        require(giftedAmount <= TOKENS_GIFT, 'Sold out');
        giftedAmount++;
        _mint(to, _currentTokenId, '');

        unchecked {
            _currentTokenId++;
        }
    }

    function send_Several(address[] calldata to) external onlyOwner {

        unchecked {
            require(_currentTokenId - 1 + to.length <= MAX_TOKENS, 'Sold out');
            require(giftedAmount + to.length <= TOKENS_GIFT, "Finito");
        }

        for (uint256 i = 0; i < to.length;) {
            giftedAmount++;
            _mint(to[i], _currentTokenId, '');
            unchecked {
                _currentTokenId++;
                i++;
            }
        }
    }

    function mint_Several_nmW(uint256 count) external payable {

        require(count < 6, 'Max 5');
        require(saleLive);
        unchecked {
            require(_currentTokenId - 1 + count <= MAX_TOKENS, 'Sold out');
            require(count * PRICE == msg.value, 'Wrong price');
        }

        uint256[] memory ids = new uint256[](count);

        for (uint256 i = 0; i < count; ) {
            ids[i] = _currentTokenId + i;
            unchecked {
                i++;
            }
        }

        _batchMint(msg.sender, ids, '');

        unchecked {
            _currentTokenId += count;
        }
    }

    function addToPresaleList(address[] calldata entries) external onlyOwner {

        for(uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");
            require(!presalerList[entry], "DUPLICATE_ENTRY");

            presalerList[entry] = true;
        }   
    }


    function removeFromPresaleList(address[] calldata entries) external onlyOwner {

        for(uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");
            
            presalerList[entry] = false;
        }
    }

    function mint_Presale(uint256 count) external payable {

        require(count <= presalePurchaseLimit, 'Max <');
        require(presaleLive, "PRESALE_CLOSED");
        require(presalerListPurchases[currentWave][msg.sender] + count <= presalePurchaseLimit, "EXCEED_ALLOC");

        unchecked {
            require(_currentTokenId + count < MAX_TOKENS, 'Sold out');
            require(count * PRICE == msg.value, 'Wrong price');
        }

        uint256[] memory ids = new uint256[](count);

        for (uint256 i = 0; i < count; ) {
            ids[i] = _currentTokenId + i;
            unchecked {
                i++;
            }
        }

        _batchMint(msg.sender, ids, '');

        unchecked {
            _currentTokenId += count;
        }
    }

    function totalSupply() public view returns (uint256) {

        unchecked {
            return _currentTokenId - 1;
        }
    }

    function uri(uint256 tokenId) public view override returns (string memory) {

        require(_currentTokenId >= tokenId, "Cannot query non-existent token");
        if (revealed) {
            return string(abi.encodePacked(_tokenBaseURI, tokenId.toString()));
        }else {
            return  _tokenBaseURI;
        }
        
    }

    function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {

        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    function royaltyInfo(uint256, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount) {

        receiver = owner();
        royaltyAmount = (salePrice * _royaltyPartsPerMillion) / 1_000_000;
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        if (_gaslessTrading) {
            if (block.chainid == 4) {
                if (ProxyRegistry(0xF57B2c51dED3A29e6891aba85459d600256Cf317).proxies(owner) == operator) {
                    return true;
                }
            } else if (block.chainid == 1) {
                if (ProxyRegistry(0xa5409ec958C83C3f309868babACA7c86DCB077c1).proxies(owner) == operator) {
                    return true;
                }
            }
        }

        return super.isApprovedForAll(owner, operator);
    }


    function setBaseURI(string calldata URI) external onlyOwner notLocked {

        _tokenBaseURI = URI;
        revealed = true;
    }

    function setAllowGaslessListing(bool allow) public onlyOwner {

        _gaslessTrading = allow;
    }

    function setRoyaltyPPM(uint256 newValue) public onlyOwner {

        require(newValue < 1_000_000, 'Must be < 1e6');
        _royaltyPartsPerMillion = newValue;
    }

    function setPrice(uint256 _price) public onlyOwner {

        PRICE = _price;
    }

    function toggleSaleStatus() public onlyOwner {

        saleLive = !saleLive;
    }

    function isPresaler(address addr) external view returns (bool) {

        return presalerList[addr];
    }
    
    function presalePurchasedCount(address addr) external view returns (uint256) {

        return presalerListPurchases[currentWave][addr];
    }

    function nextWave(uint256 newLimit) public onlyOwner {

        currentWave = currentWave + 1;
        presalePurchaseLimit = newLimit;
    }

    function lockMetadata() public onlyOwner {

        locked = true;
    }
    
    function togglePresaleStatus() public onlyOwner {

        presaleLive = !presaleLive;
    }
    

    function withdraw() external onlyOwner {

        _widthdraw(msg.sender, address(this).balance);
    }

    function _widthdraw(address _address, uint256 _amount) private {

        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }
    function widthrawERC20(IERC20 erc20Token) public onlyOwner {

        erc20Token.transfer(msg.sender, erc20Token.balanceOf(address(this)));
    }
}