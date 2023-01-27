
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

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.0;

library TimeUtil {

    function currentTime() internal view returns (uint) {

        unchecked {
            return block.timestamp;
        }
    }
}// MIT
pragma solidity ^0.8.0;


interface TheRabbitNFT {

    function ownerOf(uint256 tokenId) external view returns (address);

    function getWinnerTokenIds(uint luckyNum) external view returns (uint[] memory tokenIds);

}


contract RewardPool is Ownable {

    using ECDSA for bytes32;

    uint public lastBalance;
    uint public rewardPoolBalance;
    uint private lastSalt;
    bool public isOpen;
    uint public minBalance = 0.5 ether;
    uint public minValidPrice;

    address private rewardSigner;
    TheRabbitNFT private rabbitContractAddress;
    mapping(uint => mapping(uint => bool)) public rewardRecord; // key1:theDay  key2:tokenId

    constructor (address contractAddress, address _rewardSigner) {
        require(_rewardSigner != address(0), "400");
        rewardSigner = _rewardSigner;
        rabbitContractAddress = TheRabbitNFT(contractAddress);
        lastSalt = uint256(keccak256(abi.encodePacked(msg.sender, contractAddress, address(this), _rewardSigner)));
    }

    function supplementRewardPool() external payable {

        uint theLastBalance = address(this).balance - msg.value;
        uint royalty = theLastBalance - lastBalance;
        rewardPoolBalance += msg.value;
        if (royalty > 0) {
            rewardPoolBalance += (royalty / 3);
        }
        lastBalance = address(this).balance;
    }

    function setRewardSigner(address newSigner) external onlyOwner {

        require(newSigner != address(0), "400");
        rewardSigner = newSigner;
    }
    function setOpenStatus(bool _isOpen) external onlyOwner {

        isOpen = _isOpen;
    }
    function setMinBalance(uint _minBalance) external onlyOwner {

        minBalance = _minBalance;
    }
    function setMinValidPrice(uint _minValidPrice) external onlyOwner {

        minValidPrice = _minValidPrice;
    }

    function getAlreadyRewardTokenIds(uint luckyItem) view external returns (uint[] memory tokenIds) {

        uint[] memory allTokenIds = rabbitContractAddress.getWinnerTokenIds(luckyItem);
        if (allTokenIds.length == 0) return tokenIds;
        uint theDay = getDaysFrom1970();
        uint count = 0;
        tokenIds = new uint[](allTokenIds.length);
        for (uint index = 0; index < allTokenIds.length; index++) {
            if (rewardRecord[theDay][allTokenIds[index]]) tokenIds[count++] = allTokenIds[index];
        }
        if (count == allTokenIds.length) return tokenIds;
        uint[] memory realTokenIds = new uint[](count);
        for (uint j = 0; j < count; j++) {
            realTokenIds[j] = tokenIds[j];
        }
        return realTokenIds;
    }

    function getRewardPoolBalance() public view returns (uint count){

        count = rewardPoolBalance;
        if (address(this).balance > lastBalance) {
            uint royalty = address(this).balance - lastBalance;
            count += (royalty / 3);
        }
    }

    event RewardSucceed(address indexed to, uint amount);
    function reward(
        bytes memory salt, bytes memory token, uint[] calldata tokenIds,
        uint validDay, uint unitPrice
        ) external {

        require(_recover(_hash(salt, tokenIds, validDay, unitPrice), token) == rewardSigner, "400");
        uint theDay = getDaysFrom1970();
        require(theDay == validDay, "104");

        uint count = 0;
        for (uint i = 0; i < tokenIds.length; i++) {
            if (!rewardRecord[theDay][tokenIds[i]] && rabbitContractAddress.ownerOf(tokenIds[i]) == msg.sender) {
                count++;
                rewardRecord[theDay][tokenIds[i]] = true;
            }
        }
        if (count == 0) return;

        if (rewardPoolBalance > address(this).balance) {
            rewardPoolBalance = address(this).balance;
            lastBalance = address(this).balance;
        }

        if (address(this).balance > lastBalance) {
            uint royalty = address(this).balance - lastBalance;
            rewardPoolBalance += (royalty / 3);
            lastBalance = address(this).balance;
        }

        uint paymentAmount = count * unitPrice * 10**9;
        lastBalance = address(this).balance - paymentAmount;
        rewardPoolBalance -= paymentAmount;
        payable(msg.sender).transfer(paymentAmount);
        emit RewardSucceed(msg.sender, paymentAmount);
    }

    function getLuckyItem() view external returns (uint luckyItem, uint poolBalance) {

        if (!isOpen) {
            return (0, getRewardPoolBalance() / 10 ** 9);
        }
        poolBalance = getRewardPoolBalance() / 10 ** 9;
        uint theDay = getDaysFrom1970();
        if (theDay % 7 != 6) return (0, poolBalance);
        uint royalty = address(this).balance - lastBalance;

        bool _isOpen = false;
        if (royalty > 0) {
            if (rewardPoolBalance + (royalty / 3) >= minBalance) {
                _isOpen = true;
            }
        } else {
            if (rewardPoolBalance >= minBalance) {
                _isOpen = true;
            }
        }

        if (_isOpen) {
            return ((uint256(keccak256(abi.encodePacked(theDay, lastSalt))) % 78) + 2, poolBalance);
        }
        return (0, poolBalance);
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    function withdrawFunds() external onlyOwner {

        payable(msg.sender).transfer(address(this).balance - rewardPoolBalance);
        rewardPoolBalance = lastBalance = address(this).balance;
    }
    function getMinPriceInfo() external view returns(uint _minBalance, uint _minValidPrice) {

        return (minBalance / 10 ** 9, minValidPrice / 10 ** 9);
    }

    function _hash(bytes memory salt, uint[] calldata tokenIds, uint validDay, uint unitPrice)
    private view returns (bytes32) {

        return keccak256(abi.encodePacked(salt, address(this), tokenIds, validDay, unitPrice));
    }
    function _recover(bytes32 hash, bytes memory token) private pure returns (address) {

        return hash.toEthSignedMessageHash().recover(token);
    }

    function getDaysFrom1970() public view returns (uint _days) {

        _days = TimeUtil.currentTime() / 86400;
    }

}