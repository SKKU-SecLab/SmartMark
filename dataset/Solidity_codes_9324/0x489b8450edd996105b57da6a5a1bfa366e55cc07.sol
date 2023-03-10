
pragma solidity ^0.4.21;

contract SBCE {

	string public constant name = "SBC token";
	string public constant symbol = "SBCE";	
	uint8 public constant decimals = 8;
	address public owner;
	uint256 public totalSupply_;

	address public airdrop;
	uint256 public airdropAmount;
	bool public airdropConjured;

	mapping (address => uint256) public balances;
	mapping (address => mapping (address => uint256)) internal allowed;

	event Transfer(address indexed from, address indexed to, uint256 value);	
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event Burn(address indexed from, uint256 value);
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	modifier onlyOwner() {

		require(msg.sender == owner);
		_;
	}

	function SBCE(uint256 initialSupply, uint256 _airdropAmount) public {

		owner = msg.sender;
		balances[owner] = initialSupply * 100000000;							// Give the creator all initial tokens
		totalSupply_ = initialSupply * 100000000;								// Update total supply
		airdropAmount = _airdropAmount;
	}

	function totalSupply() public view returns (uint256) {

    	return totalSupply_;
  	}
	
	function transfer(address _to, uint256 _value) public returns (bool) {

		require(_to != address(0));
    	require(balances[msg.sender] >=_value);
		
		require(balances[msg.sender] >= _value);
		require(balances[_to] + _value >= balances[_to]);

		balances[msg.sender] -= _value;					 
		balances[_to] += _value;					
		emit Transfer(msg.sender, _to, _value);				  
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

		require(_to != address(0));						  
		require(_value <= balances[_from]);			
		require(_value <= allowed[_from][msg.sender]);

		require(balances[msg.sender] >= _value);
		require(balances[_to] + _value >= balances[_to]);		
		require(allowed[_from][msg.sender] >= _value);						// Check allowance

		balances[_from] -= _value;						   					// Subtract from the sender
		balances[_to] += _value;							 				// Add the same to the recipient
		allowed[_from][msg.sender] -= _value;
		emit Transfer(_from, _to, _value);
		return true;
	}

	function balanceOf(address _owner) public view returns (uint256 balance) {

    	return balances[_owner];
	}

	function approve(address _spender, uint256 _value) public returns (bool) {

    	allowed[msg.sender][_spender] = _value;
    	emit Approval(msg.sender, _spender, _value);		
		return true;
	}	
	
	function allowance(address _owner, address _spender) public view returns (uint256) {

		return allowed[_owner][_spender];
	}

	function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    	require(allowed[msg.sender][_spender] + _addedValue >= allowed[msg.sender][_spender]);
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + _addedValue;
    	emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    	return true;
  	}

	function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

		uint oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} 
		else {
			allowed[msg.sender][_spender] = oldValue - _subtractedValue;
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
  	}

	function burn(uint256 _value) public returns (bool) {		

		require(balances[msg.sender] >= _value ); 								// value > totalSupply is impossible because it means that sender balance is greater than totalSupply.				
		balances[msg.sender] -= _value;					  						// Subtract from the sender
		totalSupply_ -= _value;													// Updates totalSupply
		emit Burn(msg.sender, _value);											// Fires the event about token burn
		return true;
	}

	function burnFrom(address _from, uint256 _value) public returns (bool) {

		require(balances[_from] >= _value );									// Check if the sender has enough
		require(allowed[_from][msg.sender] >= _value);							// Check allowance
		balances[_from] -= _value;						  						// Subtract from the sender
		totalSupply_ -= _value;							   						// Updates totalSupply
		emit Burn(_from, _value);												// Fires the event about token burn
		return true;
	}

	function transferOwnership(address newOwner) public onlyOwner {

		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
    	owner = newOwner;
	}

	function setAirdropReceiver(address _airdrop) public onlyOwner {

		require(_airdrop != address(0));
		airdrop = _airdrop;
	}

	function conjureAirdrop() public onlyOwner {			

		require(totalSupply_ + airdropAmount >= balances[airdrop]);
		require(airdrop != address(0));
		balances[airdrop] += airdropAmount;
		totalSupply_ += airdropAmount;		
	}

	function () public payable {} 

	function withdraw() public onlyOwner {

    	msg.sender.transfer(address(this).balance);
	}

	function destroy() onlyOwner public {

		selfdestruct(owner);
	}
}