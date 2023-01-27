


pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable {
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract EtherTreasury is Ownable, ReentrancyGuard {

    
    struct TokenMaster {
        uint supply;
        uint dividend;
    }
    
    struct BalanceLedger {
        uint tokenBalance;
        uint referralBalance;
        int payOut;
    }
    
    mapping(address => bool) contractAddressList;
    mapping(address => bool) walletAddressList;
    
    address[] contractAddressSet;
    address[] walletAddressSet;
    
    uint constant magnitude = 1e18 ;
    uint constant initialPrice = 100000000000;
    uint constant incrementPrice = 10000000000;
    uint constant dividendFee = 10;
    
    bool startDeposit = false;
    
    mapping (address => mapping(address => BalanceLedger)) balanceDetails;
    mapping(address => TokenMaster) tokenDetails;
    
    event onPurchase(address walletAddress, address contractAddress, uint incomingTokenAmount, uint collateralMinted, address referredBy);
    event onSell(address walletAddress, address contractAddress, uint tokenAmountToReceiver, uint collateralBurned);
    event onReinvest(address walletAddress, address contractAddress, uint reInvestTokenAmount, uint collateralMinted);
    event onWithdraw(address walletAddress, address contractAddress, uint amountToWithdraw);
    
    function buy(address _referredBy) public nonReentrant payable returns(uint256)
    {

        require(startDeposit);
        require(msg.value>0);
        
        if(contractAddressList[0x0000000000000000000000000000000000000000] == false){
            contractAddressList[0x0000000000000000000000000000000000000000] = true ;
            
            tokenDetails[0x0000000000000000000000000000000000000000].supply = 0;
            tokenDetails[0x0000000000000000000000000000000000000000].dividend = 0;
            
            contractAddressSet.push(0x0000000000000000000000000000000000000000);
        }
        
        if(walletAddressList[msg.sender] == false){
            walletAddressList[msg.sender] = true;
            walletAddressSet.push(msg.sender);
        }
        
        uint256 collateAmount = purchaseCollate(0x0000000000000000000000000000000000000000, msg.value, _referredBy);
        return collateAmount;
    }
    
    function buy(address contractAddress, uint256 tokenAmount, address _referredBy) public nonReentrant returns(uint256)
    {

        require(startDeposit);
        
        require(ERC20(contractAddress).allowance(msg.sender, address(this)) >= tokenAmount);
        require(ERC20(contractAddress).transferFrom(msg.sender, address(this), tokenAmount));
        
        if(contractAddressList[contractAddress]==false){
            contractAddressList[contractAddress]=true ;
            
            tokenDetails[contractAddress].supply = 0;
            tokenDetails[contractAddress].dividend = 0;
            
            contractAddressSet.push(contractAddress);
        }
        
        if(walletAddressList[msg.sender] == false){
            walletAddressList[msg.sender] = true;
            walletAddressSet.push(msg.sender);
        }
        
        uint256 collateAmount = purchaseCollate(contractAddress,tokenAmount, _referredBy);
        return collateAmount;
    }
    
    fallback() nonReentrant payable external
    {
        require(startDeposit);
        require(msg.value > 0);
        if(contractAddressList[0x0000000000000000000000000000000000000000] == false){
            contractAddressList[0x0000000000000000000000000000000000000000] = true ;
            
            tokenDetails[0x0000000000000000000000000000000000000000].supply = 0;
            tokenDetails[0x0000000000000000000000000000000000000000].dividend = 0;
            
            contractAddressSet.push(0x0000000000000000000000000000000000000000);
        }
        
        if(walletAddressList[msg.sender] == false){
            walletAddressList[msg.sender] = true;
            walletAddressSet.push(msg.sender);
        }
        purchaseCollate(0x0000000000000000000000000000000000000000, msg.value, 0x0000000000000000000000000000000000000000);
    }
    
    function reinvest(address contractAddress) public nonReentrant
    {

        uint256 _dividends = myDividends(contractAddress, false); // retrieve ref. bonus later in the code
        
        address _customerAddress = msg.sender;
        balanceDetails[_customerAddress][contractAddress].payOut +=  (int256) (_dividends * magnitude);
        
        _dividends += balanceDetails[_customerAddress][contractAddress].referralBalance;
        
        balanceDetails[_customerAddress][contractAddress].referralBalance = 0;
        
        uint256 _collate = purchaseCollate(contractAddress, _dividends, 0x0000000000000000000000000000000000000000);
        
        emit onReinvest(_customerAddress, contractAddress, _dividends, _collate);
    }
    
    function sellAndwithdraw(address contractAddress) public nonReentrant
    {

        address _customerAddress = msg.sender;
        uint256 _tokens = balanceDetails[_customerAddress][contractAddress].tokenBalance;
        if(_tokens > 0) sell(contractAddress, _tokens);
    
        withdraw(contractAddress);
    }

    function withdraw(address contractAddress) public nonReentrant
    {

        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(contractAddress, false); // get ref. bonus later in the code
        
        balanceDetails[_customerAddress][contractAddress].payOut +=  (int256) (_dividends * magnitude);
        
        _dividends += balanceDetails[_customerAddress][contractAddress].referralBalance;
        balanceDetails[_customerAddress][contractAddress].referralBalance = 0;
        
        if (contractAddress == 0x0000000000000000000000000000000000000000){
            payable(address(_customerAddress)).transfer(_dividends);
        }
        else{
            ERC20(contractAddress).transfer(_customerAddress,_dividends);
        }
        
        
        emit onWithdraw(_customerAddress, contractAddress, _dividends);
    }
    
    function sell(address contractAddress, uint256 _amountOfCollate) public
    {

      
        address _customerAddress = msg.sender;
       
        require(_amountOfCollate <= balanceDetails[_customerAddress][contractAddress].tokenBalance);
        
        uint256 _collates = _amountOfCollate;
        uint256 _tokens = collateralToToken_(contractAddress, _collates);
        uint256 _dividends = SafeMath.div(_tokens, dividendFee);
        uint256 _taxedToken = SafeMath.sub(_tokens, _dividends);
        
        tokenDetails[contractAddress].supply = SafeMath.sub(tokenDetails[contractAddress].supply, _collates);
        balanceDetails[_customerAddress][contractAddress].tokenBalance = SafeMath.sub(balanceDetails[_customerAddress][contractAddress].tokenBalance, _collates);
        
        int256 _updatedPayouts = (int256) (tokenDetails[contractAddress].dividend * _collates + (_taxedToken * magnitude));
        balanceDetails[_customerAddress][contractAddress].payOut -= _updatedPayouts;       
        
        if (tokenDetails[contractAddress].supply > 0) {
            tokenDetails[contractAddress].dividend = SafeMath.add(tokenDetails[contractAddress].dividend, (_dividends * magnitude) / tokenDetails[contractAddress].supply);
        }
        
        emit onSell(_customerAddress, contractAddress, _taxedToken, _collates);
    }
        
    function buyPrice(address contractAddress) public view returns(uint currentBuyPrice) {

        if(tokenDetails[contractAddress].supply == 0){
            return initialPrice + incrementPrice;
        } else {
            uint256 _token = collateralToToken_(contractAddress, 1e18);
            uint256 _dividends = SafeMath.div(_token, dividendFee);
            uint256 _taxedToken = SafeMath.add(_token, _dividends);
            return _taxedToken;
        }
    }
    
    function sellPrice(address contractAddress) public view returns(uint) {

        if(tokenDetails[contractAddress].supply == 0){
            return initialPrice - incrementPrice;
        } else {
            uint256 _token = collateralToToken_(contractAddress, 1e18);
            uint256 _dividends = SafeMath.div(_token, dividendFee);
            uint256 _taxedToken = SafeMath.sub(_token, _dividends);
            return _taxedToken;
        }
    }

    
    function tokentoCollateral_(address contractAddress, uint amount) internal view returns(uint)
    {

        uint256 _tokenPriceInitial = initialPrice * 1e18;
        uint256 tokenSupply_ = tokenDetails[contractAddress].supply;
        uint tokenPriceIncremental_ = incrementPrice;
        
        uint256 _tokensReceived = 
         (
            (
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(amount * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;
  
        return _tokensReceived;
    }
    
    function collateralToToken_(address contractAddress, uint256 _tokens) internal view returns(uint256)
    {


        uint256 tokens_ = _tokens + 1e18 ;
        uint256 _tokenSupply = tokenDetails[contractAddress].supply + 1e18;
        uint256 tokenPriceInitial_ = initialPrice;
        uint tokenPriceIncremental_ = incrementPrice;
        
        uint256 _etherReceived =
        (
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        
        return _etherReceived;
    }
    
    function calculateCollateReceived(address contractAddress, uint256 _tokenAmount) public view returns(uint256)
    {

        uint256 _dividends = SafeMath.div(_tokenAmount, dividendFee);
        uint256 _taxedToken = SafeMath.sub(_tokenAmount, _dividends);
        uint256 _amountOfCollatral = tokentoCollateral_(contractAddress, _taxedToken);
        
        return _amountOfCollatral;
    }
     
    function calculateTokenReceived(address contractAddress, uint256 _collateToSell) public view returns(uint256)
    {

        require(_collateToSell <= tokenDetails[contractAddress].supply);
        uint256 _token = collateralToToken_(contractAddress, _collateToSell);
        uint256 _dividends = SafeMath.div(_token, dividendFee);
        uint256 _taxedToken = SafeMath.sub(_token, _dividends);
        return _taxedToken;
    }  
    
    function purchaseCollate(address contractAddress, uint256 _incomingToken, address _referredBy) internal returns(uint256)
    {

        address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(_incomingToken, dividendFee);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedToken = SafeMath.sub(_incomingToken, _undividedDividends);
        uint256 _amountOfCollate = tokentoCollateral_(contractAddress,_taxedToken);
        uint256 _fee = _dividends * magnitude;
 
      
        require(_amountOfCollate > 0 && (SafeMath.add(_amountOfCollate,tokenDetails[contractAddress].supply) > tokenDetails[contractAddress].supply));
        
        if(
            _referredBy != 0x0000000000000000000000000000000000000000 &&
            
            _referredBy != _customerAddress &&
            
            walletAddressList[_referredBy] == true
        ){
            balanceDetails[_referredBy][contractAddress].referralBalance = SafeMath.add(balanceDetails[_referredBy][contractAddress].referralBalance, _referralBonus);
        } else {
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }
        
        if(tokenDetails[contractAddress].supply > 0){
            
            tokenDetails[contractAddress].supply = SafeMath.add(tokenDetails[contractAddress].supply, _amountOfCollate);
 
            tokenDetails[contractAddress].dividend += (_dividends * magnitude / (tokenDetails[contractAddress].supply));
            
            _fee = _fee - (_fee-(_amountOfCollate * (_dividends * magnitude / (tokenDetails[contractAddress].supply))));
        
        } else {
            tokenDetails[contractAddress].supply = _amountOfCollate;
        }
        
        balanceDetails[_customerAddress][contractAddress].tokenBalance = SafeMath.add(balanceDetails[_customerAddress][contractAddress].tokenBalance, _amountOfCollate);
        
        int256 _updatedPayouts = (int256) ((tokenDetails[contractAddress].dividend * _amountOfCollate) - _fee);
        balanceDetails[_customerAddress][contractAddress].payOut += _updatedPayouts;
        
        emit onPurchase(_customerAddress, contractAddress, _incomingToken, _amountOfCollate, _referredBy);
        
        return _amountOfCollate;
    }
    
    function totalTokenBalance(address contractAddress) public view returns(uint)
    {   

        if (contractAddress== 0x0000000000000000000000000000000000000000){
            return address(this).balance;
        }
        else{
            return ERC20(contractAddress).balanceOf(address(this));
        }
    }
    
    function totalSupply(address contractAddress) public view returns(uint256)
    {

        return tokenDetails[contractAddress].supply;
    }
    
    function myTokens(address contractAddress) public view returns(uint256)
    {

        address _customerAddress = msg.sender;
        return balanceOf(contractAddress, _customerAddress);
    }
    
    function myDividends(address contractAddress, bool _includeReferralBonus) public view returns(uint256)
    {

        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(contractAddress,_customerAddress) + balanceDetails[_customerAddress][contractAddress].referralBalance : dividendsOf(contractAddress, _customerAddress) ;
    }
    
    function balanceOf(address contractAddress, address _customerAddress) view public returns(uint256)
    {

        return balanceDetails[_customerAddress][contractAddress].tokenBalance;
    }
    
    function dividendsOf(address contractAddress, address _customerAddress) view public returns(uint256)
    {

        return (uint256) ((int256)(tokenDetails[contractAddress].dividend * balanceDetails[_customerAddress][contractAddress].tokenBalance) - balanceDetails[_customerAddress][contractAddress].payOut) / magnitude;
    }
    

    function tokenList() public view returns (address [] memory){

        return contractAddressSet;
    }
    
    function walletList() public view returns (address [] memory){

        return walletAddressSet;
    }
    

    function assignUpgradedTokens(address contractAddress, address newContractAddress) public onlyOwner returns(bool success)
    {

        require(contractAddressList[contractAddress]=true, "Contract tokens must be part of system");
        
        if(contractAddressList[newContractAddress]==false)
        {
            contractAddressList[newContractAddress]=true ;
            tokenDetails[newContractAddress].supply = 0;
            tokenDetails[newContractAddress].dividend = 0;
            
            contractAddressSet.push(newContractAddress);
        }
        
        for(uint i = 0; i < walletAddressSet.length; i++)
        {
            if (balanceDetails[walletAddressSet[i]][contractAddress].tokenBalance > 0 || balanceDetails[walletAddressSet[i]][contractAddress].payOut > 0)
            {
                balanceDetails[walletAddressSet[i]][newContractAddress].tokenBalance = balanceDetails[walletAddressSet[i]][contractAddress].tokenBalance;
                balanceDetails[walletAddressSet[i]][newContractAddress].referralBalance = balanceDetails[walletAddressSet[i]][contractAddress].referralBalance;
                balanceDetails[walletAddressSet[i]][newContractAddress].payOut = balanceDetails[walletAddressSet[i]][contractAddress].payOut;
                
            }
        }
        
        tokenDetails[newContractAddress].supply = tokenDetails[contractAddress].supply;
        tokenDetails[newContractAddress].dividend = tokenDetails[contractAddress].dividend;
        
        return true;
    }
    
    
    
    function startContract() public onlyOwner returns(bool status){

        startDeposit = true;
        return true;
    }
    
    function sqrt(uint x) internal pure returns (uint y) {

        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

interface ERC20 {

    function totalSupply() external view returns (uint supply);

    function allowance(address _owner, address _spender) external view returns (uint remaining);

    function approve(address _spender, uint _value) external returns (bool success);

    function balanceOf(address _owner) external view returns (uint balance);

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint _value) external returns (bool success);


    event Approval(address indexed _owner, address indexed _spender,    uint _value);
    event Transfer(address indexed _from, address indexed _to, uint    _value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}