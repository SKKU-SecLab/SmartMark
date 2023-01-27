
pragma solidity ^0.5.4;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract SplitPayment is Ownable {

    
    address payable[] public beneficiaries;
    
    event AddedBeneficiary(address beneficiary);
    
    event RemovedBeneficiary(uint256 indexOfBeneficiary, address beneficiary);
    
    event LogPayout(address beneficiary, uint256 amount);
    
    function addBeneficiary(address payable _beneficiary) public onlyOwner {

        beneficiaries.push(_beneficiary);
        emit AddedBeneficiary(_beneficiary);
    }
    
    function bulkAddBeneficiaries(address payable[] memory _beneficiaries) public onlyOwner {

        uint256 len = beneficiaries.length;
        
        for (uint256 b = 0; b < len; b++) {
            addBeneficiary(_beneficiaries[b]);
        }
    }
    
    function removeBeneficiary(uint256 indexOfBeneficiary) public onlyOwner {

        emit RemovedBeneficiary(indexOfBeneficiary, beneficiaries[indexOfBeneficiary]);

        if (indexOfBeneficiary < beneficiaries.length - 1) {
            beneficiaries[indexOfBeneficiary] = beneficiaries[beneficiaries.length - 1];
        }

        if(indexOfBeneficiary < beneficiaries.length) {
            beneficiaries.length--;
        }
    }
    
    function() external payable {
        uint256 len = beneficiaries.length;
        uint256 amount = msg.value / len;
        
        for (uint256 b = 0; b < len; b++) {
            beneficiaries[b].transfer(amount);
            emit LogPayout(beneficiaries[b], amount);
        }
    }
    
    function payOnce(address payable[] memory _beneficiaries) public payable {

        uint256 len = _beneficiaries.length;
        uint256 amount = msg.value / len;
        
        for (uint256 b = 0; b < len; b++) {
            _beneficiaries[b].transfer(amount);
            emit LogPayout(_beneficiaries[b], amount);
        }
    }
    
    function getNumberOfBeneficiaries() public view returns (uint256 length) {

        return beneficiaries.length;
    }
}