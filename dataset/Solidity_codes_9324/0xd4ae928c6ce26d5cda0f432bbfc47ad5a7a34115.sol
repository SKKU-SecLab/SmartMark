
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


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

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
pragma solidity ^0.8.7;

interface IERC2981 {

  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount);

}

pragma solidity >=0.6.0;

library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

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

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}
pragma solidity ^0.8.11;


contract UnauthorizedAuthentic is ERC165, IERC2981, IERC1155MetadataURI, Ownable {

  using Address for address;
  using Strings for uint256;

  string public constant name = "Unauthorized Authentic";
  string public constant symbol = "UA-NFT";
  address private constant outerpockets = 0xcB4B6bd8271B4f5F81d46CbC563ae9e4F97B5a37;

  uint256 public immutable startingPrice; // 20 ether
  uint256 public immutable endingPrice; // 0.1 ether
  uint256 public immutable auctionEnd; // block height at end
  uint256 public immutable auctionStart; // block height at start
  uint256 private immutable reductionRate;
  address private royaltyAddress;
  uint256 private royaltyPercentage; // in basis points

  mapping(address => mapping(address => bool)) private operatorApprovals;
  mapping(uint256 => TokenData) public tokens;
  address[] public factories;

  struct TokenData {
    address owner;
    uint32 factoryA;
    uint32 factoryB;
    uint32 factoryC;
  }

  event FactoryListing(address indexed factory, uint256 factoryIndex);
  event Sale(uint256 indexed tokenId, uint256 price);

  constructor(
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _auctionDuration
  ) {
    startingPrice = _startingPrice;
    endingPrice = _endingPrice;
    auctionEnd = _auctionDuration + block.number;
    auctionStart = block.number;
    reductionRate = (_startingPrice - _endingPrice) / _auctionDuration;
    updateRoyaltyAddress(outerpockets);
    updateRoyaltyPercentage(750);
    transferOwnership(outerpockets);
  }

  
  function supportsInterface(bytes4 _interfaceId) public view override(ERC165, IERC165) returns (bool) {

    return
      _interfaceId == type(IERC1155).interfaceId ||
      _interfaceId == type(IERC1155MetadataURI).interfaceId ||
      _interfaceId == type(IERC2981).interfaceId ||
      super.supportsInterface(_interfaceId);
  }

  function contractURI() external view returns (string memory) {

    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
        abi.encodePacked(
          '{'
            '"name": "', name, '",'
            '"description": "**UNAUTHORIZED AUTHENTIC**\\n\\n'
            '\\"Unauthorized Authentics\\" are not simply \\"fakes\\" or \\"copies\\".'
            ' Their metadata is manufactured in the same contracts, by the same code,'
            ' producing the exact same bytes as the originals they replicate.'
            '\\n\\n`.a work by outerpockets.`",'
            '"image": "https://www.unauthedauth.com/default.png",'
            '"seller_fee_basis_points": ', royaltyPercentage.toString(), ','
            '"fee_recipient": "', uint256(uint160(royaltyAddress)).toHexString(20),'",'
            '"external_link": "https://www.unauthedauth.com/"'
          '}'
        ))
    ));
  }

  function royaltyInfo(uint256, uint256 _salePrice) external view override returns (address, uint256) {

    return (
      royaltyAddress,
      _salePrice * royaltyPercentage / 10000
    );
  }

  function updateRoyaltyAddress(address _royaltyAddress) public onlyOwner {

    royaltyAddress = _royaltyAddress;
  }
  
  function updateRoyaltyPercentage(uint256 _royaltyPercentage) public onlyOwner {

    royaltyPercentage = _royaltyPercentage;
  }


  function addFactory(address _factory) public returns (uint256) {

    factories.push(_factory);
    uint256 index = factories.length - 1;
    emit FactoryListing(_factory, index);
    return index;
  }

  function getFactories(uint256 _tokenId) external view returns (address, address, address) {

    return (
      factories[tokens[_tokenId].factoryA],
      factories[tokens[_tokenId].factoryB],
      factories[tokens[_tokenId].factoryC]
    );
  }

  function switchFactories(
    uint256 _tokenId,
    address[3] calldata _factoryAddresses,
    uint256[3] memory _factoryIndexes
  ) external {

    require(msg.sender == ownerOf(_tokenId));
    if (_factoryAddresses[0] != address(0)) {
      _factoryIndexes[0] = addFactory(_factoryAddresses[0]);
    }
    if (_factoryAddresses[1] != address(0)) {
      if (_factoryAddresses[1] == _factoryAddresses[0]) {
        _factoryIndexes[1] = _factoryIndexes[0];
      } else {
        _factoryIndexes[1] = addFactory(_factoryAddresses[1]);
      }
    }
    if (_factoryAddresses[2] != address(0)) {
      if (_factoryAddresses[2] == _factoryAddresses[0]) {
        _factoryIndexes[2] = _factoryIndexes[0];
      } else if (_factoryAddresses[2] == _factoryAddresses[1]) {
        _factoryIndexes[2] = _factoryIndexes[1];
      } else {
        _factoryIndexes[2] = addFactory(_factoryAddresses[2]);
      }
    }
    switchFactories(
      _tokenId,
      _factoryIndexes[0],
      _factoryIndexes[1],
      _factoryIndexes[2]
    );
  }

  function switchFactories(
    uint256 _tokenId,
    uint256 _factoryIndexA,
    uint256 _factoryIndexB,
    uint256 _factoryIndexC
  ) public {

    tokens[_tokenId].factoryA = uint32(_factoryIndexA);
    tokens[_tokenId].factoryB = uint32(_factoryIndexB);
    tokens[_tokenId].factoryC = uint32(_factoryIndexC);
  }

  function mint(uint256 _tokenId) external payable {

    require(msg.value >= price(block.number), "INSUFFICIENT ETH SENT");
    require(!exists(_tokenId), "TOKEN ID ALREADY EXISTS");
    tokens[_tokenId].owner = msg.sender;
    emit Sale(_tokenId, msg.value);
    emit TransferSingle(msg.sender, address(0), msg.sender, _tokenId, 1);
  }

  function price(uint256 _blockNumber) public view returns (uint256) {

    if (_blockNumber <= auctionEnd) {
      return startingPrice - (_blockNumber - auctionStart) * reductionRate;
    } else {
      return endingPrice;
    }
  }

  function withdraw() external onlyOwner {

    Address.sendValue(payable(royaltyAddress), address(this).balance);
  }


  function balanceOf(address _account, uint256 _tokenId) public view override returns (uint256) {

    address owner = ownerOf(_tokenId);
    require(exists(_tokenId), "TOKEN DOESN'T EXIST");
    return  owner == _account ? 1 : 0;
  }

  function balanceOfBatch(
    address[] calldata _accounts,
    uint256[] calldata _tokenIds
  ) public view override returns (uint256[] memory) {

    require(
      _accounts.length == _tokenIds.length,
      "ARRAYS NOT SAME LENGTH"
    );
    uint256[] memory batchBalances = new uint256[](_accounts.length);
    for (uint256 i = 0; i < _accounts.length; ++i) {
      batchBalances[i] = balanceOf(_accounts[i], _tokenIds[i]);
    }
    return batchBalances;
  }
  
  function exists(uint256 _tokenId) public view returns (bool) {

    return tokens[_tokenId].owner != address(0);
  }

  function isApprovedForAll(address _owner, address _operator) public view override returns (bool) {

    return operatorApprovals[_owner][_operator];
  }

  function ownerOf(uint256 _tokenId) public view returns (address) {

    address owner = tokens[_tokenId].owner;
    require(owner != address(0), "TOKEN DOESN'T EXIST");
    return owner;
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) external {

    safeTransferFrom(_from, _to, _tokenId, 1, _data);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) public override {

    require(_to != address(0), "INVALID RECEIVER");
    require(
      _from == msg.sender || isApprovedForAll(_from, msg.sender),
      "NOT AUTHED"
    );
    require(
        _amount == 1 && ownerOf(_tokenId) == _from,
        "INVALID SENDER"
    );
    tokens[_tokenId].owner = _to;
    emit TransferSingle(msg.sender, _from, _to, _tokenId, 1);
    _safeTransferCheck(msg.sender, _from, _to, _tokenId, 1, _data);
  }

  function safeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] calldata _tokenIds,
    uint256[] calldata _amounts,
    bytes calldata _data
  ) public override {

    uint256 length = _tokenIds.length;
    require(
      length == _amounts.length,
      "ARRAYS NOT SAME LENGTH"
    );
    require(_to != address(0), "INVALID RECEIVER");
    require(
      _from == msg.sender || isApprovedForAll(_from, msg.sender),
      "NOT AUTHED"
    );

    for (uint256 i = 0; i < length; ++i) {
      uint256 id = _tokenIds[i];
      require(
        _amounts[i] == 1 && ownerOf(id) == _from,
        "INVALID SENDER"
      );
      tokens[id].owner = _to;
    }
    
    emit TransferBatch(msg.sender, _from, _to, _tokenIds, _amounts);

    _safeBatchTransferCheck(
      msg.sender,
      _from,
      _to,
      _tokenIds,
      _amounts,
      _data
    );
  }

  function setApprovalForAll(address _operator, bool _approved) public override {

    require(msg.sender != _operator, "CAN'T APPROVE SELF");
    operatorApprovals[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }
  
  function uri(uint256 _tokenId) external view override returns (string memory) {

    require(exists(_tokenId), "TOKEN DOESN'T EXIST");
    uint256 timeswitch = (block.timestamp % 10800) / 3600;
    uint256 index;
    if (timeswitch == 0) {
      index = tokens[_tokenId].factoryA;
    } if (timeswitch == 1) {
      index = tokens[_tokenId].factoryB;
    } if (timeswitch == 2) {
      index = tokens[_tokenId].factoryC;
    }
    index = index >= factories.length ? 0 : index;
    address factory = factories[index];
    if(factory.isContract()) {
      try
        IERC721Metadata(factory).tokenURI(_tokenId)
      returns (string memory tokenURI) {
        return tokenURI;
      } catch {}
      try
        IERC1155MetadataURI(factory).uri(_tokenId)
      returns (string memory URI) {
        return URI;
      } catch {}
    }
    return IERC721Metadata(factories[0]).tokenURI(_tokenId);
  }

  function _safeTransferCheck(
    address _operator,
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) private {
    if (_to.isContract()) {
      try
        IERC1155Receiver(_to).onERC1155Received(
          _operator,
          _from,
          _tokenId,
          _amount,
          _data
        )
      returns (bytes4 response) {
        if (
          response != IERC1155Receiver(_to).onERC1155Received.selector
        ) {
          revert("INVALID RECEIVER");
        }
      } catch Error(string memory reason) {
          revert(reason);
      } catch {
          revert("INVALID RECEIVER");
      }
    }
  }

  function _safeBatchTransferCheck(
    address _operator,
    address _from,
    address _to,
    uint256[] calldata _tokenIds,
    uint256[] calldata _amounts,
    bytes calldata _data
  ) private {
    if (_to.isContract()) {
      try
        IERC1155Receiver(_to).onERC1155BatchReceived(
          _operator,
          _from,
          _tokenIds,
          _amounts,
          _data
        )
      returns (bytes4 response) {
        if (
          response != IERC1155Receiver(_to).onERC1155BatchReceived.selector
        ) {
          revert("INVALID RECEIVER");
        }
      } catch Error(string memory reason) {
          revert(reason);
      } catch {
          revert("INVALID RECEIVER");
      }
    }
  }
}
