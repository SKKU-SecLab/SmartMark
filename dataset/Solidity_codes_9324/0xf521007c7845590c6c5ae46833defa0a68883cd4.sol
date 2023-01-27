
 
 
pragma solidity ^0.6.0;

library SafeMath {

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        
        c = a * b;
        assert(c / a == b);
        return c;
    }
    

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
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



contract Ownable {

    
    address public owner;
    
    event OwnershipTransferred(address indexed from, address indexed to);
    
    
    constructor() public {
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



abstract contract ERCInterface {
    function transferFrom(address _from, address _to, uint256 _value) public virtual;
    function balanceOf(address who)  public virtual returns (uint256);
    function allowance(address owner, address spender)  public view virtual returns (uint256);
    function transfer(address to, uint256 value) public virtual returns(bool);
}



contract CryptoMultisender is Ownable {

    
    using SafeMath for uint256;
 
    mapping (address => uint256) public tokenTrialDrops;

    mapping (address => bool) public isPremiumMember;
    mapping (address => bool) public isAffiliate;
    mapping (string => address) public affiliateCodeToAddr;
    mapping (string => bool) public affiliateCodeExists;
    mapping (address => string) public affiliateCodeOfAddr;
    mapping (address => string) public isAffiliatedWith;
        
    uint256 public premiumMemberFee;
    uint256 public rate;
    uint256 public dropUnitPrice;


    event TokenAirdrop(address indexed by, address indexed tokenAddress, uint256 totalTransfers);
    event EthAirdrop(address indexed by, uint256 totalTransfers, uint256 ethValue);


   
    event RateChanged(uint256 from, uint256 to);
    event RefundIssued(address indexed to, uint256 totalWei);
    event ERC20TokensWithdrawn(address token, address sentTo, uint256 value);
    event CommissionPaid(address indexed to, uint256 value);
    event NewPremiumMembership(address indexed premiumMember);
    event NewAffiliatePartnership(address indexed newAffiliate, string indexed affiliateCode);
    event AffiliatePartnershipRevoked(address indexed affiliate, string indexed affiliateCode);
    event PremiumMemberFeeUpdated(uint256 newFee);

    
    constructor() public {
        rate = 10000;
        dropUnitPrice = 1e14; 
        premiumMemberFee = 25e16;
    }
    

    function setPremiumMemberFee(uint256 _fee) public onlyOwner returns(bool) {

        require(_fee > 0 && _fee != premiumMemberFee);
        premiumMemberFee = _fee;
        emit PremiumMemberFeeUpdated(_fee);
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
            uint256 change = msg.value.sub(_price);
            payable(msg.sender).transfer(change);
        }
    }

    
    function processAffiliateCode(string memory _afCode) internal returns(string memory) {

        
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


    function grantPremiumMembership(address _addr) public onlyOwner returns(bool) {

        require(!isPremiumMember[_addr], "Is already premiumMember member");
        isPremiumMember[_addr] = true;
        emit NewPremiumMembership(_addr);
        return true; 
    }


    function becomePremiumMember(string memory _afCode) public payable returns(bool) {

        require(!isPremiumMember[msg.sender], "Is already premiumMember member");
        require(
            msg.value >= premiumMemberFee,
            string(abi.encodePacked(
                "premiumMember fee is: ", uint2str(premiumMemberFee), ". Not enough ETH sent. ", uint2str(msg.value)
            ))
        );
        
        isPremiumMember[msg.sender] = true;
        
        _afCode = processAffiliateCode(_afCode);

        giveChange(premiumMemberFee);
        
        if(!stringsAreEqual(_afCode,"void") && isAffiliate[affiliateCodeToAddr[_afCode]]) {
            payable(owner).transfer(premiumMemberFee.mul(80).div(100));
            uint256 commission = premiumMemberFee.mul(20).div(100);
            payable(affiliateCodeToAddr[_afCode]).transfer(commission);
            emit CommissionPaid(affiliateCodeToAddr[_afCode], commission);
        } else {
            payable(owner).transfer(premiumMemberFee);
        }
        emit NewPremiumMembership(msg.sender);
        return true; 
    }
    
    
    function addAffiliate(address _addr, string memory _code) public onlyOwner returns(bool) {

        require(!isAffiliate[_addr], "Address is already an affiliate.");
        require(_addr != address(0));
        require(!affiliateCodeExists[_code]);
        affiliateCodeExists[_code] = true;
        isAffiliate[_addr] = true;
        affiliateCodeToAddr[_code] = _addr;
        affiliateCodeOfAddr[_addr] = _code;
        emit NewAffiliatePartnership(_addr,_code);
        return true;
    }
    

    function removeAffiliate(address _addr) public onlyOwner returns(bool) {

        require(isAffiliate[_addr]);
        isAffiliate[_addr] = false;
        affiliateCodeToAddr[affiliateCodeOfAddr[_addr]] = address(0);
        emit AffiliatePartnershipRevoked(_addr, affiliateCodeOfAddr[_addr]);
        affiliateCodeOfAddr[_addr] = "No longer an affiliate partner";
        return true;
    }
    

    
    function tokenHasFreeTrial(address _addressOfToken) public view returns(bool) {

        return tokenTrialDrops[_addressOfToken] < 100;
    }
    
    
    function getRemainingTrialDrops(address _addressOfToken) public view returns(uint256) {

        if(tokenHasFreeTrial(_addressOfToken)) {
            uint256 maxTrialDrops =  100;
            return maxTrialDrops.sub(tokenTrialDrops[_addressOfToken]);
        } 
        return 0;
    }
    
    
    function setRate(uint256 _newRate) public onlyOwner returns(bool) {

        require(
            _newRate != rate 
            && _newRate > 0
        );
        emit RateChanged(rate, _newRate);
        rate = _newRate;
        uint256 eth = 1 ether;
        dropUnitPrice = eth.div(rate);
        return true;
    }
    
    

    function getTokenAllowance(address _addr, address _addressOfToken) public view returns(uint256) {

        ERCInterface token = ERCInterface(_addressOfToken);
        return token.allowance(_addr, address(this));
    }
    
    
    fallback() external payable {
        revert();
    }


    receive() external payable {
        revert();
    }
    
    
    function stringsAreEqual(string memory _a, string memory _b) internal pure returns(bool) {

        bytes32 hashA = keccak256(abi.encodePacked(_a));
        bytes32 hashB = keccak256(abi.encodePacked(_b));
        return hashA == hashB;
    }
 
    
    function singleValueEthAirrop(address[] memory _recipients, uint256 _value, string memory _afCode) public payable returns(bool) {

        
        uint256 price = _recipients.length.mul(dropUnitPrice);
        uint256 totalCost = _value.mul(_recipients.length).add(price);

        require(
            msg.value >= totalCost|| isPremiumMember[msg.sender],
            "Not enough ETH sent with transaction!"
        );

        
        _afCode = processAffiliateCode(_afCode);
        
        
        if(!isPremiumMember[msg.sender]) {
            distributeCommission(_recipients.length, _afCode);
        }

        giveChange(totalCost);
        
        for(uint i=0; i<_recipients.length; i++) {
            if(_recipients[i] != address(0)) {
                payable(_recipients[i]).transfer(_value);
            }
        }

        emit EthAirdrop(msg.sender, _recipients.length, _value.mul(_recipients.length));
        
        return true;
    }
    

    
    function _getTotalEthValue(uint256[] memory _values) internal pure returns(uint256) {

        uint256 totalVal = 0;
        for(uint i = 0; i < _values.length; i++) {
            totalVal = totalVal.add(_values[i]);
        }
        return totalVal;
    }
    
    
    function multiValueEthAirdrop(address[] memory _recipients, uint256[] memory _values, string memory _afCode) public payable returns(bool) {

        require(_recipients.length == _values.length, "Total number of recipients and values are not equal");

        uint256 totalEthValue = _getTotalEthValue(_values);
        uint256 price = _recipients.length.mul(dropUnitPrice);
        uint256 totalCost = totalEthValue.add(price);

        require(
            msg.value >= totalCost || isPremiumMember[msg.sender], 
            "Not enough ETH sent with transaction!"
        );
        
        
        _afCode = processAffiliateCode(_afCode);
        
        if(!isPremiumMember[msg.sender]) {
            distributeCommission(_recipients.length, _afCode);
        }

        giveChange(totalCost);
        
        for(uint i = 0; i < _recipients.length; i++) {
            if(_recipients[i] != address(0) && _values[i] > 0) {
                payable(_recipients[i]).transfer(_values[i]);
            }
        }
        
        emit EthAirdrop(msg.sender, _recipients.length, totalEthValue);
        return true;
    }
    
    
    function singleValueTokenAirdrop(address _addressOfToken,  address[] memory _recipients, uint256 _value, string memory _afCode) public payable returns(bool) {

        ERCInterface token = ERCInterface(_addressOfToken);

        uint256 price = _recipients.length.mul(dropUnitPrice);

        require(
            msg.value >= price || tokenHasFreeTrial(_addressOfToken) || isPremiumMember[msg.sender],
            "Not enough ETH sent with transaction!"
        );

        giveChange(price);

        _afCode = processAffiliateCode(_afCode);
        
        for(uint i = 0; i < _recipients.length; i++) {
            if(_recipients[i] != address(0)) {
                token.transferFrom(msg.sender, _recipients[i], _value);
            }
        }
        if(tokenHasFreeTrial(_addressOfToken)) {
            tokenTrialDrops[_addressOfToken] = tokenTrialDrops[_addressOfToken].add(_recipients.length);
        } else {
            if(!isPremiumMember[msg.sender]) {
                distributeCommission(_recipients.length, _afCode);
            }
            
        }

        emit TokenAirdrop(msg.sender, _addressOfToken, _recipients.length);
        return true;
    }
    
    
    function multiValueTokenAirdrop(address _addressOfToken,  address[] memory _recipients, uint256[] memory _values, string memory _afCode) public payable returns(bool) {

        ERCInterface token = ERCInterface(_addressOfToken);
        require(_recipients.length == _values.length, "Total number of recipients and values are not equal");

        uint256 price = _recipients.length.mul(dropUnitPrice);

        require(
            msg.value >= price || tokenHasFreeTrial(_addressOfToken) || isPremiumMember[msg.sender],
            "Not enough ETH sent with transaction!"
        );

        giveChange(price);
        
        _afCode = processAffiliateCode(_afCode);
        
        for(uint i = 0; i < _recipients.length; i++) {
            if(_recipients[i] != address(0) && _values[i] > 0) {
                token.transferFrom(msg.sender, _recipients[i], _values[i]);
            }
        }
        if(tokenHasFreeTrial(_addressOfToken)) {
            tokenTrialDrops[_addressOfToken] = tokenTrialDrops[_addressOfToken].add(_recipients.length);
        } else {
            if(!isPremiumMember[msg.sender]) {
                distributeCommission(_recipients.length, _afCode);
            }
        }
        emit TokenAirdrop(msg.sender, _addressOfToken, _recipients.length);
        return true;
    }
        

    function distributeCommission(uint256 _drops, string memory _afCode) internal {

        if(!stringsAreEqual(_afCode,"void") && isAffiliate[affiliateCodeToAddr[_afCode]]) {
            uint256 profitSplit = _drops.mul(dropUnitPrice).div(2);
            payable(owner).transfer(profitSplit);
            payable(affiliateCodeToAddr[_afCode]).transfer(profitSplit);
            emit CommissionPaid(affiliateCodeToAddr[_afCode], profitSplit);
        } else {
            payable(owner).transfer(_drops.mul(dropUnitPrice));
        }
    }
    
    
    

    function withdrawERC20Tokens(address _addressOfToken,  address _recipient, uint256 _value) public onlyOwner returns(bool){

        require(
            _addressOfToken != address(0)
            && _recipient != address(0)
            && _value > 0
        );
        ERCInterface token = ERCInterface(_addressOfToken);
        token.transfer(_recipient, _value);
        emit ERC20TokensWithdrawn(_addressOfToken, _recipient, _value);
        return true;
    }
}