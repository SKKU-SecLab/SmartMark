

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


contract AccountStateV1 {

    uint256 public lastInitializedVersion;
    mapping(address => bool) public authKeys;
    uint256 public nonce;
    uint256 public numAuthKeys;
}

contract AccountState is AccountStateV1 {}


contract AccountEvents {



    event AuthKeyAdded(address indexed authKey);
    event AuthKeyRemoved(address indexed authKey);
    event CallFailed(string reason);


    event Upgraded(address indexed implementation);
}

contract AccountInitializeV1 is AccountState, AccountEvents {


    function initializeV1(
        address _authKey
    )
        public
    {

        require(lastInitializedVersion == 0, "AI: Improper initialization order");
        lastInitializedVersion = 1;

        authKeys[_authKey] = true;
        numAuthKeys += 1;
        emit AuthKeyAdded(_authKey);
    }
}

contract IERC20 {

    function balanceOf(address account) external returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

}

contract AccountInitializeV2 is AccountState {


    function initializeV2(
        uint256 _deploymentCost,
        address _deploymentFeeTokenAddress
    )
        public
    {

        require(lastInitializedVersion == 1, "AI2: Improper initialization order");
        lastInitializedVersion = 2;

        if (_deploymentCost != 0) {
            if (_deploymentFeeTokenAddress == address(0)) {
                uint256 amountToTransfer = _deploymentCost < address(this).balance ? _deploymentCost : address(this).balance;
                tx.origin.transfer(amountToTransfer);
            } else {
                IERC20 deploymentFeeToken = IERC20(_deploymentFeeTokenAddress);
                uint256 userBalanceOf = deploymentFeeToken.balanceOf(address(this));
                uint256 amountToTransfer = _deploymentCost < userBalanceOf ? _deploymentCost : userBalanceOf;
                deploymentFeeToken.transfer(tx.origin, amountToTransfer);
            }
        }
    }
}

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}

contract AccountInitializeV3 is AccountState {


    address constant private ERC1820_REGISTRY_ADDRESS = 0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24;
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    function initializeV3() public {

        require(lastInitializedVersion == 2, "AI3: Improper initialization order");
        lastInitializedVersion = 3;

        IERC1820Registry registry = IERC1820Registry(ERC1820_REGISTRY_ADDRESS);
        registry.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }
}

contract AccountInitialize is AccountInitializeV1, AccountInitializeV2, AccountInitializeV3 {}


contract TokenReceiverHooks {

    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;
    bytes32 constant private ERC1820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC1820_ACCEPT_MAGIC"));


    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {

        return this.onERC721Received.selector;
    }


    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external returns(bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external returns(bytes4) {

        return this.onERC1155BatchReceived.selector;
    }


    function tokensReceived(
        address,
        address,
        address,
        uint256,
        bytes calldata,
        bytes calldata
    ) external { }



    function canImplementInterfaceForAddress(bytes32 interfaceHash, address addr) external view returns(bytes32) {

        if (interfaceHash == TOKENS_RECIPIENT_INTERFACE_HASH && addr == address(this)) {
            return ERC1820_ACCEPT_MAGIC;
        }
    }
}

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library BytesLib {

    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
                    add(
                        fslot,
                        add(
                            mul(
                                div(
                                    mload(add(_postBytes, 0x20)),
                                    exp(0x100, sub(32, mlength))
                                ),
                                exp(0x100, sub(32, newlength))
                            ),
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_length + 31 >= _length, "slice_overflow");
        require(_start + _length >= _start, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {

        require(_start + 1 >= _start, "toUint8_overflow");
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {

        require(_start + 2 >= _start, "toUint16_overflow");
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {

        require(_start + 4 >= _start, "toUint32_overflow");
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {

        require(_start + 8 >= _start, "toUint64_overflow");
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {

        require(_start + 12 >= _start, "toUint96_overflow");
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {

        require(_start + 16 >= _start, "toUint128_overflow");
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {

        require(_start + 32 >= _start, "toUint256_overflow");
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes4(bytes memory _bytes, uint256 _start) internal  pure returns (bytes4) {

        require(_start + 4 >= _start, "toBytes4_overflow");
        require(_bytes.length >= _start + 4, "toBytes4_outOfBounds");
        bytes4 tempBytes4;

        assembly {
            tempBytes4 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes4;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {

        require(_start + 32 >= _start, "toBytes32_overflow");
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }
}

library strings {

    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {

        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function toSlice(string memory self) internal pure returns (slice memory) {

        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function len(bytes32 self) internal pure returns (uint) {

        uint ret;
        if (self == 0)
            return 0;
        if (uint256(self) & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (uint256(self) & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (uint256(self) & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (uint256(self) & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (uint256(self) & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {

        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    function copy(slice memory self) internal pure returns (slice memory) {

        return slice(self._len, self._ptr);
    }

    function toString(slice memory self) internal pure returns (string memory) {

        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    function len(slice memory self) internal pure returns (uint l) {

        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    function empty(slice memory self) internal pure returns (bool) {

        return self._len == 0;
    }

    function compare(slice memory self, slice memory other) internal pure returns (int) {

        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                uint256 mask = uint256(-1); // 0xffff...
                if(shortest < 32) {
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    function equals(slice memory self, slice memory other) internal pure returns (bool) {

        return compare(self, other) == 0;
    }

    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {

        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    function nextRune(slice memory self) internal pure returns (slice memory ret) {

        nextRune(self, ret);
    }

    function ord(slice memory self) internal pure returns (uint ret) {

        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    function keccak(slice memory self) internal pure returns (bytes32 ret) {

        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {

        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {

        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {

        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        split(self, needle, token);
    }

    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {

        rsplit(self, needle, token);
    }

    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    function contains(slice memory self, slice memory needle) internal pure returns (bool) {

        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    function concat(slice memory self, slice memory other) internal pure returns (string memory) {

        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {

        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(uint i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}

contract BaseAccount is AccountState, AccountInitialize, TokenReceiverHooks {

    using SafeMath for uint256;
    using ECDSA for bytes32;
    using BytesLib for bytes;
    using strings for *;

    string constant public CALL_REVERT_PREFIX = "Authereum Call Revert: ";

    modifier onlyAuthKey {

        require(_isValidAuthKey(msg.sender), "BA: Only auth key allowed");
        _;
    }

    modifier onlySelf {

        require(msg.sender == address(this), "BA: Only self allowed");
        _;
    }

    modifier onlyAuthKeyOrSelf {

        require(_isValidAuthKey(msg.sender) || msg.sender == address(this), "BA: Only auth key or self allowed");
        _;
    }

    constructor () public {
        lastInitializedVersion = uint256(-1);
    }

    function () external payable {}


    function getChainId() public pure returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }


    function addAuthKey(address _authKey) external onlyAuthKeyOrSelf {

        require(authKeys[_authKey] == false, "BA: Auth key already added");
        require(_authKey != address(this), "BA: Cannot add self as an auth key");
        authKeys[_authKey] = true;
        numAuthKeys += 1;
        emit AuthKeyAdded(_authKey);
    }

    function removeAuthKey(address _authKey) external onlyAuthKeyOrSelf {

        require(authKeys[_authKey] == true, "BA: Auth key not yet added");
        require(numAuthKeys > 1, "BA: Cannot remove last auth key");
        authKeys[_authKey] = false;
        numAuthKeys -= 1;
        emit AuthKeyRemoved(_authKey);
    }


    function _isValidAuthKey(address _authKey) internal view returns (bool) {

        return authKeys[_authKey];
    }

    function _executeTransaction(
        address _to,
        uint256 _value,
        uint256 _gasLimit,
        bytes memory _data
    )
        internal
        returns (bytes memory)
    {

        (bool success, bytes memory res) = _to.call.gas(_gasLimit).value(_value)(_data);

        if (!success) {
            revert(_getPrefixedRevertMsg(res));
        }

        return res;
    }

    function _getRevertMsgFromRes(bytes memory _res) internal pure returns (string memory) {

        if (_res.length < 68) return 'BA: Transaction reverted silently';
        bytes memory revertData = _res.slice(4, _res.length - 4); // Remove the selector which is the first 4 bytes
        return abi.decode(revertData, (string)); // All that remains is the revert string
    }

    function _getPrefixedRevertMsg(bytes memory _res) internal pure returns (string memory) {

        string memory _revertMsg = _getRevertMsgFromRes(_res);
        return string(abi.encodePacked(CALL_REVERT_PREFIX, _revertMsg));
    }
}

contract IERC1271 {

    function isValidSignature(
        bytes32 _messageHash,
        bytes memory _signature
    ) public view returns (bytes4 magicValue);


    function isValidSignature(
        bytes memory _data,
        bytes memory _signature
    ) public view returns (bytes4 magicValue);

}

contract ERC1271Account is IERC1271, BaseAccount {


    bytes4 constant private VALID_SIG = 0x1626ba7e;
    bytes4 constant private VALID_SIG_BYTES = 0x20c13b0b;
    bytes4 constant private INVALID_SIG = 0xffffffff;


    function isValidSignature(
        bytes32 _messageHash,
        bytes memory _signature
    )
        public
        view
        returns (bytes4)
    {

        bool isValid = _isValidSignature(_messageHash, _signature);
        return isValid ? VALID_SIG : INVALID_SIG;
    }

    function isValidSignature(
        bytes memory _data,
        bytes memory _signature
    )
        public
        view
        returns (bytes4)
    {

        bytes32 messageHash = _getEthSignedMessageHash(_data);
        bool isValid = _isValidSignature(messageHash, _signature);
        return isValid ? VALID_SIG_BYTES : INVALID_SIG;
    }

    function isValidAuthKeySignature(
        bytes32 _messageHash,
        bytes memory _signature
    )
        public
        view
        returns (bool)
    {

        require(_signature.length == 65, "ERC1271: Invalid isValidAuthKeySignature _signature length");

        address authKeyAddress = _messageHash.recover(
            _signature
        );

        return _isValidAuthKey(authKeyAddress);
    }

    function isValidLoginKeySignature(
        bytes32 _messageHash,
        bytes memory _signature
    )
        public
        view
        returns (bool)
    {

        require(_signature.length >= 130, "ERC1271: Invalid isValidLoginKeySignature _signature length");

        bytes memory msgHashSignature = _signature.slice(0, 65);
        bytes memory loginKeyAttestationSignature = _signature.slice(65, 65);
        uint256 restrictionDataLength = _signature.length.sub(130);
        bytes memory loginKeyRestrictionsData = _signature.slice(130, restrictionDataLength);

        address _loginKeyAddress = _messageHash.recover(
            msgHashSignature
        );

        bytes32 loginKeyAttestationMessageHash = keccak256(abi.encode(
            _loginKeyAddress, loginKeyRestrictionsData
        )).toEthSignedMessageHash();

        address _authKeyAddress = loginKeyAttestationMessageHash.recover(
            loginKeyAttestationSignature
        );

        return _isValidAuthKey(_authKeyAddress);
    }


    function _isValidSignature(
        bytes32 _messageHash,
        bytes memory _signature
    )
        public
        view
        returns (bool)
    {

        if (_signature.length == 65) {
            return isValidAuthKeySignature(_messageHash, _signature);
        } else if (_signature.length >= 130) {
            return isValidLoginKeySignature(_messageHash, _signature);
        } else {
            revert("ERC1271: Invalid isValidSignature _signature length");
        }
    }

    function _getEthSignedMessageHash(bytes memory _data) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", _uint2str(_data.length), _data));
    }

    function _uint2str(uint _num) private pure returns (string memory _uintAsString) {

        if (_num == 0) {
            return "0";
        }
        uint i = _num;
        uint j = _num;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }
}

contract BaseMetaTxAccount is BaseAccount {



    function executeMultipleTransactions(bytes[] memory _transactions) public onlyAuthKey returns (bytes[] memory) {

        bool isMetaTransaction = false;
        return _executeMultipleTransactions(_transactions, isMetaTransaction);
    }

    function executeMultipleMetaTransactions(bytes[] memory _transactions) public onlySelf returns (bytes[] memory) {

        bool isMetaTransaction = true;
        return _executeMultipleTransactions(_transactions, isMetaTransaction);
    }


    function _atomicExecuteMultipleMetaTransactions(
        bytes[] memory _transactions,
        uint256 _gasPrice
    )
        internal
        returns (bool, bytes[] memory)
    {

        require(_gasPrice <= tx.gasprice, "BMTA: Not a large enough tx.gasprice");

        nonce = nonce.add(_transactions.length);

        bytes memory _encodedTransactions = abi.encodeWithSelector(
            this.executeMultipleMetaTransactions.selector,
            _transactions
        );

        (bool success, bytes memory res) = address(this).call(_encodedTransactions);

        bytes[] memory _returnValues;
        if (!success) {
            if (res.length == 0) {
                revert("BMTA: Atomic call ran out of gas");
            }

            string memory _revertMsg = _getRevertMsgFromRes(res);
            emit CallFailed(_revertMsg);
        } else {
            _returnValues = abi.decode(res, (bytes[]));
        }

        return (success, _returnValues);
    }

    function _executeMultipleTransactions(bytes[] memory _transactions, bool _isMetaTransaction) internal returns (bytes[] memory) {

        bytes[] memory _returnValues = new bytes[](_transactions.length);
        for(uint i = 0; i < _transactions.length; i++) {
            _returnValues[i] = _decodeAndExecuteTransaction(_transactions[i], _isMetaTransaction);
        }

        return _returnValues;
    }

    function _decodeAndExecuteTransaction(bytes memory _transaction, bool _isMetaTransaction) internal returns (bytes memory) {

        (address _to, uint256 _value, uint256 _gasLimit, bytes memory _data) = _decodeTransactionData(_transaction);

        if (_isMetaTransaction) {
            require(gasleft() > _gasLimit.mul(64).div(63).add(34800));
        }

        return _executeTransaction(_to, _value, _gasLimit, _data);
    }

    function _decodeTransactionData(bytes memory _transaction) internal pure returns (address, uint256, uint256, bytes memory) {

        return abi.decode(_transaction, (address, uint256, uint256, bytes));
    }

    function _issueRefund(
        uint256 _startGas,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        address _feeTokenAddress,
        uint256 _feeTokenRate
    )
        internal
    {

        uint256 _gasUsed = _startGas.sub(gasleft()).add(_gasOverhead);

        if (_feeTokenAddress == address(0)) {
            uint256 totalEthFee = _gasUsed.mul(_gasPrice);

            if (totalEthFee == 0) return;
            require(totalEthFee <= address(this).balance, "BA: Insufficient gas (ETH) for refund");

            msg.sender.call.value(totalEthFee)("");
        } else {
            IERC20 feeToken = IERC20(_feeTokenAddress);
            uint256 totalTokenFee = _gasUsed.mul(_feeTokenRate);

            if (totalTokenFee == 0) return;
            require(totalTokenFee <= feeToken.balanceOf(address(this)), "BA: Insufficient gas (token) for refund");

            feeToken.transfer(msg.sender, totalTokenFee);
        }
    }
}

interface ILoginKeyTransactionValidator {

    function validateTransactions(
        bytes[] calldata _transactions,
        bytes calldata _validationData,
        address _relayerAddress
    ) external;


    function transactionsDidExecute(
        bytes[] calldata _transactions,
        bytes calldata _validationData,
        address _relayerAddress
    ) external;

}

contract LoginKeyMetaTxAccount is BaseMetaTxAccount {


    function executeMultipleLoginKeyMetaTransactions(
        bytes[] memory _transactions,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        bytes memory _loginKeyRestrictionsData,
        address _feeTokenAddress,
        uint256 _feeTokenRate,
        bytes memory _transactionMessageHashSignature,
        bytes memory _loginKeyAttestationSignature
    )
        public
        returns (bytes[] memory)
    {

        uint256 startGas = gasleft();

        _validateDestinations(_transactions);
        _validateRestrictionDataPreHook(_transactions, _loginKeyRestrictionsData);

        bytes32 _transactionMessageHash = keccak256(abi.encode(
            address(this),
            msg.sig,
            getChainId(),
            nonce,
            _transactions,
            _gasPrice,
            _gasOverhead,
            _feeTokenAddress,
            _feeTokenRate
        )).toEthSignedMessageHash();

        _validateLoginKeyMetaTransactionSigs(
            _transactionMessageHash, _transactionMessageHashSignature, _loginKeyRestrictionsData, _loginKeyAttestationSignature
        );

        (bool success, bytes[] memory _returnValues) = _atomicExecuteMultipleMetaTransactions(
            _transactions,
            _gasPrice
        );

        if (success) {
            _validateRestrictionDataPostHook(_transactions, _loginKeyRestrictionsData);
        }

        _issueRefund(startGas, _gasPrice, _gasOverhead, _feeTokenAddress, _feeTokenRate);

        return _returnValues;
    }


    function _validateRestrictionDataPreHook(
        bytes[] memory _transactions,
        bytes memory _loginKeyRestrictionsData
    )
        internal
    {

        (address validationContract, bytes memory validationData) = abi.decode(_loginKeyRestrictionsData, (address, bytes));
        if (validationContract != address(0)) {
            ILoginKeyTransactionValidator(validationContract).validateTransactions(_transactions, validationData, msg.sender);
        }
    }

    function _validateRestrictionDataPostHook(
        bytes[] memory _transactions,
        bytes memory _loginKeyRestrictionsData
    )
        internal
    {

        (address validationContract, bytes memory validationData) = abi.decode(_loginKeyRestrictionsData, (address, bytes));
        if (validationContract != address(0)) {
            ILoginKeyTransactionValidator(validationContract).transactionsDidExecute(_transactions, validationData, msg.sender);
        }
    }

    function _validateDestinations(
        bytes[] memory _transactions
    )
        internal
        view
    {

        address to;
        uint256 gasLimit;
        bytes memory data;
        for (uint i = 0; i < _transactions.length; i++) {
            (to,,gasLimit,data) = _decodeTransactionData(_transactions[i]);

            if (data.length != 0 || gasLimit > 2300) {
                require(to != address(this), "LKMTA: Login key is not able to call self");
                require(!authKeys[to], "LKMTA: Login key is not able to call an Auth key");
            }
        }
    }

    function _validateLoginKeyMetaTransactionSigs(
        bytes32 _transactionsMessageHash,
        bytes memory _transactionMessageHashSignature,
        bytes memory _loginKeyRestrictionsData,
        bytes memory _loginKeyAttestationSignature
    )
        internal
        view
    {

        address _transactionMessageSigner = _transactionsMessageHash.recover(
            _transactionMessageHashSignature
        );

        bytes32 loginKeyAttestationMessageHash = keccak256(abi.encode(
            _transactionMessageSigner,
            _loginKeyRestrictionsData
        )).toEthSignedMessageHash();

        address _authKeyAddress = loginKeyAttestationMessageHash.recover(
            _loginKeyAttestationSignature
        );

        require(_isValidAuthKey(_authKeyAddress), "LKMTA: Auth key is invalid");
    }
}

contract AuthKeyMetaTxAccount is BaseMetaTxAccount {


    function executeMultipleAuthKeyMetaTransactions(
        bytes[] memory _transactions,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        address _feeTokenAddress,
        uint256 _feeTokenRate,
        bytes memory _transactionMessageHashSignature
    )
        public
        returns (bytes[] memory)
    {

        uint256 _startGas = gasleft();

        bytes32 _transactionMessageHash = keccak256(abi.encode(
            address(this),
            msg.sig,
            getChainId(),
            nonce,
            _transactions,
            _gasPrice,
            _gasOverhead,
            _feeTokenAddress,
            _feeTokenRate
        )).toEthSignedMessageHash();

        _validateAuthKeyMetaTransactionSigs(
            _transactionMessageHash, _transactionMessageHashSignature
        );

        (, bytes[] memory _returnValues) = _atomicExecuteMultipleMetaTransactions(
            _transactions,
            _gasPrice
        );

        _issueRefund(_startGas, _gasPrice, _gasOverhead, _feeTokenAddress, _feeTokenRate);

        return _returnValues;
    }


    function _validateAuthKeyMetaTransactionSigs(
        bytes32 _transactionMessageHash,
        bytes memory _transactionMessageHashSignature
    )
        internal
        view
    {

        address _authKey = _transactionMessageHash.recover(_transactionMessageHashSignature);
        require(_isValidAuthKey(_authKey), "AKMTA: Auth key is invalid");
    }
}

library OpenZeppelinUpgradesAddress {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract AccountUpgradeability is BaseAccount {

    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;


    function implementation() public view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function upgradeToAndCall(
        address _newImplementation, 
        bytes memory _data
    ) 
        public 
        onlySelf
    {

        _setImplementation(_newImplementation);
        (bool success, bytes memory res) = _newImplementation.delegatecall(_data);

        string memory _revertMsg = _getRevertMsgFromRes(res);
        require(success, _revertMsg);
        emit Upgraded(_newImplementation);
    }


    function _setImplementation(address _newImplementation) internal {

        require(OpenZeppelinUpgradesAddress.isContract(_newImplementation), "AU: Cannot set a proxy implementation to a non-contract address");

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, _newImplementation)
        }
    }
}

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4);

}

interface IERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);


    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);

}

interface IERC1820ImplementerInterface {

    function canImplementInterfaceForAddress(bytes32 interfaceHash, address addr) external view returns(bytes32);

}

contract IERC777TokensRecipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

}

contract IAuthereumAccount is IERC1271, IERC721Receiver, IERC1155TokenReceiver, IERC1820ImplementerInterface, IERC777TokensRecipient {

    function () external payable;
    function name() external view returns (string memory);

    function version() external view returns (string memory);

    function implementation() external view returns (address);

    function lastInitializedVersion() external returns (uint256);

    function authKeys(address _authKey) external returns (bool);

    function nonce() external returns (uint256);

    function numAuthKeys() external returns (uint256);

    function getChainId() external pure returns (uint256);

    function addAuthKey(address _authKey) external;

    function upgradeToAndCall(address _newImplementation, bytes calldata _data) external;

    function removeAuthKey(address _authKey) external;

    function isValidAuthKeySignature(bytes32 _messageHash, bytes calldata _signature) external view returns (bool);

    function isValidLoginKeySignature(bytes32 _messageHash, bytes calldata _signature) external view returns (bool);

    function executeMultipleTransactions(bytes[] calldata _transactions) external returns (bytes[] memory);

    function executeMultipleMetaTransactions(bytes[] calldata _transactions) external returns (bytes[] memory);


    function executeMultipleAuthKeyMetaTransactions(
        bytes[] calldata _transactions,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        address _feeTokenAddress,
        uint256 _feeTokenRate,
        bytes calldata _transactionMessageHashSignature
    ) external returns (bytes[] memory);


    function executeMultipleLoginKeyMetaTransactions(
        bytes[] calldata _transactions,
        uint256 _gasPrice,
        uint256 _gasOverhead,
        bytes calldata _loginKeyRestrictionsData,
        address _feeTokenAddress,
        uint256 _feeTokenRate,
        bytes calldata _transactionMessageHashSignature,
        bytes calldata _loginKeyAttestationSignature
    ) external returns (bytes[] memory);

}

contract AuthereumAccount is
    IAuthereumAccount,
    BaseAccount,
    ERC1271Account,
    LoginKeyMetaTxAccount,
    AuthKeyMetaTxAccount,
    AccountUpgradeability
{

    string constant public name = "Authereum Account";
    string constant public version = "2020070100";
}