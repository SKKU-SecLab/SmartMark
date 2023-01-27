

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

    function owned() public {

        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner, "Invalid Owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        owner = newOwner;
    }
}


contract StandardProductPurchase is Owned {

    using SafeMath for uint256;
    
    uint256 baseFeePercent;
    uint256 baseFeeDivisor;
    
    
    uint256 referralCommissionChargePercent;
    uint256 referralCommissionChargeDivisor;
    address payable referralChargeReceiver;
    
    uint256 transactionChargePercent;
    uint256 transactionChargeDivisor;
    address payable transactionChargeReceiver;
    
    
    
    mapping(address => bool) authorizedCaller;

   
    struct ProductTx {
        string _txId;
        string _id;
        uint256 _depositedAmt;
        uint256 _receivableAmt;
        uint256 _feeAmt;
        uint256 _paymentMode;
        uint256 _pledgedFeePercent;
        uint256 _pledgedFeeDivisor;
        address payable _ownerAddress;
    }
    
    struct ProductInfo {
        string _id;
        uint256 _priceInWei;
        address payable _ownerAddress;
        uint256 _pledgedFeePercent;
        uint256 _pledgedFeeDivisor;
        uint256 _paymentMode;
    }

   
    mapping(string => ProductTx) public initiatedProductTx;
    mapping(string => ProductInfo) public initiatedProduct;
    
    event AuthorizedCaller(address _caller);
    event DeAuthorizedCaller(address _caller);
    
    event ProductInfoUpdated(string _id,
        uint256 _priceInWei,
        address payable _ownerAddress,
        uint256 _pledgedFeePercent,
        uint256 _pledgedFeeDivisor,
        uint256 _paymentMode);
    

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
    

    event TransactionCompleted(
        string _txId
    );
    
 

    constructor(address payable _transactionChargeReceiver, address payable _referralChargeReceiver) public {
        owner = msg.sender;
        transactionChargeReceiver = _transactionChargeReceiver;
        referralChargeReceiver = _referralChargeReceiver;
    }

    modifier onlyAuthorized() {

        require(
            authorizedCaller[msg.sender] == true || msg.sender == owner,
            "Only Authorized and Owner can perform this action"
        );
        _;
    }

    function authorizeCaller(address _caller) public onlyOwner returns (bool) {

        authorizedCaller[_caller] = true;
        emit AuthorizedCaller(_caller);
        return true;
    }

    function deAuthorizeCaller(address _caller)
        public
        onlyOwner
        returns (bool)
    {

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
    ) public onlyAuthorized returns (bool) {

        
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
    
    

    function updateProductInfo(
        string memory _id,
        uint256 _priceInWei,
        uint256 _pledgedFeePercent,
        uint256 _pledgedFeeDivisor,
        uint256 _paymentMode) public 
        returns (bool)
    {

        if(initiatedProduct[_id]._ownerAddress != address(0x0))
        {
            require(msg.sender == initiatedProduct[_id]._ownerAddress, "Product can only be updated by owner only");
        }
        
        uint256 _baseCheckInt = 10 ** 18;
        
        uint256 _ceilInt = 0;
        uint256 _ceilPercent = 100; 
        uint256 _ceilDivisor = 1;
        
        
        uint256 _expectedInt = 0;
        uint256 _actualInt = 0;
        
        
        _ceilInt = _ceilPercent.mul(_baseCheckInt).div(_ceilDivisor.mul(100));
        _expectedInt = baseFeePercent.mul(_baseCheckInt).div(baseFeeDivisor.mul(100));
        _actualInt = _pledgedFeePercent.mul(_baseCheckInt).div(_pledgedFeeDivisor.mul(100));
        
        require(_actualInt >= _expectedInt, "Pledged Fee Should be more than base fee ");
        require(_actualInt < _ceilInt, "Pledged Fee Should be less than 100%");
        
        initiatedProduct[_id]._id = _id;
        initiatedProduct[_id]._priceInWei = _priceInWei;
        initiatedProduct[_id]._ownerAddress = msg.sender;
        initiatedProduct[_id]._pledgedFeePercent = _pledgedFeePercent;
        initiatedProduct[_id]._pledgedFeeDivisor = _pledgedFeeDivisor;
        initiatedProduct[_id]._paymentMode = _paymentMode;
        
        emit ProductInfoUpdated( _id,
         _priceInWei,
         msg.sender,
         _pledgedFeePercent,
         _pledgedFeeDivisor,
         _paymentMode);
        
        return true;
    }
    
    
    
    function purchaseProductViaETH(
        string memory _internalTxId,
        string memory _productId,
        bool _isReferredBuyer
    ) public payable returns (bool){

        
        require(initiatedProductTx[_internalTxId]._ownerAddress == address(0x0),"Transaction already processed");
        
        uint256 _depositedAmt = msg.value;
  
        uint256 _baseRecievableAmt = 0;
        uint256 _baseFeeAmt = 0;
        
        uint256 _adminFeeAmt = 0;
        uint256 _referralFeeAmt = 0;
        
   
        
        
        initiatedProductTx[_internalTxId]._txId = _internalTxId; 
        initiatedProductTx[_internalTxId]._id = _productId; 
        initiatedProductTx[_internalTxId]._paymentMode = 1; // Via Ether
        initiatedProductTx[_internalTxId]._pledgedFeePercent = initiatedProduct[_productId]._pledgedFeePercent; 
        initiatedProductTx[_internalTxId]._pledgedFeeDivisor = initiatedProduct[_productId]._pledgedFeeDivisor; 
        initiatedProductTx[_internalTxId]._ownerAddress = initiatedProduct[_productId]._ownerAddress; 
        
        
        require(initiatedProduct[_productId]._ownerAddress != address(0x0),"Product does not exists");
        
        
        
        require(initiatedProduct[_productId]._priceInWei == _depositedAmt, "Exact Product Price should be provided");
        
        
        
        _baseFeeAmt = initiatedProduct[_productId]._pledgedFeePercent.mul(_depositedAmt).div(initiatedProduct[_productId]._pledgedFeeDivisor.mul(100));
        _baseRecievableAmt = _depositedAmt.sub(_baseFeeAmt);
        
        initiatedProductTx[_internalTxId]._depositedAmt = _depositedAmt;
        initiatedProductTx[_internalTxId]._receivableAmt = _baseRecievableAmt;
        initiatedProductTx[_internalTxId]._feeAmt = _baseFeeAmt;
        
        
        
        

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
        
        
        initiatedProduct[_productId]._ownerAddress.transfer(_baseRecievableAmt);

      
        emit TransactionCompleted(
            initiatedProductTx[_internalTxId]._txId
        );
        
        return true;
    }

    
}