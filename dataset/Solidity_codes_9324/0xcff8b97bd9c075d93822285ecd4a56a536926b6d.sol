
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

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
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

pragma solidity ^0.8.0;

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// MIT

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
}// MIT

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

}// MIT

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

}// UNLICENSED
pragma solidity ^0.8.4;


contract FLUFDynamicMarketplace is ERC1155Holder, ReentrancyGuard, Ownable {

  using ECDSA for bytes32;
  using MerkleProof for bytes32[];
  using Address for address;

  address public flufAddress;
  address public partybearsAddress;
  address public thingiesAddress;

  struct Sales {
    address contractAddress; // The contractAddresses
    uint256[] ids; // The tokenIds
    uint256[] amounts; // The quantity of each token to transfer
    uint256 price;
  }

  mapping(uint256 => Sales) public availableSales;
  uint256 public saleNonce = 0; // The nonce of the current sale, starts with 0;
  bytes32 private root; // Root of Merkle
  mapping(uint256 => mapping(bytes => bool)) public usedToken; // Whether the SALT Token has been consumed
  mapping(uint256 => mapping(address => bool)) public addressMinted; // Whether this address has already minted during this sale
  mapping(uint256 => mapping(address => bool)) private _mintedInBlock;

  enum State {
    Closed,
    PrivateSale,
    PublicSale
  }

  State private _state;
  address private _signer;

  constructor(
    address signer,
    bytes32 _newRoot,
    address _flufAddress,
    address _partybearsAddress,
    address _thingiesAddress
  ) {
    _signer = signer;
    root = _newRoot;
    flufAddress = _flufAddress;
    partybearsAddress = _partybearsAddress;
    thingiesAddress = _thingiesAddress;
  }

  function setSaleToClosed() public onlyOwner {

    _state = State.Closed;
  }

  function setSaleToPrivate() public onlyOwner {

    _state = State.PrivateSale;
  }

  function setSaleToPublic() public onlyOwner {

    _state = State.PublicSale;
  }

  function listNewSale(
    address _contractAddress,
    uint256[] memory _ids,
    uint256[] memory _amounts,
    uint256 _price
  ) public onlyOwner {

    saleNonce = saleNonce + 1;
    availableSales[saleNonce].contractAddress = _contractAddress;
    availableSales[saleNonce].ids = _ids;
    availableSales[saleNonce].amounts = _amounts;
    availableSales[saleNonce].price = _price;
  }

  function updateSaleNonce(uint256 _nonce) public onlyOwner {

    saleNonce = _nonce;
  }

  function updateSigner(address __signer) public onlyOwner {

    _signer = __signer;
  }

  function _hash(string calldata salt, address _address)
    public
    view
    returns (bytes32)
  {

    return keccak256(abi.encode(salt, address(this), _address));
  }

  function _verify(bytes32 hash, bytes memory token)
    public
    view
    returns (bool)
  {

    return (_recover(hash, token) == _signer);
  }

  function _recover(bytes32 hash, bytes memory token)
    public
    pure
    returns (address)
  {

    return hash.toEthSignedMessageHash().recover(token);
  }

  function setRoot(bytes32 _newRoot) public onlyOwner {

    root = _newRoot;
  }

  function grantTokens(address _to) internal {

    uint256[] memory ids = availableSales[saleNonce].ids;
    uint256[] memory amounts = availableSales[saleNonce].amounts;
    address contractAddress = availableSales[saleNonce].contractAddress;
    IERC1155(contractAddress).safeBatchTransferFrom(
      address(this),
      _to,
      ids,
      amounts,
      "0x0"
    );
  }

  function setFlufAddress(address _flufAddress) public onlyOwner {

    flufAddress = _flufAddress;
  }

  function setPartybearsAddress(address _partybearsAddress) public onlyOwner {

    partybearsAddress = _partybearsAddress;
  }

  function setThingiesAddress(address _thingiesAddress) public onlyOwner {

    thingiesAddress = _thingiesAddress;
  }

  function isEcosystemOwner(address _address) public view returns (bool) {

    uint256 fluf = IERC721(flufAddress).balanceOf(_address);
    if (fluf > 0) {
      return true;
    }
    uint256 pb = IERC721(partybearsAddress).balanceOf(_address);
    if (pb > 0) {
      return true;
    }
    uint256 thingies = IERC721(thingiesAddress).balanceOf(_address);
    if (thingies > 0) {
      return true;
    }
    return false;
  }

  function hasStock(uint256 _saleNonce) public view returns (bool) {

    uint256 bal = IERC1155(availableSales[_saleNonce].contractAddress)
      .balanceOf(address(this), availableSales[_saleNonce].ids[0]);
    if (bal > 0) {
      return true;
    } else {
      return false;
    }
  }

  function publicMint(string calldata salt, bytes calldata token)
    external
    payable
    nonReentrant
  {

    require(hasStock(saleNonce) == true, "Out of stock");
    require(_state == State.PublicSale, "Publicsale is not active");
    require(
      isEcosystemOwner(msg.sender) == true,
      "You dont own any of the ecosystem tokens"
    );
    require(msg.sender == tx.origin, "Mint from contract not allowed");
    require(
      !Address.isContract(msg.sender),
      "Contracts are not allowed to mint."
    );
    uint256 price = availableSales[saleNonce].price;
    require(msg.value >= price, "Ether value sent is incorrect.");
    require(!usedToken[saleNonce][token], "The token has been used.");
    require(_verify(_hash(salt, msg.sender), token), "Invalid token.");
    require(
      _mintedInBlock[block.number][msg.sender] == false,
      "already minted in this block"
    );
    usedToken[saleNonce][token] = true;
    _mintedInBlock[block.number][msg.sender] = true;
    grantTokens(msg.sender);
  }

  function privateMint(bytes32[] memory _proof) external payable nonReentrant {

    require(hasStock(saleNonce) == true, "Out of stock");
    require(_state == State.PrivateSale, "Private Sale is not active.");
    require(msg.sender == tx.origin, "Mint from contract not allowed");
    require(
      !Address.isContract(msg.sender),
      "Contracts are not allowed to mint."
    );
    uint256 price = availableSales[saleNonce].price;
    require(msg.value >= price, "Ether value sent is incorrect.");
    require(
      !addressMinted[saleNonce][msg.sender],
      "This address has already minted during private sale."
    );

    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
    require(_proof.verify(root, leaf), "invalid proof");

    addressMinted[saleNonce][msg.sender] = true;

    grantTokens(msg.sender);
  }

  function withdrawAll(address recipient) public onlyOwner {

    uint256 balance = address(this).balance;
    payable(recipient).transfer(balance);
  }

  function withdrawAllViaCall(address payable _to) public onlyOwner {

    uint256 balance = address(this).balance;
    (bool sent, bytes memory data) = _to.call{value: balance}("");
    require(sent, "Failed to send Ether");
  }

  function emergencyWithdrawTokens(
    address _to,
    uint256[] memory ids,
    uint256[] memory amounts,
    address contractAddress
  ) public onlyOwner {

    IERC1155(contractAddress).safeBatchTransferFrom(
      address(this),
      _to,
      ids,
      amounts,
      "0x0"
    );
  }
}