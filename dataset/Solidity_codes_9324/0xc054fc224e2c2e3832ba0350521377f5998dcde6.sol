
pragma solidity ^0.8.0;

interface IERC20 {

    function balanceOf(address address_) external view returns (uint256);

    function transfer(address to_, uint256 amount_) external returns (bool);

    function transferFrom(address from_, address to_, uint256 amount_) external;

}

contract EmploymentManager { 



    event AgreementCreated(address indexed employer_, address indexed benefactor_,
        address indexed currency_, uint16 totalEpochs_, uint256 paymentPerEpoch_);
    event EmployerSignedEpoch(address indexed employer_, address indexed benefactor_,
        uint256 index_, uint16 employerEpoch_);
    event BenefactorSignedEpoch(address indexed benefactor_, 
        address indexed employer_, uint256 index_, uint16 benefactorEpoch_,
        address currency_, uint256 paymentPerEpoch_);
    event EmployerWithdrewVoidAgreement(address indexed employer_, 
        address indexed benefactor_, uint256 index_, uint16 employerEpoch_,
        uint16 benefactorEpoch_, address currency_, uint256 totalDeposit_,
        uint256 totalPaid_, uint256 remainingBalance_);

    struct Agreement {
        uint32 creationTimestamp; // 4 | 28
        uint16 totalEpochs; // 2 | 26

        address employer; // 20 | 6
        uint32 employerSigned; // 4 | 2
        uint16 employerEpoch; // 2 | 0

        address benefactor; // 20 | 12
        uint32 benefactorSigned; // 4 | 8
        uint16 benefactorEpoch; // 2 | 6

        address currency; // 20 | 12
        
        uint256 totalDeposit; // 32 | 0
        uint256 totalPaid; // 32 | 0
        uint256 paymentPerEpoch; // 32 | 0
    }

    uint32 constant public epochTime = 28 days;
    uint32 constant public cutoffTime = 20 days;

    mapping(uint256 => Agreement) public indexToAgreement;

    uint256 public indexToAgreementLength;

    function _sendETH(address payable address_, uint256 amount_) internal {

        (bool success, ) = payable(address_).call{value: amount_}("");
        require(success, "Transfer failed");
    }
    function _employerSign(uint256 index_) internal {

        indexToAgreement[index_].employerSigned = uint32(block.timestamp);
        indexToAgreement[index_].employerEpoch++;
    }
    function _benefactorSign(uint256 index_) internal {

        indexToAgreement[index_].benefactorSigned = uint32(block.timestamp);
        indexToAgreement[index_].benefactorEpoch++;
    }

    function createEmploymentAgreement(address payable benefactor_, address currency_,
    uint16 totalEpochs_, uint256 paymentPerEpoch_) external payable {


        require(benefactor_ != address(0),
            "Benefactor cannot be 0x0!");
        
        uint256 _totalPayment = uint256(totalEpochs_) * paymentPerEpoch_;

        if (currency_ == address(0)) { 
            require(msg.value == _totalPayment,
                "Incorrect msg.value sent!");
        }
        else {
            require(IERC20(currency_).balanceOf(msg.sender) >= _totalPayment,
                "You don't own enough ERC20!");

            IERC20(currency_).transferFrom(msg.sender, address(this), _totalPayment);
        }

        indexToAgreement[indexToAgreementLength] = Agreement(
            uint32(block.timestamp),
            totalEpochs_,

            msg.sender,
            0,
            0,

            benefactor_,
            0,
            0,

            currency_,

            _totalPayment,
            0,
            paymentPerEpoch_
        );

        indexToAgreementLength++;

        emit AgreementCreated(msg.sender, benefactor_, currency_, 
        totalEpochs_, paymentPerEpoch_);
    }

    function employerSignEpoch(uint256 index_) external {

        
        Agreement memory _Agreement = indexToAgreement[index_];

        require(_Agreement.employer == msg.sender,
            "You are not the employer!");
        require(_Agreement.employerEpoch == _Agreement.benefactorEpoch,
            "Benefactor has not signed the last epoch yet!");
        require(_Agreement.totalEpochs > _Agreement.employerEpoch,
            "No epochs remaining!");
        
        uint32 _nextSignStart = _Agreement.creationTimestamp +
            (_Agreement.employerEpoch * epochTime);
        
        require( uint32(block.timestamp) >= _nextSignStart,
            "Next Epoch has not started yet!");
        require( uint32(block.timestamp) < (_nextSignStart + cutoffTime), 
            "Exceeded cutoff time! Agreement Void!");
        
        _employerSign(index_);
        
        emit EmployerSignedEpoch(msg.sender, _Agreement.benefactor, index_,
        _Agreement.employerEpoch);
    }

    function benefactorSignAndClaimEpoch(uint256 index_) external {

        
        Agreement memory _Agreement = indexToAgreement[index_];

        require(_Agreement.benefactor == msg.sender,
            "You are not the benefactor!");
        require(_Agreement.employerEpoch > _Agreement.benefactorEpoch,
            "Employer has not signed this epoch yet!");

        _benefactorSign(index_);

        indexToAgreement[index_].totalPaid += _Agreement.paymentPerEpoch;

        if (_Agreement.currency == address(0)) {
            _sendETH(payable(msg.sender), _Agreement.paymentPerEpoch);
        }
        else {
            IERC20(_Agreement.currency).transfer(msg.sender, _Agreement.paymentPerEpoch);
        }

        emit BenefactorSignedEpoch(msg.sender, _Agreement.employer, index_,
        _Agreement.benefactorEpoch, _Agreement.currency, _Agreement.paymentPerEpoch);
    }

    function employerWithdrawVoidAgreement(uint256 index_) external {


        Agreement memory _Agreement = indexToAgreement[index_];

        require(_Agreement.employer == msg.sender,
            "You are not the employer!");
        
        uint32 _nextSignStart = _Agreement.creationTimestamp +
            (_Agreement.employerEpoch * epochTime);
        
        require( uint32(block.timestamp) > (_nextSignStart + cutoffTime), 
            "Agreement is still valid!");

        uint256 _totalPaid = _Agreement.totalPaid;
        uint256 _remainingBalance = _Agreement.totalDeposit - _Agreement.totalPaid;

        indexToAgreement[index_].totalPaid += _remainingBalance;

        if (_Agreement.currency == address(0)) {
            _sendETH(payable(msg.sender), _remainingBalance);
        }
        else {
            IERC20(_Agreement.currency).transfer(msg.sender, _remainingBalance);
        }

        emit EmployerWithdrewVoidAgreement(msg.sender, _Agreement.benefactor, index_,
        _Agreement.employerEpoch, _Agreement.benefactorEpoch, _Agreement.currency,
        _Agreement.totalDeposit, _totalPaid, _remainingBalance);
    }
}