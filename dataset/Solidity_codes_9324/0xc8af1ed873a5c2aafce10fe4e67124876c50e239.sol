
pragma solidity ^0.4.11;

contract ERC20 {

	function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

}

contract P2PFuturesTrading {


	struct Trade{
		address tokenAddress;
		uint tokenAmount;
		uint etherAmount;
		uint etherCollateralAmount;
		uint endTradeBlock;
		bool initialized;
		bool finalized;
	}


	mapping (address => mapping(address => Trade)) public trades;

	address developerAddress = 0x335854eF79Fff47F9050ca853c7f3bA53eeEEE93;



	function startTrade(address tokenSellerAddress, address tokenAddress, uint tokenAmount, uint etherCollateralAmount, uint endTradeBlock) payable{

		if(msg.value == 0 || tokenAmount == 0 || endTradeBlock <= block.number + 220){
			throw;
		}
		
		Trade t1 = trades[msg.sender][tokenSellerAddress];
		Trade t2 = trades[tokenSellerAddress][msg.sender];
		
		if(t1.initialized || t2.initialized){
			throw;
		}

		trades[msg.sender][tokenSellerAddress] = Trade(tokenAddress, tokenAmount, msg.value, etherCollateralAmount, endTradeBlock, true, false);
	}



	function finalizeTrade(address tokenBuyerAddress, uint etherAmount, address tokenAddress, uint tokenAmount, uint endTradeBlock) payable{

		Trade t = trades[tokenBuyerAddress][msg.sender];
		
		if(!t.initialized || t.finalized){
			throw;
		}
		
		if(!(t.tokenAddress == tokenAddress && t.tokenAmount == tokenAmount && t.etherAmount == etherAmount && t.etherCollateralAmount == msg.value && t.endTradeBlock == endTradeBlock)){
			throw;
		}
		
		t.finalized = true;
	}

	 
	function completeTrade(address otherPersonAddress){

	    Trade t;
		address tokenBuyerAddress;
		address tokenSellerAddress;
		
		Trade tokenBuyerTrade = trades[msg.sender][otherPersonAddress];
		Trade tokenSellerTrade = trades[otherPersonAddress][msg.sender];
		
		if(tokenBuyerTrade.initialized && tokenBuyerTrade.finalized){
			t = tokenBuyerTrade;
			tokenBuyerAddress = msg.sender;
			tokenSellerAddress = otherPersonAddress;
		}
		else if(tokenSellerTrade.initialized && tokenSellerTrade.finalized){
			t = tokenSellerTrade;
			tokenBuyerAddress = otherPersonAddress;
			tokenSellerAddress = msg.sender;
		}
		else{
			throw;
		}
		
		
		ERC20 token = ERC20(t.tokenAddress);
		
		uint tokenSellerFee = t.tokenAmount * 5 / 1000;
		uint tokenBuyerFee = t.etherAmount * 5 / 1000;
		uint collateralFee = t.etherCollateralAmount / 100;
		
		t.initialized = false;
		t.finalized = false;
		
		if(!token.transferFrom(tokenSellerAddress, tokenBuyerAddress, t.tokenAmount - tokenSellerFee) || !token.transferFrom(tokenSellerAddress, developerAddress, tokenSellerFee)){
			if(t.endTradeBlock < block.number){
				tokenBuyerAddress.transfer(t.etherAmount + t.etherCollateralAmount - collateralFee);
				developerAddress.transfer(collateralFee);
				
				return;
			}
			else{
				throw;
			}
		}
		
		tokenSellerAddress.transfer(t.etherAmount + t.etherCollateralAmount - tokenBuyerFee);
		developerAddress.transfer(tokenBuyerFee);
    }
    
    
	function cancelTrade(address tokenSellerAddress){

		Trade t = trades[msg.sender][tokenSellerAddress];
		
		if(!t.initialized || t.finalized){
			throw;
		}
		
		t.initialized = false;
		
		msg.sender.transfer(t.etherAmount);
	}
}