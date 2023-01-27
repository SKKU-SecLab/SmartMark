
pragma solidity ^0.4.19;

 
contract IToken {

   
  function balanceOf(address _address) constant returns (uint balance);

  function transferFromOwner(address _to, uint256 _value) returns (bool success);

}

contract TokenEscrow {

	string public standard = 'FractalPreRelease 1.0';
	string public name = 'FractalPreReleaseToken';
	string public symbol = 'FPRT';
	uint public decimals = 4;
    uint public totalSupply = 50000000000;
   
	
	IToken icoToken;
	
	event Converted(address indexed from, uint256 value); // Event to inform about the fact of token burning/destroying
    	event Transfer(address indexed from, address indexed to, uint256 value);
	event Error(bytes32 error);
	
	mapping (address => uint) balanceFor; // Presale token balance for each of holders
	
	address owner;  // Contract owner
	
	uint public exchangeRate; // preICO -> ICO token exchange rate

	struct TokenSupply {
		uint limit;                 // Total amount of tokens
		uint totalSupply;           // Current amount of sold tokens
		uint tokenPriceInWei;  // Number of token per 1 Eth
		
	}
	
	TokenSupply[3] public tokenSupplies;

	modifier owneronly { if (msg.sender == owner) _; }


	function setOwner(address _owner) owneronly {

		owner = _owner;
	}
	
	function setRate(uint _exchangeRate) owneronly {

		exchangeRate = _exchangeRate;
	}
	
	function setToken(address _icoToken) owneronly {

		icoToken = IToken(_icoToken);
	}
	
	function balanceOf(address _address) constant returns (uint balance) {

		return balanceFor[_address];
	}
	
	function transfer(address _to, uint _value) returns (bool success) {

		if(_to != owner) {
			if (balanceFor[msg.sender] < _value) return false;           // Check if the sender has enough
			if (balanceFor[_to] + _value < balanceFor[_to]) return false; // Check for overflows
			if (msg.sender == owner) {
				transferByOwner(_value);
			}
			balanceFor[msg.sender] -= _value;                     // Subtract from the sender
			balanceFor[_to] += _value;                            // Add the same to the recipient
			Transfer(owner,_to,_value);
			return true;
		}
		return false;
	}
	
	function transferByOwner(uint _value) private {

		for (uint discountIndex = 0; discountIndex < tokenSupplies.length; discountIndex++) {
			TokenSupply storage tokenSupply = tokenSupplies[discountIndex];
			if(tokenSupply.totalSupply < tokenSupply.limit) {
				if (tokenSupply.totalSupply + _value > tokenSupply.limit) {
					_value -= tokenSupply.limit - tokenSupply.totalSupply;
					tokenSupply.totalSupply = tokenSupply.limit;
				} else {
					tokenSupply.totalSupply += _value;
					break;
				}
			}
		}
	}
	
	function convert() returns (bool success) {

		if (balanceFor[msg.sender] == 0) return false;            // Check if the sender has enough
		if (!exchangeToIco(msg.sender)) return false; // Try to exchange preICO tokens to ICO tokens
		Converted(msg.sender, balanceFor[msg.sender]);
		balanceFor[msg.sender] = 0;                      // Subtract from the sender
		return true;
	} 
	
	function exchangeToIco(address owner) private returns (bool) {

	    if(icoToken != address(0)) {
		    return icoToken.transferFromOwner(owner, balanceFor[owner] * exchangeRate);
	    }
	    return false;
	}

	function TokenEscrow() {

		owner = msg.sender;
		
		balanceFor[msg.sender] = 50000000000; // Give the creator all initial tokens
		
		tokenSupplies[0] = TokenSupply(10000000000, 0, 50000000000); // First million of tokens will go 2000 tokens for 1 eth
		tokenSupplies[1] = TokenSupply(20000000000, 0, 50000000000); // Following Two millions of tokens will go 2000 tokens for 1 eth
		tokenSupplies[2] = TokenSupply(20000000000, 0, 50000000000); // Two last millions of tokens will go 2000 tokens for 1 eth
	    
}


	function() payable {
		
		uint tokenAmount; // Amount of tokens which is possible to buy for incoming transfer/payment
		uint amountToBePaid; // Amount to be paid
		uint amountTransfered = msg.value; // Cost/price in WEI of incoming transfer/payment
		
		
		if (amountTransfered <= 0) {
		      	Error('no eth was transfered');
              		msg.sender.transfer(msg.value);
		  	return;
		}

		if(balanceFor[owner] <= 0) {
		      	Error('all tokens sold');
              		msg.sender.transfer(msg.value);
		      	return;
		}
		
		for (uint discountIndex = 0; discountIndex < tokenSupplies.length; discountIndex++) {
			
			TokenSupply storage tokenSupply = tokenSupplies[discountIndex];
			
			if(tokenSupply.totalSupply < tokenSupply.limit) {
			
				uint tokensPossibleToBuy = amountTransfered / tokenSupply.tokenPriceInWei;

                if (tokensPossibleToBuy > balanceFor[owner]) 
                    tokensPossibleToBuy = balanceFor[owner];

				if (tokenSupply.totalSupply + tokensPossibleToBuy > tokenSupply.limit) {
					tokensPossibleToBuy = tokenSupply.limit - tokenSupply.totalSupply;
				}

				tokenSupply.totalSupply += tokensPossibleToBuy;
				tokenAmount += tokensPossibleToBuy;

				uint delta = tokensPossibleToBuy * tokenSupply.tokenPriceInWei;

				amountToBePaid += delta;
                		amountTransfered -= delta;
			
			}
		}
		
		if (tokenAmount == 0) {
		    	Error('no token to buy');
            		msg.sender.transfer(msg.value);
			return;
        	}
		
		transferFromOwner(msg.sender, tokenAmount);

		owner.transfer(amountToBePaid);
		
		msg.sender.transfer(msg.value - amountToBePaid);
		
	}
  
	function kill() owneronly {

		selfdestruct(msg.sender);
	}
	
  
	function transferFromOwner(address _to, uint256 _value) private returns (bool success) {

		if (balanceFor[owner] < _value) return false;                 // Check if the owner has enough
		if (balanceFor[_to] + _value < balanceFor[_to]) return false;  // Check for overflows
		balanceFor[owner] -= _value;                          // Subtract from the owner
		balanceFor[_to] += _value;                            // Add the same to the recipient
        	Transfer(owner,_to,_value);
		return true;
	}
  
}