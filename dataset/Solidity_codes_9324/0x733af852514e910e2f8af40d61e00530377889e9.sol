

pragma solidity ^0.8.4;

interface ReverseRegistrar {

    function setName(string memory name) external returns (bytes32);

}

function getBytes(uint gasLimit, uint sizeLimit, address addr, bytes memory data) view returns (uint status, bytes memory result) {
    assembly {
        result := mload(0x40)

        mstore(result, 0)
        mstore(0x40, add(result, 32))

        status := staticcall(gasLimit, addr, add(data, 32), mload(data), 0, 0)

        if lt(returndatasize(), sizeLimit) {

            mstore(0x40, add(result, and(add(add(returndatasize(), 0x20), 0x1f), not(0x1f))))

            mstore(result, returndatasize())

            returndatacopy(add(result, 32), 0, returndatasize())
        }
    }
}

contract Multicall {


    constructor(address reverseRegistrar) {

        ReverseRegistrar(reverseRegistrar).setName("multicall.eth");
    }

    function execute(uint gasLimit, uint sizeLimit, address[] calldata addrs, bytes[] calldata datas) external view returns (uint blockNumber, uint[] memory statuses, bytes[] memory results) {

        require(addrs.length == datas.length);

        statuses = new uint256[](addrs.length);
        results = new bytes[](addrs.length);

        for (uint256 i = 0; i < addrs.length; i++) {
            (statuses[i], results[i]) = getBytes(gasLimit, sizeLimit, addrs[i], datas[i]);
        }

        return (block.number, statuses, results);
    }
}