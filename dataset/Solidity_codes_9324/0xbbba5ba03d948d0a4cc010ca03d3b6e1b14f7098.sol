
pragma solidity ^0.8.0;
 

contract Ownable {

    
    address public owner;
    
    event OwnershipTransferred(address indexed from, address indexed to);
    
    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns(address) {

        return owner;
    }

    modifier onlyOwner {

        require(msg.sender == owner, "Function restricted to owner of contract");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        require(
            _newOwner != address(0)
            && _newOwner != owner 
        );
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}



abstract contract DeprecatedMultisenderSC {
    function isPremiumMember(address _who) external virtual view returns(bool);
}

abstract contract ERC20Interface {
    function transferFrom(address _from, address _to, uint256 _value) public virtual;
    function balanceOf(address who)  public virtual returns (uint256);
    function allowance(address owner, address spender)  public view virtual returns (uint256);
    function transfer(address to, uint256 value) public virtual returns(bool);
    function gasOptimizedAirdrop(address[] calldata _addrs, uint256[] calldata _values) external virtual; 
}

abstract contract ERC721Interface {
    function transferFrom(address _from, address _to, uint256 _tokenId) public virtual;
    function balanceOf(address who)  public virtual returns (uint256);
    function isApprovedForAll(address _owner, address _operator) public view virtual returns(bool);
    function setApprovalForAll(address _operator, bool approved) public virtual;
    function gasOptimizedAirdrop(address _invoker, address[] calldata _addrs, uint256[] calldata _tokenIds) external virtual;
}


abstract contract ERC1155Interface {
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, uint256 _amount, bytes memory data) public virtual;
    function balanceOf(address _who, uint256 _id)  public virtual returns (uint256);
    function isApprovedForAll(address _owner, address _operator) public view virtual returns(bool);
    function setApprovalForAll(address _operator, bool approved) public virtual;
    function gasOptimizedAirdrop(address _invoker, address[] calldata _addrs, uint256[] calldata _tokenIds, uint256[] calldata _amounts) external virtual;
}



contract CryptoMultisender is Ownable {

 
    mapping (address => uint256) public tokenTrialDrops;
    mapping (address => uint256) public userTrialDrops;

    mapping (address => uint256) public premiumMembershipDiscount;
    mapping (address => uint256) public membershipExpiryTime;

    mapping (address => bool) public isGrantedPremiumMember;

    mapping (address => bool) public isListedToken;
    mapping (address => uint256) public tokenListingFeeDiscount;

    mapping (address => bool) public isGrantedListedToken;

    mapping (address => bool) public isAffiliate;
    mapping (string => address) public affiliateCodeToAddr;
    mapping (string => bool) public affiliateCodeExists;
    mapping (address => string) public affiliateCodeOfAddr;
    mapping (address => string) public isAffiliatedWith;
    mapping (string => uint256) public commissionPercentage;

    uint256 public oneDayMembershipFee;
    uint256 public sevenDayMembershipFee;
    uint256 public oneMonthMembershipFee;
    uint256 public lifetimeMembershipFee;
    uint256 public tokenListingFee;
    uint256 public rate;
    uint256 public dropUnitPrice;
    address public deprecatedMultisenderAddress;

    event TokenAirdrop(address indexed by, address indexed tokenAddress, uint256 totalTransfers);
    event EthAirdrop(address indexed by, uint256 totalTransfers, uint256 ethValue);
    event NftAirdrop(address indexed by, address indexed nftAddress, uint256 totalTransfers);
    event RateChanged(uint256 from, uint256 to);
    event RefundIssued(address indexed to, uint256 totalWei);
    event ERC20TokensWithdrawn(address token, address sentTo, uint256 value);
    event CommissionPaid(address indexed to, uint256 value);
    event NewPremiumMembership(address indexed premiumMember);
    event NewAffiliatePartnership(address indexed newAffiliate, string indexed affiliateCode);
    event AffiliatePartnershipRevoked(address indexed affiliate, string indexed affiliateCode);
    
    constructor() {
        rate = 3000;
        dropUnitPrice = 333333333333333; 
        oneDayMembershipFee = 9e17;
        sevenDayMembershipFee = 125e16;
        oneMonthMembershipFee = 2e18;
        lifetimeMembershipFee = 25e17;
        tokenListingFee = 5e18;
        deprecatedMultisenderAddress=address(0xF521007C7845590C6c5ae46833DEFa0A68883CD4);
    }

    function setMembershipFees(uint256 _oneDayFee, uint256 _sevenDayFee, uint256 _oneMonthFee, uint256 _lifetimeFee) public onlyOwner returns(bool success) {

        require(_oneDayFee>0 && _oneDayFee<_sevenDayFee && _sevenDayFee<_oneMonthFee && _oneMonthFee<_lifetimeFee);
        oneDayMembershipFee = _oneDayFee;
        sevenDayMembershipFee = _sevenDayFee;
        oneMonthMembershipFee = _oneMonthFee;
        lifetimeMembershipFee = _lifetimeFee;
        return true;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function giveChange(uint256 _price) internal {

        if(msg.value > _price) {
            uint256 change = msg.value - _price;
            payable(msg.sender).transfer(change);
        }
    }
    
    function processAffiliateCode(string memory _afCode) internal returns(string memory code) {

        if(stringsAreEqual(isAffiliatedWith[msg.sender], "void") || !isAffiliate[affiliateCodeToAddr[_afCode]]) {
            isAffiliatedWith[msg.sender] = "void";
            return "void";
        }
        if(!stringsAreEqual(_afCode, "") && stringsAreEqual(isAffiliatedWith[msg.sender],"") 
                                                                && affiliateCodeExists[_afCode]) {
            if(affiliateCodeToAddr[_afCode] == msg.sender) {
                return "void";
            }
            isAffiliatedWith[msg.sender] = _afCode;
        }
        if(stringsAreEqual(_afCode,"") && !stringsAreEqual(isAffiliatedWith[msg.sender],"")) {
            _afCode = isAffiliatedWith[msg.sender];
        } 
        if(stringsAreEqual(_afCode,"") || !affiliateCodeExists[_afCode]) {
            isAffiliatedWith[msg.sender] = "void";
            _afCode = "void";
        }
        return _afCode;
    }

    function checkIsPremiumMember(address _addr) public view returns(bool isMember) {

        return membershipExpiryTime[_addr] >= block.timestamp || isGrantedPremiumMember[_addr];
    }

    function grantPremiumMembership(address _addr) public onlyOwner returns(bool success) {

        require(checkIsPremiumMember(_addr) != true, "Is already premiumMember member");
        isGrantedPremiumMember[_addr] = true;
        emit NewPremiumMembership(_addr);
        return true; 
    }

    function revokeGrantedPremiumMembership(address _addr) public onlyOwner returns(bool success) {

        require(isGrantedPremiumMember[_addr], "Not a granted membership");
        isGrantedPremiumMember[_addr] = false;
        return true;
    }

    function setPremiumMembershipDiscount(address _addr, uint256 _discount) public onlyOwner returns(bool success) {

        premiumMembershipDiscount[_addr] = _discount;
        return true;
    }

    function getPremiumMembershipFeeOfUser(address _addr, uint256 _fee) public view returns(uint256 fee) {

        if(premiumMembershipDiscount[_addr] > 0) {
            return _fee * premiumMembershipDiscount[_addr] / 100;
        }
        return _fee;
    }



    function setDeprecatedMultisenderAddress(address _addr) public onlyOwner {

        deprecatedMultisenderAddress = _addr;
    }


    function isMemberOfOldMultisender(address _who) public view returns(bool) {

        DeprecatedMultisenderSC oldMultisender = DeprecatedMultisenderSC(deprecatedMultisenderAddress);
        return oldMultisender.isPremiumMember(_who);
    }


    function transferMembership() public returns(bool) {

        require(isMemberOfOldMultisender(msg.sender), "No membership to transfer");
        membershipExpiryTime[msg.sender] = block.timestamp + (36500 * 1 days);
        return true;
    }
    

    function assignMembership(uint256 _days, uint256 _fee, string memory _afCode) internal returns(bool success) {

        require(checkIsPremiumMember(msg.sender) != true, "Is already premiumMember member");
        uint256 fee = getPremiumMembershipFeeOfUser(msg.sender, _fee);
        require(
            msg.value >= fee,
            string(abi.encodePacked(
                "premiumMember fee is: ", uint2str(fee), ". Not enough funds sent. ", uint2str(msg.value)
            ))
        );
        membershipExpiryTime[msg.sender] = block.timestamp + (_days * 1 days);
        _afCode = processAffiliateCode(_afCode);
        giveChange(fee);
        distributeCommission(fee, _afCode);
        emit NewPremiumMembership(msg.sender);
        return true; 
    }

    function becomeLifetimeMember(string memory _afCode) public payable returns(bool success) {

        assignMembership(36500, lifetimeMembershipFee, _afCode);
        return true;
    }


    function becomeOneDayMember(string memory _afCode) public payable returns(bool success) {

        assignMembership(1, oneDayMembershipFee, _afCode);
        return true;
    }


    function becomeOneWeekMember(string memory _afCode) public payable returns(bool success) {

        assignMembership(7, sevenDayMembershipFee, _afCode);
        return true;
    }


    function becomeOneMonthMember(string memory _afCode) public payable returns(bool success) {

        assignMembership(31, oneMonthMembershipFee, _afCode);
        return true;
    }


    function checkIsListedToken(address _tokenAddr) public view returns(bool isListed) {

        return isListedToken[_tokenAddr] || isGrantedListedToken[_tokenAddr];
    }


    function setTokenListingFeeDiscount(address _tokenAddr, uint256 _discount) public onlyOwner returns(bool success) {

        tokenListingFeeDiscount[_tokenAddr] = _discount;
        return true;
    }

    function getListingFeeForToken(address _tokenAddr) public view returns(uint256 fee) {

        if(tokenListingFeeDiscount[_tokenAddr] > 0) {
            return tokenListingFee * tokenListingFeeDiscount[_tokenAddr] / 100;
        }
        return tokenListingFee;
    }

    function purchaseTokenListing(address _tokenAddr, string memory _afCode) public payable returns(bool success) {

        require(!checkIsListedToken(_tokenAddr), "Token is already listed");
        _afCode = processAffiliateCode(_afCode);
        uint256 fee = getListingFeeForToken(_tokenAddr);
        require(msg.value >= fee, "Not enough funds sent for listing");
        isListedToken[_tokenAddr] = true;
        giveChange(fee);
        distributeCommission(fee, _afCode);
        return true;
    }

    function revokeGrantedTokenListing(address _tokenAddr) public onlyOwner returns(bool success) {

        require(checkIsListedToken(_tokenAddr), "Is not listed token");
        isGrantedListedToken[_tokenAddr] = false;
        return  true;
    }


    function grantTokenListing(address _tokenAddr) public onlyOwner returns(bool success){

        require(!checkIsListedToken(_tokenAddr), "Token is already listed");
        isGrantedListedToken[_tokenAddr] = true;
        return true;
    }

    function setTokenListingFee(uint256 _newFee) public onlyOwner returns(bool success){

        tokenListingFee = _newFee;
        return true;
    }
    
    function addAffiliate(address _addr, string memory _code, uint256 _percentage) public onlyOwner returns(bool success) {

        require(!isAffiliate[_addr], "Address is already an affiliate.");
        require(_addr != address(0), "0x00 address not allowed");
        require(!affiliateCodeExists[_code], "Affiliate code already exists!");
        require(_percentage <= 100 && _percentage > 0, "Percentage must be > 0 && <= 100");
        affiliateCodeExists[_code] = true;
        isAffiliate[_addr] = true;
        affiliateCodeToAddr[_code] = _addr;
        affiliateCodeOfAddr[_addr] = _code;
        commissionPercentage[_code] = _percentage;
        emit NewAffiliatePartnership(_addr,_code);
        return true;
    }


    function changeAffiliatePercentage(address _addressOfAffiliate, uint256 _percentage) public onlyOwner returns(bool success) { 

        require(isAffiliate[_addressOfAffiliate]);
        string storage affCode = affiliateCodeOfAddr[_addressOfAffiliate];
        commissionPercentage[affCode] = _percentage;
        return true;
    }

    function removeAffiliate(address _addr) public onlyOwner returns(bool success) {

        require(isAffiliate[_addr]);
        isAffiliate[_addr] = false;
        affiliateCodeToAddr[affiliateCodeOfAddr[_addr]] = address(0);
        emit AffiliatePartnershipRevoked(_addr, affiliateCodeOfAddr[_addr]);
        affiliateCodeOfAddr[_addr] = "No longer an affiliate partner";
        return true;
    }
    
    function tokenHasFreeTrial(address _addressOfToken) public view returns(bool hasFreeTrial) {

        return tokenTrialDrops[_addressOfToken] < 100;
    }


    function userHasFreeTrial(address _addressOfUser) public view returns(bool hasFreeTrial) {

        return userTrialDrops[_addressOfUser] < 100;
    }
    
    function getRemainingTokenTrialDrops(address _addressOfToken) public view returns(uint256 remainingTrialDrops) {

        if(tokenHasFreeTrial(_addressOfToken)) {
            uint256 maxTrialDrops =  100;
            return maxTrialDrops - tokenTrialDrops[_addressOfToken];
        } 
        return 0;
    }

    function getRemainingUserTrialDrops(address _addressOfUser) public view returns(uint256 remainingTrialDrops) {

        if(userHasFreeTrial(_addressOfUser)) {
            uint256 maxTrialDrops =  100;
            return maxTrialDrops - userTrialDrops[_addressOfUser];
        }
        return 0;
    }
    
    function setRate(uint256 _newRate) public onlyOwner returns(bool success) {

        require(
            _newRate != rate 
            && _newRate > 0
        );
        emit RateChanged(rate, _newRate);
        rate = _newRate;
        uint256 eth = 1 ether;
        dropUnitPrice = eth / rate;
        return true;
    }
    
    function getTokenAllowance(address _addr, address _addressOfToken) public view returns(uint256 allowance) {

        ERC20Interface token = ERC20Interface(_addressOfToken);
        return token.allowance(_addr, address(this));
    }
    
    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
    }
    
    function stringsAreEqual(string memory _a, string memory _b) internal pure returns(bool areEqual) {

        bytes32 hashA = keccak256(abi.encodePacked(_a));
        bytes32 hashB = keccak256(abi.encodePacked(_b));
        return hashA == hashB;
    }
    
    function airdropNativeCurrency(address[] memory _recipients, uint256[] memory _values, uint256 _totalToSend, string memory _afCode) public payable returns(bool success) {

        require(_recipients.length == _values.length, "Total number of recipients and values are not equal");
        uint256 totalEthValue = _totalToSend;
        uint256 price = _recipients.length * dropUnitPrice;
        uint256 totalCost = totalEthValue + price;
        bool userHasTrial = userHasFreeTrial(msg.sender);
        bool isVIP = checkIsPremiumMember(msg.sender) == true;
        require(
            msg.value >= totalCost || isVIP || userHasTrial, 
            "Not enough funds sent with transaction!"
        );
        _afCode = processAffiliateCode(_afCode);
        if(!isVIP && !userHasTrial) {
            distributeCommission(price, _afCode);
        }
        if((isVIP || userHasTrial) && msg.value > _totalToSend) {
            payable(msg.sender).transfer((msg.value) - _totalToSend);
        } else {
            giveChange(totalCost);
        }
        for(uint i = 0; i < _recipients.length; i++) {
            payable(_recipients[i]).transfer(_values[i]);
        }
        if(userHasTrial) {
            userTrialDrops[msg.sender] = userTrialDrops[msg.sender] + _recipients.length;
        }
        emit EthAirdrop(msg.sender, _recipients.length, totalEthValue);
        return true;
    }

    function erc20Airdrop(address _addressOfToken,  address[] memory _recipients, uint256[] memory _values, uint256 _totalToSend, bool _isDeflationary, bool _optimized, string memory _afCode) public payable returns(bool success) {

        string memory afCode = processAffiliateCode(_afCode);
        ERC20Interface token = ERC20Interface(_addressOfToken);
        require(_recipients.length == _values.length, "Total number of recipients and values are not equal");
        uint256 price = _recipients.length * dropUnitPrice;
        bool isPremiumOrListed = checkIsPremiumMember(msg.sender) || checkIsListedToken(_addressOfToken);
        bool eligibleForFreeTrial = tokenHasFreeTrial(_addressOfToken) && userHasFreeTrial(msg.sender);
        require(
            msg.value >= price || tokenHasFreeTrial(_addressOfToken) || userHasFreeTrial(msg.sender) || isPremiumOrListed,
            "Not enough funds sent with transaction!"
        );
        if((eligibleForFreeTrial || isPremiumOrListed) && msg.value > 0) {
            payable(msg.sender).transfer(msg.value);
        } else {
            giveChange(price);
        }

        if(_optimized) {
            token.transferFrom(msg.sender, address(this), _totalToSend);
            token.gasOptimizedAirdrop(_recipients,_values);
        } else {
            if(!_isDeflationary) {
                token.transferFrom(msg.sender, address(this), _totalToSend);
                for(uint i = 0; i < _recipients.length; i++) {
                    token.transfer(_recipients[i], _values[i]);
                }
                if(token.balanceOf(address(this)) > 0) {
                    token.transfer(msg.sender,token.balanceOf(address(this)));
                }
            } else {
                for(uint i=0; i < _recipients.length; i++) {
                    token.transferFrom(msg.sender, _recipients[i], _values[i]);
                }
            }
        }

        if(tokenHasFreeTrial(_addressOfToken)) {
            tokenTrialDrops[_addressOfToken] = tokenTrialDrops[_addressOfToken] + _recipients.length;
        }
        if(userHasFreeTrial(msg.sender)) {
            userTrialDrops[msg.sender] = userTrialDrops[msg.sender] + _recipients.length;
        }
        if(!eligibleForFreeTrial && !isPremiumOrListed) {
            distributeCommission(_recipients.length * dropUnitPrice, afCode);
        }
        emit TokenAirdrop(msg.sender, _addressOfToken, _recipients.length);
        return true;
    }


    function erc721Airdrop(address _addressOfNFT, address[] memory _recipients, uint256[] memory _tokenIds, bool _optimized, string memory _afCode) public payable returns(bool success) {

        require(_recipients.length == _tokenIds.length, "Total number of recipients and total number of NFT IDs are not the same");
        string memory afCode = processAffiliateCode(_afCode);
        ERC721Interface erc721 = ERC721Interface(_addressOfNFT);
        uint256 price = _recipients.length * dropUnitPrice;
        bool isPremiumOrListed = checkIsPremiumMember(msg.sender) || checkIsListedToken(_addressOfNFT);
        bool eligibleForFreeTrial = tokenHasFreeTrial(_addressOfNFT) && userHasFreeTrial(msg.sender);
        require(
            msg.value >= price || eligibleForFreeTrial || isPremiumOrListed,
            "Not enough funds sent with transaction!"
        );
        if((eligibleForFreeTrial || isPremiumOrListed) && msg.value > 0) {
            payable(msg.sender).transfer(msg.value);
        } else {
            giveChange(price);
        }
        if(_optimized){
            erc721.gasOptimizedAirdrop(msg.sender,_recipients,_tokenIds);
        } else {
            for(uint i = 0; i < _recipients.length; i++) {
                erc721.transferFrom(msg.sender, _recipients[i], _tokenIds[i]);
            }
        }
        if(tokenHasFreeTrial(_addressOfNFT)) {
            tokenTrialDrops[_addressOfNFT] = tokenTrialDrops[_addressOfNFT] + _recipients.length;
        }
        if(userHasFreeTrial(msg.sender)) {
            userTrialDrops[msg.sender] = userTrialDrops[msg.sender] + _recipients.length;
        }
        if(!eligibleForFreeTrial && !isPremiumOrListed) {
            distributeCommission(_recipients.length * dropUnitPrice, afCode);
        }
        emit NftAirdrop(msg.sender, _addressOfNFT, _recipients.length);
        return true;
    }

    function erc1155Airdrop(address _addressOfNFT, address[] memory _recipients, uint256[] memory _ids, uint256[] memory _amounts, bool _optimized, string memory _afCode) public payable returns(bool success) {

        require(_recipients.length == _ids.length, "Total number of recipients and total number of NFT IDs are not the same");
        require(_recipients.length == _amounts.length, "Total number of recipients and total number of amounts are not the same");
        string memory afCode = processAffiliateCode(_afCode);
        ERC1155Interface erc1155 = ERC1155Interface(_addressOfNFT);
        uint256 price = _recipients.length * dropUnitPrice;
        bool isPremiumOrListed = checkIsPremiumMember(msg.sender) || checkIsListedToken(_addressOfNFT);
        bool eligibleForFreeTrial = tokenHasFreeTrial(_addressOfNFT) && userHasFreeTrial(msg.sender);
        require(
            msg.value >= price || eligibleForFreeTrial || isPremiumOrListed,
            "Not enough funds sent with transaction!"
        );
        if((eligibleForFreeTrial || isPremiumOrListed) && msg.value > 0) {
            payable(msg.sender).transfer(msg.value);
        } else {
            giveChange(price);
        }
        if(_optimized){
            erc1155.gasOptimizedAirdrop(msg.sender,_recipients,_ids,_amounts);
        } else {
            for(uint i = 0; i < _recipients.length; i++) {
                erc1155.safeTransferFrom(msg.sender, _recipients[i], _ids[i], _amounts[i], "");
            }
        }
        if(tokenHasFreeTrial(_addressOfNFT)) {
            tokenTrialDrops[_addressOfNFT] = tokenTrialDrops[_addressOfNFT] + _recipients.length;
        }
        if(userHasFreeTrial(msg.sender)) {
            userTrialDrops[msg.sender] = userTrialDrops[msg.sender] + _recipients.length;
        }
        if(!eligibleForFreeTrial && !isPremiumOrListed) {
            distributeCommission(_recipients.length * dropUnitPrice, afCode);
        }
        emit NftAirdrop(msg.sender, _addressOfNFT, _recipients.length);
        return true;
    }


    function distributeCommission(uint256 _profits, string memory _afCode) internal {

        if(!stringsAreEqual(_afCode,"void") && isAffiliate[affiliateCodeToAddr[_afCode]]) {
            uint256 commission = _profits * commissionPercentage[_afCode] / 100;
            payable(owner).transfer(_profits - commission);
            payable(affiliateCodeToAddr[_afCode]).transfer(commission);
            emit CommissionPaid(affiliateCodeToAddr[_afCode], commission);
        } else {
            payable(owner).transfer(_profits);
        }
    }


    function withdrawFunds() public onlyOwner returns(bool success) {

        payable(owner).transfer(address(this).balance);
        return true;
    }

    function withdrawERC20Tokens(address _addressOfToken,  address _recipient, uint256 _value) public onlyOwner returns(bool success){

        ERC20Interface token = ERC20Interface(_addressOfToken);
        token.transfer(_recipient, _value);
        emit ERC20TokensWithdrawn(_addressOfToken, _recipient, _value);
        return true;
    }

}