pragma solidity ^0.8.0;

contract OnChainTest {

    function twoValuesEquator(bytes calldata value1, bytes calldata value2)
        public
        pure
    {

        require(keccak256(value1) == keccak256(value2), "Mismatched value");
    }

    function twoCallsEquator(
        address address1,
        address address2,
        bytes calldata data1,
        bytes calldata data2
    ) public {

        (, bytes memory value1) = address1.call{value: 0}(data1);
        (, bytes memory value2) = address2.call{value: 0}(data2);

        require(keccak256(value1) == keccak256(value2), "Mismatched value");
    }

    function valueAndCallEquator(
        address address1,
        bytes calldata data1,
        bytes calldata value2
    ) public {

        (, bytes memory value1) = address1.call{value: 0}(data1);

        require(keccak256(value1) == keccak256(value2), "Mismatched value");
    }
}