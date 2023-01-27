
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT


pragma solidity ^0.8.11;



error InvalidSignature(string message);
error ExpiredSignature(string message);
error ReceiverMismatch(string message);
error TransferError(string message);
error PermissionError(string message);
error DuplicateEntryError(string message);

contract CBOXAgent is Ownable, Pausable {

  event CBOXClaimed(
    uint256 indexed cboxWeek,
    address indexed owner,
    uint256 indexed passId,
    address contractAddress,
    uint256 tokenId
  );

  using ECDSA for bytes32;

  address private _signerAddress;
  address private _coniunContractAddress;

  mapping(uint256 => mapping(uint256 => bool)) private _cboxClaims;

  constructor(address signerAddress, address coniunContractAddress) {
    _signerAddress = signerAddress;
    _coniunContractAddress = coniunContractAddress;
  }

  function setSignerAddress(address signerAddress) public onlyOwner {

    _signerAddress = signerAddress;
  }

  function claimToken(
    address vaultAddress,
    address contractAddress,
    uint256 tokenId,
    uint256 passId,
    uint256 cboxWeek,
    bytes memory signature
  ) public whenNotPaused {

    if (msg.sender != tx.origin) {
      revert PermissionError("Contract calls is not allowed");
    }

    if (_cboxClaims[cboxWeek][passId] == true) {
      revert DuplicateEntryError("This C-BOX is already claimed");
    }

    if (
      verifySignature(
        vaultAddress,
        msg.sender,
        contractAddress,
        tokenId,
        passId,
        cboxWeek,
        signature
      ) != true
    ) {
      revert InvalidSignature("Signature verification failed");
    }

    _cboxClaims[cboxWeek][passId] = true;

    ERC721Proxy proxy = ERC721Proxy(contractAddress);
    ERC721Proxy coniunProxy = ERC721Proxy(_coniunContractAddress);

    if (coniunProxy.ownerOf(passId) != msg.sender) {
      revert ReceiverMismatch("C-BOX owner mismatch");
    }

    proxy.safeTransferFrom(vaultAddress, msg.sender, tokenId);
    emit CBOXClaimed(cboxWeek, msg.sender, passId, contractAddress, tokenId);
  }


  function pause() public onlyOwner whenNotPaused {

    _pause();
  }

  function unpause() public onlyOwner whenPaused {

    _unpause();
  }

  function getMessageHash(
    address _vaultAddress,
    address _receiverAddress,
    address _contractAddress,
    uint256 _tokenId,
    uint256 _passId,
    uint256 _cboxWeek
  ) internal pure returns (bytes32) {

    return
      keccak256(
        abi.encodePacked(
          _vaultAddress,
          _receiverAddress,
          _contractAddress,
          _tokenId,
          _passId,
          _cboxWeek
        )
      );
  }

  function getEthSignedMessageHash(bytes32 _messageHash)
    private
    pure
    returns (bytes32)
  {

    return
      keccak256(
        abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
      );
  }

  function verifySignature(
    address _vaultAddress,
    address _receiverAddress,
    address _contractAddress,
    uint256 _tokenId,
    uint256 _passId,
    uint256 _cboxWeek,
    bytes memory signature
  ) private view returns (bool) {

    bytes32 messageHash = getMessageHash(
      _vaultAddress,
      _receiverAddress,
      _contractAddress,
      _tokenId,
      _passId,
      _cboxWeek
    );
    if (_receiverAddress != msg.sender) {
      revert ReceiverMismatch("This signature is not for you");
    }
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
    return recoverSigner(ethSignedMessageHash, signature) == _signerAddress;
  }

  function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
    private
    pure
    returns (address)
  {

    (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

    return ecrecover(_ethSignedMessageHash, v, r, s);
  }

  function splitSignature(bytes memory sig)
    private
    pure
    returns (
      bytes32 r,
      bytes32 s,
      uint8 v
    )
  {

    if (sig.length != 65) {
      revert InvalidSignature("Signature length is not 65 bytes");
    }
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }
  }
}

abstract contract ERC721Proxy {
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual;

  function ownerOf(uint256 tokenId) public view virtual returns (address);
}