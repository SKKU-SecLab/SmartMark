
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}/*

  << ArrayUtils >>

  Various functions for manipulating arrays in Solidity.
  This library is completely inlined and does not need to be deployed or linked.

*/

pragma solidity 0.7.5;


library ArrayUtils {


    function guardedArrayReplace(bytes memory array, bytes memory desired, bytes memory mask)
        internal
        pure
    {

        require(array.length == desired.length, "Arrays have different lengths");
        require(array.length == mask.length, "Array and mask have different lengths");

        uint words = array.length / 0x20;
        uint index = words * 0x20;
        assert(index / 0x20 == words);
        uint i;

        for (i = 0; i < words; i++) {
            assembly {
                let commonIndex := mul(0x20, add(1, i))
                let maskValue := mload(add(mask, commonIndex))
                mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
            }
        }

        if (words > 0) {
            i = words;
            assembly {
                let commonIndex := mul(0x20, add(1, i))
                let maskValue := mload(add(mask, commonIndex))
                mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
            }
        } else {
            for (i = index; i < array.length; i++) {
                array[i] = ((mask[i] ^ 0xff) & array[i]) | (mask[i] & desired[i]);
            }
        }
    }

    function arrayEq(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {

        bool success = true;

        assembly {
            let length := mload(a)

            switch eq(length, mload(b))
            case 1 {
                let cb := 1

                let mc := add(a, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(b, 0x20)
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

    function arrayDrop(bytes memory _bytes, uint _start)
        internal
        pure
        returns (bytes memory)
    {


        uint _length = SafeMath.sub(_bytes.length, _start);
        return arraySlice(_bytes, _start, _length);
    }

    function arrayTake(bytes memory _bytes, uint _length)
        internal
        pure
        returns (bytes memory)
    {


        return arraySlice(_bytes, 0, _length);
    }

    function arraySlice(bytes memory _bytes, uint _start, uint _length)
        internal
        pure
        returns (bytes memory)
    {


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

    function unsafeWriteBytes(uint index, bytes memory source)
        internal
        pure
        returns (uint)
    {

        if (source.length > 0) {
            assembly {
                let length := mload(source)
                let end := add(source, add(0x20, length))
                let arrIndex := add(source, 0x20)
                let tempIndex := index
                for { } eq(lt(arrIndex, end), 1) {
                    arrIndex := add(arrIndex, 0x20)
                    tempIndex := add(tempIndex, 0x20)
                } {
                    mstore(tempIndex, mload(arrIndex))
                }
                index := add(index, length)
            }
        }
        return index;
    }

    function unsafeWriteAddress(uint index, address source)
        internal
        pure
        returns (uint)
    {
        uint conv = uint(source) << 0x60;
        assembly {
            mstore(index, conv)
            index := add(index, 0x14)
        }
        return index;
    }

    function unsafeWriteUint(uint index, uint source)
        internal
        pure
        returns (uint)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }

    function unsafeWriteUint8(uint index, uint8 source)
        internal
        pure
        returns (uint)
    {
        assembly {
            mstore8(index, source)
            index := add(index, 0x1)
        }
        return index;
    }

}/*

  << Wyvern Atomicizer >>

  Execute multiple transactions, in order, atomically (if any fails, all revert).

*/

pragma solidity 0.7.5;


library WyvernAtomicizer {


    function atomicize (address[] calldata addrs, uint[] calldata values, uint[] calldata calldataLengths, bytes calldata calldatas)
        external
    {
        require(addrs.length == values.length && addrs.length == calldataLengths.length, "Addresses, calldata lengths, and values must match in quantity");

        uint j = 0;
        for (uint i = 0; i < addrs.length; i++) {
            bytes memory cd = new bytes(calldataLengths[i]);
            for (uint k = 0; k < calldataLengths[i]; k++) {
                cd[k] = calldatas[j];
                j++;
            }
            (bool success,) = addrs[i].call{value: values[i]}(cd);
            require(success, "Atomicizer subcall failed");
        }
    }

    function atomicizeCustom (address[] calldata addrs, uint[] calldata values, uint[] calldata calldataLengths, bytes calldata calldatas)
        external
    {
        require(addrs.length == values.length && addrs.length == calldataLengths.length, "Addresses, calldata lengths, and values must match in quantity");

        uint start = 0;
        for (uint i = 0; i < addrs.length; i++) {
            if (i > 0) {
                start += calldataLengths[i - 1];
            }

            bytes memory cd = ArrayUtils.arraySlice(calldatas, start, calldataLengths[i]);
            (bool success,) = addrs[i].call{value: values[i]}(cd);
            require(success, "Atomicizer subcall failed");
        }
    }

    function atomicize1 (address addr, uint256 value, bytes calldata data) external {
        uint amount = value;
        if (msg.value != 0) {
            amount = msg.value;
        }
        (bool success,) = addr.call{value: amount}(data);
        require(success, "Atomicizer1 call failed");
    }

    function atomicize2 (address[] calldata addrs, uint[] calldata values, bytes calldata calldata0, bytes calldata calldata1) external {
        require(addrs.length == values.length && addrs.length == 2, "Addresses and values must match in quantity 2");

        (bool success,) = addrs[0].call{value: values[0]}(calldata0);
        require(success, "Atomicizer2 firstcall failed");

        (success,) = addrs[1].call{value: values[1]}(calldata1);
        require(success, "Atomicizer2 secondcall failed");
    }

    function atomicize3 (address[] calldata addrs, uint[] calldata values,
        bytes calldata calldata0, bytes calldata calldata1, bytes calldata calldata2) external {
        require(addrs.length == values.length && addrs.length == 3, "Addresses and values must match in quantity 3");

        (bool success,) = addrs[0].call{value: values[0]}(calldata0);
        require(success, "Atomicizer3 firstcall failed");

        (success,) = addrs[1].call{value: values[1]}(calldata1);
        require(success, "Atomicizer3 secondcall failed");

        (success,) = addrs[2].call{value: values[2]}(calldata2);
        require(success, "Atomicizer3 thirdcall failed");
    }

    function atomicize4 (address[] calldata addrs, uint[] calldata values, bytes calldata calldata0,
        bytes calldata calldata1, bytes calldata calldata2, bytes calldata calldata3) external {
        require(addrs.length == values.length && addrs.length == 4, "Addresses and values must match in quantity 4");

        (bool success,) = addrs[0].call{value: values[0]}(calldata0);
        require(success, "Atomicizer4 firstcall failed");

        (success,) = addrs[1].call{value: values[1]}(calldata1);
        require(success, "Atomicizer4 secondcall failed");

        (success,) = addrs[2].call{value: values[2]}(calldata2);
        require(success, "Atomicizer4 thirdcall failed");

        (success,) = addrs[3].call{value: values[3]}(calldata3);
        require(success, "Atomicizer4 forthcall failed");
    }
}