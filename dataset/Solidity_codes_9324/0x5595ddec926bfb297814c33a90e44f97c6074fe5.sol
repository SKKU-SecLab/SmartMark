

pragma solidity ^0.8.0;


library BytesUtils {

    function drop(bytes memory array, uint256 start)
        public
        pure
        returns (bytes memory result)
    {

        result = slice(array, start, array.length - start);
    }

    function slice(
        bytes memory array,
        uint256 start,
        uint256 length
    ) public pure returns (bytes memory result) {

        assembly {
            switch iszero(length)
            case 0 {
                result := mload(0x40)

                let lengthMod := and(length, 31)

                let mc := add(
                    add(result, lengthMod),
                    mul(0x20, iszero(lengthMod))
                )
                let end := add(mc, length)

                for {
                    let cc := add(
                        add(
                            add(array, lengthMod),
                            mul(0x20, iszero(lengthMod))
                        ),
                        start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(result, length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                result := mload(0x40)

                mstore(0x40, add(result, 0x20))
            }
        }
    }
}