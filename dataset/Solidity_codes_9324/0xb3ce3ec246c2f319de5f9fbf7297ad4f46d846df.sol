
pragma solidity ^0.4.19;


contract EtherDelta {

    function balanceOf(address tokenAddress, address userAddress) public view returns (uint);

}

contract WETH_0x {

    function balanceOf(address userAddress) public view returns (uint);

}

contract Token {

    function balanceOf(address tokenOwner) public view returns (uint /*balance*/);

    function transfer(address toAddress, uint tokens) public returns (bool /*success*/);

}

contract BancorConverter {

    function getReturn(address fromToken, address toToken, uint amount) public constant returns (uint /*expectedReturn*/);

}

contract BalanceChecker {

	
	address public admin; 

	function BalanceChecker() public {

        admin = 0x00cdE0b7CfC51041FE62B08E6C45c59aE5109650; // in case of deploy using MEW with no arguments
	}

	function() public payable {
		revert();
	}
	
    modifier isAdmin() {

        require(msg.sender == admin);
	     _;
    }
    
	function destruct() public isAdmin {

		selfdestruct(admin);
	}

	function withdraw() public isAdmin {

    	admin.transfer(this.balance);
	}

	function withdrawToken(address token, uint amount) public isAdmin {

    	require(token != address(0x0)); //use withdraw for ETH
    	require(Token(token).transfer(msg.sender, amount));
	}
  
	function deltaBalances(address exchange, address user,  address[] tokens) public view returns (uint[]) {

		EtherDelta ex = EtherDelta(exchange);
	    uint[] memory balances = new uint[](tokens.length);
	    
		for(uint i = 0; i< tokens.length; i++){
			balances[i] = ex.balanceOf(tokens[i], user);
		}	
		return balances;
	}
	
	function multiDeltaBalances(address[] exchanges, address user,  address[] tokens) public view returns (uint[]) {

	    uint[] memory balances = new uint[](tokens.length * exchanges.length);
	    
	    for(uint i = 0; i < exchanges.length; i++){
			EtherDelta ex = EtherDelta(exchanges[i]);
			
    		for(uint j = 0; j< tokens.length; j++){
    		    
    			balances[(j * exchanges.length) + i] = ex.balanceOf(tokens[j], user);
    		}
	    }
		return balances;
	}
  
   function tokenBalance(address user, address token) public view returns (uint) {

        uint256 tokenCode;
        assembly { tokenCode := extcodesize(token) } // contract code size
        if(tokenCode > 0)
        {
            Token tok = Token(token);
            if(tok.call(bytes4(keccak256("balanceOf(address)")), user)) {
                return tok.balanceOf(user);
            } else {
                  return 0; // not a valid balanceOf, return 0 instead of error
            }
        } else {
            return 0; // not a contract, return 0 instead of error
        }
   }
  
	function walletBalances(address user,  address[] tokens) public view returns (uint[]) {

	    require(tokens.length > 0);
		uint[] memory balances = new uint[](tokens.length);
		
		for(uint i = 0; i< tokens.length; i++){
			if( tokens[i] != address(0x0) ) { // ETH address in Etherdelta config
			    balances[i] = tokenBalance(user, tokens[i]);
			}
			else {
			   balances[i] = user.balance; // eth balance	
			}
		}	
		return balances;
	}
	
	function allBalances(address exchange, address user,  address[] tokens) public view returns (uint[]) {

		EtherDelta ex = EtherDelta(exchange);
		uint[] memory balances = new uint[](tokens.length * 2);
		
		for(uint i = 0; i< tokens.length; i++){
		    uint j = i * 2;
			balances[j] = ex.balanceOf(tokens[i], user);
			if( tokens[i] != address(0x0) ) { // ETH address in Etherdelta config
			    balances[j + 1] = tokenBalance(user, tokens[i]);
			} else {
			   balances[j + 1] = user.balance; // eth balance	
			}
		}
		return balances; 
	}

	function allBalancesForManyAccounts(
	    address exchange, 
	    address[] users,  
	    address[] tokens
	) public view returns (uint[]) {

		EtherDelta ex = EtherDelta(exchange);
		uint usersDataSize = tokens.length * 2;
		uint[] memory balances = new uint[](usersDataSize * users.length);
		
		for(uint k = 0; k < users.length; k++){
    		for(uint i = 0; i < tokens.length; i++){
    		    uint j = i * 2;
    			balances[(k * usersDataSize) + j] = ex.balanceOf(tokens[i], users[k]);
    			if( tokens[i] != address(0x0) ) { // ETH address in Etherdelta config
    			    balances[(k * usersDataSize) + j + 1] = tokenBalance(users[k], tokens[i]);
    			} else {
    			   balances[(k * usersDataSize) + j + 1] = users[k].balance; // eth balance	
    			}
    		}
		}
		return balances; 
	}
	
	function allWETHbalances(
	    address wethAddress, 
	    address[] users
    ) public view returns (uint[]) {

		WETH_0x weth = WETH_0x(wethAddress);
		uint[] memory balances = new uint[](users.length);
		for(uint k = 0; k < users.length; k++){
    		balances[k] = weth.balanceOf(users[k]);
		}
		return balances; 
	}
	
   function getManyReturnsForManyConverters_Bancor(
        address[] bancorConverterContracts,
        address[] fromTokens,
        address[] toTokens,
        uint[] amounts
   ) public view returns (uint[]) {

        require(amounts.length == toTokens.length && 
            toTokens.length == fromTokens.length && 
            fromTokens.length == bancorConverterContracts.length);

        uint[] memory expectedReturns = new uint[](amounts.length);
		for(uint k = 0; k < amounts.length; k++){
		    BancorConverter bancor = BancorConverter(bancorConverterContracts[k]);
    		expectedReturns[k] = bancor.getReturn(fromTokens[k], toTokens[k], amounts[k]);
		}
		return expectedReturns; 
   }
   
   function getManyReturns_Bancor(
        address bancorConverterContract,
        address fromToken,
        address toToken,
        uint[] amounts
   ) public view returns (uint[]) {

        BancorConverter bancor = BancorConverter(bancorConverterContract);
        uint[] memory expectedReturns = new uint[](amounts.length);
		for(uint k = 0; k < amounts.length; k++){
    		expectedReturns[k] = bancor.getReturn(fromToken, toToken, amounts[k]);
		}
		return expectedReturns; 
   }
	    
}