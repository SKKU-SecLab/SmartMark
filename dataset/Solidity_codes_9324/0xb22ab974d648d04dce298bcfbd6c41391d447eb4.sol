

pragma solidity ^0.5;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}



contract Owned {

    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
     
    modifier onlyOwner {

        require(msg.sender == owner,"Invalid Owner");
        _;
    }
    
     
    function transferOwnership(address newOwner) public onlyOwner {

        owner = newOwner;
    }
}


contract ERC20 {

  uint256 public totalSupply;
  uint256 public decimals;
  function balanceOf(address who) public view returns (uint);

  function allowance(address owner, address spender) public view returns (uint);

  function transfer(address to, uint value) public returns (bool ok);

  function transferFrom(address from, address to, uint value) public;

  function approve(address spender, uint value) public returns (bool ok);

}


contract ExternalTokenSale is Owned {


    using SafeMath for uint;
    
    struct TokenArtifact {
        uint256 totalSold;
        uint256 exchangeRate; /* per Token in terms of base token (FTB) */
        ERC20 targetToken;
        uint256 pledgedFeePercent;
        uint256 pledgedFeeDivisor;
    }
    
    mapping(address => mapping(address => TokenArtifact)) public tokenLedger;
    mapping(address => bool) authorizedCaller;

    uint256 baseFeePercent;
    uint256 baseFeeDivisor;
    
    
    uint256 referralCommissionChargePercent;
    uint256 referralCommissionChargeDivisor;
    address payable referralChargeReceiver;
    
    uint256 transactionChargePercent;
    uint256 transactionChargeDivisor;
    address payable transactionChargeReceiver;
    
    event ConfigUpdated(
        address payable _transactionChargeReceiver,
        uint256 _transactionChargePercent,
        uint256 _transactionChargeDivisor,
        address payable _referralChargeReceiver,
        uint256 _referralCommissionChargePercent,
        uint256 _referralCommissionChargeDivisor,
        uint256 _baseFeePercent,
        uint256 _baseFeeDivisor
    );
    
    modifier onlyAuthCaller(){

        require(authorizedCaller[msg.sender] == true || msg.sender == owner,"Only Authorized and Owner can perform this action");
        _;
    }
    
    modifier onlyValidContribution(uint _value){

        require(_value > 0 ,"Value should be greater than zero");
        _;
    }

    event AuthorizedCaller(address _caller);
    event DeAuthorizedCaller(address _caller);
    
    event PurchaseToken(address indexed _buyerAddress,
                        address indexed _sellerAddress, 
                        address indexed _tokenAddress, 
                        uint256 _amount,
                        uint256 _feeAmount);
    
    event AddTokenArtifact(address indexed _sellerAddress, 
                        address indexed _tokenAddress, 
                        uint256 _amount,
                        uint256 _pledgedFeePercent,
                        uint256 _pledgedFeeDivisor);
                        
    event TransactionConfigUpdated(uint _transactionChargePercent, uint _transactionChargeDivisor);
    event ReferralCommissionConfigUpdated(uint _referralCommissionChargePercent, uint _referralCommissionChargeDivisor);

    
    constructor(address payable _transactionChargeReceiver, address payable _referralChargeReceiver) public {
        
        owner = msg.sender;
        transactionChargeReceiver = _transactionChargeReceiver;
        referralChargeReceiver = _referralChargeReceiver;
    }
    
   
     

    
    function authorizeCaller(address _caller) public onlyOwner returns(bool){

        authorizedCaller[_caller] = true;
        emit AuthorizedCaller(_caller);
        return true;
    }
    
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool){

        authorizedCaller[_caller] = false;
        emit DeAuthorizedCaller(_caller);
        return true;
    }   
    
    function getConfig()
        public
        view
        returns (
            address _transactionChargeReceiver,
            uint256 _transactionChargePercent,
            uint256 _transactionChargeDivisor,
            address _referralChargeReceiver,
            uint256 _referralCommissionChargePercent,
            uint256 _referralCommissionChargeDivisor,
            uint256 _baseFeePercent,
            uint256 _baseFeeDivisor
        )
    {

        return (
            transactionChargeReceiver,
            transactionChargePercent,
            transactionChargeDivisor,
            referralChargeReceiver,
            referralCommissionChargePercent,
            referralCommissionChargeDivisor,
            baseFeePercent,
            baseFeeDivisor
        );
    }

    function updateConfig(
        address payable _transactionChargeReceiver,
        uint256 _transactionChargePercent,
        uint256 _transactionChargeDivisor,
        address payable _referralChargeReceiver,
        uint256 _referralCommissionChargePercent,
        uint256 _referralCommissionChargeDivisor,
        uint256 _baseFeePercent,
        uint256 _baseFeeDivisor
    ) public onlyAuthCaller returns (bool) {

        
        baseFeePercent = _baseFeePercent;
        baseFeeDivisor = _baseFeeDivisor;
        
        transactionChargeReceiver = _transactionChargeReceiver;
        transactionChargePercent = _transactionChargePercent;
        transactionChargeDivisor = _transactionChargeDivisor;
    
        referralChargeReceiver = _referralChargeReceiver;
        referralCommissionChargePercent = _referralCommissionChargePercent;
        referralCommissionChargeDivisor = _referralCommissionChargeDivisor;
        
        emit ConfigUpdated(
            _transactionChargeReceiver,
            _transactionChargePercent,
            _transactionChargeDivisor,
            _referralChargeReceiver,
            _referralCommissionChargePercent,
            _referralCommissionChargeDivisor,
            _baseFeePercent,
            _baseFeeDivisor
        );

        return true;
    }
    
    
    function addTokenArtifact(
        address _tokenAddress, 
        uint256 _exchangeRate,
        uint256 _pledgedFeePercent,
        uint256 _pledgedFeeDivisor) public returns(bool)
    {

        tokenLedger[msg.sender][_tokenAddress].totalSold =  0 ;
        tokenLedger[msg.sender][_tokenAddress].exchangeRate =  _exchangeRate ;
        tokenLedger[msg.sender][_tokenAddress].targetToken =  ERC20(_tokenAddress) ;
        
        tokenLedger[msg.sender][_tokenAddress].pledgedFeePercent = _pledgedFeePercent;
        tokenLedger[msg.sender][_tokenAddress].pledgedFeeDivisor = _pledgedFeeDivisor;
        
        emit AddTokenArtifact(
            msg.sender, 
            _tokenAddress, 
            _exchangeRate,
            _pledgedFeePercent,
            _pledgedFeeDivisor
        );
        return true;
    }
    

    
    
    function purchaseToken(
        address payable _sellerAddress, 
        address _tokenAddress, 
        bool _isReferredBuyer) public payable returns(bool)
    { 

        
        TokenArtifact memory _activeTokenArtifact = tokenLedger[_sellerAddress][_tokenAddress];
        
        require(_activeTokenArtifact.exchangeRate > 0, "Exchange Rate should greater than zero ");
        
        uint256 _targetTokenDecimalBase = uint256(_activeTokenArtifact.targetToken.decimals());
        uint256 _finalAmount = 0;
  
       
        
        uint256 _depositedAmt = msg.value;
  
        uint256 _baseRecievableAmt = 0;
        uint256 _baseFeeAmt = 0;
        
        uint256 _adminFeeAmt = 0;
        uint256 _referralFeeAmt = 0;
        
   
   
        _baseFeeAmt = _activeTokenArtifact.pledgedFeePercent.mul(_depositedAmt).div(_activeTokenArtifact.pledgedFeeDivisor.mul(100));
        _baseRecievableAmt = _depositedAmt.sub(_baseFeeAmt);
        
        
        if (transactionChargeDivisor > 0 && transactionChargePercent > 0) {
            
            _adminFeeAmt = transactionChargePercent.mul(_baseFeeAmt).div(
                transactionChargeDivisor.mul(100)
            );
         
        }

        if(referralCommissionChargeDivisor > 0 &&
            referralCommissionChargePercent > 0){
            _referralFeeAmt = referralCommissionChargePercent
                .mul(_baseFeeAmt)
                .div(referralCommissionChargeDivisor.mul(100));
            }
        

        if (
            _isReferredBuyer == false            
        ) {
            _adminFeeAmt = _adminFeeAmt.add(_referralFeeAmt);                     
        } 

        if (_adminFeeAmt > 0) {
            transactionChargeReceiver.transfer(_adminFeeAmt);
        }

        if (_referralFeeAmt > 0) {
            referralChargeReceiver.transfer(_referralFeeAmt);
        }
        
        
        _sellerAddress.transfer(_baseRecievableAmt);

        _finalAmount = _depositedAmt.mul(10 ** _targetTokenDecimalBase).div(_activeTokenArtifact.exchangeRate);
        
        _activeTokenArtifact.targetToken.transferFrom(_sellerAddress,msg.sender,_finalAmount);
        
        _activeTokenArtifact.totalSold = tokenLedger[msg.sender][_tokenAddress].totalSold.add(_finalAmount);
        
        
        
        emit PurchaseToken(msg.sender, _sellerAddress, _tokenAddress, _finalAmount, _baseFeeAmt);
        return true;   
    }

    
    function () external onlyValidContribution(msg.value) payable {

       revert();
    }


}