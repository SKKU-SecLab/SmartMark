



pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}




pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
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




pragma solidity ^0.8.1;

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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
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

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}




pragma solidity ^0.8.0;



abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}




pragma solidity 0.8.7;




contract WGG is ERC721Burnable, Ownable {
   
    using Strings for uint256;
    using Counters for Counters.Counter;
    
    string public baseURI;
    string public baseExtension = ".json";
    uint8 public maxTx = 3;
    uint256 public maxSupply = 10000;
    uint256 public price = 0.08 ether;
    
    bool public goatPresaleOpen = true;
    bool public goatMainsaleOpen = false;
    
    Counters.Counter private _tokenIdTracker;

    mapping (address => bool) whiteListed;
    mapping (address => uint256) walletMinted;
    
    constructor(string memory _initBaseURI) ERC721("Wild Goat Gang", "WGG")
    {
        setBaseURI(_initBaseURI);

        for(uint i=0;i<10;i++)
        {
            _tokenIdTracker.increment();
            _safeMint(msg.sender, totalToken());
        }
    }
    
    modifier isPresaleOpen
    {
         require(goatPresaleOpen == true);
         _;
    }

    modifier isMainsaleOpen
    {
         require(goatMainsaleOpen == true);
         _;
    }

    function flipPresale() public onlyOwner
    {
        goatPresaleOpen = false;
        goatMainsaleOpen = true;
    }

    function changeMaxSupply(uint256 _maxSupply) public onlyOwner
    {
        maxSupply = _maxSupply;
    }
    
    function totalToken() public view returns (uint256) {
            return _tokenIdTracker.current();
    }

    function addWhiteList(address[] memory whiteListedAddresses) public onlyOwner
    {
        for(uint256 i=0; i<whiteListedAddresses.length;i++)
        {
            whiteListed[whiteListedAddresses[i]] = true;
        }
    }

    function isAddressWhitelisted(address whitelist) public view returns(bool)
    {
        return whiteListed[whitelist];
    }


    function preSale(uint8 mintTotal) public payable isPresaleOpen
    {
        uint256 totalMinted = mintTotal + walletMinted[msg.sender];
        
        require(whiteListed[msg.sender] == true, "You are not whitelisted!");
        require(totalMinted <= maxTx, "Mint exceeds limitations");
        require(mintTotal >= 1 , "Mint Amount Incorrect");
        require(msg.value >= price * mintTotal, "Minting a Wild Goat Costs 0.08 Ether Each!");
        require(totalToken() < maxSupply, "SOLD OUT!");
       
        for(uint i=0;i<mintTotal;i++)
        {
            require(totalToken() < maxSupply, "SOLD OUT!");
            _tokenIdTracker.increment();
            _safeMint(msg.sender, totalToken());
        }
    }

    
    function mainSale(uint8 mintTotal) public payable isMainsaleOpen
    {
        uint256 totalMinted = mintTotal + walletMinted[msg.sender];

        require(totalMinted <= maxTx, "Mint exceeds limitations");
        require(mintTotal >= 1 , "Mint Amount Incorrect");
        require(msg.value >= price * mintTotal, "Minting a Wild Goat Costs 0.08 Ether Each!");
        require(totalToken() < maxSupply, "SOLD OUT!");
       
        for(uint i=0;i<mintTotal;i++)
        {
            require(totalToken() < maxSupply, "SOLD OUT!");
            _tokenIdTracker.increment();
            _safeMint(msg.sender, totalToken());
        }
    }
   
    function withdrawContractEther() external onlyOwner
    {
        address payable teamOne = payable(0x9f199f62a1aCb6877AC6C82759Df34B24A484e9C);
        address payable teamTwo = payable(0x1599f9F775451DBd03a1a951d4D93107900276A4);
        address payable teamThree = payable(0xEEe7dB024C2c629556Df7F80f528913048f12fbc);
        address payable teamFour = payable(0xD43763625605fF5894100B24Db41EB19A9c0E65e);
        
        uint256 totalSplit = (getBalance() / 4);

        teamOne.transfer(totalSplit);
        teamTwo.transfer(totalSplit);
        teamThree.transfer(totalSplit);
        teamFour.transfer(totalSplit);

    }
    function getBalance() public view returns(uint)
    {
        return address(this).balance;
    }
   
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
   
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
   
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }
}


pragma solidity ^0.8.0;

contract ERC20I {
    string public name;
    string public symbol;
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _mint(address to_, uint256 amount_) internal virtual {
        totalSupply += amount_;
        balanceOf[to_] += amount_;
        emit Transfer(address(0x0), to_, amount_);
    }
    function _burn(address from_, uint256 amount_) internal virtual {
        balanceOf[from_] -= amount_;
        totalSupply -= amount_;
        emit Transfer(from_, address(0x0), amount_);
    }
    function _approve(address owner_, address spender_, uint256 amount_) internal virtual {
        allowance[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

    function approve(address spender_, uint256 amount_) public virtual returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }
    function transfer(address to_, uint256 amount_) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount_;
        balanceOf[to_] += amount_;
        emit Transfer(msg.sender, to_, amount_);
        return true;
    }
    function transferFrom(address from_, address to_, uint256 amount_) public virtual returns (bool) {
        if (allowance[from_][msg.sender] != type(uint256).max) {
            allowance[from_][msg.sender] -= amount_; }
        balanceOf[from_] -= amount_;
        balanceOf[to_] += amount_;
        emit Transfer(from_, to_, amount_);
        return true;
    }

    function multiTransfer(address[] memory to_, uint256[] memory amounts_) public virtual {
        require(to_.length == amounts_.length, "ERC20I: To and Amounts length Mismatch!");
        for (uint256 i = 0; i < to_.length; i++) {
            transfer(to_[i], amounts_[i]);
        }
    }
    function multiTransferFrom(address[] memory from_, address[] memory to_, uint256[] memory amounts_) public virtual {
        require(from_.length == to_.length && from_.length == amounts_.length, "ERC20I: From, To, and Amounts length Mismatch!");
        for (uint256 i = 0; i < from_.length; i++) {
            transferFrom(from_[i], to_[i], amounts_[i]);
        }
    }
}

abstract contract ERC20IBurnable is ERC20I {
    function burn(uint256 amount_) external virtual {
        _burn(msg.sender, amount_);
    }
    function burnFrom(address from_, uint256 amount_) public virtual {
        uint256 _currentAllowance = allowance[from_][msg.sender];
        require(_currentAllowance >= amount_, "ERC20IBurnable: Burn amount requested exceeds allowance!");

        if (allowance[from_][msg.sender] != type(uint256).max) {
            allowance[from_][msg.sender] -= amount_; }

        _burn(from_, amount_);
    }
}


pragma solidity 0.8.7;


contract HAYY is ERC20IBurnable, IERC721Receiver, Ownable {

    constructor() ERC20I("HAYY", "HAYY") {}

    using EnumerableSet for EnumerableSet.UintSet;

    mapping(address => EnumerableSet.UintSet) private _deposits;
    mapping(address => bool) public addressStaked;
    mapping(uint256 => uint256) public tokenIDDays;

    WGG public wildGoat = WGG(0xd151BbC88DB8A7803a2ca7a9722037aBdAca9B8e);

    uint256 ratePerDay = 10 ether; 
    uint256 lockingPeriod = 1;

    uint256 tier1Hayy = 600 ether;
    uint256 tier1Cost = 0.5 ether;

    uint256 tier2Hayy = 1000 ether;
    uint256 tier2Cost = 1 ether;

    uint256 tier3Hayy = 2250 ether;
    uint256 tier3Cost = 2.5 ether;

    uint256[] public burnedTokens;

    function addBurnedTokens(uint256 tokenId) public onlyOwner
    {
        burnedTokens.push(tokenId);
    }

    function changeTier1(uint256 totalHayy, uint256 hayCost) public onlyOwner
    {
        tier1Hayy = (totalHayy * 10 ** 18);
        tier1Cost = (hayCost * 10 ** 18);
    }

    function changeTier2(uint256 totalHayy, uint256 hayCost) public onlyOwner
    {
        tier2Hayy = (totalHayy * 10 ** 18);
        tier2Cost = (hayCost * 10 ** 18);
    }

    function changeTier3(uint256 totalHayy, uint256 hayCost) public onlyOwner
    {
        tier3Hayy = (totalHayy * 10 ** 18);
        tier3Cost = (hayCost * 10 ** 18);
    }

    function devMint(uint256 amount) public onlyOwner
    {
        _mint(msg.sender, (amount * 10 ** 18));
    }

    function setWGGAddress(address incoming) public onlyOwner
    {
        wildGoat = WGG(incoming);
    }

    function buyHayy(uint256 tierLevel) public payable
    {
        require(tierLevel >= 1 && tierLevel <= 3);
        if(tierLevel == 1)
        {
            require(msg.value >= tier1Cost);
            _mint(msg.sender, tier1Hayy);
        }
        else if(tierLevel == 2)
        {
            require(msg.value >= tier2Cost);
            _mint(msg.sender, tier2Hayy);
        }
        else if(tierLevel == 3)
        {
            require(msg.value >= tier3Cost);
            _mint(msg.sender, tier3Hayy);
        }
    }
    
    function changeRatePerDay(uint256 _rate) public onlyOwner
    {
        ratePerDay = (_rate * 10 ** 18);
    }

    function changeLockingPeriod(uint256 _period) public onlyOwner
    {
        lockingPeriod = _period;
    }

    function stakeGoat(uint256[] calldata tokenIDs) external {
        
        require(wildGoat.isApprovedForAll(msg.sender, address(this)), "You are not Approved!");
        
        
        for (uint256 i; i < tokenIDs.length; i++) {
            wildGoat.safeTransferFrom(
                msg.sender,
                address(this),
                tokenIDs[i],
                ''
            );
            
            _deposits[msg.sender].add(tokenIDs[i]);
            addressStaked[msg.sender] = true;
            tokenIDDays[tokenIDs[i]] = block.timestamp;
        }
        
    }

    function unstakeGoat(uint256[] calldata tokenIds) external {
        
        require(wildGoat.isApprovedForAll(msg.sender, address(this)), "You are not Approved!");
        
        this.claimHayy();

        for (uint256 i; i < tokenIds.length; i++) {
            require(
                _deposits[msg.sender].contains(tokenIds[i]),
                'Token not deposited'
            );

            require(daysStaked(tokenIds[i]) >= lockingPeriod, "You must be staked for at least 3 days!");
            
            _deposits[msg.sender].remove(tokenIds[i]);
            
            wildGoat.safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i],
                ''
            );
        }
        if(_deposits[msg.sender].length() < 1)
        {
            addressStaked[msg.sender] = false;
        }
    }

    function returnStakedGoats() public view returns (uint256[] memory)
    {
        return _deposits[msg.sender].values();
    }

    function claimHayy() external
    {
        uint256 totalReward = 0;
        for(uint256 i = 0; i < _deposits[msg.sender].length(); i++)
        {
            totalReward += rewardsToPay(_deposits[msg.sender].at(i));
            tokenIDDays[_deposits[msg.sender].at(i)] = block.timestamp;
        }
        _mint(msg.sender, totalReward);
    }

    function rewardsToPay(uint256 tokenID) internal view returns(uint256)
    {
        uint256 earnedRewards = daysStaked(tokenID) * ratePerDay;
                
        return earnedRewards;
    }

    function daysStaked(uint256 tokenID) public view returns(uint256)
    {
        
        require(
            _deposits[msg.sender].contains(tokenID),
            'Token not deposited'
        );
        
        uint256 returndays;
        uint256 timeCalc = block.timestamp - tokenIDDays[tokenID];
        returndays = timeCalc / 86400;
       
        return returndays;
    }

    function totalYieldEarned() public view returns(uint256)
    {
        uint256 totalReward = 0;
        for(uint256 i = 0; i < _deposits[msg.sender].length(); i++)
        {
            totalReward += rewardsToPay(_deposits[msg.sender].at(i));
        }
        return totalReward;
    }

    function goatsStaked() public view returns (uint256[] memory)
    {
        return _deposits[msg.sender].values();
    }

    function withdrawContractEther() external onlyOwner
    {
        payable(msg.sender).transfer(address(this).balance);
    }

    function walletOfOwner(address address_) public view returns (uint256[] memory) {
        uint256 _balance = wildGoat.balanceOf(address_);
        if (_balance == 0) return new uint256[](0);

        uint256[] memory _tokens = new uint256[] (_balance);
        uint256 _index;
        bool burned = false;
        
        
        for (uint256 i = 1; i <= wildGoat.totalToken(); i++) {
            burned = false;
            
            for(uint256 x=0; x<burnedTokens.length;x++)
            {
                if(i == burnedTokens[x])
                {
                    burned = true;
                }
            }
            if(!burned)
            {
                if (wildGoat.ownerOf(i) == address_) {
                    _tokens[_index] = i; _index++;
                }
            }

        }
        return _tokens;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

}