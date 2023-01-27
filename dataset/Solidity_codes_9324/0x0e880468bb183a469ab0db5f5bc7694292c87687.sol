


pragma solidity ^0.8.7;

interface IERC2981 {

  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount);

}


pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

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

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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



pragma solidity ^0.8.11;











contract LunaEclipse is ERC165, IERC2981, IERC1155MetadataURI, Ownable {

  using Address for address;
  using Strings for uint256;

  string public constant name = "Luna Eclipse";
  string public constant symbol = "US-WEEEEE";

  uint256 private constant bear_prize = type(uint256).max - 1;
  uint256 private constant bull_prize = type(uint256).max;
  string private constant contract_metadata = "https://dohkwon.com/metadata.json";
  uint256 public constant fully_eclipsed_timestamp = 1652671740;
  string private constant ipfs_hash = "bafybeiapkhctdoe6avdigry7cwgjgyfv2izosugvpumgvgn7fjqnjczrdq";
  uint256 private constant mask = 0x8000000000000000000000000000000000000000000000000000000000000000;
  uint256 private constant scale_factor = 1000000;
  AggregatorV3Interface private constant ust_price_feed = AggregatorV3Interface(
    0x8b6d9085f310396C6E4f0012783E9f850eaa8a82
  );

  uint256 public final_price = type(uint256).max;
  string private ipfs_hash_prizes;
  bytes32 private merkle_root;
  uint256 private royaltyInBasisPoints = 500;

  mapping(address => mapping(uint256 => uint256)) public override balanceOf;
  mapping(address => mapping(uint256 => bool)) public claimed;
  mapping(address => mapping(address => bool)) private operatorApprovals;
  
  function supportsInterface(bytes4 _interfaceId) public view override(ERC165, IERC165) returns (bool) {

    return
      _interfaceId == type(IERC1155).interfaceId ||
      _interfaceId == type(IERC1155MetadataURI).interfaceId ||
      _interfaceId == type(IERC2981).interfaceId ||
      super.supportsInterface(_interfaceId);
  }

  function contractURI() external pure returns (string memory) {

    return contract_metadata;
  }

  function royaltyInfo(uint256, uint256 _salePrice) external view override returns (address, uint256) {

    return (
      owner(),
      _salePrice * royaltyInBasisPoints / 10000
    );
  }

  function activateRedemption(uint80 _roundId, bytes32 _merkleRoot, string calldata _ipfsHash) external onlyOwner {

    require(final_price == type(uint256).max);
    require(block.timestamp > fully_eclipsed_timestamp);
    merkle_root = _merkleRoot;
    (,int256 price,,,) = ust_price_feed.getRoundData(_roundId);
    final_price = uint256(price) / scale_factor;
    ipfs_hash_prizes = _ipfsHash;
  }

  function updateRoyalty(uint256 _newRoyalty) external onlyOwner {

    royaltyInBasisPoints =  _newRoyalty;
  }

  function withdraw() external onlyOwner {

    Address.sendValue(payable(owner()), address(this).balance);
  }

  function mint(bool _boolish) external {

    require(block.timestamp <= fully_eclipsed_timestamp);
    (,int256 price,,,) = ust_price_feed.latestRoundData();
    uint256 tokenId = uint256(price) / scale_factor;
    if (tokenId > 100) {
      tokenId = 100;
    }
    if (_boolish) {
      tokenId = (1 << 255) | tokenId;
    }
    balanceOf[msg.sender][tokenId] += 1;
    emit TransferSingle(msg.sender, address(0), msg.sender, tokenId, 1);
  }

  function claimReward(address _to, uint256 _tokenId, uint256 _amount, bytes32[] calldata _proof) external {

    require(!claimed[_to][_tokenId]);
    require(final_price != type(uint256).max);
    bytes32 leaf = keccak256(abi.encodePacked(_to, _tokenId, _amount));
    require(MerkleProof.verify(_proof, merkle_root, leaf));

    claimed[_to][_tokenId] = true;

    _mintPrize(_to, _tokenId, _amount);
  }

  function _mintPrize(address _to, uint256 _tokenId, uint256 _amount) private {

    bool boolish = _tokenId & mask != 0;
    uint256 price = _tokenId & ~mask;
    if (boolish) {
      require(price >= final_price);
      balanceOf[_to][bull_prize] += _amount;
      emit TransferSingle(msg.sender, address(0), _to, bull_prize, _amount);
    } else {
      require(price < final_price);
      balanceOf[_to][bear_prize] += _amount;
      emit TransferSingle(msg.sender, address(0), _to, bear_prize, _amount);
    }
  }


  function balanceOfBatch(
    address[] calldata _accounts,
    uint256[] calldata _tokenIds
  ) public view override returns (uint256[] memory) {

    require(_accounts.length == _tokenIds.length);
    uint256[] memory batchBalances = new uint256[](_accounts.length);
    for (uint256 i = 0; i < _accounts.length; ++i) {
      batchBalances[i] = balanceOf[_accounts[i]][_tokenIds[i]];
    }
    return batchBalances;
  }

  function isApprovedForAll(address _owner, address _operator) public view override returns (bool) {

    return operatorApprovals[_owner][_operator];
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) public override {

    require(_to != address(0));
    require(
      _from == msg.sender || isApprovedForAll(_from, msg.sender)
    );
    balanceOf[_from][_tokenId] -= _amount;
    balanceOf[_to][_tokenId] += _amount;
    emit TransferSingle(msg.sender, _from, _to, _tokenId, _amount);
    _safeTransferCheck(msg.sender, _from, _to, _tokenId, _amount, _data);
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
      length == _amounts.length
    );
    require(_to != address(0));
    require(
      _from == msg.sender || isApprovedForAll(_from, msg.sender)
    );

    for (uint256 i = 0; i < length; ++i) {
      uint256 id = _tokenIds[i];
      uint256 amount = _amounts[i];
      balanceOf[_from][id] -= amount;
      balanceOf[_to][id] += amount;
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

    require(msg.sender != _operator);
    operatorApprovals[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function uri(uint256 _tokenId) external view returns (string memory) {

    if (_tokenId >= bear_prize) {
      return string(abi.encodePacked('ipfs://', ipfs_hash_prizes, '/', _toHexString(_tokenId), '.json'));
    }
    return string(abi.encodePacked('ipfs://', ipfs_hash, '/', _toHexString(_tokenId), '.json'));
  }

  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
  function _toHexString(uint256 value) private pure returns (string memory) {

    uint256 length = 64;
    bytes memory buffer = new bytes(length+2);
    for (uint256 i = length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    return string(buffer);
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
          revert();
        }
      } catch Error(string memory reason) {
          revert(reason);
      } catch {
          revert();
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
          revert();
        }
      } catch Error(string memory reason) {
          revert(reason);
      } catch {
          revert();
      }
    }
  }
}