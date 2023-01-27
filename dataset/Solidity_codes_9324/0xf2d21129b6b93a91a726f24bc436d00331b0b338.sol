



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

abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}



pragma solidity ^0.8.0;

library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

library Stringify {
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

  function toString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);
    }
    return string(abi.encodePacked('0x', string(s)));
 }

  function char(bytes1 b) internal pure returns (bytes1 c) {
      if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
      else return bytes1(uint8(b) + 0x57);
  }
}



pragma solidity ^0.8.0;



struct CollectionInfo {
  address addr;
  string name;
  string symbol;
  address patron;
}

struct Token {
  address collection;
  uint256 id;
}
contract PatronTokens is ERC721URIStorage {
  Token[] _registeredTokens;
  mapping(address => mapping (uint256 => bool)) _registeredTokensSet;

  address[] _registeredCollections;
  mapping(address =>  bool) _registeredCollectionsSet;

  address public _dt;

  constructor(address dtAddr) ERC721("DoubleTrouble Patron Tokens", "PTRN") {
    _dt = dtAddr;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == 0xdeadbeef || super.supportsInterface(interfaceId);
  }

  function registeredTokens() external view returns (Token[] memory) {
    return _registeredTokens;
  }

  function totalSupply() external view returns (uint256) {
    return _registeredCollections.length;
  }

  function registerToken(address collection, uint256 tokenId) public {
    require(msg.sender == _dt, "Only the DoubleTrouble contract can call this");
    if (!_registeredTokensSet[collection][tokenId]) {
      _registeredTokensSet[collection][tokenId] = true;
      _registeredTokens.push(Token(collection, tokenId));
    }
  }

  function tryToClaimPatronToken(address collection, address receiverOfNft) public {
    require(msg.sender == _dt, "Only the DoubleTrouble contract can call this");

    if (!_registeredCollectionsSet[collection]) {
      _registeredCollectionsSet[collection] = true;
      _registeredCollections.push(collection);

      _safeMint(receiverOfNft, _registeredCollections.length - 1);
    }
  }

  function patronTokenIdForCollection(address collection) public view returns (bool, uint256) {
    for (uint i = 0; i < _registeredCollections.length; i++) {
      if (collection == address(_registeredCollections[i])) {
        return (true, i);
      }
    }
    return (false, 0);
  }

  function patronOf(address collection) public view returns (address) {
    (bool found, uint256 tokenId) = patronTokenIdForCollection(collection);
    if (!found) {
      return address(0);
    }
    return ownerOf(tokenId);
  }

  function patronedCollection(uint256 tokenId) public view returns (address) {
    return _registeredCollections[tokenId];
  }

  function patronedCollectionInfo(uint256 tokenId) public view returns (CollectionInfo memory) {
    IERC721Metadata c = IERC721Metadata(_registeredCollections[tokenId]);
    return CollectionInfo(_registeredCollections[tokenId], c.name(), c.symbol(), ownerOf(tokenId));
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(tokenId < _registeredCollections.length, "tokenId not present");
    string memory collectionAddr = Stringify.toString(_registeredCollections[tokenId]);
    string memory strTokenId = Stringify.toString(tokenId);

    string[20] memory parts;
    uint256 lastPart = 0;
    parts[lastPart++] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 400 400"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

    parts[lastPart++] = string(abi.encodePacked('PTRN #', strTokenId));
    parts[lastPart++] = '</text>';

    try IERC721Metadata(_registeredCollections[tokenId]).name() returns (string memory name) {
      parts[lastPart++] = '<text x="10" y="40" class="base">';
      parts[lastPart++] = name;
      parts[lastPart++] = '</text>';
    } catch (bytes memory /*lowLevelData*/) {
    }

    try IERC721Metadata(_registeredCollections[tokenId]).symbol() returns (string memory symbol) {
      parts[lastPart++] = '<text x="10" y="60" class="base">';
      parts[lastPart++] = symbol;
      parts[lastPart++] = '</text>';
    } catch (bytes memory /*lowLevelData*/) {
    }

    parts[lastPart++] = '<text x="10" y="80" class="base">';
    parts[lastPart++] = string(abi.encodePacked('Collection: ', collectionAddr));

    parts[lastPart++] = '</text></svg>';

    string memory output;
    for (uint256 i = 0; i < lastPart; i++) {
      output = string(abi.encodePacked(output, parts[i]));
    }

    string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "PTRN #', strTokenId, '", "collection": "',
                                                                      collectionAddr, '", "description": "Whoever owns this PTRN token is the Patron for this collection. Patrons automatically get a % fee for any NFT from this collection sold within Double Trouble.", "image": "data:image/svg+xml;base64,',
                                                                      Base64.encode(bytes(output)), '"}'))));
    output = string(abi.encodePacked('data:application/json;base64,', json));

    return output;
  }
}



pragma solidity ^0.8.0;




struct TokenInfo {
   address collection;
   uint256 tokenId;
   uint256 lastPurchasePrice;
   uint256 forSalePrice;
   uint256 availableToWithdraw;
}

contract DoubleTrouble {
  mapping(address => mapping (uint256 => uint256)) _forSalePrices;
  mapping(address => mapping (uint256 => uint256)) _lastPurchasePrices;
  mapping(address => mapping (uint256 => uint256)) _lastPurchaseTimes;
  mapping(address => mapping (uint256 => address)) _owners;
  address _feeWallet;
  uint256 public _feeRate;
  uint256 public _daysForWithdraw;
  uint256 public _dtNumerator;
  uint256 public _dtDenominator;
  PatronTokens public _pt;

  event Buy(address oldOwner, address newOwner, address collection, uint256 tokenId, uint256 valueSent, uint256 amountPaid);
  event ForceBuy(address oldOwner, address newOwner, address collection, uint256 tokenId, uint256 valueSent, uint256 lastPurchasePrice, uint256 amountPaid);
  event SetPrice(address msgSender, address collection, uint256 tokenId, uint256 price);
  event Withdraw(address owner, address collection, uint256 tokenId, uint256 lastPurchasePrice);

  constructor(address ptdAddr, uint256 daysForWithdraw, uint256 dtNumerator, uint256 dtDenominator, uint256 feeRate,
              address feeWallet) {
    _feeWallet = feeWallet;
    _daysForWithdraw = daysForWithdraw;
    _dtNumerator = dtNumerator;
    _dtDenominator = dtDenominator;
    _feeRate = feeRate;
    _pt = PatronTokensDeployer(ptdAddr).deployIdempotently(address(this));
  }

  function patronTokensCollection() external view returns (address) {
    return address(_pt);
  }

  function forSalePrice(address collection, uint256 tokenId) external view returns (uint256) {
    return _forSalePrices[collection][tokenId];
  }

  function lastPurchasePrice(address collection, uint256 tokenId) external view returns (uint256) {
    return _lastPurchasePrices[collection][tokenId];
  }

  function lastPurchaseTime(address collection, uint256 tokenId) external view returns (uint256) {
    return _lastPurchaseTimes[collection][tokenId];
  }

  function availableToWithdraw(address collection, uint256 tokenId) external view returns (uint256) {
    return _lastPurchaseTimes[collection][tokenId] + (_daysForWithdraw * 1 days);
  }

  function secondsToWithdraw(address collection, uint256 tokenId) external view returns (int256) {
    unchecked {
      return int256(this.availableToWithdraw(collection, tokenId) - block.timestamp);
    }
  }

  function originalTokenURI(address collection, uint256 tokenId) external view returns (string memory) {
    return IERC721Metadata(collection).tokenURI(tokenId);
  }

  function ownerOf(address collection, uint256 tokenId) public view returns (address) {
    return _owners[collection][tokenId];
  }

  function setPrice(address collection, uint256 tokenId, uint256 price) external {
    _pt.registerToken(collection, tokenId);

    if (_lastPurchasePrices[collection][tokenId] == 0) {
      require(IERC721Metadata(collection).getApproved(tokenId) == msg.sender ||
              IERC721Metadata(collection).ownerOf(tokenId) == msg.sender, "msg.sender should be approved or owner of original NFT");
    } else {
      require(ownerOf(collection, tokenId) == msg.sender, "msg.sender should be owner of NFT");
    }
    _forSalePrices[collection][tokenId] = price;

    emit SetPrice(msg.sender, collection, tokenId, price);
  }

  function buy(address collection, uint256 tokenId) payable external {
    require(_forSalePrices[collection][tokenId] > 0, "NFT is not for sale");
    require(msg.value >= _forSalePrices[collection][tokenId], "Value sent must be at least the for sale price");
    _pt.registerToken(collection, tokenId);

    if (_owners[collection][tokenId] == address(0)) {
      require(IERC721Metadata(collection).getApproved(tokenId) == address(this), "DoubleTrouble contract must be approved to operate this token");

      address owner = IERC721Metadata(collection).ownerOf(tokenId);
      IERC721Metadata(collection).transferFrom(owner, address(this), tokenId);
      _owners[collection][tokenId] = owner;
    }

    emit Buy(_owners[collection][tokenId], msg.sender, collection, tokenId, msg.value, _forSalePrices[collection][tokenId]);
    _completeBuy(_owners[collection][tokenId], msg.sender, collection, tokenId, _forSalePrices[collection][tokenId]);
  }

  function forceBuy(address collection, uint256 tokenId) payable external {
    require(_lastPurchasePrices[collection][tokenId] > 0, "NFT was not yet purchased within DoubleTrouble");
    uint256 amountToPay = _dtNumerator * _lastPurchasePrices[collection][tokenId] / _dtDenominator;
    require(msg.value >= amountToPay, "Value sent must be at least twice the last purchase price");
    _pt.registerToken(collection, tokenId);

    emit ForceBuy(_owners[collection][tokenId], msg.sender, collection, tokenId, msg.value,
                  _lastPurchasePrices[collection][tokenId], amountToPay);
    _completeBuy(_owners[collection][tokenId], msg.sender, collection, tokenId, amountToPay);
  }

  function _completeBuy(address oldOwner, address newOwner, address collection, uint256 tokenId, uint256 amountToPay) internal virtual {
    require(_owners[collection][tokenId] == oldOwner, "old owner must match");

    _pt.tryToClaimPatronToken(collection, oldOwner);

    _owners[collection][tokenId] = newOwner;
    _lastPurchasePrices[collection][tokenId] = amountToPay;
    _lastPurchaseTimes[collection][tokenId] = block.timestamp;
    _forSalePrices[collection][tokenId] = 0;
    uint256 patronFee = amountToPay / _feeRate;

    uint256 amountSent = amountToPay - 2 * patronFee;
    (bool oldOwnersuccess, ) = oldOwner.call{value: amountSent}("");
    require(oldOwnersuccess, "Transfer to owner failed.");

    _sendFees(collection, patronFee, msg.value - amountSent);
  }

  function _sendFees(address collection, uint256 patronFee, uint256 valueLeft) internal virtual {
    address patron = _pt.patronOf(collection);
    (bool patronSuccess, ) = patron.call{value: patronFee}("");

    uint256 rest = patronSuccess ? valueLeft - patronFee : valueLeft;
    (bool feeWalletSuccess, ) = _feeWallet.call{value: rest}("");
    require(feeWalletSuccess, "Transfer to DT wallet failed.");
  }

  function withdraw(address collection, uint256 tokenId) payable external {
    require(_owners[collection][tokenId] == msg.sender, "msg.sender should be owner of NFT");
    require(block.timestamp > this.availableToWithdraw(collection, tokenId), "NFT not yet available to withdraw from Double Trouble");
    require(msg.value >= _lastPurchasePrices[collection][tokenId] / _feeRate * 2, "Must pay fee to withdraw");

    uint256 pricePaid = _lastPurchasePrices[collection][tokenId];
    emit Withdraw(_owners[collection][tokenId], collection, tokenId, pricePaid);

    IERC721Metadata(collection).transferFrom(address(this), _owners[collection][tokenId], tokenId);

    _owners[collection][tokenId] = address(0);
    _lastPurchasePrices[collection][tokenId] = 0;
    _forSalePrices[collection][tokenId] = 0;
    _lastPurchaseTimes[collection][tokenId] = 0;

    _sendFees(collection, pricePaid / _feeRate, msg.value);
  }

  function allKnownTokens() external view returns (TokenInfo[] memory) {
    Token[] memory knownTokens = _pt.registeredTokens();
    TokenInfo[] memory ret = new TokenInfo[](knownTokens.length);
    for (uint256 i = 0; i < knownTokens.length; i++) {
      Token memory t = knownTokens[i];
      ret[i] = TokenInfo(t.collection, t.id, _lastPurchasePrices[t.collection][t.id], _forSalePrices[t.collection][t.id],
                         _lastPurchaseTimes[t.collection][t.id] + (_daysForWithdraw * 1 days));
    }
    return ret;
  }
}

contract PatronTokensDeployer {
  mapping(address =>  PatronTokens) _deployed;

  function deployIdempotently(address dt) public returns (PatronTokens) {
    if (address(_deployed[dt]) == address(0)) {
      _deployed[dt] = new PatronTokens(dt);
    }
    return _deployed[dt];
  }
}