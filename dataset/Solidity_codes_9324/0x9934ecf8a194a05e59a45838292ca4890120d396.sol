
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
}//MIT
pragma solidity ^0.8.9;


contract SignedAllowanceWithData is Context {

    using ECDSA for bytes32;

    event Claimed(uint256 index, address account, bytes data);

    mapping(uint256 => uint256) public claimedBitMap;

    function isClaimed(uint256 index) public view returns (bool) {

        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {

        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    address private _allowancesSigner;

    function allowancesSigner() public view virtual returns (address) {

        return _allowancesSigner;
    }

    function createMessage(address account, uint256 index, bytes memory data)
        public
        view
        returns (bytes32)
    {

        return keccak256(abi.encode(address(this), account, index, data));
    }

    function createMessages(address[] memory accounts, uint256[] memory indexes, bytes[] memory data)
        external
        view
        returns (bytes32[] memory messages)
    {

        require(accounts.length == indexes.length && accounts.length == data.length, '!LENGTH_MISMATCH!');
        messages = new bytes32[](accounts.length);
        for (uint256 i; i < accounts.length; i++) {
            messages[i] = createMessage(accounts[i], indexes[i], data[i]);
        }
    }

    function validateSignature(
        address account,
        uint256 index,
        bytes memory data,
        bytes memory signature
    ) public view returns (bytes32) {

        return
            _validateSignature(account, index, data, signature, allowancesSigner());
    }

    function _validateSignature(
        address account,
        uint256 index,
        bytes memory data,
        bytes memory signature,
        address signer
    ) internal view returns (bytes32) {

        bytes32 message = createMessage(account, index, data)
            .toEthSignedMessageHash();

        require(message.recover(signature) == signer, '!INVALID_SIGNATURE!');

        require(isClaimed(index) == false, '!ALREADY_USED!');

        return message;
    }

    function _useAllowance(
        uint256 index,
        bytes memory data,
        bytes memory signature
    ) internal {

        validateSignature(_msgSender(), index, data, signature);
        _setClaimed(index);
        emit Claimed(index, _msgSender(), data);
    }

    function _setAllowancesSigner(address newSigner) internal {

        _allowancesSigner = newSigner;
    }
}//MIT
pragma solidity ^0.8.9;



interface IKitBag {

  function mint(address to, uint256 id, uint256 amount, bytes memory data) external;

  function balanceOf(address account, uint256 id) external view returns (uint256);

}

contract ComicDrop is Ownable, Pausable, SignedAllowanceWithData {

    IKitBag public kitBag;

    event Drop(address recipient, uint256[] odds, uint256 comic);

    constructor(
        address _kitBag
    ) {
        kitBag = IKitBag(_kitBag);
    }

    function allowancesSigner() public view override returns (address) {

        return owner();
    }

    function createComicMessage(address account, uint256 index, uint256[] calldata odds) public view returns (bytes32) {

        return createMessage(account, index, abi.encode(odds[0], odds[1]));
    }

    function pickComic(uint256 pseudoRandom, uint256[] calldata odds) internal pure returns(uint256) {

      if(pseudoRandom < odds[0]) {
        return 1;
      } else if (pseudoRandom < odds[1]) {
        return 2;
      } else {
        return 3;
      }
    }

    function mint(uint256 index, uint256[] calldata odds, bytes calldata signature) public whenNotPaused {

      _useAllowance(index, abi.encode(odds[0], odds[1]), signature);
      uint256 pseudoRandom = uint256(keccak256(abi.encode(blockhash(block.number-1), blockhash(block.number-5), odds[0], odds[1], msg.sender)));
      uint256 comic = pickComic(pseudoRandom & 0xFF, odds);
      kitBag.mint(msg.sender, comic, 1, "0x");
      emit Drop(msg.sender, odds, comic);
    }

    function setPaused(bool _bPaused) external onlyOwner {

        if (_bPaused) _pause();
        else _unpause();
    }

    function comicBalance(address _user) public view returns(uint256) {

      return kitBag.balanceOf(_user, 1) + kitBag.balanceOf(_user, 2) + kitBag.balanceOf(_user, 3);
    }

}