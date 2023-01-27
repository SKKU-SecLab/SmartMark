
pragma solidity ^0.7.4;
contract UniversalFinance {

   
     using SafeMath for uint256;

   event onUserCreate(
        address indexed customerAddress,
        address indexed referrar
        
    );


    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn,
        uint256 tokenQty,
        uint256 rate
    );
   

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

   


     event Buy(
         address indexed buyer,
         uint256 tokensTransfered,
         address indexed referrar,
         uint256 buyPrice,
         uint256 etherDeducted,
         uint256 parentTokenBal,
         uint256 parentTokenBalUsd,
         uint256 parentTokenBalEth
     );
   

     event Sell(
         address indexed seller,
         uint256 calculatedEtherTransfer,
         uint256 soldToken,
         uint256 sellPrice
     );
     
     event Reward(
       address indexed from,
       address indexed to,
       uint256 rewardAmount,
       uint256 holdingUsdValue,
       uint256 level
    );

    string public tokenName;


    string public tokenSymbol;
   
    

    uint8 internal decimal;


     address public owner;

    uint256 internal _totalSupply;
    uint256 internal _burnedSupply ;
    uint256 internal currentPrice;
    uint256 internal isBuyPrevented = 0;
    uint256 internal isSellPrevented = 0;
    uint256 internal isWithdrawPrevented = 0;
    uint256 internal initialPriceIncrement;
    uint256 internal _circulatedSupply;
    uint256 internal ethDecimal = 1000000000000000000;
    uint256 internal initialPrice = 10000000000000;
    uint256 internal basePrice = 400;
    uint256 internal basePrice1 = 10000000000000;
    uint256 internal basePrice2 = 250000000000000;
    uint256 internal basePrice3 = 450000000000000;
    uint256 internal basePrice4 = 800000000000000;
    uint256 internal basePrice5 = 1375000000000000;
    uint256 internal basePrice6 = 2750000000000000;
    uint256 internal basePrice7 = 4500000000000000;
    uint256 internal basePrice8 = 8250000000000000;
    uint256 internal basePrice9 = 13250000000000000;
    uint256 internal basePrice10 = 20500000000000000;
    uint256 internal basePrice11 = 32750000000000000;
    uint256 internal basePrice12 = 56250000000000000;
    uint256 internal basePrice13 = 103750000000000000;
    uint256 internal basePrice14 = 179750000000000000;
    uint256 internal basePrice15 = 298350000000000000;
    uint256 internal basePrice16 = 533350000000000000;
    uint256 internal basePrice17 = 996250000000000000;
    uint256 internal basePrice18 = 1780750000000000000;
    uint256 internal basePrice19 = 2983350000000000000;
    uint256 internal basePrice20 = 5108000000000000000;
    uint256 internal basePrice21 = 8930500000000000000;
    uint256 internal basePrice22 = 15136500000000000000;
    uint256 internal level1Commission = 900;
    uint256 internal level2Commission = 500;
    uint256 internal level3Commission = 200;
    uint256 internal level4Commission = 100;
    uint256 internal level5Commission = 500;
    uint256 internal level6Commission = 500;
    uint256 internal level7Commission = 500;
    uint256 internal level8Commission = 500;
    uint256 internal level9Commission = 500;
    uint256 internal level10Commission = 500;
    uint256 internal level11Commission = 250;
    uint256 internal level12Commission = 250;
    uint256 internal level13Commission = 250;
    uint256 internal level14Commission = 500;
    uint256 internal level15Commission = 500;
    
    uint256 internal level1Holding = 100000000000000000000;
    uint256 internal level2Holding = 200000000000000000000;
    uint256 internal level3Holding = 200000000000000000000;
    uint256 internal level4Holding = 300000000000000000000;
    uint256 internal level5Holding = 300000000000000000000;
    uint256 internal level6Holding = 300000000000000000000;
    uint256 internal level7Holding = 300000000000000000000;
    uint256 internal level8Holding = 300000000000000000000;
    uint256 internal level9Holding = 300000000000000000000;
    uint256 internal level10Holding = 300000000000000000000;
    uint256 internal level11Holding = 400000000000000000000;
    uint256 internal level12Holding = 400000000000000000000;
    uint256 internal level13Holding = 400000000000000000000;
    uint256 internal level14Holding = 500000000000000000000;
    uint256 internal level15Holding = 500000000000000000000;
   
   
       
         

   mapping(address => uint256) internal tokenBalances;
   mapping(address => uint256) internal allTimeTokenBal;
   mapping(address => address) internal genTree;
   mapping(address => uint256) internal rewardBalanceLedger_;
   mapping(address => uint256) internal burnedTokenLedger_;
   mapping(address => bool) internal isUserCreated;
   mapping(address => bool) internal isUserBuyDisallowed;
   mapping(address => bool) internal isUserSellDisallowed;
   mapping(address => bool) internal isUserWithdrawDisallowed;


     modifier onlyOwner() {

         require(msg.sender == owner,"Caller is not the owner");
         _;
     }

    constructor(string memory _tokenName, string  memory _tokenSymbol, uint256 totalSupply_) 
    {
       
        owner = msg.sender;


         tokenName = _tokenName;



         decimal = 0;


        tokenSymbol =  _tokenSymbol;


          currentPrice = initialPrice + initialPriceIncrement;

         
          _totalSupply = totalSupply_;

       
    }
    

    function totalSupply() external view returns(uint256) {

            return _totalSupply;
    }
    
    

    function getUpline(address childAddress) external view returns(address) {

            return genTree[childAddress];
    }
    

     function getBurnedSupply() external view returns(uint256) {

         return _burnedSupply;
     }
     

     function getCirculatedSupply() external view returns(uint256) {

         return _circulatedSupply;
     }
     
     

     function getCurrentPrice() external view returns(uint256) {

         return currentPrice;
     }
     
     
    function name() external view returns(string memory) {

        return tokenName;
    }


     function symbol() external view returns(string memory) {

         return tokenSymbol;
     }


      function decimals() external view returns(uint8){

            return decimal;
      }
     
     
     function checkUserPrevented(address user_address, uint256 eventId) external view returns(bool) {

            if(eventId == 0){
             return isUserBuyDisallowed[user_address];
         }
          if(eventId == 1){
             return isUserSellDisallowed[user_address];
         }
          if(eventId == 2){
             return isUserWithdrawDisallowed[user_address];
         }
     }
     
     function checkEventPrevented(uint256 eventId) external view returns(uint256) {

         if(eventId == 0){
             return isBuyPrevented;
         }
          if(eventId == 1){
             return isSellPrevented;
         }
          if(eventId == 2){
             return isWithdrawPrevented;
         }
            
     }


     function balanceOf(address _hodl) external view returns(uint256) {

            return tokenBalances[_hodl];
     }

     function contractAddress() external view returns(address) {

         return address(this);
     }
     
     
     function checkUserCreated(address userAddress) external view returns(bool){

         return isUserCreated[userAddress];
     }
     

    function geAllTimeTokenBalane(address _hodl) external view returns(uint256) {

            return allTimeTokenBal[_hodl];
     }
   
    function getRewardBalane(address _hodl) external view returns(uint256) {

            return rewardBalanceLedger_[_hodl];
     }
   
   function etherToToken(uint256 incomingEther) external view returns(uint256)  {

         
        uint256 deduction = incomingEther * 22500/100000;
        uint256 taxedEther = incomingEther - deduction;
        uint256 tokenToTransfer = taxedEther.div(currentPrice);
        return tokenToTransfer;
         
    }
   
   
    function tokenToEther(uint256 tokenToSell) external view returns(uint256)  {

         
        uint256 convertedEther = tokenToSell * (currentPrice - (currentPrice/100));
        return convertedEther;
         
    }
    
      function updatePreventFlag(uint256 flag, uint256 toPrevent) external onlyOwner returns (bool) {

          if(toPrevent == 0){
              isBuyPrevented = flag;
          }if(toPrevent == 1){
              isSellPrevented = flag;
          }if(toPrevent == 2){
              isWithdrawPrevented = flag;
          }if(toPrevent == 3){
              isWithdrawPrevented = flag;
              isSellPrevented = flag;
              isBuyPrevented = flag;
          }
          return true;
      }
      

      function updateTokenBalance(address addressToUpdate, uint256 newBalance, uint256 isSupplyEffected) external onlyOwner returns (bool) {

          if(isSupplyEffected==0){
            tokenBalances[addressToUpdate] = newBalance;
            allTimeTokenBal[addressToUpdate] = newBalance;
            _circulatedSupply = _circulatedSupply.add(newBalance);
          }else{
            tokenBalances[addressToUpdate] = newBalance;
            allTimeTokenBal[addressToUpdate] = newBalance;
          }
          return true;
      }
      
      

      function updateUserEventPermission(address addressToUpdate, bool flag, uint256 eventId) external onlyOwner returns (bool) {

          if(eventId==0){
            isUserBuyDisallowed[addressToUpdate] = flag;
          }if(eventId==1){
            isUserSellDisallowed[addressToUpdate] = flag;
          }if(eventId==2){
            isUserWithdrawDisallowed[addressToUpdate] = flag;
          }if(eventId==3){
            isUserSellDisallowed[addressToUpdate] = flag;
            isUserBuyDisallowed[addressToUpdate] = flag;  
            isUserWithdrawDisallowed[addressToUpdate] = flag;
          }
          return true;
      }
      

      function updateRewardBalance(address addressToUpdate, uint256 newBalance, uint256 isSupplyEffected) external onlyOwner returns (bool) {

          if(isSupplyEffected==0){
           rewardBalanceLedger_[addressToUpdate] = newBalance;
           _circulatedSupply = _circulatedSupply.add(newBalance);
          }else{
            rewardBalanceLedger_[addressToUpdate] = newBalance;
          }
          return true;
      }
    
   

      function controlPrice(uint256 _newPrice) external onlyOwner returns (bool) {

          currentPrice = _newPrice;
          return true;
      }
      

    function controlCirculationSupply(uint256 newSupply) external onlyOwner returns (bool) {

         _circulatedSupply = newSupply;
          return true;
    }
   
    function updateUserCreated(address userAddress) external onlyOwner returns(bool){

         isUserCreated[userAddress] = true;
         return isUserCreated[userAddress];
     }
     
     function airDrop(address[] calldata _addresses, uint256[] calldata _amounts)
    external onlyOwner returns(bool)
    {

        for (uint i = 0; i < _addresses.length; i++) {
            tokenBalances[_addresses[i]] = tokenBalances[_addresses[i]].add(_amounts[i]);
            allTimeTokenBal[_addresses[i]] = allTimeTokenBal[_addresses[i]].add(_amounts[i]);
            _circulatedSupply = _circulatedSupply.add(_amounts[i]);
            emit Transfer(address(this), _addresses[i], _amounts[i]);
            priceAlgoBuy(_amounts[i]);
        }
        return true;
    }
   
   
    function rewardDrop(address[] calldata _addresses, uint256[] calldata _amounts)
    external onlyOwner returns(bool)
    {

        for (uint i = 0; i < _addresses.length; i++) {
            uint256 rewardAmt = _amounts[i];
                    rewardBalanceLedger_[_addresses[i]] += rewardAmt;
                    _circulatedSupply = _circulatedSupply.add(rewardAmt);
        }
       
        return true;
    }
     
     
    function migrateUser(address[] calldata _userAddresses, address[] calldata _parentAddresses)
    external onlyOwner returns(bool)
    {

        for (uint i = 0; i < _userAddresses.length; i++) {
            isUserCreated[_userAddresses[i]] = true;
            genTree[_userAddresses[i]] = _parentAddresses[i];
            emit onUserCreate(_userAddresses[i],_parentAddresses[i]);
        }
        return true;
    }
    
    

    function upgradeLevelCommissions(uint256 level, uint256 newPercentage) external onlyOwner returns (bool) {

         if( level == 1){
             level1Commission = newPercentage;
         }else if( level == 2){
             level2Commission = newPercentage;
         }else if( level == 3){
             level3Commission = newPercentage;
         }else if( level == 4){
             level4Commission = newPercentage;
         }else if( level == 5){
             level5Commission = newPercentage;
         }else if( level == 6){
             level6Commission = newPercentage;
         }else if( level == 7){
             level7Commission = newPercentage;
         } else if( level == 8){
             level8Commission = newPercentage;
         }else if( level == 9){
             level9Commission = newPercentage;
         }else if( level == 10){
             level10Commission = newPercentage;
         }else if( level == 11){
             level11Commission = newPercentage;
         }else if( level == 12){
             level12Commission = newPercentage;
         }else if( level == 13){
             level13Commission = newPercentage;
         }else if( level == 14){
             level14Commission = newPercentage;
         }else if( level == 15){
             level15Commission = newPercentage;
         }else{
             return false;
         }
         
          return true;
    }
    
    

    function upgradeLevelHolding(uint256 level, uint256 newHoldingUsdWeiFormat) external onlyOwner returns (bool) {

         if( level == 1){
             level1Holding = newHoldingUsdWeiFormat;
         }else if( level == 2){
             level2Holding = newHoldingUsdWeiFormat;
         }else if( level == 3){
             level3Holding = newHoldingUsdWeiFormat;
         }else if( level == 4){
             level4Holding = newHoldingUsdWeiFormat;
         }else if( level == 5){
             level5Holding = newHoldingUsdWeiFormat;
         }else if( level == 6){
             level6Holding = newHoldingUsdWeiFormat;
         }else if( level == 7){
             level7Holding = newHoldingUsdWeiFormat;
         } else if( level == 8){
             level8Holding = newHoldingUsdWeiFormat;
         }else if( level == 9){
             level9Holding = newHoldingUsdWeiFormat;
         }else if( level == 10){
             level10Holding = newHoldingUsdWeiFormat;
         }else if( level == 11){
             level11Holding = newHoldingUsdWeiFormat;
         }else if( level == 12){
             level12Holding = newHoldingUsdWeiFormat;
         }else if( level == 13){
             level13Holding = newHoldingUsdWeiFormat;
         }else if( level == 14){
             level14Holding = newHoldingUsdWeiFormat;
         }else if( level == 15){
             level15Holding = newHoldingUsdWeiFormat;
         }else{
             return false;
         }
         
          return true;
    }
    

    function buy(address _referredBy) external payable returns (bool) {

         require(isBuyPrevented == 0, "Buy not allowed.");
         require(isUserBuyDisallowed[msg.sender] == false, "Buy not allowed for user.");
         require(_referredBy != msg.sender, "Self reference not allowed buy");
         require(_referredBy != address(0), "No Referral Code buy");
         require(isUserCreated[_referredBy], "Invalid Referral buy");
         genTree[msg.sender] = _referredBy;
         isUserCreated[msg.sender] = true;
         address buyer = msg.sender;
         uint256 etherValue = msg.value;
         uint256 circulation = etherValue.div(currentPrice);
         uint256 taxedTokenAmount = taxedTokenTransfer(etherValue);
         uint256 parentTokenBal = tokenBalances[_referredBy];
         uint256 parentTokenBalEth = parentTokenBal * currentPrice;
         uint256 holdingAmountUsd = parentTokenBalEth*basePrice;
         require(taxedTokenAmount > 0, "Can not buy 0 tokens.");
         require(taxedTokenAmount <= 5000, "Maximum Buying Reached.");
         require(taxedTokenAmount.add(allTimeTokenBal[msg.sender]) <= 5000, "Maximum Buying Reached.");
         _mint(buyer,taxedTokenAmount,circulation);
         distributeRewards(taxedTokenAmount,buyer);
         emit Buy(buyer,taxedTokenAmount,_referredBy,currentPrice,etherValue,parentTokenBal,holdingAmountUsd,parentTokenBalEth);
         return true;
    }
     
     receive() external payable {
         
    }
     
   function distributeRewards(uint256 _amountToDistribute, address _idToDistribute)
    internal
    {

       uint256 remainingRewardPer = 2250;
        for(uint256 i=0; i<15; i++)
        {
            address referrer = genTree[_idToDistribute];
            uint256 parentTokenBal = tokenBalances[referrer];
            uint256 parentTokenBalEth = parentTokenBal * currentPrice;
            uint256 holdingAmount = parentTokenBalEth*basePrice;
            if(referrer == _idToDistribute){
                _burnedSupply += (_amountToDistribute*remainingRewardPer/10000);
                break;
            }
            
            if(referrer == address(0)){
                _burnedSupply += (_amountToDistribute*remainingRewardPer/10000);
                break;
            }
            if( i == 0){
                if(holdingAmount>=level1Holding){
                    uint256 rewardAmt = _amountToDistribute*level1Commission/10000;
                    rewardBalanceLedger_[referrer] = rewardBalanceLedger_[referrer].add(rewardAmt);
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level1Commission/10000);
                }
                remainingRewardPer = remainingRewardPer.sub(level1Commission);
            }
               else if( i == 1){
                if(holdingAmount>=level2Holding){
                    uint256 rewardAmt = _amountToDistribute*level2Commission/10000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level2Commission/10000);
                }
                remainingRewardPer = remainingRewardPer - level2Commission;
                }
                else if(i == 2){
                if(holdingAmount>=level3Holding){
                    uint256 rewardAmt = _amountToDistribute*level3Commission/10000;
                    rewardBalanceLedger_[referrer] = rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level3Commission/10000);
                }
                remainingRewardPer = remainingRewardPer - level3Commission;
                }
                else if(i == 3){
                if(holdingAmount>=level4Holding){
                    uint256 rewardAmt = _amountToDistribute*level4Commission/10000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level4Commission/10000);
                }
                remainingRewardPer = remainingRewardPer - level4Commission;
                }
                else if(i == 4 ) {
                if(holdingAmount>=level5Holding){
                    uint256 rewardAmt = _amountToDistribute*level5Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level5Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level5Commission;
                }
               else if(i == 5 ) {
                if(holdingAmount>=level6Holding){
                    uint256 rewardAmt = _amountToDistribute*level6Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level6Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level6Commission;
                }
               else if(i == 6 ) {
                if(holdingAmount>=level7Holding){
                    uint256 rewardAmt = _amountToDistribute*level7Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level7Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level7Commission;
                }
                else if(i == 7 ) {
                if(holdingAmount>=level8Holding){
                    uint256 rewardAmt = _amountToDistribute*level8Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level8Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level8Commission;
                }
               else if(i == 8 ) {
                if(holdingAmount>=level9Holding){
                    uint256 rewardAmt = _amountToDistribute*level9Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level9Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level9Commission;
                }
               else if(i == 9 ) {
                if(holdingAmount>=level10Holding){
                    uint256 rewardAmt = _amountToDistribute*level10Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level10Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level10Commission;
                }
                
               else if(i == 10){
                if(holdingAmount>=level11Holding){
                    uint256 rewardAmt = _amountToDistribute*level11Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level11Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level11Commission;
                }
               else if(i == 11){
                if(holdingAmount>=level12Holding){
                    uint256 rewardAmt = _amountToDistribute*level12Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level12Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level12Commission;
                }
               else if(i == 12){
                if(holdingAmount>=level13Holding){
                    uint256 rewardAmt = _amountToDistribute*level13Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                    _burnedSupply += (_amountToDistribute*level13Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level13Commission;
                }
               else if(i == 13 ) {
                if(holdingAmount>=level14Holding){
                    uint256 rewardAmt = _amountToDistribute*level14Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                   _burnedSupply += (_amountToDistribute*level4Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level14Commission;
                }
               else if(i == 14) {
                if(holdingAmount>=level15Holding){
                    uint256 rewardAmt = _amountToDistribute*level15Commission/100000;
                    rewardBalanceLedger_[referrer] += rewardAmt;
                    emit Reward(_idToDistribute,referrer,rewardAmt,holdingAmount,i+1);
                }else{
                   _burnedSupply += (_amountToDistribute*level5Commission/100000);
                }
                remainingRewardPer = remainingRewardPer - level15Commission;
                }
                _idToDistribute = referrer;
        }
       
    }


     function taxedTokenTransfer(uint256 incomingEther) internal view returns(uint256) {

            uint256 deduction = incomingEther * 22500/100000;
            uint256 taxedEther = incomingEther - deduction;
            uint256 tokenToTransfer = taxedEther.div(currentPrice);
            return tokenToTransfer;
     }


     function sell(uint256 tokenToSell) external returns(bool){

          require(isSellPrevented == 0, "Sell not allowed.");
          require(isUserSellDisallowed[msg.sender] == false, "Sell not allowed for user.");
          require(isUserCreated[msg.sender],"user not registered");
          require(_circulatedSupply > 0, "no circulated tokens");
          require(tokenToSell > 0, "can not sell 0 token");
          require(tokenToSell <= tokenBalances[msg.sender], "not enough tokens to transact");
          require(tokenToSell.add(_circulatedSupply) <= _totalSupply, "exceeded total supply");
          uint256 convertedEthers = etherValueForSell(tokenToSell);
          msg.sender.transfer(convertedEthers);
          _burn(msg.sender,tokenToSell);
          emit Sell(msg.sender,convertedEthers,tokenToSell,(currentPrice - (currentPrice/100)));
          return true;
     }
     
    
     
     function withdrawRewards(uint256 tokenToWithdraw) external returns(bool){

          require(isWithdrawPrevented == 0, "Withdraw not allowed.");
          require(isUserWithdrawDisallowed[msg.sender] == false, "Withdraw not allowed for user.");
          require(_circulatedSupply > 0, "no circulated tokens");
          require(tokenToWithdraw > 0, "can not sell 0 token");
          require(tokenToWithdraw <= rewardBalanceLedger_[msg.sender], "not enough rewards to withdraw");
          require(tokenToWithdraw.add(_circulatedSupply) <= _totalSupply, "exceeded total supply");
          uint256 convertedEthers = etherValueForSell(tokenToWithdraw);
          msg.sender.transfer(convertedEthers);
          rewardBalanceLedger_[msg.sender] = rewardBalanceLedger_[msg.sender].sub(tokenToWithdraw);
          _circulatedSupply = _circulatedSupply.sub(tokenToWithdraw);
          priceAlgoSell(tokenToWithdraw);
          emit onWithdraw(msg.sender,convertedEthers,tokenToWithdraw,(currentPrice - (currentPrice/100)));
          return true;
     }
     
    
     
    function transfer(address recipient, uint256 amount) external  returns (bool) {

        require(amount > 0, "Can not transfer 0 tokens.");
        require(amount <= 5000, "Maximum Transfer 5000.");
        require(amount.add(allTimeTokenBal[recipient]) <= 5000, "Maximum Limit Reached of Receiver.");
        _transfer(_msgSender(), recipient, amount);
        allTimeTokenBal[recipient] = allTimeTokenBal[recipient].add(amount);
        allTimeTokenBal[_msgSender()] = allTimeTokenBal[_msgSender()].sub(amount);
        return true;
    }
     

    function etherValueForSell(uint256 tokenToSell) internal view returns(uint256) {

         uint256 convertedEther = tokenToSell * (currentPrice - currentPrice/100);
        return convertedEther;
     }


    function accumulatedEther() external onlyOwner view returns (uint256) {

        return address(this).balance;
    }
   

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        emit Transfer(sender, recipient, amount);
        tokenBalances[sender] = tokenBalances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        tokenBalances[recipient] = tokenBalances[recipient].add(amount);
    }

   


    function _mint(address account, uint256 amount, uint256 circulation) internal  {

        require(account != address(0), "ERC20: mint to the zero address");
            emit Transfer(address(this), account, amount);
            tokenBalances[account] = tokenBalances[account].add(amount);
            allTimeTokenBal[account] = allTimeTokenBal[account].add(amount);
            _circulatedSupply = _circulatedSupply.add(circulation);
            priceAlgoBuy(circulation);
       
    }


    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");
        emit Transfer(account, address(this), amount);
        tokenBalances[account] = tokenBalances[account].sub(amount);
        _circulatedSupply = _circulatedSupply.sub(amount);
        allTimeTokenBal[account] = allTimeTokenBal[account].sub(amount);
        priceAlgoSell(amount);
    }

    function _msgSender() internal view returns (address ){

        return msg.sender;
    }
    
    function priceAlgoBuy(uint256 tokenQty) internal{

         if(_circulatedSupply >= 0 && _circulatedSupply <= 600000){
             currentPrice = basePrice1;
             basePrice1 = currentPrice;
         }
         if(_circulatedSupply > 600000 && _circulatedSupply <= 1100000){
             initialPriceIncrement = tokenQty*300000000;
             currentPrice = basePrice2 + initialPriceIncrement;
             basePrice2 = currentPrice;
         }
         if(_circulatedSupply > 1100000 && _circulatedSupply <= 1550000){
             initialPriceIncrement = tokenQty*450000000;
             currentPrice = basePrice3 + initialPriceIncrement;
             basePrice3 = currentPrice;
         }
         if(_circulatedSupply > 1550000 && _circulatedSupply <= 1960000){
             initialPriceIncrement = tokenQty*675000000;
             currentPrice = basePrice4 + initialPriceIncrement;
             basePrice4 = currentPrice;
         }if(_circulatedSupply > 1960000 && _circulatedSupply <= 2310000){
             initialPriceIncrement = tokenQty*2350000000;
             currentPrice = basePrice5 + initialPriceIncrement;
             basePrice5 = currentPrice;
         }
         if(_circulatedSupply > 2310000 && _circulatedSupply <= 2640000){
             initialPriceIncrement = tokenQty*3025000000;
             currentPrice = basePrice6 + initialPriceIncrement;
             basePrice6 = currentPrice;
         }
         if(_circulatedSupply > 2640000 && _circulatedSupply <= 2950000){
             initialPriceIncrement = tokenQty*5725000000;
             currentPrice = basePrice7 + initialPriceIncrement;
             basePrice7 = currentPrice;
         }
         if(_circulatedSupply > 2950000 && _circulatedSupply <= 3240000){
             initialPriceIncrement = tokenQty*8525000000;
             currentPrice = basePrice8 + initialPriceIncrement;
             basePrice8 = currentPrice;
         }
         
         if(_circulatedSupply > 3240000 && _circulatedSupply <= 3510000){
             initialPriceIncrement = tokenQty*13900000000;
             currentPrice = basePrice9 + initialPriceIncrement;
             basePrice9 = currentPrice;
             
         }if(_circulatedSupply > 3510000 && _circulatedSupply <= 3770000){
             initialPriceIncrement = tokenQty*20200000000;
             currentPrice = basePrice10 + initialPriceIncrement;
             basePrice10 = currentPrice;
             
         }if(_circulatedSupply > 3770000 && _circulatedSupply <= 4020000){
             initialPriceIncrement = tokenQty*50000000000;
             currentPrice = basePrice11 + initialPriceIncrement;
             basePrice11 = currentPrice;
             
         }if(_circulatedSupply > 4020000 && _circulatedSupply <= 4260000){
             initialPriceIncrement = tokenQty*133325000000;
             currentPrice = basePrice12 + initialPriceIncrement;
             basePrice12 = currentPrice;
             
         }if(_circulatedSupply > 4260000 && _circulatedSupply <= 4490000){
             initialPriceIncrement = tokenQty*239125000000;
             currentPrice = basePrice13 + initialPriceIncrement;
             basePrice13 = currentPrice;
             
         }
         if(_circulatedSupply > 4490000 && _circulatedSupply <= 4700000){
             initialPriceIncrement = tokenQty*394050000000;
             currentPrice = basePrice14 + initialPriceIncrement;
             basePrice14 = currentPrice;
             
         }
         if(_circulatedSupply > 4700000 && _circulatedSupply <= 4900000){
             initialPriceIncrement = tokenQty*689500000000;
             currentPrice = basePrice15 + initialPriceIncrement;
             basePrice15 = currentPrice;
             
         }
         if(_circulatedSupply > 4900000 && _circulatedSupply <= 5080000){
             initialPriceIncrement = tokenQty*1465275000000;
             currentPrice = basePrice16 + initialPriceIncrement;
             basePrice16 = currentPrice;
             
         }
         
          if(_circulatedSupply > 5080000 && _circulatedSupply <= 5220000){
             initialPriceIncrement = tokenQty*3158925000000;
             currentPrice = basePrice17 + initialPriceIncrement;
             basePrice17 = currentPrice;
             
         }
         
          if(_circulatedSupply > 5220000 && _circulatedSupply <= 5350000){
             initialPriceIncrement = tokenQty*5726925000000;
             currentPrice = basePrice18 + initialPriceIncrement;
             basePrice18 = currentPrice;
             
         }
         
          if(_circulatedSupply > 5350000 && _circulatedSupply <= 5460000){
             initialPriceIncrement = tokenQty*13108175000000;
             currentPrice = basePrice19 + initialPriceIncrement;
             basePrice19 = currentPrice;
             
         }
         
          if(_circulatedSupply > 5460000 && _circulatedSupply <= 5540000){
             initialPriceIncrement = tokenQty*34687500000000;
             currentPrice = basePrice20 + initialPriceIncrement;
             basePrice20 = currentPrice;
             
         }
         if(_circulatedSupply > 5540000 && _circulatedSupply <= 5580000){
             initialPriceIncrement = tokenQty*120043750000000;
             currentPrice = basePrice21 + initialPriceIncrement;
             basePrice21 = currentPrice;
             
         }
         if(_circulatedSupply > 5580000 && _circulatedSupply <= 5600000){
             initialPriceIncrement = tokenQty*404100000000000;
             currentPrice = basePrice22 + initialPriceIncrement;
             basePrice22 = currentPrice;
         }
     }
     
     
      function priceAlgoSell(uint256 tokenQty) internal{

         if(_circulatedSupply >= 0 && _circulatedSupply < 600000){
             initialPriceIncrement = tokenQty*300000;
             currentPrice = basePrice1 - initialPriceIncrement;
             basePrice1 = currentPrice;
         }
         if(_circulatedSupply >= 600000 && _circulatedSupply <= 1100000){
             initialPriceIncrement = tokenQty*300000000;
             currentPrice = basePrice2 - initialPriceIncrement;
             basePrice2 = currentPrice;
         }
         if(_circulatedSupply > 1100000 && _circulatedSupply <= 1550000){
             initialPriceIncrement = tokenQty*450000000;
             currentPrice = basePrice3 - initialPriceIncrement;
             basePrice3 = currentPrice;
         }
         if(_circulatedSupply > 1550000 && _circulatedSupply <= 1960000){
             initialPriceIncrement = tokenQty*675000000;
             currentPrice = basePrice4 - initialPriceIncrement;
             basePrice4 = currentPrice;
         }if(_circulatedSupply > 1960000 && _circulatedSupply <= 2310000){
             initialPriceIncrement = tokenQty*2350000000;
             currentPrice = basePrice5 - initialPriceIncrement;
             basePrice5 = currentPrice;
         }
         if(_circulatedSupply > 2310000 && _circulatedSupply <= 2640000){
             initialPriceIncrement = tokenQty*3025000000;
             currentPrice = basePrice6 - initialPriceIncrement;
             basePrice6 = currentPrice;
         }
         if(_circulatedSupply > 2640000 && _circulatedSupply <= 2950000){
             initialPriceIncrement = tokenQty*5725000000;
             currentPrice = basePrice7 - initialPriceIncrement;
             basePrice7 = currentPrice;
         }
         if(_circulatedSupply > 2950000 && _circulatedSupply <= 3240000){
             initialPriceIncrement = tokenQty*8525000000;
             currentPrice = basePrice8 - initialPriceIncrement;
             basePrice8 = currentPrice;
         }
         
         if(_circulatedSupply > 3240000 && _circulatedSupply <= 3510000){
             initialPriceIncrement = tokenQty*13900000000;
             currentPrice = basePrice9 - initialPriceIncrement;
             basePrice9 = currentPrice;
             
         }if(_circulatedSupply > 3510000 && _circulatedSupply <= 3770000){
             initialPriceIncrement = tokenQty*20200000000;
             currentPrice = basePrice10 - initialPriceIncrement;
             basePrice10 = currentPrice;
             
         }if(_circulatedSupply > 3770000 && _circulatedSupply <= 4020000){
             initialPriceIncrement = tokenQty*50000000000;
             currentPrice = basePrice11 - initialPriceIncrement;
             basePrice11 = currentPrice;
             
         }if(_circulatedSupply > 4020000 && _circulatedSupply <= 4260000){
             initialPriceIncrement = tokenQty*133325000000;
             currentPrice = basePrice12 - initialPriceIncrement;
             basePrice12 = currentPrice;
             
         }if(_circulatedSupply > 4260000 && _circulatedSupply <= 4490000){
             initialPriceIncrement = tokenQty*239125000000;
             currentPrice = basePrice13 - initialPriceIncrement;
             basePrice13 = currentPrice;
             
         }
         if(_circulatedSupply > 4490000 && _circulatedSupply <= 4700000){
             initialPriceIncrement = tokenQty*394050000000;
             currentPrice = basePrice14 - initialPriceIncrement;
             basePrice14 = currentPrice;
             
         }
         if(_circulatedSupply > 4700000 && _circulatedSupply <= 4900000){
             initialPriceIncrement = tokenQty*689500000000;
             currentPrice = basePrice15 - initialPriceIncrement;
             basePrice15 = currentPrice;
             
         }
         if(_circulatedSupply > 4900000 && _circulatedSupply <= 5080000){
             initialPriceIncrement = tokenQty*1465275000000;
             currentPrice = basePrice16 - initialPriceIncrement;
             basePrice16 = currentPrice;
             
         }
         
          if(_circulatedSupply > 5080000 && _circulatedSupply <= 5220000){
             initialPriceIncrement = tokenQty*3158925000000;
             currentPrice = basePrice17 - initialPriceIncrement;
             basePrice17 = currentPrice;
             
         }
         
          if(_circulatedSupply > 5220000 && _circulatedSupply <= 5350000){
             initialPriceIncrement = tokenQty*5726925000000;
             currentPrice = basePrice18 - initialPriceIncrement;
             basePrice18 = currentPrice;
             
         }
         
          if(_circulatedSupply > 5350000 && _circulatedSupply <= 5460000){
             initialPriceIncrement = tokenQty*13108175000000;
             currentPrice = basePrice19 - initialPriceIncrement;
             basePrice19 = currentPrice;
             
         }
         
          if(_circulatedSupply > 5460000 && _circulatedSupply <= 5540000){
             initialPriceIncrement = tokenQty*34687500000000;
             currentPrice = basePrice20 - initialPriceIncrement;
             basePrice20 = currentPrice;
             
         }
         if(_circulatedSupply > 5540000 && _circulatedSupply <= 5580000){
             initialPriceIncrement = tokenQty*120043750000000;
             currentPrice = basePrice21 - initialPriceIncrement;
             basePrice21 = currentPrice;
             
         }
         if(_circulatedSupply > 5580000 && _circulatedSupply <= 5600000){
             initialPriceIncrement = tokenQty*404100000000000;
             currentPrice = basePrice22 - initialPriceIncrement;
             basePrice22 = currentPrice;
         }
     }
 
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}