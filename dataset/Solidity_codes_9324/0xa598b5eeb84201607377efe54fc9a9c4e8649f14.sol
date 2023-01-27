
pragma solidity ^0.4.25;


	
contract EthereumSmartContract {    

    address EthereumNodes; 
	
    constructor() public { 
        EthereumNodes = msg.sender;
    }
    modifier restricted() {

        require(msg.sender == EthereumNodes);
        _;
    } 
	
    function GetEthereumNodes() public view returns (address owner) { return EthereumNodes; }

}

contract ldoh is EthereumSmartContract {

	
	
 event onCashbackCode	(address indexed hodler, address cashbackcode);		
 event onAffiliateBonus	(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);		
 event onHoldplatform	(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
 event onUnlocktoken	(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
 event onUtilityfee		(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
 event onReceiveAirdrop	(address indexed hodler, uint256 amount, uint256 datetime);	

 event onAddContract	(address indexed hodler, address indexed tokenAddress, uint256 percent, string tokenSymbol, uint256 amount, uint256 endtime);
 event onTokenPrice		(address indexed hodler, address indexed tokenAddress, uint256 Currentprice, uint256 ETHprice, uint256 endtime);
 event onHoldAirdrop	(address indexed hodler, address indexed tokenAddress, uint256 HPMstatus, uint256 d1, uint256 d2, uint256 d3,uint256 endtime);
 event onHoldDeposit	(address indexed hodler, address indexed tokenAddress, uint256 amount, uint256 endtime);
 event onHoldWithdraw	(address indexed hodler, address indexed tokenAddress, uint256 amount, uint256 endtime);
 event onUtilitySetting	(address indexed hodler, address indexed tokenAddress, address indexed pwt, uint256 amount, uint256 ustatus, uint256 endtime);
 event onUtilityStatus	(address indexed hodler, address indexed tokenAddress, uint256 ustatus, uint256 endtime);
 event onUtilityBurn	(address indexed hodler, address indexed tokenAddress, uint256 uamount, uint256 bamount, uint256 endtime); 
 
 event onIHODeposit		(address indexed hodler, address indexed tokenAddress, uint256 amount, uint256 endtime);
 event onIHOWithdraw	(address indexed hodler, address indexed tokenAddress, uint256 amount, uint256 endtime);
 
		

	
	
	
	

    struct Safe {
        uint256 id;						// [01] -- > Registration Number
        uint256 amount;					// [02] -- > Total amount of contribution to this transaction
        uint256 endtime;				// [03] -- > The Expiration Of A Hold Platform Based On Unix Time
        address user;					// [04] -- > The ETH address that you are using
        address tokenAddress;			// [05] -- > The Token Contract Address That You Are Using
		string  tokenSymbol;			// [06] -- > The Token Symbol That You Are Using
		uint256 amountbalance; 			// [07] -- > 88% from Contribution / 72% Without Cashback
		uint256 cashbackbalance; 		// [08] -- > 16% from Contribution / 0% Without Cashback
		uint256 lasttime; 				// [09] -- > The Last Time You Withdraw Based On Unix Time
		uint256 percentage; 			// [10] -- > The percentage of tokens that are unlocked every month ( Default = 2% --> Promo = 3% )
		uint256 percentagereceive; 		// [11] -- > The Percentage You Have Received
		uint256 tokenreceive; 			// [12] -- > The Number Of Tokens You Have Received
		uint256 lastwithdraw; 			// [13] -- > The Last Amount You Withdraw
		address referrer; 				// [14] -- > Your ETH referrer address
		bool 	cashbackstatus; 		// [15] -- > Cashback Status
    }
	
	
	uint256 public nowtime; //Change before deploy (DELETE)
	
	uint256 private idnumber; 										// [01] -- > ID number ( Start from 500 )				
	uint256 public  TotalUser; 										// [02] -- > Total Smart Contract User					
	mapping(address => address) 		public cashbackcode; 		// [03] -- > Cashback Code 					
	mapping(address => uint256[]) 		public idaddress;			// [04] -- > Search Address by ID			
	mapping(address => address[]) 		public afflist;				// [05] -- > Affiliate List by ID					
	mapping(address => string) 			public ContractSymbol; 		// [06] -- > Contract Address Symbol				
	mapping(uint256 => Safe) 			private _safes; 			// [07] -- > Struct safe database	
	mapping(address => bool) 			public contractaddress; 	// [08] -- > Contract Address 		

	mapping (address => mapping (uint256 => uint256)) public Bigdata; 
	
	
	mapping (address => mapping (address => mapping (uint256 => uint256))) public Statistics;
	
	address public Holdplatform_address;						// [01] -- > Token contract address used for airdrop					
	uint256 public Holdplatform_balance; 						// [02] -- > The remaining balance, to be used for airdrop			
	mapping(address => uint256) public Holdplatform_status;		// [03] -- > Current airdrop status ( 0 = Disabled, 1 = Active )
	
	mapping(address => mapping (uint256 => uint256)) public Holdplatform_divider; 	

	mapping(address => uint256) public U_status;							// [01] -- > Status for utility fee payments 
	mapping(address => uint256) public U_amount;							// [02] -- > The amount of utility fee that must be paid for every hold
	mapping(address => address) public U_paywithtoken;						// [03] -- > Tokens used to pay fees
	mapping(address => mapping (address => uint256)) public U_userstatus; 	// [04] -- > The status of the user has paid or not
	
	mapping(address => mapping (uint256 => uint256)) public U_statistics;




	
	
   
    constructor() public {     	 	
        idnumber 				= 500;
		Holdplatform_address	= 0x23bAdee11Bf49c40669e9b09035f048e9146213e;	//Change before deploy
    }
    
	

    function () public payable {  
		if (msg.value == 0) {
			tothe_moon();
		} else { revert(); }
    }
    function tothemoon() public payable {  

		if (msg.value == 0) {
			tothe_moon();
		} else { revert(); }
    }
	function tothe_moon() private {  
		for(uint256 i = 1; i < idnumber; i++) {            
		Safe storage s = _safes[i];
		
			if (s.user == msg.sender && s.amountbalance > 0) {
			Unlocktoken(s.tokenAddress, s.id);
			
				if (Statistics[s.user][s.tokenAddress][3] > 0) {		// [3] Affiliatevault
				WithdrawAffiliate(s.user, s.tokenAddress);
				}
			}
		}
    }
	

    function CashbackCode(address _cashbackcode) public {		
		require(_cashbackcode != msg.sender);			
		
		if (cashbackcode[msg.sender] == 0x0000000000000000000000000000000000000000 && Bigdata[_cashbackcode][8] == 1) { // [8] Active User 
		cashbackcode[msg.sender] = _cashbackcode; }
		else { cashbackcode[msg.sender] = EthereumNodes; }		
		
	emit onCashbackCode(msg.sender, _cashbackcode);		
    } 
	

    function Holdplatform(address tokenAddress, uint256 amount) public {
		require(amount >= 1 );
		require(add(Statistics[msg.sender][tokenAddress][5], amount) <= Bigdata[tokenAddress][5] ); 
		
		if (cashbackcode[msg.sender] == 0x0000000000000000000000000000000000000000 ) { 
			cashbackcode[msg.sender] 	= EthereumNodes;
		} 
		
		if (Bigdata[msg.sender][18] == 0) { // [18] Date Register
			Bigdata[msg.sender][18] = now;
		} 
		
		if (contractaddress[tokenAddress] == false) { revert(); } else { 
		
			if (U_status[tokenAddress] == 2 ) { 
		
			uint256 Fee				= U_amount[tokenAddress];	
			
			require(amount > Fee );
		
			uint256 utilityvault 	= U_statistics[tokenAddress][1];				// [1] Utility Vault
			uint256 utilityprofit 	= U_statistics[tokenAddress][2];				// [2] Utility Profit
			uint256 Burn 			= U_statistics[tokenAddress][3];				// [3] Utility Burn
	
			uint256 percent50		= div(Fee, 2);
	
			U_statistics[tokenAddress][1]	= add(utilityvault, percent50);		// [1] Utility Vault
			U_statistics[tokenAddress][2]	= add(utilityprofit, percent50);	// [2] Utility Profit
			U_statistics[tokenAddress][3]	= add(Burn, percent50);				// [3] Utility Burn
		
			U_userstatus[msg.sender][tokenAddress] 	= 1;	
			emit onUtilityfee(msg.sender, tokenAddress, token.symbol(), U_amount[tokenAddress], now);
			
			uint256 totalamount		= sub(amount, Fee);
					
			} else { 	
		
				if (U_status[tokenAddress] == 1 && U_userstatus[msg.sender][tokenAddress] == 0 ) { revert(); } 
				else { totalamount	= amount; }
				
			}
			
			ERC20Interface token 			= ERC20Interface(tokenAddress);       
			require(token.transferFrom(msg.sender, address(this), totalamount));	
		
			HodlTokens2(tokenAddress, totalamount);
			Airdrop(msg.sender, tokenAddress, totalamount, 1);		// Code, 1 = Lock Token 2 = Unlock Token 3 = Withdraw Affiliate
			
		}
		
	}

    function HodlTokens2(address ERC, uint256 amount) private {
		
		address ref						= cashbackcode[msg.sender];
		uint256 ReferrerContribution 	= Statistics[ref][ERC][5];							// [5] ActiveContribution
		uint256 AffiliateContribution 	= Statistics[msg.sender][ERC][5];					// [5] ActiveContribution
		uint256 MyContribution 			= add(AffiliateContribution, amount); 
		
	  	if (ref == EthereumNodes && Bigdata[msg.sender][8] == 0 ) { 						// [8] Active User 
			uint256 nodecomission 		= div(mul(amount, 26), 100);
			Statistics[ref][ERC][3] 	= add(Statistics[ref][ERC][3], nodecomission ); 	// [3] Affiliatevault 
			Statistics[ref][ERC][4] 	= add(Statistics[ref][ERC][4], nodecomission );		// [4] Affiliateprofit 
			
		} else { 
		

			uint256 affcomission_one 	= div(mul(amount, 10), 100); 
			
			if (ReferrerContribution >= MyContribution) { //--o  if referrer contribution >= My contribution

				Statistics[ref][ERC][3] 		= add(Statistics[ref][ERC][3], affcomission_one); 						// [3] Affiliatevault 
				Statistics[ref][ERC][4] 		= add(Statistics[ref][ERC][4], affcomission_one); 						// [4] Affiliateprofit 

			} else {
					if (ReferrerContribution > AffiliateContribution  ) { 	
						if (amount <= add(ReferrerContribution,AffiliateContribution)  ) { 
						
						uint256 AAA					= sub(ReferrerContribution, AffiliateContribution );
						uint256 affcomission_two	= div(mul(AAA, 10), 100); 
						uint256 affcomission_three	= sub(affcomission_one, affcomission_two);		
						} else {	
						uint256 BBB					= sub(sub(amount, ReferrerContribution), AffiliateContribution);
						affcomission_three			= div(mul(BBB, 10), 100); 
						affcomission_two			= sub(affcomission_one, affcomission_three); } 
						
					} else { affcomission_two	= 0; 	affcomission_three	= affcomission_one; } 
				Statistics[ref][ERC][3] 		= add(Statistics[ref][ERC][3], affcomission_two); 						// [3] Affiliatevault 
				Statistics[ref][ERC][4] 		= add(Statistics[ref][ERC][4], affcomission_two); 						// [4] Affiliateprofit 
	
				Statistics[EthereumNodes][ERC][3] 		= add(Statistics[EthereumNodes][ERC][3], affcomission_three); 	// [3] Affiliatevault 
				Statistics[EthereumNodes][ERC][4] 		= add(Statistics[EthereumNodes][ERC][4], affcomission_three);	// [4] Affiliateprofit 
			}	
		}

		HodlTokens3(ERC, amount, ref); 	
	}
    function HodlTokens3(address ERC, uint256 amount, address ref) private {
	    
		uint256 AvailableBalances 		= div(mul(amount, 72), 100);
		
		if (ref == EthereumNodes && Bigdata[msg.sender][8] == 0 ) 										// [8] Active User 
		{ uint256	AvailableCashback = 0; } else { AvailableCashback = div(mul(amount, 16), 100);}
		
	    ERC20Interface token 	= ERC20Interface(ERC); 		
		uint256 HodlTime		= add(now, Bigdata[ERC][2]);											// [2] Holding Time (in seconds) 	
		
		_safes[idnumber] = Safe(idnumber, amount, HodlTime, msg.sender, ERC, token.symbol(), AvailableBalances, AvailableCashback, now, Bigdata[ERC][1], 0, 0, 0, ref, false);			// [1] Percent (Monthly Unlocked tokens)	
				
		Statistics[msg.sender][ERC][1]			= add(Statistics[msg.sender][ERC][1], amount); 			// [1] LifetimeContribution
		Statistics[msg.sender][ERC][5]  		= add(Statistics[msg.sender][ERC][5], amount); 			// [5] ActiveContribution
		
		uint256 Burn 							= div(mul(amount, 2), 100);
		Statistics[msg.sender][ERC][6]  		= add(Statistics[msg.sender][ERC][6], Burn); 			// [6] Burn 	
		Bigdata[ERC][6] 						= add(Bigdata[ERC][6], amount);   						// [6] All Contribution 
        Bigdata[ERC][3]							= add(Bigdata[ERC][3], amount);  						// [3] Token Balance 

		if(Statistics[msg.sender][ERC][7] == 1 ) {														// [7] Active User 
        idaddress[msg.sender].push(idnumber); idnumber++; Bigdata[ERC][10]++;  }						// [10] Total TX Hold 	
		else { 
		afflist[ref].push(msg.sender); idaddress[msg.sender].push(idnumber); idnumber++; 
		Bigdata[ERC][9]++; Bigdata[ERC][10]++; TotalUser++;   }											// [9] Total User & [10] Total TX Hold 
		
		Bigdata[msg.sender][8] 			= 1;  															// [8] Active User 
		Statistics[msg.sender][ERC][7]	= 1;															// [7] Active User 
        emit onHoldplatform(msg.sender, ERC, token.symbol(), amount, HodlTime);	
		
		amount	= 0;	AvailableBalances = 0;		AvailableCashback = 0;
		
		U_userstatus[msg.sender][ERC] 		= 0;
		
	}
	

    function Unlocktoken(address tokenAddress, uint256 id) public {
        require(tokenAddress != 0x0);
        require(id != 0);        
        
        Safe storage s = _safes[id];
        require(s.user == msg.sender);  
		require(s.tokenAddress == tokenAddress);
		
		if (s.amountbalance == 0) { revert(); } else { UnlockToken2(tokenAddress, id); }
    }
    function UnlockToken2(address ERC, uint256 id) private {
        Safe storage s = _safes[id];      
        require(s.tokenAddress == ERC);		
		     
        if(s.endtime < nowtime){ //--o  Hold Complete , Now time DELETE before deploy >> change to 'now'
        
		uint256 amounttransfer 					= add(s.amountbalance, s.cashbackbalance);
		Statistics[msg.sender][ERC][5] 			= sub(Statistics[s.user][s.tokenAddress][5], s.amount); 			// [5] ActiveContribution	
		s.lastwithdraw 							= amounttransfer;   s.amountbalance = 0;   s.lasttime = now; 

 		Airdrop(s.user, s.tokenAddress, amounttransfer, 2);		// Code, 1 = Lock Token 2 = Unlock Token 3 = Withdraw Affiliate  
		PayToken(s.user, s.tokenAddress, amounttransfer); 
		
		    if(s.cashbackbalance > 0 && s.cashbackstatus == false || s.cashbackstatus == true) {
            s.tokenreceive 		= div(mul(s.amount, 88), 100) ; 	s.percentagereceive = mul(1000000000000000000, 88);
			s.cashbackbalance 	= 0;	
			s.cashbackstatus 	= true ;
            }
			else {
			s.tokenreceive 	= div(mul(s.amount, 72), 100) ;     s.percentagereceive = mul(1000000000000000000, 72);
			}
	
		emit onUnlocktoken(msg.sender, s.tokenAddress, s.tokenSymbol, amounttransfer, now);
		
        } else { UnlockToken3(ERC, s.id); }
        
    }   
	function UnlockToken3(address ERC, uint256 id) private {		
		Safe storage s = _safes[id];
        require(s.tokenAddress == ERC);		
			
		uint256 timeframe  			= sub(now, s.lasttime);			                            
		uint256 CalculateWithdraw 	= div(mul(div(mul(s.amount, s.percentage), 100), timeframe), 2592000); // 2592000 = seconds30days
		                         
		uint256 MaxWithdraw 		= div(s.amount, 10);
			
			if (CalculateWithdraw > MaxWithdraw) { uint256 MaxAccumulation = MaxWithdraw; } else { MaxAccumulation = CalculateWithdraw; }
			
			if (MaxAccumulation > s.amountbalance) { uint256 lastwithdraw = s.amountbalance; } else { lastwithdraw = MaxAccumulation; }
			
		s.lastwithdraw 				= lastwithdraw; 			
		s.amountbalance 			= sub(s.amountbalance, lastwithdraw);
		
		if (s.cashbackbalance > 0) { 
		s.cashbackstatus 	= true ; 
		s.lastwithdraw 		= add(s.cashbackbalance, lastwithdraw); 
		} 
		
		s.cashbackbalance 			= 0; 
		s.lasttime 					= now; 		
			
		UnlockToken4(ERC, id, s.amountbalance, s.lastwithdraw );		
    }   
    function UnlockToken4(address ERC, uint256 id, uint256 newamountbalance, uint256 realAmount) private {
        Safe storage s = _safes[id];
        require(s.tokenAddress == ERC);	

		uint256 affiliateandburn 	= div(mul(s.amount, 12), 100) ; 
		uint256 maxcashback 		= div(mul(s.amount, 16), 100) ;

		uint256 firstid = s.id;
		
			if (cashbackcode[msg.sender] == EthereumNodes && idaddress[msg.sender][0] == firstid ) {
			uint256 tokenreceived 	= sub(sub(sub(s.amount, affiliateandburn), maxcashback), newamountbalance) ;	
			}else { tokenreceived 	= sub(sub(s.amount, affiliateandburn), newamountbalance) ;}
			
		s.percentagereceive 	= div(mul(tokenreceived, 100000000000000000000), s.amount) ; 	
		s.tokenreceive 			= tokenreceived; 	

		PayToken(s.user, s.tokenAddress, realAmount);           		
		emit onUnlocktoken(msg.sender, s.tokenAddress, s.tokenSymbol, realAmount, now);
		
		Airdrop(s.user, s.tokenAddress, realAmount, 2); 	// Code, 1 = Lock Token 2 = Unlock Token 3 = Withdraw Affiliate  
    } 
    function PayToken(address user, address tokenAddress, uint256 amount) private {
        
        ERC20Interface token = ERC20Interface(tokenAddress);        
        require(token.balanceOf(address(this)) >= amount);
		
		token.transfer(user, amount);
		uint256 burn	= 0;
		
        if (Statistics[user][tokenAddress][6] > 0) {												// [6] Burn  

		burn = Statistics[user][tokenAddress][6];													// [6] Burn  
        Statistics[user][tokenAddress][6] = 0;														// [6] Burn  
		
		token.transfer(0x000000000000000000000000000000000000dEaD, burn); 
		Bigdata[tokenAddress][4]			= add(Bigdata[tokenAddress][4], burn);					// [4] Total Burn
		
		Bigdata[tokenAddress][19]++;																// [19] Total TX Burn
		}
		
		Bigdata[tokenAddress][3]			= sub(sub(Bigdata[tokenAddress][3], amount), burn); 	// [3] Token Balance 	
		Bigdata[tokenAddress][7]			= add(Bigdata[tokenAddress][7], amount);				// [7] All Payments 
		Statistics[user][tokenAddress][2]  	= add(Statistics[user][tokenAddress][2], amount); 		// [2] LifetimePayments
		
		Bigdata[tokenAddress][11]++;																// [11] Total TX Unlock 
		
	}
	

    function Airdrop(address user, address tokenAddress, uint256 amount, uint256 divfrom) private {
		
		uint256 divider			= Holdplatform_divider[tokenAddress][divfrom];
		
		if (Holdplatform_status[tokenAddress] == 1) {
			
			if (Holdplatform_balance > 0 && divider > 0) {
		
			uint256 airdrop			= div(amount, divider);
		
			address airdropaddress	= Holdplatform_address;
			ERC20Interface token 	= ERC20Interface(airdropaddress);        
			token.transfer(user, airdrop);
		
			Holdplatform_balance	= sub(Holdplatform_balance, airdrop);
			Bigdata[tokenAddress][12]++;															// [12] Total TX Airdrop	
		
			emit onReceiveAirdrop(user, airdrop, now);
			}
			
		}	
	}
	

    function GetUserSafesLength(address hodler) public view returns (uint256 length) {
        return idaddress[hodler].length;
    }
	

    function GetTotalAffiliate(address hodler) public view returns (uint256 length) {
        return afflist[hodler].length;
    }
    
	function GetSafe(uint256 _id) public view
        returns (uint256 id, address user, address tokenAddress, uint256 amount, uint256 endtime, string tokenSymbol, uint256 amountbalance, uint256 cashbackbalance, uint256 lasttime, uint256 percentage, uint256 percentagereceive, uint256 tokenreceive)
    {
        Safe storage s = _safes[_id];
        return(s.id, s.user, s.tokenAddress, s.amount, s.endtime, s.tokenSymbol, s.amountbalance, s.cashbackbalance, s.lasttime, s.percentage, s.percentagereceive, s.tokenreceive);
    }
	

    function WithdrawAffiliate(address user, address tokenAddress) public { 
		require(user == msg.sender); 	
		require(Statistics[user][tokenAddress][3] > 0 );												// [3] Affiliatevault
		
		uint256 amount 	= Statistics[msg.sender][tokenAddress][3];										// [3] Affiliatevault

        ERC20Interface token = ERC20Interface(tokenAddress);        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
		
		Bigdata[tokenAddress][3] 				= sub(Bigdata[tokenAddress][3], amount); 				// [3] Token Balance 	
		Bigdata[tokenAddress][7] 				= add(Bigdata[tokenAddress][7], amount);				// [7] All Payments
		Statistics[user][tokenAddress][3] 		= 0;													// [3] Affiliatevault
		Statistics[user][tokenAddress][2] 		= add(Statistics[user][tokenAddress][2], amount);		// [2] LifetimePayments

		Bigdata[tokenAddress][13]++;																	// [13] Total TX Affiliate (Withdraw)
		emit onAffiliateBonus(msg.sender, tokenAddress, ContractSymbol[tokenAddress], amount, now);
		
		Airdrop(user, tokenAddress, amount, 3); 	// Code, 1 = Lock Token 2 = Unlock Token 3 = Withdraw Affiliate
    } 


	function Utility_fee(address tokenAddress) public {
		
		uint256 Fee		= U_amount[tokenAddress];	
		address pwt 	= U_paywithtoken[tokenAddress];
		
		if (U_status[tokenAddress] == 0 || U_status[tokenAddress] == 2 || U_userstatus[msg.sender][tokenAddress] == 1  ) { revert(); } else { 

		ERC20Interface token 			= ERC20Interface(pwt);       
		require(token.transferFrom(msg.sender, address(this), Fee));	
		
		uint256 utilityvault 	= U_statistics[pwt][1];				// [1] Utility Vault
		uint256 utilityprofit 	= U_statistics[pwt][2];				// [2] Utility Profit
		uint256 Burn 			= U_statistics[pwt][3];				// [3] Utility Burn
	
		uint256 percent50	= div(Fee, 2);
	
		U_statistics[pwt][1]	= add(utilityvault, percent50);		// [1] Utility Vault
		U_statistics[pwt][2]	= add(utilityprofit, percent50);	// [2] Utility Profit
		U_statistics[pwt][3]	= add(Burn, percent50);				// [3] Utility Burn
	
	
		U_userstatus[msg.sender][tokenAddress] 	= 1;	
		emit onUtilityfee(msg.sender, pwt, token.symbol(), U_amount[tokenAddress], now);	
		
		}		
	
	}



    function AddContractAddress(address tokenAddress, uint256 _maxcontribution, string _ContractSymbol, uint256 _PercentPermonth) public restricted {
		require(_PercentPermonth >= 2 && _PercentPermonth <= 12);
		require(_maxcontribution >= 10000000000000000000000000);
		
		Bigdata[tokenAddress][1] 		= _PercentPermonth;							// [1] Percent (Monthly Unlocked tokens)
		ContractSymbol[tokenAddress] 	= _ContractSymbol;
		Bigdata[tokenAddress][5] 		= _maxcontribution;							// [5] Max Contribution 
		
		uint256 _HodlingTime 			= mul(div(72, _PercentPermonth), 30);
		uint256 HodlTime 				= _HodlingTime * 1 days;		
		Bigdata[tokenAddress][2]		= HodlTime;									// [2] Holding Time (in seconds) 	
		
		contractaddress[tokenAddress] 	= true;
		
		emit onAddContract(msg.sender, tokenAddress, _PercentPermonth, _ContractSymbol, _maxcontribution, now);
    }
	
	function TokenPrice(address tokenAddress, uint256 Currentprice, uint256 ETHprice) public restricted  {
		
		if (Currentprice > 0  ) { Bigdata[tokenAddress][14] = Currentprice; }		// [14] Current Price (USD)
		if (ETHprice > 0  ) 	{ Bigdata[tokenAddress][17] = ETHprice; }			// [17] Current ETH Price (ETH) 
			
		emit onTokenPrice(msg.sender, tokenAddress, Currentprice, ETHprice, now);

    }
	
    function Holdplatform_Airdrop(address tokenAddress, uint256 HPM_status, uint256 HPM_divider1, uint256 HPM_divider2, uint256 HPM_divider3 ) public restricted {
		
		Holdplatform_status[tokenAddress] 		= HPM_status;	
		Holdplatform_divider[tokenAddress][1]	= HPM_divider1; 		// [1] Lock Airdrop	
		Holdplatform_divider[tokenAddress][2]	= HPM_divider2; 		// [2] Unlock Airdrop
		Holdplatform_divider[tokenAddress][3]	= HPM_divider3; 		// [3] Affiliate Airdrop
		
		emit onHoldAirdrop(msg.sender, tokenAddress, HPM_status, HPM_divider1, HPM_divider2, HPM_divider3, now);
	
    }	
	function Holdplatform_Deposit(uint256 amount) restricted public {
        
       	ERC20Interface token = ERC20Interface(Holdplatform_address);       
        require(token.transferFrom(msg.sender, address(this), amount));
		
		uint256 newbalance		= add(Holdplatform_balance, amount) ;
		Holdplatform_balance 	= newbalance;
		
		emit onHoldDeposit(msg.sender, Holdplatform_address, amount, now);
    }
	function Holdplatform_Withdraw() restricted public {
		ERC20Interface token = ERC20Interface(Holdplatform_address);
        token.transfer(msg.sender, Holdplatform_balance);
		Holdplatform_balance = 0;
		
		emit onHoldWithdraw(msg.sender, Holdplatform_address, Holdplatform_balance, now);
    }
	

	function Utility_Setting(address tokenAddress, address _U_paywithtoken, uint256 _U_amount, uint256 _U_status) public restricted {
		require(_U_amount <= 10000000000000000000000); // <= 10.000 Token
		require(_U_status == 0 || _U_status == 1 || _U_status == 2);	// 0 = Disabled , 1 = Enabled, 2 = Merger with Hold	
		
		require(_U_paywithtoken == 0x23bAdee11Bf49c40669e9b09035f048e9146213e || _U_paywithtoken == 0x60aa1cAef7F98bdcBCFc9a13bFcd9916ac469759); 
		
		U_paywithtoken[tokenAddress]	= _U_paywithtoken; 
		U_status[tokenAddress] 			= _U_status;	
		U_amount[tokenAddress]			= _U_amount; 	

	emit onUtilitySetting(msg.sender, tokenAddress, _U_paywithtoken, _U_amount, _U_status, now);	
	
    }
	function Utility_Status(address tokenAddress, uint256 Newstatus) public restricted {
		U_status[tokenAddress] = Newstatus;
		
		emit onUtilityStatus(msg.sender, tokenAddress, U_status[tokenAddress], now);
		
    }
	function Utility_Burn(address tokenAddress) public restricted {
		
		if (U_statistics[tokenAddress][1] > 0 || U_statistics[tokenAddress][3] > 0) { 
		
		uint256 utilityamount 		= U_statistics[tokenAddress][1];					// [1] Utility Vault
		uint256 burnamount 			= U_statistics[tokenAddress][3]; 					// [3] Utility Burn
		
		uint256 fee 				= add(utilityamount, burnamount);
		
		ERC20Interface token 	= ERC20Interface(tokenAddress);      
        require(token.balanceOf(address(this)) >= fee);
			
		token.transfer(EthereumNodes, utilityamount);
		U_statistics[tokenAddress][1] 	= 0;											// [1] Utility Vault
		
		token.transfer(0x000000000000000000000000000000000000dEaD, burnamount);
		Bigdata[tokenAddress][4]		= add(burnamount, Bigdata[tokenAddress][4]);	// [4] Total Burn
		U_statistics[tokenAddress][3] 	= 0;

		emit onUtilityBurn(msg.sender, tokenAddress, utilityamount, burnamount, now);		

		}
    }
	
	
	
	
	
	uint256 public Mechanism; 	// 0 = First come first served (FCFS) , 1 = Hold in 1 month, the winner is chosen randomly
	
	mapping (address => mapping (uint256 => uint256)) public Idata; 
	mapping (address => mapping (uint256 => mapping (uint256 => uint256))) public Idata2;		// Data per Round
	mapping (address => mapping (address => mapping (uint256 => uint256))) public Idata3;

	mapping (address => mapping (address => mapping (uint256 => uint256))) public Idata4;		
	
	mapping (address => mapping (uint256 => mapping (uint256 => address))) public Idata5;		
	
	mapping (address => mapping (address => mapping (uint256 => address))) public Idata6;		
	
	mapping (address => mapping (uint256 => address[]))	public winlist;	
	
	
	
	function I_Setting(address tokenAddress, uint256 amount, uint256 I_status, uint256 Totalwinner, uint256 Holdtime, uint256 Currentreward, uint256 _Mechanism  ) public restricted {
		
		require(I_status == 0 || I_status == 1);								
		require(Totalwinner == 3 || Totalwinner == 30 || Totalwinner == 300);	
		
		require(Idata[tokenAddress][9] >= Currentreward); 	// Requires a total balance must be greater than the reward that will be shared
		
		Mechanism = _Mechanism ; 
		
		uint256 Round	= add(Idata[tokenAddress][7], 1);
		
		Idata[tokenAddress][1]		= I_status;								// [1] Status 0 = Disabled, 1 = Enabled
		Idata[tokenAddress][2]		= amount;								// [2] Amount Deposit IHO ( 10,000 / 100,000 / 1,000,000 token )
		Idata[tokenAddress][3]		= Currentreward;						// [3] Total reward provided (Default 3,000,000 Token Permonth )
		Idata[tokenAddress][4]		= Totalwinner;							// [4] Maximum number of winners (3 / 30 / 300)
		Idata[tokenAddress][5]		= add(now, 864000);						// [5] IHO - Unix time starts	( Now + 10 days )
		Idata[tokenAddress][6] 		= Holdtime * 1 days;					// [6] Length of hold time in seconds	
		Idata[tokenAddress][7]		= Round;								// [7] Current IHO Round	
		
		Idata2[tokenAddress][5][Round]		= add(now, 864000);	
		
		if (Totalwinner == 3 ) { 
		require( amount == 10000000000000000000000 || amount == 100000000000000000000000 || amount == 1000000000000000000000000); 
			if (amount == 10000000000000000000000 ) { Idata[tokenAddress][8] = 100; } 		// [8] Multipler	
			if (amount == 100000000000000000000000 ) { Idata[tokenAddress][8] = 10; } 		// [8] Multipler
			if (amount == 1000000000000000000000000 ) { Idata[tokenAddress][8] = 1; } 		// [8] Multipler
		}	
		if (Totalwinner == 30 ) { 	
		require(amount == 10000000000000000000000 || amount == 100000000000000000000000); 
			if (amount == 10000000000000000000000 ) { Idata[tokenAddress][8] = 10; } 		// [8] Multipler
			if (amount == 100000000000000000000000 ) { Idata[tokenAddress][8] = 1; } 		// [8] Multipler
		}
		if (Totalwinner == 300 ) { 	
		require(amount == 10000000000000000000000); 
			if (amount == 10000000000000000000000 ) { Idata[tokenAddress][8] = 1; } 		// [8] Multipler
		}		
		
		Idata2[tokenAddress][1][Round] 		= Currentreward;				// [1] Current Reward ( Per Round )	
		Idata2[tokenAddress][2][Round]		= Currentreward;				// [2] Reward Vault for All User ( Remaining )		
    }
	
	function I_Status(address tokenAddress) public restricted {
		if (Idata[tokenAddress][1] == 0 ) { Idata[tokenAddress][1] = 1; } else { Idata[tokenAddress][1] = 0; 
		}	
    }
	
	function IHO_Deposit(address tokenAddress, uint256 amount) restricted public {
        
       	ERC20Interface token = ERC20Interface(tokenAddress);       
        require(token.transferFrom(msg.sender, address(this), amount));
		
		uint256 IHO_balance 		= add(Idata[tokenAddress][9], amount) ;			// [9] Total available Balance (Now)	
		Idata[tokenAddress][9] 		= IHO_balance;
		
		uint256 IHO_nodesbalance 	= add(Idata[tokenAddress][12], amount) ;		// [12] The amount that can be withdrawn (Nodes)
		Idata[tokenAddress][12] 	= IHO_nodesbalance;
		
		emit onIHODeposit(msg.sender, tokenAddress, amount, now);
    }
	function IHO_Withdraw(address tokenAddress) restricted public {
		
		uint256 IHO_nodesbalance 	= Idata[tokenAddress][12];							// [12] The amount that can be withdrawn (Nodes)
			
		ERC20Interface token = ERC20Interface(tokenAddress);
        token.transfer(msg.sender, IHO_nodesbalance);
		
		Idata[tokenAddress][12]		= 0;												// [12] The amount that can be withdrawn (Nodes)
		Idata[tokenAddress][9]		= sub(Idata[tokenAddress][9], IHO_nodesbalance) ;	// [9] Total available Balance (Now)
		
		emit onIHOWithdraw(msg.sender, tokenAddress, IHO_nodesbalance, now);
    }
	
	function InitialHoldOffering(address tokenAddress) public {
		
		uint256 Round			= Idata[tokenAddress][7];						// [7] Current IHO Round	
		uint256 Newround		= add(Idata[tokenAddress][7], 1);				// Newround = Current Round + 1
		uint256 Currentreward	= Idata2[tokenAddress][1][Round];				// [1] Current Reward ( Per Round ) --- > Default = 3,000,000
		
		require(Idata2[tokenAddress][6][Round] == 1); 							// [6] Status IHO Round >>> 0 = Disabled , 1 = Enabled
		require(Idata[tokenAddress][9] >= Currentreward); 						// [9] Total available Balance (Now)
		require(now >= Idata[tokenAddress][5]); 								// [5] IHO - Unix time starts	
		
		uint256 Amount			= Idata[tokenAddress][2];		// [2] Amount Deposit IHO ( 10.000 / 100.000 / 1.000.000 token )
		uint256 Reward			= Idata[tokenAddress][3];		// [3] Total reward provided (Default 3,000,000 Token Permonth )
		uint256 Totalwinner		= Idata[tokenAddress][4];		// [4] Maximum number of winners (3 / 30 / 300)
		uint256 Holdtime		= Idata[tokenAddress][6];		// [6] Length of hold time in seconds	--- > Default = 30 Days
		uint256 Multipler		= Idata[tokenAddress][8];		// [8] Multipler
		
		require(Idata2[tokenAddress][2][Round] > 0); 			// [2] Reward Vault for All User ( Remaining )	
		
		if (Idata[tokenAddress][1] == 0 || Idata6[tokenAddress][msg.sender][Round]	== 1 ) { revert();  } else { 

			ERC20Interface token 	= ERC20Interface(tokenAddress);       
			require(token.transferFrom(msg.sender, address(this), Amount));

		uint256 Ticketnumber				= add(Idata2[tokenAddress][4][Round], 1); 	// [4] Number of active participants
		Idata2[tokenAddress][4][Round] 		= Ticketnumber ;							// [4] Number of active participants
		
		Idata4[tokenAddress][msg.sender][Round]	= Ticketnumber ;	
		
		Idata5[tokenAddress][Round][Ticketnumber]	= msg.sender ;
		
		Idata6[tokenAddress][msg.sender][Round]	= 1; // 0 = none, 1=  The eth address has been registered in this round
	
		uint256 IHO		= mul(Amount, Multipler);
		
		Idata[tokenAddress][13]					= add(Idata[tokenAddress][13], Amount);				// [13] Deposit Vault
		Idata2[tokenAddress][3][Round]			= add(Idata2[tokenAddress][3][Round], Amount);		// [3] Total Deposit All User ( This Round )
		Idata3[tokenAddress][msg.sender][1]		= add(Idata3[tokenAddress][msg.sender][1], Amount);		// [1] User Balance
		Idata3[tokenAddress][msg.sender][3]		= add(now, Holdtime);	// Now + 30 days				// [3] Unlock Time
	
			if (Mechanism == 0 ) {
				
			winlist[tokenAddress][Round].push(msg.sender);		// Record the winner's eth address				
		
			Idata[tokenAddress][11]					= add(Idata[tokenAddress][11], IHO);		// [11] The IHO contract must be paid to user
			Idata[tokenAddress][12]					= sub(Idata[tokenAddress][12], IHO);		// [12] The amount that can be withdrawn (Nodes)
			Idata2[tokenAddress][2][Round]			= sub(Idata2[tokenAddress][2][Round], IHO);    		// [2] Reward Vault for All User ( Remaining )
			Idata3[tokenAddress][msg.sender][2]		= add(Idata3[tokenAddress][msg.sender][1], IHO);	// [2] IHO Balance	
			
				if (Idata2[tokenAddress][4][Round] == Totalwinner ) {						// [4] Number of active participants
					Idata2[tokenAddress][6][Round]	= 0;										// [6] Status IHO Round >>> 0 = Disabled , 1 = Enabled
				
					Idata[tokenAddress][5]					= add(add(now, Holdtime), 86400);	// IHO starting at 30 + 1 days from now
					Idata[tokenAddress][7]					= Newround;							// [7] Current IHO Round	
					Idata2[tokenAddress][1][Newround] 		= Reward;							// [1] Current Reward ( Per Round )
					Idata2[tokenAddress][2][Newround]		= Reward;							// [2] Reward Vault for All User ( Remaining )
					Idata2[tokenAddress][5][Newround]		= add(add(now, Holdtime), 86400);	// IHO starting at 30 + 1 days from now ( Per Round )
					Idata2[tokenAddress][6][Newround] 		= 1;								// [6] Status IHO Round >>> 0 = Disabled , 1 = Enabled
				}	
			}
			
		}	
	}
	
	
	function WithdrawIHO(address tokenAddress) public { 
			
		uint256 Amountdeposit	= Idata3[tokenAddress][msg.sender][1];		// [1] User Balance	
		uint256 AmountIHO		= Idata3[tokenAddress][msg.sender][2];		// [2] IHO Balance		
		
		uint256 Totalamount		= add(Amountdeposit, AmountIHO);
		
		require(Totalamount > 0 );												
		
		if (now >= Idata3[tokenAddress][msg.sender][3] ) {			// [3] Unlock Time 
		
			ERC20Interface token = ERC20Interface(tokenAddress);        
			require(token.balanceOf(address(this)) >= Totalamount);
			
			token.transfer(msg.sender, Totalamount);
		
			Idata[tokenAddress][9]	= sub(Idata[tokenAddress][9], AmountIHO);		// [9] Total available Balance (Now)
			Idata[tokenAddress][11]	= sub(Idata[tokenAddress][11], AmountIHO);		// [11] The IHO contract must be paid to user
			Idata[tokenAddress][13]	= sub(Idata[tokenAddress][13], Amountdeposit);	// [13] Deposit Vault
		
			Idata3[tokenAddress][msg.sender][1]		= 0;		// [1] User Balance	
			Idata3[tokenAddress][msg.sender][2]		= 0;		// [2] IHO Balance	
		
		} else { revert(); }
    } 
	
    function PickWinner(address tokenAddress) public restricted {
		
		require( Mechanism == 1 );
		
		uint256 Round		= Idata[tokenAddress][7];								// [7] Current IHO Round
		uint256 PickTime	= add(Idata2[tokenAddress][5][Round], 2592000); 		// 2592000 = seconds30days
		
		require(now >= PickTime );	
	
		require(Idata2[tokenAddress][7][Round] == 0); 			// [7] Status Pick Winner 0 = Available , 1 = Not Available
		uint256 Totalparticipant		= Idata2[tokenAddress][4][Round] ;	
		uint256 Pick_Winner = uint256(uint256(keccak256(abi.encodePacked(block.difficulty, now)))%Totalparticipant); 
		
		if (Pick_Winner == 0 ) { PickWinner(tokenAddress);  }
		
		else { 
		
		address Thewinneris	= Idata5[tokenAddress][Round][Pick_Winner];
		
		winlist[tokenAddress][Round].push(Thewinneris);		// Record the winner's eth address
			PickWinner2(tokenAddress, Thewinneris);
		
		Idata2[tokenAddress][8][Round]++;					//[8] Number of winners
		
		uint256 Totalwinner		= Idata[tokenAddress][4];		// [4] Maximum number of winners (3 / 30 / 300)
			
			if (Idata2[tokenAddress][8][Round] >= Totalwinner ) { 
			
				uint256 Reward			= Idata[tokenAddress][3];		// [3] Total reward provided (Default 3,000,000 Token Permonth )
			
				uint256 Newround						= add(Idata[tokenAddress][7], 1);	// Newround = Current Round + 1
				Idata[tokenAddress][7]					= Newround;							// [7] Current IHO Round	
				Idata2[tokenAddress][6][Round]			= 0;								// [6] Status IHO Round >>> 0 = Disabled , 1 = Enabled
				Idata2[tokenAddress][1][Newround] 		= Reward;							// [1] Current Reward ( Per Round )
				Idata2[tokenAddress][2][Newround]		= Reward;							// [2] Reward Vault for All User ( Remaining )
				Idata2[tokenAddress][6][Newround] 		= 1;								// [6] Status IHO Round >>> 0 = Disabled , 1 = Enabled
				
				Idata[tokenAddress][5]					= now;								// [5] IHO - Unix time starts	
			
				Idata2[tokenAddress][7][Round] = 1;   					// [7] Status Pick Winner 0 = Available , 1 = Not Available
				
			} else { PickWinner(tokenAddress); }
		}	
	}	
	
	
		function PickWinner2(address tokenAddress, address winner) public { 
			
		uint256 Amountdeposit	= Idata3[tokenAddress][winner][1];		// [1] User Balance	
		uint256 AmountIHO		= Idata3[tokenAddress][winner][2];		// [2] IHO Balance		
		
		uint256 Totalamount		= add(Amountdeposit, AmountIHO);
		
		require(Totalamount > 0 );												
		
		ERC20Interface token = ERC20Interface(tokenAddress);        
		require(token.balanceOf(address(this)) >= Totalamount);
			
		token.transfer(winner, Totalamount);
		
		Idata[tokenAddress][9]	= sub(Idata[tokenAddress][9], AmountIHO);		// [9] Total available Balance (Now)
		Idata[tokenAddress][11]	= sub(Idata[tokenAddress][11], AmountIHO);		// [11] The IHO contract must be paid to user
		Idata[tokenAddress][13]	= sub(Idata[tokenAddress][13], Amountdeposit);	// [13] Deposit Vault
		
		Idata3[tokenAddress][winner][1]		= 0;		// [1] User Balance	
		Idata3[tokenAddress][winner][2]		= 0;		// [2] IHO Balance	
		
    } 
		
	
	
	
    function updatenowtime(uint256 _nowtime) public restricted {
		nowtime 	= _nowtime;	
    }	
	
	
	
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
    
}



contract ERC20Interface {

    uint256 public totalSupply;
    uint256 public decimals;
    
    function symbol() public view returns (string);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}