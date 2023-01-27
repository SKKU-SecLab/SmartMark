
pragma solidity 0.4.25;

contract StandardToken {


    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

      return allowed[_owner][_spender];
    }

}


contract AltTokenFund is StandardToken {



    address public emissionContractAddress = 0x0;

    string constant public name = "Alt Token Fund";
    string constant public symbol = "ATF";
    uint8 constant public decimals = 8;

    address public owner = 0x0;
    bool public emissionEnabled = true;
    bool transfersEnabled = true;


    modifier isCrowdfundingContract() {

        if (msg.sender != emissionContractAddress) {
            revert();
        }
        _;
    }

    modifier onlyOwner() {

        if (msg.sender != owner) {
            revert();
        }
        _;
    }


    function issueTokens(address _for, uint tokenCount)
        external
        isCrowdfundingContract
        returns (bool)
    {

        if (emissionEnabled == false) {
            revert();
        }

        balances[_for] += tokenCount;
        totalSupply += tokenCount;
        return true;
    }

    function withdrawTokens(uint tokenCount)
        public
        returns (bool)
    {

        uint balance = balances[msg.sender];
        if (balance < tokenCount) {
            return false;
        }
        balances[msg.sender] -= tokenCount;
        totalSupply -= tokenCount;
        return true;
    }

    function changeEmissionContractAddress(address newAddress)
        external
        onlyOwner
    {

        emissionContractAddress = newAddress;
    }

    function enableTransfers(bool value)
        external
        onlyOwner
    {

        transfersEnabled = value;
    }

    function enableEmission(bool value)
        external
        onlyOwner
    {

        emissionEnabled = value;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (transfersEnabled == true) {
            return super.transfer(_to, _value);
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if (transfersEnabled == true) {
            return super.transferFrom(_from, _to, _value);
        }
        return false;
    }


    constructor (address _owner) public
    {
        totalSupply = 0;
        owner = _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        owner = newOwner;
    }
}

contract Fund {


  address public owner;
  address public SetPriceAccount;
  address public SetReferralAccount;

  modifier onlyOwner {

      if (msg.sender != owner) revert();
      _;
  }
  
  modifier onlySetPriceAccount {

      if (msg.sender != SetPriceAccount) revert();
      _;
  }
  
  modifier onlySetReferralAccount {

      if (msg.sender != SetReferralAccount) revert();
      _;
  }
  
    AltTokenFund public tokenFund;

    event Deposit(address indexed from, uint256 value);
    event Withdrawal(address indexed from, uint256 value);
    event AddInvestment(address indexed to, uint256 value);

    address public ethAddress;
    address public fundManagers;
    address public supportAddress;
    uint public tokenPrice = 1 finney; // 0.001 ETH
    uint public managersFee = 1;
    uint public referralFee = 3;
    uint public supportFee = 1;

    mapping (address => address) public referrals;



    function issueTokens(address _for, uint tokenCount)
    	private
    	returns (bool)
    {

    	if (tokenCount == 0) {
        return false;
      }

      uint percent = tokenCount / 100;

      if (!tokenFund.issueTokens(fundManagers, percent * managersFee)) {
        revert();
      }

      if (!tokenFund.issueTokens(supportAddress, percent * supportFee)) {
        revert();
      }

      if (referrals[_for] != 0) {
      	if (!tokenFund.issueTokens(referrals[_for], referralFee * percent)) {
          revert();
        }
      } else {
      	if (!tokenFund.issueTokens(fundManagers, referralFee * percent)) {
          revert();
        }
      }

      if (!tokenFund.issueTokens(_for, tokenCount - (referralFee+supportFee+managersFee) * percent)) {
        revert();
	    }

	    return true;
    }

    function addInvestment(address beneficiary, uint valueInWei)
        external
        onlyOwner
        returns (bool)
    {

        uint tokenCount = calculateTokens(valueInWei);
    	return issueTokens(beneficiary, tokenCount);
    }

    function fund()
        public
        payable
        returns (bool)
    {

        address beneficiary = msg.sender;
        uint tokenCount = calculateTokens(msg.value);
        uint roundedInvestment = tokenCount * tokenPrice / 100000000;

        if (msg.value > roundedInvestment && !beneficiary.send(msg.value - roundedInvestment)) {
          revert();
        }
        if (!ethAddress.send(roundedInvestment)) {
          revert();
        }
        return issueTokens(beneficiary, tokenCount);
    }

    function calculateTokens(uint valueInWei)
        public
        constant
        returns (uint)
    {

        return valueInWei * 100000000 / tokenPrice;
    }

    function estimateTokens(uint valueInWei)
        public
        constant
        returns (uint)
    {

        return valueInWei * (100000000-1000000*(referralFee+supportFee+managersFee)) / tokenPrice;
    }

    function setReferral(address client, address referral)
        public
        onlySetReferralAccount
    {

        referrals[client] = referral;
    }

    function getReferral(address client)
        public
        constant
        returns (address)
    {

        return referrals[client];
    }

    function setTokenPrice(uint valueInWei)
        public
        onlySetPriceAccount
    {

        tokenPrice = valueInWei;
    }


    function changeComissions(uint newManagersFee, uint newSupportFee, uint newReferralFee) public
        onlyOwner
    {

        managersFee = newManagersFee;
        supportFee = newSupportFee;
        referralFee = newReferralFee;
    }

    function changefundManagers(address newfundManagers) public
        onlyOwner
    {

        fundManagers = newfundManagers;
    }

    function changeEthAddress(address newEthAddress) public
        onlyOwner
    {

        ethAddress = newEthAddress;
    }

    function changeSupportAddress(address newSupportAddress) public
        onlyOwner
    {

        supportAddress = newSupportAddress;
    }
    
    function changeSetPriceAccount(address newSetPriceAccount) public
        onlyOwner
    {

        SetPriceAccount = newSetPriceAccount;
    }
    
     function changeSetReferralAccount (address newSetReferralAccount) public
        onlyOwner
    {
        SetReferralAccount = newSetReferralAccount;
    }

    function transferOwnership(address newOwner) public
      onlyOwner
    {

        owner = newOwner;
    }


    constructor (address _owner, address _SetPriceAccount, address _SetReferralAccount, address _ethAddress, address _fundManagers, address _supportAddress, address _tokenAddress)
    public
    {
        owner = _owner;
        SetPriceAccount = _SetPriceAccount;
        SetReferralAccount = _SetReferralAccount;
        ethAddress = _ethAddress;
        fundManagers = _fundManagers;
        supportAddress = _supportAddress;
        tokenFund = AltTokenFund(_tokenAddress);
    }

    function () public payable {
        fund();
    }
}