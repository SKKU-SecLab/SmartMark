
pragma solidity ^0.5.8;

contract Charitable {

    address payable owner;
    address payable taxCollectAddress;
    uint256 taxPercent;
    uint256 totalDonationsAmount;
    uint256 highestDonation;
    address payable highestDonor;

    constructor(address payable address_) public {
        owner = msg.sender;
        taxCollectAddress = address_;
        taxPercent = 5;
        totalDonationsAmount = 0;
        highestDonation = 0;
    }

    modifier restrictToOwner() {

        require(msg.sender == owner, 'Method available only to the to the user that deployed the contract');
        _;
    }

    modifier validateTransferAmount() {

        require(msg.value > 0, 'Transfer amount has to be greater than 0.');
        _;
    }

    modifier validateDonationAmount(uint256 donationAmount) {

        require(donationAmount >= msg.value / 100 && donationAmount <= msg.value / 2,
            'Donation amount has to be from 1% to 50% of the total transferred amount');
        _;
    }

    event Donation(
        address indexed _donor,
        uint256 _value
    );

    event OwnershipTransferred(
        address indexed previousOwner, 
        address indexed newOwner
    );

    event TaxAddressTransferred(
        address indexed previousTaxAddress, 
        address indexed newTaxAddress
    );

    event TaxPercentageTransferred(
        uint256 indexed previousPercentage, 
        uint256 indexed newPercentage
    );

    function donate(address payable charityAddress) public validateTransferAmount() payable {

        uint256 taxAmount = msg.value * taxPercent / 100;
        uint256 donationAmount = msg.value - taxAmount;

        charityAddress.transfer(donationAmount);
        taxCollectAddress.transfer(taxAmount);

        emit Donation(msg.sender, donationAmount);

        totalDonationsAmount += donationAmount;

        if (donationAmount > highestDonation) {
            highestDonation = donationAmount;
            highestDonor = msg.sender;
        }
    }

    function getAddress() public view returns (address payable) {

        return taxCollectAddress;
    }

    function getTotalDonationsAmount() public view returns (uint256) {

        return totalDonationsAmount;
    }

    function getHighestDonation() public view restrictToOwner() returns (uint256, address payable)  {

        return (highestDonation, highestDonor);
    }

    function destroy() public restrictToOwner() {

        selfdestruct(owner);
    }

    function transferOwnership(address payable newOwner) public restrictToOwner() {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setTaxAddress(address payable newTaxAddress) public restrictToOwner() {

        require(newTaxAddress != address(0));
        emit TaxAddressTransferred(taxCollectAddress, newTaxAddress);
        taxCollectAddress = newTaxAddress;
    }

    function setTaxAddress(uint256 newTaxPercent) public restrictToOwner() {

        require(newTaxPercent != 0);
        emit TaxPercentageTransferred(taxPercent, newTaxPercent);
        taxPercent = newTaxPercent;
    }
}