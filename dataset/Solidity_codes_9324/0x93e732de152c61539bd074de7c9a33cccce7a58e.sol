
pragma solidity 0.4.25;

contract OwnedI {

    event LogOwnerChanged(address indexed previousOwner, address indexed newOwner);

    function getOwner()
        view public
        returns (address);


    function setOwner(address newOwner)
        public
        returns (bool success); 

}

contract Owned is OwnedI {

    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier fromOwner {

        require(msg.sender == owner);
        _;
    }

    function getOwner()
        view public
        returns (address) {

        return owner;
    }

    function setOwner(address newOwner)
        fromOwner public
        returns (bool success) {

        require(newOwner != 0);
        if (owner != newOwner) {
            emit LogOwnerChanged(owner, newOwner);
            owner = newOwner;
        }
        success = true;
    }
}

contract BalanceFixable is OwnedI {

    function fixBalance()
        public
        returns (bool success) {

        getOwner().transfer(address(this).balance);
        return true;
    }
}

contract CertifierDbI {

    event LogCertifierAdded(address indexed certifier);

    event LogCertifierRemoved(address indexed certifier);

    function addCertifier(address certifier)
        public
        returns (bool success);


    function removeCertifier(address certifier)
        public
        returns (bool success);


    function getCertifiersCount()
        view public
        returns (uint count);


    function getCertifierStatus(address certifierAddr)
        view public 
        returns (bool authorised, uint256 index);


    function getCertifierAtIndex(uint256 index)
        view public
        returns (address);


    function isCertifier(address certifier)
        view public
        returns (bool isIndeed);

}

contract CertifierDb is Owned, CertifierDbI, BalanceFixable {

    struct Certifier {
        bool authorised;
        uint256 index;
    }

    mapping(address => Certifier) private certifierStatuses;
    
    address[] private certifiers;

    modifier fromCertifier {

        require(certifierStatuses[msg.sender].authorised);
        _;
    }

    constructor() public {
    }

    function addCertifier(address certifier)
        fromOwner public
        returns (bool success) {

        require(certifier != 0);
        if (!certifierStatuses[certifier].authorised) {
            certifierStatuses[certifier].authorised = true;
            certifierStatuses[certifier].index = certifiers.length;
            certifiers.push(certifier);
            emit LogCertifierAdded(certifier);
        }
        success = true;
    }

    function removeCertifier(address certifier)
        fromOwner public
        returns (bool success) {

        require(certifierStatuses[certifier].authorised);
        uint256 index = certifierStatuses[certifier].index;
        certifiers[index] = certifiers[certifiers.length - 1];
        certifierStatuses[certifiers[index]].index = index;
        certifiers.length--;
        delete certifierStatuses[certifier];
        emit LogCertifierRemoved(certifier);
        success = true;
    }

    function getCertifiersCount()
        view public
        returns (uint256 count) {

        count = certifiers.length;
    }

    function getCertifierStatus(address certifierAddr)
        view public 
        returns (bool authorised, uint256 index) {

        Certifier storage certifier = certifierStatuses[certifierAddr];
        return (certifier.authorised,
            certifier.index);
    }

    function getCertifierAtIndex(uint256 index)
        view public
        returns (address) {

        return certifiers[index];
    }

    function isCertifier(address certifier)
        view public
        returns (bool isIndeed) {

        isIndeed = certifierStatuses[certifier].authorised;
    }
}