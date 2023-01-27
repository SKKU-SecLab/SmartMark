
pragma solidity ^0.8.0;


interface IERC20 {

    function balanceOf(address address_) external view returns (uint256);


    function transfer(address to_, uint256 amount_) external returns (bool); 


    function transferFrom(address from_, address to_, uint256 amount_) external;

}

contract EmploymentManagerLive {



    event AgreementCreated(address employer_, address benefactor_, address token_, 
        uint256 index_, uint256 amount_, uint32 startTimestamp_, uint32 endTimestamp_);
    event ClaimFromAgreement(address employer_, address benefactor_, address token_,
        uint256 index_, uint256 amount_);

    struct Agreement {
        uint32 startTimestamp; // 4 | 28
        uint32 endTimestamp; // 4 | 24

        
        uint96 deposit; // 12 | 12
        uint96 balance; // 12 | 0
    }

    mapping(address => 
    mapping(address => 
    mapping(address => 
    mapping(uint256 => Agreement))))
        public employerToBenefactorToTokenToIndexToAgreement;

    function createAgreement(address benefactor_, address token_, uint256 amount_,
    uint256 index_, uint32 startTimestamp_, uint32 endTimestamp_) public {


        require(uint96(amount_) == amount_,
            "Amount out of bounds!");

        require(employerToBenefactorToTokenToIndexToAgreement[msg.sender][benefactor_]
        [token_][index_].balance == 0,
            "Balance of Agreement at Index != 0!");

        IERC20(token_).transferFrom(msg.sender, address(this), amount_);

        employerToBenefactorToTokenToIndexToAgreement[msg.sender][benefactor_]
        [token_][index_] = Agreement(
            startTimestamp_, endTimestamp_, uint96(amount_), uint96(amount_));
        
        emit AgreementCreated(msg.sender, benefactor_, token_, amount_, index_,
            startTimestamp_, endTimestamp_);
    }

    function _getClaimableAmount(address employer_, address benefactor_, address token_,
    uint256 index_) public view returns (uint256) {

        Agreement memory _Agreement = employerToBenefactorToTokenToIndexToAgreement
            [employer_][benefactor_][token_][index_];
        
        uint256 _totalTimeRequired = _Agreement.endTimestamp - _Agreement.startTimestamp;
        uint256 _currentTimeElapsed = block.timestamp > _Agreement.startTimestamp ? 
            block.timestamp - _Agreement.startTimestamp : 0;

        uint256 _claimedAmount = _Agreement.deposit - _Agreement.balance;

        uint256 _totalClaimable = 
            _currentTimeElapsed >= _totalTimeRequired ? uint256(_Agreement.balance) :

            (((uint256(_Agreement.deposit)) * _currentTimeElapsed) / _totalTimeRequired)
                - _claimedAmount;

        return _totalClaimable;
    }

    function claimFromAgreement(address employer_, address benefactor_, address token_,
    uint256 index_) public {

        require(benefactor_ == msg.sender,
            "You are not the benefactor!");
        
        uint256 _claimableAmount = 
            _getClaimableAmount(employer_, benefactor_, token_, index_);

        require(_claimableAmount > 0,
            "No claimable balance!");

        employerToBenefactorToTokenToIndexToAgreement
        [employer_][benefactor_][token_][index_].balance -= uint96(_claimableAmount);

        IERC20(token_).transfer(benefactor_, _claimableAmount);

        emit ClaimFromAgreement(employer_, benefactor_, token_, index_, 
        _claimableAmount);
    }
}