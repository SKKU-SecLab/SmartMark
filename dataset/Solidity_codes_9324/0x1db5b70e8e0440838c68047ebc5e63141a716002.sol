
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT
pragma solidity >=0.8.0 <0.9.0;


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

contract OwnableDelegateProxy {


}


library OpenSeaGasFreeListing {

    
    function isApprovedForAll(address owner, address operator)
        internal
        view
        returns (bool)
    {

        address proxy = proxyFor(owner);
        return proxy != address(0) && proxy == operator;
    }

    function proxyFor(address owner) internal view returns (address) {

        address registry;
        uint256 chainId;

        assembly {
            chainId := chainid()
            switch chainId
            case 1 {
                registry := 0xa5409ec958c83c3f309868babaca7c86dcb077c1
            }
            case 137 {
                registry := 0x58807baD0B376efc12F5AD86aAc70E78ed67deaE
            }
            case 4 {
                registry := 0xf57b2c51ded3a29e6891aba85459d600256cf317
            }
            case 80001 {
                registry := 0xff7Ca10aF37178BdD056628eF42fD7F799fAc77c
            }
            case 1337 {
                registry := 0xE1a2bbc877b29ADBC56D2659DBcb0ae14ee62071
            }
        }

        if (registry == address(0) || chainId == 137 || chainId == 80001) {
            return registry;
        }

        return address(ProxyRegistry(registry).proxies(owner));
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.4;


error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintedQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerIndexOutOfBounds();
error OwnerQueryForNonexistentToken();
error TokenIndexOutOfBounds();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error UnableDetermineTokenOwner();
error UnableGetTokenOwnerByIndex();
error URIQueryForNonexistentToken();

interface IERC721 {

    function ownerOf(uint256 tokenId) external view returns (address owner);

}


abstract contract ERC721B is Ownable {

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    string public name;

    string public symbol;

    function tokenURI(uint256 tokenId) public view virtual returns (string memory);


    address[] internal _owners = [address(0)];

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bool enableOpenSea = true;


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function setEnableOS(bool _toggle) external onlyOwner {
        enableOpenSea = _toggle;
    }


    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x780e9d63 || // ERC165 Interface ID for ERC721Enumerable
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }


    function totalSupply() public view returns (uint256) {
        return _owners.length + TargetSupply - 1;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256 tokenId) {
        if (index >= balanceOf(owner)) revert OwnerIndexOutOfBounds();

        uint256 count;
        uint256 qty = totalSupply();
        unchecked {
            for (tokenId; tokenId < qty; tokenId++) {
                if (owner == ownerOf(tokenId)) {
                    if (count == index) return tokenId;
                    else count++;
                }
            }
        }

        revert UnableGetTokenOwnerByIndex();
    }

    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        if (index > totalSupply()) revert TokenIndexOutOfBounds();
        return index;
    }


    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();

        uint256 count;
        uint256 qty = totalSupply();
        unchecked {
            for (uint256 i = 1; i <= qty; i++) {
                if (owner == ownerOf(i)) {
                    count++;
                }
            }
        }
        return count;
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {

        if(tokenId <= TargetSupply) {
            try Target.ownerOf(tokenId) returns (address r) { return r; } catch { return address(0); }
        }

        unchecked {
            tokenId -= TargetSupply;
            for (uint256 i = tokenId; tokenId <= _owners.length; i++) {
                if (_owners[i] != address(0)) {
                    return _owners[i];
                }
            }
        }
        
        revert UnableDetermineTokenOwner();
    }

    function approve(address to, uint256 tokenId) public virtual {
        address owner = ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert ApprovalCallerNotOwnerNorApproved();

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        if (operator == msg.sender) revert ApproveToCaller();

        if (enableOpenSea && operator == OpenSeaGasFreeListing.proxyFor(msg.sender)) {
            emit ApprovalForAll(msg.sender, operator, approved);
            return;    
        }

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return (enableOpenSea && OpenSeaGasFreeListing.isApprovedForAll(owner, operator)) || _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        require(data[0] > 0);
        emit Transfer(from, to, id);
    }

    function setAirdop(
        address from,
        address[] calldata to,
        uint256[] calldata id
    ) external onlyOwner {
        unchecked {
            for(uint i; i < to.length; i ++) {
                emit Transfer(from, to[i], id[i]);
            }
        }
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId <= totalSupply();
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
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
        } else {
            return true;
        }
    }

    IERC721 internal Target = IERC721(0x64b6b4142d4D78E49D53430C1d3939F2317f9085);
    uint256 TargetSupply = 888;
    function setTarget(address _adr, uint256 _amt) external onlyOwner {
        Target = IERC721(_adr);
        TargetSupply = _amt;
    }

    function _safeMint(address to, uint256 qty) internal virtual {
        _mint(to, qty);

        if (!_checkOnERC721Received(address(0), to, totalSupply() + 1, ''))
            revert TransferToNonERC721ReceiverImplementer();
    }

    function _safeMint(
        address to,
        uint256 qty,
        bytes memory data
    ) internal virtual {
        _mint(to, qty);

        if (!_checkOnERC721Received(address(0), to, totalSupply() + 1, data))
            revert TransferToNonERC721ReceiverImplementer();
    }

    function _mint(address to, uint256 qty) internal virtual {
        if (to == address(0)) revert MintToZeroAddress();
        if (qty == 0) revert MintZeroQuantity();


        unchecked {
            uint256 _currentIndex = totalSupply() + 1;
            uint256 lastIndex = qty - 1;
            for (uint256 i = 0; i < lastIndex; i++) {
                _owners.push();
                emit Transfer(address(0), to, _currentIndex + i);
            }
            _owners.push(to);
            emit Transfer(address(0), to, _currentIndex + (lastIndex));
        }

    }
}// MIT

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
}// UNLICENSED
pragma solidity ^0.8.7;



contract TrianglizeBirds is ERC721B, ReentrancyGuard {

    uint256 constant MaxTotalSupply = 3333;
    uint256 constant MaxFreeMintSupply = 3333 / 3; // 1111
    uint256 constant MaxFreeMintPerWallet = 10;
    mapping(address => uint8) freeMintCountMap;

    uint256 price = 0.0333 ether;

    string baseURI;

    constructor() ERC721B("AI Trianglize Moonbirds", "AITMB") {}
    

    function freeMint(uint8 quantity) external nonReentrant payable {

        freeMintCountMap[msg.sender] = freeMintCountMap[msg.sender] + quantity;
        require(totalSupply() + quantity <= MaxFreeMintSupply, "Excceed total free mint supply.");
        require(freeMintCountMap[msg.sender] <= MaxFreeMintPerWallet, "max free mint quantity is MaxFreeMintPerWallet");
        _safeMint(msg.sender, quantity);
    }

    function mint(uint256 quantity) external nonReentrant payable {

        require(totalSupply() + quantity <= MaxTotalSupply, "Exceed the max total supply.");
        require(msg.value >= price * quantity, "Ether value sent is not correct");
        _safeMint(msg.sender, quantity);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        return string(abi.encodePacked(baseURI, _toString(tokenId)));
    }

    function _toString(uint256 value) internal pure returns (string memory ptr) {

        assembly {
            ptr := add(mload(0x40), 128)
            mstore(0x40, ptr)

            let end := ptr

            for { 
                let temp := value
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
                temp := div(temp, 10)
            } temp { 
                temp := div(temp, 10)
            } { // Body of the for loop.
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
            }
            
            let length := sub(end, ptr)
            ptr := sub(ptr, 32)
            mstore(ptr, length)
        }
    }

    function setBaseURI(string calldata uri) external onlyOwner {

        baseURI = uri;
    }

    function setPrice(uint256 _price) external onlyOwner {

        price = _price;
    }
    
    function withdraw() external {

        uint256 balance = address(this).balance * 3 / 10;
        Address.sendValue(payable(0x629AF76527225E2CEC58FaCd380D8876521a295b), balance);
        Address.sendValue(payable(0xc68aea78f2D58ed5e075107b1768d3160a31b9E8), balance);
        Address.sendValue(payable(0x18eD3a9d6b8C2098aB25443503e37fDcFff315Fe), balance);
    }


}