


pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;

contract OpenOracleData {




    function source(bytes memory message, bytes memory signature) public pure returns (address) {

        (bytes32 r, bytes32 s, uint8 v) = abi.decode(signature, (bytes32, bytes32, uint8));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(message)));
        return ecrecover(hash, v, r, s);
    }
}


pragma solidity ^0.6.10;


contract OpenOraclePriceData is OpenOracleData {

    event Write(address indexed source, string key, uint64 timestamp, uint64 value);
    event NotWritten(uint64 priorTimestamp, uint256 messageTimestamp, uint256 blockTimestamp);

    struct Datum {
        uint64 timestamp;
        uint64 value;
    }

    mapping(address => mapping(string => Datum)) private data;

    function put(bytes calldata message, bytes calldata signature) external returns (string memory) {

        (address source, uint64 timestamp, string memory key, uint64 value) = decodeMessage(message, signature);
        return putInternal(source, timestamp, key, value);
    }

    function putInternal(address source, uint64 timestamp, string memory key, uint64 value) internal returns (string memory) {

        Datum storage prior = data[source][key];
        if (timestamp > prior.timestamp && timestamp < block.timestamp + 60 minutes && source != address(0)) {
            data[source][key] = Datum(timestamp, value);
            emit Write(source, key, timestamp, value);
        } else {
            emit NotWritten(prior.timestamp, timestamp, block.timestamp);
        }
        return key;
    }

    function decodeMessage(bytes calldata message, bytes calldata signature) internal pure returns (address, uint64, string memory, uint64) {

        address source = source(message, signature);

        (string memory kind, uint64 timestamp, string memory key, uint64 value) = abi.decode(message, (string, uint64, string, uint64));
        require(keccak256(abi.encodePacked(kind)) == keccak256(abi.encodePacked("prices")), "Kind of data must be 'prices'");
        return (source, timestamp, key, value);
    }

    function get(address source, string calldata key) external view returns (uint64, uint64) {

        Datum storage datum = data[source][key];
        return (datum.timestamp, datum.value);
    }

    function getPrice(address source, string calldata key) external view returns (uint64) {

        return data[source][key].value;
    }
}