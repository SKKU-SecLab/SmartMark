
pragma solidity ^0.4.21;

 
contract IdentityBase{

    
    struct Data{
	
        bytes32 biometricData;
        string name;
        string surname;
        bool isEnabled;
		
    }
    
	mapping(address => Data) identities;
   
	function isIdentity(address _sender) public view returns(bool){

	
		return identities[_sender].isEnabled;
		
	}   
   
    function setMyIdentity(bytes32 _biometricData, string _name, string _surname) public returns(bool){

    
		if(identities[msg.sender].biometricData == ""){
			
			Data storage identity = identities[msg.sender];
			identity.biometricData = _biometricData;
            identity.name = _name;
            identity.surname = _surname;
            identity.isEnabled = true;
            return true;
			
        }else{
		
			return false;
			
        }   
		
	}
   
    function checkIdentity(bytes32 _biometricData) public returns(bool){

        
        if(identities[msg.sender].biometricData == _biometricData){
			
			emit UnlockEvent(msg.sender, identities[msg.sender].name, identities[msg.sender].surname, now, true);
            return true;
			
        }else{
            
			emit UnlockEvent(msg.sender, identities[msg.sender].name, identities[msg.sender].surname, now, false);
            return false;
			
        }
       
	}  
	
	event UnlockEvent(address sender, string name, string surname, uint256 timestamp, bool result);  

}


contract IdentityExtended is IdentityBase{  

    
	struct DataExtended{
	
        bool usaPermission;
		bool euPermission;
        bool chinaPermission;
		
    }
    
    mapping(address => DataExtended) identitiesExtended;    
   
    function setIdentityExtended(bool _usaPermission, bool _euPermission, bool _chinaPermission) public {

        
        DataExtended storage dataExtended = identitiesExtended[msg.sender];
        dataExtended.usaPermission = _usaPermission;
        dataExtended.euPermission = _euPermission;
        dataExtended.chinaPermission = _chinaPermission;
		
    }
    
}


contract B2Lab_TokenPlus{


	string constant public tokenName = "NFT B2LAB";
	string constant public tokenSymbol = "B2L";
	address public contractOwner;
	uint256 constant public totalTokens = 1000000;
	uint256 public issuedTokens = 0;
	uint256 public price = 1000000000 wei;
	
	address public identityEthAddress;
   
	mapping(address => uint256) public balances;
   
	mapping(uint256 => address) public tokenOwners;
	
	struct TokenData{
	    
	    bytes8 dataA;
	    bytes8 dataB;
	    bytes8 dataC;
	    
	}
	
	mapping(uint256 => TokenData) public tokenInfo;
	
	function B2Lab_TokenPlus(address _ethAddress) public {

	
		contractOwner = msg.sender;
		identityEthAddress = _ethAddress;
		
	}
	
    modifier isContractOwner(){

        
        require(msg.sender == contractOwner);
        _;
        
    }
    
    function changeIdentityEthAddress(address _ethAddress) public isContractOwner{

	
        identityEthAddress = _ethAddress;
		
    }
    
	modifier checkIsIdentity(address _a){

       
        IdentityBase i = IdentityBase(identityEthAddress);
        
		require(i.isIdentity(_a));
		_;
		
	} 
   
	function buyTokens() payable public checkIsIdentity(msg.sender){

	
		require(msg.value > 0);
		uint256 numberTokens = msg.value / price;
		uint256 redelivery =  msg.value % price;
		require(numberTokens != 0);
		require(numberTokens <= 100);
		require((issuedTokens+numberTokens) <= totalTokens);
		
		for(uint256 i = 0; i < numberTokens; i++){
		
			issuedTokens++;
			tokenOwners[issuedTokens] = msg.sender;
			emit Transfer(contractOwner, msg.sender, issuedTokens);
			
		}
		
		balances[msg.sender] += numberTokens;
		msg.sender.transfer(redelivery);
		
	}  
   
    function transferTokens(address _to, uint256[] _tokenId) public checkIsIdentity(msg.sender) checkIsIdentity(_to){

		
		require(msg.sender != _to);
		require(_tokenId.length != 0);
        require(_tokenId.length <= 10);
        require(_to != address(0));
		
        for(uint256 i = 0; i < _tokenId.length; i++){
		
            require(tokenOwners[_tokenId[i]] == msg.sender);
			tokenOwners[_tokenId[i]] = _to;
            emit Transfer(msg.sender, _to, _tokenId[i]);
			
        }
		
		balances[msg.sender] -= _tokenId.length;
		balances[_to] += _tokenId.length;
		
	}

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
	
}