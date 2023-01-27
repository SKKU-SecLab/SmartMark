
pragma solidity ^0.4.24;

contract TxRelay {


    mapping(address => uint) public nonce;

    event Log(address from, string message);
    event MetaTxRelayed(address indexed claimedSender, address indexed addressFromSig);

    function relayMetaTx(
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        address destination,
        bytes data
    ) public {


        address claimedSender = getAddressFromData(data);
        bytes32 h = keccak256(
            abi.encodePacked(byte(0x19), byte(0), this, claimedSender, nonce[claimedSender], destination, data)
        );
        address addressFromSig = getAddressFromSig(h, sigV, sigR, sigS);

        require(claimedSender == addressFromSig, "address recovered from signature must match with claimed sender");

        nonce[claimedSender]++;

        require(destination.call(data), "can not invoke destination function");

        emit MetaTxRelayed(claimedSender, addressFromSig);
    }

    function getAddressFromData(bytes b) public pure returns (address a) {

        if (b.length < 36) return address(0);
        assembly {
            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            a := and(mask, mload(add(b, 36)))
        }
    }

    function getAddressFromSig(
        bytes32 msgHash,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS
    ) public pure returns (address a) {

        return ecrecover(msgHash, sigV, sigR, sigS);
    }
}