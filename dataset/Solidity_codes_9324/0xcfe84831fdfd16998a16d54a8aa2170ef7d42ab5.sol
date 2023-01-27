
pragma solidity 0.4.24;

contract DisclosureAgreementTracker {


    struct Agreement {
        bytes32 previous;
        uint disclosureIndex;
        uint blockNumber;
        uint signedCount;
        address[] signatories;
        mapping(address => bool) requiredSignatures;
    }

    struct Latest {
        bytes32 agreementHash;
        uint agreementCount;
    }

    address public owner;

    address public disclosureManager;

    uint public agreementCount;

    uint public disclosureCount;

    mapping(bytes32 => Agreement) public agreementMap;

    mapping(uint => Latest) public latestMap;

    event agreementAdded(
        bytes32 agreementHash,
        uint disclosureIndex,
        address[] signatories);

    event agreementSigned(
        bytes32 agreementHash,
        uint disclosureIndex,
        address signatory);

    event agreementFullySigned(
        bytes32 agreementHash,
        uint disclosureIndex);

    constructor(address disclosureManagerAddress) public {
        owner = msg.sender;
        disclosureManager = disclosureManagerAddress;
    }

    modifier isOwner() {

        if (msg.sender != owner) revert("sender must be owner");
        _;
    }

    function _hasAgreement(Agreement agreement) private pure returns(bool) {

        return agreement.disclosureIndex != 0;
    }

    function hasAgreement(bytes32 agreementHash) public view returns(bool) {

        return _hasAgreement(agreementMap[agreementHash]);
    }

    function _hasDisclosureAgreement(Latest latest) private pure returns(bool) {

        return latest.agreementCount != 0;
    }

    function hasDisclosureAgreement(uint disclosureIndex) public view returns(bool) {

        return _hasDisclosureAgreement(latestMap[disclosureIndex]);
    }

    function _isAgreementFullySigned(Agreement agreement)
    private pure returns(bool) {

        return agreement.signedCount == agreement.signatories.length;
    }

    function isAgreementFullySigned(bytes32 agreementHash)
    public view returns(bool) {

        Agreement storage agreement = agreementMap[agreementHash];
        return _hasAgreement(agreement)
            && _isAgreementFullySigned(agreement);
    }

    function isDisclosureFullySigned(uint disclosureIndex)
    public view returns(bool) {

        return isAgreementFullySigned(
            latestMap[disclosureIndex].agreementHash
        );
    }
    
    function _getRequiredSignaturesArray(Agreement storage agreement)
    private view returns (bool[]) {

        address[] storage signatories = agreement.signatories;
        bool[] memory requiredSignatureArray = new bool[](signatories.length);
        for (uint i = 0; i < signatories.length; i++) {
            address signatory = signatories[i];
            requiredSignatureArray[i] = agreement.requiredSignatures[signatory];
        }
        return requiredSignatureArray;
    }

    function getAgreement(bytes32 agreementHash)
    public view returns(
        bytes32 previous, uint disclosureIndex, uint blockNumber,
        uint signedCount, address[] signatories, bool[] requiredSignatures
    ) {

        Agreement storage agreement = agreementMap[agreementHash];
        previous = agreement.previous;
        disclosureIndex = agreement.disclosureIndex;
        blockNumber = agreement.blockNumber;
        signedCount = agreement.signedCount;
        signatories = agreement.signatories;
        requiredSignatures = _getRequiredSignaturesArray(agreement);
    }

    function addAgreement(
        bytes32 agreementHash,
        uint disclosureIndex,
        address[] signatories
    ) public isOwner {

        require(disclosureIndex > 0, "disclosureIndex must be greater than 0");
        require(agreementHash != 0, "agreementHash must not be 0");
        require(signatories.length > 0, "signatories must not be empty");

        Agreement storage agreement = agreementMap[agreementHash];
        if (_hasAgreement(agreement)) {
            revert("Agreement already exists");
        }
        agreementCount++;
        agreement.disclosureIndex = disclosureIndex;
        agreement.blockNumber = block.number;
        agreement.signatories = signatories;

        Latest storage latest = latestMap[disclosureIndex];
        if (!_hasDisclosureAgreement(latest)) {
            disclosureCount++;
        }
        agreement.previous = latest.agreementHash;
        latest.agreementHash = agreementHash;
        latest.agreementCount++;

        for (uint i = 0; i < signatories.length; i++) {
            address signatory = signatories[i];
            if (agreement.requiredSignatures[signatory]) {
                revert("signatories must not contain duplicates");
            }
            agreement.requiredSignatures[signatory] = true;
        }
        
        emit agreementAdded(agreementHash, disclosureIndex, signatories);
    }

    function signAgreement(bytes32 agreementHash) public {

        require(hasAgreement(agreementHash), "agreeement must exist");

        Agreement storage agreement = agreementMap[agreementHash];
        bool signed = agreement.requiredSignatures[msg.sender];
        require(signed, "sender already signed or not a signatory");

        agreement.requiredSignatures[msg.sender] = false;
        agreement.signedCount++;

        emit agreementSigned(
            agreementHash,
            agreement.disclosureIndex,
            msg.sender);

        if (_isAgreementFullySigned(agreement)) {
            emit agreementFullySigned(
                agreementHash,
                agreement.disclosureIndex);
        }
    }

    function () public payable {
        revert("payment not supported");
    }

}