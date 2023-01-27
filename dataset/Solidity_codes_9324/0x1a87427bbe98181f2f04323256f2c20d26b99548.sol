

pragma solidity 0.8.11;

contract Notary {


    event Signed(
        uint documentType,
        address indexed witness,
        address[] indexed signatories,
        string indexed documentURL,
        string documentHash
    );

    function witness(
        uint documentType,
        address[] calldata signatories,
        string calldata documentURL,
        string calldata documentHash
    ) public {

        emit Signed(documentType, msg.sender, signatories, documentURL, documentHash);
    }
}