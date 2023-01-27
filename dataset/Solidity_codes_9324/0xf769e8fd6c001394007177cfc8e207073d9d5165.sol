
pragma solidity ^0.4.21;

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

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract KahnAirDrop{

    using SafeMath for uint256;
	
    struct User{
		address user_address;
		uint signup_time;
		uint256 reward_amount;
		bool blacklisted;
		uint paid_time;
		uint256 paid_token;
		bool status;
	}
	
    address public owner;
	
    address public wallet;
	
    uint256 public mineth = 0;

    uint256 public minsignupeth = 0;

	bool public paused = false;
	
	uint public maxSignup = 1000;
	
	bool public allowsSignup = true;
	
	address[] public bountyaddress;
	
	address[] public adminaddress;
	
	address[] public staffaddress;
	
	uint public startTimes;
	
	uint public endTimes;
	
	bool public contractbacklist = false;

    uint public userSignupCount = 0;
	
    uint256 public userClaimAmt = 0;

    ERC20 public token;

	uint public payStyle = 2;
	
	bool public paidversion = true;

	uint public payoutNow = 4;
	
	uint256 public fixPayAmt = 0;
	
    mapping(address => User) public bounties;
	
	mapping(address => bool) public signups;
	
	mapping(address => bool) public blacklist;
	
	mapping(address => bool) public isProcess;
	
    mapping (address => bool) public admins;
	
    mapping (address => bool) public staffs;
	
    event eTokenClaim(address indexed _address, uint256 _amount);   
    event eReClaimToken(uint256 _taBal, address _wallet, address _address);   
    event eWalletChange(address _wallet, address indexed _address);
    event eUpdatePayout(uint _payStyle, uint _payoutNow, uint256 _fixPayAmt, bool _allowsSignup, address indexed _address); 
    event eUpdateStartEndTime(uint _startTimes, uint _endTimes, address indexed _address); 

	
    function KahnAirDrop(ERC20 _token, uint256 _min_eth, uint256 _minsignupeth, uint _paystyle, address _wallet, uint _starttimes, uint _endtimes, uint _payoutnow, uint256 _fixpayamt, uint _maxsignup, bool _allowssignup, bool _paidversion) public {

        require(_token != address(0));
        token = _token;
        admins[msg.sender] = true;
        adminaddress.push(msg.sender) -1;
        owner = msg.sender;
        mineth = _min_eth;
        minsignupeth = _minsignupeth;
        wallet = _wallet;
        payStyle = _paystyle;
        startTimes = _starttimes;
        endTimes = _endtimes;
        payoutNow = _payoutnow;
        fixPayAmt = _fixpayamt;
        maxSignup = _maxsignup;
        allowsSignup = _allowssignup;
        paidversion = _paidversion;
    }

    modifier onlyOwner {

       require(msg.sender == owner);
       _;
    }
	
    modifier onlyAdmin {

        require(admins[msg.sender]);
        _;
    }

    modifier onlyStaffs {

        require(admins[msg.sender] || staffs[msg.sender]);
        _;
    }

    modifier ifNotPaused {

       require(!paused);
       _;
    }

    modifier ifNotStartExp {

       require(now >= startTimes && now <= endTimes);
       _;
    }

    modifier ifNotBlacklisted {

       require(!contractbacklist);
       _;
    }

    function ownerUpdateToken(ERC20 _token, address _wallet) public onlyOwner{

        token = _token;
        wallet = _wallet;
        emit eWalletChange(wallet, msg.sender);
    }

    function ownerUpdateOthers(uint _maxno, bool _isBacklisted, uint256 _min_eth, uint256 _minsignupeth, bool _paidversion) public onlyOwner{

        maxSignup = _maxno;
        contractbacklist = _isBacklisted;
        mineth = _min_eth;
        minsignupeth = _minsignupeth;
        paidversion = _paidversion;
    }

    function ownerRetrieveTokenDetails() view public onlyOwner returns(ERC20, address, uint256, uint256, bool){

		return(token, wallet, token.balanceOf(this), userClaimAmt, contractbacklist);
    }

    function ownerRetrieveContractConfig2() view public onlyOwner returns(uint256, bool, uint, uint, uint, uint, uint256, uint, bool){

		return(mineth, paidversion, payStyle, startTimes, endTimes, payoutNow, fixPayAmt, maxSignup, allowsSignup);
    }

	function addAdminWhitelist(address[] _userlist) public onlyOwner onlyAdmin{

		require(_userlist.length > 0);
		for (uint256 i = 0; i < _userlist.length; i++) {
			address baddr = _userlist[i];
			if(baddr != address(0)){
				if(!admins[baddr]){
					admins[baddr] = true;
					adminaddress.push(baddr) -1;
				}
			}
		}
	}
	
	function removeAdminWhitelist(address[] _userlist) public onlyAdmin{

		require(_userlist.length > 0);
		for (uint256 i = 0; i < _userlist.length; i++) {
			address baddr = _userlist[i];
			if(baddr != address(0)){
				if(admins[baddr]){
					admins[baddr] = false;
				}
			}
		}
	}
	
	function addStaffWhitelist(address[] _userlist) public onlyAdmin{

		require(_userlist.length > 0);
		for (uint256 i = 0; i < _userlist.length; i++) {
			address baddr = _userlist[i];
			if(baddr != address(0)){
				if(!staffs[baddr]){
					staffs[baddr] = true;
					staffaddress.push(baddr) -1;
				}
			}
		}
	}
	
	function removeStaffWhitelist(address[] _userlist) public onlyAdmin{

		require(_userlist.length > 0);
		for (uint256 i = 0; i < _userlist.length; i++) {
			address baddr = _userlist[i];
			if(baddr != address(0)){
				if(staffs[baddr]){
					staffs[baddr] = false;
				}
			}
		}
	}
	
	function reClaimBalance() public onlyAdmin{

		uint256 taBal = token.balanceOf(this);
		token.transfer(wallet, taBal);
		emit eReClaimToken(taBal, wallet, msg.sender);
	}
	
	function adminUpdateWallet(address _wallet) public onlyAdmin{

		require(_wallet != address(0));
		wallet = _wallet;
		emit eWalletChange(wallet, msg.sender);
	}

	function adminUpdateStartEndTime(uint _startTimes, uint _endTimes) public onlyAdmin{

		require(_startTimes > 0);
		require(_endTimes > 0);
		startTimes = _startTimes;
		endTimes = _endTimes;
		emit eUpdateStartEndTime(startTimes, endTimes, msg.sender);
	}

    function adminUpdMinSign(uint256 _min_eth, uint256 _minsignupeth) public onlyAdmin{

       if(paidversion){
			mineth = _min_eth;
			minsignupeth = _minsignupeth;
	   } 
    }

	function adminUpdatePayout(uint _payStyle, uint _payoutNow, uint256 _fixPayAmt, bool _allowsSignup) public onlyAdmin{

		payStyle = _payStyle;
		payoutNow = _payoutNow;
		fixPayAmt = _fixPayAmt;
		allowsSignup = _allowsSignup;
		emit eUpdatePayout(payStyle, payoutNow, fixPayAmt, allowsSignup, msg.sender);
	}


    function signupUserWhitelist(address[] _userlist, uint256[] _amount) public onlyStaffs{

    	require(_userlist.length > 0);
		require(_amount.length > 0);
    	for (uint256 i = 0; i < _userlist.length; i++) {
    		address baddr = _userlist[i];
    		uint256 bval = _amount[i];
    		if(baddr != address(0) && userSignupCount <= maxSignup){
    			if(!bounties[baddr].blacklisted && bounties[baddr].user_address != baddr){
					signups[baddr] = true;
					bountyaddress.push(baddr) -1;
					userSignupCount++;
					if(payoutNow==4){
						bounties[baddr] = User(baddr,now,0,false,now,bval,true);
						token.transfer(baddr, bval);
						userClaimAmt = userClaimAmt.add(bval);
					}else{
						bounties[baddr] = User(baddr,now,bval,false,0,0,true);
					}
    			}
    		}
    	}
    }
	
    function removeUserWhitelist(address[] _userlist) public onlyStaffs{

		require(_userlist.length > 0);
		for (uint256 i = 0; i < _userlist.length; i++) {
			address baddr = _userlist[i];
			if(baddr != address(0) && bounties[baddr].user_address == baddr){
				bounties[baddr].status = false;
            	signups[baddr] = false;
            	userSignupCount--;
			}
		}
    }
	
	function updUserBlackList(address[] _addlist, address[] _removelist) public onlyStaffs{

		if(_addlist.length > 0){
			for (uint256 i = 0; i < _addlist.length; i++) {
				address baddr = _addlist[i];
				if(baddr != address(0) && !bounties[baddr].blacklisted){
					bounties[baddr].blacklisted = true;
					blacklist[baddr] = true;
				}
			}
		}
		
		if(_removelist.length > 0){ removeUserFromBlackList(_removelist); }
	}
	
	function removeUserFromBlackList(address[] _userlist) internal{

		require(_userlist.length > 0);
		for (uint256 i = 0; i < _userlist.length; i++) {
			address baddr = _userlist[i];
			if(baddr != address(0) && bounties[baddr].blacklisted){
				bounties[baddr].blacklisted = false;
				blacklist[baddr] = false;
			}
		}
	}
	
    function updateMultipleUsersReward(address[] _userlist, uint256[] _amount) public onlyStaffs{

		require(_userlist.length > 0);
		require(_amount.length > 0);
		for (uint256 i = 0; i < _userlist.length; i++) {
			address baddr = _userlist[i];
			uint256 bval = _amount[i];
			if(baddr != address(0)){
				if(bounties[baddr].user_address == baddr){
					bounties[baddr].reward_amount = bval;
				}else{
					if(userSignupCount <= maxSignup){
					    bounties[baddr] = User(baddr,now,bval,false,0,0,true);
					    signups[baddr] = true;
						bountyaddress.push(baddr) -1;
					    userSignupCount++;
					}
				}
			}
		}
    }
	
    function adminRetrieveContractConfig() view public onlyStaffs returns(uint, uint, uint256, uint, bool, bool){

		return(payStyle, payoutNow, fixPayAmt, maxSignup, allowsSignup, paidversion);
    }

    function adminRetrieveContractConfig2() view public onlyStaffs returns(uint256, uint256, address, uint, uint, uint){

    	return(mineth, minsignupeth, wallet, startTimes, endTimes, userSignupCount);
    }

    function adminRetrieveContractConfig3() view public onlyStaffs returns(ERC20, uint256, uint256, uint, uint){

    	uint256 taBal = token.balanceOf(this);
		return(token, taBal,userClaimAmt, now, block.number);
    }

	function chkAdmin(address _address) view public onlyAdmin returns(bool){

		return admins[_address];
	}
	
	function chkStaff(address _address) view public onlyAdmin returns(bool){

		return staffs[_address];
	}

	function getAllAdmin() view public onlyAdmin returns(address[]){

		return adminaddress;
	}

	function getAllStaff() view public onlyAdmin returns(address[]){

		return staffaddress;
	}

	function getBountyAddress() view public onlyStaffs returns(address[]){

		return bountyaddress;
	}
	
	function chkUserDetails(address _address) view public onlyStaffs returns(address,uint,uint256,bool,uint,uint256,bool){

		require(_address != address(0));
		return(bounties[_address].user_address, bounties[_address].signup_time, bounties[_address].reward_amount, bounties[_address].blacklisted, bounties[_address].paid_time, bounties[_address].paid_token, bounties[_address].status);
	}
	
	function () external payable ifNotStartExp ifNotPaused ifNotBlacklisted{
		require(!blacklist[msg.sender]);
		if(payoutNow == 0){
			require(allowsSignup);
			singleUserSignUp(msg.sender);
		}else if(payoutNow == 1){
			require(allowsSignup);
		}else if(payoutNow == 2){
			claimTokens(msg.sender);
		}else if(payoutNow == 3){
			claimImmediateTokens(msg.sender);
		}
	}
	
	function singleUserSignUp(address _address) internal ifNotStartExp ifNotPaused ifNotBlacklisted {

		if(userSignupCount <= maxSignup){
			if(!signups[_address] && bounties[_address].user_address != _address && msg.value >= minsignupeth){
				if(payoutNow != 1 || payoutNow != 2){
					signups[_address] = true;
					uint256 temrew = 0;
					if(payStyle == 1){ temrew = fixPayAmt; }
					bounties[_address] = User(_address,now,temrew,false,0,0,true);
					signups[_address] = true;
					bountyaddress.push(_address) -1;
					userSignupCount++;
				}
			}
		}
		forwardWei();
	}
	
    function claimTokens(address _beneficiary) public payable ifNotStartExp ifNotPaused ifNotBlacklisted {

	   require(msg.value >= mineth);
	   require(_beneficiary != address(0));
	   require(!blacklist[msg.sender]);
	   
       require(!isProcess[_beneficiary]);
	   
       require(signups[_beneficiary]);
	   
	   uint256 rewardAmount = getReward(_beneficiary);
	   
	   require(rewardAmount > 0);
	   
	   uint256 taBal = token.balanceOf(this);
	   
	   require(rewardAmount <= taBal);
	   
	   isProcess[_beneficiary] = true;
	   
	   token.transfer(_beneficiary, rewardAmount);
	   
	   bounties[_beneficiary].reward_amount = 0;
	   bounties[_beneficiary].status = true;
	   bounties[_beneficiary].paid_time = now;
	   
	   isProcess[_beneficiary] = false;
	   
	   userClaimAmt = userClaimAmt.add(rewardAmount);
	   
	   forwardWei();
	   
	   emit eTokenClaim(_beneficiary, rewardAmount);
    }
	
	
    function claimImmediateTokens(address _beneficiary) public payable ifNotStartExp ifNotPaused ifNotBlacklisted {

	   require(msg.value >= mineth);
	   require(_beneficiary != address(0));
	   require(!blacklist[msg.sender]);
	   require(userSignupCount <= maxSignup);
	   require(fixPayAmt > 0);
	   uint256 taBal = token.balanceOf(this);
	   require(taBal > 0);
	   require(fixPayAmt <= taBal);
       require(!isProcess[_beneficiary]);
	   isProcess[_beneficiary] = true;
	   signups[_beneficiary] = true;
	   bounties[_beneficiary] = User(_beneficiary,now,0,false,now,fixPayAmt,true);
	   bountyaddress.push(_beneficiary) -1;
	   userSignupCount++;
	   token.transfer(_beneficiary, fixPayAmt);
	   userClaimAmt = userClaimAmt.add(fixPayAmt);
	   forwardWei();
	   emit eTokenClaim(_beneficiary, fixPayAmt);
    }

	function getReward(address _address) internal constant returns(uint256){

		uint256 rtnVal = 0;
		if(payStyle == 0){
			uint256 taBal = token.balanceOf(this);
			rtnVal = taBal.div(userSignupCount);
		}else if(payStyle == 1){
			rtnVal = fixPayAmt;
		}else if(payStyle == 2){
			rtnVal = bounties[_address].reward_amount;
		}
		return rtnVal;
	}
	
	function forwardWei() internal {

		if(!paidversion){
			if(msg.value > 0)
				owner.transfer(msg.value);
		}else{
			if(msg.value > 0)
				wallet.transfer(msg.value);
		}
	}
}