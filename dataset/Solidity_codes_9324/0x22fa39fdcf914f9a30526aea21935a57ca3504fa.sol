
pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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


abstract contract ERC721B {

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    string public name;

    string public symbol;

    function tokenURI(uint256 tokenId) public view virtual returns (string memory);


    address[] internal _owners;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;


    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }





    function totalSupply() public view returns (uint256) {
        return _owners.length;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256 tokenId) {
        if (index >= balanceOf(owner)) revert ('OwnerIndexOutOfBounds');

        uint256 count;
        for (uint256 i; i < _owners.length; i++) {
            if (owner == ownerOf(i)) {
                if (count == index) return i;
                else count++;
            }
        }

        revert ('UnableGetTokenOwnerByIndex');
    }

    function tokenByIndex(uint256 index) public view virtual returns (uint256) {
        if (index >= totalSupply()) revert ('TokenIndexOutOfBounds');
        return index;
    }


    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) revert ('BalanceQueryForZeroAddress');

        uint256 count;
        for (uint256 i = 0; i < _owners.length; i++) {
            if (owner == ownerOf(i)) {
                unchecked {
                    count++;
                }
            }
        }
        return count;
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        if (!_exists(tokenId)) revert ('OwnerQueryForNonexistentToken');

        for (uint256 i = tokenId; ; i++) {
            if (_owners[i] != address(0)) {
                return _owners[i];
            }
        }

        revert ('UnableDetermineTokenOwner');
    }

    function approve(address to, uint256 tokenId) public virtual {
        address owner = ownerOf(tokenId);
        if (to == owner) revert ('ApprovalToCurrentOwner');

        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert ('ApprovalCallerNotOwnerNorApproved');

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual returns (address) {
        if (!_exists(tokenId)) revert ('ApprovalQueryForNonexistentToken');

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        if (operator == msg.sender) revert ('ApproveToCaller');

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        if (!_exists(tokenId)) revert ('OwnerQueryForNonexistentToken');
        if (ownerOf(tokenId) != from) revert ('TransferFromIncorrectOwner');
        if (to == address(0)) revert ('TransferToZeroAddress');

        bool isApprovedOrOwner = (msg.sender == from ||
            msg.sender == getApproved(tokenId) ||
            isApprovedForAll(from, msg.sender));
        if (!isApprovedOrOwner) revert ('TransferCallerNotOwnerNorApproved');

        delete _tokenApprovals[tokenId];
        _owners[tokenId] = to;

        if (tokenId > 0) {
            if (_owners[tokenId - 1] == address(0)) {
                _owners[tokenId - 1] = from;
            }
        }

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        if (!_checkOnERC721Received(from, to, id, '')) revert ('TransferToNonERC721ReceiverImplementer');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, id);

        if (!_checkOnERC721Received(from, to, id, data)) revert ('TransferToNonERC721ReceiverImplementer');
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId < _owners.length;
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
                    revert ('TransferToNonERC721ReceiverImplementer');
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


    function _safeMint(address to, uint256 qty) internal virtual {
        _mint(to, qty);

        if (!_checkOnERC721Received(address(0), to, _owners.length - 1, ''))
            revert ('TransferToNonERC721ReceiverImplementer');
    }

    function _safeMint(
        address to,
        uint256 qty,
        bytes memory data
    ) internal virtual {
        _mint(to, qty);

        if (!_checkOnERC721Received(address(0), to, _owners.length - 1, data))
            revert ('TransferToNonERC721ReceiverImplementer');
    }

    function _mint(address to, uint256 qty) internal virtual {
        if (to == address(0)) revert ('MintToZeroAddress');
        if (qty == 0) revert ('MintZeroQuantity');

        uint256 _currentIndex = _owners.length;

        for (uint256 i = 0; i < qty - 1; i++) {
            _owners.push();
            emit Transfer(address(0), to, _currentIndex + i);
        }

        _owners.push(to);
        emit Transfer(address(0), to, _currentIndex + (qty - 1));
    }
}// MIT

pragma solidity ^0.8.4;

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
}// MIT

pragma solidity ^0.8.4;

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

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.4;


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

pragma solidity ^0.8.4;

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

pragma solidity ^0.8.4;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.4;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.4;


interface IERC2981  {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}// MIT
pragma solidity ^0.8.4;

library HexStrings {

    bytes16 internal constant ALPHABET = '0123456789abcdef';

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}library ToColor {
    bytes16 internal constant ALPHABET = '0123456789abcdef';

    function toColor(bytes3 value) internal pure returns (string memory) {

      bytes memory buffer = new bytes(6);
      for (uint256 i = 0; i < 3; i++) {
          buffer[i*2+1] = ALPHABET[uint8(value[i]) & 0xf];
          buffer[i*2] = ALPHABET[uint8(value[i]>>4) & 0xf];
      }
      return string(buffer);
    }
}pragma solidity ^0.8.4;





abstract contract ERC2981ContractWideRoyalties is IERC2981, ERC165 {
    address private _royaltiesRecipient;
    uint256 private _royaltiesValue;



    function _setRoyalties(address recipient, uint256 value) internal {
        require(value <= 10000, 'ERC2981Royalties: Too high');
        _royaltiesRecipient = recipient;
        _royaltiesValue = value;
    }

    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        return (_royaltiesRecipient, (value * _royaltiesValue) / 10000);
    }
}

contract YourCollectible is ERC721B, Ownable, ReentrancyGuard, ERC2981ContractWideRoyalties {


  using Strings for uint256;
  using HexStrings for uint160;
  using ToColor for bytes3;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  bool public mintingActive = false;

   address payable public constant recipient =
    payable(0x38B2bAC6431604dFfEc17a1E6Adc649a9Ea0eFba);

    uint256 public price = 0.00 ether;



  constructor() public ERC721B("ETHERHEARTS", "EHRT") Ownable() {
    _setRoyalties(owner(), 130);
  }


  mapping (uint256 => bytes3) public color;
 
  mapping (uint256 => uint256) public messages;
  mapping (uint256 => uint256) public chubbiness;
  uint256 mintDeadline = block.timestamp + 24 hours;
  
            

      function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }



        function activeCheck() public onlyOwner {

          owner();

        mintingActive = !mintingActive;
    }

      function devMintItem(uint256 quantity)
      public
      
      onlyOwner     
      returns (uint256)
      
  { 

  


      uint256 id; 
      _safeMint(msg.sender, quantity);
      for (uint i=0; i < quantity; i++)   {
      _tokenIds.increment();
      id = _tokenIds.current();
     
      tokenURI(id);
      
     
      bytes32 predictableRandom = keccak256(abi.encodePacked( blockhash(block.number+quantity), address(this), id, quantity));  
      color[id] = bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 );
  
      messages[id] = (uint8(predictableRandom[4]) % 29 );
      }
    
      return id;
  }

  function mintItem(uint256 quantity)
      public  
      nonReentrant    
      returns (uint256)
  { 

      uint256 lastTokenId = super.totalSupply();
      require( block.timestamp < mintDeadline, 'DONE MINTING');
      require(mintingActive, '\u2764\ufe0f minting soon \u2764\ufe0f');  
      require( quantity <=uint256(5), 'leave some \u2764\ufe0f for the rest of us!');
      require( lastTokenId + quantity <= uint256(222), 'till next year loves \u2764\ufe0f');
      require(!isContract(msg.sender), 'no bots allowed fren.');

      price = price;

      uint256 id; 
      _safeMint(msg.sender, quantity);
      for (uint i=0; i < quantity; i++)   {
      _tokenIds.increment();
      id = _tokenIds.current() - 1;
     
      tokenURI(id);
      
     
      bytes32 predictableRandom = keccak256(abi.encodePacked( blockhash(block.number+quantity), address(this), id, quantity));  
      color[id] = bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 );
  
      messages[id] = (uint8(predictableRandom[4]) % 29 );
      }


    
      return id;
  }



  function tokenURI(uint256 id) public view override returns (string memory) {

      require(_exists(id), "not exist");
      
      string memory name = string(abi.encodePacked('EtherHeart #',id.toString()));
      string memory description = string(abi.encodePacked('this heart beats the color#',color[id].toColor(),' !!!'));
      string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));
      

      return
          string(
              abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                          abi.encodePacked(
                              '{"name":"',
                              name,
                              '", "description":"',
                              description,
                              '", "external_url":"https://buidlguidl.com',
                              id.toString(),
                              '", "attributes": [{"trait_type": "color", "value": "#',
                              color[id].toColor(),
                              '"}], "owner":"',
                              (uint160(ownerOf(id))).toHexString(20),
                              '", "image": "',
                              'data:image/svg+xml;base64,',
                              image,
                              '"}'
                          )
                        )
                    )
              )
          );
  }

  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {

    

    string memory svg = string(abi.encodePacked(
      '<svg width="100%" height="100%" viewBox="0 0 900 900" xmlns="http://www.w3.org/2000/svg">',
        renderTokenById(id),
      '</svg>'
    ));

    return svg;

  }

  function renderTokenById(uint256 id) public view returns (string memory) {

    string[32] memory messageTxt = [ 'RIGHT-CLICK MY HEART','I \u27e0 U','U SWEPT ME OFF MY FLOOR','TOGETHER TILL \u27e0 2.0 SHIPS', 'U RUG MY WORLD', 'BE MINED', 'HODL ME', '0x0x', 'FRONT RUN ME', 'MEV AND CHILL?', 'UR ON MY WHITELIST', 'DECENTRALIZE ME BABY', 'UR MY 1/1', 'BE MY BAY-C', 'EVM COMPATIBLE', 'MAXI 4 U', 'ON-CHAIN HOTTIE', 'U R NONFUNGIBLE TO ME', 'U R MY CRYPTONITE', 'CURATE ME', 'GWEI OUT WITH ME', 'SEEDPHRASE 2 MY \u2764\ufe0f', 'UR A FOX', 'ETHERSCAN ME', '\u26f5 OPEN TO YOUR SEA \u26f5', 'UR MY FOUNDATION', 'U R SUPERRARE', 'ILY.ETH', '$LOOK-in GOOD', 'JPEG ME', 'NON-FUNGIBLE BABY', 'MY LOVE IS LIQUID'  ] ;
    string memory render = string(abi.encodePacked(
        '<g id="head">',
          '<path id="Bottom" d="M70,279.993C70,279.993 63.297,379.987 70,427.647C85.329,536.631 300.49,820.025 450.016,820.025C599.542,820.025 817.839,533.159 830.014,423.782C835.6,373.594 830.007,280.007 830.007,280.007" style="fill:#', 
          color[id].toColor(), ';stroke:rgb(0,0,0);stroke-width:5px;"/>',
        '<path id="Top" d="M449.75,149.777C426.146,149.777 401.744,80.04 249.999,80.001C139.6,79.972 70,169.594 70,279.993C70,450.051 347.857,689.996 450.004,689.996C552.151,689.996 830.007,449.95 830.007,280.007C830.007,169.801 760.231,80.049 650.026,80.049C486.311,80.049 473.355,149.777 449.75,149.777Z" style="fill:#',
        color[id].toColor(), ';stroke:rgb(0,0,0);stroke-width:5px;"/>',
        '<text x="50%" y="40%" dominant-baseline="middle" text-anchor="middle" stroke="rgb(211, 73, 78)" stroke-width= "5" font-weight="400" font-size="48" font-family="Helvetica" fill="rgb(211, 73, 78)">' , messageTxt[messages[id]], '</text>',
        '</g>'
      ));

    return render;
  }


}