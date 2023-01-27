
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


    mapping(uint256 => uint256) private _attrs;

    mapping(address => mapping(address => bool)) private _isApprovedForAll;


    function uri(uint256 id) public view virtual returns (string memory);


    function ownerOf(uint256 id) public view returns (address) {
        return address(uint160(_attrs[id] & 0x00ffffffffffffffffffffffffffffffffffffffff));
    }


    function _setOwner(uint256 id, address to) internal {
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

library Base64 {

    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {

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
}pragma solidity ^0.8.9;



interface ProxyRegistry {

    function proxies(address) external view returns (address);

}

interface IERC2981 {

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}

contract Moonolith is ERC1155U, IERC2981, Ownable {

    using Base64 for *;
    using Strings for uint256;
    using SafeMath for uint256;
    uint256 _currentTokenId = 1;

    bool private _gaslessTrading = true;
    uint256 private _royaltyPartsPerMillion = 50_000;
    uint256 public _pricePerPix = 25000 gwei;

    string public constant name = 'Moonolith';
    string public constant symbol = 'MOON';
    string public _dataProxyUri = "ipfs://";

    uint256 public _threshold = 6862;

    uint256 public _klonSum;

    event Chunk(uint256 indexed id, uint256 indexed position, uint256 ymax, uint256 ymaxLegal, uint256 nbpix, bytes image);
    mapping(uint256 => uint256) chunkBlocks;

    address public constant creator1Address = 0x2D59325C5E9BB0e40d125Eefa1Da4c3793C604c7;
    address public constant creator2Address = 0x474e00810333F3362c17480C3Ba9eBC75507af2D;
    address public constant creator3Address = 0x0a7792C2fD7bF4bC25f4d3735E8aD9f59570aCBe;
    address public constant creator4Address = 0x1C592Db0c01413b8c857534B373A5f96c058968F;


    function draw2438054C(uint256 position, uint256 ymax, uint256 nbpix, bytes calldata image) external payable {

        require(ymax * 1000000  <= 192 * 1000000 + _klonSum * _threshold, "Out of monolith");
        require(msg.value >= nbpix * _pricePerPix, "Not enough eth");
        require(nbpix > 0, "Cannot send empty mark");
        uint256 index = _currentTokenId;
        _klonSum += nbpix;
        emit Chunk(_currentTokenId, position, ymax, 192 * 1000000 + _klonSum * _threshold, nbpix, image);
        emit TransferSingle(msg.sender, address(0), msg.sender, index, 1);
        _setOwner(index, msg.sender);
        unchecked {
            index++;
        }
        _currentTokenId = index;
    }

    function totalSupply() public view returns (uint256) {

        unchecked {
            return _currentTokenId - 1;
        }
    }

    function getMonolithInfo() public view returns (uint256 supply, uint256 threshold, uint256 klonTotal, uint256 price) {

        return (totalSupply(), _threshold, _klonSum, _pricePerPix);
    }

    function uri(uint256 _tokenId) public view virtual override returns (string memory) {

		require(_tokenId <= _currentTokenId, "URI query for nonexistent token");

		bytes memory baseURI = (abi.encodePacked(
			'{', 
            '"description": "Moonolith","external_url": "https://moonolith.io","animation_url": "',
            _dataProxyUri,
            _tokenId.toString(),
            '","image":"ipfs://QmYJ5ZSMjTAuhQeJMZgcuVG2u2eFyJejgL8bDRjwpKsgSb/"',
            '}'
		));
	
		return string(abi.encodePacked(
			"data:application/json;base64,",
			baseURI.encode()
		));
			
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
                if (ProxyRegistry(0xa5409ec958C83C3f309868babACA7c86DCB077c1).proxies(owner) == operator) {
                    return true;
                }
        }
        return super.isApprovedForAll(owner, operator);
    }

    
    function setAllowGaslessListing(bool allow) public onlyOwner {

        _gaslessTrading = allow;
    }

    function setDataProxyUri(string calldata newProxy ) public onlyOwner {

        _dataProxyUri = newProxy;
    }

    function setThreshold(uint256 threshold) public onlyOwner {

        _threshold = threshold;
    }

    function setPrice(uint256 price) public onlyOwner {

        _pricePerPix = price;
    }

    function setRoyaltyPPM(uint256 newValue) public onlyOwner {

        require(newValue < 1_000_000, 'Must be < 1e6');
        _royaltyPartsPerMillion = newValue;
    }


    function withdraw() external {

        uint256 b = address(this).balance;
        _withdraw(creator1Address, b.mul(325).div(1000));
        _withdraw(creator2Address, b.mul(325).div(1000));
        _withdraw(creator4Address, b.mul(100).div(1000));
        _withdraw(creator3Address, address(this).balance);
    }

    function _withdraw(address _address, uint256 _amount) private {

        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    function withdrawERC20(IERC20 erc20Token) public onlyOwner {

        erc20Token.transfer(msg.sender, erc20Token.balanceOf(address(this)));
    }
}